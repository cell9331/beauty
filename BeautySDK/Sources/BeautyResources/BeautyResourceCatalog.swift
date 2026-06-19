import BeautyCore
import Foundation

public struct BeautyResourceCatalog: Equatable, Sendable {
    public let manifest: BeautyResourceManifest

    public var availableFilters: [BeautyFilterDefinition] {
        manifest.filters
    }

    public var availableFilterIds: Set<String> {
        Set(manifest.filters.map(\.id))
    }

    public init(manifest: BeautyResourceManifest) {
        self.manifest = manifest
    }

    public static func bundled() throws -> BeautyResourceCatalog {
        guard let manifestURL = Bundle.module.url(forResource: "manifest", withExtension: "json") else {
            throw BeautyError.resourceNotFound("manifest")
        }

        let data: Data
        do {
            data = try Data(contentsOf: manifestURL)
        } catch {
            throw BeautyError.resourceNotFound("manifest")
        }

        let manifest = try BeautyResourceManifest.decode(from: data)
        return BeautyResourceCatalog(manifest: manifest)
    }

    public func builtInPresets() throws -> [BeautyPreset] {
        try manifest.presets.map { try preset(reference: $0) }
    }

    public func preset(id: String) throws -> BeautyPreset {
        guard BeautyResourceManifest.isValidResourceIdentifier(id),
              let reference = manifest.presets.first(where: { $0.id == id }) else {
            throw BeautyError.resourceNotFound(id)
        }
        return try preset(reference: reference)
    }

    private func preset(reference: BeautyPresetReference) throws -> BeautyPreset {
        guard let url = Bundle.module.url(forResource: reference.resourceName, withExtension: "json") else {
            throw BeautyError.resourceNotFound(reference.id)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw BeautyError.resourceNotFound(reference.id)
        }

        let preset = try BeautyPreset.decode(from: data, availableFilterIds: availableFilterIds)
        guard preset.id == reference.id else {
            throw BeautyError.presetDecodeFailed("preset_reference_mismatch")
        }
        return preset
    }
}
