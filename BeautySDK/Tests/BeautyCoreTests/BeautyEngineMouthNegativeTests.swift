import BeautyCore
import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyEngineMouthNegativeTests: XCTestCase {
    private typealias B = MouthBaselineOracle
    private typealias N = MouthNegativeOracle
    private let extent = CGRect(x: 0, y: 0, width: 640, height: 800)
    private let rows: [(String, BeautyParameters)] = [
        ("geometryBaseline_noop", .init()),
        ("mouthWidth_minus0p35", .init(mouthWidth: -0.35)),
        ("mouthWidth_plus0p35", .init(mouthWidth: 0.35)),
        ("mouthSize_plus0p35", .init(mouthSize: 0.35)),
        ("mouthSize_minus0p35", .init(mouthSize: -0.35))
    ]
    private var diagnosticRow = "source"
    private enum Stage: String, Error {
        case source = "P94N_STAGE_SOURCE"
        case detect = "P94N_STAGE_DETECT"
        case result = "P94N_STAGE_RESULT"
        case legacy = "P94N_STAGE_LEGACY"
        case extract = "P94N_STAGE_EXTRACT"
        case metric = "P94N_STAGE_METRIC"
        case receipt = "P94N_STAGE_RECEIPT"
    }

    func testNegativeWidthAllFiveComparisons() {
        do {
            let image = try at(.source) { try MouthRepairFixture.image() }
            let source = MouthRepairFixture.source()
            let carrier = try at(.source) { try extract(image, active: false) }
            check(carrier == source, "P94N_STAGE_SOURCE")
            let retained = try at(.receipt) { try inheritedDigests() }
            check(retained["source"] == sha(source), "P94N_STAGE_RECEIPT")
            var outputs: [[UInt8]] = []
            // Exactly twenty returned images: five rows, both real wrappers,
            // each twice. Fresh engines serialize the explicit CPU path.
            for row in rows {
                diagnosticRow = row.0
                let bytes = try render(row, image: image, source: source)
                outputs.append(bytes)
                if row.0 != "mouthWidth_minus0p35" {
                    check(retained[row.0] == sha(bytes), "P94N_STAGE_RECEIPT")
                }
            }
            diagnosticRow = "mouthWidth_minus0p35"
            guard outputs.count == 5 else { throw Stage.metric }
            let measured = try at(.metric) {
                let contract = try B.Contract.load(width: 640, height: 800)
                return try N.measure(source: oracle(source), neutral: oracle(outputs[0]),
                                     negative: oracle(outputs[1]), positive: oracle(outputs[2]),
                                     sizePlus: oracle(outputs[3]), sizeMinus: oracle(outputs[4]), contract: contract)
            }
            // Emit all margins, protection maxima and seventeen outcomes in
            // this invocation before independently asserting each predicate.
            try at(.receipt) { try emit(measured) }
            for marker in measured.predicates.keys.sorted() {
                check(measured.predicates[marker] == true, marker)
            }
        } catch let stage as Stage {
            fail(stage.rawValue)
        } catch {
            // Never interpolate a thrown object into XCTest output.
            fail("P94N_STAGE_METRIC")
        }
    }

    // Only fixed row IDs from the local manifest and a literal orientation
    // enter assertion diagnostics. Values, image objects and errors never do.
    private func check(_ condition: Bool, _ marker: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(condition, marker + " row=" + diagnosticRow + " orientation=up", file: file, line: line)
    }
    private func fail(_ marker: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTFail(marker + " row=" + diagnosticRow + " orientation=up", file: file, line: line)
    }

    private func render(_ row: (String, BeautyParameters), image: CIImage, source: [UInt8]) throws -> [UInt8] {
        let active = row.0 != "geometryBaseline_noop"
        var first: [UInt8]?
        var firstResult: BeautyResult<CIImage>?
        for _ in 0..<2 {
            let provider = SDKTestingFaceDetectionProvider([.phase94MouthPortrait])
            let engine = try at(.detect) {
                try BeautyEngine(configuration: BeautyConfiguration(renderBackend: .cpu), faceDetectionProvider: provider)
            }
            let result = try at(.result) {
                try engine.processResult(image: image, metadata: MouthRepairFixture.metadata(), parameters: row.1)
            }
            check(provider.invocationCount == (active ? 1 : 0), "P94N_STAGE_DETECT")
            checkMetadata(result, active: active)
            let bytes = try at(.extract) { try extract(result.output, active: active) }
            let legacyProvider = SDKTestingFaceDetectionProvider([.phase94MouthPortrait])
            let legacyEngine = try at(.detect) {
                try BeautyEngine(configuration: BeautyConfiguration(renderBackend: .cpu), faceDetectionProvider: legacyProvider)
            }
            let legacy = try at(.legacy) {
                try legacyEngine.process(image: image, orientation: .up, parameters: row.1)
            }
            check(legacyProvider.invocationCount == (active ? 1 : 0), "P94N_STAGE_DETECT")
            let legacyBytes = try at(.extract) { try extract(legacy, active: active) }
            check(sameColor(result.output, legacy), "P94N_META_COLOR")
            check(bytes == legacyBytes && sha(bytes) == sha(legacyBytes), "P94N_META_REPEAT")
            if let previous = first {
                check(previous == bytes && sha(previous) == sha(bytes), "P94N_META_REPEAT")
            } else {
                first = bytes
            }
            if let previous = firstResult {
                check(sameColor(previous.output, result.output), "P94N_META_COLOR")
                check(previous.metrics == result.metrics && previous.warnings == result.warnings,
                              "P94N_META_REPEAT")
                check(previous.detectionSummary?.availability == result.detectionSummary?.availability
                              && previous.detectionSummary?.reasons == result.detectionSummary?.reasons,
                              "P94N_META_REPEAT")
            } else {
                firstResult = result
            }
            if !active {
                check(bytes == source && legacyBytes == source, "P94N_META_REPEAT")
            }
        }
        guard let first else { throw Stage.result }
        return first
    }

    private func checkMetadata(_ result: BeautyResult<CIImage>, active: Bool) {
        check(result.detectionSummary?.reasons == [], "P94N_META_REASONS")
        check(result.detectionSummary?.availability == (active ? .usable : .notRun), "P94N_META_REASONS")
        check(result.metrics.values.allSatisfy { $0.isFinite }, "P94N_META_REASONS")
        if active {
            check(result.detectionSummary?.faceCount == 1 && result.detectionSummary?.usedFaceCount == 1,
                          "P94N_META_REASONS")
        }
        let text = (result.warnings.map { $0.code + " " + $0.message } + Array(result.metrics.keys))
            .joined(separator: " ").lowercased()
        let forbidden = ["landmark", "coordinate", "controlpoint", "control point", "simd", "mask", "raw",
                         "pixel", "image bytes", "transcript", "path", "/private/", "file://"]
        check(forbidden.allSatisfy { !text.contains($0) }, "P94N_META_REASONS")
    }

    private func sameColor(_ lhs: CIImage, _ rhs: CIImage) -> Bool {
        guard let left = lhs.colorSpace, let right = rhs.colorSpace else { return false }
        return CFEqual(left, right)
    }

    private func extract(_ image: CIImage, active: Bool) throws -> [UInt8] {
        check(image.extent == extent, "P94N_META_EXTENT")
        guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB) else { throw Stage.extract }
        // All active rows emit raw geometry; neutral requires named sRGB.
        if let actual = image.colorSpace {
            let expected = active ? CGColorSpaceCreateDeviceRGB() : sRGB
            check(actual.model == expected.model && actual.name == expected.name,
                          "P94N_META_COLOR")
            check(actual.numberOfComponents == expected.numberOfComponents && CFEqual(actual, expected),
                          "P94N_META_COLOR")
        } else {
            fail("P94N_META_COLOR")
        }
        var bytes = [UInt8](repeating: 0, count: 640 * 800 * 4)
        let context = CIContext(options: [.workingColorSpace: sRGB, .outputColorSpace: sRGB])
        bytes.withUnsafeMutableBytes { buffer in
            context.render(image, toBitmap: buffer.baseAddress!, rowBytes: 640 * 4,
                           bounds: extent, format: .RGBA8, colorSpace: sRGB)
        }
        var opaque = true
        for i in stride(from: 3, to: bytes.count, by: 4) {
            if bytes[i] != 255 { opaque = false; break }
        }
        check(opaque, "P94N_META_ALPHA")
        return bytes
    }

    private func inheritedDigests() throws -> [String: String] {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        let data = try Data(contentsOf: root.appendingPathComponent(
            ".planning/phases/94-negative-mouth-width-repair/94-METADATA-BASELINE.json"))
        guard sha(Array(data)) == "5a8b3d22d8378b8b0746877c62f4c3d0c97f9bd220ca501d38737bb8d3711c64",
              let value = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let records = value["records"] as? [[String: Any]] else { throw Stage.receipt }
        var digests: [String: String] = [:]
        for record in records {
            if let digest = record["sha256"] as? String {
                guard let name = record["case"] as? String, digests[name] == nil else { throw Stage.receipt }
                digests[name] = digest
            }
        }
        guard digests.count == 15, N.comparisons.allSatisfy({ digests[$0] != nil }) else { throw Stage.receipt }
        return digests
    }

    private func oracle(_ bytes: [UInt8]) throws -> B.Image {
        try B.Image(bytes, width: 640, height: 800)
    }
    private func sha(_ bytes: [UInt8]) -> String {
        SHA256.hash(data: Data(bytes)).map { String(format: "%02x", $0) }.joined()
    }
    private func at<T>(_ stage: Stage, _ action: () throws -> T) throws -> T {
        do { return try action() }
        catch let known as Stage { throw known }
        catch { throw stage }
    }
    private func emit(_ measured: N.Metrics) throws {
        let record: [String: Any] = ["case":"negative", "comparisons":N.comparisons,
                                     "metrics":measured.values, "predicates":measured.predicates]
        let data = try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys])
        guard let text = String(data: data, encoding: .utf8) else { throw Stage.receipt }
        print("P94N_AGGREGATE " + text)
    }
}
