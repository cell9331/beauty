import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

final class BeautyIrisScaleRemapTests: XCTestCase {
    private let width = 640
    private let height = 640
    private let radius = 17.92
    private let centers = [SIMD2<Double>(240, 256), SIMD2<Double>(400, 256)]

    // Fixed signed response from the pupil-size contract, rather than a radius
    // fitted to the candidate's output. The frontal fixture has pose gain one.
    private let steps: [(Float, Double)] = [
        (-0.25, 400.0 / 421), (-0.5, 200.0 / 221),
        (-0.75, 400.0 / 463), (-1, 100.0 / 121),
        (0.25, 400.0 / 379), (0.5, 200.0 / 179),
        (0.75, 400.0 / 337), (1, 100.0 / 79),
    ]

    private struct Fixture {
        let face: FaceGeometry
        let polygons: [[SIMD2<Double>]]
        let source: [UInt8]
        let lidPixels: Set<Int>
    }

    private func fixture(upperScale: Float = 1, closed: Bool = false,
                         collapsedLeft: Bool = false, dense: Bool = true,
                         freshness: LandmarkGeometryFreshness = .fresh,
                         transformation: [Float]? = nil,
                         irisRadiusFactor: Float = 1,
                         modelCenterOffsetPixels: SIMD2<Float> = .zero,
                         modelRadiusFactor: Float = 1) throws -> Fixture {
        let radius = self.radius * Double(irisRadiusFactor)
        let modelOffset = modelCenterOffsetPixels / SIMD2(Float(width), Float(height))
        func contour(_ x: Float) -> [SIMD2<Float>] {
            (0..<16).map { index in
                let angle = Float(index) * 2 * Float.pi / 16
                let vertical = sin(angle)
                let aperture: Float = closed ? 0.002 : 0.07 * 0.78
                return SIMD2(x + 0.07 * cos(angle),
                    0.4 + aperture * vertical * (vertical < 0 ? upperScale : 1))
            }
        }
        func eye(_ x: Float, _ side: BeautyObservedEyeSide) -> BeautyEyeSemanticSupport {
            let points = contour(x)
            let inner = SIMD2<Float>(x + (side == .left ? 0.07 : -0.07), 0.4)
            let outer = SIMD2<Float>(x + (side == .left ? -0.07 : 0.07), 0.4)
            return BeautyEyeSemanticSupport(side: side, contour: points,
                upper: points.filter { $0.y < 0.4 }, lower: points.filter { $0.y > 0.4 },
                inner: [inner], outer: [outer], corners: [inner, outer],
                center: SIMD2(x, 0.4), pupil: SIMD2(x, 0.4) + modelOffset,
                span: SIMD2(0.14, 0.07 * 0.78 * 2), tilt: 0)
        }
        let left = eye(0.375, .left), right = eye(0.625, .right)
        var points = Array(repeating: SIMD3<Float>(0.5, 0.5, 0), count: 478)
        for (indices, x) in [(MediaPipeFaceTopology.leftIris, Float(0.375)),
                              (MediaPipeFaceTopology.rightIris, Float(0.625))] {
            let ringRadius: Float = collapsedLeft && x < 0.5 ? 0 : 0.028 * irisRadiusFactor * modelRadiusFactor
            for (index, landmark) in indices.enumerated() {
                let angle = Float(index) * 2 * Float.pi / 4
                points[landmark] = SIMD3(x + modelOffset.x + ringRadius * cos(angle),
                    0.4 + modelOffset.y + ringRadius * sin(angle), 0)
            }
        }
        points[468] = SIMD3(0.375 + modelOffset.x, 0.4 + modelOffset.y, 0)
        points[473] = SIMD3(0.625 + modelOffset.x, 0.4 + modelOffset.y, 0)
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points, facialTransformation: transformation))
        let face = FaceGeometry(bounds: FaceBounds(x: 0.16, y: 0.14, width: 0.68, height: 0.7),
            faceContour: [], leftEye: left.contour, rightEye: right.contour,
            leftEyeSupport: left, rightEyeSupport: right, freshness: freshness,
            denseSupport: dense ? BeautyDenseFaceSupport(mesh: mesh) : nil)
        let polygons = [left.contour, right.contour].map { polygon in
            polygon.map { SIMD2(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
        }
        var source = [UInt8](repeating: 255, count: width * height * 4)
        var lidPixels = Set<Int>()
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let side = x < width / 2 ? 0 : 1, polygon = polygons[side]
            let offset = (y * width + x) * 4
            var color = SIMD3<Double>(166 + Double(x % 7), 91 + Double(y % 5), 143)
            if inside(p, polygon) {
                let v = p - centers[side], r = hypot(v.x, v.y)
                // An analytic circular iris with a one-pixel antialias band.
                // Red measures only its boundary; G/B carry independent X/Y
                // landmarks and a single localized highlight.
                let coverage = max(0, min(1, radius + 0.5 - r))
                func spot(_ dx: Double, _ dy: Double, sigma: Double = 1.2) -> Double {
                    let q = v - SIMD2(dx, dy)
                    return exp(-(q.x * q.x + q.y * q.y) / (2 * sigma * sigma))
                }
                let green = 130 - 100 * (spot(-0.45 * radius, 0) + spot(0.45 * radius, 0))
                let blue = 130 - 100 * (spot(0, -0.45 * radius) + spot(0, 0.45 * radius))
                let highlight = 125 * spot(-0.35 * radius, 0.3 * radius, sigma: 1.8)
                color = SIMD3(200 - 160 * coverage,
                    220 + coverage * (min(255, green + highlight) - 220),
                    220 + coverage * (min(255, blue + highlight) - 220))
            }
            if edgeDistance(p, polygon) <= 1 {
                // Known opaque lid/lash material, including the inner pixel
                // strip. Spatial variation detects even subpixel resampling.
                color = SIMD3(25 + Double((x + y) % 2) * 45,
                    51 + Double(x % 3) * 31, 102 + Double(y % 3) * 29)
                lidPixels.insert(offset)
            }
            for channel in 0..<3 { source[offset + channel] = UInt8(color[channel].rounded()) }
        } }
        return Fixture(face: face, polygons: polygons, source: source, lidPixels: lidPixels)
    }

    // Test-owned polygon and bilinear measurement helpers deliberately do not
    // call production contains/mask/sampler implementations.
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
            let a = polygon[index], b = polygon[(index + 1) % polygon.count], e = b - a
            let q = p - a
            let t = max(0, min(1, (q.x * e.x + q.y * e.y) / (e.x * e.x + e.y * e.y)))
            let v = p - a - e * t
            distance = min(distance, hypot(v.x, v.y))
        }
        return distance
    }

    private func strengths(_ fraction: Float) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.pupilSize = BeautySafetyCaps.pupilSize * fraction
        return strengths
    }

    private func render(_ fixture: Fixture, fraction: Float, source: [UInt8]? = nil) throws -> [UInt8] {
        let source = source ?? fixture.source
        let remap = try XCTUnwrap(BeautyIrisScaleRemap(width: width, height: height,
            face: fixture.face, strengths: strengths(fraction), sourceRGBA: source),
            "an admitted source must have a real remap at signed fraction \(fraction)")
        return remap.applyRGBA(source)
    }

    private func red(_ source: [UInt8], at p: SIMD2<Double>) -> Double {
        let x = p.x - 0.5, y = p.y - 0.5
        let x0 = Int(floor(x)), y0 = Int(floor(y)), tx = x - Double(x0), ty = y - Double(y0)
        func value(_ dx: Int, _ dy: Int) -> Double { Double(source[((y0 + dy) * width + x0 + dx) * 4]) }
        return (1 - ty) * ((1 - tx) * value(0, 0) + tx * value(1, 0))
            + ty * ((1 - tx) * value(0, 1) + tx * value(1, 1))
    }

    private func sampledRGB(_ source: [UInt8], at p: SIMD2<Double>) -> [UInt8] {
        let x = p.x - 0.5, y = p.y - 0.5
        let x0 = Int(floor(x)), y0 = Int(floor(y)), tx = x - Double(x0), ty = y - Double(y0)
        return (0..<3).map { channel in
            func value(_ dx: Int, _ dy: Int) -> Double {
                Double(source[((y0 + dy) * width + x0 + dx) * 4 + channel])
            }
            let blended = (1 - ty) * ((1 - tx) * value(0, 0) + tx * value(1, 0))
                + ty * ((1 - tx) * value(0, 1) + tx * value(1, 1))
            return UInt8(blended.rounded())
        }
    }

    private func crossing(_ source: [UInt8], side: Int, angle: Double,
                          threshold: Double = 120, scanRadius: Double) throws -> Double {
        let direction = SIMD2(cos(angle), sin(angle))
        var previous = red(source, at: centers[side]) - threshold
        var crossings = [Double]()
        var r = 0.25
        while r <= scanRadius {
            let value = red(source, at: centers[side] + direction * r) - threshold
            if (previous < 0 && value >= 0) || (previous >= 0 && value < 0) {
                crossings.append(r - 0.25 + 0.25 * previous / (previous - value))
            }
            previous = value
            r += 0.25
        }
        XCTAssertEqual(crossings.count, 1, "one visible limbus, with no old-radius ghost or repeated edge")
        return try XCTUnwrap(crossings.first)
    }

    private func marker(_ source: [UInt8], side: Int, axis: Int, sign: Double) throws -> SIMD2<Double> {
        let center = centers[side]
        var mass = 0.0, moment = SIMD2<Double>.zero
        // The source fixes each ROI before rendering. These boxes contain the
        // full +/- cap landmark, remain well inside the visible iris, and never
        // follow an output-selected threshold or destination mask.
        for y in Int(center.y - radius)..<Int(center.y + radius) {
            for x in Int(center.x - radius)..<Int(center.x + radius) {
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), v = p - center
                let along = axis == 0 ? v.x : v.y, across = axis == 0 ? v.y : v.x
                if along * sign >= radius * 0.18 && along * sign <= radius * 0.9
                    && abs(across) <= radius * 0.25 {
                    let weight = Double(max(0, 130 - Int(source[(y * width + x) * 4 + axis + 1])))
                    mass += weight
                    moment += p * weight
                }
            }
        }
        XCTAssertGreaterThan(mass, 0, "the known source texture landmark must remain visible")
        return moment / mass
    }

    private func rgbChange(_ source: [UInt8], _ output: [UInt8], side: Int) -> Int {
        var total = 0
        let center = centers[side]
        for y in Int(center.y - radius / 2)..<Int(center.y + radius / 2) {
            for x in Int(center.x - radius / 2)..<Int(center.x + radius / 2) {
                let offset = (y * width + x) * 4
                for channel in 0..<3 { total += abs(Int(source[offset + channel]) - Int(output[offset + channel])) }
            }
        }
        return total
    }

    private func assertProtected(_ fixture: Fixture, _ output: [UInt8], scale: Double,
                                 source: [UInt8]? = nil, file: StaticString = #filePath,
                                 line: UInt = #line) {
        let source = source ?? fixture.source
        var exteriorDelta = 0, lidDelta = 0, alphaDelta = 0, protectedCount = 0
        let windowRadius = (scale + 1) * radius
        for y in 0..<height { for x in 0..<width {
            let offset = (y * width + x) * 4, p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let owned = fixture.polygons.indices.contains { side in
                let v = p - centers[side]
                return inside(p, fixture.polygons[side]) && hypot(v.x, v.y) < windowRadius
            }
            if !owned {
                protectedCount += 1
                for channel in 0..<4 { exteriorDelta += abs(Int(source[offset + channel]) - Int(output[offset + channel])) }
            }
            if fixture.lidPixels.contains(offset) {
                for channel in 0..<4 { lidDelta += abs(Int(source[offset + channel]) - Int(output[offset + channel])) }
            }
            alphaDelta += abs(Int(source[offset + 3]) - Int(output[offset + 3]))
        } }
        XCTAssertGreaterThan(protectedCount, width * height / 2, file: file, line: line)
        XCTAssertGreaterThan(fixture.lidPixels.count, 0, file: file, line: line)
        XCTAssertEqual(exteriorDelta, 0, "whole window/aperture exterior RGBA", file: file, line: line)
        XCTAssertEqual(lidDelta, 0, "known source lid, lash and corner pixels", file: file, line: line)
        XCTAssertEqual(alphaDelta, 0, "every source alpha byte", file: file, line: line)
    }

    private func highlightComponents(_ source: [UInt8], polygon: [SIMD2<Double>]) -> Int {
        var pixels = Set<Int>()
        for y in 0..<height { for x in 0..<width {
            let i = y * width + x, offset = i * 4
            if source[offset + 1] > 230 && source[offset + 2] > 230
                && inside(SIMD2(Double(x) + 0.5, Double(y) + 0.5), polygon) { pixels.insert(i) }
        } }
        var count = 0
        while let start = pixels.first {
            count += 1
            var queue = [start]
            pixels.remove(start)
            while let i = queue.popLast() {
                for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                    let x = i % width + dx, y = i / width + dy
                    if x >= 0 && x < width && y >= 0 && y < height,
                       pixels.remove(y * width + x) != nil { queue.append(y * width + x) }
                } }
            }
        }
        return count
    }

    func testSignedInverseRadiusIsMonotoneAndC1AtBothBandEndpoints() throws {
        for (_, scale) in steps + [(0, 1)] {
            let irisEdge = scale * radius, windowEdge = (scale + 1) * radius
            func g(_ r: Double) throws -> Double {
                try XCTUnwrap(BeautyIrisScaleRemap.inverseRadius(r, sourceRadius: radius, scale: scale))
            }
            XCTAssertEqual(try g(0), 0)
            XCTAssertEqual(try g(irisEdge), radius, accuracy: 1e-10)
            XCTAssertEqual(try g(windowEdge), windowEdge, accuracy: 1e-10)
            XCTAssertEqual(try g(windowEdge + 3), windowEdge + 3)
            let h = radius * 0.0001
            let innerLeft = (try g(irisEdge) - g(irisEdge - h)) / h
            let innerRight = (try g(irisEdge + h) - g(irisEdge)) / h
            let outerLeft = (try g(windowEdge) - g(windowEdge - h)) / h
            let outerRight = (try g(windowEdge + h) - g(windowEdge)) / h
            XCTAssertEqual(innerLeft, 1 / scale, accuracy: 0.001)
            XCTAssertEqual(innerRight, 1 / scale, accuracy: 0.001)
            XCTAssertEqual(outerLeft, 1, accuracy: 0.001)
            XCTAssertEqual(outerRight, 1, accuracy: 0.001)
            var previous = try g(0)
            for index in 1...256 {
                let r = windowEdge * Double(index) / 256, value = try g(r)
                XCTAssertGreaterThan(value, previous, "signed inverse radius must not fold")
                if scale == 1 { XCTAssertEqual(value, r, "neutral scalar remap is identity") }
                previous = value
            }
        }
        for scale in [0.0, -1, Double.nan, Double.infinity] {
            XCTAssertNil(BeautyIrisScaleRemap.inverseRadius(5, sourceRadius: radius, scale: scale))
        }
    }

    func testFullVisibleIrisHasFourSignedUniformRoundStepsWithoutCenterShiftOrGhost() throws {
        let fixture = try fixture()
        let angles = (0..<8).map { Double($0) * Double.pi / 4 }
        for sign: Float in [-1, 1] {
            var previous = [Double](repeating: 0, count: 2)
            for (fraction, scale) in steps where fraction * sign > 0 {
                let output = try render(fixture, fraction: fraction)
                for side in 0..<2 {
                    var radii = [Double]()
                    for angle in angles {
                        let measured = try crossing(output, side: side, angle: angle, scanRadius: scale * radius + 3)
                        // One-pixel source AA, a bilinear footprint and .25px
                        // radial probes bound this boundary measurement error.
                        XCTAssertEqual(measured, scale * radius, accuracy: 0.75)
                        radii.append(measured)
                        let inner = try crossing(output, side: side, angle: angle, threshold: 80,
                            scanRadius: scale * radius + 3)
                        let outer = try crossing(output, side: side, angle: angle, threshold: 160,
                            scanRadius: scale * radius + 3)
                        XCTAssertGreaterThan(outer, inner)
                        XCTAssertLessThan(outer - inner, 2.1, "one AA limbus instead of a strength-blended double edge")
                    }
                    XCTAssertLessThan(try XCTUnwrap(radii.max()) - XCTUnwrap(radii.min()), 1)
                    let mean = radii.reduce(0, +) / Double(radii.count)
                    let sourceMean = try angles.map {
                        try crossing(fixture.source, side: side, angle: $0, scanRadius: radius + 3)
                    }.reduce(0, +) / Double(angles.count)
                    let amplitude = (mean - sourceMean) * Double(sign)
                    XCTAssertGreaterThan(amplitude, previous[side] + 0.15, "every signed quarter has an actual radius step")
                    previous[side] = amplitude
                    var measuredScales = [Double]()
                    for axis in 0..<2 {
                        let a = try marker(output, side: side, axis: axis, sign: -1)
                        let b = try marker(output, side: side, axis: axis, sign: 1)
                        let sa = try marker(fixture.source, side: side, axis: axis, sign: -1)
                        let sb = try marker(fixture.source, side: side, axis: axis, sign: 1)
                        for (actual, original) in [(a, sa), (b, sb)] {
                            let expected = centers[side] + (original - centers[side]) * scale
                            XCTAssertEqual(actual.x, expected.x, accuracy: 0.3)
                            XCTAssertEqual(actual.y, expected.y, accuracy: 0.3)
                        }
                        let midpoint = (a + b) / 2
                        XCTAssertEqual(midpoint.x, centers[side].x, accuracy: 0.3)
                        XCTAssertEqual(midpoint.y, centers[side].y, accuracy: 0.3)
                        measuredScales.append((axis == 0 ? b.x - a.x : b.y - a.y)
                            / (axis == 0 ? sb.x - sa.x : sb.y - sa.y))
                    }
                    XCTAssertEqual(measuredScales[0], measuredScales[1], accuracy: 0.035,
                        "X/Y texture landmarks must have the same scale")
                    XCTAssertGreaterThan(rgbChange(fixture.source, output, side: side), 0)
                }
                if abs(fraction) == 1 { XCTAssertEqual(output, try render(fixture, fraction: fraction)) }
            }
            XCTAssertGreaterThan(previous[0], 2.5)
            XCTAssertGreaterThan(previous[1], 2.5)
        }
    }

    func testShallowUpperLidOccludesRoundSignedIrisWithoutProjectionOrRepeatedHighlight() throws {
        let fixture = try fixture(upperScale: 0.45)
        let visibleAngles = [0.0, Double.pi / 4, Double.pi / 2, 3 * Double.pi / 4, Double.pi]
        for side in 0..<2 { XCTAssertEqual(highlightComponents(fixture.source, polygon: fixture.polygons[side]), 1) }
        for (fraction, scale) in steps {
            let output = try render(fixture, fraction: fraction)
            for side in 0..<2 {
                for angle in visibleAngles {
                    XCTAssertEqual(try crossing(output, side: side, angle: angle, scanRadius: scale * radius + 3),
                        scale * radius, accuracy: 0.75, "source-defined visible side/lower arcs stay circular")
                }
                XCTAssertGreaterThan(rgbChange(fixture.source, output, side: side), 0,
                    "shallow negative must not pass by abstaining from every iris pixel")
                XCTAssertEqual(highlightComponents(output, polygon: fixture.polygons[side]), 1,
                    "occluded-sector estimates must not repeat the single source highlight")
                if fraction < 0 {
                    // On the fully visible lower ray, the old radius now lies
                    // in exposed sclera. It must not keep a ghost old limbus or
                    // borrow the dark lid material from the occluded upper ray.
                    XCTAssertGreaterThan(red(output, at: centers[side] + SIMD2(0, radius + 0.75)), 190)
                }
            }
            assertProtected(fixture, output, scale: scale)
        }
    }

    func testLegalVisibleIrisTextureUsesTheSameUniformInverseScaleOnBothAxes() throws {
        let fixture = try fixture(upperScale: 0.45)
        for (fraction, scale) in steps {
            let output = try render(fixture, fraction: fraction)
            for side in 0..<2 {
                var checked = 0, expectedChange = 0, maximumError = 0
                let center = centers[side]
                for y in Int(center.y - radius * 1.3)..<Int(center.y + radius * 1.3) {
                    for x in Int(center.x - radius * 1.3)..<Int(center.x + radius * 1.3) {
                        let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                        let v = p - center
                        // Independent source material truth: the visible core
                        // is a scaled copy about c, irrespective of the outer
                        // Hermite band or an occluded-sector donor estimate.
                        let q = center + v / scale
                        if hypot(v.x, v.y) > scale * (radius - 2)
                            || !inside(p, fixture.polygons[side])
                            || edgeDistance(p, fixture.polygons[side]) <= 2.5 { continue }
                        let x0 = floor(q.x - 0.5), y0 = floor(q.y - 0.5)
                        let footprint = [SIMD2(x0 + 0.5, y0 + 0.5), SIMD2(x0 + 1.5, y0 + 0.5),
                                         SIMD2(x0 + 0.5, y0 + 1.5), SIMD2(x0 + 1.5, y0 + 1.5)]
                        if !footprint.allSatisfy({ inside($0, fixture.polygons[side])
                            && edgeDistance($0, fixture.polygons[side]) > 1 }) { continue }
                        let expected = sampledRGB(fixture.source, at: q), offset = (y * width + x) * 4
                        checked += 1
                        for channel in 0..<3 {
                            maximumError = max(maximumError, abs(Int(output[offset + channel]) - Int(expected[channel])))
                            expectedChange += abs(Int(fixture.source[offset + channel]) - Int(expected[channel]))
                        }
                    }
                }
                XCTAssertGreaterThan(checked, 100, "a nonempty legal visible core must exercise both axes")
                XCTAssertGreaterThan(expectedChange, 0, "the texture oracle rejects a zero-effect candidate")
                // Float detector coordinates differ from analytic c/R by only
                // a few millionths of a pixel; one RGBA8 quantization unit is
                // enough allowance without admitting a one-axis projection.
                XCTAssertLessThanOrEqual(maximumError, 1)
            }
        }
    }

    func testWholeWindowApertureLidAndAlphaRemainSourceExactAtEverySignedQuarter() throws {
        let fixture = try fixture()
        var source = fixture.source
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            if !fixture.polygons.contains(where: { inside(p, $0) }) {
                source[(y * width + x) * 4 + 3] = UInt8((x + 3 * y) % 256)
            }
        } }
        for (fraction, scale) in steps {
            let output = try render(fixture, fraction: fraction, source: source)
            assertProtected(fixture, output, scale: scale, source: source)
            for side in 0..<2 { XCTAssertGreaterThan(rgbChange(source, output, side: side), 0) }
        }
    }

    func testUnknownSourceFootprintExteriorRGBAndAlphaCannotInfluenceOwnedOutput() throws {
        let fixture = try fixture(upperScale: 0.45)
        var changed = fixture.source, changedExterior = 0, interiorCount = 0
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            if fixture.polygons.contains(where: { inside(p, $0) }) {
                interiorCount += 1
            } else {
                changed[offset] = (x + y) % 2 == 0 ? 0 : 255
                changed[offset + 1] = x % 3 == 0 ? 255 : 0
                changed[offset + 2] = y % 3 == 0 ? 0 : 255
                changed[offset + 3] = (x + y) % 2 == 0 ? 0 : 97
                changedExterior += 1
            }
        } }
        XCTAssertGreaterThan(interiorCount, 0)
        XCTAssertGreaterThan(changedExterior, 0)
        XCTAssertNotEqual(changed, fixture.source)
        for (fraction, scale) in steps {
            // Both preflight and rendering receive their own immutable source;
            // exterior alpha must not change admission for interior ownership.
            let a = try render(fixture, fraction: fraction)
            let b = try render(fixture, fraction: fraction, source: changed)
            var interiorDelta = [Int](repeating: 0, count: 2)
            for y in 0..<height { for x in 0..<width {
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
                for side in 0..<2 where inside(p, fixture.polygons[side]) {
                    for channel in 0..<4 { interiorDelta[side] += abs(Int(a[offset + channel]) - Int(b[offset + channel])) }
                }
            } }
            XCTAssertEqual(interiorDelta, [0, 0], "every four-point donor stencil belongs to the same source opening")
            assertProtected(fixture, a, scale: scale)
            assertProtected(fixture, b, scale: scale, source: changed)
            for side in 0..<2 {
                XCTAssertGreaterThan(rgbChange(fixture.source, a, side: side), 0)
                XCTAssertGreaterThan(rgbChange(changed, b, side: side), 0)
            }
        }
    }

    func testKnownInnerLidRimRGBAndAlphaCannotSupplyIrisOrDisableItsInterior() throws {
        let fixture = try fixture(upperScale: 0.45)
        var changed = fixture.source
        var rimCount = [Int](repeating: 0, count: 2)
        var interiorOffsets = [[Int]](repeating: [], count: 2)
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let offset = (y * width + x) * 4
            for side in 0..<2 where inside(p, fixture.polygons[side]) {
                let clearance = edgeDistance(p, fixture.polygons[side])
                // The fixture independently defines this inner strip as
                // opaque lid/lash material, despite raw polygon containment.
                if clearance <= 1 {
                    changed[offset] = (x + y) % 2 == 0 ? 255 : 0
                    changed[offset + 1] = x % 3 == 0 ? 0 : 255
                    changed[offset + 2] = y % 3 == 0 ? 255 : 0
                    changed[offset + 3] = (x + y) % 2 == 0 ? 0 : 97
                    rimCount[side] += 1
                } else if clearance > 2.5 {
                    interiorOffsets[side].append(offset)
                }
            }
        } }
        XCTAssertTrue(rimCount.allSatisfy { $0 > 0 })
        XCTAssertTrue(interiorOffsets.allSatisfy { !$0.isEmpty })
        XCTAssertNotEqual(changed, fixture.source)
        for fraction: Float in [-1, 1] {
            let a = try render(fixture, fraction: fraction)
            let b = try render(fixture, fraction: fraction, source: changed)
            for side in 0..<2 {
                var mismatch = 0, effect = 0
                for offset in interiorOffsets[side] {
                    for channel in 0..<4 {
                        mismatch += abs(Int(a[offset + channel]) - Int(b[offset + channel]))
                    }
                    for channel in 0..<3 {
                        effect += abs(Int(a[offset + channel]) - Int(fixture.source[offset + channel]))
                    }
                }
                XCTAssertEqual(mismatch, 0, "known inner lid RGBA is outside source ownership")
                XCTAssertGreaterThan(effect, 0, "rim exclusion must preserve a real signed iris edit")
            }
        }
    }

    func testUnknownCanthusRGBAndAlphaCannotInfluenceSafeInteriorOrDisableSignedIris() throws {
        // A larger, still-admitted source iris makes both signed windows meet
        // the canthus collar. The existing fixtures retain their exact radius.
        let irisRadiusFactor: Float = 1.2
        let fixture = try fixture(upperScale: 0.45, irisRadiusFactor: irisRadiusFactor)
        let sourceRadius = radius * Double(irisRadiusFactor)
        let corners = fixture.polygons.map { [$0[0], $0[8]] }
        let collarRadii = corners.map {
            0.08 * hypot($0[0].x - $0[1].x, $0[0].y - $0[1].y)
        }
        func cornerDistance(_ p: SIMD2<Double>, side: Int) -> Double {
            corners[side].map { hypot(p.x - $0.x, p.y - $0.y) }.min() ?? .infinity
        }
        var changed = fixture.source
        var unknownCount = [Int](repeating: 0, count: 2)
        var unknownWithinNegativeWindow = [Int](repeating: 0, count: 2)
        var protectedOffsets = [[Int]](repeating: [], count: 2)
        var safeOffsets = [[Int]](repeating: [], count: 2)
        let negativeWindowRadius = (1 + 100.0 / 121) * sourceRadius
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let offset = (y * width + x) * 4
            for side in 0..<2 {
                let distance = cornerDistance(p, side: side)
                if distance <= collarRadii[side] { protectedOffsets[side].append(offset) }
                guard inside(p, fixture.polygons[side]) else { continue }
                let clearance = edgeDistance(p, fixture.polygons[side])
                if distance <= collarRadii[side] && clearance > 1 {
                    // Only otherwise-owned opening pixels are perturbed. This
                    // exercises the new corner exclusion independently of the
                    // existing outside-opening and known lid-rim exclusions.
                    changed[offset] = (x + y) % 2 == 0 ? 255 : 0
                    changed[offset + 1] = x % 3 == 0 ? 0 : 255
                    changed[offset + 2] = y % 3 == 0 ? 255 : 0
                    changed[offset + 3] = (x + y) % 2 == 0 ? 0 : 97
                    unknownCount[side] += 1
                    let v = p - centers[side]
                    if hypot(v.x, v.y) < negativeWindowRadius {
                        unknownWithinNegativeWindow[side] += 1
                    }
                } else if distance > collarRadii[side] + 1 && clearance > 2.5 {
                    // The one-pixel destination AA collar is intentionally
                    // excluded; this region is fixed from source geometry.
                    safeOffsets[side].append(offset)
                }
            }
        } }
        XCTAssertTrue(unknownCount.allSatisfy { $0 > 0 })
        XCTAssertTrue(unknownWithinNegativeWindow.allSatisfy { $0 > 0 },
            "unknown canthus samples must overlap even the smaller signed window")
        XCTAssertTrue(protectedOffsets.allSatisfy { !$0.isEmpty })
        XCTAssertTrue(safeOffsets.allSatisfy { !$0.isEmpty })
        XCTAssertNotEqual(changed, fixture.source)
        for fraction: Float in [-1, 1] {
            let a = try render(fixture, fraction: fraction)
            let b = try render(fixture, fraction: fraction, source: changed)
            for side in 0..<2 {
                var protectedDelta = 0, safeDelta = 0, effectA = 0, effectB = 0
                for offset in protectedOffsets[side] {
                    for channel in 0..<4 {
                        protectedDelta += abs(Int(a[offset + channel]) - Int(fixture.source[offset + channel]))
                        protectedDelta += abs(Int(b[offset + channel]) - Int(changed[offset + channel]))
                    }
                }
                for offset in safeOffsets[side] {
                    for channel in 0..<4 {
                        safeDelta += abs(Int(a[offset + channel]) - Int(b[offset + channel]))
                    }
                    for channel in 0..<3 {
                        effectA += abs(Int(a[offset + channel]) - Int(fixture.source[offset + channel]))
                        effectB += abs(Int(b[offset + channel]) - Int(changed[offset + channel]))
                    }
                }
                XCTAssertEqual(protectedDelta, 0, "both source canthus collars remain RGBA exact")
                XCTAssertEqual(safeDelta, 0, "unknown source canthus RGBA cannot enter the safe aperture")
                XCTAssertGreaterThan(effectA, 0, "each eye must receive a real signed iris edit")
                XCTAssertGreaterThan(effectB, 0, "unknown canthus alpha must not turn that edit into whole-eye abstention")
            }
        }
    }

    func testWiderObservedIrisKeepsEightSignedRoundStepsAndSourceProtection() throws {
        let irisRadiusFactor: Float = 1.2
        let fixture = try fixture(irisRadiusFactor: irisRadiusFactor)
        // The expected circle comes from the generated source and signed
        // response, never from a fitted output or the candidate's window budget.
        let sourceRadius = radius * Double(irisRadiusFactor)
        let angles = (0..<8).map { Double($0) * Double.pi / 4 }
        let sourceMeans = try (0..<2).map { side in
            try angles.map {
                try crossing(fixture.source, side: side, angle: $0, scanRadius: sourceRadius + 3)
            }.reduce(0, +) / Double(angles.count)
        }
        let corners = fixture.polygons.map { [$0[0], $0[8]] }
        let collarRadii = corners.map {
            0.08 * hypot($0[0].x - $0[1].x, $0[0].y - $0[1].y)
        }
        var openingSide = [Int](repeating: -1, count: width * height)
        var protectedPixels = [Bool](repeating: false, count: width * height)
        var cornerCount = [Int](repeating: 0, count: 2)
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), pixel = y * width + x
            for side in 0..<2 {
                if inside(p, fixture.polygons[side]) { openingSide[pixel] = side }
                if corners[side].contains(where: { hypot(p.x - $0.x, p.y - $0.y) <= collarRadii[side] }) {
                    protectedPixels[pixel] = true
                    cornerCount[side] += 1
                }
            }
            protectedPixels[pixel] = protectedPixels[pixel]
                || openingSide[pixel] < 0 || fixture.lidPixels.contains(pixel * 4)
        } }
        XCTAssertTrue(cornerCount.allSatisfy { $0 > 0 })
        for sign: Float in [-1, 1] {
            var previous = [Double](repeating: 0, count: 2)
            for (fraction, scale) in steps where fraction * sign > 0 {
                let output = try render(fixture, fraction: fraction)
                for side in 0..<2 {
                    var radii = [Double]()
                    for angle in angles {
                        let measured = try crossing(output, side: side, angle: angle,
                            scanRadius: scale * sourceRadius + 3)
                        XCTAssertEqual(measured, scale * sourceRadius, accuracy: 0.75,
                            "a tighter safe window must preserve the admitted circular iris")
                        radii.append(measured)
                        let inner = try crossing(output, side: side, angle: angle, threshold: 80,
                            scanRadius: scale * sourceRadius + 3)
                        let outer = try crossing(output, side: side, angle: angle, threshold: 160,
                            scanRadius: scale * sourceRadius + 3)
                        XCTAssertGreaterThan(outer, inner)
                        XCTAssertLessThan(outer - inner, 2.1, "a single AA limbus survives every signed quarter")
                    }
                    XCTAssertLessThan(try XCTUnwrap(radii.max()) - XCTUnwrap(radii.min()), 1)
                    XCTAssertEqual((radii[0] - radii[4]) / 2, 0, accuracy: 0.3)
                    XCTAssertEqual((radii[2] - radii[6]) / 2, 0, accuracy: 0.3)
                    let mean = radii.reduce(0, +) / Double(radii.count)
                    let amplitude = (mean - sourceMeans[side]) * Double(sign)
                    XCTAssertGreaterThan(amplitude, previous[side] + 0.15,
                        "window safety must not turn any signed quarter into whole-eye abstention")
                    previous[side] = amplitude
                    XCTAssertGreaterThan(rgbChange(fixture.source, output, side: side), 0)
                }
                var protectedDelta = 0, alphaDelta = 0, protectedCount = 0
                // This is the reference recipe's outer window ceiling; no
                // candidate-specific adaptive radius is reproduced here.
                let windowCeiling = (scale + 1) * sourceRadius
                for y in 0..<height { for x in 0..<width {
                    let pixel = y * width + x, offset = pixel * 4, side = openingSide[pixel]
                    var isProtected = protectedPixels[pixel]
                    if side >= 0 {
                        let v = SIMD2(Double(x) + 0.5, Double(y) + 0.5) - centers[side]
                        isProtected = isProtected || hypot(v.x, v.y) >= windowCeiling
                    }
                    if isProtected {
                        protectedCount += 1
                        for channel in 0..<4 {
                            protectedDelta += abs(Int(output[offset + channel]) - Int(fixture.source[offset + channel]))
                        }
                    }
                    alphaDelta += abs(Int(output[offset + 3]) - Int(fixture.source[offset + 3]))
                } }
                XCTAssertGreaterThan(protectedCount, width * height / 2)
                XCTAssertEqual(protectedDelta, 0, "whole opening/window exterior, lid and canthus RGBA stay source exact")
                XCTAssertEqual(alphaDelta, 0, "every source alpha byte")
            }
            XCTAssertGreaterThan(previous[0], 2.5)
            XCTAssertGreaterThan(previous[1], 2.5)
        }
    }

    func testSourceRegisteredCircleCorrectsCoherentModelCenterAndRadiusError() throws {
        let baseline = try fixture()
        let fixture = try fixture(modelCenterOffsetPixels: SIMD2(1.5, -2.5), modelRadiusFactor: 1.05)
        // Only the observation is biased: true source centers, circular iris
        // pixels, aperture and canthi remain byte-for-byte the baseline fixture.
        XCTAssertEqual(fixture.source, baseline.source)
        XCTAssertEqual(fixture.polygons, baseline.polygons)
        let angles = (0..<8).map { Double($0) * Double.pi / 4 }
        for fraction: Float in [-1, 1] {
            let scale = try XCTUnwrap(steps.first { $0.0 == fraction }?.1)
            let output = try render(fixture, fraction: fraction)
            for side in 0..<2 {
                var radii = [Double]()
                for angle in angles {
                    let measured = try crossing(output, side: side, angle: angle,
                        scanRadius: scale * radius + 3)
                    XCTAssertEqual(measured, scale * radius, accuracy: 0.75,
                        "source RGB must register the real circle rather than scale the biased model ring")
                    radii.append(measured)
                    let inner = try crossing(output, side: side, angle: angle, threshold: 80,
                        scanRadius: scale * radius + 3)
                    let outer = try crossing(output, side: side, angle: angle, threshold: 160,
                        scanRadius: scale * radius + 3)
                    XCTAssertGreaterThan(outer, inner)
                    XCTAssertLessThan(outer - inner, 2.1, "registration must preserve a single AA limbus")
                }
                XCTAssertLessThan(try XCTUnwrap(radii.max()) - XCTUnwrap(radii.min()), 1)
                XCTAssertEqual((radii[0] - radii[4]) / 2, 0, accuracy: 0.3,
                    "horizontal scaling center stays on the true source center")
                XCTAssertEqual((radii[2] - radii[6]) / 2, 0, accuracy: 0.3,
                    "vertical scaling center stays on the true source center")
                XCTAssertGreaterThan(rgbChange(fixture.source, output, side: side), 0,
                    "registration cannot pass by abstaining from the signed iris edit")
            }
            assertProtected(fixture, output, scale: scale)
        }
    }

    func testNeutralMissingDenseClosedStaleAndSidePoseAbstainBitExactlyAndRecover() throws {
        let normal = try fixture()
        XCTAssertNil(BeautyIrisScaleRemap(width: width, height: height, face: normal.face,
            strengths: strengths(0), sourceRGBA: normal.source))
        // Proper 90-degree yaw, not a malformed/sheared matrix interpreted as pose.
        let sidePose: [Float] = [0, 0, 1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1]
        for invalid in [try fixture(dense: false), try fixture(closed: true),
                        try fixture(freshness: .stale), try fixture(transformation: sidePose)] {
            for fraction: Float in [-1, 1] {
                let remap = BeautyIrisScaleRemap(width: width, height: height, face: invalid.face,
                    strengths: strengths(fraction), sourceRGBA: invalid.source)
                XCTAssertNil(remap)
                XCTAssertEqual(remap?.applyRGBA(invalid.source) ?? invalid.source, invalid.source)
            }
        }
        var nonfinite = strengths(1)
        nonfinite.pupilSize = .nan
        XCTAssertNil(BeautyIrisScaleRemap(width: width, height: height, face: normal.face,
            strengths: nonfinite, sourceRGBA: normal.source))
        XCTAssertNil(BeautyIrisScaleRemap(width: 0, height: height, face: normal.face,
            strengths: strengths(1), sourceRGBA: normal.source))
        for fraction: Float in [-1, 1] {
            let output = try render(normal, fraction: fraction)
            XCTAssertNotEqual(output, normal.source)
            XCTAssertEqual(output, try render(normal, fraction: fraction))
        }
        let active = try XCTUnwrap(BeautyIrisScaleRemap(width: width, height: height, face: normal.face,
            strengths: strengths(1), sourceRGBA: normal.source))
        XCTAssertEqual(active.applyRGBA([1, 2, 3]), [1, 2, 3])
    }

    func testInvalidRingAndLegitimateAlphaFailureDoNotBorrowFromValidPeer() throws {
        let collapsed = try fixture(collapsedLeft: true)
        let normal = try fixture()
        var alphaFailure = normal.source
        // A real alpha discontinuity inside the original left iris is not an
        // occluded unknown region eligible for polar donor estimation.
        for y in 248..<264 { for x in 232..<248 where x % 2 == 0 {
            alphaFailure[(y * width + x) * 4 + 3] = 137
        } }
        for fraction: Float in [-1, 1] {
            for (input, source) in [(collapsed, collapsed.source), (normal, alphaFailure)] {
                let output = try render(input, fraction: fraction, source: source)
                var leftDelta = 0, alphaDelta = 0
                for y in 0..<height { for x in 0..<width {
                    let offset = (y * width + x) * 4
                    if x < width / 2 {
                        for channel in 0..<4 { leftDelta += abs(Int(source[offset + channel]) - Int(output[offset + channel])) }
                    }
                    alphaDelta += abs(Int(source[offset + 3]) - Int(output[offset + 3]))
                } }
                XCTAssertEqual(leftDelta, 0, "invalid source evidence rejects only its own eye")
                XCTAssertEqual(alphaDelta, 0)
                XCTAssertGreaterThan(rgbChange(source, output, side: 1), 0, "the valid peer remains independently editable")
            }
        }
    }

    // Proposal only: insert this method inside BeautyIrisScaleRemapTests.
    // Reuses the existing private fixture/measurement helpers; no existing
    // case or acceptance threshold is changed. This has not been executed.
    func testWhiteCatchlightKeepsSourcePixelsAreaAndOneComponentAtBothCaps() throws {
        let fixture = try fixture()
        var source = fixture.source
        let glintRadius = 1.5
        let glintAA = 0.5
        // The prospective catchlight exception includes the source AA envelope
        // dilated by a fixed one-pixel Chebyshev halo, its mapped footprints,
        // and the original restoration envelope. sqrt(2) is a conservative
        // circular superset of that square halo; it never follows output RGB.
        let glintExceptionRadius = glintRadius + glintAA + sqrt(2)
        let glintCenters = [
            centers[0] + SIMD2(-0.36 * radius, 0.36 * radius),
            centers[1] + SIMD2(0.36 * radius, -0.36 * radius),
        ]
        var glintSupport = [Set<Int>](repeating: [], count: 2)
        var restorePixels = [Set<Int>](repeating: [], count: 2)

        for side in 0..<2 {
            let displacement = glintCenters[side] - centers[side]
            // This fixture's actual AA payload and complete four-tap footprint
            // fit inside the median/core eligibility radius. The separately
            // permitted restoration halo need not fit inside .75 R: it must
            // retain legal opening/curve/canthus ownership instead.
            XCTAssertGreaterThan(hypot(displacement.x, displacement.y), radius * 0.5)
            XCTAssertLessThan(hypot(displacement.x, displacement.y)
                + glintRadius + glintAA + sqrt(2), 0.75 * radius)
            for y in Int(glintCenters[side].y - 4)...Int(glintCenters[side].y + 4) {
                for x in Int(glintCenters[side].x - 4)...Int(glintCenters[side].x + 4) {
                    let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                    let v = p - glintCenters[side]
                    let coverage = max(0, min(1, glintRadius + glintAA - hypot(v.x, v.y)))
                    guard coverage > 0 else { continue }
                    let pixel = y * width + x, offset = pixel * 4
                    XCTAssertTrue(inside(p, fixture.polygons[side]))
                    XCTAssertGreaterThan(edgeDistance(p, fixture.polygons[side]), 2.5)
                    XCTAssertFalse(fixture.lidPixels.contains(offset))
                    glintSupport[side].insert(pixel)
                    // Actual RGB white with an analytic one-pixel AA edge;
                    // the old G/B-only marker retains its dark red channel.
                    for channel in 0..<3 {
                        let original = Double(fixture.source[offset + channel])
                        source[offset + channel] = UInt8((original + coverage * (255 - original)).rounded())
                    }
                    // A fixed conservative part of the AA payload. R starts
                    // at 40 here; min RGB >= 160 means coverage >= 120/215,
                    // well beyond median+32 and luma median+50 in this fixture.
                    // We do not require below-threshold AA fringe restoration.
                    if (0..<3).allSatisfy({ source[offset + $0] >= 160 }) {
                        restorePixels[side].insert(pixel)
                    }
                }
            }
            XCTAssertFalse(restorePixels[side].isEmpty)
            var sourceEnvelope = Set<Int>()
            // Source-generation truth, not the production detector's mask:
            // take the analytic nonzero AA pixels and their Chebyshev-1 union.
            // The frozen small-component budget owns this entire envelope.
            for pixel in glintSupport[side] {
                for dy in -1...1 { for dx in -1...1 {
                    let x = pixel % width + dx, y = pixel / width + dy
                    XCTAssertTrue(x >= 0 && x < width && y >= 0 && y < height)
                    let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                    XCTAssertTrue(inside(p, fixture.polygons[side]))
                    XCTAssertGreaterThan(edgeDistance(p, fixture.polygons[side]), 1)
                    XCTAssertFalse(fixture.lidPixels.contains((y * width + x) * 4))
                    sourceEnvelope.insert(y * width + x)
                } }
            }
            XCTAssertTrue(glintSupport[side].isSubset(of: sourceEnvelope))
            XCTAssertLessThanOrEqual(Double(sourceEnvelope.count), 0.04 * Double.pi * radius * radius,
                "the complete source AA envelope plus one-pixel halo must qualify within the frozen 4% budget")
        }

        func whitePixels(_ rgba: [UInt8], side: Int) -> Set<Int> {
            var pixels = Set<Int>()
            // A source-fixed whole-opening ROI finds both the original glint
            // and any scaled/displaced duplicate. Sclera red is 200, and the
            // colored G/B marker has red 40; neither can cross this cutoff.
            // With source red 40, 230 corresponds to AA coverage >= 190/215.
            for y in 0..<height { for x in 0..<width {
                let pixel = y * width + x, offset = pixel * 4
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                if inside(p, fixture.polygons[side])
                    && (0..<3).allSatisfy({ rgba[offset + $0] >= 230 }) {
                    pixels.insert(pixel)
                }
            } }
            return pixels
        }

        func componentCount(_ pixels: Set<Int>) -> Int {
            var remaining = pixels, count = 0
            while let start = remaining.first {
                count += 1
                var queue = [start]
                remaining.remove(start)
                while let pixel = queue.popLast() {
                    for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                        let x = pixel % width + dx, y = pixel / width + dy
                        if x >= 0 && x < width && y >= 0 && y < height,
                           remaining.remove(y * width + x) != nil {
                            queue.append(y * width + x)
                        }
                    } }
                }
            }
            return count
        }

        func centroid(_ pixels: Set<Int>) throws -> SIMD2<Double> {
            let count = try XCTUnwrap(pixels.isEmpty ? nil : pixels.count,
                "a broken candidate must not erase every RGB-white source pixel")
            return pixels.reduce(SIMD2<Double>.zero) { moment, pixel in
                moment + SIMD2(Double(pixel % width) + 0.5, Double(pixel / width) + 0.5)
            } / Double(count)
        }

        let sourceWhite = (0..<2).map { whitePixels(source, side: $0) }
        for side in 0..<2 {
            XCTAssertFalse(sourceWhite[side].isEmpty)
            XCTAssertEqual(componentCount(sourceWhite[side]), 1)
            XCTAssertTrue(sourceWhite[side].isSubset(of: restorePixels[side]))
            XCTAssertEqual(whitePixels(fixture.source, side: side).count, 0,
                "the existing colored highlight is explicitly not a white catchlight")
        }

        for fraction: Float in [-1, 1] {
            let scale = try XCTUnwrap(steps.first { $0.0 == fraction }?.1)
            let output = try render(fixture, fraction: fraction, source: source)
            for side in 0..<2 {
                let actualWhite = whitePixels(output, side: side)
                XCTAssertEqual(actualWhite.count, sourceWhite[side].count,
                    "white catchlight area must not shrink or grow with iris scale")
                XCTAssertEqual(componentCount(actualWhite), 1,
                    "exactly one source catchlight, with no detached copy")
                XCTAssertEqual(actualWhite, sourceWhite[side],
                    "the whole-opening bright support stays at source pixels; no displaced or overlapping copy")
                let actualCenter = try centroid(actualWhite)
                let originalCenter = try centroid(sourceWhite[side])
                XCTAssertEqual(actualCenter.x, originalCenter.x, accuracy: 1e-12)
                XCTAssertEqual(actualCenter.y, originalCenter.y, accuracy: 1e-12)
                var restoredDelta = 0
                for pixel in restorePixels[side] {
                    let offset = pixel * 4
                    for channel in 0..<4 {
                        restoredDelta += abs(Int(output[offset + channel]) - Int(source[offset + channel]))
                    }
                }
                XCTAssertEqual(restoredDelta, 0,
                    "eligible white core and strong AA RGB are restored once, byte-exact at the original site")

                var checked = 0, expectedChange = 0, maximumError = 0
                let center = centers[side]
                for y in Int(center.y - radius * 1.3)..<Int(center.y + radius * 1.3) {
                    for x in Int(center.x - radius * 1.3)..<Int(center.x + radius * 1.3) {
                        let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), v = p - center
                        let q = center + v / scale
                        if hypot(v.x, v.y) > scale * (radius - 2)
                            || !inside(p, fixture.polygons[side])
                            || edgeDistance(p, fixture.polygons[side]) <= 2.5 { continue }
                        let x0 = floor(q.x - 0.5), y0 = floor(q.y - 0.5)
                        let footprint = [SIMD2(x0 + 0.5, y0 + 0.5), SIMD2(x0 + 1.5, y0 + 0.5),
                                         SIMD2(x0 + 0.5, y0 + 1.5), SIMD2(x0 + 1.5, y0 + 1.5)]
                        let fromGlint = footprint.contains { tap in
                            let d = tap - glintCenters[side]
                            return hypot(d.x, d.y) <= glintExceptionRadius
                        }
                        let destinationGlint = p - glintCenters[side]
                        // Source-stencil exclusion covers the mapped halo;
                        // destination exclusion covers the original source
                        // restoration halo. Both are frozen source geometry.
                        if fromGlint || hypot(destinationGlint.x, destinationGlint.y) <= glintExceptionRadius
                            || !footprint.allSatisfy({ inside($0, fixture.polygons[side])
                                && edgeDistance($0, fixture.polygons[side]) > 1 }) { continue }
                        let expected = sampledRGB(fixture.source, at: q), offset = (y * width + x) * 4
                        checked += 1
                        for channel in 0..<3 {
                            maximumError = max(maximumError, abs(Int(output[offset + channel]) - Int(expected[channel])))
                            expectedChange += abs(Int(fixture.source[offset + channel]) - Int(expected[channel]))
                        }
                    }
                }
                XCTAssertGreaterThan(checked, 100, "a source-defined non-glint core exercises both axes")
                XCTAssertGreaterThan(expectedChange, 0, "whole-eye abstention cannot pass")
                // Same source geometry, four-tap sampler and RGBA8 allowance
                // as the existing uniform-core test, not an output-fit limit.
                XCTAssertLessThanOrEqual(maximumError, 1,
                    "non-glint iris texture retains the original uniform inverse scale")
            }
            assertProtected(fixture, output, scale: scale, source: source)
            XCTAssertEqual(output, try render(fixture, fraction: fraction, source: source),
                "catchlight extraction/restoration is deterministic")
        }
    }


    // Temporary proposal: insert these two independent methods inside
    // BeautyIrisScaleRemapTests. No existing case or threshold is changed.
    func testLegalVisibleUpperLimbusUsesUniformSampleOutsideFixedOnePixelLid() throws {
        let fixture = try fixture(upperScale: 0.55)
        let scale = 100.0 / 79
        let windowRadius = (scale + 1) * radius
        var probes = [(offset: Int, expected: [UInt8])]()

        for side in 0..<2 {
            let center = centers[side], polygon = fixture.polygons[side]
            let corners = [polygon[0], polygon[8]]
            let collarRadius = 0.08 * hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
            for sign in [-1.0, 1.0] {
                // Fixed source geometry: four true pixel-center points, not
                // coordinates selected after viewing a candidate's output.
                let p = center + SIMD2(sign * 16.5, -15.5), v = p - center
                let q = center + v / scale
                let clearance = edgeDistance(p, polygon)
                XCTAssertTrue(inside(p, polygon))
                XCTAssertGreaterThan(clearance, 1.5)
                XCTAssertLessThan(clearance, 2.5)
                XCTAssertLessThan(hypot(v.x, v.y), scale * radius,
                    "this is a visible positive-cap iris point, not the outer Hermite band")
                let sourceVector = q - center
                XCTAssertLessThan(hypot(sourceVector.x, sourceVector.y), radius)
                XCTAssertGreaterThan(windowRadius - hypot(v.x, v.y), sqrt(2))
                XCTAssertTrue(corners.allSatisfy { hypot(p.x - $0.x, p.y - $0.y) > collarRadius })

                let x = Int(p.x - 0.5), y = Int(p.y - 0.5), offset = (y * width + x) * 4
                XCTAssertEqual(p.x, Double(x) + 0.5)
                XCTAssertEqual(p.y, Double(y) + 0.5)
                XCTAssertFalse(fixture.lidPixels.contains(offset))
                let x0 = floor(q.x - 0.5), y0 = floor(q.y - 0.5)
                let footprint = [SIMD2(x0 + 0.5, y0 + 0.5), SIMD2(x0 + 1.5, y0 + 0.5),
                                 SIMD2(x0 + 0.5, y0 + 1.5), SIMD2(x0 + 1.5, y0 + 1.5)]
                for tap in footprint {
                    XCTAssertTrue(tap.x >= 0.5 && tap.x <= Double(width) - 0.5
                        && tap.y >= 0.5 && tap.y <= Double(height) - 0.5)
                    XCTAssertTrue(inside(tap, polygon))
                    XCTAssertGreaterThan(edgeDistance(tap, polygon), 1,
                        "all four source taps lie outside the known one-pixel lid strip")
                    let tapVector = tap - center
                    XCTAssertGreaterThan(windowRadius - hypot(tapVector.x, tapVector.y), sqrt(2))
                    XCTAssertTrue(corners.allSatisfy { hypot(tap.x - $0.x, tap.y - $0.y) > collarRadius })
                }
                let expected = sampledRGB(fixture.source, at: q)
                XCTAssertEqual(Array(fixture.source[offset..<(offset + 3)]), [200, 220, 220],
                    "the same source destination is white before positive-cap iris expansion")
                XCTAssertGreaterThan(abs(Int(expected[0]) - Int(fixture.source[offset])), 32,
                    "the independent uniform iris sample differs enough to reject abstention or white blending")
                probes.append((offset, expected))
            }
        }
        XCTAssertEqual(probes.count, 4)

        var changed = fixture.source
        var rimCount = [Int](repeating: 0, count: 2)
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            for side in 0..<2 where inside(p, fixture.polygons[side])
                && edgeDistance(p, fixture.polygons[side]) <= 1 {
                // Only independently known inner-lid material changes. Every
                // legal q footprint above is outside this source-unknown strip.
                changed[offset] = (x + y) % 2 == 0 ? 255 : 0
                changed[offset + 1] = x % 3 == 0 ? 0 : 255
                changed[offset + 2] = y % 3 == 0 ? 255 : 0
                changed[offset + 3] = (x + y) % 2 == 0 ? 0 : 97
                rimCount[side] += 1
            }
        } }
        XCTAssertTrue(rimCount.allSatisfy { $0 > 0 })
        XCTAssertNotEqual(changed, fixture.source)

        let output = try render(fixture, fraction: 1)
        let perturbedOutput = try render(fixture, fraction: 1, source: changed)
        for probe in probes {
            for channel in 0..<3 {
                XCTAssertLessThanOrEqual(abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])), 1,
                    "visible legal limbus RGB uses the same uniform inverse scale, without original-white feather mixing")
                XCTAssertLessThanOrEqual(abs(Int(perturbedOutput[probe.offset + channel]) - Int(probe.expected[channel])), 1)
            }
            XCTAssertEqual(Array(output[probe.offset..<(probe.offset + 4)]),
                Array(perturbedOutput[probe.offset..<(probe.offset + 4)]),
                "unknown inner-lid RGB/alpha cannot influence the independently legal four-tap sample")
            XCTAssertGreaterThan(abs(Int(output[probe.offset]) - Int(fixture.source[probe.offset])), 32,
                "the positive fixture must receive a real expanded iris sample")
        }
        assertProtected(fixture, output, scale: scale)
        assertProtected(fixture, perturbedOutput, scale: scale, source: changed)
    }

    func testActuallyOccludedUpperLimbusAndFixedOnePixelLidStaySourceExact() throws {
        let fixture = try fixture(upperScale: 0.45)
        let scale = 100.0 / 79
        var probes = [Int]()
        for side in 0..<2 {
            for sign in [-1.0, 1.0] {
                // Exactly the same p as the positive case; only the source
                // aperture is genuinely more occluded. No output-fitted point.
                let p = centers[side] + SIMD2(sign * 16.5, -15.5)
                let clearance = edgeDistance(p, fixture.polygons[side])
                let signedDistance = inside(p, fixture.polygons[side]) ? clearance : -clearance
                XCTAssertLessThanOrEqual(signedDistance, 1,
                    "source geometry makes this point outside the opening or in the fixed forbidden strip")
                let x = Int(p.x - 0.5), y = Int(p.y - 0.5)
                probes.append((y * width + x) * 4)
            }
        }
        XCTAssertEqual(probes.count, 4)

        var forbidden = Set<Int>(), changed = fixture.source
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            let legalOpening = fixture.polygons.contains { inside(p, $0) && edgeDistance(p, $0) > 1 }
            if !legalOpening {
                forbidden.insert(offset)
                changed[offset] = (x + y) % 2 == 0 ? 255 : 0
                changed[offset + 1] = x % 3 == 0 ? 0 : 255
                changed[offset + 2] = y % 3 == 0 ? 255 : 0
                changed[offset + 3] = UInt8((x + 3 * y) % 256)
            }
        } }
        XCTAssertTrue(probes.allSatisfy { forbidden.contains($0) })
        XCTAssertGreaterThan(forbidden.count, width * height / 2)
        XCTAssertNotEqual(changed, fixture.source)

        for source in [fixture.source, changed] {
            // Whole-eye abstention is valid for this negative fixture. Only
            // the separate positive test requires actual uniform iris change.
            let remap = BeautyIrisScaleRemap(width: width, height: height, face: fixture.face,
                strengths: strengths(1), sourceRGBA: source)
            let output = remap?.applyRGBA(source) ?? source
            for offset in probes {
                XCTAssertEqual(Array(output[offset..<(offset + 4)]), Array(source[offset..<(offset + 4)]),
                    "true occlusion never expands an iris over the original source lid or exterior")
            }
            var forbiddenDelta = 0, alphaDelta = 0
            for offset in forbidden {
                for channel in 0..<4 {
                    forbiddenDelta += abs(Int(output[offset + channel]) - Int(source[offset + channel]))
                }
            }
            for pixel in 0..<(width * height) {
                let offset = pixel * 4
                alphaDelta += abs(Int(output[offset + 3]) - Int(source[offset + 3]))
            }
            XCTAssertEqual(forbiddenDelta, 0, "every exterior and known one-pixel lid RGBA byte")
            XCTAssertEqual(alphaDelta, 0, "every source alpha byte, including unknown forbidden alpha")
            assertProtected(fixture, output, scale: scale, source: source)
        }
    }


    // Proposal only: insert this method inside BeautyIrisScaleRemapTests.
    // Reuses the existing private fixture/measurement helpers; no existing
    // case or acceptance threshold is changed. This has not been executed.
    func testQualifiedSmallWhiteGlintDoesNotCountItsFixedSamplingHaloAsBrightMaterial() throws {
        let fixture = try fixture()
        var source = fixture.source
        let glintRadius = 2.0
        let glintAA = 0.5
        // The prospective catchlight exception includes the source AA envelope
        // dilated by a fixed one-pixel Chebyshev halo, its mapped footprints,
        // and the original restoration envelope. sqrt(2) is a conservative
        // circular superset of that square halo; it never follows output RGB.
        let glintExceptionRadius = glintRadius + glintAA + sqrt(2)
        let glintCenters = [
            centers[0] + SIMD2(-0.36 * radius, 0.36 * radius),
            centers[1] + SIMD2(0.36 * radius, -0.36 * radius),
        ]
        var glintSupport = [Set<Int>](repeating: [], count: 2)
        var restorePixels = [Set<Int>](repeating: [], count: 2)

        for side in 0..<2 {
            let displacement = glintCenters[side] - centers[side]
            // This fixture's actual AA payload and complete four-tap footprint
            // fit inside the median/core eligibility radius. The separately
            // permitted restoration halo need not fit inside .75 R: it must
            // retain legal opening/curve/canthus ownership instead.
            XCTAssertGreaterThan(hypot(displacement.x, displacement.y), radius * 0.5)
            XCTAssertLessThan(hypot(displacement.x, displacement.y)
                + glintRadius + glintAA + sqrt(2), 0.75 * radius)
            for y in Int(glintCenters[side].y - 4)...Int(glintCenters[side].y + 4) {
                for x in Int(glintCenters[side].x - 4)...Int(glintCenters[side].x + 4) {
                    let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                    let v = p - glintCenters[side]
                    let coverage = max(0, min(1, glintRadius + glintAA - hypot(v.x, v.y)))
                    guard coverage > 0 else { continue }
                    let pixel = y * width + x, offset = pixel * 4
                    XCTAssertTrue(inside(p, fixture.polygons[side]))
                    XCTAssertGreaterThan(edgeDistance(p, fixture.polygons[side]), 2.5)
                    XCTAssertFalse(fixture.lidPixels.contains(offset))
                    glintSupport[side].insert(pixel)
                    // Actual RGB white with an analytic one-pixel AA edge;
                    // the old G/B-only marker retains its dark red channel.
                    for channel in 0..<3 {
                        let original = Double(fixture.source[offset + channel])
                        source[offset + channel] = UInt8((original + coverage * (255 - original)).rounded())
                    }
                    // A fixed conservative part of the AA payload. R starts
                    // at 40 here; min RGB >= 160 means coverage >= 120/215,
                    // well beyond median+32 and luma median+50 in this fixture.
                    // We do not require below-threshold AA fringe restoration.
                    if (0..<3).allSatisfy({ source[offset + $0] >= 160 }) {
                        restorePixels[side].insert(pixel)
                    }
                }
            }
            XCTAssertFalse(restorePixels[side].isEmpty)
            XCTAssertLessThanOrEqual(Double(glintSupport[side].count), 0.04 * Double.pi * radius * radius,
                "4% constrains the source bright plus analytic AA material")

            var remainingAA = glintSupport[side], sourceComponentCount = 0
            while let start = remainingAA.first {
                sourceComponentCount += 1
                var component = [start], queue = [start]
                remainingAA.remove(start)
                while let pixel = queue.popLast() {
                    for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                        let x = pixel % width + dx, y = pixel / width + dy
                        if x >= 0 && x < width && y >= 0 && y < height,
                           remainingAA.remove(y * width + x) != nil {
                            queue.append(y * width + x)
                            component.append(y * width + x)
                        }
                    } }
                }
                let xs = component.map { $0 % width }, ys = component.map { $0 / width }
                // Include entire pixel squares rather than measuring only the
                // center-to-center span: this is a conservative source bbox.
                let spanX = Double(try XCTUnwrap(xs.max()) - XCTUnwrap(xs.min()) + 1)
                let spanY = Double(try XCTUnwrap(ys.max()) - XCTUnwrap(ys.min()) + 1)
                XCTAssertLessThanOrEqual(hypot(spanX, spanY), 0.4 * radius,
                    "every final source AA 8-component is independently a small patch")
            }
            XCTAssertEqual(sourceComponentCount, 1)

            var sourceHalo = Set<Int>()
            for pixel in glintSupport[side] {
                for dy in -1...1 { for dx in -1...1 {
                    sourceHalo.insert((pixel / width + dy) * width + pixel % width + dx)
                } }
            }
            XCTAssertTrue(glintSupport[side].isSubset(of: sourceHalo))
            XCTAssertGreaterThan(Double(sourceHalo.count), 0.04 * Double.pi * radius * radius,
                "the fixed Chebyshev-1 sampling halo deliberately exceeds the material budget")
            XCTAssertEqual(glintSupport[side].count, 21)
            XCTAssertEqual(sourceHalo.count, 45)

            let corners = [fixture.polygons[side][0], fixture.polygons[side][8]]
            let collarRadius = 0.08 * hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
            let sourceMaterialRadius = radius - sqrt(2)
            let windowRadius = (100.0 / 79 + 1) * radius
            func assertLegalOpaqueTap(_ tap: SIMD2<Double>) {
                XCTAssertTrue(tap.x >= 0.5 && tap.x <= Double(width) - 0.5
                    && tap.y >= 0.5 && tap.y <= Double(height) - 0.5)
                XCTAssertTrue(inside(tap, fixture.polygons[side]))
                XCTAssertGreaterThan(edgeDistance(tap, fixture.polygons[side]), 1)
                let v = tap - centers[side]
                XCTAssertLessThan(hypot(v.x, v.y), sourceMaterialRadius)
                XCTAssertGreaterThan(windowRadius - hypot(v.x, v.y), sqrt(2))
                XCTAssertTrue(corners.allSatisfy { hypot(tap.x - $0.x, tap.y - $0.y) > collarRadius })
                let x = Int(tap.x - 0.5), y = Int(tap.y - 0.5)
                XCTAssertEqual(source[(y * width + x) * 4 + 3], 255)
            }
            for pixel in sourceHalo {
                let p = SIMD2(Double(pixel % width) + 0.5, Double(pixel / width) + 0.5)
                for tap in [p, p + SIMD2(1, 0), p + SIMD2(0, 1), p + SIMD2(1, 1)] {
                    assertLegalOpaqueTap(tap)
                }
            }

            // Two distinct independently legal same-eye source stencils are
            // available outside this AA/halo; no ownership/donor gate is
            // weakened simply to make the larger sampling halo admissible.
            var donorStencils = [[Int]]()
            for q in [centers[side] + SIMD2(0.2 * radius, 0),
                      centers[side] + SIMD2(0, -0.2 * radius)] {
                let x0 = floor(q.x - 0.5), y0 = floor(q.y - 0.5)
                let footprint = [SIMD2(x0 + 0.5, y0 + 0.5), SIMD2(x0 + 1.5, y0 + 0.5),
                                 SIMD2(x0 + 0.5, y0 + 1.5), SIMD2(x0 + 1.5, y0 + 1.5)]
                var stencil = [Int]()
                for tap in footprint {
                    assertLegalOpaqueTap(tap)
                    let pixel = Int(tap.y - 0.5) * width + Int(tap.x - 0.5)
                    XCTAssertFalse(sourceHalo.contains(pixel))
                    stencil.append(pixel)
                }
                donorStencils.append(stencil)
            }
            XCTAssertNotEqual(donorStencils[0], donorStencils[1])
        }

        func whitePixels(_ rgba: [UInt8], side: Int) -> Set<Int> {
            var pixels = Set<Int>()
            // A source-fixed whole-opening ROI finds both the original glint
            // and any scaled/displaced duplicate. Sclera red is 200, and the
            // colored G/B marker has red 40; neither can cross this cutoff.
            // With source red 40, 230 corresponds to AA coverage >= 190/215.
            for y in 0..<height { for x in 0..<width {
                let pixel = y * width + x, offset = pixel * 4
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                if inside(p, fixture.polygons[side])
                    && (0..<3).allSatisfy({ rgba[offset + $0] >= 230 }) {
                    pixels.insert(pixel)
                }
            } }
            return pixels
        }

        func componentCount(_ pixels: Set<Int>) -> Int {
            var remaining = pixels, count = 0
            while let start = remaining.first {
                count += 1
                var queue = [start]
                remaining.remove(start)
                while let pixel = queue.popLast() {
                    for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                        let x = pixel % width + dx, y = pixel / width + dy
                        if x >= 0 && x < width && y >= 0 && y < height,
                           remaining.remove(y * width + x) != nil {
                            queue.append(y * width + x)
                        }
                    } }
                }
            }
            return count
        }

        func centroid(_ pixels: Set<Int>) throws -> SIMD2<Double> {
            let count = try XCTUnwrap(pixels.isEmpty ? nil : pixels.count,
                "a broken candidate must not erase every RGB-white source pixel")
            return pixels.reduce(SIMD2<Double>.zero) { moment, pixel in
                moment + SIMD2(Double(pixel % width) + 0.5, Double(pixel / width) + 0.5)
            } / Double(count)
        }

        let sourceWhite = (0..<2).map { whitePixels(source, side: $0) }
        for side in 0..<2 {
            XCTAssertFalse(sourceWhite[side].isEmpty)
            XCTAssertEqual(componentCount(sourceWhite[side]), 1)
            XCTAssertTrue(sourceWhite[side].isSubset(of: restorePixels[side]))
            XCTAssertEqual(whitePixels(fixture.source, side: side).count, 0,
                "the existing colored highlight is explicitly not a white catchlight")
        }

        for fraction: Float in [-1, 1] {
            let scale = try XCTUnwrap(steps.first { $0.0 == fraction }?.1)
            let output = try render(fixture, fraction: fraction, source: source)
            for side in 0..<2 {
                let actualWhite = whitePixels(output, side: side)
                XCTAssertEqual(actualWhite.count, sourceWhite[side].count,
                    "white catchlight area must not shrink or grow with iris scale")
                XCTAssertEqual(componentCount(actualWhite), 1,
                    "exactly one source catchlight, with no detached copy")
                XCTAssertEqual(actualWhite, sourceWhite[side],
                    "the whole-opening bright support stays at source pixels; no displaced or overlapping copy")
                let actualCenter = try centroid(actualWhite)
                let originalCenter = try centroid(sourceWhite[side])
                XCTAssertEqual(actualCenter.x, originalCenter.x, accuracy: 1e-12)
                XCTAssertEqual(actualCenter.y, originalCenter.y, accuracy: 1e-12)
                var restoredDelta = 0
                for pixel in restorePixels[side] {
                    let offset = pixel * 4
                    for channel in 0..<4 {
                        restoredDelta += abs(Int(output[offset + channel]) - Int(source[offset + channel]))
                    }
                }
                XCTAssertEqual(restoredDelta, 0,
                    "eligible white core and strong AA RGB are restored once, byte-exact at the original site")

                var checked = 0, expectedChange = 0, maximumError = 0
                let center = centers[side]
                for y in Int(center.y - radius * 1.3)..<Int(center.y + radius * 1.3) {
                    for x in Int(center.x - radius * 1.3)..<Int(center.x + radius * 1.3) {
                        let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), v = p - center
                        let q = center + v / scale
                        if hypot(v.x, v.y) > scale * (radius - 2)
                            || !inside(p, fixture.polygons[side])
                            || edgeDistance(p, fixture.polygons[side]) <= 2.5 { continue }
                        let x0 = floor(q.x - 0.5), y0 = floor(q.y - 0.5)
                        let footprint = [SIMD2(x0 + 0.5, y0 + 0.5), SIMD2(x0 + 1.5, y0 + 0.5),
                                         SIMD2(x0 + 0.5, y0 + 1.5), SIMD2(x0 + 1.5, y0 + 1.5)]
                        let fromGlint = footprint.contains { tap in
                            let d = tap - glintCenters[side]
                            return hypot(d.x, d.y) <= glintExceptionRadius
                        }
                        let destinationGlint = p - glintCenters[side]
                        // Source-stencil exclusion covers the mapped halo;
                        // destination exclusion covers the original source
                        // restoration halo. Both are frozen source geometry.
                        if fromGlint || hypot(destinationGlint.x, destinationGlint.y) <= glintExceptionRadius
                            || !footprint.allSatisfy({ inside($0, fixture.polygons[side])
                                && edgeDistance($0, fixture.polygons[side]) > 1 }) { continue }
                        let expected = sampledRGB(fixture.source, at: q), offset = (y * width + x) * 4
                        checked += 1
                        for channel in 0..<3 {
                            maximumError = max(maximumError, abs(Int(output[offset + channel]) - Int(expected[channel])))
                            expectedChange += abs(Int(fixture.source[offset + channel]) - Int(expected[channel]))
                        }
                    }
                }
                XCTAssertGreaterThan(checked, 100, "a source-defined non-glint core exercises both axes")
                XCTAssertGreaterThan(expectedChange, 0, "whole-eye abstention cannot pass")
                // Same source geometry, four-tap sampler and RGBA8 allowance
                // as the existing uniform-core test, not an output-fit limit.
                XCTAssertLessThanOrEqual(maximumError, 1,
                    "non-glint iris texture retains the original uniform inverse scale")
            }
            assertProtected(fixture, output, scale: scale, source: source)
            XCTAssertEqual(output, try render(fixture, fraction: fraction, source: source),
                "catchlight extraction/restoration is deterministic")
        }
    }


    // Proposal only: insert this method inside BeautyIrisScaleRemapTests.
    // Reuses the existing private fixture/measurement helpers; no existing
    // case or acceptance threshold is changed. This has not been executed.
    func testSmallCircularWhiteGlintUsesBoundingBoxSidesRatherThanDiagonal() throws {
        let fixture = try fixture()
        var source = fixture.source
        let glintRadius = 3.0
        let glintAA = 0.5
        // The prospective catchlight exception includes the source AA envelope
        // dilated by a fixed one-pixel Chebyshev halo, its mapped footprints,
        // and the original restoration envelope. sqrt(2) is a conservative
        // circular superset of that square halo; it never follows output RGB.
        let glintExceptionRadius = glintRadius + glintAA + sqrt(2)
        let glintCenters = [
            centers[0] + SIMD2(6.5, 4.5),
            centers[1] + SIMD2(-6.5, 4.5),
        ]
        var glintSupport = [Set<Int>](repeating: [], count: 2)
        var restorePixels = [Set<Int>](repeating: [], count: 2)

        for side in 0..<2 {
            let displacement = glintCenters[side] - centers[side]
            // This fixture's actual AA payload and complete four-tap footprint
            // fit inside the median/core eligibility radius. The separately
            // permitted restoration halo need not fit inside .75 R: it must
            // retain legal opening/curve/canthus ownership instead.
            XCTAssertEqual(displacement.x, side == 0 ? 6.5 : -6.5)
            XCTAssertEqual(displacement.y, 4.5)
            XCTAssertGreaterThan(hypot(displacement.x, displacement.y), 0)
            XCTAssertEqual(glintCenters[side].x - 0.5, floor(glintCenters[side].x - 0.5))
            XCTAssertEqual(glintCenters[side].y - 0.5, floor(glintCenters[side].y - 0.5))
            XCTAssertLessThan(hypot(displacement.x, displacement.y)
                + glintRadius + glintAA + sqrt(2), 0.75 * radius)
            for y in Int(glintCenters[side].y - 4)...Int(glintCenters[side].y + 4) {
                for x in Int(glintCenters[side].x - 4)...Int(glintCenters[side].x + 4) {
                    let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                    let v = p - glintCenters[side]
                    let coverage = max(0, min(1, glintRadius + glintAA - hypot(v.x, v.y)))
                    guard coverage > 0 else { continue }
                    let pixel = y * width + x, offset = pixel * 4
                    XCTAssertTrue(inside(p, fixture.polygons[side]))
                    XCTAssertGreaterThan(edgeDistance(p, fixture.polygons[side]), 2.5)
                    XCTAssertFalse(fixture.lidPixels.contains(offset))
                    glintSupport[side].insert(pixel)
                    // Actual RGB white with an analytic one-pixel AA edge;
                    // the old G/B-only marker retains its dark red channel.
                    for channel in 0..<3 {
                        let original = Double(fixture.source[offset + channel])
                        source[offset + channel] = UInt8((original + coverage * (255 - original)).rounded())
                    }
                    // A fixed conservative part of the AA payload. R starts
                    // at 40 here; min RGB >= 160 means coverage >= 120/215,
                    // well beyond median+32 and luma median+50 in this fixture.
                    // We do not require below-threshold AA fringe restoration.
                    if (0..<3).allSatisfy({ source[offset + $0] >= 160 }) {
                        restorePixels[side].insert(pixel)
                    }
                }
            }
            XCTAssertFalse(restorePixels[side].isEmpty)
            XCTAssertLessThanOrEqual(Double(glintSupport[side].count), 0.04 * Double.pi * radius * radius,
                "4% constrains the source bright plus analytic AA material")

            var remainingAA = glintSupport[side], sourceComponentCount = 0
            while let start = remainingAA.first {
                sourceComponentCount += 1
                var component = [start], queue = [start]
                remainingAA.remove(start)
                while let pixel = queue.popLast() {
                    for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                        let x = pixel % width + dx, y = pixel / width + dy
                        if x >= 0 && x < width && y >= 0 && y < height,
                           remainingAA.remove(y * width + x) != nil {
                            queue.append(y * width + x)
                            component.append(y * width + x)
                        }
                    } }
                }
                let xs = component.map { $0 % width }, ys = component.map { $0 / width }
                // Include entire pixel squares rather than measuring only the
                // center-to-center span: this is a conservative source bbox.
                let spanX = Double(try XCTUnwrap(xs.max()) - XCTUnwrap(xs.min()) + 1)
                let spanY = Double(try XCTUnwrap(ys.max()) - XCTUnwrap(ys.min()) + 1)
                XCTAssertEqual(spanX, 7)
                XCTAssertEqual(spanY, 7)
                XCTAssertLessThanOrEqual(max(spanX, spanY), 0.4 * radius,
                    "a circle's material diameter limits the source bbox sides")
                XCTAssertGreaterThan(hypot(spanX, spanY), 0.4 * radius,
                    "this qualified circle deliberately exceeds the mistaken diameter-as-diagonal bound")
            }
            XCTAssertEqual(sourceComponentCount, 1)

            var sourceHalo = Set<Int>()
            for pixel in glintSupport[side] {
                for dy in -1...1 { for dx in -1...1 {
                    sourceHalo.insert((pixel / width + dy) * width + pixel % width + dx)
                } }
            }
            XCTAssertTrue(glintSupport[side].isSubset(of: sourceHalo))
            XCTAssertGreaterThan(Double(sourceHalo.count), 0.04 * Double.pi * radius * radius,
                "the fixed Chebyshev-1 sampling halo deliberately exceeds the material budget")
            XCTAssertEqual(glintSupport[side].count, 37)
            XCTAssertEqual(sourceHalo.count, 69)

            let corners = [fixture.polygons[side][0], fixture.polygons[side][8]]
            let collarRadius = 0.08 * hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
            let sourceMaterialRadius = radius - sqrt(2)
            let windowRadius = (100.0 / 79 + 1) * radius
            func assertLegalOpaqueTap(_ tap: SIMD2<Double>) {
                XCTAssertTrue(tap.x >= 0.5 && tap.x <= Double(width) - 0.5
                    && tap.y >= 0.5 && tap.y <= Double(height) - 0.5)
                XCTAssertTrue(inside(tap, fixture.polygons[side]))
                XCTAssertGreaterThan(edgeDistance(tap, fixture.polygons[side]), 1)
                let v = tap - centers[side]
                XCTAssertLessThan(hypot(v.x, v.y), sourceMaterialRadius)
                XCTAssertGreaterThan(windowRadius - hypot(v.x, v.y), sqrt(2))
                XCTAssertTrue(corners.allSatisfy { hypot(tap.x - $0.x, tap.y - $0.y) > collarRadius })
                let x = Int(tap.x - 0.5), y = Int(tap.y - 0.5)
                XCTAssertEqual(source[(y * width + x) * 4 + 3], 255)
            }
            for pixel in sourceHalo {
                let p = SIMD2(Double(pixel % width) + 0.5, Double(pixel / width) + 0.5)
                for tap in [p, p + SIMD2(1, 0), p + SIMD2(0, 1), p + SIMD2(1, 1)] {
                    assertLegalOpaqueTap(tap)
                }
            }

            // Two distinct independently legal same-eye source stencils are
            // available outside this AA/halo; no ownership/donor gate is
            // weakened simply to make the larger sampling halo admissible.
            var donorStencils = [[Int]]()
            for q in [centers[side] + SIMD2(-0.2 * radius, -0.2 * radius),
                      centers[side] + SIMD2(0.2 * radius, -0.2 * radius)] {
                let x0 = floor(q.x - 0.5), y0 = floor(q.y - 0.5)
                let footprint = [SIMD2(x0 + 0.5, y0 + 0.5), SIMD2(x0 + 1.5, y0 + 0.5),
                                 SIMD2(x0 + 0.5, y0 + 1.5), SIMD2(x0 + 1.5, y0 + 1.5)]
                var stencil = [Int]()
                for tap in footprint {
                    assertLegalOpaqueTap(tap)
                    let pixel = Int(tap.y - 0.5) * width + Int(tap.x - 0.5)
                    XCTAssertFalse(sourceHalo.contains(pixel))
                    stencil.append(pixel)
                }
                donorStencils.append(stencil)
            }
            XCTAssertNotEqual(donorStencils[0], donorStencils[1])
        }

        func whitePixels(_ rgba: [UInt8], side: Int) -> Set<Int> {
            var pixels = Set<Int>()
            // A source-fixed whole-opening ROI finds both the original glint
            // and any scaled/displaced duplicate. Sclera red is 200, and the
            // colored G/B marker has red 40; neither can cross this cutoff.
            // With source red 40, 230 corresponds to AA coverage >= 190/215.
            for y in 0..<height { for x in 0..<width {
                let pixel = y * width + x, offset = pixel * 4
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                if inside(p, fixture.polygons[side])
                    && (0..<3).allSatisfy({ rgba[offset + $0] >= 230 }) {
                    pixels.insert(pixel)
                }
            } }
            return pixels
        }

        func componentCount(_ pixels: Set<Int>) -> Int {
            var remaining = pixels, count = 0
            while let start = remaining.first {
                count += 1
                var queue = [start]
                remaining.remove(start)
                while let pixel = queue.popLast() {
                    for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                        let x = pixel % width + dx, y = pixel / width + dy
                        if x >= 0 && x < width && y >= 0 && y < height,
                           remaining.remove(y * width + x) != nil {
                            queue.append(y * width + x)
                        }
                    } }
                }
            }
            return count
        }

        func centroid(_ pixels: Set<Int>) throws -> SIMD2<Double> {
            let count = try XCTUnwrap(pixels.isEmpty ? nil : pixels.count,
                "a broken candidate must not erase every RGB-white source pixel")
            return pixels.reduce(SIMD2<Double>.zero) { moment, pixel in
                moment + SIMD2(Double(pixel % width) + 0.5, Double(pixel / width) + 0.5)
            } / Double(count)
        }

        let sourceWhite = (0..<2).map { whitePixels(source, side: $0) }
        for side in 0..<2 {
            XCTAssertFalse(sourceWhite[side].isEmpty)
            XCTAssertEqual(componentCount(sourceWhite[side]), 1)
            XCTAssertTrue(sourceWhite[side].isSubset(of: restorePixels[side]))
            XCTAssertEqual(whitePixels(fixture.source, side: side).count, 0,
                "the existing colored highlight is explicitly not a white catchlight")
        }

        for fraction: Float in [-1, 1] {
            let scale = try XCTUnwrap(steps.first { $0.0 == fraction }?.1)
            let output = try render(fixture, fraction: fraction, source: source)
            for side in 0..<2 {
                let actualWhite = whitePixels(output, side: side)
                XCTAssertEqual(actualWhite.count, sourceWhite[side].count,
                    "white catchlight area must not shrink or grow with iris scale")
                XCTAssertEqual(componentCount(actualWhite), 1,
                    "exactly one source catchlight, with no detached copy")
                XCTAssertEqual(actualWhite, sourceWhite[side],
                    "the whole-opening bright support stays at source pixels; no displaced or overlapping copy")
                let actualCenter = try centroid(actualWhite)
                let originalCenter = try centroid(sourceWhite[side])
                XCTAssertEqual(actualCenter.x, originalCenter.x, accuracy: 1e-12)
                XCTAssertEqual(actualCenter.y, originalCenter.y, accuracy: 1e-12)
                var restoredDelta = 0
                for pixel in restorePixels[side] {
                    let offset = pixel * 4
                    for channel in 0..<4 {
                        restoredDelta += abs(Int(output[offset + channel]) - Int(source[offset + channel]))
                    }
                }
                XCTAssertEqual(restoredDelta, 0,
                    "eligible white core and strong AA RGB are restored once, byte-exact at the original site")

                var checked = 0, expectedChange = 0, maximumError = 0
                let center = centers[side]
                for y in Int(center.y - radius * 1.3)..<Int(center.y + radius * 1.3) {
                    for x in Int(center.x - radius * 1.3)..<Int(center.x + radius * 1.3) {
                        let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), v = p - center
                        let q = center + v / scale
                        if hypot(v.x, v.y) > scale * (radius - 2)
                            || !inside(p, fixture.polygons[side])
                            || edgeDistance(p, fixture.polygons[side]) <= 2.5 { continue }
                        let x0 = floor(q.x - 0.5), y0 = floor(q.y - 0.5)
                        let footprint = [SIMD2(x0 + 0.5, y0 + 0.5), SIMD2(x0 + 1.5, y0 + 0.5),
                                         SIMD2(x0 + 0.5, y0 + 1.5), SIMD2(x0 + 1.5, y0 + 1.5)]
                        let fromGlint = footprint.contains { tap in
                            let d = tap - glintCenters[side]
                            return hypot(d.x, d.y) <= glintExceptionRadius
                        }
                        let destinationGlint = p - glintCenters[side]
                        // Source-stencil exclusion covers the mapped halo;
                        // destination exclusion covers the original source
                        // restoration halo. Both are frozen source geometry.
                        if fromGlint || hypot(destinationGlint.x, destinationGlint.y) <= glintExceptionRadius
                            || !footprint.allSatisfy({ inside($0, fixture.polygons[side])
                                && edgeDistance($0, fixture.polygons[side]) > 1 }) { continue }
                        let expected = sampledRGB(fixture.source, at: q), offset = (y * width + x) * 4
                        checked += 1
                        for channel in 0..<3 {
                            maximumError = max(maximumError, abs(Int(output[offset + channel]) - Int(expected[channel])))
                            expectedChange += abs(Int(fixture.source[offset + channel]) - Int(expected[channel]))
                        }
                    }
                }
                XCTAssertGreaterThan(checked, 100, "a source-defined non-glint core exercises both axes")
                XCTAssertGreaterThan(expectedChange, 0, "whole-eye abstention cannot pass")
                // Same source geometry, four-tap sampler and RGBA8 allowance
                // as the existing uniform-core test, not an output-fit limit.
                XCTAssertLessThanOrEqual(maximumError, 1,
                    "non-glint iris texture retains the original uniform inverse scale")
            }
            assertProtected(fixture, output, scale: scale, source: source)
            XCTAssertEqual(output, try render(fixture, fraction: fraction, source: source),
                "catchlight extraction/restoration is deterministic")
        }
    }

}

