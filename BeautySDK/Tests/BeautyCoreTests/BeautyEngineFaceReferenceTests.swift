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

/// Optional owner-local photograph checks. Source observations, masks and
/// texture anchors live only in this invocation. The output directory must be
/// under this package's ignored .build/face-reference tree. No source paths,
/// landmarks, masks or raw pixels are included in the aggregate receipt.
///
/// With no environment input, both methods execute generated no-face safety
/// checks. That execution is deliberately not photographic effect evidence.
final class BeautyEngineFaceReferenceTests: XCTestCase {
    private enum CheckError: Error {
        case invalidInput, invalidOutput, unreadableInput, invalidSourceSupport
        case weakSourceTexture, encodingFailed, writeFailed
        case inconclusivePhotoMeasurement
        case sourceAnchorQualification(layer: String, control: String, side: String,
            candidates: Int, legal: Int, textured: Int, directional: Int)
    }
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
    private let mainControls: [BeautyFaceShapeSlider] = [
        .faceWidth, .smallFace, .temple, .cheekbone, .chinLength,
        .chinTaper, .jawAngle, .vFace
    ]

    func testIndependentSourceMatcherAndProtectionRejectWrongControls() throws {
        let width = 64, height = 80
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            for c in 0..<3 { bytes[i + c] = UInt8((x * 37 + y * 71 + x * y * 13 + c * 43) % 251) }
        } }
        let image = CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: colorSpace)
        let source = Layer(id: "generated-oracle-controls", image: image, width: width, height: height, bytes: bytes)
        let anchor = Anchor(point: SIMD2(32, 40), direction: SIMD2(1, 0), search: 8, sampling: 1)
        func translate(_ shift: Int) -> [UInt8] {
            var result = bytes
            for y in 0..<height { for x in 0..<width {
                let oldX = max(0, min(width - 1, x - shift)), a = (y * width + oldX) * 4, b = (y * width + x) * 4
                for c in 0..<4 { result[b + c] = bytes[a + c] }
            } }
            return result
        }
        let baseline = match(anchor, source: source, output: bytes)
        let positive = match(anchor, source: source, output: translate(2)) - baseline
        let reverse = match(anchor, source: source, output: translate(-2)) - baseline
        XCTAssertEqual(positive, 2, accuracy: 0.1)
        XCTAssertEqual(reverse, -2, accuracy: 0.1)
        XCTAssertFalse(reverse > 1, "wrong sign fails the effect predicate")
        XCTAssertFalse(match(anchor, source: source, output: bytes) - baseline > 1, "no-op fails the effect predicate")
        let frame = Frame(contour: [SIMD2(12, 25), SIMD2(15, 45), SIMD2(32, 60), SIMD2(49, 45), SIMD2(52, 25)],
            featureBoxes: [CGRect(x: 24, y: 30, width: 16, height: 12), CGRect.zero,
                CGRect(x: 24, y: 22, width: 16, height: 4)],
            origin: SIMD2(32, 25), axisX: SIMD2(1, 0), axisY: SIMD2(0, 1), span: 40, chin: 35,
            bounds: CGRect(x: 12, y: 10, width: 40, height: 50))
        let domains = SourceDomains(frame: frame, width: width, height: height, additionalProtection: nil)
        var exteriorLeak = bytes, featureLeak = bytes, alphaLeak = bytes
        exteriorLeak[0] ^= 255
        featureLeak[(35 * width + 30) * 4] ^= 255
        alphaLeak[3] = 254
        XCTAssertEqual(protectedChanges(bytes, exteriorLeak, domains: domains, hairline: false).exterior, 1)
        XCTAssertEqual(protectedChanges(bytes, featureLeak, domains: domains, hairline: false).features, 1)
        XCTAssertEqual(protectedChanges(bytes, alphaLeak, domains: domains, hairline: false).alpha, 1)
    }

    func testSourceTrackedContinuousFallbackRecoversGeneratedTranslations() throws {
        let width = 72, height = 88
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width { for c in 0..<3 {
            bytes[(y * width + x) * 4 + c] = UInt8((x * 37 + y * 71 + x * y * 13 + c * 43) % 251)
        } } }
        let image = CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: colorSpace)
        let source = Layer(id: "generated-tracked-forward-controls", image: image,
            width: width, height: height, bytes: bytes)
        let anchor = Anchor(point: SIMD2(36, 44), direction: SIMD2(1, 0), search: 6, sampling: 1)
        var records: [[String: Any]] = []
        for sign: Double in [-1, 1] {
            let delta = SIMD2(1.37 * sign, 0.27 * sign)
            var translated = bytes
            for y in 2..<(height - 2) { for x in 2..<(width - 2) {
                let sx = Double(x) - delta.x, sy = Double(y) - delta.y
                let ix = Int(floor(sx)), iy = Int(floor(sy)), fx = sx - Double(ix), fy = sy - Double(iy)
                for c in 0..<3 {
                    let a = (iy * width + ix) * 4 + c
                    let value = Double(bytes[a]) * (1 - fx) * (1 - fy) + Double(bytes[a + 4]) * fx * (1 - fy)
                        + Double(bytes[a + width * 4]) * (1 - fx) * fy + Double(bytes[a + width * 4 + 4]) * fx * fy
                    translated[(y * width + x) * 4 + c] = UInt8(max(0, min(255, value.rounded())))
                }
            } }
            let truthPrediction = trackedKnownPredictionMismatch(anchor, source: source, output: translated, delta: delta)
            XCTAssertEqual(truthPrediction.samples, 81)
            XCTAssertEqual(truthPrediction.mismatch, 0, "source-model corners and phase orientation must predict known truth bytes")
            let estimate = quantizedTrackedMatch(anchor, source: source, output: translated)
            XCTAssertEqual(trackedForwardLeastSquares(anchor, source: source, output: translated), delta.x, accuracy: 0.1,
                "continuous forward residual estimator retains the independently generated truth")
            XCTAssertEqual(estimate.value, delta.x, accuracy: 0.1)
            XCTAssertEqual(estimate.status, "source-compatible-continuous", "off-phase truth must be considered by the continuous feasible set")
            XCTAssertGreaterThan(estimate.compatibleCount, 0)
            XCTAssertGreaterThan(estimate.witnessCount, 0)
            XCTAssertLessThanOrEqual(estimate.uncertainty, 0.1)
            XCTAssertTrue(estimate.value * sign > 1, "forward and reverse retain their known direction")
            records.append(["generatedControlOrdinal": sign < 0 ? 0 : 1,
                "truePredictionSampleCount": truthPrediction.samples,
                "truePredictionMismatchChannels": truthPrediction.mismatch,
                "verifiedCompatibleWitnessCount": estimate.witnessCount,
                "uncertaintyPixels": estimate.uncertainty, "estimatorStatus": estimate.status,
                "absoluteError": estimate.value.isFinite ? abs(estimate.value - delta.x) : Double.greatestFiniteMagnitude])
        }
        XCTAssertEqual(quantizedTrackedMatch(anchor, source: source, output: bytes).value, 0,
            "identity cannot meet the endpoint activity threshold")
        if ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_OUTPUT"] != nil {
            let output = try outputDirectory()
            let url = output.appendingPathComponent("generated-continuous-compatibility-aggregate.json")
            guard !FileManager.default.fileExists(atPath: url.path) else { throw CheckError.invalidOutput }
            try JSONSerialization.data(withJSONObject: ["generatedSourceOnly": true, "records": records],
                options: [.sortedKeys, .prettyPrinted]).write(to: url)
        }
    }

    /// Validates the forward matcher on known source-only local translations.
    /// It never opens SDK candidate output. Legacy search errors remain visible
    /// beside the new estimator, using the same frozen anchors and search box.
    func testSourceOnlyKnownLocalTranslationsDiagnoseMatcher() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedNoFaceSafety(recovery: false)
            return
        }
        let output = try outputDirectory()
        let source = try load(input)
        var records: [[String: Any]] = []
        for layer in try layers(source) {
            let frame = try sourceFrame(layer)
            let domains = SourceDomains(frame: frame, width: layer.width, height: layer.height,
                additionalProtection: try protectionMask(layer))
            let anchors = try sourceAnchorsV1(frame: frame, layer: layer)
            for control in mainControls {
                for (index, anchor) in anchors[control]!.enumerated() {
                    let sampled = (-4...4).flatMap { y in (-4...4).map { x in
                        (Int(anchor.point.x.rounded()) + x * anchor.sampling,
                         Int(anchor.point.y.rounded()) + y * anchor.sampling)
                    } }
                    let targetCount = sampled.filter { domains.target[$0.1 * layer.width + $0.0] }.count
                    let protectedCount = sampled.filter { domains.features[$0.1 * layer.width + $0.0] }.count
                    let eligible = targetCount == sampled.count && protectedCount == 0
                    XCTAssertTrue(eligible, "source-only \(layer.id) \(control.rawValue) anchor \(index) must be in legal unprotected target")
                    for axis in 0...1 {
                        let probe = Anchor(point: anchor.point, direction: axis == 0 ? SIMD2(1, 0) : SIMD2(0, 1),
                            search: anchor.search, sampling: anchor.sampling)
                        let oldNeutral = legacyMatch(probe, source: layer, output: layer.bytes)
                        let exhaustiveNeutral = legacyMatch(probe, source: layer, output: layer.bytes, exhaustive: true)
                        let forwardNeutral = match(probe, source: layer, output: layer.bytes)
                        for sign: Double in [-1, 1] { for amount in [0.25, 0.5, 1, 2, 4] {
                            let truth = sign * amount
                            let delta = axis == 0 ? SIMD2(truth, 0) : SIMD2(0, truth)
                            let destinationLegalCount = sampled.filter { sample in
                                let (x, y) = sample
                                let xx = Int(floor(Double(x) + delta.x)), yy = Int(floor(Double(y) + delta.y))
                                guard xx >= 0, yy >= 0, xx + 1 < layer.width, yy + 1 < layer.height else { return false }
                                let footprints = [yy * layer.width + xx, yy * layer.width + xx + 1,
                                    (yy + 1) * layer.width + xx, (yy + 1) * layer.width + xx + 1]
                                return footprints.allSatisfy { domains.target[$0] && !domains.features[$0] }
                            }.count
                            let fixedSourceFootprintCount = sampled.filter { sample in
                                let sx = Double(sample.0) - delta.x, sy = Double(sample.1) - delta.y
                                let xx = Int(floor(sx)), yy = Int(floor(sy))
                                guard xx >= 0, yy >= 0, xx + 1 < layer.width, yy + 1 < layer.height else { return false }
                                let footprints = [yy * layer.width + xx, yy * layer.width + xx + 1,
                                    (yy + 1) * layer.width + xx, (yy + 1) * layer.width + xx + 1]
                                return footprints.allSatisfy { domains.target[$0] && !domains.features[$0] }
                            }.count
                            let legalControl = eligible && destinationLegalCount == sampled.count
                                && fixedSourceFootprintCount == sampled.count
                            let translated = knownLocalTranslation(layer, anchor: probe,
                                delta: delta, domains: domains)
                            let protection = protectedChanges(layer.bytes, translated, domains: domains, hairline: false)
                            XCTAssertEqual(protection.features, 0, "source-only translation protected features")
                            XCTAssertEqual(protection.exterior, 0, "source-only translation fixed-domain exterior")
                            XCTAssertEqual(protection.alpha, 0, "source-only translation alpha")
                            let coarse = legacyMatch(probe, source: layer, output: translated) - oldNeutral
                            let exhaustive = legacyMatch(probe, source: layer, output: translated, exhaustive: true) - exhaustiveNeutral
                            let forward = match(probe, source: layer, output: translated) - forwardNeutral
                            let forwardError = forward.isFinite ? abs(forward - truth) : Double.greatestFiniteMagnitude
                            let verified = legalControl && forwardError <= 0.1
                            if legalControl {
                                XCTAssertTrue(verified,
                                    "source-only forward translation inconclusive when error exceeds 0.1 px: \(layer.id) \(control.rawValue) \(axis) \(truth)")
                            }
                            records.append([
                                "layer": layer.id, "control": control.rawValue, "anchorOrdinal": index,
                                "axis": axis == 0 ? "x" : "y", "knownTranslationPixels": truth,
                                "sourceTargetSampleCount": targetCount, "sourceProtectedSampleCount": protectedCount,
                                "sourceAnchorEligible": eligible, "destinationLegalSampleCount": destinationLegalCount,
                                "fixedOutputSourceFootprintLegalCount": fixedSourceFootprintCount,
                                "knownTranslationEligible": legalControl, "coarseRecoveredPixels": coarse,
                                "coarseAbsoluteError": abs(coarse - truth), "exhaustiveRecoveredPixels": exhaustive,
                                "exhaustiveAbsoluteError": abs(exhaustive - truth),
                                "forwardRecoveredPixels": forward.isFinite ? forward : 0,
                                "forwardAbsoluteError": forwardError,
                                "forwardTruthStatus": verified ? "verified" : "inconclusive",
                                "protectedChangedPixels": protection.features,
                                "exteriorChangedPixels": protection.exterior, "alphaChangedPixels": protection.alpha
                            ])
                        } }
                    }
                }
            }
        }
        try receipt(records, name: "source-only-matcher-diagnostic.json", to: output, oracleVersion: "variance-v1")
    }

    /// Focused source-only counterexamples from the first forward-estimator
    /// calibration. No candidate output, new anchors or effect gates enter
    /// this diagnostic. It distinguishes partial local translations from
    /// raster quantization and fractional-search approximation.
    func testSourceOnlySevenMatcherCounterexamples() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedNoFaceSafety(recovery: false)
            return
        }
        let output = try outputDirectory()
        let source = try load(input)
        let layer = try layers(source)[0]
        let frame = try sourceFrame(layer)
        let domains = SourceDomains(frame: frame, width: layer.width, height: layer.height,
            additionalProtection: try protectionMask(layer))
        let anchors = try sourceAnchorsV1(frame: frame, layer: layer)
        let cases: [(BeautyFaceShapeSlider, Int, Int, Double)] = [
            (.temple, 0, 0, -4), (.chinLength, 0, 0, 0.25),
            (.chinLength, 0, 1, -0.5), (.chinLength, 0, 1, 0.5),
            (.chinTaper, 0, 1, -0.25), (.chinTaper, 1, 0, -0.25), (.chinTaper, 1, 0, -0.5)
        ]
        var records: [[String: Any]] = []
        for (control, ordinal, axis, truth) in cases {
            let anchor = anchors[control]![ordinal]
            let probe = Anchor(point: anchor.point, direction: axis == 0 ? SIMD2(1, 0) : SIMD2(0, 1),
                search: anchor.search, sampling: anchor.sampling)
            let samples = (-4...4).flatMap { y in (-4...4).map { x in
                (Int(anchor.point.x.rounded()) + x * anchor.sampling,
                 Int(anchor.point.y.rounded()) + y * anchor.sampling)
            } }
            func translated(_ amount: Double) -> [UInt8] {
                knownLocalTranslation(layer, anchor: probe,
                    delta: axis == 0 ? SIMD2(amount, 0) : SIMD2(0, amount), domains: domains)
            }
            func sameObservedSamples(_ a: [UInt8], _ b: [UInt8]) -> Bool {
                samples.allSatisfy { sample in
                    let (x, y) = sample
                    let i = (y * layer.width + x) * 4
                    return (0..<3).allSatisfy { a[i + $0] == b[i + $0] }
                }
            }
            let actual = translated(truth)
            var sourceFootprintsLegal = 0, predictionMismatchChannels = 0
            for (x, y) in samples {
                let sx = Double(x) - (axis == 0 ? truth : 0), sy = Double(y) - (axis == 1 ? truth : 0)
                let ix = Int(floor(sx)), iy = Int(floor(sy)), fx = sx - Double(ix), fy = sy - Double(iy)
                guard ix >= 0, iy >= 0, ix + 1 < layer.width, iy + 1 < layer.height else { continue }
                let footprints = [iy * layer.width + ix, iy * layer.width + ix + 1,
                    (iy + 1) * layer.width + ix, (iy + 1) * layer.width + ix + 1]
                if footprints.allSatisfy({ domains.target[$0] && !domains.features[$0] }) { sourceFootprintsLegal += 1 }
                for c in 0..<3 {
                    let p = footprints.map { Double(layer.bytes[$0 * 4 + c]) }
                    let prediction = (p[0] * (1 - fx) * (1 - fy) + p[1] * fx * (1 - fy)
                        + p[2] * (1 - fx) * fy + p[3] * fx * fy).rounded()
                    if UInt8(max(0, min(255, prediction))) != actual[(y * layer.width + x) * 4 + c] {
                        predictionMismatchChannels += 1
                    }
                }
            }
            let old = forwardLeastSquares(probe, source: layer, output: actual)
                - forwardLeastSquares(probe, source: layer, output: layer.bytes)
            let refined = forwardLeastSquares(probe, source: layer, output: actual, refineFractions: true)
                - forwardLeastSquares(probe, source: layer, output: layer.bytes, refineFractions: true)
            let quantized = quantizedMatch(probe, source: layer, output: actual)
            let quantizedNeutral = quantizedMatch(probe, source: layer, output: layer.bytes)
            let quantizedValue = quantized.value - quantizedNeutral.value
            let identicalMinus = sameObservedSamples(actual, translated(truth - 0.25))
            let identicalPlus = sameObservedSamples(actual, translated(truth + 0.25))
            let indistinguishable = identicalMinus || identicalPlus
            let protection = protectedChanges(layer.bytes, actual, domains: domains, hairline: false)
            XCTAssertEqual(protection.features, 0); XCTAssertEqual(protection.exterior, 0); XCTAssertEqual(protection.alpha, 0)
            let preciseTruth = sourceFootprintsLegal == samples.count && predictionMismatchChannels == 0
                && !indistinguishable && quantizedValue.isFinite && abs(quantizedValue - truth) <= 0.1
            if sourceFootprintsLegal == samples.count && predictionMismatchChannels == 0
                && quantized.status == "source-compatible" {
                XCTAssertEqual(quantizedValue, truth, accuracy: 0.1,
                    "quantization-compatible source truth retains the 0.1 px gate")
            }
            records.append([
                "layer": layer.id, "control": control.rawValue, "anchorOrdinal": ordinal,
                "axis": axis == 0 ? "x" : "y", "knownTranslationPixels": truth,
                "fixedOutputSourceFootprintLegalCount": sourceFootprintsLegal,
                "roundedTruePredictionMismatchChannels": predictionMismatchChannels,
                "forwardRecoveredPixels": old.isFinite ? old : 0,
                "forwardAbsoluteError": old.isFinite ? abs(old - truth) : Double.greatestFiniteMagnitude,
                "refinedRecoveredPixels": refined.isFinite ? refined : 0,
                "refinedAbsoluteError": refined.isFinite ? abs(refined - truth) : Double.greatestFiniteMagnitude,
                "refinedEstimateStatus": refined.isFinite ? "measured" : "inconclusive",
                "quantizedRecoveredPixels": quantizedValue.isFinite ? quantizedValue : 0,
                "quantizedAbsoluteError": quantizedValue.isFinite ? abs(quantizedValue - truth) : Double.greatestFiniteMagnitude,
                "quantizedUncertaintyPixels": quantized.uncertainty,
                "sourceCompatibleIntervalCount": quantized.compatibleCount,
                "quantizedEstimateStatus": quantized.status,
                "quantizedTruthStatus": preciseTruth ? "verified" : "inconclusive",
                "identicalObservedSamplesAtMinusQuarter": identicalMinus,
                "identicalObservedSamplesAtPlusQuarter": identicalPlus,
                "knownTruthStatus": sourceFootprintsLegal != samples.count || predictionMismatchChannels != 0 || indistinguishable
                    ? "inconclusive" : "eligible",
                "protectedChangedPixels": protection.features, "exteriorChangedPixels": protection.exterior
            ])
        }
        try receipt(records, name: "source-only-seven-counterexamples.json", to: output, oracleVersion: "variance-v1")
    }

    /// V2 selection and calibration use the immutable source only. The
    /// original candidate region, sample grid, masks and error tolerance stay
    /// fixed. Actual control-axis observability is required; unused image-axis
    /// ambiguity remains an explicit diagnostic rather than effect evidence.
    func testSourceOnlyDirectionalObservabilityAnchorsV2() throws {
        try directionalSourceControlsV2(qualified: false)
    }

    func testSourceOnlyQualifiedDirectionalObservabilityAnchorsV2() throws {
        try directionalSourceControlsV2(qualified: true)
    }

    /// These source-only cases are the sixteen dated C14 fixed-phase misses.
    /// Their original V2 points and truth set are preserved; no SDK candidate
    /// or reference result chooses a new point for this diagnosis.
    func testSourceOnlySixteenContinuousCompatibilityCounterexamplesV2() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedNoFaceSafety(recovery: false)
            return
        }
        let output = try outputDirectory(), source = try load(input)
        var records: [[String: Any]] = []
        for layer in try layers(source) {
            let frame = try sourceFrame(layer)
            let domains = SourceDomains(frame: frame, width: layer.width, height: layer.height,
                additionalProtection: try protectionMask(layer))
            let anchors = try sourceAnchorsV2(frame: frame, layer: layer, domains: domains)
            for control in [BeautyFaceShapeSlider.faceWidth, .smallFace] {
                for (ordinal, anchor) in anchors[control]!.enumerated() {
                    if layer.id == "full" && control == .faceWidth && ordinal == 1 { continue }
                    let truths: [Double] = layer.id == "preview960" && control == .smallFace && ordinal == 0
                        ? [-4, -2, 2, 4] : [-4, 4]
                    for truth in truths {
                        let delta = anchor.direction * truth
                        let actual = knownLocalTranslation(layer, anchor: anchor, delta: delta, domains: domains)
                        let validity = trackedTruthValidity(anchor, source: layer, output: actual, delta: delta, domains: domains)
                        let templateTruth = trackedKnownPredictionMismatch(anchor, source: layer, output: actual, delta: delta)
                        XCTAssertEqual(templateTruth.samples, 81); XCTAssertEqual(templateTruth.mismatch, 0)
                        let estimate = quantizedTrackedMatch(anchor, source: layer, output: actual)
                        let error = estimate.value.isFinite ? abs(estimate.value - truth) : Double.greatestFiniteMagnitude
                        let precise = validity.legal == 81 && validity.mismatch == 0 && estimate.value.isFinite
                            && estimate.uncertainty <= 0.1 && error <= 0.1
                        XCTAssertTrue(precise, "continuous source compatibility must prove the original counterexample: \(layer.id) \(control.rawValue) \(ordinal) \(truth)")
                        records.append([
                            "layer": layer.id, "control": control.rawValue, "anchorOrdinal": ordinal,
                            "knownTranslationPixels": truth, "trackedWindowLegalSampleCount": validity.legal,
                            "trackedWindowTruePredictionMismatchChannels": validity.mismatch,
                            "sourceTemplateTruePredictionMismatchChannels": templateTruth.mismatch,
                            "recoveredPixels": estimate.value.isFinite ? estimate.value : 0, "absoluteError": error,
                            "uncertaintyPixels": estimate.uncertainty, "estimatorStatus": estimate.status,
                            "verifiedCompatibleWitnessCount": estimate.witnessCount,
                            "truthStatus": precise ? "verified" : "inconclusive"
                        ])
                    }
                }
            }
        }
        XCTAssertEqual(records.count, 16)
        try receipt(records, name: "source-only-sixteen-continuous-v2-counterexamples.json", to: output,
            oracleVersion: "directional-v2-continuous-compatibility-diagnostic")
    }

    private func directionalSourceControlsV2(qualified: Bool) throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedNoFaceSafety(recovery: false)
            return
        }
        let output = try outputDirectory(), source = try load(input)
        var records: [[String: Any]] = []
        for layer in try layers(source) {
            let frame = try sourceFrame(layer)
            let domains = SourceDomains(frame: frame, width: layer.width, height: layer.height,
                additionalProtection: try protectionMask(layer))
            let anchors = try (qualified
                ? sourceQualifiedAnchorsV2(frame: frame, layer: layer, domains: domains)
                : sourceAnchorsV2(frame: frame, layer: layer, domains: domains))
            if qualified && ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_EXPORT_LOCAL_ANCHORS"] == "1" {
                try saveLocalSourceAnchors(anchors, layer: layer, to: output)
            }
            for control in mainControls { for (ordinal, anchor) in anchors[control]!.enumerated() {
                let information = directionalInformation(layer, point: anchor.point,
                    direction: anchor.direction, sampling: anchor.sampling)
                let axes: [(String, SIMD2<Double>, Bool)] = [
                    ("control", anchor.direction, true), ("image-x", SIMD2(1, 0), false), ("image-y", SIMD2(0, 1), false)
                ]
                for (axisName, direction, required) in axes {
                    let probe = Anchor(point: anchor.point, direction: direction, search: anchor.search, sampling: anchor.sampling)
                    for sign: Double in [-1, 1] { for amount in [0.25, 0.5, 1, 2, 4] {
                        let truth = sign * amount
                        let actual = knownLocalTranslation(layer, anchor: probe, delta: direction * truth, domains: domains)
                        let estimate = qualified ? quantizedTrackedMatch(probe, source: layer, output: actual)
                            : quantizedMatch(probe, source: layer, output: actual)
                        let validity = trackedTruthValidity(probe, source: layer, output: actual,
                            delta: direction * truth, domains: domains)
                        let error = estimate.value.isFinite ? abs(estimate.value - truth) : Double.greatestFiniteMagnitude
                        let precise = estimate.value.isFinite && error <= 0.1
                            && (!qualified || (validity.legal == 81 && validity.mismatch == 0 && estimate.uncertainty <= 0.1))
                        if required {
                            XCTAssertTrue(precise,
                                "V2 source control-axis calibration inconclusive beyond 0.1 px: \(layer.id) \(control.rawValue) \(ordinal) \(truth)")
                        }
                        let protection = protectedChanges(layer.bytes, actual, domains: domains, hairline: false)
                        XCTAssertEqual(protection.features, 0); XCTAssertEqual(protection.exterior, 0); XCTAssertEqual(protection.alpha, 0)
                        records.append([
                            "layer": layer.id, "control": control.rawValue, "anchorOrdinal": ordinal,
                            "axis": axisName, "requiredControlAxis": required, "knownTranslationPixels": truth,
                            "directionalInformation": information.score,
                            "minimumQuarterDirectionChangedChannels": information.quarterChanges,
                            "recoveredPixels": estimate.value.isFinite ? estimate.value : 0,
                            "absoluteError": error, "uncertaintyPixels": estimate.uncertainty,
                            "estimatorStatus": estimate.status, "truthStatus": precise ? "verified" : "inconclusive",
                            "verifiedCompatibleWitnessCount": estimate.witnessCount,
                            "trackedWindowLegalSampleCount": validity.legal,
                            "trackedWindowTruePredictionMismatchChannels": validity.mismatch,
                            "protectedChangedPixels": protection.features, "exteriorChangedPixels": protection.exterior
                        ])
                    } }
                }
            } }
        }
        try receipt(records, name: qualified ? "source-only-qualified-directional-v2-controls.json" : "source-only-directional-v2-controls.json",
            to: output, oracleVersion: qualified ? "directional-v2-qualified-tracked" : "directional-v2")
    }

    func testSourceOnlyFourTrackedTextureCounterexamplesV2() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedNoFaceSafety(recovery: false)
            return
        }
        let output = try outputDirectory(), source = try load(input)
        var records: [[String: Any]] = []
        for layer in try layers(source) {
            let frame = try sourceFrame(layer)
            let domains = SourceDomains(frame: frame, width: layer.width, height: layer.height,
                additionalProtection: try protectionMask(layer))
            let anchor = try sourceAnchorsV2(frame: frame, layer: layer, domains: domains)[.chinTaper]![1]
            let samples = (-4...4).flatMap { y in (-4...4).map { x in
                (Int(anchor.point.x.rounded()) + x * anchor.sampling,
                 Int(anchor.point.y.rounded()) + y * anchor.sampling)
            } }
            for truth in [2.0, 4] {
                let delta = anchor.direction * truth
                let actual = knownLocalTranslation(layer, anchor: anchor, delta: delta, domains: domains)
                var fixedLegal = 0, trackedLegal = 0, fixedMismatch = 0, trackedMismatch = 0
                let shiftX = Int(delta.x.rounded()), shiftY = Int(delta.y.rounded())
                for (x, y) in samples {
                    for tracked in [false, true] {
                        let ox = x + (tracked ? shiftX : 0), oy = y + (tracked ? shiftY : 0)
                        let sx = Double(ox) - delta.x, sy = Double(oy) - delta.y
                        let ix = Int(floor(sx)), iy = Int(floor(sy)), fx = sx - Double(ix), fy = sy - Double(iy)
                        guard min(ox, ix) >= 0, min(oy, iy) >= 0,
                              ox < layer.width, oy < layer.height, ix + 1 < layer.width, iy + 1 < layer.height else { continue }
                        let footprints = [iy * layer.width + ix, iy * layer.width + ix + 1,
                            (iy + 1) * layer.width + ix, (iy + 1) * layer.width + ix + 1]
                        let legal = domains.target[oy * layer.width + ox] && !domains.features[oy * layer.width + ox]
                            && footprints.allSatisfy { domains.target[$0] && !domains.features[$0] }
                        if legal { if tracked { trackedLegal += 1 } else { fixedLegal += 1 } }
                        for c in 0..<3 {
                            let p = footprints.map { Double(layer.bytes[$0 * 4 + c]) }
                            let prediction = (p[0] * (1 - fx) * (1 - fy) + p[1] * fx * (1 - fy)
                                + p[2] * (1 - fx) * fy + p[3] * fx * fy).rounded()
                            if UInt8(max(0, min(255, prediction))) != actual[(oy * layer.width + ox) * 4 + c] {
                                if tracked { trackedMismatch += 1 } else { fixedMismatch += 1 }
                            }
                        }
                    }
                }
                let fixed = quantizedMatch(anchor, source: layer, output: actual)
                let tracked = quantizedTrackedMatch(anchor, source: layer, output: actual)
                let error = tracked.value.isFinite ? abs(tracked.value - truth) : Double.greatestFiniteMagnitude
                let precise = trackedLegal == samples.count && trackedMismatch == 0 && tracked.value.isFinite && error <= 0.1
                XCTAssertTrue(precise, "source-tracked V2 control remains inconclusive unless legal and within 0.1 px: \(layer.id) \(truth)")
                let protection = protectedChanges(layer.bytes, actual, domains: domains, hairline: false)
                XCTAssertEqual(protection.features, 0); XCTAssertEqual(protection.exterior, 0); XCTAssertEqual(protection.alpha, 0)
                records.append([
                    "layer": layer.id, "control": "chinTaper", "anchorOrdinal": 1, "knownTranslationPixels": truth,
                    "fixedWindowLegalSampleCount": fixedLegal, "fixedWindowTruePredictionMismatchChannels": fixedMismatch,
                    "trackedWindowLegalSampleCount": trackedLegal, "trackedWindowTruePredictionMismatchChannels": trackedMismatch,
                    "fixedEstimatorStatus": fixed.status, "fixedUncertaintyPixels": fixed.uncertainty,
                    "trackedRecoveredPixels": tracked.value.isFinite ? tracked.value : 0,
                    "trackedAbsoluteError": error, "trackedUncertaintyPixels": tracked.uncertainty,
                    "trackedCompatibleIntervalCount": tracked.compatibleCount, "trackedEstimatorStatus": tracked.status,
                    "truthStatus": precise ? "verified" : "inconclusive",
                    "protectedChangedPixels": protection.features, "exteriorChangedPixels": protection.exterior
                ])
            }
        }
        try receipt(records, name: "source-only-four-tracked-v2-counterexamples.json", to: output, oracleVersion: "directional-v2-tracked-diagnostic")
    }

    /// Investigates qualification inside the original V2 candidate region.
    /// Source-only synthetic translations can reject an unobservable source
    /// patch; SDK results and competitor images never enter the selection.
    /// This diagnostic does not change the frozen V2 photo anchors.
    func testSourceOnlyV2CandidateQuantizationEligibility() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedNoFaceSafety(recovery: false)
            return
        }
        let output = try outputDirectory(), source = try load(input)
        var records: [[String: Any]] = []
        // The two integer counterexamples reject weak patches quickly. Every
        // accepted patch must then satisfy all ten original translations.
        let truths: [Double] = [2, 4, -0.25, 0.25, -0.5, 0.5, -1, 1, -2, -4]
        for layer in try layers(source) {
            let frame = try sourceFrame(layer)
            let domains = SourceDomains(frame: frame, width: layer.width, height: layer.height,
                additionalProtection: try protectionMask(layer))
            let candidates = try rightTaperCandidatesV2(frame: frame, layer: layer, domains: domains)
            var qualifiedRank: Int?, checked = 0, rejected = 0
            for (rank, candidate) in candidates.enumerated() {
                var preciseAll = true, checkedTruths = 0, maximumError = 0.0, maximumUncertainty = 0.0
                var rejectedStatus = "none"
                for truth in truths {
                    let delta = candidate.anchor.direction * truth
                    let actual = knownLocalTranslation(layer, anchor: candidate.anchor, delta: delta, domains: domains)
                    let validity = trackedTruthValidity(candidate.anchor, source: layer,
                        output: actual, delta: delta, domains: domains)
                    let estimate = quantizedTrackedMatch(candidate.anchor, source: layer, output: actual)
                    let error = estimate.value.isFinite ? abs(estimate.value - truth) : Double.greatestFiniteMagnitude
                    checkedTruths += 1
                    maximumError = max(maximumError, error)
                    maximumUncertainty = max(maximumUncertainty, estimate.uncertainty)
                    let precise = validity.legal == 81 && validity.mismatch == 0
                        && estimate.value.isFinite && estimate.uncertainty <= 0.1 && error <= 0.1
                    if !precise {
                        preciseAll = false
                        rejectedStatus = validity.legal != 81 || validity.mismatch != 0
                            ? "incomplete-source-truth" : estimate.status
                        break
                    }
                }
                checked += 1
                records.append([
                    "layer": layer.id, "control": "chinTaper", "anchorOrdinal": 1,
                    "sourceCandidateRank": rank, "candidateRegion": "frozen-v2-radius-0.012-span",
                    "directionalInformation": candidate.information,
                    "minimumQuarterDirectionChangedChannels": candidate.quarterChanges,
                    "requiredTranslationsChecked": checkedTruths, "maximumAbsoluteError": maximumError,
                    "maximumUncertaintyPixels": maximumUncertainty,
                    "qualification": preciseAll ? "all-ten-source-controls-verified" : "inconclusive",
                    "rejectionStatus": rejectedStatus, "photoOracleEnabled": false
                ])
                if preciseAll { qualifiedRank = rank; break }
                rejected += 1
            }
            XCTAssertNotNil(qualifiedRank,
                "Original V2 candidate region contains no fully observable source patch: \(layer.id)")
            records.append([
                "layer": layer.id, "control": "chinTaper", "anchorOrdinal": 1,
                "candidateRegion": "frozen-v2-radius-0.012-span",
                "eligibleSourceCandidateCount": candidates.count, "sourceCandidatesChecked": checked,
                "rejectedSourceCandidateCount": rejected, "fullyQualifiedSourceCandidateFound": qualifiedRank != nil,
                "qualifiedSourceCandidateRank": qualifiedRank ?? -1,
                "requiredTranslationsPerQualifiedCandidate": truths.count, "photoOracleEnabled": false
            ])
        }
        try receipt(records, name: "source-only-v2-candidate-quantization-eligibility.json", to: output,
            oracleVersion: "directional-v2-quantization-eligibility-diagnostic")
    }

    func testEightSourceFixedPhotoControlsOrGeneratedNoFaceRecovery() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedNoFaceSafety(recovery: true)
            return
        }
        let output = try outputDirectory()
        let source = try load(input)
        var records: [[String: Any]] = []
        for layer in try layers(source) {
            let frame = try sourceFrame(layer)
            let domains = SourceDomains(frame: frame, width: layer.width, height: layer.height,
                additionalProtection: try protectionMask(layer))
            let anchors = try selectedPhotoAnchors(frame: frame, layer: layer, domains: domains)
            let engine = try BeautyEngine()
            let prepared = try engine.prepareStillImage(image: cgImage(layer), metadata: metadata)
            let neutral = try engine.processResult(preparedImage: prepared, parameters: .init())
            let neutralBytes = try pixels(neutral.output, layer: layer)
            XCTAssertTrue(neutralBytes == layer.bytes, "canonical source neutral RGBA identity")
            try save(neutral.output, name: "\(layer.id)_neutral", to: output)
            for control in mainControls {
                for sign: Float in (control == .vFace ? [1] : [-1, 1]) {
                    var previous = 0.0
                    for (step, fraction) in [Float(0.25), 0.5, 0.75, 1].enumerated() {
                        let position = control == .vFace ? fraction : 0.5 + sign * fraction * 0.5
                        let parameters = control.applying(position: position, to: .init())
                        let result = try engine.processResult(preparedImage: prepared, parameters: parameters)
                        let actual = try pixels(result.output, layer: layer)
                        let logicalID = "\(layer.id)_\(control.rawValue)_\(sign < 0 ? "minus" : "plus")\(step + 1)"
                        let protection = protectedChanges(layer.bytes, actual, domains: domains, hairline: false)
                        XCTAssertEqual(protection.features, 0, "\(logicalID) complete brows/eyes/nose/lips")
                        XCTAssertEqual(protection.exterior, 0, "\(logicalID) fixed target-domain exterior RGBA")
                        XCTAssertEqual(protection.alpha, 0, "\(logicalID) alpha")
                        assertMetadata(result, layer: layer, logicalID: logicalID)
                        let estimates = anchors[control]!.map { selectedMatchEstimate($0, source: layer, output: actual) }
                        var direction = Double.nan
                        var measurementStatus = "qualified"
                        do {
                            direction = try measuredDirection(control, anchors: anchors[control]!,
                                source: layer, output: actual, estimates: estimates) * Double(sign)
                        } catch CheckError.inconclusivePhotoMeasurement {
                            measurementStatus = "typed-inconclusive"
                        }
                        let qualified = direction.isFinite
                        XCTAssertTrue(qualified, "\(logicalID) local photo matching is inconclusive; diagnostic fits do not qualify an effect")
                        // Measured output texture displacement, independently of
                        // the production displacement field or output detection.
                        let monotone = direction > previous + 0.1
                        XCTAssertTrue(monotone, "\(logicalID) source texture must move in direction and increase >0.1 px")
                        let visible = qualified && (fraction < 1 || direction > 1)
                        XCTAssertTrue(visible, "\(logicalID) endpoint texture displacement must exceed 1 px")
                        previous = direction
                        var repeated = true, freshEqual = true
                        if fraction == 1 {
                            let again = try engine.processResult(preparedImage: prepared, parameters: parameters)
                            repeated = actual == (try pixels(again.output, layer: layer))
                            XCTAssertTrue(repeated, "\(logicalID) repeated endpoint RGBA")
                            let fresh = try BeautyEngine().processResult(image: layer.image,
                                metadata: metadata, parameters: parameters)
                            freshEqual = actual == (try pixels(fresh.output, layer: layer))
                            XCTAssertTrue(freshEqual, "\(logicalID) public fresh/prepared RGBA equality")
                        }
                        try save(result.output, name: logicalID, to: output)
                        records.append([
                            "layer": layer.id, "control": control.rawValue, "sign": Int(sign),
                            "quarter": step + 1, "directionPixels": qualified ? direction : 0,
                            "measurementQualified": qualified, "measurementStatus": measurementStatus,
                            "anchorMatcherDiagnostics": estimates.enumerated().map { ordinal, estimate -> [String: Any] in
                                ["anchorOrdinal": ordinal, "status": estimate.status, "finiteDirection": estimate.value.isFinite,
                                 "uncertaintyPixels": estimate.uncertainty, "compatibleRectangles": estimate.compatibleCount,
                                 "verifiedWitnessCount": estimate.witnessCount, "nonuniformFitDiagnostics": estimate.diagnostics]
                            },
                            "monotone": monotone, "visibleEndpoint": visible,
                            "protectedFeatureChangedPixels": protection.features,
                            "exteriorChangedPixels": protection.exterior, "alphaChangedPixels": protection.alpha,
                            "endpointRepeated": repeated, "endpointFreshEqual": freshEqual
                        ])
                    }
                }
            }
            let restored = try engine.processResult(preparedImage: prepared, parameters: .init())
            XCTAssertTrue(try pixels(restored.output, layer: layer) == layer.bytes,
                "return to neutral after all isolated controls")
        }
        try receipt(records, name: "main-eight-aggregate.json", to: output)
    }

    /// This separate demand check keeps the two currently source-dependent
    /// controls visible as failures when they abstain. A safe no-op is not a
    /// positive hairline or contour-smoothing result. Target activity here is
    /// a capability prerequisite; appearance/reference parity needs review.
    func testAllTenSourceCapabilitiesOrGeneratedNoFaceIdentity() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedNoFaceSafety(recovery: false)
            return
        }
        let output = try outputDirectory()
        let source = try load(input)
        var records: [[String: Any]] = []
        for layer in try layers(source) {
            let frame = try sourceFrame(layer)
            let domains = SourceDomains(frame: frame, width: layer.width, height: layer.height,
                additionalProtection: try protectionMask(layer),
                manualHairlineTarget: try manualHairlineMask(layer, protection: false),
                additionalHairlineProtection: try manualHairlineMask(layer, protection: true))
            let engine = try BeautyEngine()
            let prepared = try engine.prepareStillImage(image: cgImage(layer), metadata: metadata)
            for control in BeautyFaceShapeSlider.allCases {
                for position: Float in (control == .vFace || control == .contourSmooth ? [1] : [0, 1]) {
                    let parameters = control.applying(position: position, to: .init())
                    let result = try engine.processResult(preparedImage: prepared, parameters: parameters)
                    let actual = try pixels(result.output, layer: layer)
                    let logicalID = "\(layer.id)_capability_\(control.rawValue)_\(position == 0 ? "left" : "right")"
                    let protection = protectedChanges(layer.bytes, actual, domains: domains, hairline: control == .hairline)
                    let activity = targetActivity(layer.bytes, actual, domains: domains, hairline: control == .hairline)
                    let oldRectangleExterior = control == .hairline
                        ? legacyHairlineExteriorChanges(layer.bytes, actual, domains: domains) : 0
                    // Fixed before candidate output: no-op and imperceptible
                    // numerical residue cannot establish a delivered control.
                    let useful = activity.rms >= 0.25 && activity.maximum >= 3 && activity.changed >= 16
                    XCTAssertTrue(useful, "\(logicalID) expected source capability must meaningfully act; safe no-op fails")
                    XCTAssertEqual(protection.features, 0, "\(logicalID) complete source features")
                    XCTAssertEqual(protection.exterior, 0, "\(logicalID) source-defined exterior")
                    XCTAssertEqual(protection.alpha, 0, "\(logicalID) alpha")
                    assertMetadata(result, layer: layer, logicalID: logicalID)
                    let again = try engine.processResult(preparedImage: prepared, parameters: parameters)
                    let repeated = actual == (try pixels(again.output, layer: layer))
                    XCTAssertTrue(repeated, "\(logicalID) repeat")
                    try save(result.output, name: logicalID, to: output)
                    records.append([
                        "layer": layer.id, "control": control.rawValue, "endpoint": position == 0 ? "left" : "right",
                        "meaningfulTargetActivity": useful, "targetRMSByteDelta": activity.rms,
                        "targetMaximumByteDelta": activity.maximum, "targetChangedPixels": activity.changed,
                        "protectedFeatureChangedPixels": protection.features,
                        "exteriorChangedPixels": protection.exterior, "alphaChangedPixels": protection.alpha,
                        "hairlineOracle": control == .hairline ? "frozen-manual-source-band" : "contour-source-domain",
                        "legacyHairlineRectangleExteriorChangedPixels": oldRectangleExterior,
                        "repeated": repeated
                    ])
                }
            }
        }
        try receipt(records, name: "all-ten-capability-aggregate.json", to: output)
    }

    /// Focused regression for the native smooth-source/proxy overlap. The
    /// source domains, semantic cores and useful-activity threshold are the
    /// same frozen criteria as the all-ten check above. Phase counts locate
    /// protection failures without retaining source geometry or masks.
    func testContourSmoothSourceStagesRetainFrozenProtectionAndUsefulActivity() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedNoFaceSafety(recovery: false)
            return
        }
        let output = try outputDirectory(), source = try load(input)
        var records: [[String: Any]] = []
        for layer in try layers(source) {
            let frame = try sourceFrame(layer)
            let domains = SourceDomains(frame: frame, width: layer.width, height: layer.height,
                additionalProtection: try protectionMask(layer))
            var detector = BeautyFaceDetector.production()
            let detection = detector.detect(image: layer.image, metadata: metadata,
                imageExtent: layer.image.extent.size, purpose: .geometryAndLocalSupport)
            XCTAssertEqual(detection.summary.availability, .usable)
            XCTAssertEqual(detection.observations.count, 1)
            let face = BeautyFaceGeometryAdapter.makeGeometry(from: try XCTUnwrap(detection.observations.first))
            let parameters = BeautyFaceShapeSlider.contourSmooth.applying(position: 1, to: .init())
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            let direct = FaceContourSubpixelRefiner.refineWithProtection(layer.bytes,
                width: layer.width, height: layer.height, face: face,
                strength: plan.effectiveStrengths.faceContourSmooth)
            let stage = BeautyStillImageGeometryStage(sourceRGBA: layer.bytes,
                width: layer.width, height: layer.height, plan: plan, face: face)
            let dense = stage.applyingDenseMap(to: stage.sourceRGBA)
            XCTAssertTrue(stage.sourceRGBA == direct.bytes, "isolated smooth source stage")
            XCTAssertTrue(dense == stage.sourceRGBA, "source-owned smooth must not receive a second dense proxy")
            var phases: [[String: Any]] = []
            for (name, bytes) in [("direct", direct.bytes), ("stage", stage.sourceRGBA), ("dense", dense)] {
                let protection = protectedChanges(layer.bytes, bytes, domains: domains, hairline: false)
                let activity = targetActivity(layer.bytes, bytes, domains: domains, hairline: false)
                XCTAssertEqual(protection.features, 0, "\(layer.id)_smooth_\(name) complete source features")
                XCTAssertEqual(protection.exterior, 0, "\(layer.id)_smooth_\(name) source-defined exterior")
                XCTAssertEqual(protection.alpha, 0, "\(layer.id)_smooth_\(name) alpha")
                phases.append(["phase": name, "protectedFeatureChangedPixels": protection.features,
                    "exteriorChangedPixels": protection.exterior, "alphaChangedPixels": protection.alpha,
                    "targetRMSByteDelta": activity.rms, "targetMaximumByteDelta": activity.maximum,
                    "targetChangedPixels": activity.changed])
            }
            let engine = try BeautyEngine()
            let prepared = try engine.prepareStillImage(image: cgImage(layer), metadata: metadata)
            let result = try engine.processResult(preparedImage: prepared, parameters: parameters)
            let actual = try pixels(result.output, layer: layer)
            let protection = protectedChanges(layer.bytes, actual, domains: domains, hairline: false)
            let activity = targetActivity(layer.bytes, actual, domains: domains, hairline: false)
            let useful = activity.rms >= 0.25 && activity.maximum >= 3 && activity.changed >= 16
            XCTAssertTrue(useful, "\(layer.id)_smooth expected source capability must meaningfully act; safe no-op fails")
            XCTAssertEqual(protection.features, 0, "\(layer.id)_smooth_public complete source features")
            XCTAssertEqual(protection.exterior, 0, "\(layer.id)_smooth_public source-defined exterior")
            XCTAssertEqual(protection.alpha, 0, "\(layer.id)_smooth_public alpha")
            assertMetadata(result, layer: layer, logicalID: "\(layer.id)_smooth_public")
            let again = try engine.processResult(preparedImage: prepared, parameters: parameters)
            let repeated = actual == (try pixels(again.output, layer: layer))
            XCTAssertTrue(repeated)
            let neutral = try engine.processResult(preparedImage: prepared, parameters: .init())
            XCTAssertTrue(try pixels(neutral.output, layer: layer) == layer.bytes)
            try save(result.output, name: "\(layer.id)_focused_contourSmooth", to: output)
            records.append(["layer": layer.id, "usesDenseMap": stage.usesDenseMap,
                "retainedProxyPointCount": stage.controlPoints.count,
                "protectedLeft": direct.protectedLeft, "protectedRight": direct.protectedRight,
                "phases": phases, "meaningfulTargetActivity": useful,
                "targetRMSByteDelta": activity.rms, "targetMaximumByteDelta": activity.maximum,
                "targetChangedPixels": activity.changed, "protectedFeatureChangedPixels": protection.features,
                "exteriorChangedPixels": protection.exterior, "alphaChangedPixels": protection.alpha,
                "repeated": repeated])
        }
        try receipt(records, name: "focused-smooth-stages-aggregate.json", to: output)
    }

    private struct Layer {
        let id: String
        let image: CIImage
        let width: Int
        let height: Int
        let bytes: [UInt8]
    }

    private func load(_ path: String) throws -> CIImage {
        let url = URL(fileURLWithPath: path)
        guard url.isFileURL,
              let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey]),
              values.isRegularFile == true, values.isSymbolicLink != true,
              let size = values.fileSize, size > 0, size <= BeautyConfiguration.defaultMaximumInputByteCount,
              let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true])
        else { throw CheckError.unreadableInput }
        return image
    }

    private func layers(_ source: CIImage) throws -> [Layer] {
        func make(_ image: CIImage, id: String) throws -> Layer {
            let canonical = try BeautyStillImageCanonicalizer().canonicalize(image: image,
                metadata: metadata, maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
            return Layer(id: id, image: canonical.ciImage, width: canonical.width,
                height: canonical.height, bytes: Array(canonical.rgba8Data))
        }
        let full = try make(source, id: "full")
        let scale = min(1, 960 / Double(max(full.width, full.height)))
        let resized = full.image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            .cropped(to: CGRect(x: 0, y: 0, width: floor(Double(full.width) * scale),
                height: floor(Double(full.height) * scale)))
        return [full, try make(resized, id: "preview960")]
    }

    private func pixels(_ image: CIImage, layer: Layer) throws -> [UInt8] {
        guard image.extent == layer.image.extent else { throw CheckError.invalidSourceSupport }
        var bytes = [UInt8](repeating: 0, count: layer.width * layer.height * 4)
        CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace]).render(
            image, toBitmap: &bytes, rowBytes: layer.width * 4, bounds: image.extent,
            format: .RGBA8, colorSpace: colorSpace)
        return bytes
    }

    private func cgImage(_ layer: Layer) throws -> CGImage {
        guard let cg = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
            .createCGImage(layer.image, from: layer.image.extent, format: .RGBA8, colorSpace: colorSpace)
        else { throw CheckError.encodingFailed }
        return cg
    }

    /// An optional owner-local source annotation adds hard protection for
    /// photographed ears, hair, objects and other semantics which face
    /// landmarks alone do not identify. White pixels are protected. The mask
    /// must be fixed before candidate output, opaque, and source registered.
    private func protectionMask(_ layer: Layer) throws -> [Bool]? {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_PROTECTION"] else { return nil }
        let image = try load(path)
        let sourceSize = image.extent.size
        guard sourceSize.width > 0, sourceSize.height > 0,
              abs(sourceSize.width / sourceSize.height - Double(layer.width) / Double(layer.height)) < 0.002
        else { throw CheckError.invalidSourceSupport }
        let resized = image.transformed(by: CGAffineTransform(scaleX: Double(layer.width) / sourceSize.width,
            y: Double(layer.height) / sourceSize.height)).cropped(to: layer.image.extent)
        let bytes = try pixels(resized, layer: layer)
        guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else {
            throw CheckError.invalidSourceSupport
        }
        return (0..<(layer.width * layer.height)).map { bytes[$0 * 4] >= 128 }
    }

    /// These categorical source annotations were frozen independently before
    /// hairline candidates. Nearest source-pixel registration preserves their
    /// exact declared ownership rather than feathering or expanding the band.
    private func manualHairlineMask(_ layer: Layer, protection: Bool) throws -> [Bool] {
        let key = protection ? "BEAUTY_FACE_REFERENCE_HAIRLINE_PROTECTION" : "BEAUTY_FACE_REFERENCE_HAIRLINE_TARGET"
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let name = protection ? "protected_hairline_union.png" : "legal_hairline_band.png"
        let path = ProcessInfo.processInfo.environment[key]
            ?? package.appendingPathComponent(".build/face-reference/protection-masks/" + name).path
        let image = try load(path)
        let expected = protection
            ? "f6d4b487ab9aa9a733a12af764dfdbbef5ddf5c70d6930ac762ec7f15e7b90e6"
            : "30a906016807a686f1f2a5f626051cc27d3c56fc95b4c693dfc1be27821e7443"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              SHA256.hash(data: data).map({ String(format: "%02x", $0) }).joined() == expected
        else { throw CheckError.invalidSourceSupport }
        let width = Int(image.extent.width), height = Int(image.extent.height)
        guard image.extent.origin == .zero, width > 0, height > 0,
              abs(Double(width) / Double(height) - Double(layer.width) / Double(layer.height)) < 0.002
        else { throw CheckError.invalidSourceSupport }
        let temporary = Layer(id: "source-annotation", image: image, width: width, height: height, bytes: [])
        let bytes = try pixels(image, layer: temporary)
        guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else { throw CheckError.invalidSourceSupport }
        return (0..<(layer.width * layer.height)).map { p in
            let x = p % layer.width, y = p / layer.width
            let sx = min(width - 1, Int((Double(x) + 0.5) * Double(width) / Double(layer.width)))
            let sy = min(height - 1, Int((Double(y) + 0.5) * Double(height) / Double(layer.height)))
            return bytes[(sy * width + sx) * 4] >= 128
        }
    }

    private struct Frame {
        let contour: [SIMD2<Double>]
        let featureBoxes: [CGRect]
        let origin: SIMD2<Double>
        let axisX: SIMD2<Double>
        let axisY: SIMD2<Double>
        let span: Double
        let chin: Double
        let bounds: CGRect
        func local(_ point: SIMD2<Double>) -> SIMD2<Double> {
            let d = point - origin
            return SIMD2(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
        }
        func image(_ local: SIMD2<Double>) -> SIMD2<Double> { origin + axisX * local.x + axisY * local.y }
    }

    private func sourceFrame(_ layer: Layer) throws -> Frame {
        var detector = BeautyFaceDetector.production()
        let detected = detector.detect(image: layer.image, metadata: metadata,
            imageExtent: layer.image.extent.size, purpose: .geometryAndLocalSupport)
        guard detected.summary.availability == .usable, detected.observations.count == 1,
              let observation = detected.observations.first,
              let contour = observation.observedFaceSupport?.contour, contour.count >= 7,
              let eyes = observation.observedEyeSupport, eyes.count == 2,
              let left = eyes.first(where: { $0.side == .left })?.contour, left.count >= 4,
              let right = eyes.first(where: { $0.side == .right })?.contour, right.count >= 4,
              let brows = observation.observedEyebrowSupport,
              let leftBrow = brows.left, leftBrow.count >= 4,
              let rightBrow = brows.right, rightBrow.count >= 4,
              let lip = observation.observedLipSupport?.outer, lip.count >= 4,
              let nose = observation.observedNoseSupport, nose.contour.count >= 4,
              let bounds = observation.imageBounds
        else { throw CheckError.invalidSourceSupport }
        func pixel(_ p: CoordinatePoint) -> SIMD2<Double> { SIMD2(p.x * Double(layer.width), p.y * Double(layer.height)) }
        func mean(_ points: [CoordinatePoint]) -> SIMD2<Double> { points.map(pixel).reduce(.zero, +) / Double(points.count) }
        let delta = mean(right) - mean(left), distance = hypot(delta.x, delta.y)
        guard distance > 4 else { throw CheckError.invalidSourceSupport }
        let axisX = delta / distance, axisY = SIMD2(-axisX.y, axisX.x)
        let origin = (mean(left) + mean(right)) * 0.5
        let points = contour.map(pixel)
        let span = points.map(\.x).max()! - points.map(\.x).min()!
        let chin = points.map { p in let d = p - origin; return d.x * axisY.x + d.y * axisY.y }.max()!
        guard span > 8, chin > 8 else { throw CheckError.invalidSourceSupport }
        func box(_ points: [CoordinatePoint], margin: Double) -> CGRect {
            let p = points.map(pixel)
            return CGRect(x: p.map(\.x).min()! - margin, y: p.map(\.y).min()! - margin,
                width: p.map(\.x).max()! - p.map(\.x).min()! + 2 * margin,
                height: p.map(\.y).max()! - p.map(\.y).min()! + 2 * margin)
        }
        let features = [box(left, margin: max(2, span * 0.008)), box(right, margin: max(2, span * 0.008)),
            box(leftBrow, margin: max(2, span * 0.008)), box(rightBrow, margin: max(2, span * 0.008)),
            box(lip + (observation.observedLipSupport?.inner ?? []), margin: max(2, span * 0.008)),
            box(nose.contour + nose.crest, margin: max(2, span * 0.008))]
        return Frame(contour: points, featureBoxes: features, origin: origin, axisX: axisX,
            axisY: axisY, span: span, chin: chin,
            bounds: CGRect(x: bounds.x * Double(layer.width), y: bounds.y * Double(layer.height),
                width: bounds.width * Double(layer.width), height: bounds.height * Double(layer.height)))
    }

    private struct SourceDomains {
        let target: [Bool]
        let hairlineTarget: [Bool]
        let legacyHairlineTarget: [Bool]
        let features: [Bool]
        let hairlineFeatures: [Bool]
        init(frame: Frame, width: Int, height: Int, additionalProtection: [Bool]?,
             manualHairlineTarget: [Bool]? = nil, additionalHairlineProtection: [Bool]? = nil) {
            var path = frame.contour
            if frame.local(path[0]).x > frame.local(path.last!).x { path.reverse() }
            let left = frame.local(path[0]), right = frame.local(path.last!)
            // The inner 20%-of-span band permits a smooth tissue transition;
            // the outer 6%-of-span + two-pixel corridor permits only the
            // bounded contour sweep. More distant hair/background is exact.
            // This asymmetric domain is fixed before candidate output.
            path = [frame.image(SIMD2(left.x * 0.96, -frame.chin * 0.32)),
                    frame.image(SIMD2(left.x, -frame.chin * 0.12))] + path +
                   [frame.image(SIMD2(right.x, -frame.chin * 0.12)),
                    frame.image(SIMD2(right.x * 0.96, -frame.chin * 0.32))]
            let insideRadius2 = pow(frame.span * 0.20, 2)
            let outsideRadius2 = pow(frame.span * 0.06 + 2, 2)
            let hair = CGRect(x: frame.bounds.minX - frame.span * 0.12,
                y: max(0, frame.bounds.minY - frame.span * 0.20),
                width: frame.bounds.width + frame.span * 0.24,
                height: max(0, frame.featureBoxes[2].minY - frame.bounds.minY + frame.span * 0.16))
            var target = [Bool](repeating: false, count: width * height), features = target, hairline = target, hairlineFeatures = target
            for y in 0..<height { for x in 0..<width {
                let q = SIMD2(Double(x) + 0.5, Double(y) + 0.5), p = CGPoint(x: q.x, y: q.y), i = y * width + x
                features[i] = frame.featureBoxes.contains { $0.contains(p) } || additionalProtection?[i] == true
                hairlineFeatures[i] = frame.featureBoxes.contains { $0.contains(p) } || additionalHairlineProtection?[i] == true
                hairline[i] = hair.contains(p)
                var inside = false
                for (a, b) in zip(path, Array(path.dropFirst()) + [path[0]]) where (a.y > q.y) != (b.y > q.y) {
                    if q.x < (b.x - a.x) * (q.y - a.y) / (b.y - a.y) + a.x { inside.toggle() }
                }
                let radius2 = inside ? insideRadius2 : outsideRadius2
                for (a, b) in zip(path, path.dropFirst()) {
                    let d = b - a, length2 = d.x * d.x + d.y * d.y
                    guard length2 > 0 else { continue }
                    let projection = max(0, min(1, ((q - a).x * d.x + (q - a).y * d.y) / length2))
                    let residual = q - (a + projection * d)
                    if residual.x * residual.x + residual.y * residual.y <= radius2 { target[i] = true; break }
                }
            } }
            self.target = target; self.hairlineTarget = manualHairlineTarget ?? [Bool](repeating: false, count: width * height)
            self.legacyHairlineTarget = hairline; self.features = features; self.hairlineFeatures = hairlineFeatures
        }
    }

    private func protectedChanges(_ source: [UInt8], _ output: [UInt8], domains: SourceDomains,
                                  hairline: Bool) -> (features: Int, exterior: Int, alpha: Int) {
        var features = 0, exterior = 0, alpha = 0
        for p in domains.target.indices {
            let i = p * 4
            let changed = (0..<4).contains { source[i + $0] != output[i + $0] }
            if changed && (hairline ? domains.hairlineFeatures[p] : domains.features[p]) { features += 1 }
            if changed && !(hairline ? domains.hairlineTarget[p] : domains.target[p]) { exterior += 1 }
            if source[i + 3] != output[i + 3] { alpha += 1 }
        }
        return (features, exterior, alpha)
    }

    private func targetActivity(_ source: [UInt8], _ output: [UInt8], domains: SourceDomains,
                                hairline: Bool) -> (rms: Double, maximum: Int, changed: Int) {
        var square = 0.0, count = 0, maximum = 0, changed = 0
        for p in domains.target.indices where (hairline ? domains.hairlineTarget[p] : domains.target[p])
            && !(hairline ? domains.hairlineFeatures[p] : domains.features[p]) {
            let i = p * 4
            var pixelChanged = false
            for channel in 0..<3 {
                let d = abs(Int(output[i + channel]) - Int(source[i + channel]))
                square += Double(d * d); count += 1; maximum = max(maximum, d); pixelChanged = pixelChanged || d != 0
            }
            if pixelChanged { changed += 1 }
        }
        return (sqrt(square / Double(max(1, count))), maximum, changed)
    }

    private func legacyHairlineExteriorChanges(_ source: [UInt8], _ output: [UInt8], domains: SourceDomains) -> Int {
        domains.legacyHairlineTarget.indices.filter { p in
            !domains.legacyHairlineTarget[p] && (0..<4).contains { source[p * 4 + $0] != output[p * 4 + $0] }
        }.count
    }

    private struct Anchor {
        let point: SIMD2<Double>
        let direction: SIMD2<Double>
        let search: Int
        let sampling: Int
    }

    private func selectedPhotoAnchors(frame: Frame, layer: Layer, domains: SourceDomains) throws -> [BeautyFaceShapeSlider: [Anchor]] {
        switch ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_ORACLE_VERSION"] {
        case nil, "variance-v1": return try sourceAnchorsV1(frame: frame, layer: layer)
        case "directional-v2": return try sourceAnchorsV2(frame: frame, layer: layer, domains: domains)
        case "directional-v2-qualified-tracked": return try sourceQualifiedAnchorsV2(frame: frame, layer: layer, domains: domains)
        default: throw CheckError.invalidInput
        }
    }

    /// Frozen V1 max-overall-variance selection, retained for its dated
    /// calibration counterexamples. It never becomes a V2 success claim.
    private func sourceAnchorsV1(frame: Frame, layer: Layer) throws -> [BeautyFaceShapeSlider: [Anchor]] {
        var anchors: [BeautyFaceShapeSlider: [Anchor]] = [:]
        let desired: [(BeautyFaceShapeSlider, Double, Bool, Double)] = [
            (.faceWidth, 0.47, false, -1), (.smallFace, 0.58, false, -1),
            (.jawAngle, 0.72, false, -1), (.vFace, 0.78, false, -1),
            (.temple, -0.10, false, 1), (.cheekbone, 0.22, false, -1),
            (.chinTaper, 0.88, false, 1), (.chinLength, 1, true, -1)
        ]
        for (control, y, vertical, polarity) in desired {
            let sides: [Double] = vertical ? [0] : [-1, 1]
            anchors[control] = try sides.map { side in
                let candidates = frame.contour.filter { point in
                    vertical || frame.local(point).x * side > 0
                }
                guard let raw = candidates.min(by: {
                    abs(frame.local($0).y / frame.chin - y) < abs(frame.local($1).y / frame.chin - y)
                }) else { throw CheckError.invalidSourceSupport }
                var local = frame.local(raw)
                if control == .temple { local.y = y * frame.chin }
                if !vertical { local.x -= side * frame.span * 0.018 }
                let seed = frame.image(local)
                let sampling = max(1, Int((frame.span / 260).rounded()))
                let radius = max(2, Int((frame.span * 0.012).rounded()))
                var best = seed, bestVariance = -1.0
                // Selection uses only immutable source texture, before any
                // candidate renders. Stronger local texture improves matching.
                for dy in stride(from: -radius, through: radius, by: sampling) {
                    for dx in stride(from: -radius, through: radius, by: sampling) {
                        let p = seed + SIMD2(Double(dx), Double(dy))
                        let variance = patchVariance(layer.bytes, point: p, layer: layer, sampling: sampling)
                        if variance > bestVariance { best = p; bestVariance = variance }
                    }
                }
                guard bestVariance > 4 else { throw CheckError.weakSourceTexture }
                let direction = vertical ? frame.axisY * polarity : frame.axisX * side * polarity
                return Anchor(point: best, direction: direction,
                    search: max(4, Int(ceil(frame.span * 0.065))), sampling: sampling)
            }
        }
        return anchors
    }

    private func sourceAnchorsV2(frame: Frame, layer: Layer, domains: SourceDomains) throws -> [BeautyFaceShapeSlider: [Anchor]] {
        let desired: [(BeautyFaceShapeSlider, Double, Bool, Double)] = [
            (.faceWidth, 0.47, false, -1), (.smallFace, 0.58, false, -1),
            (.jawAngle, 0.72, false, -1), (.vFace, 0.78, false, -1),
            (.temple, -0.10, false, 1), (.cheekbone, 0.22, false, -1),
            (.chinTaper, 0.88, false, 1), (.chinLength, 1, true, -1)
        ]
        var result: [BeautyFaceShapeSlider: [Anchor]] = [:]
        for (control, y, vertical, polarity) in desired {
            result[control] = try (vertical ? [0.0] : [-1, 1]).map { side in
                let candidates = frame.contour.filter { vertical || frame.local($0).x * side > 0 }
                guard let raw = candidates.min(by: {
                    abs(frame.local($0).y / frame.chin - y) < abs(frame.local($1).y / frame.chin - y)
                }) else { throw CheckError.invalidSourceSupport }
                var local = frame.local(raw)
                if control == .temple { local.y = y * frame.chin }
                if !vertical { local.x -= side * frame.span * 0.018 }
                let seed = frame.image(local), sampling = max(1, Int((frame.span / 260).rounded()))
                let radius = max(2, Int((frame.span * 0.012).rounded()))
                let direction = vertical ? frame.axisY * polarity : frame.axisX * side * polarity
                var best: SIMD2<Double>?, bestScore = -1.0
                var examined = 0, legal = 0, textured = 0, directional = 0
                for dy in stride(from: -radius, through: radius, by: sampling) {
                    for dx in stride(from: -radius, through: radius, by: sampling) {
                        let point = seed + SIMD2(Double(dx), Double(dy))
                        examined += 1
                        guard legalCalibrationPatch(point, sampling: sampling, layer: layer, domains: domains) else { continue }
                        legal += 1
                        guard patchVariance(layer.bytes, point: point, layer: layer, sampling: sampling) > 4 else { continue }
                        textured += 1
                        let information = directionalInformation(layer, point: point, direction: direction, sampling: sampling)
                        guard information.score > 4, information.quarterChanges > 0 else { continue }
                        directional += 1
                        let score = information.score * (1 + Double(information.quarterChanges) / 243)
                        if score > bestScore { best = point; bestScore = score }
                    }
                }
                guard let best else {
                    throw CheckError.sourceAnchorQualification(layer: layer.id, control: control.rawValue,
                        side: vertical ? "center" : side < 0 ? "left" : "right",
                        candidates: examined, legal: legal, textured: textured, directional: directional)
                }
                return Anchor(point: best, direction: direction,
                    search: max(4, Int(ceil(frame.span * 0.065))), sampling: sampling)
            }
        }
        return result
    }

    private func sourceQualifiedAnchorsV2(frame: Frame, layer: Layer,
                                          domains: SourceDomains) throws -> [BeautyFaceShapeSlider: [Anchor]] {
        var result = try sourceAnchorsV2(frame: frame, layer: layer, domains: domains)
        guard var taper = result[.chinTaper], taper.count == 2 else { throw CheckError.invalidSourceSupport }
        // The original source-only V2 qualification proved that a narrow
        // region contains a fully observable patch. Eligibility is independent
        // of SDK/competitor renders, with all ten actual-axis truths required.
        let candidates = try rightTaperCandidatesV2(frame: frame, layer: layer, domains: domains)
        guard let selected = candidates.first(where: { sourceTranslationQualified($0.anchor, layer: layer, domains: domains) })
        else { throw CheckError.weakSourceTexture }
        taper[1] = selected.anchor
        result[.chinTaper] = taper
        return result
    }

    private func sourceTranslationQualified(_ anchor: Anchor, layer: Layer, domains: SourceDomains) -> Bool {
        for truth: Double in [2, 4, -0.25, 0.25, -0.5, 0.5, -1, 1, -2, -4] {
            let delta = anchor.direction * truth
            let actual = knownLocalTranslation(layer, anchor: anchor, delta: delta, domains: domains)
            let validity = trackedTruthValidity(anchor, source: layer, output: actual, delta: delta, domains: domains)
            let estimate = quantizedTrackedMatch(anchor, source: layer, output: actual)
            guard validity.legal == 81, validity.mismatch == 0, estimate.value.isFinite,
                  estimate.uncertainty <= 0.1, abs(estimate.value - truth) <= 0.1 else { return false }
        }
        return true
    }

    private struct SourceCandidate {
        let anchor: Anchor
        let information: Double
        let quarterChanges: Int
        let score: Double
        let enumeration: Int
    }

    private func rightTaperCandidatesV2(frame: Frame, layer: Layer, domains: SourceDomains) throws -> [SourceCandidate] {
        // Exactly the original V2 right-side taper seed and search region.
        // Keeping V2 itself unchanged preserves its first selected anchor and
        // failures; calibration eligibility is a separate source diagnostic.
        guard let raw = frame.contour.filter({ frame.local($0).x > 0 }).min(by: {
            abs(frame.local($0).y / frame.chin - 0.88) < abs(frame.local($1).y / frame.chin - 0.88)
        }) else { throw CheckError.invalidSourceSupport }
        var local = frame.local(raw)
        local.x -= frame.span * 0.018
        let seed = frame.image(local), sampling = max(1, Int((frame.span / 260).rounded()))
        let radius = max(2, Int((frame.span * 0.012).rounded()))
        let direction = frame.axisX
        var result: [SourceCandidate] = [], enumeration = 0
        for dy in stride(from: -radius, through: radius, by: sampling) {
            for dx in stride(from: -radius, through: radius, by: sampling) {
                defer { enumeration += 1 }
                let point = seed + SIMD2(Double(dx), Double(dy))
                guard legalCalibrationPatch(point, sampling: sampling, layer: layer, domains: domains),
                      patchVariance(layer.bytes, point: point, layer: layer, sampling: sampling) > 4 else { continue }
                let information = directionalInformation(layer, point: point, direction: direction, sampling: sampling)
                guard information.score > 4, information.quarterChanges > 0 else { continue }
                result.append(SourceCandidate(anchor: Anchor(point: point, direction: direction,
                    search: max(4, Int(ceil(frame.span * 0.065))), sampling: sampling),
                    information: information.score, quarterChanges: information.quarterChanges,
                    score: information.score * (1 + Double(information.quarterChanges) / 243), enumeration: enumeration))
            }
        }
        return result.sorted { $0.score == $1.score ? $0.enumeration < $1.enumeration : $0.score > $1.score }
    }

    private func trackedTruthValidity(_ anchor: Anchor, source: Layer, output: [UInt8],
                                      delta: SIMD2<Double>, domains: SourceDomains) -> (legal: Int, mismatch: Int) {
        let cx = Int(anchor.point.x.rounded()), cy = Int(anchor.point.y.rounded())
        let dx = Int(delta.x.rounded()), dy = Int(delta.y.rounded())
        var legal = 0, mismatch = 0
        for py in -4...4 { for px in -4...4 {
            let x = cx + px * anchor.sampling + dx, y = cy + py * anchor.sampling + dy
            let sx = Double(x) - delta.x, sy = Double(y) - delta.y
            let ix = Int(floor(sx)), iy = Int(floor(sy)), fx = sx - Double(ix), fy = sy - Double(iy)
            guard min(x, ix) >= 0, min(y, iy) >= 0, x < source.width, y < source.height,
                  ix + 1 < source.width, iy + 1 < source.height else { continue }
            let footprints = [iy * source.width + ix, iy * source.width + ix + 1,
                (iy + 1) * source.width + ix, (iy + 1) * source.width + ix + 1]
            if domains.target[y * source.width + x] && !domains.features[y * source.width + x]
                && footprints.allSatisfy({ domains.target[$0] && !domains.features[$0] }) { legal += 1 }
            for c in 0..<3 {
                let p = footprints.map { Double(source.bytes[$0 * 4 + c]) }
                let prediction = (p[0] * (1 - fx) * (1 - fy) + p[1] * fx * (1 - fy)
                    + p[2] * (1 - fx) * fy + p[3] * fx * fy).rounded()
                if UInt8(max(0, min(255, prediction))) != output[(y * source.width + x) * 4 + c] { mismatch += 1 }
            }
        } }
        return (legal, mismatch)
    }

    private func trackedKnownPredictionMismatch(_ anchor: Anchor, source: Layer, output: [UInt8],
                                                delta: SIMD2<Double>) -> (samples: Int, mismatch: Int) {
        let cx = Int(anchor.point.x.rounded()), cy = Int(anchor.point.y.rounded())
        let dx = Int(delta.x.rounded()), dy = Int(delta.y.rounded())
        let residual = delta - SIMD2(Double(dx), Double(dy))
        let horizontalSide = residual.x < 0 ? -1 : 1, verticalSide = residual.y < 0 ? -1 : 1
        let u = abs(residual.x), v = abs(residual.y)
        var samples = 0, mismatch = 0
        for py in -4...4 { for px in -4...4 {
            let x = cx + px * anchor.sampling, y = cy + py * anchor.sampling
            guard x >= 1, y >= 1, x + 1 < source.width, y + 1 < source.height,
                  x + dx >= 0, y + dy >= 0, x + dx < source.width, y + dy < source.height else { continue }
            samples += 1
            let a = (y * source.width + x) * 4
            let b = a - horizontalSide * 4, c = a - verticalSide * source.width * 4, d = c - horizontalSide * 4
            let target = ((y + dy) * source.width + x + dx) * 4
            for channel in 0..<3 {
                let aa = Double(source.bytes[a + channel]), bb = Double(source.bytes[b + channel])
                let cc = Double(source.bytes[c + channel]), dd = Double(source.bytes[d + channel])
                let prediction = aa + (bb - aa) * u + (cc - aa) * v + (dd - bb - cc + aa) * u * v
                if prediction.rounded() != Double(output[target + channel]) { mismatch += 1 }
            }
        } }
        return (samples, mismatch)
    }

    private func legalCalibrationPatch(_ point: SIMD2<Double>, sampling: Int,
                                       layer: Layer, domains: SourceDomains) -> Bool {
        // Original 9x9 sample grid plus all <=4 px translations and their
        // complete bilinear footprints. This is source registration, not
        // inferred from an SDK candidate or a post-edit changed-pixel mask.
        let radius = 4 * sampling + 6, cx = Int(point.x.rounded()), cy = Int(point.y.rounded())
        guard cx - radius >= 1, cy - radius >= 1,
              cx + radius < layer.width - 1, cy + radius < layer.height - 1 else { return false }
        for y in (cy - radius)...(cy + radius) { for x in (cx - radius)...(cx + radius) {
            let p = y * layer.width + x
            if !domains.target[p] || domains.features[p] { return false }
        } }
        return true
    }

    private func directionalInformation(_ layer: Layer, point: SIMD2<Double>,
                                        direction: SIMD2<Double>, sampling: Int) -> (score: Double, quarterChanges: Int) {
        var xx = 0.0, yy = 0.0, xy = 0.0, positiveChanges = 0, negativeChanges = 0
        let cx = Int(point.x.rounded()), cy = Int(point.y.rounded())
        for py in -4...4 { for px in -4...4 {
            let x = cx + px * sampling, y = cy + py * sampling
            guard x >= 1, y >= 1, x + 1 < layer.width, y + 1 < layer.height else { return (-1, 0) }
            let i = (y * layer.width + x) * 4
            for c in 0..<3 {
                let gx = (Double(layer.bytes[i + 4 + c]) - Double(layer.bytes[i - 4 + c])) * 0.5
                let gy = (Double(layer.bytes[i + layer.width * 4 + c]) - Double(layer.bytes[i - layer.width * 4 + c])) * 0.5
                xx += gx * gx; yy += gy * gy; xy += gx * gy
                for sign: Double in [-1, 1] {
                    let sx = Double(x) - direction.x * 0.25 * sign, sy = Double(y) - direction.y * 0.25 * sign
                    let ix = Int(floor(sx)), iy = Int(floor(sy)), fx = sx - Double(ix), fy = sy - Double(iy)
                    let a = (iy * layer.width + ix) * 4 + c
                    let value = Double(layer.bytes[a]) * (1 - fx) * (1 - fy) + Double(layer.bytes[a + 4]) * fx * (1 - fy)
                        + Double(layer.bytes[a + layer.width * 4]) * (1 - fx) * fy
                        + Double(layer.bytes[a + layer.width * 4 + 4]) * fx * fy
                    if UInt8(max(0, min(255, value.rounded()))) != layer.bytes[i + c] {
                        if sign > 0 { positiveChanges += 1 } else { negativeChanges += 1 }
                    }
                }
            }
        } }
        let n = direction, t = SIMD2(-direction.y, direction.x)
        let nn = n.x * n.x * xx + 2 * n.x * n.y * xy + n.y * n.y * yy
        let tt = t.x * t.x * xx + 2 * t.x * t.y * xy + t.y * t.y * yy
        let nt = n.x * t.x * xx + (n.x * t.y + n.y * t.x) * xy + n.y * t.y * yy
        return (max(0, nn - nt * nt / max(1, tt)), min(positiveChanges, negativeChanges))
    }

    private func patchVariance(_ bytes: [UInt8], point: SIMD2<Double>, layer: Layer, sampling: Int) -> Double {
        var sum = 0.0, squares = 0.0, count = 0.0
        for dy in -4...4 { for dx in -4...4 {
            let x = Int(point.x.rounded()) + dx * sampling, y = Int(point.y.rounded()) + dy * sampling
            guard x >= 0, y >= 0, x < layer.width, y < layer.height else { return -1 }
            let i = (y * layer.width + x) * 4
            let v = (Double(bytes[i]) + Double(bytes[i + 1]) + Double(bytes[i + 2])) / 3
            sum += v; squares += v * v; count += 1
        } }
        return squares / count - pow(sum / count, 2)
    }

    private func measuredDirection(_ control: BeautyFaceShapeSlider, anchors: [Anchor],
                                   source: Layer, output: [UInt8], estimates: [MatchEstimate]? = nil) throws -> Double {
        let distances = (estimates ?? anchors.map { selectedMatchEstimate($0, source: source, output: output) }).map(\.value)
        guard distances.allSatisfy(\.isFinite) else { throw CheckError.inconclusivePhotoMeasurement }
        return distances.reduce(0, +) / Double(distances.count)
    }

    private struct MatchEstimate {
        let value: Double
        let uncertainty: Double
        let compatibleCount: Int
        let status: String
        let witnessCount: Int
        let diagnostics: [String: Any]
        init(value: Double, uncertainty: Double, compatibleCount: Int, status: String, witnessCount: Int = 0,
             diagnostics: [String: Any] = [:]) {
            self.value = value; self.uncertainty = uncertainty
            self.compatibleCount = compatibleCount; self.status = status; self.witnessCount = witnessCount
            self.diagnostics = diagnostics
        }
    }

    private func match(_ anchor: Anchor, source: Layer, output: [UInt8]) -> Double {
        selectedMatchEstimate(anchor, source: source, output: output).value
    }

    private func selectedMatchEstimate(_ anchor: Anchor, source: Layer, output: [UInt8]) -> MatchEstimate {
        if ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_ORACLE_VERSION"] == "directional-v2-qualified-tracked" {
            return quantizedTrackedMatch(anchor, source: source, output: output)
        }
        return quantizedMatch(anchor, source: source, output: output)
    }

    /// A materialized byte constrains the unquantized prediction to its
    /// half-byte interval. Intersect those constraints for every channel in
    /// the fixed sample grid, for every integer cell and fixed y phase.
    /// The midpoint and projected uncertainty come from all compatible
    /// intervals, never the known control's displacement or output landmarks.
    /// Nonuniform photographic patches without an exact compatible local
    /// translation retain the continuous forward least-squares estimate.
    private func quantizedMatch(_ anchor: Anchor, source: Layer, output: [UInt8]) -> MatchEstimate {
        if output == source.bytes {
            return MatchEstimate(value: 0, uncertainty: 0, compatibleCount: 1, status: "whole-raster-identity")
        }
        let cx = Int(anchor.point.x.rounded()), cy = Int(anchor.point.y.rounded())
        let samples = (-4...4).flatMap { y in (-4...4).map { x in
            (cx + x * anchor.sampling, cy + y * anchor.sampling)
        } }
        var lowerProjection = Double.infinity, upperProjection = -Double.infinity, count = 0
        for dy in -anchor.search...anchor.search { for dx in -anchor.search...anchor.search {
            for phase in 0...(dy == anchor.search ? 0 : 8) {
                let v = Double(phase) / 8
                var lower = 0.0, upper = dx == anchor.search ? 0.0 : 1.0, compatible = true
                for (x, y) in samples {
                    let sx = x - dx, sy = y - dy
                    guard x >= 0, y >= 0, x < source.width, y < source.height,
                          sx >= 1, sy >= 1, sx < source.width, sy < source.height else { compatible = false; break }
                    let a = (sy * source.width + sx) * 4, b = a - 4, c = a - source.width * 4, d = c - 4
                    let t = (y * source.width + x) * 4
                    for channel in 0..<3 {
                        let aa = Double(source.bytes[a + channel]), bb = Double(source.bytes[b + channel])
                        let cc = Double(source.bytes[c + channel]), dd = Double(source.bytes[d + channel])
                        let base = aa * (1 - v) + cc * v
                        let gradient = (bb - aa) * (1 - v) + (dd - cc) * v
                        let observed = Double(output[t + channel])
                        if abs(gradient) < 0.000000001 {
                            if abs(base - observed) > 0.500000001 { compatible = false; break }
                        } else {
                            let l = (observed - 0.5 - base) / gradient
                            let h = (observed + 0.5 - base) / gradient
                            lower = max(lower, min(l, h)); upper = min(upper, max(l, h))
                            if lower > upper + 0.000000001 { compatible = false; break }
                        }
                    }
                    if !compatible { break }
                }
                guard compatible, lower <= upper + 0.000000001 else { continue }
                let y = Double(dy) + v
                let p0 = (Double(dx) + lower) * anchor.direction.x + y * anchor.direction.y
                let p1 = (Double(dx) + upper) * anchor.direction.x + y * anchor.direction.y
                lowerProjection = min(lowerProjection, min(p0, p1))
                upperProjection = max(upperProjection, max(p0, p1)); count += 1
            }
        } }
        if count > 0 {
            let uncertainty = max(0, (upperProjection - lowerProjection) * 0.5)
            let value = uncertainty <= 0.1 ? (lowerProjection + upperProjection) * 0.5 : Double.nan
            return MatchEstimate(value: value, uncertainty: uncertainty, compatibleCount: count,
                status: uncertainty <= 0.1 ? "source-compatible" : "source-compatible-inconclusive")
        }
        let leastSquares = forwardLeastSquares(anchor, source: source, output: output, refineFractions: true)
        return MatchEstimate(value: leastSquares, uncertainty: Double.greatestFiniteMagnitude, compatibleCount: 0,
            status: leastSquares.isFinite ? "local-model-residual" : "inconclusive")
    }

    /// Diagnostic alternative retaining the identical source-selected sample
    /// grid. Each displacement hypothesis reads its corresponding integer
    /// output window, while the prediction samples the original source within
    /// a centered half-pixel residual. Thus the source material, rather than
    /// a stationary output window that loses that material, owns the template.
    /// Neither source points nor search bounds are selected from candidate data.
    private func quantizedTrackedMatch(_ anchor: Anchor, source: Layer, output: [UInt8]) -> MatchEstimate {
        if output == source.bytes {
            return MatchEstimate(value: 0, uncertainty: 0, compatibleCount: 1, status: "whole-raster-identity")
        }
        // Continuous fractions require a conservative two-dimensional bound;
        // a fixed phase grid can miss a valid quantized interval entirely.
        if let exact = trackedContinuousCompatibleEstimate(anchor, source: source, output: output) { return exact }
        guard let candidate = trackedLeastSquaresCandidate(anchor, source: source, output: output) else {
            return MatchEstimate(value: .nan, uncertainty: .greatestFiniteMagnitude, compatibleCount: 0, status: "inconclusive")
        }
        let diagnostics = trackedResidualDiagnostics(anchor, candidate: candidate, source: source, output: output)
        let staticAlias = diagnostics["sourceWindowChangedPixels"] as? Int == 0
            && (diagnostics["templateRoundedMismatchChannels"] as? Int ?? 0) > 0
        // A residual optimum is diagnostic only. In particular, a static
        // neighboring window cannot prove motion of the target source patch.
        // Other nonuniform fits also lack the exact qualification established
        // by the source controls; no finite effect direction is inferred.
        return MatchEstimate(value: .nan, uncertainty: .greatestFiniteMagnitude, compatibleCount: 0,
            status: staticAlias ? "inconclusive-static-output-window-alias" : "inconclusive-nonuniform-fit-unqualified",
            diagnostics: diagnostics)
    }

    private struct FractionRectangle {
        let u0: Double
        let u1: Double
        let v0: Double
        let v1: Double
    }

    private struct BilinearFractionModel {
        let horizontalSide: Int
        let verticalSide: Int
        let coefficients: [SIMD4<Double>]
    }

    private struct WitnessRectangle {
        let integerX: Int
        let integerY: Int
        let modelOrdinal: Int
        let rectangle: FractionRectangle
    }

    /// For each integer output window and each of its four centered residual
    /// cells, bilinear predictions attain their extrema at rectangle corners.
    /// Per-byte interval separation therefore proves a rectangle impossible.
    /// The projected union includes every remaining rectangle, so its bounds
    /// conservatively include the whole continuous compatible set. A verified
    /// materialized-byte witness is also required before reporting precision.
    private func trackedContinuousCompatibleEstimate(_ anchor: Anchor, source: Layer, output: [UInt8]) -> MatchEstimate? {
        let cx = Int(anchor.point.x.rounded()), cy = Int(anchor.point.y.rounded())
        let samples = (-4...4).flatMap { y in (-4...4).map { x in
            (cx + x * anchor.sampling, cy + y * anchor.sampling)
        } }
        var models: [BilinearFractionModel] = []
        for verticalSide in [-1, 1] { for horizontalSide in [-1, 1] {
            var coefficients: [SIMD4<Double>] = []
            for (x, y) in samples {
                guard x >= 1, y >= 1, x + 1 < source.width, y + 1 < source.height else {
                    return MatchEstimate(value: .nan, uncertainty: .greatestFiniteMagnitude,
                        compatibleCount: 0, status: "continuous-source-footprint-inconclusive")
                }
                let a = (y * source.width + x) * 4
                let b = a - horizontalSide * 4, c = a - verticalSide * source.width * 4
                let d = c - horizontalSide * 4
                for channel in 0..<3 {
                    let aa = Double(source.bytes[a + channel]), bb = Double(source.bytes[b + channel])
                    let cc = Double(source.bytes[c + channel]), dd = Double(source.bytes[d + channel])
                    coefficients.append(SIMD4(aa, bb - aa, cc - aa, dd - bb - cc + aa))
                }
            }
            models.append(BilinearFractionModel(horizontalSide: horizontalSide,
                verticalSide: verticalSide, coefficients: coefficients))
        } }
        func prediction(_ q: SIMD4<Double>, _ u: Double, _ v: Double) -> Double {
            q.x + q.y * u + q.z * v + q.w * u * v
        }
        func rectangleState(_ rectangle: FractionRectangle, _ model: BilinearFractionModel,
                            _ observed: [Double]) -> Int {
            var whollyCompatible = true
            for i in observed.indices {
                let q = model.coefficients[i]
                let p00 = prediction(q, rectangle.u0, rectangle.v0), p10 = prediction(q, rectangle.u1, rectangle.v0)
                let p01 = prediction(q, rectangle.u0, rectangle.v1), p11 = prediction(q, rectangle.u1, rectangle.v1)
                let lower = min(min(p00, p10), min(p01, p11)), upper = max(max(p00, p10), max(p01, p11))
                let codeLower = observed[i] - 0.5, codeUpper = observed[i] + 0.5
                if lower > codeUpper + 0.000000001 || upper < codeLower - 0.000000001 { return -1 }
                if lower < codeLower || upper >= codeUpper { whollyCompatible = false }
            }
            return whollyCompatible ? 1 : 0
        }
        func isWitness(_ u: Double, _ v: Double, _ model: BilinearFractionModel, _ observed: [Double]) -> Bool {
            model.coefficients.indices.allSatisfy { prediction(model.coefficients[$0], u, v).rounded() == observed[$0] }
        }
        var lowerProjection = Double.infinity, upperProjection = -Double.infinity, count = 0, witnesses = 0
        var witnessRectangles: [WitnessRectangle] = []
        var examined = 0
        // Bound computation must complete over every original hypothesis.
        // Exhaustion is explicitly inconclusive, never a narrowed search box.
        let maximumRectangles = 1_000_000
        for dy in -anchor.search...anchor.search { for dx in -anchor.search...anchor.search {
            var observed: [Double] = [], valid = true
            for (x, y) in samples {
                let ox = x + dx, oy = y + dy
                guard ox >= 0, oy >= 0, ox < source.width, oy < source.height else { valid = false; break }
                let t = (oy * source.width + ox) * 4
                for channel in 0..<3 { observed.append(Double(output[t + channel])) }
            }
            guard valid else { continue }
            for (modelOrdinal, model) in models.enumerated() {
                let maximumU = (dx == -anchor.search && model.horizontalSide < 0)
                    || (dx == anchor.search && model.horizontalSide > 0) ? 0.0 : 0.5
                let maximumV = (dy == -anchor.search && model.verticalSide < 0)
                    || (dy == anchor.search && model.verticalSide > 0) ? 0.0 : 0.5
                var pending = [FractionRectangle(u0: 0, u1: maximumU, v0: 0, v1: maximumV)]
                while let rectangle = pending.popLast() {
                    examined += 1
                    guard examined <= maximumRectangles else {
                        return MatchEstimate(value: .nan, uncertainty: .greatestFiniteMagnitude,
                            compatibleCount: count, status: "continuous-bound-resource-inconclusive", witnessCount: witnesses)
                    }
                    let state = rectangleState(rectangle, model, observed)
                    if state < 0 { continue }
                    let uWidth = rectangle.u1 - rectangle.u0, vWidth = rectangle.v1 - rectangle.v0
                    let projectedWidth = abs(anchor.direction.x) * uWidth + abs(anchor.direction.y) * vWidth
                    // A wholly compatible rectangle is already an exact set:
                    // splitting it cannot tighten its union bounds. Partially
                    // feasible rectangles use <=.005px projected and fraction
                    // widths; retained outer bounds never imply a witness.
                    if state > 0 || (projectedWidth <= 0.005 && max(uWidth, vWidth) <= 0.005) {
                        let x0 = (Double(dx) + Double(model.horizontalSide) * rectangle.u0) * anchor.direction.x
                        let x1 = (Double(dx) + Double(model.horizontalSide) * rectangle.u1) * anchor.direction.x
                        let y0 = (Double(dy) + Double(model.verticalSide) * rectangle.v0) * anchor.direction.y
                        let y1 = (Double(dy) + Double(model.verticalSide) * rectangle.v1) * anchor.direction.y
                        lowerProjection = min(lowerProjection, min(x0, x1) + min(y0, y1))
                        upperProjection = max(upperProjection, max(x0, x1) + max(y0, y1)); count += 1
                        let us = [rectangle.u0, (rectangle.u0 + rectangle.u1) * 0.5, rectangle.u1]
                        let vs = [rectangle.v0, (rectangle.v0 + rectangle.v1) * 0.5, rectangle.v1]
                        if us.contains(where: { u in vs.contains { isWitness(u, $0, model, observed) } }) { witnesses += 1 }
                        else { witnessRectangles.append(WitnessRectangle(integerX: dx, integerY: dy,
                            modelOrdinal: modelOrdinal, rectangle: rectangle)) }
                        continue
                    }
                    if uWidth >= vWidth {
                        let middle = (rectangle.u0 + rectangle.u1) * 0.5
                        pending.append(FractionRectangle(u0: rectangle.u0, u1: middle, v0: rectangle.v0, v1: rectangle.v1))
                        pending.append(FractionRectangle(u0: middle, u1: rectangle.u1, v0: rectangle.v0, v1: rectangle.v1))
                    } else {
                        let middle = (rectangle.v0 + rectangle.v1) * 0.5
                        pending.append(FractionRectangle(u0: rectangle.u0, u1: rectangle.u1, v0: rectangle.v0, v1: middle))
                        pending.append(FractionRectangle(u0: rectangle.u0, u1: rectangle.u1, v0: middle, v1: rectangle.v1))
                    }
                }
            }
        } }
        guard count > 0 else { return nil }
        let uncertainty = max(0, (upperProjection - lowerProjection) * 0.5)
        if witnesses == 0 && uncertainty <= 0.1 {
            // A continuous least-squares fit is only a proposed witness. All
            // 243 rounded bytes are checked in its original integer window;
            // fitting error alone cannot establish quantized compatibility.
            if let candidate = trackedLeastSquaresCandidate(anchor, source: source, output: output),
               let model = models.first(where: { $0.horizontalSide == candidate.sides.x && $0.verticalSide == candidate.sides.y }) {
                let observed = samples.flatMap { x, y -> [Double] in
                    let t = ((y + candidate.integerShift.y) * source.width + x + candidate.integerShift.x) * 4
                    return (0..<3).map { Double(output[t + $0]) }
                }
                if isWitness(candidate.fractions.x, candidate.fractions.y, model, observed) { witnesses = 1 }
            }
            // .005px is the conservative bound resolution, not a stopping
            // rule for existence. A narrow 243-channel feasible set may need
            // much finer witness search inside already retained rectangles.
            witnessSearch: for region in witnessRectangles where witnesses == 0 {
                let model = models[region.modelOrdinal]
                let observed = samples.flatMap { x, y -> [Double] in
                    let t = ((y + region.integerY) * source.width + x + region.integerX) * 4
                    return (0..<3).map { Double(output[t + $0]) }
                }
                var pending = [region.rectangle]
                while let rectangle = pending.popLast() {
                    examined += 1
                    guard examined <= maximumRectangles else {
                        return MatchEstimate(value: .nan, uncertainty: uncertainty, compatibleCount: count,
                            status: "continuous-witness-resource-inconclusive", witnessCount: witnesses)
                    }
                    if rectangleState(rectangle, model, observed) < 0 { continue }
                    let middleU = (rectangle.u0 + rectangle.u1) * 0.5, middleV = (rectangle.v0 + rectangle.v1) * 0.5
                    if isWitness(middleU, middleV, model, observed) { witnesses = 1; break witnessSearch }
                    let uWidth = rectangle.u1 - rectangle.u0, vWidth = rectangle.v1 - rectangle.v0
                    if max(uWidth, vWidth) <= 0.000001 { continue }
                    if uWidth >= vWidth {
                        pending.append(FractionRectangle(u0: rectangle.u0, u1: middleU, v0: rectangle.v0, v1: rectangle.v1))
                        pending.append(FractionRectangle(u0: middleU, u1: rectangle.u1, v0: rectangle.v0, v1: rectangle.v1))
                    } else {
                        pending.append(FractionRectangle(u0: rectangle.u0, u1: rectangle.u1, v0: rectangle.v0, v1: middleV))
                        pending.append(FractionRectangle(u0: rectangle.u0, u1: rectangle.u1, v0: middleV, v1: rectangle.v1))
                    }
                }
            }
        }
        let precise = witnesses > 0 && uncertainty <= 0.1
        return MatchEstimate(value: precise ? (lowerProjection + upperProjection) * 0.5 : .nan,
            uncertainty: uncertainty, compatibleCount: count,
            status: precise ? "source-compatible-continuous" : "continuous-compatible-outer-bound-inconclusive", witnessCount: witnesses)
    }

    /// Continuous bilinear forward prediction from the same source-owned
    /// sample grid and integer output window as the quantized estimator.
    /// Every original integer hypothesis and centered residual cell is checked.
    /// Multiple fixed starts with alternating analytic x/y minima remove the
    /// phase grid from the nonuniform photographic least-squares fallback.
    private func trackedForwardLeastSquares(_ anchor: Anchor, source: Layer, output: [UInt8]) -> Double {
        guard let candidate = trackedLeastSquaresCandidate(anchor, source: source, output: output) else { return .nan }
        return candidate.displacement.x * anchor.direction.x + candidate.displacement.y * anchor.direction.y
    }

    private struct TrackedLeastSquaresCandidate {
        let displacement: SIMD2<Double>
        let integerShift: SIMD2<Int>
        let sides: SIMD2<Int>
        let fractions: SIMD2<Double>
        let fitCost: Double
    }

    private func trackedResidualDiagnostics(_ anchor: Anchor, candidate: TrackedLeastSquaresCandidate,
                                             source: Layer, output: [UInt8]) -> [String: Any] {
        let cx = Int(anchor.point.x.rounded()), cy = Int(anchor.point.y.rounded())
        var changedPixels = 0, mismatch = 0, maximum = 0.0
        for py in -4...4 { for px in -4...4 {
            let x = cx + px * anchor.sampling, y = cy + py * anchor.sampling
            let a = (y * source.width + x) * 4
            let b = a - candidate.sides.x * 4, c = a - candidate.sides.y * source.width * 4
            let d = c - candidate.sides.x * 4
            let t = ((y + candidate.integerShift.y) * source.width + x + candidate.integerShift.x) * 4
            var changed = false
            for channel in 0..<3 {
                let aa = Double(source.bytes[a + channel]), bb = Double(source.bytes[b + channel])
                let cc = Double(source.bytes[c + channel]), dd = Double(source.bytes[d + channel])
                let u = candidate.fractions.x, v = candidate.fractions.y
                let prediction = aa + (bb - aa) * u + (cc - aa) * v + (dd - bb - cc + aa) * u * v
                let observed = Double(output[t + channel])
                if prediction.rounded() != observed { mismatch += 1 }
                maximum = max(maximum, abs(prediction - observed))
                changed = changed || source.bytes[t + channel] != output[t + channel]
            }
            if changed { changedPixels += 1 }
        } }
        return ["diagnosticAxisPixels": candidate.displacement.x * anchor.direction.x + candidate.displacement.y * anchor.direction.y,
            "rmsByteResidual": sqrt(max(0, candidate.fitCost) / 243), "maximumByteResidual": maximum,
            "templateRoundedMismatchChannels": mismatch, "sourceWindowChangedPixels": changedPixels,
            "sourceWindowSampleCount": 81, "directionQualificationProved": false]
    }

    private func trackedLeastSquaresCandidate(_ anchor: Anchor, source: Layer, output: [UInt8]) -> TrackedLeastSquaresCandidate? {
        let cx = Int(anchor.point.x.rounded()), cy = Int(anchor.point.y.rounded())
        let samples = (-4...4).flatMap { y in (-4...4).map { x in
            (cx + x * anchor.sampling, cy + y * anchor.sampling)
        } }
        var bestError = Double.infinity, best = SIMD2<Double>.zero, bestInformation = 0.0
        var bestCandidate: TrackedLeastSquaresCandidate?
        for dy in -anchor.search...anchor.search { for dx in -anchor.search...anchor.search {
            for verticalSide in [-1, 1] { for horizontalSide in [-1, 1] {
                let maximumU = (dx == -anchor.search && horizontalSide < 0)
                    || (dx == anchor.search && horizontalSide > 0) ? 0.0 : 0.5
                let maximumV = (dy == -anchor.search && verticalSide < 0)
                    || (dy == anchor.search && verticalSide > 0) ? 0.0 : 0.5
                var dd = 0.0, db = 0.0, dc = 0.0, de = 0.0
                var bb = 0.0, cc = 0.0, ee = 0.0, bc = 0.0, be = 0.0, ce = 0.0
                var valid = true
                for (x, y) in samples {
                    let ox = x + dx, oy = y + dy
                    guard x >= 1, y >= 1, x + 1 < source.width, y + 1 < source.height,
                          ox >= 0, oy >= 0, ox < source.width, oy < source.height else { valid = false; break }
                    let a = (y * source.width + x) * 4
                    let b = a - horizontalSide * 4, c = a - verticalSide * source.width * 4
                    let d = c - horizontalSide * 4, target = (oy * source.width + ox) * 4
                    for channel in 0..<3 {
                        let aa = Double(source.bytes[a + channel]), bx = Double(source.bytes[b + channel]) - aa
                        let cy = Double(source.bytes[c + channel]) - aa
                        let joint = Double(source.bytes[d + channel]) - Double(source.bytes[b + channel])
                            - Double(source.bytes[c + channel]) + aa
                        let residual = aa - Double(output[target + channel])
                        dd += residual * residual; db += residual * bx; dc += residual * cy; de += residual * joint
                        bb += bx * bx; cc += cy * cy; ee += joint * joint
                        bc += bx * cy; be += bx * joint; ce += cy * joint
                    }
                }
                guard valid else { continue }
                for phase in 0...8 {
                    var v = maximumV * Double(phase) / 8, u = 0.0
                    for _ in 0..<16 {
                        let gx = bb + 2 * v * be + v * v * ee
                        u = gx > 0.000001 ? max(0, min(maximumU, -(db + v * de + v * bc + v * v * ce) / gx)) : 0
                        let gy = cc + 2 * u * ce + u * u * ee
                        v = gy > 0.000001 ? max(0, min(maximumV, -(dc + u * de + u * bc + u * u * be) / gy)) : 0
                    }
                    let gx = bb + 2 * v * be + v * v * ee
                    u = gx > 0.000001 ? max(0, min(maximumU, -(db + v * de + v * bc + v * v * ce) / gx)) : 0
                    let cost = max(0, dd + 2 * u * db + 2 * v * dc + 2 * u * v * de
                        + u * u * bb + v * v * cc + u * u * v * v * ee + 2 * u * v * bc
                        + 2 * u * u * v * be + 2 * u * v * v * ce)
                    let candidate = SIMD2(Double(dx) + Double(horizontalSide) * u, Double(dy) + Double(verticalSide) * v)
                    let length = candidate.x * candidate.x + candidate.y * candidate.y
                    let oldLength = best.x * best.x + best.y * best.y
                    if cost < bestError - 0.00000001 || (abs(cost - bestError) <= 0.00000001 && length < oldLength) {
                        bestError = cost; best = candidate
                        bestCandidate = TrackedLeastSquaresCandidate(displacement: candidate,
                            integerShift: SIMD2(dx, dy), sides: SIMD2(horizontalSide, verticalSide), fractions: SIMD2(u, v), fitCost: cost)
                        let fxx = gx, fyy = cc + 2 * u * ce + u * u * ee
                        let fxy = Double(horizontalSide * verticalSide) * (bc + u * be + v * ce + u * v * ee)
                        let n = anchor.direction
                        bestInformation = n.x * n.x * fxx + 2 * n.x * n.y * fxy + n.y * n.y * fyy
                    }
                }
            } }
        } }
        guard bestError.isFinite, bestInformation > 0.000001 else { return nil }
        return bestCandidate
    }

    private func trackedCompatibleEstimate(_ anchor: Anchor, source: Layer, output: [UInt8]) -> MatchEstimate? {
        let cx = Int(anchor.point.x.rounded()), cy = Int(anchor.point.y.rounded())
        let samples = (-4...4).flatMap { y in (-4...4).map { x in
            (cx + x * anchor.sampling, cy + y * anchor.sampling)
        } }
        var lowerProjection = Double.infinity, upperProjection = -Double.infinity, count = 0
        for dy in -anchor.search...anchor.search { for dx in -anchor.search...anchor.search {
            for phase in -8...8 {
                let v = Double(phase) / 16
                if (dy == -anchor.search && v < 0) || (dy == anchor.search && v > 0) { continue }
                let verticalSide = v < 0 ? -1 : 1, weight = abs(v)
                for horizontalSide in [-1, 1] {
                    var lower = 0.0
                    var upper = (dx == -anchor.search && horizontalSide < 0)
                        || (dx == anchor.search && horizontalSide > 0) ? 0.0 : 0.5
                    var compatible = true
                    for (x, y) in samples {
                        let ox = x + dx, oy = y + dy
                        guard x >= 1, y >= 1, x + 1 < source.width, y + 1 < source.height,
                              ox >= 0, oy >= 0, ox < source.width, oy < source.height else { compatible = false; break }
                        let a = (y * source.width + x) * 4
                        let b = a - horizontalSide * 4, c = a - verticalSide * source.width * 4
                        let d = c - horizontalSide * 4, t = (oy * source.width + ox) * 4
                        for channel in 0..<3 {
                            let aa = Double(source.bytes[a + channel]), bb = Double(source.bytes[b + channel])
                            let cc = Double(source.bytes[c + channel]), de = Double(source.bytes[d + channel])
                            let base = aa * (1 - weight) + cc * weight
                            let gradient = (bb - aa) * (1 - weight) + (de - cc) * weight
                            let observed = Double(output[t + channel])
                            if abs(gradient) < 0.000000001 {
                                if abs(base - observed) > 0.500000001 { compatible = false; break }
                            } else {
                                let l = (observed - 0.5 - base) / gradient
                                let h = (observed + 0.5 - base) / gradient
                                lower = max(lower, min(l, h)); upper = min(upper, max(l, h))
                                if lower > upper + 0.000000001 { compatible = false; break }
                            }
                        }
                        if !compatible { break }
                    }
                    guard compatible, lower <= upper + 0.000000001 else { continue }
                    let p0 = (Double(dx) + Double(horizontalSide) * lower) * anchor.direction.x
                        + (Double(dy) + v) * anchor.direction.y
                    let p1 = (Double(dx) + Double(horizontalSide) * upper) * anchor.direction.x
                        + (Double(dy) + v) * anchor.direction.y
                    lowerProjection = min(lowerProjection, min(p0, p1))
                    upperProjection = max(upperProjection, max(p0, p1)); count += 1
                }
            }
        } }
        guard count > 0 else { return nil }
        let uncertainty = max(0, (upperProjection - lowerProjection) * 0.5)
        return MatchEstimate(value: uncertainty <= 0.1 ? (lowerProjection + upperProjection) * 0.5 : Double.nan,
            uncertainty: uncertainty, compatibleCount: count,
            status: uncertainty <= 0.1 ? "source-compatible-tracked" : "source-compatible-tracked-inconclusive")
    }

    /// Compare fixed output samples with a forward bilinear prediction from
    /// the original source. Every integer cell in the original search box is
    /// considered. The optional alternating continuous fractions are used by
    /// the fallback, retaining the same source grid and displacement bounds.
    private func forwardLeastSquares(_ anchor: Anchor, source: Layer, output: [UInt8], refineFractions: Bool = false) -> Double {
        let cx = Int(anchor.point.x.rounded()), cy = Int(anchor.point.y.rounded())
        let samples = (-4...4).flatMap { y in (-4...4).map { x in
            (cx + x * anchor.sampling, cy + y * anchor.sampling)
        } }
        var bestError = Double.infinity, best = SIMD2<Double>.zero
        var bestGradient = 0.0
        for dy in -anchor.search...anchor.search { for dx in -anchor.search...anchor.search {
            var dd = 0.0, db = 0.0, dc = 0.0, de = 0.0
            var bb = 0.0, cc = 0.0, ee = 0.0, bc = 0.0, be = 0.0, ce = 0.0
            var valid = true
            for (x, y) in samples {
                let sx = x - dx, sy = y - dy
                guard x >= 0, y >= 0, x < source.width, y < source.height,
                      sx >= 1, sy >= 1, sx < source.width, sy < source.height else { valid = false; break }
                let a = (sy * source.width + sx) * 4
                let b = a - 4, c = a - source.width * 4, d = c - 4
                let t = (y * source.width + x) * 4
                for channel in 0..<3 {
                    let original = Double(source.bytes[a + channel])
                    let residual = original - Double(output[t + channel])
                    let horizontal = Double(source.bytes[b + channel]) - original
                    let vertical = Double(source.bytes[c + channel]) - original
                    let joint = Double(source.bytes[d + channel]) - Double(source.bytes[b + channel])
                        - Double(source.bytes[c + channel]) + original
                    dd += residual * residual; db += residual * horizontal
                    dc += residual * vertical; de += residual * joint
                    bb += horizontal * horizontal; cc += vertical * vertical; ee += joint * joint
                    bc += horizontal * vertical; be += horizontal * joint; ce += vertical * joint
                }
            }
            guard valid else { continue }
            for phase in 0...(dy == anchor.search ? 0 : 8) {
                var v = Double(phase) / 8
                func horizontal(_ v: Double) -> Double {
                    let gr = db + v * (de + bc) + v * v * ce
                    let gg = bb + 2 * v * be + v * v * ee
                    return dx == anchor.search || gg < 0.000001 ? 0 : max(0, min(1, -gr / gg))
                }
                var u = horizontal(v)
                if refineFractions {
                    for _ in 0..<8 {
                        let grY = dc + u * (de + bc) + u * u * be
                        let ggY = cc + 2 * u * ce + u * u * ee
                        v = dy == anchor.search || ggY < 0.000001 ? 0 : max(0, min(1, -grY / ggY))
                        u = horizontal(v)
                    }
                }
                let vv = v * v, gr = db + v * (de + bc) + vv * ce
                let gg = bb + 2 * v * be + vv * ee, rr = dd + 2 * v * dc + vv * cc
                let error = max(0, rr + 2 * u * gr + u * u * gg)
                let candidate = SIMD2(Double(dx) + u, Double(dy) + v)
                let length2 = candidate.x * candidate.x + candidate.y * candidate.y
                let bestLength2 = best.x * best.x + best.y * best.y
                if error < bestError - 0.00000001 || (abs(error - bestError) <= 0.00000001 && length2 < bestLength2) {
                    bestError = error; best = candidate
                    bestGradient = gg + cc + 2 * u * ce + u * u * ee
                }
            }
        } }
        guard bestError.isFinite, bestGradient > 0.000001 else { return .nan }
        return best.x * anchor.direction.x + best.y * anchor.direction.y
    }

    /// Retained only for source-only counterexample diagnostics. Photograph
    /// acceptance uses the forward estimator above; old failures retain their
    /// recorded meaning and are not rewritten by this measurement repair.
    private func legacyMatch(_ anchor: Anchor, source: Layer, output: [UInt8], exhaustive: Bool = false) -> Double {
        func error(_ dx: Int, _ dy: Int) -> Double {
            var total = 0.0, count = 0
            let cx = Int(anchor.point.x.rounded()), cy = Int(anchor.point.y.rounded())
            for py in -4...4 { for px in -4...4 {
                let x = cx + px * anchor.sampling, y = cy + py * anchor.sampling
                let xx = x + dx, yy = y + dy
                guard min(x, xx) >= 0, min(y, yy) >= 0,
                      max(x, xx) < source.width, max(y, yy) < source.height else { return .infinity }
                let a = (y * source.width + x) * 4, b = (yy * source.width + xx) * 4
                for c in 0..<3 { let d = Double(source.bytes[a + c]) - Double(output[b + c]); total += d * d; count += 1 }
            } }
            return total / Double(count)
        }
        var bestX = 0, bestY = 0, bestError = error(0, 0)
        let coarse = max(1, anchor.search / 12)
        let step = exhaustive ? 1 : coarse
        for dy in stride(from: -anchor.search, through: anchor.search, by: step) {
            for dx in stride(from: -anchor.search, through: anchor.search, by: step) {
                let value = error(dx, dy)
                if value < bestError { bestError = value; bestX = dx; bestY = dy }
            }
        }
        let baseX = bestX, baseY = bestY
        for dy in (baseY - coarse)...(baseY + coarse) { for dx in (baseX - coarse)...(baseX + coarse) {
            let value = error(dx, dy)
            if value < bestError { bestError = value; bestX = dx; bestY = dy }
        } }
        func subpixel(_ lower: Double, _ middle: Double, _ upper: Double) -> Double {
            let denominator = lower - 2 * middle + upper
            return denominator > 0.0001 ? max(-0.5, min(0.5, 0.5 * (lower - upper) / denominator)) : 0
        }
        let x = Double(bestX) + subpixel(error(bestX - 1, bestY), bestError, error(bestX + 1, bestY))
        let y = Double(bestY) + subpixel(error(bestX, bestY - 1), bestError, error(bestX, bestY + 1))
        return x * anchor.direction.x + y * anchor.direction.y
    }

    private func knownLocalTranslation(_ source: Layer, anchor: Anchor,
                                       delta: SIMD2<Double>, domains: SourceDomains) -> [UInt8] {
        var output = source.bytes
        let radius = Double(4 * anchor.sampling) + max(abs(delta.x), abs(delta.y)) + 3
        let x0 = max(0, Int(floor(anchor.point.x - radius))), x1 = min(source.width - 1, Int(ceil(anchor.point.x + radius)))
        let y0 = max(0, Int(floor(anchor.point.y - radius))), y1 = min(source.height - 1, Int(ceil(anchor.point.y + radius)))
        for y in y0...y1 { for x in x0...x1 {
            let p = y * source.width + x
            guard domains.target[p], !domains.features[p] else { continue }
            let sx = Double(x) - delta.x, sy = Double(y) - delta.y
            let ix = Int(floor(sx)), iy = Int(floor(sy))
            guard ix >= 0, iy >= 0, ix + 1 < source.width, iy + 1 < source.height else { continue }
            let fx = sx - Double(ix), fy = sy - Double(iy)
            let footprints = [iy * source.width + ix, iy * source.width + ix + 1,
                (iy + 1) * source.width + ix, (iy + 1) * source.width + ix + 1]
            guard footprints.allSatisfy({ domains.target[$0] && !domains.features[$0] }) else { continue }
            for c in 0..<3 {
                let samples = footprints.map { Double(source.bytes[$0 * 4 + c]) }
                let value = samples[0] * (1 - fx) * (1 - fy) + samples[1] * fx * (1 - fy)
                    + samples[2] * (1 - fx) * fy + samples[3] * fx * fy
                output[p * 4 + c] = UInt8(max(0, min(255, value.rounded())))
            }
        } }
        return output
    }

    private func assertMetadata(_ result: BeautyResult<CIImage>, layer: Layer, logicalID: String) {
        XCTAssertEqual(result.output.extent, layer.image.extent, logicalID)
        XCTAssertEqual(result.output.colorSpace?.name, colorSpace.name, logicalID)
        XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1, logicalID)
    }

    private func outputDirectory() throws -> URL {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_OUTPUT"] else { throw CheckError.invalidOutput }
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let allowed = package.appendingPathComponent(".build/face-reference", isDirectory: true).standardizedFileURL
        let output = URL(fileURLWithPath: path, isDirectory: true).standardizedFileURL
        guard output.path.hasPrefix(allowed.path + "/"), output.resolvingSymlinksInPath().path == output.path else {
            throw CheckError.invalidOutput
        }
        do { try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true) }
        catch { throw CheckError.writeFailed }
        return output
    }

    /// Explicitly opted-in, owner-local IPC for a subsequent registered
    /// competitor comparison. Raw source points never enter aggregate
    /// receipts. outputDirectory restricts these files to the ignored tree.
    private func saveLocalSourceAnchors(_ anchors: [BeautyFaceShapeSlider: [Anchor]],
                                       layer: Layer, to output: URL) throws {
        let url = output.appendingPathComponent("local-only-\(layer.id)-source-texture-anchors.json")
        guard !FileManager.default.fileExists(atPath: url.path) else { throw CheckError.invalidOutput }
        let records = mainControls.flatMap { control in
            anchors[control]!.enumerated().map { ordinal, anchor -> [String: Any] in
                ["control": control.rawValue, "anchorOrdinal": ordinal,
                 "point": [anchor.point.x, anchor.point.y], "direction": [anchor.direction.x, anchor.direction.y],
                 "sampling": anchor.sampling, "search": anchor.search]
            }
        }
        let value: [String: Any] = ["localOnly": true, "containsRawSourceDerivedPoints": true,
            "coordinateSystem": "canonical-ci-rgba8-row", "width": layer.width, "height": layer.height,
            "oracleVersion": "directional-v2-qualified-tracked", "sourceSampleGrid": "9x9", "records": records]
        do { try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .prettyPrinted]).write(to: url) }
        catch { throw CheckError.writeFailed }
    }

    private func save(_ image: CIImage, name: String, to output: URL) throws {
        let url = output.appendingPathComponent(name + ".png")
        guard !FileManager.default.fileExists(atPath: url.path) else { throw CheckError.invalidOutput }
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        guard let cg = context.createCGImage(image, from: image.extent, format: .RGBA8, colorSpace: colorSpace),
              let destination = CGImageDestinationCreateWithURL(url as CFURL,
                "public.png" as CFString, 1, nil) else { throw CheckError.encodingFailed }
        CGImageDestinationAddImage(destination, cg, nil)
        guard CGImageDestinationFinalize(destination) else { throw CheckError.encodingFailed }
    }

    private func receipt(_ records: [[String: Any]], name: String, to output: URL, oracleVersion: String? = nil) throws {
        let url = output.appendingPathComponent(name)
        guard !FileManager.default.fileExists(atPath: url.path) else { throw CheckError.invalidOutput }
        let value: [String: Any] = ["schema": "beauty.face-reference.v1", "sourceCount": 1,
            "oracleVersion": oracleVersion ?? ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_ORACLE_VERSION"] ?? "variance-v1",
            "sourceSupport": "production-source-only", "rasterLayers": ["full", "preview960"],
            "semanticProtectionMask": ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_PROTECTION"] != nil,
            "fullSDKRegression": false, "appearanceParity": false, "records": records]
        do { try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .prettyPrinted])
            .write(to: url, options: .atomic) }
        catch { throw CheckError.writeFailed }
    }

    private func generatedNoFaceSafety(recovery: Bool) throws {
        let width = 64, height = 80
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for p in 0..<(width * height) { bytes[p * 4] = UInt8(p % width); bytes[p * 4 + 1] = UInt8(p / width); bytes[p * 4 + 2] = 128 }
        let image = CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: colorSpace)
        let layer = Layer(id: "generated-no-face", image: image, width: width, height: height, bytes: bytes)
        let engine = try BeautyEngine(configuration: .init(enableFaceTracking: false))
        for control in BeautyFaceShapeSlider.allCases {
            let neutral = try engine.processResult(image: image, metadata: metadata, parameters: .init())
            XCTAssertTrue(try pixels(neutral.output, layer: layer) == bytes, "generated neutral")
            let result = try engine.processResult(image: image, metadata: metadata,
                parameters: control.applying(position: 1, to: .init()))
            XCTAssertTrue(try pixels(result.output, layer: layer) == bytes, "generated no-face \(control.rawValue)")
            XCTAssertEqual(result.detectionSummary?.availability, .disabled)
        }
        if recovery {
            XCTAssertThrowsError(try engine.processResult(image: CIImage.empty(), metadata: metadata, parameters: .init())) { error in
                XCTAssertTrue(error is BeautyError, "typed failure")
            }
            let recovered = try engine.processResult(image: image, metadata: metadata, parameters: .init())
            XCTAssertTrue(try pixels(recovered.output, layer: layer) == bytes, "generated recovery")
        }
    }
}
