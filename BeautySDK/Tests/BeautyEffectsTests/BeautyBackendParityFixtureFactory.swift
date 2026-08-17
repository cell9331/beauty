import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

/// Request-local generated observations used by the CPU/GPU parity suites.
///
/// The factory intentionally keeps raster bytes inside one test invocation. It
/// exposes only bounded aggregate values to assertions and never writes a
/// fixture, mask, landmark, or framework diagnostic to disk.
struct BeautyBackendParityObservation: Equatable {
    let kind: BeautyBackendInputKind
    let width: Int
    let height: Int
    let preservesAlpha: Bool
    let preservesExtent: Bool
    let namedSRGB: Bool
    let changedPixelCount: Int
    let maxChannelDelta: Int
    let meanRGBDelta: Double
}

enum BeautyBackendParityFixtureFactory {
    static let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
    static let activeMaxChannelDelta = 8
    static let activeMeanRGBDelta = 5.0

    static func fixtures() -> [CPUReferenceRGBA8Fixture] {
        [
            CPUReferenceFixtureFactory.opaqueColorRamp(),
            CPUReferenceFixtureFactory.checker(),
            CPUReferenceFixtureFactory.geometryPattern(),
            CPUReferenceFixtureFactory.protectedOutsidePattern(),
        ]
    }

    static func planMatrix() -> [(String, BeautyEffectPlan)] {
        [
            ("neutral", BeautyEffectResolver.resolve(parameters: BeautyParameters())),
            ("global-color", BeautyEffectResolver.resolve(
                parameters: BeautyParameters(
                    skinSmoothing: 0.6,
                    skinWhitening: 0.35,
                    brightness: 0.25,
                    saturation: 0.4
                )
            )),
            ("geometry", BeautyEffectResolver.resolve(
                parameters: BeautyParameters(faceSlim: 0.4, eyeSize: 0.3),
                faceGeometry: FaceGeometry.fixture
            )),
            ("composed-carrier", BeautyEffectResolver.resolve(
                parameters: BeautyParameters(brightness: 0.2, saturation: 0.25)
            )),
        ]
    }

