import BeautySDK
import XCTest
@testable import BeautyDemo

final class BeautyDemoViewStateTests: XCTestCase {
    func testInitialCategoryRailViewStateCoversSDK08AndDEMO02() {
        let items = BeautyCategoryRailView.viewState(selectedCategoryID: .beauty)

        // SDK-08 DEMO-02
        XCTAssertEqual(
            items.map(\.title),
            ["Beauty", "Face Shape", "Facial Features", "Makeup", "Filters", "Stickers", "Background", "Style"]
        )
        XCTAssertEqual(items.filter(\.isSelected).map(\.title), ["Beauty"])
    }

    func testDisabledCategoryRailItemsExposeAvailabilityForDEMO03() {
        let items = BeautyCategoryRailView.viewState(selectedCategoryID: .beauty)
        let disabledItems = items.filter { !$0.availability.isEnabled }

        // DEMO-03
        XCTAssertEqual(disabledItems.map(\.title), ["Makeup", "Filters", "Stickers", "Background", "Style"])
        XCTAssertTrue(disabledItems.allSatisfy { $0.availability.badge?.isEmpty == false })
        XCTAssertTrue(disabledItems.allSatisfy { $0.availability.reason?.isEmpty == false })
    }

    func testFirstScreenModeSwitchesCoverDEMO01D01D02AndD03ShellState() {
        let modes = EditorShellView.modeViewState(selectedMode: nil)
        let previewState = EditorShellView.previewViewState(
            selectedMode: nil,
            cameraPermissionState: .notDetermined,
            cameraSessionState: .idle
        )

        // DEMO-01 D-01 D-02 D-03
        XCTAssertEqual(DemoFixtures.previewTitle, "Choose Camera or Photo")
        XCTAssertEqual(modes.map(\.title), ["Camera", "Photo"])
        XCTAssertTrue(modes.allSatisfy(\.isEnabled))
        XCTAssertTrue(modes.filter(\.isSelected).isEmpty)
        XCTAssertEqual(previewState.heading, "Choose Camera or Photo")
        XCTAssertEqual(previewState.primaryActionTitle, "Choose Photo")
    }

    func testCameraSelectionPreservesShellControlsForD04AndD06() {
        let modeItems = EditorShellView.modeViewState(selectedMode: .camera)
        let deniedPreviewState = EditorShellView.previewViewState(
            selectedMode: .camera,
            cameraPermissionState: .denied,
            cameraSessionState: .idle
        )

        // D-04 D-06
        XCTAssertEqual(modeItems.filter(\.isSelected).map(\.id), [.camera])
        XCTAssertTrue(modeItems.first { $0.id == .photo }?.isEnabled == true)
        XCTAssertEqual(deniedPreviewState.heading, "Camera access needed")
        XCTAssertEqual(BeautyPanelView.viewState(categoryID: .beauty, selectedSubcategoryID: .eyes, status: .idle).category.title, "Beauty")
        XCTAssertEqual(BeautyCategoryRailView.viewState(selectedCategoryID: .beauty).filter(\.isSelected).map(\.id), [.beauty])
    }

    func testCameraProcessingStatusUsesFriendlyCopyForD12AndD13() {
        let previewState = EditorShellView.previewViewState(
            selectedMode: .camera,
            cameraPermissionState: .authorized,
            cameraSessionState: .running,
            cameraProcessingState: .paused(
                lastSnapshot: nil,
                droppedFrameCount: 0,
                warning: CameraProcessingState.processingPausedMessage
            )
        )

        // D-12 D-13
        XCTAssertEqual(previewState.kind, .cameraRunning)
        XCTAssertEqual(previewState.statusText, "Processing paused. Showing the last usable preview.")
        XCTAssertFalse(previewState.statusText?.contains("NSError") == true)
        XCTAssertFalse(previewState.statusText?.contains("/") == true)
    }

    func testPhotoPreviewViewStateCoversD05D11AndD13Copy() {
        let emptyState = EditorShellView.previewViewState(
            selectedMode: .photo,
            cameraPermissionState: .notDetermined,
            cameraSessionState: .idle,
            photoProcessingState: .empty
        )
        let loadingState = EditorShellView.previewViewState(
            selectedMode: .photo,
            cameraPermissionState: .notDetermined,
            cameraSessionState: .idle,
            photoProcessingState: .loading(previousSnapshot: nil)
        )
        let failedState = EditorShellView.previewViewState(
            selectedMode: .photo,
            cameraPermissionState: .notDetermined,
            cameraSessionState: .idle,
            photoProcessingState: .failed(previousSnapshot: nil, message: PhotoProcessingState.decodeFailureText)
        )

        // D-05 D-11 D-13
        XCTAssertEqual(emptyState.heading, "Choose a photo")
        XCTAssertEqual(emptyState.body, "Select an image to process locally through BeautySDK.")
        XCTAssertEqual(emptyState.primaryActionTitle, "Choose Photo")
        XCTAssertEqual(loadingState.statusText, "Processing photo...")
        XCTAssertEqual(failedState.body, "Could not read that photo. Choose another image.")
        XCTAssertFalse(failedState.body.contains("NSError"))
        XCTAssertFalse(failedState.body.contains("/"))
    }

