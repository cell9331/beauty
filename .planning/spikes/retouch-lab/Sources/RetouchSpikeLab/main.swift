import CoreGraphics
import CoreImage
import CoreML
import CoreVideo
import Darwin
import Foundation
import ImageIO
import UniformTypeIdentifiers
import Vision

private struct Point: Codable, Sendable {
    let x: Double
    let y: Double
}

private struct Band: Codable, Sendable {
    let centerX: Double
    let radiusX: Double
    let top: Double
    let bottom: Double
}

private struct FaceAnchors: Sendable {
    let leftEye: [Point]
    let rightEye: [Point]
    let leftPupil: Point?
    let rightPupil: Point?
    let leftBrow: [Point]
    let rightBrow: [Point]
    let innerLips: [Point]
}

private struct LabEvent: Codable, Sendable {
    let timestamp: String
    let category: String
    let message: String
    let metadata: [String: String]
}

private struct ExperimentMetrics: Codable, Sendable {
    let mode: String
    let inputWidth: Int
    let inputHeight: Int
    let faceCount: Int
    let supportPointCounts: [String: Int]
    let maskPixels: Int
    let maskCoverage: Double
    let changedPixels: Int
    let changedOutsideMask: Int
    let maximumChannelDelta: Double
    let meanLuminanceDelta: Double
    let textureEnergyRatio: Double?
    let durationMilliseconds: Double
    let peakResidentMegabytes: Double
    let notes: [String]
}

private enum LabError: Error, CustomStringConvertible {
    case invalidArguments(String)
    case imageLoadFailed(String)
    case imageWriteFailed(String)
    case noFace
    case missingSupport(String)
    case modelLoadFailed(String)
    case modelOutputMissing

    var description: String {
        switch self {
        case let .invalidArguments(text): return text
        case let .imageLoadFailed(path): return "Unable to load image: \(path)"
        case let .imageWriteFailed(path): return "Unable to write image: \(path)"
        case .noFace: return "No usable face landmarks were detected"
        case let .missingSupport(name): return "Missing required support: \(name)"
        case let .modelLoadFailed(path): return "Unable to load Core ML model: \(path)"
        case .modelOutputMissing: return "Core ML teeth output out3 was not returned"
        }
    }
}

private struct Raster: Sendable {
    let width: Int
    let height: Int
    var pixels: [UInt8]

    init(cgImage: CGImage) throws {
        width = cgImage.width
        height = cgImage.height
        pixels = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            throw LabError.imageLoadFailed("bitmap context")
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    }

    init(width: Int, height: Int, fill: (UInt8, UInt8, UInt8, UInt8)) {
        self.width = width
        self.height = height
        pixels = [UInt8](repeating: 0, count: width * height * 4)
        for index in stride(from: 0, to: pixels.count, by: 4) {
            pixels[index] = fill.0
            pixels[index + 1] = fill.1
            pixels[index + 2] = fill.2
            pixels[index + 3] = fill.3
        }
    }

    func makeCGImage() throws -> CGImage {
        let data = Data(pixels) as CFData
        guard let provider = CGDataProvider(data: data),
              let image = CGImage(
                  width: width,
                  height: height,
                  bitsPerComponent: 8,
                  bitsPerPixel: 32,
                  bytesPerRow: width * 4,
                  space: CGColorSpaceCreateDeviceRGB(),
                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
                      .union(.byteOrder32Big),
                  provider: provider,
                  decode: nil,
                  shouldInterpolate: true,
                  intent: .defaultIntent
              )
        else {
            throw LabError.imageLoadFailed("CGImage creation")
        }
        return image
    }

    func offset(x: Int, y: Int) -> Int {
        (y * width + x) * 4
    }

    func rgb(x: Int, y: Int) -> (Float, Float, Float) {
        let index = offset(x: x, y: y)
        return (
            Float(pixels[index]) / 255,
            Float(pixels[index + 1]) / 255,
            Float(pixels[index + 2]) / 255
        )
    }

    mutating func setRGB(x: Int, y: Int, red: Float, green: Float, blue: Float) {
        let index = offset(x: x, y: y)
        pixels[index] = byte(red)
        pixels[index + 1] = byte(green)
        pixels[index + 2] = byte(blue)
    }
}

private struct DetectionResult: Sendable {
    let anchors: FaceAnchors
    let faceCount: Int
}

private struct ParsedArguments {
    let mode: String
    let options: [String: String]

    init(_ arguments: [String]) throws {
        var mode: String?
        var options: [String: String] = [:]
        var index = 0
        while index < arguments.count {
            let value = arguments[index]
            if value == "--mode" {
                guard index + 1 < arguments.count else {
                    throw LabError.invalidArguments("--mode requires a value")
                }
                mode = arguments[index + 1]
                index += 2
            } else if value.hasPrefix("--") {
                guard index + 1 < arguments.count else {
                    throw LabError.invalidArguments("\(value) requires a value")
                }
                options[String(value.dropFirst(2))] = arguments[index + 1]
                index += 2
            } else {
                throw LabError.invalidArguments("Unexpected argument: \(value)")
            }
        }
        guard let mode else {
            throw LabError.invalidArguments("Usage: retouch-spike-lab --mode <name> [--input path] [--output path]")
        }
        self.mode = mode
        self.options = options
    }
}

