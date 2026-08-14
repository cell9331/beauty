import XCTest
import BeautySDK

private struct SendablePayload: Equatable, Sendable {
    let identifier: Int
    let label: String
}

// This type intentionally has no Sendable conformance.  The static boundary
// guard owns the negative compile-contract assertion; this passing test target
// only exercises the valid public path.
private final class NonSendablePayload {
    var identifier = 7
}

final class BeautyResultConcurrencyTests: XCTestCase {
    private func assertSendable<T: Sendable>(_ value: T) -> T {
        value
    }

    func testSendableResultCanCrossTaskBoundaryWithoutLosingPublicFields() async {
        let warning = BeautyValidationWarning(code: "fixture_warning", message: "bounded")
        let summary = BeautyDetectionSummary(
            availability: .usable,
            reasons: [],
            faceCount: 2,
            usedFaceCount: 1,
            detectionDurationMs: 4.5,
            mappingDurationMs: 1.25
        )
        let original = BeautyResult(
            output: SendablePayload(identifier: 42, label: "reference"),
            warnings: [warning],
            metrics: ["duration_ms": 6.0],
            detectionSummary: summary
        )
        let sendable = assertSendable(original)

        let transferred = await Task.detached { sendable }.value

        XCTAssertEqual(transferred.output, original.output)
        XCTAssertEqual(transferred.warnings, original.warnings)
        XCTAssertEqual(transferred.metrics, original.metrics)
        XCTAssertEqual(transferred.detectionSummary, original.detectionSummary)
    }

    func testOrdinaryStringResultConstructionRemainsSourceCompatible() {
        let result = BeautyResult(output: "ok")

        XCTAssertEqual(result.output, "ok")
        XCTAssertEqual(result.warnings, [])
        XCTAssertEqual(result.metrics, [:])
        XCTAssertNil(result.detectionSummary)
    }

    func testNonSendablePayloadRemainsOutsidePositiveContract() {
        let payload = NonSendablePayload()
        let result = BeautyResult(output: payload)

        XCTAssertEqual(result.output.identifier, 7)
    }
}
