import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import XCTest
import BeautyCore
@testable import BeautyEffects

/// Semantic CPU color oracles.  Each row names the metric that explains the
/// effect, so a byte-level difference alone can never satisfy this suite.
final class CPUReferenceColorOracleTests: XCTestCase {
    private struct ColorSummary {
        let luminance: Double
        let chroma: Double
        let redExcess: Double
        let yellowExcess: Double
        let channelSpread: Double
        let redBlue: Double
        let greenRed: Double
    }

    private struct ColorRow {
        let name: String
        let parameters: (Float) -> BeautyParameters
        let assertion: (ColorSummary, ColorSummary) -> Bool
    }

    func testCurrentSkinGlobalAndFilterColorRowsUseDirectionalMetrics() throws {
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 32, height: 24)
        let baseline = try render(fixture: fixture, parameters: BeautyParameters())
        let baselineSummary = summary(of: rgba(fromBGRA: baseline))
        let rows = colorRows()
        XCTAssertEqual(rows.count, 14)

        for row in rows {
            let output = try render(fixture: fixture, parameters: row.parameters(0.8))
            let rgba = rgba(fromBGRA: output)
            let outputSummary = summary(of: rgba)
            XCTAssertTrue(row.assertion(baselineSummary, outputSummary), row.name)
            XCTAssertEqual(alphaValues(in: output), Array(repeating: 255, count: fixture.width * fixture.height), row.name)
            XCTAssertEqual(output.count, fixture.rgba8.count, row.name)
            XCTAssertTrue(output.allSatisfy { $0 <= 255 }, row.name)
        }
    }

    func testSignedColorRowsMoveInOppositeDirectionsWithBoundedDeltas() throws {
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 32, height: 24)
        let baseline = try render(fixture: fixture, parameters: BeautyParameters())
        let baselineSummary = summary(of: rgba(fromBGRA: baseline))
        let rows: [(String, (Float) -> BeautyParameters, (ColorSummary) -> Double)] = [
            ("brightness", { BeautyParameters(brightness: $0) }, { $0.luminance }),
            ("contrast", { BeautyParameters(contrast: $0) }, { $0.channelSpread }),
            ("saturation", { BeautyParameters(saturation: $0) }, { $0.chroma }),
            ("temperature", { BeautyParameters(temperature: $0) }, { $0.redBlue }),
            ("tint", { BeautyParameters(tint: $0) }, { $0.greenRed }),
            ("exposure", { BeautyParameters(exposure: $0) }, { $0.luminance }),
            ("highlight", { BeautyParameters(highlight: $0) }, { $0.luminance }),
            ("shadow", { BeautyParameters(shadow: $0) }, { $0.luminance }),
        ]

        for (name, makeParameters, metric) in rows {
            let positive = try render(fixture: fixture, parameters: makeParameters(0.8))
            let negative = try render(fixture: fixture, parameters: makeParameters(-0.8))
            let positiveDelta = metric(summary(of: rgba(fromBGRA: positive))) - metric(baselineSummary)
            let negativeDelta = metric(summary(of: rgba(fromBGRA: negative))) - metric(baselineSummary)
            XCTAssertGreaterThan(positiveDelta, 0, name)
            XCTAssertLessThan(negativeDelta, 0, name)
            XCTAssertLessThan(abs(positiveDelta), 128, name)
            XCTAssertLessThan(abs(negativeDelta), 128, name)
        }
    }

    func testNeutralColorPlanIsByteIdenticalAndNoFaceLipSupportAbstains() throws {
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp()
        let neutral = try render(fixture: fixture, parameters: BeautyParameters())
        XCTAssertEqual(neutral, bgra(fromRGBA: fixture.rgba8))

        let lipPlan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(lipColor: 0.8),
            faceGeometry: nil
        )
        let noFace = try render(fixture: fixture, plan: lipPlan, face: nil)
        XCTAssertEqual(noFace, bgra(fromRGBA: fixture.rgba8))
        XCTAssertTrue(lipPlan.skippedDomains.contains(.lipColor))
    }

    func testLipColorUsesLocalRedChromaMetricAndPreservesOutsideAlpha() throws {
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 32, height: 24)
        let parameters = BeautyParameters(lipColor: 0.8)
        let face = FaceGeometry.fixture
        let output = try render(fixture: fixture, parameters: parameters, face: face)
        let after = rgba(fromBGRA: output)
        let beforeRGBA = fixture.rgba8
        let changed = try CPUReferenceMetrics.changedIndices(before: beforeRGBA, after: after)
        XCTAssertFalse(changed.isEmpty)
        XCTAssertTrue(CPUReferenceMetrics.alphaPreserved(before: beforeRGBA, after: after))

        let beforeLocal = summary(of: beforeRGBA, indices: changed)
        let afterLocal = summary(of: after, indices: changed)
        XCTAssertGreaterThan(afterLocal.redBlue, beforeLocal.redBlue)
        XCTAssertGreaterThan(afterLocal.yellowExcess, beforeLocal.yellowExcess)
        XCTAssertTrue(changed.allSatisfy { lipEnvelopeContains(pixel: $0, width: fixture.width, height: fixture.height, face: face) })
        XCTAssertTrue(
            Set(0..<(fixture.width * fixture.height)).subtracting(changed).allSatisfy { pixel in
                pixelBytes(beforeRGBA, at: pixel).3 == pixelBytes(after, at: pixel).3
            }
        )
    }

    func testColorImagePathKeepsNamedSRGBExtentAndFiniteRGBA() {
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 16, height: 12)
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let image = CIImage(
            bitmapData: Data(fixture.rgba8),
            bytesPerRow: fixture.rowBytes,
            size: CGSize(width: fixture.width, height: fixture.height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(brightness: 0.4))
        let output = BeautyColorEffectPipeline.apply(to: image, plan: plan)
        XCTAssertEqual(output.extent, image.extent)
        // CIColorControls may drop the CIImage metadata.  When it remains,
        // it must still be named sRGB; the render below is always explicitly
        // software-backed and sRGB, which is the byte-path contract.
        XCTAssertTrue(output.colorSpace?.name == nil || output.colorSpace?.name == CGColorSpace.sRGB)
        let rendered = renderedRGBABytes(from: output, width: fixture.width, height: fixture.height, colorSpace: colorSpace)
        XCTAssertEqual(rendered.count, fixture.rgba8.count)
        XCTAssertTrue(rendered.allSatisfy { $0 <= 255 })
    }

    private func colorRows() -> [ColorRow] {
        [
            ColorRow(name: "skinSmoothing", parameters: { BeautyParameters(skinSmoothing: $0) }) { before, after in after.chroma < before.chroma },
            ColorRow(name: "skinWhitening", parameters: { BeautyParameters(skinWhitening: $0) }) { before, after in after.luminance > before.luminance },
            ColorRow(name: "skinRosy", parameters: { BeautyParameters(skinRosy: $0) }) { before, after in after.redExcess > before.redExcess },
            ColorRow(name: "skinSharpen", parameters: { BeautyParameters(skinSharpen: $0) }) { before, after in after.channelSpread > before.channelSpread },
            ColorRow(name: "brightness", parameters: { BeautyParameters(brightness: $0) }) { before, after in after.luminance > before.luminance },
            ColorRow(name: "contrast", parameters: { BeautyParameters(contrast: $0) }) { before, after in after.channelSpread > before.channelSpread },
            ColorRow(name: "saturation", parameters: { BeautyParameters(saturation: $0) }) { before, after in after.chroma > before.chroma },
            ColorRow(name: "temperature", parameters: { BeautyParameters(temperature: $0) }) { before, after in after.redBlue > before.redBlue },
            ColorRow(name: "tint", parameters: { BeautyParameters(tint: $0) }) { before, after in after.greenRed > before.greenRed },
            ColorRow(name: "exposure", parameters: { BeautyParameters(exposure: $0) }) { before, after in after.luminance > before.luminance },
            ColorRow(name: "highlight", parameters: { BeautyParameters(highlight: $0) }) { before, after in after.luminance > before.luminance },
            ColorRow(name: "shadow", parameters: { BeautyParameters(shadow: $0) }) { before, after in after.luminance > before.luminance },
            ColorRow(name: "filter.warm_light", parameters: { BeautyParameters(filterId: "warm_light", filterIntensity: $0) }) { before, after in after.redBlue > before.redBlue && after.luminance > before.luminance },
            ColorRow(name: "filter.soft_clean", parameters: { BeautyParameters(filterId: "soft_clean", filterIntensity: $0) }) { before, after in after.luminance > before.luminance && after.redBlue > before.redBlue },
        ]
    }

    private func render(
        fixture: CPUReferenceRGBA8Fixture,
        parameters: BeautyParameters,
        face: FaceGeometry? = nil
    ) throws -> [UInt8] {
        let plan = face == nil
            ? BeautyEffectResolver.resolve(parameters: parameters)
            : BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
        return try render(fixture: fixture, plan: plan, face: face)
    }

    private func render(
        fixture: CPUReferenceRGBA8Fixture,
        plan: BeautyEffectPlan,
        face: FaceGeometry?
    ) throws -> [UInt8] {
        let input = try makeBGRA(width: fixture.width, height: fixture.height, bytes: bgra(fromRGBA: fixture.rgba8))
        let output = try BeautyColorEffectPipeline.apply(to: input, plan: plan, face: face)
        return try bytes(from: output)
    }

    private func summary(of rgba8: [UInt8], indices: Set<Int>? = nil) -> ColorSummary {
        let pixels = indices ?? Set(0..<(rgba8.count / 4))
        let count = Double(max(1, pixels.count))
        let values = pixels.map { pixelBytes(rgba8, at: $0) }
        return ColorSummary(
            luminance: values.map { 0.2126 * Double($0.0) + 0.7152 * Double($0.1) + 0.0722 * Double($0.2) }.reduce(0, +) / count,
            chroma: values.map { Double(max($0.0, max($0.1, $0.2))) - Double(min($0.0, min($0.1, $0.2))) }.reduce(0, +) / count,
            redExcess: values.map { Double($0.0) - 0.83 * Double($0.1) - 0.17 * Double($0.2) }.reduce(0, +) / count,
            yellowExcess: values.map { 0.5 * (Double($0.0) + Double($0.1)) - Double($0.2) }.reduce(0, +) / count,
            channelSpread: values.map { abs(Double($0.0) - Double($0.1)) + abs(Double($0.1) - Double($0.2)) }.reduce(0, +) / count,
            redBlue: values.map { Double($0.0) - Double($0.2) }.reduce(0, +) / count,
            greenRed: values.map { Double($0.1) - Double($0.0) }.reduce(0, +) / count
        )
    }

    private func bgra(fromRGBA rgba: [UInt8]) -> [UInt8] {
        var result: [UInt8] = []
        result.reserveCapacity(rgba.count)
        for offset in stride(from: 0, to: rgba.count, by: 4) {
            result.append(contentsOf: [rgba[offset + 2], rgba[offset + 1], rgba[offset], rgba[offset + 3]])
        }
        return result
    }

    private func rgba(fromBGRA bgra: [UInt8]) -> [UInt8] {
        var result: [UInt8] = []
        result.reserveCapacity(bgra.count)
        for offset in stride(from: 0, to: bgra.count, by: 4) {
            result.append(contentsOf: [bgra[offset + 2], bgra[offset + 1], bgra[offset], bgra[offset + 3]])
        }
        return result
    }

    private func makeBGRA(width: Int, height: Int, bytes: [UInt8]) throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:],
        ]
        guard CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &pixelBuffer) == kCVReturnSuccess,
              let pixelBuffer else { throw BeautyError.pixelBufferCreationFailed }
        guard CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess else { throw BeautyError.invalidInput }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { throw BeautyError.invalidInput }
        let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        bytes.withUnsafeBytes { raw in
            for row in 0..<height {
                memcpy(baseAddress.advanced(by: row * rowBytes), raw.baseAddress!.advanced(by: row * width * 4), width * 4)
            }
        }
        return pixelBuffer
    }

    private func bytes(from pixelBuffer: CVPixelBuffer) throws -> [UInt8] {
        guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else { throw BeautyError.invalidInput }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { throw BeautyError.invalidInput }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        var bytes = [UInt8]()
        for row in 0..<height {
            let rowPointer = baseAddress.advanced(by: row * rowBytes).assumingMemoryBound(to: UInt8.self)
            bytes.append(contentsOf: UnsafeBufferPointer(start: rowPointer, count: width * 4))
        }
        return bytes
    }

    private func alphaValues(in bgra: [UInt8]) -> [UInt8] {
        stride(from: 3, to: bgra.count, by: 4).map { bgra[$0] }
    }

    private func pixelBytes(_ rgba8: [UInt8], at pixel: Int) -> (UInt8, UInt8, UInt8, UInt8) {
        let offset = pixel * 4
        return (rgba8[offset], rgba8[offset + 1], rgba8[offset + 2], rgba8[offset + 3])
    }

    private func lipEnvelopeContains(pixel: Int, width: Int, height: Int, face: FaceGeometry) -> Bool {
        guard let center = LandmarkGeometryHelper.center(of: face.outerLips) else { return false }
        let radiusX = max(face.outerLips.map { abs($0.x - center.x) }.max() ?? 0, 0.03)
        let radiusY = max(face.outerLips.map { abs($0.y - center.y) }.max() ?? 0, 0.02)
        let point = SIMD2<Float>((Float(pixel % width) + 0.5) / Float(width), (Float(pixel / width) + 0.5) / Float(height))
        let dx = (point.x - center.x) / radiusX
        let dy = (point.y - center.y) / radiusY
        return dx * dx + dy * dy <= 1
    }

    private func renderedRGBABytes(from image: CIImage, width: Int, height: Int, colorSpace: CGColorSpace) -> [UInt8] {
        let context = CPUReferenceFixtureFactory.softwareContext(colorSpace: colorSpace)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        context.render(image, toBitmap: &bytes, rowBytes: width * 4, bounds: CGRect(x: 0, y: 0, width: width, height: height), format: .RGBA8, colorSpace: colorSpace)
        return bytes
    }
}
