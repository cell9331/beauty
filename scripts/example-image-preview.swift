import CoreGraphics
import Foundation
import ImageIO

// ImageIO may synthesize an EXIF dimension dictionary even when encoding a
// fresh CGImage. Remove optional metadata segments, retaining the sRGB ICC
// profile and the compressed scan bytes exactly.
func stripMetadata(_ data: Data) throws -> Data {
    let bytes = [UInt8](data)
    guard bytes.count > 2, bytes[0] == 255, bytes[1] == 216
    else { throw NSError(domain: "preview", code: 9) }
    var result = Data(bytes[0..<2])
    var offset = 2
    while offset + 4 <= bytes.count {
        let start = offset
        guard bytes[offset] == 255 else { throw NSError(domain: "preview", code: 9) }
        while offset < bytes.count && bytes[offset] == 255 { offset += 1 }
        guard offset + 2 < bytes.count else { throw NSError(domain: "preview", code: 9) }
        let marker = bytes[offset]
        offset += 1
        if marker == 218 {
            result.append(contentsOf: bytes[start...])
            return result
        }
        let length = Int(bytes[offset]) * 256 + Int(bytes[offset + 1])
        guard length >= 2, offset + length <= bytes.count
        else { throw NSError(domain: "preview", code: 9) }
        if ![225, 237, 254].contains(marker) {
            result.append(contentsOf: bytes[start..<(offset + length)])
        }
        offset += length
    }
    throw NSError(domain: "preview", code: 9)
}

// Display copies only. Exact fixtures and renderer validation output are never
// re-encoded or substituted by this helper.
func makePreview(source: URL, output: URL) throws {
    guard let input = CGImageSourceCreateWithURL(source as CFURL, nil),
          CGImageSourceGetCount(input) == 1,
          let properties = CGImageSourceCopyPropertiesAtIndex(input, 0, nil) as? [CFString: Any],
          let width = properties[kCGImagePropertyPixelWidth] as? Int,
          let height = properties[kCGImagePropertyPixelHeight] as? Int,
          width > 0, height > 0, width <= 40_000_000 / height,
          let color = CGColorSpace(name: CGColorSpace.sRGB)
    else { throw NSError(domain: "preview", code: 1) }

    for edge in [1600, 1280, 1024, 800] {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: min(edge, max(width, height)),
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(input, 0, options as CFDictionary),
              let context = CGContext(data: nil, width: image.width, height: image.height,
                                      bitsPerComponent: 8, bytesPerRow: image.width * 4,
                                      space: color, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        else { throw NSError(domain: "preview", code: 2) }
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        let rectangle = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        context.fill(rectangle)
        context.draw(image, in: rectangle)
        guard let opaque = context.makeImage() else { throw NSError(domain: "preview", code: 3) }
        for quality in [0.8, 0.7, 0.6] {
            let data = NSMutableData()
            guard let encoder = CGImageDestinationCreateWithData(data, "public.jpeg" as CFString, 1, nil)
            else { throw NSError(domain: "preview", code: 4) }
            // Encode fresh pixels. Source EXIF, GPS, TIFF, orientation and
            // provenance dictionaries are deliberately not copied.
            CGImageDestinationAddImage(encoder, opaque, [
                kCGImageDestinationLossyCompressionQuality: quality
            ] as CFDictionary)
            guard CGImageDestinationFinalize(encoder) else { throw NSError(domain: "preview", code: 5) }
            let stripped = try stripMetadata(data as Data)
            if stripped.count > 512 * 1024 { continue }
            guard let decoded = CGImageSourceCreateWithData(stripped as CFData, nil),
                  let check = CGImageSourceCreateImageAtIndex(decoded, 0, nil),
                  check.width == image.width, check.height == image.height,
                  max(check.width, check.height) <= 1600,
                  let metadata = CGImageSourceCopyPropertiesAtIndex(decoded, 0, nil) as? [CFString: Any],
                  metadata[kCGImagePropertyGPSDictionary] == nil,
                  metadata[kCGImagePropertyExifDictionary] == nil,
                  metadata[kCGImagePropertyTIFFDictionary] == nil,
                  metadata[kCGImagePropertyOrientation] == nil
            else { throw NSError(domain: "preview", code: 6) }
            try stripped.write(to: output, options: .atomic)
            return
        }
    }
    throw NSError(domain: "preview", code: 7)
}

do {
    guard CommandLine.arguments.count == 3 else { throw NSError(domain: "preview", code: 8) }
    try makePreview(source: URL(fileURLWithPath: CommandLine.arguments[1]),
                    output: URL(fileURLWithPath: CommandLine.arguments[2]))
} catch {
    FileHandle.standardError.write(Data("preview_encoding_failed_\((error as NSError).code)\n".utf8))
    exit(1)
}