private final class EventLog {
    private(set) var events: [LabEvent] = []
    private let formatter = ISO8601DateFormatter()

    func add(_ category: String, _ message: String, metadata: [String: String] = [:]) {
        events.append(
            LabEvent(
                timestamp: formatter.string(from: Date()),
                category: category,
                message: message,
                metadata: metadata
            )
        )
    }
}

@main
private enum RetouchSpikeLab {
    static func main() {
        do {
            let parsed = try ParsedArguments(Array(CommandLine.arguments.dropFirst()))
            if parsed.mode == "self-test" {
                try runSelfTests()
                print("SELF-TEST PASS: 7/7")
                return
            }
            try run(parsed)
        } catch {
            FileHandle.standardError.write(Data("ERROR: \(error)\n".utf8))
            exit(1)
        }
    }

    private static func run(_ parsed: ParsedArguments) throws {
        guard let inputPath = parsed.options["input"],
              let outputPath = parsed.options["output"]
        else {
            throw LabError.invalidArguments("--input and --output are required")
        }
        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        let log = EventLog()
        log.add("start", "experiment started", metadata: ["mode": parsed.mode])

        let inputURL = URL(fileURLWithPath: inputPath)
        let cgImage = try loadCGImage(inputURL)
        let input = try Raster(cgImage: cgImage)
        let detectionStart = Date()
        let detection = try detectAnchors(cgImage: cgImage, width: input.width, height: input.height)
        log.add(
            "detection",
            "request-local landmark support captured",
            metadata: [
                "faces": "\(detection.faceCount)",
                "leftEyeCount": "\(detection.anchors.leftEye.count)",
                "rightEyeCount": "\(detection.anchors.rightEye.count)",
                "innerLipCount": "\(detection.anchors.innerLips.count)",
                "durationMs": formattedMilliseconds(Date().timeIntervalSince(detectionStart) * 1_000),
            ]
        )

        let start = Date()
        var notes: [String] = []
        let mask: [Float]
        let output: Raster

        switch parsed.mode {
        case "upper-lid-tone":
            let bands = try upperLidBands(detection.anchors)
            mask = bandMask(width: input.width, height: input.height, bands: bands)
            output = compressLowFrequencyLuminance(input, mask: mask, strength: 0.48)
            notes = [
                "Boundary-fixed band between observed eye and eyebrow support.",
                "Low-frequency luminance is compressed; high-frequency pixel detail is retained additively.",
                "Mechanics-only until licensed real upper-eyelid fullness fixtures are reviewed.",
            ]
        case "upper-lid-warp":
            let bands = try upperLidBands(detection.anchors)
            mask = bandMask(width: input.width, height: input.height, bands: bands)
            output = redistributeUpperLidPixels(input, mask: mask, bands: bands, strength: 0.10)
            notes = [
                "Eye and eyebrow boundaries are fixed; sampling displacement is zero at every band edge.",
                "This is a comparison candidate, not evidence of independent product semantics.",
                "Mechanics-only until licensed real upper-eyelid fullness fixtures are reviewed.",
            ]
        case "teeth-heuristic":
            mask = try heuristicTeethMask(input, innerLips: detection.anchors.innerLips)
            output = whitenTeeth(input, mask: mask, strength: 0.62)
            notes = [
                "Mask is constrained to actual Vision innerLips support and then gated by luminance/chroma.",
                "Closed-mouth, no-candidate, or implausible-area cases must fail closed in production.",
            ]
        case "teeth-coreml":
            guard let modelPath = parsed.options["model"] else {
                throw LabError.invalidArguments("teeth-coreml requires --model <compiled .mlmodelc>")
            }
            mask = try coreMLTeethMask(
                cgImage: cgImage,
                modelURL: URL(fileURLWithPath: modelPath),
                width: input.width,
                height: input.height,
                log: log
            )
            output = whitenTeeth(input, mask: mask, strength: 0.62)
            notes = [
                "EasyPortrait out3 teeth head, used from an external temporary clone.",
                "Research-only: no model or weight is copied into the repository, and redistribution remains unapproved.",
            ]
        case "sclera-redness":
            mask = try scleraRednessMask(input, anchors: detection.anchors)
            output = reduceScleraRedness(input, mask: mask, strength: 0.72)
            notes = [
                "Observed eye aperture is required and the pupil-centered iris exclusion is mandatory.",
                "Specular highlights and pixels outside the eye aperture are protected.",
                "Vein-like detail is neither logged nor persisted; only aggregate mask counts are emitted.",
            ]
        case "combined-color":
            let teeth = try heuristicTeethMask(input, innerLips: detection.anchors.innerLips)
            let sclera = try scleraRednessMask(input, anchors: detection.anchors)
            let teethOutput = whitenTeeth(input, mask: teeth, strength: 0.62)
            output = reduceScleraRedness(teethOutput, mask: sclera, strength: 0.72)
            mask = zip(teeth, sclera).map { max($0, $1) }
            try writeMask(teeth, width: input.width, height: input.height, to: outputURL.appendingPathComponent("teeth-mask.png"))
            try writeMask(sclera, width: input.width, height: input.height, to: outputURL.appendingPathComponent("sclera-mask.png"))
            notes = [
                "Teeth and sclera corrections compose once over disjoint request-local masks.",
                "The experiment intentionally excludes upper-lid work from the shared color pass.",
            ]
        case "integration":
            let iterations = max(1, Int(parsed.options["iterations"] ?? "5") ?? 5)
            let teeth = try heuristicTeethMask(input, innerLips: detection.anchors.innerLips)
            let sclera = try scleraRednessMask(input, anchors: detection.anchors)
            mask = zip(teeth, sclera).map { max($0, $1) }
            var last = input
            var durations: [Double] = []
            for _ in 0..<iterations {
                let iterationStart = Date()
                last = reduceScleraRedness(
                    whitenTeeth(input, mask: teeth, strength: 0.62),
                    mask: sclera,
                    strength: 0.72
                )
                durations.append(Date().timeIntervalSince(iterationStart) * 1_000)
            }
            output = last
            notes = [
                "Repeated \(iterations) times after one Vision request; median color-pass time \(formattedMilliseconds(median(durations))) ms.",
                "This validates the isolated still-image harness only, not the public pixel-buffer path or realtime ownership.",
                "Logs contain counts and timings only; raw coordinates, masks, and vein/teeth descriptors are absent.",
            ]
        default:
            throw LabError.invalidArguments("Unknown mode: \(parsed.mode)")
        }

        let duration = Date().timeIntervalSince(start) * 1_000
        let measured = measure(before: input, after: output, mask: mask)
        let metrics = ExperimentMetrics(
            mode: parsed.mode,
            inputWidth: input.width,
            inputHeight: input.height,
            faceCount: detection.faceCount,
            supportPointCounts: [
                "leftEye": detection.anchors.leftEye.count,
                "rightEye": detection.anchors.rightEye.count,
                "leftBrow": detection.anchors.leftBrow.count,
                "rightBrow": detection.anchors.rightBrow.count,
                "innerLips": detection.anchors.innerLips.count,
                "pupils": [detection.anchors.leftPupil, detection.anchors.rightPupil].compactMap { $0 }.count,
            ],
            maskPixels: measured.maskPixels,
            maskCoverage: measured.maskCoverage,
            changedPixels: measured.changedPixels,
            changedOutsideMask: measured.changedOutsideMask,
            maximumChannelDelta: measured.maximumChannelDelta,
            meanLuminanceDelta: measured.meanLuminanceDelta,
            textureEnergyRatio: measured.textureEnergyRatio,
            durationMilliseconds: duration,
            peakResidentMegabytes: peakResidentMegabytes(),
            notes: notes
        )
        log.add(
            "result",
            "experiment completed",
            metadata: [
                "maskPixels": "\(measured.maskPixels)",
                "changedPixels": "\(measured.changedPixels)",
                "changedOutsideMask": "\(measured.changedOutsideMask)",
                "durationMs": formattedMilliseconds(duration),
            ]
        )

        try writePNG(output, to: outputURL.appendingPathComponent("after.png"))
        try writeMask(mask, width: input.width, height: input.height, to: outputURL.appendingPathComponent("mask.png"))
        try writePNG(overlay(input, mask: mask), to: outputURL.appendingPathComponent("overlay.png"))
        try writeJSON(metrics, to: outputURL.appendingPathComponent("metrics.json"))
        try writeJSON(log.events, to: outputURL.appendingPathComponent("events.json"))
        print(String(data: try JSONEncoder.pretty.encode(metrics), encoding: .utf8) ?? "")
    }
}

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }
}

