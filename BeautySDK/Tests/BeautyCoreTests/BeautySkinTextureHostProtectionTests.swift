import CoreGraphics
import CoreImage
import ImageIO
import XCTest
import BeautyDetection
@_spi(Testing) @testable import BeautySDK

/// Host-supplied information, using the unchanged semantic-probe generator.
/// This is not automatic lip/object discovery or a replacement for its red test.
final class BeautySkinTextureHostProtectionTests: XCTestCase {
    private let side = 64
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
    private let left = Region(x: 22..<26, y: 35..<39)
    private let right = Region(x: 38..<42, y: 35..<39)
    private let lip = Region(x: 27..<38, y: 48..<51)
    private let tones: [(Int, Int, Int)] = [(170, 125, 110), (110, 76, 61)]
    private enum Material: Equatable { case skin, printedObject }
    private struct Scene { let pixels: [UInt8]; let rightMaterial: Material }
    private struct Region { let x: Range<Int>; let y: Range<Int> }

    func testHostObjectAndLipUnionPreservesFeaturesWhileTextureMeetsDirection() throws {
        var exercised = 0
        var typedUnavailable = 0
        for backend in [BeautyRenderBackend.cpu, .gpu] {
            let engine: BeautyEngine
            do { engine = try makeEngine(backend: backend) }
            catch BeautyError.metalUnavailable where backend == .gpu {
                typedUnavailable += 1
                continue
            }
            exercised += 1
            for tone in tones {
                let source = scene(tone: tone, rightMaterial: .printedObject).pixels
                let image = image(source)
                let exclusions = hostExclusions()
                let mask = try mask(exclusions)
                XCTAssertEqual(try render(engine, image, parameters: .init(), mask: mask), source)
                for smoothing in [true, false] {
                    let parameters = parameters(smoothing)
                    let baseline = try render(engine, image, parameters: parameters)
                    assertDirection(source, baseline, left, smoothing: smoothing)
                    XCTAssertGreaterThan(changed(source, baseline, right), 0)
                    if tone.0 == 110 {
                        // Same real counterexample: the mask supplies missing
                        // information instead of altering the old lip oracle.
                        XCTAssertGreaterThan(changed(source, baseline, lip), 0)
                    }
                    let output = try render(engine, image, parameters: parameters, mask: mask)
                    assertUnion(source, output, baseline, exclusions, smoothing: smoothing)
                    XCTAssertEqual(output, try render(engine, image, parameters: parameters, mask: mask))
                }
            }
        }
        XCTAssertGreaterThanOrEqual(exercised, 1)
        XCTAssertEqual(exercised + typedUnavailable, 2)
        print("host_texture_backends cpu_executed=1 metal_executed=\(exercised - 1) metal_unavailable=\(typedUnavailable)")
    }

    func testPartialUnionMaskStaysInUprightGridAcrossAllOrientationsAndMirrors() throws {
        let engine = try makeEngine()
        let exclusions = hostExclusions()
        let mask = try mask(exclusions)
        for tone in tones {
            let source = scene(tone: tone, rightMaterial: .printedObject).pixels
            let canonical = image(source)
            for smoothing in [true, false] {
                let parameters = parameters(smoothing)
                let baseline = try render(engine, canonical, parameters: parameters)
                let expected = try render(engine, canonical, parameters: parameters, mask: mask)
                assertUnion(source, expected, baseline, exclusions, smoothing: smoothing)
                for raw in UInt32(1)...UInt32(8) {
                    let orientation = try XCTUnwrap(CGImagePropertyOrientation(rawValue: raw))
                    for mirrored in [false, true] {
                        var stored = canonical
                        if mirrored {
                            stored = stored.transformed(by: CGAffineTransform(
                                a: -1, b: 0, c: 0, d: 1, tx: CGFloat(side), ty: 0
                            ))
                        }
                        let inverse: UInt32 = raw == 6 ? 8 : (raw == 8 ? 6 : raw)
                        stored = stored.oriented(forExifOrientation: Int32(inverse))
                        let request = BeautyInputMetadata(
                            orientation: orientation, isInputMirrored: mirrored,
                            isPreviewMirrored: !mirrored, source: .testFixture
                        )
                        let neutral = try render(engine, stored, metadata: request,
                                                 parameters: .init(), mask: mask)
                        XCTAssertEqual(neutral, source)
                        let output = try render(engine, stored, metadata: request,
                                                parameters: parameters, mask: mask)
                        XCTAssertEqual(output, expected)
                        assertUnion(source, output, baseline, exclusions, smoothing: smoothing)
                    }
                }
            }
        }
    }

