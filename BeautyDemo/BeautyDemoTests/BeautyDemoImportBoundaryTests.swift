import XCTest
@testable import BeautyDemo

final class BeautyDemoImportBoundaryTests: XCTestCase {
    func testDemoTestTargetCanLoadEditorShellState() {
        XCTAssertEqual(DemoFixtures.activeCategoryTitle, "Beauty")
        XCTAssertEqual(
            DemoFixtures.disabledModes.map(\.badge),
            ["Coming in Phase 3", "Coming in Phase 3"]
        )
    }
}
