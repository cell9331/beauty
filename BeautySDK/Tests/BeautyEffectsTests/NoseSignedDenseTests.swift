import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Code-generated source anatomy/markers. Thresholds are pixel directions and
/// distances, not counts of changed bytes or detector re-detection estimates.
final class NoseSignedDenseTests: XCTestCase {
    private let fields: [(String, WritableKeyPath<BeautyEffectiveStrengths, Float>, Float, SIMD2<Double>, SIMD2<Double>)] = [
        ("size", \.noseSlim, 0.35, SIMD2(0.40, 0.51), SIMD2(0.60, 0.51)),
        ("wing", \.noseWingSlim, 0.35, SIMD2(0.42, 0.63), SIMD2(0.58, 0.63)),
        ("tip", \.noseTipSize, 0.30, SIMD2(0.4648, 0.65), SIMD2(0.5352, 0.65)),
        ("bridge", \.noseBridge, 0.30, SIMD2(0.4616, 0.54), SIMD2(0.5384, 0.54)),
        ("root", \.noseRootNarrowing, 0.25, SIMD2(0.436, 0.395), SIMD2(0.564, 0.395)),
        ("lift", \.noseTipLift, 0.25, SIMD2(0.50, 0.65), SIMD2(0.50, 0.65)),
    ]

