#!/usr/bin/env swift
// FUTURE-04 generated-portrait oracle. Source identities, cheek rows, boundary
// estimator, protected regions and direction thresholds were fixed from the
// generated source pair before any FACE-01 candidate render was inspected.
// Outputs contain aggregates only; source images remain ignored local inputs.

import CoreGraphics
import CryptoKit
import Foundation
import ImageIO

private enum CheckError: Error { case invalidInput, imageDecode, sourceMismatch, failed }

private struct Raster {
    let width: Int
    let height: Int
    let bytes: [UInt8]
}

private let expectedSourceHashes = [
    "f6b1ec8a8ed3cac2e8967ff24d23e40bdcd5eb78d76703d49af13effad97a2c0",
    "4b5ea68cda785fbc611167e014b86cb83776c571deff13ada8ca355d8f220956",
]
private let cheekRows = 700..<900
private let edgeThreshold = 20
private let roughnessOffset = 20

private func read(_ path: String) throws -> Raster {
    let url = URL(fileURLWithPath: path)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          CGImageSourceGetCount(source) == 1,
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
          image.width == 1_254, image.height == 1_254,
          let space = CGColorSpace(name: CGColorSpace.sRGB) else {
        throw CheckError.imageDecode
    }
    var bytes = [UInt8](repeating: 0, count: image.width * image.height * 4)
    let decoded = bytes.withUnsafeMutableBytes { raw -> Bool in
        guard let context = CGContext(
            data: raw.baseAddress, width: image.width, height: image.height,
            bitsPerComponent: 8, bytesPerRow: image.width * 4, space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue |
                CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return false }
        context.interpolationQuality = .none
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return true
    }
    guard decoded else { throw CheckError.imageDecode }
    return Raster(width: image.width, height: image.height, bytes: bytes)
}

private func sourceHash(_ path: String) throws -> String {
    let digest = SHA256.hash(data: try Data(contentsOf: URL(fileURLWithPath: path)))
    return digest.map { String(format: "%02x", $0) }.joined()
}

private func edge(_ image: Raster, row: Int, left: Bool) -> Int? {
    let columns = left ? Array(200..<625) : Array((625..<1050).reversed())
    for x in columns {
        let offset = (row * image.width + x) * 4
        if Int(image.bytes[offset]) - Int(image.bytes[offset + 2]) > edgeThreshold {
            return x
        }
    }
    return nil
}

private func roughness(_ image: Raster, left: Bool) throws -> Double {
    let values = try cheekRows.map { row -> Int in
        guard let value = edge(image, row: row, left: left) else {
            throw CheckError.imageDecode
        }
        return value
    }
    var sum = 0.0
    for index in roughnessOffset..<(values.count - roughnessOffset) {
        sum += Double(abs(values[index - roughnessOffset] -
                          2 * values[index] + values[index + roughnessOffset]))
    }
    return sum / Double(values.count - 2 * roughnessOffset)
}

private func changed(_ a: Raster, _ b: Raster, within include: (Int, Int) -> Bool) -> Int {
    var count = 0
    for y in 0..<a.height {
        for x in 0..<a.width where include(x, y) {
            let offset = (y * a.width + x) * 4
            if (0..<3).contains(where: { a.bytes[offset + $0] != b.bytes[offset + $0] }) {
                count += 1
            }
        }
    }
    return count
}

private func sameAlpha(_ a: Raster, _ b: Raster) -> Bool {
    stride(from: 3, to: a.bytes.count, by: 4).allSatisfy {
        a.bytes[$0] == b.bytes[$0]
    }
}

