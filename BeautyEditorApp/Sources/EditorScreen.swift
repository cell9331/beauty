import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct EditorScreen: View {
    @Bindable var model: EditorModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var pickerItem: PhotosPickerItem?
    @State private var receivingPhoto = false
    @State private var pickerTask: Task<Void, Never>?
    @State private var showFileImporter = false
    @State private var showDiscardConfirmation = false
    @State private var showReplaceConfirmation = false
    @State private var showSourceChoices = false
    @State private var pendingFileSelection = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let original = model.photo?.preview {
                preview(original: original)
            } else {
                emptyState
            }
            if model.isLoading || receivingPhoto || model.isExporting || model.isProtecting {
                Color.black.opacity(0.2)
                VStack(spacing: 12) {
                    ProgressView().tint(.white)
                    Text(model.isExporting ? "正在处理原尺寸图片…" :
                         model.isProtecting ? "正在分离人物与背景…" : "正在读取图片…")
                        .font(.system(size: 14)).foregroundStyle(.white)
                }
                .padding(24).background(.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if model.photo != nil {
                if model.isEditing {
                    BeautyEditorChrome(model: model, onClose: closeEditor)
                } else {
                    reviewActions
                }
            }
        }
        .preferredColorScheme(.light)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image]) { result in
            switch result {
            case .success(let url):
                receivingPhoto = true
                Task {
                    do {
                        let data = try await Task.detached(priority: .userInitiated) {
                            let access = url.startAccessingSecurityScopedResource()
                            defer { if access { url.stopAccessingSecurityScopedResource() } }
                            return try ImageInput.readBoundedFile(url)
                        }.value
                        model.importPhoto(data)
                    } catch { model.errorMessage = (error as? EditorError)?.localizedDescription ?? "无法读取文件，请重试。" }
                    receivingPhoto = false
                }
            case .failure:
                // System cancellation preserves the current edit session.
                break
            }
        }
        .onChange(of: pickerItem) { _, item in
            pickerTask?.cancel()
            guard let item else { return }
            receivingPhoto = true
            pickerTask = Task {
                do {
                    guard let transfer = try await item.loadTransferable(type: PickerPhoto.self) else {
                        throw EditorError.invalidImage
                    }
                    try Task.checkCancellation()
                    model.importPhoto(transfer.data)
                } catch is CancellationError {
                    return
                } catch {
                    model.errorMessage = (error as? EditorError)?.localizedDescription ?? "照片读取失败，请重试。"
                }
                receivingPhoto = false
                pickerItem = nil
            }
        }
        .alert("操作提示", isPresented: Binding(get: { model.errorMessage != nil },
                                              set: { if !$0 { model.errorMessage = nil } })) {
            Button("知道了", role: .cancel) { model.errorMessage = nil }
        } message: { Text(model.errorMessage ?? "") }
        .confirmationDialog("放弃本次尚未确认的调整？", isPresented: $showDiscardConfirmation,
                            titleVisibility: .visible) {
            Button("放弃调整", role: .destructive) { model.cancelEditing() }
            Button("继续编辑", role: .cancel) {}
        }
        .confirmationDialog("更换照片会结束当前编辑，已保存到相册或文件的图片仍会保留。",
                            isPresented: $showReplaceConfirmation, titleVisibility: .visible) {
            Button("选择另一张照片") { showSourceChoices = true }
            Button("取消", role: .cancel) {}
        }
        .sheet(isPresented: $showSourceChoices, onDismiss: {
            if pendingFileSelection { pendingFileSelection = false; showFileImporter = true }
        }) {
            sourceSheet
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $model.sharedPhoto, onDismiss: { model.removeSharedFile() }) { photo in
            ActivitySheet(url: photo.url)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { model.comparing = false; model.endAdjustment() }
        }
        .privacySensitive()
        #if DEBUG
        .task {
            // Test-only injection accepts the same bounded file importer as production.
            // No fixture, mask, private locator or debug entry point is bundled.
            if let path = ProcessInfo.processInfo.environment["BEAUTY_TEST_IMAGE"] {
                do { model.importPhoto(try ImageInput.readBoundedFile(URL(fileURLWithPath: path))) }
                catch { model.errorMessage = "测试输入无法读取。" }
            }
        }
        #endif
    }

    private func preview(original: CGImage) -> some View {
        GeometryReader { geometry in
            Image(decorative: model.comparing ? original : (model.preview ?? original), scale: 1)
                .resizable().scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .accessibilityIdentifier("photo-preview")
                .overlay {
                    if model.debugEnabled {
                        LandmarkOverlay(source: model.sourceLandmarks,
                                        current: model.comparing ? [] : model.previewLandmarks,
                                        imageSize: CGSize(width: original.width, height: original.height))
                            .allowsHitTesting(false).accessibilityHidden(true)
                    }
                }
                .overlay(alignment: .top) { topActions }
                .overlay(alignment: .topLeading) {
                    if model.debugEnabled { debugPanel.padding(.leading, 12).padding(.top, 52) }
                }
                .overlay(alignment: .bottom) {
                    VStack(spacing: 8) {
                        if let message = model.successMessage ?? model.detectionMessage {
                            Text(message).font(.system(size: 12))
                                .foregroundStyle(.white).multilineTextAlignment(.center)
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(.black.opacity(0.65), in: RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal, 20)
                                .accessibilityIdentifier("photo-status")
                        }
                        if model.isEditing { BeautyPreviewControls(model: model) }
                    }
                    .padding(.bottom, 10)
                }
                .overlay(alignment: .topTrailing) {
                    if model.isRendering {
                        ProgressView().tint(.white).padding(10)
                            .background(.black.opacity(0.45), in: Capsule()).offset(x: -12, y: 56)
                            .accessibilityLabel("正在更新预览")
                    }
                }
        }
    }

    private var debugPanel: some View {
        let sourceCount = model.sourceLandmarks.reduce(0) { $0 + $1.points.count }
        let currentCount = model.previewLandmarks.reduce(0) { $0 + $1.points.count }
        return VStack(alignment: .leading, spacing: 3) {
            Text("DEBUG · 青圈原图 / 黄点当前")
            Text("\(model.previewLandmarks.first?.detectorName ?? model.sourceLandmarks.first?.detectorName ?? "识别中") 复检点 · 非 SDK 形变控制点")
            Text(model.isDebugAnalyzing ? "关键点更新中…" : "原图 \(sourceCount)点 · 当前 \(currentCount)点 · r\(model.debugRevision)")
            Text("图像 r\(model.displayedRevision) / 参数 r\(model.revision)")
            if let result = model.lastRender {
                Text("\(result.image.width)×\(result.image.height) · \(Int(result.renderMilliseconds.rounded())) ms · \(result.backendName) · 人脸 \(result.detection?.usedFaceCount ?? 0)")
                Text("\(model.selectedTool.field ?? "停用") = \(model.selectedTool.sdkValue(in: model.snapshot.parameters).formatted(.number.precision(.fractionLength(3))))")
                Text("组合 \(ToolCatalog.canonicalTools.filter { abs($0.sdkValue(in: model.snapshot.parameters)) > 0 }.count) 项")
                if let detection = result.detection, !detection.reasons.isEmpty {
                    Text("识别: \(detection.availability.rawValue) · \(detection.reasons.map(\.rawValue).joined(separator: ", "))")
                }
                if !result.warningCodes.isEmpty { Text(result.warningCodes.joined(separator: ", ")) }
            }
        }
        .font(.system(size: 10, design: .monospaced))
        .foregroundStyle(.white).padding(8)
        .background(.black.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
        .frame(maxWidth: 290, alignment: .leading)
        .allowsHitTesting(false)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("debug-status")
    }

    private var topActions: some View {
        HStack(spacing: 2) {
            Button { showReplaceConfirmation = true } label: {
                Image(systemName: "photo.badge.plus").font(.system(size: 19))
                    .frame(width: 44, height: 44).contentShape(Rectangle())
            }
            .accessibilityLabel("更换照片")
            .accessibilityIdentifier("replace-photo")
            Spacer()
            if model.isEditing {
                Button { model.undo() } label: { Image(systemName: "arrow.uturn.backward").frame(width: 44, height: 44).contentShape(Rectangle()) }
                    .disabled(!model.canUndo).accessibilityLabel("撤销").accessibilityIdentifier("undo")
                Button { model.redo() } label: { Image(systemName: "arrow.uturn.forward").frame(width: 44, height: 44).contentShape(Rectangle()) }
                    .disabled(!model.canRedo).accessibilityLabel("重做").accessibilityIdentifier("redo")
                Button { model.toggleDebug() } label: {
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                        .foregroundStyle(model.debugEnabled ? .yellow : .white)
                        .frame(width: 44, height: 44).contentShape(Rectangle())
                }
                .accessibilityLabel("关键点调试")
                .accessibilityValue(model.debugEnabled ? "开启" : "关闭")
                .accessibilityIdentifier("debug-toggle")
                Menu {
                    if let note = model.selectedTool.note { Text(note) }
                    Button(model.debugEnabled ? "关闭关键点调试" : "开启关键点调试",
                           systemImage: "point.3.connected.trianglepath.dotted") { model.toggleDebug() }
                    Button("重置当前工具", systemImage: "arrow.counterclockwise") { model.resetCurrentTool() }
                    Button("重置全部调整", systemImage: "arrow.counterclockwise.circle") { model.resetAll() }
                } label: { Image(systemName: "ellipsis").frame(width: 44, height: 44) }
                .accessibilityLabel("更多操作").accessibilityIdentifier("more-actions")
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .background(LinearGradient(colors: [.black.opacity(0.45), .clear], startPoint: .top, endPoint: .bottom))
        .disabled(model.controlsDisabled || receivingPhoto)
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "person.crop.rectangle").font(.system(size: 54, weight: .ultraLight))
                    .foregroundStyle(BeautyStyle.accent)
                Text("美颜编辑器").font(.system(size: 26, weight: .semibold)).foregroundStyle(.white)
                Text("选择一张照片，开始精细调整")
                    .font(.system(size: 14)).foregroundStyle(.white.opacity(0.65))
            }
            Spacer()
            photoPicker(title: "从相册选择照片")
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(BeautyStyle.accent, in: RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier("import-photos")
            Button { showFileImporter = true } label: {
                Text("从文件选择").font(.system(size: 14))
                    .frame(maxWidth: .infinity, minHeight: 44).contentShape(Rectangle())
            }.accessibilityIdentifier("import-files")
            Text("图片在本机处理 · 导出保留原尺寸")
                .font(.system(size: 12)).foregroundStyle(.white.opacity(0.45)).padding(.bottom, 24)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 28)
    }

    private var sourceSheet: some View {
        VStack(spacing: 12) {
            Text("选择照片").font(.headline).padding(.top, 24)
            photoPicker(title: "从相册选择").font(.system(size: 16)).frame(height: 44)
            Button {
                pendingFileSelection = true
                showSourceChoices = false
            } label: {
                Text("从文件选择").font(.system(size: 16))
                    .frame(maxWidth: .infinity, minHeight: 44).contentShape(Rectangle())
            }.accessibilityIdentifier("replacement-files")
        }
        .foregroundStyle(BeautyStyle.ink)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Color.white.ignoresSafeArea(.container, edges: .bottom) }
    }

    private func photoPicker(title: String) -> some View {
        PhotosPicker(selection: $pickerItem, matching: .images, preferredItemEncoding: .current) {
            Label(title, systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .onChange(of: pickerItem) { _, item in
            if item != nil { showSourceChoices = false }
        }
    }

    private var reviewActions: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(model.exportSize) · PNG").font(.system(size: 12)).foregroundStyle(BeautyStyle.muted)
                Spacer()
                Button { model.resumeEditing() } label: {
                    Text("继续编辑").font(.system(size: 14, weight: .medium)).foregroundStyle(BeautyStyle.ink)
                        .frame(minHeight: 44).contentShape(Rectangle())
                }.accessibilityIdentifier("resume-editing")
            }
            HStack(spacing: 12) {
                Button { model.share() } label: {
                    Label("分享图片", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color(red: 247/255, green: 247/255, blue: 248/255), in: RoundedRectangle(cornerRadius: 10))
                }.foregroundStyle(BeautyStyle.ink).accessibilityIdentifier("share-photo")
                Button { model.saveToPhotos() } label: {
                    Label("保存到相册", systemImage: "arrow.down.to.line")
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(BeautyStyle.accent, in: RoundedRectangle(cornerRadius: 10))
                }.foregroundStyle(.white).accessibilityIdentifier("save-photo")
            }
            .font(.system(size: 14, weight: .medium))
        }
        .buttonStyle(.plain).padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 12)
        .background { Color.white.ignoresSafeArea(.container, edges: .bottom) }
        .disabled(model.controlsDisabled)
    }

    private func closeEditor() {
        model.endAdjustment()
        if model.hasChanges { showDiscardConfirmation = true }
        else { model.cancelEditing() }
    }
}

private struct ActivitySheet: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

private struct LandmarkOverlay: View {
    let source: [DebugLandmarkGroup]
    let current: [DebugLandmarkGroup]
    let imageSize: CGSize

    var body: some View {
        Canvas { context, size in
            let rect = DebugLandmarkProjection.imageRect(imageSize: imageSize, viewport: size)
            for group in source {
                for point in group.points {
                    let position = DebugLandmarkProjection.project(point, in: rect)
                    let marker = Path(ellipseIn: CGRect(x: position.x - 2.5, y: position.y - 2.5, width: 5, height: 5))
                    context.stroke(marker, with: .color(.cyan.opacity(0.85)), lineWidth: 0.8)
                }
            }
            for group in current {
                for point in group.points {
                    let position = DebugLandmarkProjection.project(point, in: rect)
                    let marker = Path(ellipseIn: CGRect(x: position.x - 1.7, y: position.y - 1.7, width: 3.4, height: 3.4))
                    context.fill(marker, with: .color(.yellow))
                }
            }
        }
    }
}
