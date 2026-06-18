import XCTest
import BeautySDK

final class BeautyResultDetectionSummaryTests: XCTestCase {
    func testPIPE07NoFaceSummaryUsesStructuredReasonCodes() throws {
        let summary = BeautyDetectionSummary.noFace

        XCTAssertEqual(summary.availability, .noFace)
        XCTAssertEqual(summary.reasons, [.noFaceDetected])
        XCTAssertEqual(summary.faceCount, 0)
        XCTAssertEqual(summary.usedFaceCount, 0)

        let data = try JSONEncoder().encode(summary)
        let encoded = String(decoding: data, as: UTF8.self)
        for forbidden in ["boundingBox", "landmark", "Vision", "VNFaceObservation", "path", "raw"] {
            XCTAssertFalse(encoded.contains(forbidden), "Summary leaked forbidden token: \(forbidden)")
        }
    }

    func testPIPE07SummaryAllowsPrivacySafeCountsAndTimings() {
        let summary = BeautyDetectionSummary(
            availability: .usable,
            reasons: [],
            faceCount: 2,
            usedFaceCount: 1,
            detectionDurationMs: 4.5,
            mappingDurationMs: 1.25
        )

        XCTAssertEqual(summary.faceCount, 2)
        XCTAssertEqual(summary.usedFaceCount, 1)
        XCTAssertEqual(summary.detectionDurationMs, 4.5)
        XCTAssertEqual(summary.mappingDurationMs, 1.25)
    }

    func testBeautyResultOutputInitializerRemainsSourceCompatible() {
        let result = BeautyResult(output: "ok")

        XCTAssertEqual(result.output, "ok")
        XCTAssertEqual(result.warnings, [])
        XCTAssertEqual(result.metrics, [:])
        XCTAssertNil(result.detectionSummary)
    }

    func testBeautyResultCarriesDetectionSummaryWhenProvided() {
        let result = BeautyResult(output: "ok", detectionSummary: .disabled)

        XCTAssertEqual(result.detectionSummary, .disabled)
    }
}
