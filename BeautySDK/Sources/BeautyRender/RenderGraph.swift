import BeautyCore
import CoreVideo

public struct RenderGraph {
    public let passes: [any RenderPass]

    public init(passes: [any RenderPass]) {
        self.passes = passes
    }

    public func render(pixelBuffer: CVPixelBuffer, parameters: BeautyParameters) throws -> CVPixelBuffer {
        var current = pixelBuffer
        let normalized = parameters.normalized()

        for pass in passes where pass.isEnabled(parameters: normalized) {
            current = try pass.apply(to: current, parameters: normalized)
        }

        return current
    }
}
