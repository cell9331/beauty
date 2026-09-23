import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

final class PortraitNoseRegistrationTests: XCTestCase {
    private let crest = [0.30, 0.35, 0.40, 0.45, 0.50].map { CoordinatePoint(x: 0.50, y: $0) }
    private let contour = [CoordinatePoint(x: 0.44, y: 0.51), CoordinatePoint(x: 0.46, y: 0.55),
        CoordinatePoint(x: 0.50, y: 0.56), CoordinatePoint(x: 0.54, y: 0.55), CoordinatePoint(x: 0.56, y: 0.51)]
    private func geometry(_ support: BeautyObservedNoseSupport?) -> FaceGeometry {
        BeautyFaceGeometryAdapter.makeGeometry(from: BeautyFaceObservation(
            imageBounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
            landmarks: .complete, observedNoseSupport: support))
    }

    func testObservedNoseOwnsDistinctBandsAndPreservesLegacySiblings() {
        let face = geometry(.init(crest: crest, contour: contour))
        for root in [true, false] {
            var s = BeautyEffectiveStrengths()
            if root { s.noseRootNarrowing = 0.25 } else { s.noseBridge = 0.30 }
            let emitted = NoseWarpProvider().fieldEmissions(face: face, strengths: s).points
            XCTAssertEqual(emitted.count, 2)
            for p in emitted {
                XCTAssertEqual(p.source.y, p.target.y)
                XCTAssertLessThan(abs(p.target.x - 0.5), abs(p.source.x - 0.5))
                XCTAssertGreaterThan(p.target.y - p.radius, root ? 0.30 : 0.35)
                XCTAssertLessThan(p.target.y + p.radius, root ? 0.35 : 0.50)
            }
            if root {
                XCTAssertTrue(HorizontalInwardWarpSafety.accepts(emitted, maximumSlope: 0.8))
                XCTAssertTrue(emitted.allSatisfy { abs($0.target.x - $0.source.x) <= 0.8 * 0.025 })
            } else {
                XCTAssertLessThanOrEqual(emitted.reduce(0.0) {
                    $0 + 2 * abs(Double($1.target.x - $1.source.x)) / Double($1.radius)
                }, 0.45)
            }
        }
        var legacy = BeautyEffectiveStrengths()
        legacy.noseSlim = 0.2; legacy.noseWingSlim = 0.2; legacy.noseTipSize = 0.2; legacy.noseTipLift = 0.2
        XCTAssertEqual(NoseWarpProvider().fieldEmissions(face: face, strengths: legacy),
                       NoseWarpProvider().fieldEmissions(face: geometry(nil), strengths: legacy))
    }

    private func geometryWithEyes() -> FaceGeometry {
        func eye(_ side: BeautyObservedEyeSide, _ x: Float) -> BeautyEyeSemanticSupport {
            let trace: [SIMD2<Float>] = [.init(x - 0.04, 0.28), .init(x, 0.26),
                .init(x + 0.04, 0.28), .init(x, 0.30)]
            return BeautyEyeSemanticSupport(side: side, contour: trace,
                upper: Array(trace.prefix(3)), lower: [trace[0], trace[3], trace[2]],
                inner: [side == .left ? trace[2] : trace[0]],
                outer: [side == .left ? trace[0] : trace[2]], corners: [trace[0], trace[2]],
                center: .init(x, 0.28), pupil: nil, span: .init(0.08, 0.04), tilt: 0)
        }
        let base = geometry(.init(crest: crest, contour: contour))
        return FaceGeometry(bounds: base.bounds, faceContour: base.faceContour,
            nose: base.nose, leftEyeSupport: eye(.left, 0.38),
            rightEyeSupport: eye(.right, 0.62), observedNoseSupport: base.observedNoseSupport)
    }

