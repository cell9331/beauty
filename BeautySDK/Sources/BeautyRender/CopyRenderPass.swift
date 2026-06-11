import BeautyCore
import CoreVideo
import Foundation

public struct CopyRenderPass: RenderPass {
    public let id = "copy"
    private let factory: PixelBufferFactory

    public init(factory: PixelBufferFactory = PixelBufferFactory()) {
        self.factory = factory
    }

    public func apply(to pixelBuffer: CVPixelBuffer, parameters: BeautyParameters) throws -> CVPixelBuffer {
        _ = parameters
        guard CVPixelBufferGetPixelFormatType(pixelBuffer) == PixelBufferFactory.supportedPixelFormat else {
            throw BeautyError.unsupportedPixelFormat
        }
        let output = try factory.makePixelBuffer(matching: pixelBuffer)
        try Self.copyBytes(from: pixelBuffer, to: output)
        return output
    }

    private static func copyBytes(from source: CVPixelBuffer, to destination: CVPixelBuffer) throws {
        guard CVPixelBufferLockBaseAddress(source, .readOnly) == kCVReturnSuccess else {
            throw BeautyError.invalidInput
        }
        defer {
            CVPixelBufferUnlockBaseAddress(source, .readOnly)
        }

        guard CVPixelBufferLockBaseAddress(destination, []) == kCVReturnSuccess else {
            throw BeautyError.pixelBufferCreationFailed
        }
        defer {
            CVPixelBufferUnlockBaseAddress(destination, [])
        }

        guard let sourceBase = CVPixelBufferGetBaseAddress(source),
              let destinationBase = CVPixelBufferGetBaseAddress(destination)
        else {
            throw BeautyError.invalidInput
        }

        let height = CVPixelBufferGetHeight(source)
        let sourceBytesPerRow = CVPixelBufferGetBytesPerRow(source)
        let destinationBytesPerRow = CVPixelBufferGetBytesPerRow(destination)
        let bytesToCopyPerRow = min(sourceBytesPerRow, destinationBytesPerRow)

        for row in 0..<height {
            memcpy(
                destinationBase.advanced(by: row * destinationBytesPerRow),
                sourceBase.advanced(by: row * sourceBytesPerRow),
                bytesToCopyPerRow
            )
        }
    }
}
