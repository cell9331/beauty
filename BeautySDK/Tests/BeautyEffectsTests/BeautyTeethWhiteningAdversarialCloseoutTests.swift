import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class BeautyTeethWhiteningAdversarialCloseoutTests: XCTestCase {
    private let width = 64
    private let height = 40

    private enum ProtectedRegion: CaseIterable {
        case lip
        case tongue
        case gum
        case brace
        case facialHair
        case skin
        case apertureExterior
    }

    func testColorIndependentProtectedTruthRemainsExactAcrossSupportPerturbations() throws {
        let colorIndependentCoordinates: [ProtectedRegion: (x: Int, y: Int)] = [
            .lip: (30, 13),
            .tongue: (30, 27),
            .gum: (15, 14),
            .brace: (50, 19),
            .facialHair: (9, 18),
            .skin: (55, 20),
            .apertureExterior: (4, 4),
        ]
        XCTAssertEqual(colorIndependentCoordinates.count, ProtectedRegion.allCases.count)
        let colorIndependentProtectedTruth = Set(
            colorIndependentCoordinates.values.map { pixelIndex(x: $0.x, y: $0.y) }
        )
        var sourceBytes = makeMouthBytes()
        for index in colorIndependentProtectedTruth {
            sourceBytes = replacingRGBA(
                in: sourceBytes,
                index: index,
                with: (181, 161, 120, 255)
            )
        }

        let supports = [
            support(outer: (0.17, 0.26, 0.83, 0.74)),
            support(outer: (0.18, 0.25, 0.82, 0.75)),
            support(outer: (0.20, 0.24, 0.80, 0.76)),
        ]
        for lipSupport in supports {
            let source = try canonical(sourceBytes)
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let provider = try XCTUnwrap(BeautyTeethWhiteningProvider.makeResult(
                source: source,
                lipSupport: lipSupport,
                strength: 1,
                owner: owner
            ))
            let composed = try owner.compose([provider.unit])
            let output = Array(composed.canonicalImage.rgba8Data)
            let changed = changedPixelIndices(before: sourceBytes, after: output)

            XCTAssertFalse(changed.isEmpty)
            XCTAssertTrue(changed.isDisjoint(with: colorIndependentProtectedTruth))
            for index in colorIndependentProtectedTruth {
                XCTAssertEqual(rgba(output, at: index), rgba(sourceBytes, at: index))
            }
            XCTAssertEqual(composed.summary.changedOutsideUnionPixelCount, 0)
        }
    }

    func testRecoloredProtectedFamiliesRemainExactInFinalComposedOutput() throws {
        let coordinates: [ProtectedRegion: (x: Int, y: Int)] = [
            .lip: (30, 12),
            .tongue: (30, 28),
            .gum: (15, 14),
            .brace: (50, 19),
            .facialHair: (9, 18),
            .skin: (55, 20),
            .apertureExterior: (4, 4),
        ]
        XCTAssertEqual(coordinates.count, ProtectedRegion.allCases.count)

        var sourceBytes = makeMouthBytes()
        let recoloredProtected = Set(coordinates.values.map { pixelIndex(x: $0.x, y: $0.y) })
        for index in recoloredProtected {
            sourceBytes = replacingRGBA(
                in: sourceBytes,
                index: index,
                with: (181, 161, 120, 255)
            )
        }

        let source = try canonical(sourceBytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let provider = try XCTUnwrap(BeautyTeethWhiteningProvider.makeResult(
            source: source,
            lipSupport: support(outer: (0.18, 0.25, 0.82, 0.75)),
            strength: 1,
            owner: owner
        ))
        let composed = try owner.compose([provider.unit])
        let output = Array(composed.canonicalImage.rgba8Data)

        XCTAssertGreaterThan(composed.summary.changedPixelCount, 0)
        for region in ProtectedRegion.allCases {
            let point = try XCTUnwrap(coordinates[region])
            let index = pixelIndex(x: point.x, y: point.y)
            XCTAssertEqual(rgba(output, at: index), rgba(sourceBytes, at: index), "\(region)")
        }
        XCTAssertEqual(composed.summary.changedOutsideUnionPixelCount, 0)
    }

    func testMalformedGeometryCannotLeaveStaleClaimsInRequestLocalOwner() throws {
        let sourceBytes = makeMouthBytes()
        let source = try canonical(sourceBytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let malformed = BeautyObservedLipSupport(
            outer: rectangle(minX: 0.18, minY: 0.25, maxX: 0.82, maxY: 0.75),
            inner: [
                CoordinatePoint(x: 0.3, y: 0.5),
                CoordinatePoint(x: 0.3, y: 0.5),
                CoordinatePoint(x: 0.3, y: 0.5),
            ]
        )

        XCTAssertNil(BeautyTeethWhiteningProvider.makeResult(
            source: source,
            lipSupport: malformed,
            strength: 1,
            owner: owner
        ))
        let valid = try XCTUnwrap(BeautyTeethWhiteningProvider.makeResult(
            source: source,
            lipSupport: support(outer: (0.18, 0.25, 0.82, 0.75)),
            strength: 1,
            owner: owner
        ))
        let composed = try owner.compose([valid.unit])

        XCTAssertEqual(composed.summary.acceptedUnitCount, 1)
        XCTAssertEqual(composed.summary.rejectedUnitCount, 0)
        XCTAssertGreaterThan(composed.summary.changedPixelCount, 0)
    }

    func testValidInvalidValidRecoveryIsPixelExactAndStateless() throws {
        let sourceBytes = makeMouthBytes()
        let source = try canonical(sourceBytes)
        let validSupport = support(outer: (0.18, 0.25, 0.82, 0.75))
        let malformedSupport = BeautyObservedLipSupport(
            outer: rectangle(minX: 0.18, minY: 0.25, maxX: 0.82, maxY: 0.75),
            inner: nil
        )

        func render(_ lipSupport: BeautyObservedLipSupport) throws -> [UInt8]? {
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            guard let provider = BeautyTeethWhiteningProvider.makeResult(
                source: source,
                lipSupport: lipSupport,
                strength: 1,
                owner: owner
            ) else {
                return nil
            }
            return Array(try owner.compose([provider.unit]).canonicalImage.rgba8Data)
        }

        let first = try XCTUnwrap(render(validSupport))
        XCTAssertNil(try render(malformedSupport))
        let recovered = try XCTUnwrap(render(validSupport))
        XCTAssertEqual(recovered, first)
    }

    func testParallelRequestLocalOwnersDoNotShareClaimsOrRecoveryState() async throws {
        let source = try canonical(makeMouthBytes())
        let validSupport = support(outer: (0.18, 0.25, 0.82, 0.75))
        let malformedSupport = BeautyObservedLipSupport(
            outer: nil,
            inner: rectangle(minX: 0.28, minY: 0.38, maxX: 0.72, maxY: 0.62)
        )
        let results = try await withThrowingTaskGroup(
            of: (Int, Int).self,
            returning: [(Int, Int)].self
        ) { group in
            for index in 0..<16 {
                group.addTask {
                    let owner = BeautyLocalRetouchCompositionOwner(source: source)
                    let selectedSupport = index.isMultiple(of: 2) ? validSupport : malformedSupport
                    guard let provider = BeautyTeethWhiteningProvider.makeResult(
                        source: source,
                        lipSupport: selectedSupport,
                        strength: 1,
                        owner: owner
                    ) else {
                        return (index, 0)
                    }
                    let output = try owner.compose([provider.unit])
                    return (index, output.summary.changedPixelCount)
                }
            }
            var collected: [(Int, Int)] = []
            for try await result in group {
                collected.append(result)
            }
            return collected
        }

        XCTAssertEqual(results.count, 16)
        for (index, changedPixelCount) in results {
            if index.isMultiple(of: 2) {
                XCTAssertGreaterThan(changedPixelCount, 0)
            } else {
                XCTAssertEqual(changedPixelCount, 0)
            }
        }
    }

    func testUnrelatedColorUnitContinuesAlongsideTeethWithoutClaimCollision() throws {
        let sourceBytes = makeMouthBytes()
        let source = try canonical(sourceBytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let provider = try XCTUnwrap(BeautyTeethWhiteningProvider.makeResult(
            source: source,
            lipSupport: support(outer: (0.18, 0.25, 0.82, 0.75)),
            strength: 1,
            owner: owner
        ))
        let unrelatedIndex = pixelIndex(x: 2, y: 2)
        let unrelatedColor = try XCTUnwrap(owner.makeUnit(proposals: [
            BeautyLocalPixelProposal(
                pixelIndex: unrelatedIndex,
                isInsideHardEnvelope: true,
                softWeightQ16: 65_536,
                targetRed: 60,
                targetGreen: 30,
                targetBlue: 35
            ),
        ]))
        let output = try owner.compose([provider.unit, unrelatedColor])
        let bytes = Array(output.canonicalImage.rgba8Data)

        XCTAssertEqual(rgba(bytes, at: unrelatedIndex), [60, 30, 35, 255])
        XCTAssertEqual(output.summary.acceptedUnitCount, 2)
        XCTAssertEqual(output.summary.collisionPixelCount, 0)
        XCTAssertGreaterThan(output.summary.changedPixelCount, 1)
    }

    private func support(
        outer: (minX: Double, minY: Double, maxX: Double, maxY: Double)
    ) -> BeautyObservedLipSupport {
        BeautyObservedLipSupport(
            outer: rectangle(
                minX: outer.minX,
                minY: outer.minY,
                maxX: outer.maxX,
                maxY: outer.maxY
            ),
            inner: rectangle(minX: 0.28, minY: 0.38, maxX: 0.72, maxY: 0.62)
        )
    }

    private func rectangle(
        minX: Double,
        minY: Double,
        maxX: Double,
        maxY: Double
    ) -> [CoordinatePoint] {
        [
            CoordinatePoint(x: minX, y: minY),
            CoordinatePoint(x: maxX, y: minY),
            CoordinatePoint(x: maxX, y: maxY),
            CoordinatePoint(x: minX, y: maxY),
        ]
    }

    private func makeMouthBytes() -> [UInt8] {
        let background: [UInt8] = [45, 24, 30, 255]
        var bytes = Array(repeating: background, count: width * height).flatMap { $0 }
        for y in 16...24 {
            for x in 18...45 {
                let isFixedCore = (24...39).contains(x) && (18...22).contains(y)
                bytes = replacingRGBA(
                    in: bytes,
                    index: pixelIndex(x: x, y: y),
                    with: isFixedCore ? (181, 161, 120, 255) : (142, 130, 102, 255)
                )
            }
        }
        return bytes
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

    private func pixelIndex(x: Int, y: Int) -> Int {
        y * width + x
    }

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
        Set((0..<(before.count / 4)).filter { index in
            rgba(before, at: index) != rgba(after, at: index)
        })
    }
}
