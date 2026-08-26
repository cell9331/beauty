import CoreGraphics
import CoreImage
import Darwin
import Foundation

struct BatchManifest: Decodable {
    let schemaVersion: String
    let control: Control
    let batches: [Batch]

    struct Control: Decodable {
        let id: String
        let label: String
    }

    struct Batch: Decodable {
        let id: String
        let label: String
        let cases: [String]
    }
}

struct CaseSummary: Encodable {
    let batchID: String
    let caseID: String
    let fixtureCount: Int
    let outputCount: Int
    let missingOutputCount: Int
    let inputChangedPixels: Int
    let inputComparedPixels: Int
    let inputMeanAbsoluteRGBDelta: Double
    let inputMaxRGBDelta: Int
    let neutralChangedPixels: Int
    let neutralComparedPixels: Int
    let neutralMeanAbsoluteRGBDelta: Double
    let neutralMaxRGBDelta: Int
    let effectDetected: Bool
    let verdict: String
}

struct BatchSummary: Encodable {
    let id: String
    let label: String
    let caseCount: Int
    let casesWithOutput: Int
    let casesWithDetectedEffect: Int
    let casesWithNoDetectedEffect: Int
    let missingOutputCount: Int
}

struct ComparisonReport: Encodable {
    let schemaVersion: String
    let generatedAtUTC: String
    let controlCaseID: String
    let fixtureCount: Int
    let fixtureIDs: [String]
    let watermarkExcludedRowsPerEdge: Int
    let pixelTolerance: Int
    let effectDetectionMinimumChangedPixels: Int
    let effectDetectionMinimumMeanRGBDelta: Double
    let controlOutputCount: Int
    let controlMissingOutputCount: Int
    let controlInputChangedPixels: Int
    let controlInputComparedPixels: Int
    let controlInputMeanAbsoluteRGBDelta: Double
    let controlInputMaxRGBDelta: Int
    let batches: [BatchSummary]
    let cases: [CaseSummary]
    let overallVerdict: String
}

struct CanonicalImage {
    let width: Int
    let height: Int
    let rgba: [UInt8]
}

struct ComparisonMetrics {
    let comparedPixels: Int
    let changedPixels: Int
    let meanAbsoluteRGBDelta: Double
    let maxRGBDelta: Int
}

enum CompareError: Error, CustomStringConvertible {
    case invalidArguments(String)
    case invalidManifest(String)
    case imageDecodeFailed(String)
    case dimensionMismatch(String)
    case outputMissing(String)

    var description: String {
        switch self {
        case .invalidArguments(let message), .invalidManifest(let message),
             .imageDecodeFailed(let message), .dimensionMismatch(let message),
             .outputMissing(let message):
            return message
        }
    }
}

func argument(_ name: String, in arguments: [String]) throws -> String {
    guard let index = arguments.firstIndex(of: name), index + 1 < arguments.count else {
        throw CompareError.invalidArguments("missing \(name) value")
    }
    let value = arguments[index + 1]
    guard !value.isEmpty, !value.hasPrefix("--") else {
        throw CompareError.invalidArguments("missing \(name) value")
    }
    return value
}

func canonicalImage(at url: URL, context: CIContext) throws -> CanonicalImage {
    guard let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) else {
        throw CompareError.imageDecodeFailed(url.path)
    }
    let extent = image.extent.integral
    let width = Int(extent.width.rounded(.toNearestOrAwayFromZero))
    let height = Int(extent.height.rounded(.toNearestOrAwayFromZero))
    guard width > 0, height > 0,
          let cgImage = context.createCGImage(image, from: extent) else {
        throw CompareError.imageDecodeFailed(url.path)
    }

    var rgba = Array(repeating: UInt8(0), count: width * height * 4)
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    let drawn = rgba.withUnsafeMutableBytes { bytes in
        guard let baseAddress = bytes.baseAddress,
              let bitmap = CGContext(
                  data: baseAddress,
                  width: width,
                  height: height,
                  bitsPerComponent: 8,
                  bytesPerRow: width * 4,
                  space: colorSpace,
                  bitmapInfo: bitmapInfo
              ) else {
            return false
        }
        bitmap.interpolationQuality = .none
        bitmap.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return true
    }
    guard drawn else {
        throw CompareError.imageDecodeFailed(url.path)
    }
    return CanonicalImage(width: width, height: height, rgba: rgba)
}

