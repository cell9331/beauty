import BeautySDK
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
    }

    let kind: Kind
    let heading: String
    let body: String
    let primaryActionTitle: String?
}

struct EditorShellView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var parameterStore = BeautyParameterStore()
    @StateObject private var cameraSessionController: CameraSessionController
    @State private var selectedCategoryID: BeautyCategoryID = .beauty
    @State private var selectedSubcategoryID: FacialFeatureSubcategoryID = .eyes
    @State private var selectedInputMode: EditorInputMode?
    @State private var cameraPermissionState: CameraPermissionState = .notDetermined
    @State private var latestCameraFrame: CameraPreviewFrame?

    private let cameraPermissionClient: any CameraPermissionClient

    @MainActor
    init(
        cameraPermissionClient: (any CameraPermissionClient)? = nil,
        cameraSessionController: CameraSessionController? = nil
    ) {
        self.cameraPermissionClient = cameraPermissionClient ?? SystemCameraPermissionClient()
        self._cameraSessionController = StateObject(wrappedValue: cameraSessionController ?? CameraSessionController())
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
            cameraSessionState: cameraSessionController.state
        )

        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)

            if state.kind == .cameraRunning {
                CameraPreviewLayerView(session: cameraSessionController.session)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityLabel("Live camera preview")
            } else {
                previewMessage(for: state)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 320)
        .accessibilityElement(children: .combine)
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
        }
    }

    static func modeViewState(selectedMode: EditorInputMode?) -> [BeautyModeItem] {
        DemoFixtures.inputModeItems(selectedMode: selectedMode)
    }

    static func previewViewState(
        selectedMode: EditorInputMode?,
        cameraPermissionState: CameraPermissionState,
        cameraSessionState: CameraSessionState
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
            return EditorPreviewViewState(
                kind: .photoEmpty,
                heading: "Choose a photo",
                body: "Select an image to process locally through BeautySDK.",
                primaryActionTitle: "Choose Photo"
            )
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
                    primaryActionTitle: nil
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
