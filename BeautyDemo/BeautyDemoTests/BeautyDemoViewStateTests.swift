import BeautySDK
import XCTest
@testable import BeautyDemo

final class BeautyDemoViewStateTests: XCTestCase {
    func testV11HomeViewStateMatchesMeituReferenceHierarchy() {
        let state = MeituHomeView.viewState()

        XCTAssertEqual(state.hero.title, "复古胶片相机")
        XCTAssertEqual(state.hero.ctaTitle, "拍一拍")
        XCTAssertEqual(
            state.primaryActions.map(\.title),
            ["图片美化", "修视频", "人像美容", "拼图", "相机", "视频美容"]
        )
        XCTAssertEqual(
            state.primaryActions.map(\.route),
            [.photoEditor, .disabled, .beautyEditor, .disabled, .cameraEditor, .disabled]
        )
        XCTAssertEqual(state.primaryActions.filter { $0.size == .large }.map(\.title), ["图片美化", "修视频"])
        XCTAssertEqual(state.toolPages.map(\.tools.count), [8, 12, 1])
        XCTAssertEqual(
            state.recommendations.map(\.title),
            ["欧美闪光滤镜", "不能错过热门玩法", "欧美曲线塑形", "欧美美容常态"]
        )
        XCTAssertEqual(state.tabs.map(\.title), ["首页", "图库", "AI 修图", "我"])
        XCTAssertEqual(state.tabs.filter(\.isSelected).map(\.title), ["首页"])
        XCTAssertEqual(state.tabs.filter(\.showsDot).map(\.title), ["我"])
    }

    func testV11HomeRoutesOnlySupportedLocalFlows() {
        XCTAssertEqual(ContentView.routeTarget(for: .photoEditor), .photo)
        XCTAssertEqual(ContentView.routeTarget(for: .cameraEditor), .camera)
        XCTAssertEqual(ContentView.routeTarget(for: .beautyEditor), .beauty)
        XCTAssertNil(ContentView.routeTarget(for: .disabled))
        XCTAssertEqual(MeituEditorRouteTarget.photo.initialMode, .photo)
        XCTAssertEqual(MeituEditorRouteTarget.camera.initialMode, .camera)
        XCTAssertEqual(MeituEditorRouteTarget.beauty.initialMode, .photo)
        XCTAssertNil(ContentView.initialRouteTarget(arguments: ["BeautyDemo"]))
        XCTAssertEqual(
            ContentView.initialRouteTarget(arguments: ["BeautyDemo", "--beauty-demo-route", "editor-beauty"]),
            .beauty
        )
        XCTAssertFalse(ContentView.initialHomeStickyPreview(arguments: ["BeautyDemo"]))
        XCTAssertTrue(ContentView.initialHomeStickyPreview(arguments: ["BeautyDemo", "--beauty-demo-home-sticky"]))
    }

    func testV11EditorTaxonomyMatchesMeituFunctionReferenceOrder() {
        XCTAssertEqual(
            MeituEditorCategory.all.map(\.title),
            ["3D塑颜", "比例", "脸型", "眼睛", "嘴唇", "鼻子", "眉毛"]
        )
        XCTAssertEqual(
            MeituEditorCategory.category(id: .faceShape).tools.map(\.title),
            ["脸宽", "小脸", "面部流畅", "太阳穴", "颧骨", "下巴长短", "去双下巴", "去双下巴", "尖下巴", "V脸", "下颌角", "下颌线", "发际线"]
        )
        XCTAssertEqual(
            MeituEditorCategory.category(id: .eyes).tools.map(\.title),
            ["大小", "上下", "眼高", "长度", "眼距", "去脂", "提肌", "眼瞳大小", "眼神矫正", "眼睑下至", "眼尾上扬", "倾斜", "祛红血丝", "内眼角", "外眼角", "对称"]
        )
    }

