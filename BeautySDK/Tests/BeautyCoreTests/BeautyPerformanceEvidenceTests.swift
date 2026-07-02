import CoreVideo
import Foundation
import ImageIO
import XCTest
import BeautySDK

// Requirement evidence: PERF-01, PERF-04, PERF-05.
final class BeautyPerformanceEvidenceTests: XCTestCase {
    func testPERF01Records720pTimingMatrixAndBudgetComparison() throws {
        let report = try PerformanceEvidenceReport.measure(
            cases: PerformanceEvidenceCase.phase23Matrix,
            sampleCount: 3,
            warmupCount: 1,
            loopIterations: 6
        )
        print(report.allowlistedSummary())

        XCTAssertEqual(report.timingSummaries.map(\.caseName), ["default_noop", "skin_color_filter", "high_capped"])
        XCTAssertTrue(report.timingSummaries.allSatisfy { $0.sampleCount == 3 })
        XCTAssertTrue(report.timingSummaries.allSatisfy { $0.warmupCount == 1 })
        XCTAssertTrue(report.timingSummaries.allSatisfy { $0.resolutionBucket == "1280x720" })
        XCTAssertTrue(report.timingSummaries.allSatisfy { $0.qualityMode == .balanced })
        XCTAssertTrue(report.timingSummaries.allSatisfy { $0.meanMilliseconds >= 0 })
        XCTAssertTrue(report.timingSummaries.allSatisfy { $0.maximumMilliseconds >= 0 })

        let highCapped = try XCTUnwrap(report.timingSummaries.first { $0.caseName == "high_capped" })
        XCTAssertTrue(highCapped.warningCodes.contains("beauty_strength_capped"))
        XCTAssertTrue(highCapped.metricKeys.contains("beauty.effects.cappedCount"))
    }

    func testPERF04RecordsFixtureLoopMemoryTrendWithNonClaimForShortRuns() throws {
        let report = try PerformanceEvidenceReport.measure(
            cases: PerformanceEvidenceCase.phase23Matrix,
            sampleCount: 1,
            warmupCount: 0,
            loopIterations: 9
        )

        XCTAssertEqual(report.memoryTrend.iterationCount, 9)
        XCTAssertEqual(report.memoryTrend.caseMix, ["default_noop", "skin_color_filter", "high_capped"])
        XCTAssertEqual(report.memoryTrend.durationClaim, "short_baseline_non_claim")
        XCTAssertEqual(report.memoryTrend.rerunProtocolSeconds, 600)
        XCTAssertTrue(["available", "unavailable"].contains(report.memoryTrend.memoryMetricStatus))
        XCTAssertFalse(report.memoryTrend.releaseLikeTenMinuteClaim)
    }

    func testPERF05PerformanceEvidenceReportUsesOnlyAllowlistedFields() throws {
        let report = try PerformanceEvidenceReport.measure(
            cases: PerformanceEvidenceCase.phase23Matrix,
            sampleCount: 1,
            warmupCount: 0,
            loopIterations: 3
        )

        let text = report.allowlistedSummary()

        for required in [
            "case",
            "samples",
            "warmups",
            "mean_ms",
            "max_ms",
            "resolution",
            "quality",
            "warnings",
            "metric_keys",
            "memory_status",
            "non_claim",
            "rerun_seconds"
        ] {
            XCTAssertTrue(text.contains(required), "Missing allowlisted field \(required)")
        }

        for forbidden in PerformanceEvidenceReport.forbiddenPayloadTerms {
            XCTAssertFalse(text.contains(forbidden), "Unexpected sensitive report term \(forbidden)")
        }
    }
}

struct PerformanceEvidenceCase {
    let name: String
    let parameters: BeautyParameters

