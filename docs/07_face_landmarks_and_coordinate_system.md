# 07. iOS Beauty SDK Face Landmarks and Coordinate System Design

iOS Beauty SDK Face Key Points and Coordinate System Design Document

1. Documentation goals

This document defines unified specifications for face detection, key point analysis, coordinate conversion, direction processing, front mirroring, point smoothing, and debugging drawing in BeautySDK.

Issues this document addresses:

How to convert Vision coordinates into image coordinates?
How to convert image coordinates to Metal Texture coordinates?
Where should front camera mirroring be handled?
How to unify the horizontal and vertical screen orientations?
How to deal with EXIF Orientation of album pictures?
What are the coordinates of the points for big eyes, slim face, and thin nose?
How can Debug Overlay ensure that the drawing points are not biased?

Core principles:

1. Coordinate transformation must be centralized in CoordinateMapper.
2. The algorithm module must not directly process Vision original coordinates.
3. The key points entering FaceWarpPass must already be Texture Normalized coordinates.
4. The Detection layer is responsible for unifying key point coordinates.
5. The Render layer only consumes the unified coordinates and no longer cares about Vision / UIKit / EXIF.
6. Debug Overlay uses separate Preview coordinate mapping to avoid polluting rendering coordinates.

⸻

2. Overview of coordinate systems

There are at least 5 sets of coordinate systems in the beauty SDK:

1. Vision Normalized coordinates
2. Image Pixel coordinates
3. Texture Normalized coordinates
4. Metal Pixel coordinates
5. Preview / SwiftUI coordinates

Also covered:

EXIF Orientation
AVCaptureVideoOrientation / videoRotationAngle
Front camera mirror
Video frame direction
Picture direction
Preview layer aspectFill / aspectFit crop

If not handled uniformly, it will lead to:

Key points upside down
The left and right eyes are reversed
Front camera mirroring error
Big eyes affect the outside of the face
Face slimming in the wrong direction
Misalignment of nose and mouth
Debug points look correct, but actual rendering is wrong

⸻

3. Definition of each coordinate system

3.1 Vision Normalized coordinates

The face boxes and keypoints returned by Vision are usually normalized coordinates.

Features:

x: 0 ... 1
y: 0 ... 1
The origin is usually in the lower left corner
Normalized relative to image area

Note:

VNFaceObservation.boundingBox is a normalized rect relative to the entire image.
VNFaceLandmarkRegion2D.normalizedPoints are normalized points relative to the face boundingBox.

In other words, the landmark point is not directly relative to the entire image, but relative to the face frame.

When converting, you must first:

landmark point in face box
        ↓
image normalized point
        ↓
image pixel / texture point

⸻

3.2 Image Normalized coordinates

A set of image normalized coordinates can be used internally in the SDK:

x: 0 ... 1
y: 0 ... 1
Origin: upper left corner, recommended
Direction: consistent with the input image display direction

Why the upper left corner is recommended:

Closer to UIKit/CoreGraphics/screen coordinate conventions.
Convenient Debug Overlay.

But when entering the Metal shader, it can also be unified into Texture Normalized coordinates.

⸻

3.3 Image Pixel coordinates

Image pixel coordinates:

x: 0 ... imageWidth
y: 0 ... imageHeight
Origin: upper left corner, recommended
Unit: pixel

Used for:

Calculate distance between key points
Calculate the radius of influence
Generate debug path
Calculate face size
Determine parameter strength based on image size

⸻

3.4 Texture Normalized coordinates

Recommended points to enter FaceWarpPass:

x: 0 ... 1
y: 0 ... 1
Origin: consistent with inputTexture sampling coordinates
Direction: consistent with the inputTexture content direction

These are the principal coordinates of the geometry deformation provider and Metal shader.

Requirements:

EyeWarpProvider
NoseWarpProvider
MouthWarpProvider
FaceShapeWarpProvider

The obtained BeautyFaceLandmarks must already be Texture Normalized coordinates.

