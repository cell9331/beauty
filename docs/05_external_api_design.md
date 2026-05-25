# 05. iOS Beauty SDK External API Design

iOS Beauty SDK External API Design Document

1. Documentation goals

This document defines the public API exposed by BeautySDK to App integrators.

Goal:

1. App integration is simple.
2. The API is stable, clear, and testable.
3. Do not expose internal Metal / Vision / Core ML details.
4. Support real-time camera, image processing, and subsequent video export.
5. Support parameter preset, resource loading, error handling, and performance configuration.
6. The SDK does not include UI, and SwiftUI/UIKit UI is implemented by the App itself.

Core principles:

App only needs to care about: input image + parameters + output results.
The SDK is internally responsible for: detection, coordinates, rendering, resources, algorithms, and performance scheduling.

⸻

2. External module

The App side only needs:

import BeautySDK

It is not recommended that App directly import internal Target:

import BeautyCore
import BeautyRender
import BeautyDetection
import BeautyEffects
import BeautyResources

Internal Target can exist, but is aggregated externally through BeautySDK.

⸻

3. API Overview

The first version of the external API is divided into the following categories:

1. Engine main entrance
2. Configuration configuration
3. Parameters
4. Preset
5. Resource resource loading
6. Image Processing
7. Realtime Frame Processing Real-time frame processing
8. Video Processing Video processing, subsequent versions
9. Error error handling
10. Logging/Performance Debugging and performance

Highlights of the first version of MVP:

BeautyEngine
BeautyConfiguration
BeautyParameters
BeautyPreset
BeautyPresetLoader
BeautyError
BeautyProcessingResult

⸻

4. BeautyEngine

4.1 Positioning

BeautyEngine is the only core processing entrance of the SDK.

Responsible for:

1. Initialize the rendering pipeline.
2. Initialize the detection module.
3. Receive input image.
4. Receive parameters.
5. Scheduling detection, rendering, and effect processing.
6. Output the processing results.
7. Manage internal state.

Not responsible for:

1. Camera Session creation.
2. SwiftUI page.
3. Parameter slider.
4. Take photo button.
5. Album selection.
6. App business status.

⸻

4.2 API definition

