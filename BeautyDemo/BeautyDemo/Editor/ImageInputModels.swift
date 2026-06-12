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
    let orientation: CGImagePropertyOrientation

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
            orientation: orientation
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
            orientation: orientation
        )
    }

    static let cancelled = ImageInputSource(
        kind: .cancelled,
        id: "cancelled",
        data: nil,
        fixtureImage: nil,
        orientation: .up
    )
}

nonisolated struct DecodedImageInput: @unchecked Sendable {
    let source: ImageInputSource
    let image: CIImage
    let orientation: CGImagePropertyOrientation
}

nonisolated struct ImageProcessingSnapshot: @unchecked Sendable, Equatable {
    let sourceKind: ImageInputKind
    let sourceID: String
    let inputImage: CIImage
    let outputImage: CIImage
    let inputCGImage: CGImage
    let outputCGImage: CGImage
    let orientation: CGImagePropertyOrientation
    let parameters: BeautyParameters

    var extent: CGRect {
        outputImage.extent
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
            lhs.orientation == rhs.orientation &&
            lhs.parameters == rhs.parameters
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
        case .empty, .loaded:
            nil
        case .loading:
            Self.loadingText
        case .failed(_, let message):
            message
        }
    }
}
