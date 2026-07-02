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

    var description: String {
        switch self {
        case .missing(let name):
            return "Missing required regression input: \(name)"
        case .unreadable(let name):
            return "Could not read required regression input: \(name)"
        }
    }
}
