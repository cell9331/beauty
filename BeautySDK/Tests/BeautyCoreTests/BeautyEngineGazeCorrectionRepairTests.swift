import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyEngineGazeCorrectionRepairTests: XCTestCase {
    private let leftTarget = PPMRegion(minX: 300_000, maxX: 480_000, minY: 550_000, maxY: 700_000)
    private let rightTarget = PPMRegion(minX: 520_000, maxX: 700_000, minY: 550_000, maxY: 700_000)
    private let eyeContours = [
        PPMRegion(minX: 100_000, maxX: 300_000, minY: 550_000, maxY: 700_000),
        PPMRegion(minX: 700_000, maxX: 900_000, minY: 550_000, maxY: 700_000),
    ]
    private let eyebrows = PPMRegion(minX: 240_000, maxX: 760_000, minY: 400_000, maxY: 540_000)
    private let backgrounds = [
        PPMRegion(minX: 0, maxX: 90_000, minY: 80_000, maxY: 820_000),
        PPMRegion(minX: 910_000, maxX: 1_000_000, minY: 80_000, maxY: 820_000),
    ]
    private let watermark = PPMRegion(minX: 820_000, maxX: 980_000, minY: 920_000, maxY: 985_000)
    private let leftCenter = Point(x: 0.40, y: 0.62)
    private let rightCenter = Point(x: 0.60, y: 0.62)

    func testEYE01PublicFacadeMovesBothChromaticMarkersTowardOnlyTheirOwnCenters() throws {
        let width = 512
        let height = 512
        let source = Self.fixtureBytes(width: width, height: height)
        let image = Self.image(bytes: source, width: width, height: height)
        let active = try process(image: image, fixture: .gazeBilateralOffCenter, parameters: .init(gazeCorrection: 0.25))
        let repeated = try process(image: image, fixture: .gazeBilateralOffCenter, parameters: .init(gazeCorrection: 0.25))
        let neutral = try process(image: image, fixture: .gazeBilateralOffCenter, parameters: .init())

        XCTAssertEqual(active.invocations, 1)
        XCTAssertEqual(neutral.invocations, 0)
        XCTAssertEqual(neutral.bytes, source)
        XCTAssertEqual(active.bytes, repeated.bytes)
        XCTAssertEqual(active.result.metrics, repeated.result.metrics)
        XCTAssertEqual(active.result.output.extent, image.extent)
        XCTAssertEqual(image.colorSpace?.name, CGColorSpace.sRGB)
        XCTAssertTrue(stride(from: 3, to: active.bytes.count, by: 4).allSatisfy { active.bytes[$0] == 255 })
        XCTAssertEqual(active.result.detectionSummary?.availability, .usable)
        XCTAssertEqual(active.result.detectionSummary?.reasons, [])
        XCTAssertEqual(active.result.detectionSummary?.faceCount, 1)
        XCTAssertEqual(active.result.detectionSummary?.usedFaceCount, 1)
        assertGazeMetrics(active.result, eligible: 2, corrected: 2)
        assertRedacted(active.result)

        let leftSource = try markerCentroid(source, marker: .left, width: width, height: height, region: leftTarget)
        let leftOutput = try markerCentroid(active.bytes, marker: .left, width: width, height: height, region: leftTarget)
        let rightSource = try markerCentroid(source, marker: .right, width: width, height: height, region: rightTarget)
        let rightOutput = try markerCentroid(active.bytes, marker: .right, width: width, height: height, region: rightTarget)
        let leftReduction = q16(distance(leftSource, leftCenter) - distance(leftOutput, leftCenter))
        let rightReduction = q16(distance(rightSource, rightCenter) - distance(rightOutput, rightCenter))
        XCTAssertGreaterThanOrEqual(leftReduction, 16)
        XCTAssertGreaterThanOrEqual(rightReduction, 16)
        XCTAssertGreaterThan(distance(leftOutput, rightCenter), distance(leftSource, rightCenter))
        XCTAssertGreaterThan(distance(rightOutput, leftCenter), distance(rightSource, leftCenter))

        let targets = signal(source, active.bytes, width: width, height: height, regions: [leftTarget, rightTarget])
        XCTAssertGreaterThanOrEqual(targets.changedPixels, 256)
        XCTAssertGreaterThanOrEqual(targets.absoluteRGBDelta, 768)
        let outside = signal(source, active.bytes, width: width, height: height) { x, y in
            !self.leftTarget.contains(x: x, y: y, width: width, height: height)
                && !self.rightTarget.contains(x: x, y: y, width: width, height: height)
        }
        XCTAssertLessThanOrEqual(outside.changedPixels, 128)
        XCTAssertLessThanOrEqual(outside.absoluteRGBDelta, 512)
        let contourSignal = signal(source, active.bytes, width: width, height: height, regions: eyeContours)
        let eyebrowSignal = signal(source, active.bytes, width: width, height: height, regions: [eyebrows])
        let backgroundSignal = signal(source, active.bytes, width: width, height: height, regions: backgrounds)
        let watermarkSignal = signal(source, active.bytes, width: width, height: height, regions: [watermark])
        XCTAssertLessThanOrEqual(contourSignal.changedPixels, 64)
        XCTAssertLessThanOrEqual(contourSignal.absoluteRGBDelta, 256)
        XCTAssertLessThanOrEqual(eyebrowSignal.changedPixels, 32)
        XCTAssertLessThanOrEqual(eyebrowSignal.absoluteRGBDelta, 128)
        XCTAssertEqual(backgroundSignal.changedPixels, 0)
        XCTAssertEqual(backgroundSignal.absoluteRGBDelta, 0)
        XCTAssertEqual(watermarkSignal.changedPixels, 0)
        XCTAssertEqual(watermarkSignal.absoluteRGBDelta, 0)

        let sibling = try process(image: image, fixture: .gazeBilateralOffCenter, parameters: .init(pupilSize: 0.25))
        XCTAssertTrue(Set(sibling.result.metrics.keys).isDisjoint(with: gazeMetricKeys))
        let siblingSignal = signal(active.bytes, sibling.bytes, width: width, height: height, regions: [leftTarget, rightTarget])
        XCTAssertGreaterThanOrEqual(siblingSignal.changedPixels, 256)
        XCTAssertGreaterThanOrEqual(siblingSignal.absoluteRGBDelta, 768)
    }

    func testEYE01OneValidSideChangesOnlyItsOwnROIAndRejectedSidesRemainSourceExact() throws {
        let width = 512
        let height = 512
        let source = Self.fixtureBytes(width: width, height: height)
        let image = Self.image(bytes: source, width: width, height: height)
        let rows: [(String, SDKTestingFaceDetectionFixture, Int, Int, PPMRegion, PPMRegion)] = [
            ("left only", .gazeLeftOnly, 1, 1, leftTarget, rightTarget),
            ("left plus missing", .gazeLeftValidRightMissing, 1, 1, leftTarget, rightTarget),
            ("left plus malformed", .gazeLeftValidRightMalformed, 1, 1, leftTarget, rightTarget),
            ("right only", .gazeRightOnly, 1, 1, rightTarget, leftTarget),
        ]

        for (name, fixture, eligible, corrected, activeROI, protectedROI) in rows {
            let output = try process(image: image, fixture: fixture, parameters: .init(gazeCorrection: 0.25))
            assertGazeMetrics(output.result, eligible: eligible, corrected: corrected, name: name)
            let activeSignal = signal(source, output.bytes, width: width, height: height, regions: [activeROI])
            XCTAssertGreaterThan(activeSignal.changedPixels, 0, name)
            assertSignal(source, output.bytes, width: width, height: height, regions: [protectedROI], maxChanged: 0, maxDelta: 0, name: name)
            assertRedacted(output.result, name: name)
        }

        let rejectedRows: [(String, SDKTestingFaceDetectionFixture)] = [
            ("invalid pupil", .gazeInvalidPupil),
            ("centered", .gazeCentered),
            ("no face", .noFace),
            ("dead-zone edge", .gazeDeadZoneEdge),
        ]
        for (name, fixture) in rejectedRows {
            let output = try process(image: image, fixture: fixture, parameters: .init(gazeCorrection: 0.25))
            XCTAssertEqual(output.bytes, source, name)
            assertGazeMetrics(output.result, eligible: 0, corrected: 0, name: name)
            assertRedacted(output.result, name: name)
        }

        let ratio = try process(image: image, fixture: .gazePairRatioImplausible, parameters: .init(gazeCorrection: 0.25))
        assertGazeMetrics(ratio.result, eligible: 2, corrected: 2, name: "pair ratio remains gaze-independent")
        XCTAssertGreaterThan(signal(source, ratio.bytes, width: width, height: height, regions: [leftTarget]).changedPixels, 0)
        XCTAssertGreaterThan(signal(source, ratio.bytes, width: width, height: height, regions: [rightTarget]).changedPixels, 0)
    }

    func testEYE01JustAboveDeadZoneCapAndValidInvalidValidRecoveryAreDeterministic() throws {
        let width = 512
        let height = 512
        let source = Self.fixtureBytes(width: width, height: height)
        let image = Self.image(bytes: source, width: width, height: height)
        let above = try process(image: image, fixture: .gazeJustAboveDeadZone, parameters: .init(gazeCorrection: 0.25))
        XCTAssertNotEqual(above.bytes, source)
        assertGazeMetrics(above.result, eligible: 2, corrected: 2)

        let capped = try process(image: image, fixture: .gazeBilateralOffCenter, parameters: .init(gazeCorrection: 1))
        let exact = try process(image: image, fixture: .gazeBilateralOffCenter, parameters: .init(gazeCorrection: 0.25))
        XCTAssertEqual(capped.bytes, exact.bytes)
        XCTAssertEqual(capped.result.metrics["beauty.effects.gazeMinimumReductionQ16"], exact.result.metrics["beauty.effects.gazeMinimumReductionQ16"])
        XCTAssertEqual(capped.result.metrics["beauty.effects.cappedCount"], 1)
        XCTAssertEqual(exact.result.metrics["beauty.effects.cappedCount"], 0)

        let provider = SDKTestingFaceDetectionProvider([
            .gazeBilateralOffCenter, .gazeLeftValidRightMalformed, .gazeBilateralOffCenter,
        ])
        let engine = try BeautyEngine(faceDetectionProvider: provider)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let parameters = BeautyParameters(gazeCorrection: 0.25)
        let first = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
        let invalid = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
        let recovered = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
        let firstBytes = Self.bytes(from: first.output, width: width, height: height)
        let invalidBytes = Self.bytes(from: invalid.output, width: width, height: height)
        let recoveredBytes = Self.bytes(from: recovered.output, width: width, height: height)

        XCTAssertEqual(provider.invocationCount, 3)
        XCTAssertEqual(firstBytes, recoveredBytes)
        XCTAssertEqual(first.metrics, recovered.metrics)
        XCTAssertNotEqual(firstBytes, invalidBytes)
        assertSignal(source, invalidBytes, width: width, height: height, regions: [rightTarget], maxChanged: 0, maxDelta: 0)
        for result in [first, invalid, recovered] { assertRedacted(result) }
    }

    private var gazeMetricKeys: Set<String> {
        [
            "beauty.effects.gazeEligibleCount", "beauty.effects.gazeCorrectedCount",
            "beauty.effects.gazeRejectedCount", "beauty.effects.gazeAllReduced",
            "beauty.effects.gazeAbstained", "beauty.effects.gazeMinimumReductionQ16",
        ]
    }

    private func assertGazeMetrics(
        _ result: BeautyResult<CIImage>, eligible: Int, corrected: Int,
        name: String = "", file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertEqual(result.metrics["beauty.effects.gazeEligibleCount"], Double(eligible), name, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.effects.gazeCorrectedCount"], Double(corrected), name, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.effects.gazeRejectedCount"], Double(eligible - corrected), name, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.effects.gazeAllReduced"], eligible > 0 && corrected == eligible ? 1 : 0, name, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.effects.gazeAbstained"], corrected == 0 ? 1 : 0, name, file: file, line: line)
        let minimum = result.metrics["beauty.effects.gazeMinimumReductionQ16"]
        XCTAssertEqual(minimum?.rounded(), minimum, name, file: file, line: line)
        if eligible > 0 && corrected == eligible {
            XCTAssertTrue((1...65_536).contains(Int(minimum ?? 0)), name, file: file, line: line)
        } else {
            XCTAssertEqual(minimum, 0, name, file: file, line: line)
        }
        XCTAssertTrue(Set(result.metrics.keys).isSuperset(of: gazeMetricKeys), name, file: file, line: line)
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

    private func markerCentroid(
        _ bytes: [UInt8], marker: Marker, width: Int, height: Int, region: PPMRegion
    ) throws -> Point {
        var count = 0
        var xTotal = 0.0
        var yTotal = 0.0
        for y in 0..<height {
            for x in 0..<width where region.contains(x: x, y: y, width: width, height: height) {
                let offset = (y * width + x) * 4
                let red = Int(bytes[offset])
                let green = Int(bytes[offset + 1])
                let blue = Int(bytes[offset + 2])
                let matches = marker == .left
                    ? red >= 150 && red >= green * 2 && red >= blue * 2
                    : blue >= 150 && blue >= red * 2 && blue >= green * 2
                if matches {
                    count += 1
                    xTotal += (Double(x) + 0.5) / Double(width)
                    yTotal += (Double(y) + 0.5) / Double(height)
                }
            }
        }
        guard count >= 16 else { throw OracleError.markerMissing }
        return Point(x: xTotal / Double(count), y: yTotal / Double(count))
    }

    private func q16(_ value: Double) -> Int {
        Int((value * 65_536).rounded(.toNearestOrAwayFromZero))
    }

    private func distance(_ lhs: Point, _ rhs: Point) -> Double {
        hypot(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    private func assertSignal(
        _ source: [UInt8], _ candidate: [UInt8], width: Int, height: Int,
        regions: [PPMRegion], maxChanged: Int, maxDelta: Int, name: String = "",
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let value = signal(source, candidate, width: width, height: height, regions: regions)
        XCTAssertLessThanOrEqual(value.changedPixels, maxChanged, name, file: file, line: line)
        XCTAssertLessThanOrEqual(value.absoluteRGBDelta, maxDelta, name, file: file, line: line)
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

    private func assertRedacted(
        _ result: BeautyResult<CIImage>, name: String = "",
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let text = (
            result.warnings.map { "\($0.code) \($0.message)" }
                + Array(result.metrics.keys)
                + (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()
        for forbidden in [
            "landmark", "coordinate", "controlpoint", "control point", "simd",
            "pupilx", "pupily", "leftpupil", "rightpupil", "marker", "pixel",
            "image bytes", "path", "/private/", "file://", "transcript",
        ] {
            XCTAssertFalse(text.contains(forbidden), "\(name) unexpected durable term: \(forbidden)", file: file, line: line)
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

    private struct Point {
        let x: Double
        let y: Double
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

    private enum Marker { case left, right }
    private enum OracleError: Error { case markerMissing }

    private static func fixtureBytes(width: Int, height: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let xPPM = x * 1_000_000 / width
                let yPPM = y * 1_000_000 / height
                let inEyeTexture = yPPM >= 550_000 && yPPM < 700_000
                    && ((xPPM >= 300_000 && xPPM < 480_000)
                        || (xPPM >= 520_000 && xPPM < 700_000))
                let inEyebrow = yPPM >= 435_000 && yPPM < 475_000
                    && xPPM >= 260_000 && xPPM < 740_000
                if inEyeTexture {
                    let spatial = UInt8((x * 13 + y * 19) % 53)
                    bytes[offset] = 95 + spatial
                    bytes[offset + 1] = 105 + UInt8((x * 7 + y * 11) % 47)
                    bytes[offset + 2] = 115 + UInt8((x * 5 + y * 17) % 43)
                } else if inEyebrow {
                    bytes[offset] = 72
                    bytes[offset + 1] = 58
                    bytes[offset + 2] = 49
                }
                bytes[offset + 3] = 255
            }
        }
        paintMarker(&bytes, width: width, height: height, center: Point(x: 0.43, y: 0.62), marker: .left)
        paintMarker(&bytes, width: width, height: height, center: Point(x: 0.57, y: 0.62), marker: .right)
        return bytes
    }

    private static func paintMarker(
        _ bytes: inout [UInt8], width: Int, height: Int, center: Point, marker: Marker
    ) {
        let centerX = Int((center.x * Double(width)).rounded(.down))
        let centerY = Int((center.y * Double(height)).rounded(.down))
        for y in (centerY - 6)...(centerY + 6) {
            for x in (centerX - 6)...(centerX + 6) where (x - centerX) * (x - centerX) + (y - centerY) * (y - centerY) <= 36 {
                let offset = (y * width + x) * 4
                let texture = UInt8((x * 3 + y * 5) & 15)
                if marker == .left {
                    bytes[offset] = 230 + texture
                    bytes[offset + 1] = 24 + texture
                    bytes[offset + 2] = 32 + texture
                } else {
                    bytes[offset] = 28 + texture
                    bytes[offset + 1] = 36 + texture
                    bytes[offset + 2] = 230 + texture
                }
                bytes[offset + 3] = 255
            }
        }
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
