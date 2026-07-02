import BeautySDK
import CoreVideo
import ImageIO
import XCTest
@testable import BeautyDemo

@MainActor
final class CameraBeautyPipelineTests: XCTestCase {
    func testPIPE02PipelineProcessesCVPixelBufferThroughInjectedProcessor() async throws {
        let input = try PixelBufferTestFixtures.makePixelBuffer(width: 4, height: 4, pixelFormat: kCVPixelFormatType_32BGRA)
        let frame = CameraSessionController.makeFrame(
            pixelBuffer: input,
            orientation: .right,
            timestamp: 1
        )
        let parameters = BeautyParameters(skinSmoothing: 0.42)
        let records = LockedValues<ProcessorRecord>()
        let processor = CameraFrameProcessor { frame, parameters in
            records.append(ProcessorRecord(
                pixelBuffer: frame.pixelBuffer,
                metadata: frame.metadata,
                parameters: parameters
            ))
            return BeautyResult(output: frame.pixelBuffer, detectionSummary: .notRun)
        }
        let pipeline = CameraBeautyPipeline(processor: processor)

        pipeline.enqueue(frame: frame, parameters: parameters)
        await pipeline.waitUntilIdle()

        let record = try XCTUnwrap(records.values.first)
        XCTAssertTrue(record.pixelBuffer === input)
        XCTAssertEqual(record.metadata.orientation, .right)
        XCTAssertEqual(record.metadata.source, .camera)
        XCTAssertFalse(record.metadata.isInputMirrored)
        XCTAssertTrue(record.metadata.isPreviewMirrored)
        XCTAssertEqual(record.metadata.timestamp, 1)
        XCTAssertEqual(record.parameters, parameters)
        XCTAssertEqual(pipeline.state.latestSnapshot?.parameters, parameters)
        XCTAssertEqual(pipeline.state.latestSnapshot?.metadata, record.metadata)
        XCTAssertEqual(pipeline.state.latestSnapshot?.detectionSummary, .notRun)
        XCTAssertTrue(pipeline.state.latestSnapshot?.inputPixelBuffer === input)
        XCTAssertTrue(pipeline.state.latestSnapshot?.outputPixelBuffer === input)
    }

    func testPIPE03InFlightWorkIsBoundedAndStalePendingFramesAreDropped() async throws {
        let firstStarted = expectation(description: "first frame started")
        let releaseFirst = DispatchSemaphore(value: 0)
        let processedTimestamps = LockedValues<TimeInterval>()
        let processor = CameraFrameProcessor { frame, _ in
            processedTimestamps.append(frame.timestamp)
            if frame.timestamp == 1 {
                firstStarted.fulfill()
                _ = releaseFirst.wait(timeout: .now() + 2)
            }
            return BeautyResult(output: frame.pixelBuffer)
        }
        let pipeline = CameraBeautyPipeline(maxInFlight: 1, processor: processor)

        pipeline.enqueue(frame: try makeFrame(timestamp: 1), parameters: .init(skinSmoothing: 0.1))
        await fulfillment(of: [firstStarted], timeout: 2)

        pipeline.enqueue(frame: try makeFrame(timestamp: 2), parameters: .init(skinSmoothing: 0.2))
        pipeline.enqueue(frame: try makeFrame(timestamp: 3), parameters: .init(skinSmoothing: 0.3))

        // PIPE-03: one active frame, one latest pending frame, and one stale frame dropped for backpressure.
        XCTAssertEqual(pipeline.inFlightCount, 1)
        XCTAssertEqual(pipeline.droppedFrameCount, 1)
        XCTAssertEqual(pipeline.lastDropReason, .backpressure)

        releaseFirst.signal()
        await pipeline.waitUntilIdle()

        XCTAssertEqual(processedTimestamps.values, [1, 3])
        XCTAssertEqual(pipeline.state.droppedFrameCount, 1)
    }

