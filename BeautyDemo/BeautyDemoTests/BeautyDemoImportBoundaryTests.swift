import XCTest
@testable import BeautyDemo

final class BeautyDemoImportBoundaryTests: XCTestCase {
    func testDemoTestTargetCanLoadEditorShellState() {
        let modeItems = DemoFixtures.inputModeItems(selectedMode: nil)

        XCTAssertEqual(DemoFixtures.activeCategoryTitle, "Beauty")
        XCTAssertEqual(modeItems.map(\.title), ["Camera", "Photo"])
        XCTAssertTrue(modeItems.allSatisfy(\.isEnabled))
    }
}
