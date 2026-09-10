import CryptoKit
import Foundation
import XCTest
import BeautyCore
@testable import BeautyEffects

final class NoseRepairFieldTests: XCTestCase {
    private let provider = NoseWarpProvider()
    private typealias Point = SIMD2<Float>

    // Independent synthetic supports; these never determine public pixel ROIs.
    private func face(nose: [Point]? = nil, root: [Point]? = nil,
                      bounds: FaceBounds? = nil, freshness: LandmarkGeometryFreshness = .fresh) -> FaceGeometry {
        let original = FaceGeometry.fixture
        return FaceGeometry(bounds: bounds ?? original.bounds, faceContour: original.faceContour,
                            leftEye: original.leftEye, rightEye: original.rightEye,
                            nose: nose ?? original.nose, noseRoot: root ?? original.noseRoot,
                            noseTip: original.noseTip, outerLips: original.outerLips, freshness: freshness)
    }

    private func strengths(_ bridge: Float = 0, _ root: Float = 0) -> BeautyEffectiveStrengths {
        var value = BeautyEffectiveStrengths()
        value.noseBridge = bridge
        value.noseRootNarrowing = root
        return value
    }

    private func fields(_ face: FaceGeometry = .fixture, _ factor: Float = 1) -> NoseWarpFieldEmissions {
        provider.fieldEmissions(face: face, strengths: strengths(0.30 * factor, 0.25 * factor))
    }

    private func admitted(_ point: WarpControlPoint) -> Bool {
        let delta = point.target - point.source
        return point.radius > 0.0001 && abs(delta.x) + abs(delta.y) > 0.0001
    }

    private func scales(_ points: [WarpControlPoint], from cap: [WarpControlPoint],
                        factor: Float, strength: Float) -> Bool {
        guard !points.isEmpty, points.count == cap.count else { return false }
        return zip(points, cap).allSatisfy { point, full in
            let expected = (full.target.x - full.source.x) * factor
            let actual = point.target.x - point.source.x
            // Two Float reconstructions and the intervening multiply: <=8 ulps.
            let tolerance = 8 * max(point.target.x.ulp, full.target.x.ulp)
            return point.source == full.source && point.target.y == point.source.y &&
                abs(actual - expected) <= tolerance && point.strength == strength &&
                point.radius == full.radius && point.falloff == 2 && admitted(point)
        }
    }

    func testBridgeDisplacementScalesAtQuarterHalfAndCap() {
        let cap: Float = 0.30
        XCTAssertTrue(BeautySafetyCaps.noseBridge == cap)
        let full = fields().noseBridge
        XCTAssertFalse(full.isEmpty, "eligible bridge denominator")
        var correct = true
        for value: Float in [cap / 4, cap / 2, cap.nextDown, cap, cap / 1.80, cap / 13.45] {
            let actual = provider.fieldEmissions(face: .fixture, strengths: strengths(value)).noseBridge
            correct = scales(actual, from: full, factor: value / cap, strength: value) && correct
        }
        for value: Float in [0, Float.ulpOfOne, Float.ulpOfOne.nextUp, -cap, cap.nextUp, .infinity, -.infinity, .nan] {
            correct = provider.fieldEmissions(face: .fixture, strengths: strengths(value)).noseBridge.isEmpty && correct
        }
        XCTAssertTrue(correct, "P93_BRIDGE_SCALING")
    }

