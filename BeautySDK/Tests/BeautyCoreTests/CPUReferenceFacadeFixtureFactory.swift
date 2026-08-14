import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import BeautySDK

struct CPUReferenceFacadeFixture {
    let width: Int
    let height: Int
    let rgba8: [UInt8]
    let image: CIImage
    let metadata: BeautyInputMetadata

    var rowBytes: Int { width * 4 }
    var byteCount: Int { rgba8.count }
    var colorSpaceName: CFString? { image.colorSpace?.name }
    var alphaValues: [UInt8] {
        stride(from: 3, to: rgba8.count, by: 4).map { rgba8[$0] }
    }

    static func opaqueNeutral(width: Int = 8, height: Int = 6) throws -> CPUReferenceFacadeFixture {
        let bytes = makeBytes(width: width, height: height, alpha: 255) { x, y in
            let value = UInt8((x * 17 + y * 31 + 41) % 256)
            return (value, value, value)
        }
        return try make(width: width, height: height, rgba8: bytes)
    }

    static func geometryGradient(width: Int = 8, height: Int = 6) throws -> CPUReferenceFacadeFixture {
        let bytes = makeBytes(width: width, height: height, alpha: 255) { x, y in
            let red = UInt8((x * 29 + y * 7) % 256)
            let green = UInt8((x * 5 + y * 37 + 23) % 256)
            let blue = UInt8((x * 11 + y * 13 + 47) % 256)
            return (red, green, blue)
        }
        return try make(width: width, height: height, rgba8: bytes)
    }

    static func alphaBoundary() throws -> CPUReferenceFacadeFixture {
        let alphas: [UInt8] = [0, 1, 127, 254, 255]
        let bytes = makeBytes(width: alphas.count, height: 1, alpha: 255) { x, _ in
            (92, 128, 164, alphas[x])
        }
        return try make(width: alphas.count, height: 1, rgba8: bytes)
    }

    private static func make(width: Int, height: Int, rgba8: [UInt8]) throws -> CPUReferenceFacadeFixture {
        guard width > 0, height > 0, rgba8.count == width * height * 4,
              let sRGB = CGColorSpace(name: CGColorSpace.sRGB)
        else { throw BeautyError.invalidInput }
        let image = CIImage(
            bitmapData: Data(rgba8),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: sRGB
        )
        return CPUReferenceFacadeFixture(
            width: width,
            height: height,
            rgba8: rgba8,
            image: image,
            metadata: BeautyInputMetadata(
                orientation: .up,
                isInputMirrored: false,
                isPreviewMirrored: false,
                source: .testFixture
            )
        )
    }

    private static func makeBytes(
        width: Int,
        height: Int,
        alpha: UInt8,
        pixel: (Int, Int) -> (UInt8, UInt8, UInt8)
    ) -> [UInt8] {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let value = pixel(x, y)
                bytes.append(contentsOf: [value.0, value.1, value.2, alpha])
            }
        }
        return bytes
    }

    private static func makeBytes(
        width: Int,
        height: Int,
        alpha: UInt8,
        pixel: (Int, Int) -> (UInt8, UInt8, UInt8, UInt8)
    ) -> [UInt8] {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let value = pixel(x, y)
                bytes.append(contentsOf: [value.0, value.1, value.2, value.3])
            }
        }
        return bytes
    }
}
