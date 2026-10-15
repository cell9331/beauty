import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Independent analytic source lighting. Neither a production weight nor a
/// rendered candidate defines the source edge or the protected material here.
final class WideJawlineShadowToneComparisonTests: XCTestCase {
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

    func testDocumentToneKeepsDeclaredWarmColdAndNeutralPropertiesSeparateFromW1() throws {
        let colors: [SIMD3<Double>] = [SIMD3(210, 158, 125), SIMD3(115, 155, 195), SIMD3(92, 66, 52), SIMD3(repeating: 128)]
        func luma(_ c: SIMD3<Double>) -> Double { c.x * 0.2126 + c.y * 0.7152 + c.z * 0.0722 }
        for (index, color) in colors.enumerated() {
            for amount in [0.025, 0.05, 0.075, 0.10, 0.125] {
                let document = try XCTUnwrap(BeautyWideJawlineShadowTrial.shadeSRGB(color, amount: amount, tone: .documentPreserveB))
                let original = BeautyWideJawlineShadowTrial.shadeSRGB(color, amount: amount)
                XCTAssertTrue(original == BeautyWideJawlineShadowTrial.shadeSRGB(color, amount: amount, tone: .w1Conservative))
                XCTAssertEqual(luma(document) / luma(color), 1 - amount, accuracy: 0.000001)
                let ratio = document / color
                if index == 0 || index == 2 {
                    XCTAssertTrue(ratio.x > ratio.y && ratio.y > ratio.z, "document mode warms warm/deep controls; it is not called cooling")
                }
                if index == 1 { XCTAssertTrue(ratio.x < ratio.y && ratio.y < ratio.z, "keeping negative b is a distinct cold-source result") }
                if index == 3 { XCTAssertLessThan(abs(document.x - document.y) + abs(document.y - document.z), 0.0002) }
                XCTAssertTrue((0..<3).allSatisfy { document[$0] <= color[$0] && document[$0] >= color[$0] * 0.82 })
            }
        }
    }

    func testUnsatisfiedDocumentColourBudgetRefusesRatherThanClippingOrClaimingCooling() {
        let saturated = SIMD3<Double>(255, 0, 0)
        XCTAssertTrue(BeautyWideJawlineShadowTrial.shadeSRGB(saturated, amount: 0.125, tone: .documentPreserveB) == saturated,
            "no positive continuous document amount is supported for this saturated source")
        for amount in [-0.01, 0.181, Double.nan, Double.infinity] {
            XCTAssertTrue(BeautyWideJawlineShadowTrial.shadeSRGB(SIMD3(210, 158, 125), amount: amount, tone: .documentPreserveB) == nil)
        }
        let gray = SIMD3<Double>(repeating: 128)
        XCTAssertTrue(BeautyWideJawlineShadowTrial.shadeSRGB(gray, amount: 0, tone: .documentPreserveB) == gray)
    }

    func testLowBlueDocumentQuartersConvergeToTheBudgetWithoutRemovingExistingShadow() throws {
        for color: SIMD3<Double> in [SIMD3(190, 130, 75), SIMD3(210, 140, 50), SIMD3(180, 110, 40)] {
            var previous = color
            for amount in [0.025, 0.05, 0.075, 0.10, 0.125] {
                let result = try XCTUnwrap(BeautyWideJawlineShadowTrial.shadeSRGB(color, amount: amount, tone: .documentPreserveB))
                for c in 0..<3 {
                    XCTAssertLessThanOrEqual(result[c], previous[c] + 0.000001)
                    XCTAssertGreaterThanOrEqual(result[c], color[c] * 0.82 - 0.000001)
                }
                XCTAssertTrue((0..<3).contains { result[$0] < color[$0] - 0.5 }, "a stronger request cannot restore the original colour")
                previous = result
            }
        }
    }

    func testToneApplicationReportsAnonymousColourRefusalsAndKeepsDefaultExact() throws {
        let (w, h, bytes) = source(scale: 1, varying: false)
        let q = BeautyWideJawlineShadowTrial.assess(sourceRGBA: bytes, width: w, height: h, face: face())
        let evidence = try XCTUnwrap(q.evidence, "generated tone carrier: \(q.aggregates)")
        for fraction: Float in [0.25, 0.5, 0.75, 1] {
            for tone in [BeautyWideJawlineShadowTrial.ToneMode.w1Conservative, .documentPreserveB] {
                var refused = 0
                let output = evidence.apply(to: bytes, strength: 0.25 * fraction, tone: tone, refusedColorPixels: &refused)
                XCTAssertEqual(refused, 0)
                XCTAssertTrue(output == evidence.apply(to: bytes, strength: 0.25 * fraction, tone: tone))
                if tone == .w1Conservative { XCTAssertTrue(output == evidence.apply(to: bytes, strength: 0.25 * fraction)) }
                XCTAssertTrue(evidence.apply(to: bytes, strength: 0, tone: tone) == bytes)
                XCTAssertTrue(evidence.apply(to: bytes, strength: .nan, tone: tone) == bytes)
            }
        }
        var lowBlue = bytes
        for p in stride(from: 0, to: lowBlue.count, by: 4) { lowBlue[p] = 190; lowBlue[p + 1] = 130; lowBlue[p + 2] = 75 }
        var priorLowBlue = lowBlue, priorDarkening = 0
        for fraction: Float in [0.25, 0.5, 0.75, 1] {
            var limited = 0, unsupported = 0
            let limitedOutput = evidence.apply(to: lowBlue, strength: 0.25 * fraction, tone: .documentPreserveB,
                refusedColorPixels: &unsupported, limitedColorPixels: &limited)
            XCTAssertGreaterThan(limited, 0, "an unmet requested target is reported anonymously")
            XCTAssertEqual(unsupported, 0, "a safe partial amount keeps the existing shadow")
            XCTAssertFalse(limitedOutput == lowBlue)
            var brighterThanPrevious = 0, darkening = 0
            for p in stride(from: 0, to: lowBlue.count, by: 4) { for c in 0..<3 {
                if limitedOutput[p + c] > priorLowBlue[p + c] { brighterThanPrevious += 1 }
                darkening += Int(lowBlue[p + c]) - Int(limitedOutput[p + c])
            } }
            XCTAssertEqual(brighterThanPrevious, 0)
            XCTAssertGreaterThan(darkening, priorDarkening)
            priorLowBlue = limitedOutput; priorDarkening = darkening
        }
        var saturated = bytes
        for p in stride(from: 0, to: saturated.count, by: 4) { saturated[p] = 255; saturated[p + 1] = 0; saturated[p + 2] = 0 }
        var refused = 0
        let output = evidence.apply(to: saturated, strength: 0.25, tone: .documentPreserveB, refusedColorPixels: &refused)
        XCTAssertGreaterThan(refused, 0, "a rejected colour is an explicit unmet count, not an effect success")
        var badAlpha = 0, brighter = 0, cap = 0
        for p in stride(from: 0, to: saturated.count, by: 4) {
            if output[p + 3] != saturated[p + 3] { badAlpha += 1 }
            for c in 0..<3 {
                if output[p + c] > saturated[p + c] { brighter += 1 }
                if Double(output[p + c]) < Double(saturated[p + c]) * 0.82 - 0.5 { cap += 1 }
            }
        }
        XCTAssertEqual(badAlpha, 0); XCTAssertEqual(brighter, 0); XCTAssertEqual(cap, 0)
    }
}