    func testPERF02BackpressureStressKeepsLatestFrameWinsAndCountsDroppedFrames() async throws {
        let firstStarted = expectation(description: "first frame started")
        let releaseFirst = DispatchSemaphore(value: 0)
        let processedTimestamps = LockedValues<TimeInterval>()
        let processedParameters = LockedValues<BeautyParameters>()
        let processor = CameraFrameProcessor { frame, parameters in
            processedTimestamps.append(frame.timestamp)
            processedParameters.append(parameters)
            if frame.timestamp == 1 {
                firstStarted.fulfill()
                _ = releaseFirst.wait(timeout: .now() + 2)
            }
            return BeautyResult(output: frame.pixelBuffer)
        }
        let pipeline = CameraBeautyPipeline(maxInFlight: 1, processor: processor)

        pipeline.enqueue(frame: try makeFrame(timestamp: 1), parameters: .init(skinSmoothing: 0.1))
        await fulfillment(of: [firstStarted], timeout: 2)

        pipeline.enqueue(frame: try makeFrame(timestamp: 2), parameters: .init(skinSmoothing: 0.2))
        pipeline.enqueue(frame: try makeFrame(timestamp: 3), parameters: .init(skinSmoothing: 0.3))
        pipeline.enqueue(frame: try makeFrame(timestamp: 4), parameters: .init(skinSmoothing: 0.4))
        pipeline.enqueue(frame: try makeFrame(timestamp: 5), parameters: .init(skinSmoothing: 0.5))

        XCTAssertEqual(pipeline.inFlightCount, 1)
        XCTAssertEqual(pipeline.droppedFrameCount, 3)
        XCTAssertEqual(pipeline.lastDropReason, .backpressure)
        XCTAssertEqual(pipeline.state.droppedFrameCount, 3)

        releaseFirst.signal()
        await pipeline.waitUntilIdle()

        XCTAssertEqual(processedTimestamps.values, [1, 5])
        XCTAssertEqual(processedParameters.values.map(\.skinSmoothing), [0.1, 0.5])
        XCTAssertEqual(pipeline.state.latestSnapshot?.parameters.skinSmoothing, 0.5)
        XCTAssertEqual(pipeline.state.droppedFrameCount, 3)
        XCTAssertEqual(pipeline.droppedFrameCount, 3)
    }

    func testD14LatestParameterSnapshotIsUsedForFrameThatProcesses() async throws {
        let firstStarted = expectation(description: "first frame started")
        let releaseFirst = DispatchSemaphore(value: 0)
        let processedParameters = LockedValues<BeautyParameters>()
        let processor = CameraFrameProcessor { frame, parameters in
            processedParameters.append(parameters)
            if frame.timestamp == 1 {
                firstStarted.fulfill()
                _ = releaseFirst.wait(timeout: .now() + 2)
            }
            return BeautyResult(output: frame.pixelBuffer)
        }
        let pipeline = CameraBeautyPipeline(maxInFlight: 1, processor: processor)

        pipeline.enqueue(frame: try makeFrame(timestamp: 1), parameters: .init(skinSmoothing: 0.1))
        await fulfillment(of: [firstStarted], timeout: 2)
        pipeline.enqueue(frame: try makeFrame(timestamp: 2), parameters: .init(skinSmoothing: 0.2))
        pipeline.enqueue(frame: try makeFrame(timestamp: 3), parameters: .init(skinSmoothing: 0.9))

        releaseFirst.signal()
        await pipeline.waitUntilIdle()

        XCTAssertEqual(processedParameters.values.map(\.skinSmoothing), [0.1, 0.9])
        XCTAssertEqual(pipeline.state.latestSnapshot?.parameters.skinSmoothing, 0.9)
    }

