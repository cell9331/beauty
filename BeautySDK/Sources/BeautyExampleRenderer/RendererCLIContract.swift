import Foundation

struct RendererCommand {
    enum Action {
        case render
        case listCases
        case help
    }

    let action: Action
    let inputDirectory: String
    let outputDirectory: String?
    let selectedCase: String?
    let suppressWatermark: Bool
    let backend: String
}

enum RendererDiagnosticCode: String, Codable {
    case unknownArgument = "unknown_argument"
    case missingArgumentValue = "missing_argument_value"
    case duplicateArgument = "duplicate_argument"
    case invalidArguments = "invalid_arguments"
    case unsupportedBackend = "unsupported_backend"
    case inputDirectoryMissing = "input_directory_missing"
    case inputDirectoryInvalid = "input_directory_invalid"
    case inputImagesMissing = "input_images_missing"
    case unknownCase = "unknown_case"
    case duplicateOutputStem = "duplicate_output_stem"
    case inputDecodeFailed = "input_decode_failed"
    case renderFailed = "render_failed"
    case encodeFailed = "encode_failed"
    case outputDirectoryMissing = "output_directory_missing"
    case outputDirectoryInvalid = "output_directory_invalid"
    case outputWriteFailed = "output_write_failed"
    case outputValidationFailed = "output_validation_failed"
    case incompleteOutput = "incomplete_output"
    case reportWriteFailed = "report_write_failed"
    case invalidFailureSeam = "invalid_failure_seam"
}

struct RendererDiagnostic: Codable {
    static let schemaVersion = "beauty.example-renderer.diagnostic.v1"

    let schemaVersion: String
    let code: RendererDiagnosticCode
    let inputID: String?
    let caseID: String?

    init(code: RendererDiagnosticCode, inputID: String? = nil, caseID: String? = nil) {
        self.schemaVersion = Self.schemaVersion
        self.code = code
        self.inputID = inputID
        self.caseID = caseID
    }

    var encodedLine: Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        if let data = try? encoder.encode(self) {
            return data + Data([0x0A])
        }
        return Data("{\"code\":\"invalid_arguments\",\"schemaVersion\":\"beauty.example-renderer.diagnostic.v1\"}\n".utf8)
    }
}

struct RendererOutputUnit: Codable {
    let inputID: String
    let caseID: String
    let outputID: String
    let status: String
    let failureCode: RendererDiagnosticCode?
}

struct RendererReport: Codable {
    static let schemaVersion = "beauty.example-renderer.report.v1"

    let schemaVersion: String
    let backend: String
    let requested: Int
    let succeeded: Int
    let failed: Int
    let skipped: Int
    let inputIDs: [String]
    let caseIDs: [String]
    let outputs: [RendererOutputUnit]

    init(backend: String, inputIDs: [String], caseIDs: [String], outputs: [RendererOutputUnit]) {
        self.schemaVersion = Self.schemaVersion
        self.backend = backend
        self.requested = outputs.count
        self.succeeded = outputs.filter { $0.status == "succeeded" }.count
        self.failed = outputs.filter { $0.status == "failed" }.count
        self.skipped = outputs.filter { $0.status == "skipped" }.count
        self.inputIDs = inputIDs
        self.caseIDs = caseIDs
        self.outputs = outputs
    }

    var countsReconcile: Bool {
        requested == succeeded + failed + skipped
    }
}

struct RendererCaseList: Codable {
    static let schemaVersion = "beauty.example-renderer.cases.v1"

    let schemaVersion: String
    let cases: [String]

    init(cases: [RenderCase]) {
        self.schemaVersion = Self.schemaVersion
        self.cases = cases.map(\.id)
    }
}

struct RendererExecutionResult {
    let stdout: String
    let diagnostic: RendererDiagnostic?
}

