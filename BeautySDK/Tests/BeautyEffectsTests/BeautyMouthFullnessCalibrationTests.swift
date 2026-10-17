import BeautyCore
import Foundation
import XCTest
@testable import BeautyEffects

/// Synthetic source anatomy only. These checks cover configuration ownership
/// and source scaling; photographs and endpoint similarity require the native
/// reference audit, not these deterministic construction checks.
final class BeautyMouthFullnessCalibrationTests: XCTestCase {
    private typealias Point = SIMD2<Double>

    func testCalibrationTracksSourceThicknessAndResolution() throws {
        let small = try geometry(width: 240, height: 280)
        let large = try geometry(width: 480, height: 560)
        let thin = try geometry(width: 240, height: 280, upper: 0.018, lower: 0.025)
        let a = try XCTUnwrap(small.makeFullnessConfiguration())
        let b = try XCTUnwrap(large.makeFullnessConfiguration())
        let t = try XCTUnwrap(thin.makeFullnessConfiguration())
        XCTAssertEqual(a.upperRate, b.upperRate)
        XCTAssertEqual(a.lowerRate, b.lowerRate)
        XCTAssertEqual(a.envelope.innerMin.x, b.envelope.innerMin.x)
        XCTAssertEqual(a.envelope.innerMax.y, b.envelope.innerMax.y, accuracy: 1e-12)
        XCTAssertEqual(a.blendHalfWidth, b.blendHalfWidth, accuracy: 1e-12)
        XCTAssertEqual(a.blendHalfWidth / min(small.upperDepth, small.lowerDepth), 0.12, accuracy: 1e-12)
        XCTAssertLessThan(t.blendHalfWidth, a.blendHalfWidth)
        XCTAssertLessThan(t.envelope.innerMax.y, a.envelope.innerMax.y)
        // The absolute physical protection padding remains two pixels at
        // either resolution; its normalized outer top is allowed to differ.
    }

    func testCoreRatesAndLateralAndInferiorSupportAreIndependentVariants() throws {
        let g = try geometry(width: 240, height: 280)
        let base = try XCTUnwrap(g.makeFullnessConfiguration())
        var narrowed = BeautyMouthFullnessCalibration()
        narrowed.innerHalfWidth *= 0.8
        narrowed.outerHalfWidth *= 0.85
        narrowed.lowerSkinReach *= 0.65
        let variant = try XCTUnwrap(g.makeFullnessConfiguration(calibration: narrowed))
        XCTAssertEqual(base.upperRate, variant.upperRate)
        XCTAssertEqual(base.lowerRate, variant.lowerRate)
        XCTAssertEqual(base.envelope.innerMin.y, variant.envelope.innerMin.y)
        XCTAssertEqual(base.envelope.innerMax.y, variant.envelope.innerMax.y)
        XCTAssertLessThan(variant.envelope.outerMax.x, base.envelope.outerMax.x)
        XCTAssertLessThan(variant.envelope.outerMax.y, base.envelope.outerMax.y)
        var configuration = try XCTUnwrap(g.configuration())
        configuration.fullness = base
        let baseline = try XCTUnwrap(BeautyMouthReferenceModel(configuration: configuration))
        configuration.fullness = variant
        let changed = try XCTUnwrap(BeautyMouthReferenceModel(configuration: configuration))
        let seam = g.seam.sample(at: 0).value
        let core = Point(0, seam + g.lowerDepth * 0.5)
        XCTAssertEqual(baseline.sample(field: .fullness, strength: 1, at: core).displacement,
                       changed.sample(field: .fullness, strength: 1, at: core).displacement)
        let tail = Point(0, seam + (base.envelope.outerMax.y + variant.envelope.outerMax.y) * 0.5)
        XCTAssertGreaterThan(baseline.sample(field: .fullness, strength: 1, at: tail).displacement.y, 0)
        XCTAssertEqual(changed.sample(field: .fullness, strength: 1, at: tail).displacement, .zero)
    }

