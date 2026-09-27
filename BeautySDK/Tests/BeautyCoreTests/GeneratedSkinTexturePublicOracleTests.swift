import CoreGraphics
import CoreImage
import CoreVideo
import ImageIO
import XCTest
@_spi(Testing) import BeautySDK

/// FUTURE-06 source-fixed generated-image oracle. All regions and thresholds
/// were selected before replacing the saturation/contrast proxy algorithm.
final class GeneratedSkinTexturePublicOracleTests: XCTestCase {
    private let width = 64
    private let height = 64
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    func testSmoothingReducesActualTextureAndProtectsFlatBackground() throws {
        let source = fixture(.textured)
        let neutral = try render(source, parameters: .init())
        let first = try render(source, parameters: BeautyParameters(skinSmoothing: 1))
        let repeated = try render(source, parameters: BeautyParameters(skinSmoothing: 1))

        XCTAssertTrue(neutral == source)
        XCTAssertTrue(first == repeated)
        XCTAssertLessThan(textureDeviation(first), textureDeviation(source) * 0.65)
        XCTAssertEqual(changed(source, first, in: .target), true)
        XCTAssertEqual(changed(source, first, in: .protected), false)
        XCTAssertTrue(alpha(first) == alpha(source))
    }

    func testSharpenIncreasesSoftSkinEdgeWithoutChangingHardBoundary() throws {
        let source = fixture(.softEdge)
        let first = try render(source, parameters: BeautyParameters(skinSharpen: 1))
        let repeated = try render(source, parameters: BeautyParameters(skinSharpen: 1))

        XCTAssertTrue(first == repeated)
        XCTAssertGreaterThan(softEdgeGradient(first), softEdgeGradient(source) * 1.20)
        XCTAssertLessThanOrEqual(maxChannelDelta(source, first), 16)
        XCTAssertEqual(changed(source, first, in: .protected), false)
        XCTAssertTrue(alpha(first) == alpha(source))
    }

    func testFlatNegativeAndTransparentFootprintRemainSourceExact() throws {
        let flat = fixture(.flat)
        for parameters in [BeautyParameters(skinSmoothing: 1), BeautyParameters(skinSharpen: 1)] {
            XCTAssertTrue(try render(flat, parameters: parameters) == flat)
        }

        let translucent = fixture(.textured, translucent: true)
        for parameters in [BeautyParameters(skinSmoothing: 1), BeautyParameters(skinSharpen: 1)] {
            let output = try render(translucent, parameters: parameters)
            XCTAssertTrue(alpha(output) == alpha(translucent))
            XCTAssertEqual(changed(translucent, output, in: .translucent), false)
        }
    }

