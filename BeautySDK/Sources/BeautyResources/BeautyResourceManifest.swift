import BeautyCore
import Foundation

public struct BeautyResourceManifest: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let version: Int
    public let minimumSDKVersion: String
    public let filters: [BeautyFilterDefinition]
    public let presets: [BeautyPresetReference]

    public init(
        schemaVersion: Int,
        version: Int,
        minimumSDKVersion: String,
        filters: [BeautyFilterDefinition],
        presets: [BeautyPresetReference]
    ) {
        self.schemaVersion = schemaVersion
        self.version = version
        self.minimumSDKVersion = minimumSDKVersion
        self.filters = filters
        self.presets = presets
    }

    public static func decode(from data: Data) throws -> BeautyResourceManifest {
        do {
            let manifest = try JSONDecoder().decode(BeautyResourceManifest.self, from: data)
            return try manifest.validated()
        } catch let error as BeautyError {
            throw error
        } catch {
            throw BeautyError.presetDecodeFailed("manifest_schema")
        }
    }

    public func validated() throws -> BeautyResourceManifest {
        guard schemaVersion == 1 else {
            throw BeautyError.presetDecodeFailed("unsupported_manifest_schema")
        }
        guard version > 0 else {
            throw BeautyError.presetDecodeFailed("invalid_manifest_version")
        }
        guard !minimumSDKVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BeautyError.presetDecodeFailed("invalid_manifest_minimum_sdk")
        }
        guard !filters.isEmpty else {
            throw BeautyError.resourceNotFound("filters")
        }
        guard !presets.isEmpty else {
            throw BeautyError.resourceNotFound("presets")
        }

        var filterIds = Set<String>()
        for filter in filters {
            guard Self.isValidResourceIdentifier(filter.id) else {
                throw BeautyError.presetDecodeFailed("invalid_filter_id")
            }
            guard !filter.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw BeautyError.presetDecodeFailed("invalid_filter_name")
            }
            guard filterIds.insert(filter.id).inserted else {
                throw BeautyError.presetDecodeFailed("duplicate_filter_id")
            }
        }

        var presetIds = Set<String>()
        for preset in presets {
            guard Self.isValidResourceIdentifier(preset.id) else {
                throw BeautyError.presetDecodeFailed("invalid_preset_id")
            }
            guard Self.isValidResourceIdentifier(preset.resourceName) else {
                throw BeautyError.presetDecodeFailed("invalid_preset_resource")
            }
            guard presetIds.insert(preset.id).inserted else {
                throw BeautyError.presetDecodeFailed("duplicate_preset_id")
            }
        }

        return self
    }

    public static func isValidResourceIdentifier(_ id: String) -> Bool {
        BeautyPreset.isValidIdentifier(id) && !id.contains("..")
    }
}

public struct BeautyPresetReference: Codable, Equatable, Sendable {
    public let id: String
    public let resourceName: String

    public init(id: String, resourceName: String) {
        self.id = id
        self.resourceName = resourceName
    }
}