// C54 independent generated-source additions. The complete preceding C53 file,
// including all 17 methods, constants, helpers and thresholds, is byte-preserved.
extension BeautyIrisScaleRemapTests {
    private func c54Footprint(_ q: SIMD2<Double>) -> [SIMD2<Double>] {
        let x0 = floor(q.x - 0.5), y0 = floor(q.y - 0.5)
        return [SIMD2(x0 + 0.5, y0 + 0.5), SIMD2(x0 + 1.5, y0 + 0.5),
                SIMD2(x0 + 0.5, y0 + 1.5), SIMD2(x0 + 1.5, y0 + 1.5)]
    }

    private func c54ComponentCount(_ pixels: Set<Int>) -> Int {
        var remaining = pixels, count = 0
        while let first = remaining.first {
            count += 1
            var queue = [first]
            remaining.remove(first)
            while let pixel = queue.popLast() {
                for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                    let x = pixel % width + dx, y = pixel / width + dy
                    if x >= 0 && x < width && y >= 0 && y < height,
                       remaining.remove(y * width + x) != nil {
                        queue.append(y * width + x)
                    }
                } }
            }
        }
        return count
    }

    private func c54AssertOwnedOpaque(_ tap: SIMD2<Double>, side: Int,
                                     fixture: Fixture, source: [UInt8],
                                     windowRadius: Double,
                                     file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(tap.x >= 0.5 && tap.x <= Double(width) - 0.5
            && tap.y >= 0.5 && tap.y <= Double(height) - 0.5, file: file, line: line)
        let polygon = fixture.polygons[side], corners = [polygon[0], polygon[8]]
        let collar = 0.08 * hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
        XCTAssertTrue(inside(tap, polygon), file: file, line: line)
        XCTAssertGreaterThan(edgeDistance(tap, polygon), 1, file: file, line: line)
        XCTAssertTrue(corners.allSatisfy { hypot(tap.x - $0.x, tap.y - $0.y) > collar },
            file: file, line: line)
        let v = tap - centers[side]
        XCTAssertLessThan(hypot(v.x, v.y), windowRadius, file: file, line: line)
        let offset = (Int(tap.y - 0.5) * width + Int(tap.x - 0.5)) * 4
        XCTAssertFalse(fixture.lidPixels.contains(offset), file: file, line: line)
        // Alpha is inspected only after the source geometry above is certified.
        XCTAssertEqual(source[offset + 3], 255, file: file, line: line)
    }

    private func c54AssertProtected(_ fixture: Fixture, _ output: [UInt8],
                                    scale: Double, source: [UInt8]? = nil,
                                    file: StaticString = #filePath, line: UInt = #line) {
        let source = source ?? fixture.source
        assertProtected(fixture, output, scale: scale, source: source, file: file, line: line)
        let windows = fixture.polygons.enumerated().map { side, polygon -> Double in
            let corners = [polygon[0], polygon[8]]
            let span = hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
            let nearestCorner = corners.map {
                hypot($0.x - centers[side].x, $0.y - centers[side].y)
            }.min()!
            // Original source recipe; this includes the reduced window in the
            // offset/shallow fixture rather than merely the (s+1)R ceiling.
            return min((scale + 1) * radius, nearestCorner - 0.08 * span - sqrt(2) - 1)
        }
        var exteriorDelta = 0, protectedCount = 0
        var collarDelta = 0, collarCount = 0, reducedWindowAnnulusCount = 0
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            var owned = false, inCollar = false
            for side in fixture.polygons.indices {
                let polygon = fixture.polygons[side], corners = [polygon[0], polygon[8]]
                let collar = 0.08 * hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
                let collarOwned = corners.allSatisfy { hypot(p.x - $0.x, p.y - $0.y) > collar }
                inCollar = inCollar || !collarOwned
                let v = p - centers[side], r = hypot(v.x, v.y)
                let openingOwned = inside(p, polygon) && edgeDistance(p, polygon) > 1
                owned = owned || (openingOwned && collarOwned && r < windows[side])
                if openingOwned && collarOwned && windows[side] < (scale + 1) * radius
                    && r >= windows[side] && r < (scale + 1) * radius {
                    reducedWindowAnnulusCount += 1
                }
            }
            if !owned {
                protectedCount += 1
                for channel in 0..<4 {
                    exteriorDelta += abs(Int(output[offset + channel]) - Int(source[offset + channel]))
                }
            }
            if inCollar {
                collarCount += 1
                for channel in 0..<4 {
                    collarDelta += abs(Int(output[offset + channel]) - Int(source[offset + channel]))
                }
            }
        } }
        XCTAssertGreaterThan(protectedCount, width * height / 2, file: file, line: line)
        if windows.contains(where: { $0 < (scale + 1) * radius }) {
            XCTAssertGreaterThan(reducedWindowAnnulusCount, 0,
                "the source-defined truncated-window exterior is actually exercised", file: file, line: line)
        }
        XCTAssertEqual(exteriorDelta, 0,
            "complete original reduced-window, legal-aperture and canthus exterior stays RGBA exact",
            file: file, line: line)
        XCTAssertGreaterThan(collarCount, 0, file: file, line: line)
        XCTAssertEqual(collarDelta, 0, "every original source canthus collar stays RGBA exact", file: file, line: line)
    }


    func testNearCenterSmallWhiteGlintUsesKnownHaloRGBWithoutWholeEyeAbstention() throws {
        let fixture = try fixture()
        var source = fixture.source
        let glintRadius = 1.5
        let glintAA = 0.5
        // The prospective catchlight exception includes the source AA envelope
        // dilated by a fixed one-pixel Chebyshev halo, its mapped footprints,
        // and the original restoration envelope. sqrt(2) is a conservative
        // circular superset of that square halo; it never follows output RGB.
        let glintExceptionRadius = glintRadius + glintAA + sqrt(2)
        let glintCenters = [
            centers[0] + SIMD2(2.5, 1.5),
            centers[1] + SIMD2(-2.5, 1.5),
        ]
        var glintSupport = [Set<Int>](repeating: [], count: 2)
        var restorePixels = [Set<Int>](repeating: [], count: 2)

        for side in 0..<2 {
            let displacement = glintCenters[side] - centers[side]
            // This fixture's actual AA payload and complete four-tap footprint
            // fit inside the median/core eligibility radius. The separately
            // permitted restoration halo need not fit inside .75 R: it must
            // retain legal opening/curve/canthus ownership instead.
            XCTAssertEqual(displacement.x, side == 0 ? 2.5 : -2.5)
            XCTAssertEqual(displacement.y, 1.5)
            XCTAssertEqual(glintCenters[side].x - 0.5, floor(glintCenters[side].x - 0.5))
            XCTAssertEqual(glintCenters[side].y - 0.5, floor(glintCenters[side].y - 0.5))
            XCTAssertLessThan(hypot(displacement.x, displacement.y)
                + glintRadius + glintAA + sqrt(2), 0.75 * radius)
            for y in Int(glintCenters[side].y - 4)...Int(glintCenters[side].y + 4) {
                for x in Int(glintCenters[side].x - 4)...Int(glintCenters[side].x + 4) {
                    let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                    let v = p - glintCenters[side]
                    let coverage = max(0, min(1, glintRadius + glintAA - hypot(v.x, v.y)))
                    guard coverage > 0 else { continue }
                    let pixel = y * width + x, offset = pixel * 4
                    XCTAssertTrue(inside(p, fixture.polygons[side]))
                    XCTAssertGreaterThan(edgeDistance(p, fixture.polygons[side]), 2.5)
                    XCTAssertFalse(fixture.lidPixels.contains(offset))
                    glintSupport[side].insert(pixel)
                    // Actual RGB white with an analytic one-pixel AA edge;
                    // the old G/B-only marker retains its dark red channel.
                    for channel in 0..<3 {
                        let original = Double(fixture.source[offset + channel])
                        source[offset + channel] = UInt8((original + coverage * (255 - original)).rounded())
                    }
                    // A fixed conservative part of the AA payload. R starts
                    // at 40 here; min RGB >= 160 means coverage >= 120/215,
                    // well beyond median+32 and luma median+50 in this fixture.
                    // We do not require below-threshold AA fringe restoration.
                    if (0..<3).allSatisfy({ source[offset + $0] >= 160 }) {
                        restorePixels[side].insert(pixel)
                    }
                }
            }
            XCTAssertFalse(restorePixels[side].isEmpty)
            var sourceEnvelope = Set<Int>()
            // Source-generation truth, not the production detector's mask:
            // take the analytic nonzero AA pixels and their Chebyshev-1 union.
            // The frozen small-component budget owns this entire envelope.
            for pixel in glintSupport[side] {
                for dy in -1...1 { for dx in -1...1 {
                    let x = pixel % width + dx, y = pixel / width + dy
                    XCTAssertTrue(x >= 0 && x < width && y >= 0 && y < height)
                    let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                    XCTAssertTrue(inside(p, fixture.polygons[side]))
                    XCTAssertGreaterThan(edgeDistance(p, fixture.polygons[side]), 1)
                    XCTAssertFalse(fixture.lidPixels.contains((y * width + x) * 4))
                    sourceEnvelope.insert(y * width + x)
                } }
            }
            XCTAssertEqual(glintSupport[side].count, 9)
            XCTAssertEqual(sourceEnvelope.count, 25)
            XCTAssertEqual(c54ComponentCount(glintSupport[side]), 1)
            let xs = glintSupport[side].map { $0 % width }
            let ys = glintSupport[side].map { $0 / width }
            XCTAssertEqual(try XCTUnwrap(xs.max()) - XCTUnwrap(xs.min()) + 1, 3)
            XCTAssertEqual(try XCTUnwrap(ys.max()) - XCTUnwrap(ys.min()) + 1, 3)
            XCTAssertLessThanOrEqual(3, 0.4 * radius)
            XCTAssertTrue(glintSupport[side].isSubset(of: sourceEnvelope))
            XCTAssertLessThanOrEqual(Double(sourceEnvelope.count), 0.04 * Double.pi * radius * radius,
                "the complete source AA envelope plus one-pixel halo must qualify within the frozen 4% budget")

            // Certify every actual halo sample before reading RGB/alpha.
            // The halo is source-known iris; only its AA material is bright.
            let minimumWindow = (1 + 100.0 / 121) * radius
            for pixel in sourceEnvelope {
                let p = SIMD2(Double(pixel % width) + 0.5, Double(pixel / width) + 0.5)
                for tap in c54Footprint(p) {
                    c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                        source: source, windowRadius: minimumWindow)
                    let v = tap - centers[side]
                    XCTAssertLessThan(hypot(v.x, v.y), radius - sqrt(2))
                }
            }
            let knownHalo = centers[side] + SIMD2(side == 0 ? 0.5 : -0.5, 0.5)
            let knownHaloPixel = Int(knownHalo.y - 0.5) * width + Int(knownHalo.x - 0.5)
            XCTAssertTrue(sourceEnvelope.contains(knownHaloPixel))
            XCTAssertFalse(glintSupport[side].contains(knownHaloPixel))
            let knownHaloOffset = knownHaloPixel * 4
            XCTAssertEqual(Array(source[knownHaloOffset..<(knownHaloOffset + 4)]),
                Array(fixture.source[knownHaloOffset..<(knownHaloOffset + 4)]))

            // Independently defined same-radius, distinct donor stencils exist
            // very near c. Both exclude all AA; a known non-AA halo corner is
            // deliberately present, so halo exclusion would reject these.
            let donorPoints = [centers[side] + SIMD2(-0.5, -0.5),
                               centers[side] + SIMD2(-0.5, 0.5)]
            var donorCells = [Set<Int>]()
            for q in donorPoints {
                let v = q - centers[side]
                XCTAssertEqual(hypot(v.x, v.y), sqrt(0.5), accuracy: 1e-12)
                var cells = Set<Int>()
                for tap in c54Footprint(q) {
                    c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                        source: source, windowRadius: minimumWindow)
                    let pixel = Int(tap.y - 0.5) * width + Int(tap.x - 0.5)
                    XCTAssertFalse(glintSupport[side].contains(pixel))
                    cells.insert(pixel)
                }
                XCTAssertFalse(cells.isDisjoint(with: sourceEnvelope))
                donorCells.append(cells)
            }
            XCTAssertNotEqual(donorCells[0], donorCells[1])
        }

        func whitePixels(_ rgba: [UInt8], side: Int) -> Set<Int> {
            var pixels = Set<Int>()
            // A source-fixed whole-opening ROI finds both the original glint
            // and any scaled/displaced duplicate. Sclera red is 200, and the
            // colored G/B marker has red 40; neither can cross this cutoff.
            // With source red 40, 230 corresponds to AA coverage >= 190/215.
            for y in 0..<height { for x in 0..<width {
                let pixel = y * width + x, offset = pixel * 4
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                if inside(p, fixture.polygons[side])
                    && (0..<3).allSatisfy({ rgba[offset + $0] >= 230 }) {
                    pixels.insert(pixel)
                }
            } }
            return pixels
        }

        func componentCount(_ pixels: Set<Int>) -> Int {
            var remaining = pixels, count = 0
            while let start = remaining.first {
                count += 1
                var queue = [start]
                remaining.remove(start)
                while let pixel = queue.popLast() {
                    for dy in -1...1 { for dx in -1...1 where dx != 0 || dy != 0 {
                        let x = pixel % width + dx, y = pixel / width + dy
                        if x >= 0 && x < width && y >= 0 && y < height,
                           remaining.remove(y * width + x) != nil {
                            queue.append(y * width + x)
                        }
                    } }
                }
            }
            return count
        }

        func centroid(_ pixels: Set<Int>) throws -> SIMD2<Double> {
            let count = try XCTUnwrap(pixels.isEmpty ? nil : pixels.count,
                "a broken candidate must not erase every RGB-white source pixel")
            return pixels.reduce(SIMD2<Double>.zero) { moment, pixel in
                moment + SIMD2(Double(pixel % width) + 0.5, Double(pixel / width) + 0.5)
            } / Double(count)
        }

        let sourceWhite = (0..<2).map { whitePixels(source, side: $0) }
        for side in 0..<2 {
            XCTAssertFalse(sourceWhite[side].isEmpty)
            XCTAssertEqual(componentCount(sourceWhite[side]), 1)
            XCTAssertTrue(sourceWhite[side].isSubset(of: restorePixels[side]))
            XCTAssertEqual(whitePixels(fixture.source, side: side).count, 0,
                "the existing colored highlight is explicitly not a white catchlight")
        }

        for fraction: Float in [-1, 1] {
            let scale = try XCTUnwrap(steps.first { $0.0 == fraction }?.1)
            let output = try render(fixture, fraction: fraction, source: source)
            for side in 0..<2 {
                let actualWhite = whitePixels(output, side: side)
                XCTAssertEqual(actualWhite.count, sourceWhite[side].count,
                    "white catchlight area must not shrink or grow with iris scale")
                XCTAssertEqual(componentCount(actualWhite), 1,
                    "exactly one source catchlight, with no detached copy")
                XCTAssertEqual(actualWhite, sourceWhite[side],
                    "the whole-opening bright support stays at source pixels; no displaced or overlapping copy")
                let actualCenter = try centroid(actualWhite)
                let originalCenter = try centroid(sourceWhite[side])
                XCTAssertEqual(actualCenter.x, originalCenter.x, accuracy: 1e-12)
                XCTAssertEqual(actualCenter.y, originalCenter.y, accuracy: 1e-12)
                var restoredDelta = 0
                for pixel in restorePixels[side] {
                    let offset = pixel * 4
                    for channel in 0..<4 {
                        restoredDelta += abs(Int(output[offset + channel]) - Int(source[offset + channel]))
                    }
                }
                XCTAssertEqual(restoredDelta, 0,
                    "eligible white core and strong AA RGB are restored once, byte-exact at the original site")

                var checked = 0, expectedChange = 0, maximumError = 0
                let center = centers[side]
                for y in Int(center.y - radius * 1.3)..<Int(center.y + radius * 1.3) {
                    for x in Int(center.x - radius * 1.3)..<Int(center.x + radius * 1.3) {
                        let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), v = p - center
                        let q = center + v / scale
                        if hypot(v.x, v.y) > scale * (radius - 2)
                            || !inside(p, fixture.polygons[side])
                            || edgeDistance(p, fixture.polygons[side]) <= 2.5 { continue }
                        let x0 = floor(q.x - 0.5), y0 = floor(q.y - 0.5)
                        let footprint = [SIMD2(x0 + 0.5, y0 + 0.5), SIMD2(x0 + 1.5, y0 + 0.5),
                                         SIMD2(x0 + 0.5, y0 + 1.5), SIMD2(x0 + 1.5, y0 + 1.5)]
                        let fromGlint = footprint.contains { tap in
                            let d = tap - glintCenters[side]
                            return hypot(d.x, d.y) <= glintExceptionRadius
                        }
                        let destinationGlint = p - glintCenters[side]
                        // Source-stencil exclusion covers the mapped halo;
                        // destination exclusion covers the original source
                        // restoration halo. Both are frozen source geometry.
                        if fromGlint || hypot(destinationGlint.x, destinationGlint.y) <= glintExceptionRadius
                            || !footprint.allSatisfy({ inside($0, fixture.polygons[side])
                                && edgeDistance($0, fixture.polygons[side]) > 1 }) { continue }
                        let expected = sampledRGB(fixture.source, at: q), offset = (y * width + x) * 4
                        checked += 1
                        for channel in 0..<3 {
                            maximumError = max(maximumError, abs(Int(output[offset + channel]) - Int(expected[channel])))
                            expectedChange += abs(Int(fixture.source[offset + channel]) - Int(expected[channel]))
                        }
                    }
                }
                XCTAssertGreaterThan(checked, 100, "a source-defined non-glint core exercises both axes")
                XCTAssertGreaterThan(expectedChange, 0, "whole-eye abstention cannot pass")
                // Same source geometry, four-tap sampler and RGBA8 allowance
                // as the existing uniform-core test, not an output-fit limit.
                XCTAssertLessThanOrEqual(maximumError, 1,
                    "non-glint iris texture retains the original uniform inverse scale")
            }
            c54AssertProtected(fixture, output, scale: scale, source: source)
            XCTAssertEqual(output, try render(fixture, fraction: fraction, source: source),
                "catchlight extraction/restoration is deterministic")
        }
    }


    private func c54OffsetShallowOpeningFixture() throws -> (Fixture, Double) {
        let base = try fixture()
        let halfWidth = 64.0, lowerHeight = 34.944, openingOffsetX = 20.0
        let fixedPoint = centers[0] + SIMD2(7.5, -4.5)
        func contour(side: Int, upperHeight: Double) -> [SIMD2<Double>] {
            (0..<16).map { index in
                let angle = Double(index) * 2 * Double.pi / 16, vertical = sin(angle)
                return centers[side] + SIMD2(openingOffsetX + halfWidth * cos(angle),
                    (vertical < 0 ? upperHeight : lowerHeight) * vertical)
            }
        }
        func signedClearance(_ upperHeight: Double) -> Double {
            let polygon = contour(side: 0, upperHeight: upperHeight)
            let distance = edgeDistance(fixedPoint, polygon)
            return inside(fixedPoint, polygon) ? distance : -distance
        }
        // The single new aperture parameter is fixed by SOURCE geometry only:
        // p must be just outside the independently forbidden one-pixel strip.
        // No candidate output, sampled color, radius fit or success is involved.
        var low = 0.1, high = 20.0
        XCTAssertLessThan(signedClearance(low), 1.005)
        XCTAssertGreaterThan(signedClearance(high), 1.005)
        for _ in 0..<80 {
            let mid = (low + high) * 0.5
            if signedClearance(mid) < 1.005 { low = mid } else { high = mid }
        }
        let upperHeight = (low + high) * 0.5
        XCTAssertEqual(signedClearance(upperHeight), 1.005, accuracy: 1e-10)
        XCTAssertGreaterThan(upperHeight, 5)
        XCTAssertLessThan(upperHeight, 6)

        let normalizedContours = (0..<2).map { side in
            contour(side: side, upperHeight: upperHeight).map {
                SIMD2<Float>(Float($0.x / Double(width)), Float($0.y / Double(height)))
            }
        }
        func eye(_ side: Int) -> BeautyEyeSemanticSupport {
            let observedSide: BeautyObservedEyeSide = side == 0 ? .left : .right
            let points = normalizedContours[side]
            let inner = side == 0 ? points[0] : points[8]
            let outer = side == 0 ? points[8] : points[0]
            return BeautyEyeSemanticSupport(side: observedSide, contour: points,
                upper: points.filter { $0.y < Float(centers[side].y / Double(height)) },
                lower: points.filter { $0.y > Float(centers[side].y / Double(height)) },
                inner: [inner], outer: [outer], corners: [inner, outer],
                center: SIMD2(Float((centers[side].x + openingOffsetX) / Double(width)),
                              Float(centers[side].y / Double(height))),
                pupil: SIMD2(Float(centers[side].x / Double(width)), Float(centers[side].y / Double(height))),
                span: SIMD2(Float(halfWidth * 2 / Double(width)),
                            Float((upperHeight + lowerHeight) / Double(height))), tilt: 0)
        }
        let left = eye(0), right = eye(1)
        // The original dense 478-point circular iris c/R and fresh pose are
        // carried unchanged; only the independently generated opening changes.
        let dense = try XCTUnwrap(base.face.denseSupport)
        XCTAssertEqual(dense.mesh.points.count, 478)
        XCTAssertEqual(dense.geometryScale, 1)
        let face = FaceGeometry(bounds: base.face.bounds, faceContour: [],
            leftEye: left.contour, rightEye: right.contour,
            leftEyeSupport: left, rightEyeSupport: right, freshness: .fresh, denseSupport: dense)
        let polygons = normalizedContours.map { $0.map {
            SIMD2(Double($0.x) * Double(width), Double($0.y) * Double(height))
        } }
        var source = [UInt8](repeating: 255, count: width * height * 4)
        var lidPixels = Set<Int>()
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let side = x < width / 2 ? 0 : 1, polygon = polygons[side]
            let offset = (y * width + x) * 4
            var color = SIMD3<Double>(166 + Double(x % 7), 91 + Double(y % 5), 143)
            if inside(p, polygon) {
                let v = p - centers[side]
                if hypot(v.x, v.y) < radius + 2 {
                    // Keep the prior independent analytic circle, G/B texture
                    // and colored marker exactly, through its full limbus AA.
                    color = SIMD3(Double(base.source[offset]), Double(base.source[offset + 1]),
                                  Double(base.source[offset + 2]))
                } else {
                    color = SIMD3(200, 220, 220)
                }
            }
            if edgeDistance(p, polygon) <= 1 {
                color = SIMD3(25 + Double((x + y) % 2) * 45,
                    51 + Double(x % 3) * 31, 102 + Double(y % 3) * 29)
                lidPixels.insert(offset)
            }
            for channel in 0..<3 { source[offset + channel] = UInt8(color[channel].rounded()) }
        } }
        return (Fixture(face: face, polygons: polygons, source: source, lidPixels: lidPixels), upperHeight)
    }

    func testPositiveQuarterCoreOpeningOcclusionUsesLegalSameRadiusSupportWithoutWholeEyeAbstention() throws {
        let (fixture, upperHeight) = try c54OffsetShallowOpeningFixture()
        let scale = 400.0 / 379
        XCTAssertEqual(upperHeight, 5.72768000854, accuracy: 1e-9,
            "the opening height is a source-only solution, frozen before candidate execution")
        let windowCeiling = (scale + 1) * radius
        var legalProbes = [[(offset: Int, expected: [UInt8])]](repeating: [], count: 2)
        var expectedChange = [Int](repeating: 0, count: 2)
        for side in 0..<2 {
            let center = centers[side], polygon = fixture.polygons[side]
            let corners = [polygon[0], polygon[8]]
            let span = hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
            XCTAssertEqual(span, 128, accuracy: 0.00004)
            let nearestCorner = corners.map { hypot($0.x - center.x, $0.y - center.y) }.min()!
            let windowRadius = min(windowCeiling, nearestCorner - 0.08 * span - sqrt(2) - 1)
            XCTAssertGreaterThan(windowRadius, scale * radius + sqrt(2) + 1)
            XCTAssertGreaterThan(edgeDistance(center, polygon), sqrt(2))
            let p = center + SIMD2(7.5, -4.5), v = p - center
            let q = center + v / scale
            XCTAssertTrue(inside(p, polygon))
            XCTAssertEqual(edgeDistance(p, polygon), 1.005, accuracy: 0.00002)
            XCTAssertGreaterThan(edgeDistance(p, polygon), 1)
            XCTAssertLessThan(hypot(v.x, v.y), scale * radius)
            XCTAssertEqual(q.x - center.x, 7.10625, accuracy: 1e-12)
            XCTAssertEqual(q.y - center.y, -4.26375, accuracy: 1e-12)
            XCTAssertFalse(fixture.lidPixels.contains((Int(p.y - 0.5) * width + Int(p.x - 0.5)) * 4))
            let footprint = c54Footprint(q)
            let forbidden = footprint.filter { !inside($0, polygon) || edgeDistance($0, polygon) <= 1 }
            XCTAssertEqual(forbidden.count, 1,
                "the inverse core sample really needs a source-opening completion")
            XCTAssertEqual(edgeDistance(try XCTUnwrap(forbidden.first), polygon), 0.9872051,
                accuracy: 0.00004)
            // Hidden q RGB is deliberately never an expected output. Two
            // independently declared same-radius angular donors have fully
            // legal, distinct opaque source stencils in this original eye.
            let sourceVector = q - center, sourceRadius = hypot(sourceVector.x, sourceVector.y)
            let angle = atan2(sourceVector.y, sourceVector.x)
            var donorCells = [Set<Int>]()
            for deltaAngle in [Double.pi / 2, -Double.pi] {
                let donor = center + SIMD2(cos(angle + deltaAngle), sin(angle + deltaAngle)) * sourceRadius
                let donorVector = donor - center
                XCTAssertEqual(hypot(donorVector.x, donorVector.y), sourceRadius, accuracy: 1e-12)
                var cells = Set<Int>()
                let taps = c54Footprint(donor)
                // Complete geometry/opaque support is certified before any
                // RGB-based catchlight-veto qualification below.
                for tap in taps {
                    c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                        source: fixture.source, windowRadius: windowRadius)
                    let tapVector = tap - center
                    XCTAssertLessThan(hypot(tapVector.x, tapVector.y), radius - sqrt(2))
                    cells.insert(Int(tap.y - 0.5) * width + Int(tap.x - 0.5))
                }
                for pixel in cells {
                    let offset = pixel * 4
                    let rgb = SIMD3(Double(fixture.source[offset]), Double(fixture.source[offset + 1]),
                                    Double(fixture.source[offset + 2]))
                    XCTAssertLessThan(max(rgb.x, rgb.y, rgb.z), 250)
                    XCTAssertLessThan(0.2126 * rgb.x + 0.7152 * rgb.y + 0.0722 * rgb.z, 200)
                }
                donorCells.append(cells)
            }
            XCTAssertNotEqual(donorCells[0], donorCells[1])

            // Deep legal lateral probes use the original g(r)=r/s core. They
            // never ask for hidden q colors or follow a candidate's output.
            for dy in 2...9 { for dx in -16...16 where abs(dx) >= 6 {
                let p = center + SIMD2(Double(dx) + 0.5, Double(dy) + 0.5), v = p - center
                if hypot(v.x, v.y) > scale * (radius - 2)
                    || !inside(p, polygon) || edgeDistance(p, polygon) <= 2.5 { continue }
                let q = center + v / scale
                let taps = c54Footprint(q)
                if !taps.allSatisfy({ inside($0, polygon) && edgeDistance($0, polygon) > 1 }) { continue }
                for tap in taps {
                    c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                        source: fixture.source, windowRadius: windowRadius)
                }
                let offset = (Int(p.y - 0.5) * width + Int(p.x - 0.5)) * 4
                let expected = sampledRGB(fixture.source, at: q)
                legalProbes[side].append((offset, expected))
                for channel in 0..<3 {
                    expectedChange[side] += abs(Int(expected[channel]) - Int(fixture.source[offset + channel]))
                }
            } }
            XCTAssertGreaterThan(legalProbes[side].count, 30)
            XCTAssertGreaterThan(expectedChange[side], 0)
        }

        var changed = fixture.source, forbiddenCount = 0
        var safeOffsets = [Int]()
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            let legal = fixture.polygons.contains { inside(p, $0) && edgeDistance(p, $0) > 1 }
            if legal {
                safeOffsets.append(offset)
            } else {
                // Any opening-exterior or <=1px source strip is UNKNOWN.
                // Its arbitrary RGB/alpha cannot affect any safe destination.
                changed[offset] = (x + y) % 2 == 0 ? 255 : 0
                changed[offset + 1] = x % 3 == 0 ? 0 : 255
                changed[offset + 2] = y % 3 == 0 ? 255 : 0
                changed[offset + 3] = UInt8((x + 3 * y) % 256)
                forbiddenCount += 1
            }
        } }
        XCTAssertGreaterThan(forbiddenCount, width * height / 2)
        XCTAssertGreaterThan(safeOffsets.count, 0)
        XCTAssertNotEqual(changed, fixture.source)
        let output = try render(fixture, fraction: 0.25)
        let perturbedOutput = try render(fixture, fraction: 0.25, source: changed)
        for side in 0..<2 {
            var maximumError = 0, actualChange = 0, changedActualChange = 0
            for probe in legalProbes[side] {
                for channel in 0..<3 {
                    maximumError = max(maximumError,
                        abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                        abs(Int(perturbedOutput[probe.offset + channel]) - Int(probe.expected[channel])))
                    actualChange += abs(Int(output[probe.offset + channel]) - Int(fixture.source[probe.offset + channel]))
                    changedActualChange += abs(Int(perturbedOutput[probe.offset + channel]) - Int(changed[probe.offset + channel]))
                }
            }
            XCTAssertLessThanOrEqual(maximumError, 1,
                "the visible lateral iris keeps its original uniform inverse scale")
            XCTAssertGreaterThan(actualChange, 0, "a whole-eye abstention cannot pass the qualified +25 core fixture")
            XCTAssertGreaterThan(changedActualChange, 0, "unknown alpha cannot disable the independently owned iris")
        }
        var safeDelta = 0
        for offset in safeOffsets {
            for channel in 0..<4 {
                safeDelta += abs(Int(output[offset + channel]) - Int(perturbedOutput[offset + channel]))
            }
        }
        XCTAssertEqual(safeDelta, 0, "arbitrary <=1px/exterior unknown RGBA cannot influence any safe opening output")
        c54AssertProtected(fixture, output, scale: scale)
        c54AssertProtected(fixture, perturbedOutput, scale: scale, source: changed)
        XCTAssertEqual(output, try render(fixture, fraction: 0.25))
        XCTAssertEqual(perturbedOutput, try render(fixture, fraction: 0.25, source: changed))
    }
}

