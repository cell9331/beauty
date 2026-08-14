import CoreGraphics
import Darwin
import Foundation
import ImageIO
import XCTest

/// CLI-03 evidence deliberately observes only the compiled executable.  This
/// test target does not import BeautyExampleRenderer or duplicate its parser.
@MainActor
final class BeautyExampleRendererProcessTests: XCTestCase {
    private static let rendererName = "BeautyExampleRenderer"
    private static let reportName = "beauty-example-renderer-report.json"
    private static let expectedCases = [
        "skinSmoothing_0p50", "skinWhitening_0p50", "skinRosy_0p40", "skinSharpen_0p40",
        "brightness_plus0p25", "contrast_plus0p25", "filter_softClean_0p50", "filter_warmLight_0p50",
        "skinCombo_0p50", "geometryBaseline_noop", "faceShapeCombo_0p35", "faceSlim_0p35",
        "faceSmall_0p35", "chinLength_plus0p30", "chinLength_minus0p30", "faceVShape_0p35",
        "jawSlim_0p35", "faceContourSmooth_0p25", "templeFullness_0p25", "cheekboneSlim_0p25",
        "chinTaper_0p25", "eyeSize_0p35", "eyeDistance_plus0p25", "eyeDistance_minus0p25",
        "eyeYPosition_plus0p20", "eyeYPosition_minus0p20", "eyeTailLift_0p25", "eyeHeight_0p25",
        "eyeLength_0p25", "upperEyelidLift_0p25", "pupilSize_0p25", "gazeCorrection_0p25",
        "lowerEyelidDrop_0p25", "eyeTilt_plus0p25", "eyeTilt_minus0p25", "innerCornerOpen_0p25",
        "outerCornerOpen_0p25", "eyeSymmetry_0p25", "eyebrowYPosition_plus0p25", "eyebrowYPosition_minus0p25",
        "eyebrowThickness_plus0p25", "eyebrowThickness_minus0p25", "eyebrowLength_plus0p25", "eyebrowLength_minus0p25",
        "eyebrowSpacing_plus0p25", "eyebrowSpacing_minus0p25", "eyebrowHeadSpacing_plus0p25", "eyebrowHeadSpacing_minus0p25",
        "eyebrowTilt_plus0p25", "eyebrowTilt_minus0p25", "eyebrowPeakDefinition_0p25", "noseSlim_0p35",
        "noseWingSlim_0p35", "noseTipSize_plus0p30", "noseTipSize_minus0p30", "noseBridge_0p30",
        "noseRootNarrowing_0p25", "noseTipLift_0p25", "mouthSize_plus0p35", "mouthSize_minus0p35",
        "mouthWidth_plus0p35", "mouthWidth_minus0p35", "smile_0p50", "lipColor_0p50",
        "mouthYPosition_plus0p25", "mouthYPosition_minus0p25", "mouthTilt_plus0p25", "mouthTilt_minus0p25",
        "mouthXPosition_plus0p25", "mouthXPosition_minus0p25", "lipPeakDefinition_0p25", "lipPlump_0p25",
        "teethWhitening_1p00", "scleraRednessReduction_1p00"
    ]

    private nonisolated(unsafe) static var cachedExecutable: URL?
    private nonisolated(unsafe) static var cachedBuildRoot: URL?
    private static let executableLock = NSLock()

    override class func tearDown() {
        if let buildRoot = cachedBuildRoot { try? FileManager.default.removeItem(at: buildRoot) }
        cachedBuildRoot = nil
        cachedExecutable = nil
        super.tearDown()
    }

