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
    let outerLips: [Point]
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

private struct TeethVariantMetrics: Codable, Sendable {
    let maskPixels: Int
    let strongMaskPixels: Int
    let changedPixels: Int
    let changedOutsideMask: Int
    let maximumChannelDelta: Double
    let meanLuminanceDelta: Double
    let textureEnergyRatio: Double?
    let durationMilliseconds: Double
}

private struct TeethComparisonMetrics: Codable, Sendable {
    let mode: String
    let inputWidth: Int
    let inputHeight: Int
    let faceCount: Int
    let innerLipPointCount: Int
    let outerLipPointCount: Int
    let innerLipRegionPixels: Int
    let mouthCandidateRegionPixels: Int
    let fixed: TeethVariantMetrics
    let adaptive: TeethVariantMetrics
    let adaptiveAddedPixels: Int
    let adaptiveDroppedPixels: Int
    let strongIntersectionPixels: Int
    let strongUnionPixels: Int
    let strongMaskIoU: Double
    let adaptiveStrongAreaRatio: Double
    let peakResidentMegabytes: Double
    let notes: [String]
}

private struct ScleraJitterVariantMetrics: Codable, Sendable {
    let scenarioCount: Int
    let failedClosedScenarioCount: Int
    let irisLeakScenarioCount: Int
    let irisLeakPixelsTotal: Int
    let maximumIrisLeakPixels: Int
    let highlightLeakScenarioCount: Int
    let highlightLeakPixelsTotal: Int
    let eligiblePixelsTotal: Int
    let meanEligiblePixels: Double
    let minimumEligiblePixels: Int
    let maximumEligiblePixels: Int
    let baselineEligiblePixels: Int
}

private struct ScleraJitterMetrics: Codable, Sendable {
    let mode: String
    let inputWidth: Int
    let inputHeight: Int
    let faceCount: Int
    let eyeCount: Int
    let scenariosPerEye: Int
    let scenarioCount: Int
    let pupilHorizontalShiftFractions: [Double]
    let pupilVerticalShiftFractions: [Double]
    let eyeVerticalScaleFractions: [Double]
    let guardedMinimumAspectRatio: Double
    let guardedIrisInflationWidthFraction: Double
    let guardedFailedClosedByVerticalScale: [String: Int]
    let legacy: ScleraJitterVariantMetrics
    let guarded: ScleraJitterVariantMetrics
    let guardedBaselineRetentionRatio: Double
    let peakResidentMegabytes: Double
    let notes: [String]
}

private struct ScleraJitterStudy {
    let legacy: ScleraJitterVariantMetrics
    let guarded: ScleraJitterVariantMetrics
    let legacyLeakCounts: [Int]
    let guardedLeakCounts: [Int]
    let protectedMask: [Float]
    let legacyBaselineMask: [Float]
    let guardedBaselineMask: [Float]
    let guardedFailedClosedByVerticalScale: [String: Int]
    let scenarioCount: Int
}

private struct ScleraColorVariantMetrics: Codable, Sendable {
    let scenarioCount: Int
    let failedClosedEyeScenarioCount: Int
    let nativeMaskPixelsTotal: Int
    let nativeChangedPixelsTotal: Int
    let nativeProtectedChangeScenarioCount: Int
    let nativeProtectedChangedPixelsTotal: Int
    let nativeHighlightChangeScenarioCount: Int
    let nativeHighlightChangedPixelsTotal: Int
    let challengeMaskPixelsTotal: Int
    let challengeChangedPixelsTotal: Int
    let challengeProtectedChangeScenarioCount: Int
    let challengeProtectedChangedPixelsTotal: Int
    let challengeHighlightChangeScenarioCount: Int
    let challengeHighlightChangedPixelsTotal: Int
    let baselineNativeMaskPixels: Int
    let baselineNativeChangedPixels: Int
    let baselineNativeChangedOutsideMask: Int
    let baselineNativeProtectedChangedPixels: Int
    let baselineNativeHighlightChangedPixels: Int
    let baselineNativeMaskPixelsByEye: [String: Int]
}

private struct ScleraColorIntegrationMetrics: Codable, Sendable {
    let mode: String
    let inputWidth: Int
    let inputHeight: Int
    let faceCount: Int
    let eyeCount: Int
    let scenariosPerEye: Int
    let scenarioCount: Int
    let pupilHorizontalShiftFractions: [Double]
    let pupilVerticalShiftFractions: [Double]
    let eyeVerticalScaleFractions: [Double]
    let guardedMinimumAspectRatio: Double
    let guardedIrisInflationWidthFraction: Double
    let guardedFailedClosedByVerticalScale: [String: Int]
    let legacy: ScleraColorVariantMetrics
    let guarded: ScleraColorVariantMetrics
    let guardedBaselineNativeMaskRetentionRatio: Double
    let peakResidentMegabytes: Double
    let notes: [String]
}

private struct ScleraColorIntegrationStudy {
    let legacy: ScleraColorVariantMetrics
    let guarded: ScleraColorVariantMetrics
    let legacyBaselineMask: [Float]
    let guardedBaselineMask: [Float]
    let legacyBaselineOutput: Raster
    let guardedBaselineOutput: Raster
    let challengeInput: Raster
    let legacyChallengeBaselineMask: [Float]
    let guardedChallengeBaselineMask: [Float]
    let legacyChallengeBaselineOutput: Raster
    let guardedChallengeBaselineOutput: Raster
    let protectedMask: [Float]
    let highlightMask: [Float]
    let legacyChallengeLeakCounts: [Int]
    let guardedChallengeLeakCounts: [Int]
    let guardedFailedClosedByVerticalScale: [String: Int]
    let scenarioCount: Int
}

private struct LocalRetouchVariantMetrics: Codable, Sendable {
    let maskPixels: Int
    let changedPixels: Int
    let changedOutsideMask: Int
    let protectedIrisChangedPixels: Int
    let highlightChangedPixels: Int
    let maximumChannelDelta: Double
    let meanLuminanceDelta: Double
    let textureEnergyRatio: Double?
}

private struct LocalRetouchFailureMetrics: Codable, Sendable {
    let teethRejectedMismatchPixels: Int
    let scleraRejectedMismatchPixels: Int
    let leftEyeRejectedMismatchPixels: Int
    let rightEyeRejectedMismatchPixels: Int
    let injectedOverlapPixels: Int
    let overlapSuppressedPixels: Int
    let overlapChangedPixels: Int
}

private struct LocalRetouchCompositionMetrics: Codable, Sendable {
    let mode: String
    let inputWidth: Int
    let inputHeight: Int
    let faceCount: Int
    let detectionRequestCount: Int
    let eyeCount: Int
    let innerLipPointCount: Int
    let outerLipPointCount: Int
    let fixedTeethStrongPixels: Int
    let adaptiveTeethStrongPixels: Int
    let leftScleraMaskPixels: Int
    let rightScleraMaskPixels: Int
    let baselineCrossMaskOverlapPixels: Int
    let fusedVsStandaloneMismatchPixels: Int
    let fusedVsSequentialMismatchPixels: Int
    let legacyVsFusedMismatchPixels: Int
    let medianFusedMilliseconds: Double
    let medianSequentialMilliseconds: Double
    let legacy: LocalRetouchVariantMetrics
    let fused: LocalRetouchVariantMetrics
    let failureIsolation: LocalRetouchFailureMetrics
    let peakResidentMegabytes: Double
    let notes: [String]
}

private struct GuardedScleraPair {
    let leftMask: [Float]
    let rightMask: [Float]
    let combinedMask: [Float]
    let leftFailedClosed: Bool
    let rightFailedClosed: Bool
}

private struct LocalRetouchCompositionResult {
    let output: Raster
    let unionMask: [Float]
    let overlapPixels: Int
}

private struct NormalizedOrientationVariantMetrics: Codable, Sendable {
    let orientationRawValue: UInt32
    let encodedWidth: Int
    let encodedHeight: Int
    let normalizedWidth: Int
    let normalizedHeight: Int
    let inputMismatchPixels: Int
    let inputAlphaMismatchPixels: Int
    let maximumInputChannelDelta: Int
    let maximumAnchorDeltaPixels: Double
    let teethStrongTopologyMismatchPixels: Int
    let scleraStrongTopologyMismatchPixels: Int
    let outputMismatchPixels: Int
    let outputAlphaMismatchPixels: Int
    let maximumOutputChannelDelta: Int
}

private struct NormalizedColorVariantMetrics: Codable, Sendable {
    let sourceColorSpace: String
    let normalizedColorSpace: String
    let inputMismatchPixels: Int
    let maximumInputChannelDelta: Int
    let maximumAnchorDeltaPixels: Double
    let teethStrongTopologyMismatchPixels: Int
    let scleraStrongTopologyMismatchPixels: Int
    let fixedAnchorTeethStrongTopologyMismatchPixels: Int
    let fixedAnchorScleraStrongTopologyMismatchPixels: Int
    let outputMismatchPixels: Int
    let maximumOutputChannelDelta: Int
    let fixedAnchorMaximumOutputChannelDelta: Int
    let changedOutsideMask: Int
}

private struct NormalizedAlphaVariantMetrics: Codable, Sendable {
    let transparentInputPixels: Int
    let normalizedAlphaMismatchPixels: Int
    let outputAlphaMismatchPixels: Int
    let transparentRGBChangedPixels: Int
    let maximumAnchorDeltaPixels: Double
    let teethStrongTopologyMismatchPixels: Int
    let scleraStrongTopologyMismatchPixels: Int
    let fixedAnchorTeethStrongTopologyMismatchPixels: Int
    let fixedAnchorScleraStrongTopologyMismatchPixels: Int
    let changedOutsideMask: Int
}

private struct NormalizedInputMetrics: Codable, Sendable {
    let mode: String
    let inputWidth: Int
    let inputHeight: Int
    let faceCount: Int
    let detectionRequestCount: Int
    let orientationVariantCount: Int
    let orientationVariants: [NormalizedOrientationVariantMetrics]
    let orientationMismatchPixelsTotal: Int
    let orientationTopologyMismatchPixelsTotal: Int
    let maximumOrientationAnchorDeltaPixels: Double
    let displayP3: NormalizedColorVariantMetrics
    let transparentBorder: NormalizedAlphaVariantMetrics
    let invalidOrientationFailedClosed: Bool
    let nonRGBInputFailedClosed: Bool
    let peakResidentMegabytes: Double
    let notes: [String]
}

private struct LocalRetouchEvidence {
    let input: Raster
    let detection: DetectionResult
    let teethMask: [Float]
    let scleraMask: [Float]
    let output: Raster
    let unionMask: [Float]
}

private enum LabError: Error, CustomStringConvertible {
    case invalidArguments(String)
    case imageLoadFailed(String)
    case imageWriteFailed(String)
    case noFace
    case missingSupport(String)
    case modelLoadFailed(String)
    case modelOutputMissing
    case invalidImageOrientation
    case unsupportedImageColorModel

