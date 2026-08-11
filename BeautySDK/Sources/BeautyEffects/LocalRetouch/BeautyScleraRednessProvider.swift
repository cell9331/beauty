import BeautyCore
import BeautyDetection

/// Stable still-image entry point for the product-facing sclera-redness effect.
///
/// The concrete strategy stays private so the retained focal implementation
/// and the full-sclera implementation can be reviewed independently without
/// changing the public `scleraRednessReduction` parameter.
package enum BeautyScleraRednessProvider {
    package static func makeResult(
        source: BeautyCanonicalStillImage,
        eyeSupport: [BeautyObservedEyeSupport]?,
        eyeOrder: BeautyObservedEyeOrder?,
        strength: Float,
        owner: BeautyLocalRetouchCompositionOwner
    ) -> BeautyScleraRednessProviderResult {
        BeautyFullScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: eyeSupport,
            eyeOrder: eyeOrder,
            strength: strength,
            owner: owner
        )
    }
}