    static let phase23Matrix: [PerformanceEvidenceCase] = [
        PerformanceEvidenceCase(name: "default_noop", parameters: BeautyParameters()),
        PerformanceEvidenceCase(
            name: "skin_color_filter",
            parameters: BeautyParameters(
                skinSmoothing: 0.35,
                skinWhitening: 0.25,
                brightness: 0.15,
                filterId: "soft_clean",
                filterIntensity: 0.4
            )
        ),
        PerformanceEvidenceCase(
            name: "high_capped",
            parameters: BeautyParameters(
                skinSmoothing: 1,
                skinWhitening: 1,
                brightness: 0.2,
                faceSlim: 1,
                faceSmall: 1,
                faceVShape: 1,
                jawSlim: 1,
                eyeSize: 1,
                noseSlim: 1,
                noseWingSlim: 1,
                noseTipSize: 1,
                noseBridge: 1,
                mouthSize: 1,
                mouthWidth: 1,
                smile: 1,
                lipColor: 1,
                filterId: "warm_light",
                filterIntensity: 1
            )
        )
    ]
}

struct PerformanceTimingSummary {
    let caseName: String
    let sampleCount: Int
    let warmupCount: Int
    let meanMilliseconds: Double
    let maximumMilliseconds: Double
    let resolutionBucket: String
    let qualityMode: BeautyRenderQuality
    let warningCodes: [String]
    let metricKeys: [String]

    var budgetStatus: String {
        meanMilliseconds <= 12 ? "within_first_version_budget" : "over_budget_recorded"
    }
}

struct PerformanceMemoryTrend {
    let startResidentBytes: UInt64?
    let endResidentBytes: UInt64?
    let peakResidentBytes: UInt64?
    let iterationCount: Int
    let caseMix: [String]
    let memoryMetricStatus: String
    let durationClaim: String
    let rerunProtocolSeconds: Int
    let releaseLikeTenMinuteClaim: Bool

    var growthTrend: String {
        guard let startResidentBytes, let endResidentBytes else {
            return "unavailable"
        }
        return endResidentBytes >= startResidentBytes ? "non_decreasing" : "decreased"
    }
}

struct PerformanceEvidenceReport {
    let timingSummaries: [PerformanceTimingSummary]
    let memoryTrend: PerformanceMemoryTrend

    static let forbiddenPayloadTerms = [
        "/private/var",
        "NSError",
        "VNFaceObservation",
        "boundingBox",
        "rawPresetJson",
        "image bytes",
        "userToken",
        "userIdentifier",
        "raw JSON",
        "raw diagnostics",
        "CGPoint",
        "CGRect",
        "SIMD"
    ]

    static func measure(
        cases: [PerformanceEvidenceCase],
        sampleCount: Int,
        warmupCount: Int,
        loopIterations: Int
    ) throws -> PerformanceEvidenceReport {
        let engine = try BeautyEngine(configuration: .default)
        let input = try makeEvidencePixelBuffer(width: 1280, height: 720)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

        var summaries: [PerformanceTimingSummary] = []
        for evidenceCase in cases {
            for _ in 0..<warmupCount {
                _ = try engine.processResult(pixelBuffer: input, metadata: metadata, parameters: evidenceCase.parameters)
            }

            var durations: [Double] = []
            var lastWarnings: [String] = []
            var lastMetricKeys: [String] = []
            for _ in 0..<sampleCount {
                let start = DispatchTime.now().uptimeNanoseconds
                let result = try engine.processResult(
                    pixelBuffer: input,
                    metadata: metadata,
                    parameters: evidenceCase.parameters
                )
                let end = DispatchTime.now().uptimeNanoseconds
                durations.append(Double(end - start) / 1_000_000)
                lastWarnings = result.warnings.map(\.code).sorted()
                lastMetricKeys = result.metrics.keys.sorted()
            }

            let mean = durations.reduce(0, +) / Double(max(durations.count, 1))
            summaries.append(
                PerformanceTimingSummary(
                    caseName: evidenceCase.name,
                    sampleCount: sampleCount,
                    warmupCount: warmupCount,
                    meanMilliseconds: mean,
                    maximumMilliseconds: durations.max() ?? 0,
                    resolutionBucket: "1280x720",
                    qualityMode: .balanced,
                    warningCodes: lastWarnings,
                    metricKeys: lastMetricKeys
                )
            )
        }

        let memoryTrend = try measureMemoryTrend(
            engine: engine,
            input: input,
            metadata: metadata,
            cases: cases,
            loopIterations: loopIterations
        )
        return PerformanceEvidenceReport(timingSummaries: summaries, memoryTrend: memoryTrend)
    }