They should no longer know Vision coordinates, and they should no longer handle mirroring.

⸻

3.5 Metal Pixel coordinates

Thread ids in Metal compute shaders are usually pixel coordinates:

uint2 gid

Corresponds to:

gid.x: 0 ... texture.width
gid.y: 0 ... texture.height

In shaders, it is often necessary to convert to normalized coordinate:

float2 uv = float2(gid) / float2(width, height);

Then do the sampling transformation according to the control points.

⸻

3.6 Preview / SwiftUI coordinates

Preview coordinates are screen display coordinates:

x: 0 ... viewWidth
y: 0 ... viewHeight
Origin: upper left corner

It will be affected by the following factors:

aspectFit
aspectFill
crop area
SafeArea
SwiftUI layout
Whether the front camera previews the image

Note:

Preview coordinates are only used for Debug Overlay / UI interaction.
Do not pass Preview coordinates to algorithms or Metal shaders.

⸻

4. SDK internal unified coordinate selection

4.1 Detection output coordinates

The BeautyFaceObservation output by BeautyDetection should contain the unified points.

Suggestions:

BeautyFaceObservation.boundingBox: Texture Normalized coordinates
BeautyFaceLandmarks: Texture Normalized coordinates

Additional reservations may also be made:

imagePixelBoundingBox
imagePixelLandmarks

But the first version of MVP recommended only exposing Texture Normalized coordinates to internal algorithms.

⸻

4.2 Unified data structure

public struct BeautyFaceObservation: Sendable {
    public let id: UUID
    public let boundingBox: CGRect
    public let landmarks: BeautyFaceLandmarks
    public let roll: Float?
    public let yaw: Float?
    public let confidence: Float
}

Agreement:

The boundingBox uses Texture Normalized coordinates.
All points in landmarks use Texture Normalized coordinates.
public struct BeautyFaceLandmarks: Sendable {
    public var faceContour: [SIMD2<Float>]
    public var leftEye: [SIMD2<Float>]
    public var rightEye: [SIMD2<Float>]
    public var leftEyebrow: [SIMD2<Float>]
    public var rightEyebrow: [SIMD2<Float>]
    public var nose: [SIMD2<Float>]
    public var noseCrest: [SIMD2<Float>]
    public var outerLips: [SIMD2<Float>]
    public var innerLips: [SIMD2<Float>]
    public var leftPupil: SIMD2<Float>?
    public var rightPupil: SIMD2<Float>?
}

⸻

5. Vision key point conversion process

5.1 Raw input

Vision returns:

VNFaceObservation.boundingBox
VNFaceLandmarks2D
VNFaceLandmarkRegion2D.normalizedPoints

Among them:

boundingBox: normalized rect relative to the entire image
landmark normalizedPoints: normalized points relative to face boundingBox

⸻

5.2 landmark to image normalized

For landmark points:

p.x = landmarkPoint.x
p.y = landmarkPoint.y

face bounding box：

box.origin.x
box.origin.y
box.width
box.height

Convert to whole image normalized:

imageX = box.origin.x + p.x * box.width
imageY = box.origin.y + p.y * box.height

At this time, it is still Vision normalized coordinates, usually the origin is in the lower left corner.

⸻

5.3 Vision lower left corner to upper left corner

If the SDK internally uses the upper left corner coordinates:

normalizedX = imageX
normalizedY = 1.0 - imageY

If you convert directly to Metal texture later, you need to confirm the texture content direction.

Unified recommendations:

CoordinateMapper uniformly outputs Texture Normalized coordinates.

⸻

5.4 Convert pseudocode

func convertVisionLandmarkPoint(
    _ point: CGPoint,
    faceBoundingBox: CGRect
) -> SIMD2<Float> {
    let imageX = faceBoundingBox.origin.x + point.x * faceBoundingBox.width
    let imageY = faceBoundingBox.origin.y + point.y * faceBoundingBox.height
    // Vision bottom-left -> top-left normalized
    let topLeftX = imageX
    let topLeftY = 1.0 - imageY
    return SIMD2(Float(topLeftX), Float(topLeftY))
}

