import AppKit
import CoreImage
import Foundation
import ImageIO
import BeautySDK

enum RendererFailureInjection {
    case none
    case render
    case encode

    static func load() throws -> RendererFailureInjection {
        guard let value = ProcessInfo.processInfo.environment["BEAUTY_EXAMPLE_RENDERER_FAILURE"] else {
            return .none
        }
        switch value {
        case "render":
            return .render
        case "encode":
            return .encode
        default:
            throw RendererExecutionError(code: .invalidFailureSeam)
        }
    }
}

struct RendererExecutionError: Error {
    let code: RendererDiagnosticCode
    let inputID: String?
    let caseID: String?

    init(code: RendererDiagnosticCode, inputID: String? = nil, caseID: String? = nil) {
        self.code = code
        self.inputID = inputID
        self.caseID = caseID
    }
}

enum RendererExecution {
    static let reportFileName = "beauty-example-renderer-report.json"

    static func run(command: RendererCommand, cases: [RenderCase]) -> RendererExecutionResult {
        do {
            let outputURL = try requireOutputDirectory(command.outputDirectory)
            let inputURL = try requireInputDirectory(command.inputDirectory)
            let renderCases = cases.filter { command.selectedCase == nil || command.selectedCase == $0.id }
            let imageURLs = fixtureImageURLs(in: inputURL, fileManager: .default)
            guard !imageURLs.isEmpty else {
                throw RendererExecutionError(code: .inputImagesMissing)
            }
            try requireUniqueOutputStems(imageURLs)

            let injection = try RendererFailureInjection.load()
            return executeMatrix(
                inputURL: inputURL,
                outputURL: outputURL,
                imageURLs: imageURLs,
                renderCases: renderCases,
                suppressWatermark: command.suppressWatermark,
                backend: command.backend,
                injection: injection
            )
        } catch let error as RendererExecutionError {
            return RendererExecutionResult(
                stdout: "",
                diagnostic: RendererDiagnostic(code: error.code, inputID: error.inputID, caseID: error.caseID)
            )
        } catch {
            return RendererExecutionResult(
                stdout: "",
                diagnostic: RendererDiagnostic(code: .invalidArguments)
            )
        }
    }

    private static func requireOutputDirectory(_ path: String?) throws -> URL {
        guard let path, !path.isEmpty else {
            throw RendererExecutionError(code: .outputDirectoryMissing)
        }
        let url = URL(fileURLWithPath: path, isDirectory: true)
        let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values?.isSymbolicLink != true else {
            throw RendererExecutionError(code: .outputDirectoryInvalid)
        }
        guard values?.isDirectory == true else {
            if FileManager.default.fileExists(atPath: url.path) {
                throw RendererExecutionError(code: .outputDirectoryInvalid)
            }
            throw RendererExecutionError(code: .outputDirectoryMissing)
        }
        return url.standardizedFileURL
    }

    private static func requireInputDirectory(_ path: String) throws -> URL {
        let url = URL(fileURLWithPath: path, isDirectory: true)
        let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
        guard values?.isDirectory == true else {
            if FileManager.default.fileExists(atPath: url.path) {
                throw RendererExecutionError(code: .inputDirectoryInvalid)
            }
            throw RendererExecutionError(code: .inputDirectoryMissing)
        }
        return url.standardizedFileURL
    }

    private static func executeMatrix(
        inputURL: URL,
        outputURL: URL,
        imageURLs: [URL],
        renderCases: [RenderCase],
        suppressWatermark: Bool,
        backend: String,
        injection: RendererFailureInjection
    ) -> RendererExecutionResult {
        let inputIDs = imageURLs.map { relativePath($0, from: inputURL) }
        let caseIDs = renderCases.map(\.id)
        let outputNames = imageURLs.flatMap { imageURL in
            renderCases.map { renderCase in
                outputFileName(for: imageURL, renderCase: renderCase)
            }
        }
        var units: [RendererOutputUnit] = []
        var stdout = ""
        var firstFailure: RendererDiagnostic?

        func recordFailure(_ diagnostic: RendererDiagnostic, inputID: String? = nil, caseID: String? = nil) {
            if firstFailure == nil {
                firstFailure = RendererDiagnostic(
                    code: diagnostic.code,
                    inputID: inputID ?? diagnostic.inputID,
                    caseID: caseID ?? diagnostic.caseID
                )
            }
        }

        func appendUnit(
            inputID: String,
            caseID: String,
            outputID: String,
            status: String,
            failureCode: RendererDiagnosticCode?
        ) {
            units.append(RendererOutputUnit(
                inputID: inputID,
                caseID: caseID,
                outputID: outputID,
                status: status,
                failureCode: failureCode
            ))
        }

        guard let outputColorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            for (inputIndex, inputID) in inputIDs.enumerated() {
                for (caseIndex, caseID) in caseIDs.enumerated() {
                    appendUnit(
                        inputID: inputID,
                        caseID: caseID,
                        outputID: outputNames[inputIndex * caseIDs.count + caseIndex],
                        status: "skipped",
                        failureCode: nil
                    )
                }
            }
            recordFailure(RendererDiagnostic(code: .renderFailed))
            return finalize(
                outputURL: outputURL,
                backend: backend,
                inputIDs: inputIDs,
                caseIDs: caseIDs,
                units: units,
                stdout: stdout,
                diagnostic: firstFailure
            )
        }

