# 06. BeautyParameters Reference

BeautyParameters parameter table

1. Documentation goals

This document defines the parameter model from the first version to the full version of the iOS Beauty SDK.

This document is used for constraints:

SDK external API
SwiftUI parameter slider
Default JSON
Algorithm module
Metal Shader Uniform
test case
Version compatible

Core principles:

1. Parameter naming must be stable.
2. The default value of the parameter must be in a no-effect state.
3. The App UI can display 0~100, but the SDK uses Float internally.
4. All parameters must be Codable.
5. Parameters not implemented in the first version can be reserved, but do not take effect by default.
6. The intensity parameters must have a safe upper limit to prevent the effect from getting out of control.

⸻

2. Parameter range specifications

2.1 SDK internal scope

Float is used uniformly within the SDK.

Enhanced parameters

Used for functions that only enhance, not reversely adjust.

Range: 0.0 ... 1.0
Default: 0.0

For example:

skinSmoothing
skinWhitening
skinRosy
faceSlim
noseSlim
filterIntensity

Bidirectional adjustment parameters

Used for functions that can be made smaller or larger.

Range: -1.0 ... 1.0
Default: 0.0

For example:

eyeSize
mouthSize
chinLength
eyeDistance
eyeYPosition
mouthWidth

Enum / ID parameters

Used to select resources or patterns.

String?
Enum
Bool

For example:

filterId
makeupId
presetId

⸻

2.2 UI display range

App UI does not directly expose SDK internal scopes.

Recommended UI display:

Enhanced parameters: 0 ... 100
Bidirectional parameters: -100 ... 100

Conversion rules:

// UI 0...100 -> SDK 0...1
let sdkValue = uiValue / 100.0
// UI -100...100 -> SDK -1...1
let sdkValue = uiValue / 100.0

⸻

2.3 Parameter default values

All beauty parameters must indicate "no effect" by default.

Float：0.0
String?：nil
Bool: false unless the documentation explicitly states otherwise
Enum：default / none / natural

Disable strong effects by default.

⸻

3. The first version of BeautyParameters structure

The first version recommended defining MVP parameters first.

public struct BeautyParameters: Codable, Equatable, Sendable {
    // MARK: - Skin
    public var skinSmoothing: Float
    public var skinWhitening: Float
    public var skinRosy: Float
    public var skinSharpen: Float
    // MARK: - Face Shape
    public var faceSlim: Float
    public var faceSmall: Float
    public var faceVShape: Float
    public var jawSlim: Float
    public var chinLength: Float
    // MARK: - Eyes
    public var eyeSize: Float
    public var eyeDistance: Float
    public var eyeYPosition: Float
    public var eyeTailLift: Float
    // MARK: - Nose
    public var noseSlim: Float
    public var noseWingSlim: Float
    public var noseTipSize: Float
    public var noseBridge: Float
    // MARK: - Mouth
    public var mouthSize: Float
    public var mouthWidth: Float
    public var smile: Float
    public var lipColor: Float
    // MARK: - Filter
    public var filterId: String?
    public var filterIntensity: Float
    public init(
        skinSmoothing: Float = 0,
        skinWhitening: Float = 0,
        skinRosy: Float = 0,
        skinSharpen: Float = 0,
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
        self.skinSmoothing = skinSmoothing
        self.skinWhitening = skinWhitening
        self.skinRosy = skinRosy
        self.skinSharpen = skinSharpen
        self.faceSlim = faceSlim
        self.faceSmall = faceSmall
        self.faceVShape = faceVShape
        self.jawSlim = jawSlim
        self.chinLength = chinLength
        self.eyeSize = eyeSize
        self.eyeDistance = eyeDistance
        self.eyeYPosition = eyeYPosition
        self.eyeTailLift = eyeTailLift
        self.noseSlim = noseSlim
        self.noseWingSlim = noseWingSlim
        self.noseTipSize = noseTipSize
        self.noseBridge = noseBridge
        self.mouthSize = mouthSize
        self.mouthWidth = mouthWidth
        self.smile = smile
        self.lipColor = lipColor
        self.filterId = filterId
        self.filterIntensity = filterIntensity
    }
}

