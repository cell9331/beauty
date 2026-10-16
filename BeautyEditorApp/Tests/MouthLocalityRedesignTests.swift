#if BEAUTY_OWNER_MOUTH_LOCALITY_CHECK && !targetEnvironment(simulator)
@testable import BeautySDK
@testable import BeautyEffects
import CoreGraphics
import CoreImage
import CryptoKit
import Darwin
import Foundation
import Metal
import UIKit
import XCTest
@testable import BeautyEditor

private final class MouthLocalityMetalCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0
    func increment() { lock.lock(); value += 1; lock.unlock() }
    func read() -> Int { lock.lock(); defer { lock.unlock() }; return value }
}

/// Test-local request capture. Raw support lives only until this probe returns.
private final class MouthLocalityBackendProbe: BeautyBackendExecutor {
    private let wrapped: any BeautyBackendExecutor
    private(set) var request: BeautyBackendRequest?
    private(set) var invocationCount = 0
    init(_ wrapped: any BeautyBackendExecutor) { self.wrapped = wrapped }
    func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult {
        invocationCount += 1
        self.request = request
        return try wrapped.execute(request)
    }
}

/// Source-only V1 locality oracle. Geometry is request-local, never serialized.
/// This contour is an observed polygon, not a semantic visible-lip mask.
@MainActor final class MouthLocalityRedesignTests: XCTestCase {
    private typealias P = SIMD2<Double>
    private static let outerIndices = [61, 185, 40, 39, 37, 0, 267, 269, 270, 409,
                                       291, 375, 321, 405, 314, 17, 84, 181, 91, 146]
    private static let innerIndices = [78, 191, 80, 81, 82, 13, 312, 311, 310, 415,
                                       308, 324, 318, 402, 317, 14, 87, 178, 88, 95]

    private struct Difference: Codable {
        var pixelCount = 0
        var changedRGBPixels = 0
        var changedRGBAPixels = 0
        var maximumRGBDifference = 0
        var maximumRGBADifference = 0
    }
    private struct Frame: Codable {
        let input: String
        let slider: Int
        let directMouthSize: Float
        let expectedScale: Double
        let backend: String
        let width: Int
        let height: Int
        let meshPointCount: Int
        let alphaPreserved: Bool
        let repeated: Bool
        let sRGB: Bool
        let extentPreserved: Bool
        let original: Difference
        let outsideAllowedUnion: Difference
        let outsideOriginalLip: Difference
        let targetOnly: Difference
        let exposedOriginalLip: Difference
        let warnings: [String]
    }
    private struct Source: Codable {
        let input: String
        let encodedInputSHA256: String
        let width: Int
        let height: Int
        let detector: String
        let neutralIdentity: Bool
        let neutralRestored: Bool
        let immutableSource: Bool
    }
    private struct Receipt: Codable {
        let schemaVersion: Int
        let oracle: String
        let observationLimit: String
        let deviceModel: String
        let systemVersion: String
        let metalDevice: String
        let mouthSamplingImplementation: String
        let sources: [Source]
        let frames: [Frame]
    }

    func testFrozenLocalityOracleDetectsExteriorSinglePixelAndAcceptsInteriorAndNeutral() {
        let source = [UInt8](repeating: 127, count: 8 * 8 * 4)
        let outer = [P(2, 2), P(4, 2), P(4, 4), P(2, 4)]
        let target = [P(2, 2), P(5, 2), P(5, 5), P(2, 5)]
        let regions = Self.regions(outer: outer, target: target, width: 8, height: 8)
        let neutral = Self.differences(source, source, regions: regions)
        XCTAssertEqual(neutral[0].changedRGBAPixels, 0)
        var interior = source
        interior[(3 * 8 + 3) * 4] += 1
        let allowed = Self.differences(source, interior, regions: regions)
        XCTAssertEqual(allowed[0].changedRGBPixels, 1)
        XCTAssertEqual(allowed[1].changedRGBAPixels, 0)
        var exterior = source
        exterior[0] += 1
        let rejected = Self.differences(source, exterior, regions: regions)
        XCTAssertEqual(rejected[1].changedRGBAPixels, 1)
        XCTAssertEqual(rejected[1].maximumRGBADifference, 1)
    }

