import BeautyCore
import CoreVideo
import Foundation

public struct PixelBufferFactory: Sendable {
    public static let supportedPixelFormat = kCVPixelFormatType_32BGRA

    public init() {}

    public func makePixelBuffer(width: Int, height: Int, pixelFormat: OSType = supportedPixelFormat) throws -> CVPixelBuffer {
        guard width > 0, height > 0 else {
            throw BeautyError.invalidInput
        }

        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            pixelFormat,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }

        return pixelBuffer
    }

    public func makePixelBuffer(matching source: CVPixelBuffer) throws -> CVPixelBuffer {
        try makePixelBuffer(
            width: CVPixelBufferGetWidth(source),
            height: CVPixelBufferGetHeight(source),
            pixelFormat: CVPixelBufferGetPixelFormatType(source)
        )
    }
}