    func testRootPairRemainsAtomicAndIndependent() {
        XCTAssertTrue(BeautySafetyCaps.noseRootNarrowing == Float(0.25))
        let full = fields().noseRootNarrowing
        XCTAssertTrue(full.count == 2, "eligible explicit pair")
        for factor: Float in [0.25, 0.5, 1, 1 / 1.80, 1 / 13.45] {
            let value = Float(0.25) * factor
            let independent = provider.fieldEmissions(face: face(nose: []), strengths: strengths(0, value)).noseRootNarrowing
            XCTAssertTrue(scales(independent, from: full, factor: factor, strength: value), "root amplitude and independence")
            XCTAssertTrue(independent.allSatisfy { $0.target.y == $0.source.y }, "root Y identity")
            XCTAssertTrue(independent.count == 2 && independent[0].target.x < FaceGeometry.fixture.bounds.midX &&
                          independent[1].target.x > FaceGeometry.fixture.bounds.midX, "root straddle")
        }
        let root = FaceGeometry.fixture.noseRoot
        let malformed: [[Point]] = [[], [root[0]], [root[0], root[0]],
            [Point(.nan, root[0].y), root[1]], [Point(-1, root[0].y), root[1]],
            [root[0], Point(root[1].x + 0.01, root[1].y)],
            [root[0], Point(root[1].x, root[1].y + 0.01)],
            [root[0], Point(root[0].x - 0.01, root[0].y)]]
        for support in malformed {
            var requested = strengths(0, 0.25)
            requested.noseTipLift = 0.25
            let emission = provider.fieldEmissions(face: face(root: support), strengths: requested)
            XCTAssertTrue(emission.noseRootNarrowing.isEmpty, "no root substitution")
            XCTAssertFalse(emission.noseTipLift.isEmpty, "independent emitting sibling")
            XCTAssertTrue(emission.sanitizing(requested).noseRootNarrowing == 0 &&
                          emission.sanitizing(requested).noseTipLift == Float(0.25), "field-local sanitation")
        }
    }

    private func budget(_ points: [WarpControlPoint]) -> Double {
        points.reduce(0) { sum, point in
            let delta = point.target - point.source
            return sum + 2 * hypot(Double(delta.x), Double(delta.y)) / Double(point.radius)
        }
    }

    private func diskContained(_ point: Point, radius: Float, bounds: FaceBounds) -> Bool {
        point.x.isFinite && point.y.isFinite && radius.isFinite && radius > 0 &&
            point.x - radius >= max(0, bounds.minX) && point.x + radius <= min(1, bounds.maxX) &&
            point.y - radius >= max(0, bounds.minY) && point.y + radius <= min(1, bounds.maxY)
    }

    // Independent unclamped quadratic inverse map, using actual admitted Float points.
    private func sample(_ location: Point, _ points: [WarpControlPoint]) -> Point {
        var result = location
        for point in points where admitted(point) {
            let offset = location - point.target
            let squared = offset.x * offset.x + offset.y * offset.y
            let radius = min(max(point.radius, 0.001), 1)
            if squared < radius * radius {
                let weight = max(0, min(1, 1 - squared.squareRoot() / radius))
                result -= (point.target - point.source) * (weight * weight)
            }
        }
        return result
    }

    private func denseMapIsSafe(_ points: [WarpControlPoint], bounds: FaceBounds) -> Bool {
        guard !points.isEmpty else { return true } // explicit abstention has the identity map
        var valid = points.allSatisfy {
            diskContained($0.source, radius: $0.radius, bounds: bounds) &&
                diskContained($0.target, radius: $0.radius, bounds: bounds) && admitted($0)
        }
        let minX = points.map { $0.target.x - $0.radius }.min()!
        let maxX = points.map { $0.target.x + $0.radius }.max()!
        let minY = points.map { $0.target.y - $0.radius }.min()!
        let maxY = points.map { $0.target.y + $0.radius }.max()!
        for row in 0...128 {
            var previous: Point?
            for column in 0...128 {
                let location = Point(minX + (maxX - minX) * Float(column) / 128,
                                     minY + (maxY - minY) * Float(row) / 128)
                let value = sample(location, points)
                valid = value.x.isFinite && value.y.isFinite && valid
                if let previous { valid = value.x > previous.x && valid }
                previous = value
            }
        }
        // Circle edges from both sides, including the exact Float radius; no clamping.
        for point in points {
            for radius in [point.radius.nextDown, point.radius, point.radius.nextUp] {
                for direction in [Point(-1, 0), Point(1, 0), Point(0, -1), Point(0, 1)] {
                    let location = point.target + direction * radius
                    let value = sample(location, points)
                    let left = sample(location - Point(0.0001, 0), points)
                    let right = sample(location + Point(0.0001, 0), points)
                    valid = value.x.isFinite && value.y.isFinite && right.x > left.x && valid
                }
            }
        }
        for row in 0...128 {
            let location = Point(bounds.midX, minY + (maxY - minY) * Float(row) / 128)
            let value = sample(location, points)
            let left = sample(location - Point(0.0001, 0), points)
            let right = sample(location + Point(0.0001, 0), points)
            valid = value.x.isFinite && value.y.isFinite && right.x > left.x && valid
        }
        return valid
    }

