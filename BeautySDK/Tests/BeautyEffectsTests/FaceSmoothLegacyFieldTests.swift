import Foundation
import XCTest
@testable import BeautyEffects

final class FaceSmoothLegacyFieldTests: XCTestCase {
    /// An independent four-corner derivative check. A cell whose lower-left
    /// corner is flat can still exceed the bound at its opposite corner.
    private func maximumGradient(_ field: [Float], width: Int, height: Int) -> Double {
        var maximum = 0.0
        for y in 0..<(height - 1) { for x in 0..<(width - 1) {
            let i = y * width + x
            let a = Double(field[i]), b = Double(field[i + 1])
            let c = Double(field[i + width]), d = Double(field[i + width + 1])
            for (dx, dy) in [(b - a, c - a), (b - a, d - b), (d - c, c - a), (d - c, d - b)] {
                maximum = max(maximum, hypot(dx, dy))
            }
        } }
        return maximum
    }

    func testRejectedFootprintsCannotLeaveAbruptCapEdges() throws {
        let width = 9, height = 7
        for negative in [false, true] {
            var source = [Float](repeating: 0, count: width * height)
            // This is the cap field left by a hard domain/footprint refusal:
            // a four-pixel valid sample beside exact-zero refused samples.
            source[3 * width + 4] = negative ? -4 : 4
            XCTAssertGreaterThan(maximumGradient(source, width: width, height: height), 4)
            let cap = try XCTUnwrap(FaceContourSubpixelRefiner.constrainedLegacyCapField(
                source, width: width, height: height))
            XCTAssertLessThanOrEqual(maximumGradient(cap, width: width, height: height), 0.450001)
            XCTAssertGreaterThan(abs(cap[3 * width + 4]), 0.20, "projection must retain a useful admitted field")
            for i in source.indices {
                XCTAssertLessThanOrEqual(abs(cap[i]), abs(source[i]))
                XCTAssertTrue(source[i] == 0 ? cap[i] == 0 : cap[i] * source[i] >= 0)
            }
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                XCTAssertLessThanOrEqual(maximumGradient(cap.map { $0 * fraction },
                    width: width, height: height), 0.450001)
            }
            XCTAssertTrue(cap == FaceContourSubpixelRefiner.constrainedLegacyCapField(
                source, width: width, height: height), "deterministic projection")
        }
    }

    func testOppositeSignsAndAllCellCornersRemainBoundedWithoutRevivingZeros() throws {
        let width = 8, height = 8
        var source = [Float](repeating: 0, count: width * height)
        source[3 * width + 3] = 4
        source[3 * width + 4] = -4
        source[4 * width + 3] = 2
        source[4 * width + 4] = -1
        let cap = try XCTUnwrap(FaceContourSubpixelRefiner.constrainedLegacyCapField(
            source, width: width, height: height))
        XCTAssertLessThanOrEqual(maximumGradient(cap, width: width, height: height), 0.450001)
        XCTAssertGreaterThan(cap.map { abs($0) }.max() ?? 0, 0.10)
        XCTAssertTrue(cap.indices.allSatisfy { i in
            abs(cap[i]) <= abs(source[i]) && (source[i] == 0 ? cap[i] == 0 : cap[i] * source[i] >= 0)
        })
    }

    func testMalformedOrUnboundedFieldSupportFailsClosed() throws {
        let valid = [Float](repeating: 0, count: 25)
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedLegacyCapField(valid, width: 2, height: 3))
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedLegacyCapField(valid, width: Int.max, height: 3))
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedLegacyCapField(Array(valid.dropLast()), width: 5, height: 5))
        for invalid: Float in [.nan, .infinity, -.infinity] {
            var source = valid; source[12] = invalid
            XCTAssertNil(FaceContourSubpixelRefiner.constrainedLegacyCapField(source, width: 5, height: 5))
        }
        var unbounded = valid; unbounded[0] = 1
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedLegacyCapField(unbounded, width: 5, height: 5))
        var extreme = valid; extreme[12] = .greatestFiniteMagnitude
        let cap = try XCTUnwrap(FaceContourSubpixelRefiner.constrainedLegacyCapField(extreme, width: 5, height: 5))
        XCTAssertTrue(cap.allSatisfy(\.isFinite))
        XCTAssertLessThanOrEqual(maximumGradient(cap, width: 5, height: 5), 0.450001)
        XCTAssertTrue(valid == FaceContourSubpixelRefiner.constrainedLegacyCapField(valid, width: 5, height: 5))
    }

    func testBoundedSourceRegistrationRetainsRowPhaseWithoutHorizontalFolds() throws {
        let width = 17, height = 8
        var source = [Float](repeating: 0, count: width * height)
        for y in 1..<(height - 1) { for x in 1..<(width - 1) {
            let phase: Float = y.isMultiple(of: 2) ? 0.49 : -0.49
            source[y * width + x] = phase * min(1, max(0, Float(7 - abs(x - 8)) / 6))
        } }
        XCTAssertGreaterThan(maximumGradient(source, width: width, height: height), 0.9,
            "source quantization produces vertical phase changes")
        let cap = try XCTUnwrap(FaceContourSubpixelRefiner.constrainedLegacyRegistrationField(
            source, width: width, height: height))
        XCTAssertTrue(cap == source, "already-monotone row calibration must remain source-exact")
        for y in 0..<height { for x in 0..<(width - 1) {
            XCTAssertLessThanOrEqual(abs(Double(cap[y * width + x + 1]) - Double(cap[y * width + x])), 0.450001)
        } }
        var abrupt = source; abrupt[3 * width + 8] = 1.5
        let attenuated = try XCTUnwrap(FaceContourSubpixelRefiner.constrainedLegacyRegistrationField(
            abrupt, width: width, height: height))
        for y in 0..<height { for x in 0..<(width - 1) {
            XCTAssertLessThanOrEqual(abs(Double(attenuated[y * width + x + 1]) - Double(attenuated[y * width + x])), 0.450001)
        } }
        XCTAssertTrue(attenuated.indices.allSatisfy { abs(attenuated[$0]) <= abs(abrupt[$0]) })
        var invalid = source; invalid[3 * width + 8] = 1.5001
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedLegacyRegistrationField(invalid, width: width, height: height))
        invalid[3 * width + 8] = .nan
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedLegacyRegistrationField(invalid, width: width, height: height))
        invalid = source; invalid[0] = 1
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedLegacyRegistrationField(invalid, width: width, height: height))
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedLegacyRegistrationField(source, width: 2, height: 3))
    }

    func testCompleteSourceShapeFieldBoundsVerticalPhaseAndEveryPaddedCorner() throws {
        let width = 11, height = 8
        var source = [Float](repeating: 0, count: width * height)
        for y in 0..<height { for x in 0..<width {
            source[y * width + x] = (y.isMultiple(of: 2) ? 0.49 : -0.49) *
                min(1, max(0, Float(5 - abs(x - 5)) / 3))
        } }
        XCTAssertGreaterThan(maximumGradient(source, width: width, height: height), 0.9)
        let actual = try XCTUnwrap(FaceContourSubpixelRefiner.constrainedProtectedSourceField(
            source, width: width, height: height))
        var padded = [Float](repeating: 0, count: (width + 2) * (height + 2))
        for y in 0..<height { for x in 0..<width {
            padded[(y + 1) * (width + 2) + x + 1] = actual[y * width + x]
        } }
        XCTAssertLessThanOrEqual(maximumGradient(padded, width: width + 2, height: height + 2), 0.450001)
        XCTAssertGreaterThan(actual.reduce(Float.zero) { $0 + abs($1) }, 0.5)
        XCTAssertTrue(actual.indices.allSatisfy {
            abs(actual[$0]) <= abs(source[$0]) && (source[$0] == 0 ? actual[$0] == 0 : actual[$0] * source[$0] >= 0)
        })
        XCTAssertTrue(actual == FaceContourSubpixelRefiner.constrainedProtectedSourceField(
            source, width: width, height: height))
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedProtectedSourceField(source, width: 0, height: height))
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedProtectedSourceField(source, width: Int.max, height: height))
        var invalid = source; invalid[2] = .nan
        XCTAssertNil(FaceContourSubpixelRefiner.constrainedProtectedSourceField(invalid, width: width, height: height))
    }
}