    func testCompiledRendererDiscoveryAndReproducibility() throws {
        let executable = try rendererExecutable()
        let firstList = try run(executable, arguments: ["--list-cases"])
        let secondList = try run(executable, arguments: ["--list-cases"])
        XCTAssertEqual(firstList.status, 0)
        XCTAssertEqual(secondList.status, 0)
        XCTAssertEqual(firstList.stdout, secondList.stdout)
        XCTAssertTrue(firstList.stderr.isEmpty)
        let list = try JSONDecoder().decode(CaseList.self, from: firstList.stdout)
        XCTAssertEqual(list.schemaVersion, "beauty.example-renderer.cases.v1")
        XCTAssertEqual(list.cases, Self.expectedCases)
        XCTAssertEqual(Set(list.cases).count, 74)

        let first = try makeFixtureTree(extension: "png")
        defer { removeTree(first.root) }
        let second = try makeFixtureTree(extension: "png")
        defer { removeTree(second.root) }
        let arguments = { (tree: FixtureTree) in
            ["--input", tree.input.path, "--output", tree.output.path,
             "--case", "geometryBaseline_noop", "--backend", "cpu", "--no-watermark"]
        }
        let firstRun = try run(executable, arguments: arguments(first))
        let secondRun = try run(executable, arguments: arguments(second))
        XCTAssertEqual(firstRun.status, 0)
        XCTAssertEqual(secondRun.status, 0)
        XCTAssertTrue(firstRun.stderr.isEmpty)
        let firstPNG = try Data(contentsOf: first.output.appendingPathComponent("portrait__geometryBaseline_noop.png"))
        let secondPNG = try Data(contentsOf: second.output.appendingPathComponent("portrait__geometryBaseline_noop.png"))
        let firstReport = try Data(contentsOf: first.output.appendingPathComponent(Self.reportName))
        let secondReport = try Data(contentsOf: second.output.appendingPathComponent(Self.reportName))
        XCTAssertFalse(firstPNG.isEmpty)
        XCTAssertEqual(firstPNG, secondPNG)
        XCTAssertEqual(firstReport, secondReport)
        let report = try decodeReport(firstReport)
        assertSuccessful(report)
        assertPrivacySafe(firstRun.stdout + firstRun.stderr + firstReport, temporaryRoot: first.root)
    }

    func testCompiledRendererRejectsArgumentsSelectionAndDuplicateScalars() throws {
        let executable = try rendererExecutable()
        let cases: [([String], String)] = [
            (["--wat"], "unknown_argument"),
            (["--output"], "missing_argument_value"),
            (["--case", "does-not-exist", "--output", "/tmp/unused"], "unknown_case"),
            (["--backend", "gpu", "--output", "/tmp/unused"], "unsupported_backend"),
            (["--backend", "vulkan", "--output", "/tmp/unused"], "unsupported_backend"),
            (["--input", "a", "--input", "b", "--output", "/tmp/unused"], "duplicate_argument"),
            (["--output", "a", "--output", "b"], "duplicate_argument"),
            (["--case", "geometryBaseline_noop", "--case", "geometryBaseline_noop", "--output", "/tmp/unused"], "duplicate_argument"),
            (["--backend", "cpu", "--backend", "cpu", "--output", "/tmp/unused"], "duplicate_argument")
        ]
        for (arguments, code) in cases {
            let result = try run(executable, arguments: arguments)
            assertDiagnostic(result, code: code)
            XCTAssertTrue(result.stdout.isEmpty, arguments.description)
        }

        let tree = try makeFixtureTree(extension: "png")
        defer { removeTree(tree.root) }
        let duplicateCases = [
            ["--input", tree.input.path, "--output", tree.output.path, "--case", "geometryBaseline_noop", "--backend", "cpu", "--input", tree.input.path],
            ["--input", tree.input.path, "--output", tree.output.path, "--case", "geometryBaseline_noop", "--backend", "cpu", "--output", tree.output.path],
            ["--input", tree.input.path, "--output", tree.output.path, "--case", "geometryBaseline_noop", "--backend", "cpu", "--case", "geometryBaseline_noop"],
            ["--input", tree.input.path, "--output", tree.output.path, "--case", "geometryBaseline_noop", "--backend", "cpu", "--backend", "cpu"]
        ]
        for arguments in duplicateCases {
            let result = try run(executable, arguments: arguments)
            assertDiagnostic(result, code: "duplicate_argument")
            XCTAssertFalse(hasPNG(in: tree.output))
            XCTAssertFalse(FileManager.default.fileExists(atPath: tree.output.appendingPathComponent(Self.reportName).path))
        }
    }

