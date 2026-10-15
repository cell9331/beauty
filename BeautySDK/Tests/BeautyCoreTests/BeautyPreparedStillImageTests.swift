import BeautyCore
import BeautyDetection
import BeautyEffects
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautySDK

final class BeautyPreparedStillImageTests: XCTestCase {
    private let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
    private let context = CIContext(options: [.cacheIntermediates: false])

    func testLazyReuseMatchesFreshPixelsAndNeverAccumulatesEdits() throws {
        let probe = Probe()
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let source = image()
        let prepared = try engine.prepareStillImage(image: source)
        XCTAssertEqual(probe.calls, 0)
        let neutral = try engine.processResult(preparedImage: prepared, parameters: .init())
        XCTAssertEqual(pixels(neutral.output), pixels(CIImage(cgImage: source)))
        XCTAssertEqual(probe.calls, 0)
        let snapshots = [BeautyParameters(eyeSize: 0.1), BeautyParameters(eyeSize: 0.3),
                         BeautyParameters(eyeSize: 0.1, noseWingSlim: 0.2)]
        var first: [UInt8] = []
        for (index, parameters) in snapshots.enumerated() {
            let edited = try engine.processResult(preparedImage: prepared, parameters: parameters)
            let fresh = try BeautyEngine(faceDetector: Probe().detector()).processResult(
                image: CIImage(cgImage: source), metadata: metadata, parameters: parameters)
            XCTAssertEqual(pixels(edited.output), pixels(fresh.output))
            XCTAssertEqual(edited.detectionSummary, fresh.detectionSummary)
            XCTAssertEqual(edited.warnings, fresh.warnings)
            XCTAssertEqual(edited.metrics["beauty.detection.preparedReuse"], index == 0 ? 0 : 1)
            if index == 0 { first = pixels(edited.output) }
        }
        XCTAssertEqual(probe.calls, 1)
        XCTAssertNotEqual(first, pixels(CIImage(cgImage: source)))
        let again = try engine.processResult(preparedImage: prepared, parameters: snapshots[0])
        XCTAssertEqual(pixels(again.output), first)
        // Ordinary requests still detect afresh and cannot consume the session.
        _ = try engine.processResult(image: CIImage(cgImage: source), metadata: metadata, parameters: snapshots[0])
        _ = try engine.processResult(image: CIImage(cgImage: source), metadata: metadata, parameters: snapshots[0])
        XCTAssertEqual(probe.calls, 3)
    }

    func testReplacementResetReleaseForeignAndFailedPreparation() throws {
        let probe = Probe()
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let old = try engine.prepareStillImage(image: image())
        let other = try BeautyEngine(faceDetector: Probe().detector())
        XCTAssertThrowsError(try other.processResult(preparedImage: old, parameters: .init())) {
            XCTAssertEqual($0 as? BeautyError, .invalidInput)
        }
        XCTAssertThrowsError(try engine.prepareStillImage(image: image(),
            metadata: BeautyInputMetadata(orientation: .up, source: .video)))
        _ = try engine.processResult(preparedImage: old, parameters: .init(eyeSize: 0.1))
        let new = try engine.prepareStillImage(image: image(width: 48, height: 32))
        XCTAssertThrowsError(try engine.processResult(preparedImage: old, parameters: .init()))
        _ = try engine.processResult(preparedImage: new, parameters: .init(eyeSize: 0.1))
        XCTAssertEqual(probe.calls, 2)
        engine.reset()
        XCTAssertThrowsError(try engine.processResult(preparedImage: new, parameters: .init()))
        let last = try engine.prepareStillImage(image: image())
        engine.releasePreparedStillImage()
        XCTAssertThrowsError(try engine.processResult(preparedImage: last, parameters: .init()))
        XCTAssertEqual(probe.calls, 2)
    }

