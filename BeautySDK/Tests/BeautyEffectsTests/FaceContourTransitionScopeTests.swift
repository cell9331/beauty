import Foundation
import XCTest
@testable import BeautyEffects

final class FaceContourTransitionScopeTests: XCTestCase {
    private let path: [SIMD2<Double>] = [SIMD2(240, 220), SIMD2(240, 280),
        SIMD2(260, 340), SIMD2(320, 410), SIMD2(400, 460), SIMD2(480, 410),
        SIMD2(540, 340), SIMD2(560, 280), SIMD2(560, 220)]
    private let origin = SIMD2<Double>(400, 200)

    private func make(contour: [SIMD2<Double>]? = nil, origin: SIMD2<Double>? = nil,
                      axisX: SIMD2<Double> = SIMD2(1, 0), axisY: SIMD2<Double> = SIMD2(0, 1),
                      span: Double = 320, chin: Double = 260,
                      lowerBound: Double = 40) -> BeautyContourTransitionScope? {
        BeautyContourTransitionScope(width: 800, height: 800, contour: contour ?? path,
            origin: origin ?? self.origin, axisX: axisX, axisY: axisY,
            span: span, chin: chin, lowerBound: lowerBound)
    }

    func testSourceTubeHasUsefulInteriorAndExactFixedExterior() throws {
        let scope = try XCTUnwrap(make())
        XCTAssertEqual(scope.radius, 19.2, accuracy: 0.000_000_1)
        XCTAssertEqual(scope.normalizedWidth, 0.12, accuracy: 0.000_000_1)
        XCTAssertTrue(scope.allowsDestination(x: 240, y: 260))
        XCTAssertEqual(scope.distanceToFixed(x: 240, y: 260), 16.2, accuracy: 0.000_000_1)
        XCTAssertFalse(scope.allowsDestination(x: 219, y: 260), "outside the raw-path tube")
        XCTAssertFalse(scope.allowsDestination(x: 221, y: 260), "inside the tube without its whole collar")
        XCTAssertTrue(scope.allowsDestination(x: 225, y: 260))
        XCTAssertEqual(scope.distanceToFixed(x: 400, y: 300), 0, "the interior of the face is not the narrow tube")
    }

    func testEverySourceFootprintTexelIsRequiredEvenAtZeroWeight() throws {
        let scope = try XCTUnwrap(make())
        XCTAssertTrue(scope.allowsSourceFootprint(x: 240.5, y: 260.5))
        XCTAssertTrue(scope.allowsSourceFootprint(x: 225.5, y: 260.5))
        XCTAssertTrue(scope.allowsDestination(x: 255, y: 260))
        XCTAssertFalse(scope.allowsDestination(x: 256, y: 260))
        XCTAssertFalse(scope.allowsSourceFootprint(x: 255.5, y: 260.5),
            "an exact-centre query cannot omit its zero-weight external neighbour")
        for p in [SIMD2<Double>(-.infinity, 260), SIMD2(.nan, 260), SIMD2(0, 0), SIMD2(800, 260)] {
            XCTAssertFalse(scope.allowsSourceFootprint(x: p.x, y: p.y))
            XCTAssertEqual(scope.distanceToFixed(x: p.x, y: p.y), 0)
        }
    }

    func testClippedSourceArcsHaveRoundCapsWithoutBridgingSidesOrReachingJaw() throws {
        let scope = try XCTUnwrap(make())
        XCTAssertTrue(scope.allowsDestination(x: 240, y: 230), "the top endpoint has a round cap above the clipping slab")
        XCTAssertTrue(scope.allowsDestination(x: 240, y: 224))
        XCTAssertFalse(scope.allowsDestination(x: 240, y: 221), "the whole conservative collar remains required")
        XCTAssertFalse(scope.allowsDestination(x: 240, y: 220), "outside the top round cap")
        XCTAssertTrue(scope.allowsDestination(x: 296, y: 392), "the lower endpoint has a round cap below .70 chin")
        XCTAssertEqual(scope.distanceToFixed(x: 296, y: 382), 16.2, accuracy: 0.000_000_1)
        XCTAssertEqual(scope.distanceToFixed(x: 296, y: 403), 0)
        XCTAssertEqual(scope.distanceToFixed(x: 400, y: 382), 0, "do not join the clipped left and right endpoints")
        XCTAssertFalse(scope.allowsDestination(x: 400, y: 460), "the distant raw jaw apex remains fixed")
        XCTAssertFalse(scope.allowsDestination(x: -1, y: 260))
        XCTAssertFalse(scope.allowsDestination(x: 800, y: 260))
    }