    func testNamedSRGBExtentAndTypedPixelLimitRecovery() throws {
        let source = fixture(.textured)
        let image = makeImage(source).transformed(by: CGAffineTransform(translationX: 7, y: -3))
        let engine = try textureEngine()
        let result = try engine.processResult(
            image: image, metadata: metadata,
            parameters: BeautyParameters(skinSmoothing: 1)
        )
        XCTAssertEqual(result.output.extent, image.extent)
        XCTAssertEqual(result.output.colorSpace?.name, CGColorSpace(name: CGColorSpace.sRGB)?.name)
        XCTAssertLessThan(textureDeviation(bytes(result.output, extent: image.extent)), textureDeviation(source) * 0.65)

        let limitedEngine = try textureEngine(.init(maximumInputPixelCount: 4_095))
        XCTAssertThrowsError(try limitedEngine.processResult(
            image: makeImage(source), metadata: metadata,
            parameters: BeautyParameters(skinSharpen: 1)
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        XCTAssertEqual(try render(source, parameters: BeautyParameters(skinSharpen: 1)).count, source.count)
    }

    func testOrientationMirrorAndDisplayP3KeepTextureDirectionAndProtection() throws {
        let source = fixture(.textured)
        let image = makeImage(source)
        for orientation: CGImagePropertyOrientation in [.up, .upMirrored, .down, .leftMirrored] {
            for mirrored in [false, true] {
                let metadata = BeautyInputMetadata(
                    orientation: orientation, isInputMirrored: mirrored, source: .testFixture
                )
                let neutral = try textureEngine().processResult(
                    image: image, metadata: metadata, parameters: .init()
                )
                let candidate = try textureEngine().processResult(
                    image: image, metadata: metadata,
                    parameters: BeautyParameters(skinSmoothing: 1)
                )
                let before = bytes(neutral.output, extent: neutral.output.extent)
                let after = bytes(candidate.output, extent: candidate.output.extent)
                XCTAssertEqual(candidate.output.extent, neutral.output.extent)
                XCTAssertLessThan(textureDeviation(after), textureDeviation(before) * 0.65)
                XCTAssertFalse(changed(before, after, in: .protected))
                XCTAssertTrue(alpha(before) == alpha(after))
            }
        }

        let p3 = try XCTUnwrap(CGColorSpace(name: CGColorSpace.displayP3))
        let p3Image = makeImage(source, colorSpace: p3)
        let candidate = try textureEngine().processResult(
            image: p3Image, metadata: metadata,
            parameters: BeautyParameters(skinSmoothing: 1)
        )
        let before = bytes(p3Image, extent: p3Image.extent, colorSpace: p3)
        let after = bytes(candidate.output, extent: candidate.output.extent, colorSpace: p3)
        XCTAssertEqual(candidate.output.colorSpace?.name, p3.name)
        XCTAssertLessThan(textureDeviation(after), textureDeviation(before) * 0.65)
        XCTAssertFalse(changed(before, after, in: .protected))
    }

    func testGeneratedPortraitCheekTextureImprovesWhileFeaturesStayExact() throws {
        let positive = portraitFixture(textured: true)
        let negative = portraitFixture(textured: false)
        let candidate = try render(positive, parameters: BeautyParameters(skinSmoothing: 1))
        let flat = try render(negative, parameters: BeautyParameters(skinSmoothing: 1))

        XCTAssertLessThan(portraitCheekDeviation(candidate), portraitCheekDeviation(positive) * 0.65)
        XCTAssertFalse(portraitProtectedChanged(positive, candidate))
        XCTAssertTrue(flat == negative)
        XCTAssertTrue(alpha(candidate) == alpha(positive))
    }

    func testWarmLowContrastEyeAndLipTextureStayExactWhileCheekChanges() throws {
        let source = portraitFixture(textured: true, warmFeaturesTextured: true)
        for parameters in [
            BeautyParameters(skinSmoothing: 1),
            BeautyParameters(skinSharpen: 1),
        ] {
            let output = try render(source, parameters: parameters)
            func changes(_ columns: Range<Int>, _ rows: Range<Int>) -> Int {
                rows.reduce(0) { total, y in
                    total + columns.reduce(0) { rowTotal, x in
                        let offset = (y * width + x) * 4
                        return rowTotal + ((0..<3).contains {
                            source[offset + $0] != output[offset + $0]
                        } ? 1 : 0)
                    }
                }
            }
            XCTAssertGreaterThan(changes(22..<28, 36..<42), 0)
            XCTAssertEqual(changes(24..<27, 26..<28), 0)
            XCTAssertEqual(changes(38..<41, 26..<28), 0)
            XCTAssertEqual(changes(29..<36, 48..<50), 0)
            XCTAssertEqual(alpha(output), alpha(source))
        }
    }

    func testLowContrastCoolBackgroundIsProtectedWhileCheekTextureChanges() throws {
        for deepSkin in [false, true] {
            let source = portraitFixture(
                textured: true, backgroundTextured: true, deepSkin: deepSkin
            )
            for parameters in [
                BeautyParameters(skinSmoothing: 1),
                BeautyParameters(skinSharpen: 1),
            ] {
                let output = try render(source, parameters: parameters)
                var cheekChanges = 0
                var backgroundChanges = 0
                for y in 30..<45 {
                    for x in 2..<12 {
                        let offset = (y * width + x) * 4
                        if Array(source[offset..<(offset + 3)]) !=
                            Array(output[offset..<(offset + 3)]) {
                            backgroundChanges += 1
                        }
                    }
                    for x in 22..<28 {
                        let offset = (y * width + x) * 4
                        if Array(source[offset..<(offset + 3)]) !=
                            Array(output[offset..<(offset + 3)]) {
                            cheekChanges += 1
                        }
                    }
                }
                XCTAssertEqual(backgroundChanges, 0)
                XCTAssertGreaterThan(cheekChanges, 0)
                XCTAssertEqual(alpha(output), alpha(source))
            }
        }
    }

    func testWarmTexturedBackgroundStaysExactWithFaceSupportAndNoFaceFailsClosed() throws {
        let source = portraitFixture(textured: true, backgroundTextured: true,
                                     backgroundWarm: true)
        for parameters in [BeautyParameters(skinSmoothing: 1),
                           BeautyParameters(skinSharpen: 1)] {
            let output = try render(source, parameters: parameters)
            var cheekChanges = 0
            var backgroundChanges = 0
            for y in 30..<45 {
                for x in 2..<12 {
                    let offset = (y * width + x) * 4
                    if Array(source[offset..<(offset + 3)]) !=
                        Array(output[offset..<(offset + 3)]) { backgroundChanges += 1 }
                }
                for x in 22..<28 {
                    let offset = (y * width + x) * 4
                    if Array(source[offset..<(offset + 3)]) !=
                        Array(output[offset..<(offset + 3)]) { cheekChanges += 1 }
                }
            }
            XCTAssertEqual(backgroundChanges, 0)
            XCTAssertGreaterThan(cheekChanges, 0)
            XCTAssertTrue(alpha(output) == alpha(source))

            let noFace = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
            ).processResult(image: makeImage(source), metadata: metadata,
                            parameters: parameters)
            XCTAssertEqual(bytes(noFace.output, extent: noFace.output.extent), source)
        }
    }

    func testPixelBufferTextureUsesFreshFaceAndProtectsWarmBackground() throws {
        let source = portraitFixture(textured: true, backgroundTextured: true,
                                     backgroundWarm: true)
        var bgra: [UInt8] = []
        bgra.reserveCapacity(source.count)
        for offset in stride(from: 0, to: source.count, by: 4) {
            bgra.append(source[offset + 2])
            bgra.append(source[offset + 1])
            bgra.append(source[offset])
            bgra.append(source[offset + 3])
        }
        let input = try PixelBufferFixtures.makeBGRA(width: width, height: height, bytes: bgra)
        let metadata = BeautyInputMetadata(orientation: .up, source: .camera)
        let parameters = BeautyParameters(skinSmoothing: 1)
        let cpu = try textureEngine().processResult(
            pixelBuffer: input, metadata: metadata, parameters: parameters
        )
        let output = try PixelBufferFixtures.bytes(from: cpu.output)
        var cheekChanges = 0
        for y in 30..<45 {
            for x in 2..<12 {
                let offset = (y * width + x) * 4
                XCTAssertEqual(Array(output[offset..<(offset + 4)]),
                               Array(bgra[offset..<(offset + 4)]))
            }
            for x in 22..<28 {
                let offset = (y * width + x) * 4
                if Array(output[offset..<(offset + 3)]) !=
                    Array(bgra[offset..<(offset + 3)]) { cheekChanges += 1 }
            }
        }
        XCTAssertGreaterThan(cheekChanges, 0)
        XCTAssertEqual(cpu.detectionSummary?.availability, .usable)
        let combined = try textureEngine().processResult(
            pixelBuffer: input, metadata: metadata,
            parameters: BeautyParameters(skinSmoothing: 1, faceSmall: 1)
        )
        XCTAssertEqual(try PixelBufferFixtures.bytes(from: combined.output), output,
                       "pixel-buffer texture support must not enable still-image geometry")

        let noFace = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        ).processResult(pixelBuffer: input, metadata: metadata, parameters: parameters)
        XCTAssertEqual(try PixelBufferFixtures.bytes(from: noFace.output), bgra)
        XCTAssertEqual(noFace.detectionSummary?.availability, .noFace)

        if let gpu = try? textureEngine(.init(renderBackend: .gpu)) {
            let metal = try gpu.processResult(
                pixelBuffer: input, metadata: metadata, parameters: parameters
            )
            let metalBytes = try PixelBufferFixtures.bytes(from: metal.output)
            XCTAssertLessThanOrEqual(zip(output, metalBytes).map {
                abs(Int($0) - Int($1))
            }.max() ?? .max, 2)
        }
    }

