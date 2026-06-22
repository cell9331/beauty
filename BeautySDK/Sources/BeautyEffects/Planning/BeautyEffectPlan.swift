import BeautyCore

struct BeautyEffectPlan: Equatable, Sendable {
    let activeDomains: Set<BeautyEffectDomain>
    let skippedDomains: Set<BeautyEffectDomain>
    let warnings: [BeautyValidationWarning]
    let metrics: [String: Double]
    let effectiveStrengths: BeautyEffectiveStrengths

    init(
        activeDomains: Set<BeautyEffectDomain> = [],
        skippedDomains: Set<BeautyEffectDomain> = [],
        warnings: [BeautyValidationWarning] = [],
        metrics: [String: Double] = [:],
        effectiveStrengths: BeautyEffectiveStrengths = BeautyEffectiveStrengths()
    ) {
        self.activeDomains = activeDomains
        self.skippedDomains = skippedDomains
        self.warnings = warnings
        self.metrics = metrics
        self.effectiveStrengths = effectiveStrengths
    }
}

struct BeautyEffectiveStrengths: Equatable, Sendable {
    var skinSmoothing: Float = 0
    var skinWhitening: Float = 0
    var skinRosy: Float = 0
    var skinSharpen: Float = 0
    var brightness: Float = 0
    var contrast: Float = 0
    var saturation: Float = 0
    var temperature: Float = 0
    var tint: Float = 0
    var exposure: Float = 0
    var highlight: Float = 0
    var shadow: Float = 0
    var filterIntensity: Float = 0
    var faceSlim: Float = 0
    var faceSmall: Float = 0
    var faceVShape: Float = 0
    var jawSlim: Float = 0
    var chinLength: Float = 0
    var eyeSize: Float = 0
    var eyeDistance: Float = 0
    var eyeYPosition: Float = 0
    var eyeTailLift: Float = 0
    var noseSlim: Float = 0
    var noseWingSlim: Float = 0
    var noseTipSize: Float = 0
    var noseBridge: Float = 0
    var mouthSize: Float = 0
    var mouthWidth: Float = 0
    var smile: Float = 0
    var lipColor: Float = 0
}
