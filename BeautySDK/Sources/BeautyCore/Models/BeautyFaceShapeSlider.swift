/// Owner-host slider contract inferred from the isolated reference endpoints.
/// Position is 0...1; centered sliders are neutral at 0.5. V-face and smoothing
/// are neutral at 0. No view or mutable slider state belongs to the SDK.
public enum BeautyFaceShapeSlider: String, CaseIterable, Codable, Sendable {
    case faceWidth, smallFace, temple, cheekbone, chinLength, chinTaper
    case jawAngle, vFace, contourSmooth, hairline

    public var neutralPosition: Float {
        self == .vFace || self == .contourSmooth ? 0 : 0.5
    }

    /// Returns a normalized snapshot, preserving all other requested fields.
    /// Mapping spans the full safety cap, avoiding an early plateau on a host
    /// slider. Direct positive `chinLength` still lengthens and direct positive
    /// `chinTaper` still tapers. The reference-style sliders instead mean
    /// right=shorter chin and right=rounder/wider chin, respectively.
    public func applying(position: Float, to parameters: BeautyParameters) -> BeautyParameters {
        var result = parameters.normalized()
        let p = position.isFinite ? min(1, max(0, position)) : neutralPosition
        let signed = 2 * p - 1
        switch self {
        case .faceWidth: result.faceSlim = signed * 0.60
        case .smallFace: result.faceSmall = signed * 0.45
        case .temple: result.templeFullness = signed * 0.25
        case .cheekbone: result.cheekboneSlim = signed * 0.25
        case .chinLength: result.chinLength = -signed * 0.35
        case .chinTaper: result.chinTaper = -signed * 0.25
        case .jawAngle: result.jawSlim = signed * 0.45
        case .vFace: result.faceVShape = p * 0.50
        case .contourSmooth: result.faceContourSmooth = p * 0.25
        case .hairline: result.hairlineHeight = signed * 0.25
        }
        return result
    }
}