        let context = CIContext(options: [
            .workingColorSpace: outputColorSpace,
            .outputColorSpace: outputColorSpace
        ])
        guard let engine = try? BeautyEngine(configuration: .default) else {
            for (inputIndex, inputID) in inputIDs.enumerated() {
                for (caseIndex, caseID) in caseIDs.enumerated() {
                    appendUnit(
                        inputID: inputID,
                        caseID: caseID,
                        outputID: outputNames[inputIndex * caseIDs.count + caseIndex],
                        status: "skipped",
                        failureCode: nil
                    )
                }
            }
            recordFailure(RendererDiagnostic(code: .renderFailed))
            return finalize(
                outputURL: outputURL,
                backend: backend,
                inputIDs: inputIDs,
                caseIDs: caseIDs,
                units: units,
                stdout: stdout,
                diagnostic: firstFailure
            )
        }

        for (inputIndex, imageURL) in imageURLs.enumerated() {
            let inputID = inputIDs[inputIndex]
            let unitURLs = renderCases.map { outputURL.appendingPathComponent(outputFileName(for: imageURL, renderCase: $0)) }
            guard let inputImage = CIImage(contentsOf: imageURL, options: [.applyOrientationProperty: true]),
                  let inputDimensions = pixelDimensions(of: inputImage)
            else {
                for (caseIndex, renderCase) in renderCases.enumerated() {
                    appendUnit(
                        inputID: inputID,
                        caseID: renderCase.id,
                        outputID: unitURLs[caseIndex].lastPathComponent,
                        status: "failed",
                        failureCode: .inputDecodeFailed
                    )
                    recordFailure(RendererDiagnostic(code: .inputDecodeFailed), inputID: inputID, caseID: renderCase.id)
                }
                continue
            }

            for (caseIndex, renderCase) in renderCases.enumerated() {
                let destination = unitURLs[caseIndex]
                let outputID = destination.lastPathComponent
                do {
                    let result: BeautyResult<CIImage>
                    do {
                        result = try engine.processResult(
                            image: inputImage,
                            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                            parameters: renderCase.parameters
                        )
                    } catch {
                        throw RendererExecutionError(code: .renderFailed, inputID: inputID, caseID: renderCase.id)
                    }
                    guard injection != .render,
                          let cgImage = context.createCGImage(result.output, from: result.output.extent)
                    else {
                        throw RendererExecutionError(code: .renderFailed, inputID: inputID, caseID: renderCase.id)
                    }

                    let rendered: NSBitmapImageRep
                    if suppressWatermark {
                        rendered = NSBitmapImageRep(cgImage: cgImage)
                    } else {
                        rendered = try drawWatermark(watermarkText(for: renderCase), on: cgImage)
                    }
                    guard injection != .encode, let png = rendered.pngData(), !png.isEmpty else {
                        throw RendererExecutionError(code: .encodeFailed, inputID: inputID, caseID: renderCase.id)
                    }
                    try png.write(to: destination, options: .atomic)
                    guard validatePersistedOutput(destination, dimensions: inputDimensions) else {
                        throw RendererExecutionError(code: .outputValidationFailed, inputID: inputID, caseID: renderCase.id)
                    }
                    appendUnit(
                        inputID: inputID,
                        caseID: renderCase.id,
                        outputID: outputID,
                        status: "succeeded",
                        failureCode: nil
                    )
                    stdout += "wrote \(outputID)\n"
                } catch let error as RendererExecutionError {
                    appendUnit(
                        inputID: inputID,
                        caseID: renderCase.id,
                        outputID: outputID,
                        status: "failed",
                        failureCode: error.code
                    )
                    recordFailure(
                        RendererDiagnostic(code: error.code),
                        inputID: inputID,
                        caseID: renderCase.id
                    )
                } catch {
                    appendUnit(
                        inputID: inputID,
                        caseID: renderCase.id,
                        outputID: outputID,
                        status: "failed",
                        failureCode: .outputWriteFailed
                    )
                    recordFailure(
                        RendererDiagnostic(code: .outputWriteFailed),
                        inputID: inputID,
                        caseID: renderCase.id
                    )
                }
            }
        }