Note:

This is just the basic conversion.
In fact, orientation and mirror must be combined.

⸻

6. Orientation direction processing

6.1 Why is the direction complicated?

Different input sources have different direction information:

Camera real-time frame: CVPixelBuffer itself usually does not have the concept of "aligned".
Album pictures: may have EXIF orientation.
Video files: May have track transform.
Front camera: The preview is usually mirrored, but the captured data is not necessarily mirrored.
Metal texture: It’s just pixel memory, I don’t know how the user wants to see it.

If orientation processing is not uniform, Vision detection and Metal rendering will be inconsistent.

⸻

6.2 Orientation of SDK API

External API:

public func process(
    pixelBuffer: CVPixelBuffer,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters
) throws -> CVPixelBuffer

The orientation here means:

Tells Vision / Detection how the current pixelBuffer should be interpreted as a forward image.

It does not necessarily mean that the output image is to be rotated.

⸻

6.3 Recommended strategies

Recommendations for the first edition:

1. The App side passes in the correct CGImagePropertyOrientation.
2. Vision uses this orientation for detection.
3. CoordinateMapper maps the points to the corresponding coordinates of the inputTexture according to the orientation.
4. RenderGraph is not responsible for rotating the image.
5. The Preview layer determines how to display it.

That is:

Detection is responsible for understanding the direction.
Render is responsible for processing according to texture coordinates.
Preview is responsible for visual presentation.

⸻

6.4 Common camera direction reference

The following needs to be tested in the demo and cannot be memorized by rote.

Usually the front vertical screen may be used:

.rightMirrored

Possible uses for rear portrait screen:

.right

But it actually depends on:

AVCaptureConnection.videoOrientation / videoRotationAngle
Whether to set isVideoMirrored
buffer original direction
How to display preview layer

Therefore, it must be verified by Debug Landmark Overlay.

⸻

7. Front camera mirroring processing

7.1 Three levels of mirroring

The front camera may involve three types of mirroring:

1. Whether the collected data is mirrored
2. Whether the preview screen is mirrored
3. Whether the export result is mirrored

These three cannot be mixed together.

⸻

7.2 Recommended principles

Internally the SDK only processes key points on the actual content of the input texture.
Whether Preview is mirrored is determined by the App display layer.
Whether Export is mirrored is determined by the App export policy.

That is to say:

If the inputTexture is mirrored, the landmarks must also correspond to the mirrored texture.
If the inputTexture is not mirrored, the landmarks must also correspond to the unmirrored texture.

⸻

7.3 Duplicate mirroring is prohibited

Prohibited:

Vision orientation has been mirrored
CoordinateMapper mirrors again
Preview overlay and mirror again
FaceWarpPass mirror again

Otherwise it will appear:

Left eye and right eye reversed
Face slimming in the wrong direction
Points look offset

⸻

7.4 Recommended configuration

BeautyConfiguration can add:

public struct BeautyConfiguration: Sendable {
    public var isInputMirrored: Bool
    public var isPreviewMirrored: Bool
}

But in the first version, the App can also first ensure that the orientation is passed in correctly.

It is more recommended to introduce explicit configuration later:

public struct BeautyFrameOrientation: Sendable {
    public let imageOrientation: CGImagePropertyOrientation
    public let isInputMirrored: Bool
    public let isPreviewMirrored: Bool
}

⸻

8. CoordinateMapper design

8.1 Responsibilities

CoordinateMapper is the only module responsible for coordinate transformation.

Responsible for:

Vision face box -> SDK boundingBox
Vision landmark -> Texture Normalized point
Texture point -> Preview point, used for Debug
Image point -> Texture point
Handle orientation
Handle mirror
Handling aspectFit/aspectFill

⸻

8.2 API design

