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

    func testFilterDescriptorsStayDisabledEvenThoughSDKFieldsExist() {
        XCTAssertEqual(BeautyControlDescriptor.filterControls.map(\.id), [.filterId, .filterIntensity])
        XCTAssertTrue(BeautyControlDescriptor.filterControls.allSatisfy { !$0.availability.isEnabled })
        XCTAssertTrue(BeautyControlDescriptor.filterControls.allSatisfy { $0.availability.badge == "Coming in Phase 5" })
    }

    func testDisabledFilterControlsDoNotMutateSnapshot() {
        let store = BeautyParameterStore()

        store.setDisplayValue(80, for: .filterIntensity)

        XCTAssertEqual(store.displayValue(for: .filterIntensity), 0)
        XCTAssertEqual(store.parametersSnapshot.filterId, nil)
        XCTAssertEqual(store.parametersSnapshot.filterIntensity, 0, accuracy: 0.0001)
    }

    func testSliderUpdateSurfacesAppliedAndPendingVisualStatus() {
        let store = BeautyParameterStore()

        store.setDisplayValue(25, for: .faceSlim)

        XCTAssertEqual(store.status.primaryText, "Parameters applied")
        XCTAssertEqual(store.status.secondaryText, "Visual update pending Phase 6")
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
        store.resetAll()

        XCTAssertTrue(
            BeautyControlDescriptor.availableControls.allSatisfy { store.displayValue(for: $0) == $0.defaultDisplayValue }
        )
        XCTAssertEqual(store.parametersSnapshot, BeautyParameters())
    }

    func testResetCopyIsStableForControlsAndAllParameters() {
        XCTAssertEqual(BeautyControlDescriptor.descriptor(id: .eyeSize).resetLabel, "Reset Eye Size")
        XCTAssertEqual(BeautyControlDescriptor.resetAllTitle, "Reset All Parameters")
    }
}
