import BeautyCore
import BeautyRender
import CoreGraphics
import CoreImage
import CoreVideo
import Foundation

/// Package-only Metal execution for the shared backend boundary.
///
/// The runtime owns Metal resources. This executor only bridges one admitted
/// request into a bounded RGBA8 transaction and publishes aggregate results.
package final class BeautyMetalBackend: BeautyBackendExecutor, @unchecked Sendable {
    package struct ExecutionHooks: @unchecked Sendable {
        package let onRuntimeInvocation: @Sendable () -> Void
        package let onTerminalError: @Sendable (BeautyError) -> Void

        package init(
            onRuntimeInvocation: @escaping @Sendable () -> Void = {},
            onTerminalError: @escaping @Sendable (BeautyError) -> Void = { _ in }
        ) {
            self.onRuntimeInvocation = onRuntimeInvocation
            self.onTerminalError = onTerminalError
        }
    }

    private let runtime: BeautyMetalRuntime
    private let hooks: ExecutionHooks
    private let pixelBufferFactory = PixelBufferFactory()

    package init(
        runtime: BeautyMetalRuntime,
        hooks: ExecutionHooks = ExecutionHooks()
    ) {
        self.runtime = runtime
        self.hooks = hooks
    }

    package init(
        dependencies: BeautyMetalRuntime.Dependencies = .live,
        maximumPixelCount: Int = BeautyConfiguration.defaultMaximumInputPixelCount,
        hooks: ExecutionHooks = ExecutionHooks()
    ) throws {
        self.runtime = try BeautyMetalRuntime(
            dependencies: dependencies,
            maximumPixelCount: maximumPixelCount
        )
        self.hooks = hooks
    }

    package func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult {
        do {
            guard request.policy == .metal else {
                throw BeautyError.invalidInput
            }

            let output: BeautyBackendOutput
            switch request.input {
            case .pixelBuffer(let pixelBuffer):
                output = .pixelBuffer(try execute(pixelBuffer: pixelBuffer))
            case .stillImage(let image):
                output = .stillImage(try execute(stillImage: image, canonicalImage: request.canonicalImage))
            }

            let dimensions = dimensions(of: output)
            let summary = request.compositionSummary
            let pixelCount = dimensions.width.multipliedReportingOverflow(by: dimensions.height)
            let boundedPixelCount = pixelCount.overflow
                ? BeautyConfiguration.defaultMaximumInputPixelCount
                : pixelCount.partialValue
            let diagnostics = BeautyBackendDiagnostics(
                width: dimensions.width,
                height: dimensions.height,
                preservesAlpha: true,
                preservesExtent: true,
                unitCount: min(summary?.acceptedUnitCount ?? 0, boundedPixelCount),
                failureCount: min(summary?.rejectedUnitCount ?? 0, boundedPixelCount),
                collisionCount: min(summary?.collisionPixelCount ?? 0, boundedPixelCount),
                changedPixelCount: min(summary?.changedPixelCount ?? 0, boundedPixelCount)
            )
            return try BeautyBackendResult(
                output: output,
                diagnostics: diagnostics,
                for: request
            )
        } catch let error as BeautyError {
            hooks.onTerminalError(error)
            throw error
        } catch {
            let terminalError = BeautyError.renderFailed("terminal")
            hooks.onTerminalError(terminalError)
            throw terminalError
        }
    }

    private func execute(pixelBuffer: CVPixelBuffer) throws -> CVPixelBuffer {
        guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA else {
            throw BeautyError.unsupportedPixelFormat
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let rowBytes = try packedRowBytes(width: width)
        let sourceBytes = try read(pixelBuffer: pixelBuffer, width: width, height: height, rowBytes: rowBytes)
        let renderedBytes = try invokeRuntime(width: width, height: height, bytes: sourceBytes)
        let output = try pixelBufferFactory.makePixelBuffer(width: width, height: height)
        try write(renderedBytes, to: output, width: width, height: height, rowBytes: rowBytes)
        return output
    }

    private func execute(
        stillImage image: CIImage,
        canonicalImage: BeautyCanonicalStillImage?
    ) throws -> CIImage {
        let extent = image.extent
        guard let dimensions = BeautyBackendRequest.checkedDimensions(for: extent) else {
            throw BeautyError.invalidInput
        }

        let bytes: [UInt8]
        if let canonicalImage {
            guard canonicalImage.width == dimensions.width,
                  canonicalImage.height == dimensions.height
            else {
                throw BeautyError.invalidInput
            }
            bytes = Array(canonicalImage.rgba8Data)
        } else {
            bytes = try rasterize(image: image, extent: extent, width: dimensions.width, height: dimensions.height)
        }

        let renderedBytes = try invokeRuntime(
            width: dimensions.width,
            height: dimensions.height,
            bytes: bytes
        )
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }
        let output = CIImage(
            bitmapData: Data(renderedBytes),
            bytesPerRow: dimensions.width * 4,
            size: CGSize(width: dimensions.width, height: dimensions.height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
        guard output.extent == CGRect(origin: .zero, size: CGSize(width: dimensions.width, height: dimensions.height)) else {
            throw BeautyError.renderFailed("output_conversion_failed")
        }
        return extent.origin == .zero
            ? output
            : output.transformed(by: CGAffineTransform(translationX: extent.minX, y: extent.minY))
    }

    private func rasterize(image: CIImage, extent: CGRect, width: Int, height: Int) throws -> [UInt8] {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ])
        guard let cgImage = context.createCGImage(
            image,
            from: extent,
            format: .RGBA8,
            colorSpace: colorSpace
        ),
        cgImage.width == width,
        cgImage.height == height,
        let providerData = cgImage.dataProvider?.data
        else {
            throw BeautyError.renderFailed("input_conversion_failed")
        }

        let packedRowBytes = try packedRowBytes(width: width)
        let sourceRowBytes = cgImage.bytesPerRow
        guard sourceRowBytes >= packedRowBytes,
              let source = CFDataGetBytePtr(providerData)
        else {
            throw BeautyError.renderFailed("input_conversion_failed")
        }
        var bytes = [UInt8](repeating: 0, count: packedRowBytes * height)
        for row in 0..<height {
            bytes.withUnsafeMutableBytes { destination in
                memcpy(
                    destination.baseAddress!.advanced(by: row * packedRowBytes),
                    source.advanced(by: row * sourceRowBytes),
                    packedRowBytes
                )
            }
        }
        guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else {
            throw BeautyError.invalidInput
        }
        return bytes
    }

    private func invokeRuntime(width: Int, height: Int, bytes: [UInt8]) throws -> [UInt8] {
        hooks.onRuntimeInvocation()
        return try runtime.render(width: width, height: height, rgba8Bytes: bytes)
    }

    private func dimensions(of output: BeautyBackendOutput) -> (width: Int, height: Int) {
        switch output {
        case .pixelBuffer(let pixelBuffer):
            (CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))
        case .stillImage(let image):
            (Int(image.extent.width), Int(image.extent.height))
        }
    }

    private func packedRowBytes(width: Int) throws -> Int {
        let result = width.multipliedReportingOverflow(by: 4)
        guard width > 0, result.overflow == false, result.partialValue > 0 else {
            throw BeautyError.invalidInput
        }
        return result.partialValue
    }

    private func read(
        pixelBuffer: CVPixelBuffer,
        width: Int,
        height: Int,
        rowBytes: Int
    ) throws -> [UInt8] {
        guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
            throw BeautyError.renderFailed("input_conversion_failed")
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        guard CVPixelBufferGetBytesPerRow(pixelBuffer) >= rowBytes,
              let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        else {
            throw BeautyError.renderFailed("input_conversion_failed")
        }
        var bytes = [UInt8](repeating: 0, count: rowBytes * height)
        let sourceRowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        bytes.withUnsafeMutableBytes { destination in
            for row in 0..<height {
                memcpy(
                    destination.baseAddress!.advanced(by: row * rowBytes),
                    baseAddress.advanced(by: row * sourceRowBytes),
                    rowBytes
                )
            }
        }
        return bytes
    }

    private func write(
        _ bytes: [UInt8],
        to pixelBuffer: CVPixelBuffer,
        width: Int,
        height: Int,
        rowBytes: Int
    ) throws {
        guard bytes.count == rowBytes * height,
              CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess
        else {
            throw BeautyError.renderFailed("output_conversion_failed")
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard CVPixelBufferGetBytesPerRow(pixelBuffer) >= rowBytes,
              let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        else {
            throw BeautyError.renderFailed("output_conversion_failed")
        }
        let destinationRowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        bytes.withUnsafeBytes { source in
            for row in 0..<height {
                memcpy(
                    baseAddress.advanced(by: row * destinationRowBytes),
                    source.baseAddress!.advanced(by: row * rowBytes),
                    rowBytes
                )
            }
        }
    }
}
