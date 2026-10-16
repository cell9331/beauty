import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Independent analytic source lighting. Neither a production weight nor a
/// rendered candidate defines the source edge or the protected material here.
final class JawlineShadowSourceProfileTests: XCTestCase {
    private func edge(_ x: Double) -> Double {
        130 + 170 * sqrt(max(0, 1 - pow((x - 160) / 100, 2)))
    }
    private func phase(_ x: Double, varying: Bool) -> Double {
        varying ? 2 * sin((x - 160) * .pi / 7) : 0
    }
    private func face() -> FaceGeometry {
        func box(_ a: Float, _ b: Float, _ c: Float, _ d: Float) -> [SIMD2<Float>] {
            [SIMD2(a, c), SIMD2(b, c), SIMD2(b, d), SIMD2(a, d)]
        }
        let contour = (0...20).map { i -> SIMD2<Float> in
            let a = Double(i) / 20 * .pi
            return SIMD2(Float((160 - 100 * cos(a)) / 320), Float((130 + 170 * sin(a)) / 400))
        }
        func brow(_ x: Float, side: BeautyObservedEyebrowSide) -> BeautyEyebrowSemanticTrace {
            let p = box(x, x + 0.16, 0.27, 0.29)
            return BeautyEyebrowSemanticTrace(side: side, points: p, innerEndpoint: p[1],
                outerEndpoint: p[0], center: (p[0] + p[2]) * 0.5, apexIndex: 0)
        }
        let nasal = box(0.465, 0.535, 0.42, 0.50).map { CoordinatePoint(x: Double($0.x), y: Double($0.y)) }
        return FaceGeometry(bounds: FaceBounds(x: 0.18, y: 0.18, width: 0.64, height: 0.60),
            faceContour: contour, observedFaceSupport: BeautyFaceSemanticSupport(contour: contour,
                medianLine: [SIMD2(0.5, 0.35), SIMD2(0.5, 0.55), SIMD2(0.5, 0.75)], apexIndex: 10),
            leftEye: box(0.3125, 0.4375, 0.3375, 0.3675), rightEye: box(0.5625, 0.6875, 0.3375, 0.3675),
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(left: brow(0.27, side: .left), right: brow(0.57, side: .right)),
            observedOuterLips: box(0.4125, 0.5875, 0.5875, 0.635),
            observedNoseSupport: BeautyObservedNoseSupport(crest: nasal, contour: nasal))
    }
    private func source(scale: Double, varying: Bool, strand: Bool = false) -> (Int, Int, [UInt8]) {
        let w = Int(320 * scale), h = Int(400 * scale)
        var bytes = [UInt8](repeating: 255, count: w * h * 4)
        for y in 0..<h { for x in 0..<w {
            let px = (Double(x) + 0.5) / scale, py = (Double(y) + 0.5) / scale
            let jaw = edge(px), offset = py - jaw - phase(px, varying: varying)
            var rgb: [Double] = [35, 80, 110]
            if (abs(px - 160) <= 100 && py >= 90 && py <= jaw) ||
                ((90...230).contains(px) && py >= jaw && py < 340) {
                let u = min(1, max(0, (offset + 2.5) / 5))
                let gain = 1 - 0.14 * u * u * (3 - 2 * u)
                rgb = [210, 158, 125].map { Double($0) * gain }
            }
            if strand && abs(px - 160) < 1 && py > jaw - 8 && py < jaw + 14 { rgb = [28, 24, 20] }
            let p = (y * w + x) * 4
            for c in 0..<3 { bytes[p + c] = UInt8(rgb[c].rounded()) }
        } }
        return (w, h, bytes)
    }

    func testLocalNativePhaseAuthorityDoesNotBridgeUncertainOrForeignSource() throws {
        for scale in [1.0, 0.5] { for strand in [false, true] {
            let (w, h, bytes) = source(scale: scale, varying: true, strand: strand)
            let q = BeautyJawlineShadow.assess(sourceRGBA: bytes, width: w, height: h, face: face())
            let evidence = try XCTUnwrap(q.evidence, "source-only local carrier scale=\(scale) strand=\(strand): \(q.aggregates)")
            var authority = 0, brightSideAuthority = 0, foreignAuthority = 0
            for y in 0..<h { for x in 0..<w where evidence.ownsSourceDomainPixel(x: x, y: y) {
                authority += 1
                let px = (Double(x) + 0.5) / scale, py = (Double(y) + 0.5) / scale
                // All native corners must lie beyond the known SOURCE
                // light-to-dark centre, including between the coarse rays.
                if abs(px - 160) < 25 {
                    for dx in [-0.5, 0.5] {
                        let cx = (Double(x) + 0.5 + dx) / scale
                        if py - 0.5 / scale <= edge(cx) + phase(cx, varying: true) { brightSideAuthority += 1 }
                    }
                }
                if strand && abs(px - 160) < 1 + 1 / scale && py > edge(px) - 7 && py < edge(px) + 13 {
                    foreignAuthority += 1
                }
            } }
            XCTAssertGreaterThan(authority, 32, "an empty source domain cannot qualify")
            XCTAssertEqual(brightSideAuthority, 0)
            XCTAssertEqual(foreignAuthority, 0, "complete native source material footprints remain protected")
            XCTAssertFalse(evidence.ownsSourceDomainPixel(x: -1, y: 0))
            XCTAssertFalse(evidence.ownsSourceDomainPixel(x: Int.max, y: Int.max))
            let output = evidence.apply(to: bytes, strength: 0.25)
            let changed = stride(from: 0, to: bytes.count, by: 4).filter { output[$0..<($0 + 4)] != bytes[$0..<($0 + 4)] }.count
            XCTAssertGreaterThan(changed, 16)
        } }
    }

    func testAddedSourceLightingCannotDominateTheKnownOriginalContrast() throws {
        let bright = [210, 158, 125]
        let dark = bright.map { Int((Double($0) * 0.86).rounded()) }
        for scale in [1.0, 0.5] {
            let (w, h, bytes) = source(scale: scale, varying: false)
            let evidence = try XCTUnwrap(BeautyJawlineShadow.assess(sourceRGBA: bytes, width: w, height: h, face: face()).evidence)
            var previous = 0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = evidence.apply(to: bytes, strength: 0.25 * fraction)
                var total = 0, sourceContrastExceeded = 0, alpha = 0
                for p in stride(from: 0, to: bytes.count, by: 4) {
                    if output[p + 3] != bytes[p + 3] { alpha += 1 }
                    for c in 0..<3 {
                        let delta = Int(bytes[p + c]) - Int(output[p + c])
                        total += delta
                        // One byte accounts for native source quantization,
                        // rather than granting another contrast multiplier.
                        if Double(delta) > Double(bright[c] - dark[c]) * Double(fraction) + 1 { sourceContrastExceeded += 1 }
                    }
                }
                XCTAssertEqual(sourceContrastExceeded, 0)
                XCTAssertEqual(alpha, 0)
                XCTAssertGreaterThan(total, previous, "the contrast bound cannot be met by a no-op")
                XCTAssertTrue(output == evidence.apply(to: bytes, strength: 0.25 * fraction))
                previous = total
            }
        }
    }
}
