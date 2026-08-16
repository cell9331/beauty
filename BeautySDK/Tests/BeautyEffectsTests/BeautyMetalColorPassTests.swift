import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import Metal
import XCTest
import BeautyCore
import BeautyDetection
import BeautyRender
@testable import BeautyEffects

final class BeautyMetalColorPassTests: XCTestCase {
    func testGeneratedGlobalRowsFollowCPUDirectionAndStayBounded() throws {
        guard let runtime = makeRuntime() else { return }
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 16, height: 12)
        let rows: [(String, BeautyParameters)] = [
            ("skinSmoothing", BeautyParameters(skinSmoothing: 0.8)),
            ("skinWhitening", BeautyParameters(skinWhitening: 0.8)),
            ("skinRosy", BeautyParameters(skinRosy: 0.8)),
            ("skinSharpen", BeautyParameters(skinSharpen: 0.8)),
            ("brightness", BeautyParameters(brightness: 0.8)),
            ("contrast", BeautyParameters(contrast: 0.8)),
            ("saturation", BeautyParameters(saturation: 0.8)),
            ("temperature", BeautyParameters(temperature: 0.8)),
            ("tint", BeautyParameters(tint: 0.8)),
            ("exposure", BeautyParameters(exposure: 0.8)),
            ("highlight", BeautyParameters(highlight: 0.8)),
            ("shadow", BeautyParameters(shadow: 0.8)),
            ("filter.warm_light", BeautyParameters(filterId: "warm_light", filterIntensity: 0.8)),
            ("filter.soft_clean", BeautyParameters(filterId: "soft_clean", filterIntensity: 0.8)),
        ]

