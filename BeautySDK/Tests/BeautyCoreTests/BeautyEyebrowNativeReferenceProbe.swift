#if os(iOS)
import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects
import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import BeautySDK

/// Temporary SDK-owned native probe. The owner copies this source into the
/// existing SwiftPM test target for a bounded run, then removes that copy.
/// It owns no application, view, lifecycle or external-host dependency.
///
/// Environment:
/// - BEAUTYSDK_BROW_NATIVE_SOURCE_NAME: safe PNG basename within the test
///   bundle's NativePrivatePhoto subdirectory (default: source.png).
/// - BEAUTYSDK_BROW_NATIVE_OUTPUT_ROOT: owner-controlled ignored output root.
/// - BEAUTYSDK_BROW_NATIVE_RUN_ID: anonymous, safe candidate/run identifier.
/// - BEAUTYSDK_BROW_NATIVE_SCALE: original or preview (720 x 960).
/// - BEAUTYSDK_BROW_NATIVE_CASES: optional comma-separated slider/left|right
///   cases (for example verticalPosition/right,headSpacing/right); default all14.
/// - BEAUTYSDK_BROW_NATIVE_PRIVATE_DIAGNOSTICS: optional 1 stores transient
///   private brow geometry only in the owner-controlled ignored output root.
///
/// No photo, geometry or private path is attached to XCTest or printed. The
/// independent frozen photo oracle owns directions, amplitude and exact
/// operation-domain acceptance; this probe does not duplicate the map formula.
final class BeautyEyebrowNativeReferenceProbe: XCTestCase {
    private static let authorizedSourceSHA256 =
        "b856e9fd768cd5ec4c32d3f7ef28403ad2923711c03f5ecc7f52adbbb802f75a"
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    func testAuthorizedPhotoFourteenSignedEndpointsWithFreshNativeObservation() throws {
        let options = try Options()
        let image = try sourceImage(options)
        let width = Int(image.extent.width), height = Int(image.extent.height)
        let source = try rgba(image, width: width, height: height)
        guard stride(from: 3, to: source.count, by: 4).allSatisfy({ source[$0] == 255 }) else {
            throw ProbeFailure.sourceNotOpaque
        }

        // This is the only native detection call. All rendered endpoints use
        // the same fresh, actual 478-point observation and unchanged source.
        var nativeDetector = BeautyFaceDetector.production()
        let detected = nativeDetector.detect(image: image, metadata: metadata,
            imageExtent: image.extent.size, configuration: .init(maximumFaceCount: 1))
        guard detected.summary.usedFaceCount == 1,
              let observation = detected.observations.first,
              observation.mesh?.points.count == 478 else { throw ProbeFailure.nativeMeshMissing }
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        guard geometry.freshness == .fresh, geometry.denseSupport != nil,
              geometry.observedEyebrowSupport?.left != nil,
              geometry.observedEyebrowSupport?.right != nil,
              geometry.leftEyeSupport != nil, geometry.rightEyeSupport != nil else {
            throw ProbeFailure.nativeSupportMissing
        }
        let boxes = try mechanicalFeatureBoxes(observation, width: width, height: height)
        let injectedCalls = InvocationCounter()
        let frozenDetector = BeautyFaceDetector(mappedObservationProvider: { _ in
            injectedCalls.increment()
            return BeautyMappedFaceObservations(observations: [observation])
        })
        // Default selection is the permanent CPU reference. This run makes
        // no claim that a selected Metal runtime or external host executed.
        let engine = try BeautyEngine(faceDetector: frozenDetector)
        let emptyExclusion = try BeautyTextureExclusionMask(width: width, height: height,
            bytes: [UInt8](repeating: 0, count: width * height))
        let outputDirectory = try options.outputDirectory()

        if options.privateDiagnostics {
            try writePrivateBrowGeometry(geometry, observation: observation,
                width: width, height: height, directory: outputDirectory)
            print("BROW_NATIVE_DIAGNOSTIC_STAGE fresh_brow_sides=2 private_geometry_records=2 native_mesh_points=478")
            // Candidate admission is a diagnostic only. It never replaces the
            // public-facade endpoint response or its nonneutral pixel guard.
            try diagnoseCandidateAdmissions(source, width: width, height: height, geometry: geometry, cases: options.cases)
        }

        let neutral = try engine.processResult(image: image, metadata: metadata,
            parameters: .init())
        try assertMetadata(neutral, source: image, active: false)
        let neutralBytes = try rgba(neutral.output, width: width, height: height)
        guard neutralBytes == source else { throw ProbeFailure.neutralChanged }
        try writePNG(neutral.output, to: outputDirectory.appendingPathComponent("neutral.png"))

        guard BeautyEyebrowSlider.allCases.count == 7 else { throw ProbeFailure.controlInventoryChanged }
        var endpoints = 0, repeatedEndpoints = 0, maximumProtectedChanges = 0
        for endpoint in options.cases {
                let slider = endpoint.slider, label = endpoint.label, position = endpoint.position
                let parameters = slider.applying(position: position, to: BeautyParameters())
                let result = try engine.processResult(image: image, metadata: metadata,
                    parameters: parameters, textureExclusionMask: emptyExclusion)
                try assertMetadata(result, source: image, active: true)
                let actual = try rgba(result.output, width: width, height: height)
                // An admitted mask or script success does not make a source-
                // exact endpoint an effect delivery. Every endpoint must edit.
                guard actual != source else { throw ProbeFailure.endpointDidNotChange }
                guard alphaExact(source, actual) else { throw ProbeFailure.alphaChanged }
                let protectedChanges = changedPixels(source, actual, width: width,
                    height: height, boxes: boxes)
                maximumProtectedChanges = max(maximumProtectedChanges, protectedChanges)
                guard protectedChanges == 0 else { throw ProbeFailure.mechanicalFeatureBoxChanged }
                let repeated = try engine.processResult(image: image, metadata: metadata,
                    parameters: parameters, textureExclusionMask: emptyExclusion)
                try assertMetadata(repeated, source: image, active: true)
                let repeatedBytes = try rgba(repeated.output, width: width, height: height)
                guard actual == repeatedBytes,
                      result.metrics == repeated.metrics, result.warnings == repeated.warnings,
                      result.detectionSummary == repeated.detectionSummary else {
                    throw ProbeFailure.repeatChanged
                }
                try writePNG(result.output, to: outputDirectory.appendingPathComponent(
                    "eyebrow-\(slider.rawValue)-\(label).png"))
                endpoints += 1; repeatedEndpoints += 1
        }
        let reset = try engine.processResult(image: image, metadata: metadata,
            parameters: .init())
        let resetBytes = try rgba(reset.output, width: width, height: height)
        guard source == resetBytes else {
            throw ProbeFailure.neutralRecoveryChanged
        }
        guard endpoints == options.cases.count, repeatedEndpoints == options.cases.count,
              injectedCalls.value == options.cases.count * 2 else {
            throw ProbeFailure.executionInventoryChanged
        }
        // These are the only persisted/printed diagnostics. Source identity,
        // paths, geometry, masks, pixel arrays and photo names are omitted.
        let receipt: [String: Any] = [
            "schema": 1, "probe": "sdk-native-eyebrow-photo", "scale": options.scale,
            "sourceWidth": width, "sourceHeight": height,
            "nativeDetectionInvocations": 1, "nativeMeshPointCount": 478,
            "injectedFreshObservationRequests": injectedCalls.value,
            "signedEndpoints": endpoints, "repeatedEndpoints": repeatedEndpoints,
            "nonNeutralEndpoints": endpoints, "writtenPNGCount": endpoints + 1,
            "endpointScope": options.cases.count == 14 ? "full14" : "selected-subset",
            "selectedCases": options.cases.map { $0.identifier },
            "selectedBackend": "cpu", "neutralRGBAExact": true,
            "neutralRecoveryRGBAExact": true, "alphaExact": true,
            "extentExact": true, "outputSRGB": true,
            "mechanicalSourceFeatureBoxChangedPixels": maximumProtectedChanges,
            "independentDirectionAndOperationDomainOracleExecuted": false
        ]
        let receiptData: Data
        do { receiptData = try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys]) }
        catch { throw ProbeFailure.aggregateEncodingFailed }
        let receiptURL = outputDirectory.appendingPathComponent("aggregate.json")
        guard !FileManager.default.fileExists(atPath: receiptURL.path) else { throw ProbeFailure.outputAlreadyExists }
        do { try receiptData.write(to: receiptURL, options: [.withoutOverwriting]) }
        catch { throw ProbeFailure.outputWriteFailed }
        guard let receiptText = String(data: receiptData, encoding: .utf8) else {
            throw ProbeFailure.aggregateEncodingFailed
        }
        print("BROW_NATIVE_AGGREGATE \(receiptText)")
    }

    private func sourceImage(_ options: Options) throws -> CIImage {
        let stem = String(options.sourceName.dropLast(4))
        guard let url = Bundle(for: Self.self).url(forResource: stem, withExtension: "png",
                                                  subdirectory: "NativePrivatePhoto") else {
            throw ProbeFailure.inputMissing
        }
        let data: Data
        do {
            let properties = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
            guard properties.isRegularFile == true, properties.isSymbolicLink == false,
                  let bytes = properties.fileSize, bytes > 0, bytes <= 32 * 1_024 * 1_024 else {
                throw ProbeFailure.inputInvalid
            }
            data = try Data(contentsOf: url, options: .mappedIfSafe)
        } catch { throw ProbeFailure.inputUnreadable }
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        guard digest == Self.authorizedSourceSHA256 else { throw ProbeFailure.inputDigestMismatch }
        guard let source = CGImageSourceCreateWithData(data as CFData,
                  [kCGImageSourceShouldCache: false] as CFDictionary),
              CGImageSourceGetCount(source) == 1,
              let original = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ProbeFailure.inputDecodeFailed
        }
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let orientation = (properties?[kCGImagePropertyOrientation] as? NSNumber)?.intValue ?? 1
        guard orientation == 1 else { throw ProbeFailure.inputOrientationUnexpected }
        guard original.width > 1, original.height > 1,
              original.width <= BeautyConfiguration.defaultMaximumInputPixelCount / original.height else {
            throw ProbeFailure.inputDimensionsInvalid
        }
        var image = CIImage(cgImage: original)
        if options.scale == "preview" {
            let xScale = 720 / Double(original.width), yScale = 960 / Double(original.height)
            guard abs(xScale / yScale - 1) <= 0.001 else { throw ProbeFailure.previewAspectMismatch }
            image = image.transformed(by: CGAffineTransform(scaleX: xScale, y: yScale))
                .cropped(to: CGRect(x: 0, y: 0, width: 720, height: 960))
        }
        // Normalize once to opaque upright sRGB8 before native detection and
        // all CPU snapshots. No caller's file or original pixel buffer changes.
        guard let normalized = context().createCGImage(image, from: image.extent,
            format: .RGBA8, colorSpace: colorSpace) else { throw ProbeFailure.sourceNormalizationFailed }
        return CIImage(cgImage: normalized)
    }

    private func assertMetadata(_ result: BeautyResult<CIImage>, source: CIImage, active: Bool) throws {
        guard result.output.extent == source.extent,
              result.output.colorSpace?.name == CGColorSpace.sRGB,
              result.metrics.values.allSatisfy(\.isFinite) else { throw ProbeFailure.outputMetadataChanged }
        if active {
            guard result.detectionSummary?.usedFaceCount == 1,
                  result.metrics["beauty.detection.meshPointCount"] == 478,
                  result.metrics["beauty.effects.activeCount"] == 1,
                  result.metrics["beauty.effects.continuousEyebrowFields"] == 1 else {
                throw ProbeFailure.endpointAdmissionMissing
            }
        }
        let text = (result.warnings.map { $0.code + " " + $0.message }
            + Array(result.metrics.keys)).joined(separator: " ").lowercased()
        guard !["coordinate", "transcript", "/private/", "file://", "raw pixels"].contains(where: text.contains) else {
            throw ProbeFailure.resultDiagnosticsUnexpected
        }
    }

    /// Explicit owner-authorized transient diagnostics. These raw brow values
    /// stay in ignored storage and never enter printed/XCTest evidence.
    private func writePrivateBrowGeometry(_ geometry: FaceGeometry, observation: BeautyFaceObservation,
                                         width: Int, height: Int, directory: URL) throws {
        guard let left = geometry.observedEyebrowSupport?.left,
              let right = geometry.observedEyebrowSupport?.right,
              let mesh = observation.mesh else { throw ProbeFailure.nativeSupportMissing }
        func vector(_ point: SIMD2<Float>) -> [Double] { [Double(point.x), Double(point.y)] }
        func trace(_ value: BeautyEyebrowSemanticTrace, envelope: [Int]) -> [String: Any] {
            let normalized = value.points.map(vector)
            let pixels = value.points.map { [Double($0.x) * Double(width), Double($0.y) * Double(height)] }
            return [
                "observedPointsNormalized": normalized,
                "sourceLineNormalized": normalized, "sourceLinePixels": pixels,
                "innerHeadNormalized": vector(value.innerEndpoint),
                "outerTailNormalized": vector(value.outerEndpoint),
                "centerNormalized": vector(value.center),
                "apexIndex": value.apexIndex.map { $0 as Any } ?? NSNull(),
                "denseUpperLowerEnvelopeNormalized": mesh.path(envelope).map { [$0.x, $0.y] }
            ]
        }
        let payload: [String: Any] = [
            "schema": 1, "storageScope": "owner-local-ignored-private-diagnostic",
            "coordinateConvention": "upright normalized x-right y-down",
            "sourceWidth": width, "sourceHeight": height,
            "sourceBoundsNormalized": [Double(geometry.bounds.x),Double(geometry.bounds.y),
                Double(geometry.bounds.width),Double(geometry.bounds.height)],
            "sourceOwnershipMidXPixels": Double(geometry.bounds.midX)*Double(width),
            "denseGeometryScale": Double(geometry.denseSupport?.geometryScale ?? 1),
            "left": trace(left, envelope: MediaPipeFaceTopology.leftBrowEnvelope),
            "right": trace(right, envelope: MediaPipeFaceTopology.rightBrowEnvelope),
            "protectedPathsPixels": [geometry.leftEyeSupport?.contour ?? geometry.leftEye,
                geometry.rightEyeSupport?.contour ?? geometry.rightEye,
                geometry.nose + geometry.noseRoot + geometry.noseTip,
                geometry.observedOuterLips ?? geometry.outerLips].map { points in
                    points.map { [Double($0.x)*Double(width), Double($0.y)*Double(height)] }
                }
        ]
        let data: Data
        do { data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys]) }
        catch { throw ProbeFailure.privateDiagnosticEncodingFailed }
        let url = directory.appendingPathComponent("private-native-brow-geometry.json")
        guard !FileManager.default.fileExists(atPath: url.path) else { throw ProbeFailure.outputAlreadyExists }
        do { try data.write(to: url, options: [.withoutOverwriting]) }
        catch { throw ProbeFailure.outputWriteFailed }
    }

    private func diagnoseCandidateAdmissions(_ source: [UInt8], width: Int, height: Int,
                                              geometry: FaceGeometry, cases: [Endpoint]) throws {
        let allowed = Self.allowedAdmissionCodes
        for item in cases {
            let slider = item.slider, endpoint = item.label, position = item.position
            let parameters = slider.applying(position: position, to: BeautyParameters())
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: geometry)
            var counts: [String: Int] = [:]
            let candidate = BeautyContinuousEyebrowMap(width: width, height: height, face: geometry,
                strengths: plan.effectiveStrengths, sourceRGBA: source, onAdmission: { code in
                    let fixedCode = allowed.contains(code) ? code : "unclassified_fixed_callback"
                    counts[fixedCode, default: 0] += 1
                })
            let payload: [String: Any] = [
                "slider": slider.rawValue, "endpoint": endpoint,
                "candidateMapCreated": candidate != nil, "fixedAdmissionCounts": counts
            ]
            let data: Data
            do { data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys]) }
            catch { throw ProbeFailure.aggregateEncodingFailed }
            guard let text = String(data: data, encoding: .utf8) else { throw ProbeFailure.aggregateEncodingFailed }
            print("BROW_NATIVE_FIXED_ADMISSION \(text)")
        }
    }

    private static var allowedAdmissionCodes: Set<String> {
        var result: Set<String> = ["eyebrow_initial_rejected", "eyebrow_geometry_admitted",
                                  "eyebrow_no_material", "eyebrow_no_admitted_field", "eyebrow_spacing_pair_rejected"]
        let suffixes = ["inputs_rejected", "axis_rejected", "source_path_rejected", "source_closed_path_rejected",
            "material_rejected", "material_admitted", "sampling_admitted", "sampling_rejected",
            "skin_sampling_rejected", "skin_luminance_rejected", "skin_surface_rejected", "band_sampling_rejected",
            "dark_band_rejected", "dark_core_boundary_rejected", "dark_width_rejected",
            "dark_coherence_rejected", "material_ownership_rejected", "material_coverage_rejected", "source_core_rejected"]
        let regions = ["head_cap", "tail_cap", "head_body", "tail_body", "central_body"]
        for side in ["left", "right"] {
            for suffix in suffixes { result.insert("eyebrow_\(side)_\(suffix)") }
            for region in regions { for stage in ["dark_top_boundary", "dark_bottom_boundary", "fringe_boundary", "dark_core_boundary", "dark_width", "source_branch", "skin_sampling", "skin_luminance", "skin_registration", "seed_dark_core_boundary", "seed_dark_width", "registered_dark_core_boundary", "registered_dark_width", "registered_fringe_boundary", "registered_skin_sampling", "seed_skin_sampling"] {
                result.insert("eyebrow_\(side)_\(stage)_\(region)_rejected")
            } }
        }
        return result
    }

    private struct PixelBox {
        let minX: Int, maxX: Int, minY: Int, maxY: Int
        func contains(_ x: Int, _ y: Int) -> Bool {
            x >= minX && x < maxX && y >= minY && y < maxY
        }
    }

    /// Bounding-box mechanics only; these checks do not claim complete
    /// semantic eye, nose or lip protection or replace the external oracle.
    private func mechanicalFeatureBoxes(_ observation: BeautyFaceObservation,
                                        width: Int, height: Int) throws -> [PixelBox] {
        guard let eyes = observation.observedEyeSupport, eyes.count == 2,
              let nose = observation.observedNoseSupport,
              let lips = observation.observedLipSupport?.outer else { throw ProbeFailure.nativeSupportMissing }
        let paths = eyes.map(\.contour) + [nose.crest + nose.contour, lips]
        guard paths.allSatisfy({ $0.count >= 3 }) else { throw ProbeFailure.nativeSupportMissing }
        return paths.map { path in
            let xs = path.map { $0.x * Double(width) }, ys = path.map { $0.y * Double(height) }
            return PixelBox(minX: max(0, Int(floor(xs.min()!)) - 2),
                maxX: min(width, Int(ceil(xs.max()!)) + 2),
                minY: max(0, Int(floor(ys.min()!)) - 2),
                maxY: min(height, Int(ceil(ys.max()!)) + 2))
        }
    }

    private func changedPixels(_ source: [UInt8], _ output: [UInt8], width: Int,
                               height: Int, boxes: [PixelBox]) -> Int {
        var count = 0
        for y in 0..<height { for x in 0..<width where boxes.contains(where: { $0.contains(x, y) }) {
            let i = (y * width + x) * 4
            if source[i..<(i + 4)] != output[i..<(i + 4)] { count += 1 }
        } }
        return count
    }

    private func alphaExact(_ source: [UInt8], _ output: [UInt8]) -> Bool {
        stride(from: 3, to: source.count, by: 4).allSatisfy { source[$0] == output[$0] }
    }

    private func context() -> CIContext {
        CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace,
                           .cacheIntermediates: false])
    }

    private func rgba(_ image: CIImage, width: Int, height: Int) throws -> [UInt8] {
        guard image.extent == CGRect(x: 0, y: 0, width: width, height: height) else {
            throw ProbeFailure.outputMetadataChanged
        }
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        bytes.withUnsafeMutableBytes { raw in
            context().render(image, toBitmap: raw.baseAddress!, rowBytes: width * 4,
                             bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        }
        return bytes
    }

    private func writePNG(_ image: CIImage, to url: URL) throws {
        guard !FileManager.default.fileExists(atPath: url.path) else { throw ProbeFailure.outputAlreadyExists }
        guard let cgImage = context().createCGImage(image, from: image.extent,
                    format: .RGBA8, colorSpace: colorSpace),
              let destination = CGImageDestinationCreateWithURL(url as CFURL,
                    UTType.png.identifier as CFString, 1, nil) else { throw ProbeFailure.outputWriteFailed }
        CGImageDestinationAddImage(destination, cgImage,
            [kCGImagePropertyOrientation: 1] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw ProbeFailure.outputWriteFailed }
    }

    private struct Endpoint {
        let slider: BeautyEyebrowSlider, label: String
        var position: Float { label == "left" ? 0 : 1 }
        var identifier: String { "\(slider.rawValue)/\(label)" }
    }

    private struct Options {
        let sourceName: String, outputRoot: String, runID: String, scale: String
        let privateDiagnostics: Bool
        let cases: [Endpoint]
        init() throws {
            let environment = ProcessInfo.processInfo.environment
            sourceName = environment["BEAUTYSDK_BROW_NATIVE_SOURCE_NAME"] ?? "source.png"
            runID = environment["BEAUTYSDK_BROW_NATIVE_RUN_ID"] ?? ""
            outputRoot = environment["BEAUTYSDK_BROW_NATIVE_OUTPUT_ROOT"] ?? ""
            scale = environment["BEAUTYSDK_BROW_NATIVE_SCALE"] ?? "original"
            privateDiagnostics = environment["BEAUTYSDK_BROW_NATIVE_PRIVATE_DIAGNOSTICS"] == "1"
            let full = BeautyEyebrowSlider.allCases.flatMap { slider in
                [Endpoint(slider: slider, label: "left"), Endpoint(slider: slider, label: "right")]
            }
            if let selector = environment["BEAUTYSDK_BROW_NATIVE_CASES"] {
                let identifiers = selector.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
                guard !identifiers.isEmpty, Set(identifiers).count == identifiers.count,
                      identifiers.allSatisfy({ identifier in full.contains { $0.identifier == identifier } }) else {
                    throw ProbeFailure.environmentInvalid
                }
                cases = full.filter { identifiers.contains($0.identifier) }
            } else { cases = full }
            guard !cases.isEmpty else { throw ProbeFailure.environmentInvalid }
            let safeCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")
            guard sourceName.hasSuffix(".png"), sourceName.count > 4,
                  sourceName.unicodeScalars.allSatisfy({ safeCharacters.contains($0) }),
                  !runID.isEmpty, runID.count <= 64,
                  runID.unicodeScalars.allSatisfy({ safeCharacters.contains($0) }),
                  runID != ".", runID != "..", outputRoot.hasPrefix("/"),
                  scale == "original" || scale == "preview" else { throw ProbeFailure.environmentInvalid }
        }
        func outputDirectory() throws -> URL {
            let root = URL(fileURLWithPath: outputRoot, isDirectory: true).standardizedFileURL
            let directory = root.appendingPathComponent("\(runID)-\(scale)", isDirectory: true)
            do { try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true) }
            catch { throw ProbeFailure.outputWriteFailed }
            return directory
        }
    }

    private final class InvocationCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var count = 0
        var value: Int { lock.lock(); defer { lock.unlock() }; return count }
        func increment() { lock.lock(); defer { lock.unlock() }; count += 1 }
    }

    private enum ProbeFailure: Error {
        case environmentInvalid, inputMissing, inputInvalid, inputUnreadable
        case inputDigestMismatch, inputDecodeFailed, inputOrientationUnexpected, inputDimensionsInvalid
        case previewAspectMismatch, sourceNormalizationFailed, sourceNotOpaque
        case nativeMeshMissing, nativeSupportMissing, controlInventoryChanged
        case outputMetadataChanged, endpointAdmissionMissing, resultDiagnosticsUnexpected
        case neutralChanged, endpointDidNotChange, alphaChanged, mechanicalFeatureBoxChanged
        case repeatChanged, neutralRecoveryChanged, executionInventoryChanged
        case outputAlreadyExists, outputWriteFailed, aggregateEncodingFailed, privateDiagnosticEncodingFailed
    }
}
#endif
