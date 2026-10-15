import BeautyCore
import BeautyDetection
import BeautyEffects
import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import XCTest
@testable import BeautySDK

/// Test-only context observer. Opaque protected RGB is valid read context;
/// permission to edit source/destination core is independently constrained.
/// Its source arcs and palette are fixed and calibrated before SDK outputs.
final class BeautyEngineSourceContourContextTests: XCTestCase {
    private enum Failure: Error { case input, support, output, annotation }
    private let colourSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
    private let controls: [BeautyFaceShapeSlider] = [.faceWidth, .temple, .cheekbone]
    private struct Raster {
        let id: String, image: CIImage
        let width: Int, height: Int
        let bytes: [UInt8]
    }
    private struct Frame {
        let contour: [SIMD2<Double>], origin: SIMD2<Double>, axisX: SIMD2<Double>, axisY: SIMD2<Double>
        let span: Double, chin: Double
        let features: [CGRect]
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let q = p - origin
            return SIMD2(q.x * axisX.x + q.y * axisX.y, q.x * axisY.x + q.y * axisY.y)
        }
        func image(_ p: SIMD2<Double>) -> SIMD2<Double> { origin + axisX * p.x + axisY * p.y }
    }
    private struct Domains { let legal: [Bool], core: [Bool] }
    private struct Probe {
        let center: SIMD2<Double>, normal: SIMD2<Double>, tangent: SIMD2<Double>
        let inside: SIMD3<Double>, outside: SIMD3<Double>, search: Int, sourceCrossing: Double
        let controlPolarity: Double
        let span: Double
    }
    private struct Deformation {
        let ordinal: Int, translation: Double
        // These are inverse-coordinate Jacobian generators, not the old
        // forward .55 scale. Saturation bounds their inverse displacement.
        let a: Double, b: Double, c: Double, d: Double
        var maximumGradient: Double {
            let p = a - 1, q = b, r = c, s = d - 1
            let trace = p * p + q * q + r * r + s * s
            return sqrt(trace)
        }
    }
    private struct Boundary {
        let position: Double?
        let crossingCount: Int
        let status: String
        let fullTruthQualified: Bool
        init(position: Double?, crossingCount: Int, status: String, fullTruthQualified: Bool? = nil) {
            self.position = position; self.crossingCount = crossingCount; self.status = status
            self.fullTruthQualified = fullTruthQualified ?? (position != nil)
        }
    }
    private struct DisplayRegistration {
        let scale: Double, translation: SIMD2<Double>
        init(scale: Double, physicalTranslation: SIMD2<Double>) {
            self.scale = scale
            // Image affine transforms map physical pixel centres (index + .5).
            // The observer samples array indices whose texel centre is index.
            translation = physicalTranslation + SIMD2<Double>(repeating: (scale - 1) * 0.5)
        }
        func display(_ p: SIMD2<Double>) -> SIMD2<Double> { p * scale + translation }
        func source(_ p: SIMD2<Double>) -> SIMD2<Double> { (p - translation) / scale }
        func displayProbe(_ p: Probe) -> Probe {
            Probe(center: display(p.center), normal: p.normal, tangent: p.tangent,
                inside: p.inside, outside: p.outside, search: Int(ceil(Double(p.search) * scale)),
                sourceCrossing: p.sourceCrossing * scale, controlPolarity: p.controlPolarity, span: p.span * scale)
        }
    }
    private struct ReferenceObservation {
        let displayScale: Double
        let directions: [Int: Double]
        let aggregates: [String: Any]
    }

    func testFACEContextV2GeneratedKnownNonuniformCorrectness() throws {
        // This ordinary correctness entry always executes the generated bank,
        // including when a real-source environment is set for adjacent tests.
        try generatedChecks()
    }

    func testFACEContextV2SourceOnlyKnownNonuniformControls() throws {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedChecks(); return
        }
        let destination = try outputDirectory()
        var records: [[String: Any]] = []
        for raster in try layers(path) {
            let frame = try sourceFrame(raster), domain = try domains(raster, frame: frame)
            for control in controls { for side in [-1.0, 1] {
                let selection = selectProbe(control, side: side, raster: raster, frame: frame, domain: domain)
                XCTAssertNotNil(selection.probe, "source-only calibrated colour context is unqualified: \(raster.id) \(control.rawValue) \(side)")
                var rejectionCounts: [String: Int] = [:]
                for stage in selection.stages {
                    if let reason = stage["rejectionStage"] as? String { rejectionCounts[reason, default: 0] += 1 }
                }
                records.append(["layer": raster.id, "control": control.rawValue, "sideOrdinal": side < 0 ? 0 : 1,
                    "eligibleSourceCandidateCount": selection.eligible, "sourceCandidatesExamined": selection.examined,
                    "sourceQualified": selection.probe != nil, "candidateOutputRead": false,
                    "candidateStages": selection.stages, "rejectionCounts": rejectionCounts,
                    "protectedContextReadsPermitted": true, "controlBankCount": deformations().count,
                    "readModelQualified": selection.probe != nil, "controlWarpProductionQualified": false])
                guard let probe = selection.probe else { continue }
                for deformation in deformations() {
                    let observation = knownBoundary(probe, deformation: deformation, raster: raster, domain: domain)
                    let expected = probe.sourceCrossing + deformation.translation * probe.controlPolarity
                    let error = observation.position.map { abs($0 - expected) } ?? Double.greatestFiniteMagnitude
                    XCTAssertLessThanOrEqual(error, 0.1, "known bounded inverse-control truth")
                    records.append(["layer": raster.id, "control": control.rawValue, "sideOrdinal": side < 0 ? 0 : 1,
                        "knownControlOrdinal": deformation.ordinal, "knownTranslationPixels": deformation.translation,
                        "crossingCount": observation.crossingCount, "status": observation.status,
                        "absoluteError": error, "completeOpaqueContext": observation.status != "incomplete-opaque-context",
                        "inverseGradientBound": deformation.maximumGradient, "displacementCapFraction": 0.06,
                        "protectedContextReadsPermitted": true, "productionQualified": false])
                }
            } }
        }
        try receipt(records, name: "source-only-contour-context-v2.json", to: destination)
    }

    func testFACEContextV2PublicFaceWidthAndRegisteredReference() throws {
        try generatedRegistrationChecks()
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedChecks(); return
        }
        let destination = try outputDirectory(), rasters = try layers(path)
        let fullWidth = try XCTUnwrap(rasters.first?.width)
        var records: [[String: Any]] = []
        for raster in rasters {
            let frame = try sourceFrame(raster), domain = try domains(raster, frame: frame)
            // Complete source-only selection precedes every SDK output. Keep
            // all twelve original slots visible, including rejected controls.
            var probes = [Probe?](repeating: nil, count: 2)
            for control in controls { for side in [-1.0, 1] {
                let selection = selectProbe(control, side: side, raster: raster, frame: frame, domain: domain)
                records.append(["kind": "source-selection", "layer": raster.id, "control": control.rawValue,
                    "sideOrdinal": side < 0 ? 0 : 1, "sourceQualified": selection.probe != nil,
                    "sourceCandidatesDeclared": 5, "sourceCandidatesExamined": selection.examined,
                    "candidateStages": selection.stages, "candidateOutputRead": false,
                    "measurementIncluded": control == .faceWidth && selection.probe != nil])
                if control == .faceWidth {
                    probes[side < 0 ? 0 : 1] = selection.probe
                    XCTAssertNotNil(selection.probe, "original faceWidth source arc must retain its calibration")
                }
            } }
            var references = [ReferenceObservation?](repeating: nil, count: 2)
            for ordinal in 0..<2 {
                guard let probe = probes[ordinal] else { continue }
                let reference = try registeredReference(probe, raster: raster, fullWidth: fullWidth)
                references[ordinal] = reference
                var row = reference.aggregates
                row["kind"] = "source-only-reference-calibration"; row["layer"] = raster.id
                row["sideOrdinal"] = ordinal; row["candidateOutputRead"] = false
                records.append(row)
            }
            let engine = try BeautyEngine()
            let context = CIContext(options: [.workingColorSpace: colourSpace, .outputColorSpace: colourSpace])
            guard let cg = context.createCGImage(raster.image, from: raster.image.extent,
                format: .RGBA8, colorSpace: colourSpace) else { throw Failure.input }
            let prepared = try engine.prepareStillImage(image: cg, metadata: metadata)
            let neutral = try engine.processResult(preparedImage: prepared, parameters: .init())
            XCTAssertTrue(try pixels(neutral.output, raster: raster) == raster.bytes, "neutral source RGBA exact")
            for sign: Double in [-1, 1] {
                var previous = [0.0, 0.0]
                for (step, fraction) in [0.25, 0.5, 0.75, 1].enumerated() {
                    let parameters = BeautyFaceShapeSlider.faceWidth.applying(
                        position: Float(0.5 + sign * fraction * 0.5), to: .init())
                    let result = try engine.processResult(preparedImage: prepared, parameters: parameters)
                    let actual = try pixels(result.output, raster: raster)
                    let protection = protectionChanges(raster.bytes, actual, domain: domain)
                    XCTAssertEqual(protection.core, 0, "fine source core independent of colour-edge displacement")
                    XCTAssertEqual(protection.exterior, 0, "frozen source domain exterior")
                    XCTAssertEqual(protection.alpha, 0)
                    XCTAssertEqual(result.output.extent, raster.image.extent)
                    XCTAssertEqual(result.output.colorSpace?.name, colourSpace.name)
                    for ordinal in 0..<2 {
                        guard let probe = probes[ordinal] else { continue }
                        let boundary = findBoundary(probe, raster: raster) { x, y in self.rgb(actual, x, y, raster) }
                        let value = boundary.position.map { ($0 - probe.sourceCrossing) * probe.controlPolarity * sign }
                        let monotone = value.map { $0 > previous[ordinal] + 0.1 } ?? false
                        let visible = value.map { fraction < 1 || $0 > 1 } ?? false
                        XCTAssertNotNil(value, "qualified source colour context unresolved: \(boundary.status)")
                        XCTAssertTrue(monotone, "colour-edge quarters increase >.1: \(raster.id),side=\(ordinal),sign=\(sign),quarter=\(step + 1)")
                        XCTAssertTrue(visible, "endpoint colour-edge movement >1; identity cannot pass")
                        previous[ordinal] = value ?? .nan
                        var row: [String: Any] = ["kind": "public-faceWidth-context", "layer": raster.id,
                            "sideOrdinal": ordinal, "sign": Int(sign), "quarter": step + 1,
                            "measurementQualified": value != nil, "directionPixels": value ?? 0,
                            "status": boundary.status, "crossingCount": boundary.crossingCount,
                            "monotone": monotone, "visibleEndpoint": visible,
                            "protectedCoreChangedPixels": protection.core,
                            "legalDomainExteriorChangedPixels": protection.exterior, "alphaChangedPixels": protection.alpha,
                            "readContextOnly": true, "fullMaterialDisplacementProven": false]
                        if fraction == 1, let reference = references[ordinal],
                           let target = reference.directions[Int(sign)], let value {
                            let display = value * reference.displayScale
                            let tolerance = max(1, abs(target) * 0.35), difference = abs(display - target)
                            row["registeredReferenceDirectionDisplayPixels"] = target
                            row["sdkDirectionDisplayPixels"] = display
                            row["referenceAmplitudeWithinTolerance"] = difference <= tolerance
                            row["referenceAmplitudeTolerance"] = tolerance
                            XCTAssertLessThanOrEqual(difference, tolerance, "same calibrated source colour arc limited amplitude")
                        } else if fraction == 1 { row["referenceAmplitudeQualified"] = false }
                        records.append(row)
                    }
                    if fraction == 1 {
                        let repeated = try engine.processResult(preparedImage: prepared, parameters: parameters)
                        XCTAssertTrue(try pixels(repeated.output, raster: raster) == actual, "endpoint repeat RGBA exact")
                    }
                }
            }
            let restored = try engine.processResult(preparedImage: prepared, parameters: .init())
            XCTAssertTrue(try pixels(restored.output, raster: raster) == raster.bytes, "restored neutral exact")
        }
        try receipt(records, name: "public-face-width-context-v2.json", to: destination)
    }

    func testFACEContextV2PublicColourLateralCPUAndActualMetal() throws {
        // Selected before observing outputs. Only one modest colour setting,
        // the two faceWidth caps and the original two raster layers are used.
        let colour = BeautyParameters(brightness: 0.10)
        let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"]
        let noFace = path == nil
        func engine(gpu: Bool) throws -> BeautyEngine {
            guard noFace else { return try BeautyEngine(configuration: .init(renderBackend: gpu ? .gpu : .cpu)) }
            let detector = BeautyFaceDetector(mappedObservationProvider: { _ in
                BeautyMappedFaceObservations(observations: [])
            })
            let executor: BeautyBackendExecutor = gpu ? try BeautyMetalBackend() : BeautyCPUBackend()
            return try BeautyEngine(configuration: .init(renderBackend: gpu ? .gpu : .cpu),
                faceDetector: detector, backendExecutor: executor)
        }
        var engines: [(name: String, value: BeautyEngine)] = [("cpu", try engine(gpu: false))]
        var records: [[String: Any]] = []
        do { engines.append(("actual-metal", try engine(gpu: true))) }
        catch {
            let unavailable = (error as? BeautyError) == .metalUnavailable
            records.append(["kind": "backend-availability", "actualMetalExecuted": false,
                "typedMetalUnavailable": unavailable, "failureIsBeautyError": error is BeautyError])
            XCTFail("actual Metal witness unavailable; typedMetalUnavailable=\(unavailable)")
        }
        guard let path else {
            let raster = generatedRaster(), fixture = BeautyInputMetadata(orientation: .up, source: .testFixture)
            for backend in engines {
                let baseline = try backend.value.processResult(image: raster.image, metadata: fixture, parameters: colour)
                let coloured = try pixels(baseline.output, raster: raster)
                XCTAssertFalse(coloured == raster.bytes, "generated colour baseline is active")
                for position: Float in [0, 1] {
                    let parameters = BeautyFaceShapeSlider.faceWidth.applying(position: position, to: colour)
                    let result = try backend.value.processResult(image: raster.image, metadata: fixture, parameters: parameters)
                    XCTAssertTrue(try pixels(result.output, raster: raster) == coloured, "no-face geometry cannot change colour-only recovery")
                    XCTAssertEqual(result.detectionSummary?.usedFaceCount, 0)
                    XCTAssertEqual(result.output.extent, raster.image.extent)
                    XCTAssertEqual(result.output.colorSpace?.name, colourSpace.name)
                }
                XCTAssertThrowsError(try backend.value.processResult(image: CIImage.empty(), metadata: fixture, parameters: colour)) {
                    XCTAssertEqual($0 as? BeautyError, .invalidInput)
                }
                let recovered = try backend.value.processResult(image: raster.image, metadata: fixture, parameters: colour)
                XCTAssertTrue(try pixels(recovered.output, raster: raster) == coloured, "generated typed-failure colour recovery")
                XCTAssertTrue(stride(from: 3, to: coloured.count, by: 4).allSatisfy { coloured[$0] == 255 })
            }
            return
        }
        let destination = try outputDirectory()
        for raster in try layers(path) {
            let frame = try sourceFrame(raster), domain = try domains(raster, frame: frame)
            var lower = [Bool](repeating: false, count: domain.legal.count)
            for y in 0..<raster.height { for x in 0..<raster.width {
                let p = y * raster.width + x, q = frame.local(SIMD2(Double(x) + 0.5, Double(y) + 0.5))
                lower[p] = domain.legal[p] && !domain.core[p] && q.y >= frame.chin * 0.55
                    && q.y <= frame.chin * 0.90 && abs(q.x) >= frame.span * 0.20
            } }
            XCTAssertGreaterThan(lower.filter { $0 }.count, 16, "source-fixed lower contour response domain")
            let context = CIContext(options: [.workingColorSpace: colourSpace, .outputColorSpace: colourSpace])
            let cg = try XCTUnwrap(context.createCGImage(raster.image, from: raster.image.extent, format: .RGBA8, colorSpace: colourSpace))
            var baselines: [[UInt8]] = [], pure: [[[UInt8]]] = [], mixed: [[[UInt8]]] = []
            for backend in engines {
                let prepared = try backend.value.prepareStillImage(image: cg, metadata: metadata)
                let neutral = try backend.value.processResult(preparedImage: prepared, parameters: .init())
                XCTAssertTrue(try pixels(neutral.output, raster: raster) == raster.bytes, "backend neutral exact")
                let baseline = try backend.value.processResult(preparedImage: prepared, parameters: colour)
                let coloured = try pixels(baseline.output, raster: raster)
                XCTAssertFalse(coloured == raster.bytes, "fixed colour-only baseline active")
                baselines.append(coloured)
                var pureCaps: [[UInt8]] = [], mixedCaps: [[UInt8]] = []
                for position: Float in [0, 1] {
                    let geometry = BeautyFaceShapeSlider.faceWidth.applying(position: position, to: .init())
                    let combined = BeautyFaceShapeSlider.faceWidth.applying(position: position, to: colour)
                    let pureResult = try backend.value.processResult(preparedImage: prepared, parameters: geometry)
                    let mixedResult = try backend.value.processResult(preparedImage: prepared, parameters: combined)
                    let a = try pixels(pureResult.output, raster: raster), b = try pixels(mixedResult.output, raster: raster)
                    pureCaps.append(a); mixedCaps.append(b)
                    for (kind, result, bytes, reference) in [("faceWidth", pureResult, a, raster.bytes),
                                                            ("colour-faceWidth", mixedResult, b, coloured)] {
                        let protection = protectionChanges(reference, bytes, domain: domain)
                        let response = colourResponse(reference, bytes, mask: lower)
                        XCTAssertEqual(protection.core, 0, "independent fine source cores versus current colour baseline")
                        XCTAssertEqual(protection.exterior, 0, "geometry cannot alter colour-baseline domain exterior")
                        XCTAssertEqual(protection.alpha, 0)
                        XCTAssertGreaterThan(response.changed, 16, "lower contour geometry response cannot be identity")
                        XCTAssertGreaterThan(response.rms, 0.25, "lower contour response, without claiming boundary displacement")
                        XCTAssertEqual(result.output.extent, raster.image.extent)
                        XCTAssertEqual(result.output.colorSpace?.name, colourSpace.name)
                        XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1)
                        XCTAssertEqual(result.metrics["beauty.backend.cpuGeometryCapacityFallback"] ?? 0, 0, "actual Metal witness cannot be a CPU capacity fallback")
                        records.append(["kind": kind, "layer": raster.id, "backend": backend.name,
                            "sign": position == 0 ? -1 : 1, "brightness": kind == "faceWidth" ? 0.0 : 0.10,
                            "fineCoreChangedPixels": protection.core, "geometryExteriorChangedPixels": protection.exterior,
                            "alphaChangedPixels": protection.alpha, "lowerResponseChangedPixels": response.changed,
                            "lowerResponseRMS": response.rms, "fullBoundaryDisplacementProven": false,
                            "actualMetalExecuted": backend.name == "actual-metal"])
                    }
                    let repeated = try backend.value.processResult(preparedImage: prepared, parameters: combined)
                    XCTAssertTrue(try pixels(repeated.output, raster: raster) == b, "colour-lateral repeated exact")
                }
                pure.append(pureCaps); mixed.append(mixedCaps)
                let restored = try backend.value.processResult(preparedImage: prepared, parameters: .init())
                XCTAssertTrue(try pixels(restored.output, raster: raster) == raster.bytes, "neutral after combined geometry restores source")
            }
            if engines.count == 2 {
                // Existing still-image colour contract: max channel delta 2,
                // mean RGB delta <.75; response subtraction has twice that budget.
                let baselineParity = colourResponse(baselines[0], baselines[1])
                XCTAssertLessThanOrEqual(baselineParity.maximum, 2)
                XCTAssertLessThan(baselineParity.mean, 0.75)
                for sign in 0..<2 {
                    for (kind, bytes) in [("pure-faceWidth", pure), ("colour-faceWidth", mixed)] {
                        let parity = colourResponse(bytes[0][sign], bytes[1][sign])
                        let label = "layer=\(raster.id),kind=\(kind),sign=\(sign == 0 ? -1 : 1)"
                        XCTAssertLessThanOrEqual(parity.maximum, 2, "public CPU/actual Metal RGB maximum: \(label)")
                        XCTAssertLessThan(parity.mean, 0.75, "public CPU/actual Metal RGB mean: \(label)")
                        records.append(["kind": "backend-output-parity", "outputKind": kind,
                            "layer": raster.id, "sign": sign == 0 ? -1 : 1,
                            "maximumRGBDelta": parity.maximum, "meanRGBDelta": parity.mean,
                            "actualMetalExecuted": true, "byteIdentityRequired": false])
                    }
                    let response = colourResponse(baselines[0], mixed[0][sign], mask: lower,
                        otherBaseline: baselines[1], otherActual: mixed[1][sign])
                    XCTAssertLessThanOrEqual(response.maximum, 4, "geometry response differential parity")
                    XCTAssertLessThan(response.mean, 1.5)
                    records.append(["kind": "geometry-response-parity", "layer": raster.id, "sign": sign == 0 ? -1 : 1,
                        "maximumRGBResponseDifference": response.maximum, "meanRGBResponseDifference": response.mean,
                        "actualMetalExecuted": true, "byteIdentityRequired": false])
                }
            }
        }
        try receipt(records, name: "public-colour-lateral-context-v2.json", to: destination)
    }

    private func colourResponse(_ baseline: [UInt8], _ actual: [UInt8], mask: [Bool]? = nil,
                                otherBaseline: [UInt8]? = nil, otherActual: [UInt8]? = nil)
        -> (changed: Int, maximum: Int, mean: Double, rms: Double) {
        var changed = 0, maximum = 0, absolute = 0.0, squared = 0.0, channels = 0
        for p in 0..<(baseline.count / 4) where mask?[p] ?? true {
            var pixelChanged = false
            for c in 0..<3 {
                let i = p * 4 + c
                var value = Int(actual[i]) - Int(baseline[i])
                if let otherBaseline, let otherActual { value -= Int(otherActual[i]) - Int(otherBaseline[i]) }
                pixelChanged = pixelChanged || value != 0
                maximum = max(maximum, abs(value)); absolute += Double(abs(value)); squared += Double(value * value)
                channels += 1
            }
            if pixelChanged { changed += 1 }
        }
        return (changed, maximum, absolute / Double(max(1, channels)), sqrt(squared / Double(max(1, channels))))
    }

    private func registeredControlPixel(_ x: Int, _ y: Int, probe: Probe, deformation: Deformation,
                                        raster: Raster, registration: DisplayRegistration) -> SIMD3<Double>? {
        let sourcePoint = registration.source(SIMD2(Double(x), Double(y)))
        let value = sample(raster, at: sourcePoint) { sx, sy in
            guard let p = self.inversePoint(SIMD2(Double(sx), Double(sy)), probe: probe, deformation: deformation),
                  let colour = self.sample(raster, at: p) else { return nil }
            return SIMD3(colour.x.rounded(), colour.y.rounded(), colour.z.rounded())
        }
        return value.map { SIMD3($0.x.rounded(), $0.y.rounded(), $0.z.rounded()) }
    }

    private func registrationCalibration(_ probe: Probe, raster: Raster, displayRaster: Raster,
                                         registration: DisplayRegistration) -> (qualified: Bool, rows: [[String: Any]]) {
        let displayProbe = registration.displayProbe(probe)
        var records: [[String: Any]] = [], qualified = true
        for deformation in deformations() {
            let displayPixel: (Int, Int) -> SIMD3<Double>? = { x, y in
                self.registeredControlPixel(x, y, probe: probe, deformation: deformation,
                    raster: raster, registration: registration)
            }
            let forward = findBoundary(displayProbe, raster: displayRaster, pixel: displayPixel)
            let roundtrip = findBoundary(probe, raster: raster) { x, y in
                let p = registration.display(SIMD2(Double(x), Double(y)))
                return self.sample(displayRaster, at: p, pixel: displayPixel).map {
                    SIMD3($0.x.rounded(), $0.y.rounded(), $0.z.rounded())
                }
            }
            let expected = probe.sourceCrossing + deformation.translation * probe.controlPolarity
            let forwardError = forward.position.map { abs($0 / registration.scale - expected) }
            let roundtripError = roundtrip.position.map { abs($0 - expected) }
            let passes = (forwardError.map { $0 <= 0.1 } ?? false) && (roundtripError.map { $0 <= 0.1 } ?? false)
            qualified = qualified && passes
            records.append(["knownControlOrdinal": deformation.ordinal, "qualified": passes,
                "forwardStatus": forward.status, "roundtripStatus": roundtrip.status,
                "forwardSourcePixelError": forwardError ?? Double.greatestFiniteMagnitude,
                "roundtripSourcePixelError": roundtripError ?? Double.greatestFiniteMagnitude,
                "inverseGradientBound": deformation.maximumGradient, "productionQualified": false])
        }
        return (qualified, records)
    }

    private func registeredReference(_ probe: Probe, raster: Raster, fullWidth: Int) throws -> ReferenceObservation {
        let env = ProcessInfo.processInfo.environment
        guard let scaleText = env["BEAUTY_FACE_CONTEXT_DISPLAY_SCALE"], let baseScale = Double(scaleText),
              let txText = env["BEAUTY_FACE_CONTEXT_DISPLAY_TX"], let tx = Double(txText),
              let tyText = env["BEAUTY_FACE_CONTEXT_DISPLAY_TY"], let ty = Double(tyText),
              baseScale.isFinite, baseScale > 0, tx.isFinite, ty.isFinite,
              let originalPath = env["BEAUTY_FACE_CONTEXT_REFERENCE_ORIGINAL"],
              let leftPath = env["BEAUTY_FACE_CONTEXT_REFERENCE_LEFT"],
              let rightPath = env["BEAUTY_FACE_CONTEXT_REFERENCE_RIGHT"] else {
            return ReferenceObservation(displayScale: 1, directions: [:],
                aggregates: ["registrationQualified": false, "status": "registered-reference-env-unavailable"])
        }
        let registration = DisplayRegistration(scale: baseScale * Double(fullWidth) / Double(raster.width), physicalTranslation: SIMD2(tx, ty))
        let original = try loadRaster(originalPath, id: "registered-original")
        let calibration = registrationCalibration(probe, raster: raster, displayRaster: original, registration: registration)
        let displayProbe = registration.displayProbe(probe)
        let identity = findBoundary(displayProbe, raster: original) { x, y in self.rgb(original.bytes, x, y, original) }
        let identityError = identity.position.map { abs($0 / registration.scale - probe.sourceCrossing) }
        let qualified = calibration.qualified && (identityError.map { $0 <= 0.1 } ?? false)
        var rows: [String: Any] = ["registrationQualified": qualified, "knownControlCount": calibration.rows.count,
            "calibrationWitnesses": calibration.rows, "registeredOriginalStatus": identity.status,
            "registeredOriginalSourcePixelError": identityError ?? Double.greatestFiniteMagnitude,
            "endpointReferenceRead": false, "sourceProbesChanged": false]
        guard qualified else { return ReferenceObservation(displayScale: registration.scale, directions: [:], aggregates: rows) }
        var directions: [Int: Double] = [:], endpoints: [[String: Any]] = []
        for (sign, path) in [(-1, leftPath), (1, rightPath)] {
            let reference = try loadRaster(path, id: "registered-reference")
            guard reference.width == original.width, reference.height == original.height else { throw Failure.input }
            let target = findBoundary(displayProbe, raster: reference) { x, y in self.rgb(reference.bytes, x, y, reference) }
            let direction = target.position.map { ($0 - identity.position!) * probe.controlPolarity * Double(sign) }
            if let direction { directions[sign] = direction }
            endpoints.append(["sign": sign, "measurementQualified": direction != nil,
                "status": target.status, "directionDisplayPixels": direction ?? 0])
        }
        rows["endpointReferenceRead"] = true; rows["referenceEndpointObservations"] = endpoints
        return ReferenceObservation(displayScale: registration.scale, directions: directions, aggregates: rows)
    }

    private func generatedRegistrationChecks() throws {
        try generatedPixelCentreChecks()
        let raster = generatedRaster(), probe = generatedProbe(raster)
        let registration = DisplayRegistration(scale: 0.93, physicalTranslation: SIMD2(8.5, 9.5))
        let calibration = registrationCalibration(probe, raster: raster, displayRaster: raster, registration: registration)
        XCTAssertEqual(calibration.rows.count, 24)
        for row in calibration.rows {
            XCTAssertTrue(row["qualified"] as? Bool == true,
                "generated registered forward/roundtrip ordinal=\(row["knownControlOrdinal"] ?? -1),forward=\(row["forwardSourcePixelError"] ?? -1),roundtrip=\(row["roundtripSourcePixelError"] ?? -1)")
        }
    }

    private func generatedPixelCentreChecks() throws {
        // A generated float coordinate ramp isolates affine geometry from colour
        // phase, protected material and the independent real-source calibration.
        let width = 256, height = 192
        var values = [Float](repeating: 1, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let index = (y * width + x) * 4
            values[index] = Float(x) / Float(width)
            values[index + 1] = Float(y) / Float(height)
            values[index + 2] = 0
        } }
        let data = values.withUnsafeBytes { Data($0) }
        let source = CIImage(bitmapData: data, bytesPerRow: width * 16,
            size: CGSize(width: width, height: height), format: .RGBAf, colorSpace: nil)
        let context = CIContext(options: [.workingColorSpace: NSNull(), .outputColorSpace: NSNull()])
        for downscale: Double in [1, 0.5] {
            let outWidth = Int(Double(width) * downscale), outHeight = Int(Double(height) * downscale)
            let bounds = CGRect(x: 0, y: 0, width: outWidth, height: outHeight)
            let image = source.transformed(by: CGAffineTransform(scaleX: downscale, y: downscale)).cropped(to: bounds)
            var actual = [Float](repeating: 0, count: outWidth * outHeight * 4)
            actual.withUnsafeMutableBytes { storage in
                context.render(image, toBitmap: storage.baseAddress!, rowBytes: outWidth * 16,
                    bounds: bounds, format: .RGBAf, colorSpace: nil)
            }
            var maximumSourceCoordinateError = 0.0
            for y in stride(from: 8, to: outHeight - 8, by: 11) {
                for x in stride(from: 8, to: outWidth - 8, by: 13) {
                    let index = (y * outWidth + x) * 4
                    let expectedX = (Double(x) + 0.5) / downscale - 0.5
                    let expectedY = (Double(y) + 0.5) / downscale - 0.5
                    let xError = abs(Double(actual[index]) * Double(width) - expectedX)
                    let yError = abs(Double(actual[index + 1]) * Double(height) - expectedY)
                    maximumSourceCoordinateError = max(maximumSourceCoordinateError, max(xError, yError))
                    XCTAssertEqual(actual[index + 3], 1, "generated affine opaque coordinate context")
                }
            }
            XCTAssertLessThanOrEqual(maximumSourceCoordinateError, 0.001, "generated CI physical pixel-centre convention")
            let physicalTranslation = SIMD2<Double>(8.5, 9.5), baseScale = 0.93
            let registration = DisplayRegistration(scale: baseScale / downscale, physicalTranslation: physicalTranslation)
            let originalIndex = SIMD2<Double>(171.25, 98.5)
            let previewIndex = (originalIndex + SIMD2<Double>(repeating: 0.5)) * downscale - SIMD2<Double>(repeating: 0.5)
            let expectedDisplay = (originalIndex + SIMD2<Double>(repeating: 0.5)) * baseScale + physicalTranslation - SIMD2<Double>(repeating: 0.5)
            let display = registration.display(previewIndex)
            XCTAssertEqual(display.x, expectedDisplay.x, accuracy: 1e-10)
            XCTAssertEqual(display.y, expectedDisplay.y, accuracy: 1e-10)
            let roundtrip = registration.source(display)
            XCTAssertEqual(roundtrip.x, previewIndex.x, accuracy: 1e-10)
            XCTAssertEqual(roundtrip.y, previewIndex.y, accuracy: 1e-10)
        }
    }

    private func loadRaster(_ path: String, id: String) throws -> Raster {
        let url = URL(fileURLWithPath: path).standardizedFileURL
        let attributes: URLResourceValues
        do { attributes = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey]) }
        catch { throw Failure.input }
        guard attributes.isRegularFile == true, attributes.isSymbolicLink != true,
              let size = attributes.fileSize, size > 0, size <= BeautyConfiguration.defaultMaximumInputByteCount,
              let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) else { throw Failure.input }
        let value = try BeautyStillImageCanonicalizer().canonicalize(image: image, metadata: metadata,
            maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
        return Raster(id: id, image: value.ciImage, width: value.width, height: value.height, bytes: Array(value.rgba8Data))
    }

    func testFACEContextV2ProtectedCompositionHasIndependentCoreTruth() throws {
        let raster = generatedRaster(), count = raster.width * raster.height
        var core = [Bool](repeating: false, count: count)
        for y in 92...100 { for x in 118...138 { core[y * raster.width + x] = true } }
        let domain = Domains(legal: [Bool](repeating: true, count: count), core: core)
        let probe = generatedProbe(raster)
        for deformation in deformations() {
            var actual = raster.bytes, changes = 0
            for y in 0..<raster.height { for x in 0..<raster.width {
                let q = SIMD2(Double(x), Double(y))
                guard let p = inversePoint(q, probe: probe, deformation: deformation),
                      legalFootprint(q, raster: raster, domain: domain),
                      legalFootprint(p, raster: raster, domain: domain),
                      let colour = sample(raster, at: p) else { continue }
                let i = (y * raster.width + x) * 4
                let values = [colour.x, colour.y, colour.z]
                for channel in 0..<3 {
                    actual[i + channel] = UInt8(min(255, max(0, Int(values[channel].rounded()))))
                }
                if (0..<3).contains(where: { actual[i + $0] != raster.bytes[i + $0] }) { changes += 1 }
            } }
            var coreChanges = 0, alphaChanges = 0
            for pixel in core.indices {
                let i = pixel * 4
                if core[pixel], (0..<4).contains(where: { actual[i + $0] != raster.bytes[i + $0] }) { coreChanges += 1 }
                if actual[i + 3] != raster.bytes[i + 3] { alphaChanges += 1 }
            }
            XCTAssertEqual(coreChanges, 0, "composition source/destination core ordinal=\(deformation.ordinal)")
            XCTAssertEqual(alphaChanges, 0)
            let actualBoundary = findBoundary(probe, raster: raster) { x, y in self.rgb(actual, x, y, raster) }
            let certificate = knownBoundary(probe, deformation: deformation, raster: raster,
                domain: domain, composeProtected: true)
            XCTAssertEqual(actualBoundary.position ?? .greatestFiniteMagnitude, certificate.position ?? .greatestFiniteMagnitude,
                accuracy: 0.001, "composition observer matches its actual protected pixels")
            XCTAssertEqual(actualBoundary.position ?? .greatestFiniteMagnitude, 0, accuracy: 0.1,
                "the complete frozen source crossing remains at its known original position")
            if deformation.ordinal == 0 {
                XCTAssertTrue(actual == raster.bytes)
                XCTAssertTrue(certificate.fullTruthQualified)
            } else {
                XCTAssertFalse(certificate.fullTruthQualified, "core-clipped control cannot qualify full displacement")
                XCTAssertGreaterThan(changes, 0, "composition still exercises free context; no-op is insufficient")
            }
        }
    }

    func testFACEContextV2RejectsWeakMultipleTransparentAndUnresolvedWidth() throws {
        let base = generatedRaster(), probe = generatedProbe(base)
        let weak = Probe(center: probe.center, normal: probe.normal, tangent: probe.tangent,
            inside: SIMD3(120, 100, 80), outside: SIMD3(122, 102, 82), search: probe.search,
            sourceCrossing: 0, controlPolarity: -1, span: probe.span)
        XCTAssertEqual(findBoundary(weak, raster: base, pixel: { x, y in self.rgb(base.bytes, x, y, base) }).status,
            "weak-palette")
        for kind in [1, 2, 3] {
            let raster = generatedRaster(kind: kind)
            let boundary = findBoundary(probe, raster: raster) { x, y in self.rgb(raster.bytes, x, y, raster) }
            XCTAssertNil(boundary.position, "source negative kind=\(kind),crossings=\(boundary.crossingCount),status=\(boundary.status)")
            XCTAssertFalse(boundary.fullTruthQualified)
        }
    }

    private func generatedRaster(kind: Int = 0) -> Raster {
        let width = 256, height = 192
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            var mix = min(1, max(0, Double(x - 120) / 16))
            if kind == 1 && x >= 140 { mix = max(0, 1 - Double(x - 140) / 8) }
            if kind == 2 && (126...130).contains(x) { mix = 0.5 }
            let inside = [220.0, 180.0, 160.0], outside = [20.0, 30.0, 40.0]
            let i = (y * width + x) * 4
            for channel in 0..<3 { bytes[i + channel] = UInt8((inside[channel] * (1 - mix) + outside[channel] * mix).rounded()) }
            if kind == 3 && x == 128 && y == 96 { bytes[i + 3] = 254 }
        } }
        let image = CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: colourSpace)
        return Raster(id: "generated-context", image: image, width: width, height: height, bytes: bytes)
    }

    private func generatedProbe(_ raster: Raster) -> Probe {
        Probe(center: SIMD2(128, 96), normal: SIMD2(1, 0), tangent: SIMD2(0, 1),
            inside: SIMD3(220, 180, 160), outside: SIMD3(20, 30, 40), search: 24,
            sourceCrossing: 0, controlPolarity: -1, span: Double(raster.width))
    }

    private func deformations() -> [Deformation] {
        var result = [Deformation(ordinal: 0, translation: 0, a: 1, b: 0, c: 0, d: 1)]
        for sign: Double in [-1, 1] { for magnitude in [0.25, 0.5, 1, 2, 4] {
            result.append(Deformation(ordinal: result.count, translation: sign * magnitude, a: 1, b: 0, c: 0, d: 1))
        } }
        // Inverse displacement gradient bank, Frobenius norm <= .45.
        let matrices = [(1.45, 0.0, 0.0, 1.0), (0.55, 0.0, 0.0, 1.0),
            (1.0, 0.30, 0.0, 1.0), (1.0, -0.30, 0.0, 1.0),
            (cos(0.2), -sin(0.2), sin(0.2), cos(0.2)),
            (cos(0.2), sin(0.2), -sin(0.2), cos(0.2))]
        for (a, b, c, d) in matrices { for translation: Double in [-2, 2] {
            result.append(Deformation(ordinal: result.count, translation: translation, a: a, b: b, c: c, d: d))
        } }
        result.append(Deformation(ordinal: result.count, translation: 0, a: 1, b: 0.2, c: 0.1, d: 1))
        return result // identity plus 23 source-only bounded controls
    }

    private func selectProbe(_ control: BeautyFaceShapeSlider, side: Double, raster: Raster,
                             frame: Frame, domain: Domains) -> (probe: Probe?, examined: Int, eligible: Int, stages: [[String: Any]]) {
        let y: Double = control == .faceWidth ? 0.47 : control == .cheekbone ? 0.22 : -0.10
        let normal = frame.axisX * side, tangent = frame.axisY
        let polarity = control == .temple ? 1.0 : -1.0
        var examined = 0, eligible = 0
        var stages: [[String: Any]] = []
        // Source-only predeclared arc samples. No output/ref-dependent point,
        // region enlargement or gradient-bank adjustment is permitted.
        for offset in [0.0, -0.02, 0.02, -0.04, 0.04] {
            examined += 1
            guard let raw = frame.contour.filter({ frame.local($0).x * side > 0 }).min(by: {
                abs(frame.local($0).y / frame.chin - y - offset) < abs(frame.local($1).y / frame.chin - y - offset)
            }) else {
                stages.append(["sourceCandidateOrdinal": examined - 1, "rejectionStage": "missing-source-contour"])
                continue
            }
            var local = frame.local(raw); local.y = (y + offset) * frame.chin
            let center = frame.image(local)
            guard let inside = sample(raster, at: center - normal * max(6, frame.span * 0.06)),
                  let outside = sample(raster, at: center + normal * max(6, frame.span * 0.04)) else {
                stages.append(["sourceCandidateOrdinal": examined - 1, "rejectionStage": "prototype-raster-footprint"])
                continue
            }
            guard square(outside - inside) >= 32 * 32 else {
                stages.append(["sourceCandidateOrdinal": examined - 1, "rejectionStage": "prototype-separation"])
                continue
            }
            let prototype = Probe(center: center, normal: normal, tangent: tangent, inside: inside,
                outside: outside, search: max(8, Int(ceil(frame.span * 0.065))), sourceCrossing: 0, controlPolarity: polarity, span: frame.span)
            let sourceBoundary = findBoundary(prototype, raster: raster, pixel: { x, y in self.rgb(raster.bytes, x, y, raster) })
            guard let crossing = sourceBoundary.position else {
                stages.append(["sourceCandidateOrdinal": examined - 1, "rejectionStage": "source-boundary",
                    "sourceCrossings": sourceBoundary.crossingCount, "boundaryStatus": sourceBoundary.status,
                    "protectedContextTexelCount": coreContextCount(prototype, raster: raster, domain: domain)])
                continue
            }
            let probe = Probe(center: center, normal: normal, tangent: tangent, inside: inside,
                outside: outside, search: prototype.search, sourceCrossing: crossing, controlPolarity: polarity, span: frame.span)
            var qualified = true
            for deformation in deformations() {
                let boundary = knownBoundary(probe, deformation: deformation, raster: raster, domain: domain)
                let error = boundary.position.map { abs($0 - crossing - deformation.translation * polarity) }
                if boundary.fullTruthQualified && (error.map({ $0 <= 0.1 }) ?? false) { continue }
                qualified = false
                stages.append(["sourceCandidateOrdinal": examined - 1, "rejectionStage": "known-control",
                    "sourceCrossings": sourceBoundary.crossingCount, "firstRejectControlOrdinal": deformation.ordinal,
                    "knownControlCrossings": boundary.crossingCount, "boundaryStatus": boundary.status,
                    "footprintVeto": boundary.status == "incomplete-opaque-context",
                    "errorVeto": error.map({ $0 > 0.1 }) ?? false,
                    "protectedContextTexelCount": coreContextCount(probe, raster: raster, domain: domain),
                    "absoluteError": error ?? Double.greatestFiniteMagnitude])
                break
            }
            if qualified {
                stages.append(["sourceCandidateOrdinal": examined - 1, "rejectionStage": "qualified", "sourceCrossings": 1,
                    "protectedContextTexelCount": coreContextCount(probe, raster: raster, domain: domain)])
                eligible += 1; return (probe, examined, eligible, stages)
            }
        }
        return (nil, examined, eligible, stages)
    }

    /// C1 bounded inverse control. Componentwise tanh bounds |u| by .06 span;
    /// its diagonal derivative is <=1, so the Frobenius ||Du|| <= .45 everywhere.
    /// Bias is source-only: the predeclared truth maps exactly to source pivot.
    /// These controls may move background/context and never qualify production.
    private func inversePoint(_ q: SIMD2<Double>, probe: Probe, deformation: Deformation) -> SIMD2<Double>? {
        let cap = probe.span * 0.06, limit = cap / sqrt(2)
        let translation = probe.normal * (deformation.translation * probe.controlPolarity)
        guard limit > 0, abs(translation.x) < limit, abs(translation.y) < limit,
              deformation.maximumGradient <= 0.45 + 1e-12 else { return nil }
        let pivot = probe.center + probe.normal * probe.sourceCrossing
        let local = q - pivot - translation
        let x = local.x * probe.normal.x + local.y * probe.normal.y
        let y = local.x * probe.tangent.x + local.y * probe.tangent.y
        let raw = probe.normal * ((1 - deformation.a) * x - deformation.b * y)
            + probe.tangent * (-deformation.c * x + (1 - deformation.d) * y)
        let bias = SIMD2(limit * atanh(translation.x / limit), limit * atanh(translation.y / limit))
        let displacement = SIMD2(limit * tanh((raw.x + bias.x) / limit), limit * tanh((raw.y + bias.y) / limit))
        return q - displacement
    }

    private func knownBoundary(_ probe: Probe, deformation: Deformation, raster: Raster,
                               domain: Domains, composeProtected: Bool = false) -> Boundary {
        let truth = probe.sourceCrossing + deformation.translation * probe.controlPolarity
        var clippedTruth = false
        let identity = deformation.translation == 0 && deformation.a == 1 && deformation.b == 0 &&
            deformation.c == 0 && deformation.d == 1
        for t in stride(from: truth - 1, through: truth + 1, by: 0.125) {
            let q = probe.center + probe.normal * t
            let ix = Int(floor(q.x)), iy = Int(floor(q.y))
            for dy in 0...1 { for dx in 0...1 {
                let p = SIMD2(Double(ix + dx), Double(iy + dy))
                guard let inverse = inversePoint(p, probe: probe, deformation: deformation),
                      opaqueFootprint(p, raster: raster), opaqueFootprint(inverse, raster: raster) else {
                    return Boundary(position: nil, crossingCount: 0, status: "incomplete-opaque-context", fullTruthQualified: false)
                }
                if composeProtected && !identity && (!legalFootprint(p, raster: raster, domain: domain) ||
                    !legalFootprint(inverse, raster: raster, domain: domain)) { clippedTruth = true }
            } }
        }
        let observed = findBoundary(probe, raster: raster) { x, y in
            let q = SIMD2(Double(x), Double(y))
            guard let p = self.inversePoint(q, probe: probe, deformation: deformation) else { return nil }
            if composeProtected && (!self.legalFootprint(q, raster: raster, domain: domain) ||
                !self.legalFootprint(p, raster: raster, domain: domain)) {
                return self.rgb(raster.bytes, x, y, raster)
            }
            guard let value = self.sample(raster, at: p) else { return nil }
            return SIMD3(value.x.rounded(), value.y.rounded(), value.z.rounded())
        }
        return Boundary(position: observed.position, crossingCount: observed.crossingCount,
            status: clippedTruth ? "composed-core-clipped-no-full-truth" : observed.status,
            fullTruthQualified: !clippedTruth && observed.position != nil)
    }

    private func findBoundary(_ probe: Probe, raster: Raster,
                              pixel: @escaping (Int, Int) -> SIMD3<Double>?) -> Boundary {
        let vector = probe.outside - probe.inside, midpoint = (probe.outside + probe.inside) * 0.5
        let energy = square(vector)
        guard energy >= 32 * 32 else { return Boundary(position: nil, crossingCount: 0, status: "weak-palette") }
        var rows: [(Double, Double)] = []
        for tick in (-probe.search * 16)...(probe.search * 16) {
            let t = Double(tick) / 16
            guard let value = sample(raster, at: probe.center + probe.normal * t, pixel: pixel) else {
                return Boundary(position: nil, crossingCount: 0, status: "incomplete-opaque-context")
            }
            let q = value - midpoint
            rows.append((t, (q.x * vector.x + q.y * vector.y + q.z * vector.z) / energy))
        }
        func crossings(_ level: Double) -> (positions: [Double], plateau: Bool) {
            var positions = [Double](), plateau = false
            for (a, b) in zip(rows, rows.dropFirst()) {
                let x = a.1 - level, y = b.1 - level
                if abs(x) < 1e-10 && abs(y) < 1e-10 { plateau = true; continue }
                if (x < 0 && y >= 0) || (x > 0 && y <= 0) {
                    let p = a.0 + (b.0 - a.0) * (-x) / (y - x)
                    if positions.last.map({ abs($0 - p) > 0.02 }) ?? true { positions.append(p) }
                }
            }
            return (positions, plateau)
        }
        let crossing = crossings(0), low = crossings(-0.25), high = crossings(0.25)
        guard crossing.positions.count == 1, !crossing.plateau else {
            return Boundary(position: nil, crossingCount: crossing.positions.count,
                status: crossing.plateau ? "unresolved-boundary-width" : "multiple-or-missing-boundaries")
        }
        guard rows.first!.1 < -0.25, rows.last!.1 > 0.25,
              low.positions.count == 1, high.positions.count == 1, !low.plateau, !high.plateau,
              low.positions[0] < crossing.positions[0], crossing.positions[0] < high.positions[0] else {
            return Boundary(position: nil, crossingCount: 1, status: "unresolved-palette-width")
        }
        return Boundary(position: crossing.positions[0], crossingCount: 1, status: "unique-calibrated-context-boundary")
    }

    private func opaqueFootprint(_ p: SIMD2<Double>, raster: Raster) -> Bool {
        let x = Int(floor(p.x)), y = Int(floor(p.y))
        guard x >= 0, y >= 0, x + 1 < raster.width, y + 1 < raster.height else { return false }
        return [y * raster.width + x, y * raster.width + x + 1,
            (y + 1) * raster.width + x, (y + 1) * raster.width + x + 1].allSatisfy { raster.bytes[$0 * 4 + 3] == 255 }
    }

    private func coreContextCount(_ probe: Probe, raster: Raster, domain: Domains) -> Int {
        var texels = Set<Int>()
        for tick in (-probe.search * 16)...(probe.search * 16) {
            let p = probe.center + probe.normal * (Double(tick) / 16)
            let x = Int(floor(p.x)), y = Int(floor(p.y))
            guard x >= 0, y >= 0, x + 1 < raster.width, y + 1 < raster.height else { continue }
            for index in [y * raster.width + x, y * raster.width + x + 1,
                (y + 1) * raster.width + x, (y + 1) * raster.width + x + 1] where domain.core[index] {
                texels.insert(index)
            }
        }
        return texels.count
    }

    private func square(_ p: SIMD3<Double>) -> Double { p.x * p.x + p.y * p.y + p.z * p.z }
    private func rgb(_ bytes: [UInt8], _ x: Int, _ y: Int, _ raster: Raster) -> SIMD3<Double>? {
        guard x >= 0, y >= 0, x < raster.width, y < raster.height else { return nil }
        let i = (y * raster.width + x) * 4
        guard bytes[i + 3] == 255 else { return nil }
        return SIMD3(Double(bytes[i]), Double(bytes[i + 1]), Double(bytes[i + 2]))
    }
    private func sample(_ raster: Raster, at p: SIMD2<Double>,
                        pixel: ((Int, Int) -> SIMD3<Double>?)? = nil) -> SIMD3<Double>? {
        let ix = Int(floor(p.x)), iy = Int(floor(p.y)), fx = p.x - Double(ix), fy = p.y - Double(iy)
        let get = pixel ?? { x, y in self.rgb(raster.bytes, x, y, raster) }
        guard let a = get(ix, iy), let b = get(ix + 1, iy), let c = get(ix, iy + 1), let d = get(ix + 1, iy + 1) else { return nil }
        return a * (1 - fx) * (1 - fy) + b * fx * (1 - fy) + c * (1 - fx) * fy + d * fx * fy
    }
    private func legalFootprint(_ p: SIMD2<Double>, raster: Raster, domain: Domains) -> Bool {
        let x = Int(floor(p.x)), y = Int(floor(p.y))
        guard x >= 0, y >= 0, x + 1 < raster.width, y + 1 < raster.height else { return false }
        return [y * raster.width + x, y * raster.width + x + 1,
            (y + 1) * raster.width + x, (y + 1) * raster.width + x + 1].allSatisfy { domain.legal[$0] && !domain.core[$0] }
    }

    private func generatedChecks() throws {
        let width = 256, height = 192
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let mix = min(1, max(0, Double(x - 120) / 16))
            for (c, colours) in [(0, (220.0, 20.0)), (1, (180.0, 30.0)), (2, (160.0, 40.0))] {
                bytes[(y * width + x) * 4 + c] = UInt8((colours.0 * (1 - mix) + colours.1 * mix).rounded())
            }
        } }
        let image = CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4, size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: colourSpace)
        let raster = Raster(id: "generated-colour-edge", image: image, width: width, height: height, bytes: bytes)
        let domain = Domains(legal: [Bool](repeating: true, count: width * height), core: [Bool](repeating: false, count: width * height))
        let probe = Probe(center: SIMD2(128, 96), normal: SIMD2(1, 0), tangent: SIMD2(0, 1),
            inside: SIMD3(220, 180, 160), outside: SIMD3(20, 30, 40), search: 24, sourceCrossing: 0, controlPolarity: -1, span: Double(width))
        let neutral = findBoundary(probe, raster: raster, pixel: { x, y in self.rgb(bytes, x, y, raster) })
        XCTAssertNotNil(neutral.position)
        for deformation in deformations() {
            let actual = knownBoundary(probe, deformation: deformation, raster: raster, domain: domain)
            XCTAssertNotNil(actual.position)
            XCTAssertEqual(actual.position ?? .greatestFiniteMagnitude, -deformation.translation, accuracy: 0.1)
            if deformation.translation > 1 { XCTAssertTrue((actual.position ?? 0) < -1, "reverse direction is not a positive effect") }
        }
        XCTAssertEqual(neutral.position ?? .greatestFiniteMagnitude, 0, accuracy: 0.1)
        XCTAssertFalse((neutral.position ?? 0) > 1, "identity cannot pass target activity")
        var blocked = domain.core
        for y in 92...100 { for x in 118...138 { blocked[y * width + x] = true } }
        let protected = Domains(legal: domain.legal, core: blocked)
        let readable = knownBoundary(probe, deformation: deformations()[0], raster: raster, domain: protected)
        XCTAssertEqual(readable.position ?? .greatestFiniteMagnitude, 0, accuracy: 0.1)
        XCTAssertTrue(readable.fullTruthQualified, "identity protected RGB remains observable context")
        let control = deformations().first { $0.translation == 2 && $0.a == 1 && $0.b == 0 }!
        let clipped = knownBoundary(probe, deformation: control, raster: raster, domain: protected, composeProtected: true)
        XCTAssertFalse(clipped.fullTruthQualified, "clipped composition cannot inherit free-warp translation truth")
        XCTAssertEqual(clipped.status, "composed-core-clipped-no-full-truth")
        XCTAssertEqual(clipped.position ?? .greatestFiniteMagnitude, 0, accuracy: 0.1)
        for deformation in deformations() {
            XCTAssertLessThanOrEqual(deformation.maximumGradient, 0.45 + 1e-12)
            var maximum = 0.0
            for y in stride(from: 16, to: height - 16, by: 16) { for x in stride(from: 16, to: width - 16, by: 16) {
                let q = SIMD2(Double(x), Double(y))
                let p = try XCTUnwrap(inversePoint(q, probe: probe, deformation: deformation))
                maximum = max(maximum, hypot(q.x - p.x, q.y - p.y))
            } }
            XCTAssertLessThanOrEqual(maximum, probe.span * 0.06 + 1e-10)
        }
        XCTAssertEqual(deformations().count, 24)
    }

    private func layers(_ path: String) throws -> [Raster] {
        let url = URL(fileURLWithPath: path)
        let attributes = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        guard attributes.isRegularFile == true, attributes.isSymbolicLink != true,
              let size = attributes.fileSize, size > 0, size <= BeautyConfiguration.defaultMaximumInputByteCount,
              let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) else { throw Failure.input }
        func make(_ image: CIImage, id: String) throws -> Raster {
            let value = try BeautyStillImageCanonicalizer().canonicalize(image: image, metadata: metadata,
                maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
            return Raster(id: id, image: value.ciImage, width: value.width, height: value.height, bytes: Array(value.rgba8Data))
        }
        let full = try make(image, id: "full"), scale = min(1, 960 / Double(max(full.width, full.height)))
        let preview = full.image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            .cropped(to: CGRect(x: 0, y: 0, width: floor(Double(full.width) * scale), height: floor(Double(full.height) * scale)))
        return [full, try make(preview, id: "preview960")]
    }
    private func pixels(_ image: CIImage, raster: Raster) throws -> [UInt8] {
        guard image.extent == raster.image.extent else { throw Failure.input }
        var result = [UInt8](repeating: 0, count: raster.width * raster.height * 4)
        CIContext(options: [.workingColorSpace: colourSpace, .outputColorSpace: colourSpace]).render(image,
            toBitmap: &result, rowBytes: raster.width * 4, bounds: image.extent, format: .RGBA8, colorSpace: colourSpace)
        return result
    }

    private func sourceFrame(_ raster: Raster) throws -> Frame {
        var detector = BeautyFaceDetector.production()
        let detection = detector.detect(image: raster.image, metadata: metadata, imageExtent: raster.image.extent.size, purpose: .geometryAndLocalSupport)
        guard detection.summary.availability == .usable, detection.observations.count == 1,
              let observation = detection.observations.first, let contour = observation.observedFaceSupport?.contour, contour.count >= 7,
              let eyes = observation.observedEyeSupport, let left = eyes.first(where: { $0.side == .left })?.contour,
              let right = eyes.first(where: { $0.side == .right })?.contour, left.count >= 4, right.count >= 4,
              let brows = observation.observedEyebrowSupport, let lb = brows.left, let rb = brows.right, lb.count >= 4, rb.count >= 4,
              let nose = observation.observedNoseSupport, nose.contour.count >= 4,
              let lips = observation.observedLipSupport?.outer, lips.count >= 4 else { throw Failure.support }
        func point(_ p: CoordinatePoint) -> SIMD2<Double> { SIMD2(p.x * Double(raster.width), p.y * Double(raster.height)) }
        func mean(_ values: [CoordinatePoint]) -> SIMD2<Double> { values.map(point).reduce(.zero, +) / Double(values.count) }
        let vector = mean(right) - mean(left), norm = hypot(vector.x, vector.y)
        guard norm > 4 else { throw Failure.support }
        let axisX = vector / norm, axisY = SIMD2(-axisX.y, axisX.x), origin = (mean(left) + mean(right)) * 0.5
        let curve = contour.map(point), span = curve.map(\.x).max()! - curve.map(\.x).min()!
        let chin = curve.map { p in let v = p - origin; return v.x * axisY.x + v.y * axisY.y }.max()!
        guard span > 8, chin > 8 else { throw Failure.support }
        let features = [left, right, lb, rb, nose.contour + nose.crest, lips].map { values -> CGRect in
            let points = values.map(point), margin = max(2, span * 0.008)
            guard !points.isEmpty else { return .null }
            return CGRect(x: points.map(\.x).min()! - margin, y: points.map(\.y).min()! - margin,
                width: points.map(\.x).max()! - points.map(\.x).min()! + 2 * margin,
                height: points.map(\.y).max()! - points.map(\.y).min()! + 2 * margin)
        }
        return Frame(contour: curve, origin: origin, axisX: axisX, axisY: axisY, span: span, chin: chin, features: features)
    }

    private func domains(_ raster: Raster, frame: Frame) throws -> Domains {
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let url = package.appendingPathComponent(".build/face-reference/protection-masks-v2/semantic_core_union.png")
        let data = try Data(contentsOf: url)
        guard SHA256.hash(data: data).map({ String(format: "%02x", $0) }).joined() == "f907f32982aac47b2ad0cf50d7c4a4ec898b5af2ff49c8865378251bd9d3a640",
              let image = CIImage(data: data) else { throw Failure.annotation }
        let mw = Int(image.extent.width), mh = Int(image.extent.height)
        let mask = Raster(id: "frozen-source-core", image: image, width: mw, height: mh, bytes: [])
        let maskBytes = try pixels(image, raster: mask)
        guard mw > 0, mh > 0, abs(Double(mw) / Double(mh) - Double(raster.width) / Double(raster.height)) < 0.002 else { throw Failure.annotation }
        var legal = [Bool](repeating: false, count: raster.width * raster.height), core = legal
        var curve = frame.contour
        if frame.local(curve[0]).x > frame.local(curve.last!).x { curve.reverse() }
        let left = frame.local(curve[0]), right = frame.local(curve.last!)
        curve = [frame.image(SIMD2(left.x * 0.96, -frame.chin * 0.32)), frame.image(SIMD2(left.x, -frame.chin * 0.12))]
            + curve + [frame.image(SIMD2(right.x, -frame.chin * 0.12)), frame.image(SIMD2(right.x * 0.96, -frame.chin * 0.32))]
        for y in 0..<raster.height { for x in 0..<raster.width {
            let index = y * raster.width + x, p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let mx = min(mw - 1, Int((Double(x) + 0.5) * Double(mw) / Double(raster.width)))
            let my = min(mh - 1, Int((Double(y) + 0.5) * Double(mh) / Double(raster.height)))
            core[index] = maskBytes[(my * mw + mx) * 4] >= 128 || frame.features.contains { $0.contains(CGPoint(x: p.x, y: p.y)) }
            var inside = false
            for (a, b) in zip(curve, Array(curve.dropFirst()) + [curve[0]]) where (a.y > p.y) != (b.y > p.y) {
                if p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x { inside.toggle() }
            }
            let radius = inside ? frame.span * 0.20 : frame.span * 0.06 + 2
            for (a, b) in zip(curve, curve.dropFirst()) {
                let v = b - a, vv = v.x * v.x + v.y * v.y
                if vv == 0 { continue }
                let t = max(0, min(1, ((p - a).x * v.x + (p - a).y * v.y) / vv)), q = p - a - v * t
                if q.x * q.x + q.y * q.y <= radius * radius { legal[index] = true; break }
            }
        } }
        return Domains(legal: legal, core: core)
    }
    private func protectionChanges(_ source: [UInt8], _ actual: [UInt8], domain: Domains) -> (core: Int, exterior: Int, alpha: Int) {
        var core = 0, exterior = 0, alpha = 0
        for p in domain.core.indices {
            let i = p * 4, changed = (0..<4).contains { source[i + $0] != actual[i + $0] }
            if changed && domain.core[p] { core += 1 }
            if changed && !domain.legal[p] { exterior += 1 }
            if source[i + 3] != actual[i + 3] { alpha += 1 }
        }
        return (core, exterior, alpha)
    }
    private func outputDirectory() throws -> URL {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_OUTPUT"] else { throw Failure.output }
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let allowed = package.appendingPathComponent(".build/face-reference").standardizedFileURL
        let output = URL(fileURLWithPath: path, isDirectory: true).standardizedFileURL
        guard output.path.hasPrefix(allowed.path + "/"), output.resolvingSymlinksInPath().path == output.path else { throw Failure.output }
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        return output
    }
    private func receipt(_ records: [[String: Any]], name: String, to directory: URL) throws {
        let url = directory.appendingPathComponent(name)
        guard !FileManager.default.fileExists(atPath: url.path) else { throw Failure.output }
        try JSONSerialization.data(withJSONObject: ["schema": "source-colour-boundary-context/v2", "sourceCount": 1,
            "sourceOnlySelection": true, "rasterLayers": ["full", "preview960"], "appearanceParity": false,
            "fullSDKRegression": false, "registeredGradientBankOnly": true,
            "contextIncludesOpaqueProtectedRGB": true, "controlWarpProductionQualified": false,
            "gradientConvention": "inverse-displacement Frobenius norm <= .45",
            "controlBankCount": 24, "records": records],
            options: [.sortedKeys, .prettyPrinted]).write(to: url)
    }
}