⸻

4. Parameter list: MVP version

4.1 Skin: Basic skin beauty

Parameter name Chinese name Type SDK scope UI scope Default value Whether to rely on face or not Real-time Performance impact Algorithm module version
skinSmoothing Float 0…1 0…100 0 No, it is recommended to rely on skin mask in the future Yes Medium SkinSmoothEffect 1.0
skinWhitening Whitening Float 0…1 0…100 0 No, it is recommended to rely on skin mask in the future Yes Low SkinWhitenEffect 1.0
skinRosy Float 0…1 0…100 0 No, it is recommended to rely on skin mask in the future Yes Low SkinRosyEffect 1.0
skinSharpen Clear / Sharpen Float 0…1 0…100 0 No Yes Low SkinSharpenEffect / ColorAdjustmentEffect 1.0

Parameter description

skinSmoothing

Effect: Smooth skin, reduce pores, minor fine lines and noise.

First version implementation:

Edge protection blur
Low frequency smoothing
High frequency details added back

Subsequent enhancements:

skin mask
facial features protection mask
Advanced bilateral / guided filter

Note:

If the intensity is too high, a plastic face will appear.
The first version suggested that the upper limit of actual effective strength should not exceed 0.6.

skinWhitening

Function: Improves the brightness of skin color and makes skin cleaner.

Note:

You cannot directly increase the brightness of the entire image.
Protect the highlights and avoid overexposure of the face.
Subsequent changes should only take effect on the skin mask area.

skinRosy

Function: Increase facial complexion.

Note:

The blush should be applied lightly to areas of skin tone.
Lips, clothes, and backgrounds should not be visibly reddened.

skinSharpen

Function: Improve image clarity.

Note:

Sharpening should be done after dermabrasion.
Avoid sharpening noise and skin imperfections.

⸻

4.2 Face Shape: Face shape adjustment

Parameter name Chinese name Type SDK scope UI scope Default value Whether to rely on face or not Real-time Performance impact Algorithm module version
faceSlim Face Slim Float 0…1 0…100 0 Yes Yes Medium FaceShapeWarpProvider 1.0
faceSmall small face Float 0…1 0…100 0 Yes Yes Medium FaceShapeWarpProvider 1.0
faceVShape V face Float 0…1 0…100 0 Yes Yes Medium FaceShapeWarpProvider 1.0
jawSlim Jaw tightening Float 0…1 0…100 0 Yes Yes Medium FaceShapeWarpProvider 1.0
chinLength Chin length Float -1…1 -100…100 0 Yes Yes Medium ChinWarpProvider 1.0

Parameter description

faceSlim

Function: Narrow the cheek area.

Dependence points:

faceContour
left cheek area
right cheek area
face center

Implementation method:

The left and right cheek control points move toward the center of the face.
The area of influence falls off smoothly along the cheek area.

Security restrictions:

Too high a strength will cause the background to stretch.
It is recommended that the actual effective upper limit is 0.6.

faceSmall

Effect: Reduce the overall visual area of the face.

Dependence points:

faceContour
face bounding box
face center

Implementation method:

The facial contour points shrink toward the center as a whole.
The facial features can be followed slightly, but the first version does not recommend moving the facial features significantly.

faceVShape

Function: Make the face closer to a V-shape.

Dependence points:

faceContour
jaw contour
chin point

Implementation method:

The jaw area shrinks inwards.
The chin area is slightly elongated or tapered.

jawSlim

Function: Tighten the jawline and cheeks.

Dependence points:

lower face contour
jaw area
chin point

Note:

It cannot affect the mouth too much.
The junction between the chin and neck should not be significantly distorted.

chinLength

Function: Adjust chin length.

Scope description:

Negative number: shorten the chin
Positive numbers: elongate the chin

Note:

Bidirectional parameters.
Too much strength can cause deformation of the mouth and jaw area.

⸻