    var description: String {
        switch self {
        case let .invalidArguments(text): return text
        case let .imageLoadFailed(path): return "Unable to load image: \(path)"
        case let .imageWriteFailed(path): return "Unable to write image: \(path)"
        case .noFace: return "No usable face landmarks were detected"
        case let .missingSupport(name): return "Missing required support: \(name)"
        case let .modelLoadFailed(path): return "Unable to load Core ML model: \(path)"
        case .modelOutputMissing: return "Core ML teeth output out3 was not returned"
        case .invalidImageOrientation: return "Invalid image orientation metadata"
        case .unsupportedImageColorModel: return "Unsupported image color model"
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
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
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
                  space: CGColorSpace(name: CGColorSpace.sRGB)!,
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
                print("SELF-TEST PASS: 24/24")
                return
            }
            if parsed.mode == "teeth-compare" {
                try runTeethComparison(parsed)
                return
            }
            if parsed.mode == "sclera-jitter" {
                try runScleraJitter(parsed)
                return
            }
            if parsed.mode == "sclera-guarded-color" {
                try runScleraGuardedColor(parsed)
                return
            }
            if parsed.mode == "guarded-local-composition" {
                try runGuardedLocalComposition(parsed)
                return
            }
            if parsed.mode == "normalized-input-contract" {
                try runNormalizedInputContract(parsed)
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
                "outerLips": detection.anchors.outerLips.count,
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

    private static func runTeethComparison(_ parsed: ParsedArguments) throws {
        guard let inputPath = parsed.options["input"],
              let outputPath = parsed.options["output"]
        else {
            throw LabError.invalidArguments("teeth-compare requires --input and --output")
        }
        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        let log = EventLog()
        log.add("start", "adaptive teeth comparison started", metadata: ["mode": parsed.mode])

        let cgImage = try loadCGImage(URL(fileURLWithPath: inputPath))
        let input = try Raster(cgImage: cgImage)
        let detectionStart = Date()
        let detection = try detectAnchors(cgImage: cgImage, width: input.width, height: input.height)
        let hardRegion = try polygonMask(
            width: input.width,
            height: input.height,
            points: detection.anchors.innerLips,
            featherRadius: 0
        )
        let mouthCandidateRegion = try adaptiveMouthCandidateRegion(
            width: input.width,
            height: input.height,
            innerLips: detection.anchors.innerLips,
            outerLips: detection.anchors.outerLips
        )
        let regionPixels = hardRegion.lazy.filter { $0 > 0.5 }.count
        let mouthCandidatePixels = mouthCandidateRegion.lazy.filter { $0 > 0.5 }.count
        log.add(
            "detection",
            "request-local inner-lip support captured",
            metadata: [
                "faces": "\(detection.faceCount)",
                "innerLipCount": "\(detection.anchors.innerLips.count)",
                "outerLipCount": "\(detection.anchors.outerLips.count)",
                "regionPixels": "\(regionPixels)",
                "durationMs": formattedMilliseconds(Date().timeIntervalSince(detectionStart) * 1_000),
            ]
        )

        let fixedStart = Date()
        let fixedRaw = try heuristicTeethMask(input, innerLips: detection.anchors.innerLips)
        let fixed = constrainMask(fixedRaw, to: hardRegion)
        let fixedDuration = Date().timeIntervalSince(fixedStart) * 1_000

        let adaptiveStart = Date()
        let adaptive = try adaptiveTeethMask(
            input,
            innerLips: detection.anchors.innerLips,
            candidateRegion: mouthCandidateRegion,
            fixedSeedMask: fixed
        )
        let adaptiveDuration = Date().timeIntervalSince(adaptiveStart) * 1_000

        let fixedOutput = whitenTeeth(input, mask: fixed, strength: 0.62)
        let adaptiveOutput = whitenTeeth(input, mask: adaptive, strength: 0.62)
        let fixedMeasurement = measure(before: input, after: fixedOutput, mask: fixed)
        let adaptiveMeasurement = measure(before: input, after: adaptiveOutput, mask: adaptive)
        let overlap = compareMasks(fixed, adaptive: adaptive, threshold: 0.15)

        let fixedMetrics = TeethVariantMetrics(
            maskPixels: fixedMeasurement.maskPixels,
            strongMaskPixels: fixed.lazy.filter { $0 > 0.15 }.count,
            changedPixels: fixedMeasurement.changedPixels,
            changedOutsideMask: fixedMeasurement.changedOutsideMask,
            maximumChannelDelta: fixedMeasurement.maximumChannelDelta,
            meanLuminanceDelta: fixedMeasurement.meanLuminanceDelta,
            textureEnergyRatio: fixedMeasurement.textureEnergyRatio,
            durationMilliseconds: fixedDuration
        )
        let adaptiveMetrics = TeethVariantMetrics(
            maskPixels: adaptiveMeasurement.maskPixels,
            strongMaskPixels: adaptive.lazy.filter { $0 > 0.15 }.count,
            changedPixels: adaptiveMeasurement.changedPixels,
            changedOutsideMask: adaptiveMeasurement.changedOutsideMask,
            maximumChannelDelta: adaptiveMeasurement.maximumChannelDelta,
            meanLuminanceDelta: adaptiveMeasurement.meanLuminanceDelta,
            textureEnergyRatio: adaptiveMeasurement.textureEnergyRatio,
            durationMilliseconds: adaptiveDuration
        )
        let metrics = TeethComparisonMetrics(
            mode: parsed.mode,
            inputWidth: input.width,
            inputHeight: input.height,
            faceCount: detection.faceCount,
            innerLipPointCount: detection.anchors.innerLips.count,
            outerLipPointCount: detection.anchors.outerLips.count,
            innerLipRegionPixels: regionPixels,
            mouthCandidateRegionPixels: mouthCandidatePixels,
            fixed: fixedMetrics,
            adaptive: adaptiveMetrics,
            adaptiveAddedPixels: overlap.added,
            adaptiveDroppedPixels: overlap.dropped,
            strongIntersectionPixels: overlap.intersection,
            strongUnionPixels: overlap.union,
            strongMaskIoU: overlap.union > 0 ? Double(overlap.intersection) / Double(overlap.union) : 1,
            adaptiveStrongAreaRatio: mouthCandidatePixels > 0
                ? Double(adaptiveMetrics.strongMaskPixels) / Double(mouthCandidatePixels)
                : 0,
            peakResidentMegabytes: peakResidentMegabytes(),
            notes: [
                "The fixed mask is clipped to Vision inner-lip support; the adaptive path searches only inside an outer-lip-contained envelope with an upper safety inset and lower aperture extension.",
                "The adaptive path uses the fixed high-confidence mask as seeds, derives local brightness/chroma limits, and retains only connected candidates before compositing.",
                "An empty fixed seed set, implausible region, or implausible adaptive area fails closed.",
                "AI-generated fixtures validate mechanics only; useful coverage and protected-tissue judgments require licensed real review.",
            ]
        )
        log.add(
            "result",
            "adaptive teeth comparison completed",
            metadata: [
                "fixedStrongPixels": "\(fixedMetrics.strongMaskPixels)",
                "adaptiveStrongPixels": "\(adaptiveMetrics.strongMaskPixels)",
                "adaptiveAddedPixels": "\(overlap.added)",
                "adaptiveDroppedPixels": "\(overlap.dropped)",
            ]
        )

        try writePNG(fixedOutput, to: outputURL.appendingPathComponent("fixed-after.png"))
        try writePNG(adaptiveOutput, to: outputURL.appendingPathComponent("adaptive-after.png"))
        try writeMask(fixed, width: input.width, height: input.height, to: outputURL.appendingPathComponent("fixed-mask.png"))
        try writeMask(adaptive, width: input.width, height: input.height, to: outputURL.appendingPathComponent("adaptive-mask.png"))
        try writePNG(overlay(input, mask: fixed), to: outputURL.appendingPathComponent("fixed-overlay.png"))
        try writePNG(overlay(input, mask: adaptive), to: outputURL.appendingPathComponent("adaptive-overlay.png"))
        try writeJSON(metrics, to: outputURL.appendingPathComponent("comparison.json"))
        try writeJSON(log.events, to: outputURL.appendingPathComponent("events.json"))
        print(String(data: try JSONEncoder.pretty.encode(metrics), encoding: .utf8) ?? "")
    }

    private static func runScleraJitter(_ parsed: ParsedArguments) throws {
        guard let inputPath = parsed.options["input"],
              let outputPath = parsed.options["output"]
        else {
            throw LabError.invalidArguments("sclera-jitter requires --input and --output")
        }
        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        let log = EventLog()
        log.add("start", "sclera jitter study started", metadata: ["mode": parsed.mode])

        let cgImage = try loadCGImage(URL(fileURLWithPath: inputPath))
        let input = try Raster(cgImage: cgImage)
        let detectionStart = Date()
        let detection = try detectAnchors(cgImage: cgImage, width: input.width, height: input.height)
        let eyeCount = [detection.anchors.leftEye, detection.anchors.rightEye].filter { $0.count >= 4 }.count
        log.add(
            "detection",
            "request-local eye support captured",
            metadata: [
                "faces": "\(detection.faceCount)",
                "eyeCount": "\(eyeCount)",
                "pupilCount": "\([detection.anchors.leftPupil, detection.anchors.rightPupil].compactMap { $0 }.count)",
                "durationMs": formattedMilliseconds(Date().timeIntervalSince(detectionStart) * 1_000),
            ]
        )

        let horizontalShifts = [-0.12, -0.06, 0.0, 0.06, 0.12]
        let verticalShifts = [-0.08, 0.0, 0.08]
        let verticalScales = [1.0, 0.70, 0.40, 0.20]
        let minimumAspectRatio = 0.30
        let inflationFraction = 0.14
        let studyStart = Date()
        let study = try scleraJitterStudy(
            input,
            anchors: detection.anchors,
            horizontalShifts: horizontalShifts,
            verticalShifts: verticalShifts,
            verticalScales: verticalScales,
            guardedMinimumAspectRatio: minimumAspectRatio,
            guardedInflationFraction: inflationFraction
        )
        let baselineRetention = study.legacy.baselineEligiblePixels > 0
            ? Double(study.guarded.baselineEligiblePixels) / Double(study.legacy.baselineEligiblePixels)
            : 0
        let metrics = ScleraJitterMetrics(
            mode: parsed.mode,
            inputWidth: input.width,
            inputHeight: input.height,
            faceCount: detection.faceCount,
            eyeCount: eyeCount,
            scenariosPerEye: horizontalShifts.count * verticalShifts.count * verticalScales.count,
            scenarioCount: study.scenarioCount,
            pupilHorizontalShiftFractions: horizontalShifts,
            pupilVerticalShiftFractions: verticalShifts,
            eyeVerticalScaleFractions: verticalScales,
            guardedMinimumAspectRatio: minimumAspectRatio,
            guardedIrisInflationWidthFraction: inflationFraction,
            guardedFailedClosedByVerticalScale: study.guardedFailedClosedByVerticalScale,
            legacy: study.legacy,
            guarded: study.guarded,
            guardedBaselineRetentionRatio: baselineRetention,
            peakResidentMegabytes: peakResidentMegabytes(),
            notes: [
                "The study uses a color-independent geometric selection envelope so iris risk cannot be hidden by dark iris pixels failing the redness gate.",
                "Protected iris truth is the unperturbed pupil-centered exclusion used by the existing baseline; specular pixels are independently protected from the input.",
                "The guard fails closed below the minimum eye aspect ratio or when the perturbed pupil leaves the observed aperture.",
                "Accepted guarded scenarios inflate the iris exclusion by a bounded landmark-uncertainty margin before any color candidate can be selected.",
                "Only aggregate scenario/count metrics are persisted; raw pupils, contours, and per-scenario geometry remain request-local.",
            ]
        )
        log.add(
            "result",
            "sclera jitter study completed",
            metadata: [
                "scenarioCount": "\(study.scenarioCount)",
                "legacyLeakScenarios": "\(study.legacy.irisLeakScenarioCount)",
                "guardedLeakScenarios": "\(study.guarded.irisLeakScenarioCount)",
                "guardedFailClosedScenarios": "\(study.guarded.failedClosedScenarioCount)",
                "durationMs": formattedMilliseconds(Date().timeIntervalSince(studyStart) * 1_000),
            ]
        )

        try writePNG(overlay(input, mask: study.legacyBaselineMask), to: outputURL.appendingPathComponent("legacy-baseline-overlay.png"))
        try writePNG(overlay(input, mask: study.guardedBaselineMask), to: outputURL.appendingPathComponent("guarded-baseline-overlay.png"))
        try writePNG(protectionOverlay(input, mask: study.protectedMask), to: outputURL.appendingPathComponent("protected-overlay.png"))
        try writePNG(leakHeatmapOverlay(input, counts: study.legacyLeakCounts), to: outputURL.appendingPathComponent("legacy-leak-heatmap.png"))
        try writePNG(leakHeatmapOverlay(input, counts: study.guardedLeakCounts), to: outputURL.appendingPathComponent("guarded-leak-heatmap.png"))
        try writeJSON(metrics, to: outputURL.appendingPathComponent("comparison.json"))
        try writeJSON(log.events, to: outputURL.appendingPathComponent("events.json"))
        print(String(data: try JSONEncoder.pretty.encode(metrics), encoding: .utf8) ?? "")
    }

    private static func runScleraGuardedColor(_ parsed: ParsedArguments) throws {
        guard let inputPath = parsed.options["input"],
              let outputPath = parsed.options["output"]
        else {
            throw LabError.invalidArguments("sclera-guarded-color requires --input and --output")
        }
        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        let log = EventLog()
        log.add("start", "guarded sclera color integration started", metadata: ["mode": parsed.mode])

        let cgImage = try loadCGImage(URL(fileURLWithPath: inputPath))
        let input = try Raster(cgImage: cgImage)
        let detectionStart = Date()
        let detection = try detectAnchors(cgImage: cgImage, width: input.width, height: input.height)
        let eyeCount = [detection.anchors.leftEye, detection.anchors.rightEye].filter { $0.count >= 4 }.count
        log.add(
            "detection",
            "request-local eye support captured",
            metadata: [
                "faces": "\(detection.faceCount)",
                "eyeCount": "\(eyeCount)",
                "pupilCount": "\([detection.anchors.leftPupil, detection.anchors.rightPupil].compactMap { $0 }.count)",
                "durationMs": formattedMilliseconds(Date().timeIntervalSince(detectionStart) * 1_000),
            ]
        )

        let horizontalShifts = [-0.12, -0.06, 0.0, 0.06, 0.12]
        let verticalShifts = [-0.08, 0.0, 0.08]
        let verticalScales = [1.0, 0.70, 0.40, 0.20]
        let minimumAspectRatio = 0.30
        let inflationFraction = 0.14
        let studyStart = Date()
        let study = try scleraColorIntegrationStudy(
            input,
            anchors: detection.anchors,
            horizontalShifts: horizontalShifts,
            verticalShifts: verticalShifts,
            verticalScales: verticalScales,
            guardedMinimumAspectRatio: minimumAspectRatio,
            guardedInflationFraction: inflationFraction
        )
        let baselineRetention = study.legacy.baselineNativeMaskPixels > 0
            ? Double(study.guarded.baselineNativeMaskPixels) / Double(study.legacy.baselineNativeMaskPixels)
            : 0
        let metrics = ScleraColorIntegrationMetrics(
            mode: parsed.mode,
            inputWidth: input.width,
            inputHeight: input.height,
            faceCount: detection.faceCount,
            eyeCount: eyeCount,
            scenariosPerEye: horizontalShifts.count * verticalShifts.count * verticalScales.count,
            scenarioCount: study.scenarioCount,
            pupilHorizontalShiftFractions: horizontalShifts,
            pupilVerticalShiftFractions: verticalShifts,
            eyeVerticalScaleFractions: verticalScales,
            guardedMinimumAspectRatio: minimumAspectRatio,
            guardedIrisInflationWidthFraction: inflationFraction,
            guardedFailedClosedByVerticalScale: study.guardedFailedClosedByVerticalScale,
            legacy: study.legacy,
            guarded: study.guarded,
            guardedBaselineNativeMaskRetentionRatio: baselineRetention,
            peakResidentMegabytes: peakResidentMegabytes(),
            notes: [
                "Native inputs exercise the actual redness score and bounded transform; a request-local color-adversarial copy makes the unperturbed protected iris sclera-like red so appearance cannot hide geometric leakage.",
                "The guarded path validates each eye independently, scores color only inside the hard envelope, feathers locally, and then clips the feathered mask back to the same envelope.",
                "Protected-iris and highlight findings count final changed pixels, not only mask overlap.",
                "The 0.30/0.14 guard values are deterministic calibration seeds from Spike 010, not product constants.",
                "Only aggregate counts are persisted; contours, pupils, raw per-scenario masks, and color-adversarial geometry remain request-local.",
            ]
        )
        log.add(
            "result",
            "guarded sclera color integration completed",
            metadata: [
                "scenarioCount": "\(study.scenarioCount)",
                "legacyChallengeProtectedChangeScenarios": "\(study.legacy.challengeProtectedChangeScenarioCount)",
                "guardedChallengeProtectedChangeScenarios": "\(study.guarded.challengeProtectedChangeScenarioCount)",
                "guardedFailClosedEyeScenarios": "\(study.guarded.failedClosedEyeScenarioCount)",
                "guardedBaselineMaskPixels": "\(study.guarded.baselineNativeMaskPixels)",
                "durationMs": formattedMilliseconds(Date().timeIntervalSince(studyStart) * 1_000),
            ]
        )

        try writePNG(study.legacyBaselineOutput, to: outputURL.appendingPathComponent("legacy-after.png"))
        try writePNG(study.guardedBaselineOutput, to: outputURL.appendingPathComponent("guarded-after.png"))
        try writeMask(study.legacyBaselineMask, width: input.width, height: input.height, to: outputURL.appendingPathComponent("legacy-mask.png"))
        try writeMask(study.guardedBaselineMask, width: input.width, height: input.height, to: outputURL.appendingPathComponent("guarded-mask.png"))
        try writePNG(overlay(input, mask: study.legacyBaselineMask), to: outputURL.appendingPathComponent("legacy-overlay.png"))
        try writePNG(overlay(input, mask: study.guardedBaselineMask), to: outputURL.appendingPathComponent("guarded-overlay.png"))
        try writePNG(protectionOverlay(input, mask: study.protectedMask), to: outputURL.appendingPathComponent("protected-overlay.png"))
        try writePNG(protectionOverlay(input, mask: study.highlightMask), to: outputURL.appendingPathComponent("highlight-overlay.png"))
        try writePNG(study.challengeInput, to: outputURL.appendingPathComponent("challenge-input.png"))
        try writePNG(study.legacyChallengeBaselineOutput, to: outputURL.appendingPathComponent("legacy-challenge-after.png"))
        try writePNG(study.guardedChallengeBaselineOutput, to: outputURL.appendingPathComponent("guarded-challenge-after.png"))
        try writeMask(study.legacyChallengeBaselineMask, width: input.width, height: input.height, to: outputURL.appendingPathComponent("legacy-challenge-mask.png"))
        try writeMask(study.guardedChallengeBaselineMask, width: input.width, height: input.height, to: outputURL.appendingPathComponent("guarded-challenge-mask.png"))
        try writePNG(leakHeatmapOverlay(input, counts: study.legacyChallengeLeakCounts), to: outputURL.appendingPathComponent("legacy-challenge-leak-heatmap.png"))
        try writePNG(leakHeatmapOverlay(input, counts: study.guardedChallengeLeakCounts), to: outputURL.appendingPathComponent("guarded-challenge-leak-heatmap.png"))
        try writeJSON(metrics, to: outputURL.appendingPathComponent("comparison.json"))
        try writeJSON(log.events, to: outputURL.appendingPathComponent("events.json"))
        print(String(data: try JSONEncoder.pretty.encode(metrics), encoding: .utf8) ?? "")
    }

    private static func runGuardedLocalComposition(_ parsed: ParsedArguments) throws {
        guard let inputPath = parsed.options["input"],
              let outputPath = parsed.options["output"]
        else {
            throw LabError.invalidArguments("guarded-local-composition requires --input and --output")
        }
        let iterations = max(1, Int(parsed.options["iterations"] ?? "9") ?? 9)
        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        let log = EventLog()
        log.add("start", "guarded local-retouch composition started", metadata: ["mode": parsed.mode])

        let cgImage = try loadCGImage(URL(fileURLWithPath: inputPath))
        let input = try Raster(cgImage: cgImage)
        let detectionStart = Date()
        let detection = try detectAnchors(cgImage: cgImage, width: input.width, height: input.height)
        let detectionDuration = Date().timeIntervalSince(detectionStart) * 1_000
        let eyeCount = [
            (detection.anchors.leftEye, detection.anchors.leftPupil),
            (detection.anchors.rightEye, detection.anchors.rightPupil),
        ].filter { $0.0.count >= 4 && $0.1 != nil }.count
        log.add(
            "detection",
            "one request-local face context captured",
            metadata: [
                "faces": "\(detection.faceCount)",
                "eyeCount": "\(eyeCount)",
                "pupilCount": "\([detection.anchors.leftPupil, detection.anchors.rightPupil].compactMap { $0 }.count)",
                "innerLipCount": "\(detection.anchors.innerLips.count)",
                "outerLipCount": "\(detection.anchors.outerLips.count)",
                "requestCount": "1",
                "durationMs": formattedMilliseconds(detectionDuration),
            ]
        )

        let experimentStart = Date()
        let teeth = try adaptiveTeethSelection(input, anchors: detection.anchors)
        let sclera = try guardedScleraPair(input, anchors: detection.anchors)
        let protection = try scleraProtectionMasks(input, anchors: detection.anchors)
        let fused = composeLocalRetouch(
            input,
            teethMask: teeth.adaptive,
            scleraMask: sclera.combinedMask
        )

        let teethStandalone = whitenTeeth(input, mask: teeth.adaptive, strength: 0.62)
        let scleraStandalone = reduceScleraRedness(input, mask: sclera.combinedMask, strength: 0.72)
        let standaloneOracle = mergeStandaloneLocalRetouch(
            original: input,
            teethOutput: teethStandalone,
            scleraOutput: scleraStandalone,
            teethMask: teeth.adaptive,
            scleraMask: sclera.combinedMask
        )
        let sequentialOracle = reduceScleraRedness(
            whitenTeeth(input, mask: teeth.adaptive, strength: 0.62),
            mask: sclera.combinedMask,
            strength: 0.72
        )

        let legacyTeeth = try heuristicTeethMask(input, innerLips: detection.anchors.innerLips)
        let legacySclera = try scleraRednessMask(input, anchors: detection.anchors)
        let legacyUnion = zip(legacyTeeth, legacySclera).map { max($0, $1) }
        let legacyOutput = reduceScleraRedness(
            whitenTeeth(input, mask: legacyTeeth, strength: 0.62),
            mask: legacySclera,
            strength: 0.72
        )

        let zeroMask = [Float](repeating: 0, count: input.width * input.height)
        let teethRejectedOutput = composeLocalRetouch(
            input,
            teethMask: zeroMask,
            scleraMask: sclera.combinedMask
        ).output
        let scleraRejectedOutput = composeLocalRetouch(
            input,
            teethMask: teeth.adaptive,
            scleraMask: zeroMask
        ).output

        let leftRejected = try guardedScleraPair(
            input,
            anchors: detection.anchors,
            rejectLeft: true
        )
        let rightRejected = try guardedScleraPair(
            input,
            anchors: detection.anchors,
            rejectRight: true
        )
        let leftRejectedOutput = composeLocalRetouch(
            input,
            teethMask: teeth.adaptive,
            scleraMask: leftRejected.combinedMask
        ).output
        let rightRejectedOutput = composeLocalRetouch(
            input,
            teethMask: teeth.adaptive,
            scleraMask: rightRejected.combinedMask
        ).output
        let leftRejectedScleraStandalone = reduceScleraRedness(
            input,
            mask: leftRejected.combinedMask,
            strength: 0.72
        )
        let rightRejectedScleraStandalone = reduceScleraRedness(
            input,
            mask: rightRejected.combinedMask,
            strength: 0.72
        )
        let leftRejectedOracle = mergeStandaloneLocalRetouch(
            original: input,
            teethOutput: teethStandalone,
            scleraOutput: leftRejectedScleraStandalone,
            teethMask: teeth.adaptive,
            scleraMask: leftRejected.combinedMask
        )
        let rightRejectedOracle = mergeStandaloneLocalRetouch(
            original: input,
            teethOutput: teethStandalone,
            scleraOutput: rightRejectedScleraStandalone,
            teethMask: teeth.adaptive,
            scleraMask: rightRejected.combinedMask
        )

        var injectedScleraMask = sclera.combinedMask
        var injectedOverlapMask = zeroMask
        if let overlapIndex = teeth.adaptive.firstIndex(where: { $0 > 0.15 }) {
            injectedScleraMask[overlapIndex] = max(injectedScleraMask[overlapIndex], teeth.adaptive[overlapIndex])
            injectedOverlapMask[overlapIndex] = 1
        }
        let overlapInjected = composeLocalRetouch(
            input,
            teethMask: teeth.adaptive,
            scleraMask: injectedScleraMask
        )

        var fusedDurations: [Double] = []
        var sequentialDurations: [Double] = []
        var lastFused = fused.output
        var lastSequential = sequentialOracle
        for _ in 0..<iterations {
            let fusedStart = Date()
            lastFused = composeLocalRetouch(
                input,
                teethMask: teeth.adaptive,
                scleraMask: sclera.combinedMask
            ).output
            fusedDurations.append(Date().timeIntervalSince(fusedStart) * 1_000)

            let sequentialStart = Date()
            lastSequential = reduceScleraRedness(
                whitenTeeth(input, mask: teeth.adaptive, strength: 0.62),
                mask: sclera.combinedMask,
                strength: 0.72
            )
            sequentialDurations.append(Date().timeIntervalSince(sequentialStart) * 1_000)
        }
        let fusedVsStandalone = differentPixelCount(fused.output, standaloneOracle)
        let fusedVsSequential = differentPixelCount(fused.output, sequentialOracle)
        let benchmarkMismatch = differentPixelCount(lastFused, lastSequential)
        let teethRejectedMismatch = differentPixelCount(teethRejectedOutput, scleraStandalone)
        let scleraRejectedMismatch = differentPixelCount(scleraRejectedOutput, teethStandalone)
        let leftRejectedMismatch = differentPixelCount(leftRejectedOutput, leftRejectedOracle)
        let rightRejectedMismatch = differentPixelCount(rightRejectedOutput, rightRejectedOracle)
        let failureMismatchTotal = teethRejectedMismatch
            + scleraRejectedMismatch
            + leftRejectedMismatch
            + rightRejectedMismatch

        let legacyMetrics = localRetouchVariantMetrics(
            before: input,
            after: legacyOutput,
            mask: legacyUnion,
            protectedMask: protection.protected,
            highlightMask: protection.highlights
        )
        let fusedMetrics = localRetouchVariantMetrics(
            before: input,
            after: fused.output,
            mask: fused.unionMask,
            protectedMask: protection.protected,
            highlightMask: protection.highlights
        )
        let failureMetrics = LocalRetouchFailureMetrics(
            teethRejectedMismatchPixels: teethRejectedMismatch,
            scleraRejectedMismatchPixels: scleraRejectedMismatch,
            leftEyeRejectedMismatchPixels: leftRejectedMismatch,
            rightEyeRejectedMismatchPixels: rightRejectedMismatch,
            injectedOverlapPixels: overlapInjected.overlapPixels,
            overlapSuppressedPixels: overlapInjected.overlapPixels,
            overlapChangedPixels: changedPixelCount(
                before: input,
                after: overlapInjected.output,
                within: injectedOverlapMask
            )
        )
        let metrics = LocalRetouchCompositionMetrics(
            mode: parsed.mode,
            inputWidth: input.width,
            inputHeight: input.height,
            faceCount: detection.faceCount,
            detectionRequestCount: 1,
            eyeCount: eyeCount,
            innerLipPointCount: detection.anchors.innerLips.count,
            outerLipPointCount: detection.anchors.outerLips.count,
            fixedTeethStrongPixels: teeth.fixed.lazy.filter { $0 > 0.15 }.count,
            adaptiveTeethStrongPixels: teeth.adaptive.lazy.filter { $0 > 0.15 }.count,
            leftScleraMaskPixels: sclera.leftMask.lazy.filter { $0 > 0.001 }.count,
            rightScleraMaskPixels: sclera.rightMask.lazy.filter { $0 > 0.001 }.count,
            baselineCrossMaskOverlapPixels: fused.overlapPixels,
            fusedVsStandaloneMismatchPixels: fusedVsStandalone,
            fusedVsSequentialMismatchPixels: max(fusedVsSequential, benchmarkMismatch),
            legacyVsFusedMismatchPixels: differentPixelCount(legacyOutput, fused.output),
            medianFusedMilliseconds: median(fusedDurations),
            medianSequentialMilliseconds: median(sequentialDurations),
            legacy: legacyMetrics,
            fused: fusedMetrics,
            failureIsolation: failureMetrics,
            peakResidentMegabytes: peakResidentMegabytes(),
            notes: [
                "One Vision request supplies private eye, pupil, inner-lip, and outer-lip support to both mask providers.",
                "The fused pass reads every edited pixel from the original image; independent standalone outputs and the previous sequential ordering are byte-level correctness oracles when masks are disjoint.",
                "Adaptive teeth and guarded sclera masks are hard-clipped by their providers before composition. Any cross-mask overlap suppresses both local edits at that pixel instead of choosing an implicit precedence.",
                "Teeth, whole-sclera, left-eye, and right-eye failures are injected independently and compared with standalone expected outputs.",
                "AI-generated fixtures validate composition mechanics only; useful coverage, naturalness, and the 0.30/0.14 sclera thresholds still require licensed real review.",
            ]
        )
        log.add(
            "result",
            "guarded local-retouch composition completed",
            metadata: [
                "adaptiveTeethPixels": "\(metrics.adaptiveTeethStrongPixels)",
                "guardedScleraPixels": "\(metrics.leftScleraMaskPixels + metrics.rightScleraMaskPixels)",
                "baselineOverlapPixels": "\(metrics.baselineCrossMaskOverlapPixels)",
                "fusedMismatchPixels": "\(fusedVsStandalone + fusedVsSequential + benchmarkMismatch)",
                "failureMismatchPixels": "\(failureMismatchTotal)",
                "durationMs": formattedMilliseconds(Date().timeIntervalSince(experimentStart) * 1_000),
            ]
        )

        try writePNG(legacyOutput, to: outputURL.appendingPathComponent("legacy-after.png"))
        try writePNG(fused.output, to: outputURL.appendingPathComponent("fused-after.png"))
        try writePNG(overlay(input, mask: legacyUnion), to: outputURL.appendingPathComponent("legacy-overlay.png"))
        try writePNG(overlay(input, mask: fused.unionMask), to: outputURL.appendingPathComponent("fused-overlay.png"))
        try writeMask(teeth.adaptive, width: input.width, height: input.height, to: outputURL.appendingPathComponent("adaptive-teeth-mask.png"))
        try writeMask(sclera.combinedMask, width: input.width, height: input.height, to: outputURL.appendingPathComponent("guarded-sclera-mask.png"))
        try writeMask(fused.unionMask, width: input.width, height: input.height, to: outputURL.appendingPathComponent("fused-union-mask.png"))
        try writePNG(teethRejectedOutput, to: outputURL.appendingPathComponent("teeth-rejected-after.png"))
        try writePNG(scleraRejectedOutput, to: outputURL.appendingPathComponent("sclera-rejected-after.png"))
        try writePNG(leftRejectedOutput, to: outputURL.appendingPathComponent("left-eye-rejected-after.png"))
        try writePNG(rightRejectedOutput, to: outputURL.appendingPathComponent("right-eye-rejected-after.png"))
        try writePNG(overlapInjected.output, to: outputURL.appendingPathComponent("overlap-injected-after.png"))
        try writeJSON(metrics, to: outputURL.appendingPathComponent("comparison.json"))
        try writeJSON(log.events, to: outputURL.appendingPathComponent("events.json"))
        print(String(data: try JSONEncoder.pretty.encode(metrics), encoding: .utf8) ?? "")
    }

    private static func runNormalizedInputContract(_ parsed: ParsedArguments) throws {
        guard let inputPath = parsed.options["input"],
              let outputPath = parsed.options["output"]
        else {
            throw LabError.invalidArguments("normalized-input-contract requires --input and --output")
        }
        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        let log = EventLog()
        log.add("start", "normalized input contract started", metadata: ["mode": parsed.mode])
        let started = Date()
        let context = canonicalImageContext()

        let sourceCanonical = try normalizedImage(
            at: URL(fileURLWithPath: inputPath),
            context: context
        )
        let referenceData = try encodedImageData(
            sourceCanonical,
            orientationRaw: CGImagePropertyOrientation.up.rawValue,
            typeIdentifier: UTType.tiff.identifier
        )
        let referenceImage = try normalizedImage(data: referenceData, context: context)
        let reference = try localRetouchEvidence(referenceImage)

        var orientationMetrics: [NormalizedOrientationVariantMetrics] = []
        var orientationSixRaw: CGImage?
        var orientationSixEvidence: LocalRetouchEvidence?
        for orientationRaw in UInt32(1)...UInt32(8) {
            let encodedPixels = try inverseOrientedImage(
                referenceImage,
                targetOrientationRaw: orientationRaw,
                context: context
            )
            let data = try encodedImageData(
                encodedPixels,
                orientationRaw: orientationRaw,
                typeIdentifier: UTType.tiff.identifier
            )
            let normalized = try normalizedImage(data: data, context: context)
            let evidence = try localRetouchEvidence(normalized)
            let inputRaster = try Raster(cgImage: normalized)
            let metric = NormalizedOrientationVariantMetrics(
                orientationRawValue: orientationRaw,
                encodedWidth: encodedPixels.width,
                encodedHeight: encodedPixels.height,
                normalizedWidth: normalized.width,
                normalizedHeight: normalized.height,
                inputMismatchPixels: differentPixelCount(reference.input, inputRaster),
                inputAlphaMismatchPixels: alphaMismatchCount(reference.input, inputRaster),
                maximumInputChannelDelta: maximumRGBChannelDelta(reference.input, inputRaster),
                maximumAnchorDeltaPixels: maximumAnchorDelta(
                    reference.detection.anchors,
                    evidence.detection.anchors
                ),
                teethStrongTopologyMismatchPixels: maskTopologyMismatchCount(
                    reference.teethMask,
                    evidence.teethMask,
                    threshold: 0.15
                ),
                scleraStrongTopologyMismatchPixels: maskTopologyMismatchCount(
                    reference.scleraMask,
                    evidence.scleraMask,
                    threshold: 0.15
                ),
                outputMismatchPixels: differentPixelCount(reference.output, evidence.output),
                outputAlphaMismatchPixels: alphaMismatchCount(reference.output, evidence.output),
                maximumOutputChannelDelta: maximumRGBChannelDelta(reference.output, evidence.output)
            )
            orientationMetrics.append(metric)
            if orientationRaw == CGImagePropertyOrientation.right.rawValue {
                orientationSixRaw = encodedPixels
                orientationSixEvidence = evidence
            }
        }

        guard let displayP3 = CGColorSpace(name: CGColorSpace.displayP3),
              let sRGB = CGColorSpace(name: CGColorSpace.sRGB)
        else { throw LabError.imageLoadFailed("system color spaces") }
        let p3EncodedPixels = try colorConvertedImage(
            referenceImage,
            colorSpace: displayP3,
            context: context
        )
        let p3Data = try encodedImageData(
            p3EncodedPixels,
            orientationRaw: CGImagePropertyOrientation.up.rawValue,
            typeIdentifier: UTType.tiff.identifier
        )
        let p3NormalizedImage = try normalizedImage(data: p3Data, context: context)
        let p3Evidence = try localRetouchEvidence(p3NormalizedImage)
        let p3FixedAnchorEvidence = try localRetouchEvidence(
            p3NormalizedImage,
            fixedAnchors: reference.detection.anchors
        )
        let p3Input = try Raster(cgImage: p3NormalizedImage)
        let p3Metrics = NormalizedColorVariantMetrics(
            sourceColorSpace: "Display P3",
            normalizedColorSpace: "sRGB RGBA8",
            inputMismatchPixels: differentPixelCount(reference.input, p3Input),
            maximumInputChannelDelta: maximumRGBChannelDelta(reference.input, p3Input),
            maximumAnchorDeltaPixels: maximumAnchorDelta(
                reference.detection.anchors,
                p3Evidence.detection.anchors
            ),
            teethStrongTopologyMismatchPixels: maskTopologyMismatchCount(
                reference.teethMask,
                p3Evidence.teethMask,
                threshold: 0.15
            ),
            scleraStrongTopologyMismatchPixels: maskTopologyMismatchCount(
                reference.scleraMask,
                p3Evidence.scleraMask,
                threshold: 0.15
            ),
            fixedAnchorTeethStrongTopologyMismatchPixels: maskTopologyMismatchCount(
                reference.teethMask,
                p3FixedAnchorEvidence.teethMask,
                threshold: 0.15
            ),
            fixedAnchorScleraStrongTopologyMismatchPixels: maskTopologyMismatchCount(
                reference.scleraMask,
                p3FixedAnchorEvidence.scleraMask,
                threshold: 0.15
            ),
            outputMismatchPixels: differentPixelCount(reference.output, p3Evidence.output),
            maximumOutputChannelDelta: maximumRGBChannelDelta(reference.output, p3Evidence.output),
            fixedAnchorMaximumOutputChannelDelta: maximumRGBChannelDelta(
                reference.output,
                p3FixedAnchorEvidence.output
            ),
            changedOutsideMask: measure(
                before: p3Evidence.input,
                after: p3Evidence.output,
                mask: p3Evidence.unionMask
            ).changedOutsideMask
        )

        var alphaSource = try Raster(cgImage: referenceImage)
        applyTransparentBorder(to: &alphaSource)
        let alphaSourceImage = try alphaSource.makeCGImage()
        let alphaData = try encodedImageData(
            alphaSourceImage,
            orientationRaw: CGImagePropertyOrientation.up.rawValue,
            typeIdentifier: UTType.tiff.identifier
        )
        let alphaNormalizedImage = try normalizedImage(data: alphaData, context: context)
        let alphaEvidence = try localRetouchEvidence(alphaNormalizedImage)
        let alphaFixedAnchorEvidence = try localRetouchEvidence(
            alphaNormalizedImage,
            fixedAnchors: reference.detection.anchors
        )
        let alphaInput = try Raster(cgImage: alphaNormalizedImage)
        let transparentRegion = alphaInput.pixels.indices.reduce(into: [Float](repeating: 0, count: alphaInput.width * alphaInput.height)) { region, offset in
            guard offset % 4 == 3, alphaInput.pixels[offset] == 0 else { return }
            region[offset / 4] = 1
        }
        let alphaMetrics = NormalizedAlphaVariantMetrics(
            transparentInputPixels: transparentRegion.lazy.filter { $0 > 0.5 }.count,
            normalizedAlphaMismatchPixels: alphaMismatchCount(alphaSource, alphaInput),
            outputAlphaMismatchPixels: alphaMismatchCount(alphaEvidence.input, alphaEvidence.output),
            transparentRGBChangedPixels: changedPixelCount(
                before: alphaEvidence.input,
                after: alphaEvidence.output,
                within: transparentRegion
            ),
            maximumAnchorDeltaPixels: maximumAnchorDelta(
                reference.detection.anchors,
                alphaEvidence.detection.anchors
            ),
            teethStrongTopologyMismatchPixels: maskTopologyMismatchCount(
                reference.teethMask,
                alphaEvidence.teethMask,
                threshold: 0.15
            ),
            scleraStrongTopologyMismatchPixels: maskTopologyMismatchCount(
                reference.scleraMask,
                alphaEvidence.scleraMask,
                threshold: 0.15
            ),
            fixedAnchorTeethStrongTopologyMismatchPixels: maskTopologyMismatchCount(
                reference.teethMask,
                alphaFixedAnchorEvidence.teethMask,
                threshold: 0.15
            ),
            fixedAnchorScleraStrongTopologyMismatchPixels: maskTopologyMismatchCount(
                reference.scleraMask,
                alphaFixedAnchorEvidence.scleraMask,
                threshold: 0.15
            ),
            changedOutsideMask: measure(
                before: alphaEvidence.input,
                after: alphaEvidence.output,
                mask: alphaEvidence.unionMask
            ).changedOutsideMask
        )

        let invalidOrientationFailedClosed: Bool
        do {
            _ = try normalizedImage(
                referenceImage,
                orientationRaw: 9,
                context: context,
                destinationColorSpace: sRGB
            )
            invalidOrientationFailedClosed = false
        } catch LabError.invalidImageOrientation {
            invalidOrientationFailedClosed = true
        }
        let nonRGBInputFailedClosed: Bool
        do {
            _ = try normalizedImage(
                makeGrayTestImage(),
                orientationRaw: CGImagePropertyOrientation.up.rawValue,
                context: context,
                destinationColorSpace: sRGB
            )
            nonRGBInputFailedClosed = false
        } catch LabError.unsupportedImageColorModel {
            nonRGBInputFailedClosed = true
        }

        let orientationMismatchTotal = orientationMetrics.reduce(0) {
            $0 + $1.inputMismatchPixels + $1.outputMismatchPixels
                + $1.inputAlphaMismatchPixels + $1.outputAlphaMismatchPixels
        }
        let orientationTopologyMismatchTotal = orientationMetrics.reduce(0) {
            $0 + $1.teethStrongTopologyMismatchPixels + $1.scleraStrongTopologyMismatchPixels
        }
        let maximumOrientationAnchorDelta = orientationMetrics
            .map(\.maximumAnchorDeltaPixels)
            .max() ?? 0
        let metrics = NormalizedInputMetrics(
            mode: parsed.mode,
            inputWidth: reference.input.width,
            inputHeight: reference.input.height,
            faceCount: reference.detection.faceCount,
            detectionRequestCount: orientationMetrics.count + 2,
            orientationVariantCount: orientationMetrics.count,
            orientationVariants: orientationMetrics,
            orientationMismatchPixelsTotal: orientationMismatchTotal,
            orientationTopologyMismatchPixelsTotal: orientationTopologyMismatchTotal,
            maximumOrientationAnchorDeltaPixels: maximumOrientationAnchorDelta,
            displayP3: p3Metrics,
            transparentBorder: alphaMetrics,
            invalidOrientationFailedClosed: invalidOrientationFailedClosed,
            nonRGBInputFailedClosed: nonRGBInputFailedClosed,
            peakResidentMegabytes: peakResidentMegabytes(),
            notes: [
                "ImageIO orientation metadata is validated before Core Image rotates or mirrors source pixels into an up-oriented sRGB RGBA8 image.",
                "All eight lossless TIFF orientation representations are compared against one encoded canonical oracle before Vision, mask selection, and composition.",
                "Display P3 is color-managed back to sRGB; bounded channel deltas and strong-mask topology are reported both with a fresh Vision result and with canonical anchors held fixed to separate detector sensitivity from color-score sensitivity.",
                "The alpha case uses a transparent border outside the face. Composition must preserve every alpha byte and transparent RGB pixel; fixed-anchor metrics isolate any detector response to the changed canvas boundary.",
                "Invalid EXIF orientation and non-RGB source models fail closed before Vision. Events persist aggregate counts and deltas only.",
                "This isolated macOS experiment does not change or validate the production normalizer, HDR, device performance, or product readiness.",
            ]
        )
        log.add(
            "result",
            "normalized input contract completed",
            metadata: [
                "variantCount": "\(metrics.orientationVariantCount + 2)",
                "orientationMismatchPixels": "\(metrics.orientationMismatchPixelsTotal)",
                "orientationTopologyMismatchPixels": "\(metrics.orientationTopologyMismatchPixelsTotal)",
                "maximumOrientationAnchorDelta": String(format: "%.6f", metrics.maximumOrientationAnchorDeltaPixels),
                "p3MaximumInputDelta": "\(metrics.displayP3.maximumInputChannelDelta)",
                "p3TopologyMismatchPixels": "\(metrics.displayP3.teethStrongTopologyMismatchPixels + metrics.displayP3.scleraStrongTopologyMismatchPixels)",
                "alphaMismatchPixels": "\(metrics.transparentBorder.outputAlphaMismatchPixels)",
                "rejectedInputCount": "\([metrics.invalidOrientationFailedClosed, metrics.nonRGBInputFailedClosed].filter { $0 }.count)",
                "durationMs": formattedMilliseconds(Date().timeIntervalSince(started) * 1_000),
            ]
        )

        try writePNG(reference.input, to: outputURL.appendingPathComponent("canonical-input.png"))
        try writePNG(reference.output, to: outputURL.appendingPathComponent("canonical-after.png"))
        try writePNG(overlay(reference.input, mask: reference.unionMask), to: outputURL.appendingPathComponent("canonical-overlay.png"))
        if let orientationSixRaw {
            try writePNG(try Raster(cgImage: orientationSixRaw), to: outputURL.appendingPathComponent("orientation-6-encoded-pixels.png"))
        }
        if let orientationSixEvidence {
            try writePNG(orientationSixEvidence.output, to: outputURL.appendingPathComponent("orientation-6-normalized-after.png"))
            try writePNG(overlay(orientationSixEvidence.input, mask: orientationSixEvidence.unionMask), to: outputURL.appendingPathComponent("orientation-6-normalized-overlay.png"))
        }
        try writePNG(p3Input, to: outputURL.appendingPathComponent("display-p3-normalized-input.png"))
        try writePNG(p3Evidence.output, to: outputURL.appendingPathComponent("display-p3-normalized-after.png"))
        try writePNG(alphaEvidence.input, to: outputURL.appendingPathComponent("transparent-border-input.png"))
        try writePNG(alphaEvidence.output, to: outputURL.appendingPathComponent("transparent-border-after.png"))
        try writeJSON(metrics, to: outputURL.appendingPathComponent("comparison.json"))
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

private func canonicalImageContext() -> CIContext {
    let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
    return CIContext(options: [
        .workingColorSpace: sRGB,
        .outputColorSpace: sRGB,
        .useSoftwareRenderer: true,
        .cacheIntermediates: false,
    ])
}

private func normalizedImage(at url: URL, context: CIContext) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
        throw LabError.imageLoadFailed(url.path)
    }
    return try normalizedImage(source: source, context: context)
}

private func normalizedImage(data: Data, context: CIContext) throws -> CGImage {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
        throw LabError.imageLoadFailed("encoded image data")
    }
    return try normalizedImage(source: source, context: context)
}

private func normalizedImage(source: CGImageSource, context: CIContext) throws -> CGImage {
    guard let rawImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        throw LabError.imageLoadFailed("image source frame")
    }
    let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as NSDictionary?
    let orientationRaw = (properties?[kCGImagePropertyOrientation] as? NSNumber)?.uint32Value
        ?? CGImagePropertyOrientation.up.rawValue
    guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB) else {
        throw LabError.imageLoadFailed("sRGB color space")
    }
    return try normalizedImage(
        rawImage,
        orientationRaw: orientationRaw,
        context: context,
        destinationColorSpace: sRGB
    )
}

