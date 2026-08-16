import BeautyCore
import Foundation
import Metal

/// A package-owned, request-bounded probe of the retained Metal shader.
///
/// This type deliberately has no relationship to an application lifecycle. The
/// device, queue, and pipeline belong to one runtime instance, while textures,
/// staging buffers, command objects, and raster bytes belong to one call.
package final class BeautyMetalRuntime: @unchecked Sendable {
    package struct Dependencies: @unchecked Sendable {
        package var deviceProvider: @Sendable () -> MTLDevice?
        package var commandQueueProvider: @Sendable (MTLDevice) -> MTLCommandQueue?
        package var libraryProvider: @Sendable (MTLDevice) -> MTLLibrary?
        package var functionProvider: @Sendable (MTLLibrary, String) -> MTLFunction?
        package var pipelineProvider: @Sendable (MTLDevice, MTLFunction) -> MTLComputePipelineState?
        package var commandBufferProvider: @Sendable (MTLCommandQueue) -> MTLCommandBuffer?
        package var computeEncoderProvider: @Sendable (MTLCommandBuffer) -> MTLComputeCommandEncoder?
        package var textureProvider: @Sendable (MTLDevice, MTLTextureDescriptor) -> MTLTexture?
        package var waitForCompletion: @Sendable (MTLCommandBuffer) -> Void
        package var commandStatusProvider: @Sendable (MTLCommandBuffer) -> MTLCommandBufferStatus

        package init(
            deviceProvider: @escaping @Sendable () -> MTLDevice?,
            commandQueueProvider: @escaping @Sendable (MTLDevice) -> MTLCommandQueue?,
            libraryProvider: @escaping @Sendable (MTLDevice) -> MTLLibrary?,
            functionProvider: @escaping @Sendable (MTLLibrary, String) -> MTLFunction?,
            pipelineProvider: @escaping @Sendable (MTLDevice, MTLFunction) -> MTLComputePipelineState?,
            commandBufferProvider: @escaping @Sendable (MTLCommandQueue) -> MTLCommandBuffer?,
            computeEncoderProvider: @escaping @Sendable (MTLCommandBuffer) -> MTLComputeCommandEncoder?,
            textureProvider: @escaping @Sendable (MTLDevice, MTLTextureDescriptor) -> MTLTexture?,
            waitForCompletion: @escaping @Sendable (MTLCommandBuffer) -> Void,
            commandStatusProvider: @escaping @Sendable (MTLCommandBuffer) -> MTLCommandBufferStatus
        ) {
            self.deviceProvider = deviceProvider
            self.commandQueueProvider = commandQueueProvider
            self.libraryProvider = libraryProvider
            self.functionProvider = functionProvider
            self.pipelineProvider = pipelineProvider
            self.commandBufferProvider = commandBufferProvider
            self.computeEncoderProvider = computeEncoderProvider
            self.textureProvider = textureProvider
            self.waitForCompletion = waitForCompletion
            self.commandStatusProvider = commandStatusProvider
        }

        package static let live = Self(
            deviceProvider: { MTLCreateSystemDefaultDevice() },
            commandQueueProvider: { device in device.makeCommandQueue() },
            libraryProvider: { device in
                if let library = try? device.makeDefaultLibrary(bundle: Bundle.module) {
                    return library
                }
                guard let shaderURL = Bundle.module.url(forResource: "Warp", withExtension: "metal"),
                      let source = try? String(contentsOf: shaderURL, encoding: .utf8)
                else {
                    return nil
                }
                return try? device.makeLibrary(source: source, options: nil)
            },
            functionProvider: { library, name in library.makeFunction(name: name) },
            pipelineProvider: { device, function in
                try? device.makeComputePipelineState(function: function)
            },
            commandBufferProvider: { queue in queue.makeCommandBuffer() },
            computeEncoderProvider: { commandBuffer in commandBuffer.makeComputeCommandEncoder() },
            textureProvider: { device, descriptor in device.makeTexture(descriptor: descriptor) },
            waitForCompletion: { commandBuffer in commandBuffer.waitUntilCompleted() },
            commandStatusProvider: { commandBuffer in commandBuffer.status }
        )
    }

    package struct ResourceCounters: Equatable, Sendable {
        package let created: Int
        package let released: Int
        package let active: Int

        fileprivate init(created: Int = 0, released: Int = 0, active: Int = 0) {
            self.created = created
            self.released = released
            self.active = active
        }
    }

    private final class CounterStore: @unchecked Sendable {
        private let lock = NSLock()
        private var created = 0
        private var released = 0
        private var active = 0

        func createdResource() {
            lock.lock()
            created += 1
            active += 1
            lock.unlock()
        }

        func releasedResource() {
            lock.lock()
            released += 1
            active = max(0, active - 1)
            lock.unlock()
        }

        var snapshot: ResourceCounters {
            lock.lock()
            defer { lock.unlock() }
            return ResourceCounters(created: created, released: released, active: active)
        }
    }

    private let dependencies: Dependencies
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelines: [String: MTLComputePipelineState]
    private let counters = CounterStore()
    private let maximumPixelCount: Int

    /// Package-test-only aggregate lifecycle evidence. It intentionally omits
    /// object descriptions, dimensions, bytes, and framework error details.
    package var resourceCountersForTesting: ResourceCounters {
        counters.snapshot
    }

    package init(
        dependencies: Dependencies = .live,
        maximumPixelCount: Int = 50_000_000
    ) throws {
        guard maximumPixelCount > 0 else {
            throw BeautyError.invalidInput
        }

        guard let device = dependencies.deviceProvider() else {
            throw BeautyError.metalUnavailable
        }
        guard let commandQueue = dependencies.commandQueueProvider(device) else {
            throw BeautyError.commandQueueCreationFailed
        }
        guard let library = dependencies.libraryProvider(device) else {
            throw BeautyError.renderFailed("library_creation_failed")
        }
        let functionNames = [
            "beauty_warp_placeholder",
            "beauty_color_pass",
            "beauty_geometry_pass",
            "beauty_local_retouch_pass",
        ]
        var pipelines: [String: MTLComputePipelineState] = [:]
        for functionName in functionNames {
            guard let function = dependencies.functionProvider(library, functionName) else {
                if functionName == "beauty_warp_placeholder" {
                    throw BeautyError.shaderFunctionNotFound(functionName)
                }
                throw BeautyError.renderFailed("shader_function_missing")
            }
            guard let pipeline = dependencies.pipelineProvider(device, function) else {
                throw BeautyError.renderFailed("pipeline_creation_failed")
            }
            pipelines[functionName] = pipeline
        }

        self.dependencies = dependencies
        self.device = device
        self.commandQueue = commandQueue
        self.pipelines = pipelines
        self.maximumPixelCount = maximumPixelCount
    }

    /// Executes one identity copy through the bundled shader.
    package func render(width: Int, height: Int, rgba8Bytes: [UInt8]) throws -> [UInt8] {
        try render(width: width, height: height, rgba8Bytes: rgba8Bytes, passes: [])
    }

    /// Executes one ordered, request-local pass graph. The input and output
    /// textures are private; shared buffers are bounded upload/readback staging.
    package func render(
        width: Int,
        height: Int,
        rgba8Bytes: [UInt8],
        passes: [BeautyMetalPass]
    ) throws -> [UInt8] {
        let dimensions = try validate(width: width, height: height, inputByteCount: rgba8Bytes.count)
        guard passes.count <= 64 else { throw BeautyError.invalidInput }
        let kernelNames = passes.isEmpty
            ? ["beauty_warp_placeholder"]
            : passes.map(\.kernelName)
        guard kernelNames.allSatisfy({ pipelines[$0] != nil }) else {
            throw BeautyError.shaderFunctionNotFound("beauty_pass")
        }
        let rowBytes = dimensions.rowBytes
        let paddedRowBytes = try alignedRowBytes(rowBytes)
        let paddedByteCount = try checkedMultiply(paddedRowBytes, height)

        var inputStaging = [UInt8](repeating: 0, count: paddedByteCount)
        counters.createdResource()
        defer { counters.releasedResource() }

        rgba8Bytes.withUnsafeBytes { source in
            inputStaging.withUnsafeMutableBytes { destination in
                guard let sourceBase = source.baseAddress, let destinationBase = destination.baseAddress else {
                    return
                }
                for row in 0..<height {
                    memcpy(
                        destinationBase.advanced(by: row * paddedRowBytes),
                        sourceBase.advanced(by: row * rowBytes),
                        rowBytes
                    )
                }
            }
        }

        let outputStaging = [UInt8](repeating: 0, count: paddedByteCount)
        counters.createdResource()
        defer { counters.releasedResource() }

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        descriptor.storageMode = .private
        descriptor.usage = [.shaderRead, .shaderWrite]

        var inputTexture = tracked(dependencies.textureProvider(device, descriptor))
        guard inputTexture != nil else {
            throw BeautyError.textureCreationFailed
        }
        defer {
            counters.releasedResource()
            inputTexture = nil
        }

        var outputTexture = tracked(dependencies.textureProvider(device, descriptor))
        guard outputTexture != nil else {
            throw BeautyError.textureCreationFailed
        }
        defer {
            counters.releasedResource()
            outputTexture = nil
        }

        var commandBuffer = tracked(dependencies.commandBufferProvider(commandQueue))
        guard commandBuffer != nil else {
            throw BeautyError.renderFailed("command_buffer_creation_failed")
        }
        defer {
            counters.releasedResource()
            commandBuffer = nil
        }

        guard let inputTexture, let outputTexture, let commandBuffer else {
            throw BeautyError.renderFailed("request_resource_unavailable")
        }

        var inputBuffer = tracked(makeBuffer(bytes: inputStaging, length: paddedByteCount))
        guard inputBuffer != nil else {
            throw BeautyError.renderFailed("staging_buffer_creation_failed")
        }
        defer {
            counters.releasedResource()
            inputBuffer = nil
        }

        guard let inputBufferValue = inputBuffer else {
            throw BeautyError.renderFailed("request_resource_unavailable")
        }
        var uploadEncoder = tracked(commandBuffer.makeBlitCommandEncoder())
        guard uploadEncoder != nil else {
            throw BeautyError.renderFailed("blit_encoder_creation_failed")
        }
        defer {
            counters.releasedResource()
            uploadEncoder?.endEncoding()
            uploadEncoder = nil
        }
        guard let uploadEncoderValue = uploadEncoder else {
            throw BeautyError.renderFailed("request_resource_unavailable")
        }
        uploadEncoderValue.copy(
            from: inputBufferValue,
            sourceOffset: 0,
            sourceBytesPerRow: paddedRowBytes,
            sourceBytesPerImage: paddedByteCount,
            sourceSize: MTLSize(width: width, height: height, depth: 1),
            to: inputTexture,
            destinationSlice: 0,
            destinationLevel: 0,
            destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0)
        )
        uploadEncoderValue.endEncoding()
        uploadEncoder = nil

        let threadGrid = MTLSize(width: width, height: height, depth: 1)
        var currentTexture = inputTexture
        var nextTexture = outputTexture
        for (index, pass) in passes.enumerated() {
            guard let pipeline = pipelines[pass.kernelName] else {
                throw BeautyError.shaderFunctionNotFound(pass.kernelName)
            }
            var computeEncoder = tracked(dependencies.computeEncoderProvider(commandBuffer))
            guard computeEncoder != nil else {
                throw BeautyError.renderFailed("compute_encoder_creation_failed")
            }
            defer {
                counters.releasedResource()
                computeEncoder?.endEncoding()
                computeEncoder = nil
            }

            let threadgroupWidth = min(max(1, pipeline.threadExecutionWidth), width)
            guard threadgroupWidth > 0,
                  pipeline.maxTotalThreadsPerThreadgroup >= threadgroupWidth
            else {
                throw BeautyError.renderFailed("thread_grid_invalid")
            }
            guard let computeEncoderValue = computeEncoder else {
                throw BeautyError.renderFailed("request_resource_unavailable")
            }
            computeEncoderValue.setComputePipelineState(pipeline)
            computeEncoderValue.setTexture(currentTexture, index: 0)
            computeEncoderValue.setTexture(nextTexture, index: 1)
            switch pass {
            case .color(let parameters):
                var uniform = parameters.uniform
                withUnsafeBytes(of: &uniform) { bytes in
                    computeEncoderValue.setBytes(
                        bytes.baseAddress!,
                        length: MemoryLayout<BeautyMetalColorUniform>.stride,
                        index: 0
                    )
                }
            case .geometry(let parameters):
                var pointCount = UInt32(parameters.points.count)
                parameters.points.withUnsafeBytes { bytes in
                    computeEncoderValue.setBytes(
                        bytes.baseAddress!,
                        length: bytes.count,
                        index: 0
                    )
                }
                withUnsafeBytes(of: &pointCount) { bytes in
                    computeEncoderValue.setBytes(
                        bytes.baseAddress!,
                        length: MemoryLayout<UInt32>.stride,
                        index: 1
                    )
                }
            case .composedRetouch:
                break
            }
            computeEncoderValue.dispatchThreads(threadGrid, threadsPerThreadgroup: MTLSize(width: threadgroupWidth, height: 1, depth: 1))
            computeEncoderValue.endEncoding()
            computeEncoder = nil
            swap(&currentTexture, &nextTexture)
            if index + 1 == passes.count {
                break
            }
        }
        if passes.isEmpty {
            guard let pipeline = pipelines["beauty_warp_placeholder"] else {
                throw BeautyError.shaderFunctionNotFound("beauty_warp_placeholder")
            }
            var computeEncoder = tracked(dependencies.computeEncoderProvider(commandBuffer))
            guard computeEncoder != nil else {
                throw BeautyError.renderFailed("compute_encoder_creation_failed")
            }
            defer {
                counters.releasedResource()
                computeEncoder?.endEncoding()
                computeEncoder = nil
            }
            let threadgroupWidth = min(max(1, pipeline.threadExecutionWidth), width)
            guard pipeline.maxTotalThreadsPerThreadgroup >= threadgroupWidth else {
                throw BeautyError.renderFailed("thread_grid_invalid")
            }
            guard let encoder = computeEncoder else {
                throw BeautyError.renderFailed("request_resource_unavailable")
            }
            encoder.setComputePipelineState(pipeline)
            encoder.setTexture(currentTexture, index: 0)
            encoder.setTexture(nextTexture, index: 1)
            encoder.dispatchThreads(threadGrid, threadsPerThreadgroup: MTLSize(width: threadgroupWidth, height: 1, depth: 1))
            encoder.endEncoding()
            computeEncoder = nil
            swap(&currentTexture, &nextTexture)
        }

        var outputBuffer = tracked(makeBuffer(bytes: outputStaging, length: paddedByteCount))
        guard outputBuffer != nil else {
            throw BeautyError.renderFailed("staging_buffer_creation_failed")
        }
        defer {
            counters.releasedResource()
            outputBuffer = nil
        }

        guard let outputBufferValue = outputBuffer else {
            throw BeautyError.renderFailed("request_resource_unavailable")
        }
        var downloadEncoder = tracked(commandBuffer.makeBlitCommandEncoder())
        guard downloadEncoder != nil else {
            throw BeautyError.renderFailed("blit_encoder_creation_failed")
        }
        defer {
            counters.releasedResource()
            downloadEncoder?.endEncoding()
            downloadEncoder = nil
        }
        guard let downloadEncoderValue = downloadEncoder else {
            throw BeautyError.renderFailed("request_resource_unavailable")
        }
        downloadEncoderValue.copy(
            from: currentTexture,
            sourceSlice: 0,
            sourceLevel: 0,
            sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
            sourceSize: MTLSize(width: width, height: height, depth: 1),
            to: outputBufferValue,
            destinationOffset: 0,
            destinationBytesPerRow: paddedRowBytes,
            destinationBytesPerImage: paddedByteCount
        )
        downloadEncoderValue.endEncoding()
        downloadEncoder = nil

        commandBuffer.commit()
        dependencies.waitForCompletion(commandBuffer)
        guard dependencies.commandStatusProvider(commandBuffer) == .completed else {
            throw BeautyError.renderFailed("command_failed")
        }

        let outputPointer = outputBufferValue.contents().assumingMemoryBound(to: UInt8.self)
        var output = [UInt8](repeating: 0, count: dimensions.byteCount)
        counters.createdResource()
        defer { counters.releasedResource() }
        for row in 0..<height {
            output.replaceSubrange(
                row * rowBytes..<(row + 1) * rowBytes,
                with: UnsafeBufferPointer(
                    start: outputPointer.advanced(by: row * paddedRowBytes),
                    count: rowBytes
                )
            )
        }
        return output
    }

    private func tracked<T>(_ resource: T?) -> T? {
        guard let resource else { return nil }
        counters.createdResource()
        return resource
    }

    private func makeBuffer(bytes: [UInt8], length: Int) -> MTLBuffer? {
        bytes.withUnsafeBytes { rawBytes -> MTLBuffer? in
            guard let baseAddress = rawBytes.baseAddress else { return nil }
            return device.makeBuffer(bytes: baseAddress, length: length, options: .storageModeShared)
        }
    }

    private struct Dimensions {
        let rowBytes: Int
        let byteCount: Int
    }

    private func validate(width: Int, height: Int, inputByteCount: Int) throws -> Dimensions {
        let pixelProduct = width.multipliedReportingOverflow(by: height)
        guard width > 0, height > 0,
              !pixelProduct.overflow,
              pixelProduct.partialValue > 0,
              let pixelCount = Optional(pixelProduct.partialValue),
              pixelCount <= maximumPixelCount,
              width <= Int32.max,
              height <= Int32.max
        else {
            throw BeautyError.invalidInput
        }
        let rowBytes = try checkedMultiply(width, 4)
        let byteCount = try checkedMultiply(rowBytes, height)
        guard inputByteCount == byteCount else {
            throw BeautyError.invalidInput
        }
        return Dimensions(rowBytes: rowBytes, byteCount: byteCount)
    }

    private func checkedMultiply(_ lhs: Int, _ rhs: Int) throws -> Int {
        let result = lhs.multipliedReportingOverflow(by: rhs)
        guard !result.overflow, result.partialValue > 0 else {
            throw BeautyError.invalidInput
        }
        return result.partialValue
    }

    private func alignedRowBytes(_ rowBytes: Int) throws -> Int {
        let remainder = rowBytes % 256
        guard remainder != 0 else { return rowBytes }
        return try checkedMultiply((rowBytes / 256) + 1, 256)
    }
}
