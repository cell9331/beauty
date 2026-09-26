/// Closed, content-free diagnostic codes returned only for successful requests.
public enum BeautyDiagnosticCode: String, Codable, Equatable, Sendable {
    case warningsPresent
    case requestSucceeded
    case backendExecuted

    public var level: BeautyLogLevel {
        switch self {
        case .warningsPresent: .warning
        case .requestSucceeded: .info
        case .backendExecuted: .debug
        }
    }
}

public struct BeautyDiagnosticEvent: Codable, Equatable, Sendable {
    public let code: BeautyDiagnosticCode
    public let level: BeautyLogLevel

    public init(code: BeautyDiagnosticCode) {
        self.code = code
        self.level = code.level
    }
}
