import CoreGraphics
import Foundation
import ImageIO
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class BeautyScleraRednessProviderTests: XCTestCase {
    private let width = 80
    private let height = 48

    func testCanonicalMappedPairProducesStablePerEyeUnitsInsideSafeSclera() throws {
        let fixture = makeEyeFixture()
        let source = try canonical(fixture.bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)

        let result = BeautyScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [rightSupport, leftSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )
        let composed = try owner.compose(result.units)
        let changed = changedPixelIndices(
            before: fixture.bytes,
            after: Array(composed.canonicalImage.rgba8Data)
        )

        XCTAssertEqual(result.units.count, 2)
        XCTAssertEqual(result.summary.acceptedEyeCount, 2)
        XCTAssertEqual(result.summary.leftOutcome, .accepted)
        XCTAssertEqual(result.summary.rightOutcome, .accepted)
        XCTAssertGreaterThan(result.summary.proposalPixelCount, 0)
        XCTAssertFalse(changed.isEmpty)
        XCTAssertTrue(changed.isSubset(of: fixture.safeSclera))
        XCTAssertTrue(changed.isDisjoint(with: fixture.protectedPixels))
        XCTAssertEqual(composed.summary.changedOutsideUnionPixelCount, 0)
    }

    func testMissingOrMalformedPeerAbstainsOnlyThatEye() throws {
        let source = try canonical(makeEyeFixture().bytes)
        let malformedRight = BeautyObservedEyeSupport(
            side: .right,
            contour: rectangle(minX: 0.58, minY: 0.36, maxX: 0.90, maxY: 0.64),
            pupil: nil
        )

        for support in [[leftSupport], [leftSupport, malformedRight]] {
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: support,
                eyeOrder: .canonical,
                strength: 1,
                owner: owner
            )
            XCTAssertEqual(result.units.count, 1)
            XCTAssertEqual(result.summary.leftOutcome, .accepted)
            XCTAssertNotEqual(result.summary.rightOutcome, .accepted)
        }
    }

    func testInvalidOrderAndDuplicateSidesRejectAllScleraWork() throws {
        let source = try canonical(makeEyeFixture().bytes)
        for (support, order) in [
            ([leftSupport, rightSupport], BeautyObservedEyeOrder.invalid),
            ([leftSupport, leftSupport], BeautyObservedEyeOrder.canonical),
        ] {
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: support,
                eyeOrder: order,
                strength: 1,
                owner: owner
            )
            XCTAssertTrue(result.units.isEmpty)
            XCTAssertEqual(result.summary.acceptedEyeCount, 0)
        }
    }

    func testPupilMustBeExactlyOneFiniteContainedPlausibleSample() throws {
        let invalidPupils: [[CoordinatePoint]?] = [
            nil,
            [],
            [CoordinatePoint(x: .nan, y: 0.5)],
            [CoordinatePoint(x: 0.05, y: 0.5)],
            [CoordinatePoint(x: 0.26, y: 0.5), CoordinatePoint(x: 0.27, y: 0.5)],
        ]
        let source = try canonical(makeEyeFixture().bytes)
        for pupil in invalidPupils {
            let support = BeautyObservedEyeSupport(
                side: .left,
                contour: leftSupport.contour,
                pupil: pupil
            )
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: [support, rightSupport],
                eyeOrder: .canonical,
                strength: 1,
                owner: owner
            )
            XCTAssertEqual(result.units.count, 1)
            XCTAssertNotEqual(result.summary.leftOutcome, .accepted)
            XCTAssertEqual(result.summary.rightOutcome, .accepted)
        }
    }

    func testNonFiniteOutsideDuplicateSelfIntersectingAndCollapsedContoursAbstainLocally() throws {
        let invalidContours: [[CoordinatePoint]] = [
            rectangle(minX: -0.01, minY: 0.36, maxX: 0.42, maxY: 0.64),
            [
                CoordinatePoint(x: 0.10, y: 0.36),
                CoordinatePoint(x: .infinity, y: 0.36),
                CoordinatePoint(x: 0.42, y: 0.64),
                CoordinatePoint(x: 0.10, y: 0.64),
            ],
            Array(repeating: CoordinatePoint(x: 0.25, y: 0.5), count: 4),
            [
                CoordinatePoint(x: 0.10, y: 0.36),
                CoordinatePoint(x: 0.42, y: 0.64),
                CoordinatePoint(x: 0.42, y: 0.36),
                CoordinatePoint(x: 0.10, y: 0.64),
            ],
            rectangle(minX: 0.10, minY: 0.495, maxX: 0.42, maxY: 0.505),
        ]
        let source = try canonical(makeEyeFixture().bytes)
        for contour in invalidContours {
            let malformed = BeautyObservedEyeSupport(
                side: .left,
                contour: contour,
                pupil: [CoordinatePoint(x: 0.26, y: 0.5)]
            )
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: [malformed, rightSupport],
                eyeOrder: .canonical,
                strength: 1,
                owner: owner
            )
            XCTAssertEqual(result.units.count, 1)
            XCTAssertEqual(result.summary.rightOutcome, .accepted)
        }
    }

    func testHardEnvelopeExcludesPupilHighlightsLashMarginSkinAndExteriorAfterFeather() throws {
        let fixture = makeEyeFixture()
        let source = try canonical(fixture.bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let result = BeautyScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [leftSupport, rightSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )
        let composed = try owner.compose(result.units)
        let after = Array(composed.canonicalImage.rgba8Data)

        for pixel in fixture.protectedPixels {
            XCTAssertEqual(rgb(after, at: pixel), rgb(fixture.bytes, at: pixel))
        }
        XCTAssertEqual(result.summary.protectedProposalPixelCount, 0)
        XCTAssertGreaterThan(composed.summary.changedPixelCount, 0)
    }

    func testLowRednessAndEmptyProtectedEnvelopeAreExactLocalNoOps() throws {
        for fixture in [makeEyeFixture(redness: false), makeEyeFixture(allProtected: true)] {
            let source = try canonical(fixture.bytes)
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: [leftSupport, rightSupport],
                eyeOrder: .canonical,
                strength: 1,
                owner: owner
            )
            XCTAssertTrue(result.units.isEmpty)
            XCTAssertEqual(try owner.compose(result.units).canonicalImage.rgba8Data, source.rgba8Data)
        }
    }

    func testTransformReducesOnlyMeasuredRedExcessWithinChannelAndLuminanceBounds() throws {
        let source = (red: UInt8(210), green: UInt8(150), blue: UInt8(150))
        let target = try XCTUnwrap(BeautyScleraRednessTransform.target(
            red: source.red,
            green: source.green,
            blue: source.blue,
            strength: 1
        ))

        XCTAssertLessThan(redExcess(target.red, target.green, target.blue), redExcess(source.red, source.green, source.blue))
        XCTAssertLessThanOrEqual(abs(Int(target.red) - Int(source.red)), 40)
        XCTAssertLessThanOrEqual(abs(Int(target.green) - Int(source.green)), 40)
        XCTAssertLessThanOrEqual(abs(Int(target.blue) - Int(source.blue)), 40)
        XCTAssertLessThanOrEqual(abs(luminance(target.red, target.green, target.blue) - luminance(source.red, source.green, source.blue)), 0.02)
    }

    func testTransformIsDeterministicMonotonicSourceOnlyAndNeutralNoOp() throws {
        for pixel: (UInt8, UInt8, UInt8) in [
            (220, 220, 220),
            (190, 188, 191),
            (120, 130, 140),
        ] {
            XCTAssertNil(BeautyScleraRednessTransform.target(
                red: pixel.0,
                green: pixel.1,
                blue: pixel.2,
                strength: 1
            ))
        }
        let low = try XCTUnwrap(BeautyScleraRednessTransform.target(red: 210, green: 150, blue: 150, strength: 0.35))
        let high = try XCTUnwrap(BeautyScleraRednessTransform.target(red: 210, green: 150, blue: 150, strength: 1))
        let repeated = try XCTUnwrap(BeautyScleraRednessTransform.target(red: 210, green: 150, blue: 150, strength: 1))
        XCTAssertEqual(high, repeated)
        XCTAssertGreaterThanOrEqual(redExcess(low.red, low.green, low.blue), redExcess(high.red, high.green, high.blue))
    }

    func testZeroNegativeAndNonFiniteStrengthEmitNoUnits() throws {
        let source = try canonical(makeEyeFixture().bytes)
        for strength in [Float.zero, -1, .nan, .infinity] {
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: [leftSupport, rightSupport],
                eyeOrder: .canonical,
                strength: strength,
                owner: owner
            )
            XCTAssertTrue(result.units.isEmpty)
        }
    }

    func testPerEyeUnitOverlapPreservesImmutableSourceAndAlpha() throws {
        let fixture = makeEyeFixture()
        let source = try canonical(fixture.bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let first = BeautyScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [leftSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )
        let second = BeautyScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [leftSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )
        XCTAssertEqual(first.units.count, 1)
        XCTAssertEqual(second.units.count, 1)

        let composed = try owner.compose(first.units + second.units)
        let output = Array(composed.canonicalImage.rgba8Data)
        XCTAssertGreaterThan(composed.summary.collisionPixelCount, 0)
        XCTAssertEqual(output, fixture.bytes)
        XCTAssertEqual(
            stride(from: 3, to: output.count, by: 4).map { output[$0] },
            Array(repeating: UInt8.max, count: width * height)
        )
    }

    private var leftSupport: BeautyObservedEyeSupport {
        BeautyObservedEyeSupport(
            side: .left,
            contour: eyeContour(centerX: 0.2625),
            pupil: [CoordinatePoint(x: 0.26, y: 0.50)]
        )
    }

    private var rightSupport: BeautyObservedEyeSupport {
        BeautyObservedEyeSupport(
            side: .right,
            contour: eyeContour(centerX: 0.7375),
            pupil: [CoordinatePoint(x: 0.74, y: 0.50)]
        )
    }

    private func eyeContour(centerX: Double) -> [CoordinatePoint] {
        (0..<16).map { index in
            let angle = Double(index) * 2 * .pi / 16
            return CoordinatePoint(
                x: centerX + 0.1625 * cos(angle),
                y: 0.50 + 0.0833 * sin(angle)
            )
        }
    }

    private struct EyeFixture {
        let bytes: [UInt8]
        let safeSclera: Set<Int>
        let protectedPixels: Set<Int>
    }

    private func makeEyeFixture(redness: Bool = true, allProtected: Bool = false) -> EyeFixture {
        var bytes = uniform(red: 164, green: 118, blue: 105)
        var safe = Set<Int>()
        var protected = Set<Int>()
        let red: (UInt8, UInt8, UInt8) = redness ? (210, 150, 150) : (205, 201, 202)
        for centerX in [21, 59] {
            for y in 17...30 {
                for x in (centerX - 13)...(centerX + 13) {
                    let index = pixelIndex(x: x, y: y)
                    let dx = Double(x - centerX) / 13
                    let dy = Double(y - 24) / 7
                    guard dx * dx + dy * dy <= 1 else { continue }
                    let pupilDistance = hypot(Double(x - centerX), Double(y - 24))
                    let isMargin = x <= centerX - 11 || x >= centerX + 11 || y <= 18 || y >= 29
                    let isPupil = pupilDistance <= 5.2
                    let isHighlight = (x == centerX - 2 || x == centerX - 1) && (y == 21 || y == 22)
                    if allProtected || isMargin || isPupil || isHighlight {
                        let color: (UInt8, UInt8, UInt8)
                        if allProtected || isHighlight { color = (248, 248, 248) }
                        else if isPupil { color = (55, 64, 72) }
                        else { color = (38, 28, 30) }
                        bytes = replacingRGB(in: bytes, index: index, with: color)
                        protected.insert(index)
                    } else {
                        bytes = replacingRGB(in: bytes, index: index, with: red)
                        safe.insert(index)
                    }
                }
            }
        }
        for y in [16, 31] {
            for x in 5...74 { protected.insert(pixelIndex(x: x, y: y)) }
        }
        return EyeFixture(bytes: bytes, safeSclera: safe, protectedPixels: protected)
    }

    private func rectangle(minX: Double, minY: Double, maxX: Double, maxY: Double) -> [CoordinatePoint] {
        [
            CoordinatePoint(x: minX, y: minY),
            CoordinatePoint(x: maxX, y: minY),
            CoordinatePoint(x: maxX, y: maxY),
            CoordinatePoint(x: minX, y: maxY),
        ]
    }

    private func uniform(red: UInt8, green: UInt8, blue: UInt8) -> [UInt8] {
        Array(repeating: [red, green, blue, UInt8.max], count: width * height).flatMap { $0 }
    }

    private func canonical(_ bytes: [UInt8]) throws -> BeautyCanonicalStillImage {
        try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes),
            width: width,
            height: height,
            rowBytes: width * 4,
            metadata: BeautyInputMetadata(
                orientation: .up,
                isInputMirrored: false,
                isPreviewMirrored: false,
                source: .photo
            )
        )
    }

    private func pixelIndex(x: Int, y: Int) -> Int { y * width + x }

    private func replacingRGB(in bytes: [UInt8], index: Int, with color: (UInt8, UInt8, UInt8)) -> [UInt8] {
        var result = bytes
        let offset = index * 4
        result[offset] = color.0
        result[offset + 1] = color.1
        result[offset + 2] = color.2
        return result
    }

    private func rgb(_ bytes: [UInt8], at index: Int) -> [UInt8] {
        let offset = index * 4
        return Array(bytes[offset..<(offset + 3)])
    }

    private func changedPixelIndices(before: [UInt8], after: [UInt8]) -> Set<Int> {
        Set((0..<(before.count / 4)).filter { rgb(before, at: $0) != rgb(after, at: $0) })
    }

    private func redExcess(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Double {
        max(0, Double(red) / 255 - max(Double(green), Double(blue)) / 255)
    }

    private func luminance(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Double {
        0.2126 * Double(red) / 255 + 0.7152 * Double(green) / 255 + 0.0722 * Double(blue) / 255
    }
}
