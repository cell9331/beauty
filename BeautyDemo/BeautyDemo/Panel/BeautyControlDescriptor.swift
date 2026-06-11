import Foundation

enum BeautyControlID: String, CaseIterable, Hashable, Sendable {
    case skinSmoothing
    case skinWhitening
    case skinRosy
    case skinSharpen
    case faceSlim
    case faceSmall
    case faceVShape
    case jawSlim
    case chinLength
    case eyeSize
    case eyeDistance
    case eyeYPosition
    case eyeTailLift
    case noseSlim
    case noseWingSlim
    case noseTipSize
    case noseBridge
    case mouthSize
    case mouthWidth
    case smile
    case lipColor
    case filterIntensity
}

enum BeautyParameterKey: String, Hashable, Sendable {
    case skinSmoothing
    case skinWhitening
    case skinRosy
    case skinSharpen
    case faceSlim
    case faceSmall
    case faceVShape
    case jawSlim
    case chinLength
    case eyeSize
    case eyeDistance
    case eyeYPosition
    case eyeTailLift
    case noseSlim
    case noseWingSlim
    case noseTipSize
    case noseBridge
    case mouthSize
    case mouthWidth
    case smile
    case lipColor
    case filterIntensity
}

enum BeautyDisplayRange: Equatable, Sendable {
    case enhancement
    case bidirectional

    var bounds: ClosedRange<Double> {
        switch self {
        case .enhancement:
            0...100
        case .bidirectional:
            -100...100
        }
    }

    func clampedDisplayValue(_ value: Double) -> Double {
        min(max(value, bounds.lowerBound), bounds.upperBound)
    }

    func normalizedValue(_ value: Double) -> Float {
        Float(clampedDisplayValue(value) / 100)
    }
}

struct BeautyControlDescriptor: Identifiable, Equatable, Sendable {
    let id: BeautyControlID
    let label: String
    let parameterKey: BeautyParameterKey?
    let displayRange: BeautyDisplayRange
    let availability: BeautyAvailability

    var defaultDisplayValue: Double { 0 }
}