    func testRootSupportStaysBetweenCrestAndInnerCanthi() {
        let face = geometryWithEyes()
        var active = BeautyEffectiveStrengths(); active.noseRootNarrowing = 0.25
        let points = NoseWarpProvider().fieldEmissions(face: face, strengths: active).noseRootNarrowing
        XCTAssertEqual(points.count, 6)
        checkSeparatedRootRows(points)
        for p in points {
            let eyeBand = p.target.y > 0.26 && p.target.y < 0.30
            XCTAssertGreaterThan(p.target.x - p.radius, eyeBand ? 0.42 : 0.388)
            XCTAssertLessThan(p.target.x + p.radius, eyeBand ? 0.58 : 0.612)
            XCTAssertGreaterThan(p.target.y - p.radius, 0.26 - 0.8 * 0.03)
            XCTAssertLessThan(p.target.y + p.radius, 0.35)
            XCTAssertLessThanOrEqual(abs(p.target.x - p.source.x), 0.8 * 0.04)
            XCTAssertTrue(p.pixelCenterSampling)
        }
        for y in stride(from: Float(0.20), through: 0.40, by: 0.002) {
            var previous: Float = -.infinity
            for x in stride(from: Float(0.388), through: 0.612, by: 0.0005) {
                let sample = points.reduce(x) { sum, point in
                    let delta = SIMD2<Float>(x, y) - point.target
                    let distance = (delta.x * delta.x + delta.y * delta.y).squareRoot()
                    return sum - (point.target.x - point.source.x) * max(0, 1 - distance / point.radius)
                }
                XCTAssertGreaterThan(sample, previous)
                XCTAssertGreaterThanOrEqual(sample, 0.388 - 0.000001)
                XCTAssertLessThanOrEqual(sample, 0.612 + 0.000001)
                if (0.26...0.30).contains(y) && (x <= 0.42 || x >= 0.58) {
                    XCTAssertEqual(sample, x)
                }
                previous = sample
            }
        }
    }

    func testObservedRootContractsGeneratedStructureWithoutEyeOrBridgeChanges() throws {
        try checkRootStructure(bright: false)
    }

    func testObservedRootContractsBrightGeneratedStructure() throws {
        try checkRootStructure(bright: true)
    }

    func testObservedRootDoesNotClaimStationaryOuterStructure() throws {
        try checkRootStructure(bright:false,inner:false)
        try checkRootStructure(bright:true,inner:false)
    }

    private func checkRootStructure(bright: Bool, inner:Bool=true) throws {
        let size = 512, color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        var source = [UInt8](repeating: 255, count: size * size * 4)
        for y in 0..<size { for x in 0..<size {
            let px = (Double(x) + 0.5) / Double(size), py = (Double(y) + 0.5) / Double(size)
            // Fixed source objects: the dorsal material band and, separately,
            // the former much wider outer-base negative control.
            let band:ClosedRange<Double> = inner ? 0.468...0.532 : 0.445...0.555
            let inside = band.contains(px) && (0.24...0.35).contains(py)
            let value: UInt8 = inside != bright ? 40 : 220
            for c in 0..<3 { source[(y * size + x) * 4 + c] = value }
        } }
        let input = CIImage(bitmapData: Data(source), bytesPerRow: size * 4,
            size: CGSize(width: size, height: size), format: .RGBA8, colorSpace: color)
        let face = geometryWithEyes()
        let plan = BeautyEffectResolver.resolve(parameters: .init(noseRootNarrowing: 0.25), faceGeometry: face)
        let rendered = BeautyGeometryEffectPipeline.applyMVPProxy(to: input, plan: plan, face: face)
        var output = [UInt8](repeating: 0, count: source.count)
        CIContext(options: [.workingColorSpace: color, .outputColorSpace: color]).render(
            rendered, toBitmap: &output, rowBytes: size * 4, bounds: input.extent,
            format: .RGBA8, colorSpace: color)
        func widthBounds(_ bytes: [UInt8]) throws -> (lower: Double, upper: Double) {
            var lower = 0.0, upper = 0.0
            for y in 123..<179 {
                let inside = (198..<314).filter { x in
                    let value = bytes[(y * size + x) * 4]
                    return bright ? value > 130 : value < 130
                }
                let first = try XCTUnwrap(inside.first), last = try XCTUnwrap(inside.last)
                XCTAssertEqual(inside, Array(first...last))
                func crossing(_ range: Range<Int>) throws -> (Double, Double) {
                    let values = range.map { Double(bytes[(y * size + $0) * 4]) }
                    let bound = try XCTUnwrap(Self.crossingHull(values))
                    return (Double(range.lowerBound) + 0.5 + bound.0, Double(range.lowerBound) + 0.5 + bound.1)
                }
                let l = try crossing(198..<256), r = try crossing(256..<314)
                lower += r.0 - l.1; upper += r.1 - l.0
            }
            return (lower / 56, upper / 56)
        }
        let beforeWidth = try widthBounds(source), afterWidth = try widthBounds(output)
        if inner {
            XCTAssertGreaterThanOrEqual((beforeWidth.lower - afterWidth.upper) * 65_536 / Double(size), 16)
        } else {
            XCTAssertTrue(source==output,"Stationary outer material must not earn dorsal narrowing credit")
        }
        for y in 0..<size { for x in 0..<size {
            let i = (y * size + x) * 4
            XCTAssertEqual(output[i + 3], source[i + 3])
            let px = (Double(x) + 0.5) / Double(size), py = (Double(y) + 0.5) / Double(size)
            let eye = (0.26...0.30).contains(py) && (px <= 0.42 || px >= 0.58)
            if px <= 0.388 || px >= 0.612 || py <= 0.236 || py >= 0.35 || eye {
                XCTAssertEqual(Array(output[i..<i+4]), Array(source[i..<i+4]))
            }
        } }
    }