private func report(_ dictionary: [String: Any]) throws {
    let data = try JSONSerialization.data(withJSONObject: dictionary, options: [.sortedKeys])
    print(String(data: data, encoding: .utf8)!)
}

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    guard arguments.count == 3 || arguments.count == 9,
          arguments[0] == "--sources" || arguments[0] == "--evaluate" else {
        throw CheckError.invalidInput
    }
    let sourcePaths = Array(arguments[1...2])
    guard try zip(sourcePaths, expectedSourceHashes).allSatisfy({ path, hash in
        try sourceHash(path) == hash
    }) else { throw CheckError.sourceMismatch }
    let sources = try sourcePaths.map(read)
    let sourceRough = try sources.map { image in
        try [roughness(image, left: true), roughness(image, left: false)]
    }
    let admitted = sourceRough[0][1] > 4 &&
        sourceRough[0][1] > 1.5 * sourceRough[1][1]
    if arguments[0] == "--sources" {
        guard arguments.count == 3 else { throw CheckError.invalidInput }
        try report([
            "schema": "face01-diversity-effect-v1", "phase": "source",
            "status": admitted ? "pass" : "fail", "roughness": sourceRough,
        ])
        if !admitted { throw CheckError.failed }
    } else {
        guard arguments.count == 9 else { throw CheckError.invalidInput }
        // Per source: neutral, candidate, repeated candidate.
        let outputs = try arguments[3...].map(read)
        var candidateRough: [[Double]] = []
        var targetChanges: [Int] = []
        var protectedChanges: [Int] = []
        var totalChanges: [Int] = []
        var metadataOK = true
        var hairChanged: [Int] = []
        var hairSourcePixels: [Int] = []
        for caseIndex in 0..<2 {
            let source = sources[caseIndex]
            let neutral = outputs[caseIndex * 3]
            let candidate = outputs[caseIndex * 3 + 1]
            let repeated = outputs[caseIndex * 3 + 2]
            let sourceEdges = (550..<1000).map { row in
                (edge(source, row: row, left: true), edge(source, row: row, left: false))
            }
            let all: (Int, Int) -> Bool = { _, _ in true }
            metadataOK = metadataOK && source.bytes == neutral.bytes &&
                candidate.bytes == repeated.bytes && sameAlpha(source, candidate)
            candidateRough.append(try [roughness(candidate, left: true),
                                       roughness(candidate, left: false)])
            totalChanges.append(changed(source, candidate, within: all))
            targetChanges.append(changed(source, candidate) { x, y in
                guard (550..<1000).contains(y),
                      let leftEdge = sourceEdges[y - 550].0,
                      let rightEdge = sourceEdges[y - 550].1 else { return false }
                return abs(x - leftEdge) <= 100 || abs(x - rightEdge) <= 100
            })
            protectedChanges.append(changed(source, candidate) { x, y in
                x < 250 || x >= 1004 || (530..<725).contains(x) && (550..<1000).contains(y)
            })
            let hair: (Int, Int) -> Bool = { x, y in
                guard (250..<390).contains(x), (550..<1000).contains(y) else { return false }
                let offset = (y * source.width + x) * 4
                return max(source.bytes[offset], source.bytes[offset + 1], source.bytes[offset + 2]) < 70
            }
            hairSourcePixels.append((550..<1000).reduce(0) { count, y in
                count + (250..<390).filter { hair($0, y) }.count
            })
            hairChanged.append(changed(source, candidate, within: hair))
        }
        let positiveImproves = candidateRough[0][1] <= sourceRough[0][1] * 0.90
        let negativeSafe = candidateRough[1][1] <= sourceRough[1][1] * 1.10
        let bounded = (0..<2).allSatisfy { index in
            protectedChanges[index] == 0 && hairChanged[index] == 0 &&
                targetChanges[index] * 100 >= totalChanges[index] * 95
        }
        let pass = admitted && metadataOK && positiveImproves && negativeSafe && bounded &&
            targetChanges[0] > 100
        try report([
            "schema": "face01-diversity-effect-v1", "phase": "effect",
            "status": pass ? "pass" : "fail", "sourceRoughness": sourceRough,
            "candidateRoughness": candidateRough,
            "targetChanged": targetChanges, "protectedChanged": protectedChanges,
            "totalChanged": totalChanges, "hairChanged": hairChanged,
            "hairSourcePixels": hairSourcePixels, "neutralAndRepeatAndAlpha": metadataOK,
            "positiveImproves": positiveImproves, "negativeSafe": negativeSafe,
            "bounded": bounded,
        ])
        if !pass { throw CheckError.failed }
    }
} catch {
    fputs("face01_generated_effect_failed\n", stderr)
    exit(1)
}