    private func denseFace(_ count: Int) -> FaceGeometry {
        // Distinct paired upper traces with equal X work; lower anchors fix membership.
        var upper: [Point] = []
        for index in 0..<(count / 2) {
            let y = Float(0.42) + Float(index) * 0.0005
            upper.append(Point(0.488, y))
            upper.append(Point(0.512, y))
        }
        return face(nose: upper + [Point(0.46, 0.70), Point(0.54, 0.70)])
    }

    func testFinalFloatFieldBudgetAndDenseMap() {
        var correct = true
        var nonemptyFields = 0
        for count in [2, 4, 16, 64] {
            let input = denseFace(count)
            for factor: Float in [0.25, 0.5, 1] {
                let result = fields(input, factor)
                for points in [result.noseBridge, result.noseRootNarrowing] {
                    if !points.isEmpty { nonemptyFields += 1 }
                    correct = budget(points).isFinite && budget(points) <= 0.45 && correct
                    correct = denseMapIsSafe(points, bounds: input.bounds) && correct
                }
                let combined = result.noseBridge + result.noseRootNarrowing
                correct = budget(combined) <= 0.90 && denseMapIsSafe(combined, bounds: input.bounds) && correct
                // Low dense fields may abstain: the exact renderer floor consumes the
                // whole budget. Cap traces must still supply a nonempty denominator.
                if factor == 1 { correct = !result.noseBridge.isEmpty && correct }
                // For either prescribed radius, 64 admitted X-only points would
                // exceed the half/quarter scaled budget just at the strict cutoff.
                if count == 64 && factor < 1 { correct = result.noseBridge.isEmpty && correct }
            }
        }
        for factor: Float in [1, 0.5, 1 / 13.45] {
            for sibling in 0..<5 {
                var request = strengths(0.30 * factor, 0.25 * factor)
                addSibling(sibling, factor: factor, to: &request)
                let combined = provider.fieldEmissions(face: .fixture, strengths: request).points
                correct = denseMapIsSafe(combined, bounds: FaceGeometry.fixture.bounds) && correct
            }
        }
        XCTAssertGreaterThan(nonemptyFields, 0, "nonempty safety denominator")
        XCTAssertTrue(correct, "P93_FIELD_BUDGET")
    }

