import BeautySDK
import Foundation

struct BeautyPresetPickerItem: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let accessibilityLabel: String
    let preset: BeautyPreset

    init(preset: BeautyPreset) {
        self.id = preset.id
        self.title = preset.displayName
        self.accessibilityLabel = "Apply \(preset.displayName) Preset"
        self.preset = preset
    }
}

struct BeautyFilterPickerItem: Identifiable, Equatable, Sendable {
    let id: String
    let filterId: String?
    let title: String
    let accessibilityLabel: String
    let availability: BeautyAvailability

    static let none = BeautyFilterPickerItem(
        id: "none",
        filterId: nil,
        title: "None",
        accessibilityLabel: "Select No Filter",
        availability: .available
    )

    init(
        id: String,
        filterId: String?,
        title: String,
        accessibilityLabel: String,
        availability: BeautyAvailability
    ) {
        self.id = id
        self.filterId = filterId
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.availability = availability
    }

    init(definition: BeautyFilterDefinition) {
        self.id = definition.id
        self.filterId = definition.id
        self.title = definition.displayName
        self.accessibilityLabel = "Select \(definition.displayName) Filter"
        self.availability = .available
    }
}

struct BeautyResourcePickerFailureState: Equatable, Sendable {
    let heading: String
    let body: String
    let recovery: String
    let missingReason: String

    static let unavailable = BeautyResourcePickerFailureState(
        heading: "No presets or filters available",
        body: "Built-in resources could not be loaded. Current parameters stay unchanged.",
        recovery: "Some resources are unavailable. Choose another preset or filter.",
        missingReason: "This resource is unavailable in this build."
    )
}

enum BeautyResourcePickerModels {
    static func presetItems() -> [BeautyPresetPickerItem] {
        (try? BeautySDKResources.builtInPresets().map(BeautyPresetPickerItem.init)) ?? []
    }

    static func filterItems() -> [BeautyFilterPickerItem] {
        let filters = (try? BeautySDKResources.availableFilters().map(BeautyFilterPickerItem.init)) ?? []
        return [BeautyFilterPickerItem.none] + filters
    }
}