    func testNoFaceIsReusedButInferenceFailuresRetryWithoutBorrowing() throws {
        let probe = Probe(responses: [.failure, .empty])
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let prepared = try engine.prepareStillImage(image: image())
        let parameters = BeautyParameters(eyeSize: 0.2)
        let failed = try engine.processResult(preparedImage: prepared, parameters: parameters)
        XCTAssertEqual(failed.detectionSummary?.availability, .skipped)
        XCTAssertEqual(failed.metrics["beauty.detection.preparedReuse"], 0)
        let noFace = try engine.processResult(preparedImage: prepared, parameters: parameters)
        XCTAssertEqual(noFace.detectionSummary?.availability, .noFace)
        XCTAssertEqual(noFace.metrics["beauty.detection.preparedReuse"], 0)
        let reused = try engine.processResult(preparedImage: prepared, parameters: parameters)
        XCTAssertEqual(reused.detectionSummary?.availability, .noFace)
        XCTAssertEqual(reused.metrics["beauty.detection.preparedReuse"], 1)
        XCTAssertEqual(probe.calls, 2)
        XCTAssertEqual(pixels(failed.output), pixels(reused.output))
        let replacement = try engine.prepareStillImage(image: image())
        _ = try engine.processResult(preparedImage: replacement, parameters: parameters)
        XCTAssertEqual(probe.calls, 3)
    }

    func testPartialOutcomesRetryAndDetectionPurposesNeverShareCache() throws {
        let probe = Probe(responses: [.face, .failure, .face, .partial, .partial])
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let prepared = try engine.prepareStillImage(image: image())
        _ = try engine.processResult(preparedImage: prepared, parameters: .init(eyeSize: 0.1))
        let local = BeautyParameters(teethWhitening: 0.2)
        let failed = try engine.processResult(preparedImage: prepared, parameters: local)
        XCTAssertEqual(failed.detectionSummary?.availability, .skipped)
        XCTAssertEqual(failed.detectionSummary?.usedFaceCount, 0)
        _ = try engine.processResult(preparedImage: prepared, parameters: local)
        _ = try engine.processResult(preparedImage: prepared, parameters: local)
        XCTAssertEqual(probe.calls, 3)
        // Explicit rejected-face evidence remains partial and is retried.
        let combined = BeautyParameters(eyeSize: 0.1, teethWhitening: 0.2)
        let partial = try engine.processResult(preparedImage: prepared, parameters: combined)
        XCTAssertEqual(partial.detectionSummary?.availability, .partial)
        _ = try engine.processResult(preparedImage: prepared, parameters: combined)
        XCTAssertEqual(probe.calls, 5)
        _ = try engine.processResult(preparedImage: prepared, parameters: .init(eyeSize: 0.2))
        XCTAssertEqual(probe.calls, 5)
    }

    func testCanonicalMaskRouteIsIndependentAndMasksRemainPerRequest() throws {
        let probe = Probe()
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let source = image()
        let prepared = try engine.prepareStillImage(image: source)
        let parameters = BeautyParameters(skinSmoothing: 0.2)
        _ = try engine.processResult(preparedImage: prepared, parameters: parameters)
        let mask = try BeautyTextureExclusionMask(width: source.width, height: source.height,
            bytes: Array(repeating: UInt8(255), count: source.width * source.height))
        let protected = try engine.processResult(preparedImage: prepared, parameters: parameters,
            textureExclusionMask: mask)
        let fresh = try BeautyEngine(faceDetector: Probe().detector()).processResult(
            image: CIImage(cgImage: source), metadata: metadata, parameters: parameters,
            textureExclusionMask: mask)
        XCTAssertEqual(pixels(protected.output), pixels(fresh.output))
        XCTAssertEqual(pixels(protected.output), pixels(CIImage(cgImage: source)))
        _ = try engine.processResult(preparedImage: prepared, parameters: parameters, textureExclusionMask: mask)
        XCTAssertEqual(probe.calls, 2)
        let wrongMask = try BeautyTextureExclusionMask(width: 1, height: 1, bytes: [255])
        XCTAssertThrowsError(try engine.processResult(preparedImage: prepared, parameters: parameters,
            textureExclusionMask: wrongMask))
        XCTAssertEqual(probe.calls, 2)
    }

