import XCTest
import BeautyCore
@testable import BeautyEffects

final class BeautySafetyCapsTests: XCTestCase {
    func testSAFE01FinalEyebrowDescriptorIsExactlySevenUniqueRows() {
        let rows = EyebrowSafetyFixtures.rows

        XCTAssertEqual(rows.count, 7)
        XCTAssertEqual(Set(rows.map(\.name)).count, 7)
        XCTAssertEqual(Set(rows.map(\.narrowestUnavailableFixture)).count, 4)
        XCTAssertEqual(rows.filter(\.isSigned).count, 6)
        XCTAssertEqual(rows.filter { !$0.isSigned }.map(\.name), ["eyebrowPeakDefinition"])
        XCTAssertEqual(rows.map(\.cap), Array(repeating: 0.25, count: 7))
        XCTAssertEqual(rows.map(\.reusedStrength), Array(repeating: 0.125, count: 7))
        XCTAssertEqual(rows.map(\.maximumRadiusFraction), [0.08, 0.055, 0.07, 0.08, 0.06, 0.075, 0.055])

        for row in rows {
            let parameters = row.makeParameters(row.isSigned ? -0.25 : 0.25)
            XCTAssertEqual(parameters[keyPath: row.publicValue], row.isSigned ? -0.25 : 0.25, row.name)
            XCTAssertEqual(row.strengths(row.cap)[keyPath: row.effectiveValue], row.cap, row.name)
        }
    }

    func testSAFE01EyebrowCapOwnershipIsFinalAndHasNoProvisionalMarker() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = packageRoot.appendingPathComponent("Sources/BeautyEffects/Planning/BeautySafetyCaps.swift")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        XCTAssertTrue(source.contains("Final evidence-backed eyebrow geometry caps (Phase 52)."))
        XCTAssertFalse(source.contains("Provisional Phase 50 eyebrow caps"))
    }

    func testSAFE01FinalContourAndChinCapsAreExactlyPointTwoFive() {
        let values: [(String, Float)] = [
            ("faceContourSmooth", BeautySafetyCaps.faceContourSmooth),
            ("templeFullness", BeautySafetyCaps.templeFullness),
            ("cheekboneSlim", BeautySafetyCaps.cheekboneSlim),
            ("chinTaper", BeautySafetyCaps.chinTaper),
        ]

        XCTAssertEqual(values.count, 4)
        XCTAssertEqual(Set(values.map(\.0)).count, 4)
        for (name, actual) in values {
            XCTAssertEqual(actual, 0.25, accuracy: 0.000_001, name)
        }
    }

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