    func testRolledSourceFrameKeepsTheSameTubeDistanceAndSlab() throws {
        let angle = Double.pi / 12, c = cos(angle), s = sin(angle)
        func roll(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let q = p - origin
            return origin + SIMD2(c * q.x - s * q.y, s * q.x + c * q.y)
        }
        let rolled = path.map(roll)
        let scope = try XCTUnwrap(make(contour: rolled, axisX: SIMD2(c, s), axisY: SIMD2(-s, c)))
        let admitted = roll(SIMD2(240, 260)), fixed = roll(SIMD2(219, 260))
        XCTAssertEqual(scope.distanceToFixed(x: admitted.x, y: admitted.y), 16.2, accuracy: 0.000_000_1)
        XCTAssertTrue(scope.allowsDestination(x: Int(floor(admitted.x)), y: Int(floor(admitted.y))))
        XCTAssertEqual(scope.distanceToFixed(x: fixed.x, y: fixed.y), 0)
        let jaw = roll(SIMD2(400, 460))
        XCTAssertEqual(scope.distanceToFixed(x: jaw.x, y: jaw.y), 0)
    }

    func testSmallRasterRefusesAnEmptyCollarButLargerScaledSourceRemainsUseful() throws {
        func scaled(_ factor: Double) -> BeautyContourTransitionScope? {
            let side = Int(800 * factor)
            return BeautyContourTransitionScope(width: side, height: side, contour: path.map { $0 * factor },
                origin: origin * factor, axisX: SIMD2(1, 0), axisY: SIMD2(0, 1),
                span: 320 * factor, chin: 260 * factor, lowerBound: 40 * factor)
        }
        XCTAssertNil(scaled(0.1))
        let scope = try XCTUnwrap(scaled(0.4))
        XCTAssertEqual(scope.radius, 7.68, accuracy: 0.000_000_1)
        XCTAssertTrue(scope.allowsDestination(x: 96, y: 104))
    }

    func testMalformedFrameOrPathRefusesBeforeAnyQuery() {
        XCTAssertNil(make(contour: Array(path.prefix(6))))
        XCTAssertNil(make(contour: Array(repeating: path[0], count: 9)))
        XCTAssertNil(make(contour: path + path + path + path))
        var duplicate = path; duplicate[5] = duplicate[4]
        XCTAssertNil(make(contour: duplicate))
        let aboveSlab = (0..<9).map { SIMD2<Double>(200 + Double($0) * 10, 210) }
        XCTAssertNil(make(contour: aboveSlab), "no eligible source segment")
        var nonfinite = path; nonfinite[0] = SIMD2(.nan, 220)
        XCTAssertNil(make(contour: nonfinite))
        var outside = path; outside[0] = SIMD2(-1, 220)
        XCTAssertNil(make(contour: outside))
        XCTAssertNil(make(origin: SIMD2(.infinity, 200)))
        XCTAssertNil(make(axisX: SIMD2(1, 1)))
        XCTAssertNil(make(axisY: SIMD2(1, 0)))
        XCTAssertNil(make(axisY: SIMD2(0, -1)))
        XCTAssertNil(make(span: .nan))
        XCTAssertNil(make(span: 0))
        XCTAssertNil(make(chin: .infinity))
        XCTAssertNil(make(lowerBound: 182))
        XCTAssertNil(make(lowerBound: .nan))
    }

    func testScopeMatchesExactFrozenSourceAndDoesNotExposeRawPathInDiagnostics() throws {
        let scope = try XCTUnwrap(make())
        XCTAssertTrue(scope.matches(width: 800, height: 800, contour: path))
        XCTAssertFalse(scope.matches(width: 801, height: 800, contour: path))
        var different = path; different[0].x += 0.001
        XCTAssertFalse(scope.matches(width: 800, height: 800, contour: different))
        let labels = Set(Mirror(reflecting: scope).children.compactMap(\.label))
        XCTAssertTrue(labels == ["width", "height", "pointCount", "radius", "normalizedWidth"])
        XCTAssertFalse(String(reflecting: scope).contains("SIMD2"))
    }
}
