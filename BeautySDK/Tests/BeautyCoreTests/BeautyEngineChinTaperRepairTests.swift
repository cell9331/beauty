import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyEngineChinTaperRepairTests: XCTestCase {
    private let target = PPMRegion(minX: 330_000, maxX: 700_000, minY: 520_000, maxY: 620_000)
    private let upperFace = PPMRegion(minX: 250_000, maxX: 750_000, minY: 240_000, maxY: 400_000)
    private let mouth = PPMRegion(minX: 350_000, maxX: 650_000, minY: 400_000, maxY: 520_000)
    private let backgrounds = [
        PPMRegion(minX: 0, maxX: 200_000, minY: 80_000, maxY: 820_000),
        PPMRegion(minX: 800_000, maxX: 1_000_000, minY: 80_000, maxY: 820_000),
    ]
    private let watermark = PPMRegion(minX: 820_000, maxX: 980_000, minY: 920_000, maxY: 985_000)

    func testFACE02PublicFacadePassesFrozenSemanticProtectionAndMetadataContract() throws {
        let width = 512
        let height = 512
        let source = Self.fixtureBytes(width: width, height: height)
        let image = Self.image(bytes: source, width: width, height: height)

        let active = try process(image: image, fixture: .usableFace, parameters: .init(chinTaper: 0.25))
        let repeated = try process(image: image, fixture: .usableFace, parameters: .init(chinTaper: 0.25))
        let neutral = try process(image: image, fixture: .usableFace, parameters: .init())

        XCTAssertEqual(active.invocations, 1)
        XCTAssertEqual(repeated.invocations, 1)
        XCTAssertEqual(neutral.invocations, 0)
        XCTAssertEqual(active.result.output.extent, image.extent)
        XCTAssertEqual(active.result.detectionSummary?.availability, .usable)
        XCTAssertEqual(active.result.detectionSummary?.reasons, [])
        XCTAssertEqual(active.result.detectionSummary?.faceCount, 1)
        XCTAssertEqual(active.result.detectionSummary?.usedFaceCount, 1)
        XCTAssertEqual(active.result.metrics["beauty.detection.geometryRequired"], 1)
        XCTAssertEqual(active.result.metrics["beauty.detection.faceCount"], 1)
        XCTAssertEqual(active.result.metrics["beauty.detection.usedFaceCount"], 1)
        XCTAssertEqual(active.result.metrics["beauty.effects.activeCount"], 1)
        XCTAssertEqual(active.result.metrics["beauty.effects.cappedCount"], 0)
        XCTAssertGreaterThan(active.result.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertTrue(active.result.warnings.isEmpty)
        assertRedacted(active.result)

        XCTAssertEqual(neutral.bytes, source)
        XCTAssertEqual(active.bytes, repeated.bytes)
        XCTAssertTrue(stride(from: 3, to: active.bytes.count, by: 4).allSatisfy { active.bytes[$0] == 255 })

        let targetSignal = signal(source, active.bytes, width: width, height: height, regions: [target])
        XCTAssertGreaterThanOrEqual(targetSignal.changedPixels, 500)
        XCTAssertGreaterThanOrEqual(targetSignal.absoluteRGBDelta, 1_500)
        let signedMargin = centerlineTaperQ16(active.bytes, width: width, height: height, regions: [target])
            - centerlineTaperQ16(source, width: width, height: height, regions: [target])
        XCTAssertGreaterThanOrEqual(signedMargin, 16)

        let outside = signal(source, active.bytes, width: width, height: height) { x, y in
            !target.contains(x: x, y: y, width: width, height: height)
        }
        XCTAssertLessThanOrEqual(outside.changedPixels, 256)
        XCTAssertLessThanOrEqual(outside.absoluteRGBDelta, 1_024)
        assertSignal(source, active.bytes, width: width, height: height, regions: [upperFace], maxChanged: 64, maxDelta: 256)
        assertSignal(source, active.bytes, width: width, height: height, regions: [mouth], maxChanged: 64, maxDelta: 256)
        assertSignal(source, active.bytes, width: width, height: height, regions: backgrounds, maxChanged: 0, maxDelta: 0)
        assertSignal(source, active.bytes, width: width, height: height, regions: [watermark], maxChanged: 0, maxDelta: 0)
    }

    func testFACE02PublicFacadeIsSemanticallyDistinctFromFrozenSiblingSet() throws {
        let width = 512
        let height = 512
        let source = Self.fixtureBytes(width: width, height: height)
        let image = Self.image(bytes: source, width: width, height: height)
        let active = try process(image: image, fixture: .usableFace, parameters: .init(chinTaper: 0.25))
        let activeMetric = centerlineTaperQ16(active.bytes, width: width, height: height, regions: [target])
        let siblings: [(String, BeautyParameters)] = [
            ("chinLength positive", .init(chinLength: 0.30)),
            ("chinLength negative", .init(chinLength: -0.30)),
            ("faceVShape", .init(faceVShape: 0.35)),
            ("jawSlim", .init(jawSlim: 0.35)),
            ("faceContourSmooth", .init(faceContourSmooth: 0.25)),
        ]

        for (name, parameters) in siblings {
            let sibling = try process(image: image, fixture: .usableFace, parameters: parameters)
            XCTAssertEqual(sibling.invocations, 1, name)
            XCTAssertGreaterThanOrEqual(
                abs(activeMetric - centerlineTaperQ16(sibling.bytes, width: width, height: height, regions: [target])),
                16,
                name
            )
            assertRedacted(sibling.result)
        }
    }

    func testFACE02PublicFacadeInvalidSupportIsSourceOrSiblingSafeAndRecovers() throws {
        let width = 512
        let height = 512
        let source = Self.fixtureBytes(width: width, height: height)
        let image = Self.image(bytes: source, width: width, height: height)

        let noFace = try process(image: image, fixture: .noFace, parameters: .init(chinTaper: 0.25))
        XCTAssertEqual(noFace.invocations, 1)
        XCTAssertEqual(noFace.bytes, source)
        XCTAssertEqual(noFace.result.detectionSummary?.availability, .noFace)
        assertRedacted(noFace.result)

        for fixture: SDKTestingFaceDetectionFixture in [.missingObservedFaceContour, .malformedObservedFaceContour] {
            let baseline = try process(image: image, fixture: fixture, parameters: .init(faceSlim: 0.20))
            let combined = try process(
                image: image,
                fixture: fixture,
                parameters: .init(faceSlim: 0.20, chinTaper: 0.25)
            )
            XCTAssertEqual(baseline.invocations, 1)
            XCTAssertEqual(combined.invocations, 1)
            XCTAssertEqual(combined.bytes, baseline.bytes)
            XCTAssertEqual(combined.result.metrics, baseline.result.metrics)
            XCTAssertEqual(combined.result.warnings, baseline.result.warnings)
            assertRedacted(combined.result)
        }

        let provider = SDKTestingFaceDetectionProvider([
            .usableFace, .malformedObservedFaceContour, .usableFace,
        ])
        let engine = try BeautyEngine(faceDetectionProvider: provider)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let parameters = BeautyParameters(chinTaper: 0.25)
        let first = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
        let rejected = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
        let recovered = try engine.processResult(image: image, metadata: metadata, parameters: parameters)

        XCTAssertEqual(provider.invocationCount, 3)
        XCTAssertEqual(Self.bytes(from: first.output, width: width, height: height), Self.bytes(from: recovered.output, width: width, height: height))
        XCTAssertEqual(Self.bytes(from: rejected.output, width: width, height: height), source)
        XCTAssertEqual(first.metrics, recovered.metrics)
        XCTAssertEqual(first.warnings, recovered.warnings)
        for result in [first, rejected, recovered] { assertRedacted(result) }
    }

    private func process(
        image: CIImage,
        fixture: SDKTestingFaceDetectionFixture,
        parameters: BeautyParameters
    ) throws -> Processed {
        let provider = SDKTestingFaceDetectionProvider([fixture])
        let engine = try BeautyEngine(faceDetectionProvider: provider)
        let result = try engine.processResult(
            image: image,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: parameters
        )
        return Processed(
            result: result,
            bytes: Self.bytes(from: result.output, width: Int(image.extent.width), height: Int(image.extent.height)),
            invocations: provider.invocationCount
        )
    }

    private func assertSignal(
        _ source: [UInt8], _ candidate: [UInt8], width: Int, height: Int,
        regions: [PPMRegion], maxChanged: Int, maxDelta: Int,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let value = signal(source, candidate, width: width, height: height, regions: regions)
        XCTAssertLessThanOrEqual(value.changedPixels, maxChanged, file: file, line: line)
        XCTAssertLessThanOrEqual(value.absoluteRGBDelta, maxDelta, file: file, line: line)
    }

    private func signal(
        _ source: [UInt8], _ candidate: [UInt8], width: Int, height: Int,
        regions: [PPMRegion]
    ) -> Signal {
        signal(source, candidate, width: width, height: height) { x, y in
            regions.contains { $0.contains(x: x, y: y, width: width, height: height) }
        }
    }

    private func signal(
        _ source: [UInt8], _ candidate: [UInt8], width: Int, height: Int,
        include: (Int, Int) -> Bool
    ) -> Signal {
        var result = Signal()
        for y in 0..<height {
            for x in 0..<width where include(x, y) {
                let offset = (y * width + x) * 4
                let red = abs(Int(source[offset]) - Int(candidate[offset]))
                let green = abs(Int(source[offset + 1]) - Int(candidate[offset + 1]))
                let blue = abs(Int(source[offset + 2]) - Int(candidate[offset + 2]))
                if max(red, green, blue) > 2 { result.changedPixels += 1 }
                result.absoluteRGBDelta += red + green + blue
            }
        }
        return result
    }

    private func centerlineTaperQ16(
        _ bytes: [UInt8], width: Int, height: Int, regions: [PPMRegion]
    ) -> Int64 {
        var weight: Int64 = 0
        var weightedDistance: Int64 = 0
        for y in 0..<height {
            for x in 0..<width where regions.contains(where: { $0.contains(x: x, y: y, width: width, height: height) }) {
                let offset = (y * width + x) * 4
                let lumaQ8 = Int64(bytes[offset]) * 77 + Int64(bytes[offset + 1]) * 150 + Int64(bytes[offset + 2]) * 29
                let darkness = max(0, Int64(255 * 256) - lumaQ8)
                weight += darkness
                weightedDistance += darkness * abs(Int64(x * 2 + 1 - width))
            }
        }
        XCTAssertGreaterThan(weight, 0)
        return -(weightedDistance * 65_536 / (weight * Int64(width)))
    }

    private func assertRedacted(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let text = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()
        for forbidden in [
            "landmark", "coordinate", "controlpoint", "control point", "simd",
            "median", "contour", "pixel", "image bytes", "path", "/private/", "file://",
        ] {
            XCTAssertFalse(text.contains(forbidden), "unexpected durable geometry term: \(forbidden)", file: file, line: line)
        }
    }

    private struct Processed {
        let result: BeautyResult<CIImage>
        let bytes: [UInt8]
        let invocations: Int
    }

    private struct Signal {
        var changedPixels = 0
        var absoluteRGBDelta = 0
    }

    private struct PPMRegion {
        let minX: Int
        let maxX: Int
        let minY: Int
        let maxY: Int

        func contains(x: Int, y: Int, width: Int, height: Int) -> Bool {
            let xPPM = (x * 1_000_000) / width
            let yPPM = (y * 1_000_000) / height
            return minX <= xPPM && xPPM < maxX && minY <= yPPM && yPPM < maxY
        }
    }

    private static func fixtureBytes(width: Int, height: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let xPPM = x * 1_000_000 / width
                let yPPM = y * 1_000_000 / height
                let inChinInk = yPPM >= 535_000 && yPPM < 610_000 &&
                    ((xPPM >= 355_000 && xPPM < 455_000) || (xPPM >= 545_000 && xPPM < 645_000))
                if inChinInk {
                    let spatial = UInt8((x * 17 + y * 29) % 41)
                    bytes[offset] = 55 + spatial
                    bytes[offset + 1] = 68 + spatial
                    bytes[offset + 2] = 82 + spatial
                }
                bytes[offset + 3] = 255
            }
        }
        return bytes
    }

    private static func image(bytes: [UInt8], width: Int, height: Int) -> CIImage {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        return CIImage(
            bitmapData: Data(bytes), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    private static func bytes(from image: CIImage, width: Int, height: Int) -> [UInt8] {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        var output = [UInt8](repeating: 0, count: width * height * 4)
        context.render(
            image, toBitmap: &output, rowBytes: width * 4,
            bounds: CGRect(x: 0, y: 0, width: width, height: height),
            format: .RGBA8, colorSpace: colorSpace
        )
        return output
    }
}