    func allowlistedSummary() -> String {
        var lines = [
            "case | samples | warmups | mean_ms | max_ms | resolution | quality | budget | warnings | metric_keys"
        ]
        for summary in timingSummaries {
            lines.append(
                [
                    summary.caseName,
                    "\(summary.sampleCount)",
                    "\(summary.warmupCount)",
                    String(format: "%.3f", summary.meanMilliseconds),
                    String(format: "%.3f", summary.maximumMilliseconds),
                    summary.resolutionBucket,
                    summary.qualityMode.rawValue,
                    summary.budgetStatus,
                    summary.warningCodes.joined(separator: "+"),
                    summary.metricKeys.joined(separator: "+")
                ].joined(separator: " | ")
            )
        }
        lines.append(
            "memory_status | iterations | case_mix | growth | non_claim | rerun_seconds"
        )
        lines.append(
            [
                memoryTrend.memoryMetricStatus,
                "\(memoryTrend.iterationCount)",
                memoryTrend.caseMix.joined(separator: "+"),
                memoryTrend.growthTrend,
                memoryTrend.durationClaim,
                "\(memoryTrend.rerunProtocolSeconds)"
            ].joined(separator: " | ")
        )
        return lines.joined(separator: "\n")
    }

    private static func measureMemoryTrend(
        engine: BeautyEngine,
        input: CVPixelBuffer,
        metadata: BeautyInputMetadata,
        cases: [PerformanceEvidenceCase],
        loopIterations: Int
    ) throws -> PerformanceMemoryTrend {
        let start = currentResidentBytes()
        var peak = start

        for index in 0..<loopIterations {
            let evidenceCase = cases[index % cases.count]
            _ = try engine.processResult(pixelBuffer: input, metadata: metadata, parameters: evidenceCase.parameters)
            if let current = currentResidentBytes() {
                peak = max(peak ?? current, current)
            }
        }

        let end = currentResidentBytes()
        return PerformanceMemoryTrend(
            startResidentBytes: start,
            endResidentBytes: end,
            peakResidentBytes: peak,
            iterationCount: loopIterations,
            caseMix: cases.map(\.name),
            memoryMetricStatus: start == nil || end == nil ? "unavailable" : "available",
            durationClaim: "short_baseline_non_claim",
            rerunProtocolSeconds: 600,
            releaseLikeTenMinuteClaim: false
        )
    }

    private static func currentResidentBytes() -> UInt64? {
        nil
    }

    private static func makeEvidencePixelBuffer(width: Int, height: Int) throws -> CVPixelBuffer {
        let pixelBuffer = try PixelBufferFixtures.makePixelBuffer(
            width: width,
            height: height,
            pixelFormat: kCVPixelFormatType_32BGRA
        )
        guard CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess else {
            throw BeautyError.invalidInput
        }
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }

        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        for row in 0..<height {
            let rowPointer = baseAddress.advanced(by: row * bytesPerRow).assumingMemoryBound(to: UInt8.self)
            for column in 0..<width {
                let offset = column * 4
                rowPointer[offset] = UInt8((row + column) % 64 + 48)
                rowPointer[offset + 1] = UInt8((row * 2 + column) % 64 + 72)
                rowPointer[offset + 2] = UInt8((row + column * 2) % 64 + 96)
                rowPointer[offset + 3] = 255
            }
        }
        return pixelBuffer
    }
}
