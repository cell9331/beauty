import Foundation
import XCTest
import BeautySDK
@testable import BeautyDemo

final class InputPipelinePrivacyTests: XCTestCase {
    func testPIPE08D09GeneratedInfoPlistPurposeStringsAreLocalFirst() throws {
        let project = try readTextFile("BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj")
        let cameraPurpose = "Use the camera to preview beauty processing on this device."
        let photoPurpose = "Select photos to preview beauty processing on this device."

        XCTAssertEqual(occurrences(of: "INFOPLIST_KEY_NSCameraUsageDescription", in: project), 2)
        XCTAssertEqual(occurrences(of: "INFOPLIST_KEY_NSPhotoLibraryUsageDescription", in: project), 2)
        XCTAssertEqual(occurrences(of: cameraPurpose, in: project), 2)
        XCTAssertEqual(occurrences(of: photoPurpose, in: project), 2)
        XCTAssertFalse(project.localizedCaseInsensitiveContains("upload"))
        XCTAssertFalse(project.localizedCaseInsensitiveContains("cloud"))
    }

    func testPIPE08D13LocalFirstInputSourcesRejectNetworkPersistenceAndRawErrorCopy() throws {
        let files = try swiftFiles(in: [
            "BeautyDemo/BeautyDemo/Camera",
            "BeautyDemo/BeautyDemo/Editor",
            "BeautyDemo/BeautyDemo/Support"
        ])
        let forbiddenTokens = [
            "URLSession",
            "http" + "://",
            "https" + "://",
            "up" + "load",
            "/private" + "/var",
            "NSError",
            "AV" + "Error"
        ]

        let matches = try matches(for: forbiddenTokens, in: files)

        XCTAssertTrue(matches.isEmpty, matches.joined(separator: "\n"))
    }

    func testPIPE02RealtimeCameraPathDoesNotUseUIImageConversion() throws {
        let cameraFiles = try swiftFiles(in: ["BeautyDemo/BeautyDemo/Camera"])
        let matches = try matches(for: ["UIImage"], in: cameraFiles)
        let pipeline = try readTextFile("BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift")

        XCTAssertTrue(matches.isEmpty, matches.joined(separator: "\n"))
        XCTAssertTrue(pipeline.contains("process("))
        XCTAssertTrue(pipeline.contains("pixelBuffer:"))
    }