// C55 independent source-owned support-budget fixture. The preceding current
// C54 file, all 19 tests, original helpers and thresholds are byte-preserved.
extension BeautyIrisScaleRemapTests {
    private func c55SymmetricallyShallowIrisFixture() throws -> Fixture {
        let base = try fixture(upperScale: 0.35)
        let halfWidth = 51.2, apertureHeight = 34.944 * 0.35
        let contours = centers.map { center in
            (0..<16).map { index in
                let angle = Double(index) * 2 * Double.pi / 16
                return SIMD2<Float>(Float((center.x + halfWidth * cos(angle)) / Double(width)),
                    Float((center.y + apertureHeight * sin(angle)) / Double(height)))
            }
        }
        func eye(_ side: Int) -> BeautyEyeSemanticSupport {
            let points = contours[side]
            let observedSide: BeautyObservedEyeSide = side == 0 ? .left : .right
            let inner = side == 0 ? points[0] : points[8], outer = side == 0 ? points[8] : points[0]
            let center = SIMD2<Float>(Float(centers[side].x / Double(width)),
                                      Float(centers[side].y / Double(height)))
            return BeautyEyeSemanticSupport(side: observedSide, contour: points,
                upper: points.filter { $0.y < center.y }, lower: points.filter { $0.y > center.y },
                inner: [inner], outer: [outer], corners: [inner, outer], center: center, pupil: center,
                span: SIMD2(Float(halfWidth * 2 / Double(width)), Float(apertureHeight * 2 / Double(height))),
                tilt: 0)
        }
        let left = eye(0), right = eye(1), dense = try XCTUnwrap(base.face.denseSupport)
        XCTAssertEqual(dense.mesh.points.count, 478)
        XCTAssertEqual(dense.geometryScale, 1)
        let face = FaceGeometry(bounds: base.face.bounds, faceContour: [],
            leftEye: left.contour, rightEye: right.contour,
            leftEyeSupport: left, rightEyeSupport: right, freshness: .fresh, denseSupport: dense)
        let polygons = contours.map { $0.map {
            SIMD2(Double($0.x) * Double(width), Double($0.y) * Double(height))
        } }
        var source = [UInt8](repeating: 255, count: width * height * 4)
        var lidPixels = Set<Int>()
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            let side = x < width / 2 ? 0 : 1, polygon = polygons[side]
            var color = SIMD3<Double>(166 + Double(x % 7), 91 + Double(y % 5), 143)
            if inside(p, polygon) {
                let v = p - centers[side], r = hypot(v.x, v.y)
                // Source truth is the original analytic radius-17.92 circle.
                // Generate its texture afresh: the prior narrower opening's
                // exterior/lid RGB must not contaminate this new source.
                let coverage = max(0, min(1, radius + 0.5 - r))
                func spot(_ dx: Double, _ dy: Double, sigma: Double = 1.2) -> Double {
                    let q = v - SIMD2(dx, dy)
                    return exp(-(q.x * q.x + q.y * q.y) / (2 * sigma * sigma))
                }
                let green = 130 - 100 * (spot(-0.45 * radius, 0) + spot(0.45 * radius, 0))
                let blue = 130 - 100 * (spot(0, -0.45 * radius) + spot(0, 0.45 * radius))
                let highlight = 125 * spot(-0.35 * radius, 0.3 * radius, sigma: 1.8)
                color = SIMD3(200 - 160 * coverage,
                    220 + coverage * (min(255, green + highlight) - 220),
                    220 + coverage * (min(255, blue + highlight) - 220))
            }
            if edgeDistance(p, polygon) <= 1 {
                color = SIMD3(25 + Double((x + y) % 2) * 45,
                    51 + Double(x % 3) * 31, 102 + Double(y % 3) * 29)
                lidPixels.insert(offset)
            }
            for channel in 0..<3 { source[offset + channel] = UInt8(color[channel].rounded()) }
        } }
        return Fixture(face: face, polygons: polygons, source: source, lidPixels: lidPixels)
    }

    // This independent owner is geometry-only. In particular, no RGBA byte,
    // source alpha, fitted output edge or candidate response defines its count.
    private func c55RegistrationOwns(_ p: SIMD2<Double>, side: Int, fixture: Fixture) -> Bool {
        guard p.x >= 0.5, p.x <= Double(width) - 0.5,
              p.y >= 0.5, p.y <= Double(height) - 0.5 else { return false }
        let center = centers[side], polygon = fixture.polygons[side]
        let corners = [polygon[0], polygon[8]]
        let span = hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
        let collar = 0.08 * span
        let nearestCorner = corners.map { hypot($0.x - center.x, $0.y - center.y) }.min()!
        let registrationWindow = min((1 + 100.0 / 121) * radius,
            nearestCorner - collar - sqrt(2) - 1)
        let v = p - center
        guard hypot(v.x, v.y) < registrationWindow,
              inside(p, polygon), edgeDistance(p, polygon) > 1,
              corners.allSatisfy({ hypot(p.x - $0.x, p.y - $0.y) > collar }) else { return false }
        // The fixture has no nose/lip/brow paths. Its original peer opening is
        // the sole feature rectangle, padded by the unchanged source 1.5px.
        for peer in fixture.polygons.indices where peer != side {
            let path = fixture.polygons[peer]
            if p.x >= path.map(\.x).min()! - 1.5 && p.x <= path.map(\.x).max()! + 1.5
                && p.y >= path.map(\.y).min()! - 1.5 && p.y <= path.map(\.y).max()! + 1.5 {
                return false
            }
        }
        return true
    }

    private func c55BoundarySupportCount(_ fixture: Fixture, side: Int) -> Int {
        (0..<72).filter { index in
            let angle = Double(index) * Double.pi / 36
            let q = centers[side] + SIMD2(cos(angle), sin(angle)) * radius
            return c54Footprint(q).allSatisfy { c55RegistrationOwns($0, side: side, fixture: fixture) }
        }.count
    }

    // Frozen original radial recipe: uniform g(r)=r/s in the circle, then a
    // one-R Hermite band with the original endpoint values and derivatives.
    // Only the source-qualified .189 response changes the expected scale.
    private func c55ExpectedInverseRadius(_ r: Double, scale: Double) -> Double {
        let inner = scale * radius, outer = (scale + 1) * radius
        if r >= outer { return r }
        if r <= inner { return r / scale }
        let t = (r - inner) / radius, t2 = t * t, t3 = t2 * t
        return (2 * t3 - 3 * t2 + 1) * radius
            + (t3 - 2 * t2 + t) * radius / scale
            + (-2 * t3 + 3 * t2) * outer + (t3 - t2) * radius
    }

    func testSymmetricShallowOpeningUsesSourceQualifiedPointNineGainWithUniformRoundSignedIris() throws {
        let fixture = try c55SymmetricallyShallowIrisFixture()
        let quarterSteps: [(Float, Double)] = [
            (-0.25, 4000.0 / 4189), (-0.5, 2000.0 / 2189),
            (-0.75, 4000.0 / 4567), (-1, 1000.0 / 1189),
            (0.25, 4000.0 / 3811), (0.5, 2000.0 / 1811),
            (0.75, 4000.0 / 3433), (1, 1000.0 / 811),
        ]
        XCTAssertEqual(fixture.face.freshness, .fresh)
        // Establish the geometrical qualification BEFORE any render, reading
        // only original aperture/canthus/window bounds and four pixel centers.
        for side in 0..<2 {
            let polygon = fixture.polygons[side]
            XCTAssertEqual(polygon[0].x - centers[side].x, 51.2, accuracy: 0.00003)
            XCTAssertEqual(centers[side].y - polygon[12].y, 12.2304, accuracy: 0.00003)
            XCTAssertEqual(polygon[4].y - centers[side].y, 12.2304, accuracy: 0.00003)
            let count = c55BoundarySupportCount(fixture, side: side)
            XCTAssertEqual(count, 26)
            let fraction = Double(count) / 72
            XCTAssertLessThan(fraction, 0.45)
            let gain = max(0.9, min(1, 2 * fraction))
            XCTAssertEqual(gain, 0.9)
            XCTAssertEqual(0.21 * gain, 0.189, accuracy: 1e-15)
            for (_, scale) in quarterSteps {
                XCTAssertGreaterThan((scale + 1) * radius, scale * radius + sqrt(2) + 1)
            }
        }
        let neutral = BeautyIrisScaleRemap(width: width, height: height, face: fixture.face,
            strengths: strengths(0), sourceRGBA: fixture.source)
        XCTAssertNil(neutral)
        XCTAssertEqual(neutral?.applyRGBA(fixture.source) ?? fixture.source, fixture.source)

        var changed = fixture.source, unknownCount = 0, safeOffsets = [Int]()
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            let legal = fixture.polygons.contains { inside(p, $0) && edgeDistance(p, $0) > 1 }
            if legal {
                safeOffsets.append(offset)
            } else {
                changed[offset] = (x + y) % 2 == 0 ? 255 : 0
                changed[offset + 1] = x % 3 == 0 ? 0 : 255
                changed[offset + 2] = y % 3 == 0 ? 255 : 0
                changed[offset + 3] = UInt8((x + 3 * y) % 256)
                unknownCount += 1
            }
        } }
        XCTAssertGreaterThan(unknownCount, width * height / 2)
        XCTAssertGreaterThan(safeOffsets.count, 0)
        XCTAssertNotEqual(changed, fixture.source)
        let changedNeutral = BeautyIrisScaleRemap(width: width, height: height, face: fixture.face,
            strengths: strengths(0), sourceRGBA: changed)
        XCTAssertNil(changedNeutral)
        XCTAssertEqual(changedNeutral?.applyRGBA(changed) ?? changed, changed)

        let visibleAngles = [-Double.pi / 12, 0, Double.pi / 12,
                             11 * Double.pi / 12, Double.pi, 13 * Double.pi / 12]
        for (fraction, scale) in quarterSteps {
            XCTAssertEqual(scale, 1 / (1 - 0.189 * Double(fraction)), accuracy: 1e-14)
            // All expectations and legal source taps are fixed before render.
            var coreProbes = [[(offset: Int, expected: [UInt8])]](repeating: [], count: 2)
            var limbusProbes = [[(offset: Int, expected: [UInt8])]](repeating: [], count: 2)
            var axisProbes = [[[(offset: Int, expected: [UInt8])]]](repeating: [[], []], count: 2)
            var expectedCoreChange = [Int](repeating: 0, count: 2)
            for side in 0..<2 {
                let center = centers[side], polygon = fixture.polygons[side]
                let window = (scale + 1) * radius
                let corners = [polygon[0], polygon[8]]
                let span = hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
                let nearest = corners.map { hypot($0.x - center.x, $0.y - center.y) }.min()!
                XCTAssertLessThan(window, nearest - 0.08 * span - sqrt(2) - 1,
                    "the original one-R Hermite window is untruncated in this source fixture")
                for y in Int(center.y - radius)..<Int(center.y + radius) {
                    for x in Int(center.x - radius)..<Int(center.x + radius) {
                        let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), v = p - center
                        if hypot(v.x, v.y) > scale * (radius - 2)
                            || !inside(p, polygon) || edgeDistance(p, polygon) <= 2.5 { continue }
                        let q = center + v / scale
                        let taps = c54Footprint(q)
                        if !taps.allSatisfy({ c55RegistrationOwns($0, side: side, fixture: fixture) }) { continue }
                        for tap in taps {
                            c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                                source: fixture.source, windowRadius: window)
                        }
                        let offset = (y * width + x) * 4, expected = sampledRGB(fixture.source, at: q)
                        coreProbes[side].append((offset, expected))
                        for channel in 0..<3 {
                            expectedCoreChange[side] += abs(Int(expected[channel]) - Int(fixture.source[offset + channel]))
                        }
                    }
                }
                XCTAssertGreaterThan(coreProbes[side].count, 100)
                XCTAssertGreaterThan(expectedCoreChange[side], 0)
                // Four source-fixed texture-marker sites exercise X and Y
                // separately; clipping cannot define a new output centroid.
                for axis in 0..<2 { for sign in [-1.0, 1.0] {
                    let p = center + (axis == 0 ? SIMD2(sign * 6.5, 0.5) : SIMD2(0.5, sign * 6.5))
                    let v = p - center, q = center + v / scale
                    XCTAssertTrue(inside(p, polygon))
                    XCTAssertGreaterThan(edgeDistance(p, polygon), 2.5)
                    XCTAssertLessThan(hypot(v.x, v.y), scale * (radius - 2))
                    let taps = c54Footprint(q)
                    XCTAssertTrue(taps.allSatisfy { c55RegistrationOwns($0, side: side, fixture: fixture) })
                    for tap in taps {
                        c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                            source: fixture.source, windowRadius: window)
                    }
                    let offset = (Int(p.y - 0.5) * width + Int(p.x - 0.5)) * 4
                    axisProbes[side][axis].append((offset, sampledRGB(fixture.source, at: q)))
                } }
                // The visible lateral AA edge uses the SAME original g(r),
                // including its Hermite side. This pixel oracle distinguishes
                // .189 from .21 without changing old radius/round thresholds.
                for dy in [-0.5, 0.5] {
                    for dx in -26...25 {
                        let p = center + SIMD2(Double(dx) + 0.5, dy), v = p - center, r = hypot(v.x, v.y)
                        if abs(r - scale * radius) > 2 { continue }
                        XCTAssertTrue(inside(p, polygon))
                        XCTAssertGreaterThan(edgeDistance(p, polygon), 2.5)
                        let sourceR = c55ExpectedInverseRadius(r, scale: scale)
                        let q = center + v * (sourceR / r), taps = c54Footprint(q)
                        XCTAssertTrue(taps.allSatisfy { c55RegistrationOwns($0, side: side, fixture: fixture) })
                        for tap in taps {
                            c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                                source: fixture.source, windowRadius: window)
                        }
                        let offset = (Int(p.y - 0.5) * width + Int(p.x - 0.5)) * 4
                        limbusProbes[side].append((offset, sampledRGB(fixture.source, at: q)))
                    }
                }
                XCTAssertGreaterThanOrEqual(limbusProbes[side].count, 12)
            }

            let output = try render(fixture, fraction: fraction)
            let perturbedOutput = try render(fixture, fraction: fraction, source: changed)
            for side in 0..<2 {
                var coreError = 0, coreEffect = 0, perturbedCoreEffect = 0, limbusError = 0
                for probe in coreProbes[side] {
                    for channel in 0..<3 {
                        coreError = max(coreError,
                            abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                            abs(Int(perturbedOutput[probe.offset + channel]) - Int(probe.expected[channel])))
                        coreEffect += abs(Int(output[probe.offset + channel]) - Int(fixture.source[probe.offset + channel]))
                        perturbedCoreEffect += abs(Int(perturbedOutput[probe.offset + channel]) - Int(changed[probe.offset + channel]))
                    }
                }
                XCTAssertLessThanOrEqual(coreError, 1, "deep legal source texture keeps uniform .189 inverse response")
                XCTAssertGreaterThan(coreEffect, 0, "all eight signed quarters must edit both source irises")
                XCTAssertGreaterThan(perturbedCoreEffect, 0, "unknown RGB/alpha cannot disable an owned iris")
                for axis in 0..<2 {
                    var error = 0, effect = 0
                    for probe in axisProbes[side][axis] {
                        for channel in 0..<3 {
                            error = max(error,
                                abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                                abs(Int(perturbedOutput[probe.offset + channel]) - Int(probe.expected[channel])))
                            effect += abs(Int(output[probe.offset + channel]) - Int(fixture.source[probe.offset + channel]))
                        }
                    }
                    XCTAssertLessThanOrEqual(error, 1, "X and Y source texture markers use the same .189 uniform scale")
                    XCTAssertGreaterThan(effect, 0, "each texture axis responds at every signed quarter")
                }
                for probe in limbusProbes[side] {
                    for channel in 0..<3 {
                        limbusError = max(limbusError,
                            abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                            abs(Int(perturbedOutput[probe.offset + channel]) - Int(probe.expected[channel])))
                    }
                }
                XCTAssertLessThanOrEqual(limbusError, 1,
                    "visible circular limbus keeps the original core/Hermite g with the source-qualified .189 response")
                var radii = [Double]()
                for angle in visibleAngles {
                    let measured = try crossing(output, side: side, angle: angle, scanRadius: scale * radius + 3)
                    XCTAssertEqual(measured, scale * radius, accuracy: 0.75)
                    radii.append(measured)
                }
                XCTAssertLessThan(try XCTUnwrap(radii.max()) - XCTUnwrap(radii.min()), 1,
                    "all independently visible lateral arcs retain one circle")
                XCTAssertEqual((radii[1] - radii[4]) / 2, 0, accuracy: 0.3,
                    "the signed circle stays centered on its original source iris")
            }
            var safeDelta = 0
            for offset in safeOffsets {
                for channel in 0..<4 {
                    safeDelta += abs(Int(output[offset + channel]) - Int(perturbedOutput[offset + channel]))
                }
            }
            XCTAssertEqual(safeDelta, 0, "unknown <=1px/exterior RGBA cannot change any safe opening output or the gain")
            c54AssertProtected(fixture, output, scale: scale)
            c54AssertProtected(fixture, perturbedOutput, scale: scale, source: changed)
            XCTAssertEqual(output, try render(fixture, fraction: fraction))
        }
    }
}

