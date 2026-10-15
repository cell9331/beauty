import BeautyCore
import BeautyDetection
import BeautyEffects
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@testable import BeautySDK

/// Public original-bound preview contracts. Observations and source pixels are
/// deterministic fixtures; these checks do not claim native detector parity.
final class BeautyEngineIrisPreviewTests: XCTestCase {
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
    private let context = CIContext(options: [.cacheIntermediates: false,
        .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
        .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])

    func testFiniteThumbnailDimensionsSRGBAlphaAndTruthfulCPUMetrics() throws {
        let probe = Probe(observations: [])
        let executor = UnusedExecutor()
        let engine = try BeautyEngine(faceDetector: probe.detector(), backendExecutor: executor)
        let source = try image(width: 1024, height: 768)
        let prepared = try engine.prepareStillImage(image: source)
        let result = try engine.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: 256, parameters: .init())
        XCTAssertEqual(result.output.extent, CGRect(x: 0, y: 0, width: 256, height: 192))
        XCTAssertEqual(result.output.colorSpace?.name, colorSpace.name)
        XCTAssertTrue(result.output.extent.width.isFinite && result.output.extent.height.isFinite)
        let rendered = pixels(result.output)
        XCTAssertTrue(stride(from: 3, to: rendered.count, by: 4).allSatisfy { rendered[$0] == 255 })
        assertCPUMetrics(result, sourceWidth: 1024, sourceHeight: 768, maximumEdge: 256)
        XCTAssertEqual(result.metrics["beauty.irisPreview.completedEyeCount"], 0)
        XCTAssertEqual(probe.calls, 0, "neutral must not infer a face")
        XCTAssertEqual(executor.calls, 0, "this explicit CPU cutpoint must not claim injected backend execution")
        let small = try engine.prepareStillImage(image: image(width: 64, height: 48))
        let unscaled = try engine.processIrisPreviewResult(preparedImage: small, parameters: .init())
        XCTAssertEqual(unscaled.output.extent, CGRect(x: 0, y: 0, width: 64, height: 48))
        assertCPUMetrics(unscaled, sourceWidth: 64, sourceHeight: 48, maximumEdge: 960)
    }

    func testPreparedOriginalIsReusedWithoutEditedOutputDetectionAndExpiresCorrectly() throws {
        let probe = Probe(observations: [try observation()])
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let source = try image()
        let expectedOriginal = fingerprint(pixels(CIImage(cgImage: source)))
        let prepared = try engine.prepareStillImage(image: source)
        let first = try engine.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: 256, parameters: .init(pupilSize: 0.25))
        let next = try engine.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: 128, parameters: .init(pupilSize: -0.25))
        let repeated = try engine.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: 256, parameters: .init(pupilSize: 0.25))
        XCTAssertEqual(probe.calls, 1)
        XCTAssertEqual(probe.extents, [CGSize(width: 512, height: 384)])
        XCTAssertEqual(probe.fingerprints, [expectedOriginal], "the detector sees only the immutable original")
        XCTAssertEqual(first.metrics["beauty.detection.preparedReuse"], 0)
        XCTAssertEqual(next.metrics["beauty.detection.preparedReuse"], 1)
        XCTAssertEqual(repeated.metrics["beauty.detection.preparedReuse"], 1)
        XCTAssertEqual(pixels(first.output), pixels(repeated.output), "changing preview size/sign cannot accumulate prior edits")
        XCTAssertGreaterThan(first.metrics["beauty.irisPreview.completedEyeCount"] ?? 0, 0)
        let foreignProbe = Probe(observations: [try observation()])
        let foreign = try BeautyEngine(faceDetector: foreignProbe.detector())
        assertInvalid { try foreign.processIrisPreviewResult(preparedImage: prepared, parameters: .init(pupilSize: 0.25)) }
        XCTAssertEqual(foreignProbe.calls, 0)
        let replacement = try engine.prepareStillImage(image: image(seed: 7))
        assertInvalid { try engine.processIrisPreviewResult(preparedImage: prepared, parameters: .init()) }
        XCTAssertEqual(probe.calls, 1)
        _ = try engine.processIrisPreviewResult(preparedImage: replacement,
            maximumPreviewEdge: 256, parameters: .init(pupilSize: 0.25))
        XCTAssertEqual(probe.calls, 2)
        XCTAssertNotEqual(probe.fingerprints[0], probe.fingerprints[1])
        engine.reset()
        assertInvalid { try engine.processIrisPreviewResult(preparedImage: replacement, parameters: .init()) }
        let last = try engine.prepareStillImage(image: source)
        engine.releasePreparedStillImage()
        assertInvalid { try engine.processIrisPreviewResult(preparedImage: last, parameters: .init()) }
        XCTAssertEqual(probe.calls, 2)
    }

    func testInvalidPreviewLimitAndSelectedGPUFailBeforeDetectionOrExecution() throws {
        let probe = Probe(observations: [try observation()]), executor = UnusedExecutor()
        let engine = try BeautyEngine(faceDetector: probe.detector(), backendExecutor: executor)
        let prepared = try engine.prepareStillImage(image: image())
        for edge in [-1, 0, 961, Int.max] {
            assertInvalid { try engine.processIrisPreviewResult(preparedImage: prepared,
                maximumPreviewEdge: edge, parameters: .init(pupilSize: 0.25)) }
        }
        XCTAssertEqual(probe.calls, 0)
        XCTAssertEqual(executor.calls, 0)
        let gpuProbe = Probe(observations: [try observation()]), gpuExecutor = UnusedExecutor()
        let gpu = try BeautyEngine(configuration: .init(renderBackend: .gpu),
            faceDetector: gpuProbe.detector(), backendExecutor: gpuExecutor)
        let gpuPrepared = try gpu.prepareStillImage(image: image())
        assertInvalid { try gpu.processIrisPreviewResult(preparedImage: gpuPrepared,
            maximumPreviewEdge: 256, parameters: .init(pupilSize: 0.25)) }
        XCTAssertEqual(gpuProbe.calls, 0)
        XCTAssertEqual(gpuExecutor.calls, 0, "a CPU-only preview request must reject a selected GPU policy")
    }

    func testNoFaceFailsClosedAndNeutralRestoresOriginalThumbnail() throws {
        let probe = Probe(observations: [])
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let prepared = try engine.prepareStillImage(image: image())
        let neutral = try engine.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: 256, parameters: .init())
        XCTAssertEqual(probe.calls, 0)
        let missing = try engine.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: 256, parameters: .init(pupilSize: 0.25))
        let again = try engine.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: 256, parameters: .init(pupilSize: -0.25))
        XCTAssertEqual(missing.detectionSummary?.availability, .noFace)
        XCTAssertEqual(again.detectionSummary?.availability, .noFace)
        XCTAssertEqual(missing.metrics["beauty.irisPreview.completedEyeCount"], 0)
        XCTAssertEqual(pixels(missing.output), pixels(neutral.output))
        XCTAssertEqual(pixels(again.output), pixels(neutral.output))
        XCTAssertEqual(probe.calls, 1, "a source no-face outcome remains reusable")
        XCTAssertEqual(again.metrics["beauty.detection.preparedReuse"], 1)
        let restored = try engine.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: 256, parameters: .init())
        XCTAssertEqual(pixels(restored.output), pixels(neutral.output))
        XCTAssertEqual(probe.calls, 1)
    }

    func testIrisKeepsSiblingIntentAndLegacyThumbnailBaselineOutsideSourceIrisDomain() throws {
        let source = try image(), thumbnail = try legacyThumbnail(source, maximumEdge: 256)
        let probe = Probe(observations: [try observation()])
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let prepared = try engine.prepareStillImage(image: source)
        let legacyProbe = Probe(observations: [try observation()])
        let legacy = try BeautyEngine(faceDetector: legacyProbe.detector())
        let legacyPrepared = try legacy.prepareStillImage(image: thumbnail)
        let legacyNeutral = try legacy.processResult(preparedImage: legacyPrepared, parameters: .init())
        let iris = try engine.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: 256, parameters: .init(pupilSize: 0.25))
        let irisPixels = pixels(iris.output), neutralPixels = pixels(legacyNeutral.output)
        XCTAssertGreaterThan(regionDelta(irisPixels, neutralPixels, width: 256, height: 192,
            region: CGRect(x: 0.2, y: 0.3, width: 0.6, height: 0.18)), 0)
        let siblings: [(String, WritableKeyPath<BeautyParameters, Float>, Float, CGRect)] = [
            ("eyeSize", \.eyeSize, 0.16, CGRect(x: 0.2, y: 0.3, width: 0.6, height: 0.18)),
            ("eyeY", \.eyeYPosition, 0.1, CGRect(x: 0.2, y: 0.3, width: 0.6, height: 0.2)),
            ("brightness", \.brightness, 0.07, CGRect(x: 0.04, y: 0.8, width: 0.16, height: 0.1)),
            ("mouthWidth", \.mouthWidth, 0.12, CGRect(x: 0.36, y: 0.64, width: 0.28, height: 0.13)),
            ("noseWing", \.noseWingSlim, 0.16, CGRect(x: 0.42, y: 0.5, width: 0.16, height: 0.13)),
            ("browY", \.eyebrowYPosition, 0.15, CGRect(x: 0.2, y: 0.23, width: 0.6, height: 0.1)),
        ]
        for (name, field, strength, region) in siblings {
            var sibling = BeautyParameters(); sibling[keyPath: field] = strength
            let legacyResult = try legacy.processResult(preparedImage: legacyPrepared, parameters: sibling)
            let baseline = pixels(legacyResult.output)
            XCTAssertGreaterThan(regionDelta(baseline, neutralPixels, width: 256, height: 192, region: region), 0,
                "the \(name) source fixture must exercise a real admitted sibling")
            let newNeutral = try engine.processIrisPreviewResult(preparedImage: prepared,
                maximumPreviewEdge: 256, parameters: sibling)
            XCTAssertEqual(pixels(newNeutral.output), baseline, "\(name) p0 baseline B stays the legacy thumbnail result")
            var combined = sibling; combined.pupilSize = 0.25
            let result = try engine.processIrisPreviewResult(preparedImage: prepared,
                maximumPreviewEdge: 256, parameters: combined)
            let actual = pixels(result.output)
            XCTAssertGreaterThan(regionDelta(actual, irisPixels, width: 256, height: 192, region: region), 0,
                "\(name) cannot be cleared when iris is active")
            var outsideDelta = 0
            for y in 0..<192 { for x in 0..<256 {
                let sourcePoint = SIMD2((Double(x) + 0.5) * 2, (Double(y) + 0.5) * 2)
                let irisWindow = (1 + 100.0 / 79) * 12
                let insideIrisDomain = [0.32, 0.68].contains { cx in
                    let v = sourcePoint - SIMD2(cx * 512, 0.4 * 384)
                    return hypot(v.x, v.y) < irisWindow
                }
                if !insideIrisDomain { for channel in 0..<4 {
                    let index = (y * 256 + x) * 4 + channel
                    outsideDelta += abs(Int(actual[index]) - Int(baseline[index]))
                } }
            } }
            XCTAssertEqual(outsideDelta, 0, "\(name) outside the fixed full-source iris window must equal legacy B")
        }
        XCTAssertEqual(probe.calls, 1, "all combinations reuse original geometry; iris cannot trigger edited-output redetection")
        XCTAssertEqual(probe.extents, [CGSize(width: 512, height: 384)])
        XCTAssertEqual(probe.fingerprints, [fingerprint(pixels(CIImage(cgImage: source)))])
    }

    func testTextureMaskUsesOriginalGridAndNeverMasksOutIrisIntent() throws {
        let probe = Probe(observations: [try observation()])
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let prepared = try engine.prepareStillImage(image: image())
        let wrong = try BeautyTextureExclusionMask(width: 256, height: 192, bytes: Array(repeating: 255, count: 256 * 192))
        assertInvalid { try engine.processIrisPreviewResult(preparedImage: prepared, maximumPreviewEdge: 256,
            parameters: .init(skinSmoothing: 0.2, pupilSize: 0.25), textureExclusionMask: wrong) }
        XCTAssertEqual(probe.calls, 0)
        let full = try BeautyTextureExclusionMask(width: 512, height: 384, bytes: Array(repeating: 255, count: 512 * 384))
        let iris = try engine.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: 256, parameters: .init(pupilSize: 0.25))
        let masked = try engine.processIrisPreviewResult(preparedImage: prepared, maximumPreviewEdge: 256,
            parameters: .init(skinSmoothing: 0.2, pupilSize: 0.25), textureExclusionMask: full)
        XCTAssertEqual(pixels(masked.output), pixels(iris.output), "full texture exclusion protects texture while leaving iris active")
        XCTAssertGreaterThan(masked.metrics["beauty.irisPreview.completedEyeCount"] ?? 0, 0)
    }

    private func assertCPUMetrics(_ result: BeautyResult<CIImage>, sourceWidth: Int, sourceHeight: Int, maximumEdge: Int,
                                  file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(result.metrics["beauty.irisPreview.originalFirstCPU"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.irisPreview.maximumEdge"], Double(maximumEdge), file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.irisPreview.sourceWidth"], Double(sourceWidth), file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.irisPreview.sourceHeight"], Double(sourceHeight), file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.irisPreview.outputWidth"], Double(result.output.extent.width), file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.irisPreview.outputHeight"], Double(result.output.extent.height), file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.irisPreview.colorTexturePasses"], 2, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.irisPreview.sourceRefinerPasses"], 2, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.irisPreview.originalIRPrefixPasses"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.irisPreview.previewBaselinePrefixPasses"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.irisPreview.postGeometryPasses"], 1, file: file, line: line)
        XCTAssertNil(result.metrics["beauty.backend.cpuGeometryCapacityFallback"], file: file, line: line)
        XCTAssertTrue(result.metrics.values.allSatisfy(\.isFinite), file: file, line: line)
    }

    private func assertInvalid(_ work: () throws -> BeautyResult<CIImage>, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try work(), file: file, line: line) { XCTAssertEqual($0 as? BeautyError, .invalidInput, file: file, line: line) }
    }

    private func pixels(_ image: CIImage) -> [UInt8] {
        let width = Int(image.extent.width), height = Int(image.extent.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        context.render(image, toBitmap: &bytes, rowBytes: width * 4, bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        return bytes
    }

    private func fingerprint(_ bytes: [UInt8]) -> UInt64 { Self.fingerprint(bytes) }
    private static func fingerprint(_ bytes: [UInt8]) -> UInt64 {
        bytes.reduce(UInt64(14695981039346656037)) { ($0 ^ UInt64($1)) &* 1099511628211 }
    }

    private func regionDelta(_ a: [UInt8], _ b: [UInt8], width: Int, height: Int, region: CGRect) -> Int {
        var delta = 0
        for y in 0..<height { for x in 0..<width {
            if region.contains(CGPoint(x: (Double(x) + 0.5) / Double(width), y: (Double(y) + 0.5) / Double(height))) {
                for channel in 0..<3 { let i = (y * width + x) * 4 + channel; delta += abs(Int(a[i]) - Int(b[i])) }
            }
        } }
        return delta
    }

    private func legacyThumbnail(_ source: CGImage, maximumEdge: Int) throws -> CGImage {
        let data = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(data, "public.png" as CFString, 1, nil))
        CGImageDestinationAddImage(destination, source, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        let imageSource = try XCTUnwrap(CGImageSourceCreateWithData(data, nil))
        return try XCTUnwrap(CGImageSourceCreateThumbnailAtIndex(imageSource, 0, [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumEdge,
            kCGImageSourceShouldCacheImmediately: true,
        ] as CFDictionary))
    }

    private func observation() throws -> BeautyFaceObservation {
        func ellipse(_ x: Double, _ y: Double, _ rx: Double, _ ry: Double, _ n: Int = 16) -> [CoordinatePoint] {
            (0..<n).map { let a = Double($0) * 2 * Double.pi / Double(n); return CoordinatePoint(x: x + rx * cos(a), y: y + ry * sin(a)) }
        }
        var points = Array(repeating: SIMD3<Float>(0.5, 0.5, 0), count: 478)
        func put(_ index: Int, _ x: Double, _ y: Double) { points[index] = SIMD3(Float(x), Float(y), 0) }
        func putEllipse(_ indices: [Int], _ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, phase: Double = 0) {
            for (i, index) in indices.enumerated() {
                let a = phase + Double(i) * 2 * Double.pi / Double(indices.count)
                put(index, cx + rx * cos(a), cy + ry * sin(a))
            }
        }
        // Dense regional protection is real source evidence, not a set of
        // coincident placeholders. Nose admission requires complete distinct
        // eye/brow/lip paths; dense brow material requires a closed envelope.
        putEllipse(MediaPipeFaceTopology.leftEye, 0.32, 0.4, 0.09, 0.07)
        putEllipse(MediaPipeFaceTopology.rightEye, 0.68, 0.4, 0.09, 0.07)
        for (indices, side) in [(MediaPipeFaceTopology.leftBrowEnvelope, 0), (MediaPipeFaceTopology.rightBrowEnvelope, 1)] {
            let trace = brow(side), halfEnvelopeHeight = 0.011
            let upper = trace.map { CoordinatePoint(x: $0.x, y: $0.y - halfEnvelopeHeight) }
            let lower = trace.reversed().map { CoordinatePoint(x: $0.x, y: $0.y + halfEnvelopeHeight) }
            for (index, point) in zip(indices, upper + lower) { put(index, point.x, point.y) }
        }
        putEllipse(MediaPipeFaceTopology.outerLip, 0.5, 0.7, 0.1, 0.03, phase: Double.pi)
        putEllipse(MediaPipeFaceTopology.innerLip, 0.5, 0.7, 0.075, 0.008, phase: Double.pi)
        putEllipse(MediaPipeFaceTopology.noseContour, 0.5, 0.555, 0.055, 0.05)
        for (index, y) in zip(MediaPipeFaceTopology.noseCrest, [0.44, 0.46, 0.49, 0.52, 0.54, 0.56, 0.565]) { put(index, 0.5, y) }
        put(193, 0.47, 0.44); put(417, 0.53, 0.44)
        for (indices, cx) in [(MediaPipeFaceTopology.leftIris, 0.32), (MediaPipeFaceTopology.rightIris, 0.68)] {
            for (index, landmark) in indices.enumerated() {
                let a = Double(index) * Double.pi / 2
                points[landmark] = SIMD3(Float(cx + 12 * cos(a) / 512), Float(0.4 + 12 * sin(a) / 384), 0)
            }
        }
        points[468] = SIMD3(0.32, 0.4, 0); points[473] = SIMD3(0.68, 0.4, 0)
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points))
        return BeautyFaceObservation(stableID: "iris-preview-analytic", confidence: 1,
            imageBounds: CoordinateRect(x: 0.13, y: 0.1, width: 0.74, height: 0.8),
            observedEyeSupport: [
                BeautyObservedEyeSupport(side: .left, contour: ellipse(0.32, 0.4, 0.09, 0.07), pupil: [CoordinatePoint(x: 0.32, y: 0.4)]),
                BeautyObservedEyeSupport(side: .right, contour: ellipse(0.68, 0.4, 0.09, 0.07), pupil: [CoordinatePoint(x: 0.68, y: 0.4)])
            ], observedEyeOrder: .canonical,
            observedFaceSupport: BeautyObservedFaceSupport(contour: ellipse(0.5, 0.5, 0.32, 0.4),
                medianLine: [CoordinatePoint(x: 0.5, y: 0.25), CoordinatePoint(x: 0.5, y: 0.85)]),
            observedEyebrowSupport: BeautyObservedEyebrowSupport(left: brow(0), right: brow(1)),
            observedLipSupport: BeautyObservedLipSupport(outer: ellipse(0.5, 0.7, 0.1, 0.03, 32), inner: ellipse(0.5, 0.7, 0.075, 0.008, 20)),
            observedNoseSupport: BeautyObservedNoseSupport(crest: [CoordinatePoint(x: 0.5, y: 0.44), CoordinatePoint(x: 0.5, y: 0.5), CoordinatePoint(x: 0.5, y: 0.56)],
                contour: [CoordinatePoint(x: 0.445, y: 0.54), CoordinatePoint(x: 0.46, y: 0.6), CoordinatePoint(x: 0.5, y: 0.605), CoordinatePoint(x: 0.54, y: 0.6), CoordinatePoint(x: 0.555, y: 0.54)]), mesh: mesh)
    }

    private func brow(_ side: Int) -> [CoordinatePoint] {
        let xs = side == 0 ? [0.41, 0.37, 0.32, 0.27, 0.23] : [0.59, 0.63, 0.68, 0.73, 0.77]
        return zip(xs, [0.285, 0.255, 0.245, 0.255, 0.285]).map { CoordinatePoint(x: $0.0, y: $0.1) }
    }

    private func image(width: Int = 512, height: Int = 384, seed: Int = 0) throws -> CGImage {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        let paths = [brow(0), brow(1)].map { $0.map { SIMD2($0.x * Double(width), $0.y * Double(height)) } }
        func distance(_ p: SIMD2<Double>, _ path: [SIMD2<Double>]) -> Double {
            zip(path, path.dropFirst()).map { a, b in
                let e = b - a, v = p - a, t = max(0, min(1, (v.x * e.x + v.y * e.y) / (e.x * e.x + e.y * e.y)))
                let q = v - e * t; return hypot(q.x, q.y)
            }.min()!
        }
        for y in 0..<height { for x in 0..<width {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5), nx = p.x / Double(width), ny = p.y / Double(height)
            var rgb = SIMD3<Double>(210 + Double((x * 7 + y * 3 + seed) % 13), 174 + Double((x * 5 + y * 11 + seed) % 17), 146 + Double((x + y * 3 + seed) % 13))
            for cx in [0.32, 0.68] {
                let eye = pow((nx - cx) / 0.09, 2) + pow((ny - 0.4) / 0.07, 2)
                if eye < 1 {
                    let v = p - SIMD2(cx * Double(width), 0.4 * Double(height)), r = hypot(v.x, v.y)
                    let radius = 12 * Double(width) / 512, coverage = max(0, min(1, radius + 0.5 - r))
                    rgb = SIMD3(200 - 160 * coverage, 220 + coverage * (105 + 25 * sin(v.x * 0.7) - 220), 220 + coverage * (112 + 22 * cos(v.y * 0.8) - 220))
                }
            }
            if paths.contains(where: { distance(p, $0) <= 0.008 * Double(width) }) {
                let value = Double(28 + (x * 31 + y * 17) % 38); rgb = SIMD3(repeating: value)
            }
            if (0.43...0.57).contains(nx) && (0.49...0.615).contains(ny) {
                rgb = SIMD3(174 + Double(x % 7), 93 + Double((x + y) % 31), 64 + Double(y % 5))
            }
            let oral = pow((nx - 0.5) / 0.1, 2) + pow((ny - 0.7) / 0.03, 2)
            if oral <= 1 { rgb = SIMD3(154, 44, 57 + Double((x * 3 + y) % 27)) }
            if pow((nx - 0.5) / 0.075, 2) + pow((ny - 0.7) / 0.008, 2) <= 1 { rgb = SIMD3(25, 35 + Double(x % 9), 45) }
            let offset = (y * width + x) * 4
            for channel in 0..<3 { bytes[offset + channel] = UInt8(rgb[channel].rounded()) }
        } }
        return try XCTUnwrap(CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4,
            space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
            provider: CGDataProvider(data: Data(bytes) as CFData)!, decode: nil, shouldInterpolate: false, intent: .defaultIntent))
    }

    private final class Probe: @unchecked Sendable {
        private let lock = NSLock()
        private let observations: [BeautyFaceObservation]
        private var count = 0, seenExtents = [CGSize](), seenFingerprints = [UInt64]()
        var calls: Int { lock.withLock { count } }
        var extents: [CGSize] { lock.withLock { seenExtents } }
        var fingerprints: [UInt64] { lock.withLock { seenFingerprints } }
        init(observations: [BeautyFaceObservation]) { self.observations = observations }
        func detector() -> BeautyFaceDetector {
            BeautyFaceDetector(mappedObservationProvider: { [self] input in
                lock.withLock {
                    count += 1; seenExtents.append(input.imageExtent)
                    if let image = input.stillImage {
                        let width = Int(image.extent.width), height = Int(image.extent.height)
                        var rgba = [UInt8](repeating: 0, count: width * height * 4)
                        CIContext(options: [.cacheIntermediates: false]).render(image, toBitmap: &rgba, rowBytes: width * 4,
                            bounds: image.extent, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
                        seenFingerprints.append(BeautyEngineIrisPreviewTests.fingerprint(rgba))
                    }
                    return BeautyMappedFaceObservations(observations: observations)
                }
            })
        }
    }

    private final class UnusedExecutor: BeautyBackendExecutor {
        private(set) var calls = 0
        func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult {
            calls += 1
            throw BeautyError.renderFailed("unexpected_preview_backend")
        }
    }
}
