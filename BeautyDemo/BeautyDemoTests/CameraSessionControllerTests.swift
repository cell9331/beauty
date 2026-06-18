import AVFoundation
import CoreVideo
import XCTest
@testable import BeautyDemo

@MainActor
final class CameraSessionControllerTests: XCTestCase {
    func testPIPE01CameraOutputRequestsBGRAAndDiscardsLateFrames() {
        let output = CameraSessionController.makeVideoOutput(delegate: nil, queue: nil)

        XCTAssertEqual(CameraSessionController.requestedPixelFormat, kCVPixelFormatType_32BGRA)
        XCTAssertEqual(
            output.videoSettings[kCVPixelBufferPixelFormatTypeKey as String] as? OSType,
            kCVPixelFormatType_32BGRA
        )
        XCTAssertTrue(output.alwaysDiscardsLateVideoFrames)
    }

    func testPIPE01CameraPreviewFrameCarriesPixelBufferMetadata() throws {
        let pixelBuffer = try makePixelBuffer(width: 32, height: 24)
        let frame = CameraSessionController.makeFrame(
            pixelBuffer: pixelBuffer,
            orientation: .right,
            timestamp: 42,
            source: .testFixture
        )

        XCTAssertTrue(frame.pixelBuffer === pixelBuffer)
        XCTAssertEqual(frame.pixelFormat, kCVPixelFormatType_32BGRA)
        XCTAssertEqual(frame.extent.width, 32)
        XCTAssertEqual(frame.extent.height, 24)
        XCTAssertEqual(frame.orientation, .right)
        XCTAssertEqual(frame.timestamp, 42)
        XCTAssertEqual(frame.source, .testFixture)
        XCTAssertEqual(frame.metadata.orientation, .right)
        XCTAssertEqual(frame.metadata.source, .testFixture)
        XCTAssertEqual(frame.metadata.timestamp, 42)
        XCTAssertFalse(frame.metadata.isInputMirrored)
        XCTAssertFalse(frame.metadata.isPreviewMirrored)
    }

    func testPIPE05DefaultCameraFrameCarriesMirroringMetadata() throws {
        let pixelBuffer = try makePixelBuffer(width: 32, height: 24)
        let frame = CameraSessionController.makeFrame(
            pixelBuffer: pixelBuffer,
            timestamp: 43
        )

        XCTAssertEqual(frame.metadata.orientation, .right)
        XCTAssertEqual(frame.metadata.source, .camera)
        XCTAssertEqual(frame.metadata.timestamp, 43)
        XCTAssertFalse(frame.metadata.isInputMirrored)
        XCTAssertTrue(frame.metadata.isPreviewMirrored)
    }

    func testD07SetupFailureMapsToUnavailablePreviewState() {
        XCTAssertTrue(CameraSessionState.unavailable.isUnavailableForPreview)
        XCTAssertTrue(CameraSessionState.failedSetup(.cannotAddOutput).isUnavailableForPreview)
        XCTAssertFalse(CameraSessionState.running.isUnavailableForPreview)
    }

    private func makePixelBuffer(width: Int, height: Int) throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw NSError(domain: "CameraSessionControllerTests", code: Int(status))
        }

        return pixelBuffer
    }
}
