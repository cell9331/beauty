#if BEAUTY_OWNER_EYE_FIVE_CHECK
import BeautySDK
import CoreGraphics
import CryptoKit
import MachO
import Foundation
import ImageIO
import XCTest
@testable import BeautyEditor

/// Owner media remain in task-owned temporary input/output. This test captures
/// production pixels and mechanical contracts; an independent source-fixed
/// image oracle owns appearance, direction, amplitude and protected-region checks.
@MainActor final class EyeFivePortraitAcceptanceTests: XCTestCase {
    private struct SourceRasterGrid: Encodable {
        let width: Int
        let height: Int
        let bytesPerRow: Int
        let rowFormat: String
        let observationSite: String
        init(_ identity: OwnerSourceRasterIdentity) {
            width = identity.width; height = identity.height; bytesPerRow = identity.bytesPerRow
            rowFormat = identity.rowFormat; observationSite = identity.observationSite
        }
    }
    private struct Frame: Encodable {
        let tool: String
        let value: Int
        let changedPixels: Int
        let usedFaceCount: Int
        let meshPointCount: Int
        let dimensionsPreserved: Bool
        let alphaPreserved: Bool
        let sRGB: Bool
        let repeated: Bool?
        let warningCodes: [String]
        let actualBackend: String
        let cpuParityExact: Bool?
        let actualSourceRasterSHA256: String
        let actualSourceRasterGrid: SourceRasterGrid
    }
    private struct SourceEyeGeometryAggregate: Encodable {
        let meanEyeSpanToReferenceVisualWidthRatio: Double?
        let leftContourMeanAlongCornerAxisToSpan: Double
        let leftContourMeanAcrossCornerAxisToSpan: Double
        let rightContourMeanAlongCornerAxisToSpan: Double
        let rightContourMeanAcrossCornerAxisToSpan: Double
    }
    private struct ExecutionBinding: Encodable {
        let schemaVersion: Int
        let runName: String
        let resolution: String
        let mode: String
        let requestedBackend: String
        let inputSHA256: String
        // Encoded oracle-baseline source identity, distinct from the actual
        // SDK request/prepared raster observed by PhotoRenderer per frame.
        let renderSourceSHA256: String
        let nativeRunfileSHA256: String
        let nativeBuildReceiptSHA256: String
        let productionSourceSHA256: [String: String]
        let harnessSourceSHA256: String
        let mainExecutableSHA256: String
        let mainSDKPayloadSHA256: String
        let testExecutableSHA256: String
    }
    private struct ExecutionCapture {
        let binding: ExecutionBinding
        let runtimeArtifactPaths: [String: String]
    }
    private struct Receipt: Encodable {
        let schemaVersion: Int
        let detector: String
        let renderer: String
        let resolution: String
        let width: Int
        let height: Int
        let neutralIdentity: Bool
        let neutralRepeated: Bool
        let neutralRestored: Bool
        let neutralSourceRasterIdentity: OwnerSourceRasterIdentity
        let neutralRepeatedSourceRasterIdentity: OwnerSourceRasterIdentity
        let restoredSourceRasterIdentity: OwnerSourceRasterIdentity
        let sourceEyeGeometry: SourceEyeGeometryAggregate?
        let executionBinding: ExecutionBinding?
        let runtimeArtifactPaths: [String: String]?
        let frames: [Frame]
        let limitation: String
    }

