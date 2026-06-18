import XCTest
import BeautyCore

final class DetectionAvailabilityTests: XCTestCase {
    func testPIPE07AvailabilitySummariesCoverExpectedStates() {
        let summaries: [(BeautyDetectionSummary, DetectionAvailability)] = [
            (.disabled, .disabled),
            (.notRun, .notRun),
            (.noFace, .noFace),
            (
                BeautyDetectionSummary(
                    availability: .partial,
                    reasons: [.missingLandmarks],
                    faceCount: 1,
                    usedFaceCount: 0
                ),
                .partial
            ),
            (
                BeautyDetectionSummary(
                    availability: .lowConfidence,
                    reasons: [.lowConfidenceFace],
                    faceCount: 1,
                    usedFaceCount: 0
                ),
                .lowConfidence
            ),
            (
                BeautyDetectionSummary(
                    availability: .stale,
                    reasons: [.staleDetection],
                    faceCount: 1,
                    usedFaceCount: 1
                ),
                .stale
            ),
            (
                BeautyDetectionSummary(
                    availability: .skipped,
                    reasons: [.detectionTimedOut],
                    faceCount: 0,
                    usedFaceCount: 0
                ),
                .skipped
            ),
            (
                BeautyDetectionSummary(
                    availability: .reused,
                    reasons: [],
                    faceCount: 1,
                    usedFaceCount: 1
                ),
                .reused
            )
        ]

        XCTAssertEqual(summaries.map(\.1), [
            .disabled,
            .notRun,
            .noFace,
            .partial,
            .lowConfidence,
            .stale,
            .skipped,
            .reused
        ])

        for (summary, availability) in summaries {
            XCTAssertEqual(summary.availability, availability)
        }
    }

    func testPIPE07DetectionSummaryClampsUnsafeFaceCounts() {
        let summary = BeautyDetectionSummary(
            availability: .usable,
            reasons: [],
            faceCount: -1,
            usedFaceCount: 4
        )

        XCTAssertEqual(summary.faceCount, 0)
        XCTAssertEqual(summary.usedFaceCount, 0)
    }
}
