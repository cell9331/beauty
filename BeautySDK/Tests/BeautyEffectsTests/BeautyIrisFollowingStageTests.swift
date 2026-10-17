import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Entirely synthetic, independent raster/observations. Values below are test
/// hypotheses only, never production calibration or private measured points.
struct IrisFollowingIntegrationFixture {
    let width = 160
    let height = 120
    var source: [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            bytes[i] = UInt8(20 + x)
            bytes[i + 1] = UInt8(20 + y)
            bytes[i + 2] = UInt8(30 + (x * 13 + y * 17) % 180)
        } }
        return bytes
    }

    /// Visible, antialiased circular irises for an independently nonzero
    /// legacy IR control. This source is not the candidate's motion oracle.
    var legacyIrisSource: [UInt8] {
        var bytes = source
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            for centerX in [50.0, 110.0] {
                let v = p - SIMD2(centerX, 54)
                guard pow(v.x / 16, 2) + pow(v.y / 10, 2) < 1 else { continue }
                let coverage = max(0, min(1, 5.5 - hypot(v.x, v.y)))
                let rgb = [200 - 160 * coverage,
                    220 + coverage * (105 + 25 * sin(v.x * 0.7) - 220),
                    220 + coverage * (112 + 22 * cos(v.y * 0.8) - 220)]
                let i = (y * width + x) * 4
                for channel in 0..<3 { bytes[i + channel] = UInt8(rgb[channel].rounded()) }
            }
        } }
        return bytes
    }

    func denseObservation() throws -> BeautyFaceObservation {
        var points = Array(repeating: SIMD3<Float>(0.5, 0.5, 0), count: 478)
        for (indices, centerX) in [(MediaPipeFaceTopology.leftIris, 50.0),
                                   (MediaPipeFaceTopology.rightIris, 110.0)] {
            for (offset, index) in indices.enumerated() {
                let angle = Double(offset) * Double.pi / 2
                points[index] = SIMD3(Float((centerX + 5 * cos(angle)) / Double(width)),
                    Float((54 + 5 * sin(angle)) / Double(height)), 0)
            }
        }
        points[468] = SIMD3(50 / Float(width), 54 / Float(height), 0)
        points[473] = SIMD3(110 / Float(width), 54 / Float(height), 0)
        let base = observation()
        return BeautyFaceObservation(imageBounds: base.imageBounds,
            observedEyeSupport: base.observedEyeSupport, observedEyeOrder: base.observedEyeOrder,
            mesh: try XCTUnwrap(BeautyFaceMesh(points: points)))
    }

    func eye(_ side: BeautyIrisFollowingSide, gain: Double = 0.26,
             radiusX: Double = 23) -> BeautyIrisFollowingEyeCalibration {
        let centerX: Double = side == .left ? 50 : 110
        return BeautyIrisFollowingEyeCalibration(side: side,
            center: .init(x: centerX, y: 54), axisX: .init(x: 1, y: 0), axisY: .init(x: 0, y: 1),
            supportRadiusX: radiusX, supportRadiusY: 20, forwardGainX: gain, forwardGainY: gain,
            ownedSourceDomain: .rectangle(minX: 0, minY: 0, maxX: Double(width - 1), maxY: Double(height - 1)),
            protectedRegions: [.rectangle(minX: 0, minY: 0, maxX: 159, maxY: 20)])
    }

    func request(progress: Double = 1, eyes: [BeautyIrisFollowingEyeCalibration]? = nil,
                 source: [UInt8]? = nil, bindingSource: [UInt8]? = nil,
                 width: Int? = nil) -> BeautyIrisFollowingRequest {
        let bytes = source ?? self.source
        return BeautyIrisFollowingRequest(sourceRGBA: bytes, width: width ?? self.width, height: height,
            sourceBinding: .bind(sourceRGBA: bindingSource ?? bytes, width: width ?? self.width, height: height),
            eyes: eyes ?? [eye(.left), eye(.right)], progress: progress,
            solverPolicy: .init(maximumIterations: 80, residualTolerancePixels: 0.00001))
    }

    func plan(_ edit: ((inout BeautyEffectiveStrengths) -> Void)? = nil) -> BeautyEffectPlan {
        var strengths = BeautyEffectiveStrengths()
        strengths.pupilSize = BeautySafetyCaps.pupilSize
        edit?(&strengths)
        return BeautyEffectPlan(activeDomains: [.eyes], effectiveStrengths: strengths)
    }

    func observation(sides: Set<BeautyIrisFollowingSide> = [.left, .right],
                     canonicalOrder: Bool = true) -> BeautyFaceObservation {
        let supports = [BeautyIrisFollowingSide.left, .right].filter { sides.contains($0) }.map { side in
            let centerX: Double = side == .left ? 50 : 110
            let points = (0..<16).map { index -> CoordinatePoint in
                let angle = Double(index) * 2 * Double.pi / 16
                return CoordinatePoint(x: (centerX + 16 * cos(angle)) / Double(width),
                    y: (54 + 10 * sin(angle)) / Double(height))
            }
            return BeautyObservedEyeSupport(side: side == .left ? .left : .right, contour: points,
                pupil: [.init(x: centerX / Double(width), y: 54 / Double(height))])
        }
        return BeautyFaceObservation(imageBounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
            observedEyeSupport: supports, observedEyeOrder: canonicalOrder ? .canonical : .invalid)
    }

    func face(sides: Set<BeautyIrisFollowingSide> = [.left, .right]) -> FaceGeometry {
        BeautyFaceGeometryAdapter.makeGeometry(from: observation(sides: sides))
    }

    func stage(_ request: BeautyIrisFollowingRequest, source: [UInt8]? = nil,
               plan: BeautyEffectPlan? = nil, face: FaceGeometry? = nil) -> BeautyStillImageGeometryStage {
        BeautyStillImageGeometryStage(sourceRGBA: source ?? self.source, width: width, height: height,
            plan: plan ?? self.plan(), face: face ?? self.face(), irisGeometryRoute: .calibrated(request))
    }

    func completed(_ stage: BeautyStillImageGeometryStage) -> [UInt8] {
        let selected = stage.usesDenseMap ? stage.applyingDenseMap(to: stage.sourceRGBA)
            : BeautyGeometryEffectPipeline.warpedRGBABytes(stage.sourceRGBA, width: width, height: height,
                points: stage.controlPoints.compactMap(BeautyGeometryEffectPipeline.RenderableWarpPoint.init))
        let nasal = stage.applyingContinuousNose(to: selected)
        let mouth = stage.applyingContinuousMouth(to: nasal)
        let brows = stage.applyingContinuousEyebrows(to: mouth)
        return stage.applyingTranslation(to: stage.applyingContinuousContour(to: brows))
    }
}

