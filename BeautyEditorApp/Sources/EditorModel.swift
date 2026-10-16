import BeautySDK
import CoreGraphics
import Foundation
import Observation

struct SharedPhoto: Identifiable {
    let id = UUID()
    let url: URL
}

/// Console-only allowlist: user controls and preview state, never image/support data.
struct SliderReleaseLog: Encodable {
    let timestamp: String
    let category: String
    let toolID: String
    let toolName: String
    let sdkField: String
    let startValue: Float
    let value: Float
    let minimumValue: Float
    let maximumValue: Float
    let sdkValue: Float
    let sdkCap: Float
    let revision: Int
    let previewRevision: Int
    let previewPending: Bool
    let backgroundProtection: Bool

    var consoleLine: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(self), let json = String(data: data, encoding: .utf8) else { return nil }
        return "[BeautyEditor][slider_release] " + json
    }
}

/// Preview completion metadata only. SDK warning codes and backend labels can
/// contain caller-provided strings, so only counts and known labels are emitted.
private struct PreviewRenderLog: Encodable {
    enum Outcome: String, Encodable { case accepted, cancelled, discarded, failed }
    let requestRevision: Int
    let currentRevision: Int
    let displayedRevision: Int
    let outcome: Outcome
    let activeControlCount: Int
    let elapsedMs: Double
    let backend: String
    let detectionAvailability: String
    let usedFaceCount: Int
    let matchesSource: Bool?
    let warningCount: Int
    let errorCode: String

    enum CodingKeys: String, CodingKey {
        case requestRevision, currentRevision, displayedRevision, outcome, activeControlCount, elapsedMs
        case backend, detectionAvailability, usedFaceCount, matchesSource, warningCount, errorCode
    }

    func encode(to encoder: any Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(requestRevision, forKey: .requestRevision)
        try values.encode(currentRevision, forKey: .currentRevision)
        try values.encode(displayedRevision, forKey: .displayedRevision)
        try values.encode(outcome, forKey: .outcome)
        try values.encode(activeControlCount, forKey: .activeControlCount)
        try values.encode(elapsedMs, forKey: .elapsedMs)
        try values.encode(backend, forKey: .backend)
        try values.encode(detectionAvailability, forKey: .detectionAvailability)
        try values.encode(usedFaceCount, forKey: .usedFaceCount)
        if let matchesSource { try values.encode(matchesSource, forKey: .matchesSource) }
        else { try values.encodeNil(forKey: .matchesSource) }
        try values.encode(warningCount, forKey: .warningCount)
        try values.encode(errorCode, forKey: .errorCode)
    }

    var consoleLine: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(self), let json = String(data: data, encoding: .utf8) else { return nil }
        return "[BeautyEditor][preview_render] " + json
    }
}

@MainActor @Observable
final class EditorModel {
    private(set) var photo: ImportedPhoto?
    private(set) var preview: CGImage?
    private(set) var snapshot = EditorSnapshot()
    private(set) var committed = EditorSnapshot()
    private(set) var history = EditHistory()
    private(set) var category: BeautyCategory = .face
    private(set) var selectedToolID = "face.width"
    private(set) var isEditing = true
    private(set) var isLoading = false
    private(set) var isRendering = false
    private(set) var isExporting = false
    private(set) var isProtecting = false
    private(set) var detectionMessage: String?
    private(set) var displayedRevision = 0
    private(set) var revision = 0
    private(set) var debugEnabled = false
    private(set) var sourceLandmarks: [DebugLandmarkGroup] = []
    private(set) var previewLandmarks: [DebugLandmarkGroup] = []
    private(set) var debugRevision = -1
    private(set) var isDebugAnalyzing = false
    private(set) var lastRender: RenderedPhoto?
    var comparing = false
    var errorMessage: String?
    var successMessage: String?
    var sharedPhoto: SharedPhoto?

