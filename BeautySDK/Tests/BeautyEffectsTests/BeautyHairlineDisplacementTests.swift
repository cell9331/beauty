import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Synthetic source qualification and field invariants, not appearance or a
/// reference-app match. Actual source endpoint comparisons are retained locally.
final class BeautyHairlineDisplacementTests: XCTestCase {
    private let width = 600
    private let height = 700
    private let origin = SIMD2(300.0, 350.0)
    private let scale = 100.0

    private func face(freshness: LandmarkGeometryFreshness = .fresh,
                      observedBrows: Bool = true, angle: Double = 0,
                      fixtureScale: Double? = nil) -> FaceGeometry {
        let pixelScale = fixtureScale ?? scale
        let xAxis = SIMD2(cos(angle), sin(angle)), yAxis = SIMD2(-sin(angle), cos(angle))
        func point(_ p: SIMD2<Double>) -> SIMD2<Float> {
            let image = origin + pixelScale * (xAxis * p.x + yAxis * p.y)
            return SIMD2(Float((image.x + 0.5) / Double(width)), Float((image.y + 0.5) / Double(height)))
        }
        func box(_ center: SIMD2<Double>, _ radius: SIMD2<Double>) -> [SIMD2<Float>] {
            [center + SIMD2(-radius.x, -radius.y), center + SIMD2(radius.x, -radius.y),
             center + SIMD2(radius.x, radius.y), center + SIMD2(-radius.x, radius.y)].map(point)
        }
        let contour = (0..<21).map { index in
            point(SIMD2(-1.10 * cos(Double(index) / 20 * .pi), 1.80 * sin(Double(index) / 20 * .pi)))
        }
        func eye(_ side: BeautyObservedEyeSide, _ center: SIMD2<Double>) -> BeautyEyeSemanticSupport {
            let path = box(center, SIMD2(0.22, 0.085))
            return BeautyEyeSemanticSupport(side: side, contour: path,
                upper: Array(path.prefix(2)), lower: Array(path.suffix(2)), inner: [path[0]], outer: [path[1]],
                corners: [path[0], path[1]], center: point(center), pupil: point(center),
                span: SIMD2(0.074, 0.025), tilt: 0)
        }
        let leftEye = eye(.left, SIMD2(-0.5, 0)), rightEye = eye(.right, SIMD2(0.5, 0))
        func brow(_ side: BeautyObservedEyebrowSide, _ sign: Double) -> BeautyEyebrowSemanticTrace {
            let path = (0...4).map { index in
                point(SIMD2(sign * (0.25 + Double(index) * 0.13), -0.30 - 0.025 * sin(Double(index) / 4 * .pi)))
            }
            return BeautyEyebrowSemanticTrace(side: side, points: path,
                innerEndpoint: path[0], outerEndpoint: path[4], center: path[2], apexIndex: 2)
        }
        let lips = box(SIMD2(0, 1.10), SIMD2(0.30, 0.08))
        return FaceGeometry(bounds: FaceBounds(x: 0.25, y: 0.25, width: 0.50, height: 0.55),
            faceContour: contour,
            observedFaceSupport: BeautyFaceSemanticSupport(contour: contour, medianLine: nil, apexIndex: 10),
            leftEye: leftEye.contour, rightEye: rightEye.contour, outerLips: lips,
            leftEyeSupport: leftEye, rightEyeSupport: rightEye, freshness: freshness,
            observedEyebrowSupport: observedBrows
                ? BeautyEyebrowSemanticSupport(left: brow(.left, -1), right: brow(.right, 1)) : nil,
            observedOuterLips: lips)
    }

