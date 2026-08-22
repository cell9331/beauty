import XCTest
@testable import BeautyDetection

final class UpperEyelidSemanticSupportTests: XCTestCase {
    func testApprovedEyeIsIndependentFromPeerNoOp() {
        let observation = BeautyFaceObservation(
            stableID: "face-1",
            imageBounds: CoordinateRect(x: 0, y: 0, width: 1, height: 1),
            observedEyeSupport: [
                BeautyObservedEyeSupport(
                    side: .left,
                    contour: [
                        CoordinatePoint(x: 0.20, y: 0.20),
                        CoordinatePoint(x: 0.40, y: 0.20),
                        CoordinatePoint(x: 0.40, y: 0.40),
                        CoordinatePoint(x: 0.20, y: 0.40),
                    ]
                ),
                BeautyObservedEyeSupport(
                    side: .right,
                    contour: [
                        CoordinatePoint(x: 0.60, y: 0.20),
                        CoordinatePoint(x: 0.80, y: 0.20),
                        CoordinatePoint(x: 0.80, y: 0.40),
                        CoordinatePoint(x: 0.60, y: 0.40),
                    ]
                ),
            ],
            observedEyeOrder: .canonical
        )

        let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation,
            imageWidth: 10,
            imageHeight: 10
        ) { requests in
            [BeautyUpperEyelidSemanticApproval(
                side: requests[0].side,
                approved: true,
                confidence: 0.9,
                reason: .approved,
                pixelIndices: [22],
                hardEnvelope: requests[0].eyeEnvelope
            )]
        }

        guard case let .supported(side, confidence, _, pixels, _) = resolution.left,
              case .sourceExactNoOp(.right, _, .semanticApprovalMissing) = resolution.right
        else {
            return XCTFail("expected independent supported/no-op outcomes")
        }
        XCTAssertEqual(side, .left)
        XCTAssertEqual(confidence, 0.9)
        XCTAssertEqual(pixels, [22])
    }
}
