/// Shared owner-host mapping for the eleven centered eye geometry sliders.
/// Positions use 0...1 with exact neutral at 0.5. This value-only contract owns
/// no view or editing state. Full travel spans each field's existing safety cap.
public enum BeautyEyeShapeSlider: String, CaseIterable, Codable, Sendable {
    case eyeSize, verticalPosition, height, length, spacing, irisSize
    case lowerEyelid, outerTail, tilt, innerCorner, outerCorner

    public var neutralPosition: Float { 0.5 }

    /// Rightward is larger/wider/farther; vertical position is downward in the
    /// upright image. Lower eyelid goes down; tail raises the outer corner, while
    /// reference-style tilt lowers it (opposite the direct positive tilt).
    /// Iris size describes observed image-plane iris support, not segmentation.
    public func applying(position: Float, to parameters: BeautyParameters) -> BeautyParameters {
        var result = parameters.normalized()
        let p = position.isFinite ? min(1, max(0, position)) : neutralPosition
        result[keyPath: field] = (2 * p - 1) * cap * polarity
        return result
    }

    /// Inverse mapping for selection, undo and rehydrated parameter snapshots.
    /// Out-of-cap direct API values display at the appropriate slider endpoint.
    public func position(in parameters: BeautyParameters) -> Float {
        let value = parameters.normalized()[keyPath: field]
        return (min(1, max(-1, value / (cap * polarity))) + 1) * 0.5
    }

    private var polarity: Float { self == .tilt ? -1 : 1 }

    private var cap: Float {
        switch self {
        case .eyeSize: 0.45
        case .verticalPosition, .irisSize, .tilt, .innerCorner, .outerCorner: 0.25
        case .height, .length: 0.35
        case .spacing, .lowerEyelid, .outerTail: 0.30
        }
    }

    private var field: WritableKeyPath<BeautyParameters, Float> {
        switch self {
        case .eyeSize: \.eyeSize
        case .verticalPosition: \.eyeYPosition
        case .height: \.eyeHeight
        case .length: \.eyeLength
        case .spacing: \.eyeDistance
        case .irisSize: \.pupilSize
        case .lowerEyelid: \.lowerEyelidDrop
        case .outerTail: \.eyeTailLift
        case .tilt: \.eyeTilt
        case .innerCorner: \.innerCornerOpen
        case .outerCorner: \.outerCornerOpen
        }
    }
}
