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
}