final class BeautyIrisFollowingStageTests: XCTestCase {
    private let fixture = IrisFollowingIntegrationFixture()

    func testExplicitRouteMatchesMapperAndMovesBothLidsAndScleraWithoutLegacyApertureClip() throws {
        let source = fixture.source, request = fixture.request()
        let expected = BeautyIrisFollowingMap.render(request)
        let stage = fixture.stage(request)
        XCTAssertEqual(expected.status, .applied)
        XCTAssertEqual(stage.irisFollowingResult?.status, .applied)
        XCTAssertEqual(stage.irisFollowingResult?.appliedEyeCount, 2)
        XCTAssertTrue(stage.controlPoints.isEmpty)
        XCTAssertFalse(stage.usesDenseMap)
        XCTAssertTrue(stage.sourceRGBA == expected.rgba, "stage must use the qualified full mapper raster")
        XCTAssertTrue(fixture.completed(stage) == expected.rgba, "the already sampled field must not be sampled again")
        for centerX in [50, 110] {
            for (name, x, y) in [("upper lid", centerX, 44), ("lower lid", centerX, 64),
                                  ("left sclera", centerX - 13, 54), ("right sclera", centerX + 13, 54),
                                  ("following skin outside aperture", centerX, 39)] {
                let i = (y * fixture.width + x) * 4
                XCTAssertTrue(Array(expected.rgba[i..<i + 3]) != Array(source[i..<i + 3]), name)
            }
        }
        XCTAssertTrue(stride(from: 3, to: expected.rgba.count, by: 4).allSatisfy { expected.rgba[$0] == 255 })
        for y in 0..<fixture.height { for x in 0..<fixture.width where y < 25 || y > 80 {
            let i = (y * fixture.width + x) * 4
            XCTAssertTrue(Array(expected.rgba[i..<i + 4]) == Array(source[i..<i + 4]), "far-field pixel must remain exact")
        } }
    }

