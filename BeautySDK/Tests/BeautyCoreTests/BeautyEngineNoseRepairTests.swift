import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import ImageIO
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyEngineNoseRepairTests: XCTestCase {
    private typealias O = NoseSemanticOracle
    private enum ExpectedImageColor { case namedSRGB, legacyDeviceRGB }
    private let extent = CGRect(x: 0, y: 0, width: 512, height: 512)
    private let siblingRows: [(String, BeautyParameters)] = [
        ("noseSlim_0p35", .init(noseSlim: 0.35)),
        ("noseWingSlim_0p35", .init(noseWingSlim: 0.35)),
        ("noseTipSize_plus0p30", .init(noseTipSize: 0.30)),
        ("noseTipSize_minus0p30", .init(noseTipSize: -0.30)),
        ("noseTipLift_0p25", .init(noseTipLift: 0.25)),
    ]

    func testNOSE01FrozenBridgeSemanticContract() throws {
        let value = try semantic(.bridge)
        XCTAssertTrue(value, "P93_SEM_BRIDGE")
    }

    func testNOSE02FrozenRootSemanticContract() throws {
        let value = try semantic(.root)
        XCTAssertTrue(value, "P93_SEM_ROOT")
    }

    func testNoseNeutralMetadataOrientationAndDeterminism() throws {
        let image = try NoseRepairFixture.image()
        let source = NoseRepairFixture.source()
        XCTAssertTrue(NoseRepairFixture.metadata().orientation == .up)
        let neutral = try process(image, parameters: .init(), expectedColor: .namedSRGB)
        XCTAssertEqual(neutral.invocations, 0)
        XCTAssertTrue(neutral.bytes == source)
        XCTAssertEqual(neutral.result.detectionSummary?.availability, .notRun)

        for id in O.CaseID.allCases {
            let capped = try process(image, parameters: parameters(id), expectedColor: .legacyDeviceRGB)
            let repeated = try process(image, parameters: parameters(id), expectedColor: .legacyDeviceRGB)
            assertRepeated(capped, repeated)
            let overflow = try process(image, parameters: id == .bridge ? .init(noseBridge: 1) : .init(noseRootNarrowing: 1), expectedColor: .legacyDeviceRGB, capped: 1)
            XCTAssertTrue(overflow.bytes == capped.bytes)
            XCTAssertTrue(overflow.result.warnings.contains { $0.code == "beauty_strength_capped" })
            let legacyProvider = SDKTestingFaceDetectionProvider([.phase93RegisteredNose])
            let legacy = try BeautyEngine(faceDetectionProvider: legacyProvider)
                .process(image: image, orientation: .up, parameters: parameters(id))
            XCTAssertEqual(legacyProvider.invocationCount, 1)
            XCTAssertTrue(try bytes(legacy, expectedColor: .legacyDeviceRGB) == capped.bytes)
        }

        // The raw facade retains its existing orientation metadata policy. Fixed
        // inverse encodings exercise both raw wrappers; canonical scoring above
        // uses .up only. No new raw-to-canonical output policy is assumed.
        let orientations: [(CGImagePropertyOrientation, CGImagePropertyOrientation)] = [
            (.up, .up), (.upMirrored, .upMirrored), (.down, .down), (.downMirrored, .downMirrored),
            (.leftMirrored, .leftMirrored), (.right, .left), (.rightMirrored, .rightMirrored), (.left, .right),
        ]
        for (orientation, inverse) in orientations {
            let encoded = image.oriented(inverse)
            let decoded = encoded.oriented(orientation)
            XCTAssertTrue(try bytes(decoded, expectedColor: .namedSRGB) == source)
            let metadata = BeautyInputMetadata(orientation: orientation, source: .photo)
            let provider = SDKTestingFaceDetectionProvider([.phase93RegisteredNose])
            let current = try BeautyEngine(faceDetectionProvider: provider).processResult(
                image: encoded, metadata: metadata, parameters: .init(noseBridge: 0.30))
            let oldProvider = SDKTestingFaceDetectionProvider([.phase93RegisteredNose])
            let old = try BeautyEngine(faceDetectionProvider: oldProvider).process(
                image: encoded, orientation: orientation, parameters: .init(noseBridge: 0.30))
            XCTAssertEqual(provider.invocationCount, 1)
            XCTAssertEqual(oldProvider.invocationCount, 1)
            XCTAssertTrue(try bytes(current.output, expectedColor: .legacyDeviceRGB) == bytes(old, expectedColor: .legacyDeviceRGB))
            assertRedacted(current)
            let noOp = try BeautyEngine(faceDetectionProvider: SDKTestingFaceDetectionProvider([.phase93RegisteredNose]))
                .processResult(image: encoded, metadata: metadata, parameters: .init())
            XCTAssertTrue(try bytes(noOp.output, expectedColor: .namedSRGB) == bytes(encoded, expectedColor: .namedSRGB))
        }
    }

    func testNoseMissingSupportIsSourceExact() throws {
        let image = try NoseRepairFixture.image()
        let source = NoseRepairFixture.source()
        for fixture: SDKTestingFaceDetectionFixture in [.phase93MissingNose, .noFace] {
            for intent in [BeautyParameters(noseBridge: 0.30), .init(noseRootNarrowing: 0.25),
                           .init(noseBridge: 0.30, noseRootNarrowing: 0.25)] {
                let result = try process(image, fixture: fixture, parameters: intent, expectedColor: .namedSRGB, usable: false)
                XCTAssertTrue(result.bytes == source)
                XCTAssertEqual(result.invocations, 1)
                XCTAssertEqual(result.result.metrics["beauty.effects.activeCount"], 0)
                XCTAssertEqual(result.result.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
                XCTAssertEqual(result.result.metrics["beauty.effects.skippedNoseDomains"], 1)
                XCTAssertEqual(result.result.detectionSummary?.usedFaceCount, 0)
                XCTAssertFalse(result.result.warnings.isEmpty)
            }
        }
    }

    func testNoseValidInvalidValidRecoveryIsRedacted() throws {
        let image = try NoseRepairFixture.image()
        let source = NoseRepairFixture.source()
        for missing: SDKTestingFaceDetectionFixture in [.phase93MissingNose, .noFace] {
            for intent in [BeautyParameters(noseBridge: 0.30), .init(noseRootNarrowing: 0.25)] {
                let provider = SDKTestingFaceDetectionProvider([.phase93RegisteredNose, missing, .phase93RegisteredNose])
                let engine = try BeautyEngine(faceDetectionProvider: provider)
                let first = try engine.processResult(image: image, metadata: NoseRepairFixture.metadata(), parameters: intent)
                engine.reset()
                let rejected = try engine.processResult(image: image, metadata: NoseRepairFixture.metadata(), parameters: intent)
                engine.reset()
                let recovered = try engine.processResult(image: image, metadata: NoseRepairFixture.metadata(), parameters: intent)
                XCTAssertEqual(provider.invocationCount, 3)
                XCTAssertEqual(engine.resetCountForTesting, 2)
                XCTAssertTrue(try bytes(first.output, expectedColor: .legacyDeviceRGB) == bytes(recovered.output, expectedColor: .legacyDeviceRGB))
                XCTAssertTrue(try bytes(rejected.output, expectedColor: .namedSRGB) == source)
                XCTAssertTrue(first.metrics == recovered.metrics)
                XCTAssertTrue(first.warnings == recovered.warnings)
                XCTAssertEqual(first.detectionSummary?.availability, .usable)
                XCTAssertEqual(recovered.detectionSummary?.availability, .usable)
                XCTAssertEqual(rejected.detectionSummary?.usedFaceCount, 0)
                XCTAssertEqual(rejected.metrics["beauty.effects.activeCount"], 0)
                XCTAssertEqual(rejected.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
                XCTAssertTrue(first.detectionSummary?.reasons == recovered.detectionSummary?.reasons)
                XCTAssertEqual(first.detectionSummary?.faceCount, recovered.detectionSummary?.faceCount)
                XCTAssertEqual(first.detectionSummary?.usedFaceCount, recovered.detectionSummary?.usedFaceCount)
                for (result, expectedColor) in [
                    (first, ExpectedImageColor.legacyDeviceRGB),
                    (rejected, .namedSRGB),
                    (recovered, .legacyDeviceRGB),
                ] {
                    assertRedacted(result)
                    _ = try bytes(result.output, expectedColor: expectedColor)
                }
            }
        }
    }

    func testNoseCombinedFieldsPreserveProtectedPixels() throws {
        let image = try NoseRepairFixture.image()
        let source = try oracleImage(NoseRepairFixture.source())
        let neutral = try process(image, parameters: .init(), expectedColor: .namedSRGB)
        let intent = BeautyParameters(noseBridge: 0.30, noseRootNarrowing: 0.25)
        let combined = try process(image, parameters: intent, expectedColor: .legacyDeviceRGB)
        let repeated = try process(image, parameters: intent, expectedColor: .legacyDeviceRGB)
        assertRepeated(combined, repeated)
        let bridge = try process(image, parameters: .init(noseBridge: 0.30), expectedColor: .legacyDeviceRGB)
        let root = try process(image, parameters: .init(noseRootNarrowing: 0.25), expectedColor: .legacyDeviceRGB)
        // Public diagnostics expose the final domain and point counts, not raw
        // fields. At total 0.55 no conflict attenuation is applicable.
        XCTAssertEqual(combined.result.metrics["beauty.effects.geometryPointCount"],
                       (bridge.result.metrics["beauty.effects.geometryPointCount"] ?? 0)
                       + (root.result.metrics["beauty.effects.geometryPointCount"] ?? 0))
        XCTAssertEqual(combined.result.metrics["beauty.effects.geometryStrengthScale"] ?? 1, 1)
        XCTAssertEqual(combined.result.metrics["beauty.effects.weakenedCount"] ?? 0, 0)
        let capped = try process(image, parameters: .init(noseBridge: 1, noseRootNarrowing: 1), expectedColor: .legacyDeviceRGB, capped: 2)
        XCTAssertTrue(capped.bytes == combined.bytes)
        let candidate = try oracleImage(combined.bytes), baseline = try oracleImage(neutral.bytes)
        let outside = try O.protection(source, baseline, candidate, regions: [O.bridge, O.root], outside: true)
        let tip = try O.protection(source, baseline, candidate, regions: [O.tip])
        let background = try O.protection(source, baseline, candidate, regions: O.background)
        let watermark = try O.protection(source, baseline, candidate, regions: [O.watermark])
        XCTAssertLessThanOrEqual(outside.changed, 128); XCTAssertLessThanOrEqual(outside.rgb, 512)
        XCTAssertLessThanOrEqual(tip.changed, 64); XCTAssertLessThanOrEqual(tip.rgb, 256)
        XCTAssertEqual(background.changed, 0); XCTAssertEqual(background.rgb, 0)
        XCTAssertEqual(watermark.changed, 0); XCTAssertEqual(watermark.rgb, 0)
    }

    private func parameters(_ id: O.CaseID) -> BeautyParameters {
        id == .bridge ? .init(noseBridge: 0.30) : .init(noseRootNarrowing: 0.25)
    }

    private func semantic(_ id: O.CaseID) throws -> Bool {
        let image = try NoseRepairFixture.image()
        let source = try oracleImage(NoseRepairFixture.source())
        let neutral = try process(image, parameters: .init(), expectedColor: .namedSRGB)
        XCTAssertTrue(neutral.bytes == source.bytes)
        XCTAssertEqual(neutral.invocations, 0)
        let candidate = try process(image, parameters: parameters(id), expectedColor: .legacyDeviceRGB)
        let repeated = try process(image, parameters: parameters(id), expectedColor: .legacyDeviceRGB)
        assertRepeated(candidate, repeated)
        var rows: [String: O.Image] = [:]
        var digests: [String: String] = [:]
        for (name, intent) in siblingRows {
            let row = try process(image, parameters: intent, expectedColor: .legacyDeviceRGB)
            rows[name] = try oracleImage(row.bytes)
            digests[name] = SHA256.hash(data: Data(row.bytes)).map { String(format: "%02x", $0) }.joined()
        }
        let peer: O.CaseID = id == .bridge ? .root : .bridge
        rows[peer.rawValue] = try oracleImage(process(image, parameters: parameters(peer), expectedColor: .legacyDeviceRGB).bytes)
        let admitted = Dictionary(uniqueKeysWithValues: try id.siblingIDs.map { name in
            (name, try XCTUnwrap(rows[name], "comparison admission"))
        })
        let evaluation = try O.evaluate(caseID: id, source: source, neutral: oracleImage(neutral.bytes),
                                        candidate: oracleImage(candidate.bytes), siblings: admitted)
        let protection = evaluation.protectedNose.reduce(O.Signal(), O.Signal.maximum)
        let passed = evaluation.passes(id)
        let row: [String: Any] = [
            "case": id == .bridge ? "bridge" : "root", "comparisons": admitted.count + 2,
            "source_changed": evaluation.source.changed, "neutral_changed": evaluation.neutral.changed,
            "source_rgb": evaluation.source.rgb, "neutral_rgb": evaluation.neutral.rgb,
            "source_margin": evaluation.sourceMargin, "neutral_margin": evaluation.neutralMargin,
            "sibling_margin": try XCTUnwrap(evaluation.siblingMargins.min()),
            "outside_changed": evaluation.outside.changed, "outside_rgb": evaluation.outside.rgb,
            "protected_changed": protection.changed, "protected_rgb": protection.rgb,
            "background_changed": evaluation.background.changed, "background_rgb": evaluation.background.rgb,
            "watermark_changed": evaluation.watermark.changed, "watermark_rgb": evaluation.watermark.rgb,
            "repeated": candidate.bytes == repeated.bytes ? 1 : 0,
            "verdict": passed ? "pass" : "semantic_red", "siblings": digests,
        ]
        let data = try JSONSerialization.data(withJSONObject: row, options: [.sortedKeys])
        print("P93_NOSE_AGGREGATE " + String(decoding: data, as: UTF8.self))
        // A protection failure must never receive an admitted semantic RED.
        XCTAssertTrue(evaluation.protectionPass, "frozen protection")
        return passed
    }

    private struct Processed {
        let result: BeautyResult<CIImage>
        let bytes: [UInt8]
        let invocations: Int
    }

    private func process(_ image: CIImage, fixture: SDKTestingFaceDetectionFixture = .phase93RegisteredNose,
                         parameters: BeautyParameters, expectedColor: ExpectedImageColor,
                         usable: Bool = true, capped: Double = 0) throws -> Processed {
        // All inputs here are the fixed named-sRGB fixture. The expectation
        // comes from the declared raw request and independently expected
        // support/emission, never the returned color space or diagnostics.
        let active = parameters != BeautyParameters()
        let expectedEmission = active && usable
        XCTAssertTrue(expectedColor == (expectedEmission ? .legacyDeviceRGB : .namedSRGB),
                      "declared raw route color contract")
        _ = try bytes(image, expectedColor: .namedSRGB)
        let provider = SDKTestingFaceDetectionProvider([fixture])
        let result = try BeautyEngine(faceDetectionProvider: provider).processResult(
            image: image, metadata: NoseRepairFixture.metadata(), parameters: parameters)
        let output = try bytes(result.output, expectedColor: expectedColor)
        assertRedacted(result)
        XCTAssertEqual(result.metrics["beauty.effects.cappedCount"], capped)
        if active {
            XCTAssertEqual(provider.invocationCount, 1)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
            if usable {
                XCTAssertEqual(result.detectionSummary?.availability, .usable)
                XCTAssertTrue(result.detectionSummary?.reasons.isEmpty == true)
                XCTAssertEqual(result.detectionSummary?.faceCount, 1)
                XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1)
                XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 1)
                XCTAssertGreaterThan(result.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
                XCTAssertFalse(result.warnings.contains { $0.code == "nose_inputs_missing" })
            }
        }
        return Processed(result: result, bytes: output, invocations: provider.invocationCount)
    }

    private func assertRepeated(_ a: Processed, _ b: Processed) {
        XCTAssertTrue(a.bytes == b.bytes)
        XCTAssertTrue(a.result.metrics == b.result.metrics)
        XCTAssertTrue(a.result.warnings == b.result.warnings)
        XCTAssertEqual(a.result.detectionSummary?.availability, b.result.detectionSummary?.availability)
        XCTAssertTrue(a.result.detectionSummary?.reasons == b.result.detectionSummary?.reasons)
    }

    private func bytes(_ image: CIImage, expectedColor: ExpectedImageColor) throws -> [UInt8] {
        XCTAssertTrue(image.extent == extent, "canonical extent")
        let color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let expected: CGColorSpace
        switch expectedColor {
        case .namedSRGB:
            expected = color
        case .legacyDeviceRGB:
            // DESIGN.md's raw/no-admission contract and the retained
            // geometry overload explicitly require this device RGB space.
            expected = CGColorSpaceCreateDeviceRGB()
        }
        let actual = try XCTUnwrap(image.colorSpace, "required image color space")
        XCTAssertTrue(actual.model == expected.model, "expected color model")
        XCTAssertTrue(actual.name == expected.name, "expected color name")
        XCTAssertEqual(actual.numberOfComponents, expected.numberOfComponents, "expected color components")
        XCTAssertTrue(CFEqual(actual, expected), "exact expected color space")
        // Extraction stays explicitly named-sRGB for every route. Only the
        // incoming image metadata expectation differs; pixel scoring does not.
        var output = [UInt8](repeating: 0, count: 512 * 512 * 4)
        let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
        output.withUnsafeMutableBytes { buffer in
            context.render(image, toBitmap: buffer.baseAddress!, rowBytes: 512 * 4,
                           bounds: extent, format: .RGBA8, colorSpace: color)
        }
        XCTAssertTrue(stride(from: 3, to: output.count, by: 4).allSatisfy { output[$0] == 255 }, "opaque output")
        return output
    }

    private func oracleImage(_ bytes: [UInt8]) throws -> O.Image {
        try O.Image(bytes, width: 512, height: 512)
    }

    private func assertRedacted(_ result: BeautyResult<CIImage>) {
        let text = (result.warnings.map { $0.code + " " + $0.message } + Array(result.metrics.keys)
                    + (result.detectionSummary?.reasons.map(\.rawValue) ?? [])).joined(separator: " ").lowercased()
        let forbidden = ["landmark", "coordinate", "controlpoint", "control point", "simd", "mask", "raw",
                         "pixel", "image bytes", "transcript", "path", "/private/", "file://"]
        XCTAssertTrue(forbidden.allSatisfy { !text.contains($0) }, "redacted diagnostics")
        XCTAssertTrue(result.metrics.values.allSatisfy(\.isFinite), "finite aggregate metadata")
    }
}
