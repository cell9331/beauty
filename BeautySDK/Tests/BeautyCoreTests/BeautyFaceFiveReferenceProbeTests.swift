#if os(macOS)
import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects
@testable import BeautySDK
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest

/// Owner-local opt-in calibration helper. Photos, observed geometry and
/// pointwise fields are written only to the explicitly provided ignored folder.
/// Default test runs skip it. This probe makes no native iOS/MediaPipe claim.
/// The supplied source is the engineering neutral chosen for this comparison;
/// the reference app's common zero and intermediate response remain unconfirmed.
/// BEAUTYSDK_FACE_FIVE_PUBLIC_PIPELINE=1 additionally verifies public CPU and
/// live-Metal CIImage processing and writes a separate aggregate receipt.
final class BeautyFaceFiveReferenceProbeTests: XCTestCase {
    func testOwnerLocalFiveReferenceProbe() throws {
        let environment = ProcessInfo.processInfo.environment
        guard let sourcePath = environment["BEAUTYSDK_FACE_FIVE_SOURCE"],
              let outputPath = environment["BEAUTYSDK_FACE_FIVE_OUTPUT"],
              sourcePath.hasPrefix("/"), outputPath.hasPrefix("/") else {
            throw XCTSkip("Owner-local five-control reference probe is opt-in")
        }
        let output = URL(fileURLWithPath: outputPath, isDirectory: true)
        guard FileManager.default.fileExists(atPath: output.path) else {
            throw ProbeFailure.explicitOutputFolderRequired
        }
        guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: sourcePath) as CFURL, nil),
              CGImageSourceGetCount(source) == 1,
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ProbeFailure.sourceDecodeFailed
        }
        let image = CIImage(cgImage: cgImage)
        let width = cgImage.width, height = cgImage.height
        var detector = BeautyFaceDetector.production()
        let result = detector.detect(image: image,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            imageExtent: image.extent.size, configuration: .init(maximumFaceCount: 1))
        guard result.summary.usedFaceCount == 1, let observation = result.observations.first else {
            throw ProbeFailure.observationMissing
        }
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        guard let geometry = BeautyFaceDisplacementGeometry(width: width, height: height, face: face),
              let support = face.observedFaceSupport, let left = face.leftEyeSupport,
              let right = face.rightEyeSupport, let lips = face.observedOuterLips else {
            throw ProbeFailure.observedGeometryRejected
        }
        func vector(_ p: SIMD2<Double>) -> [Double] { [p.x, p.y] }
        func pixels(_ path: [SIMD2<Float>]) -> [[Double]] {
            path.map { [Double($0.x) * Double(width) - 0.5, Double($0.y) * Double(height) - 0.5] }
        }
        let geometryPayload: [String: Any] = [
            "schema": 1, "privateScope": "owner-local-ignored", "backend": "macOS-Vision",
            "sourceQualification": "engineering-neutral-reference-zero-unconfirmed",
            "width": width, "height": height, "coordinateConvention": "pixel-centres-x-right-y-down",
            "origin": vector(geometry.origin), "axisX": vector(geometry.axisX),
            "axisY": vector(geometry.axisY), "scale": geometry.scale,
            "contour": pixels(support.contour), "leftEye": pixels(left.contour),
            "rightEye": pixels(right.contour), "lips": pixels(lips)
        ]
        try writeJSON(geometryPayload, to: output.appendingPathComponent("private-source-geometry.json"))
        if environment["BEAUTYSDK_FACE_FIVE_GEOMETRY_ONLY"] == "1" {
            print("FACE_FIVE_REFERENCE geometry=admitted backend=macOS-Vision detectionCalls=1")
            return
        }
        guard let queryPath = environment["BEAUTYSDK_FACE_FIVE_QUERY"], queryPath.hasPrefix("/"),
              let query = try JSONSerialization.jsonObject(with: Data(contentsOf:
                URL(fileURLWithPath: queryPath))) as? [String: [[String: Any]]] else {
            throw ProbeFailure.queryMissing
        }
        let cases: [(String, BeautyFaceShapeSlider)] = [
            ("temple", .temple), ("cheekbone", .cheekbone), ("chin_length", .chinLength),
            ("pointed_chin", .chinTaper), ("v_face", .vFace)
        ]
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace,
                                          .cacheIntermediates: false])
        var rgba = [UInt8](repeating: 0, count: width * height * 4)
        rgba.withUnsafeMutableBytes { bytes in
            context.render(image, toBitmap: bytes.baseAddress!, rowBytes: width * 4,
                           bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        }
        var aggregate = [[String: Any]]()
        for (name, slider) in cases {
            let highStrengths = BeautyEffectResolver.resolve(parameters:
                slider.applying(position: 1, to: BeautyParameters()), faceGeometry: face).effectiveStrengths
            guard let high = BeautyFaceDisplacementMap(width: width, height: height,
                face: face, strengths: highStrengths) else { throw ProbeFailure.highMapRejected }
            let low: BeautyFaceDisplacementMap?
            if slider == .vFace { low = nil } else {
                let strengths = BeautyEffectResolver.resolve(parameters:
                    slider.applying(position: 0, to: BeautyParameters()), faceGeometry: face).effectiveStrengths
                guard let map = BeautyFaceDisplacementMap(width: width, height: height,
                    face: face, strengths: strengths) else { throw ProbeFailure.lowMapRejected }
                low = map
            }
            var pointRecords = [[String: Any]]()
            for record in query[name] ?? [] {
                guard let coordinates = record["p"] as? [Double], coordinates.count == 2 else {
                    throw ProbeFailure.invalidQuery
                }
                let lowPixel = SIMD2(coordinates[0], coordinates[1])
                guard let neutral = low?.sourcePoint(for: lowPixel) ?? (low == nil ? lowPixel : nil) else {
                    throw ProbeFailure.inverseFailed
                }
                let lowD = low?.forwardDisplacement(at: neutral) ?? .zero
                let highD = high.forwardDisplacement(at: neutral)
                var payload = record
                payload["neutralSource"] = vector(neutral)
                payload["predictedPairD"] = vector(highD - lowD)
                payload["predictedLowD"] = vector(lowD)
                payload["predictedHighD"] = vector(highD)
                payload["lowInverseResidual"] = hypot(neutral.x + lowD.x - lowPixel.x,
                                                       neutral.y + lowD.y - lowPixel.y)
                pointRecords.append(payload)
            }
            try writeJSON(["schema": 1, "points": pointRecords],
                to: output.appendingPathComponent("private-\(name)-pair.json"))
            for (label, map) in [("high", high), ("low", low)] {
                guard let map else { continue }
                let bytes = map.applyRGBA(rgba)
                let data = Data(bytes)
                guard let provider = CGDataProvider(data: data as CFData),
                      let rendered = CGImage(width: width, height: height, bitsPerComponent: 8,
                        bitsPerPixel: 32, bytesPerRow: width * 4, space: colorSpace,
                        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                        provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent),
                      let destination = CGImageDestinationCreateWithURL(output.appendingPathComponent(
                        "\(name)-\(label).png") as CFURL, UTType.png.identifier as CFString, 1, nil) else {
                    throw ProbeFailure.outputFailed
                }
                CGImageDestinationAddImage(destination, rendered, nil)
                guard CGImageDestinationFinalize(destination) else { throw ProbeFailure.outputFailed }
            }
            aggregate.append(["control": name, "queryCount": pointRecords.count,
                              "highGradientBound": high.maximumGradient, "highAmplitudeScale": high.amplitudeScale,
                              "lowGradientBound": low?.maximumGradient ?? 0,
                              "lowAmplitudeScale": low?.amplitudeScale ?? 1])
        }
        try writeJSON(["schema": 1, "detectionCalls": 1, "backend": "macOS-Vision",
            "sourceQualification": "engineering-neutral-reference-zero-unconfirmed", "cases": aggregate],
            to: output.appendingPathComponent("aggregate.json"))
        print("FACE_FIVE_REFERENCE cases=5 endpoints=9 detectionCalls=1 backend=macOS-Vision")
        if environment["BEAUTYSDK_FACE_FIVE_PUBLIC_PIPELINE"] == "1" {
            try verifyPublicPipeline(image: image, observation: observation, sourceRGBA: rgba,
                                     width: width, height: height, output: output, context: context)
        }
    }

    /// Opt-in only. Executes the public CIImage processing entry with one fresh
    /// production observation frozen into both engines. Metal uses its live
    /// runtime and invocation hook. The continuous face warp remains the shared
    /// CPU map after the live Metal transaction; this is not a GPU-kernel claim.
    private func verifyPublicPipeline(image: CIImage, observation: BeautyFaceObservation,
                                     sourceRGBA: [UInt8], width: Int, height: Int,
                                     output: URL, context: CIContext) throws {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let cpuObservations = Counter(), metalObservations = Counter(), runtimeCalls = Counter()
        let terminalErrors = Counter()
        func detector(_ counter: Counter) -> BeautyFaceDetector {
            BeautyFaceDetector(mappedObservationProvider: { _ in
                counter.increment()
                return BeautyMappedFaceObservations(observations: [observation])
            })
        }
        let cpu = try BeautyEngine(configuration: .init(renderBackend: .cpu),
            faceDetector: detector(cpuObservations), backendExecutor: BeautyCPUBackend())
        let liveMetal: BeautyMetalBackend
        do {
            liveMetal = try BeautyMetalBackend(hooks: .init(
                onRuntimeInvocation: { runtimeCalls.increment() },
                onTerminalError: { _ in terminalErrors.increment() }))
        } catch {
            try writeJSON(["schema": 1, "probe": "five-reference-public-CIImage",
                "status": "live-Metal-unavailable", "actualMetalExecutionConfirmed": false],
                to: output.appendingPathComponent("engine-pipeline-aggregate.json"))
            throw ProbeFailure.liveMetalUnavailable
        }
        let metal = try BeautyEngine(configuration: .init(renderBackend: .gpu),
            faceDetector: detector(metalObservations), backendExecutor: liveMetal)
        func bytes(_ value: CIImage) throws -> [UInt8] {
            guard value.extent == image.extent else { throw ProbeFailure.pipelineExtentChanged }
            var result = [UInt8](repeating: 0, count: sourceRGBA.count)
            result.withUnsafeMutableBytes { buffer in
                context.render(value, toBitmap: buffer.baseAddress!, rowBytes: width * 4,
                               bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
            }
            return result
        }
        func changedPixels(_ a: [UInt8], _ b: [UInt8]) -> Int {
            var count = 0
            for i in stride(from: 0, to: a.count, by: 4) {
                if a[i] != b[i] || a[i+1] != b[i+1] || a[i+2] != b[i+2] || a[i+3] != b[i+3] { count += 1 }
            }
            return count
        }
        func writeImage(_ value: CIImage, name: String) throws {
            guard let rendered = context.createCGImage(value, from: image.extent,
                format: .RGBA8, colorSpace: colorSpace),
                  let destination = CGImageDestinationCreateWithURL(
                    output.appendingPathComponent(name).appendingPathExtension("png") as CFURL,
                    UTType.png.identifier as CFString, 1, nil) else { throw ProbeFailure.outputFailed }
            CGImageDestinationAddImage(destination, rendered, nil)
            guard CGImageDestinationFinalize(destination) else { throw ProbeFailure.outputFailed }
        }
        let neutralCPU = try cpu.processResult(image: image, metadata: metadata, parameters: .init())
        let neutralMetal = try metal.processResult(image: image, metadata: metadata, parameters: .init())
        let neutralCPUBytes = try bytes(neutralCPU.output), neutralMetalBytes = try bytes(neutralMetal.output)
        let neutralCPUExact = neutralCPUBytes == sourceRGBA, neutralMetalExact = neutralMetalBytes == sourceRGBA
        try writeImage(neutralCPU.output, name: "engine-cpu-neutral")
        try writeImage(neutralMetal.output, name: "engine-metal-neutral")
        let cases: [(String, BeautyFaceShapeSlider)] = [
            ("temple", .temple), ("cheekbone", .cheekbone), ("chin_length", .chinLength),
            ("pointed_chin", .chinTaper), ("v_face", .vFace)
        ]
        var records = [[String: Any]]()
        var allUsedOneFace = true, allChanged = true, allCPUAndMetalExact = true
        var allAlphaExact = true, allRuntimeConfirmed = true, allDirectMapsCPUExact = true
        for (name, slider) in cases {
            for label in (slider == .vFace ? ["high"] : ["low", "high"]) {
                let parameters = slider.applying(position: label == "low" ? 0 : 1, to: .init())
                let cpuResult = try cpu.processResult(image: image, metadata: metadata, parameters: parameters)
                let beforeRuntime = runtimeCalls.value
                let metalResult = try metal.processResult(image: image, metadata: metadata, parameters: parameters)
                let endpointRuntimeCalls = runtimeCalls.value - beforeRuntime
                let cpuBytes = try bytes(cpuResult.output), metalBytes = try bytes(metalResult.output)
                let cpuChanged = changedPixels(sourceRGBA, cpuBytes), metalChanged = changedPixels(sourceRGBA, metalBytes)
                let usedOneFace = cpuResult.detectionSummary?.usedFaceCount == 1 && metalResult.detectionSummary?.usedFaceCount == 1
                let cpuMetalExact = cpuBytes == metalBytes
                let alphaExact = stride(from: 3, to: sourceRGBA.count, by: 4).allSatisfy {
                    cpuBytes[$0] == sourceRGBA[$0] && metalBytes[$0] == sourceRGBA[$0]
                }
                guard let directSource = CGImageSourceCreateWithURL(
                    output.appendingPathComponent("\(name)-\(label).png") as CFURL, nil),
                      let directCG = CGImageSourceCreateImageAtIndex(directSource, 0, nil) else {
                    throw ProbeFailure.directOutputMissing
                }
                let directBytes = try bytes(CIImage(cgImage: directCG))
                let directDifferentPixels = changedPixels(directBytes, cpuBytes)
                let maximumDirectChannelDifference = zip(directBytes, cpuBytes).reduce(0) {
                    max($0, abs(Int($1.0) - Int($1.1)))
                }
                allUsedOneFace = allUsedOneFace && usedOneFace
                allChanged = allChanged && cpuChanged > 0 && metalChanged > 0
                allCPUAndMetalExact = allCPUAndMetalExact && cpuMetalExact
                allAlphaExact = allAlphaExact && alphaExact
                allRuntimeConfirmed = allRuntimeConfirmed && endpointRuntimeCalls > 0
                allDirectMapsCPUExact = allDirectMapsCPUExact && directDifferentPixels == 0
                records.append(["control": name, "endpoint": label,
                    "usedFaceOneCPUAndMetal": usedOneFace, "cpuChangedPixels": cpuChanged,
                    "metalChangedPixels": metalChanged, "cpuMetalRGBAExact": cpuMetalExact,
                    "alphaExact": alphaExact, "liveMetalRuntimeInvocations": endpointRuntimeCalls,
                    "directMapCPUDifferentPixels": directDifferentPixels,
                    "directMapCPUMaximumChannelDifference": maximumDirectChannelDifference,
                    "directMapCPUExact": directDifferentPixels == 0])
                try writeImage(cpuResult.output, name: "engine-cpu-\(name)-\(label)")
                try writeImage(metalResult.output, name: "engine-metal-\(name)-\(label)")
            }
        }
        let recoveredCPU = try bytes(cpu.processResult(image: image, metadata: metadata, parameters: .init()).output)
        let recoveredMetal = try bytes(metal.processResult(image: image, metadata: metadata, parameters: .init()).output)
        let recoveryExact = recoveredCPU == sourceRGBA && recoveredMetal == sourceRGBA
        let passed = records.count == 9 && neutralCPUExact && neutralMetalExact && recoveryExact &&
            allUsedOneFace && allChanged && allCPUAndMetalExact && allAlphaExact && allRuntimeConfirmed &&
            terminalErrors.value == 0
        let receipt: [String: Any] = ["schema": 1, "probe": "five-reference-public-CIImage",
            "sourceQualification": "engineering-neutral-reference-zero-unconfirmed",
            "status": passed ? "passed" : "failed", "endpointCount": records.count,
            "freshProductionDetectionInvocations": 1,
            "frozenObservationRequestsCPU": cpuObservations.value,
            "frozenObservationRequestsMetal": metalObservations.value,
            "executorCPU": "BeautyCPUBackend", "executorMetal": "BeautyMetalBackend-live-runtime",
            "geometryImplementation": "shared-CPU-continuous-face-map-after-live-Metal-transaction",
            "liveMetalRuntimeInvocations": runtimeCalls.value, "metalTerminalErrors": terminalErrors.value,
            "actualMetalExecutionConfirmed": allRuntimeConfirmed,
            "neutralCPURGBAExact": neutralCPUExact, "neutralMetalRGBAExact": neutralMetalExact,
            "neutralRecoveryBothRGBAExact": recoveryExact,
            "allEndpointsUsedOneFace": allUsedOneFace, "allEndpointsChanged": allChanged,
            "allEndpointsCPUAndMetalRGBAExact": allCPUAndMetalExact, "allEndpointsAlphaExact": allAlphaExact,
            "allDirectMapsCPUExact": allDirectMapsCPUExact,
            "cases": records]
        try writeJSON(receipt, to: output.appendingPathComponent("engine-pipeline-aggregate.json"))
        print("FACE_FIVE_PUBLIC_PIPELINE endpoints=\(records.count) status=\(passed ? "passed" : "failed") liveMetalCalls=\(runtimeCalls.value)")
        guard passed else { throw ProbeFailure.publicPipelineValidationFailed }
    }

    private func writeJSON(_ payload: [String: Any], to url: URL) throws {
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        try data.write(to: url, options: .atomic)
    }

    private enum ProbeFailure: Error {
        case explicitOutputFolderRequired, sourceDecodeFailed, observationMissing, observedGeometryRejected
        case queryMissing, invalidQuery, highMapRejected, lowMapRejected, inverseFailed, outputFailed
        case liveMetalUnavailable, pipelineExtentChanged, directOutputMissing, publicPipelineValidationFailed
    }

    private final class Counter: @unchecked Sendable {
        private let lock = NSLock()
        private var count = 0
        var value: Int { lock.lock(); defer { lock.unlock() }; return count }
        func increment() { lock.lock(); defer { lock.unlock() }; count += 1 }
    }
}
#endif