private func loadCGImage(_ url: URL) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
        throw LabError.imageLoadFailed(url.path)
    }
    return image
}

private func writePNG(_ raster: Raster, to url: URL) throws {
    let image = try raster.makeCGImage()
    guard let destination = CGImageDestinationCreateWithURL(
        url as CFURL,
        UTType.png.identifier as CFString,
        1,
        nil
    ) else {
        throw LabError.imageWriteFailed(url.path)
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
        throw LabError.imageWriteFailed(url.path)
    }
}

private func writeMask(_ mask: [Float], width: Int, height: Int, to url: URL) throws {
    var raster = Raster(width: width, height: height, fill: (0, 0, 0, 255))
    for index in mask.indices {
        let value = byte(mask[index])
        let offset = index * 4
        raster.pixels[offset] = value
        raster.pixels[offset + 1] = value
        raster.pixels[offset + 2] = value
    }
    try writePNG(raster, to: url)
}

private func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
    let data = try JSONEncoder.pretty.encode(value)
    try data.write(to: url, options: .atomic)
}

private func detectAnchors(cgImage: CGImage, width: Int, height: Int) throws -> DetectionResult {
    let request = VNDetectFaceLandmarksRequest()
    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
    try handler.perform([request])
    guard let faces = request.results, !faces.isEmpty else {
        throw LabError.noFace
    }
    let face = faces.max { lhs, rhs in
        lhs.boundingBox.width * lhs.boundingBox.height < rhs.boundingBox.width * rhs.boundingBox.height
    }!
    guard let landmarks = face.landmarks else {
        throw LabError.noFace
    }
    func points(_ region: VNFaceLandmarkRegion2D?) -> [Point] {
        guard let region else { return [] }
        return region.normalizedPoints.map { normalized in
            let imageX = (face.boundingBox.minX + Double(normalized.x) * face.boundingBox.width) * Double(width)
            let visionY = face.boundingBox.minY + Double(normalized.y) * face.boundingBox.height
            return Point(x: imageX, y: (1 - visionY) * Double(height))
        }
    }
    return DetectionResult(
        anchors: FaceAnchors(
            leftEye: points(landmarks.leftEye),
            rightEye: points(landmarks.rightEye),
            leftPupil: points(landmarks.leftPupil).first,
            rightPupil: points(landmarks.rightPupil).first,
            leftBrow: points(landmarks.leftEyebrow),
            rightBrow: points(landmarks.rightEyebrow),
            innerLips: points(landmarks.innerLips)
        ),
        faceCount: faces.count
    )
}

