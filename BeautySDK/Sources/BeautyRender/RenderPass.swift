import BeautyCore
import CoreVideo

public protocol RenderPass {
    var id: String { get }
    func isEnabled(parameters: BeautyParameters) -> Bool
    func apply(to pixelBuffer: CVPixelBuffer, parameters: BeautyParameters) throws -> CVPixelBuffer
}

public extension RenderPass {
    func isEnabled(parameters: BeautyParameters) -> Bool {
        _ = parameters
        return true
    }
}
