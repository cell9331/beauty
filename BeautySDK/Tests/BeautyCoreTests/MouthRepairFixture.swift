import BeautyCore
import CoreGraphics
import CoreImage
import CoreVideo
import Foundation

/// Fixed, source-first portrait. No detector, geometry, metric or output inputs.
enum MouthRepairFixture {
    static let width = 640
    static let height = 800

    static func metadata() -> BeautyInputMetadata {
        BeautyInputMetadata(orientation: .up, source: .testFixture)
    }

    static func source() -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        func ellipse(_ x: Double, _ y: Double, _ cx: Double, _ cy: Double,
                     _ rx: Double, _ ry: Double) -> Double {
            let a = (x - cx) / rx
            let b = (y - cy) / ry
            return a * a + b * b
        }
        for y in 0..<height {
            for x in 0..<width {
                let px = Double(x) + 0.5
                let py = Double(y) + 0.5
                var value = 240
                if ellipse(px, py, 320, 384, 256, 336) <= 1 { value = 224 }
                if ellipse(px, py, 224, 304, 48, 16) <= 1
                    || ellipse(px, py, 416, 304, 48, 16) <= 1 { value = 96 }
                if py >= 368 && py <= 448 && abs(px - 320) <= (py - 368) * 24 / 80 {
                    value = 176
                }
                let q = ellipse(px, py, 320, 560, 104, 52)
                if q <= 1 { value = 144 }
                if q >= 0.80 && q <= 1.20 { value = 80 }
                if ellipse(px, py, 320, 560, 52, 24) <= 1 { value = 32 }
                let v = UInt8(value + ((x / 64 + y / 64) % 2))
                let i = (y * width + x) * 4
                bytes[i] = v
                bytes[i + 1] = v
                bytes[i + 2] = v
            }
        }
        return bytes
    }

    static func image() throws -> CIImage {
        guard let color = CGColorSpace(name: CGColorSpace.sRGB) else { throw Admission.carrier }
        return CIImage(bitmapData: Data(source()), bytesPerRow: width * 4,
                       size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: color)
    }

    static func sourceFrame() throws -> BeautyFrame {
        var carrier: CVPixelBuffer?
        guard CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA,
                                  [kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary,
                                  &carrier) == kCVReturnSuccess, let buffer = carrier,
              CVPixelBufferLockBaseAddress(buffer, []) == kCVReturnSuccess else { throw Admission.carrier }
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let address = CVPixelBufferGetBaseAddress(buffer),
              let color = CGColorSpace(name: CGColorSpace.sRGB) else { throw Admission.carrier }
        let bytes = source()
        let rowBytes = CVPixelBufferGetBytesPerRow(buffer)
        for y in 0..<height {
            let row = address.advanced(by: y * rowBytes).assumingMemoryBound(to: UInt8.self)
            for x in 0..<width {
                let i = (y * width + x) * 4
                row[x * 4] = bytes[i + 2]
                row[x * 4 + 1] = bytes[i + 1]
                row[x * 4 + 2] = bytes[i]
                row[x * 4 + 3] = bytes[i + 3]
            }
        }
        CVBufferSetAttachment(buffer, kCVImageBufferCGColorSpaceKey, color, .shouldPropagate)
        return BeautyFrame(pixelBuffer: buffer, orientation: .up, source: .testFixture)
    }

    private enum Admission: Error { case carrier }
}
