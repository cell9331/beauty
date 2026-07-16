import XCTest
import BeautyDetection
@testable import BeautyEffects

final class BeautyFaceGeometryAdapterTests: XCTestCase {
    private let bounds = CoordinateRect(x: 0.10, y: 0.10, width: 0.80, height: 0.80)

    func testObservedContoursCanonicalizeAcrossWindingAndRetainSideIdentity() {
        let left = contour(x: 0.30, y: 0.40)
        let right = contour(x: 0.58, y: 0.40)
        let forward = observation(left: left, right: right)
        let reversed = observation(left: Array(left.reversed()), right: Array(right.reversed()))

        let first = BeautyFaceGeometryAdapter.makeGeometry(from: forward)
        let second = BeautyFaceGeometryAdapter.makeGeometry(from: reversed)

        XCTAssertEqual(first.leftEyeSupport, second.leftEyeSupport)
        XCTAssertEqual(first.rightEyeSupport, second.rightEyeSupport)
        XCTAssertEqual(first.leftEyeSupport?.side, .left)
        XCTAssertEqual(first.rightEyeSupport?.side, .right)
        XCTAssertEqual(first.leftEyeSupport?.contourEligible, true)
        XCTAssertEqual(first.rightEyeSupport?.contourEligible, true)
        XCTAssertEqual(first.leftEyeSupport?.upper, first.leftEyeSupport?.upper.sorted(by: pointOrder))
    }

    func testInvalidContoursFailClosedWithoutProxyFallback() {
        let malformed: [[CoordinatePoint]] = [
            [],
            Array(repeating: CoordinatePoint(x: 0.4, y: 0.4), count: 6),
            contour(x: 0.30, y: 0.40).map { CoordinatePoint(x: $0.x, y: .infinity) },
            contour(x: 0.30, y: 0.40).map { CoordinatePoint(x: 1.2, y: $0.y) },
            Array(contour(x: 0.30, y: 0.40).prefix(5)),
            contour(x: 0.30, y: 0.40) + [CoordinatePoint(x: 0.31, y: 0.41)] + Array(repeating: CoordinatePoint(x: 0.31, y: 0.41), count: 10)
        ]

        for contour in malformed {
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: observation(left: contour, right: self.contour(x: 0.58, y: 0.40))
            )
            XCTAssertTrue(geometry.leftEye.isEmpty)
            XCTAssertNil(geometry.leftEyeSupport)
            XCTAssertFalse(geometry.rightEye.isEmpty)
        }
    }

    func testInvalidPupilPreservesContourSupportAndDoesNotSynthesizePupil() {
        let left = BeautyObservedEyeSupport(
            side: .left,
            contour: contour(x: 0.30, y: 0.40),
            pupil: [CoordinatePoint(x: 0.10, y: 0.10)]
        )
        let right = BeautyObservedEyeSupport(
            side: .right,
            contour: contour(x: 0.58, y: 0.40),
            pupil: [CoordinatePoint(x: 0.62, y: 0.44)]
        )
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(imageBounds: bounds, landmarks: .complete, observedEyeSupport: [left, right])
        )

        XCTAssertTrue(geometry.leftEyeSupport?.contourEligible == true)
        XCTAssertFalse(geometry.leftEyeSupport?.pupilEligible == true)
        XCTAssertTrue(geometry.rightEyeSupport?.contourEligible == true)
        XCTAssertTrue(geometry.rightEyeSupport?.pupilEligible == true)
    }

    func testNilObservedSupportKeepsLegacyProxyOnlyForCompatibility() {
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(imageBounds: bounds, landmarks: .complete)
        )
        XCTAssertFalse(geometry.leftEye.isEmpty)
        XCTAssertFalse(geometry.rightEye.isEmpty)
        XCTAssertNil(geometry.leftEyeSupport)
        XCTAssertNil(geometry.rightEyeSupport)
    }

    private func observation(left: [CoordinatePoint], right: [CoordinatePoint]) -> BeautyFaceObservation {
        BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyeSupport: [
                BeautyObservedEyeSupport(side: .left, contour: left),
                BeautyObservedEyeSupport(side: .right, contour: right)
            ]
        )
    }

    private func contour(x: Double, y: Double) -> [CoordinatePoint] {
        [
            CoordinatePoint(x: x, y: y + 0.03),
            CoordinatePoint(x: x + 0.04, y: y),
            CoordinatePoint(x: x + 0.12, y: y),
            CoordinatePoint(x: x + 0.16, y: y + 0.03),
            CoordinatePoint(x: x + 0.12, y: y + 0.08),
            CoordinatePoint(x: x + 0.04, y: y + 0.08),
        ]
    }

    private func pointOrder(_ lhs: SIMD2<Float>, _ rhs: SIMD2<Float>) -> Bool {
        lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
    }
}
