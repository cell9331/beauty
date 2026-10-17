import BeautyCore
import BeautyDetection
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import BeautyEffects

#if os(macOS)
/// Owner-local photo comparison of the admitted production nose map. All photo
/// geometry, raster paths and measured locations arrive through an ignored,
/// explicit manifest. No portrait or anatomical template is a test fallback.
final class BeautyNoseReferenceProbeTests: XCTestCase {
    private typealias Lab = BeautyEyeRelativeEndpointResearch
    private enum ReplayError: Error { case invalidInput, invalidBoundary, redactedReplayFailure }
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

    func testExplicitRegisteredNoseEndpointReplay() throws {
        let environment = ProcessInfo.processInfo.environment
        guard let manifest = environment["BEAUTY_NOSE_REFERENCE_MANIFEST"],
              let output = environment["BEAUTY_NOSE_REFERENCE_OUTPUT"] else {
            throw XCTSkip("Explicit ignored nose reference inputs are required; no portrait fallback.")
        }
        do { try replay(manifest: manifest, output: output) }
        catch { throw ReplayError.redactedReplayFailure }
    }

    private func replay(manifest: String, output: String) throws {
        let values = try dictionary(Data(contentsOf: checked(URL(fileURLWithPath: manifest))))
        guard values["deployment_allowed"] as? Bool == false,
              values["comparison_contract"] as? String == "conditional_observed_left_to_right_sdk_endpoint_replay",
              values["geometry_mode"] as? String == "manual_registered_mesh",
              let cases = values["cases"] as? [[String: Any]], !cases.isEmpty else {
            throw ReplayError.invalidInput
        }
        let directory = try checked(URL(fileURLWithPath: output, isDirectory: true))
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for item in cases { try replay(item, into: directory) }
    }

