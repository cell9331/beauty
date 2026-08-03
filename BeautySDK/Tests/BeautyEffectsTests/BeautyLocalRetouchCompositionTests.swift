import BeautyCore
import BeautyEffects
import Foundation
import ImageIO
import XCTest

/// Wave 0 specification for the feature-neutral original-pixel composer.
///
/// The executable model below is test-local: it freezes independently authored
/// byte and aggregate oracles without importing a production blend helper. The
/// suite remains RED only while the named production artifact is absent.
final class BeautyLocalRetouchCompositionTests: XCTestCase {
    private static let source: [UInt8] = [
        10, 20, 30, 255, 40, 50, 60, 255, 70, 80, 90, 255,
        100, 110, 120, 255, 130, 140, 150, 255, 160, 170, 180, 255,
    ]
    private static let sourceBinding = 7

    private static let standaloneA: [UInt8] = [
        11, 121, 31, 255, 40, 50, 60, 255, 70, 80, 90, 255,
        100, 110, 120, 255, 130, 140, 150, 255, 160, 170, 180, 255,
    ]
    private static let standaloneB: [UInt8] = [
        10, 20, 30, 255, 40, 50, 60, 255, 170, 20, 190, 255,
        100, 110, 120, 255, 130, 140, 150, 255, 160, 170, 180, 255,
    ]
    private static let standaloneC: [UInt8] = [
        10, 20, 30, 255, 40, 50, 60, 255, 70, 80, 90, 255,
        100, 110, 120, 255, 0, 240, 250, 255, 160, 170, 180, 255,
    ]
    private static let independentlyMergedABC: [UInt8] = [
        11, 121, 31, 255, 40, 50, 60, 255, 170, 20, 190, 255,
        100, 110, 120, 255, 0, 240, 250, 255, 160, 170, 180, 255,
    ]

