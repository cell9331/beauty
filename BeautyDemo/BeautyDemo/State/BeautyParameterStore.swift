import BeautySDK
import Combine
import Foundation

struct BeautyParameterStatus: Equatable, Sendable {
    let primaryText: String?
    let secondaryText: String?

    static let idle = BeautyParameterStatus(
        primaryText: nil,
        secondaryText: nil
    )

}

enum BeautyParameterSource: Equatable, Sendable {
    case custom
    case preset(id: String)
    case imported
}

@MainActor
final class BeautyParameterStore: ObservableObject {
    @Published private(set) var displayValues: [BeautyControlID: Double]
    @Published private(set) var selectedFilterId: String?
    @Published private(set) var selectedPresetId: String?
    @Published private(set) var parameterSource: BeautyParameterSource
    @Published private(set) var status: BeautyParameterStatus

    private let descriptors: [BeautyControlDescriptor]

    init(descriptors: [BeautyControlDescriptor]? = nil) {
        let resolvedDescriptors = descriptors ?? BeautyControlDescriptor.all

        self.descriptors = resolvedDescriptors
        self.displayValues = Dictionary(
            uniqueKeysWithValues: resolvedDescriptors.map { ($0.id, $0.defaultDisplayValue) }
        )
        self.selectedFilterId = nil
        self.selectedPresetId = nil
        self.parameterSource = .custom
        self.status = .idle
    }

    var parametersSnapshot: BeautyParameters {
        var parameters = BeautyParameters()

        for descriptor in descriptors where descriptor.availability.isEnabled {
            guard let key = descriptor.parameterKey else {
                continue
            }

            let normalizedValue = descriptor.displayRange.normalizedValue(displayValue(for: descriptor))

            switch key {
            case .skinSmoothing:
                parameters.skinSmoothing = normalizedValue
            case .skinWhitening:
                parameters.skinWhitening = normalizedValue
            case .skinRosy:
                parameters.skinRosy = normalizedValue
            case .skinSharpen:
                parameters.skinSharpen = normalizedValue
            case .brightness:
                parameters.brightness = normalizedValue
            case .contrast:
                parameters.contrast = normalizedValue
            case .saturation:
                parameters.saturation = normalizedValue
            case .temperature:
                parameters.temperature = normalizedValue
            case .tint:
                parameters.tint = normalizedValue
            case .exposure:
                parameters.exposure = normalizedValue
            case .highlight:
                parameters.highlight = normalizedValue
            case .shadow:
                parameters.shadow = normalizedValue
            case .faceSlim:
                parameters.faceSlim = normalizedValue
            case .faceSmall:
                parameters.faceSmall = normalizedValue
            case .faceVShape:
                parameters.faceVShape = normalizedValue
            case .jawSlim:
                parameters.jawSlim = normalizedValue
            case .chinLength:
                parameters.chinLength = normalizedValue
            case .eyeSize:
                parameters.eyeSize = normalizedValue
            case .eyeDistance:
                parameters.eyeDistance = normalizedValue
            case .eyeYPosition:
                parameters.eyeYPosition = normalizedValue
            case .eyeTailLift:
                parameters.eyeTailLift = normalizedValue
            case .noseSlim:
                parameters.noseSlim = normalizedValue
            case .noseWingSlim:
                parameters.noseWingSlim = normalizedValue
            case .noseTipSize:
                parameters.noseTipSize = normalizedValue
            case .noseBridge:
                parameters.noseBridge = normalizedValue
            case .mouthSize:
                parameters.mouthSize = normalizedValue
            case .mouthWidth:
                parameters.mouthWidth = normalizedValue
            case .smile:
                parameters.smile = normalizedValue
            case .lipColor:
                parameters.lipColor = normalizedValue
            case .filterIntensity:
                parameters.filterIntensity = selectedFilterId == nil ? 0 : normalizedValue
            case .filterId:
                break
            }
        }

        parameters.filterId = selectedFilterId
        return parameters
    }

    func displayValue(for descriptor: BeautyControlDescriptor) -> Double {
        displayValues[descriptor.id] ?? descriptor.defaultDisplayValue
    }

    func displayValue(for controlID: BeautyControlID) -> Double {
        displayValue(for: BeautyControlDescriptor.descriptor(id: controlID))
    }

    func setDisplayValue(_ value: Double, for controlID: BeautyControlID) {
        setDisplayValue(value, for: BeautyControlDescriptor.descriptor(id: controlID))
    }

    func setDisplayValue(_ value: Double, for descriptor: BeautyControlDescriptor) {
        guard descriptor.availability.isEnabled else {
            return
        }

        displayValues[descriptor.id] = descriptor.displayRange.clampedDisplayValue(value)
        selectedPresetId = nil
        parameterSource = .custom
        status = .idle
    }

    func selectFilter(id: String?) {
        selectedFilterId = id
        selectedPresetId = nil
        parameterSource = .custom
        if id == nil {
            displayValues[.filterIntensity] = BeautyControlDescriptor.descriptor(id: .filterIntensity).defaultDisplayValue
        }
        status = .idle
    }

