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
/// Owner-local replay only. Authorized photographs, fitted numbers and actual
/// texture points are read from ignored inputs, never embedded in this target.
/// This probe records failed effect hypotheses as well as applied renderings;
/// successful execution is not a production/reference qualification verdict.
final class BeautyIrisFollowingReferenceProbeTests: XCTestCase {
    private typealias Point = BeautyIrisFollowingPoint
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

    func testLocalPairReplayThroughMapStageAndPreview() throws {
        let environment = ProcessInfo.processInfo.environment
        guard let manifestPath = environment["BEAUTY_IRIS_REFERENCE_MANIFEST"],
              let fullSourcePath = environment["BEAUTY_IRIS_REFERENCE_FULL_SOURCE"],
              let pointPath = environment["BEAUTY_IRIS_REFERENCE_POINTS"],
              let outputPath = environment["BEAUTY_IRIS_REFERENCE_OUTPUT"] else {
            throw XCTSkip("Explicit local reference inputs are required; no bundled portrait fallback.")
        }
        do {
            try runReplay(manifestPath: manifestPath, fullSourcePath: fullSourcePath,
                          pointPath: pointPath, outputPath: outputPath)
        } catch {
            // Foundation IO errors can carry absolute owner input locations.
            // The test runner receives a fixed, aggregate error category only.
            throw LocalReplayError.redactedReplayFailure
        }
    }

    private enum LocalReplayError: Error {
        case invalidBoundary, ignoredLocationRequired, redactedReplayFailure
    }

    private func runReplay(manifestPath: String, fullSourcePath: String,
                           pointPath: String, outputPath: String) throws {
        let manifest = try dictionary(Data(contentsOf: checkedLocalURL(URL(fileURLWithPath: manifestPath))))
        XCTAssertEqual(manifest["deployment_allowed"] as? Bool, false,
            "This replay must not silently promote exploratory coefficients.")
        let sourcePath = try XCTUnwrap(manifest["source_input_png"] as? String)
        let crop = try loadPNG(checkedLocalURL(URL(fileURLWithPath: sourcePath)))
        let full = try loadPNG(checkedLocalURL(URL(fileURLWithPath: fullSourcePath)))
        let contract = try XCTUnwrap(manifest["coordinate_contract"] as? [String: Any])
        let origin = try array(contract["analysis_crop_photo_offset"], count: 2)
        let points = try XCTUnwrap(JSONSerialization.jsonObject(with:
            Data(contentsOf: checkedLocalURL(URL(fileURLWithPath: pointPath)))) as? [[Double]])
        let configurations = try XCTUnwrap(manifest["configurations"] as? [String: [String: Any]])
        let directory = try checkedLocalURL(URL(fileURLWithPath: outputPath, isDirectory: true))
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try writePNG(crop.bytes, width: crop.width, height: crop.height,
                     to: directory.appendingPathComponent("decoded-source.png"))

        let canonical = try BeautyCanonicalStillImage(rgba8Data: Data(full.bytes),
            width: full.width, height: full.height, rowBytes: full.width * 4,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo))
        // Run the existing detector once on the immutable full source. No
        // edited image is re-detected and no raw observations are serialized.
        var detector = BeautyFaceDetector.production()
        let detected = detector.detect(image: canonical.ciImage, metadata: canonical.metadata,
            imageExtent: CGSize(width: full.width, height: full.height), purpose: .geometryAndLocalSupport)
        let observation = detected.observations.first
        let face = observation.map(BeautyFaceGeometryAdapter.makeGeometry(from:))
        var strengths = BeautyEffectiveStrengths()
        strengths.pupilSize = BeautySafetyCaps.pupilSize
        let plan = BeautyEffectPlan(activeDomains: [.eyes], effectiveStrengths: strengths)
        var receipts = [[String: Any]]()