    func testV11EditorSupportedToolMappingsAndDisabledHonesty() {
        let faceTools = MeituEditorCategory.category(id: .faceShape).tools
        let eyeTools = MeituEditorCategory.category(id: .eyes).tools
        let browTools = MeituEditorCategory.category(id: .eyebrows).tools

        XCTAssertEqual(faceTools.first { $0.title == "脸宽" }?.controlID, .faceSlim)
        XCTAssertEqual(faceTools.first { $0.title == "小脸" }?.controlID, .faceSmall)
        XCTAssertEqual(faceTools.first { $0.title == "V脸" }?.controlID, .faceVShape)
        XCTAssertEqual(faceTools.first { $0.title == "下颌角" }?.controlID, .jawSlim)
        XCTAssertEqual(eyeTools.first { $0.title == "大小" }?.controlID, .eyeSize)
        XCTAssertEqual(eyeTools.first { $0.title == "眼尾上扬" }?.controlID, .eyeTailLift)
        XCTAssertTrue(browTools.allSatisfy { !$0.isSupported })
        XCTAssertTrue(MeituEditorCategory.all.flatMap(\.tools).filter { !$0.isSupported }.allSatisfy {
            $0.unavailableReason?.contains("v1.1") == true
        })
    }

    @MainActor
    func testV11MeituPanelSliderWritesSupportedParameterOnly() {
        let store = BeautyParameterStore()
        var categoryID: MeituEditorCategoryID = .faceShape
        var toolID = "face.width"
        let supported = MeituEditorCategory.category(id: categoryID).tools.first { $0.id == toolID }!
        let unsupported = MeituEditorCategory.category(id: .faceShape).tools.first { $0.id == "face.smooth" }!

        store.setDisplayValue(36, for: supported.controlID!)
        XCTAssertEqual(store.displayValue(for: .faceSlim), 36, accuracy: 0.0001)
        XCTAssertEqual(store.parametersSnapshot.faceSlim, 0.36, accuracy: 0.0001)

        let state = MeituEditorToolPanelView.viewState(
            selectedCategoryID: categoryID,
            selectedToolID: toolID,
            displayValue: store.displayValue(for: supported.controlID!),
            compareTitle: "对比",
            debugTitle: "调试"
        )
        XCTAssertEqual(state.selectedTool.controlID, .faceSlim)
        XCTAssertEqual(state.selectedValue, 36, accuracy: 0.0001)
        XCTAssertEqual(state.sliderRange, .enhancement)

        categoryID = .faceShape
        toolID = unsupported.id
        let disabledState = MeituEditorToolPanelView.viewState(
            selectedCategoryID: categoryID,
            selectedToolID: toolID,
            displayValue: 0,
            compareTitle: "对比",
            debugTitle: "调试"
        )
        XCTAssertFalse(disabledState.selectedTool.isSupported)
        XCTAssertNil(disabledState.selectedTool.controlID)
    }

    @MainActor
    func testV11CancelRestoresPreviousConfirmedParameterSnapshot() {
        let store = BeautyParameterStore()
        store.setDisplayValue(24, for: .faceSlim)
        let confirmed = store.parametersSnapshot
        store.setDisplayValue(68, for: .faceSlim)

        store.restoreCustomParameters(confirmed)

        XCTAssertEqual(store.displayValue(for: .faceSlim), 24, accuracy: 0.0001)
        XCTAssertEqual(store.parametersSnapshot.faceSlim, 0.24, accuracy: 0.0001)
        XCTAssertEqual(store.parameterSource, .custom)
    }

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
        XCTAssertEqual(disabledItems.map(\.title), ["Makeup", "Stickers", "Background", "Style"])
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

    func testDEMO06PreviewToolbarIncludesParameterJSONAndPreservesCompareLabels() {
        XCTAssertEqual(
            EditorShellView.previewToolbarViewState(
                compareActionTitle: "Show Before",
                debugActionTitle: "Show Debug Details",
                debugAccessibilityValue: "Debug details hidden"
            ).map(\.title),
            ["Show Before", "Show Debug Details", "Parameter JSON"]
        )
        XCTAssertEqual(
            EditorShellView.previewToolbarViewState(
                compareActionTitle: "Show After",
                debugActionTitle: "Hide Debug Details",
                debugAccessibilityValue: "Debug details visible"
            ).map(\.title),
            ["Show After", "Hide Debug Details", "Parameter JSON"]
        )
        XCTAssertEqual(
            EditorShellView.previewToolbarViewState(
                compareActionTitle: "Show Before",
                debugActionTitle: "Show Debug Details",
                debugAccessibilityValue: "Debug details hidden"
            ).first { $0.id == .debug }?.accessibilityValue,
            "Debug details hidden"
        )
    }