public final class BeautyEngine {
    public init(configuration: BeautyConfiguration = .default) throws
    public func process(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CVPixelBuffer
    public func process(
        image: CIImage,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CIImage
    public func reset()
}

⸻

4.3 Initialization

let configuration = BeautyConfiguration.default
let engine = try BeautyEngine(configuration: configuration)

Situations in which initialization may fail:

Metal is not available
CommandQueue creation failed
Shader loading failed
PixelBufferPool creation failed
Resource initialization failed

Therefore initialization uses throws.

⸻

4.4 Real-time frame processing

let outputPixelBuffer = try engine.process(
    pixelBuffer: inputPixelBuffer,
    orientation: .right,
    parameters: parameters
)

Usage scenarios:

Camera live preview
Real-time recording pre-processing
Video call frame processing
Live push frame processing

Rules:

1. Do not call high-frequency real-time processing in the main thread.
2. Do not pass CMSampleBuffer to the SDK for a long time.
3. The App side should take out the CVPixelBuffer from CMSampleBuffer and pass it in.
4. The SDK returns a new CVPixelBuffer or a CVPixelBuffer in the internal multiplexing pool.
5. App should not modify the returned PixelBuffer content.

⸻

4.5 Image processing

let outputImage = try engine.process(
    image: inputCIImage,
    orientation: .up,
    parameters: parameters
)

Usage scenarios:

Album picture editing
Editing after taking photos
Avatar generation
Batch image processing

Rules:

1. Image processing allows higher quality than real-time frames.
2. You can use quality mode for image processing.
3. Large image processing cannot block the main thread.
4. The App side is responsible for the final export of JPEG / PNG / HEIF.

⸻

4.6 reset

engine.reset()

Function:

Clear face tracking status
Clear point smoothing status
Clear detection cache
Clear temporary rendering state
Reset internal frame count

Calling scenario:

Switch front and rear cameras
Switch video source
Re-enter the camera page
Picture switching
User closes edit page
Detect status anomalies

⸻

5. BeautyConfiguration

5.1 Positioning

BeautyConfiguration is used to control the running strategy of the SDK.

It is not a beauty parameter, but a processing configuration.

For example:

Maximum number of faces
Detection frequency
Handling quality
Whether to enable face tracking
Preferred processing size
Whether to output performance statistics

⸻

5.2 API definition

public struct BeautyConfiguration: Sendable {
    public var preferredProcessingSize: CGSize?
    public var maximumFaceCount: Int
    public var enableFaceTracking: Bool
    public var detectionFrameInterval: Int
    public var renderQuality: BeautyRenderQuality
    public var enablePerformanceLog: Bool
    public var enableDebugMode: Bool
    public static let `default`: BeautyConfiguration
    public init(
        preferredProcessingSize: CGSize? = nil,
        maximumFaceCount: Int = 1,
        enableFaceTracking: Bool = true,
        detectionFrameInterval: Int = 3,
        renderQuality: BeautyRenderQuality = .balanced,
        enablePerformanceLog: Bool = false,
        enableDebugMode: Bool = false
    )
}

⸻

5.3 BeautyRenderQuality

public enum BeautyRenderQuality: String, Codable, Sendable {
    case performance
    case balanced
    case quality
}

performance

Suitable for:

low-end devices
Live broadcast
video call
long running

Strategy:

lower processing resolution
Lower detection frequency
Turn off advanced effects
Limit the maximum number of faces

balanced

Suitable for:

Default camera preview
Ordinary selfie
Short video recording

Strategy:

Quality and performance balance
Recommended by default

quality

Suitable for:

Picture editing
Post-photography processing
High-end equipment
Offline video export

Strategy:

Higher processing resolution
Higher quality microdermabrasion
Allows for more complex effects

⸻

5.4 Configuration example

Default configuration

let engine = try BeautyEngine(configuration: .default)

Live camera performance prioritized

let configuration = BeautyConfiguration(
    preferredProcessingSize: CGSize(width: 720, height: 1280),
    maximumFaceCount: 1,
    enableFaceTracking: true,
    detectionFrameInterval: 3,
    renderQuality: .performance,
    enablePerformanceLog: false,
    enableDebugMode: false
)
let engine = try BeautyEngine(configuration: configuration)

Picture editing quality is priority

let configuration = BeautyConfiguration(
    preferredProcessingSize: nil,
    maximumFaceCount: 1,
    enableFaceTracking: false,
    detectionFrameInterval: 1,
    renderQuality: .quality,
    enablePerformanceLog: true,
    enableDebugMode: false
)
let engine = try BeautyEngine(configuration: configuration)

⸻

6. BeautyParameters

6.1 Positioning

BeautyParameters represents the current beauty effect parameters.

It should:

Codable
Equatable
Sendable
No effect by default
can be saved
Can be loaded from preset
Can be modified in real time

⸻

6.2 API definition

public struct BeautyParameters: Codable, Equatable, Sendable {
    // Skin
    public var skinSmoothing: Float
    public var skinWhitening: Float
    public var skinRosy: Float
    public var skinSharpen: Float
    // Face Shape
    public var faceSlim: Float
    public var faceSmall: Float
    public var faceVShape: Float
    public var jawSlim: Float
    public var chinLength: Float
    // Eyes
    public var eyeSize: Float
    public var eyeDistance: Float
    public var eyeYPosition: Float
    public var eyeTailLift: Float
    // Nose
    public var noseSlim: Float
    public var noseWingSlim: Float
    public var noseTipSize: Float
    public var noseBridge: Float
    // Mouth
    public var mouthSize: Float
    public var mouthWidth: Float
    public var smile: Float
    public var lipColor: Float
    // Filter
    public var filterId: String?
    public var filterIntensity: Float
    public init(...)
}

⸻

6.3 Default parameters

let parameters = BeautyParameters()

Default state:

All Float parameters are 0
filterId is nil
filterIntensity is 0

This means:

No beauty
no change
no filter
The output should be close to the original image

⸻

6.4 Parameter range

Enhanced parameters: 0.0 ... 1.0
Bidirectional parameters: -1.0 ... 1.0

The SDK will perform a secondary clamp internally.

The App side should also ensure that the incoming legal range is passed.

⸻

6.5 Parameter update method

It is recommended to use value type status on the App side:

@Published var parameters = BeautyParameters()

or SwiftUI Observation:

@Observable
final class BeautyParameterStore {
    var parameters = BeautyParameters()
}

Slider update:

parameters.eyeSize = sliderValue / 100.0

⸻

7. BeautyPreset

7.1 Positioning

BeautyPreset represents a set of beauty parameter configurations.

Used for:

natural
clear
Exquisite
Boys are natural
Natural ID photo
sweet

⸻

7.2 API definition

public struct BeautyPreset: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let version: String
    public let parameters: BeautyParameters
    public init(
        id: String,
        name: String,
        version: String,
        parameters: BeautyParameters
    )
}

⸻

7.3 JSON example

The complete fields and examples of the default JSON are maintained in the "Preset JSON Examples" chapter of the "BeautyParameters Parameter Table".

The API document only restricts reading methods and error behaviors to avoid repeated maintenance of the same default content in multiple documents.

⸻

8. BeautyPresetLoader

8.1 Positioning

BeautyPresetLoader is responsible for loading the preset JSON built in the SDK or customized by the app.

⸻

8.2 API definition

public struct BeautyPresetLoader {
    public init()
    public func loadBuiltInPresets() throws -> [BeautyPreset]
    public func loadPreset(from url: URL) throws -> BeautyPreset
    public func loadPresets(from directoryURL: URL) throws -> [BeautyPreset]
    public func decodePreset(from data: Data) throws -> BeautyPreset
}

⸻

8.3 Usage examples

let loader = BeautyPresetLoader()
let presets = try loader.loadBuiltInPresets()
let natural = presets.first { $0.id == "natural_01" }
parameters = natural?.parameters ?? BeautyParameters()

⸻

9. Resource API

9.1 First version resource scope

The first edition resources mainly include:

LUT filter
Preset JSON

Subsequent expansion:

Makeup Package
Background Resource
Sticker Resource
Core ML Model

⸻

9.2 BeautyResourceManager

The first version can not expose complex resource managers and automatically load resources internally.

If you need app custom resources, you can provide:

public final class BeautyResourceManager {
    public func registerLUT(
        id: String,
        url: URL
    ) throws
    public func unregisterLUT(id: String)
    public func containsLUT(id: String) -> Bool
}

Suggestions:

1.0 You can not expose BeautyResourceManager first.
Custom resource registration will be opened in 1.5 or 2.0.

⸻

10. Image processing API

10.1 Basic API

public func process(
    image: CIImage,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters
) throws -> CIImage

⸻

10.2 Is the UIImage extension provided?

The SDK core is not recommended to rely on UIKit.

However, for convenience of access, optional extension Target can be provided separately:

BeautyUIKitSupport

Which provides:

public extension BeautyEngine {
    func process(
        UIImage: UIImage,
        parameters: BeautyParameters
    ) throws -> UIImage
}

First edition suggestions:

The core SDK does not provide the UIImage API.
Demo App does UIImage <-> CIImage conversion by itself.

Reason:

Keep the core SDK clean.
Avoid misuse of UIImage for live links.

⸻

11. Real-time camera access API

11.1 SDK does not create AVCaptureSession

The SDK is not responsible for creating the camera.

The App side is responsible for:

AVCaptureSession
AVCaptureDeviceInput
AVCaptureVideoDataOutput
Permission application
Switch between front and rear cameras
photo button
record button

The SDK is only responsible for processing the CVPixelBuffer passed in by the App.

⸻

11.2 Typical access on App side

final class CameraBeautyPipeline: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let engine: BeautyEngine
    private var parameters = BeautyParameters()
    init(engine: BeautyEngine) {
        self.engine = engine
    }
    func update(parameters: BeautyParameters) {
        self.parameters = parameters
    }
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        do {
            let outputBuffer = try engine.process(
                pixelBuffer: pixelBuffer,
                orientation: .right,
                parameters: parameters
            )
            // The App side is responsible for displaying the outputBuffer to MetalPreviewView or sending it to the encoder
        } catch {
            // The App side decides the downgrade strategy, such as displaying the original frame
        }
    }
}

