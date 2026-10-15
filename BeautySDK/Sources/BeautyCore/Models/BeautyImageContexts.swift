import CoreGraphics
import CoreImage

/// Shared framework resources only. No image, observation, mask or request is
/// retained here. The cache has three named profiles, never caller-owned keys.
package enum BeautyImageContexts {
    private final class Holder: @unchecked Sendable {
        let colorSpace: CGColorSpace
        let context: CIContext
        init(_ colorSpace: CGColorSpace) {
            self.colorSpace = colorSpace
            context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        }
    }
    private static let sRGB = Holder(CGColorSpace(name: CGColorSpace.sRGB)!)
    private static let displayP3 = Holder(CGColorSpace(name: CGColorSpace.displayP3)!)
    private static let deviceRGB = Holder(CGColorSpaceCreateDeviceRGB())

    package static func context(for colorSpace: CGColorSpace) -> CIContext {
        for holder in [sRGB, displayP3, deviceRGB] where CFEqual(holder.colorSpace, colorSpace) {
            return holder.context
        }
        // Preserve the caller's exact color semantics without an unbounded ICC
        // registry. Unknown profiles remain request-local.
        return CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
    }
}