private func upperLidBands(_ anchors: FaceAnchors) throws -> [Band] {
    let pairs = [(anchors.leftEye, anchors.leftBrow), (anchors.rightEye, anchors.rightBrow)]
    return try pairs.map { eye, brow in
        guard eye.count >= 4, brow.count >= 2 else {
            throw LabError.missingSupport("paired eye and eyebrow")
        }
        let eyeMinX = eye.map(\.x).min()!
        let eyeMaxX = eye.map(\.x).max()!
        let eyeTop = eye.map(\.y).min()!
        let eyeHeight = eye.map(\.y).max()! - eyeTop
        let browBottom = brow.map(\.y).max()!
        let gap = eyeTop - browBottom
        guard gap > max(2, eyeHeight * 0.15) else {
            throw LabError.missingSupport("positive upper-lid band")
        }
        return Band(
            centerX: (eyeMinX + eyeMaxX) / 2,
            radiusX: (eyeMaxX - eyeMinX) * 0.68,
            top: browBottom + gap * 0.20,
            bottom: eyeTop - gap * 0.05
        )
    }
}

private func bandMask(width: Int, height: Int, bands: [Band]) -> [Float] {
    var mask = [Float](repeating: 0, count: width * height)
    for band in bands {
        let minX = max(0, Int(floor(band.centerX - band.radiusX)))
        let maxX = min(width - 1, Int(ceil(band.centerX + band.radiusX)))
        let minY = max(0, Int(floor(band.top)))
        let maxY = min(height - 1, Int(ceil(band.bottom)))
        let bandHeight = max(1, band.bottom - band.top)
        for y in minY...maxY {
            let t = clamp(Float((Double(y) - band.top) / bandHeight))
            let vertical = pow(sin(Float.pi * t), 0.8)
            for x in minX...maxX {
                let dx = abs((Double(x) - band.centerX) / max(1, band.radiusX))
                guard dx < 1 else { continue }
                let horizontal = Float(pow(max(0, 1 - dx * dx), 0.65))
                let index = y * width + x
                mask[index] = max(mask[index], vertical * horizontal)
            }
        }
    }
    return mask
}

private func polygonMask(width: Int, height: Int, points: [Point], featherRadius: Int = 2) throws -> [Float] {
    guard points.count >= 3 else {
        throw LabError.missingSupport("polygon")
    }
    var mask = [Float](repeating: 0, count: width * height)
    let minX = max(0, Int(floor(points.map(\.x).min()!)))
    let maxX = min(width - 1, Int(ceil(points.map(\.x).max()!)))
    let minY = max(0, Int(floor(points.map(\.y).min()!)))
    let maxY = min(height - 1, Int(ceil(points.map(\.y).max()!)))
    guard minX <= maxX, minY <= maxY else { return mask }
    for y in minY...maxY {
        for x in minX...maxX where pointInPolygon(Point(x: Double(x) + 0.5, y: Double(y) + 0.5), polygon: points) {
            mask[y * width + x] = 1
        }
    }
    return featherRadius > 0 ? boxBlur(mask, width: width, height: height, radius: featherRadius) : mask
}

private func pointInPolygon(_ point: Point, polygon: [Point]) -> Bool {
    var inside = false
    var previous = polygon.count - 1
    for current in polygon.indices {
        let a = polygon[current]
        let b = polygon[previous]
        let crosses = (a.y > point.y) != (b.y > point.y)
        if crosses {
            let denominator = b.y - a.y
            let intersectionX = (b.x - a.x) * (point.y - a.y) / (abs(denominator) < 1e-9 ? 1e-9 : denominator) + a.x
            if point.x < intersectionX { inside.toggle() }
        }
        previous = current
    }
    return inside
}