func metrics(
    _ lhs: CanonicalImage,
    _ rhs: CanonicalImage,
    excludedRowsPerEdge: Int,
    tolerance: Int
) throws -> ComparisonMetrics {
    guard lhs.width == rhs.width, lhs.height == rhs.height else {
        throw CompareError.dimensionMismatch("\(lhs.width)x\(lhs.height) vs \(rhs.width)x\(rhs.height)")
    }
    let startRow = min(excludedRowsPerEdge, lhs.height)
    let endRow = max(startRow, lhs.height - excludedRowsPerEdge)
    var comparedPixels = 0
    var changedPixels = 0
    var totalDelta = 0
    var maxDelta = 0

    for y in startRow..<endRow {
        for x in 0..<lhs.width {
            let index = (y * lhs.width + x) * 4
            let redDelta = abs(Int(lhs.rgba[index]) - Int(rhs.rgba[index]))
            let greenDelta = abs(Int(lhs.rgba[index + 1]) - Int(rhs.rgba[index + 1]))
            let blueDelta = abs(Int(lhs.rgba[index + 2]) - Int(rhs.rgba[index + 2]))
            let pixelDelta = max(redDelta, greenDelta, blueDelta)
            comparedPixels += 1
            totalDelta += redDelta + greenDelta + blueDelta
            maxDelta = max(maxDelta, pixelDelta)
            if pixelDelta > tolerance {
                changedPixels += 1
            }
        }
    }

    let mean = comparedPixels == 0 ? 0 : Double(totalDelta) / Double(comparedPixels * 3)
    return ComparisonMetrics(
        comparedPixels: comparedPixels,
        changedPixels: changedPixels,
        meanAbsoluteRGBDelta: mean,
        maxRGBDelta: maxDelta
    )
}

func fixtureURLs(in inputURL: URL) -> [URL] {
    guard let enumerator = FileManager.default.enumerator(
        at: inputURL,
        includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey],
        options: [.skipsHiddenFiles]
    ) else {
        return []
    }
    return enumerator.compactMap { item in
        guard let url = item as? URL,
              url.deletingLastPathComponent().lastPathComponent == "portraits",
              ["jpg", "jpeg", "png"].contains(url.pathExtension.lowercased()) else {
            return nil
        }
        let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
        guard values?.isRegularFile == true, values?.isSymbolicLink != true else { return nil }
        return url
    }.sorted { $0.lastPathComponent < $1.lastPathComponent }
}

func outputURL(runRoot: URL, batchID: String, stem: String, caseID: String) -> URL {
    runRoot
        .appendingPathComponent(batchID, isDirectory: true)
        .appendingPathComponent(caseID, isDirectory: true)
        .appendingPathComponent("\(stem)__\(caseID).png")
}

func aggregate(_ values: [ComparisonMetrics]) -> ComparisonMetrics {
    guard !values.isEmpty else {
        return ComparisonMetrics(comparedPixels: 0, changedPixels: 0, meanAbsoluteRGBDelta: 0, maxRGBDelta: 0)
    }
    let compared = values.reduce(0) { $0 + $1.comparedPixels }
    let changed = values.reduce(0) { $0 + $1.changedPixels }
    let weightedMean = values.reduce(0.0) {
        $0 + $1.meanAbsoluteRGBDelta * Double($1.comparedPixels)
    }
    return ComparisonMetrics(
        comparedPixels: compared,
        changedPixels: changed,
        meanAbsoluteRGBDelta: compared == 0 ? 0 : weightedMean / Double(compared),
        maxRGBDelta: values.map { $0.maxRGBDelta }.max() ?? 0
    )
}

