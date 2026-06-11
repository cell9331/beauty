import Foundation

public struct BeautyErrorContext: Codable, Equatable, Sendable {
    public let operation: String
    public let code: String
    public let metadata: [String: String]

    public init(operation: String, code: String, metadata: [String: String] = [:]) {
        self.operation = Self.redacted(operation)
        self.code = Self.redacted(code)
        self.metadata = metadata.mapValues(Self.redacted)
    }

    private static func redacted(_ value: String) -> String {
        let allowed = value.unicodeScalars.filter { scalar in
            CharacterSet.alphanumerics.contains(scalar) ||
                scalar == "." || scalar == "_" || scalar == "-"
        }
        let sanitized = String(String.UnicodeScalarView(allowed))
        if sanitized.isEmpty {
            return "redacted"
        }
        return String(sanitized.prefix(48))
    }
}
