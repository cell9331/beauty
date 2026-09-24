#!/usr/bin/env swift
// Generated portrait-like inputs exercise public rendering and determinism.
// Actual contour direction is owned by the independent generated silhouette
// oracle in FaceContourSmoothRepairTests, not by changed-pixel counts here.
import CoreGraphics
import CryptoKit
import Foundation
import ImageIO

private enum ProbeError: Error {
    case invalidInput
    case imageDecode
    case mismatch
}

private struct Raster {
    let width: Int
    let height: Int
    let bytes: [UInt8]
}

private func raster(_ path: String) throws -> Raster {
    let url = URL(fileURLWithPath: path)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          CGImageSourceGetCount(source) == 1,
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
          image.width >= 64, image.height >= 64,
          image.width <= 4096, image.height <= 4096,
          let space = CGColorSpace(name: CGColorSpace.sRGB) else {
        throw ProbeError.imageDecode
    }
    let pixelCount = image.width.multipliedReportingOverflow(by: image.height)
    guard !pixelCount.overflow else { throw ProbeError.imageDecode }
    let count = pixelCount.partialValue.multipliedReportingOverflow(by: 4)
    guard !count.overflow else { throw ProbeError.imageDecode }
    var bytes = [UInt8](repeating: 0, count: count.partialValue)
    let rendered = bytes.withUnsafeMutableBytes { buffer -> Bool in
        guard let context = CGContext(
            data: buffer.baseAddress,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width * 4,
            space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue |
                CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return false }
        context.interpolationQuality = .none
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return true
    }
    guard rendered else { throw ProbeError.imageDecode }
    return Raster(width: image.width, height: image.height, bytes: bytes)
}

private func changedPixels(_ lhs: Raster, _ rhs: Raster) throws -> Int {
    guard lhs.width == rhs.width, lhs.height == rhs.height,
          lhs.bytes.count == rhs.bytes.count else { throw ProbeError.mismatch }
    var changed = 0
    for offset in stride(from: 0, to: lhs.bytes.count, by: 4) {
        guard lhs.bytes[offset + 3] == rhs.bytes[offset + 3] else {
            throw ProbeError.mismatch
        }
        if lhs.bytes[offset] != rhs.bytes[offset] ||
            lhs.bytes[offset + 1] != rhs.bytes[offset + 1] ||
            lhs.bytes[offset + 2] != rhs.bytes[offset + 2] {
            changed += 1
        }
    }
    return changed
}

private func evaluate(
    source: Raster,
    neutral: Raster,
    candidate: Raster,
    repeated: Raster
) throws -> Int {
    guard source.width == neutral.width, source.height == neutral.height,
          source.width == candidate.width, source.height == candidate.height,
          source.width == repeated.width, source.height == repeated.height,
          try changedPixels(source, neutral) == 0,
          try changedPixels(candidate, repeated) == 0 else {
        throw ProbeError.mismatch
    }
    let changed = try changedPixels(neutral, candidate)
    guard changed > 0 else { throw ProbeError.mismatch }
    return changed
}

private func selfTest() throws {
    let source = Raster(width: 64, height: 64,
                        bytes: [UInt8](repeating: 255, count: 64 * 64 * 4))
    var changed = source.bytes
    changed[0] = 250
    let candidate = Raster(width: 64, height: 64, bytes: changed)
    guard try evaluate(source: source, neutral: source,
                       candidate: candidate, repeated: candidate) == 1 else {
        throw ProbeError.mismatch
    }
    func rejects(_ block: () throws -> Int) -> Bool {
        do { _ = try block(); return false } catch { return true }
    }
    guard rejects({ try evaluate(source: source, neutral: source,
                                 candidate: source, repeated: source) }),
          rejects({ try evaluate(source: source, neutral: source,
                                 candidate: candidate, repeated: source) }) else {
        throw ProbeError.mismatch
    }
    var badAlpha = changed
    badAlpha[3] = 0
    guard rejects({ try evaluate(source: source, neutral: source,
                                 candidate: Raster(width: 64, height: 64, bytes: badAlpha),
                                 repeated: Raster(width: 64, height: 64, bytes: badAlpha)) }) else {
        throw ProbeError.mismatch
    }
    print("{\"status\":\"pass\",\"self_tests\":4}")
}

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    if arguments == ["--self-test"] {
        try selfTest()
    } else {
        guard arguments.count == 8 else { throw ProbeError.invalidInput }
        var changes: [Int] = []
        var sourceHashes: [String] = []
        for offset in stride(from: 0, to: 8, by: 4) {
            let inputs = Array(arguments[offset..<(offset + 4)])
            let source = try raster(inputs[0])
            let neutral = try raster(inputs[1])
            let candidate = try raster(inputs[2])
            let repeated = try raster(inputs[3])
            changes.append(try evaluate(source: source, neutral: neutral,
                                        candidate: candidate, repeated: repeated))
            let digest = SHA256.hash(data: try Data(contentsOf: URL(fileURLWithPath: inputs[0])))
            sourceHashes.append(digest.map { String(format: "%02x", $0) }.joined())
        }
        let result: [String: Any] = [
            "schema": "v123-generated-portrait-mechanics-v1",
            "status": "pass",
            "input_count": 2,
            "changed_pixels": changes,
            "source_sha256": sourceHashes,
            "repeat_identical": true,
            "neutral_identical": true,
            "alpha_identical": true,
            "effectiveness_credit": false
        ]
        let data = try JSONSerialization.data(withJSONObject: result, options: [.sortedKeys])
        print(String(data: data, encoding: .utf8)!)
    }
} catch {
    fputs("v123_generated_portrait_probe_failed\n", stderr)
    exit(1)
}
