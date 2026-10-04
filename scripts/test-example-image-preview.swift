import CoreGraphics
import Foundation
import ImageIO

func require(_ value: Bool, line: UInt = #line) throws {
    if !value { throw NSError(domain: "preview-test", code: Int(line)) }
}

func run() throws {
    try require(CommandLine.arguments.count == 2)
    let helper = URL(fileURLWithPath: CommandLine.arguments[1])
    let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: temporary) }
    let color = CGColorSpace(name: CGColorSpace.sRGB)!

    func invoke(_ source: URL, _ output: URL) throws -> Int32 {
        let child = Process()
        child.executableURL = helper
        child.arguments = [source.path, output.path]
        child.standardOutput = FileHandle.nullDevice
        child.standardError = FileHandle.nullDevice
        try child.run()
        child.waitUntilExit()
        return child.terminationStatus
    }

    for (index, width, height, orientation) in [(0, 64, 32, 6), (1, 2048, 256, 1)] {
        let source = temporary.appendingPathComponent("source\(index).png")
        let output = temporary.appendingPathComponent("preview\(index).jpg")
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                bytesPerRow: width * 4, space: color,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.setFillColor(red: 1, green: 0, blue: 0, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width / 2, height: height))
        let encoder = CGImageDestinationCreateWithURL(source as CFURL, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(encoder, context.makeImage()!, [
            kCGImagePropertyOrientation: orientation,
            kCGImagePropertyExifDictionary: [kCGImagePropertyExifDateTimeOriginal: "2000:01:01 00:00:00"],
            kCGImagePropertyGPSDictionary: [kCGImagePropertyGPSLatitude: 1.0, kCGImagePropertyGPSLatitudeRef: "N"],
        ] as CFDictionary)
        try require(CGImageDestinationFinalize(encoder))
        let before = try Data(contentsOf: source)
        try require(try invoke(source, output) == 0)
        try require(try Data(contentsOf: source) == before)
        let data = try Data(contentsOf: output)
        try require(data.count <= 512 * 1024)
        let decoded = CGImageSourceCreateWithData(data as CFData, nil)!
        let image = CGImageSourceCreateImageAtIndex(decoded, 0, nil)!
        let properties = CGImageSourceCopyPropertiesAtIndex(decoded, 0, nil) as! [CFString: Any]
        try require(properties[kCGImagePropertyGPSDictionary] == nil)
        try require(properties[kCGImagePropertyExifDictionary] == nil)
        try require(properties[kCGImagePropertyTIFFDictionary] == nil)
        try require(properties[kCGImagePropertyOrientation] == nil)
        try require(image.colorSpace?.name == CGColorSpace.sRGB)
        try require(index == 0 ? (image.width == 32 && image.height == 64)
                              : (image.width == 1600 && image.height == 200))
        let raster = CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: 8,
                               bytesPerRow: image.width * 4, space: color,
                               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        raster.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let pixels = raster.data!.assumingMemoryBound(to: UInt8.self)
        var red = 0, white = 0
        for pixel in 0..<(image.width * image.height) {
            let offset = pixel * 4
            if pixels[offset] > 230 && pixels[offset + 1] < 25 && pixels[offset + 2] < 25 { red += 1 }
            if pixels[offset] > 230 && pixels[offset + 1] > 230 && pixels[offset + 2] > 230 { white += 1 }
            try require(pixels[offset + 3] == 255)
        }
        let count = image.width * image.height
        try require(red > count * 45 / 100 && white > count * 45 / 100)
    }
    let corrupt = temporary.appendingPathComponent("corrupt.png")
    try Data("invalid".utf8).write(to: corrupt)
    let absent = temporary.appendingPathComponent("absent.jpg")
    try require(try invoke(corrupt, absent) != 0)
    try require(!FileManager.default.fileExists(atPath: absent.path))
    print("preview_pixel_metadata_checks_passed cases=3")
}

do { try run() } catch {
    print("preview_pixel_metadata_checks_failed_\((error as NSError).code)")
    exit(1)
}