    func testPIPE08FacadeOnlyImportsCoverDemoAndTests() throws {
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

    func testEFFECT03DemoResourceControlsAvoidRawResourceImplementationDetails() throws {
        let files = try swiftFiles(in: [
            "BeautyDemo/BeautyDemo/Panel",
            "BeautyDemo/BeautyDemo/State"
        ])
        let forbiddenTokens = [
            "/private" + "/var",
            "NSError",
            "Bundle.",
            "rawPresetJson",
            "Visual update pending " + "Phase 6",
            "../",
            ".cube",
            "LUTPass",
            "ColorPass",
            "thumbnail",
            "swatch"
        ]
        let forbiddenImports = [
            #"(?m)^\s*import Beauty(Core|Render|Detection|Effects|Resources)\b"#
        ]

        let tokenMatches = try matches(for: forbiddenTokens, in: files)
        let importMatches = try matches(forRegexPatterns: forbiddenImports, in: files)

        XCTAssertTrue((tokenMatches + importMatches).isEmpty, (tokenMatches + importMatches).joined(separator: "\n"))
    }

    func testDEMO06ParameterJSONSurfacesStayLocalFirstAndCopyPasteOnly() throws {
        let files = try swiftFiles(in: [
            "BeautyDemo/BeautyDemo/State",
            "BeautyDemo/BeautyDemo/Editor"
        ])
        let forbiddenTokens = [
            "URL" + "Session",
            "http" + "://",
            "https" + "://",
            "up" + "load",
            "Document" + "Picker",
            "file" + "Importer",
            "file" + "Exporter",
            "raw" + "PresetJson",
            "/private" + "/var",
            "NS" + "Error"
        ]

        let tokenMatches = try matches(for: forbiddenTokens, in: files)

        XCTAssertTrue(tokenMatches.isEmpty, tokenMatches.joined(separator: "\n"))
    }

    func testDEMO07PreviewDebugOverlaySurfacesStayRedactedAndGeometryFree() throws {
        let files = try swiftFiles(in: [
            "BeautyDemo/BeautyDemo/Camera",
            "BeautyDemo/BeautyDemo/Editor"
        ])
        let forbiddenTokens = [
            "VN" + "FaceObservation",
            "bounding" + "Box",
            "land" + "mark",
            "CGPoint",
            "CGRect",
            "NS" + "Error",
            "/private" + "/var",
            "raw" + "PresetJson",
            "image " + "bytes",
            "http" + "://",
            "https" + "://"
        ]
        let overlayText = try readTextFile("BeautyDemo/BeautyDemo/Editor/PreviewDebugOverlayState.swift")

        XCTAssertTrue(overlayText.contains("processing_paused"))
        XCTAssertTrue(overlayText.contains("photo_decode_failed"))
        XCTAssertTrue(overlayText.contains("Warnings"))

        let tokenMatches = try matches(for: forbiddenTokens, in: files)
            .filter { !$0.contains("ImageInputModels.swift: contains CGRect") }

        XCTAssertTrue(tokenMatches.isEmpty, tokenMatches.joined(separator: "\n"))
    }

    func testD13FriendlyInputCopyIsPresentAndRawCopyIsAbsent() throws {
        let editorText = try readTextFile("BeautyDemo/BeautyDemo/Editor/EditorShellView.swift")
        let imageModelsText = try readTextFile("BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift")
        let cameraText = try readTextFile("BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift")

        XCTAssertTrue(editorText.contains("Allow camera access to preview processing on this device. Photo mode is still available."))
        XCTAssertTrue(editorText.contains("Select an image to process locally through BeautySDK."))
        XCTAssertTrue(imageModelsText.contains("Processing photo..."))
        XCTAssertTrue(imageModelsText.contains("Could not read that photo. Choose another image."))
        XCTAssertTrue(cameraText.contains("Processing paused. Showing the last usable preview."))

        let userFacingCopy = [editorText, imageModelsText, cameraText].joined(separator: "\n")
        XCTAssertFalse(userFacingCopy.contains("NSError"))
        XCTAssertFalse(userFacingCopy.contains("/private" + "/var"))
        XCTAssertFalse(userFacingCopy.contains("AV" + "Error"))
    }

    func testPIPE07DetectionStatusPresentationUsesUISpecCopy() {
        let cases: [(BeautyDetectionSummary, String)] = [
            (
                .noFace,
                "No face detected. Face adjustments are paused."
            ),
            (
                BeautyDetectionSummary(
                    availability: .partial,
                    reasons: [.missingLandmarks],
                    faceCount: 1,
                    usedFaceCount: 0
                ),
                "Face partly visible. Some face adjustments are softened."
            ),
            (
                BeautyDetectionSummary(
                    availability: .lowConfidence,
                    reasons: [.lowConfidenceFace],
                    faceCount: 1,
                    usedFaceCount: 0
                ),
                "Face detection is uncertain. Face adjustments are softened."
            ),
            (
                BeautyDetectionSummary(
                    availability: .stale,
                    reasons: [.staleDetection],
                    faceCount: 1,
                    usedFaceCount: 1
                ),
                "Waiting for a fresh face reading. Showing the last usable preview."
            )
        ]

        for (summary, expectedText) in cases {
            XCTAssertEqual(DetectionStatusPresentation(summary: summary).statusText, expectedText)
        }
    }

    func testPIPE07DetectionStatusAndDebugSummariesAvoidSensitivePayloads() {
        let summaries = [
            BeautyDetectionSummary.noFace,
            BeautyDetectionSummary(
                availability: .partial,
                reasons: [.missingLandmarks, .mappingFailed],
                faceCount: 1,
                usedFaceCount: 0,
                detectionDurationMs: 2.5,
                mappingDurationMs: 1.25
            ),
            BeautyDetectionSummary(
                availability: .lowConfidence,
                reasons: [.lowConfidenceFace],
                faceCount: 1,
                usedFaceCount: 0
            ),
            BeautyDetectionSummary(
                availability: .stale,
                reasons: [.staleDetection],
                faceCount: 1,
                usedFaceCount: 1
            )
        ]

        let rendered = summaries
            .map { DetectionStatusPresentation(summary: $0) }
            .flatMap { presentation in
                [
                    presentation.statusText,
                    presentation.debugSummary.map(String.init(describing:))
                ].compactMap { $0 }
            }
            .joined(separator: "\n")

        let forbiddenTokens = [
            "VNFaceObservation",
            "boundingBox",
            "CGPoint",
            "CGRect",
            "NSError",
            "/private" + "/var",
            "http" + "://",
            "https" + "://"
        ]

        for token in forbiddenTokens {
            XCTAssertFalse(rendered.contains(token), "Detection status leaked \(token): \(rendered)")
        }
    }

    func testPIPE07PublicDetectionSourcesAvoidGeometryRawFrameworksAndPaths() throws {
        let files = try swiftFiles(in: [
            "BeautySDK/Sources/BeautyCore",
            "BeautySDK/Sources/BeautySDK",
            "BeautyDemo/BeautyDemo/Camera",
            "BeautyDemo/BeautyDemo/Editor"
        ])
        let forbiddenPatterns = [
            #"(?m)^\s*public\b[^\n]*(Point|Rect|bounding|landmark)"#,
            #"\bVNFaceObservation\b"#,
            #"\bNSError\b"#,
            #"/private/var"#
        ]

        let matches = try matches(forRegexPatterns: forbiddenPatterns, in: files)

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

        throw SourceScanError.missingRepoRoot
    }

    private func readTextFile(_ relativePath: String) throws -> String {
        let file = try repoRoot().appendingPathComponent(relativePath)
        return try String(contentsOf: file, encoding: .utf8)
    }

    private func swiftFiles(in relativeDirectories: [String]) throws -> [URL] {
        let root = try repoRoot()
        let manager = FileManager.default
        var files: [URL] = []

        for relativeDirectory in relativeDirectories {
            let directory = root.appendingPathComponent(relativeDirectory)
            guard let enumerator = manager.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey]) else {
                throw SourceScanError.missingDirectory(relativeDirectory)
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

    private func matches(for tokens: [String], in files: [URL]) throws -> [String] {
        var results: [String] = []

        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            for token in tokens {
                if text.contains(token) {
                    results.append("\(relativePath(file)): contains \(token)")
                }
            }
        }

        return results
    }

    private func matches(forRegexPatterns patterns: [String], in files: [URL]) throws -> [String] {
        let expressions = try patterns.map {
            try NSRegularExpression(pattern: $0)
        }
        var results: [String] = []

        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            for expression in expressions {
                for match in expression.matches(in: text, range: range) {
                    let line = lineNumber(for: match.range.location, in: text)
                    let matchedText = (text as NSString).substring(with: match.range)
                    results.append("\(relativePath(file)):\(line) matched \(matchedText)")
                }
            }
        }

        return results
    }

    private func occurrences(of needle: String, in haystack: String) -> Int {
        haystack.components(separatedBy: needle).count - 1
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

private enum SourceScanError: Error {
    case missingRepoRoot
    case missingDirectory(String)
}
