import BeautySDK
import XCTest
@testable import BeautyDemo

@MainActor
final class BeautyParameterStoreTests: XCTestCase {
    func testEnhancementDisplayValueNormalizesIntoSDKSnapshot() {
        let store = BeautyParameterStore()

        store.setDisplayValue(75, for: .skinSmoothing)

        XCTAssertEqual(store.displayValue(for: .skinSmoothing), 75)
        XCTAssertEqual(store.parametersSnapshot.skinSmoothing, 0.75, accuracy: 0.0001)
    }

    func testBidirectionalDisplayValueNormalizesIntoSDKSnapshot() {
        let store = BeautyParameterStore()

        store.setDisplayValue(-40, for: .chinLength)

        XCTAssertEqual(store.displayValue(for: .chinLength), -40)
        XCTAssertEqual(store.parametersSnapshot.chinLength, -0.40, accuracy: 0.0001)
    }

    func testOutOfRangeDisplayValuesClampBeforeSnapshotConstruction() {
        let store = BeautyParameterStore()

        store.setDisplayValue(140, for: .skinWhitening)
        store.setDisplayValue(-140, for: .eyeSize)

        XCTAssertEqual(store.displayValue(for: .skinWhitening), 100)
        XCTAssertEqual(store.parametersSnapshot.skinWhitening, 1, accuracy: 0.0001)
        XCTAssertEqual(store.displayValue(for: .eyeSize), -100)
        XCTAssertEqual(store.parametersSnapshot.eyeSize, -1, accuracy: 0.0001)
    }

    func testEFFECT02BeautyControlsAppendColorControls() {
        XCTAssertEqual(
            BeautyControlDescriptor.controls(for: .beauty).map(\.label),
            [
                "Skin Smoothing",
                "Skin Whitening",
                "Rosy Tone",
                "Skin Sharpen",
                "Brightness",
                "Contrast",
                "Saturation",
                "Temperature",
                "Tint",
                "Exposure",
                "Highlight",
                "Shadow"
            ]
        )
        XCTAssertTrue(
            BeautyControlDescriptor.controls(for: .beauty)
                .suffix(8)
                .allSatisfy { $0.displayRange == .bidirectional }
        )
    }

    func testEFFECT03FilterIdIsCategoricalAndIntensityIsSlider() {
        XCTAssertEqual(BeautyControlDescriptor.filterControls.map(\.id), [.filterIntensity])
        XCTAssertFalse(BeautyControlDescriptor.filterControls.map(\.id).contains(.filterId))
        XCTAssertEqual(BeautyControlDescriptor.filterControls.first?.label, "Filter Intensity")
        XCTAssertEqual(BeautyControlDescriptor.filterControls.first?.displayRange, .enhancement)
    }

    func testEFFECT02ColorDisplayValuesNormalizeIntoSDKSnapshot() {
        let store = BeautyParameterStore()

        store.setDisplayValue(-25, for: .brightness)
        store.setDisplayValue(40, for: .exposure)

        XCTAssertEqual(store.parametersSnapshot.brightness, -0.25, accuracy: 0.0001)
        XCTAssertEqual(store.parametersSnapshot.exposure, 0.40, accuracy: 0.0001)
    }

    func testEFFECT03FilterSelectionUpdatesSnapshot() {
        let store = BeautyParameterStore()

        store.selectFilter(id: "soft_clean")
        store.setDisplayValue(35, for: .filterIntensity)

        XCTAssertEqual(store.selectedFilterId, "soft_clean")
        XCTAssertEqual(store.parametersSnapshot.filterId, "soft_clean")
        XCTAssertEqual(store.parametersSnapshot.filterIntensity, 0.35, accuracy: 0.0001)
    }

    func testNormalParameterChangesStayQuietAfterPhase6VisualEffects() {
        let store = BeautyParameterStore()

        store.setDisplayValue(25, for: .faceSlim)

        XCTAssertEqual(store.status, .idle)
    }

    func testSingleControlResetLeavesUnrelatedDisplayValuesUnchanged() {
        let store = BeautyParameterStore()

        store.setDisplayValue(80, for: .skinSmoothing)
        store.setDisplayValue(30, for: .faceSlim)
        store.reset(.skinSmoothing)

        XCTAssertEqual(store.displayValue(for: .skinSmoothing), 0)
        XCTAssertEqual(store.parametersSnapshot.skinSmoothing, 0, accuracy: 0.0001)
        XCTAssertEqual(store.displayValue(for: .faceSlim), 30)
        XCTAssertEqual(store.parametersSnapshot.faceSlim, 0.30, accuracy: 0.0001)
    }

    func testResetAllRestoresNumericDisplayValuesAndSDKSnapshotDefaults() {
        let store = BeautyParameterStore()

        store.setDisplayValue(90, for: .skinSmoothing)
        store.setDisplayValue(40, for: .noseSlim)
        store.setDisplayValue(-25, for: .mouthSize)
        store.selectFilter(id: "warm_light")
        store.setDisplayValue(45, for: .filterIntensity)
        store.resetAll()

        XCTAssertTrue(
            BeautyControlDescriptor.availableControls.allSatisfy { store.displayValue(for: $0) == $0.defaultDisplayValue }
        )
        XCTAssertNil(store.selectedFilterId)
        XCTAssertEqual(store.parametersSnapshot, BeautyParameters())
    }

    func testEFFECT08ApplyingBuiltInPresetsSyncsDisplayValuesAndFilterState() throws {
        let presets = try BeautySDKResources.builtInPresets()
        let store = BeautyParameterStore()

        for preset in presets {
            store.setDisplayValue(99, for: .skinSmoothing)
            store.selectFilter(id: "warm_light")
            store.applyPreset(preset)

            XCTAssertEqual(store.selectedFilterId, preset.parameters.filterId, preset.displayName)
            XCTAssertEqual(store.displayValue(for: .skinSmoothing), Double(preset.parameters.skinSmoothing) * 100, accuracy: 0.0001)
            XCTAssertEqual(store.displayValue(for: .brightness), Double(preset.parameters.brightness) * 100, accuracy: 0.0001)
            XCTAssertEqual(store.displayValue(for: .exposure), Double(preset.parameters.exposure) * 100, accuracy: 0.0001)
            XCTAssertEqual(store.displayValue(for: .filterIntensity), Double(preset.parameters.filterIntensity) * 100, accuracy: 0.0001)
            XCTAssertEqual(store.parametersSnapshot, preset.parameters, preset.displayName)
        }
    }

    func testResetCopyIsStableForControlsAndAllParameters() {
        XCTAssertEqual(BeautyControlDescriptor.descriptor(id: .eyeSize).resetLabel, "Reset Eye Size")
        XCTAssertEqual(BeautyControlDescriptor.resetAllTitle, "Reset All Parameters")
    }
}
