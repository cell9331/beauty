import XCTest
@testable import BeautyDemo

final class BeautyCategoryModelTests: XCTestCase {
    func testTopLevelCategoryOrderMatchesPhaseContract() {
        XCTAssertEqual(
            BeautyCategory.all.map(\.title),
            ["Beauty", "Face Shape", "Facial Features", "Makeup", "Filters", "Stickers", "Background", "Style"]
        )
    }

    func testDisabledTopLevelCategoriesCarryBadgeAndReason() {
        let disabledCategories = BeautyCategory.all.filter { !$0.availability.isEnabled }

        XCTAssertEqual(
            disabledCategories.map(\.title),
            ["Makeup", "Filters", "Stickers", "Background", "Style"]
        )
        XCTAssertTrue(disabledCategories.allSatisfy { $0.availability.badge?.isEmpty == false })
        XCTAssertTrue(disabledCategories.allSatisfy { $0.availability.reason?.isEmpty == false })
    }

    func testFiltersStayDisabledForPhaseFive() {
        let filters = BeautyCategory.category(id: .filters)

        XCTAssertFalse(filters.availability.isEnabled)
        XCTAssertEqual(filters.availability.badge, "Coming in Phase 5")
    }

    func testFacialFeatureSubcategoryOrderMatchesPhaseContract() {
        XCTAssertEqual(
            FacialFeatureSubcategory.all.map(\.title),
            ["Eyes", "Nose", "Mouth", "Eyebrows", "Teeth", "Hairline"]
        )
    }

    func testFutureFacialFeatureSubcategoriesAreDisabled() {
        let disabledSubcategories = FacialFeatureSubcategory.all.filter { !$0.availability.isEnabled }

        XCTAssertEqual(
            disabledSubcategories.map(\.title),
            ["Eyebrows", "Teeth", "Hairline"]
        )
        XCTAssertTrue(disabledSubcategories.allSatisfy { $0.availability.badge == "Requires future resource support" })
    }
}