private func boxBlur(_ values: [Float], width: Int, height: Int, radius: Int) -> [Float] {
    guard radius > 0 else { return values }
    var horizontal = [Float](repeating: 0, count: values.count)
    var result = [Float](repeating: 0, count: values.count)
    for y in 0..<height {
        var sum: Float = 0
        for x in -radius...radius where x >= 0 && x < width {
            sum += values[y * width + x]
        }
        for x in 0..<width {
            let left = x - radius - 1
            let right = x + radius
            if left >= 0 { sum -= values[y * width + left] }
            if right < width, x > 0 { sum += values[y * width + right] }
            let count = min(width - 1, x + radius) - max(0, x - radius) + 1
            horizontal[y * width + x] = sum / Float(max(1, count))
        }
    }
    for x in 0..<width {
        var sum: Float = 0
        for y in -radius...radius where y >= 0 && y < height {
            sum += horizontal[y * width + x]
        }
        for y in 0..<height {
            let top = y - radius - 1
            let bottom = y + radius
            if top >= 0 { sum -= horizontal[top * width + x] }
            if bottom < height, y > 0 { sum += horizontal[bottom * width + x] }
            let count = min(height - 1, y + radius) - max(0, y - radius) + 1
            result[y * width + x] = sum / Float(max(1, count))
        }
    }
    return result
}

private func compressLowFrequencyLuminance(_ input: Raster, mask: [Float], strength: Float) -> Raster {
    let luminanceValues = (0..<(input.width * input.height)).map { index -> Float in
        let offset = index * 4
        return luminance(
            Float(input.pixels[offset]) / 255,
            Float(input.pixels[offset + 1]) / 255,
            Float(input.pixels[offset + 2]) / 255
        )
    }
    let radius = max(3, min(input.width, input.height) / 180)
    let lowFrequency = boxBlur(luminanceValues, width: input.width, height: input.height, radius: radius)
    var weightedTotal: Float = 0
    var weight: Float = 0
    for index in mask.indices where mask[index] > 0.02 {
        weightedTotal += lowFrequency[index] * mask[index]
        weight += mask[index]
    }
    guard weight > 0 else { return input }
    let target = weightedTotal / weight
    var output = input
    for index in mask.indices where mask[index] > 0.001 {
        let delta = (target - lowFrequency[index]) * strength * mask[index]
        let offset = index * 4
        output.pixels[offset] = byte(Float(input.pixels[offset]) / 255 + delta)
        output.pixels[offset + 1] = byte(Float(input.pixels[offset + 1]) / 255 + delta)
        output.pixels[offset + 2] = byte(Float(input.pixels[offset + 2]) / 255 + delta)
    }
    return output
}

private func redistributeUpperLidPixels(_ input: Raster, mask: [Float], bands: [Band], strength: Double) -> Raster {
    var output = input
    for band in bands {
        let minX = max(0, Int(floor(band.centerX - band.radiusX)))
        let maxX = min(input.width - 1, Int(ceil(band.centerX + band.radiusX)))
        let minY = max(0, Int(floor(band.top)))
        let maxY = min(input.height - 1, Int(ceil(band.bottom)))
        let bandHeight = max(1, band.bottom - band.top)
        for y in minY...maxY {
            let t = clamp(Float((Double(y) - band.top) / bandHeight))
            for x in minX...maxX {
                let index = y * input.width + x
                let localMask = Double(mask[index])
                guard localMask > 0.001 else { continue }
                let displacement = bandHeight * strength * sin(Double.pi * Double(t)) * localMask
                let sample = bilinearSample(input, x: Double(x), y: Double(y) + displacement)
                let blend = Float(localMask * 0.85)
                let original = input.rgb(x: x, y: y)
                output.setRGB(
                    x: x,
                    y: y,
                    red: original.0 * (1 - blend) + sample.0 * blend,
                    green: original.1 * (1 - blend) + sample.1 * blend,
                    blue: original.2 * (1 - blend) + sample.2 * blend
                )
            }
        }
    }
    return output
}

private func heuristicTeethMask(_ input: Raster, innerLips: [Point]) throws -> [Float] {
    let region = try polygonMask(width: input.width, height: input.height, points: innerLips, featherRadius: 1)
    var mask = [Float](repeating: 0, count: region.count)
    for index in region.indices where region[index] > 0.02 {
        let offset = index * 4
        let red = Float(input.pixels[offset]) / 255
        let green = Float(input.pixels[offset + 1]) / 255
        let blue = Float(input.pixels[offset + 2]) / 255
        let maximum = max(red, max(green, blue))
        let minimum = min(red, min(green, blue))
        let saturation = maximum > 0.001 ? (maximum - minimum) / maximum : 0
        let light = luminance(red, green, blue)
        let brightnessScore = smoothstep(0.32, 0.68, light)
        let neutralityScore = 1 - smoothstep(0.22, 0.58, saturation)
        let blueFloor = smoothstep(-0.18, 0.06, blue - red * 0.72)
        mask[index] = clamp(region[index] * brightnessScore * neutralityScore * blueFloor)
    }
    let candidateCount = mask.lazy.filter { $0 > 0.15 }.count
    let regionCount = region.lazy.filter { $0 > 0.15 }.count
    guard regionCount > 0,
          Double(candidateCount) / Double(regionCount) >= 0.015,
          // A broad smile can legitimately fill most of the inner-lip polygon.
          // The per-pixel neutrality/brightness gates still reject lip and tongue
          // colors; the upper bound only catches a near-solid mask failure.
          Double(candidateCount) / Double(regionCount) <= 0.94
    else {
        return [Float](repeating: 0, count: mask.count)
    }
    return boxBlur(mask, width: input.width, height: input.height, radius: 1).map { clamp($0) }
}

