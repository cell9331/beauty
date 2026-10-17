import BeautyCore
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest

#if os(macOS)
/// Owner-local replay of a TEST-ONLY source-relative field. This is neither a
/// facade/host route nor an automatic semantic owner. Portraits, source points
/// and fitted values are explicit ignored inputs, never test-target constants.
final class BeautyUpperLidGeometryReferenceProbeTests: XCTestCase {
    private typealias Lab = BeautyUpperLidGeometryResearch
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private enum ReplayError: Error { case invalidInput, invalidBoundary, redactedReplayFailure }

    func testSourceRelativeLocalReplay() throws {
        let environment = ProcessInfo.processInfo.environment
        guard let manifest = environment["BEAUTY_UPPER_LID_RESEARCH_MANIFEST"],
              let points = environment["BEAUTY_UPPER_LID_RESEARCH_POINTS"],
              let output = environment["BEAUTY_UPPER_LID_RESEARCH_OUTPUT"] else {
            throw XCTSkip("Explicit ignored source-relative inputs are required; no portrait fallback.")
        }
        do {
            try replay(manifest: manifest, points: points, output: output)
        } catch {
            // Foundation errors may contain private input paths.
            throw ReplayError.redactedReplayFailure
        }
    }

    private func replay(manifest: String, points: String, output: String) throws {
        let values = try dictionary(Data(contentsOf: checked(URL(fileURLWithPath: manifest))))
        guard values["deployment_allowed"] as? Bool == false,
              values["comparison_contract"] as? String == "source_relative_only",
              let sourcePath = values["source_png"] as? String,
              let configurations = values["configurations"] as? [String: [String: Any]],
              !configurations.isEmpty else { throw ReplayError.invalidInput }
        let source = try loadPNG(checked(URL(fileURLWithPath: sourcePath)))
        let rawPoints = try JSONSerialization.jsonObject(with:
            Data(contentsOf: checked(URL(fileURLWithPath: points))))
        guard let locations = rawPoints as? [[Double]],
              locations.allSatisfy({ $0.count == 2 && $0.allSatisfy(\.isFinite) }) else {
            throw ReplayError.invalidInput
        }
        let directory = try checked(URL(fileURLWithPath: output, isDirectory: true))
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try writePNG(source.bytes, width: source.width, height: source.height,
            to: directory.appendingPathComponent("decoded-source.png"))
        var receipts = [[String: Any]]()
        for name in configurations.keys.sorted() {
            guard name.range(of: "^[A-Za-z0-9_-]+$", options: .regularExpression) != nil,
                  let configuration = configurations[name] else { throw ReplayError.invalidInput }
            let regions = try calibrations(configuration)
            for progress in [0.0, 0.5, 1.0] {
                let request = Lab.Request(sourceRGBA: source.bytes, width: source.width, height: source.height,
                    sourceBinding: .bind(sourceRGBA: source.bytes, width: source.width, height: source.height),
                    calibrations: regions, progress: progress,
                    solverPolicy: .init(maximumIterations: 256, residualTolerancePixels: 0.000001))
                let start = ProcessInfo.processInfo.systemUptime
                let result = Lab.render(request)
                let elapsed = ProcessInfo.processInfo.systemUptime - start
                let label = name + "-p" + String(Int(progress * 100))
                try writePNG(result.rgba, width: source.width, height: source.height,
                    to: directory.appendingPathComponent(label + "-map.png"))
                if progress == 0 {
                    XCTAssertTrue(result.rgba == source.bytes, "Source-relative zero must be byte identity.")
                }
                if result.appliedRegionCount == 0 {
                    XCTAssertTrue(result.rgba == source.bytes, "Refusal cannot substitute another raster.")
                }
                // Partial admission remains pixel-only; never export a nominal
                // all-region field as if the refused region had been applied.
                if result.appliedRegionCount == regions.count || result.appliedRegionCount == 0 {
                    var field = [[String: [Double]]]()
                    for pair in locations {
                        let p = Lab.Point(x: pair[0], y: pair[1])
                        var dx = 0.0, dy = 0.0
                        if result.appliedRegionCount == regions.count {
                            for region in regions {
                                guard let q = Lab.forwardPoint(p, calibration: region, progress: progress) else {
                                    throw ReplayError.invalidInput
                                }
                                dx += q.x - p.x; dy += q.y - p.y
                            }
                        }
                        field.append(["source": pair, "target": [p.x + dx, p.y + dy]])
                    }
                    try JSONSerialization.data(withJSONObject: field, options: [.sortedKeys])
                        .write(to: checked(directory.appendingPathComponent(label + "-field.json")))
                }
                receipts.append([
                    "configuration": name, "progress": progress,
                    "status": String(describing: result.status),
                    "appliedRegions": result.appliedRegionCount, "refusedRegions": result.refusedRegionCount,
                    "refusals": result.refusalCounts.reduce(into: [String: Int]()) { $0[$1.key.rawValue] = $1.value },
                    "seconds": elapsed, "width": source.width, "height": source.height,
                    "comparisonContract": "source_relative_only", "deploymentAllowed": false,
                    "automaticSemanticOwnership": false, "productionIntegration": false
                ])
            }
        }
        try JSONSerialization.data(withJSONObject: receipts, options: [.prettyPrinted, .sortedKeys])
            .write(to: checked(directory.appendingPathComponent("swift-execution-receipt.json")))
    }

    private func calibrations(_ values: [String: Any]) throws -> [Lab.Calibration] {
        try [("left", Lab.Side.left), ("right", Lab.Side.right)].map { name, side in
            guard let value = values[name] as? [String: Any] else { throw ReplayError.invalidInput }
            func point(_ key: String) throws -> Lab.Point {
                guard let a = value[key] as? [Double], a.count == 2, a.allSatisfy(\.isFinite) else {
                    throw ReplayError.invalidInput
                }
                return .init(x: a[0], y: a[1])
            }
            func number(_ key: String) throws -> Double {
                guard let v = value[key] as? Double, v.isFinite else { throw ReplayError.invalidInput }
                return v
            }
            func rectangle(_ a: [Double]) throws -> Lab.Region {
                guard a.count == 4, a.allSatisfy(\.isFinite), a[0] <= a[2], a[1] <= a[3] else {
                    throw ReplayError.invalidInput
                }
                return .rectangle(minX: a[0], minY: a[1], maxX: a[2], maxY: a[3])
            }
            guard let owner = value["owned_source_rectangle"] as? [Double],
                  let protected = value["protected_rectangles"] as? [[Double]] else {
                throw ReplayError.invalidInput
            }
            return Lab.Calibration(side: side, center: try point("center"), axisX: try point("axis_x"),
                superiorAxis: try point("superior_axis"), supportRadiusX: try number("support_radius_x"),
                supportRadiusY: try number("support_radius_y"), amplitudePixels: try number("amplitude_pixels"),
                ownedSourceDomain: try rectangle(owner), protectedRegions: try protected.map(rectangle))
        }
    }

    private func dictionary(_ data: Data) throws -> [String: Any] {
        guard let value = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ReplayError.invalidInput
        }
        return value
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
            "example-images/参考效果分析/眼睛/本地测量/upper-lid-migration-20261017", isDirectory: true)
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