// C56 severe-opening source-budget fixture. The preceding complete C55 file,
// all 20 tests, helpers, response assertions and thresholds are byte-preserved.
extension BeautyIrisScaleRemapTests {
    private func c56ShallowIrisFixture(upperScale: Double, lowerScale: Double) throws -> Fixture {
        let base = try fixture(upperScale: Float(upperScale))
        let halfWidth = 51.2, upperHeight = 34.944 * upperScale, lowerHeight = 34.944 * lowerScale
        let contours = centers.map { center in
            (0..<16).map { index in
                let angle = Double(index) * 2 * Double.pi / 16, vertical = sin(angle)
                let apertureHeight = vertical < 0 ? upperHeight : lowerHeight
                return SIMD2<Float>(Float((center.x + halfWidth * cos(angle)) / Double(width)),
                    Float((center.y + apertureHeight * sin(angle)) / Double(height)))
            }
        }
        func eye(_ side: Int) -> BeautyEyeSemanticSupport {
            let points = contours[side]
            let observedSide: BeautyObservedEyeSide = side == 0 ? .left : .right
            let inner = side == 0 ? points[0] : points[8], outer = side == 0 ? points[8] : points[0]
            let center = SIMD2<Float>(Float(centers[side].x / Double(width)),
                                      Float(centers[side].y / Double(height)))
            return BeautyEyeSemanticSupport(side: observedSide, contour: points,
                upper: points.filter { $0.y < center.y }, lower: points.filter { $0.y > center.y },
                inner: [inner], outer: [outer], corners: [inner, outer], center: center, pupil: center,
                span: SIMD2(Float(halfWidth * 2 / Double(width)), Float((upperHeight + lowerHeight) / Double(height))),
                tilt: 0)
        }
        let left = eye(0), right = eye(1), dense = try XCTUnwrap(base.face.denseSupport)
        XCTAssertEqual(dense.mesh.points.count, 478)
        XCTAssertEqual(dense.geometryScale, 1)
        let face = FaceGeometry(bounds: base.face.bounds, faceContour: [],
            leftEye: left.contour, rightEye: right.contour,
            leftEyeSupport: left, rightEyeSupport: right, freshness: .fresh, denseSupport: dense)
        let polygons = contours.map { $0.map {
            SIMD2(Double($0.x) * Double(width), Double($0.y) * Double(height))
        } }
        var source = [UInt8](repeating: 255, count: width * height * 4)
        var lidPixels = Set<Int>()
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            let side = x < width / 2 ? 0 : 1, polygon = polygons[side]
            var color = SIMD3<Double>(166 + Double(x % 7), 91 + Double(y % 5), 143)
            if inside(p, polygon) {
                let v = p - centers[side], r = hypot(v.x, v.y)
                // Source truth is the original analytic radius-17.92 circle.
                // Generate its texture afresh: the prior narrower opening's
                // exterior/lid RGB must not contaminate this new source.
                let coverage = max(0, min(1, radius + 0.5 - r))
                func spot(_ dx: Double, _ dy: Double, sigma: Double = 1.2) -> Double {
                    let q = v - SIMD2(dx, dy)
                    return exp(-(q.x * q.x + q.y * q.y) / (2 * sigma * sigma))
                }
                let green = 130 - 100 * (spot(-0.45 * radius, 0) + spot(0.45 * radius, 0))
                let blue = 130 - 100 * (spot(0, -0.45 * radius) + spot(0, 0.45 * radius))
                let highlight = 125 * spot(-0.35 * radius, 0.3 * radius, sigma: 1.8)
                color = SIMD3(200 - 160 * coverage,
                    220 + coverage * (min(255, green + highlight) - 220),
                    220 + coverage * (min(255, blue + highlight) - 220))
            }
            if edgeDistance(p, polygon) <= 1 {
                color = SIMD3(25 + Double((x + y) % 2) * 45,
                    51 + Double(x % 3) * 31, 102 + Double(y % 3) * 29)
                lidPixels.insert(offset)
            }
            for channel in 0..<3 { source[offset + channel] = UInt8(color[channel].rounded()) }
        } }
        return Fixture(face: face, polygons: polygons, source: source, lidPixels: lidPixels)
    }


    func testSeverelyShallowOpeningsUseSourceQualifiedSevereGainsAtBothSignedCaps() throws {
        // First geometry intentionally has different source half-apertures:
        // it combines stable upper/lower half-ring ownership into count 24.
        // No candidate output or photo gate determines any source parameter.
        let definitions: [(upper: Double, lower: Double, count: Int, gain: Double)] = [
            (0.33, 0.32, 24, 0.88), (0.30, 0.30, 22, 0.86), (0.25, 0.25, 18, 0.85),
        ]
        let visibleAngles = [-Double.pi / 18, 0, Double.pi / 18,
                             17 * Double.pi / 18, Double.pi, 19 * Double.pi / 18]
        for definition in definitions {
            let fixture = try c56ShallowIrisFixture(upperScale: definition.upper, lowerScale: definition.lower)
            XCTAssertEqual(fixture.face.freshness, .fresh)
            // Source-only 72 directions and their complete four pixel centers
            // establish the gain before rendering; the owner never reads RGBA.
            for side in 0..<2 {
                let polygon = fixture.polygons[side]
                XCTAssertEqual(polygon[0].x - centers[side].x, 51.2, accuracy: 0.00003)
                XCTAssertEqual(centers[side].y - polygon[12].y, 34.944 * definition.upper, accuracy: 0.00003)
                XCTAssertEqual(polygon[4].y - centers[side].y, 34.944 * definition.lower, accuracy: 0.00003)
                let count = c55BoundarySupportCount(fixture, side: side)
                XCTAssertEqual(count, definition.count)
                XCTAssertLessThanOrEqual(count, 24)
                let fraction = Double(count) / 72
                let sourceGain = max(0.85, 0.88 - 0.72 * (1.0 / 3 - fraction))
                XCTAssertEqual(sourceGain, definition.gain, accuracy: 1e-15)
            }
            let neutral = BeautyIrisScaleRemap(width: width, height: height, face: fixture.face,
                strengths: strengths(0), sourceRGBA: fixture.source)
            XCTAssertNil(neutral)
            XCTAssertEqual(neutral?.applyRGBA(fixture.source) ?? fixture.source, fixture.source)

            var changed = fixture.source, unknownCount = 0, safeOffsets = [Int]()
            for y in 0..<height { for x in 0..<width {
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
                let legal = fixture.polygons.contains { inside(p, $0) && edgeDistance(p, $0) > 1 }
                if legal {
                    safeOffsets.append(offset)
                } else {
                    changed[offset] = (x + y) % 2 == 0 ? 255 : 0
                    changed[offset + 1] = x % 3 == 0 ? 0 : 255
                    changed[offset + 2] = y % 3 == 0 ? 255 : 0
                    changed[offset + 3] = UInt8((x + 3 * y) % 256)
                    unknownCount += 1
                }
            } }
            XCTAssertGreaterThan(unknownCount, width * height / 2)
            XCTAssertGreaterThan(safeOffsets.count, 0)
            XCTAssertNotEqual(changed, fixture.source)
            let changedNeutral = BeautyIrisScaleRemap(width: width, height: height, face: fixture.face,
                strengths: strengths(0), sourceRGBA: changed)
            XCTAssertNil(changedNeutral)
            XCTAssertEqual(changedNeutral?.applyRGBA(changed) ?? changed, changed)

            for signedCap: Float in [-1, 1] {
                let scale = 1 / (1 - 0.21 * definition.gain * Double(signedCap))
                let window = (scale + 1) * radius
                var coreProbes = [[(offset: Int, expected: [UInt8])]](repeating: [], count: 2)
                var limbusProbes = [[(offset: Int, expected: [UInt8])]](repeating: [], count: 2)
                var axisProbes = [[[(offset: Int, expected: [UInt8])]]](repeating: [[], []], count: 2)
                var expectedCoreChange = [Int](repeating: 0, count: 2)
                // The original g(r), source circle and all expected taps are
                // fixed before any candidate output. Only this pure owner
                // category supplies the explicit .88/.86/.85 strength gain.
                for side in 0..<2 {
                    let center = centers[side], polygon = fixture.polygons[side]
                    let corners = [polygon[0], polygon[8]]
                    let span = hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
                    let nearest = corners.map { hypot($0.x - center.x, $0.y - center.y) }.min()!
                    XCTAssertLessThan(window, nearest - 0.08 * span - sqrt(2) - 1)
                    for y in Int(center.y - radius)..<Int(center.y + radius) {
                        for x in Int(center.x - radius)..<Int(center.x + radius) {
                            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), v = p - center
                            if hypot(v.x, v.y) > scale * (radius - 2)
                                || !inside(p, polygon) || edgeDistance(p, polygon) <= 2.5 { continue }
                            let q = center + v / scale, taps = c54Footprint(q)
                            if !taps.allSatisfy({ c55RegistrationOwns($0, side: side, fixture: fixture) }) { continue }
                            for tap in taps {
                                c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                                    source: fixture.source, windowRadius: window)
                            }
                            let offset = (y * width + x) * 4, expected = sampledRGB(fixture.source, at: q)
                            coreProbes[side].append((offset, expected))
                            for channel in 0..<3 {
                                expectedCoreChange[side] += abs(Int(expected[channel]) - Int(fixture.source[offset + channel]))
                            }
                        }
                    }
                    XCTAssertGreaterThan(coreProbes[side].count, 100)
                    XCTAssertGreaterThan(expectedCoreChange[side], 0)
                    // The original Gaussian's source-fixed slope sites at
                    // +/-5.5px remain deep/legal even in the narrowest opening.
                    for axis in 0..<2 {
                        var expectedAxisChange = 0
                        for sign in [-1.0, 1.0] {
                            let p = center + (axis == 0 ? SIMD2(sign * 5.5, 0.5) : SIMD2(0.5, sign * 5.5))
                            let v = p - center, q = center + v / scale
                            XCTAssertTrue(inside(p, polygon))
                            XCTAssertGreaterThan(edgeDistance(p, polygon), 2.5)
                            XCTAssertLessThan(hypot(v.x, v.y), scale * (radius - 2))
                            let taps = c54Footprint(q)
                            XCTAssertTrue(taps.allSatisfy { c55RegistrationOwns($0, side: side, fixture: fixture) })
                            for tap in taps {
                                c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                                    source: fixture.source, windowRadius: window)
                            }
                            let offset = (Int(p.y - 0.5) * width + Int(p.x - 0.5)) * 4
                            let expected = sampledRGB(fixture.source, at: q)
                            axisProbes[side][axis].append((offset, expected))
                            for channel in 0..<3 {
                                expectedAxisChange += abs(Int(expected[channel]) - Int(fixture.source[offset + channel]))
                            }
                        }
                        XCTAssertGreaterThan(expectedAxisChange, 0,
                            "source-defined X and Y slope probes independently reject zero effect at both caps")
                    }
                    for dy in [-0.5, 0.5] {
                        for dx in -26...25 {
                            let p = center + SIMD2(Double(dx) + 0.5, dy), v = p - center, r = hypot(v.x, v.y)
                            if abs(r - scale * radius) > 2 { continue }
                            XCTAssertTrue(inside(p, polygon))
                            XCTAssertGreaterThan(edgeDistance(p, polygon), 2.5)
                            let sourceR = c55ExpectedInverseRadius(r, scale: scale)
                            let q = center + v * (sourceR / r), taps = c54Footprint(q)
                            XCTAssertTrue(taps.allSatisfy { c55RegistrationOwns($0, side: side, fixture: fixture) })
                            for tap in taps {
                                c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                                    source: fixture.source, windowRadius: window)
                            }
                            let offset = (Int(p.y - 0.5) * width + Int(p.x - 0.5)) * 4
                            limbusProbes[side].append((offset, sampledRGB(fixture.source, at: q)))
                        }
                    }
                    XCTAssertGreaterThanOrEqual(limbusProbes[side].count, 12)
                    // Certify the complete destination and inverse-source
                    // footprints of each independent visible ray before RGB.
                    for angle in visibleAngles {
                        let direction = SIMD2(cos(angle), sin(angle))
                        var r = 0.25
                        while r <= scale * radius + 3 {
                            let p = center + direction * r
                            let q = center + direction * c55ExpectedInverseRadius(r, scale: scale)
                            for tap in c54Footprint(p) {
                                XCTAssertTrue(inside(tap, polygon))
                                XCTAssertGreaterThan(edgeDistance(tap, polygon), 2.5)
                            }
                            let sourceTaps = c54Footprint(q)
                            XCTAssertTrue(sourceTaps.allSatisfy { c55RegistrationOwns($0, side: side, fixture: fixture) })
                            for tap in sourceTaps {
                                c54AssertOwnedOpaque(tap, side: side, fixture: fixture,
                                    source: fixture.source, windowRadius: window)
                            }
                            r += 0.25
                        }
                    }
                }

                let output = try render(fixture, fraction: signedCap)
                let perturbedOutput = try render(fixture, fraction: signedCap, source: changed)
                for side in 0..<2 {
                    var coreError = 0, effect = 0, perturbedEffect = 0, limbusError = 0
                    for probe in coreProbes[side] {
                        for channel in 0..<3 {
                            coreError = max(coreError,
                                abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                                abs(Int(perturbedOutput[probe.offset + channel]) - Int(probe.expected[channel])))
                            effect += abs(Int(output[probe.offset + channel]) - Int(fixture.source[probe.offset + channel]))
                            perturbedEffect += abs(Int(perturbedOutput[probe.offset + channel]) - Int(changed[probe.offset + channel]))
                        }
                    }
                    XCTAssertLessThanOrEqual(coreError, 1, "severe source-qualified gain preserves original uniform core g")
                    XCTAssertGreaterThan(effect, 0)
                    XCTAssertGreaterThan(perturbedEffect, 0, "unknown RGBA cannot disable the owned signed iris")
                    for axis in 0..<2 {
                        var error = 0, axisEffect = 0
                        for probe in axisProbes[side][axis] {
                            for channel in 0..<3 {
                                error = max(error,
                                    abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                                    abs(Int(perturbedOutput[probe.offset + channel]) - Int(probe.expected[channel])))
                                axisEffect += abs(Int(output[probe.offset + channel]) - Int(fixture.source[probe.offset + channel]))
                            }
                        }
                        XCTAssertLessThanOrEqual(error, 1, "X/Y texture markers retain the same independently fixed uniform scale")
                        XCTAssertGreaterThan(axisEffect, 0)
                    }
                    for probe in limbusProbes[side] {
                        for channel in 0..<3 {
                            limbusError = max(limbusError,
                                abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                                abs(Int(perturbedOutput[probe.offset + channel]) - Int(probe.expected[channel])))
                        }
                    }
                    XCTAssertLessThanOrEqual(limbusError, 1, "visible limbus uses unchanged core/Hermite g and the source-qualified severe gain")
                    var radii = [Double]()
                    for angle in visibleAngles {
                        let measured = try crossing(output, side: side, angle: angle, scanRadius: scale * radius + 3)
                        XCTAssertEqual(measured, scale * radius, accuracy: 0.75)
                        radii.append(measured)
                    }
                    XCTAssertLessThan(try XCTUnwrap(radii.max()) - XCTUnwrap(radii.min()), 1)
                    XCTAssertEqual((radii[1] - radii[4]) / 2, 0, accuracy: 0.3)
                }
                var safeDelta = 0
                for offset in safeOffsets {
                    for channel in 0..<4 {
                        safeDelta += abs(Int(output[offset + channel]) - Int(perturbedOutput[offset + channel]))
                    }
                }
                XCTAssertEqual(safeDelta, 0, "arbitrary <=1px/exterior unknown RGBA cannot alter safe output or source geometry gain")
                c54AssertProtected(fixture, output, scale: scale)
                c54AssertProtected(fixture, perturbedOutput, scale: scale, source: changed)
                XCTAssertEqual(output, try render(fixture, fraction: signedCap))
            }
        }
    }
}