private func coreMLTeethMask(
    cgImage: CGImage,
    modelURL: URL,
    width: Int,
    height: Int,
    log: EventLog
) throws -> [Float] {
    guard FileManager.default.fileExists(atPath: modelURL.path) else {
        throw LabError.modelLoadFailed(modelURL.path)
    }
    let configuration = MLModelConfiguration()
    configuration.computeUnits = .all
    let loadStart = Date()
    let model = try MLModel(contentsOf: modelURL, configuration: configuration)
    let visionModel = try VNCoreMLModel(for: model)
    let request = VNCoreMLRequest(model: visionModel)
    request.imageCropAndScaleOption = .scaleFill
    let inferenceStart = Date()
    try VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:]).perform([request])
    guard let observations = request.results as? [VNPixelBufferObservation], observations.count > 3 else {
        throw LabError.modelOutputMissing
    }
    let sourceBuffer = observations[3].pixelBuffer
    let sourceImage = CIImage(cvPixelBuffer: sourceBuffer)
    let scaleX = CGFloat(width) / sourceImage.extent.width
    let scaleY = CGFloat(height) / sourceImage.extent.height
    let scaled = sourceImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    let context = CIContext(options: [.cacheIntermediates: false])
    guard let maskImage = context.createCGImage(scaled, from: CGRect(x: 0, y: 0, width: width, height: height)) else {
        throw LabError.modelOutputMissing
    }
    let raster = try Raster(cgImage: maskImage)
    log.add(
        "coreml",
        "external research model completed",
        metadata: [
            "outputs": "\(observations.count)",
            "loadMs": formattedMilliseconds(inferenceStart.timeIntervalSince(loadStart) * 1_000),
            "inferenceMs": formattedMilliseconds(Date().timeIntervalSince(inferenceStart) * 1_000),
        ]
    )
    return (0..<(width * height)).map { index in
        Float(raster.pixels[index * 4]) / 255
    }
}

private func scleraRednessMask(_ input: Raster, anchors: FaceAnchors) throws -> [Float] {
    let pairs = [
        (anchors.leftEye, anchors.leftPupil),
        (anchors.rightEye, anchors.rightPupil),
    ]
    var combined = [Float](repeating: 0, count: input.width * input.height)
    for (eye, pupil) in pairs {
        guard eye.count >= 4, let pupil else {
            throw LabError.missingSupport("eye contour and pupil")
        }
        let aperture = try polygonMask(width: input.width, height: input.height, points: eye, featherRadius: 1)
        let eyeWidth = eye.map(\.x).max()! - eye.map(\.x).min()!
        let eyeHeight = eye.map(\.y).max()! - eye.map(\.y).min()!
        let irisRadius = max(eyeHeight * 0.58, eyeWidth * 0.16)
        for index in aperture.indices where aperture[index] > 0.02 {
            let x = index % input.width
            let y = index / input.width
            let dx = Double(x) + 0.5 - pupil.x
            let dy = Double(y) + 0.5 - pupil.y
            guard sqrt(dx * dx + dy * dy) > irisRadius else { continue }
            let offset = index * 4
            let red = Float(input.pixels[offset]) / 255
            let green = Float(input.pixels[offset + 1]) / 255
            let blue = Float(input.pixels[offset + 2]) / 255
            let maximum = max(red, max(green, blue))
            let minimum = min(red, min(green, blue))
            let saturation = maximum > 0.001 ? (maximum - minimum) / maximum : 0
            let light = luminance(red, green, blue)
            let isSpecular = red > 0.86 && green > 0.86 && blue > 0.86
            guard !isSpecular else { continue }
            let scleraLikelihood = smoothstep(0.22, 0.68, light) * (1 - smoothstep(0.48, 0.85, saturation))
            let redness = max(0, red - 0.83 * green - 0.17 * blue)
            let rednessScore = smoothstep(0.008, 0.14, redness)
            combined[index] = max(combined[index], aperture[index] * scleraLikelihood * rednessScore)
        }
    }
    return boxBlur(combined, width: input.width, height: input.height, radius: 1).map { clamp($0) }
}