4.3 Eyes: Eye adjustment

Parameter name Chinese name Type SDK scope UI scope Default value Whether to rely on face or not Real-time Performance impact Algorithm module version
eyeSize big eye / small eye Float -1…1 -100…100 0 Yes Yes Medium EyeWarpProvider 1.0
eyeDistance Eye distance Float -1…1 -100…100 0 Yes Yes Medium EyeWarpProvider 1.0
eyeYPosition The upper and lower position of the eye Float -1…1 -100…100 0 Yes Yes Medium EyeWarpProvider 1.0
eyeTailLift Eye tail lift Float -1…1 -100…100 0 Yes Yes Medium EyeWarpProvider 1.0

Parameter description

eyeSize

Function: Adjust eye size.

Scope description:

Negative numbers: eyes become smaller
Positive number: eyes become bigger

Dependence points:

leftEye
rightEye
leftPupil, optional
rightPupil, optional

Implementation method:

Calculate left and right eye centers.
Calculate the radius of influence of the eye.
Make local enlargement or reduction sampling of the area around the eyes.

Security restrictions:

Eyebrows should not be significantly affected.
The bridge of the nose should not be noticeably crooked.
It should not cause the rim of the eyeball to break.
It is recommended that the actual effective upper limit is 0.45.

eyeDistance

Function: Adjust the distance between the eyes.

Scope description:

Negative numbers: Eye distance becomes closer
Positive number: The distance between the eyes becomes farther

Implementation method:

The left eye area and the right eye area undergo local lateral displacement respectively.

Note:

The range of influence of eye distance adjustment must be controlled to avoid obvious deformation of the bridge of the nose.

eyeYPosition

Function: Adjust the up and down position of the eyes.

Scope description:

Negative numbers: Eyes move downward
Positive number: Eyes move upward

Note:

This parameter should be used with caution.
Moving the eyes up and down can easily affect the eyebrows, nose bridge and facial proportions.
The first version should be less intense.

eyeTailLift

Function: Adjust the angle of the eye tail.

Scope description:

Negative number: Press down the tail of the eye
Positive number: the tail of the eye is raised

Dependence points:

leftEye outer corner
rightEye outer corner

Note:

The first version only made slight adjustments to the ends of the eyes.
Complex eye shape switching will be moved to subsequent versions.

⸻

4.4 Nose: nose adjustment

Parameter name Chinese name Type SDK scope UI scope Default value Whether to rely on face or not Real-time Performance impact Algorithm module version
noseSlim thin nose Float 0…1 0…100 0 Yes Yes Medium NoseWarpProvider 1.0
noseWingSlim nose narrowing Float 0…1 0…100 0 Yes Yes Medium NoseWarpProvider 1.0
noseTipSize nose tip size Float -1…1 -100…100 0 Yes Yes Medium NoseWarpProvider 1.0
noseBridge nose bridge enhancement Float 0…1 0…100 0 Yes Yes Low~Medium NoseWarpProvider / MakeupLightEffect 1.0

Parameter description

noseSlim

Effect: Narrow the nose as a whole.

Dependence points:

nose
noseCrest
face center

Implementation method:

The left and right areas of the nose move toward the center line of the bridge of the nose.

Note:

The nose area points are usually not as stable as the eyes and mouth.
The strength of the first version should be conservative.

noseWingSlim

Function: Narrow the nose.

Dependence points:

nose lower points
nose wing estimated points

Note:

Vision's default alar points may not be precise enough.
The first version can do basic effects.
Advanced noses require more intensive placement.

noseTipSize

Function: Adjust the size of the nose tip.

Scope description:

Negative number: The tip of the nose is reduced
Positive number: The nose tip is enlarged. It is usually not recommended to expose the UI to the positive direction.

Suggestions:

The product UI can only display "nose reduction" and still retain the two-way capability internally.

noseBridge

Function: Enhance the three-dimensional feeling of the bridge of the nose.

Implementation method:

Version 1: Slight nose bridge area narrowing + shading enhancement.
Follow-up: Highlight on the bridge of the nose + shadow on the side of the nose.