    func testRendererCutoffAndMalformedBoundsFailClosed() {
        var correct = true
        for value: Float in [0, Float.ulpOfOne, Float.ulpOfOne.nextUp, -0.25, Float(0.25).nextUp, .infinity, -.infinity, .nan] {
            correct = provider.fieldEmissions(face: .fixture, strengths: strengths(0, value)).noseRootNarrowing.isEmpty && correct
        }
        // Adjacent representable target components bracketing the L1 renderer cutoff.
        let source: Float = 0.5
        let near = source + Float(0.0001)
        let below = near.nextDown - source
        let above = near - source
        XCTAssertTrue(below <= 0.0001 && above > 0.0001, "representable cutoff bracket")
        let synthetic = [below, above].map {
            WarpControlPoint(source: Point(source, source), target: Point(source + $0, source),
                             radius: 0.03, strength: 0.25, falloff: 2)
        }
        XCTAssertTrue(!admitted(synthetic[0]) && admitted(synthetic[1]), "strict L1 admission")
        for radius in [Float(0.0001).nextDown, Float(0.0001), Float(0.0001).nextUp] {
            let point = WarpControlPoint(source: Point(0.5, 0.5), target: Point(0.51, 0.5),
                                         radius: radius, strength: 0.25, falloff: 2)
            XCTAssertTrue(admitted(point) == (radius > 0.0001), "strict radius admission")
        }
        for full in [fields().noseBridge, fields().noseRootNarrowing] {
            XCTAssertFalse(full.isEmpty, "cutoff denominator")
        }
        for isRoot in [false, true] {
            let full = isRoot ? fields().noseRootNarrowing : fields().noseBridge
            let cap: Float = isRoot ? 0.25 : 0.30
            let minimum = full.map { abs($0.target.x - $0.source.x) }.min()!
            let threshold = cap * Float(0.0001) / minimum
            for value in [threshold.nextDown, threshold, threshold.nextUp, threshold * 0.5, threshold * 2] {
                let request = isRoot ? strengths(0, value) : strengths(value)
                let emission = provider.fieldEmissions(face: .fixture, strengths: request)
                let points = isRoot ? emission.noseRootNarrowing : emission.noseBridge
                correct = points.allSatisfy(admitted) && correct
                correct = (isRoot ? points.isEmpty || points.count == 2 : true) && correct
                let expected = points.isEmpty ? Float(0) : value
                let sanitized = emission.sanitizing(request)
                correct = (isRoot ? sanitized.noseRootNarrowing : sanitized.noseBridge) == expected && correct
            }
        }
        let invalidBounds = [
            FaceBounds(x: .nan, y: 0.2, width: 0.4, height: 0.6),
            FaceBounds(x: 0.3, y: .infinity, width: 0.4, height: 0.6),
            FaceBounds(x: 0.3, y: 0.2, width: 0, height: 0.6),
            FaceBounds(x: 0.3, y: 0.2, width: -0.4, height: 0.6),
            FaceBounds(x: 0.3, y: 0.2, width: 0.4, height: 0),
            FaceBounds(x: 0.3, y: 0.2, width: 0.4, height: -0.6),
            FaceBounds(x: Float.greatestFiniteMagnitude, y: 0.2, width: Float.greatestFiniteMagnitude, height: 0.6)]
        for bounds in invalidBounds {
            let result = fields(face(bounds: bounds))
            correct = result.noseBridge.isEmpty && result.noseRootNarrowing.isEmpty && correct
        }
        let invalidNoses: [[Point]] = [[], [Point(0.5, 0.52)],
            [Point(0.48, 0.45), Point(0.48, 0.45), Point(0.54, 0.58)],
            [Point(.nan, 0.45), Point(0.54, 0.58)],
            [Point(Float.greatestFiniteMagnitude, 0.45), Point(Float.greatestFiniteMagnitude, 0.58)],
            [Point(-0.1, 0.45), Point(0.54, 0.58)],
            [Point(0.30, 0.45), Point(0.54, 0.58)]]
        for nose in invalidNoses {
            let request = strengths(0.30, 0.25)
            let result = provider.fieldEmissions(face: face(nose: nose), strengths: request)
            correct = result.noseBridge.isEmpty && result.sanitizing(request).noseBridge == 0 && correct
            XCTAssertFalse(result.noseRootNarrowing.isEmpty, "malformed bridge keeps root sibling")
        }
        let noRoom = face(root: [Point(0.476, 0.20), Point(0.524, 0.20)])
        let roomResult = fields(noRoom)
        correct = roomResult.noseRootNarrowing.isEmpty && correct
        XCTAssertFalse(roomResult.noseBridge.isEmpty, "root disk rejection keeps bridge")
        XCTAssertTrue(correct, "P93_RENDERER_CUTOFF")
    }