private func whitenTeeth(_ input: Raster, mask: [Float], strength: Float) -> Raster {
    var output = input
    for index in mask.indices where mask[index] > 0.001 {
        let offset = index * 4
        let red = Float(input.pixels[offset]) / 255
        let green = Float(input.pixels[offset + 1]) / 255
        let blue = Float(input.pixels[offset + 2]) / 255
        let local = mask[index] * strength
        let originalLuminance = luminance(red, green, blue)
        let yellowExcess = max(0, (red + green) * 0.5 - blue)
        var nextRed = red + 0.018 * local
        var nextGreen = green + 0.018 * local
        var nextBlue = blue + yellowExcess * 0.78 * local + 0.026 * local
        let desiredLuminance = min(0.94, originalLuminance + 0.028 * local)
        let correction = desiredLuminance - luminance(nextRed, nextGreen, nextBlue)
        nextRed += correction
        nextGreen += correction
        nextBlue += correction
        output.pixels[offset] = byte(nextRed)
        output.pixels[offset + 1] = byte(nextGreen)
        output.pixels[offset + 2] = byte(nextBlue)
    }
    return output
}

private func reduceScleraRedness(_ input: Raster, mask: [Float], strength: Float) -> Raster {
    var output = input
    for index in mask.indices where mask[index] > 0.001 {
        let offset = index * 4
        let red = Float(input.pixels[offset]) / 255
        let green = Float(input.pixels[offset + 1]) / 255
        let blue = Float(input.pixels[offset + 2]) / 255
        let originalLuminance = luminance(red, green, blue)
        let local = mask[index] * strength
        let redExcess = max(0, red - (0.83 * green + 0.17 * blue))
        var nextRed = red - redExcess * 0.76 * local
        var nextGreen = green + redExcess * 0.08 * local
        var nextBlue = blue + redExcess * 0.13 * local
        let correction = originalLuminance - luminance(nextRed, nextGreen, nextBlue)
        nextRed += correction
        nextGreen += correction
        nextBlue += correction
        output.pixels[offset] = byte(nextRed)
        output.pixels[offset + 1] = byte(nextGreen)
        output.pixels[offset + 2] = byte(nextBlue)
    }
    return output
}

private func overlay(_ input: Raster, mask: [Float]) -> Raster {
    var output = input
    for index in mask.indices where mask[index] > 0.001 {
        let offset = index * 4
        let blend = min(0.72, mask[index] * 0.72)
        let red = Float(input.pixels[offset]) / 255
        let green = Float(input.pixels[offset + 1]) / 255
        let blue = Float(input.pixels[offset + 2]) / 255
        output.pixels[offset] = byte(red * (1 - blend) + blend)
        output.pixels[offset + 1] = byte(green * (1 - blend) + blend * 0.18)
        output.pixels[offset + 2] = byte(blue * (1 - blend) + blend * 0.12)
    }
    return output
}

private struct Measurement {
    let maskPixels: Int
    let maskCoverage: Double
    let changedPixels: Int
    let changedOutsideMask: Int
    let maximumChannelDelta: Double
    let meanLuminanceDelta: Double
    let textureEnergyRatio: Double?
}

private func measure(before: Raster, after: Raster, mask: [Float]) -> Measurement {
    var maskPixels = 0
    var changedPixels = 0
    var changedOutside = 0
    var maximumDelta: UInt8 = 0
    var luminanceDelta: Double = 0
    var luminanceSamples = 0
    for index in mask.indices {
        let offset = index * 4
        let deltas = (0..<3).map { channel in
            abs(Int(before.pixels[offset + channel]) - Int(after.pixels[offset + channel]))
        }
        let changed = deltas.contains { $0 > 0 }
        if mask[index] > 0.001 { maskPixels += 1 }
        if changed {
            changedPixels += 1
            if mask[index] <= 0.001 { changedOutside += 1 }
            maximumDelta = max(maximumDelta, UInt8(min(255, deltas.max() ?? 0)))
        }
        if mask[index] > 0.05 {
            let beforeL = luminance(
                Float(before.pixels[offset]) / 255,
                Float(before.pixels[offset + 1]) / 255,
                Float(before.pixels[offset + 2]) / 255
            )
            let afterL = luminance(
                Float(after.pixels[offset]) / 255,
                Float(after.pixels[offset + 1]) / 255,
                Float(after.pixels[offset + 2]) / 255
            )
            luminanceDelta += Double(afterL - beforeL)
            luminanceSamples += 1
        }
    }
    let beforeEnergy = textureEnergy(before, mask: mask)
    let afterEnergy = textureEnergy(after, mask: mask)
    return Measurement(
        maskPixels: maskPixels,
        maskCoverage: Double(maskPixels) / Double(max(1, before.width * before.height)),
        changedPixels: changedPixels,
        changedOutsideMask: changedOutside,
        maximumChannelDelta: Double(maximumDelta) / 255,
        meanLuminanceDelta: luminanceSamples > 0 ? luminanceDelta / Double(luminanceSamples) : 0,
        textureEnergyRatio: beforeEnergy > 1e-8 ? afterEnergy / beforeEnergy : nil
    )
}

