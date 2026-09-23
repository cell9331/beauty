import XCTest

/// A diagnostic counterexample, not a substitute acceptance oracle. The frozen
/// comparator's dark-half-centroid formula can reverse a known contraction.
/// Keep this evidence separate from effect/provider success and do not alter
/// the registered comparator or its thresholds here.
final class RootMetricCounterexampleTests: XCTestCase {
    private let width = 1024

    private func stripe(halfWidth: Double, background: UInt8) -> [UInt8] {
        (0..<width).map { x in
            abs((Double(x) + 0.5) / Double(width) - 0.5) < halfWidth
                ? background + 10 : background
        }
    }

    private func darkSpan(_ row: [UInt8]) -> Int64 {
        // Same integer, full-image-normalized centroid formula as the frozen
        // comparator. Repeating the row in Y cancels in numerator/denominator.
        let lo = 358, hi = 665, split = (lo + hi) / 2
        var weights = [Int64](repeating: 0, count: 2), moments = weights
        for x in lo..<hi {
            let side = x < split ? 0 : 1
            let weight = Int64(255 - row[x]) * 256
            weights[side] += weight
            moments[side] += Int64(x * 2 + 1) * weight
        }
        return moments[1] * 65_536 / (weights[1] * Int64(width * 2))
            - moments[0] * 65_536 / (weights[0] * Int64(width * 2))
    }

    func testKnownLowContrastContractionIsMisclassifiedAsExpansion() {
        let before = stripe(halfWidth: 0.12, background: 215)
        let after = stripe(halfWidth: 0.10, background: 215)
        XCTAssertEqual(before.filter { $0 == 225 }.count, 246)
        XCTAssertEqual(after.filter { $0 == 225 }.count, 204)
        XCTAssertEqual(darkSpan(before), 10_312)
        XCTAssertEqual(darkSpan(after), 10_480)
        XCTAssertEqual(darkSpan(before) - darkSpan(after), -168)
        // Negative remains a failure under the unchanged >=16 gate, despite
        // the explicitly constructed 42-pixel decrease in structural width.
        XCTAssertLessThan(darkSpan(before) - darkSpan(after), 16)
    }

    func testBrightnessOffsetReversesVerdictWithoutChangingGeometryOrContrast() {
        let lowBefore = stripe(halfWidth: 0.12, background: 215)
        let lowAfter = stripe(halfWidth: 0.10, background: 215)
        let highBefore = stripe(halfWidth: 0.12, background: 245)
        let highAfter = stripe(halfWidth: 0.10, background: 245)
        XCTAssertEqual(zip(lowBefore, highBefore).map { Int($1) - Int($0) }, Array(repeating: 30, count: width))
        XCTAssertEqual(zip(lowAfter, highAfter).map { Int($1) - Int($0) }, Array(repeating: 30, count: width))
        XCTAssertLessThan(darkSpan(lowBefore) - darkSpan(lowAfter), 0)
        XCTAssertGreaterThanOrEqual(darkSpan(highBefore) - darkSpan(highAfter), 16)
    }
}
