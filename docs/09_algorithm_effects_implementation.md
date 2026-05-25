# 09. iOS Beauty SDK Algorithm and Effect Implementation

iOS Beauty SDK Algorithm Effect Implementation Document
1. Documentation goals
This document defines the implementation scheme of core beauty effects in BeautySDK.
What must be achieved to cover the first version of MVP:
1. Big eyes / small eyes
2. Eye distance adjustment
3. Up and down position of eyes
4. Raise the tail of the eyes
5. Face slimming
6. Small face
7. V face
8. Chin adjustment
9. Slim nose
10. Narrowing of the nose
11. Reduction of nose tip
12. Mouth size
13. Mouth width
14. Smile
15. Microdermabrasion
16. Whitening
17. ruddy
18. Clear / Sharpen
19. Lip color enhancement
20. LUT filters
This document is intended to guide:
BeautyEffects module development
Metal shader development
WarpControlPointProvider Development
Parameter debugging
Effect acceptance
Performance optimization

2. Overall implementation principles
2.1 Geometric deformation unified into FaceWarpPass
The following functions all belong to geometric deformation:
big eyes
eye distance
eyes up and down
Eye tail raised
face slimming
small face
V face
chin
thin nose
Nose
Nose
mouth size
mouth width
smile
These features should not be written independently of Metal Pass.
Unified process:
BeautyParameters
        ↓
WarpControlPointProvider
        ↓
[WarpControlPoint]
        ↓
FaceWarpPass
        ↓
Warp.Metal
        ↓
warpedTexture
2.2 Merging color effects
The following features are color and image enhancements:
Whitening
ruddy
clear / sharpen
lip color enhancement
LUT filter
Wherever possible, should be combined:
SkinPass: microdermabrasion, whitening, rosiness
ColorPass: Basic Color, Clear/Sharpen
LUTPass: filter
MakeupPass: lip color, lipstick, blush, subsequent versions
2.3 Parameters must have security strength mapping
Although the UI incoming value is:
0...1
-1...1
But the full range cannot be used directly linearly within the algorithm.
should do:
normalized parameter
        ↓
clamp
        ↓
safety scale
        ↓
nonlinear curve
        ↓
actual displacement / color intensity
Example:
let safeStrength = pow(abs(parameter), 0.85) * maxStrength

