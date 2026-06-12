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
    let orientation: CGImagePropertyOrientation
    let timestamp: TimeInterval
    let source: Source
    let extent: CGSize

    nonisolated init(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        timestamp: TimeInterval,
        source: Source,
        extent: CGSize? = nil
    ) {
        self.pixelBuffer = pixelBuffer
        self.orientation = orientation
        self.timestamp = timestamp
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