private func textureEnergy(_ image: Raster, mask: [Float]) -> Double {
    guard image.width > 1, image.height > 1 else { return 0 }
    var total: Double = 0
    var weight: Double = 0
    for y in 0..<(image.height - 1) {
        for x in 0..<(image.width - 1) {
            let index = y * image.width + x
            let localWeight = Double(mask[index])
            guard localWeight > 0.05 else { continue }
            let current = image.rgb(x: x, y: y)
            let right = image.rgb(x: x + 1, y: y)
            let down = image.rgb(x: x, y: y + 1)
            let gradient = abs(luminance(current.0, current.1, current.2) - luminance(right.0, right.1, right.2))
                + abs(luminance(current.0, current.1, current.2) - luminance(down.0, down.1, down.2))
            total += Double(gradient) * localWeight
            weight += localWeight
        }
    }
    return weight > 0 ? total / weight : 0
}

private func bilinearSample(_ image: Raster, x: Double, y: Double) -> (Float, Float, Float) {
    let boundedX = min(Double(image.width - 1), max(0, x))
    let boundedY = min(Double(image.height - 1), max(0, y))
    let x0 = Int(floor(boundedX))
    let y0 = Int(floor(boundedY))
    let x1 = min(image.width - 1, x0 + 1)
    let y1 = min(image.height - 1, y0 + 1)
    let tx = Float(boundedX - Double(x0))
    let ty = Float(boundedY - Double(y0))
    let a = image.rgb(x: x0, y: y0)
    let b = image.rgb(x: x1, y: y0)
    let c = image.rgb(x: x0, y: y1)
    let d = image.rgb(x: x1, y: y1)
    func interpolate(_ p0: Float, _ p1: Float, _ p2: Float, _ p3: Float) -> Float {
        let top = p0 * (1 - tx) + p1 * tx
        let bottom = p2 * (1 - tx) + p3 * tx
        return top * (1 - ty) + bottom * ty
    }
    return (
        interpolate(a.0, b.0, c.0, d.0),
        interpolate(a.1, b.1, c.1, d.1),
        interpolate(a.2, b.2, c.2, d.2)
    )
}

private func median(_ values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    let sorted = values.sorted()
    if sorted.count.isMultiple(of: 2) {
        return (sorted[sorted.count / 2 - 1] + sorted[sorted.count / 2]) / 2
    }
    return sorted[sorted.count / 2]
}

private func peakResidentMegabytes() -> Double {
    var usage = rusage()
    guard getrusage(RUSAGE_SELF, &usage) == 0 else { return 0 }
    return Double(usage.ru_maxrss) / 1_048_576
}

private func luminance(_ red: Float, _ green: Float, _ blue: Float) -> Float {
    0.299 * red + 0.587 * green + 0.114 * blue
}

private func smoothstep(_ lower: Float, _ upper: Float, _ value: Float) -> Float {
    guard upper > lower else { return value >= upper ? 1 : 0 }
    let t = clamp((value - lower) / (upper - lower))
    return t * t * (3 - 2 * t)
}

private func clamp(_ value: Float) -> Float {
    min(1, max(0, value.isFinite ? value : 0))
}

private func byte(_ value: Float) -> UInt8 {
    UInt8((clamp(value) * 255).rounded())
}

private func formattedMilliseconds(_ value: Double) -> String {
    String(format: "%.3f", value)
}

private func runSelfTests() throws {
    func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
        if !condition() { throw LabError.invalidArguments("SELF-TEST FAIL: \(message)") }
    }
    try require(smoothstep(0, 1, -1) == 0, "smoothstep lower clamp")
    try require(smoothstep(0, 1, 2) == 1, "smoothstep upper clamp")
    let triangle = [Point(x: 2, y: 2), Point(x: 12, y: 2), Point(x: 7, y: 12)]
    let polygon = try polygonMask(width: 16, height: 16, points: triangle, featherRadius: 0)
    try require(polygon.filter { $0 > 0 }.count > 30, "polygon rasterization")
    let bands = [Band(centerX: 8, radiusX: 5, top: 2, bottom: 8)]
    let band = bandMask(width: 16, height: 16, bands: bands)
    try require(band.filter { $0 > 0 }.count > 20, "band rasterization")
    let input = Raster(width: 16, height: 16, fill: (180, 160, 120, 255))
    let whitened = whitenTeeth(input, mask: polygon, strength: 0.6)
    let measurement = measure(before: input, after: whitened, mask: polygon)
    try require(measurement.changedPixels > 0, "teeth transform changes mask")
    try require(measurement.changedOutsideMask == 0, "teeth transform containment")
    let reduced = reduceScleraRedness(
        Raster(width: 16, height: 16, fill: (210, 150, 150, 255)),
        mask: polygon,
        strength: 0.7
    )
    let rednessMeasurement = measure(
        before: Raster(width: 16, height: 16, fill: (210, 150, 150, 255)),
        after: reduced,
        mask: polygon
    )
    try require(rednessMeasurement.changedOutsideMask == 0, "redness transform containment")
}
