import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class BeautyScleraRednessAdversarialCloseoutTests: XCTestCase {
    private let width = 80
    private let height = 48

    private enum ProtectedRegion: CaseIterable {
        case iris
        case pupil
        case highlight
        case lashMargin
        case skin
        case apertureExterior
    }

    func testColorIndependentProtectedTruthRemainsExactAcrossBoundedSupportPerturbations() throws {
        let coordinates = protectedCoordinates()
        XCTAssertEqual(coordinates.count, ProtectedRegion.allCases.count)
        let colorIndependentProtectedTruth = Set(
            coordinates.values.map { pixelIndex(x: $0.x, y: $0.y) }
        )
        var sourceBytes = makeEyeBytes()
        for index in colorIndependentProtectedTruth {
            sourceBytes = replacingRGBA(
                in: sourceBytes,
                index: index,
                with: (210, 150, 150, 255)
            )
        }

        let perturbations: [(centerDelta: Double, xRadius: Double, yRadius: Double, pupilDelta: Double)] = [
            (0, 0.1625, 0.0833, 0),
            (-0.0025, 0.1575, 0.0800, 0.0040),
            (0.0025, 0.1650, 0.0860, -0.0040),
        ]
        for perturbation in perturbations {
            let source = try canonical(sourceBytes)
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: supports(
                    centerDelta: perturbation.centerDelta,
                    xRadius: perturbation.xRadius,
                    yRadius: perturbation.yRadius,
                    pupilDelta: perturbation.pupilDelta
                ),
                eyeOrder: .canonical,
                strength: 1,
                owner: owner
            )
            let output = Array(try owner.compose(result.units).canonicalImage.rgba8Data)
            let changed = changedPixelIndices(before: sourceBytes, after: output)

            XCTAssertEqual(result.units.count, 2)
            XCTAssertGreaterThan(result.summary.proposalPixelCount, 0)
            XCTAssertEqual(result.summary.protectedProposalPixelCount, 0)
            XCTAssertFalse(changed.isEmpty)
            XCTAssertTrue(changed.isDisjoint(with: colorIndependentProtectedTruth))
            for index in colorIndependentProtectedTruth {
                XCTAssertEqual(rgba(output, at: index), rgba(sourceBytes, at: index))
            }
        }
    }

    func testRecoloredProtectedFamiliesRemainExactInFinalComposedOutput() throws {
        let coordinates = protectedCoordinates()
        XCTAssertEqual(coordinates.count, ProtectedRegion.allCases.count)
        let recoloredProtected = Set(coordinates.values.map { pixelIndex(x: $0.x, y: $0.y) })
        var sourceBytes = makeEyeBytes()
        for index in recoloredProtected {
            sourceBytes = replacingRGBA(
                in: sourceBytes,
                index: index,
                with: (214, 151, 151, 255)
            )
        }

        let source = try canonical(sourceBytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let result = BeautyScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: supports(),
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )
        let composed = try owner.compose(result.units)
        let output = Array(composed.canonicalImage.rgba8Data)

        XCTAssertEqual(result.units.count, 2)
        XCTAssertGreaterThan(composed.summary.changedPixelCount, 0)
        XCTAssertEqual(composed.summary.changedOutsideUnionPixelCount, 0)
        for region in ProtectedRegion.allCases {
            let point = try XCTUnwrap(coordinates[region])
            let index = pixelIndex(x: point.x, y: point.y)
            XCTAssertEqual(rgba(output, at: index), rgba(sourceBytes, at: index), "\(region)")
        }
    }

    func testMalformedPeerEyeDoesNotSuppressAcceptedEye() throws {
        let bytes = makeEyeBytes()
        let source = try canonical(bytes)
        let left = support(side: .left, centerX: 0.2625)
        let malformedRight = BeautyObservedEyeSupport(
            side: .right,
            contour: eyeContour(centerX: 0.7375, xRadius: 0.1625, yRadius: 0.0833),
            pupil: nil
        )

        func render(_ eyeSupport: [BeautyObservedEyeSupport]) throws -> [UInt8] {
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: eyeSupport,
                eyeOrder: .canonical,
                strength: 1,
                owner: owner
            )
            XCTAssertEqual(result.summary.leftOutcome, .accepted)
            XCTAssertNotEqual(result.summary.rightOutcome, .accepted)
            return Array(try owner.compose(result.units).canonicalImage.rgba8Data)
        }

        let leftOnly = try render([left])
        let malformedPeer = try render([left, malformedRight])
        XCTAssertEqual(malformedPeer, leftOnly)
        XCTAssertGreaterThan(
            changedPixelIndices(before: bytes, after: malformedPeer).filter { $0 % width < width / 2 }.count,
            0
        )
        XCTAssertEqual(
            changedPixelIndices(before: bytes, after: malformedPeer).filter { $0 % width >= width / 2 }.count,
            0
        )
    }

    func testValidInvalidValidRecoveryIsPixelExactAndStateless() throws {
        let bytes = makeEyeBytes()
        let source = try canonical(bytes)

        func render(order: BeautyObservedEyeOrder) throws -> [UInt8] {
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: supports(),
                eyeOrder: order,
                strength: 1,
                owner: owner
            )
            return Array(try owner.compose(result.units).canonicalImage.rgba8Data)
        }

        let first = try render(order: .canonical)
        XCTAssertEqual(try render(order: .invalid), bytes)
        XCTAssertEqual(try render(order: .canonical), first)
        XCTAssertFalse(changedPixelIndices(before: bytes, after: first).isEmpty)
    }

    func testParallelRequestLocalOwnersDoNotShareClaimsOrRecoveryState() async throws {
        let source = try canonical(makeEyeBytes())
        let validSupport = supports()
        let results = try await withThrowingTaskGroup(
            of: (Int, Int).self,
            returning: [(Int, Int)].self
        ) { group in
            for index in 0..<16 {
                group.addTask {
                    let owner = BeautyLocalRetouchCompositionOwner(source: source)
                    let result = BeautyScleraRednessProvider.makeResult(
                        source: source,
                        eyeSupport: validSupport,
                        eyeOrder: index.isMultiple(of: 2) ? .canonical : .invalid,
                        strength: 1,
                        owner: owner
                    )
                    let composed = try owner.compose(result.units)
                    return (index, composed.summary.changedPixelCount)
                }
            }
            var values: [(Int, Int)] = []
            for try await value in group { values.append(value) }
            return values
        }

        XCTAssertEqual(results.count, 16)
        for (index, changed) in results {
            if index.isMultiple(of: 2) {
                XCTAssertGreaterThan(changed, 0)
            } else {
                XCTAssertEqual(changed, 0)
            }
        }
    }

    private func protectedCoordinates() -> [ProtectedRegion: (x: Int, y: Int)] {
        [
            .iris: (27, 24),
            .pupil: (21, 24),
            .highlight: (18, 22),
            .lashMargin: (21, 18),
            .skin: (21, 13),
            .apertureExterior: (2, 2),
        ]
    }

    private func supports(
        centerDelta: Double = 0,
        xRadius: Double = 0.1625,
        yRadius: Double = 0.0833,
        pupilDelta: Double = 0
    ) -> [BeautyObservedEyeSupport] {
        [
            support(
                side: .left,
                centerX: 0.2625 + centerDelta,
                xRadius: xRadius,
                yRadius: yRadius,
                pupilX: 0.26 + pupilDelta
            ),
            support(
                side: .right,
                centerX: 0.7375 - centerDelta,
                xRadius: xRadius,
                yRadius: yRadius,
                pupilX: 0.74 - pupilDelta
            ),
        ]
    }

    private func support(
        side: BeautyObservedEyeSide,
        centerX: Double,
        xRadius: Double = 0.1625,
        yRadius: Double = 0.0833,
        pupilX: Double? = nil
    ) -> BeautyObservedEyeSupport {
        BeautyObservedEyeSupport(
            side: side,
            contour: eyeContour(centerX: centerX, xRadius: xRadius, yRadius: yRadius),
            pupil: [CoordinatePoint(x: pupilX ?? centerX, y: 0.50)]
        )
    }

    private func eyeContour(centerX: Double, xRadius: Double, yRadius: Double) -> [CoordinatePoint] {
        (0..<16).map { index in
            let angle = Double(index) * 2 * .pi / 16
            return CoordinatePoint(
                x: centerX + xRadius * cos(angle),
                y: 0.50 + yRadius * sin(angle)
            )
        }
    }

    private func makeEyeBytes() -> [UInt8] {
        var bytes = uniform(red: 164, green: 118, blue: 105)
        for centerX in [21, 59] {
            for y in 17...30 {
                for x in (centerX - 13)...(centerX + 13) {
                    let dx = Double(x - centerX) / 13
                    let dy = Double(y - 24) / 7
                    guard dx * dx + dy * dy <= 1 else { continue }
                    let distance = hypot(Double(x - centerX), Double(y - 24))
                    let isMargin = x <= centerX - 11 || x >= centerX + 11 || y <= 18 || y >= 29
                    let isPupil = distance <= 5.2
                    let isHighlight = (x == centerX - 2 || x == centerX - 1) && (y == 21 || y == 22)
                    let color: (UInt8, UInt8, UInt8, UInt8)
                    if isHighlight { color = (248, 248, 248, 255) }
                    else if isPupil { color = (55, 64, 72, 255) }
                    else if isMargin { color = (38, 28, 30, 255) }
                    else { color = (210, 150, 150, 255) }
                    bytes = replacingRGBA(in: bytes, index: pixelIndex(x: x, y: y), with: color)
                }
            }
        }
        return bytes
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

    private func replacingRGBA(
        in bytes: [UInt8],
        index: Int,
        with color: (UInt8, UInt8, UInt8, UInt8)
    ) -> [UInt8] {
        var result = bytes
        let offset = index * 4
        result[offset] = color.0
        result[offset + 1] = color.1
        result[offset + 2] = color.2
        result[offset + 3] = color.3
        return result
    }

    private func rgba(_ bytes: [UInt8], at index: Int) -> [UInt8] {
        let offset = index * 4
        return Array(bytes[offset..<(offset + 4)])
    }

    private func changedPixelIndices(before: [UInt8], after: [UInt8]) -> Set<Int> {
        Set((0..<(before.count / 4)).filter { rgba(before, at: $0) != rgba(after, at: $0) })
    }
}
