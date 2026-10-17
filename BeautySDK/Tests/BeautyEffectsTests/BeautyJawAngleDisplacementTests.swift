import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Synthetic tests qualify the mechanism, support and inverse. Reference
/// matching, new faces and the final device appearance require separate checks.
final class BeautyJawAngleDisplacementTests: XCTestCase {
    private typealias Model = BeautyFaceDisplacementModel
    private let chin = SIMD2(0.0, 1.8)

    private var contour: [SIMD2<Double>] {
        (0...20).map { index in
            let angle = Double(index) / 20 * .pi
            return SIMD2(-1.10 * cos(angle), 1.80 * sin(angle))
        }
    }

    private func component(amount: Double = 1,
                           protections: [Model.Protection] = []) throws -> Model.Component {
        try XCTUnwrap(BeautyJawAngleDisplacement.component(
            contour: contour, chin: chin, amount: amount, protections: protections,
            supported: { _ in true }))
    }

    private func model(amount: Double = 1,
                       protections: [Model.Protection] = []) throws -> Model {
        try XCTUnwrap(Model(components: [try component(amount: amount, protections: protections)],
                           refineGradientBound: true))
    }

    private func vectorEqual(_ value: SIMD2<Double>, _ expected: SIMD2<Double>,
                             accuracy: Double = 1e-12,
                             file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(value.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(value.y, expected.y, accuracy: accuracy, file: file, line: line)
    }

    func testBothSidesMoveInwardAndUpwardWithFixedSlopeAndSymmetricNeutralChoice() throws {
        let positive = try model(), negative = try model(amount: -1)
        for side in [-1.0, 1.0] {
            for point in [SIMD2(side * 0.80, 1.10), SIMD2(side * 0.70, 1.35)] {
                let displacement = positive.sample(at: point).displacement
                XCTAssertGreaterThan(-side * displacement.x, 0)
                XCTAssertLessThan(displacement.y, 0)
                XCTAssertEqual(displacement.y / (side * displacement.x), 1.35, accuracy: 1e-12)
                vectorEqual(negative.sample(at: point).displacement, -displacement)
            }
        }
        let zero = try model(amount: 0)
        XCTAssertTrue(zero.isIdentity)
        XCTAssertEqual(zero.gradientBound, 0)
        vectorEqual(zero.sample(at: SIMD2(0.80, 1.10)).displacement, .zero, accuracy: 0)
    }

    func testBroadExitMovesMouthSideAndAdjacentTextureWhileChinAndNeckStayExact() throws {
        let field = try model()
        XCTAssertGreaterThan(field.sample(at: SIMD2(-0.75, 0.90)).displacement.x, 0)
        XCTAssertGreaterThan(field.sample(at: SIMD2(-0.55, 1.10)).displacement.x, 0)
        XCTAssertGreaterThan(field.sample(at: SIMD2(-1.05, 1.10)).displacement.x, 0)
        XCTAssertGreaterThan(field.sample(at: SIMD2(-0.75, 1.52)).displacement.x, 0)
        for point in [SIMD2(0.0, 1.10), chin, SIMD2(-0.10, 1.75),
                      SIMD2(0, 2.0), SIMD2(-0.75, 1.80), SIMD2(-0.75, 0.4)] {
            vectorEqual(field.sample(at: point).displacement, .zero, accuracy: 0)
            vectorEqual(try XCTUnwrap(field.inverse(of: point)), point, accuracy: 0)
        }
    }

    func testExactCoreProtectionDoesNotFreezeMouthSideAndCompleteDerivativeIsCertified() throws {
        let core = Model.Protection(window: .init(center: SIMD2(-0.55, 1.10),
            axisX: SIMD2(1, 0), axisY: SIMD2(0, 1), radius: SIMD2(0.10, 0.10)), innerFraction: 0.5)
        let field = try model(protections: [core])
        vectorEqual(field.sample(at: SIMD2(-0.55, 1.10)).displacement, .zero, accuracy: 0)
        XCTAssertGreaterThan(field.sample(at: SIMD2(-0.72, 1.10)).displacement.x, 0)
        XCTAssertLessThan(field.gradientBound, 1)
        let epsilon = 1e-6
        for point in [SIMD2(-0.62, 1.10), SIMD2(-0.9, 0.90), SIMD2(0.75, 1.42)] {
            let sample = field.sample(at: point)
            let dx = (field.sample(at: point + SIMD2(epsilon, 0)).displacement -
                      field.sample(at: point - SIMD2(epsilon, 0)).displacement) / (2 * epsilon)
            let dy = (field.sample(at: point + SIMD2(0, epsilon)).displacement -
                      field.sample(at: point - SIMD2(0, epsilon)).displacement) / (2 * epsilon)
            vectorEqual(sample.derivativeX, dx, accuracy: 2e-8)
            vectorEqual(sample.derivativeY, dy, accuracy: 2e-8)
            let norm = sqrt(sample.derivativeX.x * sample.derivativeX.x +
                            sample.derivativeX.y * sample.derivativeX.y +
                            sample.derivativeY.x * sample.derivativeY.x +
                            sample.derivativeY.y * sample.derivativeY.y)
            XCTAssertLessThanOrEqual(norm, field.gradientBound)
            let target = point + sample.displacement
            let source = try XCTUnwrap(field.inverse(of: target, tolerance: 1e-11))
            vectorEqual(source, point, accuracy: 1e-10)
        }
    }

    func testCompleteSupportAdmissionAndNonfiniteGeometryFailClosed() {
        XCTAssertNil(BeautyJawAngleDisplacement.component(contour: contour, chin: chin,
            amount: 1, protections: [], supported: { $0.center.x < 0 }))
        XCTAssertNil(BeautyJawAngleDisplacement.component(contour: contour, chin: chin,
            amount: .nan, protections: [], supported: { _ in true }))
        var invalid = contour; invalid[3].x = .infinity
        XCTAssertNil(BeautyJawAngleDisplacement.component(contour: invalid, chin: chin,
            amount: 1, protections: [], supported: { _ in true }))
        XCTAssertNil(BeautyJawAngleDisplacement.component(contour: contour, chin: SIMD2(0, 1.7),
            amount: 1, protections: [], supported: { _ in true }))
    }

    func testRefusedOutOfImageJawKeepsIndependentlyAdmittedSmallFaceUnchanged() throws {
        let width = 400, height = 700, origin = SIMD2(130.0, 250.0), eyeDistance = 100.0
        func normalized(_ p: SIMD2<Double>) -> SIMD2<Float> {
            let image = origin + eyeDistance * p
            return SIMD2(Float((image.x + 0.5) / Double(width)),
                         Float((image.y + 0.5) / Double(height)))
        }
        func box(_ center: SIMD2<Double>, _ radius: SIMD2<Double>) -> [SIMD2<Float>] {
            [center + SIMD2(-radius.x, -radius.y), center + SIMD2(radius.x, -radius.y),
             center + SIMD2(radius.x, radius.y), center + SIMD2(-radius.x, radius.y)].map(normalized)
        }
        func eye(_ side: BeautyObservedEyeSide, _ center: SIMD2<Double>) -> BeautyEyeSemanticSupport {
            let path = box(center, SIMD2(0.22, 0.085))
            return BeautyEyeSemanticSupport(side: side, contour: path,
                upper: Array(path.prefix(2)), lower: Array(path.suffix(2)),
                inner: [path[0]], outer: [path[1]], corners: [path[0], path[1]],
                center: normalized(center), pupil: nil, span: SIMD2(0.11, 0.024), tilt: 0)
        }
        func coordinate(_ p: SIMD2<Double>) -> CoordinatePoint {
            let q = normalized(p)
            return CoordinatePoint(x: Double(q.x), y: Double(q.y))
        }
        let sourceContour = contour.map(normalized)
        let left = eye(.left, SIMD2(-0.5, 0)), right = eye(.right, SIMD2(0.5, 0))
        let lips = box(SIMD2(0, 1.10), SIMD2(0.30, 0.08))
        let nose = BeautyObservedNoseSupport(
            crest: [SIMD2(0.0, 0.20), SIMD2(0, 0.40), SIMD2(0, 0.65)].map(coordinate),
            contour: [SIMD2(-0.2, 0.65), SIMD2(0, 0.75), SIMD2(0.2, 0.65)].map(coordinate))
        let face = FaceGeometry(bounds: FaceBounds(x: 0.05, y: 0.30, width: 0.55, height: 0.35),
            faceContour: sourceContour,
            observedFaceSupport: BeautyFaceSemanticSupport(contour: sourceContour, medianLine: nil, apexIndex: 10),
            leftEye: left.contour, rightEye: right.contour, outerLips: lips,
            leftEyeSupport: left, rightEyeSupport: right, freshness: .fresh,
            observedOuterLips: lips, observedNoseSupport: nose)
        var small = BeautyEffectiveStrengths(); small.faceSmall = BeautySafetyCaps.faceSmall
        var joint = small; joint.jawSlim = BeautySafetyCaps.jawSlim
        var jaw = BeautyEffectiveStrengths(); jaw.jawSlim = BeautySafetyCaps.jawSlim
        let admitted = try XCTUnwrap(BeautyFaceDisplacementMap(width: width, height: height,
            face: face, strengths: small))
        let retained = try XCTUnwrap(BeautyFaceDisplacementMap(width: width, height: height,
            face: face, strengths: joint))
        XCTAssertNil(BeautyFaceDisplacementMap(width: width, height: height, face: face, strengths: jaw))
        XCTAssertFalse(admitted.model.isIdentity)
        XCTAssertLessThan(admitted.model.sample(at: SIMD2(0, 1.8)).displacement.y, 0)
        XCTAssertEqual(retained.amplitudeScale, admitted.amplitudeScale)
        XCTAssertEqual(retained.maximumGradient, admitted.maximumGradient)
        XCTAssertEqual(retained.maximumDisplacement, admitted.maximumDisplacement)
        XCTAssertEqual(retained.model.unscaledGradientBound, admitted.model.unscaledGradientBound)
        vectorEqual(retained.model.bounds.minimum, admitted.model.bounds.minimum, accuracy: 0)
        vectorEqual(retained.model.bounds.maximum, admitted.model.bounds.maximum, accuracy: 0)
        // Fixed source-grid checks cover the support, both transition collars,
        // cores and exterior. Matching bounds/certificate also ensures a
        // refused jaw cannot switch the unchanged sibling's refinement path.
        for row in 0...32 { for column in 0...36 {
            let p = SIMD2(-1.8 + Double(column) * 0.1, -0.2 + Double(row) * 0.1)
            let a = admitted.model.sample(at: p), b = retained.model.sample(at: p)
            vectorEqual(b.displacement, a.displacement, accuracy: 0)
            vectorEqual(b.derivativeX, a.derivativeX, accuracy: 0)
            vectorEqual(b.derivativeY, a.derivativeY, accuracy: 0)
        } }
    }
}
