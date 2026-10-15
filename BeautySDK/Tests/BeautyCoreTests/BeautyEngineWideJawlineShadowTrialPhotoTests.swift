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

/// Direct D14-W1 prototype evaluation. BeautyEngine supplies only pointwise
/// CURRENT brightness baselines; this is not a public production-route test.
/// Every private annotation and gain-independent source authority is checked
/// before any effect strength is applied or candidate PNG is written.
final class BeautyEngineWideJawlineShadowTrialPhotoTests: XCTestCase {
    private enum Failure: Error { case input, source, output }
    private let space = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
    private let sourceHash = "bd5fe998c2e49b0812a9bd881bbc4c345eb15c10445b16bc790ba7f40c4b2213"
    // Independent SOURCE V2 annotations are frozen before either tone output.
    // Neither tone nor the production helper reads these private masks.
    private let hashes = [
        "doc14_legal_neck": "0c6fd71969fa5941bc50fd964e95806d5648ce615507f1d1bb3d9e2101493971",
        "doc14_activity": "71139d65c66d9628e1abb0b4ab88d0ea089663beb20ad2890d40df6d845b1c81",
        "doc14_near": "29ffba24b0e7734863e928ff6647667965cc6fcdcf0a5b3d2a5be6af8cd1c008",
        "doc14_middle": "6d9acab416063235bd041915ef381dfd4718d6a74777022dbc3a298a8848609b",
        "doc14_far": "3ba71aedc2bf2297ffc89e72ff8200e6f93a641d0acfae52104af5ef88117b28",
        "doc14_face_exclusion": "481e403346a3f2b8176bf3489c54d9a986ec1871556035dd7ded87ad7767493c",
        "doc14_clothing_exclusion": "83b0c3aa4987289ce5770496ede3e36da5178f673d7b5c47c8ac46a86d7c8eca",
        "ears_core": "d8a609c613fdb6761e58886b8cf5d94e29af6c0fe74b26cf46286245cc477d1a",
        "eyes_core": "a8219b5a697f2feed1e3b3e4a33f0f49a777a60779d76f7aaba188125016f958",
        "brows_core": "99cea5696cba82870200beead7c6edbe32443e76bdf3a7796c5f89560dfa2e6e",
        "nose_core": "ad5258bf511fe2e553049d9e1c05307942269c1d94d52ebe0c2f580e2f186452",
        "lips_core": "cde38241edb193ba5eef0b856b5486900776fa9f2b3456d326536b638be6aa64",
        "hair_core": "23566188baca12ac9383890400191839abd6e2d56781ad02c2a5ef8b7edd844b",
        "crossing_hair_core": "25312aa75a324d863ccaef45fe1f564f7cb6e24c6e8c6f29004f303f17ba2202"
    ]
    private let fineNames = ["ears_core", "eyes_core", "brows_core", "nose_core", "lips_core", "hair_core", "crossing_hair_core"]
    private let bandNames = ["activity", "near", "middle", "far"]

