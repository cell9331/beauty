public struct BeautyParameters: Codable, Equatable, Sendable {
    public var skinSmoothing: Float
    public var skinWhitening: Float
    public var skinRosy: Float
    public var skinSharpen: Float

    public var brightness: Float
    public var contrast: Float
    public var saturation: Float
    public var temperature: Float
    public var tint: Float
    public var exposure: Float
    public var highlight: Float
    public var shadow: Float

    public var faceSlim: Float
    public var faceSmall: Float
    public var faceVShape: Float
    public var jawSlim: Float
    public var chinLength: Float

    public var eyeSize: Float
    public var eyeDistance: Float
    public var eyeYPosition: Float
    public var eyeTailLift: Float

    public var noseSlim: Float
    public var noseWingSlim: Float
    public var noseTipSize: Float
    public var noseBridge: Float

    public var mouthSize: Float
    public var mouthWidth: Float
    public var smile: Float
    public var lipColor: Float

    public var filterId: String?
    public var filterIntensity: Float

    enum CodingKeys: String, CodingKey {
        case skinSmoothing
        case skinWhitening
        case skinRosy
        case skinSharpen
        case brightness
        case contrast
        case saturation
        case temperature
        case tint
        case exposure
        case highlight
        case shadow
        case faceSlim
        case faceSmall
        case faceVShape
        case jawSlim
        case chinLength
        case eyeSize
        case eyeDistance
        case eyeYPosition
        case eyeTailLift
        case noseSlim
        case noseWingSlim
        case noseTipSize
        case noseBridge
        case mouthSize
        case mouthWidth
        case smile
        case lipColor
        case filterId
        case filterIntensity
    }

    public init(
        skinSmoothing: Float = 0,
        skinWhitening: Float = 0,
        skinRosy: Float = 0,
        skinSharpen: Float = 0,
        brightness: Float = 0,
        contrast: Float = 0,
        saturation: Float = 0,
        temperature: Float = 0,
        tint: Float = 0,
        exposure: Float = 0,
        highlight: Float = 0,
        shadow: Float = 0,
        faceSlim: Float = 0,
        faceSmall: Float = 0,
        faceVShape: Float = 0,
        jawSlim: Float = 0,
        chinLength: Float = 0,
        eyeSize: Float = 0,
        eyeDistance: Float = 0,
        eyeYPosition: Float = 0,
        eyeTailLift: Float = 0,
        noseSlim: Float = 0,
        noseWingSlim: Float = 0,
        noseTipSize: Float = 0,
        noseBridge: Float = 0,
        mouthSize: Float = 0,
        mouthWidth: Float = 0,
        smile: Float = 0,
        lipColor: Float = 0,
        filterId: String? = nil,
        filterIntensity: Float = 0
    ) {
        self.skinSmoothing = Self.clampUnit(skinSmoothing)
        self.skinWhitening = Self.clampUnit(skinWhitening)
        self.skinRosy = Self.clampUnit(skinRosy)
        self.skinSharpen = Self.clampUnit(skinSharpen)

        self.brightness = Self.clampSigned(brightness)
        self.contrast = Self.clampSigned(contrast)
        self.saturation = Self.clampSigned(saturation)
        self.temperature = Self.clampSigned(temperature)
        self.tint = Self.clampSigned(tint)
        self.exposure = Self.clampSigned(exposure)
        self.highlight = Self.clampSigned(highlight)
        self.shadow = Self.clampSigned(shadow)

        self.faceSlim = Self.clampUnit(faceSlim)
        self.faceSmall = Self.clampUnit(faceSmall)
        self.faceVShape = Self.clampUnit(faceVShape)
        self.jawSlim = Self.clampUnit(jawSlim)
        self.chinLength = Self.clampSigned(chinLength)

        self.eyeSize = Self.clampSigned(eyeSize)
        self.eyeDistance = Self.clampSigned(eyeDistance)
        self.eyeYPosition = Self.clampSigned(eyeYPosition)
        self.eyeTailLift = Self.clampSigned(eyeTailLift)

        self.noseSlim = Self.clampUnit(noseSlim)
        self.noseWingSlim = Self.clampUnit(noseWingSlim)
        self.noseTipSize = Self.clampSigned(noseTipSize)
        self.noseBridge = Self.clampUnit(noseBridge)

        self.mouthSize = Self.clampSigned(mouthSize)
        self.mouthWidth = Self.clampSigned(mouthWidth)
        self.smile = Self.clampUnit(smile)
        self.lipColor = Self.clampUnit(lipColor)

        self.filterId = filterId
        self.filterIntensity = Self.clampUnit(filterIntensity)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            skinSmoothing: try container.decodeFloatIfPresent(.skinSmoothing),
            skinWhitening: try container.decodeFloatIfPresent(.skinWhitening),
            skinRosy: try container.decodeFloatIfPresent(.skinRosy),
            skinSharpen: try container.decodeFloatIfPresent(.skinSharpen),
            brightness: try container.decodeFloatIfPresent(.brightness),
            contrast: try container.decodeFloatIfPresent(.contrast),
            saturation: try container.decodeFloatIfPresent(.saturation),
            temperature: try container.decodeFloatIfPresent(.temperature),
            tint: try container.decodeFloatIfPresent(.tint),
            exposure: try container.decodeFloatIfPresent(.exposure),
            highlight: try container.decodeFloatIfPresent(.highlight),
            shadow: try container.decodeFloatIfPresent(.shadow),
            faceSlim: try container.decodeFloatIfPresent(.faceSlim),
            faceSmall: try container.decodeFloatIfPresent(.faceSmall),
            faceVShape: try container.decodeFloatIfPresent(.faceVShape),
            jawSlim: try container.decodeFloatIfPresent(.jawSlim),
            chinLength: try container.decodeFloatIfPresent(.chinLength),
            eyeSize: try container.decodeFloatIfPresent(.eyeSize),
            eyeDistance: try container.decodeFloatIfPresent(.eyeDistance),
            eyeYPosition: try container.decodeFloatIfPresent(.eyeYPosition),
            eyeTailLift: try container.decodeFloatIfPresent(.eyeTailLift),
            noseSlim: try container.decodeFloatIfPresent(.noseSlim),
            noseWingSlim: try container.decodeFloatIfPresent(.noseWingSlim),
            noseTipSize: try container.decodeFloatIfPresent(.noseTipSize),
            noseBridge: try container.decodeFloatIfPresent(.noseBridge),
            mouthSize: try container.decodeFloatIfPresent(.mouthSize),
            mouthWidth: try container.decodeFloatIfPresent(.mouthWidth),
            smile: try container.decodeFloatIfPresent(.smile),
            lipColor: try container.decodeFloatIfPresent(.lipColor),
            filterId: try container.decodeIfPresent(String.self, forKey: .filterId),
            filterIntensity: try container.decodeFloatIfPresent(.filterIntensity)
        )
    }

    public func normalized() -> BeautyParameters {
        BeautyParameters(
            skinSmoothing: skinSmoothing,
            skinWhitening: skinWhitening,
            skinRosy: skinRosy,
            skinSharpen: skinSharpen,
            brightness: brightness,
            contrast: contrast,
            saturation: saturation,
            temperature: temperature,
            tint: tint,
            exposure: exposure,
            highlight: highlight,
            shadow: shadow,
            faceSlim: faceSlim,
            faceSmall: faceSmall,
            faceVShape: faceVShape,
            jawSlim: jawSlim,
            chinLength: chinLength,
            eyeSize: eyeSize,
            eyeDistance: eyeDistance,
            eyeYPosition: eyeYPosition,
            eyeTailLift: eyeTailLift,
            noseSlim: noseSlim,
            noseWingSlim: noseWingSlim,
            noseTipSize: noseTipSize,
            noseBridge: noseBridge,
            mouthSize: mouthSize,
            mouthWidth: mouthWidth,
            smile: smile,
            lipColor: lipColor,
            filterId: filterId,
            filterIntensity: filterIntensity
        )
    }

    private static func clampUnit(_ value: Float) -> Float {
        clampFinite(value, lower: 0, upper: 1)
    }

    private static func clampSigned(_ value: Float) -> Float {
        clampFinite(value, lower: -1, upper: 1)
    }

    private static func clampFinite(_ value: Float, lower: Float, upper: Float) -> Float {
        guard value.isFinite else {
            return 0
        }
        return min(max(value, lower), upper)
    }
}

private extension KeyedDecodingContainer where K == BeautyParameters.CodingKeys {
    func decodeFloatIfPresent(_ key: BeautyParameters.CodingKeys) throws -> Float {
        try decodeIfPresent(Float.self, forKey: key) ?? 0
    }
}
