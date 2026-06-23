import BeautySDK
import Combine
import CoreVideo
import Foundation
import ImageIO

nonisolated struct CameraProcessingSnapshot: @unchecked Sendable, Equatable {
    let inputPixelBuffer: CVPixelBuffer
    let outputPixelBuffer: CVPixelBuffer
    let metadata: BeautyInputMetadata
    let parameters: BeautyParameters
    let extent: CGSize
    let detectionSummary: BeautyDetectionSummary?
    let warningCount: Int

    var orientation: CGImagePropertyOrientation {
        metadata.orientation
    }

    var timestamp: TimeInterval {
        metadata.timestamp ?? 0
    }

    init(
        inputPixelBuffer: CVPixelBuffer,
        outputPixelBuffer: CVPixelBuffer,
        metadata: BeautyInputMetadata,
        parameters: BeautyParameters,
        extent: CGSize,
        detectionSummary: BeautyDetectionSummary? = nil,
        warningCount: Int = 0
    ) {
        self.inputPixelBuffer = inputPixelBuffer
        self.outputPixelBuffer = outputPixelBuffer
        self.metadata = metadata
        self.parameters = parameters
        self.extent = extent
        self.detectionSummary = detectionSummary
        self.warningCount = max(0, warningCount)
    }

    init(
        inputPixelBuffer: CVPixelBuffer,
        outputPixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        timestamp: TimeInterval,
        parameters: BeautyParameters,
        extent: CGSize,
        detectionSummary: BeautyDetectionSummary? = nil,
        warningCount: Int = 0
    ) {
        self.init(
            inputPixelBuffer: inputPixelBuffer,
            outputPixelBuffer: outputPixelBuffer,
            metadata: BeautyInputMetadata(
                orientation: orientation,
                source: .camera,
                timestamp: timestamp
            ),
            parameters: parameters,
            extent: extent,
            detectionSummary: detectionSummary,
            warningCount: warningCount
        )
    }

    static func == (lhs: CameraProcessingSnapshot, rhs: CameraProcessingSnapshot) -> Bool {
        lhs.inputPixelBuffer === rhs.inputPixelBuffer &&
            lhs.outputPixelBuffer === rhs.outputPixelBuffer &&
            lhs.metadata == rhs.metadata &&
            lhs.parameters == rhs.parameters &&
            lhs.extent == rhs.extent &&
            lhs.detectionSummary == rhs.detectionSummary &&
            lhs.warningCount == rhs.warningCount
    }

    var detectionDebugSummary: DetectionDebugSummary? {
        detectionSummary.map { DetectionDebugSummary(summary: $0) }
    }
}

nonisolated enum CameraFrameDropReason: Equatable, Sendable {
    case backpressure
}

nonisolated enum CameraProcessingState: Equatable, Sendable {
    static let processingPausedMessage = "Processing paused. Showing the last usable preview."

    case idle
    case processing(lastSnapshot: CameraProcessingSnapshot?, droppedFrameCount: Int, warning: String?)
    case displaying(CameraProcessingSnapshot, droppedFrameCount: Int, warning: String?)
    case paused(lastSnapshot: CameraProcessingSnapshot?, droppedFrameCount: Int, warning: String)

    var latestSnapshot: CameraProcessingSnapshot? {
        switch self {
        case .idle:
            nil
        case .processing(let snapshot, _, _),
             .paused(let snapshot, _, _):
            snapshot
        case .displaying(let snapshot, _, _):
            snapshot
        }
    }

    var droppedFrameCount: Int {
        switch self {
        case .idle:
            0
        case .processing(_, let count, _),
             .displaying(_, let count, _),
             .paused(_, let count, _):
            count
        }
    }

    var statusText: String? {
        switch self {
        case .idle:
            nil
        case .processing(_, _, let warning),
             .displaying(_, _, let warning):
            warning
        case .paused(_, _, let warning):
            warning
        }
    }
}

nonisolated struct CameraFrameProcessor: Sendable {
    let process: @Sendable (CameraPreviewFrame, BeautyParameters) throws -> BeautyResult<CVPixelBuffer>

    nonisolated init(
        process: @escaping @Sendable (CameraPreviewFrame, BeautyParameters) throws -> BeautyResult<CVPixelBuffer>
    ) {
        self.process = process
    }

    nonisolated static func beautyEngine() -> CameraFrameProcessor {
        do {
            let processor = try BeautyEnginePixelBufferProcessor()
            return CameraFrameProcessor { frame, parameters in
                try processor.process(frame: frame, parameters: parameters)
            }
        } catch {
            return CameraFrameProcessor { _, _ in
                throw BeautyError.metalUnavailable
            }
        }
    }
}

@MainActor
final class CameraBeautyPipeline: ObservableObject {
    @Published private(set) var state: CameraProcessingState = .idle

