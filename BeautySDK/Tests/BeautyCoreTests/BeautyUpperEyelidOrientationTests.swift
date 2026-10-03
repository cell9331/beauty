import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@testable import BeautyCore
@_spi(Testing) @testable import BeautySDK

/// Integer storage permutations encode the source independently of Core Image's
/// orientation implementation. Injected observations isolate normalization and
/// public effect composition; they do not establish live Vision admission.
final class BeautyUpperEyelidOrientationTests: XCTestCase {
    private struct Raster {
        let width: Int
        let height: Int
        let bytes: [UInt8]
    }

    private let width = 384
    private let height = 320
    private let timestamp = 42.25
    private let parameters = BeautyParameters(upperEyelidFullnessReduction: 1)

    /// Frozen oracle: every lossless encoding of this non-square, asymmetric
    /// source produces exactly the standard-up effect bytes. Preview mirroring
    /// is metadata only; input mirroring is corrected before the effect.
    func testAllEXIFInputAndPreviewMirrorCombinationsMatchUprightEffect() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        let source = makeRaster(hasDomes: true)
        let flat = makeRaster(hasDomes: false)
        let harness = try makeHarness()
        let baseline = try harness.invokeProcessResult(
            image: image(source, colorSpace: colorSpace), metadata: metadata(), parameters: parameters)
        let baselineBytes = render(baseline.output, context: context, colorSpace: colorSpace)
        assertPositiveEffect(source: source, flat: flat, output: baselineBytes)
        assertOutputMetadata(baseline.output, harness: harness, previewMirrored: false)