public struct CoordinateMapper: Sendable {
    public let imageSize: CGSize
    public let textureSize: CGSize
    public let orientation: CGImagePropertyOrientation
    public let isInputMirrored: Bool
    public init(
        imageSize: CGSize,
        textureSize: CGSize,
        orientation: CGImagePropertyOrientation,
        isInputMirrored: Bool
    )
    public func mapFaceBoundingBox(
        _ boundingBox: CGRect
    ) -> CGRect
    public func mapLandmarkPoint(
        _ point: CGPoint,
        in faceBoundingBox: CGRect
    ) -> SIMD2<Float>
}

⸻

8.3 Preview Mapping API

Debug Overlay requires:

public struct PreviewCoordinateMapper: Sendable {
    public let textureSize: CGSize
    public let previewSize: CGSize
    public let contentMode: BeautyPreviewContentMode
    public let isPreviewMirrored: Bool
    public func mapTexturePointToPreview(
        _ point: SIMD2<Float>
    ) -> CGPoint
}
public enum BeautyPreviewContentMode: Sendable {
    case aspectFit
    case aspectFill
}

Note:

PreviewCoordinateMapper is only used for UI and Debug.
Don't make the algorithm depend on it.

⸻

9. AspectFit / AspectFill preview mapping

9.1 Why is it needed

The camera preview is usually not exactly equal to the image ratio.

For example:

Image: 1080x1920
View：393 x 852

If aspectFill is used, there will be cropping.

Debug point drawing must consider clipping, otherwise it will look offset.

⸻

9.2 AspectFit

Calculate scaling:

scale = min(viewWidth / imageWidth, viewHeight / imageHeight)
scaledWidth = imageWidth * scale
scaledHeight = imageHeight * scale
offsetX = (viewWidth - scaledWidth) / 2
offsetY = (viewHeight - scaledHeight) / 2

Mapping:

previewX = normalizedX * scaledWidth + offsetX
previewY = normalizedY * scaledHeight + offsetY

⸻

9.3 AspectFill

Calculate scaling:

scale = max(viewWidth / imageWidth, viewHeight / imageHeight)
scaledWidth = imageWidth * scale
scaledHeight = imageHeight * scale
offsetX = (viewWidth - scaledWidth) / 2
offsetY = (viewHeight - scaledHeight) / 2

Mapping:

previewX = normalizedX * scaledWidth + offsetX
previewY = normalizedY * scaledHeight + offsetY

Note:

offset may be negative, indicating that the content is cropped.

⸻

9.4 Image preview

If previewing an image:

previewX = viewWidth - previewX

Note:

Only done in PreviewCoordinateMapper.
Do not affect the Texture Normalized points.

⸻

10. Face key point model

10.1 Sources of key points in the first edition

First version using Vision:

VNDetectFaceLandmarksRequest
VNFaceObservation
VNFaceLandmarks2D

Available areas:

faceContour
leftEye
rightEye
leftEyebrow
rightEyebrow
nose
noseCrest
outerLips
innerLips
leftPupil, availability depends on system and input
rightPupil, availability depends on system and input

⸻

10.2 Internal key point structure

public struct BeautyFaceLandmarks: Sendable {
    public var faceContour: [SIMD2<Float>]
    public var leftEye: [SIMD2<Float>]
    public var rightEye: [SIMD2<Float>]
    public var leftEyebrow: [SIMD2<Float>]
    public var rightEyebrow: [SIMD2<Float>]
    public var nose: [SIMD2<Float>]
    public var noseCrest: [SIMD2<Float>]
    public var outerLips: [SIMD2<Float>]
    public var innerLips: [SIMD2<Float>]
    public var leftPupil: SIMD2<Float>?
    public var rightPupil: SIMD2<Float>?
}

⸻

10.3 Key point availability rules

Not every frame and every face can get all the points.

Therefore the algorithm module must be fault tolerant:

No eye points: skip the eye parameter.
No nose points: skip the nose parameter.
No mouth point: skip the mouth parameter.
No face outline: skip face shape parameter.
Confidence is too low: skip strong deformation.

Do not force unwrap.

⸻