    private(set) var inFlightCount = 0
    private(set) var droppedFrameCount = 0
    private(set) var lastDropReason: CameraFrameDropReason?

    private let maxInFlight: Int
    private let processor: CameraFrameProcessor
    private let processingQueue: DispatchQueue
    private var pendingWork: CameraProcessingWork?
    private var latestSnapshot: CameraProcessingSnapshot?
    private var currentWarning: String?
    private var detectionStatusDebouncer = DetectionStatusDebouncer()
    private var idleContinuations: [CheckedContinuation<Void, Never>] = []
    private var generation: UInt64 = 0

    init(
        maxInFlight: Int = 1,
        processor: CameraFrameProcessor = .beautyEngine(),
        processingQueue: DispatchQueue = DispatchQueue(label: "beauty.demo.camera.pipeline", qos: .userInitiated)
    ) {
        self.maxInFlight = max(1, maxInFlight)
        self.processor = processor
        self.processingQueue = processingQueue
    }

    func enqueue(frame: CameraPreviewFrame, parameters: BeautyParameters) {
        let work = CameraProcessingWork(frame: frame, parameters: parameters, generation: generation)

        if inFlightCount < maxInFlight {
            start(work)
            return
        }

        if pendingWork != nil {
            droppedFrameCount += 1
            lastDropReason = .backpressure
        }
        pendingWork = work
        publishProcessingState()
    }

    func reset() {
        generation &+= 1
        pendingWork = nil
        latestSnapshot = nil
        currentWarning = nil
        detectionStatusDebouncer.reset()
        inFlightCount = 0
        droppedFrameCount = 0
        lastDropReason = nil
        state = .idle
        resumeIdleContinuationsIfNeeded()
    }

    func waitUntilIdle() async {
        if inFlightCount == 0, pendingWork == nil {
            return
        }

        await withCheckedContinuation { continuation in
            idleContinuations.append(continuation)
        }
    }

    private func start(_ work: CameraProcessingWork) {
        inFlightCount += 1
        publishProcessingState()

        let processor = processor
        processingQueue.async {
            let result: CameraProcessingResult
            do {
                result = .success(try processor.process(work.frame, work.parameters))
            } catch {
                result = .failure
            }

            Task { @MainActor in
                self.finish(work, result: result)
            }
        }
    }

    private func finish(_ work: CameraProcessingWork, result: CameraProcessingResult) {
        guard work.generation == generation else {
            return
        }

        inFlightCount = max(0, inFlightCount - 1)

        switch result {
        case .success(let result):
            let snapshot = CameraProcessingSnapshot(
                inputPixelBuffer: work.frame.pixelBuffer,
                outputPixelBuffer: result.output,
                metadata: work.frame.metadata,
                parameters: work.parameters,
                extent: work.frame.extent,
                detectionSummary: result.detectionSummary,
                warningCount: result.warnings.count
            )
            latestSnapshot = snapshot
            let presentation = detectionStatusDebouncer.update(with: result.detectionSummary)
            currentWarning = presentation?.statusText
            state = .displaying(snapshot, droppedFrameCount: droppedFrameCount, warning: currentWarning)
        case .failure:
            currentWarning = CameraProcessingState.processingPausedMessage
            state = .paused(
                lastSnapshot: latestSnapshot,
                droppedFrameCount: droppedFrameCount,
                warning: CameraProcessingState.processingPausedMessage
            )
        }

        if let pendingWork {
            self.pendingWork = nil
            start(pendingWork)
        } else if inFlightCount > 0 {
            publishProcessingState()
        } else {
            resumeIdleContinuationsIfNeeded()
        }
    }

    private func publishProcessingState() {
        state = .processing(
            lastSnapshot: latestSnapshot,
            droppedFrameCount: droppedFrameCount,
            warning: currentWarning
        )
    }

    private func resumeIdleContinuationsIfNeeded() {
        guard inFlightCount == 0, pendingWork == nil else {
            return
        }

        let continuations = idleContinuations
        idleContinuations.removeAll()
        continuations.forEach { $0.resume() }
    }

}

nonisolated private struct CameraProcessingWork: @unchecked Sendable {
    let frame: CameraPreviewFrame
    let parameters: BeautyParameters
    let generation: UInt64
}

nonisolated private enum CameraProcessingResult: @unchecked Sendable {
    case success(BeautyResult<CVPixelBuffer>)
    case failure
}

nonisolated private final class BeautyEnginePixelBufferProcessor: @unchecked Sendable {
    private let engine: BeautyEngine

    nonisolated init() throws {
        self.engine = try BeautyEngine(configuration: .default)
    }

    func process(frame: CameraPreviewFrame, parameters: BeautyParameters) throws -> BeautyResult<CVPixelBuffer> {
        try engine.processResult(
            pixelBuffer: frame.pixelBuffer,
            metadata: frame.metadata,
            parameters: parameters
        )
    }
}
