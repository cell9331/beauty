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

/// Hairline-only owner-local validation. The frozen source annotation defines
/// permission; RGB prototypes observe an edge and never classify skin or hair.
/// No production hairline curve is consulted by the independent observer.
final class BeautyEngineHairlinePhotoPolicyTests: XCTestCase {
    private enum Failure: Error { case input, source, output }
    private enum ObserverVersion: String {
        case sparseV1 = "sparse-source-bank-v1"
        case denseV2 = "dense-source-bank-v2"
    }
    private enum SourcePolicyVersion: String {
        case strictDisjointV1 = "strict-disjoint-v1"
        case subtractPermanentV3 = "subtract-permanent-source-v3"
    }
    private let space = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
    private let sourceHash = "bd5fe998c2e49b0812a9bd881bbc4c345eb15c10445b16bc790ba7f40c4b2213"
    private let hashes = [
        "legal_hairline_band": "30a906016807a686f1f2a5f626051cc27d3c56fc95b4c693dfc1be27821e7443",
        "protected_hairline_union": "f6d4b487ab9aa9a733a12af764dfdbbef5ddf5c70d6930ac762ec7f15e7b90e6",
        "ears_core": "d8a609c613fdb6761e58886b8cf5d94e29af6c0fe74b26cf46286245cc477d1a",
        "eyes_core": "a8219b5a697f2feed1e3b3e4a33f0f49a777a60779d76f7aaba188125016f958",
        "brows_core": "99cea5696cba82870200beead7c6edbe32443e76bdf3a7796c5f89560dfa2e6e",
        "nose_core": "ad5258bf511fe2e553049d9e1c05307942269c1d94d52ebe0c2f580e2f186452",
        "lips_core": "cde38241edb193ba5eef0b856b5486900776fa9f2b3456d326536b638be6aa64",
        "hair_core": "23566188baca12ac9383890400191839abd6e2d56781ad02c2a5ef8b7edd844b",
        "crossing_hair_core": "25312aa75a324d863ccaef45fe1f564f7cb6e24c6e8c6f29004f303f17ba2202"
    ]
    private let translations: [Double] = [0, -0.25, 0.25, -0.5, 0.5, -1, 1, -2, 2, -4, 4]

