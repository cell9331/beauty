import XCTest
@testable import BeautyEffects

final class BeautyHairlineBrowSafetyTests: XCTestCase {
    func testObservedBrowInsideHairlineInfluenceFailsClosedForBothDirections() {
        let provider = FaceShapeWarpProvider()
        for strength: Float in [-0.25, 0.25] {
            var values = BeautyEffectiveStrengths()
            values.hairlineHeight = strength

            let unobserved = provider.fieldEmissions(
                face: face(browTop: nil), strengths: values
            ).hairlineHeight
            let separated = provider.fieldEmissions(
                face: face(browTop: 0.40), strengths: values
            ).hairlineHeight
            let overlapping = provider.fieldEmissions(
                face: face(browTop: strength < 0 ? 0.26 : 0.30), strengths: values
            ).hairlineHeight

            XCTAssertEqual(unobserved.count, 2)
            XCTAssertEqual(separated.count, 2)
            XCTAssertTrue(overlapping.isEmpty)
        }
    }

    private func face(browTop: Float?) -> FaceGeometry {
        let support = browTop.map { top in
            let points = [SIMD2<Float>(0.39, top), SIMD2<Float>(0.42, top + 0.01)]
            return BeautyEyebrowSemanticSupport(
                left: BeautyEyebrowSemanticTrace(
                    side: .left, points: points, innerEndpoint: points[1],
                    outerEndpoint: points[0], center: points[0], apexIndex: nil
                ),
                right: nil
            )
        }
        return FaceGeometry(
            bounds: FaceBounds(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
            faceContour: [
                SIMD2<Float>(0.31, 0.38), SIMD2<Float>(0.50, 0.80),
                SIMD2<Float>(0.69, 0.38),
            ],
            observedEyebrowSupport: support
        )
    }
}
