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
    public var faceContourSmooth: Float
    public var templeFullness: Float
    public var cheekboneSlim: Float
    public var chinTaper: Float

    public var eyeSize: Float
    public var eyeDistance: Float
    public var eyeYPosition: Float
    public var eyeTailLift: Float
    public var eyeHeight: Float
    public var eyeLength: Float
    public var upperEyelidLift: Float
    public var pupilSize: Float
    public var gazeCorrection: Float
    public var lowerEyelidDrop: Float
    public var eyeTilt: Float
    public var innerCornerOpen: Float
    public var outerCornerOpen: Float
    public var eyeSymmetry: Float

    public var eyebrowYPosition: Float
    public var eyebrowThickness: Float
    public var eyebrowLength: Float
    public var eyebrowSpacing: Float
    public var eyebrowHeadSpacing: Float
    public var eyebrowTilt: Float
    public var eyebrowPeakDefinition: Float

    public var noseSlim: Float
    public var noseWingSlim: Float
    public var noseTipSize: Float
    public var noseBridge: Float
    public var noseRootNarrowing: Float
    public var noseTipLift: Float

    public var mouthSize: Float
    public var mouthWidth: Float
    public var smile: Float
    public var mouthYPosition: Float
    public var mouthTilt: Float
    public var mouthXPosition: Float
    public var lipPeakDefinition: Float
    public var lipPlump: Float
    public var lipColor: Float

    public var filterId: String?
    public var filterIntensity: Float
    public var teethWhitening: Float

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
        case faceContourSmooth
        case templeFullness
        case cheekboneSlim
        case chinTaper
        case eyeSize
        case eyeDistance
        case eyeYPosition
        case eyeTailLift
        case eyeHeight
        case eyeLength
        case upperEyelidLift
        case pupilSize
        case gazeCorrection
        case lowerEyelidDrop
        case eyeTilt
        case innerCornerOpen
        case outerCornerOpen
        case eyeSymmetry
        case eyebrowYPosition
        case eyebrowThickness
        case eyebrowLength
        case eyebrowSpacing
        case eyebrowHeadSpacing
        case eyebrowTilt
        case eyebrowPeakDefinition
        case noseSlim
        case noseWingSlim
        case noseTipSize
        case noseBridge
        case noseRootNarrowing
        case noseTipLift
        case mouthSize
        case mouthWidth
        case smile
        case mouthYPosition
        case mouthTilt
        case mouthXPosition
        case lipPeakDefinition
        case lipPlump
        case lipColor
        case filterId
        case filterIntensity
        case teethWhitening
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
        faceContourSmooth: Float = 0,
        templeFullness: Float = 0,
        cheekboneSlim: Float = 0,
        chinTaper: Float = 0,
        eyeSize: Float = 0,
        eyeDistance: Float = 0,
        eyeYPosition: Float = 0,
        eyeTailLift: Float = 0,
        eyeHeight: Float = 0,
        eyeLength: Float = 0,
        upperEyelidLift: Float = 0,
        pupilSize: Float = 0,
        gazeCorrection: Float = 0,
        lowerEyelidDrop: Float = 0,
        eyeTilt: Float = 0,
        innerCornerOpen: Float = 0,
        outerCornerOpen: Float = 0,
        eyeSymmetry: Float = 0,
        eyebrowYPosition: Float = 0,
        eyebrowThickness: Float = 0,
        eyebrowLength: Float = 0,
        eyebrowSpacing: Float = 0,
        eyebrowHeadSpacing: Float = 0,
        eyebrowTilt: Float = 0,
        eyebrowPeakDefinition: Float = 0,
        noseSlim: Float = 0,
        noseWingSlim: Float = 0,
        noseTipSize: Float = 0,
        noseBridge: Float = 0,
        noseRootNarrowing: Float = 0,
        noseTipLift: Float = 0,
        mouthSize: Float = 0,
        mouthWidth: Float = 0,
        smile: Float = 0,
        mouthYPosition: Float = 0,
        mouthTilt: Float = 0,
        mouthXPosition: Float = 0,
        lipPeakDefinition: Float = 0,
        lipPlump: Float = 0,
        lipColor: Float = 0,
        filterId: String? = nil,
        filterIntensity: Float = 0,
        teethWhitening: Float = 0
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
        self.faceContourSmooth = Self.clampUnit(faceContourSmooth)
        self.templeFullness = Self.clampUnit(templeFullness)
        self.cheekboneSlim = Self.clampUnit(cheekboneSlim)
        self.chinTaper = Self.clampUnit(chinTaper)

        self.eyeSize = Self.clampUnit(eyeSize)
        self.eyeDistance = Self.clampSigned(eyeDistance)
        self.eyeYPosition = Self.clampSigned(eyeYPosition)
        self.eyeTailLift = Self.clampUnit(eyeTailLift)
        self.eyeHeight = Self.clampUnit(eyeHeight)
        self.eyeLength = Self.clampUnit(eyeLength)
        self.upperEyelidLift = Self.clampUnit(upperEyelidLift)
        self.pupilSize = Self.clampUnit(pupilSize)
        self.gazeCorrection = Self.clampUnit(gazeCorrection)
        self.lowerEyelidDrop = Self.clampUnit(lowerEyelidDrop)
        self.eyeTilt = Self.clampSigned(eyeTilt)
        self.innerCornerOpen = Self.clampUnit(innerCornerOpen)
        self.outerCornerOpen = Self.clampUnit(outerCornerOpen)
        self.eyeSymmetry = Self.clampUnit(eyeSymmetry)

        self.eyebrowYPosition = Self.clampSigned(eyebrowYPosition)
        self.eyebrowThickness = Self.clampSigned(eyebrowThickness)
        self.eyebrowLength = Self.clampSigned(eyebrowLength)
        self.eyebrowSpacing = Self.clampSigned(eyebrowSpacing)
        self.eyebrowHeadSpacing = Self.clampSigned(eyebrowHeadSpacing)
        self.eyebrowTilt = Self.clampSigned(eyebrowTilt)
        self.eyebrowPeakDefinition = Self.clampUnit(eyebrowPeakDefinition)

        self.noseSlim = Self.clampUnit(noseSlim)
        self.noseWingSlim = Self.clampUnit(noseWingSlim)
        self.noseTipSize = Self.clampSigned(noseTipSize)
        self.noseBridge = Self.clampUnit(noseBridge)
        self.noseRootNarrowing = Self.clampUnit(noseRootNarrowing)
        self.noseTipLift = Self.clampUnit(noseTipLift)

        self.mouthSize = Self.clampSigned(mouthSize)
        self.mouthWidth = Self.clampSigned(mouthWidth)
        self.smile = Self.clampUnit(smile)
        self.mouthYPosition = Self.clampSigned(mouthYPosition)
        self.mouthTilt = Self.clampSigned(mouthTilt)
        self.mouthXPosition = Self.clampSigned(mouthXPosition)
        self.lipPeakDefinition = Self.clampUnit(lipPeakDefinition)
        self.lipPlump = Self.clampUnit(lipPlump)
        self.lipColor = Self.clampUnit(lipColor)

        self.filterId = filterId
        self.filterIntensity = Self.clampUnit(filterIntensity)
        self.teethWhitening = Self.clampUnit(teethWhitening)
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
            faceContourSmooth: try container.decodeFloatIfPresent(.faceContourSmooth),
            templeFullness: try container.decodeFloatIfPresent(.templeFullness),
            cheekboneSlim: try container.decodeFloatIfPresent(.cheekboneSlim),
            chinTaper: try container.decodeFloatIfPresent(.chinTaper),
            eyeSize: try container.decodeFloatIfPresent(.eyeSize),
            eyeDistance: try container.decodeFloatIfPresent(.eyeDistance),
            eyeYPosition: try container.decodeFloatIfPresent(.eyeYPosition),
            eyeTailLift: try container.decodeFloatIfPresent(.eyeTailLift),
            eyeHeight: try container.decodeFloatIfPresent(.eyeHeight),
            eyeLength: try container.decodeFloatIfPresent(.eyeLength),
            upperEyelidLift: try container.decodeFloatIfPresent(.upperEyelidLift),
            pupilSize: try container.decodeFloatIfPresent(.pupilSize),
            gazeCorrection: try container.decodeFloatIfPresent(.gazeCorrection),
            lowerEyelidDrop: try container.decodeFloatIfPresent(.lowerEyelidDrop),
            eyeTilt: try container.decodeFloatIfPresent(.eyeTilt),
            innerCornerOpen: try container.decodeFloatIfPresent(.innerCornerOpen),
            outerCornerOpen: try container.decodeFloatIfPresent(.outerCornerOpen),
            eyeSymmetry: try container.decodeFloatIfPresent(.eyeSymmetry),
            eyebrowYPosition: try container.decodeFloatIfPresent(.eyebrowYPosition),
            eyebrowThickness: try container.decodeFloatIfPresent(.eyebrowThickness),
            eyebrowLength: try container.decodeFloatIfPresent(.eyebrowLength),
            eyebrowSpacing: try container.decodeFloatIfPresent(.eyebrowSpacing),
            eyebrowHeadSpacing: try container.decodeFloatIfPresent(.eyebrowHeadSpacing),
            eyebrowTilt: try container.decodeFloatIfPresent(.eyebrowTilt),
            eyebrowPeakDefinition: try container.decodeFloatIfPresent(.eyebrowPeakDefinition),
            noseSlim: try container.decodeFloatIfPresent(.noseSlim),
            noseWingSlim: try container.decodeFloatIfPresent(.noseWingSlim),
            noseTipSize: try container.decodeFloatIfPresent(.noseTipSize),
            noseBridge: try container.decodeFloatIfPresent(.noseBridge),
            noseRootNarrowing: try container.decodeFloatIfPresent(.noseRootNarrowing),
            noseTipLift: try container.decodeFloatIfPresent(.noseTipLift),
            mouthSize: try container.decodeFloatIfPresent(.mouthSize),
            mouthWidth: try container.decodeFloatIfPresent(.mouthWidth),
            smile: try container.decodeFloatIfPresent(.smile),
            mouthYPosition: try container.decodeFloatIfPresent(.mouthYPosition),
            mouthTilt: try container.decodeFloatIfPresent(.mouthTilt),
            mouthXPosition: try container.decodeFloatIfPresent(.mouthXPosition),
            lipPeakDefinition: try container.decodeFloatIfPresent(.lipPeakDefinition),
            lipPlump: try container.decodeFloatIfPresent(.lipPlump),
            lipColor: try container.decodeFloatIfPresent(.lipColor),
            filterId: try container.decodeIfPresent(String.self, forKey: .filterId),
            filterIntensity: try container.decodeFloatIfPresent(.filterIntensity),
            teethWhitening: try container.decodeFloatIfPresent(.teethWhitening)
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
            faceContourSmooth: faceContourSmooth,
            templeFullness: templeFullness,
            cheekboneSlim: cheekboneSlim,
            chinTaper: chinTaper,
            eyeSize: eyeSize,
            eyeDistance: eyeDistance,
            eyeYPosition: eyeYPosition,
            eyeTailLift: eyeTailLift,
            eyeHeight: eyeHeight,
            eyeLength: eyeLength,
            upperEyelidLift: upperEyelidLift,
            pupilSize: pupilSize,
            gazeCorrection: gazeCorrection,
            lowerEyelidDrop: lowerEyelidDrop,
            eyeTilt: eyeTilt,
            innerCornerOpen: innerCornerOpen,
            outerCornerOpen: outerCornerOpen,
            eyeSymmetry: eyeSymmetry,
            eyebrowYPosition: eyebrowYPosition,
            eyebrowThickness: eyebrowThickness,
            eyebrowLength: eyebrowLength,
            eyebrowSpacing: eyebrowSpacing,
            eyebrowHeadSpacing: eyebrowHeadSpacing,
            eyebrowTilt: eyebrowTilt,
            eyebrowPeakDefinition: eyebrowPeakDefinition,
            noseSlim: noseSlim,
            noseWingSlim: noseWingSlim,
            noseTipSize: noseTipSize,
            noseBridge: noseBridge,
            noseRootNarrowing: noseRootNarrowing,
            noseTipLift: noseTipLift,
            mouthSize: mouthSize,
            mouthWidth: mouthWidth,
            smile: smile,
            mouthYPosition: mouthYPosition,
            mouthTilt: mouthTilt,
            mouthXPosition: mouthXPosition,
            lipPeakDefinition: lipPeakDefinition,
            lipPlump: lipPlump,
            lipColor: lipColor,
            filterId: filterId,
            filterIntensity: filterIntensity,
            teethWhitening: teethWhitening
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