    @ObservationIgnored private let renderer: any PhotoRendering
    @ObservationIgnored private let photoWriter: any PhotoLibrarySaving
    @ObservationIgnored private let adjustmentLog: (String) -> Void
    @ObservationIgnored private let previewLog: (String) -> Void
    @ObservationIgnored private var renderTask: Task<Void, Never>?
    @ObservationIgnored private var previewTimer: Task<Void, Never>?
    @ObservationIgnored private var lastPreviewStart: ContinuousClock.Instant?
    // Limit starts, not slider values. Slow renders naturally lower the rate.
    @ObservationIgnored private let previewInterval: Duration
    @ObservationIgnored private var pendingPreview: (photo: ImportedPhoto, snapshot: EditorSnapshot, revision: Int)?
    @ObservationIgnored private var renderWorker = 0
    @ObservationIgnored private var debugTask: Task<Void, Never>?
    @ObservationIgnored private var debugRequest = 0
    @ObservationIgnored private var sourceLandmarkPhotoID: UUID?
    @ObservationIgnored private var protectionTask: Task<Void, Never>?
    @ObservationIgnored private var importTask: Task<Void, Never>?
    @ObservationIgnored private var importRevision = 0
    @ObservationIgnored private var dragStart: EditorSnapshot?
    @ObservationIgnored private var selections: [BeautyCategory: String] = [:]
    @ObservationIgnored private var sharedURL: URL?

    init(renderer: any PhotoRendering = PhotoRenderer(),
         photoWriter: any PhotoLibrarySaving = PhotoLibraryWriter(),
         previewInterval: Duration = .milliseconds(16),
         adjustmentLog: @escaping (String) -> Void = { print($0) },
         previewLog: @escaping (String) -> Void = { print($0) }) {
        self.renderer = renderer
        self.photoWriter = photoWriter
        self.previewInterval = max(.zero, previewInterval)
        self.adjustmentLog = adjustmentLog
        self.previewLog = previewLog
    }

    var selectedTool: ToolDefinition { ToolCatalog.find(selectedToolID)! }
    var value: Float { selectedTool.value(in: snapshot.parameters) }
    var hasChanges: Bool { snapshot != committed }
    var controlsDisabled: Bool { isLoading || isExporting || isProtecting }
    var canUndo: Bool { !history.undoStack.isEmpty && !controlsDisabled }
    var canRedo: Bool { !history.redoStack.isEmpty && !controlsDisabled }
    var exportSize: String {
        guard let photo else { return "" }
        return "\(Int(photo.uprightSize.width)) × \(Int(photo.uprightSize.height))"
    }

    func importPhoto(_ data: Data) {
        guard !isExporting, !isProtecting else { return }
        importRevision += 1
        let request = importRevision
        importTask?.cancel()
        stopPreview()
        revision += 1
        isLoading = true
        isRendering = false
        errorMessage = nil
        successMessage = nil
        importTask = Task {
            do {
                let loaded = try await renderer.load(data)
                try Task.checkCancellation()
                guard request == importRevision else { return }
                photo = loaded
                preview = loaded.preview
                snapshot = EditorSnapshot()
                committed = snapshot
                history.clear()
                dragStart = nil
                category = .face
                selectedToolID = category.defaultTool
                selections.removeAll()
                isEditing = true
                comparing = false
                detectionMessage = nil

                lastRender = nil
                sourceLandmarks = []
                sourceLandmarkPhotoID = nil
                previewLandmarks = []
                displayedRevision = revision
                refreshDebugLandmarks()
            } catch is CancellationError {
                // A newer selection owns the loading state.
            } catch {
                guard request == importRevision else { return }
                errorMessage = message(for: error)
                // A failed replacement must finish the previous pending edit.
                schedulePreview(immediate: true)
            }
            if request == importRevision { isLoading = false }
        }
    }

    func selectCategory(_ next: BeautyCategory) {
        guard !controlsDisabled else { return }
        guard next.hasDesign else { return }
        endAdjustment()
        selections[category] = selectedToolID
        category = next
        selectedToolID = selections[next] ?? next.defaultTool

    }

    func selectTool(_ tool: ToolDefinition) {
        guard tool.category == category, !controlsDisabled else { return }
        guard tool.available else { return }
        endAdjustment()
        selectedToolID = tool.id

    }

    func beginAdjustment() {
        guard !controlsDisabled else { return }
        if dragStart == nil { dragStart = snapshot }
    }

    func updateValue(_ next: Float) {
        guard !controlsDisabled, selectedTool.available, photo != nil else { return }
        beginAdjustment()
        let old = snapshot
        // Keep each requested field independent. The SDK admits the final
        // displacement and gradient on the actual 478-point composition.
        selectedTool.setValue(next, in: &snapshot.parameters)
        guard old != snapshot else { return }
        schedulePreview()
    }

