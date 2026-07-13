import BeautyCore

public struct BeautyEffectPlan: Equatable, Sendable {
    public let activeDomains: Set<BeautyEffectDomain>
    public let skippedDomains: Set<BeautyEffectDomain>
    public let warnings: [BeautyValidationWarning]
    public let metrics: [String: Double]
    public let effectiveStrengths: BeautyEffectiveStrengths

    public init(
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

public struct BeautyEffectiveStrengths: Equatable, Sendable {
    public var skinSmoothing: Float = 0
    public var skinWhitening: Float = 0
    public var skinRosy: Float = 0
    public var skinSharpen: Float = 0
    public var brightness: Float = 0
    public var contrast: Float = 0
    public var saturation: Float = 0
    public var temperature: Float = 0
    public var tint: Float = 0
    public var exposure: Float = 0
    public var highlight: Float = 0
    public var shadow: Float = 0
    public var filterIntensity: Float = 0
    public var faceSlim: Float = 0
    public var faceSmall: Float = 0
    public var faceVShape: Float = 0
    public var jawSlim: Float = 0
    public var chinLength: Float = 0
    public var eyeSize: Float = 0
    public var eyeDistance: Float = 0
    public var eyeYPosition: Float = 0
    public var eyeTailLift: Float = 0
    public var noseSlim: Float = 0
    public var noseWingSlim: Float = 0
    public var noseTipSize: Float = 0
    public var noseBridge: Float = 0
    public var noseRootNarrowing: Float = 0
    public var noseTipLift: Float = 0
    public var mouthSize: Float = 0
    public var mouthWidth: Float = 0
    public var smile: Float = 0
    public var lipColor: Float = 0

    public init() {}
}