11. Face selection strategy

11.1 The main face strategy of the first moderator

The first version suggested treating only the main face.

Main face selection priority:

1. The largest face
2. The face closest to the center of the screen
3. Face tracked in the previous frame

MVP simplified:

Select the face with the largest area.

⸻

11.2 Multi-face strategy

When multiple faces are later supported:

maximumFaceCount

Limit the maximum number of processes.

Multiple face sorting:

Main face priority
Area sorting
Center distance sorting

Strategy:

performance: up to 1 face
balanced: up to 1~3 faces
quality: up to 3~5 faces

⸻

12. FaceTrackingState design

12.1 Why tracking is needed

Vision returns faces per frame without stable IDs.

If used directly, it will result in:

Identity jump when there are multiple faces
Point smoothing mismatch
Beauty parameter effect object jumps

Hence the need for FaceTrackingState.

⸻

12.2 Simplified implementation of the first version

The first version can only process the main face, without the need for complex IDs.

Status:

public struct FaceTrackingState {
    public var lastFace: BeautyFaceObservation?
    public var missingFrameCount: Int
}

Rules:

Main face detected: update lastFace.
1~3 consecutive frames lost: continue to use lastFace, but reduce confidence.
Threshold exceeded: clear lastFace.

⸻

12.3 Subsequent multi-face matching

Can be used:

boundingBox IoU
Center point distance
face area
landmark distance

Assign a temporary ID to each face.

⸻

13. LandmarkSmoother Design

13.1 Objectives

Reduce key point jitter.

Appears without smoothing:

Eyes suddenly big and small
Face slimming edge jitter
Nose deformation and drift
lipstick drift
Smile trembling at the corners of the mouth

⸻

13.2 First version of algorithm: EMA

Exponential moving average:

smoothed = previous * (1 - alpha) + current * alpha

Suggestions:

alpha = 0.35 ~ 0.6

The larger the alpha:

Fast response, but more obvious jitter

The smaller the alpha:

More stable, but more noticeable delays

⸻

13.3 API design

public final class LandmarkSmoother {
    private var previousFace: BeautyFaceObservation?
    private let alpha: Float
    public init(alpha: Float = 0.45)
    public func smooth(
        _ faces: [BeautyFaceObservation]
    ) -> [BeautyFaceObservation]
    public func reset()
}

⸻

13.4 Smoothing rules

The number of key points of the same type is consistent: point-by-point smoothing.
Inconsistent quantities: use the current point, no smoothing.
Missing points: Keep available points.
Low confidence: Reduce alpha or skip strong deformations.
The face changes too much: reset the smoothing state.

⸻

14. DetectionScheduler design

14.1 Objectives

Detection should not be forced to run every frame.

Recommended:

Render 30fps
Detection 10~15fps

That is:

Detect every 2~3 frames
Intermediate frames multiplex smoothed key points

⸻

14.2 API design

public final class DetectionScheduler {
    private let detector: FaceDetecting
    private let smoother: LandmarkSmoother
    private let frameInterval: Int
    private var frameIndex: Int = 0
    private var lastFaces: [BeautyFaceObservation] = []
    public init(
        detector: FaceDetecting,
        smoother: LandmarkSmoother,
        frameInterval: Int
    )
    public func currentFaces(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) throws -> [BeautyFaceObservation]
    public func reset()
}

⸻

14.3 Scheduling rules

frameIndex % frameInterval == 0: Run detection.
Otherwise: return lastFaces.
Detection failed: short return lastFaces.
Consecutive failures exceed threshold: Return empty array.

⸻

15. FaceDetecting Protocol

15.1 Design goals

Detection implementations must be replaceable.

First edition:

VisionFaceDetector

Follow-up:

CoreMLFaceDetector
DenseLandmarkDetector
FaceMeshDetector

⸻

15.2 API

public protocol FaceDetecting {
    func detect(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) throws -> [BeautyFaceObservation]
    func reset()
}

⸻

16. VisionFaceDetector design

16.1 Responsibilities

