import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

final class BeautyUpperEyelidEditorSafetyTests: XCTestCase {
    func testCompositionChangesOnlyApprovedEyeAndPreservesProtectedExteriorAndMetadata() throws {
        let source = try canonical()
        let resolution = resolution(
            left: .supported(
                side: .left,
                confidence: 0.9,
                reason: .approved,
                pixelIndices: [12],
                hardEnvelope: fullEnvelope
            ),
            right: .sourceExactNoOp(
                side: .right,
                confidence: 0,
                reason: .semanticApprovalRejected
            )
        )
        let edit = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: resolution,
            strength: 0.75
        )
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let output = try owner.compose(edit.makeUnits(using: owner))

        XCTAssertEqual(output.canonicalImage.width, source.width)
        XCTAssertEqual(output.canonicalImage.height, source.height)
        XCTAssertEqual(output.canonicalImage.rowBytes, source.rowBytes)
        XCTAssertEqual(output.canonicalImage.metadata, source.metadata)
        XCTAssertEqual(output.summary.changedOutsideUnionPixelCount, 0)
        XCTAssertEqual(output.summary.collisionPixelCount, 0)

        let sourceBytes = Array(source.rgba8Data)
        let outputBytes = Array(output.canonicalImage.rgba8Data)
        for pixelIndex in 0..<(source.width * source.height) {
            let offset = pixelIndex * 4
            XCTAssertEqual(outputBytes[offset + 3], sourceBytes[offset + 3], "alpha pixel \(pixelIndex)")
            if pixelIndex != 12 {
                XCTAssertEqual(
                    Array(outputBytes[offset..<(offset + 4)]),
                    Array(sourceBytes[offset..<(offset + 4)]),
                    "outside pixel \(pixelIndex)"
                )
            }
        }
        for protectedPixel in [6, 7, 8, 11, 13, 16, 17, 18] {
            let offset = protectedPixel * 4
            XCTAssertEqual(
                Array(outputBytes[offset..<(offset + 4)]),
                Array(sourceBytes[offset..<(offset + 4)]),
                "protected pixel \(protectedPixel)"
            )
        }
    }

    func testOverlappingEyeUnitsReturnImmutableSourceAndCountOneCollision() throws {
        let source = try canonical()
        let edit = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: resolution(
                left: .supported(
                    side: .left,
                    confidence: 0.9,
                    reason: .approved,
                    pixelIndices: [12],
                    hardEnvelope: fullEnvelope
                ),
                right: .supported(
                    side: .right,
                    confidence: 0.9,
                    reason: .approved,
                    pixelIndices: [12],
                    hardEnvelope: fullEnvelope
                )
            ),
            strength: 1
        )
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let output = try owner.compose(edit.makeUnits(using: owner))

        XCTAssertEqual(Array(output.canonicalImage.rgba8Data), Array(source.rgba8Data))
        XCTAssertEqual(output.summary.collisionPixelCount, 1)
        XCTAssertEqual(output.summary.changedPixelCount, 0)
        XCTAssertEqual(output.canonicalImage.metadata, source.metadata)
    }

    func testRepeatedEditorCompositionIsByteDeterministicAndRejectedEyeHasNoUnit() throws {
        let source = try canonical()
        let support = resolution(
            left: .supported(
                side: .left,
                confidence: 0.9,
                reason: .approved,
                pixelIndices: [12, 13],
                hardEnvelope: fullEnvelope
            ),
            right: .sourceExactNoOp(
                side: .right,
                confidence: 0,
                reason: .closed
            )
        )
        let first = BeautyUpperEyelidFullnessEditor.edit(source: source, support: support, strength: 0.5)
        let second = BeautyUpperEyelidFullnessEditor.edit(source: source, support: support, strength: 0.5)
        XCTAssertEqual(first.proposalsByEye, second.proposalsByEye)

        let firstOwner = BeautyLocalRetouchCompositionOwner(source: source)
        let secondOwner = BeautyLocalRetouchCompositionOwner(source: source)
        let firstOutput = try firstOwner.compose(first.makeUnits(using: firstOwner))
        let secondOutput = try secondOwner.compose(second.makeUnits(using: secondOwner))
        XCTAssertEqual(Array(firstOutput.canonicalImage.rgba8Data), Array(secondOutput.canonicalImage.rgba8Data))
        XCTAssertEqual(firstOutput.summary, secondOutput.summary)
        XCTAssertEqual(first.summary.acceptedEyeCount, 1)
        XCTAssertEqual(first.summary.rejectedEyeCount, 1)
    }

    private var fullEnvelope: CoordinateRect {
        CoordinateRect(x: 0, y: 0, width: 1, height: 1)
    }

    private func resolution(
        left: BeautyUpperEyelidEyeOutcome,
        right: BeautyUpperEyelidEyeOutcome
    ) -> BeautyUpperEyelidSupportResolution {
        BeautyUpperEyelidSupportResolution(left: left, right: right)
    }

    private func canonical() throws -> BeautyCanonicalStillImage {
        let bytes = (0..<25).flatMap { index in
            let x = index % 5
            let y = index / 5
            return [
                UInt8(40 + x * 3 + y),
                UInt8(70 + x * 2 + y * 2),
                UInt8(95 + x + y * 3),
                255,
            ]
        }
        return try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes),
            width: 5,
            height: 5,
            rowBytes: 20,
            metadata: BeautyInputMetadata(
                orientation: .up,
                isInputMirrored: false,
                isPreviewMirrored: false,
                source: .testFixture
            )
        )
    }
}