private func normalizedImage(
    _ rawImage: CGImage,
    orientationRaw: UInt32,
    context: CIContext,
    destinationColorSpace: CGColorSpace
) throws -> CGImage {
    guard (CGImagePropertyOrientation.up.rawValue...CGImagePropertyOrientation.left.rawValue)
        .contains(orientationRaw)
    else {
        throw LabError.invalidImageOrientation
    }
    guard let sourceColorSpace = rawImage.colorSpace,
          sourceColorSpace.model == .rgb
    else { throw LabError.unsupportedImageColorModel }
    let source = CIImage(cgImage: rawImage, options: [.colorSpace: sourceColorSpace])
    let oriented = source.oriented(forExifOrientation: Int32(orientationRaw))
    let extent = oriented.extent.integral
    guard extent.width > 0,
          extent.height > 0,
          extent.width.isFinite,
          extent.height.isFinite
    else { throw LabError.imageLoadFailed("normalized extent") }
    guard let image = context.createCGImage(
        oriented,
        from: extent,
        format: .RGBA8,
        colorSpace: destinationColorSpace
    ) else { throw LabError.imageLoadFailed("normalized render") }
    return image
}

private func encodedImageData(
    _ image: CGImage,
    orientationRaw: UInt32,
    typeIdentifier: String
) throws -> Data {
    let data = NSMutableData()
    guard let destination = CGImageDestinationCreateWithData(
        data,
        typeIdentifier as CFString,
        1,
        nil
    ) else { throw LabError.imageWriteFailed("encoded image data") }
    let properties = [
        kCGImagePropertyOrientation: NSNumber(value: orientationRaw),
    ] as CFDictionary
    CGImageDestinationAddImage(destination, image, properties)
    guard CGImageDestinationFinalize(destination) else {
        throw LabError.imageWriteFailed("encoded image data")
    }
    return data as Data
}