    func testSourceProtectionAndBothVerticalDirectionsSurviveConfiguration() throws {
        let g = try geometry(width: 240, height: 280)
        let fullness = try XCTUnwrap(g.makeFullnessConfiguration())
        var configuration = try XCTUnwrap(g.configuration())
        configuration.fullness = fullness
        let model = try XCTUnwrap(BeautyMouthReferenceModel(configuration: configuration))
        for x in [-0.2, 0.0, 0.2] {
            let seam = g.seam.sample(at: x).value
            XCTAssertLessThan(model.sample(field: .fullness, strength: 1,
                at: Point(x, seam - g.upperDepth * 0.5)).displacement.y, 0)
            XCTAssertGreaterThan(model.sample(field: .fullness, strength: 1,
                at: Point(x, seam + g.lowerDepth * 0.5)).displacement.y, 0)
            XCTAssertEqual(model.sample(field: .fullness, strength: 1,
                at: Point(x, g.protectedTop - 0.001)).displacement, .zero)
        }
    }

    func testInvalidCalibrationAbstainsRatherThanChangingItsMeaning() throws {
        let g = try geometry(width: 240, height: 280)
        var variants = [BeautyMouthFullnessCalibration]()
        var c = BeautyMouthFullnessCalibration(); c.upperRate = .nan; variants.append(c)
        c = .init(); c.lowerRate = -.infinity; variants.append(c)
        c = .init(); c.outerHalfWidth = c.innerHalfWidth; variants.append(c)
        c = .init(); c.innerHalfWidth = 0; variants.append(c)
        c = .init(); c.upperSkinReach = 0; variants.append(c)
        c = .init(); c.lowerSkinReach = -0.1; variants.append(c)
        c = .init(); c.depthCurvature = -0.1; variants.append(c)
        c = .init(); c.depthCurvature = 1.1; variants.append(c)
        c = .init(); c.depthCurvature = .nan; variants.append(c)
        c = .init(); c.upperWidthScale = 0.9; variants.append(c)
        c = .init(); c.upperWidthScale = 1.7; variants.append(c)
        c = .init(); c.upperWidthScale = .nan; variants.append(c)
        for variant in variants { XCTAssertNil(g.makeFullnessConfiguration(calibration: variant)) }
    }

    func testDepthCurvatureSuppressesInteriorButRecoversObservedSourceDepth() throws {
        let g = try geometry(width: 360, height: 420)
        var configuration = try XCTUnwrap(g.configuration())
        configuration.fullness = try XCTUnwrap(g.makeFullnessConfiguration(calibration: .init(depthCurvature: 0)))
        let linear = try XCTUnwrap(BeautyMouthReferenceModel(configuration: configuration))
        configuration.fullness = try XCTUnwrap(g.makeFullnessConfiguration(calibration: .init(depthCurvature: 0.8)))
        let curved = try XCTUnwrap(BeautyMouthReferenceModel(configuration: configuration))
        XCTAssertEqual(configuration.fullness.upperDepth, g.upperDepth)
        XCTAssertEqual(configuration.fullness.lowerDepth, g.lowerDepth)
        let seam = g.seam.sample(at: 0).value
        for depth in [-g.upperDepth, g.lowerDepth] {
            let inner = Point(0,seam + depth * 0.2)
            let edge = Point(0,seam + depth)
            let a = linear.sample(field: .fullness, strength: 1, at: inner).displacement.y
            let b = curved.sample(field: .fullness, strength: 1, at: inner).displacement.y
            XCTAssertGreaterThan(abs(a), 0)
            XCTAssertEqual(b / a, 0.2 + 0.8 * (0.2 * 0.2 * (3 - 2 * 0.2)), accuracy: 1e-11)
            XCTAssertEqual(linear.sample(field: .fullness, strength: 1, at: edge).displacement.y,
                           curved.sample(field: .fullness, strength: 1, at: edge).displacement.y, accuracy: 1e-12)
            XCTAssertEqual(a.sign, b.sign)
        }
    }