        for rawOrientation in UInt32(1)...8 {
            let orientation = try XCTUnwrap(CGImagePropertyOrientation(rawValue: rawOrientation))
            for inputMirrored in [false, true] {
                let encodedSource = encode(source, orientation: orientation, inputMirrored: inputMirrored)
                let encodedFlat = encode(flat, orientation: orientation, inputMirrored: inputMirrored)
                for previewMirrored in [false, true] {
                    let label = "EXIF=\(rawOrientation), inputMirror=\(inputMirrored), previewMirror=\(previewMirrored)"
                    let requestMetadata = metadata(orientation: orientation,
                        inputMirrored: inputMirrored, previewMirrored: previewMirrored)
                    let edited = try harness.invokeProcessResult(
                        image: image(encodedSource, colorSpace: colorSpace),
                        metadata: requestMetadata, parameters: parameters)
                    assertEqualBytes(render(edited.output, context: context, colorSpace: colorSpace),
                                     baselineBytes, label)
                    assertOutputMetadata(edited.output, harness: harness,
                                         previewMirrored: previewMirrored, label: label)
                    XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 2, label)
                    XCTAssertGreaterThan(harness.compositionObservation.changedPixelCount, 200, label)
                    XCTAssertEqual(harness.compositionObservation.changedOutsideUnionPixelCount, 0, label)

                    let negative = try harness.invokeProcessResult(
                        image: image(encodedFlat, colorSpace: colorSpace),
                        metadata: requestMetadata, parameters: parameters)
                    assertEqualBytes(render(negative.output, context: context, colorSpace: colorSpace),
                                     flat.bytes, "\(label): flat negative")
                    assertOutputMetadata(negative.output, harness: harness,
                                         previewMirrored: previewMirrored, label: label)
                    XCTAssertEqual(harness.compositionObservation.changedPixelCount, 0, label)

                    let neutral = try harness.invokeProcessResult(
                        image: image(encodedSource, colorSpace: colorSpace),
                        metadata: requestMetadata, parameters: BeautyParameters())
                    // With no local-retouch demand, the established legacy
                    // facade preserves the raw stored raster and dimensions.
                    assertEqualBytes(render(neutral.output, context: context, colorSpace: colorSpace),
                                     encodedSource.bytes, "\(label): raw neutral")
                    XCTAssertEqual(neutral.output.extent,
                        CGRect(x: 0, y: 0, width: encodedSource.width, height: encodedSource.height), label)
                    XCTAssertEqual(neutral.output.colorSpace?.name, CGColorSpace.sRGB, label)
                    XCTAssertNil(harness.canonicalMetadataObservation, label)
                    XCTAssertEqual(harness.retainedRequestOwnerCount, 0, label)
                }
            }
        }
    }

    func testOrientedRequestRecoversAfterTypedInputFailuresOnSameEngine() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        let harness = try makeHarness()
        let source = makeRaster(hasDomes: true)
        let upright = try harness.invokeProcessResult(image: image(source, colorSpace: colorSpace),
            metadata: metadata(), parameters: parameters)
        let expected = render(upright.output, context: context, colorSpace: colorSpace)

        XCTAssertThrowsError(try harness.invokeProcessResult(image: CIImage.empty(),
            metadata: metadata(), parameters: parameters)) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        XCTAssertNil(harness.canonicalMetadataObservation)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)

        var translucentBytes = source.bytes
        translucentBytes[3] = 0
        let translucent = Raster(width: width, height: height, bytes: translucentBytes)
        XCTAssertThrowsError(try harness.invokeProcessResult(
            image: image(translucent, colorSpace: colorSpace), metadata: metadata(), parameters: parameters)) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        XCTAssertNil(harness.canonicalMetadataObservation)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)

        let stored = encode(source, orientation: .rightMirrored, inputMirrored: true)
        let recovered = try harness.invokeProcessResult(image: image(stored, colorSpace: colorSpace),
            metadata: metadata(orientation: .rightMirrored, inputMirrored: true, previewMirrored: true),
            parameters: parameters)
        assertEqualBytes(render(recovered.output, context: context, colorSpace: colorSpace), expected,
                         "same engine must recover its upright effect after rejected inputs")
        assertOutputMetadata(recovered.output, harness: harness, previewMirrored: true)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 2)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
    }

    private func makeHarness() throws -> SDKTestingLocalRetouchFoundationHarness {
        try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0, upperEyelidSupportSequence: [.paired])
    }

    private func metadata(orientation: CGImagePropertyOrientation = .up,
                          inputMirrored: Bool = false, previewMirrored: Bool = false) -> BeautyInputMetadata {
        BeautyInputMetadata(orientation: orientation, isInputMirrored: inputMirrored,
            isPreviewMirrored: previewMirrored, source: .photo, timestamp: timestamp)
    }

    private func assertOutputMetadata(_ output: CIImage, harness: SDKTestingLocalRetouchFoundationHarness,
                                      previewMirrored: Bool, label: String = "",
                                      file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(output.extent, CGRect(x: 0, y: 0, width: width, height: height), label, file: file, line: line)
        XCTAssertEqual(output.colorSpace?.name, CGColorSpace.sRGB, label, file: file, line: line)
        XCTAssertEqual(harness.canonicalMetadataObservation,
            BeautyInputMetadata(orientation: .up, isInputMirrored: false,
                isPreviewMirrored: previewMirrored, source: .photo, timestamp: timestamp),
            label, file: file, line: line)
        XCTAssertTrue(harness.usedExplicitSRGBRender, label, file: file, line: line)
    }

    private func assertPositiveEffect(source: Raster, flat: Raster, output: [UInt8]) {
        var changedByEye = [0, 0]
        var protectedChanges = 0
        var alphaChanges = 0
        var maximumDelta = 0
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                if output[offset + 3] != 255 { alphaChanges += 1 }
                let left = (40..<152).contains(x) && (120..<168).contains(y)
                let right = (232..<344).contains(x) && (120..<168).contains(y)
                let changed = (0..<3).contains { output[offset + $0] != source.bytes[offset + $0] }
                if changed {
                    if left { changedByEye[0] += 1 }
                    else if right { changedByEye[1] += 1 }
                    else { protectedChanges += 1 }
                }
                for channel in 0..<3 {
                    maximumDelta = max(maximumDelta, abs(Int(output[offset + channel]) - Int(source.bytes[offset + channel])))
                }
            }
        }
        XCTAssertGreaterThan(changedByEye[0], 100)
        XCTAssertGreaterThan(changedByEye[1], 100)
        XCTAssertEqual(protectedChanges, 0)
        XCTAssertEqual(alphaChanges, 0)
        XCTAssertLessThanOrEqual(maximumDelta, 16)
        for centerX in [96, 288] {
            let center = (138 * width + centerX) * 4
            let signal = Int(source.bytes[center]) - Int(flat.bytes[center])
            XCTAssertGreaterThan(signal, 20)
            XCTAssertGreaterThanOrEqual(Int(source.bytes[center]) - Int(output[center]), 4)
        }
    }

    private func assertEqualBytes(_ actual: [UInt8], _ expected: [UInt8], _ label: String,
                                  file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.count, expected.count, label, file: file, line: line)
        let changed = zip(actual, expected).reduce(0) { $0 + ($1.0 == $1.1 ? 0 : 1) }
        XCTAssertEqual(changed, 0, "\(label): changed byte count", file: file, line: line)
    }

    private func image(_ raster: Raster, colorSpace: CGColorSpace) -> CIImage {
        CIImage(bitmapData: Data(raster.bytes), bytesPerRow: raster.width * 4,
                size: CGSize(width: raster.width, height: raster.height), format: .RGBA8, colorSpace: colorSpace)
    }

    private func render(_ image: CIImage, context: CIContext, colorSpace: CGColorSpace) -> [UInt8] {
        let bitmapWidth = Int(image.extent.width)
        let bitmapHeight = Int(image.extent.height)
        var bytes = [UInt8](repeating: 0, count: bitmapWidth * bitmapHeight * 4)
        bytes.withUnsafeMutableBytes { buffer in
            context.render(image, toBitmap: buffer.baseAddress!, rowBytes: bitmapWidth * 4,
                           bounds: image.extent,
                           format: .RGBA8, colorSpace: colorSpace)
        }
        return bytes
    }

    /// Maps stored integer coordinates into the upright raster using EXIF's
    /// row/column permutations in raster row order. It does
    /// not call an SDK normalizer, Core Image transform, or inverse helper.
    private func encode(_ source: Raster, orientation: CGImagePropertyOrientation, inputMirrored: Bool) -> Raster {
        let swapsAxes = orientation.rawValue >= 5
        let storedWidth = swapsAxes ? source.height : source.width
        let storedHeight = swapsAxes ? source.width : source.height
        var bytes = [UInt8](repeating: 0, count: source.bytes.count)
        for sy in 0..<storedHeight {
            for sx in 0..<storedWidth {
                let upright: (x: Int, y: Int)
                switch orientation {
                case .up: upright = (sx, sy)
                case .upMirrored: upright = (storedWidth - 1 - sx, sy)
                case .down: upright = (storedWidth - 1 - sx, storedHeight - 1 - sy)
                case .downMirrored: upright = (sx, storedHeight - 1 - sy)
                case .leftMirrored: upright = (sy, sx)
                case .right: upright = (storedHeight - 1 - sy, sx)
                case .rightMirrored: upright = (storedHeight - 1 - sy, storedWidth - 1 - sx)
                case .left: upright = (sy, storedWidth - 1 - sx)
                @unknown default: preconditionFailure("unsupported EXIF fixture")
                }
                let canonicalX = inputMirrored ? source.width - 1 - upright.x : upright.x
                let sourceOffset = (upright.y * source.width + canonicalX) * 4
                let storedOffset = (sy * storedWidth + sx) * 4
                for channel in 0..<4 { bytes[storedOffset + channel] = source.bytes[sourceOffset + channel] }
            }
        }
        return Raster(width: storedWidth, height: storedHeight, bytes: bytes)
    }

    private func makeRaster(hasDomes: Bool) -> Raster {
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let texture = ((x * 17 + y * 13) % 7) - 3
                let base = 112 + x / 28 + y / 36 + texture
                var dome = 0.0
                if hasDomes {
                    for (centerX, magnitude) in [(96.0, 30.0), (288.0, 26.0)] {
                        let radiusSquared = pow((Double(x) - centerX) / 48, 2) + pow((Double(y) - 138) / 17, 2)
                        if radiusSquared < 1 { dome += magnitude * pow(1 - radiusSquared, 2) }
                    }
                }
                let brow = [96, 288].contains { abs(x - $0) < 51 && (110...114).contains(y) } ? -30 : 0
                let eye = [96, 288].contains { abs(x - $0) < 37 && (161...165).contains(y) } ? -27 : 0
                let value = base + Int(dome.rounded()) + brow + eye
                let offset = (y * width + x) * 4
                bytes[offset] = UInt8(value + 20)
                bytes[offset + 1] = UInt8(value + 10)
                bytes[offset + 2] = UInt8(value)
                bytes[offset + 3] = 255
                // Asymmetric source-fixed color markers expose accidental
                // transposition, double mirroring and square-only mappings.
                if (5..<18).contains(x) && (7..<23).contains(y) {
                    bytes[offset] = 210; bytes[offset + 1] = 42; bytes[offset + 2] = 70
                } else if (343..<369).contains(x) && (273..<282).contains(y) {
                    bytes[offset] = 35; bytes[offset + 1] = 175; bytes[offset + 2] = 220
                }
            }
        }
        return Raster(width: width, height: height, bytes: bytes)
    }
}