    func testDEMO07DebugOverlayEmptyCopyMatchesContract() {
        XCTAssertEqual(
            PreviewDebugOverlayView.emptyStateText,
            "Debug details are unavailable for this preview."
        )
    }

    func testDEMO06ParameterJSONSheetCopyMatchesContract() {
        let importState = ParameterJSONSheetView.viewState(mode: .import, importState: .empty)
        let exportState = ParameterJSONSheetView.viewState(mode: .export, importState: .empty)

        XCTAssertEqual(importState.title, "Parameter JSON")
        XCTAssertEqual(importState.modeTitles, ["Import", "Export"])
        XCTAssertEqual(importState.primaryPrompt, "Paste parameter JSON")
        XCTAssertEqual(importState.previewActionTitle, "Preview Parameter JSON")
        XCTAssertEqual(importState.applyActionTitle, "Apply Imported Parameters")
        XCTAssertEqual(exportState.primaryPrompt, "Copy this deterministic payload for SDK QA or round-trip tests.")
        XCTAssertEqual(exportState.exportActionTitle, "Copy Parameter JSON")
    }

    func testDEMO06InvalidPreviewCopyKeepsCurrentSettingsLanguage() {
        let state = ParameterJSONSheetView.viewState(
            mode: .import,
            importState: .failed(.invalidJSON)
        )

        XCTAssertEqual(
            state.feedbackText,
            "Parameter JSON could not be read. Fix the pasted payload and preview again. Current settings stay unchanged."
        )
        XCTAssertTrue(state.feedbackText?.contains("Current settings stay unchanged.") == true)
    }

    func testDEMO06ApplyIsUnavailableUntilPreviewCandidateExists() {
        XCTAssertFalse(ParameterJSONSheetView.viewState(mode: .import, importState: .empty).canApply)
        XCTAssertFalse(ParameterJSONSheetView.viewState(mode: .import, importState: .failed(.invalidJSON)).canApply)
        XCTAssertTrue(ParameterJSONSheetView.viewState(mode: .import, importState: .preview(BeautyParameters())).canApply)
        XCTAssertFalse(
            ParameterJSONSheetView.viewState(
                mode: .import,
                importState: .preview(BeautyParameters()),
                isPreviewCurrent: false
            ).canApply
        )
    }

