import BeautySDK
import Foundation

nonisolated struct DetectionStatusPresentation: Equatable, Sendable {
    let statusText: String?
    let debugSummary: DetectionDebugSummary?

    init(summary: BeautyDetectionSummary?) {
        guard let summary else {
            self.statusText = nil
            self.debugSummary = nil
            return
        }

        self.statusText = Self.statusText(for: summary)
        self.debugSummary = DetectionDebugSummary(summary: summary)
    }

    private static func statusText(for summary: BeautyDetectionSummary) -> String? {
        switch summary.availability {
        case .noFace:
            "No face detected. Face adjustments are paused."
        case .partial:
            "Face partly visible. Some face adjustments are softened."
        case .lowConfidence:
            "Face detection is uncertain. Face adjustments are softened."
        case .stale:
            "Waiting for a fresh face reading. Showing the last usable preview."
        case .notRun, .disabled, .usable, .skipped, .reused:
            nil
        }
    }
}

nonisolated struct DetectionDebugSummary: Equatable, Sendable {
    let availability: String
    let reasonCodes: [String]
    let faceCount: Int
    let usedFaceCount: Int
    let detectionDurationMs: Double?
    let mappingDurationMs: Double?

    init(summary: BeautyDetectionSummary) {
        self.availability = summary.availability.rawValue
        self.reasonCodes = summary.reasons.map(\.rawValue)
        self.faceCount = summary.faceCount
        self.usedFaceCount = summary.usedFaceCount
        self.detectionDurationMs = summary.detectionDurationMs
        self.mappingDurationMs = summary.mappingDurationMs
    }
}

nonisolated struct DetectionStatusDebouncer: Equatable, Sendable {
    private let holdFrameCount: Int
    private var currentPresentation: DetectionStatusPresentation?
    private var remainingHoldFrames: Int

    init(holdFrameCount: Int = 3) {
        self.holdFrameCount = max(1, holdFrameCount)
        self.currentPresentation = nil
        self.remainingHoldFrames = 0
    }

    mutating func update(with summary: BeautyDetectionSummary?) -> DetectionStatusPresentation? {
        let nextPresentation = DetectionStatusPresentation(summary: summary)

        guard currentPresentation?.statusText != nil else {
            return replace(with: nextPresentation)
        }

        if currentPresentation?.statusText == nextPresentation.statusText {
            remainingHoldFrames = holdFrameCount
            return currentPresentation
        }

        guard remainingHoldFrames > 1 else {
            return replace(with: nextPresentation)
        }

        remainingHoldFrames -= 1
        return currentPresentation
    }

    mutating func reset() {
        currentPresentation = nil
        remainingHoldFrames = 0
    }

    private mutating func replace(
        with presentation: DetectionStatusPresentation
    ) -> DetectionStatusPresentation? {
        guard presentation.statusText != nil else {
            currentPresentation = nil
            remainingHoldFrames = 0
            return nil
        }

        currentPresentation = presentation
        remainingHoldFrames = holdFrameCount
        return presentation
    }
}
