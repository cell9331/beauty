import Foundation

package struct BeautyFullScleraRednessTarget: Equatable, Sendable {
    package let red: UInt8
    package let green: UInt8
    package let blue: UInt8
}

/// Layered full-sclera correction derived from one immutable source pixel.
///
/// The provider supplies a low broad weight for eligible sclera and raises the
/// weight around material red excess. This transform therefore owns only the
/// bounded color target; the composition owner applies the mask exactly once.
package enum BeautyFullScleraRednessTransform {
    package static let maximumEffectiveStrength: Float = 1
    package static let maximumLuminanceDelta: Float = 0.028
    package static let maximumChannelDelta: Float = 0.17
    package static let maximumEligibleSaturation: Float = 0.48

    package static func target(
        red: UInt8,
        green: UInt8,
        blue: UInt8,
        strength: Float
    ) -> BeautyFullScleraRednessTarget? {
        guard strength.isFinite, strength > 0 else { return nil }

        let sourceRed = Float(red) / 255
        let sourceGreen = Float(green) / 255
        let sourceBlue = Float(blue) / 255
        let sourceLuminance = luminance(sourceRed, sourceGreen, sourceBlue)
        guard sourceLuminance > 0.18, sourceLuminance < 0.95 else { return nil }
        let maximum = max(sourceRed, max(sourceGreen, sourceBlue))
        let minimum = min(sourceRed, min(sourceGreen, sourceBlue))
        let saturation = maximum > 0.001 ? (maximum - minimum) / maximum : 0
        guard saturation <= maximumEligibleSaturation else { return nil }

        let localStrength = min(strength, 1) * maximumEffectiveStrength
        let redExcess = max(0, sourceRed - 0.83 * sourceGreen - 0.17 * sourceBlue)

        var nextRed = sourceRed - redExcess * 0.76 * localStrength
        var nextGreen = sourceGreen + redExcess * 0.08 * localStrength
        var nextBlue = sourceBlue + redExcess * 0.13 * localStrength

        // The broad layer supplies a restrained whitening cue even on neutral
        // sclera. Because it is applied through the provider's low soft weight,
        // texture and local luminance variation remain source-derived.
        let desiredLuminance = min(
            0.94,
            sourceLuminance + maximumLuminanceDelta * localStrength
        )
        let luminanceCorrection = desiredLuminance - luminance(nextRed, nextGreen, nextBlue)
        nextRed += luminanceCorrection
        nextGreen += luminanceCorrection
        nextBlue += luminanceCorrection

        nextRed = bounded(nextRed, around: sourceRed)
        nextGreen = bounded(nextGreen, around: sourceGreen)
        nextBlue = bounded(nextBlue, around: sourceBlue)

        let target = BeautyFullScleraRednessTarget(
            red: byte(nextRed),
            green: byte(nextGreen),
            blue: byte(nextBlue)
        )
        guard target.red != red || target.green != green || target.blue != blue else {
            return nil
        }
        return target
    }

    private static func bounded(_ value: Float, around source: Float) -> Float {
        min(source + maximumChannelDelta, max(source - maximumChannelDelta, value))
    }

    private static func luminance(_ red: Float, _ green: Float, _ blue: Float) -> Float {
        0.2126 * red + 0.7152 * green + 0.0722 * blue
    }

    private static func byte(_ value: Float) -> UInt8 {
        UInt8((min(1, max(0, value)) * 255).rounded(.toNearestOrAwayFromZero))
    }
}
