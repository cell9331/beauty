/// Shared owner-host mapping for the mouth controls. Geometry positions use
/// 0...1 with neutral at 0.5; teeth whitening is neutral at 0. This value-only
/// contract owns no view or editing state and spans the existing safety caps.
public enum BeautyMouthSlider: String, CaseIterable, Codable, Sendable {
    case size, width, verticalPosition, tilt, horizontalPosition
    case mShape, fullness, smile, teethWhitening

    public var neutralPosition: Float { self == .teethWhitening ? 0 : 0.5 }

    /// Rightward means smaller, wider, upward, clockwise, rightward, more
    /// defined M-lip, fuller, more smiling, or whiter respectively. Direct SDK
    /// `mouthSize` keeps positive=larger and `mouthYPosition` positive=downward;
    /// this slider reverses those two signs.
    /// Rotation uses the upright image's top-left coordinate system (Y down).
    public func applying(position: Float, to parameters: BeautyParameters) -> BeautyParameters {
        var result = parameters.normalized()
        let p = position.isFinite ? min(1, max(0, position)) : neutralPosition
        let amount = self == .teethWhitening ? p : 2 * p - 1
        result[keyPath: field] = amount * cap * direction
        return result
    }

    /// Inverse mapping for tool selection, undo and restored parameter values.
    /// Finite direct values beyond a safety cap display at the nearest endpoint.
    public func position(in parameters: BeautyParameters) -> Float {
        let value = parameters.normalized()[keyPath: field] / (cap * direction)
        if self == .teethWhitening { return min(1, max(0, value)) }
        return (min(1, max(-1, value)) + 1) * 0.5
    }

    private var direction: Float { self == .size || self == .verticalPosition ? -1 : 1 }

    private var cap: Float {
        switch self {
        case .size, .width: 0.35
        case .verticalPosition, .tilt, .horizontalPosition, .mShape, .fullness: 0.25
        case .smile: 0.50
        case .teethWhitening: 1
        }
    }

    private var field: WritableKeyPath<BeautyParameters, Float> {
        switch self {
        case .size: \.mouthSize
        case .width: \.mouthWidth
        case .verticalPosition: \.mouthYPosition
        case .tilt: \.mouthTilt
        case .horizontalPosition: \.mouthXPosition
        case .mShape: \.lipPeakDefinition
        case .fullness: \.lipPlump
        case .smile: \.smile
        case .teethWhitening: \.teethWhitening
        }
    }
}
