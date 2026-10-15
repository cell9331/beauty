import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import XCTest
@testable import BeautySDK

/// Independent source-owned colour-boundary oracle. It preserves the older
/// constant-translation and photographic diagnostics. Raw media, source arcs,
/// colour prototypes and masks stay in this invocation/ignored owner files.
final class BeautyEngineSourceContourEdgeTests: XCTestCase {
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
    }
    private struct Deformation {
        let ordinal: Int, translation: Double
        // Matrix in the source normal/tangent basis, mapping source to output.
        let a: Double, b: Double, c: Double, d: Double
    }
    private struct Boundary {
        let position: Double?
        let crossingCount: Int
        let status: String
    }

    func testFACEEdgeV1GeneratedKnownNonuniformCorrectness() throws {
        // This ordinary correctness entry always executes the generated bank,
        // including when a real-source environment is set for adjacent tests.
        try generatedChecks()
    }

    func testFACEEdgeV1SourceOnlyKnownNonuniformControls() throws {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedChecks(); return
        }
        let destination = try outputDirectory()
        var records: [[String: Any]] = []
        for raster in try layers(path) {
            let frame = try sourceFrame(raster), domain = try domains(raster, frame: frame)
            for control in controls { for side in [-1.0, 1] {
                let selection = selectProbe(control, side: side, raster: raster, frame: frame, domain: domain)
                XCTAssertNotNil(selection.probe, "source-only legal colour arc is unqualified: \(raster.id) \(control.rawValue) \(side)")
                var rejectionCounts: [String: Int] = [:]
                for stage in selection.stages {
                    if let reason = stage["rejectionStage"] as? String { rejectionCounts[reason, default: 0] += 1 }
                }
                records.append(["layer": raster.id, "control": control.rawValue, "sideOrdinal": side < 0 ? 0 : 1,
                    "eligibleSourceCandidateCount": selection.eligible, "sourceCandidatesExamined": selection.examined,
                    "sourceQualified": selection.probe != nil, "candidateOutputRead": false,
                    "candidateStages": selection.stages, "rejectionCounts": rejectionCounts])
                guard let probe = selection.probe else { continue }
                for deformation in deformations() {
                    let observation = knownBoundary(probe, deformation: deformation, raster: raster, domain: domain)
                    let expected = probe.sourceCrossing + deformation.translation * probe.controlPolarity
                    let error = observation.position.map { abs($0 - expected) } ?? Double.greatestFiniteMagnitude
                    XCTAssertLessThanOrEqual(error, 0.1, "known colour-edge translation/affine truth")
                    records.append(["layer": raster.id, "control": control.rawValue, "sideOrdinal": side < 0 ? 0 : 1,
                        "knownControlOrdinal": deformation.ordinal, "knownTranslationPixels": deformation.translation,
                        "crossingCount": observation.crossingCount, "status": observation.status,
                        "absoluteError": error, "sourceAllFootprintsLegal": observation.status != "incomplete-source-footprint"])
                }
            } }
        }
        try receipt(records, name: "source-only-colour-edge-v1.json", to: destination)
    }

    func testFACEEdgeV1PublicPhotoDirectionAndProtection() throws {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try generatedChecks(); return
        }
        let destination = try outputDirectory()
        var records: [[String: Any]] = []
        for raster in try layers(path) {
            let frame = try sourceFrame(raster), domain = try domains(raster, frame: frame)
            // All source choices and colour models complete before rendering.
            var probes: [BeautyFaceShapeSlider: [Probe?]] = [:]
            for control in controls {
                probes[control] = [-1.0, 1].map { selectProbe(control, side: $0, raster: raster, frame: frame, domain: domain).probe }
            }
            let engine = try BeautyEngine()
            guard let cg = CIContext().createCGImage(raster.image, from: raster.image.extent, format: .RGBA8, colorSpace: colourSpace)
            else { throw Failure.input }
            let prepared = try engine.prepareStillImage(image: cg, metadata: metadata)
            let neutral = try engine.processResult(preparedImage: prepared, parameters: .init())
            XCTAssertTrue(try pixels(neutral.output, raster: raster) == raster.bytes, "neutral RGBA exact identity")
            for control in controls { for sign: Double in [-1, 1] {
                var previous = [0.0, 0.0]
                for (step, fraction) in [0.25, 0.5, 0.75, 1].enumerated() {
                    let parameters = control.applying(position: Float(0.5 + sign * fraction * 0.5), to: .init())
                    let result = try engine.processResult(preparedImage: prepared, parameters: parameters)
                    let actual = try pixels(result.output, raster: raster)
                    let protection = protectionChanges(raster.bytes, actual, domain: domain)
                    XCTAssertEqual(protection.core, 0, "frozen source semantic/feature core")
                    XCTAssertEqual(protection.exterior, 0, "source geometric legal-domain exterior")
                    XCTAssertEqual(protection.alpha, 0)
                    XCTAssertEqual(result.output.extent, raster.image.extent)
                    XCTAssertEqual(result.output.colorSpace?.name, colourSpace.name)
                    for ordinal in 0..<2 {
                        let probe = probes[control]![ordinal]
                        let boundary = probe.map { findBoundary($0, raster: raster, pixel: { x, y in self.rgb(actual, x, y, raster) }) }
                            ?? Boundary(position: nil, crossingCount: 0, status: "unqualified-source-arc")
                        let value = probe.flatMap { p in boundary.position.map { ($0 - p.sourceCrossing) * p.controlPolarity * sign } }
                        let precise = value?.isFinite == true
                        let monotone = value.map { $0 > previous[ordinal] + 0.1 } ?? false
                        let visible = value.map { fraction < 1 || $0 > 1 } ?? false
                        XCTAssertTrue(precise, "colour boundary unresolved: \(raster.id) \(control.rawValue) \(ordinal) \(boundary.status)")
                        XCTAssertTrue(monotone, "source-owned boundary quarter must increase >.1 px")
                        XCTAssertTrue(visible, "source-owned boundary endpoint must move >1 px; no-op fails")
                        previous[ordinal] = value ?? .nan
                        records.append(["layer": raster.id, "control": control.rawValue, "sideOrdinal": ordinal,
                            "sign": Int(sign), "quarter": step + 1, "measurementQualified": precise,
                            "directionPixels": value ?? 0, "status": boundary.status, "crossingCount": boundary.crossingCount,
                            "monotone": monotone, "visibleEndpoint": visible,
                            "protectedCoreChangedPixels": protection.core, "legalDomainExteriorChangedPixels": protection.exterior,
                            "alphaChangedPixels": protection.alpha])
                    }
                    if fraction == 1 {
                        let repeated = try engine.processResult(preparedImage: prepared, parameters: parameters)
                        XCTAssertTrue(try pixels(repeated.output, raster: raster) == actual, "repeated endpoint RGBA exact identity")
                    }
                }
            } }
            let restored = try engine.processResult(preparedImage: prepared, parameters: .init())
            XCTAssertTrue(try pixels(restored.output, raster: raster) == raster.bytes, "restored neutral RGBA exact identity")
        }
        try receipt(records, name: "photo-colour-edge-v1.json", to: destination)
    }

    private func deformations() -> [Deformation] {
        var result = [Deformation(ordinal: 0, translation: 0, a: 1, b: 0, c: 0, d: 1)]
        for sign: Double in [-1, 1] { for magnitude in [0.25, 0.5, 1, 2, 4] {
            result.append(Deformation(ordinal: result.count, translation: sign * magnitude, a: 1, b: 0, c: 0, d: 1))
        } }
        // Registered gradient bank, each spectral norm ||A-I|| <= .45.
        let matrices = [(1.45, 0.0, 0.0, 1.0), (0.55, 0.0, 0.0, 1.0),
            (1.0, 0.30, 0.0, 1.0), (1.0, -0.30, 0.0, 1.0),
            (cos(0.2), -sin(0.2), sin(0.2), cos(0.2)),
            (cos(0.2), sin(0.2), -sin(0.2), cos(0.2))]
        for (a, b, c, d) in matrices { for translation: Double in [-2, 2] {
            result.append(Deformation(ordinal: result.count, translation: translation, a: a, b: b, c: c, d: d))
        } }
        return result
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
                outside: outside, search: max(8, Int(ceil(frame.span * 0.065))), sourceCrossing: 0, controlPolarity: polarity)
            let sourceBoundary = findBoundary(prototype, raster: raster, pixel: { x, y in self.rgb(raster.bytes, x, y, raster) })
            guard let crossing = sourceBoundary.position else {
                stages.append(["sourceCandidateOrdinal": examined - 1, "rejectionStage": "source-boundary",
                    "sourceCrossings": sourceBoundary.crossingCount, "boundaryStatus": sourceBoundary.status])
                continue
            }
            let probe = Probe(center: center, normal: normal, tangent: tangent, inside: inside,
                outside: outside, search: prototype.search, sourceCrossing: crossing, controlPolarity: polarity)
            var qualified = true
            for deformation in deformations() {
                let boundary = knownBoundary(probe, deformation: deformation, raster: raster, domain: domain)
                let error = boundary.position.map { abs($0 - crossing - deformation.translation * polarity) }
                if error.map({ $0 <= 0.1 }) ?? false { continue }
                qualified = false
                stages.append(["sourceCandidateOrdinal": examined - 1, "rejectionStage": "known-control",
                    "sourceCrossings": sourceBoundary.crossingCount, "firstRejectControlOrdinal": deformation.ordinal,
                    "knownControlCrossings": boundary.crossingCount, "boundaryStatus": boundary.status,
                    "footprintVeto": boundary.status == "incomplete-source-footprint",
                    "errorVeto": error.map({ $0 > 0.1 }) ?? false,
                    "absoluteError": error ?? Double.greatestFiniteMagnitude])
                break
            }
            if qualified {
                stages.append(["sourceCandidateOrdinal": examined - 1, "rejectionStage": "qualified", "sourceCrossings": 1])
                eligible += 1; return (probe, examined, eligible, stages)
            }
        }
        return (nil, examined, eligible, stages)
    }

    private func knownBoundary(_ probe: Probe, deformation: Deformation, raster: Raster, domain: Domains) -> Boundary {
        let pivot = probe.center + probe.normal * probe.sourceCrossing
        let determinant = deformation.a * deformation.d - deformation.b * deformation.c
        func inverse(_ point: SIMD2<Double>) -> SIMD2<Double> {
            let v = point - pivot - probe.normal * deformation.translation * probe.controlPolarity
            let x = v.x * probe.normal.x + v.y * probe.normal.y
            let y = v.x * probe.tangent.x + v.y * probe.tangent.y
            return pivot + probe.normal * ((deformation.d * x - deformation.b * y) / determinant)
                + probe.tangent * ((-deformation.c * x + deformation.a * y) / determinant)
        }
        // Require complete legal texel ownership around the known boundary,
        // including every output bilinear footprint and inverse source texel.
        // A protection-clipped partial truth never establishes observability.
        let truth = probe.sourceCrossing + deformation.translation * probe.controlPolarity
        for t in stride(from: truth - 1, through: truth + 1, by: 0.125) {
            let q = probe.center + probe.normal * t
            let ix = Int(floor(q.x)), iy = Int(floor(q.y))
            for dy in 0...1 { for dx in 0...1 {
                let p = SIMD2(Double(ix + dx), Double(iy + dy))
                guard legalFootprint(p, raster: raster, domain: domain),
                      legalFootprint(inverse(p), raster: raster, domain: domain) else {
                    return Boundary(position: nil, crossingCount: 0, status: "incomplete-source-footprint")
                }
            } }
        }
        return findBoundary(probe, raster: raster) { x, y in
            guard x >= 0, y >= 0, x < raster.width, y < raster.height else { return nil }
            let index = y * raster.width + x
            if !domain.legal[index] || domain.core[index] { return self.rgb(raster.bytes, x, y, raster) }
            guard let value = self.sample(raster, at: inverse(SIMD2(Double(x), Double(y)))) else { return nil }
            return SIMD3(value.x.rounded(), value.y.rounded(), value.z.rounded())
        }
    }

    private func findBoundary(_ probe: Probe, raster: Raster,
                              pixel: @escaping (Int, Int) -> SIMD3<Double>?) -> Boundary {
        let vector = probe.outside - probe.inside, midpoint = (probe.outside + probe.inside) * 0.5
        let energy = square(vector)
        var previous: (Double, Double)?, crossings: [Double] = []
        for tick in (-probe.search * 16)...(probe.search * 16) {
            let t = Double(tick) / 16
            guard let value = sample(raster, at: probe.center + probe.normal * t, pixel: pixel) else {
                return Boundary(position: nil, crossingCount: crossings.count, status: "raster-footprint-inconclusive")
            }
            let q = value - midpoint, score = (q.x * vector.x + q.y * vector.y + q.z * vector.z) / energy
            if let (oldT, oldScore) = previous, oldScore <= 0, score >= 0 {
                let position = score == oldScore ? (oldT + t) * 0.5 : oldT + (t - oldT) * (-oldScore) / (score - oldScore)
                if crossings.last.map({ abs($0 - position) > 0.02 }) ?? true { crossings.append(position) }
            }
            previous = (t, score)
        }
        guard crossings.count == 1 else {
            return Boundary(position: nil, crossingCount: crossings.count, status: crossings.isEmpty ? "missing-colour-boundary" : "multiple-boundaries-or-ghost")
        }
        return Boundary(position: crossings[0], crossingCount: 1, status: "unique-source-colour-boundary")
    }

    private func square(_ p: SIMD3<Double>) -> Double { p.x * p.x + p.y * p.y + p.z * p.z }
    private func rgb(_ bytes: [UInt8], _ x: Int, _ y: Int, _ raster: Raster) -> SIMD3<Double>? {
        guard x >= 0, y >= 0, x < raster.width, y < raster.height else { return nil }
        let i = (y * raster.width + x) * 4
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
            inside: SIMD3(220, 180, 160), outside: SIMD3(20, 30, 40), search: 24, sourceCrossing: 0, controlPolarity: -1)
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
        blocked[96 * width + 128] = true
        let protected = Domains(legal: domain.legal, core: blocked)
        let denied = knownBoundary(probe, deformation: deformations()[0], raster: raster, domain: protected)
        XCTAssertNil(denied.position)
        XCTAssertEqual(denied.status, "incomplete-source-footprint", "protected texels cannot qualify a partial synthetic truth")
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
        try JSONSerialization.data(withJSONObject: ["schema": "source-colour-boundary-edge/v1", "sourceCount": 1,
            "sourceOnlySelection": true, "rasterLayers": ["full", "preview960"], "appearanceParity": false,
            "fullSDKRegression": false, "registeredGradientBankOnly": true, "records": records],
            options: [.sortedKeys, .prettyPrinted]).write(to: url)
    }
}
