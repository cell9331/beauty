import CoreGraphics
import CoreImage
import Foundation
@_spi(Testing) import BeautySDK

enum RepairedControlSafetyFixture {
    static let width = 640
    static let height = 800
    static func source() -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            // Fixed nonuniform RGB signal makes a valid subpixel warp observable;
            // a flat source can otherwise make an all-no-op recovery look correct.
            let i = (y * width + x) * 4
            bytes[i] = UInt8(40 + (x * 17 + y * 29) % 176)
            bytes[i + 1] = UInt8(40 + (x * 31 + y * 11) % 176)
            bytes[i + 2] = UInt8(40 + (x * 7 + y * 23) % 176)
        }}
        return bytes
    }
    static func image() throws -> CIImage {
        guard let color = CGColorSpace(name: CGColorSpace.sRGB) else { throw FixtureError.carrier }
        return CIImage(bitmapData: Data(source()), bytesPerRow: width * 4,
                       size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: color)
    }
    static func metadata() -> BeautyInputMetadata { BeautyInputMetadata(orientation: .up, source: .testFixture) }
    enum FixtureError: Error { case carrier }
}
