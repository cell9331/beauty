import Foundation
import BeautySDK

struct RenderCase {
    let id: String
    let displayName: String
    let parameters: BeautyParameters
}

let cases = [
    RenderCase(
        id: "skinSmoothing_0p50",
        displayName: "skinSmoothing 0.50",
        parameters: BeautyParameters(skinSmoothing: 0.50)
    ),
    RenderCase(
        id: "skinWhitening_0p50",
        displayName: "skinWhitening 0.50",
        parameters: BeautyParameters(skinWhitening: 0.50)
    ),
    RenderCase(
        id: "skinRosy_0p40",
        displayName: "skinRosy 0.40",
        parameters: BeautyParameters(skinRosy: 0.40)
    ),
    RenderCase(
        id: "skinSharpen_0p40",
        displayName: "skinSharpen 0.40",
        parameters: BeautyParameters(skinSharpen: 0.40)
    ),
    RenderCase(
        id: "brightness_plus0p25",
        displayName: "brightness +0.25",
        parameters: BeautyParameters(brightness: 0.25)
    ),
    RenderCase(
        id: "contrast_plus0p25",
        displayName: "contrast +0.25",
        parameters: BeautyParameters(contrast: 0.25)
    ),
    RenderCase(
        id: "filter_softClean_0p50",
        displayName: "filter soft_clean 0.50",
        parameters: BeautyParameters(filterId: "soft_clean", filterIntensity: 0.50)
    ),
    RenderCase(
        id: "filter_warmLight_0p50",
        displayName: "filter warm_light 0.50",
        parameters: BeautyParameters(filterId: "warm_light", filterIntensity: 0.50)
    ),
    RenderCase(
        id: "skinCombo_0p50",
        displayName: "skin combo 0.50",
        parameters: BeautyParameters(
            skinSmoothing: 0.50,
            skinWhitening: 0.50,
            skinRosy: 0.35,
            skinSharpen: 0.25
        )
    ),
    RenderCase(
        id: "geometryBaseline_noop",
        displayName: "geometry baseline noop",
        parameters: BeautyParameters()
    ),
    RenderCase(
        id: "faceShapeCombo_0p35",
        displayName: "face shape combo 0.35",
        parameters: BeautyParameters(
            faceSlim: 0.35,
            faceSmall: 0.30,
            faceVShape: 0.35,
            jawSlim: 0.30,
            chinLength: 0.20
        )
    ),
    RenderCase(
        id: "faceSlim_0p35",
        displayName: "faceSlim 0.35",
        parameters: BeautyParameters(faceSlim: 0.35)
    ),
    RenderCase(
        id: "faceSmall_0p35",
        displayName: "faceSmall 0.35",
        parameters: BeautyParameters(faceSmall: 0.35)
    ),
    RenderCase(
        id: "chinLength_plus0p30",
        displayName: "chinLength +0.30",
        parameters: BeautyParameters(chinLength: 0.30)
    ),
    RenderCase(
        id: "chinLength_minus0p30",
        displayName: "chinLength -0.30",
        parameters: BeautyParameters(chinLength: -0.30)
    ),
    RenderCase(
        id: "faceVShape_0p35",
        displayName: "faceVShape 0.35",
        parameters: BeautyParameters(faceVShape: 0.35)
    ),
    RenderCase(
        id: "jawSlim_0p35",
        displayName: "jawSlim 0.35",
        parameters: BeautyParameters(jawSlim: 0.35)
    ),
    RenderCase(
        id: "faceContourSmooth_0p25",
        displayName: "faceContourSmooth 0.25",
        parameters: BeautyParameters(faceContourSmooth: 0.25)
    ),
    RenderCase(
        id: "templeFullness_0p25",
        displayName: "templeFullness 0.25",
        parameters: BeautyParameters(templeFullness: 0.25)
    ),
    RenderCase(
        id: "cheekboneSlim_0p25",
        displayName: "cheekboneSlim 0.25",
        parameters: BeautyParameters(cheekboneSlim: 0.25)
    ),
    RenderCase(
        id: "chinTaper_0p25",
        displayName: "chinTaper 0.25",
        parameters: BeautyParameters(chinTaper: 0.25)
    ),
    RenderCase(
        id: "eyeSize_0p35",
        displayName: "eyeSize 0.35",
        parameters: BeautyParameters(eyeSize: 0.35)
    ),
    RenderCase(
        id: "eyeDistance_plus0p25",
        displayName: "eyeDistance +0.25",
        parameters: BeautyParameters(eyeDistance: 0.25)
    ),
    RenderCase(
        id: "eyeDistance_minus0p25",
        displayName: "eyeDistance -0.25",
        parameters: BeautyParameters(eyeDistance: -0.25)
    ),
    RenderCase(
        id: "eyeYPosition_plus0p20",
        displayName: "eyeYPosition +0.20",
        parameters: BeautyParameters(eyeYPosition: 0.20)
    ),
    RenderCase(
        id: "eyeYPosition_minus0p20",
        displayName: "eyeYPosition -0.20",
        parameters: BeautyParameters(eyeYPosition: -0.20)
    ),
    RenderCase(
        id: "eyeTailLift_0p25",
        displayName: "eyeTailLift 0.25",
        parameters: BeautyParameters(eyeTailLift: 0.25)
    ),
    RenderCase(
        id: "eyeHeight_0p25",
        displayName: "eyeHeight 0.25",
        parameters: BeautyParameters(eyeHeight: 0.25)
    ),
    RenderCase(
        id: "eyeLength_0p25",
        displayName: "eyeLength 0.25",
        parameters: BeautyParameters(eyeLength: 0.25)
    ),
    RenderCase(
        id: "upperEyelidLift_0p25",
        displayName: "upperEyelidLift 0.25",
        parameters: BeautyParameters(upperEyelidLift: 0.25)
    ),
    RenderCase(
        id: "pupilSize_0p25",
        displayName: "pupilSize 0.25",
        parameters: BeautyParameters(pupilSize: 0.25)
    ),
    RenderCase(
        id: "gazeCorrection_0p25",
        displayName: "gazeCorrection 0.25",
        parameters: BeautyParameters(gazeCorrection: 0.25)
    ),
    RenderCase(
        id: "lowerEyelidDrop_0p25",
        displayName: "lowerEyelidDrop 0.25",
        parameters: BeautyParameters(lowerEyelidDrop: 0.25)
    ),
    RenderCase(
        id: "eyeTilt_plus0p25",
        displayName: "eyeTilt +0.25",
        parameters: BeautyParameters(eyeTilt: 0.25)
    ),
    RenderCase(
        id: "eyeTilt_minus0p25",
        displayName: "eyeTilt -0.25",
        parameters: BeautyParameters(eyeTilt: -0.25)
    ),
    RenderCase(
        id: "innerCornerOpen_0p25",
        displayName: "innerCornerOpen 0.25",
        parameters: BeautyParameters(innerCornerOpen: 0.25)
    ),
    RenderCase(
        id: "outerCornerOpen_0p25",
        displayName: "outerCornerOpen 0.25",
        parameters: BeautyParameters(outerCornerOpen: 0.25)
    ),
    RenderCase(
        id: "eyeSymmetry_0p25",
        displayName: "eyeSymmetry 0.25",
        parameters: BeautyParameters(eyeSymmetry: 0.25)
    ),
    RenderCase(
        id: "eyebrowYPosition_plus0p25",
        displayName: "eyebrowYPosition +0.25",
        parameters: BeautyParameters(eyebrowYPosition: 0.25)
    ),
    RenderCase(
        id: "eyebrowYPosition_minus0p25",
        displayName: "eyebrowYPosition -0.25",
        parameters: BeautyParameters(eyebrowYPosition: -0.25)
    ),
    RenderCase(
        id: "eyebrowThickness_plus0p25",
        displayName: "eyebrowThickness +0.25",
        parameters: BeautyParameters(eyebrowThickness: 0.25)
    ),
    RenderCase(
        id: "eyebrowThickness_minus0p25",
        displayName: "eyebrowThickness -0.25",
        parameters: BeautyParameters(eyebrowThickness: -0.25)
    ),
    RenderCase(
        id: "eyebrowLength_plus0p25",
        displayName: "eyebrowLength +0.25",
        parameters: BeautyParameters(eyebrowLength: 0.25)
    ),
    RenderCase(
        id: "eyebrowLength_minus0p25",
        displayName: "eyebrowLength -0.25",
        parameters: BeautyParameters(eyebrowLength: -0.25)
    ),
    RenderCase(
        id: "eyebrowSpacing_plus0p25",
        displayName: "eyebrowSpacing +0.25",
        parameters: BeautyParameters(eyebrowSpacing: 0.25)
    ),
    RenderCase(
        id: "eyebrowSpacing_minus0p25",
        displayName: "eyebrowSpacing -0.25",
        parameters: BeautyParameters(eyebrowSpacing: -0.25)
    ),
    RenderCase(
        id: "eyebrowHeadSpacing_plus0p25",
        displayName: "eyebrowHeadSpacing +0.25",
        parameters: BeautyParameters(eyebrowHeadSpacing: 0.25)
    ),
    RenderCase(
        id: "eyebrowHeadSpacing_minus0p25",
        displayName: "eyebrowHeadSpacing -0.25",
        parameters: BeautyParameters(eyebrowHeadSpacing: -0.25)
    ),
    RenderCase(
        id: "eyebrowTilt_plus0p25",
        displayName: "eyebrowTilt +0.25",
        parameters: BeautyParameters(eyebrowTilt: 0.25)
    ),
    RenderCase(
        id: "eyebrowTilt_minus0p25",
        displayName: "eyebrowTilt -0.25",
        parameters: BeautyParameters(eyebrowTilt: -0.25)
    ),
    RenderCase(
        id: "eyebrowPeakDefinition_0p25",
        displayName: "eyebrowPeakDefinition 0.25",
        parameters: BeautyParameters(eyebrowPeakDefinition: 0.25)
    ),
    RenderCase(
        id: "noseSlim_0p35",
        displayName: "noseSlim 0.35",
        parameters: BeautyParameters(noseSlim: 0.35)
    ),
    RenderCase(
        id: "noseWingSlim_0p35",
        displayName: "noseWingSlim 0.35",
        parameters: BeautyParameters(noseWingSlim: 0.35)
    ),
    RenderCase(
        id: "noseTipSize_plus0p30",
        displayName: "noseTipSize +0.30",
        parameters: BeautyParameters(noseTipSize: 0.30)
    ),
    RenderCase(
        id: "noseTipSize_minus0p30",
        displayName: "noseTipSize -0.30",
        parameters: BeautyParameters(noseTipSize: -0.30)
    ),
    RenderCase(
        id: "noseBridge_0p30",
        displayName: "noseBridge 0.30",
        parameters: BeautyParameters(noseBridge: 0.30)
    ),
    RenderCase(
        id: "noseRootNarrowing_0p25",
        displayName: "noseRootNarrowing 0.25",
        parameters: BeautyParameters(noseRootNarrowing: 0.25)
    ),
    RenderCase(
        id: "noseTipLift_0p25",
        displayName: "noseTipLift 0.25",
        parameters: BeautyParameters(noseTipLift: 0.25)
    ),
    RenderCase(
        id: "mouthSize_plus0p35",
        displayName: "mouthSize +0.35",
        parameters: BeautyParameters(mouthSize: 0.35)
    ),
    RenderCase(
        id: "mouthSize_minus0p35",
        displayName: "mouthSize -0.35",
        parameters: BeautyParameters(mouthSize: -0.35)
    ),
    RenderCase(
        id: "mouthWidth_plus0p35",
        displayName: "mouthWidth +0.35",
        parameters: BeautyParameters(mouthWidth: 0.35)
    ),
    RenderCase(
        id: "mouthWidth_minus0p35",
        displayName: "mouthWidth -0.35",
        parameters: BeautyParameters(mouthWidth: -0.35)
    ),
    RenderCase(
        id: "smile_0p50",
        displayName: "smile 0.50",
        parameters: BeautyParameters(smile: 0.50)
    ),
    RenderCase(
        id: "lipColor_0p50",
        displayName: "lipColor 0.50",
        parameters: BeautyParameters(lipColor: 0.50)
    ),
    RenderCase(
        id: "mouthYPosition_plus0p25",
        displayName: "mouthYPosition +0.25",
        parameters: BeautyParameters(mouthYPosition: 0.25)
    ),
    RenderCase(
        id: "mouthYPosition_minus0p25",
        displayName: "mouthYPosition -0.25",
        parameters: BeautyParameters(mouthYPosition: -0.25)
    ),
    RenderCase(
        id: "mouthTilt_plus0p25",
        displayName: "mouthTilt +0.25",
        parameters: BeautyParameters(mouthTilt: 0.25)
    ),
    RenderCase(
        id: "mouthTilt_minus0p25",
        displayName: "mouthTilt -0.25",
        parameters: BeautyParameters(mouthTilt: -0.25)
    ),
    RenderCase(
        id: "mouthXPosition_plus0p25",
        displayName: "mouthXPosition +0.25",
        parameters: BeautyParameters(mouthXPosition: 0.25)
    ),
    RenderCase(
        id: "mouthXPosition_minus0p25",
        displayName: "mouthXPosition -0.25",
        parameters: BeautyParameters(mouthXPosition: -0.25)
    ),
    RenderCase(
        id: "lipPeakDefinition_0p25",
        displayName: "lipPeakDefinition 0.25",
        parameters: BeautyParameters(lipPeakDefinition: 0.25)
    ),
    RenderCase(
        id: "lipPlump_0p25",
        displayName: "lipPlump 0.25",
        parameters: BeautyParameters(lipPlump: 0.25)
    ),
    RenderCase(
        id: "teethWhitening_1p00",
        displayName: "teethWhitening 1.00",
        parameters: BeautyParameters(teethWhitening: 1)
    ),
    RenderCase(
        id: "scleraRednessReduction_1p00",
        displayName: "scleraRednessReduction 1.00",
        parameters: BeautyParameters(scleraRednessReduction: 1)
    )
]

let rendererOutcome = RendererCLI.run(arguments: Array(CommandLine.arguments.dropFirst()), cases: cases)
if !rendererOutcome.stdout.isEmpty {
    FileHandle.standardOutput.write(Data(rendererOutcome.stdout.utf8))
}
if let diagnostic = rendererOutcome.diagnostic {
    FileHandle.standardError.write(diagnostic.encodedLine)
    exit(1)
}