    // The interpolated rounded samples have an envelope +/-0.5 everywhere.
    // Intersect that envelope with the threshold on EVERY segment of the
    // fixed generated half-strip. This includes adjacent shallow segments
    // when a sample equals the threshold, without slope extrapolation.
    private static func crossingHull(_ samples: [Double]) -> (Double, Double)? {
        guard samples.count >= 2, samples.allSatisfy(\.isFinite),
              let a = samples.first, let b = samples.last,
              (a + 0.5 < 130 && b - 0.5 > 130) ||
              (b + 0.5 < 130 && a - 0.5 > 130),
              zip(samples, samples.dropFirst()).allSatisfy({ a < b ? $0 <= $1 : $0 >= $1 })
        else { return nil }
        var lower = Double.infinity, upper = -Double.infinity
        for i in 0..<(samples.count - 1) {
            let x = samples[i], y = samples[i + 1]
            if x == y {
                if abs(x - 130) <= 0.5 { lower = min(lower, Double(i)); upper = max(upper, Double(i + 1)) }
                continue
            }
            let p = (129.5 - x) / (y - x), q = (130.5 - x) / (y - x)
            let lo = max(0, min(p, q).nextDown), hi = min(1, max(p, q).nextUp)
            if lo <= hi { lower = min(lower, (Double(i) + lo).nextDown); upper = max(upper, (Double(i) + hi).nextUp) }
        }
        return lower <= upper ? (lower, upper) : nil
    }

    func testGeneratedCrossingRejectsThresholdEndpointForBothPolarities() throws {
        for samples in [[129.0, 130, 220], [131.0, 130, 40]] {
            XCTAssertNil(Self.crossingHull(Array(samples.prefix(2))))
            XCTAssertNil(Self.crossingHull(Array(samples.suffix(2))))
            let hull = try XCTUnwrap(Self.crossingHull(samples))
            // Both rounding signs at the threshold endpoint are possible;
            // independently solve the appropriate actual adjacent segment.
            for rounding in [-0.25, 0.25] {
                let midpoint = samples[1] + rounding
                let before = (samples[0] - 130) * (midpoint - 130) <= 0
                let truth = before ? (130 - samples[0]) / (midpoint - samples[0])
                    : 1 + (130 - midpoint) / (samples[2] - midpoint)
                XCTAssertLessThanOrEqual(hull.0, truth)
                XCTAssertGreaterThanOrEqual(hull.1, truth)
            }
        }
        for (a, b) in [(40.0, 220.0), (220.0, 40.0)] {
            let interval = try XCTUnwrap(Self.crossingHull([a, b]))
            XCTAssertLessThan(interval.0, 0.5)
            XCTAssertGreaterThan(interval.1, 0.5)
        }
    }

