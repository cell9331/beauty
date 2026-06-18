import BeautySDK
import CoreGraphics
import CoreImage
import Foundation
import ImageIO

nonisolated enum ImageInputKind: String, Equatable, Sendable {
    case fixture
    case photosPickerData
    case cancelled
}

nonisolated struct ImageInputSource: @unchecked Sendable {
    let kind: ImageInputKind
    let id: String
    let data: Data?
    let fixtureImage: CIImage?
    let metadata: BeautyInputMetadata

    var orientation: CGImagePropertyOrientation {
        metadata.orientation
    }

    static func fixture(
        id: String = "demo-fixture",
        image: CIImage = DemoFixtures.photoFixtureImage(),
        orientation: CGImagePropertyOrientation = .up
    ) -> ImageInputSource {
        ImageInputSource(
            kind: .fixture,
            id: id,
            data: nil,
            fixtureImage: image,
            metadata: BeautyInputMetadata(
                orientation: orientation,
                source: .photo
            )
        )
    }

    static func photosPickerData(
        _ data: Data,
        id: String = "photos-picker",
        orientation: CGImagePropertyOrientation = .up
    ) -> ImageInputSource {
        ImageInputSource(
            kind: .photosPickerData,
            id: id,
            data: data,
            fixtureImage: nil,
            metadata: BeautyInputMetadata(
                orientation: orientation,
                source: .photo
            )
        )
    }

    static let cancelled = ImageInputSource(
        kind: .cancelled,
        id: "cancelled",
        data: nil,
        fixtureImage: nil,
        metadata: BeautyInputMetadata(
            orientation: .up,
            source: .photo
        )
    )
}

nonisolated struct DecodedImageInput: @unchecked Sendable {
    let source: ImageInputSource
    let image: CIImage
    let metadata: BeautyInputMetadata

    var orientation: CGImagePropertyOrientation {
        metadata.orientation
    }

    init(
        source: ImageInputSource,
        image: CIImage,
        metadata: BeautyInputMetadata
    ) {
        self.source = source
        self.image = image
        self.metadata = metadata
    }

    init(
        source: ImageInputSource,
        image: CIImage,
        orientation: CGImagePropertyOrientation
    ) {
        self.init(
            source: source,
            image: image,
            metadata: BeautyInputMetadata(
                orientation: orientation,
                source: .photo
            )
        )
    }
}

nonisolated struct ImageProcessingSnapshot: @unchecked Sendable, Equatable {
    let sourceKind: ImageInputKind
    let sourceID: String
    let inputImage: CIImage
    let outputImage: CIImage
    let inputCGImage: CGImage
    let outputCGImage: CGImage
    let metadata: BeautyInputMetadata
    let parameters: BeautyParameters
    let detectionSummary: BeautyDetectionSummary?

    var orientation: CGImagePropertyOrientation {
        metadata.orientation
    }

    var extent: CGRect {
        outputImage.extent
    }

    init(
        sourceKind: ImageInputKind,
        sourceID: String,
        inputImage: CIImage,
        outputImage: CIImage,
        inputCGImage: CGImage,
        outputCGImage: CGImage,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters,
        detectionSummary: BeautyDetectionSummary? = nil
    ) {
        self.sourceKind = sourceKind
        self.sourceID = sourceID
        self.inputImage = inputImage
        self.outputImage = outputImage
        self.inputCGImage = inputCGImage
        self.outputCGImage = outputCGImage
        self.metadata = metadata
        self.parameters = parameters
        self.detectionSummary = detectionSummary
    }

    init(
        sourceKind: ImageInputKind,
        sourceID: String,
        inputImage: CIImage,
        outputImage: CIImage,
        inputCGImage: CGImage,
        outputCGImage: CGImage,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters,
        detectionSummary: BeautyDetectionSummary? = nil
    ) {
        self.init(
            sourceKind: sourceKind,
            sourceID: sourceID,
            inputImage: inputImage,
            outputImage: outputImage,
            inputCGImage: inputCGImage,
            outputCGImage: outputCGImage,
            metadata: BeautyInputMetadata(
                orientation: orientation,
                source: .photo
            ),
            parameters: parameters,
            detectionSummary: detectionSummary
        )
    }

    static func == (lhs: ImageProcessingSnapshot, rhs: ImageProcessingSnapshot) -> Bool {
        lhs.sourceKind == rhs.sourceKind &&
            lhs.sourceID == rhs.sourceID &&
            lhs.inputImage.extent == rhs.inputImage.extent &&
            lhs.outputImage.extent == rhs.outputImage.extent &&
            lhs.inputCGImage.width == rhs.inputCGImage.width &&
            lhs.inputCGImage.height == rhs.inputCGImage.height &&
            lhs.outputCGImage.width == rhs.outputCGImage.width &&
            lhs.outputCGImage.height == rhs.outputCGImage.height &&
            lhs.metadata == rhs.metadata &&
            lhs.parameters == rhs.parameters &&
            lhs.detectionSummary == rhs.detectionSummary
    }
}

nonisolated enum PhotoProcessingState: Equatable, Sendable {
    static let loadingText = "Processing photo..."
    static let decodeFailureText = "Could not read that photo. Choose another image."

    case empty
    case loading(previousSnapshot: ImageProcessingSnapshot?)
    case loaded(ImageProcessingSnapshot)
    case failed(previousSnapshot: ImageProcessingSnapshot?, message: String)

    var latestSnapshot: ImageProcessingSnapshot? {
        switch self {
        case .empty:
            nil
        case .loading(let snapshot),
             .failed(let snapshot, _):
            snapshot
        case .loaded(let snapshot):
            snapshot
        }
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var statusText: String? {
        switch self {
        case .empty:
            nil
        case .loaded(let snapshot):
            DetectionStatusPresentation(summary: snapshot.detectionSummary).statusText
        case .loading:
            Self.loadingText
        case .failed(_, let message):
            message
        }
    }

    var detectionDebugSummary: DetectionDebugSummary? {
        latestSnapshot.flatMap { snapshot in
            DetectionStatusPresentation(summary: snapshot.detectionSummary).debugSummary
        }
    }
}
