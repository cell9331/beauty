import XCTest
import BeautyCore
@testable import BeautyDetection

final class FaceSelectionPolicyTests: XCTestCase {
    func testPIPE07SelectsLargestFaceWhenMaximumFaceCountIsOne() {
        var policy = FaceSelectionPolicy()
        let observations = [
            face("small", area: 0.10),
            face("largest", area: 0.40),
            face("middle", area: 0.20)
        ]

        let result = policy.select(
            from: observations,
            configuration: BeautyConfiguration(maximumFaceCount: 1)
        )

        XCTAssertEqual(result.selectedFaces.map(\.stableID), ["largest"])
        XCTAssertEqual(result.summary.faceCount, 3)
        XCTAssertEqual(result.summary.usedFaceCount, 1)
        XCTAssertEqual(result.summary.reasons, [.faceLimitApplied])
    }

    func testPIPE07StableIdentifierWinsWhenAreasAreWithinTieThreshold() {
        var policy = FaceSelectionPolicy()

        _ = policy.select(
            from: [face("stable", area: 0.40), face("other", area: 0.20)],
            configuration: BeautyConfiguration(maximumFaceCount: 1)
        )
        let result = policy.select(
            from: [face("new", area: 0.43), face("stable", area: 0.40)],
            configuration: BeautyConfiguration(maximumFaceCount: 1)
        )

        XCTAssertEqual(FaceSelectionPolicy.areaTieThreshold, 0.05)
        XCTAssertEqual(result.selectedFaces.map(\.stableID), ["stable"])
    }

    func testPIPE07MaximumFaceCountTwoReportsUsedFaceCountAndLimitReason() {
        var policy = FaceSelectionPolicy()
        let result = policy.select(
            from: [face("a", area: 0.40), face("b", area: 0.30), face("c", area: 0.20)],
            configuration: BeautyConfiguration(maximumFaceCount: 2)
        )

        XCTAssertEqual(result.selectedFaces.map(\.stableID), ["a", "b"])
        XCTAssertEqual(result.summary.availability, .usable)
        XCTAssertEqual(result.summary.faceCount, 3)
        XCTAssertEqual(result.summary.usedFaceCount, 2)
        XCTAssertEqual(result.summary.reasons, [.faceLimitApplied])
    }

    func testPIPE07ResetClearsLifecycleLocalStableSelection() {
        var policy = FaceSelectionPolicy()

        _ = policy.select(
            from: [face("stable", area: 0.40), face("other", area: 0.20)],
            configuration: BeautyConfiguration(maximumFaceCount: 1)
        )
        policy.reset()
        let result = policy.select(
            from: [face("new", area: 0.43), face("stable", area: 0.40)],
            configuration: BeautyConfiguration(maximumFaceCount: 1)
        )

        XCTAssertEqual(result.selectedFaces.map(\.stableID), ["new"])
    }

    private func face(_ stableID: String, area: Double) -> BeautyFaceObservation {
        BeautyFaceObservation(stableID: stableID, normalizedArea: area)
    }
}