⸻

11.3 Real-time access rules

1. Do not process video frames on the main thread.
2. Do not hold CMSampleBuffer for a long time.
3. Do not do UIImage conversion in captureOutput.
4. Parameters update must be thread-safe.
5. The App can display the original frame when processing fails.
6. Call engine.reset() when switching cameras.

⸻

12. Output result design

12.1 The first version directly returns the output object

The first version of the API could simply return:

CVPixelBuffer
CIImage

Advantages:

simple
Easy to use
Meet the MVP

⸻

12.2 BeautyProcessingResult can be expanded later

In order to return more information, you can introduce:

public struct BeautyProcessingResult<Output>: Sendable {
    public let output: Output
    public let faces: [BeautyFaceInfo]
    public let performance: BeautyPerformanceMetrics?
    public let warnings: [BeautyWarning]
}

BeautyFaceInfo

Simple facial information after desensitization can be exposed to the outside world:

public struct BeautyFaceInfo: Sendable {
    public let boundingBox: CGRect
    public let confidence: Float
}

It is not recommended to expose complete internal landmarks to the outside world unless a Debug API is provided.

⸻

13. Error handling API

13.1 BeautyError

public enum BeautyError: Error, Sendable {
    case metalUnavailable
    case commandQueueCreationFailed
    case textureCreationFailed
    case pixelBufferCreationFailed
    case shaderFunctionNotFound(String)
    case invalidInput
    case unsupportedPixelFormat
    case resourceNotFound(String)
    case presetDecodeFailed(String)
    case lutDecodeFailed(String)
    case renderFailed(String)
    case detectionFailed(String)
}

