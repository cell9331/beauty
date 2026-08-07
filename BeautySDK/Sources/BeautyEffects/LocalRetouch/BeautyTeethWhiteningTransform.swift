import Foundation

package struct BeautyTeethWhiteningTarget: Equatable, Sendable {
    package let red: UInt8
    package let green: UInt8
    package let blue: UInt8
}

package enum BeautyTeethWhiteningTransform {
    package static let maximumEffectiveStrength: Float = 0.62
    package static let yellowNeutralizationFactor: Float = 1.45
    private static let maximumRedGreenImbalance: Float = 0.12
    private static let maximumSaturation: Float = 0.55

    /// Derives one bounded target from the immutable source triplet.
    ///
    /// The caller applies the soft mask exactly once through the Q16
    /// composition owner. Neutral, already-light, and lightly warm source
    /// pixels stay on the explicit no-op side of the material-yellow gate.
    package static func target(
        red: UInt8,
        green: UInt8,
        blue: UInt8,
        strength: Float
    ) -> BeautyTeethWhiteningTarget? {
        guard strength.isFinite, strength > 0 else {
            return nil
        }

        let sourceRed = Float(red) / 255
        let sourceGreen = Float(green) / 255
        let sourceBlue = Float(blue) / 255
        let maximumChannel = max(sourceRed, max(sourceGreen, sourceBlue))
        let minimumChannel = min(sourceRed, min(sourceGreen, sourceBlue))
        let saturation = maximumChannel > 0.001
            ? (maximumChannel - minimumChannel) / maximumChannel
            : 0
        guard sourceRed - sourceGreen <= maximumRedGreenImbalance,
              saturation <= maximumSaturation
        else {
            return nil
        }
        let sourceLuminance = luminance(sourceRed, sourceGreen, sourceBlue)
        let yellowExcess = max(0, (sourceRed + sourceGreen) * 0.5 - sourceBlue)
        let yellowCorrection = smoothstep(0.08, 0.14, yellowExcess)
        let localStrength = min(strength, 1) * maximumEffectiveStrength * yellowCorrection
        guard localStrength > 0.001 else {
            return nil
        }

        var nextRed = sourceRed + 0.018 * localStrength
        var nextGreen = sourceGreen + 0.018 * localStrength
        var nextBlue = sourceBlue
            + yellowExcess * yellowNeutralizationFactor * localStrength
        let desiredLuminance = min(0.94, sourceLuminance + 0.045 * localStrength)
        let correction = desiredLuminance - luminance(nextRed, nextGreen, nextBlue)
        nextRed += correction
        nextGreen += correction
        nextBlue += correction

        let target = BeautyTeethWhiteningTarget(
            red: byte(nextRed),
            green: byte(nextGreen),
            blue: byte(nextBlue)
        )
        guard target.red != red || target.green != green || target.blue != blue else {
            return nil
        }
        return target
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