        for name in configurations.keys.sorted() {
            let values = try XCTUnwrap(configurations[name])
            let cropEyes = try calibrations(values, centerKey: "center_analysis_pixels",
                                            width: crop.width, height: crop.height)
            let fullEyes = try calibrations(values, centerKey: "center_photo_pixels",
                                            width: full.width, height: full.height)
            for progress in [0.0, 0.5, 1.0] {
                let label = "\(name)-p\(Int(progress * 100))"
                let cropRequest = request(crop.bytes, width: crop.width, height: crop.height,
                                          eyes: cropEyes, progress: progress)
                let start = ProcessInfo.processInfo.systemUptime
                let mapped = BeautyIrisFollowingMap.render(cropRequest)
                let mapElapsed = ProcessInfo.processInfo.systemUptime - start
                try writePNG(mapped.rgba, width: crop.width, height: crop.height,
                    to: directory.appendingPathComponent(label + "-map.png"))

                let fullRequest = request(full.bytes, width: full.width, height: full.height,
                                          eyes: fullEyes, progress: progress)
                let stageStart = ProcessInfo.processInfo.systemUptime
                let stage = BeautyStillImageGeometryStage(sourceRGBA: full.bytes,
                    width: full.width, height: full.height, plan: plan, face: face,
                    irisGeometryRoute: .calibrated(fullRequest))
                let stageElapsed = ProcessInfo.processInfo.systemUptime - stageStart
                let result = try XCTUnwrap(stage.irisFollowingResult)
                try writePNG(result.rgba, width: full.width, height: full.height,
                    to: directory.appendingPathComponent(label + "-stage.png"))
                XCTAssertTrue(stage.controlPoints.isEmpty)
                XCTAssertFalse(stage.usesDenseMap)
                if observation != nil {
                    let extracted = extract(result.rgba, width: full.width,
                        x: Int(origin[0]), y: Int(origin[1]), widthOut: crop.width, heightOut: crop.height)
                    XCTAssertTrue(extracted == mapped.rgba,
                        "A translated calibration on the same source grid must preserve actual pixel transport.")
                }

                let previewStart = ProcessInfo.processInfo.systemUptime
                let preview = try BeautyIrisPreviewCutpoint.execute(original: canonical,
                    plan: plan, selectedFaceObservation: observation, maximumPreviewEdge: 441,
                    irisGeometryRoute: .calibrated(fullRequest))
                let previewElapsed = ProcessInfo.processInfo.systemUptime - previewStart
                let previewPixels = rasterize(preview.output)
                try writePNG(previewPixels.bytes, width: previewPixels.width, height: previewPixels.height,
                    to: directory.appendingPathComponent(label + "-preview.png"))
                XCTAssertTrue(preview.irisFollowingResult?.rgba == result.rgba,
                    "Preview must use the same full-source calibrated route before resizing.")
                XCTAssertEqual(preview.irisFollowingResult?.status, result.status)
                if progress == 0 {
                    XCTAssertTrue(mapped.rgba == crop.bytes)
                    XCTAssertTrue(result.rgba == full.bytes)
                }

                // Only export the actual admitted all-eye field, or identity
                // when nothing was admitted. Partial cases stay pixel-only.
                if mapped.status == .applied || mapped.appliedEyeCount == 0 {
                    var field = [[String: [Double]]]()
                    for p in points where p.count == 2 {
                        let local = Point(x: p[0] - origin[0], y: p[1] - origin[1])
                        var q = local
                        if mapped.status == .applied {
                            for eye in cropEyes {
                                q = try XCTUnwrap(BeautyIrisFollowingMap.forwardPoint(q,
                                    eye: eye, progress: progress))
                            }
                        }
                        field.append(["source": p, "target": [q.x + origin[0], q.y + origin[1]]])
                    }
                    try JSONSerialization.data(withJSONObject: field, options: [.sortedKeys])
                        .write(to: checkedLocalURL(directory.appendingPathComponent(label + "-field.json")))
                }
                receipts.append([
                    "configuration": name, "progress": progress,
                    "domain": "observed endpoint pair; not a neutral product calibration",
                    "mapStatus": String(describing: mapped.status),
                    "mapAppliedEyes": mapped.appliedEyeCount, "mapRefusedEyes": mapped.refusedEyeCount,
                    "mapRefusals": mapped.refusalCounts.reduce(into: [String: Int]()) { $0[$1.key.rawValue] = $1.value },
                    "mapSeconds": mapElapsed, "stageSeconds": stageElapsed,
                    "stageStatus": String(describing: result.status),
                    "stageAppliedEyes": result.appliedEyeCount, "stageRefusedEyes": result.refusedEyeCount,
                    "previewSeconds": previewElapsed,
                    "previewWidth": previewPixels.width, "previewHeight": previewPixels.height,
                    "detectedFaces": detected.observations.count,
                    "deploymentAllowed": false
                ])
            }
        }
        try JSONSerialization.data(withJSONObject: receipts, options: [.prettyPrinted, .sortedKeys])
            .write(to: checkedLocalURL(directory.appendingPathComponent("swift-execution-receipt.json")))
        XCTAssertEqual(detected.observations.count, 1,
            "Real stage validation requires observed source support; map-only evidence is insufficient.")
    }

    private func request(_ bytes: [UInt8], width: Int, height: Int,
                         eyes: [BeautyIrisFollowingEyeCalibration], progress: Double) -> BeautyIrisFollowingRequest {
        BeautyIrisFollowingRequest(sourceRGBA: bytes, width: width, height: height,
            sourceBinding: .bind(sourceRGBA: bytes, width: width, height: height),
            eyes: eyes, progress: progress,
            solverPolicy: .init(maximumIterations: 160, residualTolerancePixels: 0.000001))
    }

    private func calibrations(_ values: [String: Any], centerKey: String,
                              width: Int, height: Int) throws -> [BeautyIrisFollowingEyeCalibration] {
        try [("left", BeautyIrisFollowingSide.left), ("right", .right)].map { name, side in
            let value = try XCTUnwrap(values[name] as? [String: Any])
            let center = try array(value[centerKey], count: 2)
            func number(_ key: String) throws -> Double { try XCTUnwrap(value[key] as? Double) }
            return BeautyIrisFollowingEyeCalibration(side: side,
                center: .init(x: center[0], y: center[1]),
                axisX: .init(x: 1, y: 0), axisY: .init(x: 0, y: 1),
                supportRadiusX: try number("radiusX_pixels"), supportRadiusY: try number("radiusY_pixels"),
                forwardGainX: try number("gainX"), forwardGainY: try number("gainY"),
                ownedSourceDomain: .rectangle(minX: 0, minY: 0,
                    maxX: Double(width - 1), maxY: Double(height - 1)), protectedRegions: [])
        }
    }

    private func dictionary(_ data: Data) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
    private func array(_ value: Any?, count: Int) throws -> [Double] {
        let a = try XCTUnwrap(value as? [Double]); XCTAssertEqual(a.count, count); return a
    }
    private func loadPNG(_ url: URL) throws -> (bytes: [UInt8], width: Int, height: Int) {
        let source = try XCTUnwrap(CGImageSourceCreateWithURL(url as CFURL, nil))
        let image = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
        var bytes = [UInt8](repeating: 0, count: image.width * image.height * 4)
        let context = try XCTUnwrap(CGContext(data: &bytes, width: image.width, height: image.height,
            bitsPerComponent: 8, bytesPerRow: image.width * 4, space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return (bytes, image.width, image.height)
    }
    private func rasterize(_ image: CIImage) -> (bytes: [UInt8], width: Int, height: Int) {
        let width = Int(image.extent.width), height = Int(image.extent.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        CIContext(options: [.workingColorSpace: colorSpace]).render(image, toBitmap: &bytes,
            rowBytes: width * 4, bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        return (bytes, width, height)
    }
    private func writePNG(_ bytes: [UInt8], width: Int, height: Int, to url: URL) throws {
        let url = try checkedLocalURL(url)
        let provider = try XCTUnwrap(CGDataProvider(data: Data(bytes) as CFData))
        let image = try XCTUnwrap(CGImage(width: width, height: height, bitsPerComponent: 8,
            bitsPerPixel: 32, bytesPerRow: width * 4, space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent))
        let destination = try XCTUnwrap(CGImageDestinationCreateWithURL(url as CFURL,
            UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
    }
    private func extract(_ bytes: [UInt8], width: Int, x: Int, y: Int,
                         widthOut: Int, heightOut: Int) -> [UInt8] {
        var result = [UInt8](); result.reserveCapacity(widthOut * heightOut * 4)
        for row in y..<y + heightOut {
            result.append(contentsOf: bytes[(row * width + x) * 4..<(row * width + x + widthOut) * 4])
        }
        return result
    }

    private var repository: URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<4 { url.deleteLastPathComponent() }
        return url.standardizedFileURL.resolvingSymlinksInPath()
    }

    private var allowedRoot: URL {
        repository.appendingPathComponent(
            "example-images/参考效果分析/眼睛/本地测量/iris-migration-20261017", isDirectory: true)
    }

    /// Check every read/write target, including existing leaf symlinks. Being
    /// under a folder named local is not a substitute for a real ignore rule.
    private func checkedLocalURL(_ input: URL) throws -> URL {
        let expectedRoot = allowedRoot.standardizedFileURL
        let root = expectedRoot.resolvingSymlinksInPath()
        let url = input.standardizedFileURL
        let resolved = url.resolvingSymlinksInPath()
        guard root.path == expectedRoot.path, resolved.path == url.path,
              resolved.path == root.path || resolved.path.hasPrefix(root.path + "/") else {
            throw LocalReplayError.invalidBoundary
        }
        let relative = String(resolved.path.dropFirst(repository.path.count + 1))
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.currentDirectoryURL = repository
        process.arguments = ["check-ignore", "-q", "--", relative]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { throw LocalReplayError.ignoredLocationRequired }
        return resolved
    }

    func testLocalBoundaryRejectsTrackedTargetsAndSymlinkEscapes() throws {
        XCTAssertThrowsError(try checkedLocalURL(URL(fileURLWithPath: #filePath)))
        let local = allowedRoot.appendingPathComponent("boundary-" + UUID().uuidString, isDirectory: true)
        let external = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: local, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: external, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: local)
            try? FileManager.default.removeItem(at: external)
        }
        let link = local.appendingPathComponent("escape")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: external)
        XCTAssertThrowsError(try checkedLocalURL(link.appendingPathComponent("points.json")))
        XCTAssertNoThrow(try checkedLocalURL(local.appendingPathComponent("aggregate.json")))
    }
}
#endif
