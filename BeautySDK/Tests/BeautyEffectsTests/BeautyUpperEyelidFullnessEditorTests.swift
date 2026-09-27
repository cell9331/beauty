import BeautyCore
import BeautyDetection
import BeautyRender
import Foundation
import XCTest
@testable import BeautyEffects

final class BeautyUpperEyelidFullnessEditorTests: XCTestCase {
    func testNeutralStrengthIsExactNoOpAndDiagnosticsAreAggregateOnly() throws {
        let fixture = try reliefFixture()
        let result = BeautyExperimentalUpperEyelidReliefEditor.edit(
            source: fixture.source,
            support: support(leftPixels: fixture.pixels),
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

    func testBoundaryAnchoredReliefCompressionFlattensConvexBulgeAndCarriesOriginalDetail() throws {
        let fixture = try reliefFixture(bulgeMagnitude: 24)
        let before = try XCTUnwrap(BeautyExperimentalUpperEyelidReliefModel.analyze(
            source: fixture.source,
            pixels: fixture.pixels
        ))
        XCTAssertTrue(before.isFullnessSupported)
        XCTAssertGreaterThan(before.centralConvexityScore, 8)

        let result = BeautyExperimentalUpperEyelidReliefEditor.edit(
            source: fixture.source,
            support: support(leftPixels: fixture.pixels),
            strength: 1
        )
        let proposals = try XCTUnwrap(result.proposalsByEye.first)
        XCTAssertEqual(proposals.count, fixture.pixels.count)
        XCTAssertEqual(result.summary.acceptedEyeCount, 1)
        XCTAssertEqual(result.summary.rejectedEyeCount, 1)
        XCTAssertGreaterThan(result.summary.changedPixelCount, 0)
        XCTAssertLessThanOrEqual(
            result.summary.maximumAbsoluteChannelDelta,
            BeautyExperimentalUpperEyelidReliefEditor.maximumAbsoluteChannelDelta
        )

        var corrections = Set<Int>()
        for proposal in proposals {
            let sourcePixel = rgb(fixture.source.rgba8Data, pixelIndex: proposal.pixelIndex)
            let correction = Int(proposal.targetRed) - sourcePixel.red
            corrections.insert(correction)
            XCTAssertEqual(Int(proposal.targetGreen) - sourcePixel.green, correction)
            XCTAssertEqual(Int(proposal.targetBlue) - sourcePixel.blue, correction)
            XCTAssertEqual(
                Int(proposal.targetRed) - Int(proposal.targetGreen),
                sourcePixel.red - sourcePixel.green
            )
            XCTAssertEqual(
                Int(proposal.targetGreen) - Int(proposal.targetBlue),
                sourcePixel.green - sourcePixel.blue
            )
        }
        XCTAssertGreaterThan(corrections.count, 5, "v4 must reshape relief, not apply one uniform darkening")
        XCTAssertLessThan(corrections.min() ?? 0, -8)
        XCTAssertGreaterThan(corrections.max() ?? 0, -2)

        let owner = BeautyLocalRetouchCompositionOwner(source: fixture.source)
        let composed = try owner.compose(result.makeUnits(using: owner)).canonicalImage
        let after = try XCTUnwrap(BeautyExperimentalUpperEyelidReliefModel.analyze(
            source: composed,
            pixels: fixture.pixels
        ))
        XCTAssertLessThan(after.centralConvexityScore, before.centralConvexityScore * 0.55)
        XCTAssertEqual(composed.width, fixture.source.width)
        XCTAssertEqual(composed.height, fixture.source.height)
        XCTAssertEqual(composed.rowBytes, fixture.source.rowBytes)
        XCTAssertEqual(composed.metadata, fixture.source.metadata)
        XCTAssertTrue(alphaBytes(composed.rgba8Data).allSatisfy { $0 == 255 })
    }

    func testHalfStrengthConvexReliefImprovesBeyondFrozenV121Baseline() throws {
        let fixture = try reliefFixture(bulgeMagnitude: 24)
        let before = try XCTUnwrap(BeautyExperimentalUpperEyelidReliefModel.analyze(
            source: fixture.source,
            pixels: fixture.pixels
        ))
        XCTAssertEqual(before.centralConvexityScore, 9.3623085, accuracy: 0.0001)
        let edit = BeautyExperimentalUpperEyelidReliefEditor.edit(
            source: fixture.source,
            support: support(leftPixels: fixture.pixels),
            strength: 0.5
        )
        XCTAssertEqual(edit.summary.reason, .edited)
        let rawCorrections = try XCTUnwrap(edit.proposalsByEye.first).map { proposal in
            Int(proposal.targetRed) - rgb(fixture.source.rgba8Data, pixelIndex: proposal.pixelIndex).red
        }
        // A uniform darkening can lower the center-vs-boundary score after
        // feathering. Require a spatial relief correction before using it.
        XCTAssertGreaterThan(Set(rawCorrections).count, 5)
        XCTAssertLessThan(rawCorrections.min() ?? 0, -4)
        XCTAssertGreaterThan(rawCorrections.max() ?? 0, -2)
        let owner = BeautyLocalRetouchCompositionOwner(source: fixture.source)
        let composed = try owner.compose(edit.makeUnits(using: owner)).canonicalImage
        let after = try XCTUnwrap(BeautyExperimentalUpperEyelidReliefModel.analyze(
            source: composed,
            pixels: fixture.pixels
        ))
        let ratio = after.centralConvexityScore / before.centralConvexityScore
        let frozenV121Ratio = 0.4537424
        XCTAssertLessThanOrEqual(ratio, 0.35)
        XCTAssertLessThanOrEqual(ratio, frozenV121Ratio - 0.10)
    }

    func testPlanarLightingAndFineCreaseDetailDoNotCreateFullnessApproval() throws {
        let fixture = try reliefFixture(bulgeMagnitude: 0, includeCreaseDetail: true)
        let model = try XCTUnwrap(BeautyExperimentalUpperEyelidReliefModel.analyze(
            source: fixture.source,
            pixels: fixture.pixels
        ))
        XCTAssertFalse(model.isFullnessSupported)
        XCTAssertLessThan(
            model.centralConvexityScore,
            BeautyExperimentalUpperEyelidReliefModel.minimumConvexityScore
        )

        let result = BeautyExperimentalUpperEyelidReliefEditor.edit(
            source: fixture.source,
            support: support(leftPixels: fixture.pixels),
            strength: 1
        )
        XCTAssertEqual(result.summary.reason, .noApprovedSupport)
        XCTAssertTrue(result.proposalsByEye.isEmpty)
    }

    func testMixedLightingKeepsLocalizedConvexReliefWithoutApprovingPlanarPeer() throws {
        let positive = try reliefFixture(bulgeMagnitude: 0, localizedBulgeMagnitude: 35,
                                         oppositeShadowMagnitude: 90)
        let model = try XCTUnwrap(BeautyExperimentalUpperEyelidReliefModel.analyze(
            source: positive.source, pixels: positive.pixels
        ))
        XCTAssertLessThan(model.centralConvexityScore,
                          BeautyExperimentalUpperEyelidReliefModel.minimumConvexityScore)
        XCTAssertTrue(model.isFullnessSupported)
        XCTAssertGreaterThanOrEqual(model.localizedConvexityScore,
                                    BeautyExperimentalUpperEyelidReliefModel.minimumLocalizedConvexityScore)
        let edit = BeautyExperimentalUpperEyelidReliefEditor.edit(
            source: positive.source, support: support(leftPixels: positive.pixels), strength: 1
        )
        XCTAssertEqual(edit.summary.acceptedEyeCount, 1)
        XCTAssertLessThanOrEqual(edit.summary.maximumAbsoluteChannelDelta, 16)
        let owner = BeautyLocalRetouchCompositionOwner(source: positive.source)
        let composed = try owner.compose(edit.makeUnits(using: owner)).canonicalImage
        let after = try XCTUnwrap(BeautyExperimentalUpperEyelidReliefModel.analyze(
            source: composed, pixels: positive.pixels
        ))
        XCTAssertLessThan(after.localizedConvexityScore, model.localizedConvexityScore * 0.85)
        let negative = try reliefFixture(bulgeMagnitude: 0, includeCreaseDetail: true)
        let negativeModel = try XCTUnwrap(BeautyExperimentalUpperEyelidReliefModel.analyze(
            source: negative.source, pixels: negative.pixels
        ))
        XCTAssertFalse(negativeModel.isFullnessSupported)
    }

    func testRejectedExperimentalSemanticOwnerApprovesGeneratedReliefAndRejectsPlanarPeer() throws {
        let positive = try reliefFixture(bulgeMagnitude: 24)
        let negative = try reliefFixture(bulgeMagnitude: 0)
        let request = semanticRequest(
            width: positive.source.width,
            height: positive.source.height,
            envelope: positive.envelope
        )

        let positiveApproval = try XCTUnwrap(
            BeautyExperimentalUpperEyelidFullnessSemanticAnalyzer.makeOwner(source: positive.source)([request]).first
        )
        XCTAssertTrue(positiveApproval.approved)
        XCTAssertEqual(positiveApproval.reason, .approved)
        XCTAssertGreaterThanOrEqual(
            positiveApproval.confidence,
            BeautyUpperEyelidSemanticSupportOwner.minimumConfidence
        )
        XCTAssertFalse(positiveApproval.pixels.isEmpty)

        let negativeApproval = try XCTUnwrap(
            BeautyExperimentalUpperEyelidFullnessSemanticAnalyzer.makeOwner(source: negative.source)([request]).first
        )
        XCTAssertFalse(negativeApproval.approved)
        XCTAssertEqual(negativeApproval.reason, .semanticApprovalRejected)
        XCTAssertTrue(negativeApproval.pixels.isEmpty)
    }

    func testInvalidSupportIsRejectedWithoutSuppressingValidPeer() throws {
        let fixture = try reliefFixture(bulgeMagnitude: 24)
        let duplicate = [fixture.pixels[0], fixture.pixels[0]]
        let resolution = BeautyUpperEyelidSupportResolution(
            left: .supported(
                side: .left,
                confidence: 0.9,
                reason: .approved,
                pixels: duplicate,
                hardEnvelope: fixture.envelope
            ),
            right: .supported(
                side: .right,
                confidence: 0.9,
                reason: .approved,
                pixels: fixture.pixels,
                hardEnvelope: fixture.envelope
            )
        )

        let result = BeautyExperimentalUpperEyelidReliefEditor.edit(
            source: fixture.source,
            support: resolution,
            strength: 1
        )

        XCTAssertEqual(result.summary.acceptedEyeCount, 1)
        XCTAssertEqual(result.summary.rejectedEyeCount, 1)
        XCTAssertEqual(result.proposalsByEye.count, 1)
        XCTAssertEqual(result.proposalsByEye.first?.count, fixture.pixels.count)
    }

    func testInvalidStrengthAndRepeatedRequestsFailClosedDeterministically() throws {
        let fixture = try reliefFixture(bulgeMagnitude: 24)
        for value in [Double.nan, .infinity, -0.01, 1.01] {
            let result = BeautyExperimentalUpperEyelidReliefEditor.edit(
                source: fixture.source,
                support: support(leftPixels: fixture.pixels),
                strength: value
            )
            XCTAssertEqual(result.summary.reason, .invalidStrength)
            XCTAssertTrue(result.proposalsByEye.isEmpty)
        }

        let first = BeautyExperimentalUpperEyelidReliefEditor.edit(
            source: fixture.source,
            support: support(leftPixels: fixture.pixels),
            strength: 0.75
        )
        let second = BeautyExperimentalUpperEyelidReliefEditor.edit(
            source: fixture.source,
            support: support(leftPixels: fixture.pixels),
            strength: 0.75
        )
        XCTAssertEqual(first.summary, second.summary)
        XCTAssertEqual(first.proposalsByEye, second.proposalsByEye)
    }

    private func semanticRequest(
        width: Int,
        height: Int,
        envelope: CoordinateRect
    ) -> BeautyUpperEyelidSemanticRequest {
        BeautyUpperEyelidSemanticRequest(
            side: .left,
            observation: BeautyFaceObservation(),
            eyeEnvelope: CoordinateRect(x: 0.2, y: 0.75, width: 0.6, height: 0.15),
            permittedEnvelope: envelope,
            imageWidth: width,
            imageHeight: height
        )
    }

    private func support(
        leftPixels: [BeautyUpperEyelidSupportPixel]
    ) -> BeautyUpperEyelidSupportResolution {
        BeautyUpperEyelidSupportResolution(
            left: .supported(
                side: .left,
                confidence: 0.9,
                reason: .approved,
                pixels: leftPixels,
                hardEnvelope: fullEnvelope
            ),
            right: .sourceExactNoOp(
                side: .right,
                confidence: 0,
                reason: .semanticApprovalRejected
            )
        )
    }

    private var fullEnvelope: CoordinateRect {
        CoordinateRect(x: 0, y: 0, width: 1, height: 1)
    }

    private func reliefFixture(
        bulgeMagnitude: Int = 22,
        includeCreaseDetail: Bool = false,
        localizedBulgeMagnitude: Int = 0,
        oppositeShadowMagnitude: Int = 0,
        width: Int = 161,
        height: Int = 81
    ) throws -> (
        source: BeautyCanonicalStillImage,
        pixels: [BeautyUpperEyelidSupportPixel],
        envelope: CoordinateRect
    ) {
        let envelope = CoordinateRect(
            x: 6.0 / Double(width),
            y: 5.0 / Double(height),
            width: 49.0 / Double(width),
            height: 21.0 / Double(height)
        )
        let centerX = 30.0
        let centerY = 15.0
        let radiusX = 24.0
        let radiusY = 10.0
        var bytes: [UInt8] = []
        bytes.reserveCapacity(width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let normalizedX = (Double(x) - centerX) / radiusX
                let normalizedY = (Double(y) - centerY) / radiusY
                let radialSquared = normalizedX * normalizedX + normalizedY * normalizedY
                let bulge = radialSquared < 1
                    ? Int((Double(bulgeMagnitude) * pow(1 - radialSquared, 2)).rounded())
                    : 0
                let texture = ((x * 17 + y * 13) % 7) - 3
                let crease = includeCreaseDetail && y == 21 && (13...47).contains(x) ? -12 : 0
                let lobeDistance = pow((Double(x) - 37) / 8, 2) +
                    pow((Double(y) - 15) / 6, 2)
                let localizedBulge = Int((Double(localizedBulgeMagnitude) *
                    exp(-lobeDistance / 2)).rounded())
                let shadowDistance = pow((Double(x) - 17) / 8, 2) +
                    pow((Double(y) - 15) / 6, 2)
                let oppositeShadow = Int((Double(oppositeShadowMagnitude) *
                    exp(-shadowDistance / 2)).rounded())
                let base = 88 + x / 3 + y / 4 + bulge + localizedBulge + texture + crease - oppositeShadow
                bytes.append(UInt8(clamping: base + 22))
                bytes.append(UInt8(clamping: base + 10))
                bytes.append(UInt8(clamping: base))
                bytes.append(255)
            }
        }
        let source = try BeautyCanonicalStillImage(
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
        let pixels = BeautyUpperEyelidSemanticSupportOwner.maximumFeatheredPixels(
            inside: envelope,
            imageWidth: width,
            imageHeight: height
        )
        return (source, pixels, envelope)
    }

    private func rgb(
        _ data: Data,
        pixelIndex: Int
    ) -> (red: Int, green: Int, blue: Int) {
        let offset = pixelIndex * 4
        return (Int(data[offset]), Int(data[offset + 1]), Int(data[offset + 2]))
    }

    private func alphaBytes(_ data: Data) -> [UInt8] {
        stride(from: 3, to: data.count, by: 4).map { data[$0] }
    }
}