    func testObservedEndpointZeroIsByteIdentityWithoutInventingUIPupilNeutral() {
        let request = fixture.request(progress: 0)
        let stage = fixture.stage(request)
        XCTAssertEqual(stage.irisFollowingResult?.status, .unchanged)
        XCTAssertTrue(fixture.completed(stage) == fixture.source, "observed endpoint zero must preserve source bytes")
        let absentUIPupil = fixture.plan { $0.pupilSize = 0 }
        let positive = fixture.stage(fixture.request(), plan: absentUIPupil)
        XCTAssertEqual(positive.irisFollowingResult?.status, .applied,
            "request progress belongs to the observed endpoint pair, not the legacy UI slider")
    }

    func testBindingFailureUsesActualStageInputAndCannotRestoreNonzeroLegacyPupil() throws {
        let legacy = BeautyStillImageGeometryStage(sourceRGBA: fixture.source, width: fixture.width,
            height: fixture.height, plan: fixture.plan(), face: fixture.face())
        XCTAssertTrue(fixture.completed(legacy) != fixture.source, "the control must exercise a real legacy pupil field")
        var actual = fixture.source
        actual[0] ^= 1
        let stage = fixture.stage(fixture.request(), source: actual)
        XCTAssertEqual(stage.irisFollowingResult?.refusalCounts[.sourceMismatch], 2)
        XCTAssertEqual(stage.irisFollowingResult?.status, .refused)
        XCTAssertTrue(fixture.completed(stage) == actual, "source mismatch must preserve actual input")
        XCTAssertTrue(actual != fixture.source, "control source must actually differ")
    }

    func testMalformedUnsafeAndDimensionMismatchRequestsFailClosed() {
        let cases: [(BeautyIrisFollowingRequest, BeautyIrisFollowingRefusalReason)] = [
            (fixture.request(progress: .nan), .invalidProgress),
            (fixture.request(eyes: [fixture.eye(.left, gain: .nan)]), .invalidCalibration),
            (fixture.request(eyes: [fixture.eye(.left, gain: 2)]), .unsafeContraction),
            (fixture.request(width: fixture.width - 1), .sourceMismatch)
        ]
        for (request, reason) in cases {
            let stage = fixture.stage(request)
            XCTAssertEqual(stage.irisFollowingResult?.status, .refused)
            XCTAssertNotNil(stage.irisFollowingResult?.refusalCounts[reason])
            XCTAssertTrue(fixture.completed(stage) == fixture.source, "invalid request must preserve stage input")
        }
    }

