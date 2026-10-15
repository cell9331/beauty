#if os(iOS)
    import XCTest
    import CoreImage
    import ImageIO
    import BeautySDK
    @testable import BeautyDetection
    @testable import BeautyEffects

    final class BeautySDKMediaPipeIntegrationTests: XCTestCase {
        private func image(_ id: String = "portrait_002") throws -> CIImage {
            let ext = id == "portrait_001" ? "jpg" : "png"
            let url = try XCTUnwrap(
                Bundle.main.url(forResource: id, withExtension: ext),
                "authorized native portrait fixture is required")
            let decoded = try XCTUnwrap(CGImageSourceCreateWithURL(url as CFURL, nil))
            let cg = try XCTUnwrap(CGImageSourceCreateImageAtIndex(decoded, 0, nil))
            let source = CIImage(cgImage: cg, options: [.colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])
            let scale = min(1, 512 / max(source.extent.width, source.extent.height))
            return source.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
                .cropped(
                    to: CGRect(
                        x: 0, y: 0, width: floor(source.extent.width * scale),
                        height: floor(source.extent.height * scale)))
        }

        func testBothPortraitsSupplyDenseMeshPoseAndValidatedEffectSupport() throws {
            var detector = BeautyFaceDetector.production()
            for id in ["portrait_001", "portrait_002"] {
                let input = try image(id)
                let result = detector.detect(
                    image: input, metadata: .init(orientation: .up, source: .testFixture),
                    imageExtent: input.extent.size)
                XCTAssertEqual(result.summary.availability, .usable)
                let face = try XCTUnwrap(result.observations.first)
                let mesh = try XCTUnwrap(face.mesh)
                XCTAssertEqual(mesh.points.count, 478)
                XCTAssertEqual(mesh.facialTransformation?.count, 16)
                let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: face)
                XCTAssertNotNil(geometry.leftEyeSupport)
                XCTAssertNotNil(geometry.rightEyeSupport)
                XCTAssertNotNil(geometry.observedFaceSupport)
                XCTAssertNotNil(geometry.observedEyebrowSupport)
                XCTAssertEqual(geometry.faceContour.count, 21)
                XCTAssertEqual(geometry.outerLips.count, 20)
                XCTAssertEqual(geometry.nose.count, 16)
            }
        }

        func testPublicEngineFaceSlimChangesPixelsWithBundledModel() throws {
            let input = try image("portrait_001")
            let engine = try BeautyEngine()
            let neutral = try engine.processResult(
                image: input, metadata: .init(orientation: .up, source: .photo),
                parameters: BeautyParameters())
            let result = try engine.processResult(
                image: input, metadata: .init(orientation: .up, source: .photo),
                parameters: BeautyParameters(faceSlim: 0.4))
            XCTAssertEqual(result.detectionSummary?.availability, .usable)
            XCTAssertEqual(result.metrics["beauty.detection.meshPointCount"], 478)
            XCTAssertEqual(result.metrics["beauty.detection.hasFacialTransformation"], 1)
            XCTAssertGreaterThan(result.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
            XCTAssertEqual(result.output.extent.size, input.extent.size)
            XCTAssertFalse(
                pixels(result.output) == pixels(neutral.output), "face geometry did not reach output pixels")
        }

        func testPublicEngineTwentyRepeatsNoFaceRecoveryAndReset() throws {
            let input = try image()
            let engine = try BeautyEngine()
            let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
            let parameters = BeautyParameters(noseRootNarrowing: 0.5)
            let first = try engine.processResult(image: input, metadata: metadata, parameters: parameters)
            XCTAssertEqual(first.detectionSummary?.availability, .usable)
            XCTAssertGreaterThan(first.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
            let reference = pixels(first.output)
            for _ in 0..<20 {
                let next = try engine.processResult(image: input, metadata: metadata, parameters: parameters)
                XCTAssertEqual(next.detectionSummary?.availability, .usable)
                XCTAssertEqual(next.metrics["beauty.detection.meshPointCount"], 478)
                XCTAssertTrue(pixels(next.output) == reference, "SDK repeat output differs")
            }
            let noFace = CIImage(color: CIColor(red: 0.5, green: 0.5, blue: 0.5))
                .cropped(to: CGRect(x: 0, y: 0, width: 256, height: 256))
            let noFaceResult = try engine.processResult(
                image: noFace, metadata: metadata, parameters: parameters)
            XCTAssertEqual(noFaceResult.detectionSummary?.availability, .noFace)
            XCTAssertNil(noFaceResult.metrics["beauty.detection.meshPointCount"])
            XCTAssertTrue(pixels(noFaceResult.output) == pixels(noFace))
            let recovered = try engine.processResult(image: input, metadata: metadata, parameters: parameters)
            XCTAssertTrue(pixels(recovered.output) == reference)
            engine.reset()
            let reset = try engine.processResult(image: input, metadata: metadata, parameters: parameters)
            XCTAssertTrue(pixels(reset.output) == reference)
        }

        func testPublicEngineIntervalAndDisabledDetectionDoNotReuseSupport() throws {
            let input = try image()
            let parameters = BeautyParameters(faceSlim: 0.4)
            let engine = try BeautyEngine(configuration: .init(detectionFrameInterval: 3))
            let metadata = BeautyInputMetadata(orientation: .up, source: .video)
            let detected = try engine.processResult(
                image: input, metadata: metadata, frameIndex: 0, parameters: parameters)
            XCTAssertEqual(detected.detectionSummary?.availability, .usable)
            let skipped = try engine.processResult(
                image: input, metadata: metadata, frameIndex: 1, parameters: parameters)
            XCTAssertEqual(skipped.detectionSummary?.reasons, [.detectionInterval])
            XCTAssertNil(skipped.metrics["beauty.detection.meshPointCount"])
            XCTAssertTrue(pixels(skipped.output) == pixels(input))
            let disabled = try BeautyEngine(configuration: .init(enableFaceTracking: false))
                .processResult(image: input, metadata: metadata, parameters: parameters)
            XCTAssertEqual(disabled.detectionSummary?.availability, .disabled)
            XCTAssertTrue(pixels(disabled.output) == pixels(input))
        }

        func testNativeDensePoseIrisAndSharedBackendCombination() throws {
            for id in ["portrait_001", "portrait_002"] {
                let input = try image(id)
                let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
                var detector = BeautyFaceDetector.production()
                let detected = detector.detect(
                    image: input, metadata: metadata, imageExtent: input.extent.size)
                let observation = try XCTUnwrap(detected.observations.first)
                let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
                let dense = try XCTUnwrap(face.denseSupport)
                XCTAssertNotNil(BeautyDenseFaceSupport.poseScale(dense.mesh.facialTransformation))
                XCTAssertGreaterThan(dense.geometryScale, 0)
                let rings = [face.leftEyeSupport, face.rightEyeSupport].compactMap { $0 }.compactMap {
                    dense.iris(side: $0.side, eye: $0)
                }
                XCTAssertGreaterThanOrEqual(rings.count, 1)
                let parameters = BeautyParameters(
                    skinSmoothing: 0.5, skinSharpen: 0.3,
                    faceSlim: 0.4, eyeSize: 0.3, pupilSize: 0.2, noseRootNarrowing: 0.4, mouthWidth: 0.2)
                let cpu = try BeautyEngine()
                let neutral = try cpu.processResult(image: input, metadata: metadata, parameters: .init())
                let first = try cpu.processResult(image: input, metadata: metadata, parameters: parameters)
                let second = try cpu.processResult(image: input, metadata: metadata, parameters: parameters)
                XCTAssertTrue(pixels(first.output) == pixels(second.output))
                XCTAssertFalse(pixels(first.output) == pixels(neutral.output))
                XCTAssertEqual(first.output.extent.size, input.extent.size)
                let gpu = try BeautyEngine(configuration: .init(renderBackend: .gpu))
                let metal = try gpu.processResult(image: input, metadata: metadata, parameters: parameters)
                let a = pixels(first.output)
                let b = pixels(metal.output)
                XCTAssertEqual(a.count, b.count)
                let maximumDelta = zip(a, b).map { abs(Int($0) - Int($1)) }.max() ?? 255
                XCTAssertLessThanOrEqual(maximumDelta, 2)
                XCTAssertTrue(stride(from: 3, to: a.count, by: 4).allSatisfy { a[$0] == 255 && b[$0] == 255 })
            }
        }

        private func pixels(_ image: CIImage) -> [UInt8] {
            let width = Int(image.extent.width)
            let height = Int(image.extent.height)
            let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
            var bytes = [UInt8](repeating: 0, count: width * height * 4)
            CIContext(options: [.workingColorSpace: sRGB, .outputColorSpace: sRGB])
                .render(
                    image, toBitmap: &bytes, rowBytes: width * 4, bounds: image.extent, format: .RGBA8,
                    colorSpace: sRGB)
            return bytes
        }
    }

#endif
