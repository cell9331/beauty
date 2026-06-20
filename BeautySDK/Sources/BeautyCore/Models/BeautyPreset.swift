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
            let decoder = JSONDecoder()
            let schema = try decoder.decode(PresetSchemaProbe.self, from: data)
            let preset: BeautyPreset
            if let schemaVersion = schema.schemaVersion {
                guard schemaVersion == 1 else {
                    throw BeautyError.presetDecodeFailed("unsupported_schema")
                }
                preset = try decoder.decode(BeautyPresetEnvelope.self, from: data).preset
            } else {
                preset = try decoder.decode(BeautyPreset.self, from: data)
            }
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
        if let filterId = parameters.filterId {
            guard Self.isValidIdentifier(filterId), !filterId.contains("..") else {
                throw BeautyError.resourceNotFound("invalid_filter")
            }
            guard availableFilterIds.contains(filterId) else {
                throw BeautyError.resourceNotFound(filterId)
            }
        }
        return self
    }

    public static func isValidIdentifier(_ id: String) -> Bool {
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

private struct PresetSchemaProbe: Decodable {
    let schemaVersion: Int?
}

private struct BeautyPresetEnvelope: Decodable {
    let id: String
    let version: Int
    let displayName: String
    let parameters: BeautyParameters

    var preset: BeautyPreset {
        BeautyPreset(
            id: id,
            version: version,
            displayName: displayName,
            parameters: parameters
        )
    }
}