    private func source(flat: Bool = false, angle: Double = 0,
                        fixtureScale: Double? = nil, patternedBackground: Bool = false) -> [UInt8] {
        let pixelScale = fixtureScale ?? scale
        let xAxis = SIMD2(cos(angle), sin(angle)), yAxis = SIMD2(-sin(angle), cos(angle))
        var source = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let delta = SIMD2(Double(x), Double(y)) - origin
            let localX = (delta.x * xAxis.x + delta.y * xAxis.y) / pixelScale
            let localY = (delta.x * yAxis.x + delta.y * yAxis.y) / pixelScale
            let i = (y * width + x) * 4
            if !flat && localY < -1.10 {
                let texture = (x * 7 + y * 3) % 13
                source[i] = UInt8(35 + texture); source[i + 1] = UInt8(28 + texture)
                source[i + 2] = UInt8(24 + texture)
            } else {
                source[i] = 205; source[i + 1] = 160; source[i + 2] = 130
            }
            if patternedBackground && abs(localX) >= 1.60 {
                // Independent high-frequency surroundings expose even a
                // subpixel field tail; they do not participate in source admission.
                source[i] = UInt8((x * 71 + y * 29) % 256)
                source[i + 1] = UInt8((x * 31 + y * 97) % 256)
                source[i + 2] = UInt8((x * 53 + y * 47) % 256)
            }
        } }
        return source
    }

    private func support() throws -> BeautyHairlineDisplacement.Support {
        let face = face()
        let geometry = try XCTUnwrap(BeautyFaceDisplacementGeometry(width: width, height: height, face: face))
        return try XCTUnwrap(BeautyHairlineDisplacement.prepare(sourceRGBA: source(), width: width,
            height: height, face: face, geometry: geometry))
    }

    func testSourceLocatedWideFieldHasDownwardAndInwardComponentsAndExactCores() throws {
        let support = try support()
        XCTAssertEqual(support.sourceBoundaryY, -1.10, accuracy: 0.04)
        let component = try XCTUnwrap(BeautyHairlineDisplacement.component(support: support, amount: 1))
        let model = try XCTUnwrap(BeautyFaceDisplacementModel(components: [component], refineGradientBound: true))
        let center = model.sample(at: SIMD2(0, -1.25)).displacement
        let left = model.sample(at: SIMD2(-0.90, -0.95)).displacement
        let right = model.sample(at: SIMD2(0.90, -0.95)).displacement
        XCTAssertGreaterThan(center.y, 0.02)
        XCTAssertEqual(center.x, 0, accuracy: 1e-14)
        XCTAssertGreaterThan(left.x, 0.005); XCTAssertGreaterThan(left.y, 0.005)
        XCTAssertLessThan(right.x, -0.005); XCTAssertGreaterThan(right.y, 0.005)
        // The upper/lower wide transitions are not a strip around one row.
        XCTAssertGreaterThan(model.sample(at: SIMD2(0, -1.55)).displacement.y, 0)
        XCTAssertGreaterThan(model.sample(at: SIMD2(0, -0.95)).displacement.y, 0)
        for point in [SIMD2(0.0, -2.5), SIMD2(0.0, 0.5), SIMD2(0.0, 1.1),
                      SIMD2(-0.5, 0), SIMD2(0.5, 0), SIMD2(-0.51, -0.325), SIMD2(0.51, -0.325)] {
            XCTAssertEqual(model.sample(at: point).displacement, .zero)
        }
    }

    func testFullDerivativeCertificateAndInverseAcrossBothSigns() throws {
        let support = try support()
        for amount in [-1.0, 1.0] {
            let component = try XCTUnwrap(BeautyHairlineDisplacement.component(support: support, amount: amount))
            let model = try XCTUnwrap(BeautyFaceDisplacementModel(components: [component], refineGradientBound: true))
            XCTAssertLessThan(model.gradientBound, 1)
            for x in stride(from: -1.8, through: 1.8, by: 0.18) {
                for y in stride(from: -2.2, through: 0.2, by: 0.16) {
                    let point = SIMD2(x, y), sample = model.sample(at: point)
                    let determinant = sample.jacobianX.x * sample.jacobianY.y - sample.jacobianX.y * sample.jacobianY.x
                    XCTAssertGreaterThan(determinant, 0)
                    let recovered = try XCTUnwrap(model.inverse(of: point + sample.displacement, tolerance: 1e-10))
                    XCTAssertEqual(recovered.x, point.x, accuracy: 2e-10)
                    XCTAssertEqual(recovered.y, point.y, accuracy: 2e-10)
                }
            }
        }
        XCTAssertNil(BeautyHairlineDisplacement.component(support: support, amount: .nan))
        XCTAssertNil(BeautyHairlineDisplacement.component(support: support, amount: 1.01))
        let zero = try XCTUnwrap(BeautyHairlineDisplacement.component(support: support, amount: 0))
        XCTAssertTrue(try XCTUnwrap(BeautyFaceDisplacementModel(components: [zero])).isIdentity)
    }

    func testSourceRefusalDoesNotInventMissingHairOrAcceptTransparentOrMalformedInput() throws {
        let validFace = face()
        let geometry = try XCTUnwrap(BeautyFaceDisplacementGeometry(width: width, height: height, face: validFace))
        XCTAssertNil(BeautyHairlineDisplacement.prepare(sourceRGBA: source(flat: true), width: width,
            height: height, face: validFace, geometry: geometry))
        XCTAssertNil(BeautyHairlineDisplacement.prepare(sourceRGBA: [], width: width,
            height: height, face: validFace, geometry: geometry))
        var transparent = source(); transparent[3] = 254
        XCTAssertNil(BeautyHairlineDisplacement.prepare(sourceRGBA: transparent, width: width,
            height: height, face: validFace, geometry: geometry))
        for invalidFace in [face(freshness: .reused), face(freshness: .stale), face(observedBrows: false)] {
            XCTAssertNil(BeautyHairlineDisplacement.prepare(sourceRGBA: source(), width: width,
                height: height, face: invalidFace, geometry: geometry))
        }
    }

    func testLateralReleaseProtectsPatternedBackgroundAtBothSignsAcrossRollAndScale() throws {
        for (angle, pixelScale) in [(-0.28, 75.0), (0.0, 100.0), (0.28, 110.0)] {
            let face = face(angle: angle, fixtureScale: pixelScale)
            let geometry = try XCTUnwrap(BeautyFaceDisplacementGeometry(width: width, height: height, face: face))
            let source = source(angle: angle, fixtureScale: pixelScale, patternedBackground: true)
            let support = try XCTUnwrap(BeautyHairlineDisplacement.prepare(sourceRGBA: source,
                width: width, height: height, face: face, geometry: geometry))
            for sign: Float in [-1, 1] {
                let component = try XCTUnwrap(BeautyHairlineDisplacement.component(support: support, amount: Double(sign)))
                let model = try XCTUnwrap(BeautyFaceDisplacementModel(components: [component], refineGradientBound: true))
                XCTAssertLessThan(model.gradientBound, 1)
                XCTAssertEqual(model.amplitudeScale, 1, accuracy: 1e-12)
                XCTAssertGreaterThan(model.sample(at: SIMD2(0, -1.25)).displacement.y * Double(sign), 0.02)
                XCTAssertGreaterThan(model.sample(at: SIMD2(-0.9, -0.95)).displacement.x * Double(sign), 0.005)
                XCTAssertLessThan(model.sample(at: SIMD2(0.9, -0.95)).displacement.x * Double(sign), -0.005)
                var strengths = BeautyEffectiveStrengths()
                strengths.hairlineHeight = sign * BeautySafetyCaps.hairlineHeight
                let map = try XCTUnwrap(BeautyFaceDisplacementMap(width: width, height: height,
                    face: face, strengths: strengths, sourceRGBA: source))
                let output = map.applyRGBA(source)
                XCTAssertNotEqual(output, source, "the test must exercise a live two-dimensional effect")
                var compared = 0, changed = 0
                for y in 0..<height { for x in 0..<width {
                    let p = SIMD2(Double(x), Double(y)), local = geometry.local(p)
                    guard abs(local.x) >= 1.60 else { continue }
                    XCTAssertEqual(model.sample(at: local).displacement, .zero)
                    let i = (y * width + x) * 4
                    compared += 1
                    if (0..<4).contains(where: { source[i + $0] != output[i + $0] }) { changed += 1 }
                } }
                XCTAssertGreaterThan(compared, 10_000)
                XCTAssertEqual(changed, 0, "source-fixed surroundings must remain byte-exact after inverse sampling")
            }
        }
    }

    func testLateralProtectionRemovesAFormerTailWithoutFlatteningItsInnerTransition() throws {
        let support = try support()
        let geometry = try XCTUnwrap(BeautyFaceDisplacementGeometry(width: width, height: height, face: face()))
        let component = try XCTUnwrap(BeautyHairlineDisplacement.component(support: support, amount: 1))
        let model = try XCTUnwrap(BeautyFaceDisplacementModel(components: [component], refineGradientBound: true))
        // This independent raw affine window is a negative control: compact
        // tangent windows alone still carry a nonzero outer-background tail.
        let angle = 0.71, radius = -support.sourceBoundaryY + 0.10
        let rawWindow = BeautyFaceDisplacementModel.Window(
            center: SIMD2(radius * sin(angle), -radius * cos(angle)),
            axisX: SIMD2(cos(angle), sin(angle)), axisY: SIMD2(-sin(angle), cos(angle)),
            radius: SIMD2(1.0, 0.59))
        let raw = try XCTUnwrap(BeautyFaceDisplacementModel(modes: [
            .affine(weight: rawWindow, anchor: .zero, scale: SIMD2(repeating: -0.046 * 0.76), translation: .zero)
        ], protections: [], refineGradientBound: true))
        let outer = SIMD2(1.65, -0.80)
        XCTAssertGreaterThan(hypot(raw.sample(at: outer).displacement.x, raw.sample(at: outer).displacement.y), 0)
        XCTAssertEqual(model.sample(at: outer).displacement, .zero)
        // The new product and its complete derivative join exact identity at
        // the source contour +/-0.40 boundary, with a finite C² transition.
        for side in [-1.0, 1.0] {
            let contourEdge = side < 0 ? geometry.normalizedContour.map(\.x).min()!
                                       : geometry.normalizedContour.map(\.x).max()!
            for y in [-1.2, -0.95, -0.70] {
                let edge = SIMD2(contourEdge + side * 0.40, y)
                XCTAssertEqual(model.sample(at: edge).displacement, .zero)
                let near = model.sample(at: edge - SIMD2(side * 1e-5, 0))
                XCTAssertLessThan(hypot(near.displacement.x, near.displacement.y), 1e-12)
                XCTAssertLessThan(hypot(near.derivativeX.x, near.derivativeX.y), 1e-8)
            }
        }
        XCTAssertGreaterThan(hypot(model.sample(at: SIMD2(1.35, -0.95)).displacement.x,
                                   model.sample(at: SIMD2(1.35, -0.95)).displacement.y), 0)
    }
}
