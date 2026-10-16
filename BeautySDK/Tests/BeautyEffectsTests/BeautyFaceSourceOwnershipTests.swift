import BeautyCore
import BeautyDetection
import CoreImage
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import BeautyEffects

/// Generated material carriers qualify only ownership mechanics. These do not
/// replace the frozen actual portrait's semantic cores or effect amplitude.
final class BeautyFaceSourceOwnershipTests: XCTestCase {
    private let width = 240, height = 240
    private let controls: Set<BeautyFaceSourceOwnership.Control> = [.faceWidth, .temple, .cheekbone]
    private enum Carrier { case darkHair, goldenHair, coldLighting, darkLighting, headwrap, isolatedSkin, isolatedInnerSkin, ambiguous, splitCheeks }

    private func points(_ a: Float, _ b: Float, _ c: Float, _ d: Float) -> [SIMD2<Float>] {
        [SIMD2(a, c), SIMD2(b, c), SIMD2(b, d), SIMD2(a, d)]
    }

    private func face(freshness: LandmarkGeometryFreshness = .fresh, missingNose: Bool = false,
                      malformedBrow: Bool = false, wideEnvelopes: Bool = false,
                      blockCheekCells: Bool = false) -> FaceGeometry {
        let contour = (0...20).map { i -> SIMD2<Float> in
            let a = Float(i) / 20 * .pi
            return SIMD2((120 - 68 * cos(a)) / 240, (75 + 105 * sin(a)) / 240)
        }
        let leftBrowPoints = wideEnvelopes ? points(0.30, 0.48, 0.25, 0.33) : points(0.335, 0.425, 0.25, 0.28)
        let rightBrowPoints = wideEnvelopes ? points(0.53, 0.74, 0.24, 0.31) : points(0.575, 0.665, 0.25, 0.28)
        func brow(_ p: [SIMD2<Float>], side: BeautyObservedEyebrowSide) -> BeautyEyebrowSemanticTrace {
            BeautyEyebrowSemanticTrace(side: side, points: p,
                innerEndpoint: side == .left ? p[1] : p[0], outerEndpoint: side == .left ? p[0] : p[1],
                center: (p[0] + p[2]) * 0.5, apexIndex: 0)
        }
        let nasalPath = wideEnvelopes ? points(0.365, 0.62, 0.38, 0.51) : points(0.465, 0.535, 0.40, 0.49)
        let nasal = nasalPath.map {
            CoordinatePoint(x: Double($0.x), y: Double($0.y))
        }
        return FaceGeometry(bounds: FaceBounds(x: 0.21, y: 0.14, width: 0.58, height: 0.63),
            faceContour: contour,
            observedFaceSupport: BeautyFaceSemanticSupport(contour: contour,
                medianLine: [SIMD2(0.5, 0.31), SIMD2(0.5, 0.50), SIMD2(0.5, 0.75)], apexIndex: 10),
            leftEye: points(0.345, 0.415, 0.30, 0.34), rightEye: points(0.585, 0.655, 0.30, 0.34),
            freshness: freshness,
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(
                left: brow(malformedBrow ? [SIMD2(.nan, 0.25), leftBrowPoints[1], leftBrowPoints[2], leftBrowPoints[3]] : leftBrowPoints, side: .left),
                right: brow(rightBrowPoints, side: .right)),
            observedOuterLips: blockCheekCells ? points(0.20, 0.80, 0.38, 0.65) :
                (wideEnvelopes ? points(0.42, 0.62, 0.50, 0.66) : points(0.425, 0.575, 0.56, 0.62)),
            observedNoseSupport: missingNose ? nil : BeautyObservedNoseSupport(crest: nasal, contour: nasal))
    }

    private func carrier(_ kind: Carrier = .darkHair) -> [UInt8] {
        var result = [UInt8](repeating: 255, count: width * height * 4)
        let skinRGB = kind == .coldLighting ? [125, 170, 205] : (kind == .darkLighting ? [92, 65, 50] : [210, 155, 120])
        for y in 0..<height { for x in 0..<width {
            let px = Double(x) + 0.5, py = Double(y) + 0.5
            let inside = py >= 44 && (py < 75 ? abs(px - 120) <= 64 :
                pow((px - 120) / 68, 2) + pow((py - 75) / 105, 2) <= 1 && py <= 180)
            let head = px >= 32 && px <= 208 && py >= 15 && py <= 136
            let stripe = (x % 5) * 4
            var rgb = [30, 85, 125]
            if head { rgb = [30 + stripe, 25 + stripe, 22 + stripe] }
            if kind == .goldenHair && head { rgb = [172 + stripe, 133 + stripe, 39 + stripe] }
            if kind == .headwrap && head { rgb = [184, 184, 184] }
            let external = rgb
            if inside { rgb = skinRGB }
            // A declared 1.5-pixel colour mixture supplies a genuine uncertain
            // boundary. Pure external texels remain independent hard negatives.
            if py >= 75 && py <= 180 {
                let half = 68 * sqrt(max(0, 1 - pow((py - 75) / 105, 2)))
                let coverage = min(1, max(0, 0.5 + (half - abs(px - 120)) / 1.5))
                let skin = skinRGB
                if coverage > 0 && coverage < 1 {
                    rgb = zip(skin, external).map { Int((Double($0.0) * coverage + Double($0.1) * (1 - coverage)).rounded()) }
                }
            }
            if kind == .splitCheeks && inside && x < 120 { rgb = [225, 105, 80] }
            if kind == .isolatedSkin && (8..<24).contains(x) && (150..<166).contains(y) { rgb = [210, 155, 120] }
            if kind == .isolatedInnerSkin && (162..<180).contains(x) && (93..<111).contains(y) { rgb = [20, 20, 20] }
            if kind == .isolatedInnerSkin && (167..<173).contains(x) && (99..<105).contains(y) { rgb = [210, 155, 120] }
            if kind == .ambiguous { rgb = [210, 155, 120] }
            let i = (y * width + x) * 4
            result[i] = UInt8(rgb[0]); result[i + 1] = UInt8(rgb[1]); result[i + 2] = UInt8(rgb[2])
        } }
        return result
    }

