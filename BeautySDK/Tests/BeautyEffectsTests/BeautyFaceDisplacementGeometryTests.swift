import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Geometry and direction controls for the candidate field. These fixtures do
/// not qualify reference matching, human appearance, occlusion, or neck visibility.
final class BeautyFaceDisplacementGeometryTests: XCTestCase {
    private let width = 1200
    private let height = 1400

    private func face(angle: Double = 0, origin: SIMD2<Double> = SIMD2(600, 450),
                      freshness: LandmarkGeometryFreshness = .fresh,
                      observedEyes: Bool = true, observedMouth: Bool = true,
                      observedNose: Bool = true, invalidContour: Bool = false,
                      dense: BeautyDenseFaceSupport? = nil) -> FaceGeometry {
        let x = SIMD2(cos(angle), sin(angle)), y = SIMD2(-sin(angle), cos(angle))
        let scale = 200.0
        func normalized(_ p: SIMD2<Double>) -> SIMD2<Float> {
            let image = origin + scale * (x * p.x + y * p.y)
            return SIMD2(Float((image.x + 0.5) / Double(width)), Float((image.y + 0.5) / Double(height)))
        }
        func box(_ center: SIMD2<Double>, _ radius: SIMD2<Double>) -> [SIMD2<Float>] {
            [center + SIMD2(-radius.x,-radius.y), center + SIMD2(radius.x,-radius.y),
             center + SIMD2(radius.x,radius.y), center + SIMD2(-radius.x,radius.y)].map(normalized)
        }
        var contour = (0..<21).map { index in
            let angle = Double(index) / 20 * Double.pi
            return normalized(SIMD2(-1.10 * cos(angle), 1.80 * sin(angle)))
        }
        if invalidContour { contour.swapAt(3, 16) }
        func eye(_ side: BeautyObservedEyeSide, _ center: SIMD2<Double>) -> BeautyEyeSemanticSupport {
            let path = box(center, SIMD2(0.22,0.085))
            return BeautyEyeSemanticSupport(side: side, contour: path,
                upper: Array(path.prefix(2)), lower: Array(path.suffix(2)),
                inner: [path[0]], outer: [path[1]], corners: [path[0],path[1]],
                center: normalized(center), pupil: normalized(center),
                span: SIMD2(0.074,0.025), tilt: 0)
        }
        let left = eye(.left, SIMD2(-0.5,0)), right = eye(.right, SIMD2(0.5,0))
        let lips = box(SIMD2(0,1.10), SIMD2(0.30,0.08))
        func coordinate(_ p: SIMD2<Double>) -> CoordinatePoint {
            let n = normalized(p)
            return CoordinatePoint(x: Double(n.x), y: Double(n.y))
        }
        let nose = BeautyObservedNoseSupport(
            crest: [SIMD2(0.0,0.20),SIMD2(0,0.40),SIMD2(0,0.65)].map(coordinate),
            contour: [SIMD2(-0.2,0.65),SIMD2(0,0.75),SIMD2(0.2,0.65)].map(coordinate))
        return FaceGeometry(bounds: FaceBounds(x: 0.25,y: 0.20,width: 0.50,height: 0.50),
            faceContour: contour,
            observedFaceSupport: BeautyFaceSemanticSupport(contour: contour, medianLine: nil, apexIndex: 10),
            leftEye: left.contour, rightEye: right.contour, outerLips: lips,
            leftEyeSupport: observedEyes ? left : nil, rightEyeSupport: observedEyes ? right : nil,
            freshness: freshness, observedOuterLips: observedMouth ? lips : nil,
            observedNoseSupport: observedNose ? nose : nil, denseSupport: dense)
    }

    private func geometry(_ face: FaceGeometry? = nil) throws -> BeautyFaceDisplacementGeometry {
        try XCTUnwrap(BeautyFaceDisplacementGeometry(width: width, height: height, face: face ?? self.face()))
    }

