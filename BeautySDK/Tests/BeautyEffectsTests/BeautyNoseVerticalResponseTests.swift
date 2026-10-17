import BeautyCore
import Foundation
import XCTest
@testable import BeautyEffects

/// Image-space checks use independent synthetic source features. No field
/// coefficients or sampled offsets participate in the expected directions.
final class BeautyNoseVerticalResponseTests: XCTestCase {
    private let configurations: [(width: Int, height: Int, angle: Double)] = [
        (480, 640, 0), (480, 640, 0.20),
        (640, 480, 0), (640, 480, 0.20)
    ]

    private func localMotion(source: [UInt8], output: [UInt8],
                             width: Int, height: Int, mark: SIMD2<Double>,
                             angle: Double, radius: Int = 20) -> SIMD2<Double> {
        let location = ContinuousNoseTestFixture.point(mark, angle: angle,
            aspect: Double(width) / Double(height))
        let before = ContinuousNoseTestFixture.centroid(source, width: width,
            height: height, around: location, radius: radius)
        let after = ContinuousNoseTestFixture.centroid(output, width: width,
            height: height, around: location, radius: radius)
        let delta = after - before
        // Local +y follows the synthetic nose from the eyes toward the base.
        return SIMD2(delta.x * cos(angle) + delta.y * sin(angle),
                     -delta.x * sin(angle) + delta.y * cos(angle))
    }

    func testTipContractsUpperAndLowerSourceFeaturesInOppositeVerticalDirections() throws {
        // These anatomical source features straddle the bulb; the upper one is
        // below the dorsum and the lower one is above the nasal base.
        let upper = SIMD2(0.5, 0.555), lower = SIMD2(0.5, 0.615)
        for (width, height, angle) in configurations {
            let face = try ContinuousNoseTestFixture.face(angle: angle,
                aspect: Double(width) / Double(height))
            let source = ContinuousNoseTestFixture.raster(width: width, height: height,
                marks: [upper, lower], angle: angle)
            for sign: Float in [-1, 1] {
                var previousUpper = 0.0, previousLower = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    var strengths = BeautyEffectiveStrengths()
                    strengths.noseTipSize = sign * fraction * BeautySafetyCaps.noseTipSize
                    let map = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                        height: height, face: face, strengths: strengths))
                    let output = map.applyRGBA(source)
                    let upperMotion = localMotion(source: source, output: output,
                        width: width, height: height, mark: upper, angle: angle, radius: 12)
                    let lowerMotion = localMotion(source: source, output: output,
                        width: width, height: height, mark: lower, angle: angle, radius: 12)
                    let upperContraction = upperMotion.y * Double(sign)
                    let lowerContraction = -lowerMotion.y * Double(sign)
                    let context = "\(width)x\(height), roll \(angle), sign \(sign), fraction \(fraction)"
                    XCTAssertGreaterThan(upperContraction, previousUpper + 0.025,
                        "the upper bulb moves toward the center: \(context)")
                    XCTAssertGreaterThan(lowerContraction, previousLower + 0.025,
                        "the lower bulb moves toward the center: \(context)")
                    XCTAssertEqual(upperMotion.x, 0, accuracy: 0.20, context)
                    XCTAssertEqual(lowerMotion.x, 0, accuracy: 0.20, context)
                    XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                    previousUpper = upperContraction
                    previousLower = lowerContraction
                }
            }
        }
    }

    func testSizeCarriesBothOuterSkinSidesVerticallyWhileKeepingNasalCoreHeight() throws {
        let left = SIMD2(0.365, 0.53), right = SIMD2(0.635, 0.53)
        let middle = SIMD2(0.5, 0.50), base = SIMD2(0.5, 0.655)
        for (width, height, angle) in configurations {
            let face = try ContinuousNoseTestFixture.face(angle: angle,
                aspect: Double(width) / Double(height))
            let source = ContinuousNoseTestFixture.raster(width: width, height: height,
                marks: [left, right, middle, base], angle: angle)
            for sign: Float in [-1, 1] {
                var previousLeft = 0.0, previousRight = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    var strengths = BeautyEffectiveStrengths()
                    strengths.noseSlim = sign * fraction * BeautySafetyCaps.noseSlim
                    let map = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                        height: height, face: face, strengths: strengths))
                    let output = map.applyRGBA(source)
                    let leftMotion = localMotion(source: source, output: output,
                        width: width, height: height, mark: left, angle: angle)
                    let rightMotion = localMotion(source: source, output: output,
                        width: width, height: height, mark: right, angle: angle)
                    let leftFollow = leftMotion.y * Double(sign)
                    let rightFollow = rightMotion.y * Double(sign)
                    let context = "\(width)x\(height), roll \(angle), sign \(sign), fraction \(fraction)"
                    XCTAssertGreaterThan(leftFollow, previousLeft + 0.025,
                        "the left outer skin follows the signed size change: \(context)")
                    XCTAssertGreaterThan(rightFollow, previousRight + 0.025,
                        "the right outer skin follows in the same vertical direction: \(context)")
                    for mark in [middle, base] {
                        let motion = localMotion(source: source, output: output,
                            width: width, height: height, mark: mark, angle: angle)
                        XCTAssertEqual(motion.y, 0, accuracy: 0.10,
                            "size preserves the nasal core's vertical extent: \(context)")
                    }
                    XCTAssertGreaterThan(leftMotion.x * Double(sign), 0.10, context)
                    XCTAssertLessThan(rightMotion.x * Double(sign), -0.10, context)
                    XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                    previousLeft = leftFollow
                    previousRight = rightFollow
                }
            }
        }
    }
}
