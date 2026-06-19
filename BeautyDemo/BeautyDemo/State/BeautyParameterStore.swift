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

    static let appliedPendingVisual = BeautyParameterStatus(
        primaryText: "Parameters applied",
        secondaryText: "Visual update pending Phase 6"
    )
}

@MainActor
final class BeautyParameterStore: ObservableObject {
    @Published private(set) var displayValues: [BeautyControlID: Double]
    @Published private(set) var selectedFilterId: String?
    @Published private(set) var selectedPresetId: String?
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
        status = .appliedPendingVisual
    }

    func selectFilter(id: String?) {
        selectedFilterId = id
        selectedPresetId = nil
        if id == nil {
            displayValues[.filterIntensity] = BeautyControlDescriptor.descriptor(id: .filterIntensity).defaultDisplayValue
        }
        status = .appliedPendingVisual
    }

    func applyPreset(_ preset: BeautyPreset) {
        apply(parameters: preset.parameters)
        selectedPresetId = preset.id
        status = .appliedPendingVisual
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
        status = .appliedPendingVisual
    }

    func resetAll() {
        for descriptor in descriptors where descriptor.availability.isEnabled {
            displayValues[descriptor.id] = descriptor.defaultDisplayValue
        }

        selectedFilterId = nil
        selectedPresetId = nil
        status = .appliedPendingVisual
    }

    private func apply(parameters: BeautyParameters) {
        setDisplayValue(Double(parameters.skinSmoothing) * 100, for: .skinSmoothing)
        setDisplayValue(Double(parameters.skinWhitening) * 100, for: .skinWhitening)
        setDisplayValue(Double(parameters.skinRosy) * 100, for: .skinRosy)
        setDisplayValue(Double(parameters.skinSharpen) * 100, for: .skinSharpen)
        setDisplayValue(Double(parameters.brightness) * 100, for: .brightness)
        setDisplayValue(Double(parameters.contrast) * 100, for: .contrast)
        setDisplayValue(Double(parameters.saturation) * 100, for: .saturation)
        setDisplayValue(Double(parameters.temperature) * 100, for: .temperature)
        setDisplayValue(Double(parameters.tint) * 100, for: .tint)
        setDisplayValue(Double(parameters.exposure) * 100, for: .exposure)
        setDisplayValue(Double(parameters.highlight) * 100, for: .highlight)
        setDisplayValue(Double(parameters.shadow) * 100, for: .shadow)
        setDisplayValue(Double(parameters.faceSlim) * 100, for: .faceSlim)
        setDisplayValue(Double(parameters.faceSmall) * 100, for: .faceSmall)
        setDisplayValue(Double(parameters.faceVShape) * 100, for: .faceVShape)
        setDisplayValue(Double(parameters.jawSlim) * 100, for: .jawSlim)
        setDisplayValue(Double(parameters.chinLength) * 100, for: .chinLength)
        setDisplayValue(Double(parameters.eyeSize) * 100, for: .eyeSize)
        setDisplayValue(Double(parameters.eyeDistance) * 100, for: .eyeDistance)
        setDisplayValue(Double(parameters.eyeYPosition) * 100, for: .eyeYPosition)
        setDisplayValue(Double(parameters.eyeTailLift) * 100, for: .eyeTailLift)
        setDisplayValue(Double(parameters.noseSlim) * 100, for: .noseSlim)
        setDisplayValue(Double(parameters.noseWingSlim) * 100, for: .noseWingSlim)
        setDisplayValue(Double(parameters.noseTipSize) * 100, for: .noseTipSize)
        setDisplayValue(Double(parameters.noseBridge) * 100, for: .noseBridge)
        setDisplayValue(Double(parameters.mouthSize) * 100, for: .mouthSize)
        setDisplayValue(Double(parameters.mouthWidth) * 100, for: .mouthWidth)
        setDisplayValue(Double(parameters.smile) * 100, for: .smile)
        setDisplayValue(Double(parameters.lipColor) * 100, for: .lipColor)
        selectedFilterId = parameters.filterId
        displayValues[.filterIntensity] = BeautyControlDescriptor.descriptor(id: .filterIntensity)
            .displayRange
            .clampedDisplayValue(Double(parameters.filterIntensity) * 100)
    }
}