    private func vectorEqual(_ actual: SIMD2<Double>, _ expected: SIMD2<Double>,
                             accuracy: Double = 1e-6, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.y, expected.y, accuracy: accuracy, file: file, line: line)
    }

    func testSourceFrameAndFieldsFollowImageRoll() throws {
        let level = try geometry(), rolled = try geometry(face(angle: 0.37))
        XCTAssertEqual(level.scale, 200, accuracy: 0.001)
        XCTAssertEqual(rolled.scale, 200, accuracy: 0.001)
        var strengths = BeautyEffectiveStrengths(); strengths.faceSlim = 0.60
        let a = try XCTUnwrap(level.model(strengths: strengths))
        let b = try XCTUnwrap(rolled.model(strengths: strengths))
        for point in [SIMD2(-1.0,0.60),SIMD2(0.8,1.3),SIMD2(0,1.8)] {
            vectorEqual(rolled.local(rolled.image(point)), point, accuracy: 1e-12)
            vectorEqual(b.sample(at: point).displacement, a.sample(at: point).displacement, accuracy: 1e-6)
        }
    }

    func testFaceWidthIncludesCheekInwardAndSideJawUpwardWithoutWholeEyeProtection() throws {
        let geometry = try geometry()
        var strengths = BeautyEffectiveStrengths(); strengths.faceSlim = 0.60
        let model = try XCTUnwrap(geometry.model(strengths: strengths))
        XCTAssertGreaterThan(model.sample(at: SIMD2(-1.0,0.60)).displacement.x, 0)
        XCTAssertLessThan(model.sample(at: SIMD2(1.0,0.60)).displacement.x, 0)
        let jaw = model.sample(at: SIMD2(-0.68,1.40)).displacement
        let chin = model.sample(at: SIMD2(0,1.80)).displacement
        XCTAssertLessThan(jaw.y, 0)
        XCTAssertLessThan(abs(chin.y), abs(jaw.y))
        XCTAssertGreaterThan(model.sample(at: SIMD2(-0.70,0.05)).displacement.x, 0)
        // The observed nasal centre alone is exact; a whole facial feature box
        // is not used to suppress the four candidate motion modes.
        vectorEqual(model.sample(at: SIMD2(0,0.55)).displacement, .zero, accuracy: 0)
        strengths.faceSlim = -0.60
        let negative = try XCTUnwrap(geometry.model(strengths: strengths))
        vectorEqual(negative.sample(at: SIMD2(-0.68,1.40)).displacement, -jaw, accuracy: 1e-12)
    }

    func testSmallFaceMovesMouthChinAndSourceBoxContinuationButProtectsEyeCores() throws {
        let geometry = try geometry()
        var strengths = BeautyEffectiveStrengths(); strengths.faceSmall = 0.45
        let model = try XCTUnwrap(geometry.model(strengths: strengths))
        vectorEqual(model.sample(at: SIMD2(-0.5,0)).displacement, .zero, accuracy: 0)
        vectorEqual(model.sample(at: SIMD2(0.5,0)).displacement, .zero, accuracy: 0)
        let mouth = model.sample(at: SIMD2(0,1.10)).displacement
        let chin = model.sample(at: SIMD2(0,1.80)).displacement
        XCTAssertLessThan(mouth.y, 0)
        XCTAssertLessThan(chin.y, mouth.y)
        XCTAssertLessThan(model.sample(at: SIMD2(0,2.0)).displacement.y, 0)
        vectorEqual(model.sample(at: SIMD2(0,2.6)).displacement, .zero, accuracy: 0)
        XCTAssertGreaterThan(model.sample(at: SIMD2(-0.80,1.30)).displacement.x, 0)
        XCTAssertLessThan(model.sample(at: SIMD2(0.80,1.30)).displacement.x, 0)
    }

    func testSmoothingUsesTwoFixedLowerNormalWindowsAndOneWayStrength() throws {
        let geometry = try geometry()
        var strengths = BeautyEffectiveStrengths(); strengths.faceContourSmooth = 0.25
        let model = try XCTUnwrap(geometry.model(strengths: strengths))
        let left = model.sample(at: SIMD2(-0.75,1.30)).displacement
        let right = model.sample(at: SIMD2(0.75,1.30)).displacement
        XCTAssertGreaterThan(left.x, 0)
        XCTAssertLessThan(right.x, 0)
        XCTAssertLessThan(left.y, 0)
        XCTAssertLessThan(right.y, 0)
        vectorEqual(model.sample(at: SIMD2(0,1.10)).displacement, .zero, accuracy: 0)
        strengths.faceContourSmooth = -0.25
        XCTAssertTrue(try XCTUnwrap(geometry.model(strengths: strengths)).isIdentity)
    }

    func testCombinedComponentsPreserveIndependentProtectionOwnership() throws {
        let geometry = try geometry()
        var widthOnly = BeautyEffectiveStrengths(); widthOnly.faceSlim = 0.60
        var smallOnly = BeautyEffectiveStrengths(); smallOnly.faceSmall = 0.45
        var combined = widthOnly; combined.faceSmall = 0.45
        let widthModel = try XCTUnwrap(geometry.model(strengths: widthOnly))
        let smallModel = try XCTUnwrap(geometry.model(strengths: smallOnly))
        let all = try XCTUnwrap(geometry.model(strengths: combined))
        let nasalPoint = SIMD2(0.0,0.55)
        vectorEqual(widthModel.sample(at: nasalPoint).displacement, .zero, accuracy: 0)
        XCTAssertLessThan(smallModel.sample(at: nasalPoint).displacement.y, 0)
        XCTAssertLessThan(all.sample(at: nasalPoint).displacement.y, 0)
        XCTAssertLessThan(all.gradientBound, 1)
    }

    func testAdmissionRejectsLegacyProxiesStaleCrossingAndTruncatedSupports() throws {
        for invalid in [face(freshness: .reused), face(freshness: .stale),
                        face(observedEyes: false), face(observedMouth: false), face(invalidContour: true)] {
            XCTAssertNil(BeautyFaceDisplacementGeometry(width: width, height: height, face: invalid))
        }
        let nearEdge = try geometry(face(origin: SIMD2(280,450)))
        var widthOnly = BeautyEffectiveStrengths(); widthOnly.faceSlim = 0.60
        XCTAssertNil(nearEdge.model(strengths: widthOnly))
        let noNose = try geometry(face(observedNose: false))
        XCTAssertNil(noNose.model(strengths: widthOnly))
        var smallOnly = BeautyEffectiveStrengths(); smallOnly.faceSmall = 0.45
        XCTAssertNotNil(noNose.model(strengths: smallOnly))
        smallOnly.faceSmall = .nan
        XCTAssertNil(noNose.model(strengths: smallOnly))
    }

    func testDensePoseRejectsBackFacingAndMalformedSuppliedRotation() throws {
        // Only the transform contributes to these synthetic controls. The
        // observed face/eyes/lips remain the independent fixture above.
        func dense(_ matrix: [Float]) throws -> BeautyDenseFaceSupport {
            let points = (0..<478).map { index in
                SIMD3<Float>(0.2 + Float(index % 23) / 40, 0.15 + Float(index / 23) / 30, 0)
            }
            return BeautyDenseFaceSupport(mesh: try XCTUnwrap(
                BeautyFaceMesh(points: points, facialTransformation: matrix)))
        }
        let backFacing = try dense(yawMatrix(cosine: -1))
        XCTAssertEqual(backFacing.geometryScale, 0)
        XCTAssertNil(BeautyFaceDisplacementGeometry(width: width, height: height, face: face(dense: backFacing)))
        var shear = yawMatrix(cosine: 1); shear[1] = 0.5
        let malformed = try dense(shear)
        XCTAssertNotNil(malformed.mesh.facialTransformation)
        // The pre-existing DenseSupport compatibility fallback is one; the
        // new field must independently reject the supplied malformed pose.
        XCTAssertEqual(malformed.geometryScale, 1)
        XCTAssertNil(BeautyFaceDisplacementGeometry(width: width, height: height, face: face(dense: malformed)))
    }

    func testHalfDensePoseAttenuatesEachFieldBeforeWholeModelCertification() throws {
        let points = (0..<478).map { index in
            SIMD3<Float>(0.2 + Float(index % 23) / 40, 0.15 + Float(index / 23) / 30, 0)
        }
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points, facialTransformation: yawMatrix(cosine: 0.635)))
        let dense = BeautyDenseFaceSupport(mesh: mesh)
        XCTAssertEqual(dense.geometryScale, 0.5, accuracy: 0.000_001)
        let full = try geometry(), half = try geometry(face(dense: dense))
        let cases: [(WritableKeyPath<BeautyEffectiveStrengths,Float>, Float, SIMD2<Double>)] = [
            (\.faceSlim, 0.03, SIMD2(-1.0,0.60)),
            (\.faceSmall, 0.02, SIMD2(0,1.10)),
            (\.faceContourSmooth, 0.01, SIMD2(-0.75,1.30)),
        ]
        for (key, amount, point) in cases {
            var strengths = BeautyEffectiveStrengths(); strengths[keyPath: key] = amount
            let a = try XCTUnwrap(full.model(strengths: strengths))
            let b = try XCTUnwrap(half.model(strengths: strengths))
            // Small controls avoid safety saturation obscuring the pose ratio.
            XCTAssertEqual(a.amplitudeScale, 1); XCTAssertEqual(b.amplitudeScale, 1)
            XCTAssertGreaterThan(hypot(a.sample(at: point).displacement.x, a.sample(at: point).displacement.y), 0)
            vectorEqual(b.sample(at: point).displacement,
                        a.sample(at: point).displacement * Double(dense.geometryScale), accuracy: 1e-10)
            XCTAssertLessThan(b.gradientBound, a.gradientBound)
        }
    }

    private func yawMatrix(cosine: Double) -> [Float] {
        let sine = sqrt(max(0, 1 - cosine * cosine))
        return [cosine,0,sine,0, 0,1,0,0, -sine,0,cosine,0, 0,0,0,1].map(Float.init)
    }
}
