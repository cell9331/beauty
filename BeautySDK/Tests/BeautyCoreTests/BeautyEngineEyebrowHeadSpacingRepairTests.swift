import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyEngineEyebrowHeadSpacingRepairTests: XCTestCase {
    private let leftHead = PPMRegion(minX: 400_000, maxX: 500_000, minY: 240_000, maxY: 430_000)
    private let rightHead = PPMRegion(minX: 500_000, maxX: 600_000, minY: 240_000, maxY: 430_000)
    private let leftOuter = PPMRegion(minX: 240_000, maxX: 400_000, minY: 240_000, maxY: 430_000)
    private let rightOuter = PPMRegion(minX: 600_000, maxX: 760_000, minY: 240_000, maxY: 430_000)
    private let eyes = PPMRegion(minX: 250_000, maxX: 750_000, minY: 430_000, maxY: 500_000)
    private let backgrounds = [
        PPMRegion(minX: 0, maxX: 140_000, minY: 80_000, maxY: 820_000),
        PPMRegion(minX: 860_000, maxX: 1_000_000, minY: 80_000, maxY: 820_000),
    ]
    private let watermark = PPMRegion(minX: 820_000, maxX: 980_000, minY: 920_000, maxY: 985_000)

    func testBROW01PublicFacadePassesFrozenSignedSemanticSiblingProtectionAndMetadataContract() throws {
        let fixture = Self.fixture()
        let source = fixture.bytes
        let image = fixture.image

        let neutral = try process(image: image, fixture: .phase92PairedObservedEyebrows, parameters: .init())
        let headPlus = try process(image: image, fixture: .phase92PairedObservedEyebrows, parameters: .init(eyebrowHeadSpacing: 0.25))
        let repeatedPlus = try process(image: image, fixture: .phase92PairedObservedEyebrows, parameters: .init(eyebrowHeadSpacing: 0.25))
        let headMinus = try process(image: image, fixture: .phase92PairedObservedEyebrows, parameters: .init(eyebrowHeadSpacing: -0.25))
        let wholePlus = try process(image: image, fixture: .phase92PairedObservedEyebrows, parameters: .init(eyebrowSpacing: 0.25))
        let wholeMinus = try process(image: image, fixture: .phase92PairedObservedEyebrows, parameters: .init(eyebrowSpacing: -0.25))

        XCTAssertEqual(neutral.invocations, 0)
        XCTAssertEqual(neutral.bytes, source)
        XCTAssertEqual(headPlus.bytes, repeatedPlus.bytes)
        XCTAssertEqual(headPlus.result.metrics, repeatedPlus.result.metrics)
        XCTAssertEqual(headPlus.result.warnings, repeatedPlus.result.warnings)
        XCTAssertEqual(headPlus.result.output.extent, image.extent)
        XCTAssertEqual(headMinus.result.output.extent, image.extent)
        XCTAssertEqual(image.colorSpace?.name, CGColorSpace.sRGB)

        for rendered in [headPlus, headMinus, wholePlus, wholeMinus] {
            XCTAssertEqual(rendered.invocations, 1)
            assertUsableMetadata(rendered.result)
            XCTAssertTrue(stride(from: 3, to: rendered.bytes.count, by: 4).allSatisfy { rendered.bytes[$0] == 255 })
            assertRedacted(rendered.result)
        }

        let regions = [leftHead, rightHead]
        let sourceGap = innerBrowHeadGapQ16(source, width: fixture.width, height: fixture.height)
        let neutralGap = innerBrowHeadGapQ16(neutral.bytes, width: fixture.width, height: fixture.height)
        XCTAssertEqual(neutralGap, sourceGap)

        let plusSourceSignal = signal(source, headPlus.bytes, width: fixture.width, height: fixture.height, regions: regions)
        let plusNeutralSignal = signal(neutral.bytes, headPlus.bytes, width: fixture.width, height: fixture.height, regions: regions)
        let minusSourceSignal = signal(source, headMinus.bytes, width: fixture.width, height: fixture.height, regions: regions)
        let minusNeutralSignal = signal(neutral.bytes, headMinus.bytes, width: fixture.width, height: fixture.height, regions: regions)

        for (name, rendered, sourceSignal, neutralSignal) in [
            ("head positive", headPlus, plusSourceSignal, plusNeutralSignal),
            ("head negative", headMinus, minusSourceSignal, minusNeutralSignal),
        ] {
            XCTAssertGreaterThanOrEqual(sourceSignal.changedPixels, 500, name)
            XCTAssertGreaterThanOrEqual(sourceSignal.absoluteRGBDelta, 2_000, name)
            XCTAssertGreaterThanOrEqual(neutralSignal.changedPixels, 500, name)
            XCTAssertGreaterThanOrEqual(neutralSignal.absoluteRGBDelta, 2_000, name)
            assertProtection(source, rendered.bytes, width: fixture.width, height: fixture.height, name: name)
            assertProtection(neutral.bytes, rendered.bytes, width: fixture.width, height: fixture.height, name: "\(name) versus neutral")
        }

        let headPlusGap = innerBrowHeadGapQ16(headPlus.bytes, width: fixture.width, height: fixture.height)
        let headMinusGap = innerBrowHeadGapQ16(headMinus.bytes, width: fixture.width, height: fixture.height)
        XCTAssertGreaterThanOrEqual(headPlusGap - sourceGap, 16)
        XCTAssertGreaterThanOrEqual(headPlusGap - neutralGap, 16)
        XCTAssertLessThanOrEqual(headMinusGap - sourceGap, -16)
        XCTAssertLessThanOrEqual(headMinusGap - neutralGap, -16)
        XCTAssertGreaterThanOrEqual(abs(headPlusGap - headMinusGap), 16)

        let wholePlusGap = innerBrowHeadGapQ16(wholePlus.bytes, width: fixture.width, height: fixture.height)
        let wholeMinusGap = innerBrowHeadGapQ16(wholeMinus.bytes, width: fixture.width, height: fixture.height)
        let siblingDifferences = [
            ("head plus versus whole plus", abs(headPlusGap - wholePlusGap)),
            ("head plus versus whole minus", abs(headPlusGap - wholeMinusGap)),
            ("head minus versus whole plus", abs(headMinusGap - wholePlusGap)),
            ("head minus versus whole minus", abs(headMinusGap - wholeMinusGap)),
        ]
        for (name, difference) in siblingDifferences {
            XCTAssertGreaterThanOrEqual(difference, 16, name)
        }

        let protection = fixedProtectionAggregate(
            baselines: [source, neutral.bytes],
            candidates: [headPlus.bytes, headMinus.bytes],
            width: fixture.width,
            height: fixture.height
        )
        print("BROW01_SIGNAL paired_plus_changed=\(plusSourceSignal.changedPixels) paired_minus_changed=\(minusSourceSignal.changedPixels) plus_source_rgb=\(plusSourceSignal.absoluteRGBDelta) minus_source_rgb=\(minusSourceSignal.absoluteRGBDelta) plus_neutral_changed=\(plusNeutralSignal.changedPixels) minus_neutral_changed=\(minusNeutralSignal.changedPixels) plus_neutral_rgb=\(plusNeutralSignal.absoluteRGBDelta) minus_neutral_rgb=\(minusNeutralSignal.absoluteRGBDelta) plus_darkness=\(headPlusGap) minus_darkness=\(headMinusGap) source_darkness=\(sourceGap) neutral_darkness=\(neutralGap)")
        print("BROW01_FIXED_AGGREGATES plus_source_q16=\(headPlusGap - sourceGap) plus_neutral_q16=\(headPlusGap - neutralGap) minus_source_q16=\(headMinusGap - sourceGap) minus_neutral_q16=\(headMinusGap - neutralGap) opposite_q16=\(abs(headPlusGap - headMinusGap)) head_plus_whole_plus_q16=\(siblingDifferences[0].1) head_plus_whole_minus_q16=\(siblingDifferences[1].1) head_minus_whole_plus_q16=\(siblingDifferences[2].1) head_minus_whole_minus_q16=\(siblingDifferences[3].1) outside_changed_max=\(protection.outside.changedPixels) outside_rgb_max=\(protection.outside.absoluteRGBDelta) outer_changed_max=\(protection.outer.changedPixels) outer_rgb_max=\(protection.outer.absoluteRGBDelta) eye_changed_max=\(protection.eye.changedPixels) eye_rgb_max=\(protection.eye.absoluteRGBDelta) background_changed_max=\(protection.background.changedPixels) background_rgb_max=\(protection.background.absoluteRGBDelta) watermark_changed_max=\(protection.watermark.changedPixels) watermark_rgb_max=\(protection.watermark.absoluteRGBDelta)")
    }

    func testBROW01PerSideEligibilityAndProviderEmptyRemainSourceSafe() throws {
        let fixture = Self.fixture()
        let source = fixture.bytes
        let image = fixture.image
        let parameters = BeautyParameters(eyebrowHeadSpacing: 0.25)

        let leftOnly = try process(image: image, fixture: .phase92LeftOnlyObservedEyebrow, parameters: parameters)
        let leftSignal = signal(source, leftOnly.bytes, width: fixture.width, height: fixture.height, regions: [leftHead])
        let leftPeerSignal = signal(source, leftOnly.bytes, width: fixture.width, height: fixture.height, regions: [rightHead])
        XCTAssertGreaterThan(leftSignal.changedPixels, 0)
        assertSignal(source, leftOnly.bytes, width: fixture.width, height: fixture.height, regions: [rightHead], maxChanged: 0, maxDelta: 0, name: "left-only rejected peer")

        let rightOnly = try process(image: image, fixture: .phase92RightOnlyObservedEyebrow, parameters: parameters)
        let rightSignal = signal(source, rightOnly.bytes, width: fixture.width, height: fixture.height, regions: [rightHead])
        let rightPeerSignal = signal(source, rightOnly.bytes, width: fixture.width, height: fixture.height, regions: [leftHead])
        XCTAssertGreaterThan(rightSignal.changedPixels, 0)
        assertSignal(source, rightOnly.bytes, width: fixture.width, height: fixture.height, regions: [leftHead], maxChanged: 0, maxDelta: 0, name: "right-only rejected peer")

        for rendered in [leftOnly, rightOnly] {
            XCTAssertEqual(rendered.invocations, 1)
            assertUsableMetadata(rendered.result)
            assertRedacted(rendered.result)
        }

        for invalid: SDKTestingFaceDetectionFixture in [.missingObservedEyebrows, .malformedObservedEyebrows, .noFace] {
            let rendered = try process(image: image, fixture: invalid, parameters: parameters)
            XCTAssertEqual(rendered.invocations, 1)
            XCTAssertEqual(rendered.bytes, source)
            assertRedacted(rendered.result)
        }

        let providerEmpty = try process(image: image, fixture: .phase92PairedObservedEyebrows, parameters: .init())
        XCTAssertEqual(providerEmpty.invocations, 0)
        XCTAssertEqual(providerEmpty.bytes, source)
        XCTAssertEqual(providerEmpty.result.detectionSummary?.availability, .notRun)
        XCTAssertEqual(providerEmpty.result.detectionSummary?.faceCount, 0)
        XCTAssertEqual(providerEmpty.result.detectionSummary?.usedFaceCount, 0)
        assertRedacted(providerEmpty.result)
        print("BROW01_SIDE_SIGNAL left_changed=\(leftSignal.changedPixels) right_changed=\(rightSignal.changedPixels) left_peer_changed=\(leftPeerSignal.changedPixels) right_peer_changed=\(rightPeerSignal.changedPixels)")
    }

    func testBROW01ValidInvalidValidRecoveryIsByteDeterministicAndRedacted() throws {
        let fixture = Self.fixture()
        let provider = SDKTestingFaceDetectionProvider([
            .phase92PairedObservedEyebrows, .malformedObservedEyebrows, .phase92PairedObservedEyebrows,
        ])
        let engine = try BeautyEngine(faceDetectionProvider: provider)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let parameters = BeautyParameters(eyebrowHeadSpacing: 0.25)

        let first = try engine.processResult(image: fixture.image, metadata: metadata, parameters: parameters)
        let rejected = try engine.processResult(image: fixture.image, metadata: metadata, parameters: parameters)
        let recovered = try engine.processResult(image: fixture.image, metadata: metadata, parameters: parameters)
        let firstBytes = Self.bytes(from: first.output, width: fixture.width, height: fixture.height)
        let rejectedBytes = Self.bytes(from: rejected.output, width: fixture.width, height: fixture.height)
        let recoveredBytes = Self.bytes(from: recovered.output, width: fixture.width, height: fixture.height)

        XCTAssertEqual(provider.invocationCount, 3)
        XCTAssertEqual(firstBytes, recoveredBytes)
        XCTAssertEqual(rejectedBytes, fixture.bytes)
        XCTAssertEqual(first.metrics, recovered.metrics)
        XCTAssertEqual(first.warnings, recovered.warnings)
        XCTAssertEqual(first.detectionSummary?.availability, recovered.detectionSummary?.availability)
        XCTAssertEqual(first.detectionSummary?.reasons, recovered.detectionSummary?.reasons)
        XCTAssertEqual(first.detectionSummary?.faceCount, recovered.detectionSummary?.faceCount)
        XCTAssertEqual(first.detectionSummary?.usedFaceCount, recovered.detectionSummary?.usedFaceCount)
        XCTAssertEqual(first.output.extent, recovered.output.extent)
        let validSignal = signal(fixture.bytes, firstBytes, width: fixture.width, height: fixture.height, regions: [leftHead, rightHead])
        XCTAssertGreaterThan(validSignal.changedPixels, 0)
        for result in [first, rejected, recovered] { assertRedacted(result) }
        print("BROW01_RECOVERY_SIGNAL valid_changed=\(validSignal.changedPixels) recovered_equal=\(firstBytes == recoveredBytes ? 1 : 0) rejected_source_equal=\(rejectedBytes == fixture.bytes ? 1 : 0)")
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

    private func assertUsableMetadata(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(result.detectionSummary?.availability, .usable, file: file, line: line)
        XCTAssertEqual(result.detectionSummary?.reasons, [], file: file, line: line)
        XCTAssertEqual(result.detectionSummary?.faceCount, 1, file: file, line: line)
        XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.detection.faceCount"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.effects.cappedCount"], 0, file: file, line: line)
        XCTAssertGreaterThan(result.metrics["beauty.effects.geometryPointCount"] ?? 0, 0, file: file, line: line)
        XCTAssertFalse(result.warnings.contains { $0.code == "eyebrow_inputs_missing" }, file: file, line: line)
    }

    private func assertProtection(
        _ baseline: [UInt8], _ candidate: [UInt8], width: Int, height: Int, name: String,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let outside = signal(baseline, candidate, width: width, height: height) { x, y in
            !self.leftHead.contains(x: x, y: y, width: width, height: height)
                && !self.rightHead.contains(x: x, y: y, width: width, height: height)
        }
        XCTAssertLessThanOrEqual(outside.changedPixels, 128, name, file: file, line: line)
        XCTAssertLessThanOrEqual(outside.absoluteRGBDelta, 512, name, file: file, line: line)
        assertSignal(baseline, candidate, width: width, height: height, regions: [leftOuter], maxChanged: 64, maxDelta: 256, name: "\(name) left outer", file: file, line: line)
        assertSignal(baseline, candidate, width: width, height: height, regions: [rightOuter], maxChanged: 64, maxDelta: 256, name: "\(name) right outer", file: file, line: line)
        assertSignal(baseline, candidate, width: width, height: height, regions: [eyes], maxChanged: 64, maxDelta: 256, name: "\(name) eyes", file: file, line: line)
        assertSignal(baseline, candidate, width: width, height: height, regions: backgrounds, maxChanged: 0, maxDelta: 0, name: "\(name) backgrounds", file: file, line: line)
        assertSignal(baseline, candidate, width: width, height: height, regions: [watermark], maxChanged: 0, maxDelta: 0, name: "\(name) watermark", file: file, line: line)
    }

    private func fixedProtectionAggregate(
        baselines: [[UInt8]], candidates: [[UInt8]], width: Int, height: Int
    ) -> ProtectionAggregate {
        var value = ProtectionAggregate()
        for baseline in baselines {
            for candidate in candidates {
                value.outside.formMaximum(signal(baseline, candidate, width: width, height: height) { x, y in
                    !self.leftHead.contains(x: x, y: y, width: width, height: height)
                        && !self.rightHead.contains(x: x, y: y, width: width, height: height)
                })
                value.outer.formMaximum(signal(baseline, candidate, width: width, height: height, regions: [leftOuter]))
                value.outer.formMaximum(signal(baseline, candidate, width: width, height: height, regions: [rightOuter]))
                value.eye.formMaximum(signal(baseline, candidate, width: width, height: height, regions: [eyes]))
                value.background.formMaximum(signal(baseline, candidate, width: width, height: height, regions: backgrounds))
                value.watermark.formMaximum(signal(baseline, candidate, width: width, height: height, regions: [watermark]))
            }
        }
        return value
    }

    private func assertSignal(
        _ baseline: [UInt8], _ candidate: [UInt8], width: Int, height: Int,
        regions: [PPMRegion], maxChanged: Int, maxDelta: Int, name: String,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let value = signal(baseline, candidate, width: width, height: height, regions: regions)
        XCTAssertLessThanOrEqual(value.changedPixels, maxChanged, name, file: file, line: line)
        XCTAssertLessThanOrEqual(value.absoluteRGBDelta, maxDelta, name, file: file, line: line)
    }

    private func signal(
        _ baseline: [UInt8], _ candidate: [UInt8], width: Int, height: Int,
        regions: [PPMRegion]
    ) -> Signal {
        signal(baseline, candidate, width: width, height: height) { x, y in
            regions.contains { $0.contains(x: x, y: y, width: width, height: height) }
        }
    }

    private func signal(
        _ baseline: [UInt8], _ candidate: [UInt8], width: Int, height: Int,
        include: (Int, Int) -> Bool
    ) -> Signal {
        var value = Signal()
        for y in 0..<height {
            for x in 0..<width where include(x, y) {
                let offset = (y * width + x) * 4
                let red = abs(Int(baseline[offset]) - Int(candidate[offset]))
                let green = abs(Int(baseline[offset + 1]) - Int(candidate[offset + 1]))
                let blue = abs(Int(baseline[offset + 2]) - Int(candidate[offset + 2]))
                if max(red, green, blue) > 2 { value.changedPixels += 1 }
                value.absoluteRGBDelta += red + green + blue
            }
        }
        return value
    }

    private func innerBrowHeadGapQ16(_ bytes: [UInt8], width: Int, height: Int) -> Int64 {
        let left = darknessCentroidXQ16(bytes, width: width, height: height, region: leftHead)
        let right = darknessCentroidXQ16(bytes, width: width, height: height, region: rightHead)
        return right - left
    }

    private func darknessCentroidXQ16(
        _ bytes: [UInt8], width: Int, height: Int, region: PPMRegion,
        file: StaticString = #filePath, line: UInt = #line
    ) -> Int64 {
        var darknessTotal: Int64 = 0
        var xMoment: Int64 = 0
        for y in 0..<height {
            for x in 0..<width where region.contains(x: x, y: y, width: width, height: height) {
                let offset = (y * width + x) * 4
                let lumaQ8 = Int64(bytes[offset]) * 77
                    + Int64(bytes[offset + 1]) * 150
                    + Int64(bytes[offset + 2]) * 29
                let darkness = max(0, Int64(255 * 256) - lumaQ8)
                darknessTotal += darkness
                xMoment += darkness * Int64(x * 2 + 1)
            }
        }
        XCTAssertGreaterThan(darknessTotal, 0, file: file, line: line)
        return xMoment * 65_536 / (darknessTotal * Int64(width * 2))
    }

    private func assertRedacted(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let text = (
            result.warnings.map { "\($0.code) \($0.message)" }
                + Array(result.metrics.keys)
                + (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()
        for forbidden in [
            "landmark", "coordinate", "controlpoint", "control point", "simd", "mask",
            "raw", "pixel", "image bytes", "transcript", "path", "/private/", "file://",
        ] {
            XCTAssertFalse(text.contains(forbidden), "unexpected durable detail term: \(forbidden)", file: file, line: line)
        }
    }

    private struct Processed {
        let result: BeautyResult<CIImage>
        let bytes: [UInt8]
        let invocations: Int
    }

    private struct Fixture {
        let width: Int
        let height: Int
        let bytes: [UInt8]
        let image: CIImage
    }

    private struct Signal {
        var changedPixels = 0
        var absoluteRGBDelta = 0

        mutating func formMaximum(_ other: Signal) {
            changedPixels = max(changedPixels, other.changedPixels)
            absoluteRGBDelta = max(absoluteRGBDelta, other.absoluteRGBDelta)
        }
    }

    private struct ProtectionAggregate {
        var outside = Signal()
        var outer = Signal()
        var eye = Signal()
        var background = Signal()
        var watermark = Signal()
    }

    private struct PPMRegion {
        let minX: Int
        let maxX: Int
        let minY: Int
        let maxY: Int

        func contains(x: Int, y: Int, width: Int, height: Int) -> Bool {
            let xPPM = x * 1_000_000 / width
            let yPPM = y * 1_000_000 / height
            return minX <= xPPM && xPPM < maxX && minY <= yPPM && yPPM < maxY
        }
    }

    private static func fixture() -> Fixture {
        let width = 512
        let height = 512
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let xPPM = x * 1_000_000 / width
                let yPPM = y * 1_000_000 / height
                let offset = (y * width + x) * 4
                let isBrow = yPPM >= 270_000 && yPPM < 410_000
                    && ((xPPM >= 270_000 && xPPM < 495_000) || (xPPM >= 505_000 && xPPM < 730_000))
                let isEye = yPPM >= 450_000 && yPPM < 480_000
                    && ((xPPM >= 330_000 && xPPM < 460_000) || (xPPM >= 540_000 && xPPM < 670_000))
                let isBackground = yPPM >= 100_000 && yPPM < 180_000
                    && (xPPM < 120_000 || xPPM >= 880_000)
                let isWatermark = xPPM >= 850_000 && xPPM < 950_000
                    && yPPM >= 940_000 && yPPM < 970_000
                if isBrow {
                    let texture = UInt8((x * 31 + y * 17) % 61)
                    bytes[offset] = 35 + texture
                    bytes[offset + 1] = 45 + texture
                    bytes[offset + 2] = 55 + texture
                } else if isEye {
                    let texture = UInt8((x * 13 + y * 23) % 37)
                    bytes[offset] = 85 + texture
                    bytes[offset + 1] = 105 + texture
                    bytes[offset + 2] = 125 + texture
                } else if isBackground {
                    bytes[offset] = 205
                    bytes[offset + 1] = 220
                    bytes[offset + 2] = 235
                } else if isWatermark {
                    bytes[offset] = 180
                    bytes[offset + 1] = 190
                    bytes[offset + 2] = 200
                }
                bytes[offset + 3] = 255
            }
        }
        return Fixture(width: width, height: height, bytes: bytes, image: image(bytes: bytes, width: width, height: height))
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