// C57 source-phase opening-feather contract. The preceding complete C56 file,
// all 21 test methods, helpers, gains and thresholds are byte-preserved.
extension BeautyIrisScaleRemapTests {
    private func c57LowerApertureHeight() -> Double {
        let center = SIMD2<Double>(240.5, 256.5), p = center + SIMD2(16, 16)
        func polygon(_ lowerHeight: Double) -> [SIMD2<Double>] {
            (0..<16).map { index in
                let angle = Double(index) * Double.pi / 8, vertical = sin(angle)
                return center + SIMD2(51.2 * cos(angle), (vertical < 0 ? 34.944 : lowerHeight) * vertical)
            }
        }
        func signedClearance(_ h: Double) -> Double {
            let contour = polygon(h), distance = edgeDistance(p, contour)
            return inside(p, contour) ? distance : -distance
        }
        var low = 0.1, high = 34.944
        XCTAssertLessThan(signedClearance(low), 1.30)
        XCTAssertGreaterThan(signedClearance(high), 1.30)
        // The aperture is solved from source geometry alone. There is no
        // candidate render, source RGB lookup or fitted circle in this solve.
        for _ in 0..<80 {
            let middle = (low + high) * 0.5
            if signedClearance(middle) < 1.30 { low = middle } else { high = middle }
        }
        let h = (low + high) * 0.5
        XCTAssertEqual(signedClearance(h), 1.30, accuracy: 1e-10)
        return h
    }

