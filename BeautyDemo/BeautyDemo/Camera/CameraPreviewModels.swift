import BeautySDK
import CoreGraphics
import CoreVideo
import Foundation
import ImageIO

nonisolated struct CameraPreviewFrame: @unchecked Sendable {
    enum Source: String, Equatable, Sendable {
        case camera
        case testFixture
    }

    let pixelBuffer: CVPixelBuffer
    let metadata: BeautyInputMetadata
    let source: Source
    let extent: CGSize

    var orientation: CGImagePropertyOrientation {
        metadata.orientation
    }

    var timestamp: TimeInterval {
        metadata.timestamp ?? 0
    }

    nonisolated init(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        timestamp: TimeInterval,
        source: Source,
        isInputMirrored: Bool = false,
        isPreviewMirrored: Bool? = nil,
        extent: CGSize? = nil
    ) {
        self.pixelBuffer = pixelBuffer
        self.metadata = BeautyInputMetadata(
            orientation: orientation,
            isInputMirrored: isInputMirrored,
            isPreviewMirrored: isPreviewMirrored ?? (source == .camera),
            source: source.beautyInputSource,
            timestamp: timestamp
        )
        self.source = source
        self.extent = extent ?? CGSize(
            width: CVPixelBufferGetWidth(pixelBuffer),
            height: CVPixelBufferGetHeight(pixelBuffer)
        )
    }

    var pixelFormat: OSType {
        CVPixelBufferGetPixelFormatType(pixelBuffer)
    }
}

private extension CameraPreviewFrame.Source {
    var beautyInputSource: BeautyInputSource {
        switch self {
        case .camera:
            .camera
        case .testFixture:
            .testFixture
        }
    }
}

enum CameraSessionFailure: String, Error, Equatable, Sendable {
    case noVideoDevice
    case cannotCreateInput
    case cannotAddInput
    case cannotAddOutput
    case missingPixelBuffer
    case runtimeFailure
}

enum CameraSessionState: Equatable, Sendable {
    case idle
    case configuring
    case running
    case unavailable
    case failedSetup(CameraSessionFailure)

    var isUnavailableForPreview: Bool {
        switch self {
        case .unavailable, .failedSetup:
            return true
        case .idle, .configuring, .running:
            return false
        }
    }
}
