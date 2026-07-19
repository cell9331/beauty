import XCTest
import BeautyCore
@testable import BeautyEffects

final class BeautySafetyCapsTests: XCTestCase {
    func testEYE19FinalRemainingEyeCapsMatchExactContract() {
        let values: [(String, Float, Float)] = [
            ("eyeHeight", BeautySafetyCaps.eyeHeight, 0.35),
            ("eyeLength", BeautySafetyCaps.eyeLength, 0.35),
            ("upperEyelidLift", BeautySafetyCaps.upperEyelidLift, 0.30),
            ("pupilSize", BeautySafetyCaps.pupilSize, 0.25),
            ("gazeCorrection", BeautySafetyCaps.gazeCorrection, 0.25),
            ("lowerEyelidDrop", BeautySafetyCaps.lowerEyelidDrop, 0.30),
            ("eyeTilt", BeautySafetyCaps.eyeTilt, 0.25),
            ("innerCornerOpen", BeautySafetyCaps.innerCornerOpen, 0.25),
            ("outerCornerOpen", BeautySafetyCaps.outerCornerOpen, 0.25),
            ("eyeSymmetry", BeautySafetyCaps.eyeSymmetry, 0.25),
        ]

        XCTAssertEqual(values.count, 10)
        for (name, actual, expected) in values {
            XCTAssertEqual(actual, expected, accuracy: 0.000_001, name)
        }
    }

    func testMOUTH12FinalMouthGeometryCapsAreExactlyPointTwoFive() {
        XCTAssertEqual(BeautySafetyCaps.mouthYPosition, 0.25)
        XCTAssertEqual(BeautySafetyCaps.mouthTilt, 0.25)
        XCTAssertEqual(BeautySafetyCaps.mouthXPosition, 0.25)
        XCTAssertEqual(BeautySafetyCaps.lipPeakDefinition, 0.25)
        XCTAssertEqual(BeautySafetyCaps.lipPlump, 0.25)
    }

    func testNOSE10FinalRemainingNoseCapsAreExactlyPointTwoFive() {
        XCTAssertEqual(BeautySafetyCaps.noseRootNarrowing, 0.25)
        XCTAssertEqual(BeautySafetyCaps.noseTipLift, 0.25)
    }

    func testPhase6SafetyCapsMatchCanonicalConstants() {
        XCTAssertEqual(BeautySafetyCaps.skinSmoothing, 0.60, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.skinWhitening, 0.50, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.skinRosy, 0.40, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.skinSharpen, 0.40, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.filterIntensity, 1.0, accuracy: 0.0001)

        XCTAssertEqual(BeautySafetyCaps.faceSlim, 0.60, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.faceSmall, 0.45, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.faceVShape, 0.50, accuracy: 0.0001)
        XCTAssertLessThanOrEqual(BeautySafetyCaps.jawSlim, BeautySafetyCaps.faceSlim)
        XCTAssertEqual(BeautySafetyCaps.jawSlim, 0.45, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.chinLength, 0.35, accuracy: 0.0001)

        XCTAssertEqual(BeautySafetyCaps.eyeSize, 0.45, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.eyeDistance, 0.30, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.eyeYPosition, 0.25, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.eyeTailLift, 0.30, accuracy: 0.0001)

        XCTAssertEqual(BeautySafetyCaps.noseSlim, 0.35, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.noseWingSlim, 0.35, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.noseTipSize, 0.30, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.noseBridge, 0.30, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.noseRootNarrowing, 0.25, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.noseTipLift, 0.25, accuracy: 0.0001)

        XCTAssertEqual(BeautySafetyCaps.mouthSize, 0.35, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.mouthWidth, 0.35, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.smile, 0.50, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.lipColor, 0.50, accuracy: 0.0001)
    }
}