    func testD12D13UnsupportedPixelFormatMapsToFriendlyStatusAndPreservesLastUsablePreview() async throws {
        let processor = CameraFrameProcessor { frame, _ in
            guard frame.pixelFormat == kCVPixelFormatType_32BGRA else {
                throw BeautyError.unsupportedPixelFormat
            }
            return BeautyResult(output: frame.pixelBuffer)
        }
        let pipeline = CameraBeautyPipeline(processor: processor)

        pipeline.enqueue(frame: try makeFrame(timestamp: 1, pixelFormat: kCVPixelFormatType_32BGRA), parameters: .init())
        await pipeline.waitUntilIdle()
        let lastUsableSnapshot = try XCTUnwrap(pipeline.state.latestSnapshot)

        pipeline.enqueue(frame: try makeFrame(timestamp: 2, pixelFormat: kCVPixelFormatType_OneComponent8), parameters: .init())
        await pipeline.waitUntilIdle()

        XCTAssertEqual(pipeline.state.statusText, CameraProcessingState.processingPausedMessage)
        XCTAssertEqual(pipeline.state.latestSnapshot, lastUsableSnapshot)
        XCTAssertFalse(pipeline.state.statusText?.contains("unsupported_pixel_format") == true)
        XCTAssertFalse(pipeline.state.statusText?.contains("unsupportedPixelFormat") == true)
        XCTAssertFalse(pipeline.state.statusText?.contains("NSError") == true)
        XCTAssertFalse(pipeline.state.statusText?.contains("/") == true)
    }

    func testPIPE07CameraDetectionStatusDebouncesNoFaceUsableAndStaleSummaries() async throws {
        let summaries = LockedQueue<BeautyDetectionSummary?>([
            .noFace,
            BeautyDetectionSummary(availability: .usable, faceCount: 1, usedFaceCount: 1),
            BeautyDetectionSummary(availability: .usable, faceCount: 1, usedFaceCount: 1),
            BeautyDetectionSummary(availability: .usable, faceCount: 1, usedFaceCount: 1),
            BeautyDetectionSummary(availability: .stale, reasons: [.staleDetection], faceCount: 1, usedFaceCount: 1)
        ])
        let processor = CameraFrameProcessor { frame, _ in
            BeautyResult(output: frame.pixelBuffer, detectionSummary: summaries.pop() ?? nil)
        }
        let pipeline = CameraBeautyPipeline(processor: processor)

        pipeline.enqueue(frame: try makeFrame(timestamp: 1), parameters: .init())
        await pipeline.waitUntilIdle()
        XCTAssertEqual(pipeline.state.statusText, "No face detected. Face adjustments are paused.")

        pipeline.enqueue(frame: try makeFrame(timestamp: 2), parameters: .init())
        await pipeline.waitUntilIdle()
        XCTAssertEqual(pipeline.state.statusText, "No face detected. Face adjustments are paused.")

        pipeline.enqueue(frame: try makeFrame(timestamp: 3), parameters: .init())
        await pipeline.waitUntilIdle()
        XCTAssertEqual(pipeline.state.statusText, "No face detected. Face adjustments are paused.")

        pipeline.enqueue(frame: try makeFrame(timestamp: 4), parameters: .init())
        await pipeline.waitUntilIdle()
        XCTAssertNil(pipeline.state.statusText)

        pipeline.enqueue(frame: try makeFrame(timestamp: 5), parameters: .init())
        await pipeline.waitUntilIdle()
        XCTAssertEqual(pipeline.state.statusText, "Waiting for a fresh face reading. Showing the last usable preview.")
    }