    private func assess(_ source: [UInt8]?, geometry: FaceGeometry? = nil,
                        controls requested: Set<BeautyFaceSourceOwnership.Control>? = nil) -> BeautyFaceSourceOwnership.Qualification {
        BeautyFaceSourceOwnership.assess(sourceRGBA: source, width: width, height: height,
            face: geometry ?? face(), controls: requested ?? controls)
    }

    func testSourceConnectedSkinAndIndependentDarkHairBackgroundCores() throws {
        let q = assess(carrier()), evidence = try XCTUnwrap(q.evidence)
        XCTAssertNil(q.refusal)
        XCTAssertGreaterThan(q.aggregates["connectedSkinPixels", default: 0], 1000)
        XCTAssertGreaterThan(q.aggregates["highConfidenceHairPixels", default: 0], 100)
        XCTAssertGreaterThan(q.aggregates["highConfidenceBackgroundPixels", default: 0], 1000)
        XCTAssertGreaterThan(q.aggregates["mixedTransitionPixels", default: 0], 0)
        XCTAssertEqual(evidence.material(x: 45, y: 40), .highConfidenceHair)
        XCTAssertEqual(evidence.material(x: 8, y: 180), .highConfidenceBackground)
        XCTAssertEqual(evidence.material(x: 174, y: 123), .connectedSkin)
        XCTAssertFalse(evidence.preservesDestinationPixel(x: 174, y: 123))
        XCTAssertTrue(evidence.preservesDestinationPixel(x: 45, y: 40))
        XCTAssertTrue(evidence.preservesDestinationPixel(x: 8, y: 180))
        XCTAssertTrue(evidence.allowsSourceFootprint(x: 174.5, y: 123.5))
        XCTAssertFalse(evidence.allowsSourceFootprint(x: 45.5, y: 40.5), "hair must not be transported into an editable destination")
        XCTAssertFalse(evidence.allowsSourceFootprint(x: 8.5, y: 180.5), "background core cannot supply invisible fill")
    }

    func testGoldenHairAndColdSkinRequireTheirOwnSourceEvidence() throws {
        let golden = try XCTUnwrap(assess(carrier(.goldenHair)).evidence)
        XCTAssertEqual(golden.material(x: 45, y: 40), .highConfidenceHair)
        XCTAssertTrue(golden.preservesDestinationPixel(x: 45, y: 40))
        let cold = try XCTUnwrap(assess(carrier(.coldLighting)).evidence)
        XCTAssertEqual(cold.material(x: 174, y: 123), .connectedSkin)
        XCTAssertFalse(cold.preservesDestinationPixel(x: 174, y: 123), "cold lighting cannot be rejected by a universal warm-skin formula")
        XCTAssertTrue(cold.preservesDestinationPixel(x: 45, y: 40))
    }

    func testUniformHeadwrapRemainsUnknownRatherThanNonSkinHair() throws {
        let q = assess(carrier(.headwrap)), evidence = try XCTUnwrap(q.evidence)
        XCTAssertEqual(q.aggregates["highConfidenceHairPixels", default: 0], 0)
        XCTAssertEqual(evidence.material(x: 45, y: 40), .unknown)
        XCTAssertTrue(evidence.preservesDestinationPixel(x: 45, y: 40))
        XCTAssertFalse(evidence.allowsSourceFootprint(x: 45.5, y: 40.5))
    }

    func testIsolatedSkinColourIslandDoesNotJoinFaceOrBecomeHair() throws {
        let evidence = try XCTUnwrap(assess(carrier(.isolatedSkin)).evidence)
        XCTAssertEqual(evidence.material(x: 15, y: 156), .unknown)
        XCTAssertTrue(evidence.preservesDestinationPixel(x: 15, y: 156))
        XCTAssertFalse(evidence.allowsSourceFootprint(x: 15.5, y: 156.5))
        let inside = try XCTUnwrap(assess(carrier(.isolatedInnerSkin)).evidence)
        XCTAssertEqual(inside.material(x: 169, y: 102), .unknown, "a same-colour island inside anatomy still needs seed connectivity")
        XCTAssertTrue(inside.preservesDestinationPixel(x: 169, y: 102))
        XCTAssertFalse(inside.allowsSourceFootprint(x: 169.5, y: 102.5))
    }

    func testColourAmbiguityAndDisagreeingSeedFamiliesRefuse() {
        let ambiguous = assess(carrier(.ambiguous))
        XCTAssertNil(ambiguous.evidence)
        XCTAssertEqual(ambiguous.refusal, .externalMaterialUnproved)
        let disagreement = assess(carrier(.splitCheeks))
        XCTAssertNil(disagreement.evidence)
        XCTAssertEqual(disagreement.refusal, .seedAmbiguous)
    }

    func testFreshCompleteSupportOpaqueSourceAndNonemptyScopeAreMandatory() {
        XCTAssertEqual(assess(nil).refusal, .sourceUnavailable)
        XCTAssertEqual(assess([255, 255]).refusal, .invalidRaster)
        XCTAssertEqual(assess(carrier(), geometry: face(freshness: .reused)).refusal, .invalidFreshSupport)
        XCTAssertEqual(assess(carrier(), geometry: face(freshness: .stale)).refusal, .invalidFreshSupport)
        XCTAssertEqual(assess(carrier(), geometry: face(missingNose: true)).refusal, .invalidFreshSupport)
        XCTAssertEqual(assess(carrier(), geometry: face(malformedBrow: true)).refusal, .invalidFreshSupport)
        XCTAssertEqual(assess(carrier(), controls: []).refusal, .unsupportedScope)
        var alpha = carrier(); alpha[(45 * width + 40) * 4 + 3] = 254
        XCTAssertEqual(assess(alpha).refusal, .nonopaqueSource)
    }

