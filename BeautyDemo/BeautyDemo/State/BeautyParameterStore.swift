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
    @Published private(set) var status: BeautyParameterStatus

    private let descriptors: [BeautyControlDescriptor]

    init(descriptors: [BeautyControlDescriptor]? = nil) {
        let resolvedDescriptors = descriptors ?? BeautyControlDescriptor.all

        self.descriptors = resolvedDescriptors
        self.displayValues = Dictionary(
            uniqueKeysWithValues: resolvedDescriptors.map { ($0.id, $0.defaultDisplayValue) }
        )
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
            case .filterId, .filterIntensity:
                break
            }
        }

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
        status = .appliedPendingVisual
    }

    func resetAll() {
        for descriptor in descriptors where descriptor.availability.isEnabled {
            displayValues[descriptor.id] = descriptor.defaultDisplayValue
        }

        status = .appliedPendingVisual
    }
}