    private func c57PixelPhaseIrisFixture(phase: Double, lowerHeight: Double) throws -> Fixture {
        let phaseCenters = centers.map { $0 + SIMD2(phase, phase) }
        let halfWidth = 51.2, upperHeight = 34.944
        let contours = phaseCenters.map { center in
            (0..<16).map { index in
                let angle = Double(index) * 2 * Double.pi / 16, vertical = sin(angle)
                let apertureHeight = vertical < 0 ? upperHeight : lowerHeight
                return SIMD2<Float>(Float((center.x + halfWidth * cos(angle)) / Double(width)),
                    Float((center.y + apertureHeight * sin(angle)) / Double(height)))
            }
        }
        func eye(_ side: Int) -> BeautyEyeSemanticSupport {
            let points = contours[side]
            let observedSide: BeautyObservedEyeSide = side == 0 ? .left : .right
            let inner = side == 0 ? points[0] : points[8], outer = side == 0 ? points[8] : points[0]
            let center = SIMD2<Float>(Float(phaseCenters[side].x / Double(width)),
                                      Float(phaseCenters[side].y / Double(height)))
            return BeautyEyeSemanticSupport(side: observedSide, contour: points,
                upper: points.filter { $0.y < center.y }, lower: points.filter { $0.y > center.y },
                inner: [inner], outer: [outer], corners: [inner, outer], center: center, pupil: center,
                span: SIMD2(Float(halfWidth * 2 / Double(width)), Float((upperHeight + lowerHeight) / Double(height))),
                tilt: 0)
        }
        let left = eye(0), right = eye(1)
        // Build a fresh 478-point carrier in THIS source phase. Ring and
        // center positions are explicitly regenerated about the shifted c,
        // preserving radius 17.92 rather than mixing old and shifted points.
        let normalizedPhase = SIMD2<Float>(Float(phase / Double(width)), Float(phase / Double(height)))
        var points = Array(repeating: SIMD3<Float>(0.5 + normalizedPhase.x, 0.5 + normalizedPhase.y, 0), count: 478)
        for (indices, side) in [(MediaPipeFaceTopology.leftIris, 0), (MediaPipeFaceTopology.rightIris, 1)] {
            for (index, landmark) in indices.enumerated() {
                let angle = Double(index) * Double.pi / 2, center = phaseCenters[side]
                points[landmark] = SIMD3(Float((center.x + radius * cos(angle)) / Double(width)),
                    Float((center.y + radius * sin(angle)) / Double(height)), 0)
            }
        }
        for (landmark, side) in [(468, 0), (473, 1)] {
            points[landmark] = SIMD3(Float(phaseCenters[side].x / Double(width)),
                Float(phaseCenters[side].y / Double(height)), 0)
        }
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points))
        let dense = BeautyDenseFaceSupport(mesh: mesh)
        XCTAssertEqual(dense.mesh.points.count, 478)
        XCTAssertEqual(dense.geometryScale, 1)
        let bounds = FaceBounds(x: 0.16 + normalizedPhase.x, y: 0.14 + normalizedPhase.y, width: 0.68, height: 0.7)
        let face = FaceGeometry(bounds: bounds, faceContour: [],
            leftEye: left.contour, rightEye: right.contour,
            leftEyeSupport: left, rightEyeSupport: right, freshness: .fresh, denseSupport: dense)
        let polygons = contours.map { $0.map {
            SIMD2(Double($0.x) * Double(width), Double($0.y) * Double(height))
        } }
        var source = [UInt8](repeating: 255, count: width * height * 4)
        var lidPixels = Set<Int>()
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            let side = x < width / 2 ? 0 : 1, polygon = polygons[side]
            var color = SIMD3<Double>(166 + Double(x % 7), 91 + Double(y % 5), 143)
            if inside(p, polygon) {
                let v = p - phaseCenters[side], r = hypot(v.x, v.y)
                // Source truth is the original analytic radius-17.92 circle.
                // Generate its texture afresh: the prior narrower opening's
                // exterior/lid RGB must not contaminate this new source.
                let coverage = max(0, min(1, radius + 0.5 - r))
                func spot(_ dx: Double, _ dy: Double, sigma: Double = 1.2) -> Double {
                    let q = v - SIMD2(dx, dy)
                    return exp(-(q.x * q.x + q.y * q.y) / (2 * sigma * sigma))
                }
                let green = 130 - 100 * (spot(-0.45 * radius, 0) + spot(0.45 * radius, 0))
                let blue = 130 - 100 * (spot(0, -0.45 * radius) + spot(0, 0.45 * radius))
                let highlight = 125 * spot(-0.35 * radius, 0.3 * radius, sigma: 1.8)
                color = SIMD3(200 - 160 * coverage,
                    220 + coverage * (min(255, green + highlight) - 220),
                    220 + coverage * (min(255, blue + highlight) - 220))
            }
            if edgeDistance(p, polygon) <= 1 {
                color = SIMD3(25 + Double((x + y) % 2) * 45,
                    51 + Double(x % 3) * 31, 102 + Double(y % 3) * 29)
                lidPixels.insert(offset)
            }
            for channel in 0..<3 { source[offset + channel] = UInt8(color[channel].rounded()) }
        } }
        return Fixture(face: face, polygons: polygons, source: source, lidPixels: lidPixels)
    }


    private func c57SourceOwns(_ p: SIMD2<Double>, side: Int, fixture: Fixture,
                              phaseCenters: [SIMD2<Double>]) -> Bool {
        guard p.x >= 0.5, p.x <= Double(width) - 0.5,
              p.y >= 0.5, p.y <= Double(height) - 0.5 else { return false }
        let center = phaseCenters[side], polygon = fixture.polygons[side], corners = [polygon[0], polygon[8]]
        let span = hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
        let nearest = corners.map { hypot($0.x - center.x, $0.y - center.y) }.min()!
        let registrationWindow = min((1 + 100.0 / 121) * radius, nearest - 0.08 * span - sqrt(2) - 1)
        let v = p - center
        guard hypot(v.x, v.y) < registrationWindow, inside(p, polygon), edgeDistance(p, polygon) > 1,
              corners.allSatisfy({ hypot(p.x - $0.x, p.y - $0.y) > 0.08 * span }) else { return false }
        for peer in fixture.polygons.indices where peer != side {
            let path = fixture.polygons[peer]
            if p.x >= path.map(\.x).min()! - 1.5 && p.x <= path.map(\.x).max()! + 1.5
                && p.y >= path.map(\.y).min()! - 1.5 && p.y <= path.map(\.y).max()! + 1.5 { return false }
        }
        return true
    }

    private func c57AssertOpaqueOwnedFootprint(_ taps: [SIMD2<Double>], side: Int,
                                              fixture: Fixture, phaseCenters: [SIMD2<Double>],
                                              file: StaticString = #filePath, line: UInt = #line) {
        // The COMPLETE geometry stencil is certified before reading any RGBA.
        guard taps.allSatisfy({ c57SourceOwns($0, side: side, fixture: fixture, phaseCenters: phaseCenters) }) else {
            XCTFail("an independent four-tap source stencil is not wholly owned", file: file, line: line)
            return
        }
        for tap in taps {
            let offset = (Int(tap.y - 0.5) * width + Int(tap.x - 0.5)) * 4
            XCTAssertFalse(fixture.lidPixels.contains(offset), file: file, line: line)
            XCTAssertEqual(fixture.source[offset + 3], 255, file: file, line: line)
        }
    }

    private func c57WindowRadius(_ fixture: Fixture, side: Int, phaseCenters: [SIMD2<Double>], scale: Double) -> Double {
        let polygon = fixture.polygons[side], center = phaseCenters[side], corners = [polygon[0], polygon[8]]
        let span = hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
        let nearest = corners.map { hypot($0.x - center.x, $0.y - center.y) }.min()!
        return min((scale + 1) * radius, nearest - 0.08 * span - sqrt(2) - 1)
    }

    private func c57ExpectedInverseRadius(_ r: Double, scale: Double, outer: Double) -> Double {
        let inner = scale * radius, h = outer - inner
        if r >= outer { return r }
        if r <= inner { return r / scale }
        let t = (r - inner) / h, t2 = t * t, t3 = t2 * t
        return (2 * t3 - 3 * t2 + 1) * radius + (t3 - 2 * t2 + t) * h / scale
            + (-2 * t3 + 3 * t2) * outer + (t3 - t2) * h
    }

    private func c57AssertProtected(_ fixture: Fixture, _ output: [UInt8], phaseCenters: [SIMD2<Double>],
                                   scale: Double, source: [UInt8]? = nil,
                                   file: StaticString = #filePath, line: UInt = #line) {
        let source = source ?? fixture.source
        let windows = fixture.polygons.indices.map {
            c57WindowRadius(fixture, side: $0, phaseCenters: phaseCenters, scale: scale)
        }
        var protectedDelta = 0, protectedCount = 0, lidDelta = 0, alphaDelta = 0, collarDelta = 0, collarCount = 0
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            var owned = false, inCollar = false
            for side in fixture.polygons.indices {
                let polygon = fixture.polygons[side], corners = [polygon[0], polygon[8]]
                let collar = 0.08 * hypot(corners[0].x - corners[1].x, corners[0].y - corners[1].y)
                let safeCorner = corners.allSatisfy { hypot(p.x - $0.x, p.y - $0.y) > collar }
                inCollar = inCollar || !safeCorner
                let v = p - phaseCenters[side]
                owned = owned || (inside(p, polygon) && edgeDistance(p, polygon) > 1
                    && safeCorner && hypot(v.x, v.y) < windows[side])
            }
            if !owned {
                protectedCount += 1
                for channel in 0..<4 { protectedDelta += abs(Int(output[offset + channel]) - Int(source[offset + channel])) }
            }
            if fixture.lidPixels.contains(offset) {
                for channel in 0..<4 { lidDelta += abs(Int(output[offset + channel]) - Int(source[offset + channel])) }
            }
            if inCollar {
                collarCount += 1
                for channel in 0..<4 { collarDelta += abs(Int(output[offset + channel]) - Int(source[offset + channel])) }
            }
            alphaDelta += abs(Int(output[offset + 3]) - Int(source[offset + 3]))
        } }
        XCTAssertGreaterThan(protectedCount, width * height / 2, file: file, line: line)
        XCTAssertGreaterThan(fixture.lidPixels.count, 0, file: file, line: line)
        XCTAssertGreaterThan(collarCount, 0, file: file, line: line)
        XCTAssertEqual(protectedDelta, 0, "actual phase-aware window/aperture/collar exterior RGBA", file: file, line: line)
        XCTAssertEqual(lidDelta, 0, "the original fixed one-pixel source lid/lash strip", file: file, line: line)
        XCTAssertEqual(collarDelta, 0, "all original source canthus collars", file: file, line: line)
        XCTAssertEqual(alphaDelta, 0, "every source alpha byte", file: file, line: line)
    }

    func testSourcePixelPhaseLegalOpeningFeatherMatchesRawUniformCoreOutsideFixedOnePixelLid() throws {
        let lowerHeight = c57LowerApertureHeight(), scale = 100.0 / 79
        XCTAssertEqual(lowerHeight, 18.45020203495696, accuracy: 1e-9)
        // Only upper/lateral rays with complete legal destination/source
        // footprints are measured. The source-occluded lower arc is excluded.
        let visibleAngles = [-Double.pi / 2, -Double.pi / 4, 0, Double.pi, 5 * Double.pi / 4]
        for phase in [0.0, 0.5] {
            let fixture = try c57PixelPhaseIrisFixture(phase: phase, lowerHeight: lowerHeight)
            let phaseCenters = centers.map { $0 + SIMD2(phase, phase) }
            XCTAssertEqual(fixture.face.freshness, .fresh)
            let dense = try XCTUnwrap(fixture.face.denseSupport)
            XCTAssertEqual(dense.mesh.points.count, 478)
            for (landmark, side) in [(468, 0), (473, 1)] {
                XCTAssertEqual(Double(dense.mesh.points[landmark].x) * Double(width), phaseCenters[side].x, accuracy: 0.00003)
                XCTAssertEqual(Double(dense.mesh.points[landmark].y) * Double(height), phaseCenters[side].y, accuracy: 0.00003)
            }
            var boundaryProbes = [[(offset: Int, expected: [UInt8])]](repeating: [], count: 2)
            var coreProbes = [[(offset: Int, expected: [UInt8])]](repeating: [], count: 2)
            var axisProbes = [[[(offset: Int, expected: [UInt8])]]](repeating: [[], []], count: 2)
            for side in 0..<2 {
                let center = phaseCenters[side], polygon = fixture.polygons[side]
                // Source-only 72-direction full-stencil ownership proves gain
                // exactly one for BOTH phases before output or RGB inspection.
                let count = (0..<72).filter { index in
                    let angle = Double(index) * Double.pi / 36
                    let q = center + SIMD2(cos(angle), sin(angle)) * radius
                    return c54Footprint(q).allSatisfy {
                        c57SourceOwns($0, side: side, fixture: fixture, phaseCenters: phaseCenters)
                    }
                }.count
                XCTAssertGreaterThanOrEqual(count, 36)
                XCTAssertEqual(max(0.9, min(1, 2 * Double(count) / 72)), 1)
                let window = c57WindowRadius(fixture, side: side, phaseCenters: phaseCenters, scale: scale)
                for sign in [-1.0, 1.0] {
                    let p = center + (phase == 0 ? SIMD2(sign * 16.5, 15.5) : SIMD2(sign * 16, 16))
                    let v = p - center, q = center + v / scale
                    XCTAssertEqual(p.x - 0.5, floor(p.x - 0.5))
                    XCTAssertEqual(p.y - 0.5, floor(p.y - 0.5))
                    XCTAssertTrue(inside(p, polygon))
                    XCTAssertGreaterThanOrEqual(edgeDistance(p, polygon), 1.25)
                    if phase == 0 {
                        XCTAssertGreaterThanOrEqual(edgeDistance(p, polygon), 1.5,
                            "the old phase's fixed point already has full original opening coverage")
                    } else {
                        XCTAssertEqual(edgeDistance(p, polygon), 1.30, accuracy: 0.00003)
                    }
                    XCTAssertLessThan(hypot(v.x, v.y), scale * radius)
                    XCTAssertLessThan(hypot((q - center).x, (q - center).y), radius)
                    XCTAssertGreaterThan(window - hypot(v.x, v.y), sqrt(2) + 1)
                    let taps = c54Footprint(q)
                    XCTAssertTrue(taps.allSatisfy { edgeDistance($0, polygon) >= 4 })
                    c57AssertOpaqueOwnedFootprint(taps, side: side, fixture: fixture, phaseCenters: phaseCenters)
                    let offset = (Int(p.y - 0.5) * width + Int(p.x - 0.5)) * 4
                    XCTAssertFalse(fixture.lidPixels.contains(offset))
                    XCTAssertEqual(Array(fixture.source[offset..<(offset + 3)]), [200, 220, 220])
                    let expected = sampledRGB(fixture.source, at: q)
                    XCTAssertGreaterThan(abs(Int(expected[0]) - Int(fixture.source[offset])), 32,
                        "the independently owned raw inverse sample rejects white blending or abstention")
                    boundaryProbes[side].append((offset, expected))
                }
                for y in Int(center.y - radius * 1.3)..<Int(center.y + radius * 1.3) {
                    for x in Int(center.x - radius * 1.3)..<Int(center.x + radius * 1.3) {
                        let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), v = p - center
                        if hypot(v.x, v.y) > scale * (radius - 2)
                            || !inside(p, polygon) || edgeDistance(p, polygon) <= 2.5 { continue }
                        let q = center + v / scale, taps = c54Footprint(q)
                        if !taps.allSatisfy({ c57SourceOwns($0, side: side, fixture: fixture, phaseCenters: phaseCenters) }) { continue }
                        c57AssertOpaqueOwnedFootprint(taps, side: side, fixture: fixture, phaseCenters: phaseCenters)
                        let offset = (y * width + x) * 4, probe = (offset, sampledRGB(fixture.source, at: q))
                        coreProbes[side].append(probe)
                        // Source-fixed pixel-grid sites on each Gaussian slope
                        // define X/Y texture probes correctly in BOTH phases.
                        if abs(v.y) <= 0.75 && abs(v.x) >= radius * 0.18 && abs(v.x) <= radius * 0.4 {
                            axisProbes[side][0].append(probe)
                        }
                        if abs(v.x) <= 0.75 && abs(v.y) >= radius * 0.18 && abs(v.y) <= radius * 0.4 {
                            axisProbes[side][1].append(probe)
                        }
                    }
                }
                XCTAssertEqual(boundaryProbes[side].count, 2)
                XCTAssertGreaterThan(coreProbes[side].count, 100)
                for axis in 0..<2 {
                    XCTAssertFalse(axisProbes[side][axis].isEmpty)
                    let expectedChange = axisProbes[side][axis].reduce(0) { change, probe in
                        change + (0..<3).reduce(0) {
                            $0 + abs(Int(probe.expected[$1]) - Int(fixture.source[probe.offset + $1]))
                        }
                    }
                    XCTAssertGreaterThan(expectedChange, 0, "both source texture axes independently require actual iris scaling")
                }
                for angle in visibleAngles {
                    let direction = SIMD2(cos(angle), sin(angle))
                    var r = 0.25
                    while r <= scale * radius + 3 {
                        let p = center + direction * r
                        let q = center + direction * c57ExpectedInverseRadius(r, scale: scale, outer: window)
                        for tap in c54Footprint(p) {
                            XCTAssertTrue(inside(tap, polygon))
                            XCTAssertGreaterThan(edgeDistance(tap, polygon), 2.5)
                        }
                        c57AssertOpaqueOwnedFootprint(c54Footprint(q), side: side, fixture: fixture, phaseCenters: phaseCenters)
                        r += 0.25
                    }
                }
            }

            var changed = fixture.source, unknownCount = 0, safeOffsets = [Int]()
            for y in 0..<height { for x in 0..<width {
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
                if fixture.polygons.contains(where: { inside(p, $0) && edgeDistance(p, $0) > 1 }) {
                    safeOffsets.append(offset)
                } else {
                    changed[offset] = (x + y) % 2 == 0 ? 255 : 0
                    changed[offset + 1] = x % 3 == 0 ? 0 : 255
                    changed[offset + 2] = y % 3 == 0 ? 255 : 0
                    changed[offset + 3] = UInt8((x + 3 * y) % 256)
                    unknownCount += 1
                }
            } }
            XCTAssertGreaterThan(unknownCount, width * height / 2)
            XCTAssertNotEqual(changed, fixture.source)
            for source in [fixture.source, changed] {
                let neutral = BeautyIrisScaleRemap(width: width, height: height, face: fixture.face,
                    strengths: strengths(0), sourceRGBA: source)
                XCTAssertNil(neutral)
                XCTAssertEqual(neutral?.applyRGBA(source) ?? source, source)
            }
            let output = try render(fixture, fraction: 1)
            let perturbedOutput = try render(fixture, fraction: 1, source: changed)
            for side in 0..<2 {
                for probes in [boundaryProbes[side], coreProbes[side]] {
                    var error = 0, effect = 0
                    for probe in probes {
                        for channel in 0..<3 {
                            error = max(error,
                                abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                                abs(Int(perturbedOutput[probe.offset + channel]) - Int(probe.expected[channel])))
                            effect += abs(Int(output[probe.offset + channel]) - Int(fixture.source[probe.offset + channel]))
                        }
                    }
                    XCTAssertLessThanOrEqual(error, 1,
                        "legal non-glint target SDF>=1.25 uses its complete raw uniform source sample in either pixel phase")
                    XCTAssertGreaterThan(effect, 0)
                }
                for axis in 0..<2 {
                    var error = 0, effect = 0
                    for probe in axisProbes[side][axis] {
                        for channel in 0..<3 {
                            error = max(error,
                                abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                                abs(Int(perturbedOutput[probe.offset + channel]) - Int(probe.expected[channel])))
                            effect += abs(Int(output[probe.offset + channel]) - Int(fixture.source[probe.offset + channel]))
                        }
                    }
                    XCTAssertLessThanOrEqual(error, 1)
                    XCTAssertGreaterThan(effect, 0, "both source-fixed X/Y slopes retain the same nonzero uniform scale")
                }
                // The original crossing helper's center is phase-zero. For the
                // shifted fixture use the identical independent .25px scan and
                // one-crossing measurement about this actual source center.
                var radii = [Double]()
                for angle in visibleAngles {
                    let direction = SIMD2(cos(angle), sin(angle)), center = phaseCenters[side]
                    var previous = red(output, at: center) - 120, crossings = [Double](), r = 0.25
                    while r <= scale * radius + 3 {
                        let value = red(output, at: center + direction * r) - 120
                        if (previous < 0 && value >= 0) || (previous >= 0 && value < 0) {
                            crossings.append(r - 0.25 + 0.25 * previous / (previous - value))
                        }
                        previous = value
                        r += 0.25
                    }
                    XCTAssertEqual(crossings.count, 1)
                    let measured = try XCTUnwrap(crossings.first)
                    XCTAssertEqual(measured, scale * radius, accuracy: 0.75)
                    radii.append(measured)
                }
                XCTAssertLessThan(try XCTUnwrap(radii.max()) - XCTUnwrap(radii.min()), 1)
                XCTAssertEqual((radii[2] - radii[3]) / 2, 0, accuracy: 0.3)
            }
            var safeDelta = 0
            for offset in safeOffsets {
                for channel in 0..<4 { safeDelta += abs(Int(output[offset + channel]) - Int(perturbedOutput[offset + channel])) }
            }
            XCTAssertEqual(safeDelta, 0, "unknown <=1px/exterior RGBA cannot influence safe output or the source-only gain")
            c57AssertProtected(fixture, output, phaseCenters: phaseCenters, scale: scale)
            c57AssertProtected(fixture, perturbedOutput, phaseCenters: phaseCenters, scale: scale, source: changed)
            XCTAssertEqual(output, try render(fixture, fraction: 1))
        }
    }
}

