import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import ImageIO

public final class BeautyEngine {
    public let configuration: BeautyConfiguration
    private var resetGeneration: UInt64 = 0

    public init(configuration: BeautyConfiguration = .default) throws {
        self.configuration = configuration
    }

    /// Returns an SDK-created output pixel buffer that is readable for the current processing result lifecycle.
    public func process(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CVPixelBuffer {
        let metadata = BeautyInputMetadata(
            orientation: orientation,
            isInputMirrored: false,
            isPreviewMirrored: false,
            source: .camera
        )
        return try processResult(
            pixelBuffer: pixelBuffer,
            metadata: metadata,
            parameters: parameters
        ).output
    }

    public func processResult(
        pixelBuffer: CVPixelBuffer,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters
    ) throws -> BeautyResult<CVPixelBuffer> {
        _ = metadata
        _ = parameters.normalized()
        try Self.validate(pixelBuffer: pixelBuffer)
        return BeautyResult(
            output: try Self.makeCopiedBGRAOutput(from: pixelBuffer),
            detectionSummary: initialDetectionSummary
        )
    }

    /// Returns an SDK-created image value that is readable for the current processing result lifecycle.
    public func process(
        image: CIImage,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CIImage {
        let metadata = BeautyInputMetadata(
            orientation: orientation,
            isInputMirrored: false,
            isPreviewMirrored: false,
            source: .photo
        )
        return try processResult(
            image: image,
            metadata: metadata,
            parameters: parameters
        ).output
    }

    public func processResult(
        image: CIImage,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters
    ) throws -> BeautyResult<CIImage> {
        _ = metadata
        _ = parameters.normalized()
        guard image.extent.isFiniteAndNonEmpty else {
            throw BeautyError.invalidInput
        }
        return BeautyResult(
            output: image.cropped(to: image.extent),
            detectionSummary: initialDetectionSummary
        )
    }

    public func reset() {
        resetGeneration &+= 1
    }

    public var resetCountForTesting: UInt64 {
        resetGeneration
    }

    private var initialDetectionSummary: BeautyDetectionSummary {
        configuration.enableFaceTracking ? .notRun : .disabled
    }

    private static func validate(pixelBuffer: CVPixelBuffer) throws {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        guard width > 0, height > 0 else {
            throw BeautyError.invalidInput
        }
        guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA else {
            throw BeautyError.unsupportedPixelFormat
        }
    }

    private static func makeCopiedBGRAOutput(from pixelBuffer: CVPixelBuffer) throws -> CVPixelBuffer {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)

        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]

        var output: CVPixelBuffer?
        let createStatus = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            pixelFormat,
            attributes as CFDictionary,
            &output
        )

        guard createStatus == kCVReturnSuccess, let output else {
            throw BeautyError.pixelBufferCreationFailed
        }

        try copyBytes(from: pixelBuffer, to: output)
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
            let sourceRow = sourceBase.advanced(by: row * sourceBytesPerRow)
            let destinationRow = destinationBase.advanced(by: row * destinationBytesPerRow)
            memcpy(destinationRow, sourceRow, bytesToCopyPerRow)
        }
    }
}

private extension CGRect {
    var isFiniteAndNonEmpty: Bool {
        origin.x.isFinite &&
            origin.y.isFinite &&
            size.width.isFinite &&
            size.height.isFinite &&
            size.width > 0 &&
            size.height > 0
    }
}