    func testInvalidObservedNoseCannotBorrowTemplates() {
        let face = geometryWithEyes()
        for amount: Float in [0.025, 0.05, 0.10, 0.20, 0.25] {
            var s = BeautyEffectiveStrengths(); s.noseRootNarrowing = amount
            let points = NoseWarpProvider().fieldEmissions(face: face, strengths: s).noseRootNarrowing
            XCTAssertEqual(points.count, 6)
            checkSeparatedRootRows(points)
            for point in points {
                let eyeBand = point.target.y > 0.26 && point.target.y < 0.30
                XCTAssertGreaterThan(point.target.x - point.radius, eyeBand ? 0.42 : 0.388, "generated subcap=\(amount)")
                XCTAssertLessThan(point.target.x + point.radius, eyeBand ? 0.58 : 0.612, "generated subcap=\(amount)")
            }
        }
        var active = BeautyEffectiveStrengths(); active.noseBridge = 0.3; active.noseRootNarrowing = 0.25
        for invalid in [[], [crest[0]], [crest[0], crest[0], crest[2]],
                        [CoordinatePoint(x: .nan, y: 0.3)] + Array(crest.dropFirst())] {
            let face = geometry(.init(crest: invalid, contour: contour))
            XCTAssertTrue(NoseWarpProvider().fieldEmissions(face: face, strengths: active).points.isEmpty)
        }
    }

    private func checkSeparatedRootRows(_ points: [WarpControlPoint]) {
        XCTAssertEqual(points.count % 2, 0)
        var previousBottom = -Float.infinity
        for row in stride(from: 0, to: points.count, by: 2) {
            let pair = Array(points[row..<row+2])
            XCTAssertTrue(HorizontalInwardWarpSafety.accepts(pair, maximumSlope: 0.8))
            XCTAssertGreaterThan(pair.map { $0.target.y - $0.radius }.min()!, previousBottom)
            previousBottom = pair.map { $0.target.y + $0.radius }.max()!
        }
    }

    func testActualPixelsAreConfinedToSeparateObservedBands() throws {
        let size = 256, color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        var source = [UInt8](repeating: 255, count: size * size * 4)
        for y in 0..<size { for x in 0..<size {
            source[(y * size + x) * 4] = UInt8((x * 13 + y * 7) % 256)
        } }
        let image = CIImage(bitmapData: Data(source), bytesPerRow: size * 4,
            size: CGSize(width: size, height: size), format: .RGBA8, colorSpace: color)
        let face = geometry(.init(crest: crest, contour: contour))
        func render(_ p: BeautyParameters) -> [UInt8] {
            let plan = BeautyEffectResolver.resolve(parameters: p, faceGeometry: face)
            let result = BeautyGeometryEffectPipeline.applyMVPProxy(to: image, plan: plan, face: face)
            XCTAssertEqual(result.extent, image.extent)
            var bytes = [UInt8](repeating: 0, count: source.count)
            CIContext(options: [.workingColorSpace: color, .outputColorSpace: color]).render(
                result, toBitmap: &bytes, rowBytes: size * 4, bounds: result.extent, format: .RGBA8, colorSpace: color)
            return bytes
        }
        XCTAssertEqual(render(.init()), source)
        for root in [true, false] {
            let p = root ? BeautyParameters(noseRootNarrowing: 0.25) : BeautyParameters(noseBridge: 0.30)
            let result = render(p)
            XCTAssertEqual(result, render(p))
            var changed = 0
            for y in 0..<size { for x in 0..<size {
                let i = (y * size + x) * 4
                XCTAssertEqual(result[i + 3], source[i + 3])
                guard result[i..<i+3] != source[i..<i+3] else { continue }
                changed += 1
                let py = (Double(y) + 0.5) / Double(size)
                XCTAssertGreaterThan(py, root ? 0.30 : 0.35)
                XCTAssertLessThan(py, root ? 0.35 : 0.50)
            } }
            XCTAssertGreaterThan(changed, 20)
        }
    }
}