⸻

13.2 Error handling suggestions

Real-time processing on the App side:

do {
    let output = try engine.process(
        pixelBuffer: pixelBuffer,
        orientation: orientation,
        parameters: parameters
    )
    display(output)
} catch {
    display(pixelBuffer) //Downgrade display of original frame
}

Image processing:

do {
    let output = try engine.process(
        image: image,
        orientation: orientation,
        parameters: parameters
    )
    save(output)
} catch {
    showError(error)
}

⸻

14. Log API

14.1 BeautyLogLevel

public enum BeautyLogLevel: Int, Codable, Sendable {
    case none
    case error
    case warning
    case info
    case debug
}

14.2 Configuration method

public struct BeautyConfiguration: Sendable {
    public var logLevel: BeautyLogLevel
}

Default:

release：error
debug: warning or info

Log rules:

Don't export user privacy.
Do not output the image path.
Don't output large amounts of logs per frame.
Performance logs must be turnable.

⸻

15. Performance Statistics API

15.1 BeautyPerformanceMetrics

Subsequent versions can be opened:

public struct BeautyPerformanceMetrics: Sendable {
    public let totalFrameTime: TimeInterval
    public let detectionTime: TimeInterval
    public let renderTime: TimeInterval
    public let faceCount: Int
    public let frameIndex: Int
}

15.2 How to obtain

The first version recommends using debug callbacks or logs, not as a strong dependency on the main API.

Later available:

public var performanceHandler: ((BeautyPerformanceMetrics) -> Void)?

or:

public func processWithResult(...) throws -> BeautyProcessingResult<CVPixelBuffer>

⸻

16. Debug API

16.1 Debug capability

Debug mode can support:

Return to face frame
Return to key points
Return current FPS
Time taken to return each Pass
Output intermediate texture, internal tools only

16.2 First Edition Recommendations

The first version does not expose the complete Debug API to ordinary integrators.

Internal switches available:

public var enableDebugMode: Bool

App Demo can draw landmarks through internal modules or Debug Target.

⸻

17. Threads and life cycle specifications

17.1 BeautyEngine life cycle

Suggestions:

The camera page creates a BeautyEngine.
Image editing pages can be created independently from BeautyEngine.
Don't create a BeautyEngine every frame.
Release the BeautyEngine when the page is destroyed.
Reset when switching input sources.

17.2 Threading rules

BeautyEngine initialization can be done in the background thread or during the page preparation phase.
process(pixelBuffer:) should not be called frequently on the main thread.
process(image:) should not process large images on the main thread.
Parameters are value types, and the App side needs to ensure thread safety when updating.

17.3 Multiple instance rules

Multiple instances of BeautyEngine are allowed, but abuse is not recommended.

Scenario:

a real-time camera engine
An image export engine

Note:

Multiple instances will occupy more Metal / texture / resource resources.

⸻

18. Pixel Format Specification

18.1 Recommended input format

Live camera priority support:

kCVPixelFormatType_32BGRA

It will be supported in the future:

kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange

18.2 First Edition Recommendations

The first version gives priority to support:

BGRA

Reason:

Simple access
Metal handles directly
Reduce YUV conversion complexity

If we optimize live broadcast/encoding performance in the future, we will support the YUV pipeline.

⸻

19. API usage complete example

19.1 Live Camera Example

import BeautySDK
import AVFoundation
final class CameraBeautyPipeline: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let engine: BeautyEngine
    private let queue = DispatchQueue(label: "com.demo.beauty.camera")
    private var currentParameters = BeautyParameters(
        skinSmoothing: 0.25,
        skinWhitening: 0.15,
        skinRosy: 0.08,
        faceSlim: 0.12,
        eyeSize: 0.1,
        filterId: "clean_01",
        filterIntensity: 0.25
    )
    override init() {
        self.engine = try! BeautyEngine(configuration: .default)
        super.init()
    }
    func updateParameters(_ parameters: BeautyParameters) {
        queue.async {
            self.currentParameters = parameters
        }
    }
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let parameters = currentParameters
        do {
            let processedBuffer = try engine.process(
                pixelBuffer: pixelBuffer,
                orientation: .right,
                parameters: parameters
            )
            // display processedBuffer
        } catch {
            // fallback: display original pixelBuffer
        }
    }
}

⸻

19.2 Image processing example

import BeautySDK
import CoreImage
let engine = try BeautyEngine(
    configuration: BeautyConfiguration(renderQuality: .quality)
)
let parameters = BeautyParameters(
    skinSmoothing: 0.35,
    skinWhitening: 0.2,
    faceSlim: 0.15,
    eyeSize: 0.12,
    filterId: "clean_01",
    filterIntensity: 0.3
)
let outputImage = try engine.process(
    image: inputImage,
    orientation: .up,
    parameters: parameters
)

⸻

19.3 Preset usage examples

let presetLoader = BeautyPresetLoader()
let presets = try presetLoader.loadBuiltInPresets()
if let preset = presets.first(where: { $0.id == "natural_01" }) {
    parameters = preset.parameters
}

⸻

20. First version of API minimum set

20.1 Must be disclosed

BeautyEngine
BeautyConfiguration
BeautyRenderQuality
BeautyParameters
BeautyPreset
BeautyPresetLoader
BeautyError
BeautyLogLevel

20.2 Not public yet

VisionFaceDetector
FaceWarpEffect
WarpControlPoint
RenderGraph
MetalContext
TextureCache
SkinSmoothEffect
LUTFilterEffect
CoordinateMapper
LandmarkSmoother

These are internal implementations and should not be relied upon by apps.

⸻

21. API Stability Rules

21.1 public API modification rules