    func testUpperWidthAddsUpperLateralResponseWithoutWideningTheLowerField() throws {
        let g = try geometry(width: 360, height: 420)
        var configuration = try XCTUnwrap(g.configuration())
        var calibration = BeautyMouthFullnessCalibration(innerHalfWidth: 0.20, outerHalfWidth: 0.40,
            upperWidthScale: 1)
        configuration.fullness = try XCTUnwrap(g.makeFullnessConfiguration(calibration: calibration))
        let shared = try XCTUnwrap(BeautyMouthReferenceModel(configuration: configuration))
        calibration.upperWidthScale = 1.4
        configuration.fullness = try XCTUnwrap(g.makeFullnessConfiguration(calibration: calibration))
        let expanded = try XCTUnwrap(BeautyMouthReferenceModel(configuration: configuration))
        let upperEnvelope = try XCTUnwrap(configuration.fullness.upperEnvelope)
        let sourceEnvelope = try XCTUnwrap(configuration.fullness.sourceEnvelope)
        XCTAssertEqual(upperEnvelope.innerMin.y, configuration.fullness.envelope.innerMin.y)
        XCTAssertEqual(upperEnvelope.outerMax.y, configuration.fullness.envelope.outerMax.y)
        XCTAssertLessThanOrEqual(sourceEnvelope.innerMin.x, upperEnvelope.outerMin.x)
        XCTAssertGreaterThanOrEqual(sourceEnvelope.innerMax.x, upperEnvelope.outerMax.x,
            "Absolute protection cannot clip the newly widened upper support")
        let seam = g.seam.sample(at: 0.45).value
        let upper = Point(0.45,seam - g.upperDepth * 0.5)
        let lower = Point(0.45,seam + g.lowerDepth * 0.5)
        XCTAssertEqual(shared.sample(field: .fullness, strength: 1, at: upper).displacement, .zero)
        XCTAssertLessThan(expanded.sample(field: .fullness, strength: 1, at: upper).displacement.y, 0)
        XCTAssertEqual(shared.sample(field: .fullness, strength: 1, at: lower).displacement, .zero)
        XCTAssertEqual(expanded.sample(field: .fullness, strength: 1, at: lower).displacement, .zero)
        for x in [-0.15,0,0.15] {
            let p = Point(x,g.seam.sample(at: x).value + g.lowerDepth * 0.5)
            XCTAssertEqual(shared.sample(field: .fullness, strength: 1, at: p).displacement,
                           expanded.sample(field: .fullness, strength: 1, at: p).displacement)
        }
    }

    func testCurvedSeamSkinBelowAbsoluteProtectionCanMoveAboveTheOldRelativeFloor() throws {
        let g = try geometry(width: 360, height: 420, seamSag: 0.03, noseBottom: 0.59)
        let fullness = try XCTUnwrap(g.makeFullnessConfiguration())
        let source = try XCTUnwrap(fullness.sourceEnvelope)
        let seam = g.seam.sample(at: 0).value
        let oldFloor = g.protectedTop - g.seam.minimumValue
        let oldAbsoluteCutoff = seam + oldFloor
        XCTAssertGreaterThan(oldAbsoluteCutoff, g.protectedTop)
        let p = Point(0, g.protectedTop + (min(g.top, oldAbsoluteCutoff) - g.protectedTop) * 0.5)
        XCTAssertGreaterThan(p.y, g.protectedTop)
        XCTAssertLessThan(p.y - seam, oldFloor)
        XCTAssertGreaterThan(source.innerMin.y - source.outerMin.y, (g.top - g.protectedTop) * 0.70,
            "The available source gap supplies a finite transition, not an epsilon clamp")
        var configuration = try XCTUnwrap(g.configuration())
        configuration.fullness = fullness
        let corrected = try XCTUnwrap(BeautyMouthReferenceModel(configuration: configuration))
        XCTAssertLessThan(corrected.sample(field: .fullness, strength: 1, at: p).displacement.y, 0)
        var legacy = fullness
        legacy.sourceEnvelope = nil
        // The old model had one common envelope. Do not retain the new
        // upper copy while changing only the legacy shared Y support below.
        legacy.upperEnvelope = nil
        legacy.depthCurvature = 0
        legacy.envelope.outerMin.y = max(legacy.envelope.outerMin.y, oldFloor)
        legacy.envelope.innerMin.y = max(legacy.envelope.innerMin.y, legacy.envelope.outerMin.y + 0.0001)
        configuration.fullness = legacy
        let previous = try XCTUnwrap(BeautyMouthReferenceModel(configuration: configuration))
        XCTAssertEqual(previous.sample(field: .fullness, strength: 1, at: p).displacement, .zero)
        for x in [-0.4, -0.2, 0, 0.2, 0.4] {
            for y in [g.protectedTop - 0.01, g.protectedTop] {
                XCTAssertEqual(corrected.sample(field: .fullness, strength: 1, at: Point(x,y)).displacement, .zero)
            }
        }
    }

