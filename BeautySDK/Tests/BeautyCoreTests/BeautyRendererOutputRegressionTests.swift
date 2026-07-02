import CoreImage
import ImageIO
import XCTest
import BeautySDK

// Requirement evidence: RENDER-01, RENDER-02.
final class BeautyRendererOutputRegressionTests: XCTestCase {
    private static let rendererSourceRelativePath = "BeautySDK/Sources/BeautyExampleRenderer/main.swift"

    private static let expectedRendererCaseIDs = [
        "skinSmoothing_0p50",
        "skinWhitening_0p50",
        "skinRosy_0p40",
        "skinSharpen_0p40",
        "brightness_plus0p25",
        "contrast_plus0p25",
        "filter_softClean_0p50",
        "filter_warmLight_0p50",
        "skinCombo_0p50"
    ]

    private static let fixtureNames = [
        "e1.png",
        "e2.png",
        "e3.png",
        "e4.png",
        "e5.png"
    ]

    func testRendererCaseInventoryMatchesCurrentPublicFacadeMatrix() throws {
        let source = try rendererSource()

        XCTAssertEqual(
            rendererCaseIDs(in: source),
            Self.expectedRendererCaseIDs,
            "BeautyExampleRenderer/main.swift renderer case IDs changed"
        )
        XCTAssertTrue(source.contains("import BeautySDK"), "BeautyExampleRenderer/main.swift should import BeautySDK")

        for forbiddenTarget in ["BeautyCore", "BeautyDetection", "BeautyEffects", "BeautyRender", "BeautyResources"] {
            XCTAssertFalse(
                source.contains("import \(forbiddenTarget)"),
                "BeautyExampleRenderer/main.swift should not import \(forbiddenTarget)"
            )
        }
    }

    func testDefaultParametersPreserveCurrentFixturePixelsBeforeWatermark() throws {
        let engine = try BeautyEngine(configuration: .default)

        for fixtureURL in try exampleFixtureURLs() {
            let fixtureName = relativeFixtureName(for: fixtureURL)
            let input = try fixtureImage(at: fixtureURL, named: fixtureName)
            let result = try engine.processResult(
                image: input,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                parameters: BeautyParameters()
            )

            XCTAssertEqual(result.output.extent, input.extent, "\(fixtureName) changed extent before watermark")
            XCTAssertEqual(
                try renderedRGBABytes(from: result.output, named: fixtureName),
                try renderedRGBABytes(from: input, named: fixtureName),
                "\(fixtureName) changed rendered RGBA bytes before watermark"
            )
        }
    }

    private func rendererSource() throws -> String {
        let url = try repositoryRootURL().appendingPathComponent(Self.rendererSourceRelativePath)
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw RegressionTestError.unreadable(Self.rendererSourceRelativePath)
        }
    }

    private func rendererCaseIDs(in source: String) -> [String] {
        source.split(separator: "\n").compactMap { line in
            let marker = "id: \""
            guard let markerRange = line.range(of: marker) else {
                return nil
            }
            let remainder = line[markerRange.upperBound...]
            guard let endIndex = remainder.firstIndex(of: "\"") else {
                return nil
            }
            return String(remainder[..<endIndex])
        }
    }

    private func exampleFixtureURLs() throws -> [URL] {
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input", isDirectory: true)
        return try Self.fixtureNames.map { fixtureName in
            let url = inputDirectory.appendingPathComponent(fixtureName)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw RegressionTestError.missing("example-images/input/\(fixtureName)")
            }
            return url
        }
    }

    private func fixtureImage(at url: URL, named fixtureName: String) throws -> CIImage {
        guard let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) else {
            throw RegressionTestError.unreadable("example-images/input/\(fixtureName)")
        }
        return image
    }

    private func renderedRGBABytes(from image: CIImage, named fixtureName: String) throws -> [UInt8] {
        let extent = image.extent
        let width = Int(extent.width.rounded(.toNearestOrAwayFromZero))
        let height = Int(extent.height.rounded(.toNearestOrAwayFromZero))
        guard width > 0, height > 0, CGFloat(width) == extent.width, CGFloat(height) == extent.height else {
            throw RegressionTestError.invalidExtent(fixtureName)
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace
        ])
        let rowBytes = width * 4
        var bytes = [UInt8](repeating: 0, count: rowBytes * height)
        try bytes.withUnsafeMutableBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress else {
                throw RegressionTestError.unreadable(fixtureName)
            }
            context.render(
                image,
                toBitmap: baseAddress,
                rowBytes: rowBytes,
                bounds: extent,
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return bytes
    }

    private func relativeFixtureName(for url: URL) -> String {
        url.lastPathComponent
    }

    private func repositoryRootURL() throws -> URL {
        var current = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while current.path != "/" {
            let renderer = current.appendingPathComponent(Self.rendererSourceRelativePath)
            if FileManager.default.fileExists(atPath: renderer.path) {
                return current
            }
            current.deleteLastPathComponent()
        }
        throw RegressionTestError.missing(Self.rendererSourceRelativePath)
    }
}

private enum RegressionTestError: Error, CustomStringConvertible {
    case missing(String)
    case unreadable(String)
    case invalidExtent(String)

    var description: String {
        switch self {
        case .missing(let name):
            return "Missing required regression input: \(name)"
        case .unreadable(let name):
            return "Could not read required regression input: \(name)"
        case .invalidExtent(let name):
            return "Invalid rendered image extent for \(name)"
        }
    }
}
