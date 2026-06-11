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

    func testFirstScreenFixtureCopyCoversDEMO08ShellState() {
        // DEMO-08
        XCTAssertEqual(DemoFixtures.previewTitle, "Preview fixture ready")
        XCTAssertEqual(DemoFixtures.disabledModes.map(\.title), ["Camera", "Photo"])
        XCTAssertEqual(DemoFixtures.disabledModes.map(\.badge), ["Coming in Phase 3", "Coming in Phase 3"])
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
}
