import Foundation
import XCTest
@testable import BeautyEffects

final class FaceContourProjectionEquivalenceTests: XCTestCase {
    private let xs: [Double] = [0, 0.5, 1.75, 3, 5]
    private let ys: [Double] = [0, 0.75, 2, 4]

    func testZeroAndSignedZeroFieldsMatchLegacy64PassBits() {
        let seed = (0..<(xs.count * ys.count)).map { index in
            SIMD2<Double>(index.isMultiple(of: 2) ? -0.0 : 0.0,
                          index.isMultiple(of: 3) ? -0.0 : 0.0)
        }
        assertEquivalent(seed, maximumGradient: 0.45, maximumDisplacement: 0.3)
    }

    func testAlreadyFeasibleSignedFieldMatchesLegacy64PassBits() {
        let seed = ys.flatMap { y in xs.map { x in SIMD2(x * 0.015, y * -0.01) } }
        assertEquivalent(seed, maximumGradient: 0.45, maximumDisplacement: 0.3)
    }

    func testActiveProjectionWithFixedNodesMatchesLegacy64PassBits() {
        let seed = (0..<(xs.count * ys.count)).map { index -> SIMD2<Double> in
            if index.isMultiple(of: 5) { return .zero }
            return SIMD2(index.isMultiple(of: 2) ? 1.7 : -2.3,
                         index.isMultiple(of: 3) ? -1.1 : 2.9)
        }
        assertEquivalent(seed, maximumGradient: 0.45, maximumDisplacement: 0.3)
    }

    func testDisplacementOnlyClampMatchesLegacy64PassBits() {
        let seed = [SIMD2<Double>](repeating: SIMD2(2, -1), count: xs.count * ys.count)
        assertEquivalent(seed, maximumGradient: 0.45, maximumDisplacement: 0.3)
    }

    private func assertEquivalent(_ seed: [SIMD2<Double>], maximumGradient: Double,
                                  maximumDisplacement: Double, file: StaticString = #filePath,
                                  line: UInt = #line) {
        let expected = legacy64PassField(seed, xs: xs, ys: ys,
            maximumGradient: maximumGradient, maximumDisplacement: maximumDisplacement)
        let actual = BeautyContinuousFaceMap.boundedField(seed, xs: xs, ys: ys,
            maximumGradient: maximumGradient, maximumDisplacement: maximumDisplacement)
        XCTAssertEqual(actual.count, expected.count, file: file, line: line)
        for index in expected.indices {
            XCTAssertEqual(actual[index].x.bitPattern, expected[index].x.bitPattern,
                           "x component at node \(index)", file: file, line: line)
            XCTAssertEqual(actual[index].y.bitPattern, expected[index].y.bitPattern,
                           "y component at node \(index)", file: file, line: line)
        }
    }

    // Frozen pre-optimization solver. Keep its 64 passes, arithmetic and update
    // order independent of the production early-exit implementation above.
    private func legacy64PassField(_ seed: [SIMD2<Double>], xs: [Double], ys: [Double],
        maximumGradient: Double, maximumDisplacement: Double) -> [SIMD2<Double>] {
        var field = seed
        let fixed = seed.map { $0 == .zero }
        func norm(_ p: SIMD2<Double>) -> Double { hypot(p.x, p.y) }
        func project(_ a: Int, _ b: Int, _ c: Int, _ dx: Double, _ dy: Double) {
            let ax = 1 / dx, ay = 1 / dy
            let gx = (field[b] - field[a]) * ax, gy = (field[c] - field[a]) * ay
            guard sqrt(gx.x*gx.x + gx.y*gx.y + gy.x*gy.x + gy.y*gy.y) > maximumGradient else { return }
            let m00 = (fixed[a] ? 0 : ax*ax) + (fixed[b] ? 0 : ax*ax)
            let m11 = (fixed[a] ? 0 : ay*ay) + (fixed[c] ? 0 : ay*ay)
            let m01 = fixed[a] ? 0 : ax*ay
            guard m00 + m11 > 0 else { return }
            func reduced(_ multiplier: Double) -> (SIMD2<Double>, SIMD2<Double>) {
                let determinant = 1 + multiplier * (m00 + m11)
                    + multiplier * multiplier * max(0, m00 * m11 - m01 * m01)
                return ((gx * (1 + multiplier * m11) - gy * (multiplier * m01)) / determinant,
                        (gy * (1 + multiplier * m00) - gx * (multiplier * m01)) / determinant)
            }
            func admissible(_ multiplier: Double) -> Bool {
                let (x, y) = reduced(multiplier)
                return sqrt(x.x*x.x + x.y*x.y + y.x*y.x + y.y*y.y) <= maximumGradient
            }
            var lower = 0.0, upper = 1 / (m00 + m11)
            for _ in 0..<40 where !admissible(upper) { upper *= 2 }
            for _ in 0..<12 {
                let middle = (lower + upper) * 0.5
                if admissible(middle) { upper = middle } else { lower = middle }
            }
            let (x, y) = reduced(upper)
            if !fixed[a] { field[a] += (x * ax + y * ay) * upper }
            if !fixed[b] { field[b] -= x * (ax * upper) }
            if !fixed[c] { field[c] -= y * (ay * upper) }
        }
        for pass in 0..<64 {
            let rows = pass.isMultiple(of: 2) ? Array(0..<(ys.count - 1)) : Array((0..<(ys.count - 1)).reversed())
            let columns = pass.isMultiple(of: 2) ? Array(0..<(xs.count - 1)) : Array((0..<(xs.count - 1)).reversed())
            for row in rows { for col in columns {
                let tl = row * xs.count + col, tr = tl + 1, bl = tl + xs.count, br = bl + 1
                let dx = xs[col + 1] - xs[col], dy = ys[row + 1] - ys[row]
                project(tl, tr, bl, dx, dy); project(tr, tl, br, dx, dy)
                project(bl, br, tl, dx, dy); project(br, bl, tr, dx, dy)
            } }
            for index in field.indices {
                let length = norm(field[index])
                if length > maximumDisplacement { field[index] *= maximumDisplacement / length }
            }
        }
        return field
    }
}