    func endAdjustment() {
        guard let previous = dragStart else { return }
        history.record(previous, replacing: snapshot)
        dragStart = nil
        flushPreview()
    }

    /// Only native touch-up calls this. Other transaction/lifecycle endings stay silent.
    func releaseSliderAdjustment(_ finalValue: Float) {
        guard let initial = dragStart, photo != nil, !controlsDisabled, selectedTool.available else { return }
        let tool = selectedTool
        updateValue(finalValue)
        endAdjustment()
        let event = SliderReleaseLog(
            timestamp: Date().ISO8601Format(), category: tool.category.rawValue,
            toolID: tool.id, toolName: tool.title, sdkField: tool.field!,
            startValue: tool.value(in: initial.parameters), value: tool.value(in: snapshot.parameters),
            minimumValue: tool.range.bounds.lowerBound, maximumValue: tool.range.bounds.upperBound,
            sdkValue: tool.sdkValue(in: snapshot.parameters), sdkCap: tool.maximumSDKStrength,
            revision: revision, previewRevision: displayedRevision,
            previewPending: isRendering || pendingPreview != nil || displayedRevision != revision,
            backgroundProtection: snapshot.protectBackground)
        if let line = event.consoleLine { adjustmentLog(line) }
    }

    func undo() {
        guard !controlsDisabled else { return }
        endAdjustment()
        guard let previous = history.undo(snapshot) else { return }
        snapshot = previous

        schedulePreview(immediate: true)
    }

    func redo() {
        guard !controlsDisabled else { return }
        endAdjustment()
        guard let next = history.redo(snapshot) else { return }
        snapshot = next

        schedulePreview(immediate: true)
    }

    func resetCurrentTool() {
        guard !controlsDisabled else { return }
        endAdjustment()
        let previous = snapshot

        selectedTool.setValue(0, in: &snapshot.parameters)
        history.record(previous, replacing: snapshot)
        schedulePreview(immediate: true)
    }

    func resetAll() {
        guard !controlsDisabled else { return }
        endAdjustment()
        let previous = snapshot
        snapshot = EditorSnapshot()

        history.record(previous, replacing: snapshot)
        schedulePreview(immediate: true)
    }

    func toggleBackgroundProtection() {
        guard let photo, !controlsDisabled else { return }
        endAdjustment()
        let previous = snapshot
        if previous.protectBackground {
            snapshot.protectBackground = false
            history.record(previous, replacing: snapshot)
            schedulePreview(immediate: true)
            return
        }
        var candidate = previous
        candidate.protectBackground = true
        stopPreview()
        revision += 1
        let request = revision
        isRendering = false
        isProtecting = true
        protectionTask = Task {
            do {
                let result = try await renderer.render(photo, snapshot: candidate, fullResolution: false)
                try Task.checkCancellation()
                guard request == revision else { return }
                snapshot = candidate
                history.record(previous, replacing: snapshot)
                accept(result, revision: request)
            } catch is CancellationError {
            } catch {
                if request == revision {
                    errorMessage = message(for: error)
                    isProtecting = false
                    schedulePreview(immediate: true)
                }
            }
            if request == revision { isProtecting = false }
        }
    }

    func confirmEditing() {
        guard !controlsDisabled else { return }
        endAdjustment()
        committed = snapshot
        isEditing = false
        comparing = false
    }

    func resumeEditing() { isEditing = true }

    func cancelEditing() {
        guard !controlsDisabled else { return }
        dragStart = nil
        snapshot = committed

        history.clear()
        isEditing = false
        comparing = false
        schedulePreview(immediate: true)
    }

    func saveToPhotos() { export(share: false) }
    func share() { export(share: true) }

    func removeSharedFile() {
        guard let sharedURL else { return }
        try? FileManager.default.removeItem(at: sharedURL)
        self.sharedURL = nil
        self.sharedPhoto = nil
    }