func runSemanticSelfTests() throws -> Int {
    throw CompareError.invalidManifest("semantic contract validation not implemented")
}

let commandArguments = Array(CommandLine.arguments.dropFirst())
if commandArguments == ["--self-test"] {
    do {
        let mutationCount = try runSemanticSelfTests()
        print("semantic_contract_self_test=PASS mutations=\(mutationCount)")
        exit(0)
    } catch {
        fputs("semantic contract self-test failed: \(error)\n", stderr)
        exit(1)
    }
}

do {
    let arguments = commandArguments
    let inputURL = URL(fileURLWithPath: try argument("--input", in: arguments), isDirectory: true)
    let runRoot = URL(fileURLWithPath: try argument("--run-root", in: arguments), isDirectory: true)
    let manifestURL = URL(fileURLWithPath: try argument("--manifest", in: arguments))
    let reportURL = URL(fileURLWithPath: try argument("--report", in: arguments))

    let manifestData = try Data(contentsOf: manifestURL)
    let manifest = try JSONDecoder().decode(BatchManifest.self, from: manifestData)
    guard manifest.schemaVersion == "beauty.face-feature-batch-manifest.v1",
          manifest.control.id == "geometryBaseline_noop" else {
        throw CompareError.invalidManifest("unsupported face-feature batch manifest")
    }
    let allCaseIDs = manifest.batches.flatMap { $0.cases }
    guard Set(allCaseIDs).count == allCaseIDs.count,
          !allCaseIDs.contains(manifest.control.id),
          !manifest.batches.isEmpty else {
        throw CompareError.invalidManifest("duplicate, empty, or control case in manifest")
    }

    let fixtures = fixtureURLs(in: inputURL)
    guard !fixtures.isEmpty else {
        throw CompareError.invalidManifest("no portrait fixtures found")
    }
    let context = CIContext(options: [
        .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
        .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
    ])
    let inputImages = try fixtures.map { try canonicalImage(at: $0, context: context) }
    let width = inputImages.map { $0.width }.min() ?? 0
    let watermarkFontSize = max(34.0, min(72.0, Double(width) / 30.0))
    let watermarkPadding = max(24.0, Double(width) / 70.0)
    let watermarkRows = Int(ceil(watermarkPadding + watermarkFontSize * 1.75 + 6.0))
    let tolerance = 2
    let minimumChangedPixels = 32
    let minimumMeanDelta = 0.05

    let controlImages = try fixtures.map { fixture -> CanonicalImage in
        let url = outputURL(
            runRoot: runRoot,
            batchID: "control",
            stem: fixture.deletingPathExtension().lastPathComponent,
            caseID: manifest.control.id
        )
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CompareError.outputMissing(url.lastPathComponent)
        }
        return try canonicalImage(at: url, context: context)
    }
    let inputToControl = try Array(zip(inputImages, controlImages)).map {
        try metrics($0.0, $0.1, excludedRowsPerEdge: watermarkRows, tolerance: tolerance)
    }
    let controlInputMetrics = aggregate(inputToControl)

    var caseSummaries: [CaseSummary] = []
    var batchSummaries: [BatchSummary] = []
    var anyMissing = false

    for batch in manifest.batches {
        var casesWithOutput = 0
        var casesWithEffect = 0
        var missingOutputCount = 0
        for caseID in batch.cases {
            var inputMetrics: [ComparisonMetrics] = []
            var neutralMetrics: [ComparisonMetrics] = []
            var outputCount = 0
            var missingCount = 0

            for (index, fixture) in fixtures.enumerated() {
                let output = outputURL(
                    runRoot: runRoot,
                    batchID: batch.id,
                    stem: fixture.deletingPathExtension().lastPathComponent,
                    caseID: caseID
                )
                guard FileManager.default.fileExists(atPath: output.path) else {
                    missingCount += 1
                    continue
                }
                let rendered = try canonicalImage(at: output, context: context)
                inputMetrics.append(try metrics(
                    inputImages[index], rendered,
                    excludedRowsPerEdge: watermarkRows,
                    tolerance: tolerance
                ))
                neutralMetrics.append(try metrics(
                    controlImages[index], rendered,
                    excludedRowsPerEdge: watermarkRows,
                    tolerance: tolerance
                ))
                outputCount += 1
            }

            let inputMetric = aggregate(inputMetrics)
            let neutralMetric = aggregate(neutralMetrics)
            let effectDetected = neutralMetric.changedPixels >= minimumChangedPixels &&
                neutralMetric.meanAbsoluteRGBDelta >= minimumMeanDelta
            let verdict: String
            if missingCount > 0 {
                verdict = "missing_output"
                anyMissing = true
            } else if effectDetected {
                verdict = "changed_vs_neutral"
                casesWithEffect += 1
            } else {
                verdict = "no_detectable_change"
            }
            if outputCount == fixtures.count { casesWithOutput += 1 }
            missingOutputCount += missingCount

            caseSummaries.append(CaseSummary(
                batchID: batch.id,
                caseID: caseID,
                fixtureCount: fixtures.count,
                outputCount: outputCount,
                missingOutputCount: missingCount,
                inputChangedPixels: inputMetric.changedPixels,
                inputComparedPixels: inputMetric.comparedPixels,
                inputMeanAbsoluteRGBDelta: inputMetric.meanAbsoluteRGBDelta,
                inputMaxRGBDelta: inputMetric.maxRGBDelta,
                neutralChangedPixels: neutralMetric.changedPixels,
                neutralComparedPixels: neutralMetric.comparedPixels,
                neutralMeanAbsoluteRGBDelta: neutralMetric.meanAbsoluteRGBDelta,
                neutralMaxRGBDelta: neutralMetric.maxRGBDelta,
                effectDetected: effectDetected,
                verdict: verdict
            ))
        }
        batchSummaries.append(BatchSummary(
            id: batch.id,
            label: batch.label,
            caseCount: batch.cases.count,
            casesWithOutput: casesWithOutput,
            casesWithDetectedEffect: casesWithEffect,
            casesWithNoDetectedEffect: casesWithOutput - casesWithEffect,
            missingOutputCount: missingOutputCount
        ))
    }

    let report = ComparisonReport(
        schemaVersion: "beauty.face-feature-batch-report.v1",
        generatedAtUTC: ISO8601DateFormatter().string(from: Date()),
        controlCaseID: manifest.control.id,
        fixtureCount: fixtures.count,
        fixtureIDs: fixtures.indices.map { String(format: "portrait_%03d", $0 + 1) },
        watermarkExcludedRowsPerEdge: watermarkRows,
        pixelTolerance: tolerance,
        effectDetectionMinimumChangedPixels: minimumChangedPixels,
        effectDetectionMinimumMeanRGBDelta: minimumMeanDelta,
        controlOutputCount: controlImages.count,
        controlMissingOutputCount: 0,
        controlInputChangedPixels: controlInputMetrics.changedPixels,
        controlInputComparedPixels: controlInputMetrics.comparedPixels,
        controlInputMeanAbsoluteRGBDelta: controlInputMetrics.meanAbsoluteRGBDelta,
        controlInputMaxRGBDelta: controlInputMetrics.maxRGBDelta,
        batches: batchSummaries,
        cases: caseSummaries,
        overallVerdict: anyMissing ? "incomplete" : "completed_mechanical_comparison"
    )
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    try FileManager.default.createDirectory(at: reportURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try encoder.encode(report).write(to: reportURL, options: .atomic)

    print("wrote \(reportURL.path)")
    print("fixtures=\(fixtures.count) cases=\(allCaseIDs.count) missing=\(caseSummaries.reduce(0) { $0 + $1.missingOutputCount })")
    for batch in batchSummaries {
        print("\(batch.id): outputs=\(batch.casesWithOutput)/\(batch.caseCount) effects=\(batch.casesWithDetectedEffect)")
    }
    if anyMissing { exit(2) }
} catch {
    fputs("face-feature comparison failed: \(error)\n", stderr)
    exit(1)
}