    func testCompiledRendererRejectsInputAndOutputMatrix() throws {
        let executable = try rendererExecutable()
        let missingInput = try makeFixtureTree(extension: "png")
        defer { removeTree(missingInput.root) }
        try Data("stale-output".utf8).write(
            to: missingInput.output.appendingPathComponent("portrait__geometryBaseline_noop.png")
        )
        try Data("stale-report".utf8).write(
            to: missingInput.output.appendingPathComponent(Self.reportName)
        )
        removeTree(missingInput.input)
        var result = try run(executable, arguments: renderArguments(input: missingInput.input, output: missingInput.output))
        assertDiagnostic(result, code: "input_directory_missing")
        XCTAssertFalse(hasPNG(in: missingInput.output))
        XCTAssertFalse(FileManager.default.fileExists(atPath: missingInput.output.appendingPathComponent(Self.reportName).path))

        let empty = try makeFixtureTree(extension: "png", createInput: true, createImage: false)
        defer { removeTree(empty.root) }
        result = try run(executable, arguments: renderArguments(input: empty.input, output: empty.output))
        assertDiagnostic(result, code: "input_images_missing")

        let noOutput = try makeFixtureTree(extension: "png")
        defer { removeTree(noOutput.root) }
        result = try run(executable, arguments: renderArguments(input: noOutput.input, output: noOutput.root.appendingPathComponent("missing")))
        assertDiagnostic(result, code: "output_directory_missing")
        XCTAssertFalse(FileManager.default.fileExists(atPath: noOutput.root.appendingPathComponent("missing").path))

        let outputFile = try makeFixtureTree(extension: "png")
        defer { removeTree(outputFile.root) }
        let fileOutput = outputFile.root.appendingPathComponent("output-file")
        try Data([0x01]).write(to: fileOutput)
        result = try run(executable, arguments: renderArguments(input: outputFile.input, output: fileOutput))
        assertDiagnostic(result, code: "output_directory_invalid")

        let symlink = try makeFixtureTree(extension: "png")
        defer { removeTree(symlink.root) }
        let symlinkTarget = symlink.root.appendingPathComponent("real-output", isDirectory: true)
        try FileManager.default.createDirectory(at: symlinkTarget, withIntermediateDirectories: false)
        let symlinkOutput = symlink.root.appendingPathComponent("linked-output", isDirectory: true)
        try FileManager.default.createSymbolicLink(at: symlinkOutput, withDestinationURL: symlinkTarget)
        result = try run(executable, arguments: renderArguments(input: symlink.input, output: symlinkOutput))
        assertDiagnostic(result, code: "output_directory_invalid")

        let duplicate = try makeFixtureTree(extension: "png", createImage: false)
        defer { removeTree(duplicate.root) }
        let a = duplicate.input.appendingPathComponent("A", isDirectory: true)
        let b = duplicate.input.appendingPathComponent("B", isDirectory: true)
        try FileManager.default.createDirectory(at: a, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: b, withIntermediateDirectories: true)
        try writePNG(to: a.appendingPathComponent("portrait.png"))
        try writeJPEG(to: b.appendingPathComponent("Portrait.jpg"))
        result = try run(executable, arguments: renderArguments(input: duplicate.input, output: duplicate.output))
        assertDiagnostic(result, code: "duplicate_output_stem")
        XCTAssertFalse(hasPNG(in: duplicate.output))

        let corrupt = try makeFixtureTree(extension: "png", createImage: false)
        defer { removeTree(corrupt.root) }
        try Data("not-an-image".utf8).write(to: corrupt.input.appendingPathComponent("corrupt.jpg"))
        result = try run(executable, arguments: renderArguments(input: corrupt.input, output: corrupt.output))
        assertDiagnostic(result, code: "input_decode_failed")
        let corruptReport = try Data(contentsOf: corrupt.output.appendingPathComponent(Self.reportName))
        let decodedCorrupt = try decodeReport(corruptReport)
        XCTAssertEqual(decodedCorrupt.requested, 1)
        XCTAssertEqual(decodedCorrupt.succeeded, 0)
        XCTAssertEqual(decodedCorrupt.failed, 1)
        XCTAssertEqual(decodedCorrupt.skipped, 0)
        XCTAssertFalse(hasPNG(in: corrupt.output))
    }

