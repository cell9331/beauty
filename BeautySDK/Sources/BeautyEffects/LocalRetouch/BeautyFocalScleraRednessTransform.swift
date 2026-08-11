import Foundation

package struct BeautyFocalScleraRednessTarget: Equatable, Sendable {
    package let red: UInt8
    package let green: UInt8
    package let blue: UInt8
}

package enum BeautyFocalScleraRednessTransform {
    package static let maximumEffectiveStrength: Float = 1
    package static let maximumLuminanceDelta: Float = 0.018
    private static let minimumMaterialRedExcess: Float = 0.045

    /// Derives a bounded target from one immutable canonical source triplet.
    /// The caller leaves soft-weight application to the Q16 composition owner.
    package static func target(
        red: UInt8,
        green: UInt8,
        blue: UInt8,
        strength: Float
    ) -> BeautyFocalScleraRednessTarget? {
        guard strength.isFinite, strength > 0 else { return nil }

        let sourceRed = Float(red) / 255
        let sourceGreen = Float(green) / 255
        let sourceBlue = Float(blue) / 255
        let sourceLuminance = luminance(sourceRed, sourceGreen, sourceBlue)
        let redExcess = max(0, sourceRed - 0.83 * sourceGreen - 0.17 * sourceBlue)
        guard redExcess > minimumMaterialRedExcess else { return nil }
        // The provider mask already owns the graded material-redness weight.
        // Do not apply a second smoothstep here: composition applies that mask
        // exactly once through its Q16 soft weight.
        let localStrength = min(strength, 1) * maximumEffectiveStrength

        var nextRed = sourceRed - redExcess * 0.76 * localStrength
        var nextGreen = sourceGreen + redExcess * 0.08 * localStrength
        var nextBlue = sourceBlue + redExcess * 0.13 * localStrength
        let rawLuminance = luminance(nextRed, nextGreen, nextBlue)
        // Teeth whitening uses a much larger lift; sclera correction borrows
        // only the bounded visibility cue and keeps it below the established
        // 0.018 naturalness ceiling.
        let desiredLuminance = min(
            0.94,
            sourceLuminance + maximumLuminanceDelta * localStrength
        )
        let luminanceCorrection = desiredLuminance - rawLuminance
        nextRed += luminanceCorrection
        nextGreen += luminanceCorrection
        nextBlue += luminanceCorrection

        let result = BeautyFocalScleraRednessTarget(
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

    private static func byte(_ value: Float) -> UInt8 {
        UInt8((min(1, max(0, value)) * 255).rounded(.toNearestOrAwayFromZero))
    }
}
