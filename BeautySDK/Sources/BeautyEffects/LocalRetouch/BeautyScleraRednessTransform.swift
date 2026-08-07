import Foundation

package struct BeautyScleraRednessTarget: Equatable, Sendable {
    package let red: UInt8
    package let green: UInt8
    package let blue: UInt8
}

package enum BeautyScleraRednessTransform {
    package static let maximumEffectiveStrength: Float = 0.52
    package static let maximumLuminanceDelta: Float = 0.018

    /// Derives a bounded target from one immutable canonical source triplet.
    /// The caller leaves soft-weight application to the Q16 composition owner.
    package static func target(
        red: UInt8,
        green: UInt8,
        blue: UInt8,
        strength: Float
    ) -> BeautyScleraRednessTarget? {
        guard strength.isFinite, strength > 0 else { return nil }

        let sourceRed = Float(red) / 255
        let sourceGreen = Float(green) / 255
        let sourceBlue = Float(blue) / 255
        let sourceLuminance = luminance(sourceRed, sourceGreen, sourceBlue)
        let redExcess = max(0, sourceRed - max(sourceGreen, sourceBlue))
        let materialRedness = smoothstep(0.030, 0.100, redExcess)
        let localStrength = min(strength, 1) * maximumEffectiveStrength * materialRedness
        guard localStrength > 0.001 else { return nil }

        var nextRed = sourceRed - redExcess * 0.55 * localStrength
        var nextGreen = sourceGreen + redExcess * 0.18 * localStrength
        var nextBlue = sourceBlue + redExcess * 0.10 * localStrength
        let rawLuminance = luminance(nextRed, nextGreen, nextBlue)
        let desiredLuminance = min(
            sourceLuminance + maximumLuminanceDelta,
            max(sourceLuminance - maximumLuminanceDelta, sourceLuminance)
        )
        let luminanceCorrection = desiredLuminance - rawLuminance
        nextRed += luminanceCorrection
        nextGreen += luminanceCorrection
        nextBlue += luminanceCorrection

        let result = BeautyScleraRednessTarget(
            red: byte(nextRed),
            green: byte(nextGreen),
            blue: byte(nextBlue)
        )
        guard result.red != red || result.green != green || result.blue != blue else {
            return nil
        }
        return result
    }

    private static func luminance(_ red: Float, _ green: Float, _ blue: Float) -> Float {
        0.2126 * red + 0.7152 * green + 0.0722 * blue
    }

    private static func smoothstep(_ lower: Float, _ upper: Float, _ value: Float) -> Float {
        guard upper > lower else { return value >= upper ? 1 : 0 }
        let t = min(1, max(0, (value - lower) / (upper - lower)))
        return t * t * (3 - 2 * t)
    }

    private static func byte(_ value: Float) -> UInt8 {
        UInt8((min(1, max(0, value)) * 255).rounded(.toNearestOrAwayFromZero))
    }
}