    @MainActor
    func testDEMO06ValidSheetCandidateAppliesImportedPathAndClearsPresetSource() throws {
        let store = BeautyParameterStore()
        let preset = try XCTUnwrap(try BeautySDKResources.builtInPresets().first)
        store.applyPreset(preset)
        let exported = try ParameterJSONCoding.export(
            parameters: BeautyParameters(skinSmoothing: 0.42, filterId: "soft_clean", filterIntensity: 0.35)
        )
        let candidate = try XCTUnwrap(ParameterJSONCoding.previewImport(exported).candidate)

        store.applyImportedParameters(candidate)

        XCTAssertNil(store.selectedPresetId)
        XCTAssertEqual(store.parameterSource, .imported)
        XCTAssertEqual(store.selectedFilterId, "soft_clean")
        XCTAssertEqual(store.displayValue(for: .skinSmoothing), 42, accuracy: 0.0001)
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

    func testEFFECT03FilterPanelViewStateShowsMetadataFilters() {
        let state = BeautyPanelView.viewState(
            categoryID: .filters,
            selectedSubcategoryID: .eyes,
            status: .idle
        )

        XCTAssertTrue(state.activeAvailability.isEnabled)
        XCTAssertEqual(state.filterPickerItems.map(\.title), ["None", "Soft Clean", "Warm Light"])
        XCTAssertEqual(state.filterPickerItems.map(\.accessibilityLabel), ["Select No Filter", "Select Soft Clean Filter", "Select Warm Light Filter"])
        XCTAssertEqual(state.controls.map(\.id), [.filterIntensity])
    }

    func testBeautyPanelViewStateCoversDEMO05AndDEMO08ResetSurface() {
        let state = BeautyPanelView.viewState(
            categoryID: .beauty,
            selectedSubcategoryID: .eyes,
            status: .idle
        )

        // DEMO-05 DEMO-08
        XCTAssertTrue(state.showsResetAll)
        XCTAssertNil(state.status.primaryText)
        XCTAssertNil(state.status.secondaryText)
        XCTAssertEqual(state.presetPickerItems.map(\.title), ["Natural", "Clear", "Refined", "Male Natural", "ID Photo Natural"])
        XCTAssertEqual(state.presetPickerItems.map(\.accessibilityLabel), [
            "Apply Natural Preset",
            "Apply Clear Preset",
            "Apply Refined Preset",
            "Apply Male Natural Preset",
            "Apply ID Photo Natural Preset"
        ])
        XCTAssertEqual(
            state.controls.map(\.id),
            [
                .skinSmoothing,
                .skinWhitening,
                .skinRosy,
                .skinSharpen,
                .brightness,
                .contrast,
                .saturation,
                .temperature,
                .tint,
                .exposure,
                .highlight,
                .shadow
            ]
        )
    }

    func testPhase6PanelPathsCoverAllEffectCategoriesWithoutReordering() {
        XCTAssertEqual(
            BeautyCategory.all.map(\.id),
            [.beauty, .faceShape, .facialFeatures, .makeup, .filters, .stickers, .background, .style]
        )
        XCTAssertEqual(
            FacialFeatureSubcategory.all.map(\.id),
            [.eyes, .nose, .mouth, .eyebrows, .teeth, .hairline]
        )

        let beauty = BeautyPanelView.viewState(categoryID: .beauty, selectedSubcategoryID: .eyes, status: .idle)
        XCTAssertEqual(beauty.category.title, "Beauty")
        XCTAssertEqual(beauty.presetPickerItems.map(\.title), ["Natural", "Clear", "Refined", "Male Natural", "ID Photo Natural"])
        XCTAssertEqual(beauty.controls.map(\.id), [
            .skinSmoothing,
            .skinWhitening,
            .skinRosy,
            .skinSharpen,
            .brightness,
            .contrast,
            .saturation,
            .temperature,
            .tint,
            .exposure,
            .highlight,
            .shadow
        ])

        let faceShape = BeautyPanelView.viewState(categoryID: .faceShape, selectedSubcategoryID: .eyes, status: .idle)
        XCTAssertEqual(faceShape.category.title, "Face Shape")
        XCTAssertEqual(faceShape.controls.map(\.id), [.faceSlim, .faceSmall, .faceVShape, .jawSlim, .chinLength])

        let eyes = BeautyPanelView.viewState(categoryID: .facialFeatures, selectedSubcategoryID: .eyes, status: .idle)
        XCTAssertEqual(eyes.subcategories.filter(\.isSelected).map(\.id), [.eyes])
        XCTAssertEqual(eyes.controls.map(\.id), [.eyeSize, .eyeDistance, .eyeYPosition, .eyeTailLift])

        let nose = BeautyPanelView.viewState(categoryID: .facialFeatures, selectedSubcategoryID: .nose, status: .idle)
        XCTAssertEqual(nose.subcategories.filter(\.isSelected).map(\.id), [.nose])
        XCTAssertEqual(nose.controls.map(\.id), [.noseSlim, .noseWingSlim, .noseTipSize, .noseBridge])

        let mouth = BeautyPanelView.viewState(categoryID: .facialFeatures, selectedSubcategoryID: .mouth, status: .idle)
        XCTAssertEqual(mouth.subcategories.filter(\.isSelected).map(\.id), [.mouth])
        XCTAssertEqual(mouth.controls.map(\.id), [.mouthSize, .mouthWidth, .smile, .lipColor])

        let filters = BeautyPanelView.viewState(categoryID: .filters, selectedSubcategoryID: .eyes, status: .idle)
        XCTAssertEqual(filters.category.title, "Filters")
        XCTAssertEqual(filters.filterPickerItems.map(\.title), ["None", "Soft Clean", "Warm Light"])
        XCTAssertEqual(filters.controls.map(\.id), [.filterIntensity])

        XCTAssertTrue([beauty, faceShape, eyes, nose, mouth, filters].allSatisfy(\.activeAvailability.isEnabled))
        XCTAssertTrue([beauty, faceShape, eyes, nose, mouth, filters].allSatisfy(\.showsResetAll))
    }

    func testDEMO07FutureCategoriesStayVisibleDisabledAndUseFinalV1Copy() {
        let disabledCategories = BeautyCategory.all.filter { !$0.availability.isEnabled }

        XCTAssertEqual(BeautyCategory.all.map(\.id), [.beauty, .faceShape, .facialFeatures, .makeup, .filters, .stickers, .background, .style])
        XCTAssertEqual(disabledCategories.map(\.id), [.makeup, .stickers, .background, .style])
        XCTAssertEqual(disabledCategories.map { $0.availability.badge }, Array(repeating: "Not in v1", count: 4))
        XCTAssertEqual(disabledCategories.map { $0.availability.reason }, [
            "Makeup templates are not included in v1.",
            "Sticker effects are not included in v1.",
            "Background editing is not included in v1.",
            "Style templates are not included in v1."
        ])

        for category in disabledCategories {
            let state = BeautyPanelView.viewState(categoryID: category.id, selectedSubcategoryID: .eyes, status: .idle)
            XCTAssertFalse(state.activeAvailability.isEnabled)
            XCTAssertTrue(state.controls.isEmpty)
            XCTAssertTrue(state.disabledControls.isEmpty)
            XCTAssertFalse(state.showsResetAll)
        }
    }

    func testDEMO07FutureSubcategoriesStayVisibleDisabledAndUseFinalV1Copy() {
        let subcategories = FacialFeatureSubcategory.all
        let disabledSubcategories = subcategories.filter { !$0.availability.isEnabled }

        XCTAssertEqual(subcategories.map(\.id), [.eyes, .nose, .mouth, .eyebrows, .teeth, .hairline])
        XCTAssertEqual(disabledSubcategories.map(\.id), [.eyebrows, .teeth, .hairline])
        XCTAssertEqual(disabledSubcategories.map { $0.availability.badge }, Array(repeating: "Not in v1", count: 3))
        XCTAssertEqual(disabledSubcategories.map { $0.availability.reason }, [
            "Eyebrow controls are not included in v1.",
            "Teeth whitening is not included in v1.",
            "Hairline controls are not included in v1."
        ])

        for subcategory in disabledSubcategories {
            let state = BeautyPanelView.viewState(
                categoryID: .facialFeatures,
                selectedSubcategoryID: subcategory.id,
                status: .idle
            )
            XCTAssertFalse(state.activeAvailability.isEnabled)
            XCTAssertTrue(state.controls.isEmpty)
            XCTAssertTrue(state.disabledControls.isEmpty)
            XCTAssertFalse(state.showsResetAll)
        }
    }

    func testEFFECT03MissingResourceCopyIsFriendlyAndRedacted() {
        let state = BeautyResourcePickerFailureState.unavailable

        XCTAssertEqual(state.heading, "No presets or filters available")
        XCTAssertEqual(state.body, "Built-in resources could not be loaded. Current parameters stay unchanged.")
        XCTAssertEqual(state.recovery, "Some resources are unavailable. Choose another preset or filter.")
        XCTAssertEqual(state.missingReason, "This resource is unavailable in this build.")
        XCTAssertFalse([state.heading, state.body, state.recovery, state.missingReason].joined().contains("NSError"))
        XCTAssertFalse([state.heading, state.body, state.recovery, state.missingReason].joined().contains("/"))
        XCTAssertFalse([state.heading, state.body, state.recovery, state.missingReason].joined().contains("BeautyResources"))
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