    func testPresentMalformedEyeSupportRefusesWithoutLegacyFallback() throws {
        let original = face(), source = carrier()
        func eye(_ contour: [SIMD2<Float>], side: BeautyObservedEyeSide) -> BeautyEyeSemanticSupport {
            let valid = side == .left ? original.leftEye : original.rightEye
            return BeautyEyeSemanticSupport(side: side, contour: contour,
                upper: valid, lower: valid, inner: [valid[0]], outer: [valid[1]],
                corners: [valid[0], valid[1]], center: (valid[0] + valid[2]) * 0.5,
                pupil: nil, span: SIMD2(0.07, 0.04), tilt: 0)
        }
        func geometry(left: [SIMD2<Float>], right: [SIMD2<Float>]) -> FaceGeometry {
            FaceGeometry(bounds: original.bounds, faceContour: original.faceContour,
                observedFaceSupport: original.observedFaceSupport,
                leftEye: original.leftEye, rightEye: original.rightEye,
                leftEyeSupport: eye(left, side: .left), rightEyeSupport: eye(right, side: .right),
                freshness: original.freshness, observedEyebrowSupport: original.observedEyebrowSupport,
                observedOuterLips: original.observedOuterLips, observedNoseSupport: original.observedNoseSupport)
        }
        var strengths = BeautyEffectiveStrengths(); strengths.faceSlim = BeautySafetyCaps.faceSlim
        for sideOrdinal in 0...1 {
            let valid = sideOrdinal == 0 ? original.leftEye : original.rightEye
            var nonfinite = valid; nonfinite[0] = SIMD2(.nan, valid[0].y)
            let malformed: [[SIMD2<Float>]] = [[], Array(valid.prefix(3)), nonfinite]
            for contour in malformed {
                let bad = geometry(left: sideOrdinal == 0 ? contour : original.leftEye,
                    right: sideOrdinal == 1 ? contour : original.rightEye)
                let q = assess(source, geometry: bad)
                XCTAssertNil(q.evidence)
                XCTAssertEqual(q.refusal, .invalidFreshSupport)
                XCTAssertNil(BeautyContinuousFaceMap(width: width, height: height, face: bad,
                    strengths: strengths, sourceRGBA: source))
            }
        }
        let unchanged = geometry(left: original.leftEye, right: original.rightEye)
        let q = assess(source, geometry: unchanged)
        XCTAssertNil(q.refusal)
        _ = try XCTUnwrap(q.evidence)
        XCTAssertTrue(q.aggregates == assess(source, geometry: original).aggregates,
            "valid selected contours equal to legacy keep the original qualification")
        _ = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height, face: unchanged,
            strengths: strengths, sourceRGBA: source))
    }

    func testGeometryOnlyCheekRelocationKeepsWideAsymmetricFeatureCollars() throws {
        let geometry = face(wideEnvelopes: true)
        let q = assess(carrier(), geometry: geometry), evidence = try XCTUnwrap(q.evidence)
        for ordinal in 0...1 {
            let prefix = "seedFamily\(ordinal)"
            XCTAssertEqual(q.aggregates[prefix + "OriginalProtectedFeature", default: 0], 1,
                "the declared wide envelope must actually block the original seed")
            XCTAssertEqual(q.aggregates[prefix + "SelectedRelocated", default: 0], 1)
            XCTAssertEqual(q.aggregates[prefix + "Qualified", default: 0], 1)
            XCTAssertEqual(q.aggregates[prefix + "SampleCount", default: 0], 9)
        }
        for (x, y) in [(95, 110), (150, 120), (74, 69), (170, 65)] {
            XCTAssertEqual(evidence.material(x: x, y: y), .protectedFeature)
            XCTAssertTrue(evidence.preservesDestinationPixel(x: x, y: y))
            XCTAssertFalse(evidence.allowsSourceFootprint(x: Double(x) + 0.5, y: Double(y) + 0.5))
        }
        func geometryCounts(_ values: [String: Int]) -> [String: Int] {
            values.filter { $0.key.contains("Geometry") || $0.key.contains("Selected") || $0.key.contains("OriginalProtected") }
        }
        let cold = assess(carrier(.coldLighting), geometry: geometry)
        XCTAssertNil(cold.refusal)
        XCTAssertTrue(geometryCounts(q.aggregates) == geometryCounts(cold.aggregates), "source colour cannot pick another geometry patch")
        let disagreement = assess(carrier(.splitCheeks), geometry: geometry)
        XCTAssertEqual(disagreement.refusal, .seedAmbiguous)
        XCTAssertTrue(geometryCounts(q.aggregates) == geometryCounts(disagreement.aggregates),
            "a colour-rejected patch cannot trigger a search for a more convenient positive")
    }

    func testNoLegalCheekCellRefusesBeforeReadingColourAndKeepsSupportGuards() {
        let blocked = face(wideEnvelopes: true, blockCheekCells: true)
        for source in [carrier(), carrier(.splitCheeks)] {
            let q = assess(source, geometry: blocked)
            XCTAssertNil(q.evidence)
            XCTAssertEqual(q.refusal, .seedUnavailable)
            for ordinal in 0...1 {
                XCTAssertEqual(q.aggregates["seedFamily\(ordinal)NoLegalGeometryPatch", default: 0], 1)
                XCTAssertEqual(q.aggregates["seedFamily\(ordinal)SampleCount", default: 0], 0)
            }
        }
        XCTAssertEqual(assess(carrier(), geometry: face(freshness: .stale, wideEnvelopes: true)).refusal, .invalidFreshSupport)
        XCTAssertEqual(assess(carrier(), geometry: face(malformedBrow: true, wideEnvelopes: true)).refusal, .invalidFreshSupport)
    }

    func testCompleteFeaturePixelsAndEverySourceFootprintTexelRemainReserved() throws {
        let evidence = try XCTUnwrap(assess(carrier()).evidence)
        for (x, y) in [(90, 75), (150, 75), (90, 64), (150, 64), (120, 107), (120, 141)] {
            XCTAssertEqual(evidence.material(x: x, y: y), .protectedFeature)
            XCTAssertTrue(evidence.preservesDestinationPixel(x: x, y: y))
            XCTAssertFalse(evidence.allowsSourceFootprint(x: Double(x) + 0.5, y: Double(y) + 0.5))
            XCTAssertEqual(evidence.distanceToReserve(x: Double(x) + 0.5, y: Double(y) + 0.5), 0)
        }
        // In this independently fixed row the face ends near x=180. The
        // final admitted texel must not authorize the next reserved texel,
        // even when that second texel has zero interpolation weight.
        let admitted = (170..<210).filter { !evidence.preservesDestinationPixel(x: $0, y: 123) }
        let edge = try XCTUnwrap(admitted.last)
        XCTAssertTrue(evidence.preservesDestinationPixel(x: edge + 1, y: 123))
        XCTAssertFalse(evidence.allowsSourceFootprint(x: Double(edge) + 0.5, y: 123.5))
        for p in [SIMD2<Double>(-.infinity, 10), SIMD2(.nan, 10), SIMD2(0.49, 10), SIMD2(239.5, 10)] {
            XCTAssertFalse(evidence.allowsSourceFootprint(x: p.x, y: p.y))
        }
    }

    func testScopeAndConservativeDistanceNeverEnlargeEditableSourceSweep() throws {
        let evidence = try XCTUnwrap(assess(carrier()).evidence)
        XCTAssertTrue(evidence.preservesDestinationPixel(x: 120, y: 50), "interior forehead is outside the lateral contour band")
        XCTAssertTrue(evidence.preservesDestinationPixel(x: 120, y: 185), "below the three registered lateral control ranges")
        XCTAssertGreaterThan(evidence.distanceToReserve(x: 167.5, y: 123.5), 0)
        for (x, y) in [(174, 123), (167, 123), (174, 118), (177, 128)] {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            var exactDistance = Double.infinity
            for yy in 0..<height { for xx in 0..<width where evidence.preservesDestinationPixel(x: xx, y: yy) {
                let dx = max(0, abs(p.x - (Double(xx) + 0.5)) - 0.5)
                let dy = max(0, abs(p.y - (Double(yy) + 0.5)) - 0.5)
                exactDistance = min(exactDistance, hypot(dx, dy))
            } }
            XCTAssertLessThanOrEqual(evidence.distanceToReserve(x: p.x, y: p.y), exactDistance)
        }
        XCTAssertEqual(evidence.distanceToReserve(x: .nan, y: 123), 0)
        let temple = try XCTUnwrap(assess(carrier(), controls: [.temple]).evidence)
        XCTAssertTrue(temple.preservesDestinationPixel(x: 174, y: 123), "temple evidence cannot admit a cheek destination")
    }

    func testCompositionUsesCurrentStageInputAndRejectsAlphaOrSizeMismatch() throws {
        let original = carrier(), evidence = try XCTUnwrap(assess(original).evidence)
        var stageInput = original, warped = original
        for p in 0..<(width * height) {
            stageInput[p * 4] = 99
            warped[p * 4] = 17; warped[p * 4 + 1] = 18; warped[p * 4 + 2] = 19
        }
        let output = try XCTUnwrap(evidence.compositePreservingSourceCores(originalRGBA: stageInput, warpedRGBA: warped))
        var changedEditable = 0, changedReserved = 0, changedAlpha = 0
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            if output[i..<i + 4] != stageInput[i..<i + 4] {
                if evidence.preservesDestinationPixel(x: x, y: y) { changedReserved += 1 }
                else { changedEditable += 1 }
            }
            if output[i + 3] != stageInput[i + 3] { changedAlpha += 1 }
        } }
        XCTAssertGreaterThan(changedEditable, 100)
        XCTAssertEqual(changedReserved, 0)
        XCTAssertEqual(changedAlpha, 0)
        XCTAssertTrue(output == evidence.compositePreservingSourceCores(originalRGBA: stageInput, warpedRGBA: warped))
        XCTAssertNil(evidence.compositePreservingSourceCores(originalRGBA: [255], warpedRGBA: warped))
        warped[3] = 254
        XCTAssertNil(evidence.compositePreservingSourceCores(originalRGBA: stageInput, warpedRGBA: warped))
    }

    func testPureExternalCoreColourCannotBeReclassifiedAsEditableMixture() throws {
        for kind in [Carrier.darkHair, .goldenHair, .headwrap, .coldLighting] {
            let evidence = try XCTUnwrap(assess(carrier(kind)).evidence)
            var pureExternalChecked = 0, mixedChecked = 0
            for y in 115..<130 { for x in 170..<195 {
                let half = 68 * sqrt(max(0, 1 - pow((Double(y) + 0.5 - 75) / 105, 2)))
                let coverage = min(1, max(0, 0.5 + (half - abs(Double(x) + 0.5 - 120)) / 1.5))
                if coverage == 0 {
                    pureExternalChecked += 1
                    XCTAssertTrue(evidence.preservesDestinationPixel(x: x, y: y), "pure external colour is not a mixed edit permission")
                    XCTAssertNotEqual(evidence.material(x: x, y: y), .mixedTransition)
                    XCTAssertFalse(evidence.allowsSourceFootprint(x: Double(x) + 0.5, y: Double(y) + 0.5))
                }
                if evidence.allowsTransitionDestination(x: x, y: y) { mixedChecked += 1 }
            } }
            XCTAssertGreaterThan(pureExternalChecked, 100)
            if kind == .darkHair { XCTAssertGreaterThan(mixedChecked, 0, "the positive must include a genuine declared antialiased mixture") }
        }
    }

    func testKnownSingleBoundaryMixturesDoNotBecomeRepeatedHairTexture() throws {
        for fraction in [0.3, 0.7] {
            var source = carrier()
            let skin = [210.0, 155.0, 120.0], outside = [30.0, 25.0, 22.0]
            for y in 120..<129 {
                let i = (y * width + 180) * 4
                for c in 0..<3 { source[i + c] = UInt8((skin[c] * (1 - fraction) + outside[c] * fraction).rounded()) }
            }
            let evidence = try XCTUnwrap(assess(source).evidence)
            var declaredMixtures = 0
            for y in 122..<127 {
                if evidence.material(x: 180, y: y) == .mixedTransition { declaredMixtures += 1 }
                XCTAssertNotEqual(evidence.material(x: 180, y: y), .highConfidenceHair,
                    "known antialias mixture is not proof of a hair core")
            }
            XCTAssertGreaterThan(declaredMixtures, 0, "both source-known mixture fractions require a useful qualified boundary")
        }
    }

    func testSourceCoherentCrossingRidgesProtectTwoPixelHighlightsAndObliqueFilaments() throws {
        for kind in [Carrier.darkHair, .coldLighting, .darkLighting] {
            for oblique in [false, true] {
                var source = carrier(kind), core = [Int]()
                let lineRGB = kind == .coldLighting ? [113, 152, 184] : (kind == .darkLighting ? [75, 53, 38] : [180, 140, 100])
                for y in 98..<128 {
                    let center = 169.0 + (oblique ? 0.5 * Double(y - 112) : 0)
                    for x in 158..<182 where abs(Double(x) + 0.5 - center) <= 1 {
                        let p = y * width + x
                        for c in 0..<3 { source[p * 4 + c] = UInt8(lineRGB[c]) }
                        if (104..<120).contains(y) { core.append(p) }
                    }
                }
                let q = assess(source), evidence = try XCTUnwrap(q.evidence)
                XCTAssertGreaterThan(q.aggregates["ridgeCoherentSeedPixels", default: 0], 0)
                XCTAssertGreaterThan(core.count, 16)
                var proposal = source
                for p in 0..<(width * height) { for c in 0..<3 { proposal[p * 4 + c] = 1 } }
                let composite = try XCTUnwrap(evidence.compositePreservingSourceCores(originalRGBA: source, warpedRGBA: proposal))
                for p in core {
                    let x = p % width, y = p / width, i = p * 4
                    XCTAssertEqual(evidence.material(x: x, y: y), .protectedSourceRidge)
                    XCTAssertTrue(evidence.preservesDestinationPixel(x: x, y: y))
                    XCTAssertFalse(evidence.allowsSourceFootprint(x: Double(x) + 0.5, y: Double(y) + 0.5))
                    XCTAssertEqual(evidence.distanceToReserve(x: Double(x) + 0.5, y: Double(y) + 0.5), 0)
                    XCTAssertTrue(source[i..<i + 4] == composite[i..<i + 4], "declared filament RGBA must remain exact")
                }
            }
        }
    }

    func testOneSidedShadowWidePatchAndIsolatedSpotDoNotAcquireRidgeProof() throws {
        for negative in 0..<3 {
            var source = carrier()
            let region: (Range<Int>, Range<Int>) = negative == 0 ? (166..<191, 94..<133) :
                (negative == 1 ? (162..<179, 100..<129) : (169..<171, 112..<114))
            for y in region.1 { for x in region.0 {
                let i = (y * width + x) * 4
                source[i] = 160; source[i + 1] = 118; source[i + 2] = 91
            } }
            let q = assess(source), evidence = try XCTUnwrap(q.evidence)
            XCTAssertEqual(q.aggregates["ridgeCoherentSeedPixels", default: 0], 0,
                "one-sided, wide or incoherent dark evidence cannot prove a filament")
            XCTAssertNotEqual(evidence.material(x: 170, y: 112), .protectedSourceRidge)
            XCTAssertFalse(evidence.preservesDestinationPixel(x: 170, y: 112), "negative cannot pass by disabling the whole cheek")
        }
    }

    func testSameColourLateralAttachmentHasCoherentGeometricReserveWithUsefulInterior() throws {
        for kind in [Carrier.darkHair, .coldLighting, .darkLighting] {
            let q = assess(carrier(kind)), evidence = try XCTUnwrap(q.evidence)
            XCTAssertGreaterThan(q.aggregates["geometricAttachmentPixels", default: 0], 0)
            for y in 105..<117 { for x in 178..<185 {
                XCTAssertTrue(evidence.preservesDestinationPixel(x: x, y: y))
                XCTAssertFalse(evidence.allowsSourceFootprint(x: Double(x) + 0.5, y: Double(y) + 0.5))
                XCTAssertEqual(evidence.distanceToReserve(x: Double(x) + 0.5, y: Double(y) + 0.5), 0)
            } }
            XCTAssertFalse(evidence.preservesDestinationPixel(x: 170, y: 110))
            XCTAssertGreaterThan(evidence.distanceToReserve(x: 170.5, y: 110.5), 0)
        }
    }

    func testFrozenKnownAttachmentMixtureClassificationDoesNotGrantEditPermission() throws {
        // The original C28 toy and its failed editable claim remain frozen in
        // local evidence. These are the SAME bytes/positions: reading material
        // is allowed, while the independent attachment reserve still owns it.
        for fraction in [0.3, 0.7] {
            var source = carrier()
            let skin = [210.0, 155.0, 120.0], outside = [30.0, 25.0, 22.0]
            for y in 120..<129 {
                let i = (y * width + 180) * 4
                for c in 0..<3 { source[i + c] = UInt8((skin[c] * (1 - fraction) + outside[c] * fraction).rounded()) }
            }
            let q = assess(source), evidence = try XCTUnwrap(q.evidence)
            XCTAssertGreaterThan(q.aggregates["reservedMixedTransitionPixels", default: 0], 0)
            for y in 122..<124 {
                XCTAssertEqual(evidence.material(x: 180, y: y), .mixedTransition)
                XCTAssertTrue(evidence.preservesDestinationPixel(x: 180, y: y))
                XCTAssertFalse(evidence.allowsTransitionDestination(x: 180, y: y))
                XCTAssertFalse(evidence.allowsSourceFootprint(x: 180.5, y: Double(y) + 0.5))
                XCTAssertEqual(evidence.distanceToReserve(x: 180.5, y: Double(y) + 0.5), 0)
            }
        }
    }

    func testIndependentLowerCheekBackgroundMixtureRetainsLegalSourceOwnership() throws {
        // Separately predeclared lower-cheek/background boundary, below the
        // attachment. It does not replace or move the frozen original toy.
        for fraction in [0.3, 0.7] {
            var source = carrier()
            let skin = [210.0, 155.0, 120.0], outside = [30.0, 85.0, 125.0]
            for y in 147..<158 {
                let i = (y * width + 167) * 4
                for c in 0..<3 { source[i + c] = UInt8((skin[c] * (1 - fraction) + outside[c] * fraction).rounded()) }
            }
            let evidence = try XCTUnwrap(assess(source).evidence)
            XCTAssertEqual(evidence.material(x: 167, y: 150), .mixedTransition)
            XCTAssertTrue(evidence.allowsTransitionDestination(x: 167, y: 150))
            XCTAssertTrue(evidence.allowsSourceFootprint(x: 166.5, y: 150.5))
            XCTAssertTrue(evidence.preservesDestinationPixel(x: 175, y: 150), "proved background core remains fixed")
            XCTAssertFalse(evidence.allowsSourceFootprint(x: 175.5, y: 150.5))
        }
    }

    private func markerCarrier() -> [UInt8] {
        var source = carrier()
        // Independent source positions were declared before rendering. Every
        // marker modifies only known fully foreground pixels of this fixture.
        for (cx, cy) in [(164, 140), (174, 58), (170, 110)] {
            for y in (cy - 8)..<(cy + 9) { for x in (cx - 5)..<(cx + 6) {
                let i = (y * width + x) * 4
                if source[i] == 210 && source[i + 1] == 155 && source[i + 2] == 120 {
                    source[i] = UInt8(210 + (x - cx) * 4)
                }
            } }
        }
        return source
    }

    private func independentGeneratedCore(x: Int, y: Int) -> Bool {
        let px = Double(x) + 0.5, py = Double(y) + 0.5
        var coverage = 0.0
        if py >= 44 && py < 75 { coverage = abs(px - 120) <= 64 ? 1 : 0 }
        if py >= 75 && py <= 180 {
            let half = 68 * sqrt(max(0, 1 - pow((py - 75) / 105, 2)))
            coverage = min(1, max(0, 0.5 + (half - abs(px - 120)) / 1.5))
        }
        let head = px >= 32 && px <= 208 && py >= 15 && py <= 136
        // Includes the declared hair antialias, not just pure dark RGB cores.
        if head && coverage < 1 { return true }
        if !head && coverage == 0 { return true }
        let boxes: [(Double, Double, Double, Double, Double)] = [
            (0.345, 0.415, 0.30, 0.34, 0.055), (0.585, 0.655, 0.30, 0.34, 0.055),
            (0.335, 0.425, 0.25, 0.28, 0.045), (0.575, 0.665, 0.25, 0.28, 0.045),
            (0.465, 0.535, 0.40, 0.49, 0.008), (0.425, 0.575, 0.56, 0.62, 0.08)
        ]
        return boxes.contains { b in
            let p = max(2, 136 * b.4)
            return px + 0.5 >= b.0 * 240 - p && px - 0.5 <= b.1 * 240 + p
                && py + 0.5 >= b.2 * 240 - p && py - 0.5 <= b.3 * 240 + p
        }
    }

    func testScopedSourceAwareMapMovesIndependentSkinMarkersBothSignedQuarterDirectionsAndKeepsCoresExact() throws {
        let source = markerCarrier(), geometry = face()
        let entries: [(WritableKeyPath<BeautyEffectiveStrengths, Float>, Float,
                       BeautyFaceSourceOwnership.Control, Int, Int, Int)] = [
            (\.faceSlim, BeautySafetyCaps.faceSlim, .faceWidth, 164, 140, 1),
            (\.templeFullness, BeautySafetyCaps.templeFullness, .temple, 174, 58, -1),
            (\.cheekboneSlim, BeautySafetyCaps.cheekboneSlim, .cheekbone, 170, 110, 1)
        ]
        for (ordinal, entry) in entries.enumerated() {
            let evidence = try XCTUnwrap(assess(source, controls: [entry.2]).evidence)
            XCTAssertFalse(evidence.preservesDestinationPixel(x: entry.3, y: entry.4), "predeclared marker must be source-owned")
            XCTAssertGreaterThan(evidence.distanceToReserve(x: Double(entry.3) + 0.5, y: Double(entry.4) + 0.5), 0)
            for sign: Float in [-1, 1] { for quarter: Float in [0.25, 0.5, 0.75, 1] {
                var strengths = BeautyEffectiveStrengths(); strengths[keyPath: entry.0] = entry.1 * sign * quarter
                let map = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height, face: geometry,
                    strengths: strengths, sourceRGBA: source))
                let output = map.applyRGBA(source)
                var coreChanges = 0, alphaChanges = 0, ownedChanges = 0
                for y in 0..<height { for x in 0..<width {
                    let i = (y * width + x) * 4
                    if source[i..<i + 4] != output[i..<i + 4] {
                        if independentGeneratedCore(x: x, y: y) { coreChanges += 1 }
                        if !evidence.preservesDestinationPixel(x: x, y: y) { ownedChanges += 1 }
                    }
                    if source[i + 3] != output[i + 3] { alphaChanges += 1 }
                } }
                XCTAssertEqual(coreChanges, 0, "generated original hair/background/full feature oracle")
                XCTAssertEqual(alphaChanges, 0)
                XCTAssertGreaterThan(ownedChanges, 0, "source-safe refusal cannot satisfy requested marker action")
                var signedDelta = 0, markerCount = 0, foreignMarkerPixels = 0
                for y in (entry.4 - 1)...(entry.4 + 1) { for x in (entry.3 - 1)...(entry.3 + 1) {
                    let i = (y * width + x) * 4
                    signedDelta += (Int(output[i]) - Int(source[i])) * entry.5 * Int(sign)
                    markerCount += 1
                    if output[i + 1] != source[i + 1] || output[i + 2] != source[i + 2] { foreignMarkerPixels += 1 }
                } }
                XCTAssertGreaterThan(Double(signedDelta) / Double(markerCount), 0,
                    "independent source marker direction controlOrdinal=\(ordinal) sign=\(Int(sign)) quarter=\(quarter)")
                XCTAssertEqual(foreignMarkerPixels, 0, "hair/background colour cannot be cloned into the foreground witness")
                XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                XCTAssertTrue(output == map.applyRGBA(source))
                let repeated = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height, face: geometry,
                    strengths: strengths, sourceRGBA: source))
                XCTAssertTrue(output == repeated.applyRGBA(source))
            } }
        }
    }

    func testScopedSourceAwareMapRefusesUnprovedMalformedAndTransparentSourcesWithoutLegacyRevival() {
        let entries: [(WritableKeyPath<BeautyEffectiveStrengths, Float>, Float)] = [
            (\.faceSlim, BeautySafetyCaps.faceSlim), (\.templeFullness, BeautySafetyCaps.templeFullness),
            (\.cheekboneSlim, BeautySafetyCaps.cheekboneSlim)
        ]
        var transparent = markerCarrier(); transparent[3] = 254
        for entry in entries {
            var strengths = BeautyEffectiveStrengths(); strengths[keyPath: entry.0] = entry.1
            for source in [carrier(.ambiguous), transparent] {
                XCTAssertNil(BeautyContinuousFaceMap(width: width, height: height, face: face(), strengths: strengths, sourceRGBA: source))
            }
            let malformed = face(malformedBrow: true)
            XCTAssertNil(BeautyContinuousFaceMap(width: width, height: height, face: malformed,
                strengths: strengths, sourceRGBA: markerCarrier()))
            XCTAssertTrue(BeautyContinuousFaceMap.replacesLegacy(for: malformed), "observed route stays the owner when source proof refuses")
        }
    }

    func testScopedMapRejectsOtherGeometryCombinationButPreservesCurrentStageColorInputCores() throws {
        let source = markerCarrier(), geometry = face()
        let otherGeometry: [WritableKeyPath<BeautyEffectiveStrengths, Float>] = [
            \.chinLength, \.hairlineHeight, \.faceContourSmooth, \.noseSlim, \.mouthWidth,
            \.skinSmoothing, \.skinSharpen
        ]
        for key in otherGeometry {
            var strengths = BeautyEffectiveStrengths(); strengths.faceSlim = BeautySafetyCaps.faceSlim
            strengths[keyPath: key] = 0.1
            XCTAssertNil(BeautyContinuousFaceMap(width: width, height: height, face: geometry, strengths: strengths, sourceRGBA: source))
        }
        var strengths = BeautyEffectiveStrengths(); strengths.faceSlim = BeautySafetyCaps.faceSlim; strengths.brightness = 0.05
        let map = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height, face: geometry,
            strengths: strengths, sourceRGBA: source))
        var current = source
        for i in stride(from: 0, to: current.count, by: 4) { current[i] = UInt8(min(255, Int(current[i]) + 1)) }
        let output = map.applyRGBA(current)
        var coreChanges = 0, alphaChanges = 0
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            if independentGeneratedCore(x: x, y: y), current[i..<i + 4] != output[i..<i + 4] { coreChanges += 1 }
            if current[i + 3] != output[i + 3] { alphaChanges += 1 }
        } }
        XCTAssertEqual(coreChanges, 0)
        XCTAssertEqual(alphaChanges, 0)
        let hair = (40 * width + 45) * 4
        XCTAssertNotEqual(current[hair], source[hair], "the carrier must distinguish current-stage restoration from raw original")
        XCTAssertEqual(output[hair], current[hair])
    }

    func testStillImageStageUsesRawOwnershipProofWhileSamplingAndRestoringCurrentColor() throws {
        let raw = markerCarrier(), geometry = face()
        var current = raw
        // A synthetic pointwise colour raster deliberately erases the original
        // material separation while retaining the independent foreground marker.
        // Its colours are current-stage data, not an ownership measurement.
        for i in stride(from: 0, to: current.count, by: 4) {
            current[i] = UInt8((210 + (Double(raw[i]) - 210) / 8).rounded())
            current[i + 1] = 155; current[i + 2] = 120
        }
        var strengths = BeautyEffectiveStrengths(); strengths.faceSlim = BeautySafetyCaps.faceSlim
        strengths.brightness = 0.05
        let plan = BeautyEffectPlan(activeDomains: [.faceShape, .color], effectiveStrengths: strengths)
        let rawMap = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height, face: geometry,
            strengths: strengths, sourceRGBA: raw))
        XCTAssertNil(BeautyContinuousFaceMap(width: width, height: height, face: geometry,
            strengths: strengths, sourceRGBA: current), "the colour fixture must expose accidental after-colour qualification")
        let stage = BeautyStillImageGeometryStage(sourceRGBA: current, width: width, height: height,
            plan: plan, face: geometry, sourceOwnershipRGBA: raw)
        XCTAssertTrue(stage.sourceRGBA == current)
        XCTAssertTrue(stage.controlPoints.isEmpty, "observed continuous route cannot also emit a legacy proxy")
        let expected = rawMap.applyRGBA(current)
        let output = stage.applyingContinuousContour(to: stage.sourceRGBA)
        XCTAssertTrue(output == expected, "stage must use raw proof and current sampler/compositor bytes together")
        var coreChanges = 0, alphaChanges = 0, markerDelta = 0
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            if independentGeneratedCore(x: x, y: y), current[i..<i + 4] != output[i..<i + 4] { coreChanges += 1 }
            if current[i + 3] != output[i + 3] { alphaChanges += 1 }
        } }
        for y in 139...141 { for x in 163...165 {
            let i = (y * width + x) * 4
            markerDelta += Int(output[i]) - Int(current[i])
        } }
        XCTAssertEqual(coreChanges, 0)
        XCTAssertEqual(alphaChanges, 0)
        XCTAssertGreaterThan(markerDelta, 0, "raw-qualified stage must retain independent requested marker action")
        let hair = (40 * width + 45) * 4
        XCTAssertNotEqual(current[hair], raw[hair])
        XCTAssertEqual(output[hair], current[hair], "core restoration must keep the supplied current colour")
        let rejected = BeautyStillImageGeometryStage(sourceRGBA: current, width: width, height: height,
            plan: plan, face: geometry, sourceOwnershipRGBA: [])
        XCTAssertTrue(rejected.controlPoints.isEmpty, "malformed present proof cannot fall back to legacy points")
        XCTAssertTrue(rejected.applyingContinuousContour(to: rejected.sourceRGBA) == current,
            "malformed present proof refuses instead of qualifying from current colour")
        var other = BeautyEffectiveStrengths(); other.chinLength = BeautySafetyCaps.chinLength
        let otherPlan = BeautyEffectPlan(activeDomains: [.faceShape], effectiveStrengths: other)
        let compatibleMap = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height, face: geometry,
            strengths: other, sourceRGBA: current))
        let compatibleExpected = compatibleMap.applyRGBA(current)
        let compatible = BeautyStillImageGeometryStage(sourceRGBA: current, width: width, height: height,
            plan: otherPlan, face: geometry, sourceOwnershipRGBA: [])
        let compatibleDefault = BeautyStillImageGeometryStage(sourceRGBA: current, width: width, height: height,
            plan: otherPlan, face: geometry)
        XCTAssertTrue(compatible.applyingContinuousContour(to: current) == compatibleExpected,
            "optional scoped proof cannot change a nonscoped continuous field")
        XCTAssertTrue(compatibleDefault.applyingContinuousContour(to: current) == compatibleExpected)
        XCTAssertFalse(compatibleExpected == current, "nonscoped compatibility witness must actually act")
    }

    /// Explicit local diagnostic export. This test never reads a hand mask or
    /// an SDK candidate. Export is optional and restricted to ignored material;
    /// the receipt contains only counts and fixed schema labels.
    func testSourceOnlyOwnershipQualificationAndOptionalLocalMasks() throws {
        let environment = ProcessInfo.processInfo.environment
        guard let input = environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            let generated = assess(carrier(.coldLighting))
            XCTAssertNil(generated.refusal)
            XCTAssertGreaterThan(generated.aggregates["editablePixels", default: 0], 16)
            return
        }
        let cs = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let image = try XCTUnwrap(CIImage(contentsOf: URL(fileURLWithPath: input), options: [.applyOrientationProperty: true]))
        XCTAssertEqual(image.extent.origin, .zero)
        let context = CIContext(options: [.workingColorSpace: cs, .outputColorSpace: cs])
        let directory = try environment["BEAUTY_FACE_REFERENCE_OUTPUT"].map { try ignoredOutput($0) }
        let exportMasks = environment["BEAUTY_FACE_REFERENCE_OWNERSHIP_EXPORT_LOCAL_MASKS"] == "1"
        if exportMasks && directory == nil { throw LocalDiagnosticError.invalidOutput }
        var records = [[String: Any]]()
        for (ordinal, scale) in [1.0, min(1, 960 / max(image.extent.width, image.extent.height))].enumerated() {
            let layer = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            let w = Int(layer.extent.width.rounded()), h = Int(layer.extent.height.rounded())
            let bounds = CGRect(x: 0, y: 0, width: w, height: h)
            var rgba = [UInt8](repeating: 0, count: w * h * 4)
            context.render(layer, toBitmap: &rgba, rowBytes: w * 4, bounds: bounds, format: .RGBA8, colorSpace: cs)
            var detector = BeautyFaceDetector.production()
            let result = detector.detect(image: layer,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                imageExtent: bounds.size, purpose: .geometryAndLocalSupport)
            let observation = try XCTUnwrap(result.observations.first)
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
            let q = BeautyFaceSourceOwnership.assess(sourceRGBA: rgba, width: w, height: h, face: geometry, controls: controls)
            XCTAssertNil(q.refusal, "source-only material qualification refused layerOrdinal=\(ordinal) reason=\(q.refusal?.rawValue ?? "none")")
            var record: [String: Any] = ["layerOrdinal": ordinal, "qualified": q.evidence != nil,
                "refusal": q.refusal?.rawValue ?? "none", "aggregates": q.aggregates,
                "localMasksExported": false]
            if exportMasks, let directory, let evidence = q.evidence {
                var material = [UInt8](repeating: 255, count: w * h * 4), admitted = material, reserved = material
                for y in 0..<h { for x in 0..<w {
                    let i = (y * w + x) * 4
                    let category = evidence.material(x: x, y: y).rawValue * 40
                    let edit: UInt8 = evidence.preservesDestinationPixel(x: x, y: y) ? 0 : 255
                    for c in 0..<3 { material[i + c] = category; admitted[i + c] = edit; reserved[i + c] = 255 - edit }
                } }
                try writeLocalMask(material, width: w, height: h,
                    to: directory.appendingPathComponent("ownership-layer-\(ordinal)-material.png"), colorSpace: cs)
                try writeLocalMask(admitted, width: w, height: h,
                    to: directory.appendingPathComponent("ownership-layer-\(ordinal)-editable.png"), colorSpace: cs)
                try writeLocalMask(reserved, width: w, height: h,
                    to: directory.appendingPathComponent("ownership-layer-\(ordinal)-reserved.png"), colorSpace: cs)
                record["localMasksExported"] = true
            }
            records.append(record)
            print("source-material-ownership layerOrdinal=\(ordinal) qualified=\(q.evidence != nil) reason=\(q.refusal?.rawValue ?? "none") aggregates=\(q.aggregates)")
        }
        if let directory {
            let receipt: [String: Any] = ["schema": "face-source-ownership/bounded-material-v1", "sourceOnly": true,
                "manualMaskRead": false, "effectParity": false, "fullSDKRegression": false,
                "scope": ["faceWidth", "temple", "cheekbone"], "records": records]
            let target = directory.appendingPathComponent("source-only-ownership-qualification.json")
            guard !FileManager.default.fileExists(atPath: target.path) else { throw LocalDiagnosticError.invalidOutput }
            try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys, .prettyPrinted]).write(to: target)
        }
    }

    private enum LocalDiagnosticError: Error { case invalidOutput, encoding }
    private func ignoredOutput(_ path: String) throws -> URL {
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let allowed = package.appendingPathComponent(".build/face-reference").standardizedFileURL
        let output = URL(fileURLWithPath: path, isDirectory: true).standardizedFileURL
        guard output.path.hasPrefix(allowed.path + "/"), output.resolvingSymlinksInPath().path == output.path else {
            throw LocalDiagnosticError.invalidOutput
        }
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        return output
    }
    private func writeLocalMask(_ rgba: [UInt8], width: Int, height: Int, to url: URL, colorSpace: CGColorSpace) throws {
        guard !FileManager.default.fileExists(atPath: url.path),
              let provider = CGDataProvider(data: Data(rgba) as CFData),
              let image = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
                bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent),
              let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw LocalDiagnosticError.encoding
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw LocalDiagnosticError.encoding }
    }

    func testDiagnosticsAndReflectionExposeOnlyAllowlistedAggregates() throws {
        let q = assess(carrier()), evidence = try XCTUnwrap(q.evidence)
        XCTAssertTrue(q.aggregates == assess(carrier()).aggregates)
        XCTAssertEqual(Mirror(reflecting: evidence).children.compactMap(\.label), ["aggregates"])
        XCTAssertEqual(Set(Mirror(reflecting: q).children.compactMap(\.label)), Set(["refusal", "aggregates"]))
        XCTAssertFalse(String(reflecting: evidence).contains("sourceRGBA"))
        XCTAssertFalse(String(reflecting: evidence).contains("owners"))
        XCTAssertFalse(String(reflecting: evidence).contains("reserveDistance"))
    }
}