    func testCompiledRendererReportsDestinationAndReportCollisions() throws {
        let executable = try rendererExecutable()
        let destination = try makeFixtureTree(extension: "png")
        defer { removeTree(destination.root) }
        let collision = destination.output.appendingPathComponent("portrait__geometryBaseline_noop.png", isDirectory: true)
        try FileManager.default.createDirectory(at: collision, withIntermediateDirectories: false)
        let result = try run(executable, arguments: renderArguments(input: destination.input, output: destination.output))
        assertDiagnostic(result, code: "output_write_failed")
        let report = try decodeReport(try Data(contentsOf: destination.output.appendingPathComponent(Self.reportName)))
        XCTAssertEqual(report.requested, 1)
        XCTAssertEqual(report.succeeded, 0)
        XCTAssertEqual(report.failed, 1)
        XCTAssertEqual(report.skipped, 0)
        assertPrivacySafe(result.stdout + result.stderr, temporaryRoot: destination.root)

        let reportCollision = try makeFixtureTree(extension: "png")
        defer { removeTree(reportCollision.root) }
        let reportURL = reportCollision.output.appendingPathComponent(Self.reportName, isDirectory: true)
        try FileManager.default.createDirectory(at: reportURL, withIntermediateDirectories: false)
        let collisionResult = try run(executable, arguments: renderArguments(input: reportCollision.input, output: reportCollision.output))
        assertDiagnostic(collisionResult, code: "report_write_failed", allowStdout: true)
        XCTAssertTrue(hasPNG(in: reportCollision.output))
        XCTAssertFalse(collisionResult.status == 0)
    }

    func testCompiledRendererEscapesControlCharactersInProgressOutput() throws {
        let executable = try rendererExecutable()
        let tree = try makeFixtureTree(extension: "png")
        defer { removeTree(tree.root) }
        let controlNamedInput = tree.input.appendingPathComponent("portrait\ninput.png")
        try FileManager.default.moveItem(
            at: tree.input.appendingPathComponent("portrait.png"),
            to: controlNamedInput
        )

        let result = try run(executable, arguments: renderArguments(input: tree.input, output: tree.output))
        XCTAssertEqual(result.status, 0)
        let stdout = String(decoding: result.stdout, as: UTF8.self)
        XCTAssertTrue(stdout.contains("wrote portrait\\u000Ainput__geometryBaseline_noop.png"))
        XCTAssertFalse(stdout.contains("wrote portrait\ninput__geometryBaseline_noop.png"))
        assertPrivacySafe(result.stdout + result.stderr, temporaryRoot: tree.root)
    }

