import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

final class BeautyUpperEyelidFullnessEditorTests: XCTestCase {
    func testNeutralStrengthIsExactNoOpAndDiagnosticsAreAggregateOnly() throws {
        let source = try canonical()
        let result = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: support(leftPixels: [12]),
            strength: 0
        )

        XCTAssertEqual(result.summary.reason, .neutral)
        XCTAssertEqual(result.summary.proposalPixelCount, 0)
        XCTAssertTrue(result.proposalsByEye.isEmpty)
        let diagnostic = [
            String(describing: result),
            result.debugDescription,
            String(describing: Mirror(reflecting: result)),
        ].joined(separator: " ").lowercased()
        for forbidden in ["pixelindices", "coordinatepoint", "rgba8data", "/private/", "file://"] {
            XCTAssertFalse(diagnostic.contains(forbidden), forbidden)
        }
    }

    func testApprovedPixelUsesLowFrequencyCorrectionAndCarriesOriginalDetail() throws {
        let sourceBytes = gradientBytes(width: 5, height: 5)
        let source = try canonical(bytes: sourceBytes, width: 5, height: 5)
        let result = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: support(leftPixels: [12]),
            strength: 0.5
        )

        let proposal = try XCTUnwrap(result.proposalsByEye.first?.first)
        let sourcePixel = rgb(sourceBytes, pixelIndex: 12)
        let low = lowFrequency(sourceBytes, pixelIndex: 12, width: 5, height: 5)
        let correction = (
            red: Int((Double(128 - low.red) * 0.5 * 0.125).rounded(.toNearestOrAwayFromZero)),
            green: Int((Double(128 - low.green) * 0.5 * 0.125).rounded(.toNearestOrAwayFromZero)),
            blue: Int((Double(128 - low.blue) * 0.5 * 0.125).rounded(.toNearestOrAwayFromZero))
        )

        XCTAssertEqual(proposal.targetRed, UInt8(sourcePixel.red + correction.red))
        XCTAssertEqual(proposal.targetGreen, UInt8(sourcePixel.green + correction.green))
        XCTAssertEqual(proposal.targetBlue, UInt8(sourcePixel.blue + correction.blue))
        XCTAssertEqual(
            Int(proposal.targetRed),
            low.red + correction.red + (sourcePixel.red - low.red)
        )
        XCTAssertEqual(
            Int(proposal.targetGreen),
            low.green + correction.green + (sourcePixel.green - low.green)
        )
        XCTAssertEqual(
            Int(proposal.targetBlue),
            low.blue + correction.blue + (sourcePixel.blue - low.blue)
        )
        XCTAssertEqual(result.summary.acceptedEyeCount, 1)
        XCTAssertEqual(result.summary.rejectedEyeCount, 1)
        XCTAssertEqual(result.summary.proposalPixelCount, 1)
        XCTAssertGreaterThan(result.summary.changedPixelCount, 0)
        XCTAssertLessThanOrEqual(result.summary.maximumAbsoluteChannelDelta, 16)
    }

    func testInvalidSupportIsRejectedWithoutSuppressingValidPeer() throws {
        let source = try canonical()
        let resolution = BeautyUpperEyelidSupportResolution(
            left: .supported(
                side: .left,
                confidence: 0.9,
                reason: .approved,
                pixelIndices: [12, 12],
                hardEnvelope: fullEnvelope
            ),
            right: .supported(
                side: .right,
                confidence: 0.9,
                reason: .approved,
                pixelIndices: [13],
                hardEnvelope: fullEnvelope
            )
        )

        let result = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: resolution,
            strength: 1
        )

        XCTAssertEqual(result.summary.acceptedEyeCount, 1)
        XCTAssertEqual(result.summary.rejectedEyeCount, 1)
        XCTAssertEqual(result.proposalsByEye.count, 1)
        XCTAssertEqual(result.proposalsByEye.first?.map(\.pixelIndex), [13])
    }

    func testInvalidStrengthAndRepeatedRequestsFailClosedDeterministically() throws {
        let source = try canonical()
        let invalidValues = [Double.nan, .infinity, -0.01, 1.01]
        for value in invalidValues {
            let result = BeautyUpperEyelidFullnessEditor.edit(
                source: source,
                support: support(leftPixels: [12]),
                strength: value
            )
            XCTAssertEqual(result.summary.reason, .invalidStrength)
            XCTAssertTrue(result.proposalsByEye.isEmpty)
        }

        let first = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: support(leftPixels: [12, 13]),
            strength: 0.75
        )
        let second = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: support(leftPixels: [12, 13]),
            strength: 0.75
        )
        XCTAssertEqual(first.summary, second.summary)
        XCTAssertEqual(first.proposalsByEye, second.proposalsByEye)
    }

    private var fullEnvelope: CoordinateRect {
        CoordinateRect(x: 0, y: 0, width: 1, height: 1)
    }

    private func support(leftPixels: [Int]) -> BeautyUpperEyelidSupportResolution {
        BeautyUpperEyelidSupportResolution(
            left: .supported(
                side: .left,
                confidence: 0.9,
                reason: .approved,
                pixelIndices: leftPixels,
                hardEnvelope: fullEnvelope
            ),
            right: .sourceExactNoOp(
                side: .right,
                confidence: 0,
                reason: .semanticApprovalRejected
            )
        )
    }

    private func canonical(
        bytes: [UInt8] = [],
        width: Int = 5,
        height: Int = 5
    ) throws -> BeautyCanonicalStillImage {
        let values = bytes.isEmpty ? gradientBytes(width: width, height: height) : bytes
        return try BeautyCanonicalStillImage(
            rgba8Data: Data(values),
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

    private func gradientBytes(width: Int, height: Int) -> [UInt8] {
        (0..<(width * height)).flatMap { index in
            let x = index % width
            let y = index / width
            return [
                UInt8(40 + x * 3 + y),
                UInt8(70 + x * 2 + y * 2),
                UInt8(95 + x + y * 3),
                255,
            ]
        }
    }

    private func rgb(_ bytes: [UInt8], pixelIndex: Int) -> (red: Int, green: Int, blue: Int) {
        let offset = pixelIndex * 4
        return (Int(bytes[offset]), Int(bytes[offset + 1]), Int(bytes[offset + 2]))
    }

    private func lowFrequency(
        _ bytes: [UInt8],
        pixelIndex: Int,
        width: Int,
        height: Int
    ) -> (red: Int, green: Int, blue: Int) {
        let x = pixelIndex % width
        let y = pixelIndex / width
        var red = 0
        var green = 0
        var blue = 0
        var count = 0
        for sampleY in max(0, y - 1)...min(height - 1, y + 1) {
            for sampleX in max(0, x - 1)...min(width - 1, x + 1) {
                let sample = rgb(bytes, pixelIndex: sampleY * width + sampleX)
                red += sample.red
                green += sample.green
                blue += sample.blue
                count += 1
            }
        }
        return (
            (red + count / 2) / count,
            (green + count / 2) / count,
            (blue + count / 2) / count
        )
    }
}