    private func export(share: Bool) {
        guard let photo, !controlsDisabled else { return }
        endAdjustment()
        comparing = false
        isExporting = true
        successMessage = nil
        let exportSnapshot = snapshot
        Task {
            defer { isExporting = false }
            do {
                let result = try await renderer.render(photo, snapshot: exportSnapshot, fullResolution: true)
                let data = try await renderer.encodePNG(result.image)
                if share {
                    removeSharedFile()
                    let folder = FileManager.default.temporaryDirectory.appendingPathComponent("BeautyEditorExports")
                    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                    let url = folder.appendingPathComponent("Beauty-\(UUID().uuidString).png")
                    try data.write(to: url, options: [.atomic, .completeFileProtection])
                    sharedURL = url
                    sharedPhoto = SharedPhoto(url: url)
                } else {
                    try await photoWriter.save(data)
                    successMessage = "已保存到相册 · \(exportSize)"
                }
            } catch { errorMessage = message(for: error) }
        }
    }

    private func stopPreview() {
        renderWorker += 1
        previewTimer?.cancel()
        previewTimer = nil
        lastPreviewStart = nil
        renderTask?.cancel()
        renderTask = nil
        pendingPreview = nil
        debugRequest += 1
        debugTask?.cancel()
        isDebugAnalyzing = false
        previewLandmarks = []
        debugRevision = -1
    }

    /// One running render plus one replaceable latest request. A separate
    /// timer throttles starts and can be flushed without canceling active work.
    private func schedulePreview(immediate: Bool = false) {
        guard let photo else { return }
        revision += 1
        pendingPreview = (photo, snapshot, revision)
        isRendering = true
        successMessage = nil
        suspendDebugAnalysis()
        if immediate { flushPreview() } else { armPreviewTimer() }
    }

    private func armPreviewTimer() {
        guard renderTask == nil, previewTimer == nil, pendingPreview != nil else { return }
        let now = ContinuousClock.now
        let delay = lastPreviewStart.map { max(.zero, now.duration(to: $0 + previewInterval)) } ?? .zero
        let worker = renderWorker
        previewTimer = Task {
            do { if delay > .zero { try await Task.sleep(for: delay) } }
            catch { return }
            guard !Task.isCancelled, worker == renderWorker else { return }
            previewTimer = nil
            startPreview()
        }
    }

    private func flushPreview() {
        previewTimer?.cancel()
        previewTimer = nil
        startPreview()
        if !isRendering { refreshDebugLandmarks() }
    }

    private func startPreview() {
        guard renderTask == nil, let request = pendingPreview else { return }
        pendingPreview = nil
        lastPreviewStart = .now
        let worker = renderWorker
        let neutral = BeautyParameters()
        let activeControlCount = ToolCatalog.canonicalTools.filter {
            $0.available && $0.sdkValue(in: request.snapshot.parameters) != $0.sdkValue(in: neutral)
        }.count
        let started = ContinuousClock.now
        renderTask = Task {
            var outcome = PreviewRenderLog.Outcome.discarded
            var completedResult: RenderedPhoto?
            var errorCode = "none"
            defer {
                logPreviewCompletion(requestRevision: request.revision, started: started,
                                     activeControlCount: activeControlCount,
                                     outcome: outcome, result: completedResult, errorCode: errorCode)
                if worker == renderWorker {
                    renderTask = nil
                    if pendingPreview != nil {
                        // Release bypasses throttling; latest pending work wins.
                        if dragStart == nil { startPreview() } else { armPreviewTimer() }
                    } else {
                        isRendering = false
                        refreshDebugLandmarks()
                    }
                }
            }
            do {
                let result = try await renderer.render(request.photo, snapshot: request.snapshot, fullResolution: false)
                completedResult = result
                try Task.checkCancellation()
                if worker == renderWorker, self.photo?.id == request.photo.id,
                   request.revision > displayedRevision {
                    accept(result, revision: request.revision)
                    outcome = .accepted
                }
            } catch is CancellationError {
                outcome = .cancelled
                errorCode = "cancelled"
                return
            } catch {
                outcome = .failed
                errorCode = previewErrorCode(error)
                if request.revision == revision { errorMessage = message(for: error) }
            }
        }
    }