    private func replay(_ item: [String: Any], into directory: URL) throws {
        guard let name = item["feature"] as? String, ["size", "tip", "root", "bridge"].contains(name),
              let sourcePath = item["source_png"] as? String,
              let referencePath = item["reference_png"] as? String,
              let pointsPath = item["points_json"] as? String,
              let geometryPath = item["geometry_json"] as? String else { throw ReplayError.invalidInput }
        let source = try loadPNG(checked(URL(fileURLWithPath: sourcePath)))
        let reference = try loadPNG(checked(URL(fileURLWithPath: referencePath)))
        guard source.width == reference.width, source.height == reference.height else {
            throw ReplayError.invalidInput
        }
        let rawPoints = try JSONSerialization.jsonObject(with:
            Data(contentsOf: checked(URL(fileURLWithPath: pointsPath))))
        guard let points = rawPoints as? [[Double]], !points.isEmpty,
              points.allSatisfy({ $0.count == 2 && $0.allSatisfy(\.isFinite) &&
                  $0[0] >= 0 && $0[1] >= 0 && $0[0] <= Double(source.width - 1) &&
                  $0[1] <= Double(source.height - 1) }) else { throw ReplayError.invalidInput }
        let geometry = try dictionary(Data(contentsOf: checked(URL(fileURLWithPath: geometryPath))))
        guard geometry["registration_source"] as? String == "manual_photo_annotation",
              geometry["production_detection"] as? Bool == false,
              let meshPoints = geometry["normalized_mesh_points"] as? [[Double]],
              meshPoints.count == 478,
              meshPoints.allSatisfy({ $0.count == 3 && $0.allSatisfy(\.isFinite) }),
              let mesh = BeautyFaceMesh(points: meshPoints.map { SIMD3(Float($0[0]), Float($0[1]), Float($0[2])) }),
              let observation = MediaPipeFaceTopology.observation(from: mesh) else { throw ReplayError.invalidInput }
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        guard BeautyContinuousNoseMap.isEligible(face: face) else { throw ReplayError.invalidInput }
        let folder = try checked(directory.appendingPathComponent(name, isDirectory: true))
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try writePNG(source.bytes, width: source.width, height: source.height,
            to: folder.appendingPathComponent("decoded-source.png"))
        try writePNG(reference.bytes, width: reference.width, height: reference.height,
            to: folder.appendingPathComponent("decoded-reference.png"))
        var lowStrengths = BeautyEffectiveStrengths(), highStrengths = BeautyEffectiveStrengths()
        let cap: Float
        switch name {
        case "size":
            cap = BeautySafetyCaps.noseSlim
            lowStrengths.noseSlim = -cap; highStrengths.noseSlim = cap
        case "tip":
            cap = BeautySafetyCaps.noseTipSize
            lowStrengths.noseTipSize = -cap; highStrengths.noseTipSize = cap
        case "root":
            cap = BeautySafetyCaps.noseRootNarrowing
            lowStrengths.noseRootNarrowing = -cap; highStrengths.noseRootNarrowing = cap
        case "bridge":
            cap = BeautySafetyCaps.noseBridge
            lowStrengths.noseBridge = -cap; highStrengths.noseBridge = cap
        default:
            throw ReplayError.invalidInput
        }
        guard let lowMap = BeautyContinuousNoseMap(width: source.width, height: source.height,
                face: face, strengths: lowStrengths),
              let highMap = BeautyContinuousNoseMap(width: source.width, height: source.height,
                face: face, strengths: highStrengths) else { throw ReplayError.invalidInput }
        for (label, map, strengths) in [("low", lowMap, lowStrengths), ("high", highMap, highStrengths)] {
            let pixels = map.applyRGBA(source.bytes)
            let stage = BeautyStillImageGeometryStage(sourceRGBA: source.bytes, width: source.width,
                height: source.height, plan: BeautyEffectPlan(activeDomains: [.nose], effectiveStrengths: strengths), face: face)
            XCTAssertTrue(stage.sourceRGBA == source.bytes, "Nose-only source prefix must remain unchanged.")
            XCTAssertTrue(stage.controlPoints.isEmpty, "Dense ownership must suppress the old point proxies.")
            XCTAssertTrue(stage.applyingContinuousNose(to: stage.sourceRGBA) == pixels,
                "Production nose stage and directly admitted map must agree.")
            try writePNG(pixels, width: source.width, height: source.height,
                to: folder.appendingPathComponent("carrier-" + label + ".png"))
        }
        let low = Lab.Endpoint(displacementLipschitzBound: lowMap.maximumGradient) {
            lowMap.ordinaryUnclippedSampleIndex(at: $0)
        }
        let high = Lab.Endpoint(displacementLipschitzBound: highMap.maximumGradient) {
            highMap.ordinaryUnclippedSampleIndex(at: $0)
        }
        let policy = Lab.Policy(width: source.width, height: source.height,
            maximumIterations: 256, residualTolerance: 0.0000001)
        var field = [[String: Any]](), refusals = [String: Int]()
        var maximumClosure = 0.0, maximumResidual = 0.0
        for pair in points {
            let p = SIMD2(pair[0], pair[1])
            // H = B_high^-1 o B_low: both endpoints share one registered
            // geometry/carrier. No subtraction of fields on unlike grids.
            let result = Lab.relativeForward(point: p, low: low, high: high, policy: policy)
            if let q = result.point {
                let reverse = Lab.relativeInverse(point: q, low: low, high: high, policy: policy)
                guard let restored = reverse.point,
                      let neutral = lowMap.ordinaryUnclippedSampleIndex(at: p) else { throw ReplayError.invalidInput }
                let closure = hypot(restored.x - p.x, restored.y - p.y)
                maximumClosure = max(maximumClosure, closure)
                maximumResidual = max(maximumResidual, result.residual ?? 0)
                XCTAssertLessThanOrEqual(closure, 0.00001, "Numerical closure is not photo-fit accuracy.")
                field.append(["source": pair, "target": [q.x, q.y],
                    "neutral_source": [neutral.x, neutral.y],
                    "residual": result.residual ?? 0, "round_trip": closure])
            } else {
                let reason = result.refusal?.rawValue ?? "missing_result"
                refusals[reason, default: 0] += 1
                field.append(["source": pair, "refusal": reason])
            }
        }
        try JSONSerialization.data(withJSONObject: field, options: [.sortedKeys])
            .write(to: checked(folder.appendingPathComponent("relative-current-field.json")))
        let request = Lab.Request(sourceRGBA: source.bytes, width: source.width, height: source.height,
            sourceBinding: .bind(sourceRGBA: source.bytes, width: source.width, height: source.height), policy: policy)
        let rendered = Lab.render(request, low: low, high: high)
        try writePNG(rendered.rgba, width: source.width, height: source.height,
            to: folder.appendingPathComponent("relative-current.png"))
        let receipt: [String: Any] = [
            "feature": name, "comparisonContract": "conditional_observed_left_to_right_sdk_endpoint_replay",
            "sourceFrame": "observed-left photo; not a certified neutral or certified SDK low endpoint",
            "comparisonColorSpace": "independent sRGB decode, no spatial resampling",
            "geometryMode": "manual_registered_mesh", "productionDetection": false,
            "sourceWidth": source.width, "sourceHeight": source.height,
            "lowDirectStrength": -cap, "highDirectStrength": cap,
            "lowAdmittedGradient": lowMap.maximumGradient, "highAdmittedGradient": highMap.maximumGradient,
            "lowMaximumDisplacement": lowMap.maximumDisplacement,
            "highMaximumDisplacement": highMap.maximumDisplacement,
            "probePoints": points.count, "pointRefusals": refusals,
            "maximumNumericalClosure": maximumClosure, "maximumNumericalResidual": maximumResidual,
            "rasterStatus": rendered.status.rawValue, "rasterRefusal": rendered.refusal?.rawValue ?? "none",
            "rasterChangedPixels": rendered.changedPixelCount, "rasterSampledPixels": rendered.sampledPixelCount,
            "rasterMaximumResidual": rendered.maximumResidual, "wholePhotoEvaluated": true,
            "deploymentAllowed": false, "photoFitEstablishedByThisTest": false]
        try JSONSerialization.data(withJSONObject: receipt, options: [.prettyPrinted, .sortedKeys])
            .write(to: checked(folder.appendingPathComponent("swift-execution-receipt.json")))
        XCTAssertEqual(rendered.status, .applied, "A numerical replay refusal is not effect success.")
        XCTAssertTrue(refusals.isEmpty, "Every frozen coordinate must retain a result or explicit failure.")
    }

