import BeautyCore
import BeautyDetection
import CoreImage
import Foundation
import XCTest
@testable import BeautyEffects

final class JawlineShadowTests: XCTestCase {
    private let width = 320, height = 400
    private func box(_ a: Float, _ b: Float, _ c: Float, _ d: Float) -> [SIMD2<Float>] {
        [SIMD2(a, c), SIMD2(b, c), SIMD2(b, d), SIMD2(a, d)]
    }
    private func face(freshness: LandmarkGeometryFreshness = .fresh, missingNose: Bool = false) -> FaceGeometry {
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
            freshness: freshness, observedEyebrowSupport: BeautyEyebrowSemanticSupport(
                left: brow(0.27, side: .left), right: brow(0.57, side: .right)),
            observedOuterLips: box(0.4125, 0.5875, 0.5875, 0.635),
            observedNoseSupport: missingNose ? nil : BeautyObservedNoseSupport(crest: nasal, contour: nasal))
    }
    private enum Kind: CaseIterable { case warm, cold, dark, uniform, splitPalette, disconnected }
    private func boundary(_ x: Double) -> Double {
        130 + 170 * sqrt(max(0, 1 - pow((x - 160) / 100, 2)))
    }
    private func source(_ kind: Kind = .warm) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        let skin: [Double] = kind == .cold ? [115, 155, 195] : kind == .dark ? [92, 66, 52] : [210, 158, 125]
        for y in 0..<height { for x in 0..<width {
            let px = Double(x) + 0.5, py = Double(y) + 0.5, edge = boundary(px)
            var rgb: [Double] = [35, 80, 110]
            let faceSkin = abs(px - 160) <= 100 && py >= 90 && py <= edge
            let neckSkin = (90...230).contains(px) && py >= edge && py < 340
            if faceSkin || neckSkin {
                let t = min(1, max(0, (py - edge + 3) / 6))
                let shade = 1 - 0.06 * t * t * (3 - 2 * t)
                rgb = skin.map { $0 * shade }
                if kind == .splitPalette && x < 160 { rgb = [225, 105, 80] }
                if kind == .disconnected && py > edge + 1 && py < edge + 4 { rgb = [20, 20, 20] }
            }
            if y >= 340 { rgb = [215, 215, 205] } // collar, outside the declared source band
            if x < 80 && y > 150 { rgb = [45 + Double(x % 5), 30, 25] } // hair body
            if (84...96).contains(x) && (175...220).contains(y) { rgb = [180, 130, 105] } // ear
            if (175...176).contains(x) && (280...322).contains(y) { rgb = [28, 24, 20] } // narrow foreground strand
            if kind == .uniform { rgb = skin }
            let p = (y * width + x) * 4
            for c in 0..<3 { bytes[p + c] = UInt8(rgb[c].rounded()) }
        } }
        return bytes
    }
    private func plan(_ fraction: Float = 1) -> BeautyEffectPlan {
        var s = BeautyEffectiveStrengths(); s.jawlineShadow = 0.25 * fraction
        return BeautyEffectPlan(activeDomains: [.jawlineShadow], effectiveStrengths: s)
    }

    func testIndependentUnitParameterCodableCapsAndPlanning() throws {
        XCTAssertEqual(BeautyParameters().jawlineShadow, 0)
        let cases: [(Float, Float)] = [(-1, 0), (0, 0), (0.2, 0.2), (2, 1), (.nan, 0), (.infinity, 0)]
        for (input, expected) in cases {
            XCTAssertEqual(BeautyParameters(jawlineShadow: input).jawlineShadow, expected)
            var p = BeautyParameters(); p.jawlineShadow = input
            XCTAssertEqual(p.normalized().jawlineShadow, expected)
        }
        let legacy = try JSONDecoder().decode(BeautyParameters.self, from: Data("{\"jawSlim\":0.2}".utf8))
        XCTAssertEqual(legacy.jawlineShadow, 0); XCTAssertEqual(legacy.jawSlim, 0.2)
        let requested = BeautyParameters(jawSlim: -0.2, jawlineShadow: 0.17)
        XCTAssertEqual(try JSONDecoder().decode(BeautyParameters.self, from: JSONEncoder().encode(requested)), requested)
        let p = BeautyEffectResolver.resolve(parameters: .init(jawlineShadow: 1), faceGeometry: face())
        XCTAssertEqual(p.effectiveStrengths.jawlineShadow, 0.25)
        XCTAssertEqual(p.effectiveStrengths.jawSlim, 0)
        XCTAssertEqual(p.activeDomains, [.jawlineShadow])
        XCTAssertNil(p.metrics["beauty.effects.geometryPointCount"])
        XCTAssertEqual(p.metrics["beauty.effects.jawlineShadow.sourceQualificationDeferred"], 1)
        XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters: .init(jawlineShadow: 0.25)))
        XCTAssertTrue(BeautyGeometryEffectPipeline.controlPoints(for: p, face: face()).isEmpty)
        let image = CIImage(color: .white).cropped(to: CGRect(x: 0, y: 0, width: 64, height: 64))
        for invalid: Float in [-0.01, 1.01, .nan, .infinity] {
            var bad = BeautyEffectiveStrengths(); bad.jawlineShadow = invalid
            XCTAssertThrowsError(try BeautyBackendRequest(input: .stillImage(image),
                metadata: .init(orientation: .up, source: .testFixture),
                plan: BeautyEffectPlan(activeDomains: [.jawlineShadow], effectiveStrengths: bad))) {
                XCTAssertEqual($0 as? BeautyError, .invalidInput)
            }
        }
    }

    func testGeneratedSkinDirectionsQuartersAndIndependentProtectedContent() throws {
        for kind in [Kind.warm, .cold, .dark] {
            let input = source(kind)
            let q = BeautyJawlineShadow.assess(sourceRGBA: input, width: width, height: height, face: face())
            let evidence = try XCTUnwrap(q.evidence, "generated \(kind): \(q.refusal?.rawValue ?? "none") \(q.aggregates)")
            XCTAssertNil(q.refusal)
            var previousTotal = 0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = evidence.apply(to: input, strength: 0.25 * fraction)
                XCTAssertTrue(output == evidence.apply(to: input, strength: 0.25 * fraction), "repeat")
                var changed = 0, totalDarkening = 0, targetDarkening = 0, targetCount = 0
                var alphaLeaks = 0, brightened = 0, capLeaks = 0, domainLeaks = 0, protectedLeaks = 0
                for y in 0..<height { for x in 0..<width {
                    let p = (y * width + x) * 4, changedPixel = output[p..<(p + 4)] != input[p..<(p + 4)]
                    if output[p + 3] != input[p + 3] { alphaLeaks += 1 }
                    for c in 0..<3 {
                        if output[p + c] > input[p + c] { brightened += 1 }
                        if Double(output[p + c]) < Double(input[p + c]) * 0.82 - 0.5 { capLeaks += 1 }
                        totalDarkening += Int(input[p + c]) - Int(output[p + c])
                    }
                    if changedPixel {
                        changed += 1
                        // This oracle uses the generating analytic boundary,
                        // rather than reading the implementation's weights.
                        let d = Double(y) + 0.5 - boundary(Double(x) + 0.5)
                        let h = (Double(x) + 0.5 - 160) / 100
                        let normalDistance = d / hypot(1, 1.7 * h / sqrt(max(0.000001, 1 - h * h)))
                        if abs(Double(x) + 0.5 - 160) >= 81 || d <= 0 || normalDistance >= 56 { domainLeaks += 1 }
                    }
                    let protected = Double(y) + 0.5 <= boundary(Double(x) + 0.5) || y >= 340 || x < 90 || x >= 230 ||
                        ((175...176).contains(x) && (280...322).contains(y))
                    if protected && changedPixel { protectedLeaks += 1 }
                    if (140...165).contains(x), (12...25).contains(Double(y) + 0.5 - boundary(Double(x) + 0.5)) {
                        targetCount += 1; targetDarkening += Int(input[p]) - Int(output[p])
                    }
                } }
                XCTAssertEqual(alphaLeaks, 0); XCTAssertEqual(brightened, 0); XCTAssertEqual(capLeaks, 0)
                XCTAssertEqual(domainLeaks, 0); XCTAssertEqual(protectedLeaks, 0, "protected \(kind)")
                XCTAssertGreaterThan(changed, 32, "a no-op cannot qualify \(kind)")
                XCTAssertGreaterThan(totalDarkening, previousTotal)
                XCTAssertGreaterThan(targetCount, 32)
                XCTAssertGreaterThan(Double(targetDarkening) / Double(targetCount), Double(fraction) * 3)
                previousTotal = totalDarkening
            }
            XCTAssertTrue(evidence.apply(to: input, strength: 0) == input)
            XCTAssertTrue(evidence.apply(to: input, strength: .nan) == input)
        }
    }

    func testSourceNegativesMalformedAndNonopaqueRefuseWithoutFallback() throws {
        for kind in [Kind.uniform, .splitPalette, .disconnected] {
            let q = BeautyJawlineShadow.assess(sourceRGBA: source(kind), width: width, height: height, face: face())
            XCTAssertNil(q.evidence, "negative \(kind)")
            XCTAssertNotNil(q.refusal, "negative \(kind): \(q.aggregates)")
        }
        for geometry in [face(freshness: .stale), face(freshness: .reused), face(missingNose: true)] {
            XCTAssertEqual(BeautyJawlineShadow.assess(sourceRGBA: source(), width: width, height: height, face: geometry).refusal, .invalidSupport)
        }
        for bad in [[], Array(source().dropLast())] {
            XCTAssertEqual(BeautyJawlineShadow.assess(sourceRGBA: bad, width: width, height: height, face: face()).refusal, .invalidRaster)
        }
        var transparent = source(); transparent[3] = 254
        XCTAssertEqual(BeautyJawlineShadow.assess(sourceRGBA: transparent, width: width, height: height, face: face()).refusal, .nonopaqueSource)
        XCTAssertEqual(BeautyJawlineShadow.assess(sourceRGBA: [], width: Int.max, height: 64, face: face()).refusal, .invalidRaster)
    }

    func testCurrentColorCompositionAndPresentMalformedProofRemainExact() throws {
        let immutable = source(), geometry = face(), requested = plan()
        let evidence = try XCTUnwrap(BeautyJawlineShadow.assess(sourceRGBA: immutable, width: width, height: height, face: geometry).evidence)
        var current = immutable
        for p in stride(from: 0, to: current.count, by: 4) { for c in 0..<3 { current[p + c] = UInt8(min(255, Int(current[p + c]) + 7)) } }
        let stage = BeautyStillImageGeometryStage(sourceRGBA: current, width: width, height: height,
            plan: requested, face: geometry, jawlineShadowSourceRGBA: immutable)
        XCTAssertNil(stage.jawlineShadowRefusal)
        XCTAssertTrue(stage.controlPoints.isEmpty)
        XCTAssertTrue(stage.sourceRGBA == current)
        XCTAssertTrue(stage.applyingTranslation(to: current) == evidence.apply(to: current, strength: 0.25))
        XCTAssertFalse(stage.applyingTranslation(to: current) == current)
        for malformed in [[], Array(immutable.dropLast())] {
            let rejected = BeautyStillImageGeometryStage(sourceRGBA: current, width: width, height: height,
                plan: requested, face: geometry, jawlineShadowSourceRGBA: malformed)
            XCTAssertEqual(rejected.jawlineShadowRefusal, .invalidRaster)
            XCTAssertTrue(rejected.applyingTranslation(to: current) == current)
        }
    }

    func testGeometryAndTextureCombinationsRejectOnlyNewToneIntent() {
        for sibling: WritableKeyPath<BeautyParameters, Float> in [\.chinLength, \.faceSlim, \.wholeFaceYPosition, \.skinSmoothing, \.skinSharpen] {
            var base = BeautyParameters(); base[keyPath: sibling] = 0.2
            var mixed = base; mixed.jawlineShadow = 0.25
            let original = BeautyEffectResolver.resolve(parameters: base, faceGeometry: face())
            let output = BeautyEffectResolver.resolve(parameters: mixed, faceGeometry: face())
            XCTAssertEqual(output.effectiveStrengths.jawlineShadow, 0)
            XCTAssertEqual(output.effectiveStrengths, original.effectiveStrengths)
            XCTAssertTrue(output.skippedDomains.contains(.jawlineShadow))
            XCTAssertTrue(output.warnings.contains { $0.code == "jawline_shadow_source_scope_unavailable" })
        }
        var p = BeautyParameters(jawlineShadow: 0.25); p.brightness = 0.1; p.contrast = 0.1
        XCTAssertEqual(BeautyEffectResolver.resolve(parameters: p, faceGeometry: face()).effectiveStrengths.jawlineShadow, 0.25)
        p.wholeFaceTilt = 0.000001
        XCTAssertEqual(BeautyEffectResolver.resolve(parameters: p, faceGeometry: face()).effectiveStrengths.jawlineShadow, 0,
            "a nonzero geometry request cannot regain the tonal scope after provider sanitization")
    }

    func testAuditedSourceFixedFieldsMayShareSourceToneWhileOtherGeometryRemainsRejected() {
        var parameters = BeautyParameters(jawlineShadow: 0.25)
        parameters.jawSlim = 0.2; parameters.hairlineHeight = -0.2
        XCTAssertTrue(BeautyJawlineShadow.hasIndependentSourceRequest(parameters))
        var strengths = BeautyEffectiveStrengths()
        strengths.jawlineShadow = 0.25; strengths.jawSlim = 0.2; strengths.hairlineHeight = -0.2
        XCTAssertTrue(BeautyJawlineShadow.hasIndependentSourceCoordinates(strengths))
        let resolved = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face())
        XCTAssertEqual(resolved.effectiveStrengths.jawlineShadow, 0.25)
        parameters.chinLength = 0.001; strengths.chinLength = 0.001
        XCTAssertFalse(BeautyJawlineShadow.hasIndependentSourceRequest(parameters))
        XCTAssertFalse(BeautyJawlineShadow.hasIndependentSourceCoordinates(strengths))
    }

    /// A separate analytic lighting carrier has the same geometry and skin
    /// families at both raster sizes. These pixels are generated at their
    /// native sample centers, rather than upsampling a qualification image.
    private func softLightingSource(scale: Double, phase: Double, competing: Bool = false) -> (Int, Int, [UInt8]) {
        let w = Int(Double(width) * scale), h = Int(Double(height) * scale)
        var bytes = [UInt8](repeating: 255, count: w * h * 4)
        func smooth(_ t: Double) -> Double { let u = min(1, max(0, t)); return u * u * (3 - 2 * u) }
        for y in 0..<h { for x in 0..<w {
            let px = (Double(x) + 0.5) / scale, py = (Double(y) + 0.5) / scale
            let edge = boundary(px), offset = py - edge - phase
            var rgb: [Double] = [35, 80, 110]
            if (abs(px - 160) <= 100 && py >= 90 && py <= edge) ||
                ((90...230).contains(px) && py >= edge && py < 340) {
                let lighting: Double
                if competing {
                    // Two equally credible same-material dark boundaries,
                    // separated by a return to the original illumination.
                    lighting = smooth((offset + 4.5) / 1.5) - smooth((offset + 1.5) / 1.5)
                        + smooth((offset - 2.5) / 1.5)
                } else {
                    lighting = smooth((offset + 2.5) / 5)
                }
                rgb = [210, 158, 125].map { Double($0) * (1 - 0.14 * lighting) }
            }
            if py >= 340 { rgb = [215, 215, 205] }
            if (175...176).contains(px) && (280...322).contains(py) { rgb = [28, 24, 20] }
            let p = (y * w + x) * 4
            for c in 0..<3 { bytes[p + c] = UInt8(rgb[c].rounded()) }
        } }
        return (w, h, bytes)
    }

    func testRegisteredSoftSourceLightingHasBroadUsefulQuartersAtBothPhysicalSizes() throws {
        for scale in [1.0, 0.5] { for phase in [-1.5, 1.5] {
            let (w, h, bytes) = softLightingSource(scale: scale, phase: phase)
            let q = BeautyJawlineShadow.assess(sourceRGBA: bytes, width: w, height: h, face: face())
            let evidence = try XCTUnwrap(q.evidence, "soft carrier scale=\(scale) phase=\(phase) \(q.refusal?.rawValue ?? "none") \(q.aggregates)")
            var prior = 0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = evidence.apply(to: bytes, strength: 0.25 * fraction)
                var changed = 0, darkening = 0, exterior = 0, protected = 0, alpha = 0
                var centerRows = Set<Int>()
                for y in 0..<h { for x in 0..<w {
                    let p = (y * w + x) * 4
                    let px = (Double(x) + 0.5) / scale, py = (Double(y) + 0.5) / scale
                    let active = output[p..<(p + 4)] != bytes[p..<(p + 4)]
                    if output[p + 3] != bytes[p + 3] { alpha += 1 }
                    for c in 0..<3 { darkening += Int(bytes[p + c]) - Int(output[p + c]) }
                    if active {
                        changed += 1
                        let d = py - boundary(px)
                        let h = (px - 160) / 100
                        let normalDistance = d / hypot(1, 1.7 * h / sqrt(max(0.000001, 1 - h * h)))
                        if abs(px - 160) >= 81 || d <= 0 || normalDistance >= 56 { exterior += 1 }
                        if py <= boundary(px) || py >= 340 || px < 90 || px >= 230 ||
                            ((175...176).contains(px) && (280...322).contains(py)) { protected += 1 }
                        if abs(px - 160) < 2 { centerRows.insert(y) }
                    }
                } }
                XCTAssertEqual(exterior, 0); XCTAssertEqual(protected, 0); XCTAssertEqual(alpha, 0)
                XCTAssertGreaterThan(changed, 16, "soft lighting must remain useful at both native raster sizes")
                XCTAssertGreaterThan(darkening, prior)
                if fraction == 1 { XCTAssertGreaterThanOrEqual(centerRows.count, Int(24 * scale), "a fine painted edge cannot qualify as broad lighting") }
                XCTAssertTrue(output == evidence.apply(to: bytes, strength: 0.25 * fraction))
                prior = darkening
            }
        } }
    }

    func testCompetingOrAbsentSourceLightingDoesNotInventOneJawBoundary() {
        for scale in [1.0, 0.5] {
            for (phase, competing) in [(0.0, true), (20.0, false)] {
                let (w, h, bytes) = softLightingSource(scale: scale, phase: phase, competing: competing)
                let q = BeautyJawlineShadow.assess(sourceRGBA: bytes, width: w, height: h, face: face())
                XCTAssertNil(q.evidence, "ambiguous/absent source lighting scale=\(scale) competing=\(competing), \(q.aggregates)")
                XCTAssertNotNil(q.refusal)
            }
        }
    }

    func testRegisteredDarkSideKeepsKnownActualJawBrightSideExactAndUsefulBelowIt() throws {
        for scale in [1.0, 0.5] { for phase in [-1.5, 1.5] {
            let (w, h, bytes) = softLightingSource(scale: scale, phase: phase)
            let q = BeautyJawlineShadow.assess(sourceRGBA: bytes, width: w, height: h, face: face())
            let evidence = try XCTUnwrap(q.evidence, "dark-side source scale=\(scale) phase=\(phase) \(q.refusal?.rawValue ?? "none") \(q.aggregates)")
            var prior = 0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = evidence.apply(to: bytes, strength: 0.25 * fraction)
                var upperChanged = 0, changed = 0, belowDarkening = 0, alpha = 0
                for y in 0..<h { for x in 0..<w {
                    let p = (y * w + x) * 4
                    let px = (Double(x) + 0.5) / scale, py = (Double(y) + 0.5) / scale
                    let delta = Int(bytes[p]) - Int(output[p])
                    if output[p + 3] != bytes[p + 3] { alpha += 1 }
                    if output[p..<(p + 4)] != bytes[p..<(p + 4)] {
                        changed += 1
                        // Independent analytic SOURCE boundary, not the
                        // registered phase or the implementation's mask.
                        if py <= boundary(px) + phase { upperChanged += 1 }
                        else { belowDarkening += delta }
                    }
                } }
                XCTAssertEqual(upperChanged, 0, "source jaw bright side remains exact at both native scales")
                XCTAssertEqual(alpha, 0)
                XCTAssertGreaterThan(changed, 16, "refusal/no-op cannot establish safe useful shading")
                XCTAssertGreaterThan(belowDarkening, prior)
                XCTAssertTrue(output == evidence.apply(to: bytes, strength: 0.25 * fraction))
                prior = belowDarkening
            }
        } }
    }

    func testProductionSourceQualificationOrGeneratedSafety() throws {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try testGeneratedSkinDirectionsQuartersAndIndependentProtectedContent(); return
        }
        let url = URL(fileURLWithPath: path).standardizedFileURL
        let properties = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        guard properties.isRegularFile == true, properties.isSymbolicLink != true,
              let size = properties.fileSize, size > 0, size <= BeautyConfiguration.defaultMaximumInputByteCount else {
            XCTFail("invalid local source"); return
        }
        let full = try XCTUnwrap(CIImage(contentsOf: url, options: [.applyOrientationProperty: true]))
        let scale = min(1, 960 / max(full.extent.width, full.extent.height))
        let preview = full.transformed(by: CGAffineTransform(scaleX: scale, y: scale)).cropped(to:
            CGRect(x: 0, y: 0, width: floor(full.extent.width * scale), height: floor(full.extent.height * scale)))
        let cs = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        var aggregates = [[String: Any]]()
        for (layer, image) in [("full", full), ("preview", preview)] {
            let w = Int(image.extent.width), h = Int(image.extent.height)
            var detector = BeautyFaceDetector.production()
            let detected = detector.detect(image: image, metadata: .init(orientation: .up, source: .photo),
                imageExtent: image.extent.size, purpose: .geometryAndLocalSupport)
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: try XCTUnwrap(detected.observations.first))
            var bytes = [UInt8](repeating: 0, count: w * h * 4)
            BeautyImageContexts.context(for: cs).render(image, toBitmap: &bytes, rowBytes: w * 4,
                bounds: image.extent, format: .RGBA8, colorSpace: cs)
            let q = BeautyJawlineShadow.assess(sourceRGBA: bytes, width: w, height: h, face: geometry)
            let output = q.evidence?.apply(to: bytes, strength: 0.25) ?? bytes
            let changed = stride(from: 0, to: bytes.count, by: 4).filter { bytes[$0..<($0 + 4)] != output[$0..<($0 + 4)] }.count
            aggregates.append(["layer": layer, "width": w, "height": h, "refusal": q.refusal?.rawValue ?? "none",
                "sourceQualification": q.aggregates, "changedPixels": changed])
            XCTAssertNotNil(q.evidence, "real source \(layer) remains unmet: \(q.refusal?.rawValue ?? "none") \(q.aggregates)")
            XCTAssertGreaterThan(changed, 16, "source activity is required \(layer)")
            XCTAssertTrue(stride(from: 3, to: bytes.count, by: 4).allSatisfy { output[$0] == bytes[$0] })
        }
        let data = try JSONSerialization.data(withJSONObject: aggregates, options: [.sortedKeys])
        print("JAWLINE_SOURCE_QUALIFICATION " + String(decoding: data, as: UTF8.self))
    }
}