    func testPhase3InputStateMatrixCoversPIPE01PIPE04PIPE06PIPE08AndDEMO01() throws {
        let snapshot = try makeImageSnapshot()
        let states = [
            EditorShellView.previewViewState(
                selectedMode: nil,
                cameraPermissionState: .notDetermined,
                cameraSessionState: .idle
            ),
            EditorShellView.previewViewState(
                selectedMode: .camera,
                cameraPermissionState: .requesting,
                cameraSessionState: .idle
            ),
            EditorShellView.previewViewState(
                selectedMode: .camera,
                cameraPermissionState: .denied,
                cameraSessionState: .idle
            ),
            EditorShellView.previewViewState(
                selectedMode: .camera,
                cameraPermissionState: .unavailable,
                cameraSessionState: .idle
            ),
            EditorShellView.previewViewState(
                selectedMode: .camera,
                cameraPermissionState: .authorized,
                cameraSessionState: .running
            ),
            EditorShellView.previewViewState(
                selectedMode: .photo,
                cameraPermissionState: .notDetermined,
                cameraSessionState: .idle,
                photoProcessingState: .empty
            ),
            EditorShellView.previewViewState(
                selectedMode: .photo,
                cameraPermissionState: .notDetermined,
                cameraSessionState: .idle,
                photoProcessingState: .loading(previousSnapshot: snapshot)
            ),
            EditorShellView.previewViewState(
                selectedMode: .photo,
                cameraPermissionState: .notDetermined,
                cameraSessionState: .idle,
                photoProcessingState: .loaded(snapshot)
            ),
            EditorShellView.previewViewState(
                selectedMode: .photo,
                cameraPermissionState: .notDetermined,
                cameraSessionState: .idle,
                photoProcessingState: .failed(previousSnapshot: snapshot, message: PhotoProcessingState.decodeFailureText)
            )
        ]

        // PIPE-01 PIPE-04 PIPE-06 PIPE-08 DEMO-01
        XCTAssertEqual(
            states.map(\.kind),
            [
                .initial,
                .cameraRequesting,
                .cameraPermissionNeeded,
                .cameraUnavailable,
                .cameraRunning,
                .photoEmpty,
                .photoLoading,
                .photoLoaded,
                .photoFailed
            ]
        )
        XCTAssertEqual(states[0].primaryActionTitle, "Choose Photo")
        XCTAssertEqual(states[2].primaryActionTitle, "Open Settings")
        XCTAssertEqual(states[3].primaryActionTitle, "Try Again")
        XCTAssertEqual(states[6].statusText, "Processing photo...")
        XCTAssertEqual(states[8].statusText, "Could not read that photo. Choose another image.")
        XCTAssertTrue(EditorShellView.modeViewState(selectedMode: .camera).allSatisfy(\.isEnabled))
        XCTAssertTrue(EditorShellView.modeViewState(selectedMode: .photo).allSatisfy(\.isEnabled))
    }

    func testFacialFeaturePanelViewStateCoversDEMO04() {
        let state = BeautyPanelView.viewState(
            categoryID: .facialFeatures,
            selectedSubcategoryID: .eyes,
            status: .idle
        )

        // DEMO-04
        XCTAssertEqual(
            state.subcategories.map(\.title),
            ["Eyes", "Nose", "Mouth", "Eyebrows", "Teeth", "Hairline"]
        )
        XCTAssertEqual(state.subcategories.filter(\.isSelected).map(\.title), ["Eyes"])
        XCTAssertEqual(state.controls.map(\.id), [.eyeSize, .eyeDistance, .eyeYPosition, .eyeTailLift])
    }

    func testFilterPanelViewStateCoversDEMO03DisabledControls() {
        let state = BeautyPanelView.viewState(
            categoryID: .filters,
            selectedSubcategoryID: .eyes,
            status: .idle
        )

        // DEMO-03
        XCTAssertFalse(state.activeAvailability.isEnabled)
        XCTAssertEqual(state.activeAvailability.badge, "Coming in Phase 5")
        XCTAssertEqual(state.disabledControls.map(\.id), [.filterId, .filterIntensity])
    }

    func testBeautyPanelViewStateCoversDEMO05AndDEMO08ResetSurface() {
        let state = BeautyPanelView.viewState(
            categoryID: .beauty,
            selectedSubcategoryID: .eyes,
            status: .appliedPendingVisual
        )

        // DEMO-05 DEMO-08
        XCTAssertTrue(state.showsResetAll)
        XCTAssertEqual(state.status.primaryText, "Parameters applied")
        XCTAssertEqual(state.status.secondaryText, "Visual update pending Phase 6")
        XCTAssertEqual(state.controls.map(\.id), [.skinSmoothing, .skinWhitening, .skinRosy, .skinSharpen])
    }

    func testSliderDisplayAndAccessibilityValuesCoverDEMO05() {
        // DEMO-05
        XCTAssertEqual(BeautySliderView.displayValueText(32, range: .enhancement), "32")
        XCTAssertEqual(BeautySliderView.displayValueText(45, range: .bidirectional), "+45")
        XCTAssertEqual(BeautySliderView.accessibilityValueText(-20, range: .bidirectional), "-20 percent")
    }

    private func makeImageSnapshot() throws -> ImageProcessingSnapshot {
        let renderer = ImageDisplayRenderer()
        let image = DemoFixtures.photoFixtureImage()
        let cgImage = try renderer.render(image)

        return ImageProcessingSnapshot(
            sourceKind: .fixture,
            sourceID: "view-state",
            inputImage: image,
            outputImage: image,
            inputCGImage: cgImage,
            outputCGImage: cgImage,
            orientation: .up,
            parameters: BeautyParameters(skinSmoothing: 0.2)
        )
    }
}