    func testEveryOtherGeometryFamilyAndSourceRefinerIsExplicitlyUnsupported() {
        let keys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] = [
            \.eyeSize, \.eyeHeight, \.eyeDistance, \.gazeCorrection, \.eyeSymmetry,
            \.faceSlim, \.faceContourSmooth, \.wholeFaceXPosition, \.wholeFaceTilt,
            \.hairlineHeight, \.foreheadHeight, \.doubleChinReduction, \.doubleChinReductionPro,
            \.headWrap, \.philtrumLength, \.jawlineShadow,
            \.eyebrowThickness, \.noseTipSize, \.mouthWidth, \.lipPlump
        ]
        for key in keys {
            let stage = fixture.stage(fixture.request(), plan: fixture.plan { $0[keyPath: key] = 0.2 })
            XCTAssertEqual(stage.irisFollowingResult?.refusalCounts[.unsupportedStageCombination], 2)
            XCTAssertTrue(fixture.completed(stage) == fixture.source, "unsupported combination must preserve input")
        }
    }

    func testNoObservedFaceAndInvalidOrderNeverUseCoarseEyeProxies() {
        let request = fixture.request()
        let noFace = BeautyStillImageGeometryStage(sourceRGBA: fixture.source, width: fixture.width,
            height: fixture.height, plan: fixture.plan(), face: nil, irisGeometryRoute: .calibrated(request))
        XCTAssertEqual(noFace.irisFollowingResult?.refusalCounts[.missingObservedEyeSupport], 2)
        XCTAssertTrue(fixture.completed(noFace) == fixture.source, "no-face refusal must preserve input")
        let coarse = BeautyFaceGeometryAdapter.makeGeometry(from: .init(
            imageBounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8)))
        let badOrder = BeautyFaceGeometryAdapter.makeGeometry(from: fixture.observation(canonicalOrder: false))
        let fresh = fixture.face()
        let stale = FaceGeometry(bounds: fresh.bounds, faceContour: [],
            leftEye: fresh.leftEye, rightEye: fresh.rightEye,
            leftEyeSupport: fresh.leftEyeSupport, rightEyeSupport: fresh.rightEyeSupport, freshness: .stale)
        for face in [coarse, badOrder, stale] {
            let stage = fixture.stage(request, face: face)
            XCTAssertEqual(stage.irisFollowingResult?.refusalCounts[.missingObservedEyeSupport], 2)
            XCTAssertTrue(fixture.completed(stage) == fixture.source, "unqualified observations must preserve input")
        }
    }

    func testMissingObservedSideRetainsIndependentlyValidPeer() {
        let request = fixture.request()
        let stage = fixture.stage(request, face: fixture.face(sides: [.right]))
        let rightOnly = BeautyIrisFollowingMap.render(fixture.request(eyes: [fixture.eye(.right)]))
        XCTAssertEqual(stage.irisFollowingResult?.status, .partiallyApplied)
        XCTAssertEqual(stage.irisFollowingResult?.appliedEyeCount, 1)
        XCTAssertEqual(stage.irisFollowingResult?.refusedEyeCount, 1)
        XCTAssertEqual(stage.irisFollowingResult?.refusalCounts[.missingObservedEyeSupport], 1)
        XCTAssertTrue(fixture.completed(stage) == rightOnly.rgba, "valid peer must match independent single-eye rendering")
    }

    func testClosedBlinkCrossingAndIncompleteLidSupportRejectOnlyThatObservedSide() throws {
        let full = fixture.face(), base = try XCTUnwrap(full.leftEyeSupport)
        func support(contour: [SIMD2<Float>]? = nil, upper: [SIMD2<Float>]? = nil,
                     lower: [SIMD2<Float>]? = nil, coincidentCanthi: Bool = false) -> BeautyEyeSemanticSupport {
            BeautyEyeSemanticSupport(side: .left, contour: contour ?? base.contour,
                upper: upper ?? base.upper, lower: lower ?? base.lower,
                inner: base.inner, outer: coincidentCanthi ? base.inner : base.outer, corners: base.corners,
                center: base.center, pupil: base.pupil, span: base.span, tilt: base.tilt)
        }
        let closed = base.contour.map { SIMD2($0.x, base.center.y) }
        // 1.2 source pixels of aperture is above the adapter's existing 0.01
        // relative-height floor but below the existing eye-map 0.08 span gate.
        let blink = base.contour.map { SIMD2($0.x, base.center.y + ($0.y - base.center.y) * 0.06) }
        var crossing = base.contour
        crossing.swapAt(1, 9)
        let cases: [(String, BeautyEyeSemanticSupport)] = [
            ("closed", support(contour: closed, upper: closed, lower: closed)),
            ("blink", support(contour: blink, upper: blink.filter { $0.y <= base.center.y },
                lower: blink.filter { $0.y >= base.center.y })),
            ("crossing", support(contour: crossing)),
            ("short upper", support(upper: Array(base.upper.prefix(1)))),
            ("short lower", support(lower: Array(base.lower.prefix(1)))),
            ("duplicate upper", support(upper: [base.upper[0], base.upper[0]])),
            ("coincident canthi", support(coincidentCanthi: true))
        ]
        let rightOnly = BeautyIrisFollowingMap.render(fixture.request(eyes: [fixture.eye(.right)])).rgba
        for (name, bad) in cases {
            let face = FaceGeometry(bounds: full.bounds, faceContour: [],
                leftEye: bad.contour, rightEye: full.rightEye,
                leftEyeSupport: bad, rightEyeSupport: full.rightEyeSupport)
            let stage = fixture.stage(fixture.request(), face: face)
            XCTAssertEqual(stage.irisFollowingResult?.status, .partiallyApplied, name)
            XCTAssertEqual(stage.irisFollowingResult?.refusalCounts[.missingObservedEyeSupport], 1, name)
            XCTAssertTrue(fixture.completed(stage) == rightOnly, "\(name): valid peer must remain independently usable")
        }
    }
}
