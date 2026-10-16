import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import ImageIO
import XCTest
@testable import BeautyEffects
@testable import BeautySDK

/// Independent source-only photographic permission and activity declaration.
/// It never reads the implementation's weights or treats its refusal as effect
/// success. Private annotations are evaluation inputs, never production inputs.
final class BeautyEngineJawlineShadowPhotoPolicyTests: XCTestCase {
    private enum Failure: Error { case input, source, output }
    private let space = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
    private let sourceHash = "bd5fe998c2e49b0812a9bd881bbc4c345eb15c10445b16bc790ba7f40c4b2213"
    private let hashes = [
        "jaw_shadow_legal": "48219acc3d41b311a789f55a28a00783736745f91752b2732629a47e4df407f6",
        "jaw_shadow_activity": "7a755fbd03041424e093ddbaf5da0d44b2b78a1ed27f8d81013e324df335ed51",
        "jaw_shadow_lower_face_control": "d7616a3ca782b3401f9f0e0767be1f0a0466a0de4f456082e69802dfbbd44466",
        "ears_core": "d8a609c613fdb6761e58886b8cf5d94e29af6c0fe74b26cf46286245cc477d1a",
        "eyes_core": "a8219b5a697f2feed1e3b3e4a33f0f49a777a60779d76f7aaba188125016f958",
        "brows_core": "99cea5696cba82870200beead7c6edbe32443e76bdf3a7796c5f89560dfa2e6e",
        "nose_core": "ad5258bf511fe2e553049d9e1c05307942269c1d94d52ebe0c2f580e2f186452",
        "lips_core": "cde38241edb193ba5eef0b856b5486900776fa9f2b3456d326536b638be6aa64",
        "hair_core": "23566188baca12ac9383890400191839abd6e2d56781ad02c2a5ef8b7edd844b",
        "crossing_hair_core": "25312aa75a324d863ccaef45fe1f564f7cb6e24c6e8c6f29004f303f17ba2202"
    ]

    func testPublicCPUJawlineShadowActualPhotoUsesFrozenSourcePolicyAndCurrentColor() throws {
        try runPhoto(backend: .cpu)
    }

    func testPublicMetalJawlineShadowActualPhotoUsesFrozenSourcePolicyAndMatchesCPU() throws {
        try runPhoto(backend: .gpu)
    }

    func testGeneratedIndependentPolicyRejectsNoopBrighteningAndProtectedContentLeaks() {
        let count = 64
        var legal = [Bool](repeating: false, count: count), activity = legal, control = legal
        legal[27] = true; legal[28] = true; activity[27] = true; control[35] = true
        var fine = Array(repeating: [Bool](repeating: false, count: count), count: 7)
        fine[0][1] = true; fine[5][2] = true
        let policy = Policy(legal: legal, activity: activity, control: control, fine: fine)
        let original: [UInt8] = Array(repeating: [UInt8(128), 128, 128, 255], count: count).flatMap { $0 }
        let noop = policy.counts(original, original)
        XCTAssertFalse(noop.usefulEndpoint)
        var positive = original
        for c in 0..<3 { positive[27 * 4 + c] -= 8 }
        let p = policy.counts(original, positive)
        XCTAssertGreaterThan(p.darkening, 0); XCTAssertEqual(p.meanRGBDelta, [-8, -8, -8])
        XCTAssertEqual(p.permanent, 0); XCTAssertEqual(p.bodyHair, 0); XCTAssertEqual(p.exterior, 0)
        var leaked = positive
        leaked[4] -= 1; leaked[8] -= 1; leaked[35 * 4] -= 1; leaked[40 * 4] += 1; leaked[3] = 254
        let bad = policy.counts(original, leaked)
        XCTAssertEqual(bad.permanent, 1); XCTAssertEqual(bad.bodyHair, 1)
        XCTAssertEqual(bad.control, 1); XCTAssertEqual(bad.exterior, 5)
        XCTAssertEqual(bad.alpha, 1); XCTAssertEqual(bad.brighterChannels, 1)
        fine[0][27] = true
        XCTAssertEqual(Policy(legal: legal, activity: activity, control: control, fine: fine).permanentLegalIntersection, 1)
    }