private func inverseOrientedImage(
    _ canonical: CGImage,
    targetOrientationRaw: UInt32,
    context: CIContext
) throws -> CGImage {
    let inverseRaw: UInt32
    switch targetOrientationRaw {
    case 1, 2, 3, 4, 5, 7: inverseRaw = targetOrientationRaw
    case 6: inverseRaw = 8
    case 8: inverseRaw = 6
    default: throw LabError.invalidImageOrientation
    }
    guard let colorSpace = canonical.colorSpace else {
        throw LabError.unsupportedImageColorModel
    }
    let source = CIImage(cgImage: canonical, options: [.colorSpace: colorSpace])
    let inverse = source.oriented(forExifOrientation: Int32(inverseRaw))
    let extent = inverse.extent.integral
    guard let image = context.createCGImage(
        inverse,
        from: extent,
        format: .RGBA8,
        colorSpace: colorSpace
    ) else { throw LabError.imageLoadFailed("inverse orientation render") }
    return image
}

private func colorConvertedImage(
    _ image: CGImage,
    colorSpace: CGColorSpace,
    context: CIContext
) throws -> CGImage {
    guard let sourceColorSpace = image.colorSpace else {
        throw LabError.unsupportedImageColorModel
    }
    let source = CIImage(cgImage: image, options: [.colorSpace: sourceColorSpace])
    guard let converted = context.createCGImage(
        source,
        from: source.extent.integral,
        format: .RGBA8,
        colorSpace: colorSpace
    ) else { throw LabError.imageLoadFailed("color-space render") }
    return converted
}

private func applyTransparentBorder(to raster: inout Raster) {
    let border = max(2, min(raster.width, raster.height) / 18)
    for y in 0..<raster.height {
        for x in 0..<raster.width where x < border || x >= raster.width - border || y < border || y >= raster.height - border {
            let offset = raster.offset(x: x, y: y)
            raster.pixels[offset] = 0
            raster.pixels[offset + 1] = 0
            raster.pixels[offset + 2] = 0
            raster.pixels[offset + 3] = 0
        }
    }
}

private func makeGrayTestImage() throws -> CGImage {
    let bytes = Data([0, 85, 170, 255]) as CFData
    guard let provider = CGDataProvider(data: bytes),
          let image = CGImage(
              width: 2,
              height: 2,
              bitsPerComponent: 8,
              bitsPerPixel: 8,
              bytesPerRow: 2,
              space: CGColorSpaceCreateDeviceGray(),
              bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
              provider: provider,
              decode: nil,
              shouldInterpolate: false,
              intent: .defaultIntent
          )
    else { throw LabError.imageLoadFailed("gray test image") }
    return image
}

private func localRetouchEvidence(_ image: CGImage) throws -> LocalRetouchEvidence {
    let input = try Raster(cgImage: image)
    let detection = try detectAnchors(cgImage: image, width: input.width, height: input.height)
    return try localRetouchEvidence(input, detection: detection)
}

private func localRetouchEvidence(
    _ image: CGImage,
    fixedAnchors: FaceAnchors
) throws -> LocalRetouchEvidence {
    let input = try Raster(cgImage: image)
    return try localRetouchEvidence(
        input,
        detection: DetectionResult(anchors: fixedAnchors, faceCount: 1)
    )
}

private func localRetouchEvidence(
    _ input: Raster,
    detection: DetectionResult
) throws -> LocalRetouchEvidence {
    let teeth = try adaptiveTeethSelection(input, anchors: detection.anchors)
    let sclera = try guardedScleraPair(input, anchors: detection.anchors)
    let composition = composeLocalRetouch(
        input,
        teethMask: teeth.adaptive,
        scleraMask: sclera.combinedMask
    )
    return LocalRetouchEvidence(
        input: input,
        detection: detection,
        teethMask: teeth.adaptive,
        scleraMask: sclera.combinedMask,
        output: composition.output,
        unionMask: composition.unionMask
    )
}

private func maximumRGBChannelDelta(_ first: Raster, _ second: Raster) -> Int {
    guard first.width == second.width,
          first.height == second.height,
          first.pixels.count == second.pixels.count
    else { return 255 }
    var maximum = 0
    for index in 0..<(first.width * first.height) {
        let offset = index * 4
        for channel in 0..<3 {
            maximum = max(
                maximum,
                abs(Int(first.pixels[offset + channel]) - Int(second.pixels[offset + channel]))
            )
        }
    }
    return maximum
}

private func alphaMismatchCount(_ first: Raster, _ second: Raster) -> Int {
    guard first.width == second.width,
          first.height == second.height,
          first.pixels.count == second.pixels.count
    else { return max(first.width * first.height, second.width * second.height) }
    var count = 0
    for index in 0..<(first.width * first.height) where first.pixels[index * 4 + 3] != second.pixels[index * 4 + 3] {
        count += 1
    }
    return count
}

private func maskTopologyMismatchCount(
    _ first: [Float],
    _ second: [Float],
    threshold: Float
) -> Int {
    guard first.count == second.count else { return max(first.count, second.count) }
    var count = 0
    for index in first.indices where (first[index] > threshold) != (second[index] > threshold) {
        count += 1
    }
    return count
}