    func testAbsoluteProtectionProductKeepsBothAnalyticGradientColumns() throws {
        let g = try geometry(width: 360, height: 420, seamSag: 0.03, noseBottom: 0.59)
        var configuration = try XCTUnwrap(g.configuration())
        configuration.fullness = try XCTUnwrap(g.makeFullnessConfiguration())
        let model = try XCTUnwrap(BeautyMouthReferenceModel(configuration: configuration))
        let step = 1e-6
        for x in [-0.18, 0.08, 0.23] {
            let p = Point(x, g.protectedTop + (g.top - g.protectedTop) * 0.4)
            let sample = model.sample(field: .fullness, strength: 1, at: p)
            let left = model.sample(field: .fullness, strength: 1, at: p - Point(step,0)).displacement
            let right = model.sample(field: .fullness, strength: 1, at: p + Point(step,0)).displacement
            let above = model.sample(field: .fullness, strength: 1, at: p - Point(0,step)).displacement
            let below = model.sample(field: .fullness, strength: 1, at: p + Point(0,step)).displacement
            XCTAssertEqual(sample.gradientX.y, (right.y - left.y) / (2 * step), accuracy: 2e-7)
            XCTAssertEqual(sample.gradientY.y, (below.y - above.y) / (2 * step), accuracy: 2e-7)
        }
    }

    private func geometry(width: Int, height: Int,
                          upper: Double = 0.035, lower: Double = 0.045,
                          seamSag: Double = 0, noseBottom: Float = 0.49) throws -> BeautyMouthReferenceGeometry {
        let count = 25
        let upperTrace = (0..<count).map { i -> SIMD2<Float> in
            let x = -1 + 2 * Double(i) / Double(count - 1)
            return SIMD2(Float(0.5 + 0.18 * x), Float(0.65 + seamSag * (1 - x * x) - upper * sqrt(max(0, 1 - x * x))))
        }
        let lowerTrace = (1..<(count - 1)).reversed().map { i -> SIMD2<Float> in
            let x = -1 + 2 * Double(i) / Double(count - 1)
            return SIMD2(Float(0.5 + 0.18 * x), Float(0.65 + seamSag * (1 - x * x) + lower * sqrt(max(0, 1 - x * x))))
        }
        let outer = upperTrace + lowerTrace
        let inner = (0..<20).map { i -> SIMD2<Float> in
            let a = Double(i) * Double.pi / 10
            let x = 0.14 * cos(a), r = x / 0.18
            return SIMD2(Float(0.5 + x), Float(0.65 + seamSag * (1 - r * r) + 0.005 * sin(a)))
        }
        func box(_ x: Float, _ y: Float) -> [SIMD2<Float>] {
            [SIMD2(x,y),SIMD2(x+0.10,y),SIMD2(x+0.10,y+0.04),SIMD2(x,y+0.04)]
        }
        let face = FaceGeometry(bounds: .init(x: 0.18, y: 0.1, width: 0.64, height: 0.82),
            faceContour: [], leftEye: box(0.28,0.30), rightEye: box(0.60,0.30),
            nose: box(0.45,noseBottom - 0.04), outerLips: outer, upperLips: upperTrace,
            lowerLips: lowerTrace, innerLips: inner,
            observedOuterLips: outer, observedInnerLips: inner)
        return try XCTUnwrap(BeautyMouthReferenceGeometry(width: width, height: height, face: face))
    }
}