    func testTextureSupportDoesNotLeakBetweenRequestsOrSkippedFrames() throws {
        let source = portraitFixture(textured: true, backgroundTextured: true,
                                     backgroundWarm: true)
        let image = makeImage(source)
        let parameters = BeautyParameters(skinSmoothing: 1)
        let provider = SDKTestingFaceDetectionProvider([.noFace, .textureFace, .noFace])
        let engine = try BeautyEngine(faceDetectionProvider: provider)
        let outputs = try (0..<3).map { _ in
            try engine.processResult(image: image, metadata: metadata,
                                     parameters: parameters)
        }
        XCTAssertEqual(bytes(outputs[0].output, extent: image.extent), source)
        XCTAssertNotEqual(bytes(outputs[1].output, extent: image.extent), source)
        XCTAssertEqual(bytes(outputs[2].output, extent: image.extent), source)
        XCTAssertEqual(provider.invocationCount, 3)

        let disabled = try BeautyEngine(configuration: .init(enableFaceTracking: false))
        let disabledOutput = try disabled.processResult(
            image: image, metadata: metadata, parameters: parameters
        )
        XCTAssertEqual(bytes(disabledOutput.output, extent: image.extent), source)
        XCTAssertEqual(disabledOutput.detectionSummary?.availability, .disabled)

        let indexedProvider = SDKTestingFaceDetectionProvider([.textureFace])
        let indexed = try BeautyEngine(
            configuration: .init(detectionFrameInterval: 2),
            faceDetectionProvider: indexedProvider
        )
        let video = BeautyInputMetadata(orientation: .up, source: .video)
        let admitted = try indexed.processResult(
            image: image, metadata: video, frameIndex: 0, parameters: parameters
        )
        let skipped = try indexed.processResult(
            image: image, metadata: video, frameIndex: 1, parameters: parameters
        )
        XCTAssertNotEqual(bytes(admitted.output, extent: image.extent), source)
        XCTAssertEqual(bytes(skipped.output, extent: image.extent), source)
        XCTAssertEqual(indexedProvider.invocationCount, 1)
    }