        if units.count != outputNames.count {
            recordFailure(RendererDiagnostic(code: .incompleteOutput))
        }
        return finalize(
            outputURL: outputURL,
            backend: backend,
            inputIDs: inputIDs,
            caseIDs: caseIDs,
            units: units,
            stdout: stdout,
            diagnostic: firstFailure
        )
    }

    private static func finalize(
        outputURL: URL,
        backend: String,
        inputIDs: [String],
        caseIDs: [String],
        units: [RendererOutputUnit],
        stdout: String,
        diagnostic: RendererDiagnostic?
    ) -> RendererExecutionResult {
        let report = RendererReport(backend: backend, inputIDs: inputIDs, caseIDs: caseIDs, outputs: units)
        guard report.countsReconcile, report.requested == units.count else {
            return RendererExecutionResult(
                stdout: stdout,
                diagnostic: RendererDiagnostic(code: .incompleteOutput)
            )
        }

        let reportURL = outputURL.appendingPathComponent(reportFileName)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            try encoder.encode(report).write(to: reportURL, options: .atomic)
        } catch {
            return RendererExecutionResult(
                stdout: stdout,
                diagnostic: RendererDiagnostic(code: .reportWriteFailed)
            )
        }

        if report.succeeded == report.requested, report.failed == 0, report.skipped == 0 {
            return RendererExecutionResult(stdout: stdout, diagnostic: nil)
        }
        return RendererExecutionResult(
            stdout: stdout,
            diagnostic: diagnostic ?? RendererDiagnostic(code: .incompleteOutput)
        )
    }

    private static func fixtureImageURLs(in directory: URL, fileManager: FileManager) -> [URL] {
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var urls: [URL] = []
        for case let url as URL in enumerator {
            guard ["png", "jpg", "jpeg"].contains(url.pathExtension.lowercased()) else {
                continue
            }
            let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
            guard values?.isRegularFile == true, values?.isSymbolicLink != true else {
                continue
            }
            urls.append(url)
        }

        return urls.sorted { relativePath($0, from: directory) < relativePath($1, from: directory) }
    }

    private static func requireUniqueOutputStems(_ imageURLs: [URL]) throws {
        var stems = Set<String>()
        for imageURL in imageURLs {
            let stem = imageURL.deletingPathExtension().lastPathComponent
            guard stems.insert(outputStemCollisionKey(stem)).inserted else {
                throw RendererExecutionError(code: .duplicateOutputStem)
            }
        }
    }

    private static func outputStemCollisionKey(_ stem: String) -> String {
        stem
            .folding(options: [.caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .decomposedStringWithCanonicalMapping
    }

    private static func outputFileName(for imageURL: URL, renderCase: RenderCase) -> String {
        "\(imageURL.deletingPathExtension().lastPathComponent)__\(renderCase.id).png"
    }

    private static func relativePath(_ url: URL, from directory: URL) -> String {
        let directoryPath = directory.standardizedFileURL.path
        let filePath = url.standardizedFileURL.path
        let prefix = directoryPath.hasSuffix("/") ? directoryPath : directoryPath + "/"
        guard filePath.hasPrefix(prefix) else {
            return url.lastPathComponent
        }
        return String(filePath.dropFirst(prefix.count)).replacingOccurrences(of: "\\", with: "/")
    }

    private static func pixelDimensions(of image: CIImage) -> (width: Int, height: Int)? {
        let width = Int(image.extent.width.rounded(.toNearestOrAwayFromZero))
        let height = Int(image.extent.height.rounded(.toNearestOrAwayFromZero))
        guard width > 0, height > 0, CGFloat(width) == image.extent.width, CGFloat(height) == image.extent.height else {
            return nil
        }
        return (width, height)
    }

    private static func validatePersistedOutput(_ url: URL, dimensions: (width: Int, height: Int)) -> Bool {
        let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        guard values?.isRegularFile == true, values?.isSymbolicLink != true, (values?.fileSize ?? 0) > 0 else {
            return false
        }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            return false
        }
        return image.width == dimensions.width && image.height == dimensions.height
    }

    private static func watermarkText(for renderCase: RenderCase) -> String {
        renderCase.displayName
    }

    private static func drawWatermark(_ text: String, on cgImage: CGImage) throws -> NSBitmapImageRep {
        let width = cgImage.width
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        guard let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else {
            throw RendererExecutionError(code: .renderFailed)
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphics

        let fontSize = CGFloat(max(34, min(72, width / 30)))
        let padding = CGFloat(max(24, width / 70))
        let bandHeight = fontSize * 1.75
        let bandRect = NSRect(
            x: padding,
            y: padding,
            width: CGFloat(width) - padding * 2,
            height: bandHeight
        )
        NSColor.black.withAlphaComponent(0.62).setFill()
        NSBezierPath(roundedRect: bandRect, xRadius: 18, yRadius: 18).fill()

        let horizontalInset = padding * 0.6
        let verticalInset = (bandHeight - fontSize * 1.15) / 2
        let textRect = bandRect.insetBy(dx: horizontalInset, dy: verticalInset)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: NSColor.white
        ]
        (text as NSString).draw(
            with: textRect,
            options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
            attributes: attributes
        )
        NSGraphicsContext.restoreGraphicsState()

        return bitmap
    }
}

extension RendererFailureInjection: Equatable {}

extension NSBitmapImageRep {
    fileprivate func pngData() -> Data? {
        representation(using: .png, properties: [:])
    }
}
