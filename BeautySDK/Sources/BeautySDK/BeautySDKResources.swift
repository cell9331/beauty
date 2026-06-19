import BeautyCore
import BeautyResources

public enum BeautySDKResources {
    public static func availableFilters() throws -> [BeautyFilterDefinition] {
        try catalog().availableFilters
    }

    public static func builtInPresets() throws -> [BeautyPreset] {
        try catalog().builtInPresets()
    }

    public static func preset(id: String) throws -> BeautyPreset {
        try catalog().preset(id: id)
    }

    public static func validate(parameters: BeautyParameters) throws -> BeautyParameters {
        let normalized = parameters.normalized()
        guard let filterId = normalized.filterId else {
            return normalized
        }
        guard try catalog().availableFilterIds.contains(filterId) else {
            throw BeautyError.resourceNotFound(filterId)
        }
        return normalized
    }

    private static func catalog() throws -> BeautyResourceCatalog {
        try BeautyResourceCatalog.bundled()
    }
}