Note:

The "higher" bridge of the nose is more about the effect of light and shadow, and should not rely solely on geometric deformation.

⸻

4.5 Mouth: mouth adjustment

Parameter name Chinese name Type SDK scope UI scope Default value Whether to rely on face or not Real-time Performance impact Algorithm module version
mouthSize Mouth size Float -1…1 -100…100 0 Yes Yes Medium MouthWarpProvider 1.0
mouthWidth Mouth width Float -1…1 -100…100 0 Yes Yes Medium MouthWarpProvider 1.0
smile Mouth smile Float 0…1 0…100 0 Yes Yes Medium MouthWarpProvider 1.0
lipColor Lip Color Enhancement Float 0…1 0…100 0 Yes, subsequent recommendations lip mask Yes Low LipColorEffect 1.0

Parameter description

mouthSize

Function: Adjust the overall size of the mouth.

Scope description:

Negative numbers: the mouth becomes smaller
Positive number: the mouth becomes bigger

Dependence points:

outerLips
innerLips
mouth center

Note:

Mouth resizing should not severely stretch the dental area.

mouthWidth

Function: Adjust the horizontal width of the mouth.

Scope description:

Negative numbers: the mouth becomes narrower
Positive number: mouth becomes wider

Implementation method:

The left and right corners of the mouth move laterally.

smile

Function: Raise the corners of the mouth to create a slight smile.

Dependence points:

left mouth corner
right mouth corner
outerLips

Implementation method:

Move the left and right corners of your mouth upward.
The area of influence falls off smoothly.

Note:

Don't make your expression too fake.
A practical upper limit of 0.5 is recommended.

lipColor

What it does: Enhance natural lip color.

Implementation method:

The first version: Generate a basic area based on the key points of the lips and perform color enhancement.
Follow-up: full lipstick mask + blend mode.

⸻

4.6 Filter: filter parameters

Parameter name Chinese name Type SDK scope UI scope Default value Whether to rely on face or not Real-time Performance impact Algorithm module version
filterId filter ID String? - - nil No Yes Low~Medium LUTFilterEffect 1.0
filterIntensity filter intensity Float 0…1 0…100 0 No Yes Low~Medium LUTFilterEffect 1.0

Parameter description

filterId

Function: Specify the currently used filter resource.

Example:

clean_01
film_01
warm_01
cool_white_01

Rules:

When filterId is nil, the LUT filter is not applied.
When the resource filterId is not found, an error should be returned or downgraded to no filter.

filterIntensity

Function: Control filter intensity.

Implementation:

output = mix(original, filtered, filterIntensity)

Rules:

When filterIntensity = 0, it must be equal to the original image.
When filterIntensity = 1, it is a complete filter.

⸻

5. Subsequent extended parameter list

It is not recommended to implement all the following parameters in 1.0, but it is recommended to reserve categories in the design.

⸻

5.1 Advanced Eyes: Advanced eye parameters

Parameter name Chinese name Type SDK scope Default value Dependency Recommended version
eyeWidth eye width Float -1…1 0 leftEye / rightEye 1.5
eyeHeight eye height Float -1…1 0 leftEye / rightEye 1.5
leftEyeSize left eye size Float -1…1 0 leftEye 1.5
rightEyeSize Right eye size Float -1…1 0 rightEye 1.5
innerEyeCorner Open the inner corner of the eye Float 0…1 0 eye corners 1.5
outerEyeCorner outer eye corners Float 0…1 0 eye corners 1.5
eyeWhite eye white brightening Float 0…1 0 eye mask 1.5
eyeLight eye light Float 0…1 0 eye / pupil 1.5
eyeBag Float 0…1 0 lower eye area 2.0
darkCircleRemoval Dark Circle Reduction Float 0…1 0 under-eye mask 2.0

⸻

5.2 Advanced Nose: Advanced nose parameters