    func testDirectWidePrototypeActualPhotoUsesFrozenSourcePolicyAndCurrentColor() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            testGeneratedPolicyRejectsNoopAndSourceAuthorityLeaksBeforeCandidate(); return
        }
        let output = try outputDirectory()
        // Freeze BOTH raster layers, masks and their own production detector
        // results before any CURRENT baseline or prototype output is generated.
        let sources = try prepareCanonical(input).map { layer -> FrozenSource in
            let legal = try mask("doc14_legal_neck", layer)
            let faceMask = try mask("doc14_face_exclusion", layer)
            let clothes = try mask("doc14_clothing_exclusion", layer)
            let bands = try bandNames.map { try mask("doc14_" + $0, layer) }
            let fine = try fineNames.map { try mask($0, layer) }
            let policy = try XCTUnwrap(Policy(legal: legal, face: faceMask, clothes: clothes, bands: bands, fine: fine))
            var detector = BeautyFaceDetector.production()
            let detected = detector.detect(image: layer.image, metadata: metadata,
                imageExtent: layer.image.extent.size, purpose: .geometryAndLocalSupport)
            XCTAssertEqual(detected.summary.availability, .usable)
            XCTAssertEqual(detected.observations.count, 1)
            let observation = try XCTUnwrap(detected.observations.first)
            #if os(iOS)
            XCTAssertEqual(observation.mesh?.points.count, 478, "native uses its own production MediaPipe evidence")
            let requiredSourceGeometry = observation.mesh?.points.count == 478
            #else
            let requiredSourceGeometry = true
            #endif
            let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
            let qualification = BeautyWideJawlineShadowTrial.assess(sourceRGBA: layer.bytes,
                width: layer.width, height: layer.height, face: face)
            let authority = policy.authority(width: layer.width, height: layer.height) { x, y in
                qualification.evidence?.ownsSourceDomainPixel(x: x, y: y) ?? false
            }
            return FrozenSource(layer: layer, policy: policy, qualification: qualification, sourceAuthority: authority,
                sourceGeometry: observation.mesh == nil ? "production-Vision" : "production-MediaPipe",
                meshPointCount: observation.mesh?.points.count ?? 0,
                sourceDetectionQualified: requiredSourceGeometry && detected.summary.availability == .usable && detected.observations.count == 1)
        }
        var records = [[String: Any]]()
        for source in sources {
            let layer = source.layer, policy = source.policy
            for (name, count) in policy.declarationFailures { XCTAssertEqual(count, 0, "\(layer.id) source declaration: \(name)") }
            XCTAssertTrue(policy.bands.allSatisfy { $0.filter { $0 }.count >= 16 }, "all fixed activity bands need a denominator")
            XCTAssertNotNil(source.qualification.evidence, "\(layer.id) source remains unmet: \(source.qualification.refusal?.rawValue ?? "none") \(source.qualification.aggregates)")
            XCTAssertNil(source.qualification.refusal)
            XCTAssertGreaterThan(source.sourceAuthority["pixels", default: 0], 16)
            for key in ["exterior", "face", "clothes"] + fineNames {
                XCTAssertEqual(source.sourceAuthority[key, default: 0], 0, "\(layer.id) gain-before authority: \(key)")
            }
            let qualified = source.sourceDetectionQualified && source.qualification.evidence != nil && policy.declarationFailures.values.allSatisfy { $0 == 0 } &&
                policy.bands.allSatisfy { $0.filter { $0 }.count >= 16 } && source.sourceAuthority["pixels", default: 0] > 16 &&
                (["exterior", "face", "clothes"] + fineNames).allSatisfy { source.sourceAuthority[$0, default: 0] == 0 }
            guard qualified, let evidence = source.qualification.evidence else {
                records.append(["layer": layer.id, "sourceGeometry": source.sourceGeometry,
                    "sourceQualification": source.qualification.aggregates,
                    "sourceRefusal": source.qualification.refusal?.rawValue ?? "none",
                    "sourceAuthorityBeforeCandidate": source.sourceAuthority,
                    "sourceDeclarationFailures": policy.declarationFailures,
                    "sourceQualified": false, "sourceDetectionQualified": source.sourceDetectionQualified,
                    "candidateRendered": false, "unmetIsSuccess": false])
                continue
            }
            let engine = try BeautyEngine() // CURRENT colour only; no backend selection or GPU claim.
            let prepared = try engine.prepareStillImage(image: cgImage(layer), metadata: metadata)
            let neutralResult = try engine.processResult(preparedImage: prepared, parameters: .init())
            let neutral = try pixels(neutralResult.output, layer)
            XCTAssertTrue(neutral == layer.bytes)
            XCTAssertEqual(neutralResult.output.extent, layer.image.extent)
            XCTAssertEqual(neutralResult.output.colorSpace?.name, space.name)
            try save(layer.image, output.appendingPathComponent("doc14-direct-\(layer.id)-original.png"))
            var originalEndpoints = [String: [UInt8]]()
            for brightness: Float in [0, 0.10] {
                var parameters = BeautyParameters(); parameters.brightness = brightness
                let baselineResult = try engine.processResult(preparedImage: prepared, parameters: parameters)
                let current = try pixels(baselineResult.output, layer)
                let currentChanged = current != layer.bytes
                if brightness > 0 { XCTAssertTrue(currentChanged, "CURRENT colour control must actually act") }
                XCTAssertEqual(baselineResult.output.extent, layer.image.extent)
                XCTAssertEqual(baselineResult.output.colorSpace?.name, space.name)
                XCTAssertTrue(evidence.apply(to: current, strength: 0) == current)
                XCTAssertTrue(evidence.apply(to: current, strength: .nan) == current)
                try save(image(current, layer), output.appendingPathComponent("doc14-direct-\(layer.id)-brightness-\(Int(brightness * 100))-current.png"))
                for tone in [BeautyWideJawlineShadowTrial.ToneMode.w1Conservative, .documentPreserveB] {
                    XCTAssertTrue(evidence.apply(to: current, strength: 0, tone: tone) == current)
                    XCTAssertTrue(evidence.apply(to: current, strength: .nan, tone: tone) == current)
                    var previousDarkening = 0.0
                    for fraction: Float in [0.25, 0.5, 0.75, 1] {
                        let strength = BeautySafetyCaps.jawlineShadow * fraction
                        var refusedColorPixels = 0, limitedColorPixels = 0
                        let actual = evidence.apply(to: current, strength: strength, tone: tone,
                            refusedColorPixels: &refusedColorPixels, limitedColorPixels: &limitedColorPixels)
                        XCTAssertEqual(refusedColorPixels, 0, "\(layer.id) \(tone.rawValue): rejected colours are unmet, never naturalness success")
                        XCTAssertEqual(actual.count, current.count)
                        guard actual.count == current.count else { throw Failure.output }
                        let counts = policy.counts(current, actual)
                        for count in counts.fine { XCTAssertEqual(count, 0, "\(layer.id) full source fine-core preservation") }
                        XCTAssertEqual(counts.exterior, 0); XCTAssertEqual(counts.face, 0); XCTAssertEqual(counts.clothes, 0)
                        XCTAssertEqual(counts.alpha, 0); XCTAssertEqual(counts.brighter, 0); XCTAssertEqual(counts.cap, 0)
                        XCTAssertGreaterThan(counts.activity[0].darkening, previousDarkening, "four quarters must remain useful and monotonic")
                        XCTAssertTrue(counts.activity[0].meanRGBDelta.allSatisfy { $0 < 0 })
                        for index in [2, 3] {
                            XCTAssertGreaterThan(counts.activity[index].darkening, 0, "\(layer.id) \(bandNames[index]) cannot be a narrow edge/no-op")
                            XCTAssertGreaterThanOrEqual(counts.activity[index].changed, 16, "\(layer.id) \(bandNames[index]) fixed broad source target")
                        }
                        if fraction == 1 { XCTAssertTrue(counts.activity[0].usefulEndpoint, "original .25 RMS /3 max /16 changed endpoint gate") }
                        previousDarkening = counts.activity[0].darkening
                        let repeated = evidence.apply(to: current, strength: strength, tone: tone) == actual
                        XCTAssertTrue(repeated)
                        // CURRENT, rather than original, must survive everywhere
                        // outside the already-frozen source authority rectangle.
                        var replacedCurrent = 0
                        for y in 0..<layer.height { for x in 0..<layer.width where !evidence.ownsSourceDomainPixel(x: x, y: y) {
                            let p = (y * layer.width + x) * 4
                            if current[p..<(p + 4)] != actual[p..<(p + 4)] { replacedCurrent += 1 }
                        } }
                        XCTAssertEqual(replacedCurrent, 0)
                        let rendered = image(actual, layer)
                        XCTAssertEqual(rendered.extent, layer.image.extent)
                        XCTAssertEqual(rendered.colorSpace?.name, space.name)
                        XCTAssertTrue(try pixels(rendered, layer) == actual, "explicit sRGB wrapping preserves the direct prototype bytes")
                        let name = "doc14-direct-\(layer.id)-\(tone.rawValue)-brightness-\(Int(brightness * 100))-quarter-\(Int(fraction * 100)).png"
                        try save(rendered, output.appendingPathComponent(name))
                        if fraction == 1 {
                            if brightness == 0 { originalEndpoints[tone.rawValue] = actual }
                            else if let originalEndpoint = originalEndpoints[tone.rawValue] {
                                XCTAssertFalse(actual == originalEndpoint, "CURRENT brightness is not replaced by original source RGB")
                            } else { XCTFail("missing immutable original-colour endpoint") }
                        }
                        let bandRows = zip(bandNames, counts.activity).map { name, c -> [String: Any] in
                            ["band": name, "denominator": c.denominator, "changedPixels": c.changed,
                             "RMSByteDelta": c.rms, "maximumByteDelta": c.maximum,
                             "meanRGBDelta": c.meanRGBDelta, "darkening": c.darkening,
                             "encodedLumaRatio": c.lumaRatio]
                        }
                        let defaultParity: [String: Any] = tone == .w1Conservative ? ["tested": true, "exact": repeated] : ["tested": false]
                        records.append(["layer": layer.id, "tone": tone.rawValue, "brightness": brightness, "fraction": fraction,
                            "refusedColorPixels": refusedColorPixels, "limitedColorPixels": limitedColorPixels,
                            "requestedToneAmountIsUpperBound": tone == .documentPreserveB,
                            "allRequestedToneAmountsFeasible": limitedColorPixels == 0,
                            "W1DefaultEntryParity": defaultParity,
                            "sourceGeometry": source.sourceGeometry, "sourceMeshPointCount": source.meshPointCount,
                            "sourceQualified": true, "candidateRendered": true,
                            "sourceQualification": source.qualification.aggregates,
                            "sourceAuthorityBeforeCandidate": source.sourceAuthority,
                            "sourceAuthorityCheckedBeforeStrength": true,
                            "fineChangedPixels": Dictionary(uniqueKeysWithValues: zip(fineNames, counts.fine)),
                            "exteriorChangedPixels": counts.exterior, "faceChangedPixels": counts.face,
                            "clothesChangedPixels": counts.clothes, "alphaChangedPixels": counts.alpha,
                            "brighterChannels": counts.brighter, "capLeakChannels": counts.cap,
                            "bands": bandRows, "neutralExact": neutral == layer.bytes, "repeatExact": repeated,
                            "currentColorBaselineActive": currentChanged, "currentOutsideAuthorityExact": replacedCurrent == 0,
                            "sourceQualifiedOnce": true, "extentExact": true, "explicitSRGB": true,
                            "canonicalMetadataUp": layer.metadata.orientation == .up,
                            "canonicalMetadataUnmirrored": !layer.metadata.isInputMirrored])
                    }
                }
                XCTAssertTrue(try pixels(engine.processResult(preparedImage: prepared, parameters: parameters).output, layer) == current,
                    "direct prototype cannot mutate the engine's CURRENT baseline state")
            }
        }
        let aggregate: [String: Any] = ["schema": "doc14-wide-direct-prototype-source-policy/v1", "records": records,
            "directPrototypeOnly": true, "publicProductionConnection": false, "backendSelection": false,
            "sourcePolicyVersion": "doc14-source-v2", "toneModes": ["w1Conservative", "documentPreserveB"],
            "sideDepthFactorIsMeasuredReferenceClaim": false,
            "sourceDeclarationPrecedesAllCandidates": true, "productionReadsPrivateAnnotation": false,
            "sourceRefusalIsSuccess": false, "appearanceParity": false, "fullSDKRegression": false]
        let destination = output.appendingPathComponent("doc14-wide-trial-photo-policy.json")
        guard !FileManager.default.fileExists(atPath: destination.path) else { throw Failure.output }
        try JSONSerialization.data(withJSONObject: aggregate, options: [.prettyPrinted, .sortedKeys]).write(to: destination)
    }

    func testGeneratedPolicyRejectsNoopAndSourceAuthorityLeaksBeforeCandidate() {
        let count = 256
        var legal = [Bool](repeating: false, count: count), face = legal, clothes = legal
        for p in 0..<128 { legal[p] = true }
        var bands = Array(repeating: [Bool](repeating: false, count: count), count: 4)
        for p in 0..<96 { bands[0][p] = true; bands[1 + p / 32][p] = true }
        var fine = Array(repeating: [Bool](repeating: false, count: count), count: 7)
        for i in fine.indices { fine[i][200 + i] = true }
        face[230] = true; clothes[220] = true
        guard let policy = Policy(legal: legal, face: face, clothes: clothes, bands: bands, fine: fine) else {
            XCTFail("generated source policy malformed"); return
        }
        XCTAssertTrue(policy.declarationFailures.values.allSatisfy { $0 == 0 })
        let original = Array(repeating: [UInt8(128), 128, 128, 255], count: count).flatMap { $0 }
        XCTAssertFalse(policy.counts(original, original).activity[0].usefulEndpoint)
        var positive = original
        for p in 0..<96 { for c in 0..<3 { positive[p * 4 + c] -= 8 } }
        let qualified = policy.counts(original, positive)
        XCTAssertTrue(qualified.activity[0].usefulEndpoint)
        XCTAssertTrue(qualified.activity[2...3].allSatisfy { $0.changed == 32 && $0.darkening > 0 })
        var leaked = positive
        for p in [200, 220, 230] { leaked[p * 4] -= 1 }
        leaked[240 * 4] += 1; leaked[3] = 254
        let bad = policy.counts(original, leaked)
        XCTAssertEqual(bad.fine[0], 1); XCTAssertEqual(bad.face, 1); XCTAssertEqual(bad.clothes, 1)
        XCTAssertEqual(bad.alpha, 1); XCTAssertEqual(bad.brighter, 1)
        var claimed = legal; claimed[200] = true; claimed[220] = true; claimed[230] = true
        let authority = policy.authority(width: 16, height: 16) { x, y in claimed[y * 16 + x] }
        XCTAssertEqual(authority["exterior"], 3)
        XCTAssertEqual(authority["ears_core"], 1); XCTAssertEqual(authority["face"], 1); XCTAssertEqual(authority["clothes"], 1)
        XCTAssertTrue(Policy(legal: [], face: [], clothes: [], bands: [], fine: []) == nil)
    }

    private struct Layer {
        let id: String, image: CIImage, width: Int, height: Int, bytes: [UInt8], metadata: BeautyInputMetadata
    }
    private struct FrozenSource {
        let layer: Layer, policy: Policy, qualification: BeautyWideJawlineShadowTrial.Qualification
        let sourceAuthority: [String: Int], sourceGeometry: String, meshPointCount: Int
        let sourceDetectionQualified: Bool
    }
    private struct BandCounts {
        var denominator = 0, changed = 0, maximum = 0
        var rms = 0.0, darkening = 0.0, lumaRatio = 1.0
        var meanRGBDelta = [Double](repeating: 0, count: 3)
        var usefulEndpoint: Bool { rms >= 0.25 && maximum >= 3 && changed >= 16 }
    }
    private struct Counts {
        var fine = [Int](repeating: 0, count: 7)
        var exterior = 0, face = 0, clothes = 0, alpha = 0, brighter = 0, cap = 0
        var activity = [BandCounts](repeating: BandCounts(), count: 4)
    }
    private struct Policy {
        let legal: [Bool], face: [Bool], clothes: [Bool], bands: [[Bool]], fine: [[Bool]]
        let declarationFailures: [String: Int]
        init?(legal: [Bool], face: [Bool], clothes: [Bool], bands: [[Bool]], fine: [[Bool]]) {
            guard !legal.isEmpty, face.count == legal.count, clothes.count == legal.count,
                  bands.count == 4, fine.count == 7,
                  (bands + fine).allSatisfy({ $0.count == legal.count }) else { return nil }
            self.legal = legal; self.face = face; self.clothes = clothes; self.bands = bands; self.fine = fine
            var failures = ["legalFineIntersection": 0, "legalFaceIntersection": 0, "legalClothingIntersection": 0,
                "activityExterior": 0, "nearExterior": 0, "middleExterior": 0, "farExterior": 0]
            for p in legal.indices {
                if legal[p] && fine.contains(where: { $0[p] }) { failures["legalFineIntersection", default: 0] += 1 }
                if legal[p] && face[p] { failures["legalFaceIntersection", default: 0] += 1 }
                if legal[p] && clothes[p] { failures["legalClothingIntersection", default: 0] += 1 }
                for (i, name) in ["activityExterior", "nearExterior", "middleExterior", "farExterior"].enumerated() {
                    if bands[i][p] && !legal[p] { failures[name, default: 0] += 1 }
                }
            }
            declarationFailures = failures
        }
        func authority(width: Int, height: Int, owns: (Int, Int) -> Bool) -> [String: Int] {
            let names = ["ears_core", "eyes_core", "brows_core", "nose_core", "lips_core", "hair_core", "crossing_hair_core"]
            var result = Dictionary(uniqueKeysWithValues: (["pixels", "exterior", "face", "clothes"] + names).map { ($0, 0) })
            for y in 0..<height { for x in 0..<width where owns(x, y) {
                let p = y * width + x
                result["pixels", default: 0] += 1
                if !legal[p] { result["exterior", default: 0] += 1 }
                if face[p] { result["face", default: 0] += 1 }
                if clothes[p] { result["clothes", default: 0] += 1 }
                for i in fine.indices where fine[i][p] { result[names[i], default: 0] += 1 }
            } }
            return result
        }
        func counts(_ original: [UInt8], _ output: [UInt8]) -> Counts {
            var result = Counts(), square = [Double](repeating: 0, count: 4)
            var sourceLuma = square, outputLuma = square
            for p in legal.indices {
                let i = p * 4
                let changed = (0..<4).contains { original[i + $0] != output[i + $0] }
                if changed {
                    if !legal[p] { result.exterior += 1 }
                    if face[p] { result.face += 1 }; if clothes[p] { result.clothes += 1 }
                    for j in fine.indices where fine[j][p] { result.fine[j] += 1 }
                }
                if original[i + 3] != output[i + 3] { result.alpha += 1 }
                var pixelChanged = false
                for c in 0..<3 {
                    let a = Int(original[i + c]), b = Int(output[i + c]), delta = b - a
                    if delta > 0 { result.brighter += 1 }
                    if Double(b) < Double(a) * 0.82 - 0.5 { result.cap += 1 }
                    pixelChanged = pixelChanged || delta != 0
                    for j in bands.indices where bands[j][p] {
                        square[j] += Double(delta * delta)
                        result.activity[j].maximum = max(result.activity[j].maximum, abs(delta))
                        result.activity[j].meanRGBDelta[c] += Double(delta)
                    }
                }
                for j in bands.indices where bands[j][p] {
                    result.activity[j].denominator += 1
                    if pixelChanged { result.activity[j].changed += 1 }
                    sourceLuma[j] += Double(original[i]) * 0.2126 + Double(original[i + 1]) * 0.7152 + Double(original[i + 2]) * 0.0722
                    outputLuma[j] += Double(output[i]) * 0.2126 + Double(output[i + 1]) * 0.7152 + Double(output[i + 2]) * 0.0722
                }
            }
            for j in bands.indices {
                let count = Double(max(1, result.activity[j].denominator))
                result.activity[j].rms = sqrt(square[j] / (count * 3))
                result.activity[j].meanRGBDelta = result.activity[j].meanRGBDelta.map { $0 / count }
                result.activity[j].darkening = -result.activity[j].meanRGBDelta.reduce(0, +)
                result.activity[j].lumaRatio = outputLuma[j] / max(1, sourceLuma[j])
            }
            return result
        }
    }

    private func prepareCanonical(_ path: String) throws -> [Layer] {
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
        let full = try canonicalizer.canonicalize(image: input, metadata: metadata,
            maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
        return try [("full", 1.0), ("preview960", min(1, 960 / Double(max(full.width, full.height))))].map { id, scale in
            let resized = full.ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale)).cropped(to:
                CGRect(x: 0, y: 0, width: floor(Double(full.width) * scale), height: floor(Double(full.height) * scale)))
            let raster = try canonicalizer.canonicalize(image: resized, metadata: metadata,
                maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
            XCTAssertEqual(raster.metadata.orientation, .up); XCTAssertFalse(raster.metadata.isInputMirrored)
            XCTAssertEqual(raster.ciImage.colorSpace?.name, space.name)
            let bytes = Array(raster.rgba8Data)
            guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else { throw Failure.source }
            return Layer(id: id, image: raster.ciImage, width: raster.width, height: raster.height,
                bytes: bytes, metadata: raster.metadata)
        }
    }
    private func privateURL(_ name: String) -> URL {
        Bundle(for: BeautyEngineWideJawlineShadowTrialPhotoTests.self).bundleURL
            .appendingPathComponent("NativeDoc14Photo").appendingPathComponent(name + ".png")
    }
    private func mask(_ name: String, _ layer: Layer) throws -> [Bool] {
        let url: URL
        if FileManager.default.fileExists(atPath: privateURL(name).path) { url = privateURL(name) }
        else {
            #if os(iOS)
            throw Failure.source
            #else
            let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            let folder = name.hasPrefix("doc14_") ? "doc14-oracle/source-annotations" : "protection-masks-v2"
            url = package.appendingPathComponent(".build/face-reference/\(folder)/\(name).png")
            #endif
        }
        guard let expected = hashes[name], expected.count == 64,
              hash(try Data(contentsOf: url)) == expected,
              let input = CIImage(contentsOf: url), input.extent.origin == .zero else { throw Failure.source }
        let w = Int(input.extent.width), h = Int(input.extent.height)
        guard w > 1, h > 1, abs(Double(w) / Double(h) - Double(layer.width) / Double(layer.height)) < 0.002 else { throw Failure.source }
        let annotation = Layer(id: "annotation", image: input, width: w, height: h, bytes: [], metadata: metadata)
        let bytes = try pixels(input, annotation)
        guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else { throw Failure.source }
        return (0..<(layer.width * layer.height)).map { p in
            let x = min(w - 1, Int((Double(p % layer.width) + 0.5) * Double(w) / Double(layer.width)))
            let y = min(h - 1, Int((Double(p / layer.width) + 0.5) * Double(h) / Double(layer.height)))
            return bytes[(y * w + x) * 4] >= 128
        }
    }
    private func image(_ bytes: [UInt8], _ layer: Layer) -> CIImage {
        CIImage(bitmapData: Data(bytes), bytesPerRow: layer.width * 4,
            size: CGSize(width: layer.width, height: layer.height), format: .RGBA8, colorSpace: space)
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
        let cg = try XCTUnwrap(CIContext(options: [.workingColorSpace: space, .outputColorSpace: space]).createCGImage(
            image, from: image.extent, format: .RGBA8, colorSpace: space))
        let destination = try XCTUnwrap(CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil))
        CGImageDestinationAddImage(destination, cg, nil)
        guard CGImageDestinationFinalize(destination) else { throw Failure.output }
    }
}
