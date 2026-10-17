import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import BeautyEffects

#if os(macOS)
/// Ignored owner-local CURRENT-map comparison only. No new tilt formula, photo
/// coefficients, neutral inference or public diagnostics are introduced here.
final class BeautyEyeTiltReferenceProbeTests: XCTestCase {
    private typealias Lab = BeautyEyeRelativeEndpointResearch
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private enum ReplayError: Error { case invalidInput, invalidBoundary, redactedReplayFailure }

    func testFrozenCurrentTiltEndpointReplay() throws {
        let env = ProcessInfo.processInfo.environment
        guard let manifest = env["BEAUTY_TILT_BASELINE_MANIFEST"],
              let output = env["BEAUTY_TILT_BASELINE_OUTPUT"] else {
            throw XCTSkip("Explicit ignored tilt baseline inputs are required; no portrait fallback.")
        }
        do { try replay(manifest: manifest, output: output) }
        catch { throw ReplayError.redactedReplayFailure }
    }

    private func replay(manifest: String, output: String) throws {
        let data = try Data(contentsOf: checked(URL(fileURLWithPath: manifest)))
        guard let values = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              values["deployment_allowed"] as? Bool == false,
              values["comparison_contract"] as? String == "conditional_observed_left_to_right_sdk_endpoint_replay",
              let sourcePath = values["source_png"] as? String,
              let targetPath = values["target_png"] as? String,
              let pointPath = values["points_json"] as? String else { throw ReplayError.invalidInput }
        let source = try loadPNG(checked(URL(fileURLWithPath: sourcePath)))
        // Normalize both frozen photos through the same color-managed decoder.
        // This is an evaluation copy, never a re-registration or another carrier.
        let target = try loadPNG(checked(URL(fileURLWithPath: targetPath)))
        guard source.width == target.width, source.height == target.height else {
            throw ReplayError.invalidInput
        }
        let pointData = try Data(contentsOf: checked(URL(fileURLWithPath: pointPath)))
        guard let points = try JSONSerialization.jsonObject(with: pointData) as? [[Double]],
              points.allSatisfy({ $0.count == 2 && $0.allSatisfy(\.isFinite) }) else {
            throw ReplayError.invalidInput
        }
        let directory = try checked(URL(fileURLWithPath: output, isDirectory: true))
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try writePNG(source.bytes, width: source.width, height: source.height,
            to: directory.appendingPathComponent("decoded-source.png"))
        try writePNG(target.bytes, width: target.width, height: target.height,
            to: directory.appendingPathComponent("decoded-reference.png"))
        let canonical = try BeautyCanonicalStillImage(rgba8Data: Data(source.bytes),
            width: source.width, height: source.height, rowBytes: source.width * 4,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo))
        var detector = BeautyFaceDetector.production()
        let detected = detector.detect(image: canonical.ciImage, metadata: canonical.metadata,
            imageExtent: CGSize(width: source.width, height: source.height), purpose: .geometryAndLocalSupport)
        guard detected.observations.count == 1, let observation = detected.observations.first else {
            throw ReplayError.invalidInput
        }
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        // Existing product contract only, not measured screenshot strengths.
        let lowParameters = BeautyEyeShapeSlider.tilt.applying(position: 0, to: .init())
        let highParameters = BeautyEyeShapeSlider.tilt.applying(position: 1, to: .init())
        XCTAssertEqual(lowParameters.eyeTilt, BeautySafetyCaps.eyeTilt)
        XCTAssertEqual(highParameters.eyeTilt, -BeautySafetyCaps.eyeTilt)
        var lowStrengths = BeautyEffectiveStrengths(), highStrengths = BeautyEffectiveStrengths()
        lowStrengths.eyeTilt = lowParameters.eyeTilt; highStrengths.eyeTilt = highParameters.eyeTilt
        guard let lowMap = BeautyContinuousEyeMap(width: source.width, height: source.height,
                face: face, strengths: lowStrengths, sourceRGBA: source.bytes),
              let highMap = BeautyContinuousEyeMap(width: source.width, height: source.height,
                face: face, strengths: highStrengths, sourceRGBA: source.bytes) else { throw ReplayError.invalidInput }
        let low = Lab.Endpoint(displacementLipschitzBound: lowMap.maximumGradient) {
            lowMap.ordinaryUnclippedSampleIndex(at: $0)
        }
        let high = Lab.Endpoint(displacementLipschitzBound: highMap.maximumGradient) {
            highMap.ordinaryUnclippedSampleIndex(at: $0)
        }
        let policy = Lab.Policy(width: source.width, height: source.height,
            maximumIterations: 256, residualTolerance: 0.0000001)
        for (label, map, strengths) in [("low", lowMap, lowStrengths), ("high", highMap, highStrengths)] {
            let pixels = map.applyRGBA(source.bytes)
            let stage = BeautyStillImageGeometryStage(sourceRGBA: source.bytes, width: source.width,
                height: source.height, plan: BeautyEffectPlan(activeDomains: [.eyes], effectiveStrengths: strengths), face: face)
            XCTAssertTrue(stage.sourceRGBA == source.bytes, "Tilt-only source prefix must remain unchanged.")
            XCTAssertTrue(stage.controlPoints.isEmpty, "Observed ownership must suppress old point proxies.")
            XCTAssertTrue(stage.applyingContinuousContour(to: stage.sourceRGBA) == pixels,
                "Actual stage and directly admitted current map must agree.")
            try writePNG(pixels, width: source.width, height: source.height,
                to: directory.appendingPathComponent("carrier-" + label + ".png"))
        }
        var field = [[String: Any]](), refusalCounts = [String: Int]()
        var maxRoundTrip = 0.0, maxForwardResidual = 0.0
        for pair in points {
            let p = SIMD2(pair[0], pair[1])
            let result = Lab.relativeForward(point: p, low: low, high: high, policy: policy)
            if let q = result.point {
                let reverse = Lab.relativeInverse(point: q, low: low, high: high, policy: policy)
                guard let restored = reverse.point else { throw ReplayError.invalidInput }
                let closure = hypot(restored.x - p.x, restored.y - p.y)
                maxRoundTrip = max(maxRoundTrip, closure)
                maxForwardResidual = max(maxForwardResidual, result.residual ?? 0)
                XCTAssertLessThanOrEqual(closure, 0.00001, "Numerical comparator closure only; not photo fit.")
                field.append(["source": pair, "target": [q.x, q.y], "residual": result.residual ?? 0,
                              "iterations": result.iterations, "roundTrip": closure])
            } else {
                let reason = result.refusal?.rawValue ?? "missing_result"
                refusalCounts[reason, default: 0] += 1
                field.append(["source": pair, "refusal": reason])
            }
        }
        try JSONSerialization.data(withJSONObject: field, options: [.sortedKeys])
            .write(to: checked(directory.appendingPathComponent("relative-current-field.json")))
        let request = Lab.Request(sourceRGBA: source.bytes, width: source.width, height: source.height,
            sourceBinding: .bind(sourceRGBA: source.bytes, width: source.width, height: source.height),
            policy: policy, activeBounds: nil)
        let rendered = Lab.render(request, low: low, high: high)
        try writePNG(rendered.rgba, width: source.width, height: source.height,
            to: directory.appendingPathComponent("relative-current.png"))
        let receipt: [String: Any] = [
            "comparisonContract": "conditional_observed_left_to_right_sdk_endpoint_replay",
            "sourceFrame": "observed-left photo; not a certified neutral",
            "comparisonColorSpace": "source and reference independently decoded to sRGB without spatial resampling",
            "sourceWidth": source.width, "sourceHeight": source.height,
            "detectedSourceFaces": detected.observations.count, "detectionPasses": 1,
            "lowDirectStrength": lowParameters.eyeTilt, "highDirectStrength": highParameters.eyeTilt,
            "lowAdmittedGradient": lowMap.maximumGradient, "highAdmittedGradient": highMap.maximumGradient,
            "lowMaximumDisplacement": lowMap.maximumDisplacement, "highMaximumDisplacement": highMap.maximumDisplacement,
            "probePoints": points.count, "pointRefusals": refusalCounts,
            "maxForwardResidual": maxForwardResidual, "maxRoundTrip": maxRoundTrip,
            "rasterStatus": rendered.status.rawValue, "rasterRefusal": rendered.refusal?.rawValue ?? "none",
            "rasterChangedPixels": rendered.changedPixelCount, "rasterSampledPixels": rendered.sampledPixelCount,
            "rasterMaximumResidual": rendered.maximumResidual, "rasterMaximumIterations": rendered.maximumIterationsUsed,
            "wholePhotoEvaluated": true, "geometrySamplesFromObservedLeft": 1,
            "deploymentAllowed": false, "newTiltFormula": false]
        try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys, .prettyPrinted])
            .write(to: checked(directory.appendingPathComponent("swift-execution-receipt.json")))
        XCTAssertEqual(rendered.status, .applied, "A baseline refusal must remain a failed replay, not an effect success.")
        XCTAssertTrue(refusalCounts.isEmpty, "Every frozen coordinate must retain a result or explicit failure.")
    }

    private func loadPNG(_ url: URL) throws -> (bytes: [UInt8], width: Int, height: Int) {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue,
              let height = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue,
              validDimensions(width: width, height: height) else { throw ReplayError.invalidInput }
        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
              image.width == width, image.height == height,
              validDimensions(width: image.width, height: image.height) else { throw ReplayError.invalidInput }
        var bytes = [UInt8](repeating: 0, count: image.width * image.height * 4)
        guard let context = CGContext(data: &bytes, width: image.width, height: image.height,
            bitsPerComponent: 8, bytesPerRow: image.width * 4, space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { throw ReplayError.invalidInput }
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return (bytes, image.width, image.height)
    }

    private func validDimensions(width: Int, height: Int) -> Bool {
        width > 1 && height > 1 && width <= BeautyConfiguration.defaultMaximumInputPixelCount / height
            && width * height <= Int.max / 4
    }

    func testReplayDimensionAdmissionPrecedesPixelAllocation() {
        XCTAssertTrue(validDimensions(width: 2, height: 2))
        for pair in [(0, 2), (2, 0), (1, 2), (-2, 2), (Int.max, 2), (2, Int.max),
                     (BeautyConfiguration.defaultMaximumInputPixelCount, 2)] {
            XCTAssertFalse(validDimensions(width: pair.0, height: pair.1))
        }
    }

    private func writePNG(_ bytes: [UInt8], width: Int, height: Int, to input: URL) throws {
        let url = try checked(input)
        guard let provider = CGDataProvider(data: Data(bytes) as CFData),
              let image = CGImage(width: width, height: height, bitsPerComponent: 8,
                bitsPerPixel: 32, bytesPerRow: width * 4, space: colorSpace,
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent),
              let destination = CGImageDestinationCreateWithURL(url as CFURL,
                UTType.png.identifier as CFString, 1, nil) else { throw ReplayError.invalidInput }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw ReplayError.invalidInput }
    }

    private var repository: URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<4 { url.deleteLastPathComponent() }
        return url.standardizedFileURL.resolvingSymlinksInPath()
    }
    private var allowedRoot: URL {
        repository.appendingPathComponent(
            "example-images/参考效果分析/眼睛/本地测量/tilt-migration-20261017", isDirectory: true)
    }
    private func checked(_ input: URL) throws -> URL {
        let expectedRoot = allowedRoot.standardizedFileURL
        let root = expectedRoot.resolvingSymlinksInPath()
        let url = input.standardizedFileURL, resolved = input.standardizedFileURL.resolvingSymlinksInPath()
        guard root.path == expectedRoot.path, resolved.path == url.path,
              resolved.path == root.path || resolved.path.hasPrefix(root.path + "/") else {
            throw ReplayError.invalidBoundary
        }
        let relative = String(resolved.path.dropFirst(repository.path.count + 1))
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.currentDirectoryURL = repository
        process.arguments = ["check-ignore", "-q", "--", relative]
        process.standardOutput = FileHandle.nullDevice; process.standardError = FileHandle.nullDevice
        try process.run(); process.waitUntilExit()
        guard process.terminationStatus == 0 else { throw ReplayError.invalidBoundary }
        return resolved
    }

    func testLocalReplayRejectsOutsideAndSymlinkTargets() throws {
        XCTAssertThrowsError(try checked(URL(fileURLWithPath: #filePath)))
        let local = allowedRoot.appendingPathComponent("boundary-" + UUID().uuidString)
        let external = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: local, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: external, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: local)
            try? FileManager.default.removeItem(at: external)
        }
        let link = local.appendingPathComponent("escape")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: external)
        XCTAssertThrowsError(try checked(link.appendingPathComponent("private.json")))
        XCTAssertNoThrow(try checked(local.appendingPathComponent("receipt.json")))
    }
}
#endif
