import CoreGraphics
import CoreImage
import Foundation
import ImageIO

/// One request-owned, normalized still-image raster for package-internal consumers.
///
/// The carrier deliberately has no exported or SPI byte surface and no diagnostic
/// representation. Every view is derived from the same immutable
/// RGBA8 backing owned by `Storage`.
package struct BeautyCanonicalStillImage: @unchecked Sendable {
    package let width: Int
    package let height: Int
    package let rowBytes: Int
    package let metadata: BeautyInputMetadata

    private let storage: Storage

    package init(
        rgba8Data: Data,
        width: Int,
        height: Int,
        rowBytes: Int,
        metadata: BeautyInputMetadata
    ) throws {
        guard width > 0,
              height > 0,
              metadata.orientation == .up,
              metadata.isInputMirrored == false
        else {
            throw BeautyError.invalidInput
        }

        let (expectedRowBytes, rowOverflow) = width.multipliedReportingOverflow(by: 4)
        guard rowOverflow == false,
              rowBytes == expectedRowBytes
        else {
            throw BeautyError.invalidInput
        }

        let (expectedByteCount, totalOverflow) = rowBytes.multipliedReportingOverflow(by: height)
        guard totalOverflow == false,
              rgba8Data.count == expectedByteCount
        else {
            throw BeautyError.invalidInput
        }

        guard stride(from: 3, to: rgba8Data.count, by: 4).allSatisfy({ rgba8Data[$0] == 255 }) else {
            throw BeautyError.invalidInput
        }

        guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }

        let image = CIImage(
            bitmapData: rgba8Data,
            bytesPerRow: rowBytes,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: sRGB
        )

        self.width = width
        self.height = height
        self.rowBytes = rowBytes
        self.metadata = metadata
        self.storage = Storage(rgba8Data: rgba8Data, image: image)
    }

    package var ciImage: CIImage {
        storage.image
    }

    package var byteCount: Int {
        storage.rgba8Data.count
    }

    package var rgba8Data: Data {
        storage.rgba8Data
    }

    package var backingIdentity: Int {
        ObjectIdentifier(storage).hashValue
    }

    private final class Storage: @unchecked Sendable {
        let rgba8Data: Data
        let image: CIImage

        init(rgba8Data: Data, image: CIImage) {
            self.rgba8Data = rgba8Data
            self.image = image
        }
    }
}
