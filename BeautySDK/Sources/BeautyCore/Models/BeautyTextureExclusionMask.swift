import Foundation

/// Request-local protection for skin smoothing and sharpening on still images.
///
/// The mask uses the upright, input-mirror-corrected image grid. A byte of 255
/// protects that pixel from the skin-texture stage; 0 leaves it eligible for
/// the stage's existing face, color, and edge checks. The mask is never included
/// in results or diagnostics.
public struct BeautyTextureExclusionMask: Sendable, CustomStringConvertible,
    CustomDebugStringConvertible, CustomReflectable {
    public let width: Int
    public let height: Int
    package let bytes: [UInt8]

    public init(width: Int, height: Int, bytes: [UInt8]) throws {
        let count = width.multipliedReportingOverflow(by: height)
        guard width > 0, height > 0, !count.overflow,
              bytes.count == count.partialValue,
              bytes.allSatisfy({ $0 == 0 || $0 == 255 })
        else { throw BeautyError.invalidInput }
        self.width = width
        self.height = height
        self.bytes = bytes
    }

    public var description: String {
        "BeautyTextureExclusionMask(width: \(width), height: \(height))"
    }

    public var debugDescription: String { description }

    public var customMirror: Mirror {
        Mirror(self, children: ["width": width, "height": height], displayStyle: .struct)
    }
}