Parameter name Chinese name Type SDK scope Default value Dependency Recommended version
noseHeight nose bridge height Float 0…1 0 noseCrest 1.5
noseLength nose length Float -1…1 0 nose / noseCrest 1.5
noseTipLift nose tip lift Float -1…1 0 nose tip 1.5
nosePositionY nose up and down position Float -1…1 0 nose 1.5
noseShadow nose shadow Float 0…1 0 nose mask 2.0
noseHighlight nose bridge highlight Float 0…1 0 noseCrest mask 2.0
noseBase Nose base Float 0…1 0 dense landmarks 2.5

⸻

5.3 Advanced Mouth: Advanced mouth parameters

Parameter name Chinese name Type SDK scope Default value Dependency Recommended version
mouthYPosition The upper and lower position of the mouth Float -1…1 0 outerLips 1.5
upperLipThickness Upper lip thickness Float -1…1 0 outerLips / innerLips 1.5
lowerLipThickness Lower lip thickness Float -1…1 0 outerLips / innerLips 1.5
lipGloss lip gloss Float 0…1 0 lip mask 2.0
lipWrinkleSmooth Lip wrinkle lightening Float 0…1 0 lip mask 2.0
teethWhitening Teeth Whitening Float 0…1 0 teeth mask 2.0
philtrumLength philtrum length Float -1…1 0 nose + lips 2.0

⸻

5.4 Eyebrow: eyebrow parameters

Parameter name Chinese name Type SDK scope Default value Dependency Recommended version
eyebrowYPosition The upper and lower position of eyebrows Float -1…1 0 eyebrow landmarks 1.5
eyebrowDistance eyebrow distance Float -1…1 0 eyebrow landmarks 1.5
eyebrowThickness eyebrow thickness Float -1…1 0 eyebrow mask 2.0
eyebrowColor eyebrow color intensity Float 0…1 0 eyebrow mask 2.0
eyebrowShapeId eyebrow shape ID String? - nil eyebrow landmarks 2.0

⸻

5.5 Advanced Face Shape: Advanced face shape parameters

Parameter name Chinese name Type SDK scope Default value Dependency Recommended version
cheekboneSlim cheekbone adduction Float 0…1 0 face contour 1.5
foreheadHeight forehead height Float -1…1 0 face contour / hairline 2.0
templeFullness Temple fullness Float 0…1 0 face contour 2.0
faceSymmetry left and right face symmetry Float 0…1 0 face contour 2.0
midFaceLength atrium length Float -1…1 0 dense landmarks 2.5
lowerFaceLength lower court length Float -1…1 0 dense landmarks 2.5
hairlineHeight hairline height Float -1…1 0 hair / skin segmentation 2.5

⸻

5.6 Advanced Skin: Advanced skin parameters

Parameter name Chinese name Type SDK scope Default value Dependency Recommended version
skinTexturePreserve Skin texture preservation Float 0…1 0.5 skin mask 2.0
skinEvenTone Even skin tone Float 0…1 0 skin mask 2.0
acneRemoval acne removal Float 0…1 0 blemish detection 2.0
spotRemoval freckle removal Float 0…1 0 blemish detection 2.0
tearTroughRemoval Tear trough reduction Float 0…1 0 under-eye mask 2.0
nasolabialFoldRemoval Float 0…1 0 mouth / cheek mask 2.0
foreheadWrinkleRemoval Forehead wrinkle reduction Float 0…1 0 forehead mask 2.0

⸻

5.7 Makeup: Makeup parameters

Parameter name Chinese name Type SDK scope Default value Dependency Recommended version
makeupId makeup ID String? - nil makeup resources 2.0
makeupIntensity The overall intensity of makeup Float 0…1 0 makeup resources 2.0
lipstickIntensity Lipstick intensity Float 0…1 0 lip mask 2.0
blushIntensity Blush intensity Float 0…1 0 cheek mask 2.0
eyeshadowIntensity Eyeshadow intensity Float 0…1 0 eye mask 2.0
eyelinerIntensity Eyeliner intensity Float 0…1 0 eye landmarks 2.0
eyelashIntensity Eyelash intensity Float 0…1 0 eye landmarks 2.0
contourIntensity Contour intensity Float 0…1 0 face mask 2.0
highlightIntensity Highlight intensity Float 0…1 0 face mask 2.0

