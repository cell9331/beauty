import Foundation

nonisolated struct PreviewDebugOverlayState: Equatable, Sendable {
    static let allowedRowLabels: Set<String> = [
        "Frame",
        "Detection",
        "Reasons",
        "Faces",
        "Timing",
        "Warnings",
        "Last Error",
        "Status"
    ]

    let frameStatus: FrameStatus
    let detection: DetectionDebugSummary?
    let warningCount: Int
    let lastErrorCode: String?
    let statusText: String?

    var rows: [Row] {
        var rows = [
            Row(label: "Frame", value: frameStatus.rawValue)
        ]

        if let detection {
            rows.append(Row(label: "Detection", value: detection.availability))
            rows.append(Row(label: "Reasons", value: Self.reasonText(detection.reasonCodes)))
            rows.append(Row(label: "Faces", value: "\(detection.usedFaceCount)/\(detection.faceCount) used"))
            rows.append(Row(label: "Timing", value: Self.timingText(detection)))
        }

        rows.append(Row(label: "Warnings", value: "\(max(0, warningCount))"))

        if let lastErrorCode, !lastErrorCode.isEmpty {
            rows.append(Row(label: "Last Error", value: lastErrorCode))
        }

        if let statusText, !statusText.isEmpty {
            rows.append(Row(label: "Status", value: statusText))
        }

        return rows
    }

    var renderedDebugDescription: String {
        rows.map { "\($0.label): \($0.value)" }.joined(separator: "\n")
    }

    init(
        frameStatus: FrameStatus,
        detection: DetectionDebugSummary?,
        warningCount: Int,
        lastErrorCode: String?,
        statusText: String?
    ) {
        self.frameStatus = frameStatus
        self.detection = detection
        self.warningCount = max(0, warningCount)
        self.lastErrorCode = lastErrorCode
        self.statusText = statusText
    }

    static func camera(_ state: CameraProcessingState) -> PreviewDebugOverlayState? {
        switch state {
        case .idle:
            nil
        case .processing(let snapshot, _, let warning):
            PreviewDebugOverlayState(
                frameStatus: .cameraRunning,
                detection: snapshot?.detectionDebugSummary,
                warningCount: snapshot?.warningCount ?? 0,
                lastErrorCode: nil,
                statusText: warning
            )
        case .displaying(let snapshot, _, let warning):
            PreviewDebugOverlayState(
                frameStatus: .cameraRunning,
                detection: snapshot.detectionDebugSummary,
                warningCount: snapshot.warningCount,
                lastErrorCode: nil,
                statusText: warning
            )
        case .paused(let snapshot, _, let warning):
            PreviewDebugOverlayState(
                frameStatus: .processingPaused,
                detection: snapshot?.detectionDebugSummary,
                warningCount: snapshot?.warningCount ?? 0,
                lastErrorCode: "processing_paused",
                statusText: warning
            )
        }
    }

    static func photo(_ state: PhotoProcessingState) -> PreviewDebugOverlayState? {
        switch state {
        case .empty:
            PreviewDebugOverlayState(
                frameStatus: .photoEmpty,
                detection: nil,
                warningCount: 0,
                lastErrorCode: nil,
                statusText: nil
            )
        case .loading(let snapshot):
            PreviewDebugOverlayState(
                frameStatus: .photoLoading,
                detection: snapshot?.detectionDebugSummary,
                warningCount: snapshot?.warningCount ?? 0,
                lastErrorCode: nil,
                statusText: PhotoProcessingState.loadingText
            )
        case .loaded(let snapshot):
            PreviewDebugOverlayState(
                frameStatus: .photoLoaded,
                detection: snapshot.detectionDebugSummary,
                warningCount: snapshot.warningCount,
                lastErrorCode: nil,
                statusText: DetectionStatusPresentation(summary: snapshot.detectionSummary).statusText
            )
        case .failed(let snapshot, let message):
            PreviewDebugOverlayState(
                frameStatus: .photoFailed,
                detection: snapshot?.detectionDebugSummary,
                warningCount: snapshot?.warningCount ?? 0,
                lastErrorCode: "photo_decode_failed",
                statusText: message
            )
        }
    }

    private static func reasonText(_ reasonCodes: [String]) -> String {
        guard !reasonCodes.isEmpty else {
            return "none"
        }
        return reasonCodes.joined(separator: ", ")
    }

    private static func timingText(_ detection: DetectionDebugSummary) -> String {
        let detectionText = detection.detectionDurationMs.map { "detection \(formatMs($0))" } ?? "detection n/a"
        let mappingText = detection.mappingDurationMs.map { "mapping \(formatMs($0))" } ?? "mapping n/a"
        return "\(detectionText), \(mappingText)"
    }

    private static func formatMs(_ value: Double) -> String {
        String(format: "%.2f ms", value)
    }
}

extension PreviewDebugOverlayState {
    nonisolated enum FrameStatus: String, Equatable, Sendable {
        case cameraRunning = "camera running"
        case processingPaused = "processing paused"
        case photoEmpty = "photo empty"
        case photoLoading = "photo loading"
        case photoLoaded = "photo loaded"
        case photoFailed = "photo failed"
    }

    nonisolated struct Row: Equatable, Sendable {
        let label: String
        let value: String
    }
}
