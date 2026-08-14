import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

/// Generated, request-local safety oracles for the CPU local-retouch owners.
///
/// These tests intentionally keep all source bytes, support, proposals, and
/// protected indices transient. They exercise the same providers and
/// composition owner used by the SDK; they are not visual fixture baselines.
final class CPUReferenceLocalRetouchOracleTests: XCTestCase {
    private let mouthWidth = 64
    private let mouthHeight = 40
    private let eyeWidth = 320
    private let eyeHeight = 200

    func testGeneratedTeethOracleReducesYellowExcessInsideInnerEnvelope() throws {
        let fixture = makeMouthFixture()
        let source = try canonical(fixture.bytes, width: mouthWidth, height: mouthHeight)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let result = try XCTUnwrap(BeautyTeethWhiteningProvider.makeResult(
            source: source,
            lipSupport: validLipSupport,
            strength: 1,
            owner: owner
        ))
        let output = Array(try owner.compose([result.unit]).canonicalImage.rgba8Data)
        let changed = changedIndices(before: fixture.bytes, after: output)

        XCTAssertFalse(changed.isEmpty)
        XCTAssertTrue(changed.isSubset(of: fixture.enamel))
        XCTAssertTrue(changed.isDisjoint(with: fixture.protected))
        XCTAssertEqual(alphaBytes(output), alphaBytes(fixture.bytes))
        XCTAssertEqual(CPUReferenceMetrics.regionIntersection(changed, fixture.outside), [])
        XCTAssertEqual(result.summary.droppedFixedStrongPixelCount, 0)
        XCTAssertGreaterThanOrEqual(
            result.summary.finalStrongPixelCount,
            result.summary.fixedStrongPixelCount
        )
        XCTAssertLessThan(
            meanYellowExcess(output, indices: changed),
            meanYellowExcess(fixture.bytes, indices: changed)
        )
        XCTAssertLessThanOrEqual(maximumRGBDelta(fixture.bytes, output, indices: changed), 72)
    }

    func testGeneratedTeethNegativeAndMalformedSupportAbstainExactly() throws {
        let sourceBytes = makeMouthFixture().bytes
        let source = try canonical(sourceBytes, width: mouthWidth, height: mouthHeight)
        let negativeBytes = uniformBytes(red: 225, green: 225, blue: 225, width: mouthWidth, height: mouthHeight)
        let negative = try canonical(negativeBytes, width: mouthWidth, height: mouthHeight)

        for candidate in [source, negative] {
            let owner = BeautyLocalRetouchCompositionOwner(source: candidate)
            let support = candidate.rgba8Data == source.rgba8Data ? malformedLipSupport : validLipSupport
            XCTAssertNil(BeautyTeethWhiteningProvider.makeResult(
                source: candidate,
                lipSupport: support,
                strength: 1,
                owner: owner
            ))
            let composed = try owner.compose([])
            XCTAssertEqual(composed.canonicalImage.rgba8Data, candidate.rgba8Data)
            XCTAssertEqual(composed.summary, BeautyLocalRetouchCompositionSummary())
        }
    }

    func testGeneratedScleraOracleReducesRedExcessAndProtectsAnatomy() throws {
        let fixture = makeEyeFixture(includeVessels: true)
        let source = try canonical(fixture.bytes, width: eyeWidth, height: eyeHeight)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let result = BeautyFullScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [eyeSupport(side: .left, center: (90, 100)), eyeSupport(side: .right, center: (230, 100))],
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )
        let output = Array(try owner.compose(result.units).canonicalImage.rgba8Data)
        let changed = changedIndices(before: fixture.bytes, after: output)