    func testCompiledRendererReplacesGeneratedArtifactsWhenOutputIsReused() throws {
        let executable = try rendererExecutable()
        let tree = try makeFixtureTree(extension: "png")
        defer { removeTree(tree.root) }

        var result = try run(
            executable,
            arguments: ["--input", tree.input.path, "--output", tree.output.path,
                        "--case", "geometryBaseline_noop", "--backend", "cpu", "--no-watermark"]
        )
        XCTAssertEqual(result.status, 0)
        let oldOutput = tree.output.appendingPathComponent("portrait__geometryBaseline_noop.png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: oldOutput.path))

        result = try run(
            executable,
            arguments: ["--input", tree.input.path, "--output", tree.output.path,
                        "--case", "skinSmoothing_0p50", "--backend", "cpu", "--no-watermark"]
        )
        XCTAssertEqual(result.status, 0)
        XCTAssertFalse(FileManager.default.fileExists(atPath: oldOutput.path))
        let currentOutput = tree.output.appendingPathComponent("portrait__skinSmoothing_0p50.png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: currentOutput.path))
        let report = try decodeReport(try Data(contentsOf: tree.output.appendingPathComponent(Self.reportName)))
        XCTAssertEqual(report.caseIDs, ["skinSmoothing_0p50"])

        removeTree(tree.input)
        result = try run(
            executable,
            arguments: ["--input", tree.input.path, "--output", tree.output.path,
                        "--case", "skinSmoothing_0p50", "--backend", "cpu", "--no-watermark"]
        )
        assertDiagnostic(result, code: "input_directory_missing")
        XCTAssertFalse(FileManager.default.fileExists(atPath: Self.reportNameURL(in: tree.output).path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: currentOutput.path))
    }

    func testCompiledRendererReachesInternalRenderAndEncodeFailureSeams() throws {
        let executable = try rendererExecutable()
        for seam in ["render", "encode"] {
            let tree = try makeFixtureTree(extension: "png")
            defer { removeTree(tree.root) }
            let result = try run(
                executable,
                arguments: renderArguments(input: tree.input, output: tree.output),
                environment: ["BEAUTY_EXAMPLE_RENDERER_FAILURE": seam]
            )
            assertDiagnostic(result, code: seam == "render" ? "render_failed" : "encode_failed")
            XCTAssertFalse(hasPNG(in: tree.output))
            let reportData = try Data(contentsOf: tree.output.appendingPathComponent(Self.reportName))
            let report = try decodeReport(reportData)
            XCTAssertEqual(report.requested, 1)
            XCTAssertEqual(report.succeeded, 0)
            XCTAssertEqual(report.failed, 1)
            XCTAssertEqual(report.skipped, 0)
            XCTAssertEqual(report.outputs.first?.failureCode, seam == "render" ? "render_failed" : "encode_failed")
            assertPrivacySafe(result.stdout + result.stderr + reportData, temporaryRoot: tree.root)
        }

        let help = try run(executable, arguments: ["--help"])
        let list = try run(executable, arguments: ["--list-cases"])
        XCTAssertFalse(String(decoding: help.stdout, as: UTF8.self).contains("BEAUTY_EXAMPLE_RENDERER_FAILURE"))
        XCTAssertFalse(String(decoding: list.stdout, as: UTF8.self).contains("BEAUTY_EXAMPLE_RENDERER_FAILURE"))
    }

    private func rendererExecutable() throws -> URL {
        Self.executableLock.lock()
        defer { Self.executableLock.unlock() }
        if let cached = Self.cachedExecutable { return cached }
        let root = try repositoryRootURL()
        let buildRoot = FileManager.default.temporaryDirectory.appendingPathComponent("beauty-cli-build-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: buildRoot, withIntermediateDirectories: false)
        Self.cachedBuildRoot = buildRoot
        let packagePath = root.appendingPathComponent("BeautySDK").path
        let build = try runTool("swift", arguments: ["build", "--package-path", packagePath, "--scratch-path", buildRoot.path, "--product", Self.rendererName], timeout: 120)
        XCTAssertEqual(build.status, 0, "BeautyExampleRenderer build failed: \(String(decoding: build.stderr, as: UTF8.self))")
        guard build.status == 0 else { throw ProcessTestError.toolFailed("swift build") }
        let bin = try runTool("swift", arguments: ["build", "--package-path", packagePath, "--scratch-path", buildRoot.path, "--show-bin-path"], timeout: 120)
        XCTAssertEqual(bin.status, 0)
        guard bin.status == 0 else { throw ProcessTestError.toolFailed("swift build --show-bin-path") }
        let binPath = String(decoding: bin.stdout, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        let executable = URL(fileURLWithPath: binPath).appendingPathComponent(Self.rendererName)
        let values = try executable.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .isExecutableKey])
        guard values.isRegularFile == true, values.isSymbolicLink != true, values.isExecutable == true else {
            throw ProcessTestError.toolFailed("resolved executable")
        }
        Self.cachedExecutable = executable
        return executable
    }

    private func run(_ executable: URL, arguments: [String], environment additions: [String: String] = [:]) throws -> CapturedProcess {
        var environment = ProcessInfo.processInfo.environment
        for (key, value) in additions { environment[key] = value }
        return try runTool(executable.path, arguments: arguments, environment: environment, timeout: 30)
    }

    private func runTool(_ executable: String, arguments: [String], environment: [String: String] = ProcessInfo.processInfo.environment, timeout: TimeInterval) throws -> CapturedProcess {
        let process = Process()
        process.executableURL = try resolveExecutable(executable, environment: environment)
        process.arguments = arguments
        process.environment = environment
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        let outBox = ProcessDataBox()
        let errBox = ProcessDataBox()
        let readers = DispatchGroup()
        readers.enter()
        DispatchQueue.global().async {
            Self.capture(stdout.fileHandleForReading, into: outBox)
            readers.leave()
        }
        readers.enter()
        DispatchQueue.global().async {
            Self.capture(stderr.fileHandleForReading, into: errBox)
            readers.leave()
        }
        let termination = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in termination.signal() }
        try process.run()
        var timedOut = false
        if termination.wait(timeout: .now() + timeout) == .timedOut {
            timedOut = true
            if process.isRunning { process.terminate() }
            if termination.wait(timeout: .now() + 5) == .timedOut {
                if process.isRunning { kill(process.processIdentifier, SIGKILL) }
                _ = termination.wait(timeout: .now() + 1)
            }
        }
        if timedOut {
            stdout.fileHandleForReading.closeFile()
            stderr.fileHandleForReading.closeFile()
        }
        let readersTimedOut = readers.wait(timeout: .now() + 5) == .timedOut
        if readersTimedOut {
            stdout.fileHandleForReading.closeFile()
            stderr.fileHandleForReading.closeFile()
        }
        let out = outBox.value
        let err = errBox.value
        XCTAssertLessThanOrEqual(out.count, 1 * 1024 * 1024)
        XCTAssertLessThanOrEqual(err.count, 1 * 1024 * 1024)
        if timedOut || readersTimedOut { throw ProcessTestError.timedOut(executable) }
        return CapturedProcess(status: process.terminationStatus, stdout: out, stderr: err)
    }

    private nonisolated static func capture(_ handle: FileHandle, into box: ProcessDataBox) {
        while true {
            let chunk = handle.readData(ofLength: 64 * 1024)
            guard !chunk.isEmpty else { return }
            if !box.append(chunk, limit: 1 * 1024 * 1024) {
                handle.closeFile()
                return
            }
        }
    }

    private func resolveExecutable(_ executable: String, environment: [String: String]) throws -> URL {
        if executable.contains("/") {
            return URL(fileURLWithPath: executable)
        }
        let searchPath = environment["PATH"] ?? "/usr/bin:/bin"
        for directory in searchPath.split(separator: ":") {
            let candidate = URL(fileURLWithPath: String(directory), isDirectory: true).appendingPathComponent(executable)
            if FileManager.default.isExecutableFile(atPath: candidate.path) { return candidate }
        }
        throw ProcessTestError.toolFailed("unable to resolve \(executable)")
    }

    private func renderArguments(input: URL, output: URL) -> [String] {
        ["--input", input.path, "--output", output.path, "--case", "geometryBaseline_noop", "--backend", "cpu", "--no-watermark"]
    }

    private func makeFixtureTree(extension: String, createInput: Bool = true, createImage: Bool = true) throws -> FixtureTree {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("beauty-cli-\(UUID().uuidString)", isDirectory: true)
        let input = root.appendingPathComponent("input", isDirectory: true)
        let output = root.appendingPathComponent("output", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        if createInput { try FileManager.default.createDirectory(at: input, withIntermediateDirectories: false) }
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: false)
        if createImage {
            if `extension`.lowercased() == "jpg" { try writeJPEG(to: input.appendingPathComponent("portrait.jpg")) }
            else { try writePNG(to: input.appendingPathComponent("portrait.png")) }
        }
        return FixtureTree(root: root, input: input, output: output)
    }

    private func writePNG(to url: URL) throws { try writeImage(to: url, type: "public.png") }
    private func writeJPEG(to url: URL) throws { try writeImage(to: url, type: "public.jpeg") }

    private func writeImage(to url: URL, type: String) throws {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil, width: 4, height: 3, bitsPerComponent: 8, bytesPerRow: 16,
                                       space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let image = context.makeImage(),
              let destination = CGImageDestinationCreateWithURL(url as CFURL, type as CFString, 1, nil)
        else { throw ProcessTestError.fixture("image encoder") }
        CGImageDestinationAddImage(destination, image, [kCGImagePropertyColorModel: "RGB"] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw ProcessTestError.fixture("image write") }
    }

    private func decodeReport(_ data: Data) throws -> Report {
        try JSONDecoder().decode(Report.self, from: data)
    }

    private func assertSuccessful(_ report: Report, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(report.schemaVersion, "beauty.example-renderer.report.v1", file: file, line: line)
        XCTAssertEqual(report.backend, "cpu", file: file, line: line)
        XCTAssertEqual(report.requested, 1, file: file, line: line)
        XCTAssertEqual(report.succeeded, 1, file: file, line: line)
        XCTAssertEqual(report.failed, 0, file: file, line: line)
        XCTAssertEqual(report.skipped, 0, file: file, line: line)
        XCTAssertEqual(report.outputs.count, 1, file: file, line: line)
        XCTAssertEqual(report.outputs.first?.status, "succeeded", file: file, line: line)
        XCTAssertNil(report.outputs.first?.failureCode, file: file, line: line)
    }

    private func assertDiagnostic(_ result: CapturedProcess, code: String, allowStdout: Bool = false, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotEqual(result.status, 0, file: file, line: line)
        if !allowStdout { XCTAssertTrue(result.stdout.isEmpty, file: file, line: line) }
        let diagnostic = try? JSONDecoder().decode(Diagnostic.self, from: result.stderr)
        XCTAssertEqual(diagnostic?.schemaVersion, "beauty.example-renderer.diagnostic.v1", file: file, line: line)
        XCTAssertEqual(diagnostic?.code, code, file: file, line: line)
    }

    private func assertPrivacySafe(_ data: Data, temporaryRoot: URL, file: StaticString = #filePath, line: UInt = #line) {
        let text = String(decoding: data, as: UTF8.self).lowercased()
        XCTAssertFalse(text.contains(temporaryRoot.path.lowercased()), file: file, line: line)
        for token in ["/private/", "nserror", "landmark", "mask", "pixel", "coordinate", "private-fixture", "private_fixture", "file://"] {
            XCTAssertFalse(text.contains(token), "privacy token \(token)", file: file, line: line)
        }
    }

    private func hasPNG(in directory: URL) -> Bool {
        (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil))?.contains { $0.pathExtension.lowercased() == "png" } == true
    }