3. Public data structures
3.1 WarpControlPoint
public struct WarpControlPoint: Sendable {
    public let source: SIMD2<Float>
    public let target: SIMD2<Float>
    public let radius: Float
    public let strength: Float
    public let falloff: Float
}
Field description:
source: original position of control point, Texture Normalized coordinates
target: control point target position, Texture Normalized coordinates
radius: influence radius, Texture Normalized unit
strength: actual strength, usually 0...1
falloff: attenuation parameter, controlling edge transition
3.2 WarpControlPointProvider
public protocol WarpControlPointProvider {
    func makeControlPoints(
        face: BeautyFaceObservation,
        parameters: BeautyParameters,
        imageSize: CGSize
    ) -> [WarpControlPoint]
}
3.3 LandmarkGeometryHelper
All providers should rely on unified geometry tools and not write their own.
Suggested tools:
public enum LandmarkGeometryHelper {
    public static func center(of points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func boundingRect(of points: [SIMD2<Float>]) -> CGRect?
    public static func distance(_ a: SIMD2<Float>, _ b: SIMD2<Float>) -> Float
    public static func leftMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func rightMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func topMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func bottomMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
}

4. FaceWarpPass overall design
4.1 Input
inputTexture
BeautyParameters
[BeautyFaceObservation]
[WarpControlPointProvider]
4.2 Output
outputTexture
4.3 Processing flow
1. Traverse faces.
2. Traverse providers.
3. Each provider generates control points based on the current face and parameters.
4. Merge all control points.
5. Upload to GPU buffer.
6. Warp.Metal reverse-samples each pixel.
7. Output warpedTexture.
4.4 Metal sampling logic
Each output pixel:
p = current output coordinates
samplePosition = p

for controlPoint in controlPoints:
    d = distance(p, controlPoint.source)
    if d < radius:
        weight = falloff(d / radius)
        offset = (controlPoint.target - controlPoint.source) * weight * strength
        samplePosition -= offset

output[p] = input[samplePosition]
Use reverse sampling:
Invert the input sampling position from the output pixel
avoid cavities
4.5 falloff curve
Recommended first edition:
x = d / radius
weight = (1 - x)^2
Softer:
weight = smoothstep(1, 0, x)
Metal example:
float falloffWeight(float x, float falloff) {
    x = clamp(x, 0.0, 1.0);
    float w = 1.0 - smoothstep(0.0, 1.0, x);
    return pow(w, max(falloff, 0.001));
}

5. EyeWarpProvider: Eye effects
5.1 Support parameters
eyeSize
eyeDistance
eyeYPosition
eyeTailLift
Key points of dependency:
leftEye
rightEye
leftPupil, optional
rightPupil, optional

5.2 eyeSize: big eyes / small eyes
Function description
Adjust the overall size of the eyes.
Positive number: eyes become bigger
Negative numbers: eyes become smaller
input parameters
eyeSize: -1...1
Dependence point
leftEye
rightEye
Control point generation
For each eye:
eyeCenter = center(eyePoints)
eyeRect = boundingRect(eyePoints)
eyeWidth = eyeRect.width
eyeHeight = eyeRect.height
radius = max(eyeWidth, eyeHeight) * radiusScale
Recommended:
radiusScale = 1.8 ~ 2.4
maxStrength = 0.45
For big eyes:
source = eyeCenter
target = eyeCenter
However, a single source/target point is not enough to express amplification. The shader needs to support the radial scale type, or use multiple control points.
The first version is simpler:
Provide a radialScale control type for eyeSize in the shader.
If you insist on unifying the WarpControlPoint, you can generate multiple control points around the eyes:
The point above the eye moves upward
Now point moves down
Eyes move outward
Eye tail moves outward
Recommended first version implementation
In order to unify Provider, it is recommended to generate 4 control points:
top point -> move up
bottom point -> move down
inner point -> move toward the outside of the eye head
outer point -> move to the outside of the eye
For each eye:
top = topMostPoint(eyePoints)
bottom = bottomMostPoint(eyePoints)
left = leftMostPoint(eyePoints)
right = rightMostPoint(eyePoints)
center = center(eyePoints)
Moving direction:
direction = normalize(point - center)
target = point + direction * displacement
Displacement:
displacement = eyeSize * maxStrength * eyeWidth
security restrictions
Actual strength limit: 0.45
The radius of influence cannot exceed 2.5 times the width of the eye
Does not significantly affect eyebrows and nose bridge
Skip if there are no eye points
Skip when the number of left and right eye points is abnormal.
Acceptance criteria
Eyes become bigger obviously but naturally
Eyeballs and eyelid edges are not cracked
Eyebrows are not obviously deformed
The bridge of the nose is not pulled crooked
The effect is the same for left and right eyes

5.3 eyeDistance: eye distance adjustment
Function description
Adjust the distance between your eyes.
Negative numbers: Eye distance becomes closer
Positive number: The distance between the eyes becomes farther
Dependence point
leftEye center
rightEye center
face center
Control point generation
leftEyeCenter
rightEyeCenter
faceCenterX
Direction:
left eye:
eyeDistance > 0: move left
    eyeDistance < 0: move right

right eye:
    eyeDistance > 0: move to the right
    eyeDistance < 0: move left
Displacement:
displacement = abs(eyeDistance) * maxStrength * distanceBetweenEyes
maxStrength = 0.12 ~ 0.18
Control points:
source = eyeCenter
target = eyeCenter + horizontalOffset
radius = eyeWidth * 2.0
security restrictions
Actual strength limit: 0.3
The affected area cannot cover the entire nose
It is recommended to only affect the orbital area
Acceptance criteria
The distance between the eyes changes naturally
The bridge of the nose is not obviously distorted
Eye shape is not significantly deformed

5.4 eyeYPosition: the upper and lower position of the eye
Function description
Overall adjustment of vertical eye position.
Positive number: Eyes move upward
Negative numbers: Eyes move downward
Control point generation
Generate a central control point for each eye:
source = eyeCenter
target = eyeCenter + SIMD2(0, -verticalOffset)
Note:
If the Texture Normalized coordinate y increases downward, then:
Move up: target.y -= offset
Move down: target.y += offset
Displacement:
offset = eyeYPosition * maxStrength * faceHeight
maxStrength = 0.03 ~ 0.06
security restrictions
Actual strength limit: 0.25
The upper and lower position of the eyes is a strong proportional adjustment, so the first version should be conservative.
Avoid abnormal distance between eyebrows and eyes

5.5 eyeTailLift: Eye tail lift
Function description
Adjust the angle of the eye end.
Positive number: the tail of the eye is raised
Negative number: Press down the tail of the eye
Dependence point
leftEye
rightEye
Eye end judgment
In non-mirror unified coordinates:
Outer corner of left eye: further to the left
Outer corner of right eye: further to the right
But if the input is mirrored coordinates, CoordinateMapper has been unified to the texture coordinates, so the Provider can only judge based on the current texture.
Control point generation
leftEyeOuter = leftMostPoint(leftEye)
rightEyeOuter = rightMostPoint(rightEye)
Move:
Upward: outer.y -= offset
Press down: outer.y += offset
Displacement:
offset = eyeTailLift * maxStrength * eyeHeight
maxStrength = 0.4 ~ 0.7
radius：
eyeWidth * 1.2
Acceptance criteria
Changes in the angle of the tail of the eye are visible
No obvious movement of eyes and head
The eyes do not drift as a whole

6. FaceShapeWarpProvider: Face shape effect
6.1 Support parameters
faceSlim
faceSmall
faceVShape
jawSlim
Key points of dependency:
faceContour
boundingBox

6.2 faceSlim: face slimming
Function description
Narrow the cheek area.
Dependence point
faceContour
faceCenter
Control point selection
Need an estimate:
leftCheek
rightCheek
If the faceContour points are arranged from one side to the other side according to the contour, the points on both sides of the middle and lower parts can be taken.
More robust first version approach:
faceRect = boundingRect(faceContour)
leftCheek = SIMD2(faceRect.minX, faceRect.midY + faceRect.height * 0.12)
rightCheek = SIMD2(faceRect.maxX, faceRect.midY + faceRect.height * 0.12)
faceCenter = center(faceContour)
Control point generation
leftCheek target  = leftCheek  + SIMD2(+offset, 0)
rightCheek target = rightCheek + SIMD2(-offset, 0)
Displacement:
offset = faceSlim * maxStrength * faceWidth
maxStrength = 0.08 ~ 0.12
radius：
faceWidth * 0.35 ~ 0.45
security restrictions
Actual strength limit: 0.6
Reduce intensity when the face is too sideways
Skip if faceContour is incomplete
If the face is too small, skip or reduce the intensity.
Acceptance criteria
Cheeks narrow naturally
The background stretch is not obvious
The mouth and nose are not obviously deformed
The left and right faces are basically symmetrical

6.3 faceSmall: small face
Function description
Reduce the overall visual area of the face.
Implementation ideas
Move the facial contour points as a whole toward the center of the face.
Control point generation
Select multiple contour points:
leftUpperFace
leftCheek
leftJaw
rightUpperFace
rightCheek
rightJaw
chin
Each point:
direction = normalize(faceCenter - point)
target = point + direction * displacement
Displacement:
displacement = faceSmall * maxStrength * faceWidth
maxStrength = 0.04 ~ 0.08
radius：
faceWidth * 0.25 ~ 0.4
security restrictions
Actual strength limit: 0.45
Don’t let the entire facial features collapse toward the center
It is not recommended to move the forehead too much in the first version

6.4 faceVShape: V face
Function description
Tighten the lower face to bring it closer to a V-shape.
Dependence point
faceContour
chin point
jaw points
Control point generation
leftJaw -> move inwards and upwards
rightJaw -> move inwards and upwards
chin -> slightly downward or maintain, depending on the effect of the product
Displacement:
jawOffsetX = faceVShape * maxStrength * faceWidth
jawOffsetY = faceVShape * maxStrength * faceHeight * 0.2
Recommended:
maxStrength = 0.06 ~ 0.1
security restrictions
Actual strength limit: 0.5
Prevent awl face
Prevent the chin from being too pointed

6.5 jawSlim: jaw tightening
Function description
Optimize jawline and cheeks.
Control point generation
Select the left and right sides of the jaw:
leftJawArea
rightJawArea
Goal:
move inward
Move slightly upward
Acceptance criteria
The jawline is tighter
Does not affect the corners of the mouth
No obvious distortion in the neck area

7. ChinWarpProvider: Chin adjustment
7.1 chinLength: chin length
Function description
Positive numbers: elongate the chin
Negative number: shorten the chin
Dependence point
faceContour bottom point
outerLips
faceCenter
Control point generation
chinPoint = bottomMostPoint(faceContour)
Move:
Positive number: chinPoint.y += offset
Negative number: chinPoint.y -= offset
If the Texture coordinate y increases downward:
Lengthen chin = y increases
shorten chin = y decrease
Displacement:
offset = chinLength * maxStrength * faceHeight
maxStrength = 0.06 ~ 0.1
radius：
faceWidth * 0.25
security restrictions
Actual strength limit: 0.35
Do not affect the mouth area too much
Do not cause sharp deformity of the chin

8. NoseWarpProvider: nose effect
8.1 Support parameters
noseSlim
noseWingSlim
noseTipSize
noseBridge
Key points of dependency:
nose
noseCrest

8.2 noseSlim: thin nose
Function description
Overall narrowing of the nose area.
Dependence point
nose
noseCrest
Nose bridge centerline estimation
noseCenter = center(nose + noseCrest)
noseRect = boundingRect(nose)
Control point generation
Estimate the left and right boundaries of the nose:
leftNose = leftMostPoint(nose)
rightNose = rightMostPoint(nose)
Move towards the center:
leftNose target = leftNose + SIMD2(+offset, 0)
rightNose target = rightNose + SIMD2(-offset, 0)
Displacement:
offset = noseSlim * maxStrength * noseWidth
maxStrength = 0.12 ~ 0.2
radius：
noseWidth * 1.2 ~ 1.8
security restrictions
Actual strength limit: 0.35
Skip when there are insufficient points
Reduce intensity when facing sideways

8.3 noseWingSlim: nose wing narrowing
Function description
Narrow the nose.
Control point selection
Select the left and right borders of the lower half of the nose area.
If the Vision point is not stable enough:
Use the lower part of nose boundingRect to estimate nose position
leftWing = SIMD2(noseRect.minX, noseRect.maxY - noseRect.height * 0.25)
rightWing = SIMD2(noseRect.maxX, noseRect.maxY - noseRect.height * 0.25)
Move:
leftWing -> right
rightWing -> left
security restrictions
Actual strength limit: 0.35
The radius should be smaller than noseSlim
Avoid affecting the area above the lips too much.

8.4 noseTipSize: nose tip size
Function description
Negative number: The tip of the nose is reduced
Positive number: The tip of the nose is enlarged and is usually not exposed on the product
Control point generation
Estimated nose center:
noseTip = bottomMostPoint(nose)
To reduce the size of the nose tip, you can use multiple points to move toward the center of the nose tip:
leftTipBoundary -> noseTipCenter
rightTipBoundary -> noseTipCenter
topTipBoundary -> noseTipCenter
bottomTipBoundary -> noseTipCenter
Simplified first version:
The left and right borders of the nose move toward the center
security restrictions
Actual strength limit: 0.3
Avoid nose collapse

8.5 noseBridge: nose bridge enhancement
Function description
Enhance the three-dimensional effect of the bridge of the nose.
implementation strategy
The first edition can be divided into two parts:
1. Slight geometric narrowing of the bridge of the nose
2. Slight light and shadow enhancement
Geometry part:
The left and right areas around noseCrest move toward the center line
The light and shadow part will be later put into Makeup/Light effect:
Nose bridge highlight
nasal shadow
Note
The bridge of the nose becoming higher is not a purely geometric problem.
Don’t just rely on stretching.

9. MouthWarpProvider: mouth effects
9.1 Support parameters
mouthSize
mouthWidth
smile
Key points of dependency:
outerLips
innerLips

9.2 mouthSize: mouth size
Function description
Positive number: the mouth becomes bigger
Negative numbers: the mouth becomes smaller
Dependence point
outerLips
mouthCenter
Control point generation
Get the upper, lower, left and right boundaries of the mouth:
topLip
bottomLip
leftCorner
rightCorner
mouthCenter
Move:
direction = normalize(point - mouthCenter)
target = point + direction * displacement
Displacement:
displacement = mouthSize * maxStrength * mouthWidth
maxStrength = 0.15 ~ 0.25
radius：
mouthWidth * 0.8 ~ 1.2
security restrictions
Actual strength limit: 0.35
Do not severely stretch the tooth area
Skip when there are insufficient mouth points

9.3 mouthWidth: mouth width
Function description
Positive number: mouth becomes wider
Negative numbers: the mouth becomes narrower
Control point generation
leftCorner = leftMostPoint(outerLips)
rightCorner = rightMostPoint(outerLips)
Move:
Positive number: leftCorner moves left, rightCorner moves right
Negative numbers: leftCorner moves right, rightCorner moves left
Displacement:
offset = mouthWidth * maxStrength * mouthWidthValue
maxStrength = 0.2 ~ 0.3

9.4 smile: smile at the corners of the mouth
Function description
Let the corners of your mouth rise slightly.
Dependence point
leftCorner
rightCorner
outerLips
Control point generation
leftCorner target.y -= offset
rightCorner target.y -= offset
If y increases downward, then y decreases upward.
Displacement:
offset = smile * maxStrength * mouthHeight
maxStrength = 0.6 ~ 1.0
radius：
mouthWidth * 0.35 ~ 0.5
security restrictions
Actual strength limit: 0.5
Don't pull your mouth into a fake smile
Do not significantly affect the nose and chin
Acceptance criteria
Expression is softer
The corners of the mouth are raised naturally
The tooth area is not obviously distorted
Symmetrical mouth corners

10. SkinSmoothEffect: microdermabrasion
10.1 Function description
Microdermabrasion is used to reduce skin noise, pores and slight texture, but does not blur the features and edges.
Parameters:
skinSmoothing: 0...1
10.2 First version implementation strategy
The first version can be used:
Low frequency smoothing + high frequency detail addition
Process:
inputTexture
    ↓
Blur / Smooth Texture
    ↓
detail = input - smooth
    ↓
output = mix(input, smooth + detail * detailPreserve, intensity)
10.3 More realistic MVP simplification
In order to implement quickly, the first version can:
1. Use a small radius bilateral-like blur or edge-aware blur.
2. Mix the original image and the smoothed image according to skinSmoothing.
3. Slightly preserve high-frequency details.
If there is no skin mask:
The intensity must be low.
Protect the edges.
Don’t force the entire image to be blurry.
10.4 Recommended Pass
SkinBlurHorizontal
SkinBlurVertical
SkinBlend
Or:
SkinPass internal multi-stage encode
10.5 Security restrictions
Actual strength limit: 0.6
Reduced edge strength
High frequency details are retained by default 0.35 ~ 0.5
10.6 Acceptance criteria
Skin smoothens
The edges of the eyes, eyebrows, and mouth are not blurry
Hair edges are not blurry
No obvious plastic face will appear
An intensity of 0 is equal to the original image

11. SkinWhitenEffect: Whitening
11.1 Function description
Improves skin tone's brightness and cleanliness.
Parameters:
skinWhitening: 0...1
11.2 First version implementation strategy
When there is no skin mask, conservative full-image skin color optimization is used:
1. Slightly increase mid-tone brightness.
2. Reduce yellowness/dullness.
3. Protect highlights and avoid overexposure.
4. Keep the black area from being lifted too much.
11.3 Simplified formula ideas
luma = dot(color.rgb, vec3(0.299, 0.587, 0.114))
whitenWeight = smoothstep(0.2, 0.85, luma) * (1 - smoothstep(0.85, 1.0, luma))
color.rgb += whitenAmount * whitenWeight
The yellow color can be slightly reduced:
color.b += smallAmount
color.r += smallAmount * 0.5
11.4 Security restrictions
Actual strength limit: 0.5
Highlight area reduction effect
Dark area reduction effect
The skin mask must be connected later
11.5 Acceptance criteria
Brighter and cleaner complexion
The background is not overly brightened
Highlights are not overexposed
Not fake

12. SkinRosyEffect: rosy
12.1 Function description
Increase facial complexion.
Parameters:
skinRosy: 0...1
12.2 First version implementation strategy
Without skin mask, only slight color enhancement is done:
boost red channel
Slightly lowered green/blue balance
Limit scope based on brightness
12.3 Recommended strategies
rosyColor = vec3(1.0, 0.82, 0.82)
output = mix(color, color * rosyColor, rosyWeight * intensity)
Or:
color.r += 0.03 * intensity * skinLikeWeight
12.4 Security restrictions
Actual strength limit: 0.4
Don’t make the whole picture red
Don’t over-enhance the red color of your lips and clothing

13. SkinSharpenEffect/ColorSharpen: Clear Sharpening
13.1 Function description
Enhance facial features and image clarity.
Parameters:
skinSharpen: 0...1
13.2 Implementation strategy
Use simple unsharp mask:
blurred = blur(input)
detail = input - blurred
output = input + detail * sharpenAmount
MVP can do light sharpening in ColorPass.
13.3 Security restrictions
Actual strength limit: 0.4
Sharpening after dermabrasion
Don't enhance noise
Reduce sharpening in dark light scenes

14. LipColorEffect: Lip color enhancement
14.1 Function description
Enhances natural lip color without doing a full lipstick.
Parameters:
lipColor: 0...1
14.2 Dependence points
outerLips
innerLips
14.3 First version implementation strategy
Generate a rough lip mask using lip key points.
MVP simplifies:
Generate an elliptical area based on outerLips boundingRect
Exclude innerLips region, optional
Color enhancement:
Boost red/saturation
Retain original light and dark textures
Mixing method:
output = mix(input, enhancedLipColor, mask * lipColor)
14.4 Security restrictions
Actual strength limit: 0.5
Don’t look like a solid color patch
Do not apply it outside the teeth
Skip if there are no lips points

15. LUTFilterEffect: filter
15.1 Function description
Apply LUT style filters.
Parameters:
filterId: String?
filterIntensity: 0...1
15.2 Implementation process
filterId
    ↓
LUTLoader
    ↓
3D LUT Texture
    ↓
LUTPass
    ↓
filteredColor
    ↓
mix(original, filtered, filterIntensity)
15.3 Rules
filterId == nil: skip
filterIntensity == 0: skip
LUT not found: error thrown or downgraded without filter
LUT cannot be parsed every frame
15.4 Acceptance criteria
Intensity 0 is equal to the original image
Strength 1 is the full filter
Slider changes smoothly
Switching multiple filters without crashing
Resource cache is valid

16. Parameter combination order
Recommended rendering order:
1. FaceWarpPass
2. SkinPass
3. LipColor / MakeupPass
4. ColorPass
5. LUTPass
6. OutputPass
Reason:
Do the deformation first, then the skin and color to avoid deformation and stretching as a result of microdermabrasion.
The lip color is made after deformation to fit the current lip position.
The LUT is done last to unify the overall style.

17. Parameter conflict handling
17.1 Big eyes + eye distance
Question:
Both effects affect the peri-eye area.
Strategy:
First generate all eye control points.
Limit the total displacement when merging.
The influence radius of eyeDistance is slightly larger, and the influence radius of eyeSize is slightly smaller.
17.2 Face slimming + small face + V face
Question:
Superposition of multiple face shape parameters can easily lead to excessive deformation.
Strategy:
The total intensity of the face shape class is normalized and limited.
The total displacement does not exceed faceWidth * 0.12.
17.3 Slim nose + nose wing + nose tip
Question:
There are few points in the nose area, and it is easy to collapse after superposition.
Strategy:
nose total strength limit.
noseWingSlim first, noseSlim next, and noseTipSize last.
17.4 Mouth size + smile
Question:
The corners of the mouth are affected by both mouthSize and smile.
Strategy:
The total displacement limit of the mouth corner point.
The y displacement of smile is given priority, and the x/y displacement of mouthSize is weakened.

18. Downgrade strategy
18.1 No face
Skips all FaceWarpPass control points.
Moving on to filters/colors that don't rely on faces.
18.2 Some key points are missing
No eye points: Skip the eye effect.
No nose points: Skip the nose effect.
No lip points: Skip mouth and lip color.
No contour points: skip the face shape.
18.3 The face is too small
Reduce geometric deformation intensity.
Skip advanced effects.
18.4 Side view / wide angle
The first version can be roughly judged by the boundingBox and key point distribution.
Strategy:
When the yaw is too large, reduce the strength of the face, nose, and mouth.

19. Acceptance Test Atlas
Each effect must be tested in the following scenarios:
Positive face
Slight profile
round face
long face
wide face
small eyes
big eyes
Flat nose
wide nose
thin lips
thick lips
wear glasses
Bangs cover
dim light
strong light
front camera
rear camera
multiple faces

20. First version development sequence
Suggested order:
1. LUTFilterEffect
2. ColorPass / skinSharpen
3. SkinWhitenEffect
4. SkinRosyEffect
5. FaceWarpPass basic framework
6. EyeWarpProvider.eyeSize
7. FaceShapeWarpProvider.faceSlim
8. FaceShapeWarpProvider.faceSmall / faceVShape
9. ChinWarpProvider.chinLength
10. NoseWarpProvider.noseSlim
11. MouthWarpProvider.smile
12. Add eyeDistance / eyeYPosition / eyeTailLift
13. Add noseWingSlim / noseTipSize
14. Supplement mouthSize / mouthWidth
15. SkinSmoothEffect
16. LipColorEffect
Reason:
First do the effect that does not depend on the point, and quickly verify the RenderGraph.
Then do FaceWarpPass, first achieve the two logo effects of big eyes and slim face.
Finally complete the complete MVP parameters.

21. First version of Provider file planning
BeautyEffects/Warp/
├── WarpControlPoint.swift
├── WarpControlPointProvider.swift
├── FaceWarpEffect.swift
├── EyeWarpProvider.swift
├── FaceShapeWarpProvider.swift
├── ChinWarpProvider.swift
├── NoseWarpProvider.swift
└── MouthWarpProvider.swift
BeautyEffects/Skin/
├── SkinSmoothEffect.swift
├── SkinWhitenEffect.swift
├── SkinRosyEffect.swift
└── SkinSharpenEffect.swift
BeautyEffects/Color/
├── ColorAdjustmentEffect.swift
├── LUTFilterEffect.swift
└── FilterBlendEffect.swift
BeautyEffects/Makeup/
└── LipColorEffect.swift

22. First version of effect acceptance criteria
22.1 Basic effects
When the parameter is 0, the output is close to the original image.
The effect changes continuously as the parameter gradually increases.
There will be no serious image damage when the intensity is maximum.
When there are no key points, the corresponding effect will be automatically skipped.
22.2 Real-time performance
720p 30fps available.
1080p is available on mid- to high-end devices.
Big eyes + face slimming + whitening + LUT can be turned on at the same time without lagging.
22.3 Visual effects
Naturally big eyes.
Slimming the face does not stretch the background.
The nose is not flat.
The corners of his mouth are true.
Microdermabrasion is not plastic.
Whitening is not fake.
Ruddy but not red.
The filter does not have a serious color cast.

23. Subsequent advanced algorithm expansion
23.1 Advanced Eyes
Eye width
Eyes high
Open the inner corner of the eye
Out of the corner of the eye
lying silkworm
Eye light
Brighten the whites of the eyes
Contact lenses
23.2 Advanced skins
skin mask
facial features protection mask
Remove acne
Freckle removal
Nasal pattern
tear trough
Skin texture preserved
23.3 Advanced makeup
lipstick
blush
eye shadow
Eyeliner
eyelashes
eyebrows
Contour
Highlights
23.4 Advanced deformation
mesh warp
dense landmarks
face mesh
3D pose aware deformation

24. One sentence conclusion
The implementation of the first version of the algorithm should not pursue the number of functions, but ensure that the underlying model is correct:
All facial deformations generate WarpControlPoint and enter FaceWarpPass uniformly.
All color and skin effects are combined by Pass, avoiding one shader per parameter.
Each parameter has security strength, downgrade strategy, and acceptance criteria.
As long as this set of rules is stable, subsequent additions of advanced eyes, complete makeup, skin repair, and background segmentation can all be expanded on the same architecture.
