import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class RepairedControlSafetyTests: XCTestCase {
    private typealias F = RepairedControlSafetyFixture
    private let directions: [(String, BeautyParameters)] = [
        ("chinTaper", .init(chinTaper: 0.20)), ("gazeCorrection", .init(gazeCorrection: 0.20)),
        ("eyebrowHeadSpacingPositive", .init(eyebrowHeadSpacing: 0.20)),
        ("eyebrowHeadSpacingNegative", .init(eyebrowHeadSpacing: -0.20)),
        ("noseBridge", .init(noseBridge: 0.30)), ("noseRootNarrowing", .init(noseRootNarrowing: 0.30)),
        ("mouthWidthNegative", .init(mouthWidth: -0.35))]

    func testCrossControlSafetyAllDirections() throws {
        let image = try F.image()
        for (name, active) in directions {
            let neutral = try render(image, fixture: .usableFace, parameters: .init())
            let first = try render(image, fixture: validCarrier(name), parameters: active)
            let second = try render(image, fixture: validCarrier(name), parameters: active)
            XCTAssertTrue(neutral.bytes == F.source(), "P95S_NEUTRAL \(name)")
            XCTAssertTrue(first.bytes == second.bytes, "P95S_DETERMINISM \(name)")
            XCTAssertEqual(first.extent, image.extent, "P95S_EXTENT \(name)")
            XCTAssertTrue(first.alphaOpaque, "P95S_ALPHA \(name)")
            XCTAssertTrue(first.redacted, "P95S_PRIVACY \(name)")
            for carrier in [SDKTestingFaceDetectionFixture.noFace, .missingLandmarks, .detectionTimedOut, invalidCarrier(name)] {
                let invalid = try render(image, fixture: carrier, parameters: active)
                XCTAssertTrue(invalid.bytes == neutral.bytes, "P95S_REJECTED_SOURCE_EXACT \(name)")
                XCTAssertEqual(invalid.extent, image.extent, "P95S_REJECTED_EXTENT \(name)")
                XCTAssertTrue(invalid.alphaOpaque && invalid.redacted, "P95S_REJECTED_METADATA \(name)")
            }
            let provider = SDKTestingFaceDetectionProvider([validCarrier(name), .noFace, validCarrier(name)])
            let engine = try BeautyEngine(configuration: BeautyConfiguration(renderBackend: .cpu), faceDetectionProvider: provider)
            let before = try render(image, fixture: validCarrier(name), parameters: active, engine: engine)
            engine.reset()
            let rejected = try render(image, fixture: .noFace, parameters: active, engine: engine)
            engine.reset()
            let recovered = try render(image, fixture: validCarrier(name), parameters: active, engine: engine)
            XCTAssertEqual(provider.invocationCount, 3, "P95S_RECOVERY_EXECUTED \(name)")
            XCTAssertTrue(rejected.bytes == F.source(), "P95S_RECOVERY_REJECTION \(name)")
            XCTAssertTrue(before.bytes != F.source(), "P95S_RECOVERY_ACTIVE \(name)")
            XCTAssertTrue(recovered.bytes != F.source(), "P95S_RECOVERY_RESUMED_ACTIVE \(name)")
            XCTAssertTrue(before.bytes == recovered.bytes, "P95S_RECOVERY \(name)")
            XCTAssertTrue(before.redacted && rejected.redacted && recovered.redacted, "P95S_RECOVERY_PRIVACY \(name)")
        }
    }

    private func validCarrier(_ name: String) -> SDKTestingFaceDetectionFixture {
        switch name {
        case "gazeCorrection": return .gazeBilateralOffCenter
        case "eyebrowHeadSpacingPositive", "eyebrowHeadSpacingNegative": return .phase92PairedObservedEyebrows
        case "noseBridge", "noseRootNarrowing": return .phase93RegisteredNose
        case "mouthWidthNegative": return .phase94MouthPortrait
        default: return .usableFace
        }
    }

    private func invalidCarrier(_ name: String) -> SDKTestingFaceDetectionFixture {
        switch name {
        case "gazeCorrection": return .gazeInvalidPupil
        case "eyebrowHeadSpacingPositive", "eyebrowHeadSpacingNegative": return .malformedObservedEyebrows
        case "noseBridge", "noseRootNarrowing": return .phase93MissingNose
        case "mouthWidthNegative": return .phase94MouthPortraitMissingOuterLips
        default: return .malformedObservedFaceContour
        }
    }

    private struct Output { let bytes: [UInt8]; let extent: CGRect; let alphaOpaque: Bool; let redacted: Bool }
    private func render(_ image: CIImage, fixture: SDKTestingFaceDetectionFixture,
                        parameters: BeautyParameters, engine suppliedEngine: BeautyEngine? = nil) throws -> Output {
        let provider = SDKTestingFaceDetectionProvider([fixture])
        let engine = try suppliedEngine ?? BeautyEngine(configuration: BeautyConfiguration(renderBackend: .cpu), faceDetectionProvider: provider)
        let result = try engine.processResult(image: image, metadata: F.metadata(), parameters: parameters)
        var bytes = [UInt8](repeating: 0, count: F.width * F.height * 4)
        let color = CGColorSpace(name: CGColorSpace.sRGB)!
        CIContext(options: [.workingColorSpace: color, .outputColorSpace: color]).render(result.output,
            toBitmap: &bytes, rowBytes: F.width * 4, bounds: image.extent, format: .RGBA8, colorSpace: color)
        let text = (result.warnings.map { $0.code + " " + $0.message } + Array(result.metrics.keys)).joined().lowercased()
        let forbidden = ["pixel", "landmark", "coordinate", "mask", "path", "transcript"]
        return Output(bytes: bytes, extent: result.output.extent,
                      alphaOpaque: stride(from: 3, to: bytes.count, by: 4).allSatisfy { bytes[$0] == 255 },
                      redacted: forbidden.allSatisfy { !text.contains($0) })
    }
}