        for (name, parameters) in rows {
            let plan = BeautyEffectResolver.resolve(parameters: parameters)
            let metalBytes = try renderMetal(
                fixture: fixture,
                plan: plan,
                runtime: runtime
            )
            let cpuBytes = try renderCPU(fixture: fixture, plan: plan)
            XCTAssertEqual(metalBytes.count, fixture.rgba8.count, name)
            XCTAssertEqual(alphaValues(metalBytes), fixture.alphaValues, name)
            XCTAssertTrue(metalBytes.allSatisfy { $0 <= 255 }, name)
            XCTAssertLessThan(meanRGBDelta(metalBytes, cpuBytes), 5.0, name)
            XCTAssertTrue(direction(name: name, before: summary(fixture.rgba8), after: summary(metalBytes)), name)
        }
    }

    func testNeutralAndUnsupportedLocalPlansAreByteIdentical() throws {
        guard let runtime = makeRuntime() else { return }
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp()
        let neutral = BeautyEffectResolver.resolve(parameters: BeautyParameters())
        XCTAssertEqual(
            try renderMetal(fixture: fixture, plan: neutral, runtime: runtime),
            fixture.rgba8
        )

        let noFacePlan = BeautyEffectResolver.resolve(parameters: BeautyParameters(lipColor: 0.8))
        XCTAssertTrue(noFacePlan.skippedDomains.contains(.lipColor))
        XCTAssertEqual(
            try renderMetal(fixture: fixture, plan: noFacePlan, runtime: runtime),
            fixture.rgba8
        )
    }

    func testFaceLocalLipColorStaysInsideEnvelopeAndPreservesAlpha() throws {
        guard let runtime = makeRuntime() else { return }
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 32, height: 24)
        let faceGeometry = FaceGeometry.fixture
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(lipColor: 0.8),
            faceGeometry: faceGeometry
        )
        let observation = BeautyFaceObservation()
        let input = try makePixelBuffer(width: fixture.width, height: fixture.height, bytes: bgra(fixture.rgba8))
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .pixelBuffer(input),
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            plan: plan,
            selectedFaceSupport: observation
        )
        let result = try BeautyMetalBackend(runtime: runtime).execute(request)
        guard case .pixelBuffer(let output) = result.output else {
            return XCTFail("Metal changed the output kind")
        }
        let outputRGBA = rgba(try bytes(from: output))
        let changed = Set(0..<(fixture.rgba8.count / 4)).filter { index in
            let offset = index * 4
            return outputRGBA[offset..<offset + 3] != fixture.rgba8[offset..<offset + 3]
        }
        XCTAssertFalse(changed.isEmpty)
        XCTAssertTrue(changed.allSatisfy { lipEnvelopeContains(pixel: $0, width: fixture.width, height: fixture.height, face: BeautyFaceGeometryAdapter.makeGeometry(from: observation)) })
        XCTAssertEqual(alphaValues(outputRGBA), fixture.alphaValues)
    }

    func testStillImageUsesNamedSRGBExtentAndRepeatedRequestsAreStable() throws {
        guard let runtime = makeRuntime() else { return }
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 8, height: 6)
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let image = CIImage(
            bitmapData: Data(fixture.rgba8),
            bytesPerRow: fixture.rowBytes,
            size: CGSize(width: fixture.width, height: fixture.height),
            format: .RGBA8,
            colorSpace: colorSpace
        ).transformed(by: CGAffineTransform(translationX: 3, y: -2))
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(brightness: 0.4))
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .stillImage(image),
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            plan: plan
        )
        let backend = BeautyMetalBackend(runtime: runtime)
        let first = try backend.execute(request)
        let second = try backend.execute(request)
        guard case .stillImage(let firstImage) = first.output,
              case .stillImage(let secondImage) = second.output
        else { return XCTFail("Metal changed the output kind") }
        XCTAssertEqual(firstImage.extent, image.extent)
        XCTAssertEqual(secondImage.extent, image.extent)
        XCTAssertEqual(firstImage.colorSpace?.name, colorSpace.name)
        XCTAssertEqual(secondImage.colorSpace?.name, colorSpace.name)
        XCTAssertEqual(renderedBytes(firstImage, width: fixture.width, height: fixture.height), renderedBytes(secondImage, width: fixture.width, height: fixture.height))
    }

    private func makeRuntime() -> BeautyMetalRuntime? {
        do { return try BeautyMetalRuntime() }
        catch BeautyError.metalUnavailable { XCTAssertTrue(true, "metalUnavailable"); return nil }
        catch { XCTFail("unexpected runtime setup failure: \(error)"); return nil }
    }

    private func renderMetal(fixture: CPUReferenceRGBA8Fixture, plan: BeautyEffectPlan, runtime: BeautyMetalRuntime) throws -> [UInt8] {
        let input = try makePixelBuffer(width: fixture.width, height: fixture.height, bytes: bgra(fixture.rgba8))
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .pixelBuffer(input),
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            plan: plan
        )
        let result = try BeautyMetalBackend(runtime: runtime).execute(request)
        guard case .pixelBuffer(let output) = result.output else { throw BeautyError.invalidInput }
        return rgba(try bytes(from: output))
    }

    private func renderCPU(fixture: CPUReferenceRGBA8Fixture, plan: BeautyEffectPlan) throws -> [UInt8] {
        let input = try makePixelBuffer(width: fixture.width, height: fixture.height, bytes: bgra(fixture.rgba8))
        let request = try BeautyBackendRequest(
            policy: .cpu,
            input: .pixelBuffer(input),
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            plan: plan
        )
        let result = try BeautyCPUBackend().execute(request)
        guard case .pixelBuffer(let output) = result.output else { throw BeautyError.invalidInput }
        return rgba(try bytes(from: output))
    }

    private struct ColorSummary {
        let luminance: Double
        let chroma: Double
        let redBlue: Double
        let greenRed: Double
        let spread: Double
    }

    private func summary(_ bytes: [UInt8]) -> ColorSummary {
        let values = stride(from: 0, to: bytes.count, by: 4).map { offset in
            (Double(bytes[offset]), Double(bytes[offset + 1]), Double(bytes[offset + 2]))
        }
        let count = Double(max(1, values.count))
        return ColorSummary(
            luminance: values.map { 0.2126 * $0.0 + 0.7152 * $0.1 + 0.0722 * $0.2 }.reduce(0, +) / count,
            chroma: values.map { max($0.0, max($0.1, $0.2)) - min($0.0, min($0.1, $0.2)) }.reduce(0, +) / count,
            redBlue: values.map { $0.0 - $0.2 }.reduce(0, +) / count,
            greenRed: values.map { $0.1 - $0.0 }.reduce(0, +) / count,
            spread: values.map { abs($0.0 - $0.1) + abs($0.1 - $0.2) }.reduce(0, +) / count
        )
    }

    private func direction(name: String, before: ColorSummary, after: ColorSummary) -> Bool {
        switch name {
        case "skinSmoothing": return after.chroma < before.chroma
        case "skinWhitening", "brightness", "exposure", "highlight", "shadow": return after.luminance > before.luminance
        case "skinRosy", "temperature", "filter.warm_light", "filter.soft_clean": return after.redBlue > before.redBlue
        case "skinSharpen", "contrast": return after.spread > before.spread
        case "saturation": return after.chroma > before.chroma
        case "tint": return after.greenRed > before.greenRed
        default: return false
        }
    }

    private func meanRGBDelta(_ lhs: [UInt8], _ rhs: [UInt8]) -> Double {
        let values = stride(from: 0, to: min(lhs.count, rhs.count), by: 4).flatMap { offset in
            (0..<3).map { abs(Int(lhs[offset + $0]) - Int(rhs[offset + $0])) }
        }
        return Double(values.reduce(0, +)) / Double(max(1, values.count))
    }

    private func alphaValues(_ bytes: [UInt8]) -> [UInt8] {
        stride(from: 3, to: bytes.count, by: 4).map { bytes[$0] }
    }

    private func bgra(_ bytes: [UInt8]) -> [UInt8] {
        var output = bytes
        for offset in stride(from: 0, to: output.count, by: 4) { output.swapAt(offset, offset + 2) }
        return output
    }

    private func rgba(_ bytes: [UInt8]) -> [UInt8] { bgra(bytes) }

    private func lipEnvelopeContains(pixel: Int, width: Int, height: Int, face: FaceGeometry) -> Bool {
        guard let center = LandmarkGeometryHelper.center(of: face.outerLips) else { return false }
        let radiusX = max(face.outerLips.map { abs($0.x - center.x) }.max() ?? 0, 0.03)
        let radiusY = max(face.outerLips.map { abs($0.y - center.y) }.max() ?? 0, 0.02)
        let point = SIMD2<Float>((Float(pixel % width) + 0.5) / Float(width), (Float(pixel / width) + 0.5) / Float(height))
        let dx = (point.x - center.x) / radiusX
        let dy = (point.y - center.y) / radiusY
        return dx * dx + dy * dy <= 1
    }

    private func makePixelBuffer(width: Int, height: Int, bytes: [UInt8]) throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:],
        ]
        guard CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &pixelBuffer) == kCVReturnSuccess,
              let pixelBuffer,
              CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess
        else { throw BeautyError.pixelBufferCreationFailed }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { throw BeautyError.invalidInput }
        let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        bytes.withUnsafeBytes { source in
            for row in 0..<height {
                memcpy(baseAddress.advanced(by: row * rowBytes), source.baseAddress!.advanced(by: row * width * 4), width * 4)
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
        var output = [UInt8](repeating: 0, count: width * height * 4)
        output.withUnsafeMutableBytes { destination in
            for row in 0..<height {
                memcpy(destination.baseAddress!.advanced(by: row * width * 4), baseAddress.advanced(by: row * rowBytes), width * 4)
            }
        }
        return output
    }

    private func renderedBytes(_ image: CIImage, width: Int, height: Int) -> [UInt8] {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        var output = [UInt8](repeating: 0, count: width * height * 4)
        CIContext(options: [.useSoftwareRenderer: true]).render(
            image,
            toBitmap: &output,
            rowBytes: width * 4,
            bounds: CGRect(x: 0, y: 0, width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
        return output
    }
}