    private func face() throws -> FaceGeometry {
        var meshPoints = (0..<478).map { i in SIMD3<Float>(0.18 + Float(i % 23) / 36, 0.1 + Float(i / 23) / 27, 0) }
        meshPoints[1] = SIMD3(0.5, 0.65, 0)
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: meshPoints))
        let contour: [SIMD2<Float>] = [SIMD2(0.4, 0.57), SIMD2(0.42, 0.63), SIMD2(0.5, 0.66), SIMD2(0.58, 0.63), SIMD2(0.6, 0.57)]
        let crest = [0.36, 0.405, 0.45, 0.50, 0.55, 0.60, 0.65].map { CoordinatePoint(x: 0.5, y: $0) }
        return FaceGeometry(bounds: FaceBounds(x: 0.18, y: 0.1, width: 0.64, height: 0.8), faceContour: [],
            nose: contour, noseTip: [SIMD2(0.42, 0.63), SIMD2(0.5, 0.65), SIMD2(0.58, 0.63)],
            observedNoseSupport: BeautyObservedNoseSupport(crest: crest,
                contour: contour.map { CoordinatePoint(x: Double($0.x), y: Double($0.y)) }),
            denseSupport: BeautyDenseFaceSupport(mesh: mesh))
    }

    private func raster(width: Int, height: Int, markers: [SIMD2<Double>]) -> [UInt8] {
        var bytes = [UInt8](repeating: 173, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let index = (y * width + x) * 4
            let distance = markers.map { p in pow(Double(x) + 0.5 - p.x * Double(width), 2) + pow(Double(y) + 0.5 - p.y * Double(height), 2) }.min()!
            bytes[index] = UInt8((128 - 110 * exp(-distance / 12)).rounded())
            bytes[index + 1] = UInt8(x * 100 / width)
            bytes[index + 2] = UInt8(y * 100 / height)
        } }
        return bytes
    }

    private func metric(_ bytes: [UInt8], width: Int, height: Int, lift: Bool) -> Double {
        var totals = [Double](repeating: 0, count: 2), sums = totals
        for y in 0..<height { for x in 0..<width {
            let weight = Double(max(0, 128 - Int(bytes[(y * width + x) * 4])))
            let side = lift ? 0 : (x < width / 2 ? 0 : 1)
            totals[side] += weight
            sums[side] += weight * Double(lift ? y : x)
        } }
        return lift ? sums[0] / totals[0] : sums[1] / totals[1] - sums[0] / totals[0]
    }

    func testSixFieldsHaveOppositeMonotoneVisiblePixelDirectionsAndProtectedExterior() throws {
        let anatomy = try face()
        XCTAssertTrue(NoseWarpProvider().fieldEmissions(face: anatomy, strengths: BeautyEffectiveStrengths()).points.isEmpty)
        for (width, height) in [(480, 640), (640, 480)] {
            for (name, key, cap, left, right) in fields {
                let source = raster(width: width, height: height, markers: name == "lift" ? [left] : [left, right])
                let baseline = metric(source, width: width, height: height, lift: name == "lift")
                // A no-op cannot satisfy the fixed direction/amplitude oracle.
                XCTAssertFalse(baseline - baseline < -0.15)
                for sign: Float in [-1, 1] {
                    var previous = 0.0
                    for fraction: Float in [0.25, 0.50, 0.75, 1] {
                        var strengths = BeautyEffectiveStrengths(); strengths[keyPath: key] = sign * cap * fraction
                        let points = NoseWarpProvider().fieldEmissions(face: anatomy, strengths: strengths).points
                        let map = try XCTUnwrap(BeautyDenseGeometryMap(width: width, height: height, face: anatomy, points: points), name)
                        let output = map.applyRGBA(source)
                        let change = metric(output, width: width, height: height, lift: name == "lift") - baseline
                        let amplitude = -change * Double(sign)
                        XCTAssertGreaterThan(amplitude, 0.15, "\(name) signed direction at \(fraction)")
                        XCTAssertGreaterThan(amplitude, previous + 0.04, "\(name) monotonic amplitude")
                        XCTAssertFalse(change * Double(sign) > 0.15, "Opposite-direction output must fail the oracle")
                        if fraction == 1 { XCTAssertGreaterThan(amplitude, 1, "\(name) visible endpoint in pixels") }
                        previous = amplitude
                        XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                        XCTAssertEqual(output, map.applyRGBA(source), "determinism")
                        XCTAssertEqual(output.count, width * height * 4)
                        XCTAssertTrue(stride(from: 3, to: output.count, by: 4).allSatisfy { output[$0] == 173 })
                        for y in 0..<height { for x in 0..<width where Double(x) / Double(width) < 0.22 || Double(x) / Double(width) > 0.78 || Double(y) / Double(height) < 0.24 || Double(y) / Double(height) > 0.84 {
                            let i = (y * width + x) * 4
                            XCTAssertEqual(output[i], source[i]); XCTAssertEqual(output[i+1], source[i+1]); XCTAssertEqual(output[i+2], source[i+2])
                        } }
                    }
                }
            }
        }
    }

    func testBothRootDirectionsPreserveCompleteEyeBoxesAndLipBandPixels() throws {
        let base = try face()
        func eye(_ x: Float) -> BeautyEyeSemanticSupport {
            BeautyEyeSemanticSupport(side: x < 0.5 ? .left : .right,
                contour: [SIMD2(x, 0.35), SIMD2(x + 0.14, 0.35), SIMD2(x + 0.14, 0.41), SIMD2(x, 0.41)],
                upper: [], lower: [], inner: [], outer: [], corners: [], center: SIMD2(x + 0.07, 0.38),
                pupil: nil, span: SIMD2(0.14, 0.06), tilt: 0)
        }
        let anatomy = FaceGeometry(bounds: base.bounds, faceContour: [], nose: base.nose, noseTip: base.noseTip,
            leftEyeSupport: eye(0.29), rightEyeSupport: eye(0.57), observedNoseSupport: base.observedNoseSupport,
            denseSupport: base.denseSupport)
        for sign: Float in [-1, 1] {
            var strengths = BeautyEffectiveStrengths(); strengths.noseRootNarrowing = sign * 0.25
            let points = NoseWarpProvider().fieldEmissions(face: anatomy, strengths: strengths).points
            XCTAssertFalse(points.isEmpty)
            let width = 480, height = 640
            let source = raster(width: width, height: height, markers: [SIMD2(0.4744, 0.38), SIMD2(0.5256, 0.38)])
            let map = try XCTUnwrap(BeautyDenseGeometryMap(width: width, height: height, face: anatomy, points: points))
            let output = map.applyRGBA(source)
            XCTAssertNotEqual(source, output)
            for (minX, maxX, minY, maxY) in [(0.29, 0.43, 0.35, 0.41), (0.57, 0.71, 0.35, 0.41), (0.43, 0.57, 0.74, 0.80)] {
                for y in Int(minY * Double(height))...Int(maxY * Double(height)) {
                    for x in Int(minX * Double(width))...Int(maxX * Double(width)) {
                        let i = (y * width + x) * 4
                        XCTAssertEqual(Array(output[i..<(i+4)]), Array(source[i..<(i+4)]))
                    }
                }
            }
        }
    }

    func testInactiveNoseDoesNotAlterSiblingLatticeOrPixels() throws {
        let complete = try face()
        let sibling = FaceGeometry(bounds: complete.bounds, faceContour: [], denseSupport: complete.denseSupport)
        let point = WarpControlPoint(source: SIMD2(0.31, 0.30), target: SIMD2(0.32, 0.30), radius: 0.06, strength: 0.2, falloff: 2)
        let map = try XCTUnwrap(BeautyDenseGeometryMap(width: 193, height: 127, face: complete, points: [point]))
        let reference = try XCTUnwrap(BeautyDenseGeometryMap(width: 193, height: 127, face: sibling, points: [point]))
        XCTAssertEqual(map.xs, reference.xs); XCTAssertEqual(map.ys, reference.ys)
        let source = raster(width: 193, height: 127, markers: [SIMD2(0.31, 0.30)])
        XCTAssertEqual(map.applyRGBA(source), reference.applyRGBA(source))
    }

    func testSignedDenseMissingAnatomyAbstainsAndTinySupportSurvivesKnots() throws {
        let complete = try face()
        let missing = FaceGeometry(bounds: complete.bounds, faceContour: [], denseSupport: complete.denseSupport)
        for (_, key, cap, _, _) in fields {
            var s = BeautyEffectiveStrengths(); s[keyPath: key] = -cap
            XCTAssertTrue(NoseWarpProvider().fieldEmissions(face: missing, strengths: s).points.isEmpty)
        }
        var point = WarpControlPoint(source: SIMD2(0.493, 0.397), target: SIMD2(0.495, 0.397), radius: 0.003, strength: 0.25, falloff: 1)
        point.samplingCenter = point.source
        let map = try XCTUnwrap(BeautyDenseGeometryMap(width: 480, height: 640, face: complete, points: [point]))
        XCTAssertTrue(map.xs.contains(Double(point.source.x)))
        XCTAssertTrue(map.ys.contains(Double(point.source.y)))
        XCTAssertGreaterThan(map.displacement(at: SIMD2(Double(point.source.x), Double(point.source.y))).x, 0)
        XCTAssertLessThanOrEqual(map.xs.count, 124); XCTAssertLessThanOrEqual(map.ys.count, 188)
    }
}