⸻

5.8 Background: background and portrait segmentation parameters

Parameter name Chinese name Type SDK scope Default value Dependency Recommended version
portraitSegmentationEnabled portrait segmentation switch Bool - false person segmentation 2.5
backgroundBlur background blur Float 0…1 0 portrait mask 2.5
backgroundDarken background darkening Float 0…1 0 portrait mask 2.5
backgroundReplaceId background replacement ID String? - nil portrait mask 2.5
portraitOutline portrait stroke Float 0…1 0 portrait mask 2.5
edgeLight edge light Float 0…1 0 portrait mask 2.5

⸻

5.9 Body: body beauty parameters

Parameter name Chinese name Type SDK scope Default value Dependency Recommended version
legLength long legs Float 0…1 0 body pose 3.0
bodySlim Float 0…1 0 body pose / segmentation 3.0
waistSlim thin waist Float 0…1 0 body pose 3.0
armSlim thin arms Float 0…1 0 body pose 3.0
legSlim Float 0…1 0 body pose 3.0
headSize head size Float -1…1 0 face + body pose 3.0
shoulderWidth shoulder width Float -1…1 0 body pose 3.0

⸻

6. Parameter classification and UI mapping

The App side parameter panel recommends grouping like this.

6.1 First level classification

Beauty
face shape
eyes
nose
mouth
eyebrows
makeup
filter
background
body

6.2 MVP UI mapping

Beauty

Microdermabrasion -> skinSmoothing
Whitening -> skinWhitening
rosy -> skinRosy
clear -> skinSharpen

face shape

Face slimming -> faceSlim
small face -> faceSmall
V face -> faceVShape
jaw -> jawSlim
Chin -> chinLength

eyes

Big eyes -> eyeSize
eye distance -> eyeDistance
Up and down -> eyeYPosition
eye tail -> eyeTailLift

nose

Slim nose -> noseSlim
Nose -> noseWingSlim
nose -> noseTipSize
nose bridge -> noseBridge

mouth

Mouth size -> mouthSize
Mouth width -> mouthWidth
smile -> smile
Lip color -> lipColor

filter

Filter selection -> filterId
Filter intensity -> filterIntensity

⸻

7. Parameter normalization specification

The App should ensure that the parameter range is legal before passing it to the SDK.

The SDK must also be clamped twice internally to avoid external transmission errors.

extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

It is recommended to provide:

public struct BeautyParameterNormalizer {
    public func normalize(_ parameters: BeautyParameters) -> BeautyParameters {
        var result = parameters
        result.skinSmoothing = result.skinSmoothing.clamped(to: 0...1)
        result.skinWhitening = result.skinWhitening.clamped(to: 0...1)
        result.skinRosy = result.skinRosy.clamped(to: 0...1)
        result.skinSharpen = result.skinSharpen.clamped(to: 0...1)
        result.faceSlim = result.faceSlim.clamped(to: 0...1)
        result.faceSmall = result.faceSmall.clamped(to: 0...1)
        result.faceVShape = result.faceVShape.clamped(to: 0...1)
        result.jawSlim = result.jawSlim.clamped(to: 0...1)
        result.chinLength = result.chinLength.clamped(to: -1...1)
        result.eyeSize = result.eyeSize.clamped(to: -1...1)
        result.eyeDistance = result.eyeDistance.clamped(to: -1...1)
        result.eyeYPosition = result.eyeYPosition.clamped(to: -1...1)
        result.eyeTailLift = result.eyeTailLift.clamped(to: -1...1)
        result.noseSlim = result.noseSlim.clamped(to: 0...1)
        result.noseWingSlim = result.noseWingSlim.clamped(to: 0...1)
        result.noseTipSize = result.noseTipSize.clamped(to: -1...1)
        result.noseBridge = result.noseBridge.clamped(to: 0...1)
        result.mouthSize = result.mouthSize.clamped(to: -1...1)
        result.mouthWidth = result.mouthWidth.clamped(to: -1...1)
        result.smile = result.smile.clamped(to: 0...1)
        result.lipColor = result.lipColor.clamped(to: 0...1)
        result.filterIntensity = result.filterIntensity.clamped(to: 0...1)
        return result
    }
}