    func testEncodedPNGUnionMaskRecoversAfterWrongGridWithoutMaskStateLeak() throws {
        let engine = try makeEngine()
        let exclusions = hostExclusions()
        let mask = try mask(exclusions)
        let wrongGrid = try BeautyTextureExclusionMask(
            width: side - 1, height: side, bytes: [UInt8](repeating: 0, count: (side - 1) * side)
        )
        for tone in tones {
            let source = scene(tone: tone, rightMaterial: .printedObject).pixels
            let image = image(source)
            let encoded = try png(image)
            for smoothing in [true, false] {
                let parameters = parameters(smoothing)
                func process(_ mask: BeautyTextureExclusionMask?) throws -> [UInt8] {
                    let result = try engine.processResult(
                        encodedImageData: encoded, metadata: metadata,
                        parameters: parameters, textureExclusionMask: mask
                    )
                    return rgba(result.output)
                }
                let baseline = try process(nil)
                XCTAssertThrowsError(try process(wrongGrid)) {
                    XCTAssertEqual($0 as? BeautyError, .invalidInput)
                }
                let recovered = try process(mask)
                assertUnion(source, recovered, baseline, exclusions, smoothing: smoothing)
                XCTAssertEqual(recovered, try render(engine, image, parameters: parameters, mask: mask))
                XCTAssertEqual(recovered, try process(mask))
                XCTAssertEqual(try process(nil), baseline)
            }
        }
    }

    func testNoFaceFlatSkinAndWholeExclusionDoNotGainTextureOrRetainPriorMask() throws {
        let engine = try makeEngine()
        let noFace = try makeEngine(face: .noFace)
        let union = try mask(hostExclusions())
        let zero = try mask([UInt8](repeating: 0, count: side * side))
        let whole = try mask([UInt8](repeating: 255, count: side * side))
        for tone in tones {
            let source = scene(tone: tone, rightMaterial: .printedObject).pixels
            let image = image(source)
            var flat = source
            for region in [Region(x: 20..<29, y: 34..<44), Region(x: 35..<44, y: 34..<44)] {
                for y in region.y { for x in region.x {
                    let index = (y * side + x) * 4
                    flat[index] = UInt8(tone.0)
                    flat[index + 1] = UInt8(tone.1)
                    flat[index + 2] = UInt8(tone.2)
                }}
            }
            for smoothing in [true, false] {
                let parameters = parameters(smoothing)
                let baseline = try render(engine, image, parameters: parameters)
                XCTAssertEqual(try render(engine, image, parameters: parameters, mask: zero), baseline)
                XCTAssertEqual(try render(engine, image, parameters: parameters, mask: whole), source)
                XCTAssertEqual(try render(noFace, image, parameters: parameters, mask: union), source)
                _ = try render(engine, image, parameters: parameters, mask: union)
                XCTAssertEqual(try render(engine, image, parameters: parameters), baseline)
                let flatOutput = try render(engine, self.image(flat), parameters: parameters, mask: union)
                XCTAssertEqual(changed(flat, flatOutput, left), 0)
                assertProtection(flat, flatOutput)
            }
        }
    }

    private func makeEngine(
        backend: BeautyRenderBackend = .cpu, face: SDKTestingFaceDetectionFixture = .textureFace
    ) throws -> BeautyEngine {
        let configuration = BeautyConfiguration(renderBackend: backend)
        let selection = try BeautyBackendFactory.select(configuration: configuration)
        XCTAssertEqual(selection.policy, backend == .gpu ? .metal : .cpu)
        let provider = SDKTestingFaceDetectionProvider([face])
        return try BeautyEngine(
            configuration: configuration,
            faceDetector: VisionFaceDetector(observationProvider: provider.makeObservationProvider()),
            backendExecutor: selection.executor
        )
    }

    private func hostExclusions() -> [UInt8] {
        var exclusions = [UInt8](repeating: 0, count: side * side)
        // Independent host information: union the object and known entire lip.
        // These are source-defined regions, not an inferred material mask.
        for region in [Region(x: 35..<44, y: 34..<44), lip] {
            for y in region.y { for x in region.x { exclusions[y * side + x] = 255 } }
        }
        return exclusions
    }

    private func mask(_ bytes: [UInt8]) throws -> BeautyTextureExclusionMask {
        try BeautyTextureExclusionMask(width: side, height: side, bytes: bytes)
    }

    private func parameters(_ smoothing: Bool) -> BeautyParameters {
        smoothing ? BeautyParameters(skinSmoothing: 1) : BeautyParameters(skinSharpen: 1)
    }

    private func image(_ pixels: [UInt8]) -> CIImage {
        CIImage(bitmapData: Data(pixels), bytesPerRow: side * 4,
                size: CGSize(width: side, height: side), format: .RGBA8, colorSpace: colorSpace)
    }

    private func render(
        _ engine: BeautyEngine, _ image: CIImage, metadata: BeautyInputMetadata? = nil,
        parameters: BeautyParameters, mask: BeautyTextureExclusionMask? = nil
    ) throws -> [UInt8] {
        let result = try engine.processResult(
            image: image, metadata: metadata ?? self.metadata,
            parameters: parameters, textureExclusionMask: mask
        )
        return rgba(result.output)
    }

