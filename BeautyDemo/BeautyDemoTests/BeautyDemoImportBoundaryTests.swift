import Foundation
import XCTest
@testable import BeautyDemo

final class BeautyDemoImportBoundaryTests: XCTestCase {
    func testDemoTestTargetCanLoadEditorShellState() {
        let modeItems = DemoFixtures.inputModeItems(selectedMode: nil)

        XCTAssertEqual(DemoFixtures.activeCategoryTitle, "Beauty")
        XCTAssertEqual(modeItems.map(\.title), ["Camera", "Photo"])
        XCTAssertTrue(modeItems.allSatisfy(\.isEnabled))
    }

    func testPIPE08DemoAndTestsStayOnPublicBeautySDKFacade() throws {
        let files = try swiftFiles(in: [
            "BeautyDemo/BeautyDemo",
            "BeautyDemo/BeautyDemoTests"
        ])
        let internalImport = try NSRegularExpression(
            pattern: #"(?m)^\s*import Beauty(Core|Render|Detection|Effects|Resources)\b"#
        )
        var matches: [String] = []
        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            for match in internalImport.matches(in: text, range: range) {
                matches.append("\(relativePath(file)):\(lineNumber(for: match.range.location, in: text))")
            }
        }

        XCTAssertTrue(matches.isEmpty, matches.joined(separator: "\n"))
    }

    private func repoRoot() throws -> URL {
        var cursor = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

        while cursor.path != "/" {
            let projectPath = cursor.appendingPathComponent("BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj")
            if FileManager.default.fileExists(atPath: projectPath.path) {
                return cursor
            }
            cursor.deleteLastPathComponent()
        }

        throw ImportBoundaryScanError.missingRepoRoot
    }

    private func swiftFiles(in relativeDirectories: [String]) throws -> [URL] {
        let root = try repoRoot()
        let manager = FileManager.default
        var files: [URL] = []

        for relativeDirectory in relativeDirectories {
            let directory = root.appendingPathComponent(relativeDirectory)
            guard let enumerator = manager.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey]) else {
                throw ImportBoundaryScanError.missingDirectory(relativeDirectory)
            }

            for item in enumerator {
                guard let file = item as? URL, file.pathExtension == "swift" else {
                    continue
                }
                let resourceValues = try file.resourceValues(forKeys: [.isRegularFileKey])
                if resourceValues.isRegularFile == true {
                    files.append(file)
                }
            }
        }

        return files.sorted { $0.path < $1.path }
    }

    private func relativePath(_ file: URL) -> String {
        guard let root = try? repoRoot().path else {
            return file.path
        }
        return file.path.replacingOccurrences(of: root + "/", with: "")
    }

    private func lineNumber(for utf16Offset: Int, in text: String) -> Int {
        let prefix = text.utf16.prefix(utf16Offset)
        return String(decoding: prefix, as: UTF16.self).reduce(into: 1) { count, character in
            if character == "\n" {
                count += 1
            }
        }
    }
}

private enum ImportBoundaryScanError: Error {
    case missingRepoRoot
    case missingDirectory(String)
}
