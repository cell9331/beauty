import CoreVideo
import XCTest
@_spi(Testing) import BeautySDK

// Requirement evidence: SDK-04, SDK-06, SDK-07.
final class CopyRenderPassTests: XCTestCase {
    func testCopyRenderPassPreservesBGRABytesInNewOutput() throws {
        let input = try PixelBufferFixtures.makeBGRA(width: 2, height: 1, bytes: [
            1, 2, 3, 255,
            4, 5, 6, 255
        ])

        let output = try SDKTestingCopyRenderPass().apply(to: input, parameters: .init())

        XCTAssertFalse(input === output)
        XCTAssertEqual(try PixelBufferFixtures.bytes(from: output), try PixelBufferFixtures.bytes(from: input))
    }

    func testRenderGraphInvokesPassesInOrder() throws {
        let input = try PixelBufferFixtures.makeBGRA(width: 1, height: 1, bytes: [1, 2, 3, 255])
        let recorder = PassRecorder()
        let graph = SDKTestingRenderGraph(passes: [
            RecordingPass(id: "first", recorder: recorder),
            RecordingPass(id: "second", recorder: recorder)
        ])

        _ = try graph.render(pixelBuffer: input, parameters: .init())

        XCTAssertEqual(recorder.ids, ["first", "second"])
    }

    func testUnsupportedCopyInputMapsToBeautyError() throws {
        let input = try PixelBufferFixtures.makePixelBuffer(width: 1, height: 1, pixelFormat: kCVPixelFormatType_OneComponent8)

        XCTAssertThrowsError(try SDKTestingCopyRenderPass().apply(to: input, parameters: .init())) { error in
            XCTAssertEqual(error as? BeautyError, .unsupportedPixelFormat)
        }
    }
}

final class PassRecorder {
    var ids: [String] = []
}

struct RecordingPass: SDKTestingRenderPass {
    let id: String
    let recorder: PassRecorder

    func apply(to pixelBuffer: CVPixelBuffer, parameters: BeautyParameters) throws -> CVPixelBuffer {
        _ = parameters
        recorder.ids.append(id)
        return pixelBuffer
    }
}

enum PixelBufferFixtures {
    static func makePixelBuffer(width: Int, height: Int, pixelFormat: OSType) throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormat, attributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }
        return pixelBuffer
    }

    static func makeBGRA(width: Int, height: Int, bytes: [UInt8]) throws -> CVPixelBuffer {
        let pixelBuffer = try makePixelBuffer(width: width, height: height, pixelFormat: kCVPixelFormatType_32BGRA)
        guard CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess else {
            throw BeautyError.invalidInput
        }
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let expectedRowBytes = width * 4
        try bytes.withUnsafeBytes { rawBytes in
            guard let sourceBase = rawBytes.baseAddress else {
                throw BeautyError.invalidInput
            }
            for row in 0..<height {
                memcpy(
                    baseAddress.advanced(by: row * bytesPerRow),
                    sourceBase.advanced(by: row * expectedRowBytes),
                    expectedRowBytes
                )
            }
        }
        return pixelBuffer
    }

    static func bytes(from pixelBuffer: CVPixelBuffer) throws -> [UInt8] {
        guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
            throw BeautyError.invalidInput
        }
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let expectedRowBytes = width * 4
        var output: [UInt8] = []
        for row in 0..<height {
            let rowPointer = baseAddress.advanced(by: row * bytesPerRow).assumingMemoryBound(to: UInt8.self)
            output.append(contentsOf: UnsafeBufferPointer(start: rowPointer, count: expectedRowBytes))
        }
        return output
    }
}