    private func runPhoto(backend: BeautyRenderBackend) throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            testGeneratedIndependentPolicyRejectsNoopBrighteningAndProtectedContentLeaks()
            return
        }
        let output = try outputDirectory()
        // Both layers' permission, activity, controls, independent fine cores
        // and source qualifications are frozen BEFORE either engine renders.
        let sources = try sourceLayers(input).map { layer -> FrozenSource in
            let legal = try mask("jaw_shadow_legal", layer), activity = try mask("jaw_shadow_activity", layer)
            let control = try mask("jaw_shadow_lower_face_control", layer)
            let fine = try ["ears_core", "eyes_core", "brows_core", "nose_core", "lips_core", "hair_core", "crossing_hair_core"]
                .map { try mask($0, layer) }
            var detector = BeautyFaceDetector.production()
            let detected = detector.detect(image: layer.image, metadata: metadata,
                imageExtent: layer.image.extent.size, purpose: .geometryAndLocalSupport)
            XCTAssertEqual(detected.summary.availability, .usable)
            XCTAssertEqual(detected.observations.count, 1)
            let observation = try XCTUnwrap(detected.observations.first)
            let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
            let qualification = BeautyJawlineShadow.assess(sourceRGBA: layer.bytes,
                width: layer.width, height: layer.height, face: face)
            let policy = Policy(legal: legal, activity: activity, control: control, fine: fine)
            var authority = ["sourceDomainPixels": 0, "sourceDomainExterior": 0,
                "sourceDomainPermanent": 0, "sourceDomainBodyHair": 0, "sourceDomainLowerFaceControl": 0]
            // Exhaust the source-owned domain BEFORE a strength or candidate
            // exists. Low gain/8bit rounding cannot hide a geometric leak.
            if let evidence = qualification.evidence {
                for y in 0..<layer.height { for x in 0..<layer.width where evidence.ownsSourceDomainPixel(x: x, y: y) {
                    let p = y * layer.width + x
                    authority["sourceDomainPixels", default: 0] += 1
                    if !legal[p] { authority["sourceDomainExterior", default: 0] += 1 }
                    if fine.prefix(5).contains(where: { $0[p] }) { authority["sourceDomainPermanent", default: 0] += 1 }
                    if fine[5][p] || fine[6][p] { authority["sourceDomainBodyHair", default: 0] += 1 }
                    if control[p] { authority["sourceDomainLowerFaceControl", default: 0] += 1 }
                } }
            }
            return FrozenSource(layer: layer, policy: policy, qualification: qualification,
                sourceGeometry: observation.mesh == nil ? "production-Vision" : "production-MediaPipe",
                sourceAuthority: authority)
        }
        var rows = [[String: Any]]()
        let backendName = backend == .cpu ? "cpu" : "metal"
        for source in sources {
            let layer = source.layer, policy = source.policy
            XCTAssertEqual(policy.permanentLegalIntersection, 0, "frozen permission cannot exempt ears or features")
            XCTAssertEqual(policy.hairLegalIntersection, 0, "tonal shading has no permission to shade source hair")
            XCTAssertEqual(policy.controlLegalIntersection, 0)
            XCTAssertEqual(policy.activityExterior, 0)
            XCTAssertGreaterThan(policy.activity.filter { $0 }.count, 16)
            guard policy.permanentLegalIntersection == 0, policy.hairLegalIntersection == 0,
                  policy.controlLegalIntersection == 0, policy.activityExterior == 0,
                  policy.activity.filter({ $0 }).count > 16 else {
                rows.append(["layer": layer.id, "backend": backendName, "sourceDeclarationQualified": false,
                    "candidateRendered": false, "permanentLegalIntersection": policy.permanentLegalIntersection,
                    "hairLegalIntersection": policy.hairLegalIntersection,
                    "controlLegalIntersection": policy.controlLegalIntersection, "activityExterior": policy.activityExterior])
                continue
            }
            XCTAssertNotNil(source.qualification.evidence, "actual source remains unmet: \(source.qualification.refusal?.rawValue ?? "none")")
            XCTAssertNil(source.qualification.refusal)
            XCTAssertGreaterThan(source.sourceAuthority["sourceDomainPixels", default: 0], 16)
            for key in ["sourceDomainExterior", "sourceDomainPermanent", "sourceDomainBodyHair", "sourceDomainLowerFaceControl"] {
                XCTAssertEqual(source.sourceAuthority[key, default: 0], 0, "pre-gain source authority: \(key)")
            }
            // A source refusal deliberately does not skip public processing:
            // its actual activity gate must also fail, with both layers kept.
            let engine = try BeautyEngine(configuration: .init(renderBackend: backend))
            let image = try cgImage(layer), prepared = try engine.prepareStillImage(image: image, metadata: metadata)
            let neutral = try engine.processResult(preparedImage: prepared, parameters: .init())
            let neutralExact = try pixels(neutral.output, layer) == layer.bytes
            XCTAssertTrue(neutralExact); XCTAssertEqual(neutral.output.colorSpace?.name, space.name)
            let cpu: BeautyEngine? = backend == .gpu ? try BeautyEngine(configuration: .init(renderBackend: .cpu)) : nil
            let cpuPrepared = try cpu?.prepareStillImage(image: image, metadata: metadata)
            for brightness: Float in [0, 0.10] {
                var parameters = BeautyParameters(); parameters.brightness = brightness
                let baseline = try pixels(engine.processResult(preparedImage: prepared, parameters: parameters).output, layer)
                let baselineColorChanged = baseline != layer.bytes
                if brightness > 0 { XCTAssertTrue(baselineColorChanged, "current-colour witness must actually act") }
                var previousDarkening = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    parameters.jawlineShadow = BeautySafetyCaps.jawlineShadow * fraction
                    let result = try engine.processResult(preparedImage: prepared, parameters: parameters)
                    let actual = try pixels(result.output, layer), counts = policy.counts(baseline, actual)
                    XCTAssertEqual(counts.permanent, 0); XCTAssertEqual(counts.bodyHair, 0)
                    XCTAssertEqual(counts.control, 0); XCTAssertEqual(counts.exterior, 0)
                    XCTAssertEqual(counts.alpha, 0); XCTAssertEqual(counts.brighterChannels, 0)
                    XCTAssertEqual(counts.capLeakChannels, 0)
                    XCTAssertGreaterThan(counts.darkening, previousDarkening, "four source-fixed quarters must actually darken monotonically")
                    XCTAssertTrue(counts.meanRGBDelta.allSatisfy { $0 < 0 }, "each RGB mean must darken on the fixed activity declaration")
                    if fraction == 1 { XCTAssertTrue(counts.usefulEndpoint, "actual endpoint retains .25/3/16 gate; no-op cannot pass") }
                    previousDarkening = counts.darkening
                    let expected = source.qualification.evidence?.apply(to: baseline,
                        strength: BeautySafetyCaps.jawlineShadow * fraction) ?? baseline
                    let phaseExact = expected == actual
                    XCTAssertTrue(phaseExact, "qualification reads original source but composition must multiply CURRENT colour")
                    let repeated = try pixels(engine.processResult(preparedImage: prepared, parameters: parameters).output, layer) == actual
                    XCTAssertTrue(repeated)
                    XCTAssertEqual(result.output.extent, layer.image.extent)
                    XCTAssertEqual(result.output.colorSpace?.name, space.name)
                    XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1)
                    XCTAssertNil(result.metrics["beauty.backend.cpuGeometryCapacityFallback"], "requested Metal cannot silently be a CPU geometry fallback")
                    var parity: [String: Any] = ["tested": false]
                    if let cpu, let cpuPrepared {
                        let cpuActual = try pixels(cpu.processResult(preparedImage: cpuPrepared, parameters: parameters).output, layer)
                        let comparison = compare(cpuActual, actual)
                        // Existing still-image backend parity contract.
                        XCTAssertLessThanOrEqual(comparison.maximum, 2)
                        XCTAssertLessThan(comparison.mean, 0.75)
                        XCTAssertEqual(comparison.alpha, 0)
                        parity = ["tested": true, "maximumByteDelta": comparison.maximum,
                            "meanRGBByteDelta": comparison.mean, "alphaChangedPixels": comparison.alpha]
                    }
                    let name = "\(backendName)-\(layer.id)-brightness-\(Int(brightness * 100))-quarter-\(Int(fraction * 100))"
                    try save(result.output, output.appendingPathComponent(name + ".png"))
                    rows.append(["layer": layer.id, "backend": backendName, "fraction": fraction, "brightness": brightness,
                        "sourceDeclarationQualified": true, "candidateRendered": true,
                        "sourceGeometry": source.sourceGeometry, "sourceQualified": source.qualification.evidence != nil,
                        "sourceRefusal": source.qualification.refusal?.rawValue ?? "none",
                        "sourceQualification": source.qualification.aggregates,
                        "sourceDomainAuthorityBeforeStrength": source.sourceAuthority,
                        "sourceAuthorityCheckedBeforeCandidate": true,
                        "sourceActivityDenominatorPixels": policy.activity.filter { $0 }.count,
                        "permanentChangedPixels": counts.permanent, "bodyHairChangedPixels": counts.bodyHair,
                        "lowerFaceControlChangedPixels": counts.control, "exteriorChangedPixels": counts.exterior,
                        "alphaChangedPixels": counts.alpha, "brightenedChannels": counts.brighterChannels,
                        "capLeakChannels": counts.capLeakChannels, "targetChangedPixels": counts.changed,
                        "targetRMSByteDelta": counts.rms, "targetMaximumByteDelta": counts.maximum,
                        "targetMeanRGBDelta": counts.meanRGBDelta, "currentColorBaselineActive": baselineColorChanged,
                        "currentColorCompositionExact": phaseExact, "neutralExact": neutralExact,
                        "repeatedExact": repeated, "CPUParity": parity])
                }
                parameters.jawlineShadow = 0
                XCTAssertTrue(try pixels(engine.processResult(preparedImage: prepared, parameters: parameters).output, layer) == baseline,
                    "source-owned tone state cannot leak into the recovered baseline")
            }
        }
        let aggregate: [String: Any] = ["schema": "jawline-shadow-independent-photo-policy/v1", "records": rows,
            "sourceDeclarationPrecedesCandidates": true, "productionReadsPrivateAnnotation": false,
            "candidateSelectedPoints": false, "sourceRefusalIsSuccess": false,
            "MeituMeanRGBDeltaUsedAsGate": false, "appearanceParity": false, "fullSDKRegression": false]
        let url = output.appendingPathComponent("jawline-shadow-\(backendName)-photo-policy.json")
        guard !FileManager.default.fileExists(atPath: url.path) else { throw Failure.output }
        try JSONSerialization.data(withJSONObject: aggregate, options: [.sortedKeys, .prettyPrinted]).write(to: url)
    }

    private struct Layer { let id: String; let image: CIImage; let width: Int; let height: Int; let bytes: [UInt8] }
    private struct FrozenSource {
        let layer: Layer; let policy: Policy; let qualification: BeautyJawlineShadow.Qualification; let sourceGeometry: String
        let sourceAuthority: [String: Int]
    }
    private struct Counts {
        var permanent = 0, bodyHair = 0, exterior = 0, control = 0, alpha = 0
        var brighterChannels = 0, capLeakChannels = 0, changed = 0, maximum = 0
        var rms = 0.0, darkening = 0.0
        var meanRGBDelta = [Double](repeating: 0, count: 3)
        var usefulEndpoint: Bool { rms >= 0.25 && maximum >= 3 && changed >= 16 }
    }
    private struct Policy {
        let legal: [Bool], activity: [Bool], control: [Bool], fine: [[Bool]]
        let permanentLegalIntersection: Int, hairLegalIntersection: Int, controlLegalIntersection: Int, activityExterior: Int
        init(legal: [Bool], activity: [Bool], control: [Bool], fine: [[Bool]]) {
            self.legal = legal; self.activity = activity; self.control = control; self.fine = fine
            permanentLegalIntersection = legal.indices.filter { p in legal[p] && fine.prefix(5).contains { $0[p] } }.count
            hairLegalIntersection = legal.indices.filter { p in legal[p] && (fine[5][p] || fine[6][p]) }.count
            controlLegalIntersection = legal.indices.filter { legal[$0] && control[$0] }.count
            activityExterior = legal.indices.filter { activity[$0] && !legal[$0] }.count
        }
        func counts(_ source: [UInt8], _ output: [UInt8]) -> Counts {
            var c = Counts(), square = 0.0, count = 0
            for p in legal.indices {
                let i = p * 4, differs = (0..<4).contains { source[i + $0] != output[i + $0] }
                if differs {
                    if fine.prefix(5).contains(where: { $0[p] }) { c.permanent += 1 }
                    if fine[5][p] || fine[6][p] { c.bodyHair += 1 }
                    if !legal[p] { c.exterior += 1 }; if control[p] { c.control += 1 }
                }
                if source[i + 3] != output[i + 3] { c.alpha += 1 }
                var pixelChanged = false
                for channel in 0..<3 {
                    let a = Int(source[i + channel]), b = Int(output[i + channel]), d = b - a
                    if b > a { c.brighterChannels += 1 }
                    if Double(b) < Double(a) * 0.82 - 0.5 { c.capLeakChannels += 1 }
                    if activity[p] {
                        square += Double(d * d); c.maximum = max(c.maximum, abs(d))
                        c.meanRGBDelta[channel] += Double(d); pixelChanged = pixelChanged || d != 0
                    }
                }
                if activity[p] { count += 1; if pixelChanged { c.changed += 1 } }
            }
            c.rms = sqrt(square / Double(max(1, count * 3)))
            c.meanRGBDelta = c.meanRGBDelta.map { $0 / Double(max(1, count)) }
            c.darkening = -c.meanRGBDelta.reduce(0, +)
            return c
        }
    }
    private func compare(_ a: [UInt8], _ b: [UInt8]) -> (maximum: Int, mean: Double, alpha: Int) {
        var maximum = 0, sum = 0.0, count = 0, alpha = 0
        for p in stride(from: 0, to: a.count, by: 4) {
            if a[p + 3] != b[p + 3] { alpha += 1 }
            for c in 0..<3 { let d = abs(Int(a[p + c]) - Int(b[p + c])); maximum = max(maximum, d); sum += Double(d); count += 1 }
        }
        return (maximum, sum / Double(max(1, count)), alpha)
    }
    private func sourceLayers(_ path: String) throws -> [Layer] {
        #if os(iOS)
        let url = privateURL("portrait")
        #else
        let url = URL(fileURLWithPath: path).standardizedFileURL
        #endif
        let attributes = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        guard attributes.isRegularFile == true, attributes.isSymbolicLink != true,
              let size = attributes.fileSize, size > 0, size <= BeautyConfiguration.defaultMaximumInputByteCount,
              hash(try Data(contentsOf: url)) == sourceHash,
              let input = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) else { throw Failure.input }
        let canonicalizer = BeautyStillImageCanonicalizer()
        let full = try canonicalizer.canonicalize(image: input, metadata: metadata, maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
        return try [("full", 1.0), ("preview960", min(1, 960 / Double(max(full.width, full.height))))].map { id, scale in
            let image = full.ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale)).cropped(to:
                CGRect(x: 0, y: 0, width: floor(Double(full.width) * scale), height: floor(Double(full.height) * scale)))
            let r = try canonicalizer.canonicalize(image: image, metadata: metadata, maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
            let bytes = Array(r.rgba8Data)
            guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else { throw Failure.source }
            return Layer(id: id, image: r.ciImage, width: r.width, height: r.height, bytes: bytes)
        }
    }
    private func privateURL(_ name: String) -> URL {
        Bundle(for: BeautyEngineJawlineShadowPhotoPolicyTests.self).bundleURL.appendingPathComponent("NativePrivatePhoto").appendingPathComponent(name + ".png")
    }
    private func mask(_ name: String, _ layer: Layer) throws -> [Bool] {
        let url: URL
        if FileManager.default.fileExists(atPath: privateURL(name).path) { url = privateURL(name) }
        else {
            #if os(iOS)
            throw Failure.source
            #else
            let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            let folder = name.hasPrefix("jaw_shadow_") ? "jaw-shadow-oracle/source-annotations" : "protection-masks-v2"
            url = package.appendingPathComponent(".build/face-reference/\(folder)/\(name).png")
            #endif
        }
        guard hash(try Data(contentsOf: url)) == hashes[name], let image = CIImage(contentsOf: url), image.extent.origin == .zero else { throw Failure.source }
        let w = Int(image.extent.width), h = Int(image.extent.height)
        guard w > 1, h > 1, abs(Double(w) / Double(h) - Double(layer.width) / Double(layer.height)) < 0.002 else { throw Failure.source }
        let original = Layer(id: "annotation", image: image, width: w, height: h, bytes: [])
        let bytes = try pixels(image, original)
        guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else { throw Failure.source }
        return (0..<(layer.width * layer.height)).map { p in
            let x = min(w - 1, Int((Double(p % layer.width) + 0.5) * Double(w) / Double(layer.width)))
            let y = min(h - 1, Int((Double(p / layer.width) + 0.5) * Double(h) / Double(layer.height)))
            return bytes[(y * w + x) * 4] >= 128
        }
    }
    private func pixels(_ image: CIImage, _ layer: Layer) throws -> [UInt8] {
        guard image.extent == layer.image.extent else { throw Failure.source }
        var bytes = [UInt8](repeating: 0, count: layer.width * layer.height * 4)
        CIContext(options: [.workingColorSpace: space, .outputColorSpace: space]).render(image, toBitmap: &bytes,
            rowBytes: layer.width * 4, bounds: image.extent, format: .RGBA8, colorSpace: space)
        return bytes
    }
    private func cgImage(_ layer: Layer) throws -> CGImage {
        try XCTUnwrap(CIContext(options: [.workingColorSpace: space, .outputColorSpace: space]).createCGImage(
            layer.image, from: layer.image.extent, format: .RGBA8, colorSpace: space))
    }
    private func hash(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }
    private func outputDirectory() throws -> URL {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_OUTPUT"] else { throw Failure.output }
        let output = URL(fileURLWithPath: path).standardizedFileURL
        guard output.resolvingSymlinksInPath().path == output.path else { throw Failure.output }
        #if os(iOS)
        guard output.path.contains("/.build/face-reference/native/outputs/") else { throw Failure.output }
        #else
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        guard output.path.hasPrefix(package.appendingPathComponent(".build/face-reference").path + "/") else { throw Failure.output }
        #endif
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        return output
    }
    private func save(_ image: CIImage, _ url: URL) throws {
        guard !FileManager.default.fileExists(atPath: url.path) else { throw Failure.output }
        let context = CIContext(options: [.workingColorSpace: space, .outputColorSpace: space])
        let cg = try XCTUnwrap(context.createCGImage(image, from: image.extent, format: .RGBA8, colorSpace: space))
        let destination = try XCTUnwrap(CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil))
        CGImageDestinationAddImage(destination, cg, nil)
        guard CGImageDestinationFinalize(destination) else { throw Failure.output }
    }
}