    func testOrientationMirrorColorAlphaAndReflectionMatchFreshRoute() throws {
        let source = image(alpha: 128, colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!)
        for raw in UInt32(1)...8 {
            let engine = try BeautyEngine(faceDetector: Probe(responses: [.empty]).detector())
            let metadata = BeautyInputMetadata(orientation: CGImagePropertyOrientation(rawValue: raw)!,
                isInputMirrored: true, isPreviewMirrored: true, source: .photo)
            let prepared = try engine.prepareStillImage(image: source, metadata: metadata)
            let edited = try engine.processResult(preparedImage: prepared, parameters: .init(brightness: 0.1))
            let fresh = try engine.processResult(image: CIImage(cgImage: source), metadata: metadata,
                                                parameters: .init(brightness: 0.1))
            XCTAssertEqual(edited.output.extent, fresh.output.extent)
            XCTAssertEqual(pixels(edited.output), pixels(fresh.output))
            let output = pixels(edited.output)
            XCTAssertTrue(stride(from: 3, to: output.count, by: 4).allSatisfy { output[$0] == 128 })
            var reflection = ""; dump(prepared, to: &reflection)
            XCTAssertFalse(reflection.contains("identifier"))
            XCTAssertFalse(reflection.contains("image:"))
            XCTAssertFalse(reflection.contains("observations"))
        }
    }

