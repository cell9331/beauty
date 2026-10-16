import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Independent analytic source lighting. Neither a production weight nor a
/// rendered candidate defines the source edge or the protected material here.
final class WideJawlineShadowTrialTests: XCTestCase {
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
            if py >= 340 { rgb = [215, 215, 205] }
            if px < 80 && py > 150 { rgb = [45, 30, 25] }
            if (84...96).contains(px) && (175...220).contains(py) { rgb = [180, 130, 105] }
            if strand && abs(px - 160) < 1 && py > jaw - 8 && py < 340 { rgb = [28, 24, 20] }
            let p = (y * w + x) * 4
            for c in 0..<3 { bytes[p + c] = UInt8(rgb[c].rounded()) }
        } }
        return (w, h, bytes)
    }

    func testDeclaredOklabControlsDimWithoutInventingWarmthOrBreakingGamut() throws {
        let colors: [SIMD3<Double>] = [SIMD3(210, 158, 125), SIMD3(115, 155, 195), SIMD3(92, 66, 52), SIMD3(repeating: 128)]
        func luma(_ c: SIMD3<Double>) -> Double { c.x * 0.2126 + c.y * 0.7152 + c.z * 0.0722 }
        for (index, color) in colors.enumerated() {
            XCTAssertEqual(BeautyWideJawlineShadowTrial.shadeSRGB(color, amount: 0), color)
            var previous = color
            for amount in [0.025, 0.05, 0.075, 0.10, 0.125] {
                let result = try XCTUnwrap(BeautyWideJawlineShadowTrial.shadeSRGB(color, amount: amount))
                XCTAssertEqual(luma(result) / luma(color), 1 - amount, accuracy: 0.000001)
                for c in 0..<3 {
                    XCTAssertLessThanOrEqual(result[c], color[c])
                    XCTAssertGreaterThanOrEqual(result[c], color[c] * 0.82)
                    XCTAssertLessThan(result[c], previous[c])
                }
                let ratios = result / color
                if index == 0 || index == 2 {
                    XCTAssertLessThan(ratios.x, ratios.y)
                    XCTAssertLessThan(ratios.y, ratios.z, "warm/deep source gets a bounded relative cooling, not the document's false guarantee")
                }
                if index == 1 { XCTAssertLessThan(abs(ratios.z - ratios.x), 0.01, "cold colour gets no extra positive-warm correction") }
                if index == 3 {
                    XCTAssertEqual(result.x, result.y, accuracy: 0.0001)
                    XCTAssertEqual(result.y, result.z, accuracy: 0.0001)
                }
                previous = result
            }
        }
    }

    func testInvalidColourAmountsRefuseAndNeutralIsExact() {
        for amount in [-0.01, 0.181, Double.nan, Double.infinity] {
            XCTAssertNil(BeautyWideJawlineShadowTrial.shadeSRGB(SIMD3(210, 158, 125), amount: amount))
        }
        for color: SIMD3<Double> in [SIMD3(-1, 0, 0), SIMD3(0, 256, 0), SIMD3(.nan, 1, 1)] {
            XCTAssertNil(BeautyWideJawlineShadowTrial.shadeSRGB(color, amount: 0.1))
        }
        XCTAssertEqual(BeautyWideJawlineShadowTrial.shadeSRGB(SIMD3<Double>.zero, amount: 0.1), SIMD3<Double>.zero)
    }

    func testWideNativeFieldHasFarNeckActivityAndIndependentProtectedContent() throws {
        for scale in [1.0, 0.5] {
            let (w, h, bytes) = source(scale: scale, varying: false, strand: true)
            let q = BeautyWideJawlineShadowTrial.assess(sourceRGBA: bytes, width: w, height: h, face: face())
            let evidence = try XCTUnwrap(q.evidence, "wide source qualification scale=\(scale): \(q.refusal?.rawValue ?? "none") \(q.aggregates)")
            XCTAssertEqual(q.aggregates["qualifiedNeckFamilies"], 2)
            var prior = 0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = evidence.apply(to: bytes, strength: 0.25 * fraction)
                var changed = 0, farActivity = 0, protected = 0, alpha = 0, brightened = 0, cap = 0, authority = 0, total = 0
                for y in 0..<h { for x in 0..<w {
                    let p = (y * w + x) * 4
                    let px = (Double(x) + 0.5) / scale, py = (Double(y) + 0.5) / scale
                    let active = output[p..<(p + 4)] != bytes[p..<(p + 4)]
                    if output[p + 3] != bytes[p + 3] { alpha += 1 }
                    for c in 0..<3 {
                        total += Int(bytes[p + c]) - Int(output[p + c])
                        if output[p + c] > bytes[p + c] { brightened += 1 }
                        if Double(output[p + c]) < Double(bytes[p + c]) * 0.82 - 0.5 { cap += 1 }
                    }
                    if active {
                        changed += 1
                        if !evidence.ownsSourceDomainPixel(x: x, y: y) { authority += 1 }
                        if py <= edge(px) || py >= 340 || (px < 80 && py > 150) ||
                            ((84...96).contains(px) && (175...220).contains(py)) ||
                            (abs(px - 160) < 1 && py > edge(px) - 8 && py < 340) { protected += 1 }
                        if abs(px - 160) < 30 && (20...30).contains(py - edge(px)) { farActivity += 1 }
                    }
                } }
                XCTAssertGreaterThan(changed, 32)
                XCTAssertGreaterThan(farActivity, 16, "a narrow painted contour cannot qualify this new broad-field hypothesis")
                XCTAssertGreaterThan(total, prior)
                XCTAssertEqual(protected, 0); XCTAssertEqual(alpha, 0); XCTAssertEqual(brightened, 0); XCTAssertEqual(cap, 0); XCTAssertEqual(authority, 0)
                XCTAssertTrue(output == evidence.apply(to: bytes, strength: 0.25 * fraction))
                prior = total
            }
            XCTAssertTrue(evidence.apply(to: bytes, strength: 0) == bytes)
            var current = bytes
            for p in stride(from: 0, to: current.count, by: 4) { for c in 0..<3 { current[p + c] = UInt8(min(255, Int(current[p + c]) + 7)) } }
            let output = evidence.apply(to: current, strength: 0.25)
            XCTAssertFalse(output == current)
            XCTAssertTrue(output == evidence.apply(to: current, strength: 0.25))
            var currentBrighter = 0, currentAlpha = 0
            for p in stride(from: 0, to: current.count, by: 4) {
                for c in 0..<3 where output[p + c] > current[p + c] { currentBrighter += 1 }
                if output[p + 3] != current[p + 3] { currentAlpha += 1 }
            }
            XCTAssertEqual(currentBrighter, 0); XCTAssertEqual(currentAlpha, 0)
        }
    }

    func testAbsentNeckEvidenceAndMalformedSourceRefuseWithoutFallback() {
        let (w, h, bytes) = source(scale: 1, varying: false)
        var cloth = bytes
        for y in 0..<h { for x in 0..<w where Double(y) + 0.5 > edge(Double(x) + 0.5) + 6 {
            let p = (y * w + x) * 4
            cloth[p] = 215; cloth[p + 1] = 215; cloth[p + 2] = 205
        } }
        XCTAssertEqual(BeautyWideJawlineShadowTrial.assess(sourceRGBA: cloth, width: w, height: h, face: face()).refusal, .neckEvidenceUnavailable)
        var transparent = bytes; transparent[3] = 254
        XCTAssertEqual(BeautyWideJawlineShadowTrial.assess(sourceRGBA: transparent, width: w, height: h, face: face()).refusal, .nonopaqueSource)
        XCTAssertEqual(BeautyWideJawlineShadowTrial.assess(sourceRGBA: [], width: w, height: h, face: face()).refusal, .invalidRaster)
        var uniform = bytes
        for p in stride(from: 0, to: uniform.count, by: 4) { uniform[p] = 210; uniform[p + 1] = 158; uniform[p + 2] = 125 }
        XCTAssertNil(BeautyWideJawlineShadowTrial.assess(sourceRGBA: uniform, width: w, height: h, face: face()).evidence)
    }
}
