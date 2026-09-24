import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyEngineFaceContourSmoothRepairTests: XCTestCase {
    func testFACE01OrientedAndMirroredStillImagesRetainActiveOrFailClosedBehavior() throws {
        let width = 320
        let height = 320
        let image = Self.image(Self.fixture(width: width, height: height), width: width, height: height)
        let orientations: [(CGImagePropertyOrientation, CGImagePropertyOrientation)] = [
            (.up, .up), (.upMirrored, .upMirrored), (.down, .down),
            (.leftMirrored, .leftMirrored), (.right, .left),
            (.rightMirrored, .rightMirrored), (.left, .right),
        ]
        for (orientation, inverse) in orientations {
            let encoded = image.oriented(inverse)
            let metadata = BeautyInputMetadata(orientation: orientation, source: .testFixture)
            let provider = SDKTestingFaceDetectionProvider([.usableFace, .usableFace])
            let engine = try BeautyEngine(faceDetectionProvider: provider)
            let neutral = try BeautyEngine(faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace]))
                .processResult(image: encoded, metadata: metadata, parameters: BeautyParameters())
            let first = try engine.processResult(
                image: encoded, metadata: metadata,
                parameters: BeautyParameters(faceContourSmooth: 0.25)
            )
            let repeated = try engine.processResult(
                image: encoded, metadata: metadata,
                parameters: BeautyParameters(faceContourSmooth: 0.25)
            )
            let baselineBytes = Self.bytes(neutral.output, width: width, height: height)
            let firstBytes = Self.bytes(first.output, width: width, height: height)
            XCTAssertEqual(provider.invocationCount, 2)
            XCTAssertEqual(first.output.extent, neutral.output.extent)
            XCTAssertEqual(first.output.extent, repeated.output.extent)
            XCTAssertEqual(firstBytes, Self.bytes(repeated.output, width: width, height: height))
            let changed = Self.changedPixels(baselineBytes, firstBytes, width: width, height: height) { _, _ in true }
            if orientation == .up || orientation == .upMirrored {
                XCTAssertGreaterThan(changed, 0)
                XCTAssertGreaterThan(first.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
            } else {
                XCTAssertEqual(changed, 0)
                XCTAssertEqual(first.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
            }
            XCTAssertTrue(stride(from: 3, to: firstBytes.count, by: 4).allSatisfy { firstBytes[$0] == 255 })
            assertRedacted(first)
            assertRedacted(repeated)
        }
    }

    func testFACE01PublicFacadeChangesLateralPixelsAndRecoversAfterInvalidSupport() throws {
        let width = 320
        let height = 320
        let source = Self.fixture(width: width, height: height)
        let image = Self.image(source, width: width, height: height)
        let provider = SDKTestingFaceDetectionProvider([
            .usableFace, .malformedObservedFaceContour, .usableFace,
        ])
        let engine = try BeautyEngine(faceDetectionProvider: provider)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let parameters = BeautyParameters(faceContourSmooth: 0.25)

        let first = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
        let rejected = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
        let recovered = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
        let firstBytes = Self.bytes(first.output, width: width, height: height)
        let rejectedBytes = Self.bytes(rejected.output, width: width, height: height)
        let recoveredBytes = Self.bytes(recovered.output, width: width, height: height)

        XCTAssertEqual(provider.invocationCount, 3)
        XCTAssertEqual(first.output.extent, image.extent)
        XCTAssertEqual(recovered.output.extent, image.extent)
        XCTAssertEqual(first.detectionSummary?.availability, .usable)
        XCTAssertGreaterThan(first.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertGreaterThan(Self.changedPixels(source, firstBytes, width: width, height: height) { x, y in
            (0.26..<0.46).contains(Float(x) / Float(width)) &&
                (0.30..<0.76).contains(Float(y) / Float(height)) ||
            (0.54..<0.74).contains(Float(x) / Float(width)) &&
                (0.30..<0.76).contains(Float(y) / Float(height))
        }, 0)
        XCTAssertEqual(Self.changedPixels(source, firstBytes, width: width, height: height) { x, _ in
            x < width / 5 || x >= width * 4 / 5
        }, 0)
        XCTAssertEqual(Self.changedPixels(source, firstBytes, width: width, height: height) { x, _ in
            x >= width * 48 / 100 && x < width * 52 / 100
        }, 0)
        XCTAssertEqual(rejectedBytes, source)
        XCTAssertEqual(firstBytes, recoveredBytes)
        XCTAssertEqual(first.metrics, recovered.metrics)
        XCTAssertEqual(first.warnings, recovered.warnings)
        XCTAssertTrue(stride(from: 3, to: firstBytes.count, by: 4).allSatisfy { firstBytes[$0] == 255 })
        for result in [first, rejected, recovered] { assertRedacted(result) }
    }

    private func assertRedacted(_ result: BeautyResult<CIImage>) {
        let text = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()
        for forbidden in ["landmark", "coordinate", "controlpoint", "simd", "contour", "pixel", "/private/"] {
            XCTAssertFalse(text.contains(forbidden), forbidden)
        }
    }

    private static func fixture(width: Int, height: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let i = (y * width + x) * 4
                bytes[i] = UInt8((x * 13 + y * 7) & 255)
                bytes[i + 1] = UInt8((x * 5 + y * 11) & 255)
                bytes[i + 2] = UInt8((x * 3 + y * 17) & 255)
            }
        }
        return bytes
    }

    private static func image(_ bytes: [UInt8], width: Int, height: Int) -> CIImage {
        CIImage(
            bitmapData: Data(bytes),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }

    private static func bytes(_ image: CIImage, width: Int, height: Int) -> [UInt8] {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        bytes.withUnsafeMutableBytes { raw in
            context.render(
                image,
                toBitmap: raw.baseAddress!,
                rowBytes: width * 4,
                bounds: image.extent,
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return bytes
    }

    private static func changedPixels(
        _ lhs: [UInt8], _ rhs: [UInt8], width: Int, height: Int,
        include: (Int, Int) -> Bool
    ) -> Int {
        var count = 0
        for y in 0..<height {
            for x in 0..<width where include(x, y) {
                let i = (y * width + x) * 4
                if (0..<3).contains(where: { abs(Int(lhs[i + $0]) - Int(rhs[i + $0])) > 2 }) {
                    count += 1
                }
            }
        }
        return count
    }
}