        XCTAssertEqual(result.summary.acceptedEyeCount, 2)
        XCTAssertFalse(changed.isEmpty)
        XCTAssertTrue(changed.isDisjoint(with: fixture.protected))
        XCTAssertTrue(changed.isDisjoint(with: fixture.caruncle))
        XCTAssertEqual(alphaBytes(output), alphaBytes(fixture.bytes))
        XCTAssertLessThan(
            meanRedExcess(output, indices: changed),
            meanRedExcess(fixture.bytes, indices: changed)
        )
        XCTAssertLessThanOrEqual(maximumRGBDelta(fixture.bytes, output, indices: changed), 44)
        XCTAssertLessThanOrEqual(
            abs(meanLuminance(output, indices: changed) - meanLuminance(fixture.bytes, indices: changed)),
            0.08
        )
    }

    func testGeneratedScleraMalformedPeerFailsClosedWithoutSuppressingValidEye() throws {
        let fixture = makeEyeFixture(includeVessels: true)
        let source = try canonical(fixture.bytes, width: eyeWidth, height: eyeHeight)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let malformed = BeautyObservedEyeSupport(
            side: .right,
            contour: [CoordinatePoint(x: 0.5, y: 0.5)],
            pupil: nil
        )
        let result = BeautyFullScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [eyeSupport(side: .left, center: (90, 100)), malformed],
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )

        XCTAssertEqual(result.summary.leftOutcome, .accepted)
        XCTAssertEqual(result.summary.rightOutcome, .invalidSupport)
        XCTAssertEqual(result.units.count, 1)
        XCTAssertGreaterThan(result.summary.acceptedEyeCount, 0)
    }

    func testCompositionUsesOriginalSourceForQ16BlendAndKeepsAlpha() throws {
        let bytes = sourceBytes(count: 8)
        let source = try canonical(bytes, width: 8, height: 1)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let first = try XCTUnwrap(owner.makeUnit(proposals: [proposal(1, weight: 32_768, target: (240, 40, 20))]))
        let second = try XCTUnwrap(owner.makeUnit(proposals: [proposal(2, weight: UInt32.max, target: (10, 210, 80))]))
        let result = try owner.compose([first, second])
        let output = Array(result.canonicalImage.rgba8Data)

        XCTAssertEqual(Array(output[4..<8]), [146, 71, 86, 255])
        XCTAssertEqual(Array(output[8..<12]), [10, 210, 80, 255])
        XCTAssertEqual(alphaBytes(output), Array(repeating: 255, count: 8))
        XCTAssertEqual(result.summary.ownedPixelCount, 2)
        XCTAssertEqual(result.summary.changedPixelCount, 2)
    }

    func testCompositionCollisionPreservesSourceAndRetainsUniqueNeighbor() throws {
        let bytes = sourceBytes(count: 8)
        let source = try canonical(bytes, width: 8, height: 1)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let collidingA = try XCTUnwrap(owner.makeUnit(proposals: [proposal(2, target: (240, 20, 10))]))
        let collidingB = try XCTUnwrap(owner.makeUnit(proposals: [proposal(2, target: (10, 240, 20))]))
        let neighbor = try XCTUnwrap(owner.makeUnit(proposals: [proposal(3, target: (30, 40, 230))]))
        let result = try owner.compose([collidingA, collidingB, neighbor])
        let output = Array(result.canonicalImage.rgba8Data)

        XCTAssertEqual(Array(output[8..<12]), Array(bytes[8..<12]))
        XCTAssertEqual(Array(output[12..<16]), [30, 40, 230, 255])
        XCTAssertEqual(result.summary.acceptedUnitCount, 3)
        XCTAssertEqual(result.summary.collisionPixelCount, 1)
        XCTAssertEqual(result.summary.ownedPixelCount, 1)
        XCTAssertEqual(result.summary.changedPixelCount, 1)
    }

    func testCompositionRejectsForeignStaleAndDuplicateClaimsWithoutSourceDrift() throws {
        let bytes = sourceBytes(count: 8)
        let source = try canonical(bytes, width: 8, height: 1)
        let foreignSource = try canonical(bytes, width: 8, height: 1)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let foreignOwner = BeautyLocalRetouchCompositionOwner(source: foreignSource)
        let valid = try XCTUnwrap(owner.makeUnit(proposals: [proposal(0, target: (230, 40, 30))]))
        let foreign = try XCTUnwrap(foreignOwner.makeUnit(proposals: [proposal(1, target: (30, 220, 50))]))
        let duplicate = try XCTUnwrap(owner.makeUnit(proposals: [proposal(2, target: (40, 50, 220))]))
        let result = try owner.compose([foreign, valid, duplicate, duplicate])
        let output = Array(result.canonicalImage.rgba8Data)

        XCTAssertEqual(Array(output[0..<4]), [230, 40, 30, 255])
        XCTAssertEqual(Array(output[4..<8]), Array(bytes[4..<8]))
        XCTAssertEqual(Array(output[8..<12]), Array(bytes[8..<12]))
        XCTAssertEqual(result.summary.acceptedUnitCount, 1)
        XCTAssertEqual(result.summary.rejectedUnitCount, 3)
        XCTAssertEqual(result.summary.ownedPixelCount, 1)
        XCTAssertEqual(result.summary.collisionPixelCount, 0)
    }

    private var validLipSupport: BeautyObservedLipSupport {
        BeautyObservedLipSupport(
            outer: rectangle(minX: 0.18, minY: 0.25, maxX: 0.82, maxY: 0.75),
            inner: rectangle(minX: 0.28, minY: 0.38, maxX: 0.72, maxY: 0.62)
        )
    }

    private var malformedLipSupport: BeautyObservedLipSupport {
        BeautyObservedLipSupport(
            outer: [CoordinatePoint(x: -0.1, y: 0.2)],
            inner: [CoordinatePoint(x: 0.4, y: 0.4)]
        )
    }

    private func rectangle(minX: Double, minY: Double, maxX: Double, maxY: Double) -> [CoordinatePoint] {
        [
            CoordinatePoint(x: minX, y: minY),
            CoordinatePoint(x: maxX, y: minY),
            CoordinatePoint(x: maxX, y: maxY),
            CoordinatePoint(x: minX, y: maxY),
        ]
    }

    private struct MouthFixture {
        let bytes: [UInt8]
        let enamel: Set<Int>
        let protected: Set<Int>
        let outside: Set<Int>
    }

    private func makeMouthFixture() -> MouthFixture {
        var bytes = uniformBytes(red: 45, green: 24, blue: 30, width: mouthWidth, height: mouthHeight)
        var enamel = Set<Int>()
        var protected = Set<Int>()
        var outside = Set<Int>()
        for y in 0..<mouthHeight {
            for x in 0..<mouthWidth {
                let index = y * mouthWidth + x
                if x == 0 || y == 0 || x == mouthWidth - 1 || y == mouthHeight - 1 {
                    outside.insert(index)
                }
            }
        }
        for y in 16...24 {
            for x in 18...45 {
                let index = y * mouthWidth + x
                let core = (24...39).contains(x) && (18...22).contains(y)
                replaceRGB(&bytes, index: index, color: core ? (181, 161, 120) : (142, 130, 102))
                enamel.insert(index)
            }
        }
        for (index, color) in [
            (pixelIndex(x: 21, y: 18), (UInt8(185), UInt8(48), UInt8(72))),
            (pixelIndex(x: 22, y: 20), (UInt8(154), UInt8(49), UInt8(65))),
            (pixelIndex(x: 31, y: 20), (UInt8(190), UInt8(190), UInt8(190))),
            (pixelIndex(x: 40, y: 18), (UInt8(30), UInt8(25), UInt8(20))),
        ] {
            replaceRGB(&bytes, index: index, color: color)
            protected.insert(index)
            enamel.remove(index)
        }
        return MouthFixture(bytes: bytes, enamel: enamel, protected: protected, outside: outside)
    }

    private struct EyeFixture {
        let bytes: [UInt8]
        let protected: Set<Int>
        let caruncle: Set<Int>
    }

    private func makeEyeFixture(includeVessels: Bool) -> EyeFixture {
        var bytes = uniformBytes(red: 164, green: 118, blue: 105, width: eyeWidth, height: eyeHeight)
        var protected = Set<Int>()
        var caruncle = Set<Int>()
        let centers = [(side: BeautyObservedEyeSide.left, x: 90), (side: .right, x: 230)]
        for (side, centerX) in centers {
            let centerY = 100
            for y in (centerY - 27)...(centerY + 27) {
                for x in (centerX - 55)...(centerX + 55) {
                    let dx = Double(x - centerX)
                    let dy = Double(y - centerY)
                    guard dx * dx / (55 * 55) + dy * dy / (27 * 27) <= 1 else { continue }
                    let index = y * eyeWidth + x
                    let distance = hypot(dx, dy)
                    let boundary = dx * dx / (53 * 53) + dy * dy / (25 * 25) > 1
                    let iris = distance <= 23.5
                    let highlight = (x == centerX - 6 || x == centerX - 5)
                        && (y == centerY - 7 || y == centerY - 6)
                    if boundary || iris || highlight {
                        replaceRGB(&bytes, index: index, color: highlight ? (248, 248, 248) : iris ? (72, 79, 86) : (38, 28, 30))
                        protected.insert(index)
                        continue
                    }
                    let medial = side == .left ? x >= centerX + 43 : x <= centerX - 43
                    if medial {
                        replaceRGB(&bytes, index: index, color: (218, 135, 145))
                        caruncle.insert(index)
                    } else {
                        replaceRGB(&bytes, index: index, color: (210, 206, 207))
                    }
                }
            }
            guard includeVessels else { continue }
            for anchor in [(x: centerX - 36, y: centerY), (x: centerX + 34, y: centerY + 5)] {
                for y in (anchor.y - 2)...(anchor.y + 2) {
                    for x in (anchor.x - 3)...(anchor.x + 3) {
                        let index = y * eyeWidth + x
                        replaceRGB(&bytes, index: index, color: (210, 150, 150))
                    }
                }
            }
        }
        return EyeFixture(bytes: bytes, protected: protected, caruncle: caruncle)
    }

    private func eyeSupport(side: BeautyObservedEyeSide, center: (x: Int, y: Int)) -> BeautyObservedEyeSupport {
        BeautyObservedEyeSupport(
            side: side,
            contour: (0..<24).map { index in
                let angle = Double(index) * 2 * .pi / 24
                return CoordinatePoint(
                    x: (Double(center.x) + 55 * cos(angle)) / Double(eyeWidth),
                    y: (Double(center.y) + 27 * sin(angle)) / Double(eyeHeight)
                )
            },
            pupil: [CoordinatePoint(x: Double(center.x) / Double(eyeWidth), y: Double(center.y) / Double(eyeHeight))]
        )
    }

    private func canonical(_ bytes: [UInt8], width: Int, height: Int) throws -> BeautyCanonicalStillImage {
        try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes), width: width, height: height, rowBytes: width * 4,
            metadata: BeautyInputMetadata(orientation: .up, isInputMirrored: false, isPreviewMirrored: false, source: .testFixture)
        )
    }

    private func proposal(_ pixelIndex: Int, weight: UInt32 = UInt32.max, target: (UInt8, UInt8, UInt8)) -> BeautyLocalPixelProposal {
        BeautyLocalPixelProposal(
            pixelIndex: pixelIndex, isInsideHardEnvelope: true, softWeightQ16: weight,
            targetRed: target.0, targetGreen: target.1, targetBlue: target.2
        )
    }

    private func sourceBytes(count: Int) -> [UInt8] {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(count * 4)
        for value in 0..<count {
            bytes.append(contentsOf: [UInt8(50 + value), UInt8(100 + value), UInt8(150 + value), 255])
        }
        return bytes
    }

    private func uniformBytes(red: UInt8, green: UInt8, blue: UInt8, width: Int, height: Int) -> [UInt8] {
        Array(repeating: [red, green, blue, 255], count: width * height).flatMap { $0 }
    }

    private func replaceRGB(_ bytes: inout [UInt8], index: Int, color: (UInt8, UInt8, UInt8)) {
        let offset = index * 4
        bytes[offset] = color.0
        bytes[offset + 1] = color.1
        bytes[offset + 2] = color.2
    }

    private func pixelIndex(x: Int, y: Int) -> Int { y * mouthWidth + x }

    private func changedIndices(before: [UInt8], after: [UInt8]) -> Set<Int> {
        Set((0..<(before.count / 4)).filter { index in
            let offset = index * 4
            return before[offset..<(offset + 3)] != after[offset..<(offset + 3)]
        })
    }

    private func alphaBytes(_ bytes: [UInt8]) -> [UInt8] {
        stride(from: 3, to: bytes.count, by: 4).map { bytes[$0] }
    }

    private func meanYellowExcess(_ bytes: [UInt8], indices: Set<Int>) -> Double {
        mean(indices) { index in
            let p = rgb(bytes, index: index)
            return max(0, Double(p.0) - 0.72 * Double(p.1) - 0.28 * Double(p.2)) / 255
        }
    }

    private func meanRedExcess(_ bytes: [UInt8], indices: Set<Int>) -> Double {
        mean(indices) { index in
            let p = rgb(bytes, index: index)
            return max(0, Double(p.0) / 255 - 0.83 * Double(p.1) / 255 - 0.17 * Double(p.2) / 255)
        }
    }

    private func meanLuminance(_ bytes: [UInt8], indices: Set<Int>) -> Double {
        mean(indices) { index in
            let p = rgb(bytes, index: index)
            return (0.2126 * Double(p.0) + 0.7152 * Double(p.1) + 0.0722 * Double(p.2)) / 255
        }
    }

    private func mean(_ indices: Set<Int>, _ value: (Int) -> Double) -> Double {
        guard !indices.isEmpty else { return 0 }
        return indices.reduce(0) { $0 + value($1) } / Double(indices.count)
    }

    private func maximumRGBDelta(_ before: [UInt8], _ after: [UInt8], indices: Set<Int>) -> Int {
        indices.reduce(0) { maximum, index in
            let old = rgb(before, index: index)
            let new = rgb(after, index: index)
            return max(maximum, abs(Int(old.0) - Int(new.0)), abs(Int(old.1) - Int(new.1)), abs(Int(old.2) - Int(new.2)))
        }
    }

    private func rgb(_ bytes: [UInt8], index: Int) -> (UInt8, UInt8, UInt8) {
        let offset = index * 4
        return (bytes[offset], bytes[offset + 1], bytes[offset + 2])
    }
}