    func testDeepSnapshotSurvivesMutableProviderAndInputBudgetsFailBeforeDetection() throws {
        let width = 16, height = 12, count = width * height * 4
        let memory = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: 1)
        memory.initializeMemory(as: UInt8.self, repeating: 80, count: count)
        for index in stride(from: 3, to: count, by: 4) { memory.storeBytes(of: UInt8(255), toByteOffset: index, as: UInt8.self) }
        let provider = CGDataProvider(dataInfo: nil, data: memory, size: count,
            releaseData: { _, bytes, _ in UnsafeMutableRawPointer(mutating: bytes).deallocate() })!
        let source = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
            bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue), provider: provider,
            decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
        let probe = Probe()
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let prepared = try engine.prepareStillImage(image: source)
        let before = try engine.processResult(preparedImage: prepared, parameters: .init())
        let original = pixels(before.output)
        memory.initializeMemory(as: UInt8.self, repeating: 0, count: count)
        let after = try engine.processResult(preparedImage: prepared, parameters: .init())
        XCTAssertEqual(pixels(after.output), original)
        XCTAssertEqual(probe.calls, 0)
        let bounded = try BeautyEngine(configuration: BeautyConfiguration(maximumInputPixelCount: 100),
            faceDetector: probe.detector())
        XCTAssertThrowsError(try bounded.prepareStillImage(image: source)) {
            XCTAssertEqual($0 as? BeautyError, .invalidInput)
        }
        XCTAssertEqual(probe.calls, 0)
    }

    func testMetalPreparedPixelsMatchFreshAndAlphaFailureDoesNotConsumeSupport() throws {
        let configuration = BeautyConfiguration(renderBackend: .gpu)
        let selection = try BeautyBackendFactory.select(configuration: configuration)
        let probe = Probe()
        let engine = try BeautyEngine(configuration: configuration, faceDetector: probe.detector(),
            backendExecutor: selection.executor)
        let source = image()
        let prepared = try engine.prepareStillImage(image: source)
        let parameters = BeautyParameters(eyeSize: 0.2)
        let one = try engine.processResult(preparedImage: prepared, parameters: parameters)
        let two = try engine.processResult(preparedImage: prepared, parameters: parameters)
        let fresh = try engine.processResult(image: CIImage(cgImage: source), metadata: metadata, parameters: parameters)
        XCTAssertEqual(pixels(one.output), pixels(fresh.output))
        XCTAssertEqual(pixels(two.output), pixels(fresh.output))
        XCTAssertEqual(two.metrics["beauty.detection.preparedReuse"], 1)
        XCTAssertEqual(probe.calls, 2)
        let transparent = image(alpha: 128)
        let rejected = try engine.prepareStillImage(image: transparent)
        var referenceError: BeautyError?
        XCTAssertThrowsError(try engine.processResult(image: CIImage(cgImage: transparent),
            metadata: metadata, parameters: parameters)) { referenceError = $0 as? BeautyError }
        XCTAssertNotNil(referenceError)
        XCTAssertThrowsError(try engine.processResult(preparedImage: rejected, parameters: parameters)) {
            XCTAssertEqual($0 as? BeautyError, referenceError)
        }
        XCTAssertEqual(probe.calls, 2)
    }

    func testDisabledDetectionAndOversizedRowStorageDoNotInfer() throws {
        let probe = Probe()
        let engine = try BeautyEngine(configuration: BeautyConfiguration(enableFaceTracking: false),
            faceDetector: probe.detector())
        let prepared = try engine.prepareStillImage(image: image())
        for _ in 0..<2 {
            let result = try engine.processResult(preparedImage: prepared, parameters: .init(eyeSize: 0.2))
            XCTAssertEqual(result.detectionSummary?.availability, .disabled)
            XCTAssertNil(result.metrics["beauty.detection.preparedReuse"])
        }
        let padded = CGImage(width: 1, height: 1, bitsPerComponent: 8, bitsPerPixel: 32,
            bytesPerRow: 8, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
            provider: CGDataProvider(data: Data([80, 80, 80, 255, 0, 0, 0, 0]) as CFData)!,
            decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
        let tiny = try BeautyEngine(configuration: BeautyConfiguration(maximumInputPixelCount: 1),
            faceDetector: probe.detector())
        XCTAssertThrowsError(try tiny.prepareStillImage(image: padded)) {
            XCTAssertEqual($0 as? BeautyError, .invalidInput)
        }
        XCTAssertEqual(probe.calls, 0)
    }

    private func image(width: Int = 64, height: Int = 48, alpha: UInt8 = 255,
                       colorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!) -> CGImage {
        var bytes: [UInt8] = []
        for y in 0..<height { for x in 0..<width {
            bytes += [UInt8((x * 7 + y * 3) % 240), UInt8((x * 3 + y * 5) % 240), 80, alpha]
        } }
        return CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
            bytesPerRow: width * 4, space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
            provider: CGDataProvider(data: Data(bytes) as CFData)!, decode: nil,
            shouldInterpolate: false, intent: .defaultIntent)!
    }

    private func pixels(_ image: CIImage) -> [UInt8] {
        let width = Int(image.extent.width), height = Int(image.extent.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        context.render(image, toBitmap: &bytes, rowBytes: width * 4, bounds: image.extent,
                       format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
        return bytes
    }

    private final class Probe: @unchecked Sendable {
        enum Response { case face, empty, failure, partial }
        private let lock = NSLock()
        private let responses: [Response]
        private var count = 0
        var calls: Int { lock.withLock { count } }
        init(responses: [Response] = [.face]) { self.responses = responses }
        func detector() -> BeautyFaceDetector {
            BeautyFaceDetector(mappedObservationProvider: { _ in
                try self.lock.withLock {
                    let response = self.responses[min(self.count, self.responses.count - 1)]
                    self.count += 1
                    switch response {
                    case .face: return BeautyMappedFaceObservations(observations: [
                        BeautyFaceObservation(imageBounds: CoordinateRect(x: 0.15, y: 0.1, width: 0.7, height: 0.8))])
                    case .partial: return BeautyMappedFaceObservations(observations: [
                        BeautyFaceObservation(imageBounds: CoordinateRect(x: 0.15, y: 0.1, width: 0.7, height: 0.8))],
                        rejectedFaceCount: 1)
                    case .empty: return BeautyMappedFaceObservations(observations: [])
                    case .failure: throw BeautyFaceDetector.Failure.detectorUnavailable
                    }
                }
            })
        }
    }
}
