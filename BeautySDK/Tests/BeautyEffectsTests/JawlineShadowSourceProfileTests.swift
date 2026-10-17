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
    private func source(scale: Double, varying: Bool, strand: Bool = false,
                        transitionWidth: Double = 5, neckChroma: Bool = false) -> (Int, Int, [UInt8]) {
        let w = Int(320 * scale), h = Int(400 * scale)
        var bytes = [UInt8](repeating: 255, count: w * h * 4)
        for y in 0..<h { for x in 0..<w {
            let px = (Double(x) + 0.5) / scale, py = (Double(y) + 0.5) / scale
            let jaw = edge(px), offset = py - jaw - phase(px, varying: varying)
            var rgb: [Double] = [35, 80, 110]
            if (abs(px - 160) <= 100 && py >= 90 && py <= jaw) ||
                ((90...230).contains(px) && py >= jaw && py < 340) {
                let u = min(1, max(0, (offset + transitionWidth * 0.5) / transitionWidth))
                let gain = 1 - 0.14 * u * u * (3 - 2 * u)
                // The independently generated neck family remains close to
                // the face. A warmer under-jaw region is close to BOTH neck
                // families, although outside the single face-family radius.
                let base: [Double]
                if neckChroma && py > jaw + 3 {
                    base = py < jaw + 10 ? [200, 138, 88] : [200, 143, 100]
                } else { base = [210, 158, 125] }
                rgb = base.map { $0 * gain }
            }
            // Include every native texel intersecting the physical strand.
            // At half size, centers are 159/161: a center-only abs<1 test
            // generates NO strand while the independent oracle expects one.
            if strand && abs(px - 160) < 1 + 0.5 / scale && py > jaw - 8 && py < jaw + 14 {
                rgb = [28, 24, 20]
            }
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

    func testNewShadowEntersAfterActualSourceCentreWithoutWaitingForSourceDarkPercentile() throws {
        for scale in [1.0, 0.5] { for transition in [5.0, 12.0] {
            let (w, h, bytes) = source(scale: scale, varying: false, transitionWidth: transition)
            let q = BeautyJawlineShadow.assess(sourceRGBA: bytes, width: w, height: h, face: face())
            let evidence = try XCTUnwrap(q.evidence,
                "source centre scale=\(scale) width=\(transition): \(q.aggregates)")
            XCTAssertEqual(q.aggregates["sourceCenterEntryRegistration"], 1)
            var previous = 0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = evidence.apply(to: bytes, strength: 0.25 * fraction)
                var upperChanged = 0, entryCount = 0, entryDarkening = 0, alphaChanged = 0
                for y in 0..<h { for x in 0..<w {
                    let p = (y * w + x) * 4
                    let px = (Double(x) + 0.5) / scale, py = (Double(y) + 0.5) / scale
                    let delta = Int(bytes[p + 1]) - Int(output[p + 1])
                    if py <= edge(px) && output[p..<(p + 4)] != bytes[p..<(p + 4)] { upperChanged += 1 }
                    if output[p + 3] != bytes[p + 3] { alphaChanged += 1 }
                    // Independent source geometry, 1.0--1.8% of its known
                    // 200px face width beyond the true jaw centre. This is
                    // unrelated to the production profile/weight buffers.
                    if abs(px - 160) < 12 && (2.0...3.6).contains(py - edge(px)) {
                        entryCount += 1; entryDarkening += delta
                    }
                } }
                XCTAssertEqual(upperChanged, 0, "the actual face bright side remains exact")
                XCTAssertEqual(alphaChanged, 0)
                XCTAssertGreaterThan(entryCount, 8)
                XCTAssertGreaterThan(Double(entryDarkening) / Double(entryCount), Double(fraction) * 8,
                    "new shadow must join the known jaw without source-90% plus a second entry feather")
                XCTAssertGreaterThan(entryDarkening, previous)
                previous = entryDarkening
            }
        } }
    }

    func testWideFieldPreservesMaterialAndUsefulTailWithoutPerRayLightingGain() throws {
        for scale in [1.0, 0.5] {
            let (w, h, bytes) = source(scale: scale, varying: false, strand: true)
            let q = BeautyJawlineShadow.assess(sourceRGBA: bytes, width: w, height: h, face: face())
            let evidence = try XCTUnwrap(q.evidence)
            XCTAssertEqual(q.aggregates["qualifiedNeckFamilies"], 2)
            var previous = 0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = evidence.apply(to: bytes, strength: 0.25 * fraction)
                var total = 0, tailTotal = 0, tailCount = 0, protectedLeaks = 0
                var belowStrandTotal = 0, belowStrandCount = 0
                for y in 0..<h { for x in 0..<w {
                    let p = (y * w + x) * 4
                    let px = (Double(x) + 0.5) / scale, py = (Double(y) + 0.5) / scale
                    let offset = py - edge(px)
                    let changed = output[p..<(p + 4)] != bytes[p..<(p + 4)]
                    let sourceStrand = abs(px - 160) < 1 + 0.5 / scale &&
                        py > edge(px) - 8 && py < edge(px) + 14
                    if changed && (py <= edge(px) || sourceStrand || py >= 340) { protectedLeaks += 1 }
                    XCTAssertEqual(output[p + 3], bytes[p + 3])
                    for c in 0..<3 {
                        let delta = Int(bytes[p + c]) - Int(output[p + c]); total += delta
                        XCTAssertGreaterThanOrEqual(delta, 0)
                        XCTAssertLessThanOrEqual(Double(delta), Double(bytes[p + c]) * 0.18 + 0.5)
                    }
                    // This independent source window is 0.10--0.15 face
                    // widths below the known jaw: the previous thin field
                    // was identically zero here, regardless of gain.
                    if (135...150).contains(px) && (20...30).contains(offset) {
                        tailCount += 1; tailTotal += Int(bytes[p + 1]) - Int(output[p + 1])
                    }
                    // The source strand ends at jaw+14. Verified native skin
                    // below it is connected around its sides, while the strand
                    // itself above remains protected by the independent oracle.
                    if abs(px - 160) < 1 + 0.5 / scale && (20...30).contains(offset) {
                        belowStrandCount += 1
                        belowStrandTotal += Int(bytes[p + 1]) - Int(output[p + 1])
                    }
                } }
                XCTAssertEqual(protectedLeaks, 0)
                XCTAssertGreaterThan(tailCount, 12)
                XCTAssertGreaterThan(Double(tailTotal) / Double(tailCount), Double(fraction) * 3)
                XCTAssertGreaterThan(belowStrandCount, 4)
                XCTAssertGreaterThan(Double(belowStrandTotal) / Double(belowStrandCount), Double(fraction) * 3,
                    "a native foreign strand cannot cut a whole verified source-skin column below its endpoint")
                XCTAssertGreaterThan(total, previous)
                XCTAssertTrue(output == evidence.apply(to: bytes, strength: 0.25 * fraction))
                previous = total
            }
        }
    }

    func testOriginalBilateralNeckFamiliesOwnTheirWarmSourceMaterialWithoutOwningForeignStrand() throws {
        for scale in [1.0, 0.5] {
            let (w, h, bytes) = source(scale: scale, varying: false, strand: true, neckChroma: true)
            let q = BeautyJawlineShadow.assess(sourceRGBA: bytes, width: w, height: h, face: face())
            let evidence = try XCTUnwrap(q.evidence, "bilateral neck source scale=\(scale): \(q.aggregates)")
            XCTAssertEqual(q.aggregates["bilateralNeckMaterialCorroboration"], 1)
            var previous = 0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = evidence.apply(to: bytes, strength: fraction * 0.25)
                var count = 0, darkening = 0, protectedLeaks = 0
                for y in 0..<h { for x in 0..<w {
                    let p = (y * w + x) * 4
                    let px = (Double(x) + 0.5) / scale, py = (Double(y) + 0.5) / scale
                    let offset = py - edge(px)
                    let changed = output[p..<(p + 4)] != bytes[p..<(p + 4)]
                    let foreign = abs(px - 160) < 1 + 0.5 / scale && offset > -8 && offset < 14
                    if changed && (py <= edge(px) || foreign || py >= 340) { protectedLeaks += 1 }
                    XCTAssertEqual(output[p + 3], bytes[p + 3])
                    for c in 0..<3 {
                        let delta = Int(bytes[p + c]) - Int(output[p + c])
                        XCTAssertGreaterThanOrEqual(delta, 0)
                        XCTAssertLessThanOrEqual(Double(delta), Double(bytes[p + c]) * 0.18 + 0.5)
                    }
                    // Fixed source region wholly inside the deliberately
                    // warm band. Keep the native foreign footprint outside
                    // this independent positive oracle at both raster sizes.
                    if (9...18).contains(abs(px - 160)) && (5...8).contains(offset) {
                        count += 1; darkening += Int(bytes[p + 1]) - Int(output[p + 1])
                    }
                } }
                XCTAssertEqual(protectedLeaks, 0)
                XCTAssertGreaterThan(count, 4)
                XCTAssertGreaterThan(Double(darkening) / Double(count), Double(fraction) * 3,
                    "verified source neck chroma cannot create a false material hole at the entrance")
                XCTAssertGreaterThan(darkening, previous)
                previous = darkening
            }
        }
    }
}
