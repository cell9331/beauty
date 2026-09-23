import XCTest
@testable import BeautyEffects

final class HorizontalInwardWarpSafetyTests: XCTestCase {
    private func point(_ x: Float, _ delta: Float, radius: Float = 0.1) -> WarpControlPoint {
        .init(source: .init(x, 0.5), target: .init(x + delta, 0.5),
              radius: radius, strength: 0.25, falloff: 1)
    }

    func testOrderedInwardFieldsHavePositiveHorizontalJacobian() {
        let points = [point(0.3, 0.06), point(0.7, -0.06)]
        XCTAssertTrue(HorizontalInwardWarpSafety.accepts(points, maximumSlope: 0.8))
        // Independent finite-difference oracle on the actual inverse map.
        func sample(_ x: Double, _ y: Double) -> Double {
            points.reduce(x) { result, point in
                let dx = x - Double(point.target.x), dy = y - Double(point.target.y)
                let weight = max(0, 1 - (dx * dx + dy * dy).squareRoot() / Double(point.radius))
                return result - Double(point.target.x - point.source.x) * weight
            }
        }
        for y in stride(from: 0.3, through: 0.7, by: 0.01) {
            for x in stride(from: 0.1, through: 0.9, by: 0.002) {
                XCTAssertGreaterThanOrEqual((sample(x + 0.00001, y) - sample(x, y)) / 0.00001, 0.2 - 0.0001)
            }
        }
    }

    func testRejectsCrossingNonhorizontalNonlinearAndOverlappingExcess() {
        XCTAssertFalse(HorizontalInwardWarpSafety.accepts([], maximumSlope: 0.8))
        XCTAssertFalse(HorizontalInwardWarpSafety.accepts([point(0.3, 0.41), point(0.7, -0.41)], maximumSlope: 0.8))
        XCTAssertFalse(HorizontalInwardWarpSafety.accepts([point(0.3, 0.05), point(0.31, 0.05), point(0.7, -0.05)], maximumSlope: 0.8))
        var p = point(0.3, 0.05)
        p = .init(source: p.source, target: .init(p.target.x, 0.51), radius: p.radius, strength: p.strength, falloff: 1)
        XCTAssertFalse(HorizontalInwardWarpSafety.accepts([p, point(0.7, -0.05)], maximumSlope: 0.8))
        p = .init(source: .init(0.3, 0.5), target: .init(0.35, 0.5), radius: 0.1, strength: 0.25, falloff: 2)
        XCTAssertFalse(HorizontalInwardWarpSafety.accepts([p, point(0.7, -0.05)], maximumSlope: 0.8))
        XCTAssertFalse(HorizontalInwardWarpSafety.accepts([point(0.3, .nan)], maximumSlope: 0.8))
        XCTAssertFalse(HorizontalInwardWarpSafety.accepts([point(0.3, 0.05), point(0.7, -0.05)], maximumSlope: 1))
    }
}