    func applyPreset(_ preset: BeautyPreset) {
        apply(parameters: preset.parameters)
        selectedPresetId = preset.id
        parameterSource = .preset(id: preset.id)
        status = .idle
    }

    func applyImportedParameters(_ parameters: BeautyParameters) {
        apply(parameters: parameters)
        selectedPresetId = nil
        parameterSource = .imported
        status = .idle
    }

    func restoreCustomParameters(_ parameters: BeautyParameters) {
        apply(parameters: parameters)
        selectedPresetId = nil
        parameterSource = .custom
        status = .idle
    }

    func reset(_ controlID: BeautyControlID) {
        reset(BeautyControlDescriptor.descriptor(id: controlID))
    }

    func reset(_ descriptor: BeautyControlDescriptor) {
        guard descriptor.availability.isEnabled else {
            return
        }

        displayValues[descriptor.id] = descriptor.defaultDisplayValue
        selectedPresetId = nil
        parameterSource = .custom
        status = .idle
    }

    func resetAll() {
        for descriptor in descriptors where descriptor.availability.isEnabled {
            displayValues[descriptor.id] = descriptor.defaultDisplayValue
        }

        selectedFilterId = nil
        selectedPresetId = nil
        parameterSource = .custom
        status = .idle
    }

    private func apply(parameters: BeautyParameters) {
        let normalized = parameters.normalized()

        setDisplayValueFromSnapshot(Double(normalized.skinSmoothing) * 100, for: .skinSmoothing)
        setDisplayValueFromSnapshot(Double(normalized.skinWhitening) * 100, for: .skinWhitening)
        setDisplayValueFromSnapshot(Double(normalized.skinRosy) * 100, for: .skinRosy)
        setDisplayValueFromSnapshot(Double(normalized.skinSharpen) * 100, for: .skinSharpen)
        setDisplayValueFromSnapshot(Double(normalized.brightness) * 100, for: .brightness)
        setDisplayValueFromSnapshot(Double(normalized.contrast) * 100, for: .contrast)
        setDisplayValueFromSnapshot(Double(normalized.saturation) * 100, for: .saturation)
        setDisplayValueFromSnapshot(Double(normalized.temperature) * 100, for: .temperature)
        setDisplayValueFromSnapshot(Double(normalized.tint) * 100, for: .tint)
        setDisplayValueFromSnapshot(Double(normalized.exposure) * 100, for: .exposure)
        setDisplayValueFromSnapshot(Double(normalized.highlight) * 100, for: .highlight)
        setDisplayValueFromSnapshot(Double(normalized.shadow) * 100, for: .shadow)
        setDisplayValueFromSnapshot(Double(normalized.faceSlim) * 100, for: .faceSlim)
        setDisplayValueFromSnapshot(Double(normalized.faceSmall) * 100, for: .faceSmall)
        setDisplayValueFromSnapshot(Double(normalized.faceVShape) * 100, for: .faceVShape)
        setDisplayValueFromSnapshot(Double(normalized.jawSlim) * 100, for: .jawSlim)
        setDisplayValueFromSnapshot(Double(normalized.chinLength) * 100, for: .chinLength)
        setDisplayValueFromSnapshot(Double(normalized.eyeSize) * 100, for: .eyeSize)
        setDisplayValueFromSnapshot(Double(normalized.eyeDistance) * 100, for: .eyeDistance)
        setDisplayValueFromSnapshot(Double(normalized.eyeYPosition) * 100, for: .eyeYPosition)
        setDisplayValueFromSnapshot(Double(normalized.eyeTailLift) * 100, for: .eyeTailLift)
        setDisplayValueFromSnapshot(Double(normalized.noseSlim) * 100, for: .noseSlim)
        setDisplayValueFromSnapshot(Double(normalized.noseWingSlim) * 100, for: .noseWingSlim)
        setDisplayValueFromSnapshot(Double(normalized.noseTipSize) * 100, for: .noseTipSize)
        setDisplayValueFromSnapshot(Double(normalized.noseBridge) * 100, for: .noseBridge)
        setDisplayValueFromSnapshot(Double(normalized.mouthSize) * 100, for: .mouthSize)
        setDisplayValueFromSnapshot(Double(normalized.mouthWidth) * 100, for: .mouthWidth)
        setDisplayValueFromSnapshot(Double(normalized.smile) * 100, for: .smile)
        setDisplayValueFromSnapshot(Double(normalized.lipColor) * 100, for: .lipColor)
        selectedFilterId = normalized.filterId
        let filterIntensity = normalized.filterId == nil ? 0 : Double(normalized.filterIntensity) * 100
        displayValues[.filterIntensity] = BeautyControlDescriptor.descriptor(id: .filterIntensity)
            .displayRange
            .clampedDisplayValue(filterIntensity)
    }

    private func setDisplayValueFromSnapshot(_ value: Double, for controlID: BeautyControlID) {
        let descriptor = BeautyControlDescriptor.descriptor(id: controlID)
        guard descriptor.availability.isEnabled else {
            return
        }
        displayValues[descriptor.id] = descriptor.displayRange.clampedDisplayValue(value)
    }
}
