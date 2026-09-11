import BeautyCore
import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyEngineMouthBaselineTests: XCTestCase {
    private typealias O = MouthBaselineOracle
    private let extent = CGRect(x: 0, y: 0, width: 640, height: 800)
    private let rows: [(String, BeautyParameters)] = [
        ("geometryBaseline_noop", .init()),
        ("mouthWidth_plus0p35", .init(mouthWidth: 0.35)),
        ("mouthSize_plus0p35", .init(mouthSize: 0.35)),
        ("mouthSize_minus0p35", .init(mouthSize: -0.35)),
        ("smile_0p50", .init(smile: 0.50)),
        ("lipColor_0p50", .init(lipColor: 0.50)),
        ("mouthYPosition_plus0p25", .init(mouthYPosition: 0.25)),
        ("mouthYPosition_minus0p25", .init(mouthYPosition: -0.25)),
        ("mouthTilt_plus0p25", .init(mouthTilt: 0.25)),
        ("mouthTilt_minus0p25", .init(mouthTilt: -0.25)),
        ("mouthXPosition_plus0p25", .init(mouthXPosition: 0.25)),
        ("mouthXPosition_minus0p25", .init(mouthXPosition: -0.25)),
        ("lipPeakDefinition_0p25", .init(lipPeakDefinition: 0.25)),
        ("lipPlump_0p25", .init(lipPlump: 0.25))
    ]

    func testPositiveExpansionAndProtectionBaseline() throws {
        let image = try MouthRepairFixture.image()
        let source = MouthRepairFixture.source()
        XCTAssertTrue(try extract(image, active: false) == source, "P94_BASELINE_SOURCE_CARRIER")
        let contract = try O.Contract.load(width: 640, height: 800)
        var output: [[UInt8]] = []
        // Both actual wrappers, with fresh serialized engines for every call.
        // Full byte equality connects each wrapper to the independent metric.
        for row in rows.prefix(4) {
            output.append(try render(row, image: image, source: source, repeats: 1))
        }
        let values = try O.measure(source: oracle(source), neutral: oracle(output[0]),
                                   positive: oracle(output[1]), sizePlus: oracle(output[2]),
                                   sizeMinus: oracle(output[3]), contract: contract)
        let admitted = O.admitted(values)
        var record: [String: Any] = values.mapValues { $0 as Any }
        record["case"] = "positive"
        record["ok"] = admitted
        try emit(record)
        XCTAssertTrue(admitted, "P94_POSITIVE_EXPANSION_AND_PROTECTION")
    }

    func testRetainedMouthRowsHaveDeterministicDigests() throws {
        let image = try MouthRepairFixture.image()
        let source = MouthRepairFixture.source()
        XCTAssertTrue(rows.count == 14 && Set(rows.map { $0.0 }).count == 14, "P94_BASELINE_EXACT_ROWS")
        XCTAssertTrue(try extract(image, active: false) == source, "P94_BASELINE_SOURCE_CARRIER")
        var output: [String: [UInt8]] = [:]
        var digests: [String: String] = [:]
        for row in rows {
            // Four outputs per row: processResult and process, each twice.
            let bytes = try render(row, image: image, source: source, repeats: 2)
            output[row.0] = bytes
            digests[row.0] = sha(bytes)
        }
        guard let neutral = output["geometryBaseline_noop"], let positive = output["mouthWidth_plus0p35"],
              let sizePlus = output["mouthSize_plus0p35"], let sizeMinus = output["mouthSize_minus0p35"] else {
            throw Admission.missingRow
        }
        XCTAssertTrue(neutral == source, "P94_BASELINE_NEUTRAL_IDENTITY")
        XCTAssertTrue(digests["mouthSize_plus0p35"] != digests["mouthSize_minus0p35"], "P94_BASELINE_DISTINCT_SIZE_DIGESTS")
        let contract = try O.Contract.load(width: 640, height: 800)
        let positiveSpan = try O.span(oracle(positive), targets: contract.targets)
        let sourceMargin = try O.subtract(positiveSpan, O.span(oracle(source), targets: contract.targets))
        let neutralMargin = try O.subtract(positiveSpan, O.span(oracle(neutral), targets: contract.targets))
        let plusMargin = try O.absolute(O.subtract(positiveSpan, O.span(oracle(sizePlus), targets: contract.targets)))
        let minusMargin = try O.absolute(O.subtract(positiveSpan, O.span(oracle(sizeMinus), targets: contract.targets)))
        XCTAssertTrue(sourceMargin >= 16 && neutralMargin >= 16 && plusMargin >= 16 && minusMargin >= 16,
                      "P94_BASELINE_RETAINED_SPAN_DISTINCTIONS")
        for row in rows {
            guard let value = digests[row.0] else { throw Admission.missingRow }
            try emit(["case": row.0, "sha256": value])
        }
        try emit(["case": "source", "sha256": sha(source)])
    }

    private func render(_ row: (String, BeautyParameters), image: CIImage, source: [UInt8],
                        repeats: Int) throws -> [UInt8] {
        guard repeats == 1 || repeats == 2 else { throw Admission.missingRow }
        let active = row.0 != "geometryBaseline_noop"
        var first: [UInt8]?
        var firstResult: BeautyResult<CIImage>?
        for _ in 0..<repeats {
            let provider = SDKTestingFaceDetectionProvider([.phase94MouthPortrait])
            let engine = try BeautyEngine(faceDetectionProvider: provider)
            let result = try engine.processResult(image: image, metadata: MouthRepairFixture.metadata(), parameters: row.1)
            let current = try extract(result.output, active: active, colorOnly: row.0 == "lipColor_0p50")
            XCTAssertTrue(provider.invocationCount == (active ? 1 : 0), "P94_BASELINE_RESULT_DETECTOR_COUNT")
            checkMetadata(result, active: active)
            if let old = firstResult {
                XCTAssertTrue(sameColorMetadata(old.output, result.output), "P94_BASELINE_REPEATED_COLOR_METADATA")
                XCTAssertTrue(old.metrics == result.metrics && old.warnings == result.warnings,
                              "P94_BASELINE_REPEATED_METADATA")
                XCTAssertTrue(old.detectionSummary?.availability == result.detectionSummary?.availability
                              && old.detectionSummary?.reasons == result.detectionSummary?.reasons,
                              "P94_BASELINE_REPEATED_DETECTION")
            } else {
                firstResult = result
            }
            let legacyProvider = SDKTestingFaceDetectionProvider([.phase94MouthPortrait])
            let legacyEngine = try BeautyEngine(faceDetectionProvider: legacyProvider)
            let legacy = try legacyEngine.process(image: image, orientation: .up, parameters: row.1)
            let legacyBytes = try extract(legacy, active: active, colorOnly: row.0 == "lipColor_0p50")
            XCTAssertTrue(sameColorMetadata(result.output, legacy), "P94_BASELINE_WRAPPER_COLOR_METADATA")
            XCTAssertTrue(legacyProvider.invocationCount == (active ? 1 : 0), "P94_BASELINE_LEGACY_DETECTOR_COUNT")
            XCTAssertTrue(current == legacyBytes && sha(current) == sha(legacyBytes), "P94_BASELINE_WRAPPER_EQUALITY")
            if let previous = first {
                XCTAssertTrue(previous == current && sha(previous) == sha(current), "P94_BASELINE_REPEAT_EQUALITY")
            } else {
                first = current
            }
            if !active {
                XCTAssertTrue(current == source && legacyBytes == source, "P94_BASELINE_NEUTRAL_IDENTITY")
            }
        }
        guard let first else { throw Admission.missingRow }
        return first
    }

    private func checkMetadata(_ result: BeautyResult<CIImage>, active: Bool) {
        XCTAssertTrue(result.detectionSummary?.reasons == [], "P94_BASELINE_TYPED_REASONS")
        XCTAssertTrue(result.detectionSummary?.availability == (active ? .usable : .notRun), "P94_BASELINE_AVAILABILITY")
        XCTAssertTrue(result.metrics.values.allSatisfy { $0.isFinite }, "P94_BASELINE_FINITE_METADATA")
        let text = (result.warnings.map { $0.code + " " + $0.message } + Array(result.metrics.keys))
            .joined(separator: " ").lowercased()
        let forbidden = ["landmark", "coordinate", "controlpoint", "control point", "simd", "mask", "raw",
                         "pixel", "image bytes", "transcript", "path", "/private/", "file://"]
        XCTAssertTrue(forbidden.allSatisfy { !text.contains($0) }, "P94_BASELINE_REDACTED_METADATA")
        if active {
            XCTAssertTrue(result.detectionSummary?.faceCount == 1 && result.detectionSummary?.usedFaceCount == 1,
                          "P94_BASELINE_FACE_COUNTS")
        }
    }

    private func sameColorMetadata(_ first: CIImage, _ second: CIImage) -> Bool {
        switch (first.colorSpace, second.colorSpace) {
        case (nil, nil): return true
        case let (lhs?, rhs?): return CFEqual(lhs, rhs)
        default: return false
        }
    }

    private func extract(_ image: CIImage, active: Bool, colorOnly: Bool = false) throws -> [UInt8] {
        XCTAssertTrue(image.extent == extent, "P94_BASELINE_EXTENT")
        guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB) else { throw Admission.color }
        if colorOnly {
            // Color-filter output has no promised concrete source tag. Its
            // optional metadata must still agree across wrappers and repeats;
            // actual pixels below are always materialized in named sRGB.
            if let actual = image.colorSpace {
                XCTAssertTrue(actual.model == .rgb && actual.numberOfComponents == 3,
                              "P94_BASELINE_COLOR_ONLY_RGB_METADATA")
            }
        } else {
            guard let actual = image.colorSpace else { throw Admission.color }
            let expected = active ? CGColorSpaceCreateDeviceRGB() : sRGB
            XCTAssertTrue(actual.model == expected.model && actual.name == expected.name,
                          "P94_BASELINE_COLOR_METADATA")
            XCTAssertTrue(actual.numberOfComponents == expected.numberOfComponents && CFEqual(actual, expected),
                          "P94_BASELINE_EXACT_COLOR_SPACE")
        }
        var output = [UInt8](repeating: 0, count: 640 * 800 * 4)
        let context = CIContext(options: [.workingColorSpace: sRGB, .outputColorSpace: sRGB])
        output.withUnsafeMutableBytes { buffer in
            context.render(image, toBitmap: buffer.baseAddress!, rowBytes: 640 * 4,
                           bounds: extent, format: .RGBA8, colorSpace: sRGB)
        }
        var opaque = true
        for offset in stride(from: 3, to: output.count, by: 4) {
            if output[offset] != 255 { opaque = false; break }
        }
        XCTAssertTrue(opaque, "P94_BASELINE_OPAQUE_ALPHA")
        return output
    }

    private func oracle(_ bytes: [UInt8]) throws -> O.Image {
        try O.Image(bytes, width: 640, height: 800)
    }

    private func sha(_ bytes: [UInt8]) -> String {
        SHA256.hash(data: Data(bytes)).map { String(format: "%02x", $0) }.joined()
    }

    private func emit(_ record: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys])
        guard let text = String(data: data, encoding: .utf8) else { throw Admission.record }
        print("P94_AGGREGATE " + text)
    }
    private enum Admission: Error { case color, missingRow, record }
}