    private func rgba(_ image: CIImage) -> [UInt8] {
        XCTAssertEqual(image.extent, CGRect(x: 0, y: 0, width: side, height: side))
        XCTAssertEqual(image.colorSpace?.name, colorSpace.name)
        var bytes = [UInt8](repeating: 0, count: side * side * 4)
        CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
            .render(image, toBitmap: &bytes, rowBytes: side * 4,
                    bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        return bytes
    }

    private func png(_ image: CIImage) throws -> Data {
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        let cg = try XCTUnwrap(context.createCGImage(image, from: image.extent))
        let data = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(
            data as CFMutableData, "public.png" as CFString, 1, nil
        ))
        CGImageDestinationAddImage(destination, cg, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return data as Data
    }

    private func assertUnion(
        _ source: [UInt8], _ output: [UInt8], _ baseline: [UInt8], _ exclusions: [UInt8],
        smoothing: Bool
    ) {
        assertDirection(source, output, left, smoothing: smoothing)
        XCTAssertEqual(changed(source, output, right), 0)
        assertProtection(source, output)
        for index in exclusions.indices {
            let reference = exclusions[index] == 255 ? source : baseline
            for channel in 0..<4 {
                XCTAssertEqual(output[index * 4 + channel], reference[index * 4 + channel])
            }
        }
    }

    private func scene(tone: (Int, Int, Int), rightMaterial: Material) -> Scene {
        // Two physical interpretations: actual skin texture or a printed,
        // skin-colored covering reproducing the same visible pixels. Material
        // is ground truth for the oracle, never an image-generation branch.
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let dx = Double(x - 32) / 20
                let dy = Double(y - 33) / 24
                let onCheek = (34..<44).contains(y) &&
                    ((20..<29).contains(x) || (35..<44).contains(x))
                let detail = (x / 2 + y / 2).isMultiple(of: 2) ? 10 : -10
                let rgb: (Int, Int, Int)
                if dx * dx + dy * dy > 1 { rgb = (35, 45, 65) }
                else if y < 20 { rgb = (32, 28, 26) }
                else if ((23..<28).contains(x) || (37..<42).contains(x)) &&
                    (25..<29).contains(y) { rgb = (50, 40, 38) }
                else if (27..<38).contains(x) && (48..<51).contains(y) {
                    rgb = (125, 63, 70)
                } else {
                    let value = onCheek ? detail : 0
                    rgb = (tone.0 + value, tone.1 + value, tone.2 + value)
                }
                let offset = (y * side + x) * 4
                pixels[offset] = UInt8(rgb.0)
                pixels[offset + 1] = UInt8(rgb.1)
                pixels[offset + 2] = UInt8(rgb.2)
                pixels[offset + 3] = 255
            }
        }
        return Scene(pixels: pixels, rightMaterial: rightMaterial)
    }

    private func changed(_ source: [UInt8], _ output: [UInt8], _ region: Region) -> Int {
        region.y.reduce(0) { total, y in
            total + region.x.reduce(0) { subtotal, x in
                let offset = (y * side + x) * 4
                return subtotal + ((0..<3).contains {
                    source[offset + $0] != output[offset + $0]
                } ? 1 : 0)
            }
        }
    }

    private func variation(_ pixels: [UInt8], _ region: Region) -> Double {
        var total = 0.0
        var count = 0
        func luminance(_ x: Int, _ y: Int) -> Double {
            let i = (y * side + x) * 4
            return Double(77 * Int(pixels[i]) + 150 * Int(pixels[i + 1]) +
                          29 * Int(pixels[i + 2])) / 256
        }
        for y in region.y {
            for x in region.x {
                if x + 1 < region.x.upperBound {
                    total += abs(luminance(x + 1, y) - luminance(x, y)); count += 1
                }
                if y + 1 < region.y.upperBound {
                    total += abs(luminance(x, y + 1) - luminance(x, y)); count += 1
                }
            }
        }
        return total / Double(count)
    }

    private func meetsDirection(
        _ source: [UInt8], _ output: [UInt8], _ region: Region, smoothing: Bool
    ) -> Bool {
        let before = variation(source, region)
        let after = variation(output, region)
        return smoothing ? after <= before * 0.80 : after >= before * 1.10
    }

    private func assertDirection(
        _ source: [UInt8], _ output: [UInt8], _ region: Region, smoothing: Bool,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertGreaterThan(variation(source, region), 0, file: file, line: line)
        XCTAssertTrue(meetsDirection(source, output, region, smoothing: smoothing),
                      "Frozen texture direction failed", file: file, line: line)
    }

    private func assertProtection(_ source: [UInt8], _ output: [UInt8]) {
        XCTAssertEqual(source.count, output.count)
        for index in stride(from: 0, to: source.count, by: 4) {
            XCTAssertEqual(source[index + 3], output[index + 3])
            for channel in 0..<3 {
                XCTAssertLessThanOrEqual(abs(Int(output[index + channel]) - Int(source[index + channel])), 16)
            }
        }
        for region in [Region(x: 0..<side, y: 0..<12),
                       Region(x: 23..<28, y: 25..<29),
                       Region(x: 37..<42, y: 25..<29),
                       Region(x: 27..<38, y: 48..<51)] {
            XCTAssertEqual(changed(source, output, region), 0)
        }
    }
}
