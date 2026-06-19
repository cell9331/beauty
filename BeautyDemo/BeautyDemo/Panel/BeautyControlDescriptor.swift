import Foundation

enum BeautyControlID: String, CaseIterable, Hashable, Sendable {
    case skinSmoothing
    case skinWhitening
    case skinRosy
    case skinSharpen
    case brightness
    case contrast
    case saturation
    case temperature
    case tint
    case exposure
    case highlight
    case shadow
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
    case filterId
    case filterIntensity
}

enum BeautyParameterKey: String, Hashable, Sendable {
    case skinSmoothing
    case skinWhitening
    case skinRosy
    case skinSharpen
    case brightness
    case contrast
    case saturation
    case temperature
    case tint
    case exposure
    case highlight
    case shadow
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
    case filterId
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
    var resetLabel: String { "Reset \(label)" }
}

extension BeautyControlDescriptor {
    static let resetAllTitle = "Reset All Parameters"

    static let skinControls: [BeautyControlDescriptor] = [
        BeautyControlDescriptor(
            id: .skinSmoothing,
            label: "Skin Smoothing",
            parameterKey: .skinSmoothing,
            displayRange: .enhancement,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .skinWhitening,
            label: "Skin Whitening",
            parameterKey: .skinWhitening,
            displayRange: .enhancement,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .skinRosy,
            label: "Rosy Tone",
            parameterKey: .skinRosy,
            displayRange: .enhancement,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .skinSharpen,
            label: "Skin Sharpen",
            parameterKey: .skinSharpen,
            displayRange: .enhancement,
            availability: .available
        )
    ]

    static let colorControls: [BeautyControlDescriptor] = [
        BeautyControlDescriptor(
            id: .brightness,
            label: "Brightness",
            parameterKey: .brightness,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .contrast,
            label: "Contrast",
            parameterKey: .contrast,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .saturation,
            label: "Saturation",
            parameterKey: .saturation,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .temperature,
            label: "Temperature",
            parameterKey: .temperature,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .tint,
            label: "Tint",
            parameterKey: .tint,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .exposure,
            label: "Exposure",
            parameterKey: .exposure,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .highlight,
            label: "Highlight",
            parameterKey: .highlight,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .shadow,
            label: "Shadow",
            parameterKey: .shadow,
            displayRange: .bidirectional,
            availability: .available
        )
    ]

    static let beautyControls: [BeautyControlDescriptor] = skinControls + colorControls

    static let faceShapeControls: [BeautyControlDescriptor] = [
        BeautyControlDescriptor(
            id: .faceSlim,
            label: "Face Slim",
            parameterKey: .faceSlim,
            displayRange: .enhancement,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .faceSmall,
            label: "Small Face",
            parameterKey: .faceSmall,
            displayRange: .enhancement,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .faceVShape,
            label: "V Shape",
            parameterKey: .faceVShape,
            displayRange: .enhancement,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .jawSlim,
            label: "Jaw Slim",
            parameterKey: .jawSlim,
            displayRange: .enhancement,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .chinLength,
            label: "Chin Length",
            parameterKey: .chinLength,
            displayRange: .bidirectional,
            availability: .available
        )
    ]

    static let eyesControls: [BeautyControlDescriptor] = [
        BeautyControlDescriptor(
            id: .eyeSize,
            label: "Eye Size",
            parameterKey: .eyeSize,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .eyeDistance,
            label: "Eye Distance",
            parameterKey: .eyeDistance,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .eyeYPosition,
            label: "Eye Vertical Position",
            parameterKey: .eyeYPosition,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .eyeTailLift,
            label: "Eye Tail Lift",
            parameterKey: .eyeTailLift,
            displayRange: .bidirectional,
            availability: .available
        )
    ]

    static let noseControls: [BeautyControlDescriptor] = [
        BeautyControlDescriptor(
            id: .noseSlim,
            label: "Nose Slim",
            parameterKey: .noseSlim,
            displayRange: .enhancement,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .noseWingSlim,
            label: "Nose Wing Slim",
            parameterKey: .noseWingSlim,
            displayRange: .enhancement,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .noseTipSize,
            label: "Nose Tip Size",
            parameterKey: .noseTipSize,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .noseBridge,
            label: "Nose Bridge",
            parameterKey: .noseBridge,
            displayRange: .enhancement,
            availability: .available
        )
    ]

    static let mouthControls: [BeautyControlDescriptor] = [
        BeautyControlDescriptor(
            id: .mouthSize,
            label: "Mouth Size",
            parameterKey: .mouthSize,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .mouthWidth,
            label: "Mouth Width",
            parameterKey: .mouthWidth,
            displayRange: .bidirectional,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .smile,
            label: "Smile",
            parameterKey: .smile,
            displayRange: .enhancement,
            availability: .available
        ),
        BeautyControlDescriptor(
            id: .lipColor,
            label: "Lip Color",
            parameterKey: .lipColor,
            displayRange: .enhancement,
            availability: .available
        )
    ]

    static let filterControls: [BeautyControlDescriptor] = [
        BeautyControlDescriptor(
            id: .filterIntensity,
            label: "Filter Intensity",
            parameterKey: .filterIntensity,
            displayRange: .enhancement,
            availability: .available
        )
    ]

    static let all: [BeautyControlDescriptor] = beautyControls
        + faceShapeControls
        + eyesControls
        + noseControls
        + mouthControls
        + filterControls

    static let availableControls: [BeautyControlDescriptor] = all.filter(\.availability.isEnabled)

    static func descriptor(id: BeautyControlID) -> BeautyControlDescriptor {
        all.first { $0.id == id }!
    }

    static func controls(for categoryID: BeautyCategoryID) -> [BeautyControlDescriptor] {
        switch categoryID {
        case .beauty:
            beautyControls
        case .faceShape:
            faceShapeControls
        case .facialFeatures:
            eyesControls
        case .filters:
            filterControls
        case .makeup, .stickers, .background, .style:
            []
        }
    }

    static func controls(for subcategoryID: FacialFeatureSubcategoryID) -> [BeautyControlDescriptor] {
        switch subcategoryID {
        case .eyes:
            eyesControls
        case .nose:
            noseControls
        case .mouth:
            mouthControls
        case .eyebrows, .teeth, .hairline:
            []
        }
    }
}
