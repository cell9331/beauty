import CoreGraphics
import Foundation
import ImageIO
import XCTest

final class BeautyReviewedMaskValidationTests: XCTestCase {
    func testExactZeroOriginUpOrUnspecifiedMaskGeometryPasses() {
        let extent = CGRect(x: 0, y: 0, width: 64, height: 40)
        XCTAssertNoThrow(try BeautyReviewedMaskValidation.validate(
            extent: extent,
            orientationProperty: nil,
            width: 64,
            height: 40
        ))
        XCTAssertNoThrow(try BeautyReviewedMaskValidation.validate(
            extent: extent,
            orientationProperty: NSNumber(value: CGImagePropertyOrientation.up.rawValue),
            width: 64,
            height: 40
        ))
    }

    func testWrongSizeTranslatedNonFiniteAndOrientedMasksFailBeforeMeasurement() {
        let invalidCases: [(CGRect, Any?)] = [
            (CGRect(x: 0, y: 0, width: 63, height: 40), nil),
            (CGRect(x: 1, y: 0, width: 64, height: 40), nil),
            (CGRect(x: 0, y: 0, width: CGFloat.nan, height: 40), nil),
            (
                CGRect(x: 0, y: 0, width: 64, height: 40),
                NSNumber(value: CGImagePropertyOrientation.right.rawValue)
            ),
        ]

        for (extent, orientation) in invalidCases {
            XCTAssertThrowsError(try BeautyReviewedMaskValidation.validate(
                extent: extent,
                orientationProperty: orientation,
                width: 64,
                height: 40
            ))
        }
    }
}
