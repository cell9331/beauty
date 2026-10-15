import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Independent material truth for shrinking an iris under a shallow lid.
/// The generated sclera has known illumination at each destination position;
/// an angular donor's brightness is not ground truth for newly exposed tissue.
final class BeautyIrisExposedScleraTests: XCTestCase {
    private let width = 640
    private let height = 640
    private let radius = 17.92
    private let centers = [SIMD2<Double>(240, 256), SIMD2<Double>(400, 256)]
    private let capScale = 100.0 / 121.0

    private struct Fixture {
        let face: FaceGeometry
        let polygons: [[SIMD2<Double>]]
        let axes: [SIMD2<Double>]
        let normals: [SIMD2<Double>]
        let source: [UInt8]
    }

    private enum WhiteMaterial: Equatable {
        case affine
        case checkerboard
    }

    private func fixture(shallow: Bool = true,
                         material: WhiteMaterial = .affine,
                         steepNormalGradient: Bool = false) throws -> Fixture {
        let axes = [-0.12, 0.12].map { SIMD2(cos($0), sin($0)) }
        let normals = axes.map { SIMD2(-$0.y, $0.x) }
        let verticalRadius = shallow ? 17.8 : 34.944
        var meshPoints = Array(repeating: SIMD3<Float>(0.5, 0.5, 0), count: 478)
        var supports = [BeautyEyeSemanticSupport]()
        var polygons = [[SIMD2<Double>]]()
        for side in 0..<2 {
            let center = centers[side], axis = axes[side], normal = normals[side]
            func normalized(_ p: SIMD2<Double>) -> SIMD2<Float> {
                SIMD2(Float(p.x / Double(width)), Float(p.y / Double(height)))
            }
            let contour = (0..<32).map { index in
                let angle = Double(index) * 2 * Double.pi / 32
                return normalized(center + axis * (44.8 * cos(angle))
                    + normal * (verticalRadius * sin(angle)))
            }
            let left = normalized(center - axis * 44.8)
            let right = normalized(center + axis * 44.8)
            let inner = side == 0 ? right : left
            let outer = side == 0 ? left : right
            let eye = BeautyEyeSemanticSupport(side: side == 0 ? .left : .right,
                contour: contour,
                upper: contour.filter { p in
                    let delta = SIMD2(Double(p.x) * Double(width), Double(p.y) * Double(height)) - center
                    return dot(delta, normal) < 0
                },
                lower: contour.filter { p in
                    let delta = SIMD2(Double(p.x) * Double(width), Double(p.y) * Double(height)) - center
                    return dot(delta, normal) > 0
                },
                inner: [inner], outer: [outer], corners: [inner, outer],
                center: normalized(center), pupil: normalized(center),
                span: SIMD2(0.14, Float(2 * verticalRadius / Double(height))),
                tilt: Float(side == 0 ? -0.12 : 0.12))
            supports.append(eye)
            polygons.append(contour.map { SIMD2(Double($0.x) * Double(width), Double($0.y) * Double(height)) })
            let indices = side == 0 ? MediaPipeFaceTopology.leftIris : MediaPipeFaceTopology.rightIris
            for (index, landmark) in indices.enumerated() {
                let angle = Double(index) * 2 * Double.pi / 4
                let p = normalized(center + (axis * cos(angle) + normal * sin(angle)) * radius)
                meshPoints[landmark] = SIMD3(p.x, p.y, 0)
            }
            let c = normalized(center)
            meshPoints[side == 0 ? 468 : 473] = SIMD3(c.x, c.y, 0)
        }
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: meshPoints))
        let face = FaceGeometry(bounds: FaceBounds(x: 0.16, y: 0.14, width: 0.68, height: 0.7),
            faceContour: [], leftEye: supports[0].contour, rightEye: supports[1].contour,
            leftEyeSupport: supports[0], rightEyeSupport: supports[1],
            freshness: .fresh, denseSupport: BeautyDenseFaceSupport(mesh: mesh))
        var source = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let side = x < width / 2 ? 0 : 1, offset = (y * width + x) * 4
            var color = SIMD3<Double>(166 + Double(x % 7), 91 + Double(y % 5), 143)
            if inside(p, polygons[side]) {
                let delta = p - centers[side]
                let local = SIMD2(dot(delta, axes[side]), dot(delta, normals[side]))
                var white = whiteField(local, side: side, steepNormalGradient: steepNormalGradient)
                if material == .checkerboard {
                    // A deliberately non-affine white-material negative. No
                    // output-dependent points or fitted model define its truth.
                    let tile = Int(floor(local.x / 3)) + Int(floor(local.y / 3))
                    white += SIMD3(repeating: tile % 2 == 0 ? 20 : -20)
                }
                let iris = SIMD3(43 + 9 * sin(local.x * 0.43),
                    66 + 7 * cos(local.y * 0.37), 81 + 8 * sin((local.x + local.y) * 0.31))
                let coverage = max(0, min(1, radius + 0.5 - hypot(delta.x, delta.y)))
                color = white * (1 - coverage) + iris * coverage
            }
            if edgeDistance(p, polygons[side]) <= 1 {
                // This entire contact strip is known opaque lid/lash material.
                color = SIMD3(25 + Double((x + y) % 2) * 45,
                    51 + Double(x % 3) * 31, 102 + Double(y % 3) * 29)
            }
            for channel in 0..<3 {
                source[offset + channel] = UInt8(min(255, max(0, color[channel].rounded())))
            }
        } }
        return Fixture(face: face, polygons: polygons, axes: axes, normals: normals, source: source)
    }

    /// Opposite illumination gradients in the two eyes rule out a constant
    /// white fill, symmetric left/right averaging and angular brightness reuse.
    private func whiteField(_ local: SIMD2<Double>, side: Int,
                            steepNormalGradient: Bool = false) -> SIMD3<Double> {
        if steepNormalGradient {
            // An independently declared second challenge increases normal
            // illumination contrast. With |u|<=44.8 and |v|<=17.8, every
            // component stays strictly inside 0...255 without clamping.
            if side == 0 {
                return SIMD3(176, 180, 184) + SIMD3(0.4, -0.3, 0.2) * local.x
                    + SIMD3(3, 2.8, 2.6) * local.y
            }
            return SIMD3(174, 180, 186) + SIMD3(-0.35, 0.25, -0.18) * local.x
                + SIMD3(-3.1, -2.7, -2.8) * local.y
        }
        if side == 0 {
            return SIMD3(206, 214, 222) + SIMD3(0.18, -0.22, 0.12) * local.x
                + SIMD3(0.9, 0.7, 0.5) * local.y
        }
        return SIMD3(216, 207, 201) + SIMD3(-0.28, 0.24, -0.18) * local.x
            + SIMD3(-0.8, -0.6, -0.9) * local.y
    }

    private func reportGeneratedAggregate(challenge: String, side: Int, checked: Int,
                                          maximumError: Int, sourceIrisDifference: Int) {
        // Optional test-only aggregate: generated inputs, no pixel arrays,
        // locations, landmarks or private photo material cross this boundary.
        if ProcessInfo.processInfo.environment["BEAUTY_IRIS_GENERATED_AGGREGATE"] == "1" {
            print("IrisExposedSclera challenge=\(challenge) side=\(side) checked=\(checked) maxRGBError=\(maximumError) sourceIrisDifference=\(sourceIrisDifference)")
        }
    }

    private func dot(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double {
        a.x * b.x + a.y * b.y
    }

    private func inside(_ p: SIMD2<Double>, _ polygon: [SIMD2<Double>]) -> Bool {
        var result = false
        for index in polygon.indices {
            let a = polygon[index], b = polygon[(index + 1) % polygon.count]
            if (a.y > p.y) != (b.y > p.y),
               p.x < a.x + (p.y - a.y) * (b.x - a.x) / (b.y - a.y) { result.toggle() }
        }
        return result
    }

    private func edgeDistance(_ p: SIMD2<Double>, _ polygon: [SIMD2<Double>]) -> Double {
        var distance = Double.infinity
        for index in polygon.indices {
            let a = polygon[index], edge = polygon[(index + 1) % polygon.count] - a
            let t = max(0, min(1, dot(p - a, edge) / dot(edge, edge)))
            let delta = p - a - edge * t
            distance = min(distance, hypot(delta.x, delta.y))
        }
        return distance
    }

    private func render(_ fixture: Fixture, fraction: Float,
                        source: [UInt8]? = nil) throws -> BeautyIrisScaleRemap.OwnedRaster {
        let source = source ?? fixture.source
        var strengths = BeautyEffectiveStrengths()
        strengths.pupilSize = BeautySafetyCaps.pupilSize * fraction
        let remap = try XCTUnwrap(BeautyIrisScaleRemap(width: width, height: height,
            face: fixture.face, strengths: strengths, sourceRGBA: source))
        return remap.applyRGBAWithSourceOwner(source)
    }

    private func sampleRGB(_ source: [UInt8], at p: SIMD2<Double>) -> [UInt8] {
        let u = p.x - 0.5, v = p.y - 0.5
        let x = Int(floor(u)), y = Int(floor(v)), fx = u - Double(x), fy = v - Double(y)
        return (0..<3).map { channel in
            func value(_ dx: Int, _ dy: Int) -> Double {
                Double(source[((y + dy) * width + x + dx) * 4 + channel])
            }
            let value = (1 - fy) * ((1 - fx) * value(0, 0) + fx * value(1, 0))
                + fy * ((1 - fx) * value(0, 1) + fx * value(1, 1))
            return UInt8(min(255, max(0, value.rounded())))
        }
    }

    private func assertProtected(_ fixture: Fixture, output: [UInt8], source: [UInt8]? = nil,
                                 file: StaticString = #filePath, line: UInt = #line) {
        let source = source ?? fixture.source
        var protectedCount = 0, mismatch = 0, alphaMismatch = 0
        var farWhiteCount = 0, contactCount = 0
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            let side = x < width / 2 ? 0 : 1, polygon = fixture.polygons[side]
            let delta = p - centers[side], r = hypot(delta.x, delta.y)
            let interior = inside(p, polygon), contact = edgeDistance(p, polygon) <= 1
            // The fixed +/- 30% iris bound plus five full source pixels is
            // conservatively outside transported iris/AA material at either cap.
            let farWhite = interior && r >= 1.3 * radius + 5
            let corner = [polygon[0], polygon[16]].contains {
                hypot((p - $0).x, (p - $0).y) <= 0.08 * 89.6
            }
            if !interior || contact || farWhite || corner {
                protectedCount += 1
                if farWhite { farWhiteCount += 1 }
                if contact { contactCount += 1 }
                for channel in 0..<4 where output[offset + channel] != source[offset + channel] { mismatch += 1 }
            }
            if output[offset + 3] != source[offset + 3] { alphaMismatch += 1 }
        } }
        XCTAssertGreaterThan(protectedCount, width * height / 2, file: file, line: line)
        XCTAssertGreaterThan(farWhiteCount, 0, file: file, line: line)
        XCTAssertGreaterThan(contactCount, 0, file: file, line: line)
        XCTAssertEqual(mismatch, 0, "opening exterior, lid contact, canthi and far sclera stay RGBA exact", file: file, line: line)
        XCTAssertEqual(alphaMismatch, 0, "every source alpha byte", file: file, line: line)
    }

    func testNegativeCapExposedWhiteRetainsDestinationIlluminationWithoutDarkRidge() throws {
        let fixture = try fixture()
        let result = try render(fixture, fraction: -1)
        XCTAssertEqual(result.owner.appliedEyeCount, 2, "a real shrinking effect is required in each qualified eye")
        for side in 0..<2 {
            var checked = 0, sourceIrisDifference = 0, maximumError = 0
            for y in 230..<282 { for x in Int(centers[side].x - radius)..<Int(centers[side].x + radius) {
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), delta = p - centers[side]
                let r = hypot(delta.x, delta.y)
                let local = SIMD2(dot(delta, fixture.axes[side]), dot(delta, fixture.normals[side]))
                // Frozen source geometry selects material exposed by the
                // negative cap, including the shallow upper/lower sectors.
                // The 1.5px gap excludes the one-pixel limbus AA footprint.
                guard r >= capScale * radius + 1.5, r <= radius - 0.5,
                      abs(local.y) >= 14, inside(p, fixture.polygons[side]),
                      edgeDistance(p, fixture.polygons[side]) >= 1.3 else { continue }
                let expected = whiteField(local, side: side), offset = (y * width + x) * 4
                checked += 1
                for channel in 0..<3 {
                    let target = Int(expected[channel].rounded())
                    maximumError = max(maximumError, abs(Int(result.rgba[offset + channel]) - target))
                    sourceIrisDifference += abs(Int(fixture.source[offset + channel]) - target)
                }
            } }
            XCTAssertGreaterThan(checked, 12, "the source-defined exposed ring is nonempty")
            XCTAssertGreaterThan(sourceIrisDifference, checked * 100, "neutral/no-op cannot satisfy the material oracle")
            // Affine truth has only RGBA8 input/output quantization error.
            // A gray or dark donor ridge cannot hide in a mean-error metric.
            XCTAssertLessThanOrEqual(maximumError, 2, "new sclera follows field(p), not the occluded sample or angular donor's illumination")
            reportGeneratedAggregate(challenge: "ordinaryAffine", side: side, checked: checked,
                maximumError: maximumError, sourceIrisDifference: sourceIrisDifference)
        }
        XCTAssertEqual(result.rgba, try render(fixture, fraction: -1).rgba)
        assertProtected(fixture, output: result.rgba)
    }

    func testNegativeCapExposedWhiteRetainsSteepDestinationIllumination() throws {
        // C74 passed the ordinary-gradient challenge above. This separately
        // declared input increases a normal-direction lighting gradient so a
        // wrong angular illumination estimate is distinguishable from RGBA8
        // quantization. The original input and acceptance tolerance stay fixed.
        let fixture = try fixture(steepNormalGradient: true)
        let result = try render(fixture, fraction: -1)
        XCTAssertEqual(result.owner.appliedEyeCount, 2)
        for side in 0..<2 {
            var checked = 0, sourceIrisDifference = 0, maximumError = 0
            for y in 230..<282 { for x in Int(centers[side].x - radius)..<Int(centers[side].x + radius) {
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), delta = p - centers[side]
                let r = hypot(delta.x, delta.y)
                let local = SIMD2(dot(delta, fixture.axes[side]), dot(delta, fixture.normals[side]))
                guard r >= capScale * radius + 1.5, r <= radius - 0.5,
                      abs(local.y) >= 14, inside(p, fixture.polygons[side]),
                      edgeDistance(p, fixture.polygons[side]) >= 1.3 else { continue }
                let expected = whiteField(local, side: side, steepNormalGradient: true)
                let offset = (y * width + x) * 4
                checked += 1
                for channel in 0..<3 {
                    let target = Int(expected[channel].rounded())
                    maximumError = max(maximumError, abs(Int(result.rgba[offset + channel]) - target))
                    sourceIrisDifference += abs(Int(fixture.source[offset + channel]) - target)
                }
            } }
            XCTAssertGreaterThan(checked, 12)
            XCTAssertGreaterThan(sourceIrisDifference, checked * 100)
            XCTAssertLessThanOrEqual(maximumError, 2,
                "newly exposed white must retain the source-defined steep field(p) illumination")
            reportGeneratedAggregate(challenge: "steepAffine", side: side, checked: checked,
                maximumError: maximumError, sourceIrisDifference: sourceIrisDifference)
        }
        XCTAssertEqual(result.rgba, try render(fixture, fraction: -1).rgba)
        assertProtected(fixture, output: result.rgba)
    }

    func testSignedVisibleCoreKeepsUniformInverseScaleAndProtectedRegions() throws {
        let fixture = try fixture(shallow: false)
        let cases: [(Float, Double)] = [(-1, capScale), (1, 100.0 / 79)]
        for (fraction, scale) in cases {
            let result = try render(fixture, fraction: fraction)
            XCTAssertEqual(result.owner.appliedEyeCount, 2)
            for side in 0..<2 {
                var checked = 0, expectedChange = 0, maximumError = 0
                for y in 240..<272 { for x in Int(centers[side].x - 16)..<Int(centers[side].x + 16) {
                    let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), delta = p - centers[side]
                    guard hypot(delta.x, delta.y) <= scale * (radius - 4) else { continue }
                    let expected = sampleRGB(fixture.source, at: centers[side] + delta / scale)
                    let offset = (y * width + x) * 4
                    checked += 1
                    for channel in 0..<3 {
                        maximumError = max(maximumError, abs(Int(result.rgba[offset + channel]) - Int(expected[channel])))
                        expectedChange += abs(Int(fixture.source[offset + channel]) - Int(expected[channel]))
                    }
                } }
                XCTAssertGreaterThan(checked, 100)
                XCTAssertGreaterThan(expectedChange, 0, "a zero-effect render fails the independent texture oracle")
                XCTAssertLessThanOrEqual(maximumError, 1, "legal visible iris uses g=r/s on both coordinates")
            }
            assertProtected(fixture, output: result.rgba)
        }
    }

    func testExcludedRGBAndAlphaCannotChangeWhiteReconstructionOrInteriorAdmission() throws {
        let fixture = try fixture()
        var adversarial = fixture.source, excludedCount = 0
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), side = x < width / 2 ? 0 : 1
            let polygon = fixture.polygons[side]
            let excluded = !inside(p, polygon) || edgeDistance(p, polygon) <= 1
                || [polygon[0], polygon[16]].contains {
                    hypot((p - $0).x, (p - $0).y) <= 0.08 * 89.6
                }
            if excluded {
                let offset = (y * width + x) * 4
                adversarial[offset] = (x + y) % 2 == 0 ? 0 : 255
                adversarial[offset + 1] = x % 3 == 0 ? 255 : 0
                adversarial[offset + 2] = y % 3 == 0 ? 0 : 255
                adversarial[offset + 3] = (x + y) % 2 == 0 ? 0 : 97
                excludedCount += 1
            }
        } }
        XCTAssertGreaterThan(excludedCount, width * height / 2)
        for fraction: Float in [-1, 1] {
            let a = try render(fixture, fraction: fraction)
            let b = try render(fixture, fraction: fraction, source: adversarial)
            XCTAssertEqual(a.owner.appliedEyeCount, 2)
            XCTAssertEqual(b.owner.appliedEyeCount, a.owner.appliedEyeCount,
                "unknown exterior alpha cannot become an admission input")
            var interiorCount = 0, interiorMismatch = 0
            for y in 0..<height { for x in 0..<width {
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), side = x < width / 2 ? 0 : 1
                guard inside(p, fixture.polygons[side]), edgeDistance(p, fixture.polygons[side]) > 2.5,
                      [fixture.polygons[side][0], fixture.polygons[side][16]].allSatisfy({
                          hypot((p - $0).x, (p - $0).y) > 0.08 * 89.6 + 2
                      }) else { continue }
                interiorCount += 1
                let offset = (y * width + x) * 4
                for channel in 0..<4 where a.rgba[offset + channel] != b.rgba[offset + channel] { interiorMismatch += 1 }
            } }
            XCTAssertGreaterThan(interiorCount, 100)
            XCTAssertEqual(interiorMismatch, 0, "all interior material is independent of excluded RGBA")
            assertProtected(fixture, output: a.rgba)
            assertProtected(fixture, output: b.rgba, source: adversarial)
        }
    }

    func testNonAffineWhiteMaterialDoesNotAuthorizeProtectedPixelsOrUnknownAlpha() throws {
        let fixture = try fixture(material: .checkerboard)
        var source = fixture.source
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), side = x < width / 2 ? 0 : 1
            if !inside(p, fixture.polygons[side]) { source[(y * width + x) * 4 + 3] = UInt8((x + 3 * y) % 256) }
        } }
        var neutral = BeautyEffectiveStrengths()
        neutral.pupilSize = 0
        XCTAssertNil(BeautyIrisScaleRemap(width: width, height: height,
            face: fixture.face, strengths: neutral, sourceRGBA: source))
        for fraction: Float in [-1, 1] {
            let a = try render(fixture, fraction: fraction, source: source)
            let b = try render(fixture, fraction: fraction, source: source)
            XCTAssertEqual(a.rgba, b.rgba, "unsupported low-frequency fitting may safely fall back or abstain deterministically")
            XCTAssertEqual(a.owner.appliedEyeCount, b.owner.appliedEyeCount)
            assertProtected(fixture, output: a.rgba, source: source)
        }
    }
}