    private static func reportNameURL(in output: URL) -> URL {
        output.appendingPathComponent(reportName)
    }

    private func removeTree(_ url: URL) { try? FileManager.default.removeItem(at: url) }

    private func repositoryRootURL() throws -> URL {
        var current = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while current.path != "/" {
            if FileManager.default.fileExists(atPath: current.appendingPathComponent("BeautySDK/Package.swift").path) { return current }
            current.deleteLastPathComponent()
        }
        throw ProcessTestError.fixture("repository root")
    }
}

private struct FixtureTree {
    let root: URL
    let input: URL
    let output: URL
}

private struct CapturedProcess {
    let status: Int32
    let stdout: Data
    let stderr: Data
}

private final class ProcessDataBox: @unchecked Sendable {
    private let lock = NSLock()
    private var data = Data()

    var value: Data {
        lock.lock()
        defer { lock.unlock() }
        return data
    }

    func replace(_ value: Data) {
        lock.lock()
        data = value
        lock.unlock()
    }

    func append(_ value: Data, limit: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let remaining = max(0, limit - data.count)
        if remaining > 0 {
            data.append(value.prefix(remaining))
        }
        return value.count <= remaining
    }
}

private struct CaseList: Codable {
    let schemaVersion: String
    let cases: [String]
}

private struct Diagnostic: Codable {
    let schemaVersion: String
    let code: String
    let inputID: String?
    let caseID: String?
}

private struct Report: Codable {
    let schemaVersion: String
    let backend: String
    let requested: Int
    let succeeded: Int
    let failed: Int
    let skipped: Int
    let inputIDs: [String]
    let caseIDs: [String]
    let outputs: [Output]
}

private struct Output: Codable {
    let inputID: String
    let caseID: String
    let outputID: String
    let status: String
    let failureCode: String?
}

private enum ProcessTestError: Error, CustomStringConvertible {
    case toolFailed(String)
    case timedOut(String)
    case fixture(String)

    var description: String {
        switch self {
        case .toolFailed(let value): return "tool failed: \(value)"
        case .timedOut(let value): return "process timed out: \(value)"
        case .fixture(let value): return "fixture failed: \(value)"
        }
    }
}