    func testPERF03ResetClearsPendingWorkDropCountersWarningsAndSnapshots() async throws {
        let blockedFrameStarted = expectation(description: "blocked frame started")
        let blockedFrameReleased = expectation(description: "blocked frame released")
        let releaseBlockedFrame = DispatchSemaphore(value: 0)
        let processedTimestamps = LockedValues<TimeInterval>()
        let processor = CameraFrameProcessor { frame, _ in
            processedTimestamps.append(frame.timestamp)
            if frame.timestamp == 2 {
                blockedFrameStarted.fulfill()
                _ = releaseBlockedFrame.wait(timeout: .now() + 2)
                blockedFrameReleased.fulfill()
            }
            let summary: BeautyDetectionSummary? = frame.timestamp == 1 ? .noFace : .notRun
            return BeautyResult(output: frame.pixelBuffer, detectionSummary: summary)
        }
        let pipeline = CameraBeautyPipeline(maxInFlight: 1, processor: processor)

        pipeline.enqueue(frame: try makeFrame(timestamp: 1), parameters: .init(skinSmoothing: 0.1))
        await pipeline.waitUntilIdle()
        let preResetSnapshot = try XCTUnwrap(pipeline.state.latestSnapshot)
        XCTAssertEqual(preResetSnapshot.timestamp, 1)
        XCTAssertEqual(pipeline.state.statusText, "No face detected. Face adjustments are paused.")

        pipeline.enqueue(frame: try makeFrame(timestamp: 2), parameters: .init(skinSmoothing: 0.2))
        await fulfillment(of: [blockedFrameStarted], timeout: 2)
        pipeline.enqueue(frame: try makeFrame(timestamp: 3), parameters: .init(skinSmoothing: 0.3))
        pipeline.enqueue(frame: try makeFrame(timestamp: 4), parameters: .init(skinSmoothing: 0.4))

        XCTAssertEqual(pipeline.inFlightCount, 1)
        XCTAssertEqual(pipeline.droppedFrameCount, 1)
        XCTAssertEqual(pipeline.lastDropReason, .backpressure)
        XCTAssertEqual(pipeline.state.latestSnapshot, preResetSnapshot)
        XCTAssertEqual(pipeline.state.statusText, "No face detected. Face adjustments are paused.")

        pipeline.reset()

        XCTAssertEqual(pipeline.inFlightCount, 0)
        XCTAssertEqual(pipeline.droppedFrameCount, 0)
        XCTAssertNil(pipeline.lastDropReason)
        XCTAssertEqual(pipeline.state, .idle)
        XCTAssertNil(pipeline.state.latestSnapshot)
        XCTAssertNil(pipeline.state.statusText)

        releaseBlockedFrame.signal()
        await fulfillment(of: [blockedFrameReleased], timeout: 2)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(pipeline.state, .idle)
        XCTAssertNil(pipeline.state.latestSnapshot)
        XCTAssertEqual(processedTimestamps.values, [1, 2])
    }

    private func makeFrame(timestamp: TimeInterval, pixelFormat: OSType = kCVPixelFormatType_32BGRA) throws -> CameraPreviewFrame {
        let pixelBuffer = try PixelBufferTestFixtures.makePixelBuffer(width: 4, height: 4, pixelFormat: pixelFormat)
        return CameraSessionController.makeFrame(
            pixelBuffer: pixelBuffer,
            orientation: .right,
            timestamp: timestamp,
            source: .testFixture
        )
    }
}

private struct ProcessorRecord {
    let pixelBuffer: CVPixelBuffer
    let metadata: BeautyInputMetadata
    let parameters: BeautyParameters
}

private enum PixelBufferTestFixtures {
    static func makePixelBuffer(width: Int, height: Int, pixelFormat: OSType) throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            pixelFormat,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }

        return pixelBuffer
    }
}

private final class LockedValues<Element>: @unchecked Sendable {
    private let queue = DispatchQueue(label: "beauty.demo.tests.locked-values")
    private var storage: [Element] = []

    var values: [Element] {
        queue.sync {
            storage
        }
    }

    func append(_ element: Element) {
        queue.sync {
            storage.append(element)
        }
    }
}

private final class LockedQueue<Element>: @unchecked Sendable {
    private let queue = DispatchQueue(label: "beauty.demo.tests.locked-queue")
    private var storage: [Element]

    init(_ storage: [Element]) {
        self.storage = storage
    }

    func pop() -> Element? {
        queue.sync {
            guard !storage.isEmpty else {
                return nil
            }
            return storage.removeFirst()
        }
    }
}
