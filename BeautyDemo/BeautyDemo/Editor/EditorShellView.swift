import BeautySDK
import PhotosUI
import SwiftUI
import UIKit

struct EditorPreviewViewState: Equatable {
    enum Kind: Equatable {
        case initial
        case cameraRequesting
        case cameraPermissionNeeded
        case cameraUnavailable
        case cameraRunning
        case photoEmpty
        case photoLoading
        case photoLoaded
        case photoFailed
    }

    let kind: Kind
    let heading: String
    let body: String
    let primaryActionTitle: String?
    let statusText: String?

    init(
        kind: Kind,
        heading: String,
        body: String,
        primaryActionTitle: String?,
        statusText: String? = nil
    ) {
        self.kind = kind
        self.heading = heading
        self.body = body
        self.primaryActionTitle = primaryActionTitle
        self.statusText = statusText
    }
}

struct EditorPreviewToolbarAction: Identifiable, Equatable {
    enum Kind: Equatable {
        case compare
        case debug
        case parameterJSON
    }

    let id: Kind
    let title: String
    let accessibilityValue: String?
}

private enum EditorSheet: Identifiable {
    case parameterJSON

    var id: String {
        switch self {
        case .parameterJSON:
            "parameterJSON"
        }
    }
}

struct EditorShellView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var parameterStore = BeautyParameterStore()
    @StateObject private var cameraSessionController: CameraSessionController
    @StateObject private var cameraBeautyPipeline: CameraBeautyPipeline
    @StateObject private var imageEditorPipeline: ImageEditorPipeline
    @State private var selectedCategoryID: BeautyCategoryID = .beauty
    @State private var selectedSubcategoryID: FacialFeatureSubcategoryID = .eyes
    @State private var selectedInputMode: EditorInputMode?
    @State private var cameraPermissionState: CameraPermissionState = .notDetermined
    @State private var latestCameraFrame: CameraPreviewFrame?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var compareState = CompareState()
    @State private var debugVisibilityState = PreviewDebugVisibilityState()
    @State private var activeSheet: EditorSheet?

    private let cameraPermissionClient: any CameraPermissionClient

    @MainActor
    init(
        cameraPermissionClient: (any CameraPermissionClient)? = nil,
        cameraSessionController: CameraSessionController? = nil,
        cameraBeautyPipeline: CameraBeautyPipeline? = nil,
        imageEditorPipeline: ImageEditorPipeline? = nil
    ) {
        self.cameraPermissionClient = cameraPermissionClient ?? SystemCameraPermissionClient()
        self._cameraSessionController = StateObject(wrappedValue: cameraSessionController ?? CameraSessionController())
        self._cameraBeautyPipeline = StateObject(wrappedValue: cameraBeautyPipeline ?? CameraBeautyPipeline())
        self._imageEditorPipeline = StateObject(wrappedValue: imageEditorPipeline ?? ImageEditorPipeline())
    }

    var body: some View {
        VStack(spacing: 16) {
            modeHeader
            previewSurface
            BeautyPanelView(
                selectedCategoryID: selectedCategoryID,
                selectedSubcategoryID: $selectedSubcategoryID,
                parameterStore: parameterStore
            )
            BeautyCategoryRailView(selectedCategoryID: $selectedCategoryID)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 247 / 255, green: 248 / 255, blue: 250 / 255))
        .onChange(of: selectedPhotoItem) { _, item in
            handlePhotoSelection(item)
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .parameterJSON:
                ParameterJSONSheetView(parameterStore: parameterStore) { _ in
                    if selectedInputMode == .photo {
                        imageEditorPipeline.reprocessLatest(parameters: parameterStore.parametersSnapshot)
                    }
                }
            }
        }
    }

    private var modeHeader: some View {
        HStack(spacing: 8) {
            ForEach(Self.modeViewState(selectedMode: selectedInputMode)) { item in
                BeautyModeEntryView(item: item) {
                    selectMode(item.id)
                }
            }
        }
    }

    private var previewSurface: some View {
        let state = Self.previewViewState(
            selectedMode: selectedInputMode,
            cameraPermissionState: cameraPermissionState,
            cameraSessionState: cameraSessionController.state,
            cameraProcessingState: cameraBeautyPipeline.state,
            photoProcessingState: imageEditorPipeline.state
        )

        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)

            previewContent(for: state)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 320)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func previewContent(for state: EditorPreviewViewState) -> some View {
        switch state.kind {
        case .cameraRunning:
            cameraPreviewContent(for: state)
        case .photoEmpty, .photoLoading, .photoLoaded, .photoFailed:
            photoPreviewContent(for: state)
        case .initial, .cameraRequesting, .cameraPermissionNeeded, .cameraUnavailable:
            previewMessage(for: state)
        }
    }

    private func cameraPreviewContent(for state: EditorPreviewViewState) -> some View {
        ZStack {
            CameraPreviewLayerView(session: cameraSessionController.session)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel("Live camera preview")

            if debugVisibilityState.isVisible {
                PreviewDebugOverlayView(state: PreviewDebugOverlayState.camera(cameraBeautyPipeline.state))
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            VStack {
                Spacer()
                if cameraBeautyPipeline.state.latestSnapshot != nil {
                    previewToolbar(showsCompare: true)
                }
                if let statusText = state.statusText {
                    cameraStatusBanner(statusText)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func photoPreviewContent(for state: EditorPreviewViewState) -> some View {
        ZStack {
            if let snapshot = imageEditorPipeline.state.latestSnapshot {
                Image(decorative: compareState.photoImage(from: snapshot), scale: 1)
                    .resizable()
                    .scaledToFit()
                    .padding(16)
                    .accessibilityLabel("Photo preview")
            } else {
                photoMessage(for: state)
            }

            if debugVisibilityState.isVisible {
                PreviewDebugOverlayView(state: PreviewDebugOverlayState.photo(imageEditorPipeline.state))
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            VStack {
                Spacer()
                if imageEditorPipeline.state.latestSnapshot != nil, !imageEditorPipeline.state.isLoading {
                    previewToolbar(showsCompare: true)
                }
                if imageEditorPipeline.state.isLoading {
                    cameraStatusBanner(PhotoProcessingState.loadingText)
                } else if let statusText = state.statusText {
                    cameraStatusBanner(statusText)
                }
                if !imageEditorPipeline.state.isLoading {
                    photoPickerButton("Choose Photo")
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func previewToolbar(showsCompare: Bool) -> some View {
        HStack(spacing: 8) {
            if showsCompare {
                compareButton
            }
            debugButton
            parameterJSONButton
        }
    }

    private var compareButton: some View {
        Button(compareState.actionTitle) {
            compareState.toggle()
        }
        .font(.system(size: 13, weight: .semibold))
        .buttonStyle(.borderedProminent)
        .accessibilityLabel(compareState.actionTitle)
        .accessibilityValue(compareState.accessibilityValue)
        .accessibilityHint("Switches between before and after without changing parameters.")
    }

    private var debugButton: some View {
        Button(debugVisibilityState.title) {
            debugVisibilityState.toggle()
        }
        .font(.system(size: 13, weight: .semibold))
        .buttonStyle(.bordered)
        .tint(debugVisibilityState.isVisible ? Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255) : nil)
        .frame(minHeight: 44)
        .accessibilityLabel(debugVisibilityState.title)
        .accessibilityValue(debugVisibilityState.accessibilityValue)
        .accessibilityHint("Shows read-only preview diagnostics without changing output.")
    }

    private var parameterJSONButton: some View {
        Button("Parameter JSON") {
            activeSheet = .parameterJSON
        }
        .font(.system(size: 13, weight: .semibold))
        .buttonStyle(.bordered)
        .frame(minHeight: 44)
        .accessibilityLabel("Open Parameter JSON")
    }

    private func cameraStatusBanner(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color(red: 32 / 255, green: 47 / 255, blue: 77 / 255))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.92))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
            )
            .accessibilityLabel(text)
    }

    private func previewMessage(for state: EditorPreviewViewState) -> some View {
        VStack(spacing: 16) {
            portraitGlyph

            VStack(spacing: 8) {
                Text(state.heading)
                    .font(.system(size: state.kind == .initial ? 28 : 20, weight: .semibold))
                Text(state.body)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            if let primaryActionTitle = state.primaryActionTitle {
                Button(primaryActionTitle) {
                    handlePreviewAction(for: state)
                }
                .font(.system(size: 13, weight: .semibold))
                .buttonStyle(.borderedProminent)
                .accessibilityLabel(primaryActionTitle)
            }
        }
    }

    private func photoMessage(for state: EditorPreviewViewState) -> some View {
        VStack(spacing: 16) {
            portraitGlyph

            VStack(spacing: 8) {
                Text(state.heading)
                    .font(.system(size: 20, weight: .semibold))
                Text(state.body)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
    }

    private func photoPickerButton(_ title: String) -> some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
        }
        .buttonStyle(.borderedProminent)
        .accessibilityLabel(title)
        .accessibilityHint("Choose a local photo to process on this device.")
    }

    private var portraitGlyph: some View {
        ZStack {
            Circle()
                .fill(Color(red: 238 / 255, green: 243 / 255, blue: 255 / 255))
                .frame(width: 132, height: 132)

            Circle()
                .fill(Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255).opacity(0.16))
                .frame(width: 72, height: 72)
                .offset(y: -24)

            Capsule()
                .fill(Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255).opacity(0.14))
                .frame(width: 96, height: 56)
                .offset(y: 40)
        }
        .accessibilityHidden(true)
    }

    private func selectMode(_ mode: EditorInputMode) {
        selectedInputMode = mode

        switch mode {
        case .camera:
            Task {
                await requestCameraAndStartIfNeeded()
            }
        case .photo:
            cameraSessionController.stop()
            cameraBeautyPipeline.reset()
        }
    }

    private func handlePreviewAction(for state: EditorPreviewViewState) {
        switch state.kind {
        case .initial, .photoEmpty:
            selectMode(.photo)
        case .cameraPermissionNeeded:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
        case .cameraUnavailable:
            selectMode(.camera)
        case .cameraRequesting, .cameraRunning:
            break
        case .photoLoading, .photoLoaded, .photoFailed:
            break
        }
    }

    private func handlePhotoSelection(_ item: PhotosPickerItem?) {
        guard let item else {
            return
        }

        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    imageEditorPipeline.process(
                        input: .photosPickerData(data),
                        parameters: parameterStore.parametersSnapshot
                    )
                }
            } catch {
                imageEditorPipeline.recordSelectionFailure()
            }
            selectedPhotoItem = nil
        }
    }

    private func requestCameraAndStartIfNeeded() async {
        cameraPermissionState = .requesting
        let state = await cameraPermissionClient.requestAccessIfNeeded()
        cameraPermissionState = state

        guard state == .authorized else {
            cameraSessionController.stop()
            return
        }

        cameraSessionController.start { frame in
            latestCameraFrame = frame
            cameraBeautyPipeline.enqueue(
                frame: frame,
                parameters: parameterStore.parametersSnapshot
            )
        }
    }

    static func modeViewState(selectedMode: EditorInputMode?) -> [BeautyModeItem] {
        DemoFixtures.inputModeItems(selectedMode: selectedMode)
    }

    static func previewToolbarViewState(
        compareActionTitle: String,
        debugActionTitle: String,
        debugAccessibilityValue: String
    ) -> [EditorPreviewToolbarAction] {
        [
            EditorPreviewToolbarAction(id: .compare, title: compareActionTitle, accessibilityValue: nil),
            EditorPreviewToolbarAction(
                id: .debug,
                title: debugActionTitle,
                accessibilityValue: debugAccessibilityValue
            ),
            EditorPreviewToolbarAction(id: .parameterJSON, title: "Parameter JSON", accessibilityValue: nil)
        ]
    }

    static func previewViewState(
        selectedMode: EditorInputMode?,
        cameraPermissionState: CameraPermissionState,
        cameraSessionState: CameraSessionState,
        cameraProcessingState: CameraProcessingState = .idle,
        photoProcessingState: PhotoProcessingState = .empty
    ) -> EditorPreviewViewState {
        switch selectedMode {
        case .none:
            return EditorPreviewViewState(
                kind: .initial,
                heading: DemoFixtures.previewTitle,
                body: DemoFixtures.previewBody,
                primaryActionTitle: "Choose Photo"
            )
        case .some(.photo):
            switch photoProcessingState {
            case .empty:
                return EditorPreviewViewState(
                    kind: .photoEmpty,
                    heading: "Choose a photo",
                    body: "Select an image to process locally through BeautySDK.",
                    primaryActionTitle: "Choose Photo"
                )
            case .loading:
                return EditorPreviewViewState(
                    kind: .photoLoading,
                    heading: "Choose a photo",
                    body: PhotoProcessingState.loadingText,
                    primaryActionTitle: nil,
                    statusText: PhotoProcessingState.loadingText
                )
            case .loaded:
                return EditorPreviewViewState(
                    kind: .photoLoaded,
                    heading: "Photo",
                    body: "Processed image",
                    primaryActionTitle: "Choose Photo"
                )
            case .failed(_, let message):
                return EditorPreviewViewState(
                    kind: .photoFailed,
                    heading: "Choose a photo",
                    body: message,
                    primaryActionTitle: "Choose Photo",
                    statusText: message
                )
            }
        case .some(.camera):
            if cameraPermissionState == .requesting {
                return EditorPreviewViewState(
                    kind: .cameraRequesting,
                    heading: "Camera access needed",
                    body: "Allow camera access to preview processing on this device. Photo mode is still available.",
                    primaryActionTitle: nil
                )
            }

            if cameraPermissionState.isPermissionBlocked {
                return EditorPreviewViewState(
                    kind: .cameraPermissionNeeded,
                    heading: "Camera access needed",
                    body: "Allow camera access to preview processing on this device. Photo mode is still available.",
                    primaryActionTitle: "Open Settings"
                )
            }

            if cameraPermissionState == .unavailable || cameraSessionState.isUnavailableForPreview {
                return EditorPreviewViewState(
                    kind: .cameraUnavailable,
                    heading: "Camera unavailable",
                    body: "Live preview cannot start on this device. Use Photo mode to continue testing the SDK path.",
                    primaryActionTitle: "Try Again"
                )
            }

            if cameraPermissionState == .authorized && cameraSessionState == .running {
                return EditorPreviewViewState(
                    kind: .cameraRunning,
                    heading: "Camera",
                    body: "Live preview",
                    primaryActionTitle: nil,
                    statusText: cameraProcessingState.statusText
                )
            }

            return EditorPreviewViewState(
                kind: .cameraUnavailable,
                heading: "Camera unavailable",
                body: "Live preview cannot start on this device. Use Photo mode to continue testing the SDK path.",
                primaryActionTitle: "Try Again"
            )
        }
    }
}

#Preview {
    EditorShellView()
}