    func testFrozenSourceHairlineObserverTranslationControlsBeforeCandidate() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try testGeneratedEdgeObserverRejectsWrongDirectionAndMultipleBoundaries()
            return
        }
        let output = try outputDirectory(), layers = try sourceLayers(input)
        var rows = [[String: Any]]()
        for layer in layers {
            let target = try mask("legal_hairline_band", layer)
            let selection = selectSourceProbes(layer, target: target)
            XCTAssertEqual(selection.probes.count, 3, "\(layer.id) all three predeclared source slots must calibrate")
            rows.append(["layer": layer.id, "sourceOnly": true, "SDKCandidateRead": false,
                "qualifiedSlotCount": selection.probes.count, "requiredSlotCount": 3,
                "testedSourceCandidateCount": selection.tested, "slots": selection.records])
        }
        try receipt(["schema": "hairline-source-edge-controls/v1", "records": rows,
            "maximumAllowedErrorSourcePixels": 0.1, "candidateSelectedPoints": false],
            name: "hairline-source-edge-controls.json", output: output)
    }

    /// V1's frozen three slots and candidate ranges stay unchanged. V2 tests
    /// every integer column in each original range, ordered only by distance
    /// from that source slot. No candidate output enters this selection.
    func testFrozenSourceHairlineObserverDenseV2TranslationControlsBeforeCandidate() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try testGeneratedEdgeObserverRejectsWrongDirectionAndMultipleBoundaries()
            return
        }
        let output = try outputDirectory(), layers = try sourceLayers(input)
        var rows = [[String: Any]]()
        for layer in layers {
            let target = try mask("legal_hairline_band", layer)
            let selection = selectSourceProbes(layer, target: target, version: .denseV2)
            XCTAssertEqual(selection.probes.count, 3, "\(layer.id) V2 all three original source slots must calibrate")
            rows.append(["layer": layer.id, "sourceOnly": true, "SDKCandidateRead": false,
                "observerVersion": ObserverVersion.denseV2.rawValue, "originalSlotAndRangeRetained": true,
                "qualifiedSlotCount": selection.probes.count, "requiredSlotCount": 3,
                "testedSourceCandidateCount": selection.tested, "slots": selection.records])
        }
        try receipt(["schema": "hairline-source-edge-controls/v2", "records": rows,
            "frozenV1ResultsReplaced": false, "maximumAllowedErrorSourcePixels": 0.1,
            "candidateSelectedPoints": false], name: "hairline-source-edge-controls-v2.json", output: output)
    }

    func testHairlinePhotoEndpointsQuartersAndPermanentSourceProtection() throws {
        guard let input = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try testGeneratedEdgeObserverRejectsWrongDirectionAndMultipleBoundaries()
            return
        }
        let output = try outputDirectory(), layers = try sourceLayers(input)
        let version: ObserverVersion
        if let requested = ProcessInfo.processInfo.environment["BEAUTY_HAIRLINE_ORACLE_VERSION"] {
            guard let parsed = ObserverVersion(rawValue: requested) else { throw Failure.input }
            version = parsed
        } else { version = .sparseV1 }
        let sourcePolicyVersion: SourcePolicyVersion
        if let requested = ProcessInfo.processInfo.environment["BEAUTY_HAIRLINE_SOURCE_POLICY_VERSION"] {
            guard let parsed = SourcePolicyVersion(rawValue: requested) else { throw Failure.input }
            sourcePolicyVersion = parsed
        } else { sourcePolicyVersion = .strictDisjointV1 }
        var rows = [[String: Any]]()
        let frozenSources = try layers.map { layer -> FrozenSource in
            // All masks, features, source slots and known controls precede
            // even the first candidate. Fine hair inside the old legal band
            // may transition; ears and complete features are never exempt.
            let target = try mask("legal_hairline_band", layer)
            let protected = try mask("protected_hairline_union", layer)
            let fine = try ["ears_core", "eyes_core", "brows_core", "nose_core", "lips_core", "hair_core", "crossing_hair_core"]
                .map { try mask($0, layer) }
            var detector = BeautyFaceDetector.production()
            let detected = detector.detect(image: layer.image, metadata: metadata,
                imageExtent: layer.image.extent.size, purpose: .geometryAndLocalSupport)
            XCTAssertEqual(detected.summary.availability, .usable)
            XCTAssertEqual(detected.observations.count, 1)
            let observation = try XCTUnwrap(detected.observations.first)
            let features = try sourceFeatureBoxes(observation, layer)
            let policy = Policy(target: target, protected: protected, fine: fine,
                features: features, width: layer.width, height: layer.height, version: sourcePolicyVersion)
            let selection = selectSourceProbes(layer, target: target, version: version)
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
            // Admission reads only original RGBA/support. The already frozen
            // band enters the second helper solely as a diagnostic comparison;
            // no mask is passed to production qualification or rendering.
            let qualificationCounts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(
                layer.bytes, width: layer.width, height: layer.height, face: geometry)
            let bandPlanning = HairlineBoundaryRefiner.sourceBandPlanningAggregates(
                layer.bytes, width: layer.width, height: layer.height, face: geometry, frozenSourceBand: target)
            return FrozenSource(layer: layer, observation: observation, policy: policy, selection: selection,
                sourceQualificationCounts: qualificationCounts, sourceBandPlanning: bandPlanning)
        }
        for frozen in frozenSources {
            let layer = frozen.layer, observation = frozen.observation
            let policy = frozen.policy, selection = frozen.selection
            XCTAssertEqual(policy.permanentTargetOverlap, 0, "\(layer.id) frozen target must avoid permanent features before rendering")
            XCTAssertEqual(selection.probes.count, 3, "\(layer.id) uncalibrated edge observation is inconclusive")
            guard policy.permanentTargetOverlap == 0, selection.probes.count == 3 else {
                rows.append(["layer": layer.id, "sourceDeclarationQualified": false,
                    "candidateRendered": false, "permanentTargetOverlap": policy.permanentTargetOverlap,
                    "observerVersion": version.rawValue,
                    "sourcePolicyVersion": sourcePolicyVersion.rawValue,
                    "originalAnnotatedTargetPermanentOverlapPixels": policy.originalPermanentTargetOverlap,
                    "originalTargetFeatureBoxOverlapPixelsByFamily": policy.originalFeatureBoxOverlap,
                    "sourceOnlyQualificationCounts": frozen.sourceQualificationCounts,
                    "sourceOnlyFrozenBandPlanningDiagnostics": frozen.sourceBandPlanning,
                    "productionAdmissionReadsFrozenMask": false,
                    "qualifiedSourceSlotCount": selection.probes.count, "sourceCalibration": selection.records])
                continue
            }
            let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
            let engine = try BeautyEngine(), cg = try cgImage(layer)
            let prepared = try engine.prepareStillImage(image: cg, metadata: metadata)
            let neutral = try engine.processResult(preparedImage: prepared, parameters: .init())
            let neutralExact = try pixels(neutral.output, layer) == layer.bytes
            XCTAssertTrue(neutralExact); XCTAssertEqual(neutral.output.colorSpace?.name, space.name)
            for sign: Float in [-1, 1] {
                var previous = [Double](repeating: 0, count: selection.probes.count)
                var previousRMS = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    let strength = sign * fraction * BeautySafetyCaps.hairlineHeight
                    let parameters = BeautyParameters(hairlineHeight: strength)
                    let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
                    let direct = HairlineBoundaryRefiner.apply(layer.bytes, width: layer.width,
                        height: layer.height, face: face, strength: strength)
                    let stage = BeautyStillImageGeometryStage(sourceRGBA: layer.bytes, width: layer.width,
                        height: layer.height, plan: plan, face: face)
                    let dense = stage.applyingDenseMap(to: stage.sourceRGBA)
                    XCTAssertTrue(direct == stage.sourceRGBA); XCTAssertTrue(dense == stage.sourceRGBA)
                    let result = try engine.processResult(preparedImage: prepared, parameters: parameters)
                    let actual = try pixels(result.output, layer)
                    var phases = [[String: Any]]()
                    for (name, bytes) in [("direct", direct), ("stage", stage.sourceRGBA), ("dense", dense), ("public", actual)] {
                        let c = policy.counts(layer.bytes, bytes)
                        XCTAssertEqual(c.permanent, 0, "\(layer.id)_\(name) ears and complete features")
                        XCTAssertEqual(c.bodyHair, 0, "\(layer.id)_\(name) hair outside frozen transition")
                        XCTAssertEqual(c.protected, 0, "\(layer.id)_\(name) old protected source union")
                        XCTAssertEqual(c.exterior, 0, "\(layer.id)_\(name) entire frozen source exterior")
                        XCTAssertEqual(c.effectiveExterior, 0, "\(layer.id)_\(name) effective source permission excludes every permanent feature")
                        XCTAssertEqual(c.alpha, 0)
                        phases.append(["phase": name, "permanentChangedPixels": c.permanent,
                            "bodyHairChangedPixels": c.bodyHair, "protectedChangedPixels": c.protected,
                            "exteriorChangedPixels": c.exterior, "alphaChangedPixels": c.alpha,
                            "effectiveExteriorChangedPixels": c.effectiveExterior,
                            "targetChangedPixels": c.changed, "targetMaximumByteDelta": c.maximum, "targetRMSByteDelta": c.rms])
                    }
                    let activity = policy.counts(layer.bytes, actual)
                    let usefulEndpoint = activity.rms >= 0.25 && activity.maximum >= 3 && activity.changed >= 16
                    if fraction == 1 { XCTAssertTrue(usefulEndpoint, "\(layer.id) original .25/3/16 endpoint activity gate") }
                    // RMS order is diagnostic: quantized small quarters need
                    // a qualified geometric observer to claim monotonicity.
                    let rmsMonotone = activity.rms > previousRMS
                    previousRMS = activity.rms
                    var measured = [[String: Any]]()
                    for (slot, probe) in selection.probes.enumerated() {
                        let crossing = observe(probe) { sample(actual, width: layer.width, height: layer.height, at: $0) }
                        let directed = crossing.value.map { ($0 - probe.sourceCrossing) * Double(sign) }
                        let qualified = directed?.isFinite == true
                        XCTAssertTrue(qualified, "\(layer.id) source-fixed hairline edge is inconclusive at slot \(slot): \(crossing.status)")
                        let monotone = directed.map { $0 > previous[slot] + 0.1 } ?? false
                        XCTAssertTrue(monotone, "\(layer.id) each calibrated source edge must move in the requested direction by >.1px per quarter")
                        let visible = fraction < 1 || (directed.map { $0 > 1 } ?? false)
                        XCTAssertTrue(visible, "\(layer.id) endpoint source edge must move by >1 source pixel")
                        measured.append(["sourceSlotOrdinal": slot, "measurementQualified": qualified,
                            "status": crossing.status, "crossingCount": crossing.count,
                            "directedSourcePixelDisplacement": directed.map { $0 as Any } ?? NSNull(),
                            "positiveDirection": directed.map { $0 > 0 } ?? false,
                            "monotoneGreaterThanPointOne": monotone, "visibleEndpoint": visible])
                        previous[slot] = directed ?? .infinity
                    }
                    let again = try engine.processResult(preparedImage: prepared, parameters: parameters)
                    let repeated = actual == (try pixels(again.output, layer))
                    XCTAssertTrue(repeated)
                    XCTAssertEqual(result.output.extent, layer.image.extent)
                    XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1)
                    let expectedSpace = face.denseSupport == nil ? CGColorSpaceCreateDeviceRGB() : space
                    XCTAssertTrue(CFEqual(try XCTUnwrap(result.output.colorSpace), expectedSpace))
                    let name = "\(layer.id)-hairline-\(sign < 0 ? "negative" : "positive")-\(Int(fraction * 100))"
                    try save(result.output, output.appendingPathComponent(name + ".png"))
                    rows.append(["layer": layer.id, "sign": sign, "fraction": fraction,
                        "sourceDeclarationQualified": true, "candidateRendered": true,
                        "sourceObserverCalibratedBeforeCandidate": true, "sourceCalibration": selection.records,
                        "observerVersion": version.rawValue,
                        "sourcePolicyVersion": sourcePolicyVersion.rawValue,
                        "originalAnnotatedTargetPermanentOverlapPixels": policy.originalPermanentTargetOverlap,
                        "originalTargetFeatureBoxOverlapPixelsByFamily": policy.originalFeatureBoxOverlap,
                        "effectiveEditablePixelCount": policy.editable.filter { $0 }.count,
                        "originalActivityDefinitionRetained": true,
                        "sourceOnlyQualificationCounts": frozen.sourceQualificationCounts,
                        "sourceOnlyFrozenBandPlanningDiagnostics": frozen.sourceBandPlanning,
                        "productionAdmissionReadsFrozenMask": false,
                        "sourceGeometry": observation.mesh == nil ? "production-Vision" : "production-MediaPipe",
                        "oldTargetActivityDenominatorPixels": policy.activity.filter { $0 }.count,
                        "endpointActivityGatePassed": fraction < 1 ? NSNull() : usefulEndpoint as Any,
                        "RMSMonotoneDiagnosticOnly": rmsMonotone, "neutralExact": neutralExact,
                        "repeatedExact": repeated, "phases": phases, "sourceEdgeObservations": measured])
                }
            }
        }
        let schema = sourcePolicyVersion == .subtractPermanentV3 ? "hairline-frozen-source-photo-policy/v3" :
            (version == .sparseV1 ? "hairline-frozen-source-photo-policy/v1" : "hairline-frozen-source-photo-policy/v2")
        try receipt(["schema": schema, "records": rows,
            "oldAllTenResultsReplaced": false, "appearanceParity": false, "fullSDKRegression": false,
            "observerUsesProductionHairlineCurve": false, "candidatePointSelection": false],
            name: "hairline-photo-policy-aggregate.json", output: output)
    }

    func testGeneratedEdgeObserverRejectsWrongDirectionAndMultipleBoundaries() throws {
        let width = 80, height = 96
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let value: UInt8 = y < 44 ? 30 : 170, i = (y * width + x) * 4
            bytes[i] = value; bytes[i + 1] = value; bytes[i + 2] = value
        } }
        let probe = Probe(x: 40.5, lower: 32.5, upper: 56.5,
            before: SIMD3(repeating: 30), after: SIMD3(repeating: 170), sourceCrossing: 44)
        let source = observe(probe) { sample(bytes, width: width, height: height, at: $0) }
        XCTAssertEqual(try XCTUnwrap(source.value), probe.sourceCrossing, accuracy: 0.00001)
        let controls = calibrate(probe, bytes: bytes, width: width, height: height)
        XCTAssertTrue(controls.qualified); XCTAssertLessThanOrEqual(controls.maximumError, 0.1)
        let wrong = observe(probe) { translatedSample(bytes, width: width, height: height, at: $0, shift: -1) }
        XCTAssertGreaterThan(abs((try XCTUnwrap(wrong.value)) - probe.sourceCrossing - 1), 0.1)
        var ghost = bytes
        for y in 47...50 { for x in 0..<width { for c in 0..<3 { ghost[(y * width + x) * 4 + c] = 30 } } }
        let ambiguous = observe(probe) { sample(ghost, width: width, height: height, at: $0) }
        XCTAssertNil(ambiguous.value); XCTAssertGreaterThan(ambiguous.count, 1)
        var alpha = bytes; alpha[(44 * width + 40) * 4 + 3] = 254
        XCTAssertNil(observe(probe) { sample(alpha, width: width, height: height, at: $0) }.value)
        var target = [Bool](repeating: false, count: width * height)
        for y in 32...56 { for x in 28...52 { target[y * width + x] = true } }
        let inside = 44 * width + 40, outsideHair = 20 * width + 30, ear = 60 * width + 20
        var fine = Array(repeating: [Bool](repeating: false, count: width * height), count: 7)
        fine[5][inside] = true; fine[5][outsideHair] = true; fine[0][ear] = true
        let policy = Policy(target: target, protected: target.map { !$0 }, fine: fine,
            features: [], width: width, height: height)
        XCTAssertEqual(policy.permanentTargetOverlap, 0)
        var legal = bytes; legal[inside * 4] += 1
        let legalCounts = policy.counts(bytes, legal)
        XCTAssertEqual(legalCounts.changed, 1); XCTAssertEqual(legalCounts.exterior, 0)
        XCTAssertEqual(legalCounts.bodyHair, 0); XCTAssertEqual(legalCounts.permanent, 0)
        var leak = bytes; leak[outsideHair * 4] += 1; leak[ear * 4] += 1; leak[3] = 254
        let c = policy.counts(bytes, leak)
        XCTAssertEqual(c.bodyHair, 1); XCTAssertEqual(c.permanent, 1)
        XCTAssertEqual(c.exterior, 3); XCTAssertEqual(c.protected, 3); XCTAssertEqual(c.alpha, 1)
        fine[0][inside] = true
        XCTAssertEqual(Policy(target: target, protected: target.map { !$0 }, fine: fine,
            features: [], width: width, height: height).permanentTargetOverlap, 1,
            "even a legal hairline band cannot exempt an ear")
        let box = CGRect(x: 40, y: 44, width: 1, height: 1)
        let strict = Policy(target: target, protected: target.map { !$0 }, fine: fine,
            features: [box], width: width, height: height)
        let narrowed = Policy(target: target, protected: target.map { !$0 }, fine: fine,
            features: [box], width: width, height: height, version: .subtractPermanentV3)
        XCTAssertEqual(strict.permanentTargetOverlap, 1)
        XCTAssertEqual(narrowed.originalPermanentTargetOverlap, 1)
        XCTAssertEqual(narrowed.permanentTargetOverlap, 0)
        XCTAssertFalse(narrowed.editable[inside])
        XCTAssertTrue(narrowed.activity == strict.activity, "V3 cannot change the original activity denominator")
        let featureLeak = narrowed.counts(bytes, legal)
        XCTAssertEqual(featureLeak.permanent, 1, "subtracting permission never exempts a modified ear or whole feature")
        XCTAssertEqual(featureLeak.effectiveExterior, 1)
        XCTAssertEqual(featureLeak.exterior, 0, "the separate original-band audit is retained")
    }

    private struct Layer { let id: String; let image: CIImage; let width: Int; let height: Int; let bytes: [UInt8] }
    private struct Probe { let x: Double, lower: Double, upper: Double; let before: SIMD3<Double>, after: SIMD3<Double>; let sourceCrossing: Double }
    private struct Crossing { let value: Double?; let count: Int; let status: String }
    private struct Calibration { let qualified: Bool; let maximumError: Double; let qualifiedCount: Int; let observedCount: Int }
    private struct Selection { let probes: [Probe]; let tested: Int; let records: [[String: Any]] }
    private struct FrozenSource {
        let layer: Layer; let observation: BeautyFaceObservation; let policy: Policy; let selection: Selection
        let sourceQualificationCounts: [String: Int]; let sourceBandPlanning: [String: Double]
    }

    private func selectSourceProbes(_ layer: Layer, target: [Bool], version: ObserverVersion = .sparseV1) -> Selection {
        let columns = (0..<layer.width).filter { x in (0..<layer.height).filter { target[$0 * layer.width + x] }.count >= 8 }
        guard let left = columns.first, let right = columns.last, right > left else { return Selection(probes: [], tested: 0, records: []) }
        var selected = [Probe](), records = [[String: Any]](), tested = 0
        for (slot, fraction) in [0.25, 0.5, 0.75].enumerated() {
            var seen = Set<Int>(), found: Probe?, foundControl: Calibration?
            var rejected = [String: Int](), bestControl: Calibration?
            let candidates: [Int]
            switch version {
            case .sparseV1:
                candidates = [0.0, -0.025, 0.025, -0.05, 0.05, -0.075, 0.075, -0.1, 0.1].compactMap { offset in
                    let desired = Double(left) + (fraction + offset) * Double(right - left)
                    return columns.min(by: { abs(Double($0) - desired) < abs(Double($1) - desired) })
                }
            case .denseV2:
                let desired = Double(left) + fraction * Double(right - left)
                candidates = columns.filter { abs(Double($0) - desired) <= 0.1 * Double(right - left) }.sorted { a, b in
                    let da = abs(Double(a) - desired), db = abs(Double(b) - desired)
                    return da == db ? a < b : da < db
                }
            }
            for x in candidates {
                guard seen.insert(x).inserted else { continue }
                tested += 1
                let rows = (0..<layer.height).filter { target[$0 * layer.width + x] }
                guard let a = rows.first, let b = rows.last, b - a >= 8 else { continue }
                let inset = max(2, (b - a) / 10), reach = max(4, min(12, (b - a) / 5))
                guard let before = prototype(layer, x: x, y: a + inset), let after = prototype(layer, x: x, y: b - inset) else {
                    rejected["incomplete-source-prototype", default: 0] += 1; continue
                }
                let initial = Probe(x: Double(x) + 0.5, lower: Double(a - reach) + 0.5, upper: Double(b + reach) + 0.5,
                    before: before, after: after, sourceCrossing: 0)
                let edge = observe(initial) { sample(layer.bytes, width: layer.width, height: layer.height, at: $0) }
                guard let crossing = edge.value else { rejected[edge.status, default: 0] += 1; continue }
                let probe = Probe(x: initial.x, lower: initial.lower, upper: initial.upper,
                    before: before, after: after, sourceCrossing: crossing)
                let control = calibrate(probe, bytes: layer.bytes, width: layer.width, height: layer.height)
                if bestControl == nil || control.qualifiedCount > bestControl!.qualifiedCount { bestControl = control }
                if control.qualified { found = probe; foundControl = control; break }
                rejected["known-translations-inconclusive", default: 0] += 1
            }
            if let found, let control = foundControl {
                selected.append(found)
                records.append(["sourceSlotOrdinal": slot, "qualified": true, "knownControlCount": translations.count,
                    "qualifiedKnownControlCount": control.qualifiedCount, "maximumErrorSourcePixels": control.maximumError,
                    "rejectedSourceCandidateStatuses": rejected])
            } else {
                records.append(["sourceSlotOrdinal": slot, "qualified": false, "status": "source-only-observer-inconclusive",
                    "requiredKnownControlCount": translations.count, "selectedKnownControlCount": 0,
                    "bestSourceCandidateQualifiedKnownControlCount": bestControl?.qualifiedCount ?? 0,
                    "bestSourceCandidateObservedKnownControlCount": bestControl?.observedCount ?? 0,
                    "bestSourceCandidateMaximumErrorSourcePixels": bestControl.map { $0.maximumError as Any } ?? NSNull(),
                    "rejectedSourceCandidateStatuses": rejected])
            }
        }
        return Selection(probes: selected, tested: tested, records: records)
    }
    private func prototype(_ layer: Layer, x: Int, y: Int) -> SIMD3<Double>? {
        var sum = SIMD3<Double>.zero
        for dy in -2...2 { for dx in -2...2 {
            guard let value = sample(layer.bytes, width: layer.width, height: layer.height,
                at: SIMD2(Double(x + dx) + 0.5, Double(y + dy) + 0.5)) else { return nil }
            sum += value
        } }
        return sum / 25
    }
    private func calibrate(_ probe: Probe, bytes: [UInt8], width: Int, height: Int) -> Calibration {
        var maximum = 0.0, qualified = 0, observedCount = 0
        for truth in translations {
            let observed = observe(probe) { translatedSample(bytes, width: width, height: height, at: $0, shift: truth) }
            guard let value = observed.value else { continue }
            observedCount += 1
            let error = abs(value - probe.sourceCrossing - truth)
            maximum = max(maximum, error)
            if error <= 0.1 { qualified += 1 }
        }
        return Calibration(qualified: qualified == translations.count, maximumError: maximum, qualifiedCount: qualified,
            observedCount: observedCount)
    }
    private func observe(_ probe: Probe, sampler: (SIMD2<Double>) -> SIMD3<Double>?) -> Crossing {
        let vector = probe.after - probe.before, energy = vector.x * vector.x + vector.y * vector.y + vector.z * vector.z
        guard energy >= 32 * 32 else { return Crossing(value: nil, count: 0, status: "weak-source-prototype") }
        let count = Int(floor((probe.upper - probe.lower) * 16)) + 1
        guard count > 2 else { return Crossing(value: nil, count: 0, status: "empty-source-window") }
        var values = [Double]()
        for i in 0..<count {
            guard let rgb = sampler(SIMD2(probe.x, probe.lower + Double(i) / 16)) else {
                return Crossing(value: nil, count: 0, status: "incomplete-opaque-footprint")
            }
            let d = rgb - (probe.before + probe.after) * 0.5
            values.append((d.x * vector.x + d.y * vector.y + d.z * vector.z) / energy)
        }
        func crossings(_ level: Double) -> ([Double], Bool) {
            var result = [Double](), plateau = false
            for i in 0..<(count - 1) {
                let a = values[i] - level, b = values[i + 1] - level
                if abs(a) < 0.000000001 && abs(b) < 0.000000001 { plateau = true }
                if (a < 0 && b >= 0) || (a > 0 && b <= 0) {
                    let y = probe.lower + (Double(i) - a / (b - a)) / 16
                    if result.last.map({ abs($0 - y) > 0.02 }) ?? true { result.append(y) }
                }
            }
            return (result, plateau)
        }
        let (middle, plateau) = crossings(0), (low, lp) = crossings(-0.25), (high, hp) = crossings(0.25)
        guard middle.count == 1, !plateau else { return Crossing(value: nil, count: middle.count, status: "multiple-or-unresolved-boundaries") }
        guard low.count == 1, high.count == 1, !lp, !hp, low[0] < middle[0], middle[0] < high[0],
              values[0] < -0.25, values[count - 1] > 0.25 else { return Crossing(value: nil, count: 1, status: "unresolved-prototype-width") }
        return Crossing(value: middle[0], count: 1, status: "unique-source-colour-edge")
    }
    private func sample(_ bytes: [UInt8], width: Int, height: Int, at p: SIMD2<Double>) -> SIMD3<Double>? {
        let q = p - SIMD2(repeating: 0.5)
        guard q.x.isFinite, q.y.isFinite, q.x >= 0, q.y >= 0, q.x < Double(width - 1), q.y < Double(height - 1) else { return nil }
        let x = Int(floor(q.x)), y = Int(floor(q.y)), fx = q.x - Double(x), fy = q.y - Double(y)
        var result = SIMD3<Double>.zero
        for (dx, wx) in [(0, 1 - fx), (1, fx)] { for (dy, wy) in [(0, 1 - fy), (1, fy)] {
            let i = ((y + dy) * width + x + dx) * 4
            guard bytes[i + 3] == 255 else { return nil }
            result += SIMD3(Double(bytes[i]), Double(bytes[i + 1]), Double(bytes[i + 2])) * wx * wy
        } }
        return result
    }
    private func translatedSample(_ bytes: [UInt8], width: Int, height: Int, at p: SIMD2<Double>, shift: Double) -> SIMD3<Double>? {
        let q = p - SIMD2(repeating: 0.5)
        guard q.x.isFinite, q.y.isFinite, shift.isFinite, q.x >= 0, q.y >= 0,
              q.x < Double(width - 1), q.y < Double(height - 1) else { return nil }
        let x = Int(floor(q.x)), y = Int(floor(q.y)), fx = q.x - Double(x), fy = q.y - Double(y)
        var result = SIMD3<Double>.zero
        for (dx, wx) in [(0, 1 - fx), (1, fx)] { for (dy, wy) in [(0, 1 - fy), (1, fy)] {
            guard let rgb = sample(bytes, width: width, height: height,
                at: SIMD2(Double(x + dx) + 0.5, Double(y + dy) + 0.5 - shift)) else { return nil }
            // The known input transform has the same 8bit materialization as
            // a raster warp, before the observer interpolates that raster.
            let value = SIMD3(floor(rgb.x + 0.5), floor(rgb.y + 0.5), floor(rgb.z + 0.5))
            result += value * wx * wy
        } }
        return result
    }

    private struct Counts { var permanent = 0, bodyHair = 0, protected = 0, exterior = 0, effectiveExterior = 0, alpha = 0, changed = 0, maximum = 0; var rms = 0.0 }
    private struct Policy {
        let target: [Bool], editable: [Bool], permanent: [Bool], bodyHair: [Bool], protected: [Bool], activity: [Bool]
        let permanentTargetOverlap: Int, originalPermanentTargetOverlap: Int
        let originalFeatureBoxOverlap: [Int]
        init(target: [Bool], protected: [Bool], fine: [[Bool]], features: [CGRect], width: Int, height: Int,
             version: SourcePolicyVersion = .strictDisjointV1) {
            var permanent = target.map { _ in false }, body = permanent, activity = permanent
            var overlap = 0, editable = target, effectiveOverlap = 0
            var boxOverlap = [Int](repeating: 0, count: features.count)
            for p in target.indices {
                let point = CGPoint(x: Double(p % width) + 0.5, y: Double(p / width) + 0.5)
                let feature = features.contains { $0.contains(point) }
                permanent[p] = fine.prefix(5).contains { $0[p] } || feature
                body[p] = (fine[5][p] || fine[6][p]) && !target[p]
                activity[p] = target[p] && !protected[p] && !feature
                if target[p] && permanent[p] { overlap += 1 }
                for (ordinal, box) in features.enumerated() where target[p] && box.contains(point) { boxOverlap[ordinal] += 1 }
                if version == .subtractPermanentV3 { editable[p] = target[p] && !permanent[p] }
                if editable[p] && permanent[p] { effectiveOverlap += 1 }
            }
            self.target = target; self.permanent = permanent; bodyHair = body; self.protected = protected
            self.activity = activity; self.editable = editable
            originalPermanentTargetOverlap = overlap; permanentTargetOverlap = effectiveOverlap
            originalFeatureBoxOverlap = boxOverlap
        }
        func counts(_ source: [UInt8], _ output: [UInt8]) -> Counts {
            var c = Counts(), square = 0.0, count = 0
            for p in target.indices {
                let i = p * 4, differs = (0..<4).contains { source[i + $0] != output[i + $0] }
                if differs {
                    if permanent[p] { c.permanent += 1 }; if bodyHair[p] { c.bodyHair += 1 }
                    if protected[p] && !target[p] { c.protected += 1 }; if !target[p] { c.exterior += 1 }
                    if !editable[p] { c.effectiveExterior += 1 }
                }
                if source[i + 3] != output[i + 3] { c.alpha += 1 }
                if activity[p] {
                    var changed = false
                    for channel in 0..<3 {
                        let d = abs(Int(output[i + channel]) - Int(source[i + channel]))
                        square += Double(d * d); count += 1; c.maximum = max(c.maximum, d); changed = changed || d != 0
                    }
                    if changed { c.changed += 1 }
                }
            }
            c.rms = sqrt(square / Double(max(1, count))); return c
        }
    }
    private func sourceFeatureBoxes(_ observation: BeautyFaceObservation, _ layer: Layer) throws -> [CGRect] {
        guard let contour = observation.observedFaceSupport?.contour, contour.count >= 7,
              let eyes = observation.observedEyeSupport, let left = eyes.first(where: { $0.side == .left })?.contour, left.count >= 4,
              let right = eyes.first(where: { $0.side == .right })?.contour, right.count >= 4,
              let brows = observation.observedEyebrowSupport, let lb = brows.left, lb.count >= 4, let rb = brows.right, rb.count >= 4,
              let lips = observation.observedLipSupport?.outer, lips.count >= 4,
              let nose = observation.observedNoseSupport, nose.contour.count >= 4 else { throw Failure.source }
        let paths = [left, right, lb, rb, lips + (observation.observedLipSupport?.inner ?? []), nose.crest + nose.contour]
        guard (contour + paths.flatMap { $0 }).allSatisfy({ $0.x.isFinite && $0.y.isFinite && (0...1).contains($0.x) && (0...1).contains($0.y) }) else { throw Failure.source }
        let span = (contour.map(\.x).max()! - contour.map(\.x).min()!) * Double(layer.width), margin = max(2, span * 0.008)
        return paths.map { path in
            let x = path.map { $0.x * Double(layer.width) }, y = path.map { $0.y * Double(layer.height) }
            return CGRect(x: x.min()! - margin, y: y.min()! - margin,
                width: x.max()! - x.min()! + 2 * margin, height: y.max()! - y.min()! + 2 * margin)
        }
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
    private func hash(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }
    private func privateURL(_ name: String) -> URL {
        Bundle(for: BeautyEngineHairlinePhotoPolicyTests.self).bundleURL.appendingPathComponent("NativePrivatePhoto").appendingPathComponent(name + ".png")
    }
    private func mask(_ name: String, _ layer: Layer) throws -> [Bool] {
        let url: URL
        if FileManager.default.fileExists(atPath: privateURL(name).path) { url = privateURL(name) }
        else {
            #if os(iOS)
            throw Failure.source
            #else
            let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            let folder = name == "legal_hairline_band" || name == "protected_hairline_union" ? "protection-masks" : "protection-masks-v2"
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
    private func receipt(_ object: [String: Any], name: String, output: URL) throws {
        let url = output.appendingPathComponent(name)
        guard !FileManager.default.fileExists(atPath: url.path) else { throw Failure.output }
        try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]).write(to: url)
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
