import Foundation

public struct BeautyPreset: Codable, Equatable, Sendable {
    public let id: String
    public let version: Int
    public let displayName: String
    public let parameters: BeautyParameters

    public init(
        id: String,
        version: Int,
        displayName: String,
        parameters: BeautyParameters
    ) {
        self.id = id
        self.version = version
        self.displayName = displayName
        self.parameters = parameters
    }

    public static func decode(
        from data: Data,
        availableFilterIds: Set<String> = []
    ) throws -> BeautyPreset {
        do {
            let preset = try JSONDecoder().decode(BeautyPreset.self, from: data)
            return try preset.validated(availableFilterIds: availableFilterIds)
        } catch let error as BeautyError {
            throw error
        } catch {
            throw BeautyError.presetDecodeFailed("schema")
        }
    }

    public func validated(availableFilterIds: Set<String> = []) throws -> BeautyPreset {
        guard Self.isValidIdentifier(id) else {
            throw BeautyError.presetDecodeFailed("invalid_id")
        }
        guard version > 0 else {
            throw BeautyError.presetDecodeFailed("invalid_version")
        }
        guard !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BeautyError.presetDecodeFailed("invalid_name")
        }
        if let filterId = parameters.filterId, !availableFilterIds.contains(filterId) {
            throw BeautyError.resourceNotFound(filterId)
        }
        return self
    }

    private static func isValidIdentifier(_ id: String) -> Bool {
        guard !id.isEmpty else {
            return false
        }
        return id.unicodeScalars.allSatisfy { scalar in
            (scalar.value >= 65 && scalar.value <= 90) ||
                (scalar.value >= 97 && scalar.value <= 122) ||
                (scalar.value >= 48 && scalar.value <= 57) ||
                scalar == "." ||
                scalar == "_" ||
                scalar == "-"
        }
    }
}