⸻

8. Parameter security strength recommendations

Even if the SDK range is 0…1 or -1…1, the actual algorithm internals should not use the full strength linearly.

8.1 MVP safety upper limit

Parameter Actual Maximum Strength of Proposed Algorithm Reason
skinSmoothing 0.6 Avoid plastic faces
skinWhitening 0.5 avoids overexposure and false whitening
skinRosy 0.4 Prevents facial redness
faceSlim 0.6 avoids background stretching
faceSmall 0.45 avoids abnormal facial features proportions
faceVShape 0.5 avoid awl face
chinLength 0.35 to avoid jaw deformity
eyeSize 0.45 to prevent eyes from being too large
eyeDistance 0.3 to avoid nose bridge deformation
eyeYPosition 0.25 to avoid abnormal facial proportions
eyeTailLift 0.3 to avoid false eye shapes
noseSlim 0.35 Vision Nose points are limited
noseWingSlim 0.35 The nose points are not dense enough
noseTipSize 0.3 to avoid nose tip deformation
mouthSize 0.35 to avoid tooth stretching
mouthWidth 0.35 to avoid mouth corner deformation
smile 0.5 avoid fake smiles
lipColor 0.5 avoids excessive lipstick feeling

⸻

9. Mapping of parameters and algorithm modules

9.1 FaceWarpPass parameters

The following parameters should be entered into FaceWarpPass uniformly:

faceSlim
faceSmall
faceVShape
jawSlim
chinLength
eyeSize
eyeDistance
eyeYPosition
eyeTailLift
noseSlim
noseWingSlim
noseTipSize
mouthSize
mouthWidth
smile

Corresponding Provider:

FaceShapeWarpProvider
ChinWarpProvider
EyeWarpProvider
NoseWarpProvider
MouthWarpProvider

9.2 SkinPass parameters

skinSmoothing
skinWhitening
skinRosy

Corresponding Effect:

SkinSmoothEffect
SkinWhitenEffect
SkinRosyEffect

9.3 ColorPass parameters

skinSharpen

Can be expanded later:

brightness
contrast
saturation
temperature
tint
exposure
highlight
shadow

9.4 LUTPass parameters

filterId
filterIntensity

Corresponding Effect:

LUTFilterEffect

9.5 MakeupPass parameters

Currently, only the following are retained in MVP:

lipColor

Next comes the complete makeup look:

makeupId
makeupIntensity
lipstickIntensity
blushIntensity
eyeshadowIntensity
eyelinerIntensity

⸻

10. Parameter Codable JSON example

10.1 Single parameter group

{
  "skinSmoothing": 0.3,
  "skinWhitening": 0.2,
  "skinRosy": 0.1,
  "skinSharpen": 0.15,
  "faceSlim": 0.2,
  "faceSmall": 0.1,
  "faceVShape": 0.12,
  "jawSlim": 0.08,
  "chinLength": 0.05,
  "eyeSize": 0.18,
  "eyeDistance": 0,
  "eyeYPosition": 0,
  "eyeTailLift": 0.08,
  "noseSlim": 0.12,
  "noseWingSlim": 0.1,
  "noseTipSize": -0.08,
  "noseBridge": 0.12,
  "mouthSize": 0,
  "mouthWidth": 0,
  "smile": 0.08,
  "lipColor": 0.2,
  "filterId": "clean_01",
  "filterIntensity": 0.35
}

10.2 Default JSON example

