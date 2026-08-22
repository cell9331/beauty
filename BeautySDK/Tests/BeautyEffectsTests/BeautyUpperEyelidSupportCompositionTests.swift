import BeautyCore
import Foundation
import XCTest
@testable import BeautyDetection
@testable import BeautyEffects

final class BeautyUpperEyelidSupportCompositionTests: XCTestCase {
    private let sourceBytes: [UInt8] = [
        10, 20, 30, 255, 40, 50, 60, 255, 70, 80, 90, 255,
        100, 110, 120, 255, 130, 140, 150, 255, 160, 170, 180, 255,
    ]

    func testRejectedEyeRemainsSourceExactBesideAcceptedPeer() throws {
        let source = try canonical()
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let resolution = BeautyUpperEyelidSupportResolution(
            left: .supported(
                side: .left,
                confidence: 0.9,
                reason: .approved,
                pixelIndices: [0],
                hardEnvelope: fullEnvelope
            ),
            right: .sourceExactNoOp(
                side: .right,
                confidence: 0,
                reason: .semanticApprovalRejected
            )
        )

        let unit = try XCTUnwrap(owner.makeUnit(proposals: proposals(from: resolution)))
        let result = try owner.compose([unit])

        var expected = sourceBytes
        expected.replaceSubrange(0..<3, with: [200, 201, 202])
        XCTAssertEqual(Array(result.canonicalImage.rgba8Data), expected)
        XCTAssertEqual(Array(result.canonicalImage.rgba8Data[4..<8]), [40, 50, 60, 255])
        XCTAssertEqual(result.summary.collisionPixelCount, 0)
        XCTAssertEqual(result.canonicalImage.width, source.width)
        XCTAssertEqual(result.canonicalImage.height, source.height)
        XCTAssertEqual(result.canonicalImage.metadata, source.metadata)
    }

    func testOverlappingPerEyeClaimsReturnSourceBytesAndCountCollision() throws {
        let source = try canonical()
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let resolution = BeautyUpperEyelidSupportResolution(
            left: .supported(
                side: .left,
                confidence: 0.9,
                reason: .approved,
                pixelIndices: [2],
                hardEnvelope: fullEnvelope
            ),
            right: .supported(
                side: .right,
                confidence: 0.9,
                reason: .approved,
                pixelIndices: [2],
                hardEnvelope: fullEnvelope
            )
        )

        let left = try XCTUnwrap(owner.makeUnit(proposals: proposals(from: resolution, target: (255, 0, 0), side: .left)))
        let right = try XCTUnwrap(owner.makeUnit(proposals: proposals(from: resolution, target: (0, 255, 0), side: .right)))
        let result = try owner.compose([left, right])

        XCTAssertEqual(Array(result.canonicalImage.rgba8Data), sourceBytes)
        XCTAssertEqual(Array(result.canonicalImage.rgba8Data[8..<12]), [70, 80, 90, 255])
        XCTAssertEqual(result.summary.collisionPixelCount, 1)
        XCTAssertEqual(result.summary.changedPixelCount, 0)
        XCTAssertEqual(result.canonicalImage.metadata, source.metadata)
    }

    private var fullEnvelope: CoordinateRect {
        CoordinateRect(x: 0, y: 0, width: 1, height: 1)
    }

    private func proposals(
        from resolution: BeautyUpperEyelidSupportResolution,
        target: (UInt8, UInt8, UInt8) = (200, 201, 202),
        side: BeautyObservedEyeSide? = nil
    ) -> [BeautyLocalPixelProposal] {
        resolution.outcomes
            .filter { side == nil || $0.side == side }
            .flatMap { outcome in
                outcome.pixelIndices.map { pixelIndex in
                    BeautyLocalPixelProposal(
                        pixelIndex: pixelIndex,
                        isInsideHardEnvelope: outcome.isSupported,
                        softWeightQ16: UInt32.max,
                        targetRed: target.0,
                        targetGreen: target.1,
                        targetBlue: target.2
                    )
                }
            }
    }

    private func canonical() throws -> BeautyCanonicalStillImage {
        try BeautyCanonicalStillImage(
            rgba8Data: Data(sourceBytes),
            width: 3,
            height: 2,
            rowBytes: 12,
            metadata: BeautyInputMetadata(
                orientation: .up,
                isInputMirrored: false,
                isPreviewMirrored: false,
                source: .testFixture
            )
        )
    }
}
