import CoreGraphics
import CoreVideo
import Foundation
import ImageIO

public struct BeautyFrame {
    public enum Source: String, Codable, Equatable, Sendable {
        case camera
        case photo
        case video
        case export
        case testFixture
    }

    public let pixelBuffer: CVPixelBuffer
    public let orientation: CGImagePropertyOrientation
    public let isInputMirrored: Bool
    public let isPreviewMirrored: Bool
    public let timestamp: TimeInterval?
    public let source: Source
    public let extent: CGSize

    public init(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        isInputMirrored: Bool = false,
        isPreviewMirrored: Bool = false,
        timestamp: TimeInterval? = nil,
        source: Source,
        extent: CGSize? = nil
    ) {
        self.pixelBuffer = pixelBuffer
        self.orientation = orientation
        self.isInputMirrored = isInputMirrored
        self.isPreviewMirrored = isPreviewMirrored
        self.timestamp = timestamp
        self.source = source
        self.extent = extent ?? CGSize(
            width: CVPixelBufferGetWidth(pixelBuffer),
            height: CVPixelBufferGetHeight(pixelBuffer)
        )
    }
}