{
  "id": "natural_01",
  "name": "natural",
  "version": "1.0.0",
  "parameters": {
    "skinSmoothing": 0.22,
    "skinWhitening": 0.12,
    "skinRosy": 0.08,
    "skinSharpen": 0.08,
    "faceSlim": 0.08,
    "faceSmall": 0.04,
    "faceVShape": 0.04,
    "jawSlim": 0.02,
    "chinLength": 0,
    "eyeSize": 0.06,
    "eyeDistance": 0,
    "eyeYPosition": 0,
    "eyeTailLift": 0.02,
    "noseSlim": 0.04,
    "noseWingSlim": 0.02,
    "noseTipSize": 0,
    "noseBridge": 0.03,
    "mouthSize": 0,
    "mouthWidth": 0,
    "smile": 0.03,
    "lipColor": 0.08,
    "filterId": "clean_01",
    "filterIntensity": 0.2
  }
}

⸻

11. Parameter version strategy

11.1 New parameters

New parameters must meet:

The default value is no effect state.
Does not break old JSON decoding.
Old preset effects will not be changed.
Must be written to parameter table.
CHANGELOG must be written.

11.2 Delete parameters

It is not recommended to delete external parameters.

If it must be discarded:

@available(*, deprecated, message: "Use xxx instead")

11.3 Parameter renaming

Renaming is prohibited in principle.

If you must rename:

Keep old fields compatible with at least one major version.
PresetLoader does field mapping.
Documentation markup deprecated.

⸻

12. Parametric test specifications

12.1 Default value testing

Must test:

BeautyParameters() All parameters have no effect.
filterId == nil。
filterIntensity == 0。

12.2 Range testing

Must test:

It will clamp when the input value is less than the minimum value.
When the input value is greater than the maximum value, it will be clamped.
Bidirectional parameters will not be incorrectly clamped to 0...1.

12.3 Codable testing

Must test:

BeautyParameters can be encoded.
BeautyParameters can be decoded.
Missing fields can use default values, or be compatible via PresetLoader.
Old version presets can be loaded.

12.4 Effect off test

Must test:

When all parameters are 0, the output should be equal or approximately equal to the input.
When a single parameter is 0, the corresponding Effect should have no side effects.
When filterIntensity is 0, the image should not be changed even if filterId exists.

⸻

13. First version of parameter implementation priority

P0: Must be implemented

skinSmoothing
skinWhitening
skinRosy
skinSharpen
faceSlim
faceSmall
faceVShape
chinLength
eyeSize
eyeDistance
noseSlim
mouthSize
smile
filterId
filterIntensity

P1: Proposed 1.0 implementation

jawSlim
eyeYPosition
eyeTailLift
noseWingSlim
noseTipSize
noseBridge
mouthWidth
lipColor

P2: Will be implemented after 1.5

eyeWidth
eyeHeight
innerEyeCorner
outerEyeCorner
cheekboneSlim
upperLipThickness
lowerLipThickness
eyebrowYPosition
teethWhitening

P3: Implemented after 2.0

full makeup
Advanced skin
Remove acne
Nasal pattern
Background segmentation
body beauty

⸻

14. Final recommendations for the first version of parameters

The first version of BeautyParameters should not be too large, but should cover the core experience.

The final recommendation 1.0 contains 22 parameters:

skinSmoothing
skinWhitening
skinRosy
skinSharpen
faceSlim
faceSmall
faceVShape
jawSlim
chinLength
eyeSize
eyeDistance
eyeYPosition
eyeTailLift
noseSlim
noseWingSlim
noseTipSize
noseBridge
mouthSize
mouthWidth
smile
lipColor
filterId
filterIntensity

These parameters are sufficient to support:

Basic beauty
Basic face shape
Basic eyes
Basic nose
Basic mouth
Basic filter
Basic preset

Do not cram subsequent advanced features into the 1.0 parameter model initially to avoid premature API expansion.

⸻

15. One sentence conclusion

The goal of the first version of BeautyParameters is not to cover all fantasy functions, but to stably support a beauty SDK MVP that can run in real time, can be preset, and is extensible.

There are fewer parameters, but each parameter must be stable, explainable, testable, and scalable.