    private func dictionary(_ data: Data) throws -> [String: Any] {
        guard let value = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ReplayError.invalidInput
        }
        return value
    }

    private func validDimensions(width: Int, height: Int) -> Bool {
        width > 1 && height > 1 && width <= BeautyConfiguration.defaultMaximumInputPixelCount / height
            && width * height <= Int.max / 4
    }

    private func loadPNG(_ url: URL) throws -> (bytes: [UInt8], width: Int, height: Int) {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue,
              let height = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue,
              validDimensions(width: width, height: height),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
              image.width == width, image.height == height else { throw ReplayError.invalidInput }
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(data: &bytes, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { throw ReplayError.invalidInput }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return (bytes, width, height)
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
    private var allowedRoots: [URL] {
        ["implementation-validation", "scope-correction"].map {
            repository.appendingPathComponent(
                "example-images/参考效果分析/鼻子/本地测量/20261017/" + $0, isDirectory: true)
        }
    }
    private func checked(_ input: URL) throws -> URL {
        let url = input.standardizedFileURL, resolved = input.standardizedFileURL.resolvingSymlinksInPath()
        guard let expectedRoot = allowedRoots.map(\.standardizedFileURL).first(where: {
            resolved.path == $0.path || resolved.path.hasPrefix($0.path + "/")
        }) else { throw ReplayError.invalidBoundary }
        let root = expectedRoot.resolvingSymlinksInPath()
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
}
#endif