    func testDirectMetalDiagnosticsAndSourceContourReview() async throws {
        struct Probe: Encodable {
            let input: String
            let slider: Int
            let runtimeInvocations: Int
            let terminalCode: String?
            let terminalDescription: String?
            let completed: Bool
            let canonicalizationCode: String
            let preparedConstructionCode: String
            let preparedMetalPreflightCode: String
            let backendRequestCount: Int
            let cpuRequestAndActualGeometryAvailable: Bool
        }
        let manager = FileManager.default
        let root = try manager.url(for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true).appendingPathComponent("OwnerMouthLocality20261014", isDirectory: true)
        let runName = try String(contentsOf: root.appendingPathComponent("run-name.txt"), encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard runName.range(of: "^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$", options: .regularExpression) != nil,
              runName.utf8.count <= 64 else { throw NSError(domain: "MouthLocalityReview", code: 1) }
        let output = root.appendingPathComponent(runName, isDirectory: true)
        guard !manager.fileExists(atPath: output.path) else { throw NSError(domain: "MouthLocalityReview", code: 2) }
        try manager.createDirectory(at: output, withIntermediateDirectories: true)
        var probes: [Probe] = []
        for label in ["a", "b"] {
            let data = try ImageInput.readBoundedFile(root.appendingPathComponent("input-" + label + ".png"))
            let renderer = PhotoRenderer(preferredBackend: .gpu)
            let photo = try await renderer.load(data)
            let width = photo.preview.width, height = photo.preview.height
            let faces = try await renderer.landmarks(photo.preview)
            let face = try XCTUnwrap(faces.first)
            guard face.points.count == 478, face.detectorName == "MediaPipe 478" else {
                throw NSError(domain: "MouthLocalityReview", code: 3)
            }
            let points = face.points.map { P(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
            let outer = Self.outerIndices.map { points[$0] }
            let span = hypot(points[291].x - points[61].x, points[291].y - points[61].y)
            let crop = Self.cropRect(outer, span: span, width: width, height: height)
            let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = true
            let drawing = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
            let marked = drawing.image { context in
                UIImage(cgImage: photo.preview).draw(at: .zero)
                let cg = context.cgContext
                cg.setStrokeColor(UIColor.cyan.cgColor); cg.setLineWidth(1)
                cg.move(to: CGPoint(x: outer[0].x, y: outer[0].y))
                for p in outer.dropFirst() { cg.addLine(to: CGPoint(x: p.x, y: p.y)) }
                cg.closePath(); cg.strokePath()
            }
            try await Self.save(try XCTUnwrap(marked.cgImage), name: label + "-source-contour",
                renderer: renderer, output: output, cropRect: crop)
            let counter = MouthLocalityMetalCounter()
            let backend = try BeautyMetalBackend(hooks: .init(onRuntimeInvocation: { counter.increment() }))
            let backendProbe = MouthLocalityBackendProbe(backend)
            let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
            let canonicalizer = BeautyStillImageCanonicalizer()
            let maximumPixels = BeautyConfiguration.defaultMaximumInputPixelCount
            let preparedSource = try BeautyPreparedStillImageState(image: photo.preview, metadata: metadata,
                maximumPixelCount: maximumPixels)
            let canonicalCode: String
            do {
                _ = try canonicalizer.canonicalize(image: preparedSource.image, metadata: metadata, maximumPixelCount: maximumPixels)
                canonicalCode = "completed"
            } catch let error as BeautyError { canonicalCode = error.code }
            let preflightCode: String
            do {
                try canonicalizer.preflightOpaqueBoundedRGBForMetalStillImage(image: preparedSource.image,
                    maximumPixelCount: maximumPixels)
                preflightCode = "completed"
            } catch let error as BeautyError { preflightCode = error.code }
            let engine = try BeautyEngine(configuration: BeautyConfiguration(
                preferredProcessingSize: CGSize(width: 960, height: 960), maximumFaceCount: 1,
                enableFaceTracking: true, detectionFrameInterval: 1, renderBackend: .gpu), backendExecutor: backendProbe)
            let token = try engine.prepareStillImage(image: photo.preview)
            let cpuProbe = MouthLocalityBackendProbe(BeautyCPUBackend())
            let cpu = try BeautyEngine(configuration: BeautyConfiguration(
                preferredProcessingSize: CGSize(width: 960, height: 960), maximumFaceCount: 1,
                enableFaceTracking: true, detectionFrameInterval: 1, renderBackend: .cpu), backendExecutor: cpuProbe)
            let cpuToken = try cpu.prepareStillImage(image: photo.preview)
            for slider: Float in [-100, 100] {
                let parameters = BeautyMouthSlider.size.applying(position: (slider + 100) / 200, to: BeautyParameters())
                _ = try cpu.processResult(preparedImage: cpuToken, parameters: parameters)
                let actualFace = cpuProbe.request?.selectedFaceSupport.map(BeautyFaceGeometryAdapter.makeGeometry(from:))
                let actualScale = actualFace?.denseSupport?.geometryScale
                // Candidate preparation may use this actual route-owned support only in memory.
                let geometryAvailable = actualFace?.observedOuterLips?.isEmpty == false && actualScale != nil
                    && actualScale!.isFinite && actualScale! > 0
                let before = counter.read()
                let beforeRequests = backendProbe.invocationCount
                do {
                    _ = try engine.processResult(preparedImage: token, parameters: parameters)
                    probes.append(Probe(input: label, slider: Int(slider), runtimeInvocations: counter.read() - before,
                        terminalCode: nil, terminalDescription: nil, completed: true,
                        canonicalizationCode: canonicalCode, preparedConstructionCode: "completed", preparedMetalPreflightCode: preflightCode,
                        backendRequestCount: backendProbe.invocationCount - beforeRequests,
                        cpuRequestAndActualGeometryAvailable: geometryAvailable))
                } catch let error as BeautyError {
                    probes.append(Probe(input: label, slider: Int(slider), runtimeInvocations: counter.read() - before,
                        terminalCode: error.code, terminalDescription: error.description, completed: false,
                        canonicalizationCode: canonicalCode, preparedConstructionCode: "completed", preparedMetalPreflightCode: preflightCode,
                        backendRequestCount: backendProbe.invocationCount - beforeRequests,
                        cpuRequestAndActualGeometryAvailable: geometryAvailable))
                }
            }
        }
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(probes).write(to: output.appendingPathComponent("metal-probes.json"), options: .atomic)
        for probe in probes {
            XCTAssertTrue(probe.completed, probe.input + ":" + String(probe.slider) + " " + (probe.terminalDescription ?? ""))
            XCTAssertEqual(probe.runtimeInvocations, 1)
        }
    }

    func testCurrentProductionTwoPortraitSizeEndpointsLocality() async throws {
        let manager = FileManager.default
        let root = try manager.url(for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true).appendingPathComponent("OwnerMouthLocality20261014", isDirectory: true)
        let runName = try String(contentsOf: root.appendingPathComponent("run-name.txt"), encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard runName.range(of: "^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$", options: .regularExpression) != nil,
              runName.utf8.count <= 64 else { throw NSError(domain: "MouthLocalityReview", code: 1) }
        let output = root.appendingPathComponent(runName, isDirectory: true)
        guard !manager.fileExists(atPath: output.path) else { throw NSError(domain: "MouthLocalityReview", code: 2) }
        try manager.createDirectory(at: output, withIntermediateDirectories: true)
        let metal = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let deviceModel = Self.machine()
        XCTAssertTrue(deviceModel.hasPrefix("iPad"), "This evidence must execute on the owner's iPad")
        var frames: [Frame] = []
        var sources: [Source] = []
        for label in ["a", "b"] {
            let data = try ImageInput.readBoundedFile(root.appendingPathComponent("input-" + label + ".png"))
            let renderer = PhotoRenderer(preferredBackend: .gpu)
            let photo = try await renderer.load(data)
            let width = photo.preview.width, height = photo.preview.height
            XCTAssertEqual(width, 720); XCTAssertEqual(height, 960)
            let original = [UInt8](TestImage.pixels(photo.preview))
            let detected = try await renderer.landmarks(photo.preview)
            let face = try XCTUnwrap(detected.first)
            guard detected.count == 1, face.points.count == 478, face.detectorName == "MediaPipe 478" else {
                throw NSError(domain: "MouthLocalityReview", code: 3)
            }
            let points = face.points.map { P(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
            let outer = Self.outerIndices.map { points[$0] }
            let center = (points[61] + points[291]) * 0.5
            let span = hypot(points[291].x - points[61].x, points[291].y - points[61].y)
            let cropRect = Self.cropRect(outer, span: span, width: width, height: height)
            let neutral = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: false)
            let neutralIdentity = [UInt8](TestImage.pixels(neutral.image)) == original
            try await Self.save(neutral.image, name: label + "-neutral", renderer: renderer,
                                output: output, cropRect: cropRect)
            let tool = try XCTUnwrap(ToolCatalog.find("mouth.size"))
            for slider: Float in [-100, 100] {
                var snapshot = EditorSnapshot()
                tool.setValue(slider, in: &snapshot.parameters)
                XCTAssertEqual(tool.value(in: snapshot.parameters), slider, accuracy: 0.0001)
                XCTAssertEqual(snapshot.parameters.mouthSize, -0.35 * slider / 100, accuracy: 0.000001)
                let scale = 1 - 0.16 * Double(slider / 100)
                let target = outer.map { center + ($0 - center) * scale }
                // Frozen before calling the current renderer; never derived from output differences.
                let regions = Self.regions(outer: outer, target: target, width: width, height: height)
                let result = try await renderer.render(photo, snapshot: snapshot, fullResolution: false)
                let current = [UInt8](TestImage.pixels(result.image))
                guard current.count == original.count else { throw NSError(domain: "MouthLocalityReview", code: 4) }
                let repeatedResult = try await renderer.render(photo, snapshot: snapshot, fullResolution: false)
                let repeatIdentity = [UInt8](TestImage.pixels(repeatedResult.image)) == current
                let metrics = Self.differences(original, current, regions: regions)
                let extent = result.image.width == width && result.image.height == height
                let frame = Frame(input: label, slider: Int(slider), directMouthSize: snapshot.parameters.mouthSize,
                    expectedScale: scale, backend: result.backendName, width: result.image.width,
                    height: result.image.height, meshPointCount: Int(result.metrics["beauty.detection.meshPointCount"] ?? 0),
                    alphaPreserved: stride(from: 3, to: current.count, by: 4).allSatisfy { current[$0] == original[$0] },
                    repeated: repeatIdentity, sRGB: result.image.colorSpace?.name == CGColorSpace.sRGB,
                    extentPreserved: extent, original: metrics[0], outsideAllowedUnion: metrics[1],
                    outsideOriginalLip: metrics[2], targetOnly: metrics[3], exposedOriginalLip: metrics[4],
                    warnings: result.warningCodes)
                frames.append(frame)
                XCTAssertNotEqual(result.metrics["beauty.backend.cpuGeometryCapacityFallback"], 1)
                let name = label + "-size-" + (slider < 0 ? "negative" : "positive")
                try await Self.save(result.image, name: name, renderer: renderer, output: output, cropRect: cropRect)
            }
            let restored = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: false)
            sources.append(Source(input: label, encodedInputSHA256: Self.sha(data), width: width, height: height,
                detector: face.detectorName, neutralIdentity: neutralIdentity,
                neutralRestored: [UInt8](TestImage.pixels(restored.image)) == original,
                immutableSource: [UInt8](TestImage.pixels(photo.preview)) == original))
        }
        let receipt = Receipt(schemaVersion: 1,
            oracle: "Frozen V1: 20 observed source outer-lip polygon S, target T scaled by 1 + 0.16 * direct mouthSize/cap about the source mouth-corner midpoint. Allowed U is S union T plus at most one output pixel Euclidean edge distance. Pixel-center coordinates. U-exterior RGBA must be exact. Target-only and exposed source-only are separately reported. No output-derived domain or halo.",
            observationLimit: "MediaPipe observed contour is not semantic visible-lip segmentation. Source coverage requires independent original-detail inspection; exact locality alone does not qualify appearance.",
            deviceModel: deviceModel, systemVersion: UIDevice.current.systemVersion, metalDevice: metal.name,
            mouthSamplingImplementation: "Actual Metal backend executes its runtime; continuous mouth material sampling remains CPU-owned within that backend.",
            sources: sources, frames: frames)
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(receipt).write(to: output.appendingPathComponent("aggregate.json"), options: .atomic)
        // Finish every source and endpoint before declaring the new strict gate.
        XCTAssertEqual(frames.count, 4)
        for source in sources {
            XCTAssertTrue(source.neutralIdentity); XCTAssertTrue(source.neutralRestored); XCTAssertTrue(source.immutableSource)
        }
        for frame in frames {
            let identity = frame.input + ":" + String(frame.slider)
            XCTAssertEqual(frame.backend, "Metal", identity)
            XCTAssertEqual(frame.meshPointCount, 478, identity)
            XCTAssertTrue(frame.alphaPreserved && frame.repeated && frame.sRGB && frame.extentPreserved, identity)
            XCTAssertGreaterThan(frame.original.changedRGBPixels, 0, identity)
            XCTAssertEqual(frame.outsideAllowedUnion.changedRGBAPixels, 0, identity + " U-exterior face must remain exact")
            XCTAssertEqual(frame.outsideAllowedUnion.maximumRGBADifference, 0, identity + " U-exterior maximum difference")
        }
    }

    #if BEAUTY_OWNER_MOUTH_CANDIDATE_CHECK
    private struct CandidateAdmission: Encodable {
        let input: String
        let encodedInputSHA256: String
        let knownInputHashMatches: Bool
        let width: Int
        let height: Int
        let requestRasterMatchesSource: Bool
        let canonicalCarrierAvailable: Bool
        let stillImageInputAvailable: Bool
        let previewRGBA8SHA256: String
        let previousAEncodingSHA256: String?
        let previousAPreviewRGBA8SHA256: String?
        let previousAEncodingPreviewMatches: Bool?
        let outerTopologyMatchesMesh: Bool
        let innerTopologyMatchesMesh: Bool
        let independentOuterMatches: Bool
        let independentInnerMatches: Bool
        let semanticPointsMatch: Bool
        let actualDensePoseScaleAvailable: Bool
        let sourceMouthAspectRatio: Double
        let admitted: Bool
    }
    /// Request-local only. Never serialize the points, mask or source bytes.
    private struct CandidateInput {
        let report: CandidateAdmission
        let outer: [P]
        let inner: [P]
        let oracleOuter: [P]
        let oracleCenter: P
        let leftCorner: P
        let rightCorner: P
        let innerUpperCenter: P
        let innerLowerCenter: P
        let maximumDisplacement: Double
    }
    private static func candidateOutputDirectory() throws -> (URL, URL) {
        let manager = FileManager.default
        let root = try manager.url(for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true).appendingPathComponent("OwnerMouthLocality20261014", isDirectory: true)
        let runName = try String(contentsOf: root.appendingPathComponent("run-name.txt"), encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard runName.range(of: "^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$", options: .regularExpression) != nil,
              runName.utf8.count <= 64 else { throw NSError(domain: "MouthLocalityReview", code: 1) }
        let output = root.appendingPathComponent(runName, isDirectory: true)
        guard !manager.fileExists(atPath: output.path) else { throw NSError(domain: "MouthLocalityReview", code: 2) }
        try manager.createDirectory(at: output, withIntermediateDirectories: true)
        return (root, output)
    }
    private static func candidateInput(_ image: CGImage, encodedInput: Data, label: String,
                                       renderer: PhotoRenderer, comparisonRoot: URL) async throws -> CandidateInput {
        let width = image.width, height = image.height
        let detected = try await renderer.landmarks(image)
        guard detected.count == 1, let independent = detected.first,
              independent.points.count == 478, independent.detectorName == "MediaPipe 478" else {
            throw NSError(domain: "MouthLocalityReview", code: 3)
        }
        let independentPoints = independent.points.map { P(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
        let oracleOuter = outerIndices.map { independentPoints[$0] }
        let oracleInner = innerIndices.map { independentPoints[$0] }
        let probe = MouthLocalityBackendProbe(BeautyCPUBackend())
        let engine = try BeautyEngine(configuration: BeautyConfiguration(
            preferredProcessingSize: CGSize(width: 960, height: 960), maximumFaceCount: 1,
            enableFaceTracking: true, detectionFrameInterval: 1, renderBackend: .cpu), backendExecutor: probe)
        let token = try engine.prepareStillImage(image: image)
        _ = try engine.processResult(preparedImage: token,
            parameters: BeautyMouthSlider.size.applying(position: 0, to: BeautyParameters()))
        guard let request = probe.request, let observation = request.selectedFaceSupport,
              let mesh = observation.mesh, mesh.points.count == 478 else {
            throw NSError(domain: "MouthLocalityReview", code: 4)
        }
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        guard let observedOuter = geometry.observedOuterLips, let observedInner = geometry.observedInnerLips,
              let dense = geometry.denseSupport else { throw NSError(domain: "MouthLocalityReview", code: 5) }
        let actualPoints = mesh.points.map { P(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
        let actualOuter = observedOuter.map { P(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
        let actualInner = observedInner.map { P(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
        guard actualOuter.count == 20, actualInner.count == 20 else {
            throw NSError(domain: "MouthLocalityReview", code: 7)
        }
        // Use exact path members for helper identity checks, while independently
        // verifying these ordered slots against the real mesh semantic indices.
        let left = actualOuter[0], right = actualOuter[10]
        let upper = actualInner[5], lower = actualInner[15]
        let span = hypot(right.x - left.x, right.y - left.y)
        guard span.isFinite, span > 0 else { throw NSError(domain: "MouthLocalityReview", code: 6) }
        let mar = hypot(upper.x - lower.x, upper.y - lower.y) / span
        let pose = Double(dense.geometryScale)
        let faceShortSide = min(Double(geometry.bounds.width) * Double(width), Double(geometry.bounds.height) * Double(height))
        let cap = min(0.2 * span, 0.06 * faceShortSide) * pose
        let poseAvailable = pose.isFinite && pose > 0 && pose <= 1 && cap.isFinite && cap > 0
        func matches(_ a: [P], _ b: [P]) -> Bool {
            a.count == b.count && zip(a, b).allSatisfy { hypot($0.0.x - $0.1.x, $0.0.y - $0.1.y) <= 0.001 }
        }
        // Ordered slots are verified against this request's actual mesh. No extrema inference.
        let outerMatches = matches(actualOuter, outerIndices.map { actualPoints[$0] })
        let innerMatches = matches(actualInner, innerIndices.map { actualPoints[$0] })
        let independentOuterMatches = matches(actualOuter, oracleOuter)
        let independentInnerMatches = matches(actualInner, oracleInner)
        let semanticMatches = matches([left, right, upper, lower], [61, 291, 13, 14].map { actualPoints[$0] })
            && matches([left, right, upper, lower], [61, 291, 13, 14].map { independentPoints[$0] })
        let sourceBytes = TestImage.pixels(image)
        let canonicalAvailable = request.canonicalImage != nil
        let stillImageAvailable: Bool
        let rasterMatches: Bool
        switch request.input {
        case .stillImage(let actualImage):
            stillImageAvailable = true
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)
            if actualImage.extent == bounds && request.metadata.orientation == .up && !request.metadata.isInputMirrored {
                // Match TestImage.pixels' explicit RGBA8/sRGB readback exactly.
                // The mouth-only legacy route has no canonicalImage carrier.
                let context = CIContext(options: [.cacheIntermediates: false])
                var actualBytes = Data(count: width * height * 4)
                actualBytes.withUnsafeMutableBytes { storage in
                    context.render(actualImage, toBitmap: storage.baseAddress!, rowBytes: width * 4,
                        bounds: bounds, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
                }
                rasterMatches = actualBytes == sourceBytes
            } else { rasterMatches = false }
        case .pixelBuffer:
            stillImageAvailable = false
            rasterMatches = false
        }
        var previousEncodingSHA: String?
        var previousPreviewSHA: String?
        var previousPreviewMatches: Bool?
        if label == "a" {
            let previous = try ImageInput.readBoundedFile(comparisonRoot.appendingPathComponent("previous-A-encoding.png"))
            previousEncodingSHA = sha(previous)
            let priorPhoto = try await renderer.load(previous)
            let priorBytes = TestImage.pixels(priorPhoto.preview)
            previousPreviewSHA = sha(priorBytes)
            previousPreviewMatches = previousEncodingSHA == "9ceb0577bf8a9ffac7e4ca63e7570b6af3af26240f39a40f2ecea347660de340"
                && priorPhoto.preview.width == width && priorPhoto.preview.height == height && priorBytes == sourceBytes
        }
        let hash = sha(encodedInput)
        let expectedHashes = ["a": "b856e9fd768cd5ec4c32d3f7ef28403ad2923711c03f5ecc7f52adbbb802f75a",
                              "b": "f9eff6395fdaad35d508d4ee297b942d5caf70e13d98f7175957f225f9e12d78"]
        let knownHash = hash == expectedHashes[label]
        let admitted = width == 720 && height == 960 && knownHash && rasterMatches && outerMatches && innerMatches
            && independentOuterMatches && independentInnerMatches && semanticMatches && poseAvailable
            && mar.isFinite && mar >= 0 && mar <= 0.08 && (label != "a" || previousPreviewMatches == true)
        let report = CandidateAdmission(input: label, encodedInputSHA256: hash, knownInputHashMatches: knownHash,
            width: width, height: height, requestRasterMatchesSource: rasterMatches,
            canonicalCarrierAvailable: canonicalAvailable, stillImageInputAvailable: stillImageAvailable,
            previewRGBA8SHA256: sha(sourceBytes), previousAEncodingSHA256: previousEncodingSHA,
            previousAPreviewRGBA8SHA256: previousPreviewSHA, previousAEncodingPreviewMatches: previousPreviewMatches,
            outerTopologyMatchesMesh: outerMatches, innerTopologyMatchesMesh: innerMatches,
            independentOuterMatches: independentOuterMatches, independentInnerMatches: independentInnerMatches,
            semanticPointsMatch: semanticMatches, actualDensePoseScaleAvailable: poseAvailable,
            sourceMouthAspectRatio: mar, admitted: admitted)
        return CandidateInput(report: report, outer: actualOuter, inner: actualInner,
            oracleOuter: oracleOuter, oracleCenter: (independentPoints[61] + independentPoints[291]) * 0.5,
            leftCorner: left, rightCorner: right, innerUpperCenter: upper, innerLowerCenter: lower,
            maximumDisplacement: cap)
    }
    func testCandidateSourceAdmissionAndSemanticContourReview() async throws {
        let (root, output) = try Self.candidateOutputDirectory()
        var reports: [CandidateAdmission] = []
        for label in ["a", "b"] {
            let data = try ImageInput.readBoundedFile(root.appendingPathComponent("input-" + label + ".png"))
            let renderer = PhotoRenderer(preferredBackend: .cpu)
            let photo = try await renderer.load(data)
            let input = try await Self.candidateInput(photo.preview, encodedInput: data, label: label, renderer: renderer, comparisonRoot: root)
            reports.append(input.report)
            let width = photo.preview.width, height = photo.preview.height
            let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = true
            let drawing = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
            let marked = drawing.image { context in
                UIImage(cgImage: photo.preview).draw(at: .zero)
                let cg = context.cgContext
                for (path, color) in [(input.outer, UIColor.cyan), (input.inner, UIColor.yellow)] {
                    guard let first = path.first else { continue }
                    cg.setStrokeColor(color.cgColor); cg.setLineWidth(1)
                    cg.move(to: CGPoint(x: first.x, y: first.y))
                    for point in path.dropFirst() { cg.addLine(to: CGPoint(x: point.x, y: point.y)) }
                    cg.closePath(); cg.strokePath()
                }
                for (point, name, color) in [(input.leftCorner, "61", UIColor.green),
                    (input.rightCorner, "291", UIColor.green), (input.innerUpperCenter, "13", UIColor.magenta),
                    (input.innerLowerCenter, "14", UIColor.orange)] {
                    cg.setStrokeColor(color.cgColor); cg.setLineWidth(1)
                    cg.strokeEllipse(in: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4))
                    let offsetY = name == "13" ? -15.0 : 4.0
                    (name as NSString).draw(at: CGPoint(x: point.x + 4, y: point.y + offsetY),
                        withAttributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: color])
                }
            }
            let span = hypot(input.rightCorner.x - input.leftCorner.x, input.rightCorner.y - input.leftCorner.y)
            let crop = Self.cropRect(input.outer, span: span, width: width, height: height)
            try await Self.save(try XCTUnwrap(marked.cgImage), name: label + "-source-admission-contours",
                renderer: renderer, output: output, cropRect: crop)
        }
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(reports).write(to: output.appendingPathComponent("source-admission.json"), options: .atomic)
        XCTAssertTrue(Self.machine().hasPrefix("iPad"))
        XCTAssertEqual(reports.count, 2)
        for report in reports { XCTAssertTrue(report.admitted, report.input + " source admission") }
    }
    func testIsolatedSizeCandidateWithActualSupportAndFrozenLocality() async throws {
        struct CandidateFrame: Encodable {
            let input: String
            let slider: Int
            let status: String
            let failure: String?
            let observedSourceMatchesOracle: Bool
            let outputPNG: String?
            let repeatFailure: String?
            let actualTargetOutsideFrozenUnionPixels: Int?
            let actualScaleBetweenNeutralAndRequest: Bool?
            let pixels: Frame?
            let materialCapRetained: Bool?
            let statistics: [String: Double]?
        }
        struct NearNeutralProbe: Encodable {
            let requestedScale: Double
            let status: String
            let failure: String?
            let maximumRGBDifference: Int?
        }
        struct CandidateSource: Encodable {
            let admission: CandidateAdmission
            let semanticDiagnostics: [String: Bool]
            let sourceControlPNG: String
            let neutralStatus: String
            let neutralFailure: String?
            let neutralOutputPNG: String?
            let neutralExact: Bool?
            let nearNeutral: [NearNeutralProbe]
            let nearNeutralMaximumRGBDifference: Int?
            let immutableSource: Bool
        }
        struct CandidateReceipt: Encodable {
            let schemaVersion: Int
            let scope: String
            let deviceModel: String
            let sources: [CandidateSource]
            let frames: [CandidateFrame]
        }
        let (root, output) = try Self.candidateOutputDirectory()
        var frames: [CandidateFrame] = []
        var sources: [CandidateSource] = []
        for label in ["a", "b"] {
            let data = try ImageInput.readBoundedFile(root.appendingPathComponent("input-" + label + ".png"))
            let renderer = PhotoRenderer(preferredBackend: .cpu)
            let photo = try await renderer.load(data)
            let width = photo.preview.width, height = photo.preview.height
            let original = [UInt8](TestImage.pixels(photo.preview))
            let input = try await Self.candidateInput(photo.preview, encodedInput: data, label: label, renderer: renderer, comparisonRoot: root)
            let sameObservation = input.report.independentOuterMatches && input.report.independentInnerMatches
                && input.report.semanticPointsMatch
            let diagnostics = MouthLocalCompositeCandidate.semanticDiagnostics(outer: input.outer,
                sourceLeftCorner: input.leftCorner, sourceRightCorner: input.rightCorner,
                innerUpperCenter: input.innerUpperCenter, innerLowerCenter: input.innerLowerCenter)
            let semanticDiagnostics = ["leftCornerMember": diagnostics.leftCornerMember,
                "rightCornerMember": diagnostics.rightCornerMember, "upperInside": diagnostics.upperInside,
                "lowerInside": diagnostics.lowerInside, "pivotInside": diagnostics.pivotInside]
            let span = hypot(input.rightCorner.x - input.leftCorner.x, input.rightCorner.y - input.leftCorner.y)
            let crop = Self.cropRect(input.oracleOuter, span: span, width: width, height: height)
            // This is the unmodified source control, never a claimed helper-neutral output.
            let sourceControlName = label + "-source-control"
            try await Self.save(try Self.image(original, width: width, height: height), name: sourceControlName,
                renderer: renderer, output: output, cropRect: crop)
            guard input.report.admitted else {
                sources.append(CandidateSource(admission: input.report, semanticDiagnostics: semanticDiagnostics,
                    sourceControlPNG: sourceControlName + ".png", neutralStatus: "not_attempted",
                    neutralFailure: "source_admission_failed", neutralOutputPNG: nil, neutralExact: nil,
                    nearNeutral: [], nearNeutralMaximumRGBDifference: nil,
                    immutableSource: original == [UInt8](TestImage.pixels(photo.preview))))
                for slider in [-100, 100] {
                    frames.append(CandidateFrame(input: label, slider: slider, status: "source_rejected",
                        failure: "source_admission_failed", observedSourceMatchesOracle: sameObservation,
                        outputPNG: nil, repeatFailure: nil,
                        actualTargetOutsideFrozenUnionPixels: nil, actualScaleBetweenNeutralAndRequest: nil,
                        pixels: nil, materialCapRetained: nil, statistics: nil))
                }
                continue
            }
            func render(_ scale: Double) -> Result<MouthLocalCompositeCandidate.Output, MouthLocalCompositeCandidate.Failure> {
                MouthLocalCompositeCandidate.render(source: original, width: width, height: height,
                    outer: input.outer, sourceLeftCorner: input.leftCorner, sourceRightCorner: input.rightCorner,
                    innerUpperCenter: input.innerUpperCenter, innerLowerCenter: input.innerLowerCenter,
                    scale: scale, maxDisplacement: input.maximumDisplacement)
            }
            // Pose enters the actual source cap exactly once; helper receives no second pose factor.
            let neutralStatus: String
            let neutralFailure: String?
            let neutralOutputName: String?
            let neutralExact: Bool
            switch render(1) {
            case .success(let result):
                neutralStatus = result.status.rawValue; neutralFailure = nil
                neutralExact = result.rgba == original
                let name = label + "-helper-neutral"
                neutralOutputName = name + ".png"
                try await Self.save(try Self.image(result.rgba, width: width, height: height), name: name,
                    renderer: renderer, output: output, cropRect: crop)
            case .failure(let failure):
                neutralStatus = "rejected"; neutralFailure = failure.rawValue
                neutralExact = false; neutralOutputName = nil
            }
            var nearNeutral: [NearNeutralProbe] = []
            for scale in [1 - 1e-6, 1 + 1e-6] {
                switch render(scale) {
                case .success(let result):
                    let masks = [UInt8](repeating: 0, count: width * height)
                    let maximum = Self.differences(original, result.rgba, regions: masks)[0].maximumRGBDifference
                    nearNeutral.append(NearNeutralProbe(requestedScale: scale, status: result.status.rawValue,
                        failure: nil, maximumRGBDifference: maximum))
                case .failure(let failure):
                    nearNeutral.append(NearNeutralProbe(requestedScale: scale, status: "rejected",
                        failure: failure.rawValue, maximumRGBDifference: nil))
                }
            }
            let nearNeutralMax = nearNeutral.allSatisfy({ $0.failure == nil })
                ? nearNeutral.compactMap(\.maximumRGBDifference).max() : nil
            for slider: Float in [-100, 100] {
                let scale = 1 - 0.16 * Double(slider / 100)
                let target = input.oracleOuter.map { input.oracleCenter + ($0 - input.oracleCenter) * scale }
                let regions = Self.regions(outer: input.oracleOuter, target: target, width: width, height: height)
                switch render(scale) {
                case .failure(let failure):
                    frames.append(CandidateFrame(input: label, slider: Int(slider), status: "rejected", failure: failure.rawValue,
                        observedSourceMatchesOracle: sameObservation, outputPNG: nil, repeatFailure: nil,
                        actualTargetOutsideFrozenUnionPixels: nil, actualScaleBetweenNeutralAndRequest: nil,
                        pixels: nil, materialCapRetained: nil, statistics: nil))
                case .success(let result):
                    let repeated: Bool
                    let repeatFailure: String?
                    switch render(scale) {
                    case .success(let again): repeated = again.rgba == result.rgba; repeatFailure = nil
                    case .failure(let failure): repeated = false; repeatFailure = failure.rawValue
                    }
                    let image = try Self.image(result.rgba, width: width, height: height)
                    let metrics = Self.differences(original, result.rgba, regions: regions)
                    let pixels = Frame(input: label, slider: Int(slider), directMouthSize: -0.35 * slider / 100,
                        expectedScale: scale, backend: "isolated CPU composite research", width: width, height: height,
                        meshPointCount: 478, alphaPreserved: stride(from: 3, to: original.count, by: 4).allSatisfy {
                            original[$0] == result.rgba[$0]
                        }, repeated: repeated, sRGB: image.colorSpace?.name == CGColorSpace.sRGB,
                        extentPreserved: image.width == width && image.height == height,
                        original: metrics[0], outsideAllowedUnion: metrics[1], outsideOriginalLip: metrics[2],
                        targetOnly: metrics[3], exposedOriginalLip: metrics[4], warnings: [])
                    let s = result.stats
                    let materialSafe = s.maximumMaterialDisplacement <= input.maximumDisplacement + 1e-9
                        && s.maximumInverseDisplacementGradient <= 0.45 && s.inverseJacobianDeterminant > 0
                    let scaleAdmitted = (min(1, scale)...max(1, scale)).contains(s.actualScale)
                    let actualCenter = (input.leftCorner + input.rightCorner) * 0.5
                    let actualTarget = input.outer.map { actualCenter + ($0 - actualCenter) * s.actualScale }
                    // Independently rasterize the actual target; do not let its bounds redefine frozen U.
                    var targetOutside = 0
                    for index in regions.indices where regions[index] & 1 != 0 {
                        let point = P(Double(index % width) + 0.5, Double(index / width) + 0.5)
                        if Self.contains(point, polygon: actualTarget) { targetOutside += 1 }
                    }
                    let outputName = label + "-candidate-size-" + (slider < 0 ? "negative" : "positive")
                    frames.append(CandidateFrame(input: label, slider: Int(slider), status: result.status.rawValue, failure: nil,
                        observedSourceMatchesOracle: sameObservation, outputPNG: outputName + ".png", repeatFailure: repeatFailure,
                        actualTargetOutsideFrozenUnionPixels: targetOutside,
                        actualScaleBetweenNeutralAndRequest: scaleAdmitted, pixels: pixels, materialCapRetained: materialSafe,
                        statistics: ["requestedScale": s.requestedScale, "actualScale": s.actualScale,
                            "sourceMouthAspectRatio": s.sourceMouthAspectRatio,
                            "maximumMaterialDisplacement": s.maximumMaterialDisplacement,
                            "maximumInverseDisplacementGradient": s.maximumInverseDisplacementGradient,
                            "inverseJacobianDeterminant": s.inverseJacobianDeterminant,
                            "changedPixelCount": Double(s.changedPixelCount), "rgbClippedPixelCount": Double(s.rgbClippedPixelCount),
                            "backgroundUnknownPixelCount": Double(s.backgroundUnknownPixelCount),
                            "backgroundIterations": Double(s.backgroundIterations), "backgroundMaximumResidual": s.backgroundMaximumResidual]))
                    try await Self.save(image, name: outputName,
                        renderer: renderer, output: output, cropRect: crop)
                }
            }
            sources.append(CandidateSource(admission: input.report, semanticDiagnostics: semanticDiagnostics,
                sourceControlPNG: sourceControlName + ".png", neutralStatus: neutralStatus,
                neutralFailure: neutralFailure, neutralOutputPNG: neutralOutputName, neutralExact: neutralExact,
                nearNeutral: nearNeutral, nearNeutralMaximumRGBDifference: nearNeutralMax,
                immutableSource: original == [UInt8](TestImage.pixels(photo.preview))))
        }
        let receipt = CandidateReceipt(schemaVersion: 3,
            scope: "Isolated size composite closed-mouth mechanism research on two iPad previews. Actual request raster, outer/inner topology, four semantic points and independent detection must match; MAR <= 0.08. Actual source cap with pose once, and baseline V1 exterior oracle remain fixed. No appearance, open-mouth, Metal execution or release qualification.",
            deviceModel: Self.machine(), sources: sources, frames: frames)
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(receipt).write(to: output.appendingPathComponent("candidate-aggregate.json"), options: .atomic)
        XCTAssertTrue(Self.machine().hasPrefix("iPad"))
        XCTAssertEqual(frames.count, 4)
        for source in sources {
            XCTAssertTrue(source.admission.admitted && source.immutableSource)
            XCTAssertNil(source.neutralFailure)
            XCTAssertEqual(source.neutralExact, true)
            XCTAssertNotNil(source.neutralOutputPNG)
            XCTAssertEqual(source.nearNeutral.count, 2)
            for probe in source.nearNeutral { XCTAssertNil(probe.failure) }
            XCTAssertNotNil(source.nearNeutralMaximumRGBDifference)
            if let maximum = source.nearNeutralMaximumRGBDifference { XCTAssertLessThanOrEqual(maximum, 1) }
        }
        for frame in frames {
            XCTAssertNil(frame.failure, frame.input + ":" + String(frame.slider))
            XCTAssertTrue(frame.observedSourceMatchesOracle)
            XCTAssertEqual(frame.materialCapRetained, true)
            XCTAssertEqual(frame.actualScaleBetweenNeutralAndRequest, true)
            XCTAssertEqual(frame.actualTargetOutsideFrozenUnionPixels, 0)
            XCTAssertNil(frame.repeatFailure)
            XCTAssertNotNil(frame.outputPNG)
            XCTAssertNotNil(frame.statistics)
            XCTAssertEqual(frame.statistics?["rgbClippedPixelCount"], 0, "Linear RGB clipping is an independent color failure")
            XCTAssertNotNil(frame.pixels)
            if let pixels = frame.pixels {
                XCTAssertEqual(pixels.outsideAllowedUnion.changedRGBAPixels, 0)
                XCTAssertEqual(pixels.outsideAllowedUnion.maximumRGBADifference, 0)
                XCTAssertGreaterThan(pixels.original.changedRGBPixels, 0)
                XCTAssertTrue(pixels.alphaPreserved && pixels.repeated && pixels.sRGB && pixels.extentPreserved)
            }
        }
    }
    #endif

    private static func image(_ rgba: [UInt8], width: Int, height: Int) throws -> CGImage {
        let provider = try XCTUnwrap(CGDataProvider(data: Data(rgba) as CFData))
        return try XCTUnwrap(CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
            bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue), provider: provider,
            decode: nil, shouldInterpolate: false, intent: .defaultIntent))
    }

    private static func save(_ image: CGImage, name: String, renderer: PhotoRenderer,
                             output: URL, cropRect: CGRect) async throws {
        try await renderer.encodePNG(image).write(to: output.appendingPathComponent(name + ".png"))
        if let crop = image.cropping(to: cropRect) {
            try await renderer.encodePNG(crop).write(to: output.appendingPathComponent(name + "-detail.png"))
        }
    }
    private static func cropRect(_ points: [P], span: Double, width: Int, height: Int) -> CGRect {
        let rect = CGRect(x: points.map(\.x).min()!, y: points.map(\.y).min()!,
            width: points.map(\.x).max()! - points.map(\.x).min()!,
            height: points.map(\.y).max()! - points.map(\.y).min()!).insetBy(dx: -span * 0.45, dy: -span * 0.45).integral
        return rect.intersection(CGRect(x: 0, y: 0, width: width, height: height))
    }
    private static func regions(outer: [P], target: [P], width: Int, height: Int) -> [UInt8] {
        (0..<(width * height)).map { index in
            let point = P(Double(index % width) + 0.5, Double(index / width) + 0.5)
            let inSource = contains(point, polygon: outer), inTarget = contains(point, polygon: target)
            let allowed = inSource || inTarget || distance(point, polygon: outer) <= 1 || distance(point, polygon: target) <= 1
            return (allowed ? 0 : 1) | (inSource ? 0 : 2) | (inTarget && !inSource ? 4 : 0) | (inSource && !inTarget ? 8 : 0)
        }
    }
    private static func contains(_ p: P, polygon: [P]) -> Bool {
        var inside = false
        for i in polygon.indices {
            let a = polygon[i], b = polygon[(i + 1) % polygon.count]
            if (a.y > p.y) != (b.y > p.y), p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x { inside.toggle() }
        }
        return inside
    }
    private static func distance(_ p: P, polygon: [P]) -> Double {
        polygon.indices.map { i in
            let a = polygon[i], edge = polygon[(i + 1) % polygon.count] - a
            let q = p - a, lengthSquared = edge.x * edge.x + edge.y * edge.y
            let t = min(1, max(0, (q.x * edge.x + q.y * edge.y) / max(1e-12, lengthSquared)))
            let delta = q - edge * t
            return hypot(delta.x, delta.y)
        }.min()!
    }
    private static func differences(_ source: [UInt8], _ output: [UInt8], regions: [UInt8]) -> [Difference] {
        var values = Array(repeating: Difference(), count: 5)
        for pixel in regions.indices {
            let offset = pixel * 4
            let rgb = (0..<3).map { abs(Int(source[offset + $0]) - Int(output[offset + $0])) }.max()!
            let rgba = max(rgb, abs(Int(source[offset + 3]) - Int(output[offset + 3])))
            for region in 0..<5 where region == 0 || (regions[pixel] & (1 << (region - 1))) != 0 {
                values[region].pixelCount += 1
                values[region].changedRGBPixels += rgb > 0 ? 1 : 0
                values[region].changedRGBAPixels += rgba > 0 ? 1 : 0
                values[region].maximumRGBDifference = max(values[region].maximumRGBDifference, rgb)
                values[region].maximumRGBADifference = max(values[region].maximumRGBADifference, rgba)
            }
        }
        return values
    }
    private static func sha(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }
    private static func machine() -> String {
        var system = utsname(); uname(&system)
        let capacity = MemoryLayout.size(ofValue: system.machine)
        return withUnsafePointer(to: &system.machine) { pointer in
            pointer.withMemoryRebound(to: CChar.self, capacity: capacity) { String(cString: $0) }
        }
    }
}
#endif