enum RendererCLI {
    static func run(arguments: [String], cases: [RenderCase]) -> RendererExecutionResult {
        do {
            let command = try RendererCommandParser.parse(arguments: arguments, cases: cases)
            switch command.action {
            case .help:
                return RendererExecutionResult(stdout: helpText, diagnostic: nil)
            case .listCases:
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.sortedKeys]
                let data = try encoder.encode(RendererCaseList(cases: cases))
                return RendererExecutionResult(stdout: String(decoding: data, as: UTF8.self) + "\n", diagnostic: nil)
            case .render:
                return RendererExecution.run(command: command, cases: cases)
            }
        } catch let error as RendererCLIError {
            return RendererExecutionResult(stdout: "", diagnostic: error.diagnostic)
        } catch {
            return RendererExecutionResult(
                stdout: "",
                diagnostic: RendererDiagnostic(code: .invalidArguments)
            )
        }
    }

    private static let helpText = """
    BeautyExampleRenderer

    Usage: BeautyExampleRenderer --output <directory> [options]
      --input <directory>   Input directory (default: example-images/input)
      --output <directory>  Existing output directory (required for rendering)
      --case <case-id>      Render one case instead of all cases
      --backend cpu         Select the CPU renderer (the only supported backend)
      --no-watermark         Omit the presentation watermark
      --list-cases           Print the deterministic case inventory as JSON
      --help                 Print this help text
    """
}

enum RendererCLIError: Error {
    case diagnostic(RendererDiagnostic)

    var diagnostic: RendererDiagnostic {
        switch self {
        case .diagnostic(let diagnostic):
            return diagnostic
        }
    }
}

enum RendererCommandParser {
    static func parse(arguments: [String], cases: [RenderCase]) throws -> RendererCommand {
        var action: RendererCommand.Action = .render
        var inputDirectory: String?
        var outputDirectory: String?
        var selectedCase: String?
        var backend: String?
        var suppressWatermark = false
        var seen: Set<String> = []
        var index = 0

        while index < arguments.count {
            let argument = arguments[index]
            switch argument {
            case "--help":
                guard action == .render, seen.isEmpty else {
                    throw RendererCLIError.diagnostic(RendererDiagnostic(code: .invalidArguments))
                }
                action = .help
                seen.insert(argument)
            case "--list-cases":
                guard action == .render, seen.isEmpty else {
                    throw RendererCLIError.diagnostic(RendererDiagnostic(code: .invalidArguments))
                }
                action = .listCases
                seen.insert(argument)
            case "--no-watermark":
                guard action == .render else {
                    throw RendererCLIError.diagnostic(RendererDiagnostic(code: .invalidArguments))
                }
                guard seen.insert(argument).inserted else {
                    throw RendererCLIError.diagnostic(RendererDiagnostic(code: .duplicateArgument))
                }
                suppressWatermark = true
            case "--input", "--output", "--case", "--backend":
                guard action == .render else {
                    throw RendererCLIError.diagnostic(RendererDiagnostic(code: .invalidArguments))
                }
                guard seen.insert(argument).inserted else {
                    throw RendererCLIError.diagnostic(RendererDiagnostic(code: .duplicateArgument))
                }
                let valueIndex = index + 1
                guard valueIndex < arguments.count, !arguments[valueIndex].hasPrefix("--"), !arguments[valueIndex].isEmpty else {
                    throw RendererCLIError.diagnostic(RendererDiagnostic(code: .missingArgumentValue))
                }
                let value = arguments[valueIndex]
                switch argument {
                case "--input":
                    inputDirectory = value
                case "--output":
                    outputDirectory = value
                case "--case":
                    selectedCase = value
                case "--backend":
                    backend = value
                default:
                    break
                }
                index = valueIndex
            default:
                throw RendererCLIError.diagnostic(RendererDiagnostic(code: .unknownArgument))
            }
            index += 1
        }

        if action != .render {
            return RendererCommand(
                action: action,
                inputDirectory: inputDirectory ?? "example-images/input",
                outputDirectory: outputDirectory,
                selectedCase: selectedCase,
                suppressWatermark: suppressWatermark,
                backend: backend ?? "cpu"
            )
        }

        if let backend, backend != "cpu" {
            throw RendererCLIError.diagnostic(RendererDiagnostic(code: .unsupportedBackend))
        }
        guard let outputDirectory, !outputDirectory.isEmpty else {
            throw RendererCLIError.diagnostic(RendererDiagnostic(code: .outputDirectoryMissing))
        }
        if let selectedCase, !cases.contains(where: { $0.id == selectedCase }) {
            throw RendererCLIError.diagnostic(RendererDiagnostic(code: .unknownCase))
        }

        return RendererCommand(
            action: .render,
            inputDirectory: inputDirectory ?? "example-images/input",
            outputDirectory: outputDirectory,
            selectedCase: selectedCase,
            suppressWatermark: suppressWatermark,
            backend: "cpu"
        )
    }
}