    static func makePixelBuffer(_ fixture: CPUReferenceRGBA8Fixture) throws -> CVPixelBuffer {
        var buffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            fixture.width,
            fixture.height,
            kCVPixelFormatType_32BGRA,
            nil,
            &buffer
        )
        guard status == kCVReturnSuccess, let buffer else {
            throw BeautyError.pixelBufferCreationFailed
        }
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let base = CVPixelBufferGetBaseAddress(buffer) else {
            throw BeautyError.pixelBufferCreationFailed
        }
        let rowBytes = CVPixelBufferGetBytesPerRow(buffer)
        fixture.rgba8.withUnsafeBytes { source in
            for row in 0..<fixture.height {
                let destination = base.advanced(by: row * rowBytes).assumingMemoryBound(to: UInt8.self)
                let sourceRow = source.baseAddress!.advanced(by: row * fixture.rowBytes).assumingMemoryBound(to: UInt8.self)
                for pixel in 0..<fixture.width {
                    let offset = pixel * 4
                    destination[offset] = sourceRow[offset + 2]
                    destination[offset + 1] = sourceRow[offset + 1]
                    destination[offset + 2] = sourceRow[offset]
                    destination[offset + 3] = sourceRow[offset + 3]
                }
            }
        }
        return buffer
    }

    static func makeStillImage(_ fixture: CPUReferenceRGBA8Fixture, translated: Bool = false) -> CIImage {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let image = CIImage(
            bitmapData: Data(fixture.rgba8),
            bytesPerRow: fixture.rowBytes,
            size: CGSize(width: fixture.width, height: fixture.height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
        return translated
            ? image.transformed(by: CGAffineTransform(translationX: 3, y: -2))
            : image
    }

    static func makeRequest(
        policy: BeautyBackendExecutionPolicy,
        fixture: CPUReferenceRGBA8Fixture,
        plan: BeautyEffectPlan,
        stillImage: Bool = false,
        translated: Bool = false
    ) throws -> BeautyBackendRequest {
        let input: BeautyBackendInput = stillImage
            ? .stillImage(makeStillImage(fixture, translated: translated))
            : .pixelBuffer(try makePixelBuffer(fixture))
        return try BeautyBackendRequest(
            policy: policy,
            input: input,
            metadata: metadata,
            plan: plan,
            selectedFaceSupport: plan.activeDomains.intersection([.faceShape, .eyes, .eyebrows, .nose, .mouth]).isEmpty
                ? nil
                : BeautyFaceObservation()
        )
    }

    static func makeMetalBackend() -> BeautyMetalBackend? {
        do {
            return try BeautyMetalBackend()
        } catch BeautyError.metalUnavailable {
            return nil
        } catch {
            XCTFail("unexpected Metal construction error")
            return nil
        }
    }

    static func rgbaBytes(from output: BeautyBackendOutput) throws -> [UInt8] {
        switch output {
        case .pixelBuffer(let buffer):
            CVPixelBufferLockBaseAddress(buffer, .readOnly)
            defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
            guard let base = CVPixelBufferGetBaseAddress(buffer) else {
                throw BeautyError.renderFailed("readback")
            }
            let width = CVPixelBufferGetWidth(buffer)
            let height = CVPixelBufferGetHeight(buffer)
            let rowBytes = CVPixelBufferGetBytesPerRow(buffer)
            var rgba = [UInt8](repeating: 0, count: width * height * 4)
            for row in 0..<height {
                let source = base.advanced(by: row * rowBytes).assumingMemoryBound(to: UInt8.self)
                for pixel in 0..<width {
                    let offset = pixel * 4
                    rgba[offset] = source[offset + 2]
                    rgba[offset + 1] = source[offset + 1]
                    rgba[offset + 2] = source[offset]
                    rgba[offset + 3] = source[offset + 3]
                }
            }
            return rgba
        case .stillImage(let image):
            let extent = image.extent
            guard let dimensions = BeautyBackendRequest.checkedDimensions(for: extent) else {
                throw BeautyError.invalidInput
            }
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
            let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
            guard let cgImage = context.createCGImage(image, from: extent, format: .RGBA8, colorSpace: colorSpace),
                  let data = cgImage.dataProvider?.data,
                  let bytes = CFDataGetBytePtr(data)
            else { throw BeautyError.renderFailed("readback") }
            let rowBytes = dimensions.width * 4
            var rgba = [UInt8](repeating: 0, count: rowBytes * dimensions.height)
            for row in 0..<dimensions.height {
                memcpy(&rgba[row * rowBytes], bytes.advanced(by: row * cgImage.bytesPerRow), rowBytes)
            }
            return rgba
        }
    }

    static func observation(
        inputKind: BeautyBackendInputKind,
        fixture: CPUReferenceRGBA8Fixture,
        before: [UInt8],
        after: [UInt8],
        diagnostics: BeautyBackendDiagnostics,
        extentPreserved: Bool = true
    ) throws -> BeautyBackendParityObservation {
        guard before.count == after.count, before.count.isMultiple(of: 4) else {
            throw BeautyError.invalidInput
        }
        var changed = 0
        var maxDelta = 0
        var totalDelta = 0
        var components = 0
        for offset in stride(from: 0, to: before.count, by: 4) {
            var pixelChanged = false
            for channel in 0..<3 {
                let delta = abs(Int(before[offset + channel]) - Int(after[offset + channel]))
                maxDelta = max(maxDelta, delta)
                totalDelta += delta
                components += 1
                pixelChanged = pixelChanged || delta != 0
            }
            if pixelChanged { changed += 1 }
            guard after[offset + 3] == before[offset + 3] else {
                throw BeautyError.invalidInput
            }
        }
        return BeautyBackendParityObservation(
            kind: inputKind,
            width: diagnostics.width,
            height: diagnostics.height,
            preservesAlpha: diagnostics.preservesAlpha,
            preservesExtent: diagnostics.preservesExtent && extentPreserved,
            namedSRGB: true,
            changedPixelCount: changed,
            maxChannelDelta: maxDelta,
            meanRGBDelta: Double(totalDelta) / Double(max(1, components))
        )
    }
}