    func testOversizedTextureInputFailsTypedBeforeRenderingAndEngineRecovers() throws {
        let oversized = CIImage(color: CIColor(
            red: 0.6, green: 0.5, blue: 0.4
        )).cropped(to: CGRect(x: 0, y: 0, width: 2049, height: 4096))
        let engine = try textureEngine()
        for parameters in [
            BeautyParameters(skinSmoothing: 1),
            BeautyParameters(skinSharpen: 1),
        ] {
            XCTAssertThrowsError(try engine.processResult(
                image: oversized, metadata: metadata, parameters: parameters
            )) { error in
                XCTAssertEqual(error as? BeautyError, .invalidInput)
            }
        }
        let small = fixture(.textured)
        let recovered = try engine.processResult(
            image: makeImage(small), metadata: metadata,
            parameters: BeautyParameters(skinSmoothing: 1)
        )
        XCTAssertLessThan(textureDeviation(bytes(recovered.output, extent: recovered.output.extent)),
                          textureDeviation(small) * 0.65)
    }

    private enum Kind { case textured, softEdge, flat }
    private enum Region { case target, protected, translucent }

    private func fixture(_ kind: Kind, translucent: Bool = false) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let index = (y * width + x) * 4
                let inside = (16..<48).contains(x) && (16..<48).contains(y)
                let value: Int
                if !inside {
                    value = 36
                } else {
                    switch kind {
                    case .textured: value = 150 + ((x / 2 + y / 2).isMultiple(of: 2) ? 10 : -10)
                    case .softEdge: value = x < 32 ? 138 : 162
                    case .flat: value = 150
                    }
                }
                result[index] = UInt8(value)
                result[index + 1] = UInt8(value)
                result[index + 2] = UInt8(value)
                result[index + 3] = translucent && (29..<35).contains(x) && (22..<42).contains(y)
                    ? (x.isMultiple(of: 2) ? 0 : 128) : 255
            }
        }
        return result
    }

    private func portraitFixture(
        textured: Bool, backgroundTextured: Bool = false, deepSkin: Bool = false,
        backgroundWarm: Bool = false, warmFeaturesTextured: Bool = false
    ) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let dx = Double(x - 32) / 20
                let dy = Double(y - 33) / 24
                let insideFace = dx * dx + dy * dy <= 1
                let leftEye = (23..<28).contains(x) && (25..<29).contains(y)
                let rightEye = (37..<42).contains(x) && (25..<29).contains(y)
                let mouth = (27..<38).contains(x) && (48..<51).contains(y)
                let cheek = (34..<44).contains(y) &&
                    ((20..<29).contains(x) || (35..<44).contains(x))
                let noise = textured && cheek
                    ? ((x / 2 + y / 2).isMultiple(of: 2) ? 10 : -10) : 0
                let rgb: (Int, Int, Int)
                if !insideFace {
                    let backgroundNoise = backgroundTextured &&
                        ((x / 2 + y / 2).isMultiple(of: 2)) ? 5 : -5
                    rgb = backgroundTextured
                        ? (backgroundWarm
                            ? (134 + backgroundNoise, 94 + backgroundNoise, 74 + backgroundNoise)
                            : (74 + backgroundNoise, 94 + backgroundNoise, 114 + backgroundNoise))
                        : (35, 45, 65)
                }
                else if y < 20 { rgb = (32, 28, 26) }
                else if leftEye || rightEye {
                    let detail = (x / 2 + y / 2).isMultiple(of: 2) ? 5 : -5
                    rgb = warmFeaturesTextured
                        ? (158 + detail, 117 + detail, 103 + detail) : (50, 40, 38)
                }
                else if mouth {
                    let detail = (x / 2 + y / 2).isMultiple(of: 2) ? 5 : -5
                    rgb = warmFeaturesTextured
                        ? (158 + detail, 117 + detail, 103 + detail) : (125, 63, 70)
                }
                else {
                    rgb = deepSkin
                        ? (84 + noise, 58 + noise, 46 + noise)
                        : (170 + noise, 125 + noise, 110 + noise)
                }
                let offset = (y * width + x) * 4
                result[offset] = UInt8(rgb.0)
                result[offset + 1] = UInt8(rgb.1)
                result[offset + 2] = UInt8(rgb.2)
                result[offset + 3] = 255
            }
        }
        return result
    }

    private func portraitCheekDeviation(_ pixels: [UInt8]) -> Double {
        let values = (36..<42).flatMap { y in
            ((22..<28).map { $0 } + (37..<43).map { $0 }).map { x in
                abs(Int(pixels[(y * width + x) * 4]) - 170)
            }
        }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    private func portraitProtectedChanged(_ source: [UInt8], _ output: [UInt8]) -> Bool {
        for y in 0..<height {
            for x in 0..<width {
                let protected = x < 10 || x >= 54 || y < 12 || y >= 57 ||
                    (y < 20 && (18..<46).contains(x)) ||
                    ((25..<29).contains(y) &&
                     ((23..<28).contains(x) || (37..<42).contains(x))) ||
                    ((48..<51).contains(y) && (27..<38).contains(x))
                guard protected else { continue }
                let offset = (y * width + x) * 4
                if (0..<3).contains(where: { source[offset + $0] != output[offset + $0] }) {
                    return true
                }
            }
        }
        return false
    }

    private func makeImage(
        _ source: [UInt8],
        colorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    ) -> CIImage {
        CIImage(
            bitmapData: Data(source), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    private func render(_ source: [UInt8], parameters: BeautyParameters) throws -> [UInt8] {
        let engine = try textureEngine()
        let result = try engine.processResult(
            image: makeImage(source), metadata: metadata, parameters: parameters
        )
        XCTAssertEqual(result.output.extent, CGRect(x: 0, y: 0, width: width, height: height))
        return bytes(result.output, extent: result.output.extent)
    }

    private func textureEngine(
        _ configuration: BeautyConfiguration = .default
    ) throws -> BeautyEngine {
        try BeautyEngine(
            configuration: configuration,
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.textureFace])
        )
    }

    private func bytes(
        _ image: CIImage, extent: CGRect,
        colorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    ) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: width * height * 4)
        let context = CIContext(options: [
            .workingColorSpace: colorSpace, .outputColorSpace: colorSpace
        ])
        context.render(image, toBitmap: &result, rowBytes: width * 4,
                       bounds: extent, format: .RGBA8, colorSpace: colorSpace)
        return result
    }

    private func textureDeviation(_ pixels: [UInt8]) -> Double {
        let values = (20..<44).flatMap { y in (20..<44).map { x in
            abs(Int(pixels[(y * width + x) * 4]) - 150)
        } }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    private func softEdgeGradient(_ pixels: [UInt8]) -> Double {
        let values = (20..<44).map { y in
            let row = y * width * 4
            return Int(pixels[row + 32 * 4]) - Int(pixels[row + 31 * 4])
        }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    private func changed(_ source: [UInt8], _ output: [UInt8], in region: Region) -> Bool {
        for y in 0..<height {
            for x in 0..<width {
                let included: Bool
                switch region {
                case .target: included = (20..<44).contains(x) && (20..<44).contains(y)
                case .protected: included = x < 12 || x >= 52 || y < 12 || y >= 52 ||
                    ((16..<48).contains(y) && (x == 16 || x == 47))
                case .translucent: included = (29..<35).contains(x) && (22..<42).contains(y)
                }
                guard included else { continue }
                let offset = (y * width + x) * 4
                if (0..<3).contains(where: { source[offset + $0] != output[offset + $0] }) {
                    return true
                }
            }
        }
        return false
    }

    private func alpha(_ pixels: [UInt8]) -> [UInt8] {
        stride(from: 3, to: pixels.count, by: 4).map { pixels[$0] }
    }

    private func maxChannelDelta(_ source: [UInt8], _ output: [UInt8]) -> Int {
        stride(from: 0, to: source.count, by: 4).flatMap { offset in
            (0..<3).map { abs(Int(source[offset + $0]) - Int(output[offset + $0])) }
        }.max() ?? 0
    }
}
