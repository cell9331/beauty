import BeautyCore
import CoreGraphics
import CoreImage
import CoreVideo
import Foundation

/// An independently authored frontal mechanics drawing. No detector, adapter,
/// provider, output, disk mask, or semantic ROI participates in its recipe.
enum NoseRepairFixture {
    static let width = 512
    static let height = 512
    // Fixed copy of the canonical fixture's head width. Composition is declared
    // before rendering: tall oval, centered horizontally, 35% upper free space.
    static let headWidth: Double = 0.40
    static let headHeight = headWidth * 2
    static let headX = (1 - headWidth) / 2
    static let headY = (1 - headHeight) * 0.35
    static let browPlane = headY + headHeight * 0.25
    static let rootPlane = headY + headHeight * 0.30
    static let innerCanthusPlane = headY + headHeight * 0.34
    static let bridgeTop = headY + headHeight * 0.39
    static let bridgeBottom = headY + headHeight * 0.59
    static let tipPlane = headY + headHeight * 0.66
    static let rootFlanks = [0.5 - headWidth * 0.06, 0.5 + headWidth * 0.06]

    static func metadata() -> BeautyInputMetadata {
        BeautyInputMetadata(orientation: .up, source: .testFixture)
    }

    static func source() -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let px = (Double(x) + 0.5) / Double(width)
                let py = (Double(y) + 0.5) / Double(height)
                let localX = (px - 0.5) / headWidth
                let localY = (py - headY) / headHeight
                // Low-amplitude guard on the entire canvas also covers every
                // protected region, including background and watermark.
                let guardTexture = ((x / 4 + y / 4) % 2 == 0) ? -2 : 2
                var value = 220 + guardTexture
                let insideHead = localX * localX * 4 + pow((localY - 0.5) * 2, 2) <= 1
                if insideHead {
                    // Brow and eye axes are source anatomy, not sampled output.
                    if abs(localY - 0.25) < 0.008 && abs(localX) > 0.12 && abs(localX) < 0.36 {
                        value = 75 + guardTexture
                    }
                    if abs(localY - 0.34) < 0.012 && abs(localX) > 0.10 && abs(localX) < 0.32 {
                        value = 105 + guardTexture
                    }
                    if abs(localY - 0.66) < 0.022 && abs(localX) < 0.09 {
                        value = 170 + guardTexture
                    }
                    let texture = ((37 * x + 17 * y) % 31) - 15
                    if localY >= 0.26 && localY < 0.34 && abs(localX) < 0.18 {
                        value = 230
                        if rootFlanks.contains(where: { abs(px - $0) <= headWidth * 0.015 }) {
                            value = 45
                        }
                        value += texture
                    }
                    if localY >= 0.39 && localY < 0.59 && abs(localX) < 0.18 {
                        value = abs(localX) <= 0.04 ? 238 : 90
                        value += texture
                    }
                }
                let byte = UInt8(clamping: value)
                let offset = (y * width + x) * 4
                bytes[offset] = byte
                bytes[offset + 1] = byte
                bytes[offset + 2] = byte
            }
        }
        return bytes
    }

    static func image() throws -> CIImage {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw FixtureError.carrier
        }
        return CIImage(bitmapData: Data(source()), bytesPerRow: width * 4,
                       size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: colorSpace)
    }

    static func sourceFrame() throws -> BeautyFrame {
        var buffer: CVPixelBuffer?
        guard CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA,
                                  [kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary,
                                  &buffer) == kCVReturnSuccess, let buffer else {
            throw FixtureError.carrier
        }
        guard CVPixelBufferLockBaseAddress(buffer, []) == kCVReturnSuccess else {
            throw FixtureError.carrier
        }
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let address = CVPixelBufferGetBaseAddress(buffer) else { throw FixtureError.carrier }
        let bytes = source()
        let stride = CVPixelBufferGetBytesPerRow(buffer)
        for y in 0..<height {
            let row = address.advanced(by: y * stride).assumingMemoryBound(to: UInt8.self)
            for x in 0..<width {
                let offset = (y * width + x) * 4
                row[x * 4] = bytes[offset + 2]
                row[x * 4 + 1] = bytes[offset + 1]
                row[x * 4 + 2] = bytes[offset]
                row[x * 4 + 3] = 255
            }
        }
        CVBufferSetAttachment(buffer, kCVImageBufferCGColorSpaceKey,
                              CGColorSpace(name: CGColorSpace.sRGB)!, .shouldPropagate)
        return BeautyFrame(pixelBuffer: buffer, orientation: .up, source: .testFixture)
    }

    private enum FixtureError: Error { case carrier }
}