// C58 independent textured-white source fixture. The preceding entire C57
// file, all 22 methods, helpers, gains and oracle thresholds are byte-exact.
extension BeautyIrisScaleRemapTests {
    private func c58TexturedWhiteFixture() throws -> Fixture {
        let base = try fixture()
        var source = base.source
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), side = x < width / 2 ? 0 : 1
            let polygon = base.polygons[side], v = p - centers[side], r = hypot(v.x, v.y)
            if !inside(p, polygon) || edgeDistance(p, polygon) <= 1 || r <= radius + 3 { continue }
            // Source-fixed, smoothly introduced independent white texture.
            // Its start is beyond the true limbus AA/registration support;
            // its position is not selected from any candidate/oracle output.
            let t = max(0, min(1, (r - radius - 3) / 2)), envelope = t * t * (3 - 2 * t)
            let rgb = SIMD3(200 + 12 * envelope * sin(0.8 * v.x + 0.3 * v.y),
                            220 + 10 * envelope * cos(0.35 * v.x - 0.7 * v.y),
                            220 + 8 * envelope * sin(0.5 * v.x + 0.9 * v.y))
            let offset = (y * width + x) * 4
            for channel in 0..<3 { source[offset + channel] = UInt8(rgb[channel].rounded()) }
        } }
        return Fixture(face: base.face, polygons: base.polygons, source: source, lidPixels: base.lidPixels)
    }

    func testSourceDefinedMaterialGuardPreservesTexturedOuterWhiteAndUniformSignedIris() throws {
        let fixture = try c58TexturedWhiteFixture()
        let phaseCenters = centers
        // Complete source cell coverage + bilinear pixel-center footprint,
        // projected through the existing 1.3 scale ceiling; one raster pixel
        // then supplies only the C1 color join. None is a brightness parameter.
        let materialHalo = 1.3 * (sqrt(0.5) + sqrt(2)), colorJoin = 1.0
        var changed = fixture.source, unknownCount = 0, safeOffsets = [Int]()
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), offset = (y * width + x) * 4
            if fixture.polygons.contains(where: { inside(p, $0) && edgeDistance(p, $0) > 1 }) {
                safeOffsets.append(offset)
            } else {
                changed[offset] = (x + y) % 2 == 0 ? 255 : 0
                changed[offset + 1] = x % 3 == 0 ? 0 : 255
                changed[offset + 2] = y % 3 == 0 ? 255 : 0
                changed[offset + 3] = UInt8((x + 3 * y) % 256)
                unknownCount += 1
            }
        } }
        XCTAssertGreaterThan(unknownCount, width * height / 2)
        for source in [fixture.source, changed] {
            let neutral = BeautyIrisScaleRemap(width: width, height: height, face: fixture.face,
                strengths: strengths(0), sourceRGBA: source)
            XCTAssertNil(neutral)
            XCTAssertEqual(neutral?.applyRGBA(source) ?? source, source)
        }
        for (fraction, scale) in steps {
            let plateau = max(radius, scale * radius) + materialHalo, exterior = plateau + colorJoin
            func materialWeight(_ r: Double) -> Double {
                let t = max(0, min(1, (r - plateau) / colorJoin))
                return 1 - t * t * (3 - 2 * t)
            }
            XCTAssertEqual(materialWeight(plateau), 1)
            XCTAssertEqual(materialWeight(exterior), 0)
            let h = 0.00001
            XCTAssertEqual((materialWeight(plateau + h) - materialWeight(plateau)) / h, 0, accuracy: 0.001)
            XCTAssertEqual((materialWeight(exterior) - materialWeight(exterior - h)) / h, 0, accuracy: 0.001)
            var core = [[(offset: Int, expected: [UInt8])]](repeating: [], count: 2)
            var axis = [[[(offset: Int, expected: [UInt8])]]](repeating: [[], []], count: 2)
            var fade = [[(offset: Int, expected: [UInt8])]](repeating: [], count: 2)
            var exteriorOffsets = [[Int]](repeating: [], count: 2)
            var forbiddenOldWhiteTransport = [Int](repeating: 0, count: 2)
            for side in 0..<2 {
                let center = centers[side], polygon = fixture.polygons[side]
                let window = c57WindowRadius(fixture, side: side, phaseCenters: phaseCenters, scale: scale)
                for y in Int(center.y - radius * 1.3)..<Int(center.y + radius * 1.3) {
                    for x in Int(center.x - radius * 1.3)..<Int(center.x + radius * 1.3) {
                        let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), v = p - center
                        if hypot(v.x, v.y) > scale * (radius - 2) || !inside(p, polygon)
                            || edgeDistance(p, polygon) <= 2.5 { continue }
                        let q = center + v / scale, taps = c54Footprint(q)
                        if !taps.allSatisfy({ c55RegistrationOwns($0, side: side, fixture: fixture) }) { continue }
                        c57AssertOpaqueOwnedFootprint(taps, side: side, fixture: fixture, phaseCenters: phaseCenters)
                        let offset = (y * width + x) * 4, probe = (offset, sampledRGB(fixture.source, at: q))
                        core[side].append(probe)
                        if abs(v.y) <= 0.75 && abs(v.x) >= radius * 0.18 && abs(v.x) <= radius * 0.4 {
                            axis[side][0].append(probe)
                        }
                        if abs(v.x) <= 0.75 && abs(v.y) >= radius * 0.18 && abs(v.y) <= radius * 0.4 {
                            axis[side][1].append(probe)
                        }
                    }
                }
                XCTAssertGreaterThan(core[side].count, 100)
                // Legal horizontal white sites are fixed before output. The
                // original mandatory raw g sample would transport this known
                // far-white texture; the requested material support copies it.
                for dy in [-0.5, 0.5] {
                    for dx in -31...30 {
                        let p = center + SIMD2(Double(dx) + 0.5, dy), v = p - center, r = hypot(v.x, v.y)
                        if r < plateau || r > exterior + 3 { continue }
                        XCTAssertTrue(inside(p, polygon))
                        XCTAssertGreaterThan(edgeDistance(p, polygon), 2.5)
                        let q = center + v * (c57ExpectedInverseRadius(r, scale: scale, outer: window) / r)
                        let taps = c54Footprint(q)
                        XCTAssertTrue(taps.allSatisfy { c55RegistrationOwns($0, side: side, fixture: fixture) })
                        c57AssertOpaqueOwnedFootprint(taps, side: side, fixture: fixture, phaseCenters: phaseCenters)
                        XCTAssertGreaterThan(window - max(r, hypot((q - center).x, (q - center).y)), sqrt(2) + 1)
                        let offset = (Int(p.y - 0.5) * width + Int(p.x - 0.5)) * 4
                        let remapped = sampledRGB(fixture.source, at: q)
                        if r >= exterior {
                            for channel in 0..<3 {
                                forbiddenOldWhiteTransport[side] += abs(Int(remapped[channel]) - Int(fixture.source[offset + channel]))
                            }
                        } else {
                            let weight = materialWeight(r)
                            let expected = (0..<3).map { channel in
                                UInt8((Double(fixture.source[offset + channel]) * (1 - weight)
                                    + Double(remapped[channel]) * weight).rounded())
                            }
                            fade[side].append((offset, expected))
                        }
                    }
                }
                XCTAssertGreaterThan(forbiddenOldWhiteTransport[side], 0,
                    "a source-only white texture oracle must distinguish old Hermite color transport from exact copy")
                XCTAssertFalse(fade[side].isEmpty)
                for y in 0..<height { for x in 0..<width {
                    let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), v = p - center
                    if inside(p, polygon) && hypot(v.x, v.y) >= exterior {
                        exteriorOffsets[side].append((y * width + x) * 4)
                    }
                } }
                XCTAssertGreaterThan(exteriorOffsets[side].count, 100)
            }
            let output = try render(fixture, fraction: fraction)
            let perturbed = try render(fixture, fraction: fraction, source: changed)
            for side in 0..<2 {
                var coreError = 0, effect = 0, fadeError = 0, whiteDelta = 0
                for probe in core[side] {
                    for channel in 0..<3 {
                        coreError = max(coreError, abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                            abs(Int(perturbed[probe.offset + channel]) - Int(probe.expected[channel])))
                        effect += abs(Int(output[probe.offset + channel]) - Int(fixture.source[probe.offset + channel]))
                    }
                }
                XCTAssertLessThanOrEqual(coreError, 1)
                XCTAssertGreaterThan(effect, 0, "all eight signed quarters keep a real uniform iris edit")
                for probes in axis[side] {
                    var axisEffect = 0
                    XCTAssertFalse(probes.isEmpty)
                    for probe in probes { for channel in 0..<3 {
                        axisEffect += abs(Int(output[probe.offset + channel]) - Int(fixture.source[probe.offset + channel]))
                    } }
                    XCTAssertGreaterThan(axisEffect, 0)
                }
                for probe in fade[side] { for channel in 0..<3 {
                    fadeError = max(fadeError, abs(Int(output[probe.offset + channel]) - Int(probe.expected[channel])),
                        abs(Int(perturbed[probe.offset + channel]) - Int(probe.expected[channel])))
                } }
                XCTAssertLessThanOrEqual(fadeError, 1, "the source-only material boundary joins through a C1 color fade")
                for offset in exteriorOffsets[side] { for channel in 0..<4 {
                    whiteDelta += abs(Int(output[offset + channel]) - Int(fixture.source[offset + channel]))
                    whiteDelta += abs(Int(perturbed[offset + channel]) - Int(changed[offset + channel]))
                } }
                XCTAssertEqual(whiteDelta, 0, "all source-defined far-white RGBA stays byte-exact instead of being transported")
            }
            var safeDelta = 0
            for offset in safeOffsets { for channel in 0..<4 {
                safeDelta += abs(Int(output[offset + channel]) - Int(perturbed[offset + channel]))
            } }
            XCTAssertEqual(safeDelta, 0)
            c54AssertProtected(fixture, output, scale: scale)
            c54AssertProtected(fixture, perturbed, scale: scale, source: changed)
            if abs(fraction) == 1 { XCTAssertEqual(output, try render(fixture, fraction: fraction)) }
        }
    }
}
