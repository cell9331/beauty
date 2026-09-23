import Foundation
import BeautySDK

enum RepairedControlCompatibilityFixture {
    static let fieldNames = [
        "skinSmoothing", "skinWhitening", "skinRosy", "skinSharpen", "brightness", "contrast",
        "saturation", "temperature", "tint", "exposure", "highlight", "shadow", "faceSlim",
        "faceSmall", "faceVShape", "jawSlim", "chinLength", "faceContourSmooth", "templeFullness",
        "cheekboneSlim", "chinTaper", "eyeSize", "eyeDistance", "eyeYPosition", "eyeTailLift",
        "eyeHeight", "eyeLength", "upperEyelidLift", "pupilSize", "gazeCorrection", "lowerEyelidDrop",
        "eyeTilt", "innerCornerOpen", "outerCornerOpen", "eyeSymmetry", "eyebrowYPosition",
        "eyebrowThickness", "eyebrowLength", "eyebrowSpacing", "eyebrowHeadSpacing", "eyebrowTilt",
        "eyebrowPeakDefinition", "noseSlim", "noseWingSlim", "noseTipSize", "noseBridge",
        "noseRootNarrowing", "noseTipLift", "mouthSize", "mouthWidth", "smile", "mouthYPosition",
        "mouthTilt", "mouthXPosition", "lipPeakDefinition", "lipPlump", "lipColor", "filterId",
        "filterIntensity", "teethWhitening", "scleraRednessReduction", "upperEyelidFullnessReduction"
    ]
    static let presetIDs = ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
    static let rendererCases = [
        "skinSmoothing_0p50", "skinWhitening_0p50", "skinRosy_0p40", "skinSharpen_0p40",
        "brightness_plus0p25", "contrast_plus0p25", "filter_softClean_0p50", "filter_warmLight_0p50",
        "skinCombo_0p50", "geometryBaseline_noop", "faceShapeCombo_0p35", "faceSlim_0p35",
        "faceSmall_0p35", "chinLength_plus0p30", "chinLength_minus0p30", "faceVShape_0p35",
        "jawSlim_0p35", "faceContourSmooth_0p25", "templeFullness_0p25", "cheekboneSlim_0p25",
        "chinTaper_0p25", "eyeSize_0p35", "eyeDistance_plus0p25", "eyeDistance_minus0p25",
        "eyeYPosition_plus0p20", "eyeYPosition_minus0p20", "eyeTailLift_0p25", "eyeHeight_0p25",
        "eyeLength_0p25", "upperEyelidLift_0p25", "pupilSize_0p25", "gazeCorrection_0p25",
        "lowerEyelidDrop_0p25", "eyeTilt_plus0p25", "eyeTilt_minus0p25", "innerCornerOpen_0p25",
        "outerCornerOpen_0p25", "eyeSymmetry_0p25", "eyebrowYPosition_plus0p25", "eyebrowYPosition_minus0p25",
        "eyebrowThickness_plus0p25", "eyebrowThickness_minus0p25", "eyebrowLength_plus0p25", "eyebrowLength_minus0p25",
        "eyebrowSpacing_plus0p25", "eyebrowSpacing_minus0p25", "eyebrowHeadSpacing_plus0p25", "eyebrowHeadSpacing_minus0p25",
        "eyebrowTilt_plus0p25", "eyebrowTilt_minus0p25", "eyebrowPeakDefinition_0p25", "noseSlim_0p35",
        "noseWingSlim_0p35", "noseTipSize_plus0p30", "noseTipSize_minus0p30", "noseBridge_0p30",
        "noseRootNarrowing_0p25", "noseTipLift_0p25", "mouthSize_plus0p35", "mouthSize_minus0p35",
        "mouthWidth_plus0p35", "mouthWidth_minus0p35", "smile_0p50", "lipColor_0p50",
        "mouthYPosition_plus0p25", "mouthYPosition_minus0p25", "mouthTilt_plus0p25", "mouthTilt_minus0p25",
        "mouthXPosition_plus0p25", "mouthXPosition_minus0p25", "lipPeakDefinition_0p25", "lipPlump_0p25",
        "teethWhitening_1p00", "scleraRednessReduction_1p00", "upperEyelidFullnessReduction_1p00"
    ]
}