    func testProductionCompositionArtifactIsTheOnlyWave0RedDependency() {
        let testFile = URL(fileURLWithPath: #filePath)
        let repositoryRoot = testFile
            .deletingLastPathComponent() // BeautyEffectsTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // BeautySDK
            .deletingLastPathComponent() // repository
        let productionArtifact = repositoryRoot
            .appendingPathComponent("BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift")

        guard FileManager.default.fileExists(atPath: productionArtifact.path) else {
            XCTFail("RED_MISSING_ARTIFACT:BeautyLocalRetouchComposition.swift")
            return
        }
    }

    func testProductionExactCarrierBindingAndCheckedOffsetsRejectForeignWorkLocally() throws {
        let source = try productionCanonical(bytes: Self.source, width: 3, height: 2)
        let copiedSource = source
        let foreignSource = try productionCanonical(bytes: Self.source, width: 3, height: 2)

        XCTAssertEqual(source.pixelSourceBinding, copiedSource.pixelSourceBinding)
        XCTAssertNotEqual(source.pixelSourceBinding, foreignSource.pixelSourceBinding)

        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let foreignOwner = BeautyLocalRetouchCompositionOwner(source: foreignSource)
        let valid = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(0)]))
        let foreign = try XCTUnwrap(foreignOwner.makeUnit(proposals: [productionProposal(1)]))
        let negativeIndex = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(-1)]))
        let overflowingIndex = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(Int.max)]))

        let result = try owner.compose([foreign, negativeIndex, overflowingIndex, valid])
        var expected = Self.source
        expected.replaceSubrange(0..<3, with: [200, 201, 202])
        XCTAssertEqual(Array(result.canonicalImage.rgba8Data), expected)
        XCTAssertEqual(result.canonicalImage.metadata, source.metadata)
        XCTAssertEqual(
            result.summary,
            BeautyLocalRetouchCompositionSummary(
                acceptedUnitCount: 1,
                rejectedUnitCount: 3,
                ownedPixelCount: 1,
                changedPixelCount: 1
            )
        )
    }

    func testProductionIssuanceCapsDuplicateTokensAndRawDuplicatesPreserveValidSibling() throws {
        var pixels: [UInt8] = []
        for value in 0..<16 {
            pixels.append(contentsOf: [
                UInt8(value), UInt8(value + 1), UInt8(value + 2), UInt8.max,
            ])
        }
        let source = try productionCanonical(bytes: pixels, width: 16, height: 1)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)

        let duplicated = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(0)]))
        let rawDuplicate = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(1, hard: false, weight: 65_536),
            productionProposal(1, weight: 0),
        ]))
        let overBudget = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(2), productionProposal(3), productionProposal(4),
        ]))
        let valid = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(5)]))

        let result = try owner.compose([duplicated, duplicated, rawDuplicate, overBudget, valid])
        XCTAssertEqual(
            result.summary,
            BeautyLocalRetouchCompositionSummary(
                acceptedUnitCount: 1,
                rejectedUnitCount: 4,
                ownedPixelCount: 1,
                changedPixelCount: 1
            )
        )

        for index in 4..<8 {
            XCTAssertNotNil(owner.makeUnit(proposals: [productionProposal(index + 2)]))
        }
        XCTAssertNil(owner.makeUnit(proposals: [productionProposal(15)]))
    }

    func testQ16LiteralBlendAndAlpha() throws {
        let source = try productionCanonical(bytes: Self.source, width: 3, height: 2)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let midpoint = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(0, weight: 32_768, target: (11, 221, 31)),
        ]))
        let full = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(2, target: (170, 20, 190)),
        ]))
        let clamped = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(4, weight: UInt32.max, target: (0, 240, 250)),
        ]))
        let unchanged = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(5, target: (160, 170, 180)),
        ]))

        let midpointResult = try owner.compose([midpoint])
        XCTAssertEqual(Array(midpointResult.canonicalImage.rgba8Data), Self.standaloneA)
        XCTAssertEqual(
            midpointResult.summary,
            BeautyLocalRetouchCompositionSummary(
                acceptedUnitCount: 1,
                ownedPixelCount: 1,
                changedPixelCount: 1
            )
        )
        XCTAssertEqual(Array(try owner.compose([full]).canonicalImage.rgba8Data), Self.standaloneB)
        XCTAssertEqual(Array(try owner.compose([clamped]).canonicalImage.rgba8Data), Self.standaloneC)

        let unchangedResult = try owner.compose([unchanged])
        XCTAssertEqual(unchangedResult.canonicalImage.pixelSourceBinding, source.pixelSourceBinding)
        XCTAssertEqual(
            unchangedResult.summary,
            BeautyLocalRetouchCompositionSummary(acceptedUnitCount: 1, ownedPixelCount: 1)
        )
        XCTAssertEqual(
            stride(from: 3, to: midpointResult.canonicalImage.byteCount, by: 4)
                .map { midpointResult.canonicalImage.rgba8Data[$0] },
            [255, 255, 255, 255, 255, 255]
        )
    }

    func testHardReclipZeroWeightAndOutsideUnionIdentity() throws {
        let source = try productionCanonical(bytes: Self.source, width: 3, height: 2)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let hardFalse = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(1, hard: false, target: (255, 255, 255)),
        ]))
        let zeroWeight = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(3, weight: 0, target: (255, 255, 255)),
        ]))
        let accepted = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(0, weight: 32_768, target: (11, 221, 31)),
        ]))

        let result = try owner.compose([hardFalse, zeroWeight, accepted])
        XCTAssertEqual(Array(result.canonicalImage.rgba8Data), Self.standaloneA)
        XCTAssertEqual(
            result.summary,
            BeautyLocalRetouchCompositionSummary(
                acceptedUnitCount: 1,
                rejectedUnitCount: 2,
                ownedPixelCount: 1,
                changedPixelCount: 1
            )
        )
        XCTAssertEqual(
            Array(result.canonicalImage.rgba8Data[4..<Self.source.count]),
            Array(Self.source[4..<Self.source.count])
        )
    }

    func testStandaloneMergedFusedAndPermutedOutputs() throws {
        let source = try productionCanonical(bytes: Self.source, width: 3, height: 2)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let a = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(0, weight: 32_768, target: (11, 221, 31)),
        ]))
        let b = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(2, target: (170, 20, 190)),
        ]))
        let c = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(4, weight: UInt32.max, target: (0, 240, 250)),
        ]))

        XCTAssertEqual(Array(try owner.compose([a]).canonicalImage.rgba8Data), Self.standaloneA)
        XCTAssertEqual(Array(try owner.compose([b]).canonicalImage.rgba8Data), Self.standaloneB)
        XCTAssertEqual(Array(try owner.compose([c]).canonicalImage.rgba8Data), Self.standaloneC)

        let expectedSummary = BeautyLocalRetouchCompositionSummary(
            acceptedUnitCount: 3,
            ownedPixelCount: 3,
            changedPixelCount: 3
        )
        for units in [
            [a, b, c], [a, c, b], [b, a, c],
            [b, c, a], [c, a, b], [c, b, a],
        ] {
            let result = try owner.compose(units)
            XCTAssertEqual(Array(result.canonicalImage.rgba8Data), Self.independentlyMergedABC)
            XCTAssertEqual(result.summary, expectedSummary)
        }
    }

    func testProductionTwoAndThreeOwnerCollisionToSourceIsCountedOnce() throws {
        let sourceBytes = productionSixteenPixelSource()
        let source = try productionCanonical(bytes: sourceBytes, width: 16, height: 1)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let a = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(1, target: (210, 211, 212)),
            productionProposal(2, target: (171, 21, 191)),
        ]))
        let b = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(1, target: (220, 221, 222)),
            productionProposal(3, target: (201, 202, 203)),
        ]))
        let c = try XCTUnwrap(owner.makeUnit(proposals: [
            productionProposal(1, target: (230, 231, 232)),
            productionProposal(4, target: (1, 241, 251)),
        ]))

        var expectedTwo = sourceBytes
        expectedTwo.replaceSubrange(8..<11, with: [171, 21, 191])
        expectedTwo.replaceSubrange(12..<15, with: [201, 202, 203])
        let two = try owner.compose([b, a])
        XCTAssertEqual(Array(two.canonicalImage.rgba8Data), expectedTwo)
        XCTAssertEqual(
            two.summary,
            BeautyLocalRetouchCompositionSummary(
                acceptedUnitCount: 2,
                ownedPixelCount: 2,
                changedPixelCount: 2,
                collisionPixelCount: 1
            )
        )

        var expectedThree = expectedTwo
        expectedThree.replaceSubrange(16..<19, with: [1, 241, 251])
        for units in [[a, b, c], [c, b, a], [b, a, c]] {
            let result = try owner.compose(units)
            XCTAssertEqual(Array(result.canonicalImage.rgba8Data), expectedThree)
            XCTAssertEqual(
                result.summary,
                BeautyLocalRetouchCompositionSummary(
                    acceptedUnitCount: 3,
                    ownedPixelCount: 3,
                    changedPixelCount: 3,
                    collisionPixelCount: 1
                )
            )
        }

        let collisionOnly = try owner.compose([
            try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(5)])),
            try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(5)])),
        ])
        XCTAssertEqual(collisionOnly.canonicalImage.pixelSourceBinding, source.pixelSourceBinding)
        XCTAssertEqual(Array(collisionOnly.canonicalImage.rgba8Data), sourceBytes)
        XCTAssertEqual(
            collisionOnly.summary,
            BeautyLocalRetouchCompositionSummary(acceptedUnitCount: 2, collisionPixelCount: 1)
        )
    }

    func testProductionOpaqueFailureMatrixPreservesEveryAcceptedSibling() throws {
        let sourceBytes = productionSixteenPixelSource()
        let source = try productionCanonical(bytes: sourceBytes, width: 16, height: 1)
        let foreignSource = try productionCanonical(bytes: sourceBytes, width: 16, height: 1)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let foreignOwner = BeautyLocalRetouchCompositionOwner(source: foreignSource)
        let a = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(0, target: (11, 121, 31))]))
        let b = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(2, target: (170, 20, 190))]))
        let c = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(4, target: (0, 240, 250))]))
        let invalidA = try XCTUnwrap(foreignOwner.makeUnit(proposals: [productionProposal(0)]))
        let invalidB = try XCTUnwrap(foreignOwner.makeUnit(proposals: [productionProposal(2)]))
        let invalidC = try XCTUnwrap(foreignOwner.makeUnit(proposals: [productionProposal(4)]))
        let invalidFuture = try XCTUnwrap(foreignOwner.makeUnit(proposals: [productionProposal(6)]))

        var expectedA = sourceBytes
        expectedA.replaceSubrange(0..<3, with: [11, 121, 31])
        var expectedB = sourceBytes
        expectedB.replaceSubrange(8..<11, with: [170, 20, 190])
        var expectedC = sourceBytes
        expectedC.replaceSubrange(16..<19, with: [0, 240, 250])
        var expectedAB = expectedA
        expectedAB.replaceSubrange(8..<11, with: [170, 20, 190])
        var expectedAC = expectedA
        expectedAC.replaceSubrange(16..<19, with: [0, 240, 250])
        var expectedBC = expectedB
        expectedBC.replaceSubrange(16..<19, with: [0, 240, 250])
        var expectedABC = expectedAB
        expectedABC.replaceSubrange(16..<19, with: [0, 240, 250])

        XCTAssertEqual(Array(try owner.compose([invalidA, b, c]).canonicalImage.rgba8Data), expectedBC)
        XCTAssertEqual(Array(try owner.compose([a, invalidB, invalidC]).canonicalImage.rgba8Data), expectedA)
        XCTAssertEqual(Array(try owner.compose([a, invalidB, c]).canonicalImage.rgba8Data), expectedAC)
        XCTAssertEqual(Array(try owner.compose([a, b, invalidC]).canonicalImage.rgba8Data), expectedAB)
        let futureRejected = try owner.compose([a, b, c, invalidFuture])
        XCTAssertEqual(Array(futureRejected.canonicalImage.rgba8Data), expectedABC)
        XCTAssertEqual(
            futureRejected.summary,
            BeautyLocalRetouchCompositionSummary(
                acceptedUnitCount: 3,
                rejectedUnitCount: 1,
                ownedPixelCount: 3,
                changedPixelCount: 3
            )
        )
    }

    func testProductionEmptyAndValidInvalidValidCallsRetainNoState() throws {
        let sourceBytes = productionSixteenPixelSource()
        let source = try productionCanonical(bytes: sourceBytes, width: 16, height: 1)
        let foreignSource = try productionCanonical(bytes: sourceBytes, width: 16, height: 1)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let foreignOwner = BeautyLocalRetouchCompositionOwner(source: foreignSource)
        let a = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(0, target: (11, 121, 31))]))
        let b = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(2, target: (170, 20, 190))]))
        let c = try XCTUnwrap(owner.makeUnit(proposals: [productionProposal(4, target: (0, 240, 250))]))
        let invalidA = try XCTUnwrap(foreignOwner.makeUnit(proposals: [productionProposal(0)]))
        let invalidB = try XCTUnwrap(foreignOwner.makeUnit(proposals: [productionProposal(2)]))
        let invalidC = try XCTUnwrap(foreignOwner.makeUnit(proposals: [productionProposal(4)]))

        var expected = sourceBytes
        expected.replaceSubrange(0..<3, with: [11, 121, 31])
        expected.replaceSubrange(8..<11, with: [170, 20, 190])
        expected.replaceSubrange(16..<19, with: [0, 240, 250])

        let empty = try owner.compose([])
        let first = try owner.compose([a, b, c])
        let middle = try owner.compose([invalidA, invalidB, invalidC])
        let third = try owner.compose([c, a, b])
        XCTAssertEqual(empty.canonicalImage.pixelSourceBinding, source.pixelSourceBinding)
        XCTAssertEqual(empty.summary, BeautyLocalRetouchCompositionSummary())
        XCTAssertEqual(Array(first.canonicalImage.rgba8Data), expected)
        XCTAssertEqual(Array(middle.canonicalImage.rgba8Data), sourceBytes)
        XCTAssertEqual(middle.summary, BeautyLocalRetouchCompositionSummary(rejectedUnitCount: 3))
        XCTAssertEqual(Array(third.canonicalImage.rgba8Data), expected)
        XCTAssertEqual(third.summary, first.summary)
    }

    func testQ16EndpointsMidpointClampRoundHalfUpAndSourceAlphaAreLiteral() throws {
        let zero = try compose([
            unit("A", proposals: [proposal(0, weight: 0, target: (255, 255, 255))]),
        ])
        XCTAssertEqual(zero.bytes, Self.source)
        XCTAssertEqual(zero.summary, Summary(acceptedUnitCount: 0, rejectedUnitCount: 1))

        let midpoint = try compose([unitA()])
        XCTAssertEqual(midpoint.bytes, Self.standaloneA)
        XCTAssertEqual(Array(midpoint.bytes[0...3]), [11, 121, 31, 255])

        let full = try compose([unitB()])
        XCTAssertEqual(full.bytes, Self.standaloneB)
        XCTAssertEqual(Array(full.bytes[8...11]), [170, 20, 190, 255])

        let clamped = try compose([unitC()])
        XCTAssertEqual(clamped.bytes, Self.standaloneC)
        XCTAssertEqual(Array(clamped.bytes[16...19]), [0, 240, 250, 255])
        XCTAssertEqual(stride(from: 3, to: clamped.bytes.count, by: 4).map { clamped.bytes[$0] },
                       [255, 255, 255, 255, 255, 255])
    }

    func testExactSourceBindingRejectsForeignSameSizeSameByteCarrierLocally() throws {
        let foreign = unit(
            "foreign",
            sourceBinding: Self.sourceBinding + 1,
            proposals: [proposal(1, weight: 65_536, target: (255, 255, 255))]
        )
        let result = try compose([foreign, unitA()])

        XCTAssertEqual(result.bytes, Self.standaloneA)
        XCTAssertEqual(
            result.summary,
            Summary(acceptedUnitCount: 1, rejectedUnitCount: 1, ownedPixelCount: 1, changedPixelCount: 1)
        )
    }

    func testCheckedDimensionsRowBytesByteCountAndIndexRelationsRejectOnlyInvalidUnit() throws {
        let invalidUnits = [
            unit("width", width: Int.max, proposals: [proposal(1)]),
            unit("height", height: Int.max, proposals: [proposal(1)]),
            unit("row", rowBytes: Int.max, proposals: [proposal(1)]),
            unit("bytes", declaredByteCount: Int.max, proposals: [proposal(1)]),
            unit("negative", proposals: [proposal(-1)]),
            unit("outside", proposals: [proposal(6)]),
            unit("offset", proposals: [proposal(Int.max)]),
            unit("count", declaredRawClaimCount: Int.max, proposals: [proposal(1)]),
        ]

        for invalid in invalidUnits {
            let result = try compose([invalid, unitA()])
            XCTAssertEqual(result.bytes, Self.standaloneA)
            XCTAssertEqual(result.summary.acceptedUnitCount, 1)
            XCTAssertEqual(result.summary.rejectedUnitCount, 1)
        }
    }

    func testHardFalsePositiveWeightAndZeroWeightAreUnownedOutsideUnionIdentity() throws {
        let result = try compose([
            unit("hard-false", proposals: [proposal(1, hard: false, weight: 65_536)]),
            unit("zero", proposals: [proposal(3, weight: 0)]),
            unitA(),
        ])

        XCTAssertEqual(result.bytes, Self.standaloneA)
        XCTAssertEqual(
            result.summary,
            Summary(acceptedUnitCount: 1, rejectedUnitCount: 2, ownedPixelCount: 1, changedPixelCount: 1)
        )
        XCTAssertEqual(Array(result.bytes[4...23]), Array(Self.source[4...23]))
    }

    func testDuplicateRawIndexBeforeFilteringRejectsUnitAndRetainsValidSibling() throws {
        let duplicate = unit("duplicate", proposals: [
            proposal(1, hard: false, weight: 65_536),
            proposal(1, weight: 0),
        ])
        let result = try compose([duplicate, unitB()])

        XCTAssertEqual(result.bytes, Self.standaloneB)
        XCTAssertEqual(
            result.summary,
            Summary(acceptedUnitCount: 1, rejectedUnitCount: 1, ownedPixelCount: 1, changedPixelCount: 1)
        )
    }

    func testDuplicateOpaqueUnitTokenRejectsEveryCopyAndRetainsValidSibling() throws {
        let duplicated = unitA()
        let result = try compose([duplicated, duplicated, unitC()])

        XCTAssertEqual(result.bytes, Self.standaloneC)
        XCTAssertEqual(
            result.summary,
            Summary(acceptedUnitCount: 1, rejectedUnitCount: 2, ownedPixelCount: 1, changedPixelCount: 1)
        )
    }

    func testTwoAndThreeOwnerCollisionCountOncePreserveSourceAndComposeAdjacentWork() throws {
        let a = unit("A", proposals: [
            proposal(1, weight: 65_536, target: (210, 211, 212)),
            proposal(2, weight: 65_536, target: (171, 21, 191)),
        ])
        let b = unit("B", proposals: [
            proposal(1, weight: 65_536, target: (220, 221, 222)),
            proposal(3, weight: 65_536, target: (201, 202, 203)),
        ])
        let c = unit("C", proposals: [
            proposal(1, weight: 65_536, target: (230, 231, 232)),
            proposal(4, weight: 65_536, target: (1, 241, 251)),
        ])
        let expectedTwo: [UInt8] = [
            10, 20, 30, 255, 40, 50, 60, 255, 171, 21, 191, 255,
            201, 202, 203, 255, 130, 140, 150, 255, 160, 170, 180, 255,
        ]
        let expectedThree: [UInt8] = [
            10, 20, 30, 255, 40, 50, 60, 255, 171, 21, 191, 255,
            201, 202, 203, 255, 1, 241, 251, 255, 160, 170, 180, 255,
        ]

        let two = try compose([a, b])
        XCTAssertEqual(two.bytes, expectedTwo)
        XCTAssertEqual(
            two.summary,
            Summary(acceptedUnitCount: 2, ownedPixelCount: 2, changedPixelCount: 2, collisionPixelCount: 1)
        )

        let three = try compose([a, b, c])
        XCTAssertEqual(three.bytes, expectedThree)
        XCTAssertEqual(
            three.summary,
            Summary(acceptedUnitCount: 3, ownedPixelCount: 3, changedPixelCount: 3, collisionPixelCount: 1)
        )
    }

    func testStandaloneIndependentMergeFusedReverseAndEveryPermutationAreEqual() throws {
        XCTAssertEqual(try compose([unitA()]).bytes, Self.standaloneA)
        XCTAssertEqual(try compose([unitB()]).bytes, Self.standaloneB)
        XCTAssertEqual(try compose([unitC()]).bytes, Self.standaloneC)

        let expectedSummary = Summary(
            acceptedUnitCount: 3,
            ownedPixelCount: 3,
            changedPixelCount: 3
        )
        let permutations = [
            [unitA(), unitB(), unitC()],
            [unitA(), unitC(), unitB()],
            [unitB(), unitA(), unitC()],
            [unitB(), unitC(), unitA()],
            [unitC(), unitA(), unitB()],
            [unitC(), unitB(), unitA()],
        ]

        for units in permutations {
            let result = try compose(units)
            XCTAssertEqual(result.bytes, Self.independentlyMergedABC)
            XCTAssertEqual(result.summary, expectedSummary)
        }
    }

    func testOpaqueWholePairSubunitAndFutureBandAbstentionMatrix() throws {
        let aRejected = try compose([invalid(unitA()), unitB(), unitC()])
        let pairBCRejected = try compose([unitA(), invalid(unitB()), invalid(unitC())])
        let bRejected = try compose([unitA(), invalid(unitB()), unitC()])
        let cRejected = try compose([unitA(), unitB(), invalid(unitC())])
        let futureBandRejected = try compose([unitA(), unitB(), unitC(), invalid(unitD())])

        let expectedBC: [UInt8] = [
            10, 20, 30, 255, 40, 50, 60, 255, 170, 20, 190, 255,
            100, 110, 120, 255, 0, 240, 250, 255, 160, 170, 180, 255,
        ]
        let expectedAC: [UInt8] = [
            11, 121, 31, 255, 40, 50, 60, 255, 70, 80, 90, 255,
            100, 110, 120, 255, 0, 240, 250, 255, 160, 170, 180, 255,
        ]
        let expectedAB: [UInt8] = [
            11, 121, 31, 255, 40, 50, 60, 255, 170, 20, 190, 255,
            100, 110, 120, 255, 130, 140, 150, 255, 160, 170, 180, 255,
        ]

        XCTAssertEqual(aRejected.bytes, expectedBC)
        XCTAssertEqual(pairBCRejected.bytes, Self.standaloneA)
        XCTAssertEqual(bRejected.bytes, expectedAC)
        XCTAssertEqual(cRejected.bytes, expectedAB)
        XCTAssertEqual(futureBandRejected.bytes, Self.independentlyMergedABC)
        XCTAssertEqual(futureBandRejected.summary.rejectedUnitCount, 1)
    }

    func testEmptyAndValidInvalidValidRequestsRetainNoBytesClaimsOrSummary() throws {
        let empty = try compose([])
        let first = try compose([unitA(), unitB(), unitC()])
        let middle = try compose([invalid(unitA()), invalid(unitB()), invalid(unitC())])
        let third = try compose([unitA(), unitB(), unitC()])

        XCTAssertEqual(empty.bytes, Self.source)
        XCTAssertEqual(empty.summary, Summary())
        XCTAssertEqual(first.bytes, Self.independentlyMergedABC)
        XCTAssertEqual(middle.bytes, Self.source)
        XCTAssertEqual(middle.summary, Summary(rejectedUnitCount: 3))
        XCTAssertEqual(third.bytes, Self.independentlyMergedABC)
        XCTAssertEqual(third.summary, first.summary)
    }

    func testAggregateObservationHasExactSixFieldAllowlist() {
        let labels = Set(Mirror(reflecting: Summary()).children.compactMap(\.label))
        XCTAssertEqual(labels, [
            "acceptedUnitCount",
            "rejectedUnitCount",
            "ownedPixelCount",
            "changedPixelCount",
            "changedOutsideUnionPixelCount",
            "collisionPixelCount",
        ])
        let productionLabels = Set(
            Mirror(reflecting: BeautyLocalRetouchCompositionSummary()).children.compactMap(\.label)
        )
        XCTAssertEqual(productionLabels, labels)
    }
}