    func testProductionPortraitFiveEyeFramesAndMechanicalContracts() async throws {
        let environment = ProcessInfo.processInfo.environment
        let manager = FileManager.default
        let inputURL: URL, outputURL: URL
        let runName: String, mode: String, resolution: String, backend: String
        #if targetEnvironment(simulator)
        let inputValue = try XCTUnwrap(environment["BEAUTY_EYE_FIVE_INPUT"], "temporary input environment is required")
        let outputValue = try XCTUnwrap(environment["BEAUTY_EYE_FIVE_OUTPUT_ROOT"], "temporary output root is required")
        inputURL = URL(fileURLWithPath: inputValue).standardizedFileURL.resolvingSymlinksInPath()
        outputURL = URL(fileURLWithPath: outputValue, isDirectory: true).standardizedFileURL.resolvingSymlinksInPath()
        runName = try XCTUnwrap(environment["BEAUTY_EYE_FIVE_RUN_NAME"], "run identity is required")
        mode = environment["BEAUTY_EYE_FIVE_MODE"] ?? "quarters"
        resolution = environment["BEAUTY_EYE_FIVE_RESOLUTION"] ?? "preview"
        backend = environment["BEAUTY_EYE_FIVE_BACKEND"] ?? "cpu"
        // Foundation can retain the host /tmp alias after resolving symlinks.
        guard (inputURL.path.hasPrefix("/private/tmp/") || inputURL.path.hasPrefix("/tmp/")),
              (outputURL.path.hasPrefix("/private/tmp/") || outputURL.path.hasPrefix("/tmp/")) else {
            throw NSError(domain: "EyeFiveReferenceCheck", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "temporary task-root admission rejected"])
        }
        #else
        let documents = try manager.url(for: .documentDirectory, in: .userDomainMask,
                                        appropriateFor: nil, create: false).standardizedFileURL.resolvingSymlinksInPath()
        let root = documents.appendingPathComponent("OwnerEyeFiveReference", isDirectory: true)
        let rootValues = try root.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard rootValues.isDirectory == true, rootValues.isSymbolicLink != true,
              root.standardizedFileURL.resolvingSymlinksInPath().deletingLastPathComponent() == documents else {
            throw NSError(domain: "EyeFiveReferenceCheck", code: 8,
                          userInfo: [NSLocalizedDescriptionKey: "physical Documents task-root admission rejected"])
        }
        outputURL = root
        inputURL = root.appendingPathComponent("input.png").standardizedFileURL.resolvingSymlinksInPath()
        let runURL = root.appendingPathComponent("run-name.txt").standardizedFileURL.resolvingSymlinksInPath()
        guard runURL.deletingLastPathComponent() == root,
              try runURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true,
              let runSize = try runURL.resourceValues(forKeys: [.fileSizeKey]).fileSize, runSize <= 128 else {
            throw NSError(domain: "EyeFiveReferenceCheck", code: 9)
        }
        runName = try String(contentsOf: runURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        mode = environment["BEAUTY_EYE_FIVE_MODE"] ?? "endpoints"
        resolution = environment["BEAUTY_EYE_FIVE_RESOLUTION"] ?? "full"
        backend = environment["BEAUTY_EYE_FIVE_BACKEND"] ?? "gpu"
        #endif
        let inputPath = inputURL.path
        let outputRoot = outputURL.path
        let fullResolution = resolution == "full"
        guard inputURL.deletingLastPathComponent() == outputURL,
              try inputURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true,
              runName.range(of: "^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$", options: .regularExpression) != nil,
              runName.utf8.count <= 64, ["endpoints", "quarters"].contains(mode),
              ["preview", "full"].contains(resolution), ["cpu", "gpu"].contains(backend) else {
            throw NSError(domain: "EyeFiveReferenceCheck", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "bounded capture configuration admission rejected"])
        }
        #if targetEnvironment(simulator)
        let verifyMetal = false
        #else
        let verifyMetal = backend == "gpu"
        guard !verifyMetal || fullResolution else {
            throw NSError(domain: "EyeFiveReferenceCheck", code: 10)
        }
        #endif
        let output = outputURL.appendingPathComponent(runName, isDirectory: true)
        guard !FileManager.default.fileExists(atPath: output.path) else {
            throw NSError(domain: "EyeFiveReferenceCheck", code: 2)
        }
        let data = try ImageInput.readBoundedFile(URL(fileURLWithPath: inputPath))
        let source = try XCTUnwrap(CGImageSourceCreateWithData(data as CFData, nil))
        let sourceImage = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
        let renderer = PhotoRenderer(preferredBackend: backend == "gpu" ? .gpu : .cpu)
        let photo = try await renderer.load(data)
        let parityRenderer = verifyMetal ? PhotoRenderer(preferredBackend: .cpu) : nil
        let parityPhoto: ImportedPhoto?
        if let parityRenderer { parityPhoto = try await parityRenderer.load(data) }
        else { parityPhoto = nil }
        let previewOriginal = TestImage.pixels(photo.preview)
        let selectedSource = fullResolution ? sourceImage : photo.preview
        let original = [UInt8](TestImage.pixels(selectedSource))
        let width = selectedSource.width, height = selectedSource.height
        // Hash actual loaded native artifacts and the execution configuration
        // before the first output write. Encoded source bytes bind the oracle;
        // no source geometry or runtime container path enters this provenance.
        let provenanceRequested = environment["BEAUTY_EYE_FIVE_RUNFILE_PATH"] != nil
            || environment["BEAUTY_EYE_FIVE_NATIVE_BUILD_RECEIPT"] != nil
        let oracleBaselineSourceData: Data?
        if provenanceRequested {
            oracleBaselineSourceData = fullResolution ? data : try await renderer.encodePNG(
                canonicalImage(original, width: width, height: height))
        } else { oracleBaselineSourceData = nil }
        let executionCapture = try nativeExecutionCapture(environment: environment,
            runName: runName, mode: mode, resolution: resolution, backend: backend,
            inputData: data, oracleBaselineSourceData: oracleBaselineSourceData)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        if !fullResolution, let oracleBaselineSourceData {
            try oracleBaselineSourceData.write(to: output.appendingPathComponent("source.png"))
        }
        let detected = try await renderer.landmarks(selectedSource)
        let face = try XCTUnwrap(detected.first)
        XCTAssertEqual(detected.count, 1)
        XCTAssertEqual(face.detectorName, "MediaPipe 478")
        XCTAssertEqual(face.points.count, 478)
        // Derive only relative scalar aggregates from this existing transient
        // owner evidence. Never encode, log, export or draw the source points.
        let sourceEyeGeometry: SourceEyeGeometryAggregate?
        if environment["BEAUTY_EYE_FIVE_DIAGNOSTIC"] == "1" {
            sourceEyeGeometry = try sourceGeometryAggregate(
                points: face.points, width: width, height: height,
                referenceNormalizedWidth: environment["BEAUTY_EYE_FIVE_REFERENCE_EYE_MEAN_NORMALIZED_WIDTH"].flatMap(Double.init)
            )
        } else { sourceEyeGeometry = nil }
        let neutral = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: fullResolution)
        let neutralSourceIdentity = try XCTUnwrap(neutral.ownerSourceRasterIdentity,
            "actual neutral source observation is required")
        let neutralPixels = [UInt8](TestImage.pixels(neutral.image))
        let neutralIdentity = neutralPixels == original
        XCTAssertTrue(neutralIdentity, "upright sRGB input must remain exact at neutral")
        XCTAssertEqual(neutral.image.width, width)
        XCTAssertEqual(neutral.image.height, height)
        let neutralAgain = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: fullResolution)
        let neutralAgainSourceIdentity = try XCTUnwrap(neutralAgain.ownerSourceRasterIdentity,
            "actual repeated neutral source observation is required")
        let neutralRepeated = [UInt8](TestImage.pixels(neutralAgain.image)) == neutralPixels
        XCTAssertTrue(neutralRepeated)
        try await renderer.encodePNG(neutral.image).write(to: output.appendingPathComponent("neutral.png"))
        try await renderer.encodePNG(canonicalImage(neutralPixels, width: width, height: height))
            .write(to: output.appendingPathComponent("canonical-neutral.png"))
        let firstTools = [("eye.size", "size"), ("eye.positionY", "Y"), ("eye.eyelidSize", "height"),
                          ("eye.length", "length"), ("eye.spacing", "spacing")]
        let nextTools = [("eye.lowerLid", "lowerLid"), ("eye.tailLift", "tail"), ("eye.tilt", "tilt"),
                         ("eye.innerCorner", "inner"), ("eye.outerCorner", "outer")]
        let group = environment["BEAUTY_EYE_FIVE_GROUP"] ?? "first"
        guard ["first", "next", "all", "iris", "reference"].contains(group) else {
            throw NSError(domain: "EyeFiveReferenceCheck", code: 11)
        }
        let irisTools = [("eye.irisSize", "iris")]
        let tools: [(String, String)]
        switch group {
        case "next": tools = nextTools
        case "all": tools = firstTools + nextTools
        case "iris": tools = irisTools
        case "reference": tools = firstTools + nextTools + irisTools
        default: tools = firstTools
        }
        let values: [Float] = mode == "endpoints" ? [-100, 100] : [-25, -50, -75, -100, 25, 50, 75, 100]
        var frames = [Frame]()
        for (id, label) in tools {
            let tool = try XCTUnwrap(ToolCatalog.find(id))
            for value in values {
                var snapshot = EditorSnapshot()
                tool.setValue(value, in: &snapshot.parameters)
                XCTAssertEqual(tool.value(in: snapshot.parameters), value, accuracy: 0.0001, id)
                let result = try await renderer.render(photo, snapshot: snapshot, fullResolution: fullResolution)
                let actualSource = try XCTUnwrap(result.ownerSourceRasterIdentity,
                    "actual SDK request source observation is required")
                let pixels = [UInt8](TestImage.pixels(result.image))
                let dimensions = result.image.width == width && result.image.height == height && pixels.count == original.count
                XCTAssertTrue(dimensions, id)
                guard dimensions else { throw NSError(domain: "EyeFiveReferenceCheck", code: 3) }
                let alpha = stride(from: 3, to: pixels.count, by: 4).allSatisfy { pixels[$0] == original[$0] }
                let isSRGB = result.image.colorSpace?.name == CGColorSpace.sRGB
                let usedFaces = result.detection?.usedFaceCount ?? 0
                let meshCount = Int(result.metrics["beauty.detection.meshPointCount"] ?? 0)
                XCTAssertEqual(usedFaces, 1, id)
                XCTAssertEqual(meshCount, 478, id)
                XCTAssertTrue(alpha, id)
                XCTAssertTrue(isSRGB, id)
                var cpuParityExact: Bool?
                if verifyMetal {
                    XCTAssertEqual(result.backendName, "Metal", id + " must execute Metal without fallback")
                    let cpu = try XCTUnwrap(parityRenderer)
                    let cpuPhoto = try XCTUnwrap(parityPhoto)
                    let cpuResult = try await cpu.render(cpuPhoto, snapshot: snapshot, fullResolution: true)
                    XCTAssertEqual(cpuResult.backendName, "CPU", id)
                    cpuParityExact = [UInt8](TestImage.pixels(cpuResult.image)) == pixels
                    XCTAssertTrue(cpuParityExact == true, id + " independent CPU/actual Metal RGBA must match exactly")
                } else {
                    let expectedBackend = id == "eye.irisSize" && !fullResolution
                        ? "CPU original iris preview" : "CPU"
                    XCTAssertEqual(result.backendName, expectedBackend, id)
                }
                let changed = stride(from: 0, to: pixels.count, by: 4).reduce(0) { count, offset in
                    count + ((0..<4).contains { pixels[offset + $0] != original[offset + $0] } ? 1 : 0)
                }
                XCTAssertGreaterThan(changed, 0, id)
                var repeated: Bool?
                if abs(value) == 100 {
                    let repeatedResult = try await renderer.render(photo, snapshot: snapshot, fullResolution: fullResolution)
                    if verifyMetal { XCTAssertEqual(repeatedResult.backendName, "Metal", id) }
                    repeated = [UInt8](TestImage.pixels(repeatedResult.image)) == pixels
                    XCTAssertTrue(repeated == true, id + " endpoint pixels must repeat")
                    let repeatedName = "repeat-" + label + (value < 0 ? "-left-q100.png" : "-right-q100.png")
                    try await renderer.encodePNG(repeatedResult.image)
                        .write(to: output.appendingPathComponent(repeatedName))
                }
                frames.append(Frame(tool: id, value: Int(value), changedPixels: changed,
                                    usedFaceCount: usedFaces, meshPointCount: meshCount,
                                    dimensionsPreserved: dimensions, alphaPreserved: alpha,
                                    sRGB: isSRGB, repeated: repeated, warningCodes: result.warningCodes,
                                    actualBackend: result.backendName, cpuParityExact: cpuParityExact,
                                    actualSourceRasterSHA256: actualSource.sha256,
                                    actualSourceRasterGrid: SourceRasterGrid(actualSource)))
                let name = label + (value < 0 ? "-left-q" : "-right-q") + String(Int(abs(value))) + ".png"
                try await renderer.encodePNG(result.image).write(to: output.appendingPathComponent(name))
                try await renderer.encodePNG(canonicalImage(pixels, width: width, height: height))
                    .write(to: output.appendingPathComponent("canonical-" + name))
            }
        }
        let restored = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: fullResolution)
        let restoredSourceIdentity = try XCTUnwrap(restored.ownerSourceRasterIdentity,
            "actual restored source observation is required")
        let neutralRestored = [UInt8](TestImage.pixels(restored.image)) == original
        XCTAssertTrue(neutralRestored)
        XCTAssertEqual(TestImage.pixels(photo.preview), previewOriginal)
        if verifyMetal {
            let cpu = try XCTUnwrap(parityRenderer), cpuPhoto = try XCTUnwrap(parityPhoto)
            let cpuRestored = try await cpu.render(cpuPhoto, snapshot: EditorSnapshot(), fullResolution: true)
            XCTAssertEqual([UInt8](TestImage.pixels(cpuRestored.image)), original)
        }
        let receipt = Receipt(schemaVersion: 1, detector: face.detectorName, renderer: "production PhotoRenderer / preferred " + backend + "; actual backend in frame receipt",
                              resolution: fullResolution ? "full resolution, fresh support per render" : "preview, source-bound prepared support", width: width, height: height,
                              neutralIdentity: neutralIdentity, neutralRepeated: neutralRepeated,
                              neutralRestored: neutralRestored,
                              neutralSourceRasterIdentity: neutralSourceIdentity,
                              neutralRepeatedSourceRasterIdentity: neutralAgainSourceIdentity,
                              restoredSourceRasterIdentity: restoredSourceIdentity, sourceEyeGeometry: sourceEyeGeometry,
                              executionBinding: executionCapture?.binding,
                              runtimeArtifactPaths: executionCapture?.runtimeArtifactPaths, frames: frames,
                              limitation: "Capture/mechanical assertions do not prove appearance or reference equivalence. The input is an already edited reference endpoint. Independent source-fixed image registration and original-detail visual inspection own the five-field appearance oracle.")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(receipt).write(to: output.appendingPathComponent("aggregate.json"))
    }

    private func nativeExecutionCapture(environment: [String: String], runName: String,
                                        mode: String, resolution: String, backend: String,
                                        inputData: Data, oracleBaselineSourceData: Data?) throws -> ExecutionCapture? {
        let runPath = environment["BEAUTY_EYE_FIVE_RUNFILE_PATH"]
        let buildPath = environment["BEAUTY_EYE_FIVE_NATIVE_BUILD_RECEIPT"]
        guard runPath != nil || buildPath != nil else { return nil }
        func rejectUnless(_ value: Bool, line: UInt = #line) throws {
            guard value else {
                throw NSError(domain: "EyeFiveReferenceCheck", code: 30,
                    userInfo: [NSLocalizedDescriptionKey: "actual native capture provenance rejected at source line \(line)"])
            }
        }
        let runURL = URL(fileURLWithPath: try XCTUnwrap(runPath)).standardizedFileURL.resolvingSymlinksInPath()
        let buildURL = URL(fileURLWithPath: try XCTUnwrap(buildPath)).standardizedFileURL.resolvingSymlinksInPath()
        let evidenceRoot = URL(fileURLWithPath: try XCTUnwrap(environment["BEAUTY_EYE_FIVE_OUTPUT_ROOT"]))
            .standardizedFileURL.resolvingSymlinksInPath()
        let canonicalHostTempRoot = URL(fileURLWithPath: "/private/tmp", isDirectory: true)
            .standardizedFileURL.resolvingSymlinksInPath()
        try rejectUnless(evidenceRoot.path.hasPrefix(canonicalHostTempRoot.path + "/")
            && runURL.deletingLastPathComponent() == evidenceRoot && buildURL.deletingLastPathComponent() == evidenceRoot
            && runURL.pathExtension == "xctestrun" && buildURL.pathExtension == "json")
        for url in [runURL, buildURL] {
            let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
            try rejectUnless(values.isRegularFile == true && (values.fileSize ?? Int.max) <= 4 * 1024 * 1024)
        }
        let runData = try Data(contentsOf: runURL)
        let buildData = try Data(contentsOf: buildURL)
        let run = try PropertyListSerialization.propertyList(from: runData, format: nil)
        let build = try XCTUnwrap(JSONSerialization.jsonObject(with: buildData) as? [String: Any])
        var targets = [[String: Any]]()
        func visit(_ value: Any) {
            if let object = value as? [String: Any] {
                if object["TestHostPath"] != nil { targets.append(object) }
                for item in object.values { visit(item) }
            } else if let array = value as? [Any] {
                for item in array { visit(item) }
            }
        }
        visit(run)
        try rejectUnless(targets.count == 1)
        let target = try XCTUnwrap(targets.first)
        try rejectUnless(target["BlueprintName"] as? String == "BeautyEditorTests"
            && target["TestHostBundleIdentifier"] as? String == Bundle.main.bundleIdentifier)
        let admitted = try XCTUnwrap(target["EnvironmentVariables"] as? [String: String])
        let fields = ["BEAUTY_EYE_FIVE_RUN_NAME": runName, "BEAUTY_EYE_FIVE_MODE": mode,
                      "BEAUTY_EYE_FIVE_RESOLUTION": resolution, "BEAUTY_EYE_FIVE_BACKEND": backend]
        try rejectUnless(fields.allSatisfy { admitted[$0.key] == $0.value && environment[$0.key] == $0.value })
        for key in ["BEAUTY_EYE_FIVE_INPUT", "BEAUTY_EYE_FIVE_OUTPUT_ROOT",
                    "BEAUTY_EYE_FIVE_RUNFILE_PATH", "BEAUTY_EYE_FIVE_NATIVE_BUILD_RECEIPT"] {
            try rejectUnless(admitted[key] == environment[key] && admitted[key] != nil)
        }
        try rejectUnless(mode == "quarters" && admitted["BEAUTY_EYE_FIVE_GROUP"] == "iris"
            && environment["BEAUTY_EYE_FIVE_GROUP"] == "iris"
            && !admitted.contains { $0.key.hasPrefix("BEAUTY_") && $0.key.contains("DIAG") && $0.value == "1" }
            && build["buildExitCode"] as? Int == 0 && build["configuration"] as? String == "Debug simulator")
        let relativePayload = try XCTUnwrap(build["mainSDKPayloadRelativePath"] as? String)
        let relativeMain = try XCTUnwrap(build["mainExecutableRelativePath"] as? String)
        let relativeTest = try XCTUnwrap(build["testExecutableRelativePath"] as? String)
        let runtimeApp = Bundle.main.bundleURL.standardizedFileURL.resolvingSymlinksInPath()
        let main = try XCTUnwrap(Bundle.main.executableURL).standardizedFileURL.resolvingSymlinksInPath()
        let payload = runtimeApp.appendingPathComponent(relativePayload).standardizedFileURL.resolvingSymlinksInPath()
        let test = try XCTUnwrap(Bundle(for: EyeFivePortraitAcceptanceTests.self).executableURL)
            .standardizedFileURL.resolvingSymlinksInPath()
        let preservedApp = URL(fileURLWithPath: try XCTUnwrap(target["TestHostPath"] as? String))
            .standardizedFileURL.resolvingSymlinksInPath()
        let preservedTestBundle = URL(fileURLWithPath: try XCTUnwrap(target["TestBundlePath"] as? String))
            .standardizedFileURL.resolvingSymlinksInPath()
        try rejectUnless(!relativeMain.contains("..") && !relativePayload.contains("..") && !relativeTest.contains("..")
            && main == runtimeApp.appendingPathComponent(relativeMain)
            && payload.path.hasPrefix(runtimeApp.path + "/")
            && preservedTestBundle == preservedApp.appendingPathComponent("PlugIns/BeautyEditorTests.xctest")
            && (test == preservedApp.appendingPathComponent(relativeTest)
                || test == runtimeApp.appendingPathComponent(relativeTest)))
        // Enumerating dyld proves the selected SDK image and class-owning test
        // executable are loaded; mere file existence is insufficient.
        var loaded = Set<String>()
        for index in 0..<_dyld_image_count() {
            if let name = _dyld_get_image_name(index) {
                loaded.insert(URL(fileURLWithPath: String(cString: name)).standardizedFileURL.resolvingSymlinksInPath().path)
            }
        }
        try rejectUnless(loaded.contains(main.path) && loaded.contains(payload.path) && loaded.contains(test.path))
        let mainSHA = try fileSHA256(main), payloadSHA = try fileSHA256(payload), testSHA = try fileSHA256(test)
        try rejectUnless(mainSHA == build["mainExecutableSHA256"] as? String
            && payloadSHA == build["mainSDKPayloadSHA256"] as? String
            && testSHA == build["testExecutableSHA256"] as? String)
        let sources = try XCTUnwrap(build["sourceHashes"] as? [String: String])
        let required = ["BeautySDK/Sources/BeautyEffects/Render/BeautyIrisScaleRemap.swift",
                        "BeautySDK/Sources/BeautyEffects/Render/BeautyContinuousEyeMap.swift",
                        "BeautySDK/Sources/BeautyEffects/Render/BeautyStillImageGeometryStage.swift"]
        var production = [String: String]()
        for name in required {
            let value = try XCTUnwrap(sources["SDK/" + name])
            try rejectUnless(value.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil)
            production[name] = value
        }
        let harness = try XCTUnwrap(build["harnessSourceSHA256"] as? String)
        try rejectUnless(harness == sources["Host/Tests/EyeFivePortraitAcceptanceTests.swift"])
        let binding = ExecutionBinding(schemaVersion: 1, runName: runName, resolution: resolution,
            mode: mode, requestedBackend: backend, inputSHA256: dataSHA256(inputData),
            renderSourceSHA256: dataSHA256(try XCTUnwrap(oracleBaselineSourceData)), nativeRunfileSHA256: dataSHA256(runData),
            nativeBuildReceiptSHA256: dataSHA256(buildData), productionSourceSHA256: production,
            harnessSourceSHA256: harness, mainExecutableSHA256: mainSHA,
            mainSDKPayloadSHA256: payloadSHA, testExecutableSHA256: testSHA)
        return ExecutionCapture(binding: binding, runtimeArtifactPaths: [
            "mainExecutableRelativePath": relativeMain, "mainSDKPayloadRelativePath": relativePayload,
            "testExecutableRelativePath": relativeTest])
    }

    private func dataSHA256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func fileSHA256(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hash = SHA256()
        while let data = try handle.read(upToCount: 1024 * 1024), !data.isEmpty { hash.update(data: data) }
        return hash.finalize().map { String(format: "%02x", $0) }.joined()
    }

    // Freeze the same sRGB RGBA8 raster used by the production backend
    // assertions. ImageIO/CI presentation can otherwise add a one-code-value
    // conversion difference to an unchanged protected pixel of a P3 source.
    // Keep the ordinary production PNG alongside this independent byte view.
    private func canonicalImage(_ bytes: [UInt8], width: Int, height: Int) throws -> CGImage {
        let provider = try XCTUnwrap(CGDataProvider(data: Data(bytes) as CFData))
        return try XCTUnwrap(CGImage(width: width, height: height, bitsPerComponent: 8,
            bitsPerPixel: 32, bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
            provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent))
    }

    private func sourceGeometryAggregate(points: [CGPoint], width: Int, height: Int,
                                         referenceNormalizedWidth: Double?) throws -> SourceEyeGeometryAggregate {
        guard points.count == 478 else { throw NSError(domain: "EyeFiveReferenceCheck", code: 4) }
        // These index lists match the repository's fixed MediaPipeFaceTopology;
        // local pixel positions exist only during this calculation.
        let left = try relativeEyeGeometry(points: points,
            indices: [33, 7, 163, 144, 145, 153, 154, 155, 133, 173, 157, 158, 159, 160, 161, 246],
            width: width, height: height)
        let right = try relativeEyeGeometry(points: points,
            indices: [263, 249, 390, 373, 374, 380, 381, 382, 362, 398, 384, 385, 386, 387, 388, 466],
            width: width, height: height)
        let ratio: Double?
        if let referenceNormalizedWidth {
            guard referenceNormalizedWidth.isFinite, referenceNormalizedWidth > 0, referenceNormalizedWidth < 1 else {
                throw NSError(domain: "EyeFiveReferenceCheck", code: 5)
            }
            ratio = (left.span + right.span) * 0.5 / (referenceNormalizedWidth * Double(width))
        } else { ratio = nil }
        return SourceEyeGeometryAggregate(meanEyeSpanToReferenceVisualWidthRatio: ratio,
            leftContourMeanAlongCornerAxisToSpan: left.along,
            leftContourMeanAcrossCornerAxisToSpan: left.across,
            rightContourMeanAlongCornerAxisToSpan: right.along,
            rightContourMeanAcrossCornerAxisToSpan: right.across)
    }

    private func relativeEyeGeometry(points: [CGPoint], indices: [Int],
                                     width: Int, height: Int) throws -> (span: Double, along: Double, across: Double) {
        func pixel(_ index: Int) -> CGPoint {
            CGPoint(x: points[index].x * CGFloat(width), y: points[index].y * CGFloat(height))
        }
        let contour = indices.map(pixel)
        guard contour.allSatisfy({ $0.x.isFinite && $0.y.isFinite }) else {
            throw NSError(domain: "EyeFiveReferenceCheck", code: 7)
        }
        // Match the production adapter's stable extreme-x corner selection,
        // rather than assuming nominal mesh corner indices are the extremes.
        func order(_ a: CGPoint, _ b: CGPoint) -> Bool { a.x == b.x ? a.y < b.y : a.x < b.x }
        let start = try XCTUnwrap(contour.min(by: order))
        let end = try XCTUnwrap(contour.max(by: order))
        let dx = Double(end.x - start.x), dy = Double(end.y - start.y)
        let span = hypot(dx, dy)
        guard span.isFinite, span > 0 else { throw NSError(domain: "EyeFiveReferenceCheck", code: 6) }
        let meanX = contour.reduce(0.0) { $0 + Double($1.x) } / Double(contour.count)
        let meanY = contour.reduce(0.0) { $0 + Double($1.y) } / Double(contour.count)
        let offsetX = meanX - Double((start.x + end.x) * 0.5)
        let offsetY = meanY - Double((start.y + end.y) * 0.5)
        return (span, (offsetX * dx + offsetY * dy) / (span * span),
                (-offsetX * dy + offsetY * dx) / (span * span))
    }
}
#endif