    func testReusedAndCombinedStrengthsRemainExact() {
        var parameters = BeautyParameters()
        parameters.noseBridge = 1
        parameters.noseRootNarrowing = 1
        let fresh = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
        let reused = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face(freshness: .reused))
        XCTAssertTrue(fresh.effectiveStrengths.noseBridge == Float(0.30) && fresh.effectiveStrengths.noseRootNarrowing == Float(0.25), "exact caps")
        XCTAssertTrue(reused.effectiveStrengths.noseBridge == fresh.effectiveStrengths.noseBridge * 0.5 &&
                      reused.effectiveStrengths.noseRootNarrowing == fresh.effectiveStrengths.noseRootNarrowing * 0.5, "exact reuse factor")
        var correct = true
        let full = fields()
        for effective in [fresh.effectiveStrengths, reused.effectiveStrengths] {
            let result = provider.fieldEmissions(face: .fixture, strengths: effective)
            correct = scales(result.noseBridge, from: full.noseBridge, factor: effective.noseBridge / 0.30, strength: effective.noseBridge) && correct
            correct = scales(result.noseRootNarrowing, from: full.noseRootNarrowing, factor: effective.noseRootNarrowing / 0.25, strength: effective.noseRootNarrowing) && correct
        }
        for factor: Float in [1, 0.5, 1 / 1.80, 1 / 13.45] {
            for sibling in 0..<5 {
                var request = strengths(0.30 * factor, 0.25 * factor)
                addSibling(sibling, factor: factor, to: &request)
                let result = provider.fieldEmissions(face: .fixture, strengths: request)
                correct = scales(result.noseBridge, from: full.noseBridge, factor: factor, strength: request.noseBridge) && correct
                correct = scales(result.noseRootNarrowing, from: full.noseRootNarrowing, factor: factor, strength: request.noseRootNarrowing) && correct
                XCTAssertTrue(result.points == result.noseSlim + result.noseWingSlim + result.noseTipSize +
                              result.noseBridge + result.noseRootNarrowing + result.noseTipLift, "six-field order")
            }
        }
        XCTAssertTrue(correct, "P93_REUSED_SCALING")
    }

    private func addSibling(_ index: Int, factor: Float, to value: inout BeautyEffectiveStrengths) {
        switch index {
        case 0: value.noseSlim = 0.35 * factor
        case 1: value.noseWingSlim = 0.35 * factor
        case 2: value.noseTipSize = 0.30 * factor
        case 3: value.noseTipSize = -0.30 * factor
        default: value.noseTipLift = 0.25 * factor
        }
    }

    private func siblingDigest(_ emission: NoseWarpFieldEmissions) -> String {
        var bytes = Data()
        for points in [emission.noseSlim, emission.noseWingSlim, emission.noseTipSize, emission.noseTipLift] {
            var count = UInt32(points.count).littleEndian
            withUnsafeBytes(of: &count) { bytes.append(contentsOf: $0) }
            for point in points {
                for value in [point.source.x, point.source.y, point.target.x, point.target.y, point.radius, point.strength, point.falloff] {
                    var bits = value.bitPattern.littleEndian
                    withUnsafeBytes(of: &bits) { bytes.append(contentsOf: $0) }
                }
            }
        }
        return SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }

    func testLegacySiblingVectorsRemainByteIdentical() {
        // Captured on original provider SHA-256 0684e2689cd5f3b780a69f13f701339879c3f418691a586205f4dda028ea23c8.
        // Counts and little-endian Float bits bind all four unchanged sibling fields.
        let expected = [
            "317747ddcec010b0c807dff976233905cb8e5c4a83588bfbd13f0a00d66990cb",
            "532793fb187b062f14c24dc2ef62d1e144102de6a1dc79af758302f12769cf8f",
            "bf1e39cb5af15f54f27fc042003942b50c070910a22df23236ef65da9ab54cd3",
            "94bc892ffa1d6b392469d2776ac2db2abd84b3f0e2d900b6baff0da7c100373a",
            "7c079fe2cd8ad4716bafc34eb42a3b2579b0677f502b40d31f7537f6fd697739",
            "2e23e20cae0b2530e322fbc28bc72bd7a6e14ed23f4af8d8380fde3e39676b9b",
            "8b4e446094cd10d441eb0f081e2a7a1b6aebdb4a91c9edc6720c2a0450a14267",
            "db8f866cea2a7ad2a45490501b904202a533bb2d27ab91a19902f7be6569168b",
            "f4d6cea6a51844c94d0d3f40ad382c2e3e21dec37e3966e36ac15329ae23fa29",
            "0082fee2972a6c65f72508f5ea16b5a4bd560b1cc998d3e3ac2fff0fd2fceccd",
            "7a51b89ce13e139fe63b9251aae358a50495a1ef48bfe4c24c302b12579a406b",
            "1f0523d5c580dc4c41ff939718760a7fe2bd8bae31511db6e2f11aee7f8c2a8f",
            "19bf94f0514f961d391c0a0a4d380610468d831fe870a73c68b75540a26b5ab6",
            "a83cf8a7ba8fcf527357d908e7b1c7f64e3cedd4e41810ce73d290422707a43c",
            "6af1a5d21d5dd38338be4140a736f9e7f3ab9e1e8ad5c15c2fa31973d6891bcb"
        ]
        var index = 0
        for factor: Float in [1, 0.5, 1 / 13.45] {
            for sibling in 0..<5 {
                var request = strengths(0.30 * factor, 0.25 * factor)
                addSibling(sibling, factor: factor, to: &request)
                let result = provider.fieldEmissions(face: .fixture, strengths: request)
                XCTAssertTrue(siblingDigest(result) == expected[index], "frozen sibling vectors")
                index += 1
            }
        }
        XCTAssertEqual(index, expected.count)
    }
}