Any public API modifications must be logged to CHANGELOG.

Destructive modifications require a major version upgrade.

21.2 New Parameter Adding Rules

New parameters must be:

Default value has no effect
Codable compatible with old JSON
Do not change the old preset effect
Write parameter document
Add testing

21.3 Parameter obsolescence rules

Do not delete directly.

Use:

@available(*, deprecated, message: "Use newParameter instead")

Keep at least one major version.

⸻

22. Not recommended API design

22.1 One method per function is not recommended

Error:

engine.setEyeSize(0.3)
engine.setFaceSlim(0.2)
engine.setNoseSlim(0.1)
engine.enableWhitening(true)

Reason:

Dispersed state
Not thread safe
Difficult to save
Difficult to preset
Difficult to roll back
Difficult to test

Correct:

var parameters = BeautyParameters()
parameters.eyeSize = 0.3
parameters.faceSlim = 0.2
let output = try engine.process(
    pixelBuffer: pixelBuffer,
    orientation: orientation,
    parameters: parameters
)

⸻

22.2 It is not recommended to hold UI state in the SDK

Error:

engine.currentCategory = .eyes
engine.selectedSlider = .eyeSize
engine.showBeforeAfter = true

Correct:

UI state is held by the App.
The SDK only receives final BeautyParameters.

⸻

22.3 Exposing internal Metal objects is deprecated

Error:

engine.currentTexture
engine.commandBuffer
engine.renderGraph

Correct:

Ordinary integrators only use CVPixelBuffer / CIImage for output.
Internal debugging tools can obtain more information through the separate Debug API.

⸻

23. Follow-up API expansion plan

23.1 Video file processing API

Future versions may add:

public final class BeautyVideoProcessor {
    public init(engine: BeautyEngine)
    public func export(
        inputURL: URL,
        outputURL: URL,
        parameters: BeautyParameters,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws
    public func cancel()
}

Support:

AVAssetReader
AVAssetWriter
audio preserved
Orientation preserved
Progress callback
Cancel export

⸻

23.2 Image batch processing API

public final class BeautyBatchImageProcessor {
    public init(engine: BeautyEngine)
    public func process(
        images: [CIImage],
        parameters: BeautyParameters
    ) async throws -> [CIImage]
}

⸻

23.3 Custom resource API

public final class BeautyResourceManager {
    public func registerLUT(id: String, url: URL) throws
    public func registerMakeupPackage(url: URL) throws
    public func unregisterResource(id: String)
}

⸻

23.4 Debug Result API

public func processWithResult(
    pixelBuffer: CVPixelBuffer,
    orientation: CGImagePropertyOrientation,
    parameters: BeautyParameters
) throws -> BeautyProcessingResult<CVPixelBuffer>

⸻

24. First version of API acceptance criteria

The first version of the API must meet:

1. App only needs to import BeautySDK.
2. BeautyEngine is easy to initialize.
3. Real-time frames can be processed through process(pixelBuffer:).
4. Images can be processed through process(image:).
5. Parameters can be Codable saved and restored.
6. Presets can be loaded as JSON.
7. All default parameters have no effect.
8. There is a clear BeautyError when an error occurs.
9. The SDK does not expose the UI.
10. The SDK does not require the App to understand the internal details of Metal.
11. You can reset when switching input sources.
12. There is API space for video export and resource expansion in the future.

⸻

25. One sentence conclusion

BeautySDK external API should be kept very simple:

Create Engine
Configuration
Pass in Image/PixelBuffer
Pass in BeautyParameters
Get processing results

The app should not know how to do face detection, how to do Metal rendering, and how to generate WarpControlPoint inside the SDK.

In the end, the most commonly used code by the integrator should only have these few lines:

let engine = try BeautyEngine(configuration: .default)
let parameters = BeautyParameters(skinSmoothing: 0.3, faceSlim: 0.2, eyeSize: 0.15)
let output = try engine.process(pixelBuffer: input, orientation: .right, parameters: parameters)
