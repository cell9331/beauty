/// Shared owner-host mapping for the seven centered eyebrow geometry sliders.
/// Positions use 0...1 with exact neutral at 0.5. This value-only contract owns
/// no view or editing state. Full travel spans each field's existing safety cap.
public enum BeautyEyebrowSlider: String, CaseIterable, Codable, Sendable {
    case verticalPosition, thickness, length, spacing, headSpacing, tilt, peak

    public var neutralPosition: Float { 0.5 }

    /// Rightward moves the eyebrows upward, makes them thicker or longer,
    /// increases whole-brow or inner-head spacing, lowers the outer ends, or
    /// defines the interior peaks. Leftward applies the opposite direction.
    /// Vertical position uses the upright image's top-left coordinates (Y down).
    public func applying(position: Float, to parameters: BeautyParameters) -> BeautyParameters {
        var result = parameters.normalized()
        let p = position.isFinite ? min(1, max(0, position)) : neutralPosition
        result[keyPath: field] = (2 * p - 1) * cap * polarity
        return result
    }

    /// Inverse mapping for selection, undo and restored parameter values.
    /// Direct values beyond the safety cap display at the nearest endpoint.
    public func position(in parameters: BeautyParameters) -> Float {
        let value = parameters.normalized()[keyPath: field] / (cap * polarity)
        return (min(1, max(-1, value)) + 1) * 0.5
    }

    private var cap: Float { 0.25 }

    private var polarity: Float { self == .verticalPosition || self == .tilt ? -1 : 1 }

    private var field: WritableKeyPath<BeautyParameters, Float> {
        switch self {
        case .verticalPosition: \.eyebrowYPosition
        case .thickness: \.eyebrowThickness
        case .length: \.eyebrowLength
        case .spacing: \.eyebrowSpacing
        case .headSpacing: \.eyebrowHeadSpacing
        case .tilt: \.eyebrowTilt
        case .peak: \.eyebrowPeakDefinition
        }
    }
}