private extension BeautyLocalRetouchCompositionTests {
    func productionCanonical(
        bytes: [UInt8],
        width: Int,
        height: Int
    ) throws -> BeautyCanonicalStillImage {
        try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes),
            width: width,
            height: height,
            rowBytes: width * 4,
            metadata: BeautyInputMetadata(
                orientation: .up,
                source: .testFixture
            )
        )
    }

    func productionSixteenPixelSource() -> [UInt8] {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(64)
        for value in 0..<16 {
            bytes.append(UInt8(value))
            bytes.append(UInt8(value + 1))
            bytes.append(UInt8(value + 2))
            bytes.append(UInt8.max)
        }
        return bytes
    }

    func productionProposal(
        _ pixelIndex: Int,
        hard: Bool = true,
        weight: UInt32 = 65_536,
        target: (UInt8, UInt8, UInt8) = (200, 201, 202)
    ) -> BeautyLocalPixelProposal {
        BeautyLocalPixelProposal(
            pixelIndex: pixelIndex,
            isInsideHardEnvelope: hard,
            softWeightQ16: weight,
            targetRed: target.0,
            targetGreen: target.1,
            targetBlue: target.2
        )
    }

    struct Proposal {
        let rawIndex: Int
        let isInsideHardEnvelope: Bool
        let softWeightQ16: UInt32
        let target: (UInt8, UInt8, UInt8)
    }

    struct Unit {
        let token: String
        let sourceBinding: Int
        let width: Int
        let height: Int
        let rowBytes: Int
        let declaredByteCount: Int
        let declaredRawClaimCount: Int
        let proposals: [Proposal]
    }

    struct Summary: Equatable {
        var acceptedUnitCount = 0
        var rejectedUnitCount = 0
        var ownedPixelCount = 0
        var changedPixelCount = 0
        var changedOutsideUnionPixelCount = 0
        var collisionPixelCount = 0
    }

    struct Result {
        let bytes: [UInt8]
        let summary: Summary
    }

    enum ReferenceError: Error {
        case invalidCanonicalSource
    }

    func proposal(
        _ rawIndex: Int,
        hard: Bool = true,
        weight: UInt32 = 65_536,
        target: (UInt8, UInt8, UInt8) = (200, 201, 202)
    ) -> Proposal {
        Proposal(
            rawIndex: rawIndex,
            isInsideHardEnvelope: hard,
            softWeightQ16: weight,
            target: target
        )
    }

    func unit(
        _ token: String,
        sourceBinding: Int = 7,
        width: Int = 3,
        height: Int = 2,
        rowBytes: Int = 12,
        declaredByteCount: Int = 24,
        declaredRawClaimCount: Int? = nil,
        proposals: [Proposal]
    ) -> Unit {
        Unit(
            token: token,
            sourceBinding: sourceBinding,
            width: width,
            height: height,
            rowBytes: rowBytes,
            declaredByteCount: declaredByteCount,
            declaredRawClaimCount: declaredRawClaimCount ?? proposals.count,
            proposals: proposals
        )
    }

    func unitA() -> Unit {
        unit("A", proposals: [proposal(0, weight: 32_768, target: (11, 221, 31))])
    }

    func unitB() -> Unit {
        unit("B", proposals: [proposal(2, weight: 65_536, target: (170, 20, 190))])
    }

    func unitC() -> Unit {
        unit("C", proposals: [proposal(4, weight: UInt32.max, target: (0, 240, 250))])
    }

    func unitD() -> Unit {
        unit("D", proposals: [proposal(5, weight: 65_536, target: (10, 11, 12))])
    }

    func invalid(_ unit: Unit) -> Unit {
        self.unit(
            unit.token,
            sourceBinding: unit.sourceBinding + 1,
            width: unit.width,
            height: unit.height,
            rowBytes: unit.rowBytes,
            declaredByteCount: unit.declaredByteCount,
            declaredRawClaimCount: unit.declaredRawClaimCount,
            proposals: unit.proposals
        )
    }

    func compose(_ units: [Unit]) throws -> Result {
        let width = 3
        let height = 2
        let (rowBytes, rowOverflow) = width.multipliedReportingOverflow(by: 4)
        let (byteCount, byteOverflow) = rowBytes.multipliedReportingOverflow(by: height)
        guard !rowOverflow, !byteOverflow, rowBytes == 12, byteCount == Self.source.count else {
            throw ReferenceError.invalidCanonicalSource
        }

        var summary = Summary()
        let tokenFrequency = Dictionary(grouping: units, by: \.token).mapValues(\.count)
        var accepted: [(String, [Proposal])] = []

        for unit in units {
            guard tokenFrequency[unit.token] == 1,
                  unit.sourceBinding == Self.sourceBinding,
                  unit.width == width,
                  unit.height == height,
                  unit.rowBytes == rowBytes,
                  unit.declaredByteCount == byteCount,
                  unit.declaredRawClaimCount == unit.proposals.count,
                  !unit.proposals.isEmpty
            else {
                summary.rejectedUnitCount += 1
                continue
            }

            var rawIndices = Set<Int>()
            var effective: [Proposal] = []
            var isStructurallyValid = true
            for proposal in unit.proposals {
                let (_, offsetOverflow) = proposal.rawIndex.multipliedReportingOverflow(by: 4)
                guard proposal.rawIndex >= 0,
                      proposal.rawIndex < width * height,
                      !offsetOverflow,
                      rawIndices.insert(proposal.rawIndex).inserted
                else {
                    isStructurallyValid = false
                    break
                }
                if proposal.isInsideHardEnvelope, proposal.softWeightQ16 > 0 {
                    effective.append(proposal)
                }
            }

            guard isStructurallyValid, !effective.isEmpty else {
                summary.rejectedUnitCount += 1
                continue
            }
            accepted.append((unit.token, effective.sorted { $0.rawIndex < $1.rawIndex }))
            summary.acceptedUnitCount += 1
        }

        var output = Self.source
        let claims = Dictionary(grouping: accepted.flatMap(\.1), by: \.rawIndex)
        for rawIndex in claims.keys.sorted() {
            guard let proposals = claims[rawIndex] else { continue }
            guard proposals.count == 1, let proposal = proposals.first else {
                summary.collisionPixelCount += 1
                continue
            }

            let offset = rawIndex * 4
            let sourcePixel = (Self.source[offset], Self.source[offset + 1], Self.source[offset + 2])
            let weight = UInt64(min(proposal.softWeightQ16, 65_536))
            let target = proposal.target
            let blended: [UInt8] = [
                Self.referenceBlend(source: sourcePixel.0, target: target.0, weight: weight),
                Self.referenceBlend(source: sourcePixel.1, target: target.1, weight: weight),
                Self.referenceBlend(source: sourcePixel.2, target: target.2, weight: weight),
            ]
            summary.ownedPixelCount += 1
            if blended != Array(Self.source[offset..<(offset + 3)]) {
                summary.changedPixelCount += 1
            }
            output.replaceSubrange(offset..<(offset + 3), with: blended)
        }

        return Result(bytes: output, summary: summary)
    }

    static func referenceBlend(source: UInt8, target: UInt8, weight: UInt64) -> UInt8 {
        let numerator = UInt64(source) * (65_536 - weight) + UInt64(target) * weight + 32_768
        return UInt8(numerator / 65_536)
    }
}