Create VNDetectFaceLandmarksRequest
Execute VNImageRequestHandler
Parse VNFaceObservation
Parse landmarks
Call CoordinateMapper
Output BeautyFaceObservation

⸻

16.2 Pseudocode

public final class VisionFaceDetector: FaceDetecting {
    private let configuration: BeautyConfiguration
    public init(configuration: BeautyConfiguration) {
        self.configuration = configuration
    }
    public func detect(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) throws -> [BeautyFaceObservation] {
        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(
            CVPixelBuffer: pixelBuffer,
            orientation: orientation,
            options: [:]
        )
        try handler.perform([request])
        guard let observations = request.results else {
            return []
        }
        let mapper = CoordinateMapper(
            imageSize: CGSize(
                width: CVPixelBufferGetWidth(pixelBuffer),
                height: CVPixelBufferGetHeight(pixelBuffer)
            ),
            textureSize: CGSize(
                width: CVPixelBufferGetWidth(pixelBuffer),
                height: CVPixelBufferGetHeight(pixelBuffer)
            ),
            orientation: orientation,
            isInputMirrored: false
        )
        return observations
            .sorted(by: { $0.boundingBox.width * $0.boundingBox.height > $1.boundingBox.width * $1.boundingBox.height })
            .prefix(configuration.maximumFaceCount)
            .compactMap { observation in
                mapObservation(observation, mapper: mapper)
            }
    }
    public func reset() {}
}

⸻

17. Key point analysis specifications

17.1 Security analysis

Vision's landmark region may be empty.

Must be handled safely:

let leftEye = landmarks.leftEye?.normalizedPoints ?? []

Do not force unpack.

⸻

17.2 Point sequence

The order of points returned by Vision may not meet the needs of some algorithms.

If the algorithm depends on:

left eye head
left eye tail
corner of mouth
chin point
alar point

A separate landmark helper needs to be created:

public struct LandmarkGeometryHelper {
    public static func center(of points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func leftMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func rightMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func topMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func bottomMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
}

Don't write cluttered logic over and over again in Provider.

⸻

18. LandmarkGeometryHelper

18.1 Common geometric calculations

public enum LandmarkGeometryHelper {
    public static func center(
        of points: [SIMD2<Float>]
    ) -> SIMD2<Float>? {
        guard !points.isEmpty else { return nil }
        let sum = points.reduce(SIMD2<Float>(0, 0), +)
        return sum / Float(points.count)
    }
    public static func distance(
        _ a: SIMD2<Float>,
        _ b: SIMD2<Float>
    ) -> Float {
        simd_distance(a, b)
    }
    public static func boundingRect(
        of points: [SIMD2<Float>]
    ) -> CGRect? {
        guard let first = points.first else { return nil }
        var minX = first.x
        var maxX = first.x
        var minY = first.y
        var maxY = first.y
        for p in points.dropFirst() {
            minX = min(minX, p.x)
            maxX = max(maxX, p.x)
            minY = min(minY, p.y)
            maxY = max(maxY, p.y)
        }
        return CGRect(
            x: CGFloat(minX),
            y: CGFloat(minY),
            width: CGFloat(maxX - minX),
            height: CGFloat(maxY - minY)
        )
    }
}

⸻

19. Each algorithm depends on key points

19.1 Eye function

eyeSize

Dependencies:

leftEye
rightEye

Optional:

leftPupil
rightPupil

Need to calculate:

eye center
eye width
eye height
radius of influence

⸻

eyeDistance

Dependencies:

leftEye center
rightEye center
face center

⸻

eyeYPosition

Dependencies:

leftEye
rightEye
face boundingBox

⸻

eyeTailLift

Dependencies:

leftEye outer corner
rightEye outer corner

When there are insufficient Vision points, you can use:

leftEye leftmost/rightmost point
rightEye leftmost/rightmost point

Determine the head and tail of the eyes based on the direction of the left and right faces.

⸻

19.2 Face shape function

faceSlim

Dependencies:

faceContour
face center

Need an estimate:

left cheek point
Right cheek point
mandibular point

⸻

faceSmall

Dependencies:

faceContour
boundingBox
face center

⸻

faceVShape

Dependencies:

faceContour
chin point
jaw contour

⸻

chinLength

Dependencies:

faceContour bottom point
outerLips
face center

⸻

19.3 Nose function

noseSlim

Dependencies:

nose
noseCrest

Need an estimate:

center line of nose bridge
Nose left and right borders
Nose area

⸻

noseWingSlim

Dependencies:

nose lower points
noseCrest

Note:

Vision alar points are not dense enough.
The first version only does basic effects.

⸻

noseTipSize

Dependencies:

nose bottom area
nose center

⸻

19.4 Mouth functions

mouthSize

Dependencies:

outerLips
innerLips

⸻

mouthWidth

Dependencies:

outerLips left corner
outerLips right corner
mouth center

⸻

smile

Dependencies:

left mouth corner
right mouth corner
outerLips

⸻

lipColor

Dependencies:

outerLips
innerLips

Follow-up needs:

lip mask

⸻

20. Debug Overlay Specification

20.1 Purpose

Debug Overlay for verification:

Check whether the test is accurate
Is the coordinate conversion correct?
Is the front image correct?
Is the horizontal and vertical screen correct?
Preview whether cropping is processed correctly

⸻

20.2 Drawing content

Suggested drawing:

face boundingBox
faceContour
leftEye
rightEye
nose
noseCrest
outerLips
innerLips
key center point
control points, optional

⸻

20.3 Color suggestions

faceContour: green
leftEye/rightEye: blue
nose: yellow
mouth: red
control points source: white
control points target: purple

The specific color is determined by the Demo App and does not belong to the core of the SDK.

⸻

20.4 Debug coordinate process

Texture Normalized Landmark
        ↓
PreviewCoordinateMapper
        ↓
SwiftUI / UIKit Overlay Point
        ↓
draw

Don't:

Vision original points are drawn directly to SwiftUI

⸻

21. Coordinate test case

Test diagrams and test scenarios must be established.

21.1 Camera direction test

Front vertical screen
Rear vertical screen
Front horizontal screen left
Front horizontal screen right
Rear horizontal screen left
Rear horizontal screen right

Acceptance:

The dots accurately cover the facial features.
The left and right eyes are not opposite.
The mouth and nose are straight.

⸻

21.2 Image orientation test

Test EXIF:

up
down
left
right
upMirrored
downMirrored
leftMirrored
rightMirrored

Acceptance:

The detection results are consistent with the visual direction of the picture.

⸻

21.3 Preview ContentMode test

aspectFit
aspectFill
different view sizes
Different picture ratios

Acceptance:

The Debug point is aligned with the preview content.

⸻

21.4 Algorithm coordinate test

Big eyes act on the eye area
Face slimming works on the cheek area
Nose slimming works on the nose area
Mouth corner acts on the mouth corner area

Acceptance:

There is no obvious deformation.

⸻

22. Common errors and troubleshooting

22.1 point is upside down

Possible reasons:

Vision bottom-left does not turn top-left
Orientation error
The input texture direction is inconsistent with the detection direction.

Troubleshooting:

First draw the face boundingBox
Draw eyes again
Check if y requires 1 - y

⸻

22.2 Right and left eyes are reversed

Possible reasons:

Pre-mirror processing duplicates
orientation uses mirrored, but mirrors manually
Preview mirror and detection mirror confusion

Troubleshooting:

Use a face with obvious left and right features to test.
Turn off the Preview mirror and Coordinate mirror respectively.

⸻

22.3 Debug point is right, but beauty is wrong

Possible reasons:

Debug uses Preview coordinates, and algorithm uses Texture coordinates. The conversions between the two are different.
FaceWarpPass does additional coordinate transformation internally.
The actual direction of inputTexture is inconsistent with landmarks.

Troubleshooting:

Draw Texture Normalized points directly to an intermediate texture.
Confirm that the point seen by the Render layer is consistent with the Debug Overlay.

⸻

22.4 Vertical screen is right, horizontal screen is wrong

Possible reasons:

orientation is not updated as the device changes
Texture width / height usage error
CoordinateMapper does not handle rotation
Preview aspectFill cropping not processed

⸻

22.5 Pre-preview is correct, export is wrong

Possible reasons:

The preview is mirrored, but the export is not
Or export and do a mirror

Suggestions:

Make it clear that previewMirror and exportMirror are two strategies.

⸻

23. Relationship with FaceWarpPass

FaceWarpPass only receives unified landmarks.

It assumes:

1. All points are Texture Normalized coordinates.
2. The point direction is consistent with inputTexture.
3. The x/y range is 0...1.
4. The mirror has been processed.
5. orientation has been processed.

Therefore FaceWarpPass should not appear:

CGImagePropertyOrientation
Vision boundingBox
Preview size
SwiftUI view size
isVideoMirrored

If FaceWarpPass requires these, the coordinate system bounds are wrong.

⸻

24. Relationship with SwiftUI Demo

SwiftUI Demo can have:

LandmarkDebugOverlay
ControlPointDebugOverlay
PerformanceOverlay

But these belong to the App layer.

The way Demo obtains debug data can be:

SDK debug result
Internal debug callback
Or use detection debug target directly inside Demo

First edition suggestions:

First obtain BeautyFaceObservation through SDK Debug Mode in Demo App.
Then use PreviewCoordinateMapper to draw.

Don't let SwiftUI View call Vision directly.

⸻

25. First version implementation tasks

25.1 Required documents

FaceDetecting.swift
VisionFaceDetector.swift
BeautyFaceObservation.swift
BeautyFaceLandmarks.swift
CoordinateMapper.swift
PreviewCoordinateMapper.swift
LandmarkGeometryHelper.swift
LandmarkSmoother.swift
DetectionScheduler.swift
FaceTrackingState.swift

⸻

25.2 Must-do features

Vision face detection
Vision landmarks analysis
Vision point -> Texture Normalized point
Main face selection
Detect throttling
Point smoothing
Debug Overlay coordinate conversion
Front/rear vertical screen test
Album picture orientation test

⸻

25.3 Acceptance criteria

1. The key points of the front face accurately cover the facial features.
2. The front camera does not reflect left and right.
3. The rear camera is in the correct direction.
4. At least there is a clear processing strategy for horizontal and vertical screens.
5. Debug Overlay is aligned with the preview.
6. After using the FaceWarpPass point, the big eyes will act on the eye area.
7. All deformation effects are automatically skipped when there are no faces.
8. Point jitter is within the acceptable range.

⸻

26. Follow-up upgrade direction

26.1 Core ML High Density Keypoints

When the Vision points are not precise enough, introduce:

DenseLandmarkDetector
FaceMeshDetector

Replace with the same protocol:

FaceDetecting

Does not affect the upper FaceWarpProvider.

⸻

26.2 Face Mesh

Advanced features require:

Dense facial contours
Nose/nostril points
Lip lines are tighter
eyebrow area
hairline
facial mesh triangulation

Used for:

Advanced thin nose
complete lipstick
eye shadow eyeliner
hairline
Advanced face shape

⸻

26.3 3D Pose

It can be enhanced in the future:

yaw
pitch
roll
face angle

Used for:

profile downgrade
Makeup perspective correction
sticker gesture
Prevent strong deformation of faces at large angles

⸻

27. One sentence conclusion

The most important thing about the face key point system is not "whether it can detect the face", but:

All points seen by the algorithm must be exactly aligned with the current inputTexture.

Therefore the first version must be done first:

VisionFaceDetector
CoordinateMapper
LandmarkSmoother
PreviewCoordinateMapper
Debug Overlay

As long as the coordinate system is stable, big eyes, thin face, thin nose, mouth corners, and makeup can continue to expand stably.