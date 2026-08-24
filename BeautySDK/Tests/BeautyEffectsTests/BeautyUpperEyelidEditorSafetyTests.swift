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
                pixels: weightedPixels([12]),
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
                    pixels: weightedPixels([12]),
                    hardEnvelope: fullEnvelope
                ),
                right: .supported(
                    side: .right,
                    confidence: 0.9,
                    reason: .approved,
                    pixels: weightedPixels([12]),
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
                pixels: weightedPixels([12, 13]),
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

    func testFeatheredBandRetainsTextureAndCannotCreateRectangularBoundary() throws {
        let width = 64
        let height = 40
        let source = try texturedCanonical(width: width, height: height)
        let envelope = CoordinateRect(x: 0.18, y: 0.25, width: 0.64, height: 0.30)
        let pixels = BeautyUpperEyelidSemanticSupportOwner.maximumFeatheredPixels(
            inside: envelope,
            imageWidth: width,
            imageHeight: height
        )
        XCTAssertGreaterThan(pixels.count, 100)
        XCTAssertTrue(pixels.contains(where: { $0.softWeightQ16 < 8_192 }))
        XCTAssertTrue(pixels.contains(where: { $0.softWeightQ16 == 65_536 }))

        let support = resolution(
            left: .supported(
                side: .left,
                confidence: 0.9,
                reason: .approved,
                pixels: pixels,
                hardEnvelope: envelope
            ),
            right: .sourceExactNoOp(
                side: .right,
                confidence: 0,
                reason: .semanticApprovalRejected
            )
        )
        let edit = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: support,
            strength: 1
        )
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let output = try owner.compose(edit.makeUnits(using: owner)).canonicalImage

        XCTAssertGreaterThan(edit.summary.changedPixelCount, 0)
        XCTAssertLessThanOrEqual(edit.summary.maximumAbsoluteChannelDelta, 16)
        let supported = Set(pixels.map(\.pixelIndex))
        let sourceBytes = Array(source.rgba8Data)
        let outputBytes = Array(output.rgba8Data)
        var maximumAdjacentCorrectionJump = 0
        for pixelIndex in 0..<(width * height) {
            let offset = pixelIndex * 4
            XCTAssertEqual(outputBytes[offset + 3], sourceBytes[offset + 3])
            let redCorrection = Int(outputBytes[offset]) - Int(sourceBytes[offset])
            let greenCorrection = Int(outputBytes[offset + 1]) - Int(sourceBytes[offset + 1])
            let blueCorrection = Int(outputBytes[offset + 2]) - Int(sourceBytes[offset + 2])
            XCTAssertLessThanOrEqual(redCorrection, 0)
            XCTAssertEqual(greenCorrection, redCorrection)
            XCTAssertEqual(blueCorrection, redCorrection)
            if !supported.contains(pixelIndex) {
                XCTAssertEqual(
                    Array(outputBytes[offset..<(offset + 4)]),
                    Array(sourceBytes[offset..<(offset + 4)]),
                    "unowned pixel \(pixelIndex)"
                )
            }
            if pixelIndex % width < width - 1 {
                let nextOffset = offset + 4
                let correction = redCorrection
                let nextCorrection = Int(outputBytes[nextOffset]) - Int(sourceBytes[nextOffset])
                maximumAdjacentCorrectionJump = max(
                    maximumAdjacentCorrectionJump,
                    abs(correction - nextCorrection)
                )
            }
        }
        XCTAssertLessThanOrEqual(maximumAdjacentCorrectionJump, 5)

        let interior = supported.filter { index in
            let x = index % width
            let y = index / width
            return x > 0 && x < width - 1 && y > 0 && y < height - 1
                && supported.contains(index - 1)
                && supported.contains(index + 1)
                && supported.contains(index - width)
                && supported.contains(index + width)
        }
        let sourceTexture = highFrequencyEnergy(sourceBytes, pixels: interior, width: width)
        let outputTexture = highFrequencyEnergy(outputBytes, pixels: interior, width: width)
        XCTAssertGreaterThan(sourceTexture, 0)
        XCTAssertGreaterThanOrEqual(outputTexture / sourceTexture, 0.98)

        for protectedRow in [9, 22] {
            for x in 0..<width {
                let offset = (protectedRow * width + x) * 4
                XCTAssertEqual(
                    Array(outputBytes[offset..<(offset + 4)]),
                    Array(sourceBytes[offset..<(offset + 4)])
                )
            }
        }
    }

    private var fullEnvelope: CoordinateRect {
        CoordinateRect(x: 0, y: 0, width: 1, height: 1)
    }

    private func weightedPixels(_ indices: [Int]) -> [BeautyUpperEyelidSupportPixel] {
        indices.map { BeautyUpperEyelidSupportPixel(pixelIndex: $0, softWeightQ16: 65_536) }
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

    private func texturedCanonical(width: Int, height: Int) throws -> BeautyCanonicalStillImage {
        let bytes = (0..<(width * height)).flatMap { index -> [UInt8] in
            let x = index % width
            let y = index / width
            let dx = Double(x) - Double(width - 1) * 0.5
            let dy = (Double(y) - Double(height - 1) * 0.42) * 1.8
            let broadHighlight = Int((14 * exp(-(dx * dx + dy * dy) / 180)).rounded())
            let detail = ((x * 7 + y * 11) % 5) - 2
            let base = 112 + x / 6 + y / 8 + broadHighlight + detail
            return [UInt8(base + 12), UInt8(base + 4), UInt8(base), 255]
        }
        return try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes),
            width: width,
            height: height,
            rowBytes: width * 4,
            metadata: BeautyInputMetadata(
                orientation: .up,
                isInputMirrored: false,
                isPreviewMirrored: false,
                source: .testFixture
            )
        )
    }

    private func highFrequencyEnergy(
        _ bytes: [UInt8],
        pixels: Set<Int>,
        width: Int
    ) -> Double {
        pixels.reduce(0) { total, index in
            let center = luminance(bytes, pixelIndex: index)
            let laplacian = 4 * center
                - luminance(bytes, pixelIndex: index - 1)
                - luminance(bytes, pixelIndex: index + 1)
                - luminance(bytes, pixelIndex: index - width)
                - luminance(bytes, pixelIndex: index + width)
            return total + Double(abs(laplacian))
        }
    }

    private func luminance(_ bytes: [UInt8], pixelIndex: Int) -> Int {
        let offset = pixelIndex * 4
        return (54 * Int(bytes[offset])
            + 183 * Int(bytes[offset + 1])
            + 19 * Int(bytes[offset + 2])
            + 128) >> 8
    }
}
