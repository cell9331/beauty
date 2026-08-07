import CoreGraphics
import Foundation
import ImageIO
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class BeautyTeethWhiteningProviderTests: XCTestCase {
    private let width = 64
    private let height = 40

    func testValidMappedLipSupportRetainsFixedBaselineAndChangesOnlyKnownEnamel() throws {
        let fixture = makeMouthFixture()
        let source = try canonical(fixture.bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)

        let provider = try XCTUnwrap(BeautyTeethWhiteningProvider.makeResult(
            source: source,
            lipSupport: validSupport,
            strength: 1,
            owner: owner
        ))
        let composed = try owner.compose([provider.unit])
        let changed = changedPixelIndices(
            before: fixture.bytes,
            after: Array(composed.canonicalImage.rgba8Data)
        )

        XCTAssertFalse(changed.isEmpty)
        XCTAssertTrue(changed.isSubset(of: fixture.allowedEnamel))
        XCTAssertGreaterThan(provider.summary.fixedStrongPixelCount, 0)
        XCTAssertGreaterThanOrEqual(
            provider.summary.finalStrongPixelCount,
            provider.summary.fixedStrongPixelCount
        )
        XCTAssertEqual(provider.summary.droppedFixedStrongPixelCount, 0)
        XCTAssertEqual(composed.summary.changedOutsideUnionPixelCount, 0)
    }

    func testCompleteActualInnerAndOuterSupportAreBothMandatory() throws {
        let source = try canonical(makeMouthFixture().bytes)
        for support in [
            nil,
            BeautyObservedLipSupport(outer: validSupport.outer, inner: nil),
            BeautyObservedLipSupport(outer: nil, inner: validSupport.inner),
        ] {
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            XCTAssertNil(BeautyTeethWhiteningProvider.makeResult(
                source: source,
                lipSupport: support,
                strength: 1,
                owner: owner
            ))
        }
    }

    func testMalformedNonFiniteOutsideDuplicateSelfIntersectingAndNonNestedSupportAbstains() throws {
        let source = try canonical(makeMouthFixture().bytes)
        let malformed: [BeautyObservedLipSupport] = [
            BeautyObservedLipSupport(
                outer: rectangle(minX: -0.01, minY: 0.2, maxX: 0.8, maxY: 0.8),
                inner: validSupport.inner
            ),
            BeautyObservedLipSupport(
                outer: rectangle(minX: 0.2, minY: 0.2, maxX: 0.8, maxY: 0.8),
                inner: [
                    CoordinatePoint(x: 0.3, y: 0.4),
                    CoordinatePoint(x: 0.7, y: 0.4),
                    CoordinatePoint(x: .infinity, y: 0.6),
                ]
            ),
            BeautyObservedLipSupport(
                outer: rectangle(minX: 0.2, minY: 0.2, maxX: 0.8, maxY: 0.8),
                inner: [
                    CoordinatePoint(x: 0.4, y: 0.5),
                    CoordinatePoint(x: 0.4, y: 0.5),
                    CoordinatePoint(x: 0.4, y: 0.5),
                ]
            ),
            BeautyObservedLipSupport(
                outer: [
                    CoordinatePoint(x: 0.2, y: 0.2),
                    CoordinatePoint(x: 0.8, y: 0.8),
                    CoordinatePoint(x: 0.8, y: 0.2),
                    CoordinatePoint(x: 0.2, y: 0.8),
                ],
                inner: validSupport.inner
            ),
            BeautyObservedLipSupport(
                outer: rectangle(minX: 0.2, minY: 0.2, maxX: 0.8, maxY: 0.8),
                inner: rectangle(minX: 0.05, minY: 0.4, maxX: 0.35, maxY: 0.6)
            ),
        ]

        for support in malformed {
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            XCTAssertNil(BeautyTeethWhiteningProvider.makeResult(
                source: source,
                lipSupport: support,
                strength: 1,
                owner: owner
            ))
        }
    }

    func testClosedCollapsedAndImplausibleMouthsAbstain() throws {
        let source = try canonical(makeMouthFixture().bytes)
        let supports = [
            BeautyObservedLipSupport(
                outer: rectangle(minX: 0.2, minY: 0.45, maxX: 0.8, maxY: 0.55),
                inner: rectangle(minX: 0.3, minY: 0.49, maxX: 0.7, maxY: 0.51)
            ),
            BeautyObservedLipSupport(
                outer: rectangle(minX: 0.49, minY: 0.45, maxX: 0.51, maxY: 0.55),
                inner: rectangle(minX: 0.495, minY: 0.48, maxX: 0.505, maxY: 0.52)
            ),
            BeautyObservedLipSupport(
                outer: rectangle(minX: 0.01, minY: 0.01, maxX: 0.99, maxY: 0.99),
                inner: rectangle(minX: 0.02, minY: 0.02, maxX: 0.98, maxY: 0.98)
            ),
        ]

        for support in supports {
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            XCTAssertNil(BeautyTeethWhiteningProvider.makeResult(
                source: source,
                lipSupport: support,
                strength: 1,
                owner: owner
            ))
        }
    }

    func testAdaptiveGrowthIsSeedConnectedAndNeverDropsFixedStrongPixels() throws {
        let fixture = makeMouthFixture(includeDisconnectedLookalike: true)
        let source = try canonical(fixture.bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let provider = try XCTUnwrap(BeautyTeethWhiteningProvider.makeResult(
            source: source,
            lipSupport: validSupport,
            strength: 1,
            owner: owner
        ))
        let result = try owner.compose([provider.unit])
        let changed = changedPixelIndices(before: fixture.bytes, after: Array(result.canonicalImage.rgba8Data))

        XCTAssertGreaterThan(provider.summary.adaptiveStrongPixelCount, provider.summary.fixedStrongPixelCount)
        XCTAssertEqual(provider.summary.droppedFixedStrongPixelCount, 0)
        XCTAssertTrue(changed.isDisjoint(with: fixture.disconnectedLookalike))
        XCTAssertTrue(changed.isSubset(of: fixture.allowedEnamel))
    }

    func testNoAcceptedSeedAndOccludedMouthAbstainWithoutSyntheticCoverage() throws {
        for bytes in [
            makeUniformBytes(red: 45, green: 24, blue: 30),
            makeUniformBytes(red: 75, green: 70, blue: 66),
        ] {
            let source = try canonical(bytes)
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            XCTAssertNil(BeautyTeethWhiteningProvider.makeResult(
                source: source,
                lipSupport: validSupport,
                strength: 1,
                owner: owner
            ))
        }
    }

    func testPostFilterHardReclipPreservesUpperLipAndEveryOutsideEnvelopePixel() throws {
        var fixture = makeMouthFixture()
        let upperLip = pixelIndex(x: 30, y: 10)
        let justAboveAperture = pixelIndex(x: 30, y: 14)
        fixture.bytes = replacingRGB(in: fixture.bytes, index: upperLip, with: (181, 161, 120))
        fixture.bytes = replacingRGB(in: fixture.bytes, index: justAboveAperture, with: (181, 161, 120))

        let source = try canonical(fixture.bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let provider = try XCTUnwrap(BeautyTeethWhiteningProvider.makeResult(
            source: source,
            lipSupport: validSupport,
            strength: 1,
            owner: owner
        ))
        let result = try owner.compose([provider.unit])
        let output = Array(result.canonicalImage.rgba8Data)

        XCTAssertEqual(rgb(output, at: upperLip), rgb(fixture.bytes, at: upperLip))
        XCTAssertEqual(rgb(output, at: justAboveAperture), rgb(fixture.bytes, at: justAboveAperture))
        XCTAssertEqual(result.summary.changedOutsideUnionPixelCount, 0)
    }

    func testProtectedLipTongueGumBracesHairAndSkinSentinelsRemainExact() throws {
        let fixture = makeMouthFixture(includeProtectedSentinels: true)
        let source = try canonical(fixture.bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let provider = try XCTUnwrap(BeautyTeethWhiteningProvider.makeResult(
            source: source,
            lipSupport: validSupport,
            strength: 1,
            owner: owner
        ))
        let result = try owner.compose([provider.unit])
        let output = Array(result.canonicalImage.rgba8Data)

        for index in fixture.protectedSentinels {
            XCTAssertEqual(rgb(output, at: index), rgb(fixture.bytes, at: index))
        }
        XCTAssertGreaterThan(result.summary.changedPixelCount, 0)
    }

    func testTransformMakesNeutralAlreadyLightAndLightlyWarmPixelsExactNoOps() {
        for pixel: (UInt8, UInt8, UInt8) in [
            (220, 220, 220),
            (238, 238, 238),
            (230, 225, 210),
            (160, 158, 150),
        ] {
            XCTAssertNil(BeautyTeethWhiteningTransform.target(
                red: pixel.0,
                green: pixel.1,
                blue: pixel.2,
                strength: 1
            ))
        }
    }

    func testTransformReducesMaterialYellowWithinLockedChannelAndLuminanceBounds() throws {
        let source = (red: UInt8(181), green: UInt8(161), blue: UInt8(120))
        let target = try XCTUnwrap(BeautyTeethWhiteningTransform.target(
            red: source.red,
            green: source.green,
            blue: source.blue,
            strength: 1
        ))

        XCTAssertLessThan(yellowExcess(target.red, target.green, target.blue), yellowExcess(source.red, source.green, source.blue))
        XCTAssertGreaterThan(luminance(target.red, target.green, target.blue), luminance(source.red, source.green, source.blue))
        XCTAssertLessThanOrEqual(
            luminance(target.red, target.green, target.blue) - luminance(source.red, source.green, source.blue),
            0.032
        )
        XCTAssertLessThanOrEqual(abs(Int(target.red) - Int(source.red)), 72)
        XCTAssertLessThanOrEqual(abs(Int(target.green) - Int(source.green)), 72)
        XCTAssertLessThanOrEqual(abs(Int(target.blue) - Int(source.blue)), 72)
    }

    func testTransformStrengthIsMonotonicDeterministicAndSourceOnly() throws {
        let low = try XCTUnwrap(BeautyTeethWhiteningTransform.target(
            red: 181,
            green: 161,
            blue: 120,
            strength: 0.35
        ))
        let high = try XCTUnwrap(BeautyTeethWhiteningTransform.target(
            red: 181,
            green: 161,
            blue: 120,
            strength: 1
        ))
        let repeated = try XCTUnwrap(BeautyTeethWhiteningTransform.target(
            red: 181,
            green: 161,
            blue: 120,
            strength: 1
        ))

        XCTAssertEqual(high, repeated)
        XCTAssertLessThanOrEqual(Int(low.blue) - 120, Int(high.blue) - 120)
        XCTAssertLessThanOrEqual(
            luminance(low.red, low.green, low.blue),
            luminance(high.red, high.green, high.blue)
        )
    }

    func testZeroNegativeAndNonFiniteStrengthAbstain() throws {
        let source = try canonical(makeMouthFixture().bytes)
        for strength in [Float.zero, -1, .nan, .infinity] {
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            XCTAssertNil(BeautyTeethWhiteningProvider.makeResult(
                source: source,
                lipSupport: validSupport,
                strength: strength,
                owner: owner
            ))
        }
    }

    private var validSupport: BeautyObservedLipSupport {
        BeautyObservedLipSupport(
            outer: rectangle(minX: 0.18, minY: 0.25, maxX: 0.82, maxY: 0.75),
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

    private struct MouthFixture {
        var bytes: [UInt8]
        var allowedEnamel: Set<Int>
        var disconnectedLookalike: Set<Int>
        var protectedSentinels: Set<Int>
    }

    private func makeMouthFixture(
        includeDisconnectedLookalike: Bool = false,
        includeProtectedSentinels: Bool = false
    ) -> MouthFixture {
        var bytes = makeUniformBytes(red: 45, green: 24, blue: 30)
        var allowed = Set<Int>()

        for y in 16...24 {
            for x in 18...45 {
                let index = pixelIndex(x: x, y: y)
                let isFixedCore = (24...39).contains(x) && (18...22).contains(y)
                let color: (UInt8, UInt8, UInt8) = isFixedCore
                    ? (181, 161, 120)
                    : (142, 130, 102)
                bytes = replacingRGB(in: bytes, index: index, with: color)
                allowed.insert(index)
            }
        }

        var disconnected = Set<Int>()
        if includeDisconnectedLookalike {
            for y in 17...19 {
                for x in 48...51 {
                    let index = pixelIndex(x: x, y: y)
                    bytes = replacingRGB(in: bytes, index: index, with: (170, 154, 116))
                    disconnected.insert(index)
                }
            }
        }

        var protected = Set<Int>()
        if includeProtectedSentinels {
            let sentinels: [(Int, (UInt8, UInt8, UInt8))] = [
                (pixelIndex(x: 21, y: 18), (185, 48, 72)),
                (pixelIndex(x: 22, y: 20), (154, 49, 65)),
                (pixelIndex(x: 23, y: 22), (205, 130, 135)),
                (pixelIndex(x: 31, y: 20), (190, 190, 190)),
                (pixelIndex(x: 40, y: 18), (30, 25, 20)),
                (pixelIndex(x: 41, y: 21), (180, 130, 100)),
            ]
            for (index, color) in sentinels {
                bytes = replacingRGB(in: bytes, index: index, with: color)
                protected.insert(index)
                allowed.remove(index)
            }
        }

        return MouthFixture(
            bytes: bytes,
            allowedEnamel: allowed,
            disconnectedLookalike: disconnected,
            protectedSentinels: protected
        )
    }

    private func makeUniformBytes(red: UInt8, green: UInt8, blue: UInt8) -> [UInt8] {
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

    private func pixelIndex(x: Int, y: Int) -> Int {
        y * width + x
    }

    private func replacingRGB(
        in bytes: [UInt8],
        index: Int,
        with color: (UInt8, UInt8, UInt8)
    ) -> [UInt8] {
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
        Set((0..<(before.count / 4)).filter { index in
            rgb(before, at: index) != rgb(after, at: index)
        })
    }

    private func yellowExcess(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Double {
        max(0, (Double(red) + Double(green)) / (2 * 255) - Double(blue) / 255)
    }

    private func luminance(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Double {
        0.2126 * Double(red) / 255
            + 0.7152 * Double(green) / 255
            + 0.0722 * Double(blue) / 255
    }
}