private func maximumAnchorDelta(_ first: FaceAnchors, _ second: FaceAnchors) -> Double {
    let firstPoints = first.leftEye + first.rightEye + first.leftBrow + first.rightBrow
        + first.innerLips + first.outerLips + [first.leftPupil, first.rightPupil].compactMap { $0 }
    let secondPoints = second.leftEye + second.rightEye + second.leftBrow + second.rightBrow
        + second.innerLips + second.outerLips + [second.leftPupil, second.rightPupil].compactMap { $0 }
    guard firstPoints.count == secondPoints.count else { return 1_000_000 }
    return zip(firstPoints, secondPoints).map { firstPoint, secondPoint in
        hypot(firstPoint.x - secondPoint.x, firstPoint.y - secondPoint.y)
    }.max() ?? 0
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
            innerLips: points(landmarks.innerLips),
            outerLips: points(landmarks.outerLips)
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

private func adaptiveTeethMask(
    _ input: Raster,
    innerLips: [Point],
    candidateRegion region: [Float],
    fixedSeedMask: [Float]
) throws -> [Float] {
    let regionIndices = region.indices.filter { region[$0] > 0.5 }
    let seedIndices = fixedSeedMask.indices.filter { fixedSeedMask[$0] > 0.15 && region[$0] > 0.5 }
    guard regionIndices.count >= 12, seedIndices.count >= 2 else {
        return [Float](repeating: 0, count: region.count)
    }

    let lipWidth = innerLips.map(\.x).max()! - innerLips.map(\.x).min()!
    let lipHeight = innerLips.map(\.y).max()! - innerLips.map(\.y).min()!
    guard lipWidth >= 4, lipHeight / lipWidth >= 0.07 else {
        return [Float](repeating: 0, count: region.count)
    }

    var regionLuminance: [Float] = []
    var seedLuminance: [Float] = []
    var seedSaturation: [Float] = []
    regionLuminance.reserveCapacity(regionIndices.count)
    seedLuminance.reserveCapacity(seedIndices.count)
    seedSaturation.reserveCapacity(seedIndices.count)
    for index in regionIndices {
        let color = pixelFeatures(input, index: index)
        regionLuminance.append(color.light)
    }
    for index in seedIndices {
        let color = pixelFeatures(input, index: index)
        seedLuminance.append(color.light)
        seedSaturation.append(color.saturation)
    }

    let split = otsuThreshold(regionLuminance)
    let seedLow = percentile(seedLuminance, fraction: 0.10)
    let seedQuarter = percentile(seedLuminance, fraction: 0.25)
    let seedSaturationHigh = percentile(seedSaturation, fraction: 0.90)
    let candidateLuminance = max(0.18, min(split, seedLow) - 0.14)
    let candidateSaturation = min(0.62, max(0.32, seedSaturationHigh + 0.16))

    var candidate = [Bool](repeating: false, count: region.count)
    var score = [Float](repeating: 0, count: region.count)
    for index in regionIndices {
        let color = pixelFeatures(input, index: index)
        let redGreen = color.red - color.green
        let redBlue = color.red - color.blue
        guard color.light >= candidateLuminance,
              color.saturation <= candidateSaturation + 0.18,
              redGreen <= 0.24,
              redBlue <= 0.46
        else { continue }
        let brightness = smoothstep(candidateLuminance, max(candidateLuminance + 0.08, seedQuarter), color.light)
        let neutrality = 1 - smoothstep(candidateSaturation, min(0.90, candidateSaturation + 0.22), color.saturation)
        let redBalance = 1 - smoothstep(0.16, 0.34, redGreen)
        let blueBalance = 1 - smoothstep(0.24, 0.46, redBlue)
        let localScore = clamp(brightness * neutrality * redBalance * blueBalance)
        score[index] = localScore
        candidate[index] = localScore > 0.035
    }
    for index in seedIndices {
        candidate[index] = true
        score[index] = max(score[index], fixedSeedMask[index])
    }

    var connected = [Bool](repeating: false, count: region.count)
    var queue = seedIndices
    for index in seedIndices { connected[index] = true }
    var cursor = 0
    while cursor < queue.count {
        let index = queue[cursor]
        cursor += 1
        let x = index % input.width
        let y = index / input.width
        for dy in -1...1 {
            for dx in -1...1 where dx != 0 || dy != 0 {
                let nextX = x + dx
                let nextY = y + dy
                guard nextX >= 0, nextX < input.width, nextY >= 0, nextY < input.height else { continue }
                let next = nextY * input.width + nextX
                if candidate[next], !connected[next] {
                    connected[next] = true
                    queue.append(next)
                }
            }
        }
    }

    var adaptive = [Float](repeating: 0, count: region.count)
    for index in regionIndices where connected[index] {
        adaptive[index] = max(fixedSeedMask[index], score[index] * 0.90)
    }
    let blurred = constrainMask(
        boxBlur(adaptive, width: input.width, height: input.height, radius: 1),
        to: region
    )
    let fixedStrong = fixedSeedMask.lazy.filter { $0 > 0.15 }.count
    let adaptiveStrong = blurred.lazy.filter { $0 > 0.15 }.count
    let areaRatio = Double(adaptiveStrong) / Double(regionIndices.count)
    guard adaptiveStrong >= fixedStrong, areaRatio >= 0.015, areaRatio <= 0.94 else {
        return [Float](repeating: 0, count: region.count)
    }
    return zip(blurred, fixedSeedMask).map { clamp(max($0, $1)) }
}

private func adaptiveTeethSelection(
    _ input: Raster,
    anchors: FaceAnchors
) throws -> (fixed: [Float], adaptive: [Float]) {
    let empty = [Float](repeating: 0, count: input.width * input.height)
    guard anchors.innerLips.count >= 3, anchors.outerLips.count >= 3 else {
        return (empty, empty)
    }
    let hardRegion = try polygonMask(
        width: input.width,
        height: input.height,
        points: anchors.innerLips,
        featherRadius: 0
    )
    let candidateRegion = try adaptiveMouthCandidateRegion(
        width: input.width,
        height: input.height,
        innerLips: anchors.innerLips,
        outerLips: anchors.outerLips
    )
    let fixedRaw = try heuristicTeethMask(input, innerLips: anchors.innerLips)
    let fixed = constrainMask(fixedRaw, to: hardRegion)
    let adaptive = try adaptiveTeethMask(
        input,
        innerLips: anchors.innerLips,
        candidateRegion: candidateRegion,
        fixedSeedMask: fixed
    )
    return (fixed, adaptive)
}

private func adaptiveMouthCandidateRegion(
    width: Int,
    height: Int,
    innerLips: [Point],
    outerLips: [Point]
) throws -> [Float] {
    guard innerLips.count >= 3, outerLips.count >= 3 else {
        throw LabError.missingSupport("inner and outer lips")
    }
    var region = try polygonMask(width: width, height: height, points: outerLips, featherRadius: 0)
    let innerMinY = innerLips.map(\.y).min()!
    let innerMaxY = innerLips.map(\.y).max()!
    let apertureHeight = innerMaxY - innerMinY
    let upperInset = max(1, apertureHeight * 0.05)
    let lowerMargin = max(1, apertureHeight * 0.10)
    // Vision's upper inner-lip edge is the safest ceiling available to this
    // mechanics-only provider. A symmetric extension admitted a thin strip of
    // upper lip on portrait_002, so preserve lateral/lower coverage without
    // searching above the aperture.
    let minimumY = innerMinY + upperInset
    let maximumY = innerMaxY + lowerMargin
    for index in region.indices where region[index] > 0 {
        let y = Double(index / width) + 0.5
        if y < minimumY || y > maximumY {
            region[index] = 0
        }
    }
    return region
}

private func constrainMask(_ mask: [Float], to region: [Float]) -> [Float] {
    zip(mask, region).map { clamp($0 * $1) }
}

private func compareMasks(
    _ fixed: [Float],
    adaptive: [Float],
    threshold: Float
) -> (added: Int, dropped: Int, intersection: Int, union: Int) {
    var added = 0
    var dropped = 0
    var intersection = 0
    var union = 0
    for index in fixed.indices {
        let inFixed = fixed[index] > threshold
        let inAdaptive = adaptive[index] > threshold
        if inAdaptive && !inFixed { added += 1 }
        if inFixed && !inAdaptive { dropped += 1 }
        if inFixed && inAdaptive { intersection += 1 }
        if inFixed || inAdaptive { union += 1 }
    }
    return (added, dropped, intersection, union)
}

private func pixelFeatures(
    _ input: Raster,
    index: Int
) -> (red: Float, green: Float, blue: Float, light: Float, saturation: Float) {
    let offset = index * 4
    let red = Float(input.pixels[offset]) / 255
    let green = Float(input.pixels[offset + 1]) / 255
    let blue = Float(input.pixels[offset + 2]) / 255
    let maximum = max(red, max(green, blue))
    let minimum = min(red, min(green, blue))
    let saturation = maximum > 0.001 ? (maximum - minimum) / maximum : 0
    return (red, green, blue, luminance(red, green, blue), saturation)
}

private func percentile(_ values: [Float], fraction: Double) -> Float {
    guard !values.isEmpty else { return 0 }
    let sorted = values.sorted()
    let bounded = min(1, max(0, fraction))
    let index = Int((Double(sorted.count - 1) * bounded).rounded())
    return sorted[index]
}

private func otsuThreshold(_ values: [Float], bins: Int = 128) -> Float {
    guard values.count > 1, bins > 1 else { return values.first ?? 0 }
    var histogram = [Int](repeating: 0, count: bins)
    for value in values {
        let bin = min(bins - 1, max(0, Int(clamp(value) * Float(bins - 1))))
        histogram[bin] += 1
    }
    let total = Double(values.count)
    let weightedTotal = histogram.enumerated().reduce(0.0) { partial, entry in
        partial + Double(entry.offset * entry.element)
    }
    var backgroundWeight = 0.0
    var backgroundSum = 0.0
    var bestVariance = -1.0
    var bestBin = 0
    for bin in histogram.indices {
        backgroundWeight += Double(histogram[bin])
        if backgroundWeight == 0 { continue }
        let foregroundWeight = total - backgroundWeight
        if foregroundWeight == 0 { break }
        backgroundSum += Double(bin * histogram[bin])
        let backgroundMean = backgroundSum / backgroundWeight
        let foregroundMean = (weightedTotal - backgroundSum) / foregroundWeight
        let difference = backgroundMean - foregroundMean
        let variance = backgroundWeight * foregroundWeight * difference * difference
        if variance > bestVariance {
            bestVariance = variance
            bestBin = bin
        }
    }
    return Float(bestBin) / Float(bins - 1)
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

private struct ScleraColorMaskResult {
    let mask: [Float]
    let failedClosed: Bool
}

private struct ScleraColorAccumulator {
    var scenarioCount = 0
    var failedClosedEyeScenarioCount = 0
    var nativeMaskPixelsTotal = 0
    var nativeChangedPixelsTotal = 0
    var nativeProtectedChangeScenarioCount = 0
    var nativeProtectedChangedPixelsTotal = 0
    var nativeHighlightChangeScenarioCount = 0
    var nativeHighlightChangedPixelsTotal = 0
    var challengeMaskPixelsTotal = 0
    var challengeChangedPixelsTotal = 0
    var challengeProtectedChangeScenarioCount = 0
    var challengeProtectedChangedPixelsTotal = 0
    var challengeHighlightChangeScenarioCount = 0
    var challengeHighlightChangedPixelsTotal = 0

    mutating func recordNative(
        maskPixels: Int,
        changedPixels: Int,
        protectedChangedPixels: Int,
        highlightChangedPixels: Int,
        failedClosed: Bool
    ) {
        scenarioCount += 1
        if failedClosed { failedClosedEyeScenarioCount += 1 }
        nativeMaskPixelsTotal += maskPixels
        nativeChangedPixelsTotal += changedPixels
        if protectedChangedPixels > 0 { nativeProtectedChangeScenarioCount += 1 }
        nativeProtectedChangedPixelsTotal += protectedChangedPixels
        if highlightChangedPixels > 0 { nativeHighlightChangeScenarioCount += 1 }
        nativeHighlightChangedPixelsTotal += highlightChangedPixels
    }

    mutating func recordChallenge(
        maskPixels: Int,
        changedPixels: Int,
        protectedChangedPixels: Int,
        highlightChangedPixels: Int
    ) {
        challengeMaskPixelsTotal += maskPixels
        challengeChangedPixelsTotal += changedPixels
        if protectedChangedPixels > 0 { challengeProtectedChangeScenarioCount += 1 }
        challengeProtectedChangedPixelsTotal += protectedChangedPixels
        if highlightChangedPixels > 0 { challengeHighlightChangeScenarioCount += 1 }
        challengeHighlightChangedPixelsTotal += highlightChangedPixels
    }

    func metrics(
        baselineMeasurement: Measurement,
        baselineProtectedChangedPixels: Int,
        baselineHighlightChangedPixels: Int,
        baselineMaskPixelsByEye: [String: Int]
    ) -> ScleraColorVariantMetrics {
        ScleraColorVariantMetrics(
            scenarioCount: scenarioCount,
            failedClosedEyeScenarioCount: failedClosedEyeScenarioCount,
            nativeMaskPixelsTotal: nativeMaskPixelsTotal,
            nativeChangedPixelsTotal: nativeChangedPixelsTotal,
            nativeProtectedChangeScenarioCount: nativeProtectedChangeScenarioCount,
            nativeProtectedChangedPixelsTotal: nativeProtectedChangedPixelsTotal,
            nativeHighlightChangeScenarioCount: nativeHighlightChangeScenarioCount,
            nativeHighlightChangedPixelsTotal: nativeHighlightChangedPixelsTotal,
            challengeMaskPixelsTotal: challengeMaskPixelsTotal,
            challengeChangedPixelsTotal: challengeChangedPixelsTotal,
            challengeProtectedChangeScenarioCount: challengeProtectedChangeScenarioCount,
            challengeProtectedChangedPixelsTotal: challengeProtectedChangedPixelsTotal,
            challengeHighlightChangeScenarioCount: challengeHighlightChangeScenarioCount,
            challengeHighlightChangedPixelsTotal: challengeHighlightChangedPixelsTotal,
            baselineNativeMaskPixels: baselineMeasurement.maskPixels,
            baselineNativeChangedPixels: baselineMeasurement.changedPixels,
            baselineNativeChangedOutsideMask: baselineMeasurement.changedOutsideMask,
            baselineNativeProtectedChangedPixels: baselineProtectedChangedPixels,
            baselineNativeHighlightChangedPixels: baselineHighlightChangedPixels,
            baselineNativeMaskPixelsByEye: baselineMaskPixelsByEye
        )
    }
}

private struct ScleraEyeSupport {
    let label: String
    let eye: [Point]
    let pupil: Point
    let eyeWidth: Double
    let eyeHeight: Double
    let protectedMask: [Float]
    let highlightMask: [Float]
}

private func scleraColorScore(_ input: Raster, index: Int) -> Float {
    let color = pixelFeatures(input, index: index)
    let scleraLikelihood = smoothstep(0.22, 0.68, color.light)
        * (1 - smoothstep(0.48, 0.85, color.saturation))
    let redness = max(0, color.red - 0.83 * color.green - 0.17 * color.blue)
    return clamp(scleraLikelihood * smoothstep(0.008, 0.14, redness))
}

private func legacyScleraColorMask(
    _ input: Raster,
    eye: [Point],
    pupil: Point?
) throws -> ScleraColorMaskResult {
    guard eye.count >= 4, let pupil else {
        return ScleraColorMaskResult(
            mask: [Float](repeating: 0, count: input.width * input.height),
            failedClosed: true
        )
    }
    let eyeWidth = eye.map(\.x).max()! - eye.map(\.x).min()!
    let eyeHeight = eye.map(\.y).max()! - eye.map(\.y).min()!
    guard eyeWidth >= 2, eyeHeight > 0 else {
        return ScleraColorMaskResult(
            mask: [Float](repeating: 0, count: input.width * input.height),
            failedClosed: true
        )
    }
    let aperture = try polygonMask(width: input.width, height: input.height, points: eye, featherRadius: 1)
    let irisRadius = max(eyeHeight * 0.58, eyeWidth * 0.16)
    var scored = [Float](repeating: 0, count: aperture.count)
    for index in aperture.indices where aperture[index] > 0.02 {
        let x = Double(index % input.width) + 0.5
        let y = Double(index / input.width) + 0.5
        guard hypot(x - pupil.x, y - pupil.y) > irisRadius else { continue }
        let color = pixelFeatures(input, index: index)
        let isSpecular = color.red > 0.86 && color.green > 0.86 && color.blue > 0.86
        guard !isSpecular else { continue }
        scored[index] = aperture[index] * scleraColorScore(input, index: index)
    }
    return ScleraColorMaskResult(
        mask: boxBlur(scored, width: input.width, height: input.height, radius: 1).map { clamp($0) },
        failedClosed: false
    )
}

private func guardedScleraColorMask(
    _ input: Raster,
    eye: [Point],
    pupil: Point?,
    minimumAspectRatio: Double,
    irisInflationWidthFraction: Double
) throws -> ScleraColorMaskResult {
    guard let pupil else {
        return ScleraColorMaskResult(
            mask: [Float](repeating: 0, count: input.width * input.height),
            failedClosed: true
        )
    }
    let envelope = try geometricScleraEnvelope(
        input,
        eye: eye,
        pupil: pupil,
        minimumAspectRatio: minimumAspectRatio,
        irisInflationWidthFraction: irisInflationWidthFraction
    )
    guard !envelope.failedClosed else {
        return ScleraColorMaskResult(mask: envelope.mask, failedClosed: true)
    }
    var scored = [Float](repeating: 0, count: envelope.mask.count)
    for index in envelope.mask.indices where envelope.mask[index] > 0.5 {
        scored[index] = scleraColorScore(input, index: index)
    }
    let feathered = boxBlur(scored, width: input.width, height: input.height, radius: 1)
    return ScleraColorMaskResult(
        mask: constrainMask(feathered, to: envelope.mask),
        failedClosed: false
    )
}

private func guardedScleraPair(
    _ input: Raster,
    anchors: FaceAnchors,
    rejectLeft: Bool = false,
    rejectRight: Bool = false
) throws -> GuardedScleraPair {
    let left = try guardedScleraColorMask(
        input,
        eye: anchors.leftEye,
        pupil: rejectLeft ? nil : anchors.leftPupil,
        minimumAspectRatio: 0.30,
        irisInflationWidthFraction: 0.14
    )
    let right = try guardedScleraColorMask(
        input,
        eye: anchors.rightEye,
        pupil: rejectRight ? nil : anchors.rightPupil,
        minimumAspectRatio: 0.30,
        irisInflationWidthFraction: 0.14
    )
    return GuardedScleraPair(
        leftMask: left.mask,
        rightMask: right.mask,
        combinedMask: zip(left.mask, right.mask).map { max($0, $1) },
        leftFailedClosed: left.failedClosed,
        rightFailedClosed: right.failedClosed
    )
}

private func scleraProtectionMasks(
    _ input: Raster,
    anchors: FaceAnchors
) throws -> (protected: [Float], highlights: [Float]) {
    var protected = [Float](repeating: 0, count: input.width * input.height)
    var highlights = protected
    let supports = [
        (anchors.leftEye, anchors.leftPupil),
        (anchors.rightEye, anchors.rightPupil),
    ]
    for (eye, optionalPupil) in supports {
        guard eye.count >= 4, let pupil = optionalPupil else { continue }
        let eyeWidth = eye.map(\.x).max()! - eye.map(\.x).min()!
        let eyeHeight = eye.map(\.y).max()! - eye.map(\.y).min()!
        guard eyeWidth >= 2, eyeHeight >= 1 else { continue }
        let aperture = try polygonMask(
            width: input.width,
            height: input.height,
            points: eye,
            featherRadius: 0
        )
        let eyeProtected = circularMaskWithinRegion(
            width: input.width,
            height: input.height,
            center: pupil,
            radius: max(eyeHeight * 0.58, eyeWidth * 0.16),
            region: aperture
        )
        protected = zip(protected, eyeProtected).map { max($0, $1) }
        highlights = zip(highlights, specularMask(input, region: aperture)).map { max($0, $1) }
    }
    return (protected, highlights)
}

private func scleraColorIntegrationStudy(
    _ input: Raster,
    anchors: FaceAnchors,
    horizontalShifts: [Double],
    verticalShifts: [Double],
    verticalScales: [Double],
    guardedMinimumAspectRatio: Double,
    guardedInflationFraction: Double
) throws -> ScleraColorIntegrationStudy {
    let rawPairs = [
        ("left", anchors.leftEye, anchors.leftPupil),
        ("right", anchors.rightEye, anchors.rightPupil),
    ]
    var supports: [ScleraEyeSupport] = []
    var protectedMask = [Float](repeating: 0, count: input.width * input.height)
    var highlightMask = [Float](repeating: 0, count: input.width * input.height)
    for (label, eye, optionalPupil) in rawPairs {
        guard eye.count >= 4, let pupil = optionalPupil else { continue }
        let eyeWidth = eye.map(\.x).max()! - eye.map(\.x).min()!
        let eyeHeight = eye.map(\.y).max()! - eye.map(\.y).min()!
        guard eyeWidth >= 2, eyeHeight >= 1 else { continue }
        let aperture = try polygonMask(width: input.width, height: input.height, points: eye, featherRadius: 0)
        let radius = max(eyeHeight * 0.58, eyeWidth * 0.16)
        let eyeProtected = circularMaskWithinRegion(
            width: input.width,
            height: input.height,
            center: pupil,
            radius: radius,
            region: aperture
        )
        let eyeHighlights = specularMask(input, region: aperture)
        protectedMask = zip(protectedMask, eyeProtected).map { max($0, $1) }
        highlightMask = zip(highlightMask, eyeHighlights).map { max($0, $1) }
        supports.append(
            ScleraEyeSupport(
                label: label,
                eye: eye,
                pupil: pupil,
                eyeWidth: eyeWidth,
                eyeHeight: eyeHeight,
                protectedMask: eyeProtected,
                highlightMask: eyeHighlights
            )
        )
    }
    guard !supports.isEmpty else { throw LabError.missingSupport("eye contour and pupil") }

    let challengeInput = scleraColorAdversarialInput(
        input,
        protectedMask: protectedMask,
        highlightMask: highlightMask
    )
    var legacyAccumulator = ScleraColorAccumulator()
    var guardedAccumulator = ScleraColorAccumulator()
    var legacyBaselineMask = [Float](repeating: 0, count: input.width * input.height)
    var guardedBaselineMask = [Float](repeating: 0, count: input.width * input.height)
    var legacyChallengeBaselineMask = [Float](repeating: 0, count: input.width * input.height)
    var guardedChallengeBaselineMask = [Float](repeating: 0, count: input.width * input.height)
    var legacyBaselineByEye: [String: Int] = [:]
    var guardedBaselineByEye: [String: Int] = [:]
    var legacyChallengeLeakCounts = [Int](repeating: 0, count: input.width * input.height)
    var guardedChallengeLeakCounts = [Int](repeating: 0, count: input.width * input.height)
    var ignoredLeakCounts = [Int](repeating: 0, count: input.width * input.height)
    var guardedFailedClosedByVerticalScale: [String: Int] = [:]

    for support in supports {
        for verticalScale in verticalScales {
            let perturbedEye = verticallyScaledEye(support.eye, scale: verticalScale)
            for verticalShift in verticalShifts {
                for horizontalShift in horizontalShifts {
                    let perturbedPupil = Point(
                        x: support.pupil.x + horizontalShift * support.eyeWidth,
                        y: support.pupil.y + verticalShift * support.eyeHeight
                    )
                    let legacyNative = try legacyScleraColorMask(input, eye: perturbedEye, pupil: perturbedPupil)
                    let guardedNative = try guardedScleraColorMask(
                        input,
                        eye: perturbedEye,
                        pupil: perturbedPupil,
                        minimumAspectRatio: guardedMinimumAspectRatio,
                        irisInflationWidthFraction: guardedInflationFraction
                    )
                    if guardedNative.failedClosed {
                        guardedFailedClosedByVerticalScale[String(format: "%.2f", verticalScale), default: 0] += 1
                    }
                    let legacyNativeMeasurement = assessScleraRednessTransform(
                        input,
                        mask: legacyNative.mask,
                        protectedMask: support.protectedMask,
                        highlightMask: support.highlightMask,
                        accumulateLeakCounts: false,
                        leakCounts: &ignoredLeakCounts
                    )
                    let guardedNativeMeasurement = assessScleraRednessTransform(
                        input,
                        mask: guardedNative.mask,
                        protectedMask: support.protectedMask,
                        highlightMask: support.highlightMask,
                        accumulateLeakCounts: false,
                        leakCounts: &ignoredLeakCounts
                    )
                    legacyAccumulator.recordNative(
                        maskPixels: legacyNativeMeasurement.maskPixels,
                        changedPixels: legacyNativeMeasurement.changedPixels,
                        protectedChangedPixels: legacyNativeMeasurement.protectedChangedPixels,
                        highlightChangedPixels: legacyNativeMeasurement.highlightChangedPixels,
                        failedClosed: legacyNative.failedClosed
                    )
                    guardedAccumulator.recordNative(
                        maskPixels: guardedNativeMeasurement.maskPixels,
                        changedPixels: guardedNativeMeasurement.changedPixels,
                        protectedChangedPixels: guardedNativeMeasurement.protectedChangedPixels,
                        highlightChangedPixels: guardedNativeMeasurement.highlightChangedPixels,
                        failedClosed: guardedNative.failedClosed
                    )

                    let legacyChallenge = try legacyScleraColorMask(
                        challengeInput,
                        eye: perturbedEye,
                        pupil: perturbedPupil
                    )
                    let guardedChallenge = try guardedScleraColorMask(
                        challengeInput,
                        eye: perturbedEye,
                        pupil: perturbedPupil,
                        minimumAspectRatio: guardedMinimumAspectRatio,
                        irisInflationWidthFraction: guardedInflationFraction
                    )
                    let legacyChallengeMeasurement = assessScleraRednessTransform(
                        challengeInput,
                        mask: legacyChallenge.mask,
                        protectedMask: support.protectedMask,
                        highlightMask: support.highlightMask,
                        accumulateLeakCounts: true,
                        leakCounts: &legacyChallengeLeakCounts
                    )
                    let guardedChallengeMeasurement = assessScleraRednessTransform(
                        challengeInput,
                        mask: guardedChallenge.mask,
                        protectedMask: support.protectedMask,
                        highlightMask: support.highlightMask,
                        accumulateLeakCounts: true,
                        leakCounts: &guardedChallengeLeakCounts
                    )
                    legacyAccumulator.recordChallenge(
                        maskPixels: legacyChallengeMeasurement.maskPixels,
                        changedPixels: legacyChallengeMeasurement.changedPixels,
                        protectedChangedPixels: legacyChallengeMeasurement.protectedChangedPixels,
                        highlightChangedPixels: legacyChallengeMeasurement.highlightChangedPixels
                    )
                    guardedAccumulator.recordChallenge(
                        maskPixels: guardedChallengeMeasurement.maskPixels,
                        changedPixels: guardedChallengeMeasurement.changedPixels,
                        protectedChangedPixels: guardedChallengeMeasurement.protectedChangedPixels,
                        highlightChangedPixels: guardedChallengeMeasurement.highlightChangedPixels
                    )

                    if horizontalShift == 0, verticalShift == 0, verticalScale == 1 {
                        legacyBaselineMask = zip(legacyBaselineMask, legacyNative.mask).map { max($0, $1) }
                        guardedBaselineMask = zip(guardedBaselineMask, guardedNative.mask).map { max($0, $1) }
                        legacyChallengeBaselineMask = zip(legacyChallengeBaselineMask, legacyChallenge.mask).map { max($0, $1) }
                        guardedChallengeBaselineMask = zip(guardedChallengeBaselineMask, guardedChallenge.mask).map { max($0, $1) }
                        legacyBaselineByEye[support.label] = legacyNativeMeasurement.maskPixels
                        guardedBaselineByEye[support.label] = guardedNativeMeasurement.maskPixels
                    }
                }
            }
        }
    }

    let legacyBaselineOutput = reduceScleraRedness(input, mask: legacyBaselineMask, strength: 0.72)
    let guardedBaselineOutput = reduceScleraRedness(input, mask: guardedBaselineMask, strength: 0.72)
    let legacyChallengeBaselineOutput = reduceScleraRedness(
        challengeInput,
        mask: legacyChallengeBaselineMask,
        strength: 0.72
    )
    let guardedChallengeBaselineOutput = reduceScleraRedness(
        challengeInput,
        mask: guardedChallengeBaselineMask,
        strength: 0.72
    )
    let legacyBaselineMeasurement = measure(before: input, after: legacyBaselineOutput, mask: legacyBaselineMask)
    let guardedBaselineMeasurement = measure(before: input, after: guardedBaselineOutput, mask: guardedBaselineMask)

    return ScleraColorIntegrationStudy(
        legacy: legacyAccumulator.metrics(
            baselineMeasurement: legacyBaselineMeasurement,
            baselineProtectedChangedPixels: changedPixelCount(before: input, after: legacyBaselineOutput, within: protectedMask),
            baselineHighlightChangedPixels: changedPixelCount(before: input, after: legacyBaselineOutput, within: highlightMask),
            baselineMaskPixelsByEye: legacyBaselineByEye
        ),
        guarded: guardedAccumulator.metrics(
            baselineMeasurement: guardedBaselineMeasurement,
            baselineProtectedChangedPixels: changedPixelCount(before: input, after: guardedBaselineOutput, within: protectedMask),
            baselineHighlightChangedPixels: changedPixelCount(before: input, after: guardedBaselineOutput, within: highlightMask),
            baselineMaskPixelsByEye: guardedBaselineByEye
        ),
        legacyBaselineMask: legacyBaselineMask,
        guardedBaselineMask: guardedBaselineMask,
        legacyBaselineOutput: legacyBaselineOutput,
        guardedBaselineOutput: guardedBaselineOutput,
        challengeInput: challengeInput,
        legacyChallengeBaselineMask: legacyChallengeBaselineMask,
        guardedChallengeBaselineMask: guardedChallengeBaselineMask,
        legacyChallengeBaselineOutput: legacyChallengeBaselineOutput,
        guardedChallengeBaselineOutput: guardedChallengeBaselineOutput,
        protectedMask: protectedMask,
        highlightMask: highlightMask,
        legacyChallengeLeakCounts: legacyChallengeLeakCounts,
        guardedChallengeLeakCounts: guardedChallengeLeakCounts,
        guardedFailedClosedByVerticalScale: guardedFailedClosedByVerticalScale,
        scenarioCount: legacyAccumulator.scenarioCount
    )
}

private func scleraColorAdversarialInput(
    _ input: Raster,
    protectedMask: [Float],
    highlightMask: [Float]
) -> Raster {
    var output = input
    for index in protectedMask.indices where protectedMask[index] > 0.5 && highlightMask[index] <= 0.5 {
        let x = index % input.width
        let y = index / input.width
        output.setRGB(x: x, y: y, red: 0.82, green: 0.55, blue: 0.55)
    }
    return output
}

private func changedPixelCount(before: Raster, after: Raster, within region: [Float]) -> Int {
    var count = 0
    for index in region.indices where region[index] > 0.5 {
        let offset = index * 4
        if (0..<3).contains(where: { before.pixels[offset + $0] != after.pixels[offset + $0] }) {
            count += 1
        }
    }
    return count
}

private struct ScleraTransformAssessment {
    let maskPixels: Int
    let changedPixels: Int
    let protectedChangedPixels: Int
    let highlightChangedPixels: Int
}

private func assessScleraRednessTransform(
    _ input: Raster,
    mask: [Float],
    protectedMask: [Float],
    highlightMask: [Float],
    accumulateLeakCounts: Bool,
    leakCounts: inout [Int]
) -> ScleraTransformAssessment {
    var maskPixels = 0
    var changedPixels = 0
    var protectedChangedPixels = 0
    var highlightChangedPixels = 0
    for index in mask.indices where mask[index] > 0.001 {
        maskPixels += 1
        let offset = index * 4
        let reduced = reducedScleraPixel(input, index: index, localMask: mask[index], strength: 0.72)
        let changed = input.pixels[offset] != reduced.0
            || input.pixels[offset + 1] != reduced.1
            || input.pixels[offset + 2] != reduced.2
        if changed {
            changedPixels += 1
            let protected = protectedMask[index] > 0.5
            let highlight = highlightMask[index] > 0.5
            if protected { protectedChangedPixels += 1 }
            if highlight { highlightChangedPixels += 1 }
            if accumulateLeakCounts, protected || highlight { leakCounts[index] += 1 }
        }
    }
    return ScleraTransformAssessment(
        maskPixels: maskPixels,
        changedPixels: changedPixels,
        protectedChangedPixels: protectedChangedPixels,
        highlightChangedPixels: highlightChangedPixels
    )
}

private struct ScleraEnvelopeResult {
    let mask: [Float]
    let failedClosed: Bool
}

private struct ScleraJitterAccumulator {
    var scenarioCount = 0
    var failedClosedScenarioCount = 0
    var irisLeakScenarioCount = 0
    var irisLeakPixelsTotal = 0
    var maximumIrisLeakPixels = 0
    var highlightLeakScenarioCount = 0
    var highlightLeakPixelsTotal = 0
    var eligiblePixelsTotal = 0
    var minimumEligiblePixels = Int.max
    var maximumEligiblePixels = 0

    mutating func record(eligible: Int, irisLeak: Int, highlightLeak: Int, failedClosed: Bool) {
        scenarioCount += 1
        if failedClosed { failedClosedScenarioCount += 1 }
        if irisLeak > 0 { irisLeakScenarioCount += 1 }
        irisLeakPixelsTotal += irisLeak
        maximumIrisLeakPixels = max(maximumIrisLeakPixels, irisLeak)
        if highlightLeak > 0 { highlightLeakScenarioCount += 1 }
        highlightLeakPixelsTotal += highlightLeak
        eligiblePixelsTotal += eligible
        minimumEligiblePixels = min(minimumEligiblePixels, eligible)
        maximumEligiblePixels = max(maximumEligiblePixels, eligible)
    }

    func metrics(baselineEligiblePixels: Int) -> ScleraJitterVariantMetrics {
        ScleraJitterVariantMetrics(
            scenarioCount: scenarioCount,
            failedClosedScenarioCount: failedClosedScenarioCount,
            irisLeakScenarioCount: irisLeakScenarioCount,
            irisLeakPixelsTotal: irisLeakPixelsTotal,
            maximumIrisLeakPixels: maximumIrisLeakPixels,
            highlightLeakScenarioCount: highlightLeakScenarioCount,
            highlightLeakPixelsTotal: highlightLeakPixelsTotal,
            eligiblePixelsTotal: eligiblePixelsTotal,
            meanEligiblePixels: scenarioCount > 0 ? Double(eligiblePixelsTotal) / Double(scenarioCount) : 0,
            minimumEligiblePixels: minimumEligiblePixels == Int.max ? 0 : minimumEligiblePixels,
            maximumEligiblePixels: maximumEligiblePixels,
            baselineEligiblePixels: baselineEligiblePixels
        )
    }
}

private func scleraJitterStudy(
    _ input: Raster,
    anchors: FaceAnchors,
    horizontalShifts: [Double],
    verticalShifts: [Double],
    verticalScales: [Double],
    guardedMinimumAspectRatio: Double,
    guardedInflationFraction: Double
) throws -> ScleraJitterStudy {
    let pairs = [
        (anchors.leftEye, anchors.leftPupil),
        (anchors.rightEye, anchors.rightPupil),
    ]
    var legacyAccumulator = ScleraJitterAccumulator()
    var guardedAccumulator = ScleraJitterAccumulator()
    var legacyLeakCounts = [Int](repeating: 0, count: input.width * input.height)
    var guardedLeakCounts = [Int](repeating: 0, count: input.width * input.height)
    var protectedMask = [Float](repeating: 0, count: input.width * input.height)
    var legacyBaselineMask = [Float](repeating: 0, count: input.width * input.height)
    var guardedBaselineMask = [Float](repeating: 0, count: input.width * input.height)
    var legacyBaselineEligible = 0
    var guardedBaselineEligible = 0
    var guardedFailedClosedByVerticalScale: [String: Int] = [:]

    for (eye, optionalPupil) in pairs {
        guard eye.count >= 4, let pupil = optionalPupil else {
            throw LabError.missingSupport("eye contour and pupil")
        }
        let eyeWidth = eye.map(\.x).max()! - eye.map(\.x).min()!
        let eyeHeight = eye.map(\.y).max()! - eye.map(\.y).min()!
        guard eyeWidth >= 2, eyeHeight >= 1 else {
            throw LabError.missingSupport("non-collapsed eye")
        }
        let originalAperture = try polygonMask(width: input.width, height: input.height, points: eye, featherRadius: 0)
        let originalRadius = max(eyeHeight * 0.58, eyeWidth * 0.16)
        let eyeProtectedMask = circularMaskWithinRegion(
            width: input.width,
            height: input.height,
            center: pupil,
            radius: originalRadius,
            region: originalAperture
        )
        let eyeHighlightMask = specularMask(input, region: originalAperture)
        protectedMask = zip(protectedMask, eyeProtectedMask).map { max($0, $1) }

        for verticalScale in verticalScales {
            let perturbedEye = verticallyScaledEye(eye, scale: verticalScale)
            for verticalShift in verticalShifts {
                for horizontalShift in horizontalShifts {
                    let perturbedPupil = Point(
                        x: pupil.x + horizontalShift * eyeWidth,
                        y: pupil.y + verticalShift * eyeHeight
                    )
                    let legacy = try geometricScleraEnvelope(
                        input,
                        eye: perturbedEye,
                        pupil: perturbedPupil,
                        minimumAspectRatio: nil,
                        irisInflationWidthFraction: 0
                    )
                    let guarded = try geometricScleraEnvelope(
                        input,
                        eye: perturbedEye,
                        pupil: perturbedPupil,
                        minimumAspectRatio: guardedMinimumAspectRatio,
                        irisInflationWidthFraction: guardedInflationFraction
                    )
                    if guarded.failedClosed {
                        let scaleKey = String(format: "%.2f", verticalScale)
                        guardedFailedClosedByVerticalScale[scaleKey, default: 0] += 1
                    }
                    let legacyCounts = assessScleraEnvelope(
                        legacy.mask,
                        protectedMask: eyeProtectedMask,
                        highlightMask: eyeHighlightMask,
                        leakCounts: &legacyLeakCounts
                    )
                    let guardedCounts = assessScleraEnvelope(
                        guarded.mask,
                        protectedMask: eyeProtectedMask,
                        highlightMask: eyeHighlightMask,
                        leakCounts: &guardedLeakCounts
                    )
                    legacyAccumulator.record(
                        eligible: legacyCounts.eligible,
                        irisLeak: legacyCounts.irisLeak,
                        highlightLeak: legacyCounts.highlightLeak,
                        failedClosed: legacy.failedClosed
                    )
                    guardedAccumulator.record(
                        eligible: guardedCounts.eligible,
                        irisLeak: guardedCounts.irisLeak,
                        highlightLeak: guardedCounts.highlightLeak,
                        failedClosed: guarded.failedClosed
                    )
                    if horizontalShift == 0, verticalShift == 0, verticalScale == 1 {
                        legacyBaselineEligible += legacyCounts.eligible
                        guardedBaselineEligible += guardedCounts.eligible
                        legacyBaselineMask = zip(legacyBaselineMask, legacy.mask).map { max($0, $1) }
                        guardedBaselineMask = zip(guardedBaselineMask, guarded.mask).map { max($0, $1) }
                    }
                }
            }
        }
    }
    return ScleraJitterStudy(
        legacy: legacyAccumulator.metrics(baselineEligiblePixels: legacyBaselineEligible),
        guarded: guardedAccumulator.metrics(baselineEligiblePixels: guardedBaselineEligible),
        legacyLeakCounts: legacyLeakCounts,
        guardedLeakCounts: guardedLeakCounts,
        protectedMask: protectedMask,
        legacyBaselineMask: legacyBaselineMask,
        guardedBaselineMask: guardedBaselineMask,
        guardedFailedClosedByVerticalScale: guardedFailedClosedByVerticalScale,
        scenarioCount: legacyAccumulator.scenarioCount
    )
}

private func verticallyScaledEye(_ eye: [Point], scale: Double) -> [Point] {
    let centerY = (eye.map(\.y).min()! + eye.map(\.y).max()!) / 2
    return eye.map { point in
        Point(x: point.x, y: centerY + (point.y - centerY) * scale)
    }
}

private func geometricScleraEnvelope(
    _ input: Raster,
    eye: [Point],
    pupil: Point,
    minimumAspectRatio: Double?,
    irisInflationWidthFraction: Double
) throws -> ScleraEnvelopeResult {
    guard eye.count >= 4 else {
        return ScleraEnvelopeResult(mask: [Float](repeating: 0, count: input.width * input.height), failedClosed: true)
    }
    let eyeWidth = eye.map(\.x).max()! - eye.map(\.x).min()!
    let eyeHeight = eye.map(\.y).max()! - eye.map(\.y).min()!
    guard eyeWidth >= 2, eyeHeight > 0 else {
        return ScleraEnvelopeResult(mask: [Float](repeating: 0, count: input.width * input.height), failedClosed: true)
    }
    if let minimumAspectRatio,
       eyeHeight / eyeWidth < minimumAspectRatio || !pointInPolygon(pupil, polygon: eye) {
        return ScleraEnvelopeResult(mask: [Float](repeating: 0, count: input.width * input.height), failedClosed: true)
    }
    let aperture = try polygonMask(width: input.width, height: input.height, points: eye, featherRadius: 0)
    let irisRadius = max(eyeHeight * 0.58, eyeWidth * 0.16) + eyeWidth * irisInflationWidthFraction
    var mask = [Float](repeating: 0, count: aperture.count)
    for index in aperture.indices where aperture[index] > 0.5 {
        let x = Double(index % input.width) + 0.5
        let y = Double(index / input.width) + 0.5
        let distance = hypot(x - pupil.x, y - pupil.y)
        guard distance > irisRadius else { continue }
        let color = pixelFeatures(input, index: index)
        let isSpecular = color.red > 0.86 && color.green > 0.86 && color.blue > 0.86
        if !isSpecular { mask[index] = 1 }
    }
    return ScleraEnvelopeResult(mask: mask, failedClosed: false)
}

private func circularMaskWithinRegion(
    width: Int,
    height: Int,
    center: Point,
    radius: Double,
    region: [Float]
) -> [Float] {
    var mask = [Float](repeating: 0, count: width * height)
    let radiusSquared = radius * radius
    for index in region.indices where region[index] > 0.5 {
        let x = Double(index % width) + 0.5
        let y = Double(index / width) + 0.5
        let dx = x - center.x
        let dy = y - center.y
        if dx * dx + dy * dy <= radiusSquared { mask[index] = 1 }
    }
    return mask
}

private func specularMask(_ input: Raster, region: [Float]) -> [Float] {
    var mask = [Float](repeating: 0, count: region.count)
    for index in region.indices where region[index] > 0.5 {
        let color = pixelFeatures(input, index: index)
        if color.red > 0.86 && color.green > 0.86 && color.blue > 0.86 {
            mask[index] = 1
        }
    }
    return mask
}

private func assessScleraEnvelope(
    _ mask: [Float],
    protectedMask: [Float],
    highlightMask: [Float],
    leakCounts: inout [Int]
) -> (eligible: Int, irisLeak: Int, highlightLeak: Int) {
    var eligible = 0
    var irisLeak = 0
    var highlightLeak = 0
    for index in mask.indices where mask[index] > 0.5 {
        eligible += 1
        if protectedMask[index] > 0.5 {
            irisLeak += 1
            leakCounts[index] += 1
        }
        if highlightMask[index] > 0.5 { highlightLeak += 1 }
    }
    return (eligible, irisLeak, highlightLeak)
}

private func whitenTeeth(_ input: Raster, mask: [Float], strength: Float) -> Raster {
    var output = input
    for index in mask.indices where mask[index] > 0.001 {
        let offset = index * 4
        let whitened = whitenedTeethPixel(input, index: index, localMask: mask[index], strength: strength)
        output.pixels[offset] = whitened.0
        output.pixels[offset + 1] = whitened.1
        output.pixels[offset + 2] = whitened.2
    }
    return output
}

private func whitenedTeethPixel(
    _ input: Raster,
    index: Int,
    localMask: Float,
    strength: Float
) -> (UInt8, UInt8, UInt8) {
    let offset = index * 4
    let red = Float(input.pixels[offset]) / 255
    let green = Float(input.pixels[offset + 1]) / 255
    let blue = Float(input.pixels[offset + 2]) / 255
    let originalLuminance = luminance(red, green, blue)
    let yellowExcess = max(0, (red + green) * 0.5 - blue)
    // A neutral/already-light tooth is a negative control for this transform.
    // The previous unconditional blue and luminance lifts changed those
    // pixels even when there was no yellow cast to correct.
    // Keep lightly warm enamel on the explicit no-op side of the gate, while
    // giving materially yellow teeth a visible but still bounded correction.
    let yellowCorrection = smoothstep(0.08, 0.14, yellowExcess)
    let local = localMask * strength * yellowCorrection
    guard local > 0.001 else {
        return (input.pixels[offset], input.pixels[offset + 1], input.pixels[offset + 2])
    }
    var nextRed = red + 0.018 * local
    var nextGreen = green + 0.018 * local
    var nextBlue = blue + yellowExcess * 1.05 * local
    let desiredLuminance = min(0.94, originalLuminance + 0.045 * local)
    let correction = desiredLuminance - luminance(nextRed, nextGreen, nextBlue)
    nextRed += correction
    nextGreen += correction
    nextBlue += correction
    return (byte(nextRed), byte(nextGreen), byte(nextBlue))
}

private func reduceScleraRedness(_ input: Raster, mask: [Float], strength: Float) -> Raster {
    var output = input
    for index in mask.indices where mask[index] > 0.001 {
        let offset = index * 4
        let reduced = reducedScleraPixel(input, index: index, localMask: mask[index], strength: strength)
        output.pixels[offset] = reduced.0
        output.pixels[offset + 1] = reduced.1
        output.pixels[offset + 2] = reduced.2
    }
    return output
}

private func reducedScleraPixel(
    _ input: Raster,
    index: Int,
    localMask: Float,
    strength: Float
) -> (UInt8, UInt8, UInt8) {
    let offset = index * 4
    let red = Float(input.pixels[offset]) / 255
    let green = Float(input.pixels[offset + 1]) / 255
    let blue = Float(input.pixels[offset + 2]) / 255
    let originalLuminance = luminance(red, green, blue)
    let local = localMask * strength
    let redExcess = max(0, red - (0.83 * green + 0.17 * blue))
    var nextRed = red - redExcess * 0.76 * local
    var nextGreen = green + redExcess * 0.08 * local
    var nextBlue = blue + redExcess * 0.13 * local
    let correction = originalLuminance - luminance(nextRed, nextGreen, nextBlue)
    nextRed += correction
    nextGreen += correction
    nextBlue += correction
    return (byte(nextRed), byte(nextGreen), byte(nextBlue))
}

private func composeLocalRetouch(
    _ input: Raster,
    teethMask: [Float],
    scleraMask: [Float]
) -> LocalRetouchCompositionResult {
    let count = input.width * input.height
    let empty = [Float](repeating: 0, count: count)
    guard teethMask.count == count, scleraMask.count == count else {
        return LocalRetouchCompositionResult(
            output: input,
            unionMask: empty,
            overlapPixels: 0
        )
    }

    var union = empty
    var output = input
    var overlapPixels = 0
    for index in 0..<count {
        let teeth = clamp(teethMask[index])
        let sclera = clamp(scleraMask[index])
        if teeth > 0.001, sclera > 0.001 {
            overlapPixels += 1
            continue
        }
        union[index] = max(teeth, sclera)
        let offset = index * 4
        if teeth > 0.001 {
            let pixel = whitenedTeethPixel(
                input,
                index: index,
                localMask: teeth,
                strength: 0.62
            )
            output.pixels[offset] = pixel.0
            output.pixels[offset + 1] = pixel.1
            output.pixels[offset + 2] = pixel.2
        } else if sclera > 0.001 {
            let pixel = reducedScleraPixel(
                input,
                index: index,
                localMask: sclera,
                strength: 0.72
            )
            output.pixels[offset] = pixel.0
            output.pixels[offset + 1] = pixel.1
            output.pixels[offset + 2] = pixel.2
        }
    }
    return LocalRetouchCompositionResult(
        output: output,
        unionMask: union,
        overlapPixels: overlapPixels
    )
}

private func mergeStandaloneLocalRetouch(
    original: Raster,
    teethOutput: Raster,
    scleraOutput: Raster,
    teethMask: [Float],
    scleraMask: [Float]
) -> Raster {
    let count = original.width * original.height
    guard teethMask.count == count,
          scleraMask.count == count,
          teethOutput.width == original.width,
          teethOutput.height == original.height,
          scleraOutput.width == original.width,
          scleraOutput.height == original.height
    else { return original }
    var output = original
    for index in 0..<count {
        let hasTeeth = clamp(teethMask[index]) > 0.001
        let hasSclera = clamp(scleraMask[index]) > 0.001
        guard hasTeeth != hasSclera else { continue }
        let offset = index * 4
        let source = hasTeeth ? teethOutput : scleraOutput
        output.pixels[offset] = source.pixels[offset]
        output.pixels[offset + 1] = source.pixels[offset + 1]
        output.pixels[offset + 2] = source.pixels[offset + 2]
    }
    return output
}

private func differentPixelCount(_ first: Raster, _ second: Raster) -> Int {
    guard first.width == second.width,
          first.height == second.height,
          first.pixels.count == second.pixels.count
    else { return max(first.width * first.height, second.width * second.height) }
    var count = 0
    for index in 0..<(first.width * first.height) {
        let offset = index * 4
        if (0..<3).contains(where: { first.pixels[offset + $0] != second.pixels[offset + $0] }) {
            count += 1
        }
    }
    return count
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

private func protectionOverlay(_ input: Raster, mask: [Float]) -> Raster {
    var output = input
    for index in mask.indices where mask[index] > 0.001 {
        let offset = index * 4
        let blend: Float = 0.58
        let red = Float(input.pixels[offset]) / 255
        let green = Float(input.pixels[offset + 1]) / 255
        let blue = Float(input.pixels[offset + 2]) / 255
        output.pixels[offset] = byte(red * (1 - blend) + blend * 0.08)
        output.pixels[offset + 1] = byte(green * (1 - blend) + blend * 0.72)
        output.pixels[offset + 2] = byte(blue * (1 - blend) + blend)
    }
    return output
}

private func leakHeatmapOverlay(_ input: Raster, counts: [Int]) -> Raster {
    var output = input
    let maximum = counts.max() ?? 0
    guard maximum > 0 else { return output }
    for index in counts.indices where counts[index] > 0 {
        let offset = index * 4
        let intensity = sqrt(Float(counts[index]) / Float(maximum))
        let blend = 0.42 + 0.48 * intensity
        let red = Float(input.pixels[offset]) / 255
        let green = Float(input.pixels[offset + 1]) / 255
        let blue = Float(input.pixels[offset + 2]) / 255
        output.pixels[offset] = byte(red * (1 - blend) + blend)
        output.pixels[offset + 1] = byte(green * (1 - blend) + blend * (0.58 - 0.38 * intensity))
        output.pixels[offset + 2] = byte(blue * (1 - blend) + blend * 0.06)
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

private func localRetouchVariantMetrics(
    before: Raster,
    after: Raster,
    mask: [Float],
    protectedMask: [Float],
    highlightMask: [Float]
) -> LocalRetouchVariantMetrics {
    let measurement = measure(before: before, after: after, mask: mask)
    return LocalRetouchVariantMetrics(
        maskPixels: measurement.maskPixels,
        changedPixels: measurement.changedPixels,
        changedOutsideMask: measurement.changedOutsideMask,
        protectedIrisChangedPixels: changedPixelCount(before: before, after: after, within: protectedMask),
        highlightChangedPixels: changedPixelCount(before: before, after: after, within: highlightMask),
        maximumChannelDelta: measurement.maximumChannelDelta,
        meanLuminanceDelta: measurement.meanLuminanceDelta,
        textureEnergyRatio: measurement.textureEnergyRatio
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
    guard let maskedIndex = polygon.indices.first(where: { polygon[$0] > 0.99 }) else {
        throw LabError.invalidArguments("SELF-TEST FAIL: missing strong teeth-mask sample")
    }
    let maskedOffset = maskedIndex * 4
    let yellowBefore = max(0, (Float(input.pixels[maskedOffset]) + Float(input.pixels[maskedOffset + 1])) * 0.5 - Float(input.pixels[maskedOffset + 2])) / 255
    let yellowAfter = max(0, (Float(whitened.pixels[maskedOffset]) + Float(whitened.pixels[maskedOffset + 1])) * 0.5 - Float(whitened.pixels[maskedOffset + 2])) / 255
    try require(yellowAfter < yellowBefore - 0.03, "teeth transform reduces material yellow excess")
    let alreadyLight = Raster(width: 16, height: 16, fill: (245, 245, 245, 255))
    let alreadyLightOutput = whitenTeeth(alreadyLight, mask: polygon, strength: 0.6)
    let alreadyLightMeasurement = measure(
        before: alreadyLight,
        after: alreadyLightOutput,
        mask: polygon
    )
    try require(alreadyLightMeasurement.changedPixels == 0, "already-light teeth are a no-op")
    let lightlyWarm = Raster(width: 16, height: 16, fill: (235, 230, 220, 255))
    let lightlyWarmOutput = whitenTeeth(lightlyWarm, mask: polygon, strength: 0.6)
    let lightlyWarmMeasurement = measure(before: lightlyWarm, after: lightlyWarmOutput, mask: polygon)
    try require(lightlyWarmMeasurement.changedPixels == 0, "lightly warm teeth below correction threshold are a no-op")
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

    let innerLips = [Point(x: 10, y: 10), Point(x: 22, y: 10), Point(x: 22, y: 14), Point(x: 10, y: 14)]
    let outerLips = [Point(x: 4, y: 7), Point(x: 28, y: 7), Point(x: 28, y: 17), Point(x: 4, y: 17)]
    let candidateRegion = try adaptiveMouthCandidateRegion(
        width: 32,
        height: 24,
        innerLips: innerLips,
        outerLips: outerLips
    )
    try require(candidateRegion[8 * 32 + 16] == 0, "adaptive envelope excludes upper-lip band")
    try require(candidateRegion[9 * 32 + 16] == 0, "adaptive envelope respects upper aperture edge")
    try require(candidateRegion[10 * 32 + 16] == 0, "adaptive envelope has an upper safety inset")
    try require(candidateRegion[11 * 32 + 16] > 0, "adaptive envelope retains seeded aperture")
    var fixedSeed = [Float](repeating: 0, count: 32 * 24)
    for y in 11...13 {
        for x in 13...19 { fixedSeed[y * 32 + x] = 1 }
    }
    var adaptiveInput = Raster(width: 32, height: 24, fill: (45, 22, 28, 255))
    for y in 10...14 {
        for x in 8...24 {
            adaptiveInput.setRGB(x: x, y: y, red: 0.71, green: 0.63, blue: 0.47)
        }
    }
    let adaptive = try adaptiveTeethMask(
        adaptiveInput,
        innerLips: innerLips,
        candidateRegion: candidateRegion,
        fixedSeedMask: fixedSeed
    )
    try require(
        adaptive.filter { $0 > 0.15 }.count > fixedSeed.filter { $0 > 0.15 }.count,
        "adaptive teeth grows connected neutral candidates"
    )
    let failedClosed = try adaptiveTeethMask(
        adaptiveInput,
        innerLips: innerLips,
        candidateRegion: candidateRegion,
        fixedSeedMask: [Float](repeating: 0, count: 32 * 24)
    )
    try require(failedClosed.allSatisfy { $0 == 0 }, "adaptive teeth requires fixed seeds")

    let eye = [
        Point(x: 4, y: 12), Point(x: 8, y: 8), Point(x: 24, y: 8),
        Point(x: 28, y: 12), Point(x: 24, y: 16), Point(x: 8, y: 16),
    ]
    let pupil = Point(x: 16, y: 12)
    let eyeInput = Raster(width: 32, height: 24, fill: (180, 170, 165, 255))
    let aperture = try polygonMask(width: 32, height: 24, points: eye, featherRadius: 0)
    let protected = circularMaskWithinRegion(width: 32, height: 24, center: pupil, radius: 4.64, region: aperture)
    let shiftedPupil = Point(x: pupil.x + 2.88, y: pupil.y)
    let legacyEnvelope = try geometricScleraEnvelope(
        eyeInput,
        eye: eye,
        pupil: shiftedPupil,
        minimumAspectRatio: nil,
        irisInflationWidthFraction: 0
    )
    let guardedEnvelope = try geometricScleraEnvelope(
        eyeInput,
        eye: eye,
        pupil: shiftedPupil,
        minimumAspectRatio: 0.30,
        irisInflationWidthFraction: 0.14
    )
    var leakScratch = [Int](repeating: 0, count: 32 * 24)
    let legacyRisk = assessScleraEnvelope(
        legacyEnvelope.mask,
        protectedMask: protected,
        highlightMask: [Float](repeating: 0, count: 32 * 24),
        leakCounts: &leakScratch
    )
    leakScratch = [Int](repeating: 0, count: 32 * 24)
    let guardedRisk = assessScleraEnvelope(
        guardedEnvelope.mask,
        protectedMask: protected,
        highlightMask: [Float](repeating: 0, count: 32 * 24),
        leakCounts: &leakScratch
    )
    try require(legacyRisk.irisLeak > 0, "legacy sclera envelope exposes shifted-iris risk")
    try require(guardedRisk.irisLeak == 0, "guarded sclera envelope protects shifted iris")
    let challenge = scleraColorAdversarialInput(
        eyeInput,
        protectedMask: protected,
        highlightMask: [Float](repeating: 0, count: 32 * 24)
    )
    let legacyColor = try legacyScleraColorMask(challenge, eye: eye, pupil: shiftedPupil)
    let guardedColor = try guardedScleraColorMask(
        challenge,
        eye: eye,
        pupil: shiftedPupil,
        minimumAspectRatio: 0.30,
        irisInflationWidthFraction: 0.14
    )
    let legacyColorOutput = reduceScleraRedness(challenge, mask: legacyColor.mask, strength: 0.72)
    let guardedColorOutput = reduceScleraRedness(challenge, mask: guardedColor.mask, strength: 0.72)
    try require(
        changedPixelCount(before: challenge, after: legacyColorOutput, within: protected) > 0,
        "legacy feathered color transform changes adversarial protected iris"
    )
    try require(
        changedPixelCount(before: challenge, after: guardedColorOutput, within: protected) == 0,
        "guarded feathered color transform remains clipped outside protected iris"
    )
    let blinkEnvelope = try geometricScleraEnvelope(
        eyeInput,
        eye: verticallyScaledEye(eye, scale: 0.20),
        pupil: pupil,
        minimumAspectRatio: 0.30,
        irisInflationWidthFraction: 0.14
    )
    try require(blinkEnvelope.failedClosed && blinkEnvelope.mask.allSatisfy { $0 == 0 }, "blink-like eye fails closed")
    let openColor = try guardedScleraColorMask(
        eyeInput,
        eye: eye,
        pupil: pupil,
        minimumAspectRatio: 0.30,
        irisInflationWidthFraction: 0.14
    )
    let collapsedColor = try guardedScleraColorMask(
        eyeInput,
        eye: verticallyScaledEye(eye, scale: 0.20),
        pupil: pupil,
        minimumAspectRatio: 0.30,
        irisInflationWidthFraction: 0.14
    )
    let independentUnion = zip(openColor.mask, collapsedColor.mask).map { max($0, $1) }
    try require(
        openColor.mask.contains { $0 > 0.001 }
            && collapsedColor.failedClosed
            && independentUnion == openColor.mask,
        "collapsed eye fails closed without disabling accepted peer eye"
    )

    let compositionInput = Raster(width: 16, height: 16, fill: (205, 165, 135, 255))
    var teethMask = [Float](repeating: 0, count: 16 * 16)
    var scleraMask = teethMask
    teethMask[5 * 16 + 5] = 0.8
    scleraMask[10 * 16 + 10] = 0.7
    let composed = composeLocalRetouch(
        compositionInput,
        teethMask: teethMask,
        scleraMask: scleraMask
    )
    let standalone = mergeStandaloneLocalRetouch(
        original: compositionInput,
        teethOutput: whitenTeeth(compositionInput, mask: teethMask, strength: 0.62),
        scleraOutput: reduceScleraRedness(compositionInput, mask: scleraMask, strength: 0.72),
        teethMask: teethMask,
        scleraMask: scleraMask
    )
    let sequential = reduceScleraRedness(
        whitenTeeth(compositionInput, mask: teethMask, strength: 0.62),
        mask: scleraMask,
        strength: 0.72
    )
    try require(
        differentPixelCount(composed.output, standalone) == 0
            && differentPixelCount(composed.output, sequential) == 0,
        "disjoint fused composition matches standalone and sequential oracles"
    )
    let rejectedTeeth = composeLocalRetouch(
        compositionInput,
        teethMask: [Float](repeating: 0, count: 16 * 16),
        scleraMask: scleraMask
    )
    try require(
        differentPixelCount(
            rejectedTeeth.output,
            reduceScleraRedness(compositionInput, mask: scleraMask, strength: 0.72)
        ) == 0,
        "rejected teeth region preserves accepted sclera result"
    )
    scleraMask[5 * 16 + 5] = 0.8
    let overlap = composeLocalRetouch(
        compositionInput,
        teethMask: teethMask,
        scleraMask: scleraMask
    )
    var overlapRegion = [Float](repeating: 0, count: 16 * 16)
    overlapRegion[5 * 16 + 5] = 1
    try require(
        overlap.overlapPixels == 1
            && changedPixelCount(before: compositionInput, after: overlap.output, within: overlapRegion) == 0,
        "ambiguous cross-mask overlap suppresses both edits"
    )

    let imageContext = canonicalImageContext()
    var asymmetric = Raster(width: 7, height: 5, fill: (0, 0, 0, 255))
    for y in 0..<asymmetric.height {
        for x in 0..<asymmetric.width {
            asymmetric.setRGB(
                x: x,
                y: y,
                red: Float(x + 1) / 9,
                green: Float(y + 1) / 7,
                blue: Float(x + y + 1) / 13
            )
        }
    }
    let asymmetricImage = try asymmetric.makeCGImage()
    let orientationReference = try normalizedImage(
        asymmetricImage,
        orientationRaw: CGImagePropertyOrientation.up.rawValue,
        context: imageContext,
        destinationColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
    )
    let orientationReferenceRaster = try Raster(cgImage: orientationReference)
    var orientationMismatch = 0
    for orientationRaw in UInt32(1)...UInt32(8) {
        let raw = try inverseOrientedImage(
            orientationReference,
            targetOrientationRaw: orientationRaw,
            context: imageContext
        )
        let data = try encodedImageData(
            raw,
            orientationRaw: orientationRaw,
            typeIdentifier: UTType.tiff.identifier
        )
        let normalized = try normalizedImage(data: data, context: imageContext)
        orientationMismatch += differentPixelCount(
            orientationReferenceRaster,
            try Raster(cgImage: normalized)
        )
    }
    try require(orientationMismatch == 0, "all EXIF orientation and mirror cases normalize exactly")
    let invalidOrientationRejected: Bool
    do {
        _ = try normalizedImage(
            orientationReference,
            orientationRaw: 9,
            context: imageContext,
            destinationColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
        invalidOrientationRejected = false
    } catch LabError.invalidImageOrientation {
        invalidOrientationRejected = true
    }
    try require(invalidOrientationRejected, "invalid EXIF orientation fails closed")
    let grayRejected: Bool
    do {
        _ = try normalizedImage(
            makeGrayTestImage(),
            orientationRaw: CGImagePropertyOrientation.up.rawValue,
            context: imageContext,
            destinationColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
        grayRejected = false
    } catch LabError.unsupportedImageColorModel {
        grayRejected = true
    }
    try require(grayRejected, "non-RGB input fails closed")
    var alphaCompositionInput = Raster(width: 8, height: 8, fill: (80, 70, 60, 128))
    alphaCompositionInput.pixels[3] = 0
    alphaCompositionInput.pixels[0] = 0
    alphaCompositionInput.pixels[1] = 0
    alphaCompositionInput.pixels[2] = 0
    var alphaTeethMask = [Float](repeating: 0, count: 64)
    alphaTeethMask[4 * 8 + 4] = 0.7
    let alphaComposition = composeLocalRetouch(
        alphaCompositionInput,
        teethMask: alphaTeethMask,
        scleraMask: [Float](repeating: 0, count: 64)
    )
    try require(
        alphaMismatchCount(alphaCompositionInput, alphaComposition.output) == 0,
        "local composition preserves alpha bytes"
    )
}