    private func logPreviewCompletion(requestRevision: Int, started: ContinuousClock.Instant,
                                      activeControlCount: Int,
                                      outcome: PreviewRenderLog.Outcome, result: RenderedPhoto?, errorCode: String) {
        let elapsed = started.duration(to: .now).components
        let milliseconds = Double(elapsed.seconds) * 1_000 + Double(elapsed.attoseconds) / 1_000_000_000_000_000
        let knownBackends = ["CPU", "Metal", "CPU original iris preview", "CPU fallback", "CPU capacity fallback"]
        let backend = result.map { knownBackends.contains($0.backendName) ? $0.backendName : "other" } ?? "unavailable"
        let event = PreviewRenderLog(
            requestRevision: requestRevision, currentRevision: revision, displayedRevision: displayedRevision,
            outcome: outcome, activeControlCount: activeControlCount,
            elapsedMs: milliseconds.isFinite ? max(0, milliseconds) : 0,
            backend: backend, detectionAvailability: result?.detection?.availability.rawValue ?? "unavailable",
            usedFaceCount: result?.detection?.usedFaceCount ?? 0, matchesSource: result?.matchesSource,
            warningCount: max(0, max(result?.warningCount ?? 0, result?.warningCodes.count ?? 0)), errorCode: errorCode)
        if let line = event.consoleLine { previewLog(line) }
    }

    private func previewErrorCode(_ error: Error) -> String {
        if let error = error as? BeautyError { return "sdk." + error.code }
        if let error = error as? EditorError {
            return switch error {
            case .invalidImage: "editor.invalid_image"
            case .tooLarge: "editor.too_large"
            case .unsupportedColor: "editor.unsupported_color"
            case .invalidOrientation: "editor.invalid_orientation"
            case .backgroundUnavailable: "editor.background_unavailable"
            case .renderFailed: "editor.render_failed"
            case .saveDenied: "editor.save_denied"
            case .saveFailed: "editor.save_failed"
            }
        }
        return "unknown"
    }

    private func suspendDebugAnalysis() {
        debugRequest += 1
        debugTask?.cancel()
        previewLandmarks = []
        debugRevision = -1
        isDebugAnalyzing = false
    }

    func toggleDebug() {
        debugEnabled.toggle()
        if debugEnabled { refreshDebugLandmarks() }
        else {
            debugRequest += 1
            debugTask?.cancel()
            sourceLandmarks = []
            sourceLandmarkPhotoID = nil
            previewLandmarks = []
            debugRevision = -1
            isDebugAnalyzing = false
        }
    }

    private func refreshDebugLandmarks() {
        debugRequest += 1
        debugTask?.cancel()
        previewLandmarks = []
        debugRevision = -1
        guard debugEnabled, dragStart == nil, !isRendering, let photo, let preview else { return }
        let request = debugRequest
        let imageRevision = displayedRevision
        let needsSource = sourceLandmarkPhotoID != photo.id
        isDebugAnalyzing = true
        debugTask = Task {
            defer { if request == debugRequest { isDebugAnalyzing = false } }
            do {
                if needsSource {
                    let points = try await renderer.landmarks(photo.preview)
                    try Task.checkCancellation()
                    guard request == debugRequest, self.photo?.id == photo.id else { return }
                    sourceLandmarks = points
                    sourceLandmarkPhotoID = photo.id
                }
                let points = try await renderer.landmarks(preview)
                try Task.checkCancellation()
                guard request == debugRequest, self.photo?.id == photo.id,
                      imageRevision == displayedRevision, debugEnabled else { return }
                previewLandmarks = points
                debugRevision = imageRevision
            } catch {
                // Debug failure does not reject an otherwise valid edited photo.
            }
        }
    }

    private func accept(_ result: RenderedPhoto, revision: Int) {
        preview = result.image
        lastRender = result
        displayedRevision = revision
        refreshDebugLandmarks()
        switch result.detection?.availability {
        case .noFace, .lowConfidence, .disabled, .skipped:
            detectionMessage = "未获得可用人脸，相关调整保持原图。请试试清晰的正面人像。"
        case .partial:
            detectionMessage = "部分面部区域未识别，相关调整保持原图。"
        default:
            if result.warningCodes.contains(where: { $0.hasSuffix("inputs_missing") }) {
                detectionMessage = "部分五官缺少可用关键点，对应工具保持原图；其他调整保留。"
            } else if revision == self.revision && result.matchesSource && snapshot.parameters != EditorSnapshot().parameters {
                detectionMessage = "此照片未满足当前工具的处理条件，本次输出保持原图。"
            } else {
                detectionMessage = nil
            }
        }
    }

    private func message(for error: Error) -> String {
        if let editorError = error as? EditorError { return editorError.localizedDescription }
        if error is BeautyError { return EditorError.renderFailed.localizedDescription }
        return "操作未完成，请重试。当前图片和已完成的调整仍保留。"
    }
}
