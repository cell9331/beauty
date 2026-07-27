import XCTest
import Dispatch
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

private final class Phase52RequestSignal: @unchecked Sendable {
    private let lock = NSLock()
    let expectation: XCTestExpectation
    private var storedCount = 0

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    var count: Int {
        lock.withLock { storedCount }
    }

    func signal() {
        lock.withLock {
            storedCount += 1
        }
        expectation.fulfill()
    }
}

private final class Phase52ProviderBarrier: @unchecked Sendable {
    let entered: Phase52RequestSignal
    private let releaseSemaphore = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var storedReleaseCount = 0
    private var storedWaitTimedOut = false

    init(enteredExpectation: XCTestExpectation) {
        self.entered = Phase52RequestSignal(expectation: enteredExpectation)
    }

    var releaseCount: Int {
        lock.withLock { storedReleaseCount }
    }

    var waitTimedOut: Bool {
        lock.withLock { storedWaitTimedOut }
    }

    func enterAndWaitForRelease() {
        entered.signal()
        if releaseSemaphore.wait(timeout: .now() + .seconds(30)) == .timedOut {
            lock.withLock { storedWaitTimedOut = true }
        }
    }

    func release() {
        let shouldSignal = lock.withLock {
            guard storedReleaseCount == 0 else {
                return false
            }
            storedReleaseCount = 1
            return true
        }
        if shouldSignal {
            releaseSemaphore.signal()
        }
    }
}

private actor Phase52AsyncGate {
    private var isReleased = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func wait() async {
        guard !isReleased else {
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func release() {
        guard !isReleased else {
            return
        }
        isReleased = true
        let waitingContinuations = waiters
        waiters.removeAll()
        for continuation in waitingContinuations {
            continuation.resume()
        }
    }
}

private struct Phase52RequestSnapshot: Sendable {
    let identity: Int
    let fieldName: String
    let effectiveStrength: Float
    let warningCodes: [String]
    let eyebrowActive: Bool
    let eyebrowSkipped: Bool
    let activeCount: Double
    let skippedEyebrowCount: Double
    let geometryPointCount: Double
}

private enum Phase46DegradationSupportClass: Equatable {
    case contour
    case contourAndCenterline
}

private enum Phase46DegradationEmissionPath {
    case face(KeyPath<FaceShapeWarpFieldEmissions, [WarpControlPoint]>)
    case chin(KeyPath<ChinWarpFieldEmissions, [WarpControlPoint]>)

    func points(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> [WarpControlPoint] {
        switch self {
        case let .face(keyPath):
            return FaceShapeWarpProvider()
                .fieldEmissions(face: face, strengths: strengths)[keyPath: keyPath]
        case let .chin(keyPath):
            return ChinWarpProvider()
                .fieldEmissions(face: face, strengths: strengths)[keyPath: keyPath]
        }
    }
}

private struct Phase46DegradationFieldRow {
    let name: String
    let parameter: WritableKeyPath<BeautyParameters, Float>
    let effective: KeyPath<BeautyEffectiveStrengths, Float>
    let emission: Phase46DegradationEmissionPath
    let requiredSupport: Phase46DegradationSupportClass
}

private enum Phase48FaceSupportClass: Equatable {
    case compatibility
    case contour
    case contourAndCenterline
}

private struct Phase48FaceFieldRow {
    let name: String
    let parameter: WritableKeyPath<BeautyParameters, Float>
    let effective: KeyPath<BeautyEffectiveStrengths, Float>
    let emission: Phase46DegradationEmissionPath
    let requiredSupport: Phase48FaceSupportClass
    let requestedValue: Float
}

final class MissingLandmarkDegradationTests: XCTestCase {
    func testGEOMRepresentativeSupportAndFreshnessDegradationMatrix() {
        let parameters = phase46AllRequestedParameters
        let completeFace = FaceGeometry.phase46AsymmetricComplete
        let complete = BeautyEffectResolver.resolve(
            parameters: parameters,
            faceGeometry: completeFace
        )

        for row in phase46DegradationRows {
            XCTAssertEqual(
                complete.effectiveStrengths[keyPath: row.effective],
                0.25,
                accuracy: 0.000_001,
                "complete \(row.name)"
            )
            XCTAssertFalse(
                row.emission.points(
                    face: completeFace,
                    strengths: complete.effectiveStrengths
                ).isEmpty,
                "complete \(row.name)"
            )
        }
        XCTAssertTrue(complete.activeDomains.contains(.faceShape))
        XCTAssertFalse(complete.skippedDomains.contains(.faceShape))

        for (name, face) in [
            ("contour only", FaceGeometry.phase46ContourOnly),
            ("centerline missing", .phase46CenterlineMissing),
            ("centerline malformed", .phase46CenterlineIneligible),
        ] {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            for row in phase46DegradationRows {
                let expected: Float = row.requiredSupport == .contour ? 0.25 : 0
                XCTAssertEqual(
                    plan.effectiveStrengths[keyPath: row.effective],
                    expected,
                    accuracy: 0.000_001,
                    "\(name) \(row.name)"
                )
                XCTAssertEqual(
                    row.emission.points(face: face, strengths: plan.effectiveStrengths).isEmpty,
                    expected == 0,
                    "\(name) \(row.name)"
                )
            }
            XCTAssertTrue(plan.activeDomains.contains(.faceShape), name)
            XCTAssertFalse(plan.skippedDomains.contains(.faceShape), name)
            assertRedacted(plan)
        }

        var shippedAndNew = parameters
        for row in phase46DegradationRows {
            shippedAndNew[keyPath: row.parameter] = 0.25
        }
        shippedAndNew.faceSlim = 0.20
        shippedAndNew.chinLength = -0.20
        let shippedOnly = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 0.20, chinLength: -0.20),
            faceGeometry: .phase46LegacyProxyOnly
        )
        let proxyOnly = BeautyEffectResolver.resolve(
            parameters: shippedAndNew,
            faceGeometry: .phase46LegacyProxyOnly
        )
        for row in phase46DegradationRows {
            XCTAssertEqual(
                proxyOnly.effectiveStrengths[keyPath: row.effective],
                0,
                "proxy-only \(row.name)"
            )
            XCTAssertTrue(
                row.emission.points(
                    face: .phase46LegacyProxyOnly,
                    strengths: proxyOnly.effectiveStrengths
                ).isEmpty,
                "proxy-only \(row.name)"
            )
        }
        let faceProvider = FaceShapeWarpProvider()
        let chinProvider = ChinWarpProvider()
        XCTAssertEqual(
            faceProvider.fieldEmissions(
                face: .phase46LegacyProxyOnly,
                strengths: proxyOnly.effectiveStrengths
            ).faceSlim,
            faceProvider.fieldEmissions(
                face: .phase46LegacyProxyOnly,
                strengths: shippedOnly.effectiveStrengths
            ).faceSlim
        )
        XCTAssertEqual(
            chinProvider.fieldEmissions(
                face: .phase46LegacyProxyOnly,
                strengths: proxyOnly.effectiveStrengths
            ).chinLength,
            chinProvider.fieldEmissions(
                face: .phase46LegacyProxyOnly,
                strengths: shippedOnly.effectiveStrengths
            ).chinLength
        )
        XCTAssertEqual(proxyOnly.activeDomains, shippedOnly.activeDomains)
        XCTAssertEqual(proxyOnly.skippedDomains, shippedOnly.skippedDomains)
        XCTAssertEqual(proxyOnly.metrics, shippedOnly.metrics)

        let staleFace = phase46Face(completeFace, freshness: .stale)
        for (name, face) in [("no face", Optional<FaceGeometry>.none), ("stale", staleFace)] {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            for row in phase46DegradationRows {
                XCTAssertEqual(
                    plan.effectiveStrengths[keyPath: row.effective],
                    0,
                    "\(name) \(row.name)"
                )
                if let face {
                    XCTAssertTrue(
                        row.emission.points(face: face, strengths: plan.effectiveStrengths).isEmpty,
                        "\(name) \(row.name)"
                    )
                }
            }
            XCTAssertFalse(plan.activeDomains.contains(.faceShape), name)
            XCTAssertTrue(plan.skippedDomains.contains(.faceShape), name)
            XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"], name)
            assertRedacted(plan)
        }
    }

    func testGEOMFreshReusedStaleFreshTransitionsCarryNoPriorFaceWork() {
        let parameters = phase46AllRequestedParameters
        let completeFace = FaceGeometry.phase46AsymmetricComplete
        let reusedFace = phase46Face(completeFace, freshness: .reused)
        let staleFace = phase46Face(completeFace, freshness: .stale)

        let fresh = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: completeFace)
        let reused = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: reusedFace)
        let stale = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: staleFace)
        let freshAgain = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: completeFace)

        for row in phase46DegradationRows {
            XCTAssertEqual(
                reused.effectiveStrengths[keyPath: row.effective],
                0.125,
                accuracy: 0.000_001,
                "reused \(row.name) must be cap × 0.5 before any combined scale"
            )
            XCTAssertFalse(
                row.emission.points(
                    face: reusedFace,
                    strengths: reused.effectiveStrengths
                ).isEmpty,
                "reused \(row.name)"
            )
            XCTAssertEqual(stale.effectiveStrengths[keyPath: row.effective], 0, "stale \(row.name)")
            XCTAssertTrue(
                row.emission.points(
                    face: staleFace,
                    strengths: stale.effectiveStrengths
                ).isEmpty,
                "stale \(row.name)"
            )
        }
        XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5)
        XCTAssertFalse(stale.activeDomains.contains(.faceShape))
        XCTAssertTrue(stale.skippedDomains.contains(.faceShape))
        XCTAssertEqual(freshAgain, fresh)
        XCTAssertEqual(
            phase46NamedPoints(face: completeFace, strengths: freshAgain.effectiveStrengths),
            phase46NamedPoints(face: completeFace, strengths: fresh.effectiveStrengths)
        )
        assertRedacted(fresh)
        assertRedacted(reused)
        assertRedacted(stale)
        assertRedacted(freshAgain)
    }

    func testSAFE01CompleteNineFieldFaceTransitionsAreFieldLocalAndStateless() {
        let parameters = phase48AllFaceParameters
        let freshFace = FaceGeometry.phase46AsymmetricComplete
        let reusedFace = phase46Face(freshFace, freshness: .reused)
        let staleFace = phase46Face(freshFace, freshness: .stale)
        let fresh = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: freshFace)
        let reused = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: reusedFace)
        let stale = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: staleFace)
        let noFace = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: nil)
        let freshAgain = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: freshFace)

        XCTAssertEqual(phase48FaceRows.count, 9)
        XCTAssertEqual(Set(phase48FaceRows.map(\.name)).count, 9)
        for row in phase48FaceRows {
            XCTAssertEqual(
                fresh.effectiveStrengths[keyPath: row.effective],
                row.requestedValue,
                accuracy: 0.000_001,
                "fresh \(row.name)"
            )
            XCTAssertFalse(
                row.emission.points(face: freshFace, strengths: fresh.effectiveStrengths).isEmpty,
                "fresh \(row.name)"
            )
            XCTAssertEqual(
                reused.effectiveStrengths[keyPath: row.effective],
                row.requestedValue * 0.5,
                accuracy: 0.000_001,
                "reused \(row.name)"
            )
            XCTAssertFalse(
                row.emission.points(face: reusedFace, strengths: reused.effectiveStrengths).isEmpty,
                "reused \(row.name)"
            )
        }
        XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5)

        for (name, plan) in [("stale", stale), ("no face", noFace)] {
            XCTAssertFalse(plan.activeDomains.contains(.faceShape), name)
            XCTAssertTrue(plan.skippedDomains.contains(.faceShape), name)
            XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"], name)
            for row in phase48FaceRows where row.requiredSupport != .compatibility {
                XCTAssertEqual(
                    plan.effectiveStrengths[keyPath: row.effective],
                    0,
                    "\(name) \(row.name)"
                )
            }
        }

        let supportCases: [(String, FaceGeometry)] = [
            ("observed contour missing", .phase46LegacyProxyOnly),
            ("observed contour malformed", .phase48MalformedObservedContour),
            ("centerline missing", .phase46CenterlineMissing),
            ("centerline malformed", .phase46CenterlineIneligible),
        ]
        for (name, face) in supportCases {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            for row in phase48FaceRows {
                let shouldEmit: Bool
                switch row.requiredSupport {
                case .compatibility:
                    shouldEmit = true
                case .contour:
                    shouldEmit = name.hasPrefix("centerline")
                case .contourAndCenterline:
                    shouldEmit = false
                }
                XCTAssertEqual(
                    plan.effectiveStrengths[keyPath: row.effective] != 0,
                    shouldEmit,
                    "\(name) \(row.name)"
                )
                XCTAssertEqual(
                    row.emission.points(face: face, strengths: plan.effectiveStrengths).isEmpty,
                    !shouldEmit,
                    "\(name) \(row.name)"
                )
            }
            XCTAssertTrue(plan.activeDomains.contains(.faceShape), name)
            XCTAssertFalse(plan.skippedDomains.contains(.faceShape), name)
            assertRedacted(plan)
        }

        XCTAssertEqual(freshAgain, fresh)
        XCTAssertEqual(
            phase46NamedPoints(face: freshFace, strengths: freshAgain.effectiveStrengths),
            phase46NamedPoints(face: freshFace, strengths: fresh.effectiveStrengths)
        )
        for plan in [fresh, reused, stale, noFace, freshAgain] {
            assertRedacted(plan)
        }
    }

    func testGEOMProviderEmptyNewFieldPreservesValidShippedSibling() {
        let face = FaceGeometry.phase46LocallyStraightContour
        let parameters = BeautyParameters(faceSlim: 0.20, faceContourSmooth: 0.25)
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
        let faceEmissions = FaceShapeWarpProvider().fieldEmissions(
            face: face,
            strengths: plan.effectiveStrengths
        )
        let chinEmissions = ChinWarpProvider().fieldEmissions(
            face: face,
            strengths: plan.effectiveStrengths
        )

        XCTAssertEqual(plan.effectiveStrengths.faceContourSmooth, 0)
        XCTAssertTrue(faceEmissions.faceContourSmooth.isEmpty)
        XCTAssertEqual(plan.effectiveStrengths.faceSlim, 0.20, accuracy: 0.000_001)
        XCTAssertFalse(faceEmissions.faceSlim.isEmpty)
        XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        XCTAssertFalse(plan.skippedDomains.contains(.faceShape))
        XCTAssertFalse(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
        XCTAssertFalse(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertNil(plan.metrics["beauty.effects.geometryStrengthScale"])
        XCTAssertNil(plan.metrics["beauty.effects.weakenedCount"])

        let expectedPoints = faceEmissions.points + chinEmissions.points
        XCTAssertEqual(expectedPoints, faceEmissions.faceSlim)
        XCTAssertEqual(
            BeautyGeometryEffectPipeline.controlPoints(
                for: plan.effectiveStrengths,
                face: face
            ),
            expectedPoints
        )
        XCTAssertEqual(
            plan.metrics["beauty.effects.geometryPointCount"],
            Double(expectedPoints.count)
        )
        assertRedacted(plan)
    }

    func testMissingEitherEyeGroupSkipsEyesZerosStrengthsAndKeepsOtherDomainsActive() {
        for face in [FaceGeometry.missingLeftEye, .missingRightEye] {
            let plan = BeautyEffectResolver.resolve(
                parameters: BeautyParameters(
                    brightness: 0.2,
                    eyeSize: 1,
                    eyeDistance: -1,
                    eyeYPosition: 1,
                    eyeTailLift: 1,
                    noseSlim: 0.2,
                    mouthSize: 0.2,
                    filterId: "soft_clean",
                    filterIntensity: 0.5
                ),
                faceGeometry: face
            )

            XCTAssertFalse(plan.activeDomains.contains(.eyes))
            XCTAssertTrue(plan.skippedDomains.contains(.eyes))
            XCTAssertTrue(plan.activeDomains.isSuperset(of: [.nose, .mouth, .color, .filter]))
            assertEyeStrengthsAreZero(plan)
            XCTAssertEqual(plan.metrics["beauty.effects.skippedEyeDomains"], 1)
            XCTAssertTrue(plan.warnings.contains {
                $0.code == "eye_inputs_missing" && $0.message == "Eye effects skipped: inputs incomplete."
            })
            assertRedacted(plan)
            assertNoEyeSideOrRawGeometryDisclosure(plan)
        }
    }

    func testObservedContourMissingEitherSideCannotReactivateCompleteEyeDomain() {
        let bounds = CoordinateRect(x: 0.10, y: 0.10, width: 0.80, height: 0.80)
        let left = BeautyObservedEyeSupport(
            side: .left,
            contour: [
                CoordinatePoint(x: 0.30, y: 0.43), CoordinatePoint(x: 0.34, y: 0.40),
                CoordinatePoint(x: 0.42, y: 0.40), CoordinatePoint(x: 0.46, y: 0.43),
                CoordinatePoint(x: 0.42, y: 0.48), CoordinatePoint(x: 0.34, y: 0.48)
            ]
        )
        let observation = BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyeSupport: [left],
            observedEyeOrder: .canonical
        )

        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(brightness: 0.2, eyeSize: 1),
            selectedFaceObservation: observation
        )

        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.skippedDomains.contains(.eyes))
        assertEyeStrengthsAreZero(plan)
        XCTAssertTrue(plan.activeDomains.contains(.color))
        assertNoEyeSideOrRawGeometryDisclosure(plan)
    }

    func testMalformedObservedSupportKeepsSafeSiblingDomainsActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(brightness: 0.2, eyeSize: 1, noseSlim: 0.3),
            selectedFaceObservation: .fixtureWithMalformedObservedEyes
        )

        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.activeDomains.contains(.nose))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        assertEyeStrengthsAreZero(plan)
        assertNoEyeSideOrRawGeometryDisclosure(plan)
    }

    func testUnsupportedEyeFieldIsNotReintroducedIntoConflictBaselineWithValidSiblings() {
        let malformed = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 1, eyeSize: 1, noseSlim: 1, mouthSize: 1),
            selectedFaceObservation: .fixtureWithMalformedObservedEyes
        )
        let eyeOmitted = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 1, noseSlim: 1, mouthSize: 1),
            selectedFaceObservation: .fixtureWithMalformedObservedEyes
        )

        XCTAssertEqual(malformed.effectiveStrengths.eyeSize, 0)
        XCTAssertEqual(malformed.effectiveStrengths.faceSlim, eyeOmitted.effectiveStrengths.faceSlim, accuracy: 0.000001)
        XCTAssertEqual(malformed.effectiveStrengths.noseSlim, eyeOmitted.effectiveStrengths.noseSlim, accuracy: 0.000001)
        XCTAssertEqual(malformed.effectiveStrengths.mouthSize, eyeOmitted.effectiveStrengths.mouthSize, accuracy: 0.000001)
    }

    func testPupilDependentEyeFieldsZeroLocallyWhileContourSiblingRemainsAccounted() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(eyeHeight: 1, pupilSize: 1, gazeCorrection: 1),
            faceGeometry: .fixture
        )

        XCTAssertTrue(plan.activeDomains.contains(.eyes))
        XCTAssertEqual(plan.effectiveStrengths.eyeHeight, BeautySafetyCaps.eyeHeight, accuracy: 0.000001)
        XCTAssertEqual(plan.effectiveStrengths.pupilSize, 0, accuracy: 0.000001)
        XCTAssertEqual(plan.effectiveStrengths.gazeCorrection, 0, accuracy: 0.000001)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertFalse(plan.skippedDomains.contains(.eyes))
        assertRedacted(plan)
    }

    func testEYE20AllFourteenFieldsFreshnessTransitionsAreStateless() {
        let parameters = BeautyParameters(
            brightness: 0.2,
            eyeSize: 1,
            eyeDistance: -1,
            eyeYPosition: 1,
            eyeTailLift: 1,
            eyeHeight: 1,
            eyeLength: 1,
            upperEyelidLift: 1,
            pupilSize: 1,
            gazeCorrection: 1,
            lowerEyelidDrop: 1,
            eyeTilt: -1,
            innerCornerOpen: 1,
            outerCornerOpen: 1,
            eyeSymmetry: 1,
            noseSlim: 0.2,
            mouthSize: 0.2
        )

        let fresh = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
        let reused = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .reused)
        let freshAfterReuse = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
        let stale = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .stale)
        let freshAfterStale = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
        let noFace = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: nil)

        XCTAssertTrue(fresh.activeDomains.contains(.eyes))
        XCTAssertEqual(freshAfterReuse.effectiveStrengths, fresh.effectiveStrengths)
        XCTAssertEqual(freshAfterStale.effectiveStrengths, fresh.effectiveStrengths)
        XCTAssertEqual(freshAfterReuse.activeDomains, fresh.activeDomains)
        XCTAssertEqual(freshAfterStale.activeDomains, fresh.activeDomains)

        for plan in [reused, stale, noFace] {
            XCTAssertFalse(plan.activeDomains.contains(.eyes))
            XCTAssertTrue(plan.skippedDomains.contains(.eyes))
            assertEyeStrengthsAreZero(plan)
            assertRedacted(plan)
            assertNoEyeSideOrRawGeometryDisclosure(plan)
        }
        XCTAssertTrue(reused.activeDomains.isSuperset(of: [.nose, .mouth, .color]))
        XCTAssertGreaterThan(reused.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertTrue(stale.activeDomains.contains(.color))
        XCTAssertTrue(noFace.activeDomains.contains(.color))
    }

    func testMissingStaleAndReusedGeometryMetadataStayRedacted() {
        let plans = [
            BeautyEffectResolver.resolve(
                parameters: BeautyParameters(eyeSize: 1),
                faceGeometry: .missingLeftEye
            ),
            BeautyEffectResolver.resolve(
                parameters: BeautyParameters(noseSlim: 1),
                faceGeometry: .missingNose
            ),
            BeautyEffectResolver.resolve(
                parameters: BeautyParameters(mouthSize: 1, lipColor: 1),
                faceGeometry: .missingMouth
            ),
            BeautyEffectResolver.resolve(
                parameters: BeautyParameters(faceSlim: 1, eyeSize: 1, noseSlim: 1, mouthSize: 1),
                faceGeometry: .stale
            ),
            BeautyEffectResolver.resolve(
                parameters: BeautyParameters(faceSlim: 1, eyeSize: 1, noseSlim: 1, mouthSize: 1),
                faceGeometry: .reused
            )
        ]

        for plan in plans {
            assertRedacted(plan)
        }
    }

    func testPERF03NoFaceMissingStaleAndReusedGeometryRemainRedactedAndDegraded() {
        let parameters = BeautyParameters(
            brightness: 0.2,
            faceSlim: 1,
            eyeSize: 1,
            noseSlim: 1,
            mouthSize: 1,
            lipColor: 1,
            filterId: "soft_clean",
            filterIntensity: 0.5
        )

        let noFace = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: nil)
        XCTAssertTrue(noFace.activeDomains.contains(.color))
        XCTAssertTrue(noFace.activeDomains.contains(.filter))
        XCTAssertFalse(noFace.activeDomains.contains(.faceShape))
        XCTAssertTrue(noFace.skippedDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth, .lipColor]))
        XCTAssertTrue(noFace.warnings.contains { $0.code == "face_effects_skipped_no_face" })

        let missingMouth = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .missingMouth)
        XCTAssertTrue(missingMouth.activeDomains.contains(.color))
        XCTAssertTrue(missingMouth.activeDomains.contains(.filter))
        XCTAssertTrue(missingMouth.activeDomains.contains(.eyes))
        XCTAssertTrue(missingMouth.activeDomains.contains(.nose))
        XCTAssertFalse(missingMouth.activeDomains.contains(.mouth))
        XCTAssertFalse(missingMouth.activeDomains.contains(.lipColor))
        XCTAssertTrue(missingMouth.warnings.contains { $0.code == "mouth_inputs_missing" })
        XCTAssertTrue(missingMouth.warnings.contains { $0.code == "lip_inputs_missing" })

        let stale = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .stale)
        XCTAssertTrue(stale.activeDomains.contains(.color))
        XCTAssertTrue(stale.activeDomains.contains(.filter))
        XCTAssertFalse(stale.activeDomains.contains(.eyes))
        XCTAssertFalse(stale.activeDomains.contains(.nose))
        XCTAssertTrue(stale.warnings.contains { $0.code == "geometry_stale_skipped" })

        let reused = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .reused)
        XCTAssertFalse(reused.activeDomains.contains(.eyes))
        XCTAssertTrue(reused.skippedDomains.contains(.eyes))
        XCTAssertTrue(reused.activeDomains.contains(.nose))
        XCTAssertEqual(reused.effectiveStrengths.eyeSize, 0)
        XCTAssertLessThan(reused.effectiveStrengths.noseSlim, BeautySafetyCaps.noseSlim)
        XCTAssertTrue(reused.warnings.contains { $0.code == "geometry_stale_reduced" })

        for plan in [noFace, missingMouth, stale, reused] {
            assertRedacted(plan)
        }
    }

    func testMissingNoseSkipsOnlyNoseAndKeepsEyeAndSafeDomainsActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                eyeSize: 0.2,
                noseSlim: 1,
                noseWingSlim: 1,
                noseTipSize: -1,
                noseBridge: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            ),
            faceGeometry: .missingNose
        )

        XCTAssertFalse(plan.activeDomains.contains(.nose))
        XCTAssertTrue(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertEqual(plan.skippedDomains, [.nose])
        assertNoseStrengthsAreZero(plan)
        XCTAssertEqual(plan.metrics["beauty.effects.skippedNoseDomains"], 1)
        XCTAssertTrue(plan.warnings.contains { $0.code == "nose_inputs_missing" })
        assertRedacted(plan)
    }

    func testPhase35NOSE03StaleZerosNoseWhileReusedScalesAllFieldsByHalf() {
        let parameters = BeautyParameters(
            noseSlim: 1,
            noseWingSlim: 1,
            noseTipSize: -1,
            noseBridge: 1,
            noseRootNarrowing: 1,
            noseTipLift: 1
        )
        let stale = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .stale)
        XCTAssertTrue(stale.skippedDomains.contains(.nose))
        assertNoseStrengthsAreZero(stale)
        XCTAssertEqual(stale.metrics["beauty.effects.skippedNoseDomains"], 1)
        XCTAssertTrue(stale.warnings.contains { $0.code == "geometry_stale_skipped" })

        let reused = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .reused)
        XCTAssertTrue(reused.activeDomains.contains(.nose))
        XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5)
        XCTAssertEqual(reused.effectiveStrengths.noseSlim, 0.175, accuracy: 0.0001)
        XCTAssertEqual(reused.effectiveStrengths.noseWingSlim, 0.175, accuracy: 0.0001)
        XCTAssertEqual(reused.effectiveStrengths.noseTipSize, -0.15, accuracy: 0.0001)
        XCTAssertEqual(reused.effectiveStrengths.noseBridge, 0.15, accuracy: 0.0001)
        XCTAssertEqual(reused.effectiveStrengths.noseRootNarrowing, 0.125, accuracy: 0.0001)
        XCTAssertEqual(reused.effectiveStrengths.noseTipLift, 0.125, accuracy: 0.0001)
        assertRedacted(reused)
    }

    func testNOSE11SixFieldZeroNoFaceMissingProviderEmptyStaleAndReusedMatrix() {
        typealias ParameterPath = WritableKeyPath<BeautyParameters, Float>
        typealias EffectivePath = WritableKeyPath<BeautyEffectiveStrengths, Float>
        typealias EmissionPath = KeyPath<NoseWarpFieldEmissions, [WarpControlPoint]>
        struct Row {
            let name: String
            let request: Float
            let parameter: ParameterPath
            let effective: EffectivePath
            let emission: EmissionPath
            let reused: Float
            let unavailableFace: FaceGeometry
            let siblingParameter: ParameterPath
            let siblingEffective: EffectivePath
            let siblingEmission: EmissionPath
        }

        let rows: [Row] = [
            Row(name: "noseSlim", request: 1, parameter: \.noseSlim, effective: \.noseSlim, emission: \.noseSlim, reused: 0.175, unavailableFace: .onePointLegacyNose, siblingParameter: \.noseRootNarrowing, siblingEffective: \.noseRootNarrowing, siblingEmission: \.noseRootNarrowing),
            Row(name: "noseWingSlim", request: 1, parameter: \.noseWingSlim, effective: \.noseWingSlim, emission: \.noseWingSlim, reused: 0.175, unavailableFace: .missingLegacyNose, siblingParameter: \.noseRootNarrowing, siblingEffective: \.noseRootNarrowing, siblingEmission: \.noseRootNarrowing),
            Row(name: "noseTipSize positive", request: 1, parameter: \.noseTipSize, effective: \.noseTipSize, emission: \.noseTipSize, reused: 0.15, unavailableFace: .missingLegacyNose, siblingParameter: \.noseRootNarrowing, siblingEffective: \.noseRootNarrowing, siblingEmission: \.noseRootNarrowing),
            Row(name: "noseTipSize negative", request: -1, parameter: \.noseTipSize, effective: \.noseTipSize, emission: \.noseTipSize, reused: -0.15, unavailableFace: .missingLegacyNose, siblingParameter: \.noseRootNarrowing, siblingEffective: \.noseRootNarrowing, siblingEmission: \.noseRootNarrowing),
            Row(name: "noseBridge", request: 1, parameter: \.noseBridge, effective: \.noseBridge, emission: \.noseBridge, reused: 0.15, unavailableFace: .missingLegacyNose, siblingParameter: \.noseRootNarrowing, siblingEffective: \.noseRootNarrowing, siblingEmission: \.noseRootNarrowing),
            Row(name: "noseRootNarrowing", request: 1, parameter: \.noseRootNarrowing, effective: \.noseRootNarrowing, emission: \.noseRootNarrowing, reused: 0.125, unavailableFace: .onePointNoseRoot, siblingParameter: \.noseTipLift, siblingEffective: \.noseTipLift, siblingEmission: \.noseTipLift),
            Row(name: "noseTipLift", request: 1, parameter: \.noseTipLift, effective: \.noseTipLift, emission: \.noseTipLift, reused: 0.125, unavailableFace: .onePointNoseTip, siblingParameter: \.noseRootNarrowing, siblingEffective: \.noseRootNarrowing, siblingEmission: \.noseRootNarrowing),
        ]
        let provider = NoseWarpProvider()

        for row in rows {
            var zeroParameters = BeautyParameters()
            zeroParameters[keyPath: row.parameter] = 0
            let zero = BeautyEffectResolver.resolve(parameters: zeroParameters, faceGeometry: .fixture)
            XCTAssertFalse(zero.activeDomains.contains(.nose), "zero \(row.name)")
            XCTAssertFalse(zero.skippedDomains.contains(.nose), "zero \(row.name)")
            XCTAssertEqual(zero.effectiveStrengths[keyPath: row.effective], 0, "zero \(row.name)")
            XCTAssertTrue(provider.fieldEmissions(face: .fixture, strengths: zero.effectiveStrengths)[keyPath: row.emission].isEmpty, "zero \(row.name)")
            XCTAssertNil(zero.metrics["beauty.effects.geometryPointCount"], "zero \(row.name)")
            XCTAssertEqual(zero.metrics["beauty.effects.cappedCount"], 0, "zero \(row.name)")
            XCTAssertNil(zero.metrics["beauty.effects.weakenedCount"], "zero \(row.name)")
            XCTAssertFalse(zero.warnings.contains { $0.code == "nose_inputs_missing" }, "zero \(row.name)")

            var requested = BeautyParameters()
            requested[keyPath: row.parameter] = row.request
            let noFace = BeautyEffectResolver.resolve(parameters: requested, faceGeometry: nil)
            XCTAssertFalse(noFace.activeDomains.contains(.nose), "no-face \(row.name)")
            XCTAssertTrue(noFace.skippedDomains.contains(.nose), "no-face \(row.name)")
            XCTAssertEqual(noFace.effectiveStrengths[keyPath: row.effective], 0, "no-face \(row.name)")
            XCTAssertNil(noFace.metrics["beauty.effects.geometryPointCount"], "no-face \(row.name)")
            XCTAssertTrue(noFace.warnings.contains { $0.code == "face_effects_skipped_no_face" }, "no-face \(row.name)")

            var unavailableParameters = requested
            unavailableParameters[keyPath: row.siblingParameter] = 1
            let unavailable = BeautyEffectResolver.resolve(
                parameters: unavailableParameters,
                faceGeometry: row.unavailableFace
            )
            let unavailableEmissions = provider.fieldEmissions(
                face: row.unavailableFace,
                strengths: unavailable.effectiveStrengths
            )
            XCTAssertEqual(unavailable.effectiveStrengths[keyPath: row.effective], 0, "missing/provider-empty \(row.name)")
            XCTAssertTrue(unavailableEmissions[keyPath: row.emission].isEmpty, "missing/provider-empty \(row.name)")
            XCTAssertGreaterThan(abs(unavailable.effectiveStrengths[keyPath: row.siblingEffective]), 0, "sibling \(row.name)")
            XCTAssertFalse(unavailableEmissions[keyPath: row.siblingEmission].isEmpty, "sibling \(row.name)")
            XCTAssertTrue(unavailable.activeDomains.contains(.nose), "sibling \(row.name)")
            XCTAssertFalse(unavailable.skippedDomains.contains(.nose), "sibling \(row.name)")
            XCTAssertFalse(unavailable.warnings.contains { $0.code == "nose_inputs_missing" }, "sibling \(row.name)")
            XCTAssertNil(unavailable.metrics["beauty.effects.weakenedCount"], "missing/provider-empty \(row.name)")
            XCTAssertNil(unavailable.metrics["beauty.effects.geometryStrengthScale"], "missing/provider-empty \(row.name)")
            XCTAssertEqual(
                unavailable.metrics["beauty.effects.geometryPointCount"],
                Double(unavailableEmissions.points.count),
                "dispatch \(row.name)"
            )

            let stale = BeautyEffectResolver.resolve(parameters: requested, faceGeometry: .stale)
            XCTAssertEqual(stale.effectiveStrengths[keyPath: row.effective], 0, "stale \(row.name)")
            XCTAssertTrue(stale.skippedDomains.contains(.nose), "stale \(row.name)")
            XCTAssertTrue(provider.fieldEmissions(face: .stale, strengths: stale.effectiveStrengths)[keyPath: row.emission].isEmpty, "stale \(row.name)")

            let reused = BeautyEffectResolver.resolve(parameters: requested, faceGeometry: .reused)
            XCTAssertEqual(reused.effectiveStrengths[keyPath: row.effective], row.reused, accuracy: 0.0001, "reused \(row.name)")
            XCTAssertTrue(reused.activeDomains.contains(.nose), "reused \(row.name)")
            XCTAssertFalse(provider.fieldEmissions(face: .reused, strengths: reused.effectiveStrengths)[keyPath: row.emission].isEmpty, "reused \(row.name)")
            XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5, "reused \(row.name)")

            for plan in [zero, noFace, unavailable, stale, reused] {
                assertRedacted(plan)
            }
        }
    }

    func testNOSE11FreshReusedStaleAndValidUnavailableTransitionsDoNotCarryPriorWork() {
        let allFields = BeautyParameters(
            noseSlim: 1,
            noseWingSlim: 1,
            noseTipSize: -1,
            noseBridge: 1,
            noseRootNarrowing: 1,
            noseTipLift: 1
        )
        let provider = NoseWarpProvider()
        let fresh = BeautyEffectResolver.resolve(parameters: allFields, faceGeometry: .fixture)
        let reused = BeautyEffectResolver.resolve(parameters: allFields, faceGeometry: .reused)
        let stale = BeautyEffectResolver.resolve(parameters: allFields, faceGeometry: .stale)
        let freshEmissions = provider.fieldEmissions(face: .fixture, strengths: fresh.effectiveStrengths)
        let reusedEmissions = provider.fieldEmissions(face: .reused, strengths: reused.effectiveStrengths)
        let staleEmissions = provider.fieldEmissions(face: .stale, strengths: stale.effectiveStrengths)

        XCTAssertFalse(freshEmissions.points.isEmpty)
        XCTAssertFalse(reusedEmissions.points.isEmpty)
        XCTAssertNotEqual(freshEmissions.points, reusedEmissions.points)
        XCTAssertTrue(staleEmissions.points.isEmpty)
        assertNoseStrengthsAreZero(stale)
        XCTAssertEqual(reused.effectiveStrengths.noseSlim, 0.175, accuracy: 0.0001)
        XCTAssertEqual(reused.effectiveStrengths.noseWingSlim, 0.175, accuracy: 0.0001)
        XCTAssertEqual(reused.effectiveStrengths.noseTipSize, -0.15, accuracy: 0.0001)
        XCTAssertEqual(reused.effectiveStrengths.noseBridge, 0.15, accuracy: 0.0001)
        XCTAssertEqual(reused.effectiveStrengths.noseRootNarrowing, 0.125, accuracy: 0.0001)
        XCTAssertEqual(reused.effectiveStrengths.noseTipLift, 0.125, accuracy: 0.0001)

        let transitions: [(String, BeautyParameters, FaceGeometry, KeyPath<BeautyEffectiveStrengths, Float>, KeyPath<NoseWarpFieldEmissions, [WarpControlPoint]>)] = [
            ("noseSlim", BeautyParameters(noseSlim: 1, noseRootNarrowing: 1), .onePointLegacyNose, \.noseSlim, \.noseSlim),
            ("noseWingSlim", BeautyParameters(noseWingSlim: 1, noseRootNarrowing: 1), .missingLegacyNose, \.noseWingSlim, \.noseWingSlim),
            ("noseTipSize positive", BeautyParameters(noseTipSize: 1, noseRootNarrowing: 1), .missingLegacyNose, \.noseTipSize, \.noseTipSize),
            ("noseTipSize negative", BeautyParameters(noseTipSize: -1, noseRootNarrowing: 1), .missingLegacyNose, \.noseTipSize, \.noseTipSize),
            ("noseBridge", BeautyParameters(noseBridge: 1, noseRootNarrowing: 1), .missingLegacyNose, \.noseBridge, \.noseBridge),
            ("noseRootNarrowing", BeautyParameters(noseRootNarrowing: 1, noseTipLift: 1), .onePointNoseRoot, \.noseRootNarrowing, \.noseRootNarrowing),
            ("noseTipLift", BeautyParameters(noseRootNarrowing: 1, noseTipLift: 1), .onePointNoseTip, \.noseTipLift, \.noseTipLift),
        ]
        for (name, parameters, destinationFace, effective, emission) in transitions {
            let valid = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
            let destination = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: destinationFace)
            let validEmission = provider.fieldEmissions(face: .fixture, strengths: valid.effectiveStrengths)[keyPath: emission]
            let destinationEmissions = provider.fieldEmissions(face: destinationFace, strengths: destination.effectiveStrengths)

            XCTAssertFalse(validEmission.isEmpty, "valid \(name)")
            XCTAssertEqual(destination.effectiveStrengths[keyPath: effective], 0, "destination \(name)")
            XCTAssertTrue(destinationEmissions[keyPath: emission].isEmpty, "destination \(name)")
            XCTAssertFalse(destinationEmissions.points.isEmpty, "supported sibling \(name)")
            XCTAssertNotEqual(validEmission, destinationEmissions[keyPath: emission], "no carryover \(name)")
            assertRedacted(valid)
            assertRedacted(destination)
        }
    }

    func testPhase35NOSE06InvalidIndependentSupportFailsClosedAndSafeDomainsContinue() {
        let cases: [(FaceGeometry, BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>)] = [
            (.onePointNoseRoot, BeautyParameters(brightness: 0.2, noseRootNarrowing: 1, filterId: "soft_clean", filterIntensity: 0.5), \.noseRootNarrowing),
            (.onePointNoseTip, BeautyParameters(brightness: 0.2, noseTipLift: 1, filterId: "soft_clean", filterIntensity: 0.5), \.noseTipLift),
        ]

        for (face, parameters, keyPath) in cases {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            XCTAssertFalse(plan.activeDomains.contains(.nose))
            XCTAssertTrue(plan.skippedDomains.contains(.nose))
            XCTAssertTrue(plan.activeDomains.isSuperset(of: [.color, .filter]))
            XCTAssertEqual(plan.effectiveStrengths[keyPath: keyPath], 0)
            XCTAssertEqual(plan.metrics["beauty.effects.skippedNoseDomains"], 1)
            XCTAssertTrue(plan.warnings.contains { $0.code == "nose_inputs_missing" })
            assertRedacted(plan)
        }
    }

    func testPhase35NOSE06InvalidIndependentSupportDoesNotZeroValidLegacyNoseWork() {
        let cases: [(FaceGeometry, BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>, KeyPath<BeautyEffectiveStrengths, Float>)] = [
            (.onePointNoseRoot, BeautyParameters(noseBridge: 1, noseRootNarrowing: 1), \.noseRootNarrowing, \.noseBridge),
            (.onePointNoseTip, BeautyParameters(noseTipSize: 1, noseTipLift: 1), \.noseTipLift, \.noseTipSize),
        ]

        for (face, parameters, invalidKeyPath, legacyKeyPath) in cases {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            XCTAssertTrue(plan.activeDomains.contains(.nose))
            XCTAssertFalse(plan.skippedDomains.contains(.nose))
            XCTAssertEqual(plan.effectiveStrengths[keyPath: invalidKeyPath], 0)
            XCTAssertGreaterThan(plan.effectiveStrengths[keyPath: legacyKeyPath], 0)
            XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
            XCTAssertFalse(plan.warnings.contains { $0.code == "nose_inputs_missing" })
            assertRedacted(plan)
        }
    }

    func testPhase35ReviewUnsupportedIndependentSupportIsExcludedFromConflictAccounting() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                faceSlim: 1,
                faceSmall: 1,
                noseRootNarrowing: 1
            ),
            faceGeometry: .onePointNoseRoot
        )
        let expectedScale = 1 / (BeautySafetyCaps.faceSlim + BeautySafetyCaps.faceSmall)

        XCTAssertEqual(plan.effectiveStrengths.noseRootNarrowing, 0)
        XCTAssertEqual(plan.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim * expectedScale, accuracy: 0.0001)
        XCTAssertEqual(plan.effectiveStrengths.faceSmall, BeautySafetyCaps.faceSmall * expectedScale, accuracy: 0.0001)
        XCTAssertEqual(plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(expectedScale), accuracy: 0.0001)
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 2)
        XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        XCTAssertTrue(plan.skippedDomains.contains(.nose))
        XCTAssertTrue(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertTrue(plan.warnings.contains { $0.code == "nose_inputs_missing" })
        assertRedacted(plan)
    }

    func testPhase35ReviewValidIndependentSupportCannotMaskUnavailableLegacyNoseWork() {
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: FaceGeometry.fixture.leftEye,
            rightEye: FaceGeometry.fixture.rightEye,
            nose: [],
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips
        )
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                faceSlim: 1,
                faceSmall: 1,
                noseSlim: 1,
                noseWingSlim: 1,
                noseTipSize: -1,
                noseBridge: 1,
                noseRootNarrowing: 1
            ),
            faceGeometry: face
        )
        let expectedScale = 1 / (
            BeautySafetyCaps.faceSlim +
                BeautySafetyCaps.faceSmall +
                BeautySafetyCaps.noseRootNarrowing
        )

        XCTAssertEqual(plan.effectiveStrengths.noseSlim, 0)
        XCTAssertEqual(plan.effectiveStrengths.noseWingSlim, 0)
        XCTAssertEqual(plan.effectiveStrengths.noseTipSize, 0)
        XCTAssertEqual(plan.effectiveStrengths.noseBridge, 0)
        XCTAssertEqual(
            plan.effectiveStrengths.noseRootNarrowing,
            BeautySafetyCaps.noseRootNarrowing * expectedScale,
            accuracy: 0.0001
        )
        XCTAssertEqual(plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(expectedScale), accuracy: 0.0001)
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 3)
        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .nose]))
        XCTAssertFalse(plan.skippedDomains.contains(.nose))
        XCTAssertFalse(plan.warnings.contains { $0.code == "nose_inputs_missing" })
        assertRedacted(plan)
    }

    func testPhase35ReviewLegacySanitizationIsPerFieldBeforeConflictAccounting() {
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: FaceGeometry.fixture.leftEye,
            rightEye: FaceGeometry.fixture.rightEye,
            nose: [SIMD2<Float>(0.50, 0.52)],
            noseRoot: FaceGeometry.fixture.noseRoot,
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips
        )
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                faceSlim: 1,
                faceSmall: 1,
                noseSlim: 1,
                noseRootNarrowing: 1
            ),
            faceGeometry: face
        )
        let expectedScale = 1 / (
            BeautySafetyCaps.faceSlim +
                BeautySafetyCaps.faceSmall +
                BeautySafetyCaps.noseRootNarrowing
        )

        XCTAssertEqual(plan.effectiveStrengths.noseSlim, 0)
        XCTAssertEqual(
            plan.effectiveStrengths.noseRootNarrowing,
            BeautySafetyCaps.noseRootNarrowing * expectedScale,
            accuracy: 0.0001
        )
        XCTAssertEqual(plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(expectedScale), accuracy: 0.0001)
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 3)
        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .nose]))
        XCTAssertFalse(plan.skippedDomains.contains(.nose))
        XCTAssertFalse(plan.warnings.contains { $0.code == "nose_inputs_missing" })
        assertRedacted(plan)
    }

    func testPhase35ReviewNonEmittingRootIsExcludedWhileTipSiblingRemainsActive() {
        let face = FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: FaceGeometry.fixture.leftEye,
            rightEye: FaceGeometry.fixture.rightEye,
            nose: FaceGeometry.fixture.nose,
            noseRoot: [
                SIMD2<Float>(0.49989995, 0.488),
                SIMD2<Float>(0.50010005, 0.488)
            ],
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips
        )
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                faceSlim: 1,
                faceSmall: 1,
                noseRootNarrowing: 1,
                noseTipLift: 1
            ),
            faceGeometry: face
        )
        let expectedScale = 1 / (
            BeautySafetyCaps.faceSlim +
                BeautySafetyCaps.faceSmall +
                BeautySafetyCaps.noseTipLift
        )

        XCTAssertEqual(plan.effectiveStrengths.noseRootNarrowing, 0)
        XCTAssertEqual(
            plan.effectiveStrengths.noseTipLift,
            BeautySafetyCaps.noseTipLift * expectedScale,
            accuracy: 0.0001
        )
        XCTAssertEqual(plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(expectedScale), accuracy: 0.0001)
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 3)
        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .nose]))
        XCTAssertFalse(plan.skippedDomains.contains(.nose))
        assertRedacted(plan)
    }

    func testPhase35ReviewTinyNonEmittingTipIsExcludedWhileRootSiblingRemainsActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                faceSlim: 1,
                faceSmall: 1,
                noseRootNarrowing: 1,
                noseTipLift: Float.ulpOfOne * 2
            ),
            faceGeometry: .fixture
        )
        let expectedScale = 1 / (
            BeautySafetyCaps.faceSlim +
                BeautySafetyCaps.faceSmall +
                BeautySafetyCaps.noseRootNarrowing
        )

        XCTAssertEqual(plan.effectiveStrengths.noseTipLift, 0)
        XCTAssertEqual(
            plan.effectiveStrengths.noseRootNarrowing,
            BeautySafetyCaps.noseRootNarrowing * expectedScale,
            accuracy: 0.0001
        )
        XCTAssertEqual(plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(expectedScale), accuracy: 0.0001)
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 3)
        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .nose]))
        XCTAssertFalse(plan.skippedDomains.contains(.nose))
        assertRedacted(plan)
    }

    func testPhase35ReviewConflictThresholdCrossingRootIsRemovedBeforeFinalConflictEvidence() {
        assertConflictThresholdCrossingNoseField(
            parameters: BeautyParameters(
                faceSlim: 1,
                faceSmall: 1,
                faceVShape: 1,
                jawSlim: 1,
                chinLength: 1,
                noseSlim: 1,
                noseRootNarrowing: 0.000004
            ),
            dropped: \.noseRootNarrowing
        )
    }

    func testPhase35ReviewConflictThresholdCrossingTipLiftIsRemovedBeforeFinalConflictEvidence() {
        assertConflictThresholdCrossingNoseField(
            parameters: BeautyParameters(
                faceSlim: 1,
                faceSmall: 1,
                faceVShape: 1,
                jawSlim: 1,
                chinLength: 1,
                noseSlim: 1,
                noseTipLift: 0.000003
            ),
            dropped: \.noseTipLift
        )
    }

    func testPhase35ReviewConflictThresholdCrossingSignedTipSizeIsRemovedInBothDirections() {
        for requested in [Float.ulpOfOne * 2, -Float.ulpOfOne * 2] {
            assertConflictThresholdCrossingNoseField(
                parameters: BeautyParameters(
                    faceSlim: 1,
                    faceSmall: 1,
                    faceVShape: 1,
                    jawSlim: 1,
                    chinLength: 1,
                    noseSlim: 1,
                    noseTipSize: requested
                ),
                dropped: \.noseTipSize
            )
        }
    }

    func testBROW07SidePairChordAndApexDegradationStayFieldLocal() {
        let left = phase50EyebrowTrace(side: .left)
        let right = phase50EyebrowTrace(side: .right)
        let provider = EyebrowWarpProvider()

        for (name, support, expectsSpacing) in [
            ("left only", BeautyEyebrowSemanticSupport(left: left, right: nil), false),
            ("right only", BeautyEyebrowSemanticSupport(left: nil, right: right), false),
            ("paired", BeautyEyebrowSemanticSupport(left: left, right: right), true),
        ] {
            let face = phase50EyebrowFace(support: support)
            let plan = BeautyEffectResolver.resolve(parameters: phase50AllEyebrowParameters, faceGeometry: face)
            let emissions = provider.fieldEmissions(face: face, strengths: plan.effectiveStrengths)

            XCTAssertNotEqual(plan.effectiveStrengths.eyebrowYPosition, 0, name)
            XCTAssertNotEqual(plan.effectiveStrengths.eyebrowThickness, 0, name)
            XCTAssertNotEqual(plan.effectiveStrengths.eyebrowLength, 0, name)
            XCTAssertNotEqual(plan.effectiveStrengths.eyebrowHeadSpacing, 0, name)
            XCTAssertNotEqual(plan.effectiveStrengths.eyebrowTilt, 0, name)
            XCTAssertNotEqual(plan.effectiveStrengths.eyebrowPeakDefinition, 0, name)
            XCTAssertEqual(plan.effectiveStrengths.eyebrowSpacing != 0, expectsSpacing, name)
            XCTAssertEqual(emissions.eyebrowSpacing.isEmpty, !expectsSpacing, name)
            XCTAssertTrue(plan.activeDomains.contains(.eyebrows), name)
            assertRedacted(plan)
        }

        let noApexLeft = phase50EyebrowTrace(side: .left, apexIndex: nil)
        let pairedFace = phase50EyebrowFace(
            support: BeautyEyebrowSemanticSupport(left: left, right: right)
        )
        let oneApexFace = phase50EyebrowFace(
            support: BeautyEyebrowSemanticSupport(left: noApexLeft, right: right)
        )
        let pairedPlan = BeautyEffectResolver.resolve(parameters: phase50AllEyebrowParameters, faceGeometry: pairedFace)
        let oneApexPlan = BeautyEffectResolver.resolve(parameters: phase50AllEyebrowParameters, faceGeometry: oneApexFace)
        let pairedPeak = provider.fieldEmissions(face: pairedFace, strengths: pairedPlan.effectiveStrengths).eyebrowPeakDefinition
        let oneApexPeak = provider.fieldEmissions(face: oneApexFace, strengths: oneApexPlan.effectiveStrengths).eyebrowPeakDefinition
        XCTAssertNotEqual(oneApexPlan.effectiveStrengths.eyebrowPeakDefinition, 0)
        XCTAssertFalse(oneApexPeak.isEmpty)
        XCTAssertLessThan(oneApexPeak.count, pairedPeak.count, "nil apex removes only that side")

        let degenerate = phase50EyebrowTrace(
            side: .left,
            points: [.init(0.30, 0.40), .init(0.32, 0.37), .init(0.34, 0.35), .init(0.36, 0.37), .init(0.30, 0.40)],
            apexIndex: 2
        )
        let degenerateFace = phase50EyebrowFace(
            support: BeautyEyebrowSemanticSupport(left: degenerate, right: nil)
        )
        let degeneratePlan = BeautyEffectResolver.resolve(parameters: phase50AllEyebrowParameters, faceGeometry: degenerateFace)
        XCTAssertNotEqual(degeneratePlan.effectiveStrengths.eyebrowYPosition, 0)
        XCTAssertNotEqual(degeneratePlan.effectiveStrengths.eyebrowThickness, 0)
        XCTAssertEqual(degeneratePlan.effectiveStrengths.eyebrowLength, 0)
        XCTAssertEqual(degeneratePlan.effectiveStrengths.eyebrowSpacing, 0)
        XCTAssertEqual(degeneratePlan.effectiveStrengths.eyebrowHeadSpacing, 0)
        XCTAssertEqual(degeneratePlan.effectiveStrengths.eyebrowTilt, 0)
        XCTAssertEqual(degeneratePlan.effectiveStrengths.eyebrowPeakDefinition, 0)
        XCTAssertTrue(degeneratePlan.activeDomains.contains(.eyebrows))
        assertRedacted(degeneratePlan)
    }

    func testBROW07FreshReusedStaleMissingAndValidInvalidValidCarryNoPriorWork() {
        let support = BeautyEyebrowSemanticSupport(
            left: phase50EyebrowTrace(side: .left),
            right: phase50EyebrowTrace(side: .right)
        )
        let freshFace = phase50EyebrowFace(support: support)
        let reusedFace = phase50EyebrowFace(support: support, freshness: .reused)
        let staleFace = phase50EyebrowFace(support: support, freshness: .stale)
        let missingFace = phase50EyebrowFace(support: nil)
        let fresh = BeautyEffectResolver.resolve(parameters: phase50AllEyebrowParameters, faceGeometry: freshFace)
        let reused = BeautyEffectResolver.resolve(parameters: phase50AllEyebrowParameters, faceGeometry: reusedFace)
        let stale = BeautyEffectResolver.resolve(parameters: phase50AllEyebrowParameters, faceGeometry: staleFace)
        let missing = BeautyEffectResolver.resolve(parameters: phase50AllEyebrowParameters, faceGeometry: missingFace)
        let noFace = BeautyEffectResolver.resolve(parameters: phase50AllEyebrowParameters, faceGeometry: nil)
        let freshAgain = BeautyEffectResolver.resolve(parameters: phase50AllEyebrowParameters, faceGeometry: freshFace)

        for (keyPath, reusedExpected) in zip(
            phase50EyebrowEffectiveKeyPaths,
            [-0.125, 0.125, -0.125, 0.125, -0.125, 0.125, 0.125]
        ) {
            XCTAssertEqual(reused.effectiveStrengths[keyPath: keyPath], Float(reusedExpected), accuracy: 0.000_001)
            XCTAssertEqual(stale.effectiveStrengths[keyPath: keyPath], 0)
            XCTAssertEqual(missing.effectiveStrengths[keyPath: keyPath], 0)
            XCTAssertEqual(noFace.effectiveStrengths[keyPath: keyPath], 0)
            XCTAssertEqual(freshAgain.effectiveStrengths[keyPath: keyPath], fresh.effectiveStrengths[keyPath: keyPath])
        }
        XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5)
        XCTAssertEqual(
            EyebrowWarpProvider().fieldEmissions(face: freshFace, strengths: freshAgain.effectiveStrengths),
            EyebrowWarpProvider().fieldEmissions(face: freshFace, strengths: fresh.effectiveStrengths)
        )
        for plan in [fresh, reused, stale, missing, noFace, freshAgain] { assertRedacted(plan) }
    }

    func testBROW07ProviderEmptyRemovalKeepsSafeSiblingAndAggregateEvidence() {
        let face = phase50EyebrowFace(
            support: BeautyEyebrowSemanticSupport(
                left: phase50EyebrowTrace(side: .left),
                right: phase50EyebrowTrace(side: .right)
            )
        )
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(brightness: 0.2, eyebrowPeakDefinition: Float.ulpOfOne * 2),
            faceGeometry: face
        )
        XCTAssertEqual(plan.effectiveStrengths.eyebrowPeakDefinition, 0)
        XCTAssertFalse(plan.activeDomains.contains(.eyebrows))
        XCTAssertTrue(plan.skippedDomains.contains(.eyebrows))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
        XCTAssertNil(plan.metrics["beauty.effects.geometryStrengthScale"])
        XCTAssertNil(plan.metrics["beauty.effects.weakenedCount"])
        assertRedacted(plan)
    }

    func testBROW07ConcurrentRequestLocalFixturesRemainIsolated() async {
        let validFace = phase50EyebrowFace(
            support: BeautyEyebrowSemanticSupport(
                left: phase50EyebrowTrace(side: .left),
                right: phase50EyebrowTrace(side: .right)
            )
        )
        let missingFace = phase50EyebrowFace(support: nil)
        let results = await withTaskGroup(of: (Int, Float).self, returning: [(Int, Float)].self) { group in
            for index in 0..<16 {
                group.addTask {
                    let face = index.isMultiple(of: 2) ? validFace : missingFace
                    let plan = BeautyEffectResolver.resolve(
                        parameters: BeautyParameters(eyebrowYPosition: 1),
                        faceGeometry: face
                    )
                    return (index, plan.effectiveStrengths.eyebrowYPosition)
                }
            }
            var values: [(Int, Float)] = []
            for await value in group { values.append(value) }
            return values
        }
        XCTAssertEqual(results.count, 16)
        for (index, value) in results {
            XCTAssertEqual(value, index.isMultiple(of: 2) ? 0.25 : 0)
        }
    }

    func testSAFE02ValidInvalidValidSevenRowLifecycleAndDirectionTransitionsAreStateless() {
        let freshFace = EyebrowSafetyFixtures.face()
        let reusedFace = EyebrowSafetyFixtures.face(freshness: .reused)
        let staleFace = EyebrowSafetyFixtures.face(freshness: .stale)

        for row in EyebrowSafetyFixtures.rows {
            let positiveParameters = row.makeParameters(1)
            let positive = BeautyEffectResolver.resolve(parameters: positiveParameters, faceGeometry: freshFace)
            let reused = BeautyEffectResolver.resolve(parameters: positiveParameters, faceGeometry: reusedFace)
            let stale = BeautyEffectResolver.resolve(parameters: positiveParameters, faceGeometry: staleFace)
            let noFace = BeautyEffectResolver.resolve(parameters: positiveParameters, faceGeometry: nil)
            let invalid = BeautyEffectResolver.resolve(
                parameters: positiveParameters,
                faceGeometry: EyebrowSafetyFixtures.unavailableFace(for: row.narrowestUnavailableFixture)
            )
            let recovered = BeautyEffectResolver.resolve(parameters: positiveParameters, faceGeometry: freshFace)

            XCTAssertEqual(positive.effectiveStrengths[keyPath: row.effectiveValue], row.cap, row.name)
            XCTAssertEqual(reused.effectiveStrengths[keyPath: row.effectiveValue], row.reusedStrength, row.name)
            XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5, row.name)
            XCTAssertEqual(stale.effectiveStrengths[keyPath: row.effectiveValue], 0, row.name)
            XCTAssertEqual(noFace.effectiveStrengths[keyPath: row.effectiveValue], 0, row.name)
            XCTAssertEqual(invalid.effectiveStrengths[keyPath: row.effectiveValue], 0, row.name)
            XCTAssertEqual(recovered, positive, "\(row.name) valid-invalid-valid recovery")

            if row.isSigned {
                let negative = BeautyEffectResolver.resolve(
                    parameters: row.makeParameters(-1),
                    faceGeometry: freshFace
                )
                let positiveAgain = BeautyEffectResolver.resolve(
                    parameters: positiveParameters,
                    faceGeometry: freshFace
                )
                XCTAssertEqual(negative.effectiveStrengths[keyPath: row.effectiveValue], -row.cap, row.name)
                XCTAssertEqual(positiveAgain, positive, "\(row.name) positive-negative-positive recovery")
            }

            for plan in [positive, reused, stale, noFace, invalid, recovered] {
                assertRedacted(plan)
            }
        }
    }

    func testSAFE02PairFailurePreservesEyebrowAndUnrelatedSafeSiblings() {
        let face = EyebrowSafetyFixtures.unavailableFace(for: .singleSide)
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                faceSlim: 0.2,
                eyeSize: 0.2,
                eyebrowYPosition: 0.2,
                eyebrowSpacing: 0.2,
                noseSlim: 0.2,
                mouthSize: 0.2,
                lipColor: 0.2,
                filterId: "soft_clean",
                filterIntensity: 0.2
            ),
            faceGeometry: face
        )

        XCTAssertEqual(plan.effectiveStrengths.eyebrowSpacing, 0)
        XCTAssertEqual(plan.effectiveStrengths.eyebrowYPosition, 0.2)
        XCTAssertTrue(plan.activeDomains.isSuperset(of: [
            .color, .filter, .faceShape, .eyes, .eyebrows, .nose, .mouth, .lipColor,
        ]))
        XCTAssertFalse(plan.skippedDomains.contains(.eyebrows))
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        assertRedacted(plan)
    }

    func testSAFE02ParallelCompletionOrderAndInterruptedWorkCannotLeakRequestState() async {
        let rows = EyebrowSafetyFixtures.rows
        let interruptedIdentity = 10_001
        let resolverEntered = Phase52RequestSignal(
            expectation: expectation(description: "interrupted resolver entered")
        )
        let providerBarrier = Phase52ProviderBarrier(
            enteredExpectation: expectation(description: "interrupted provider entered")
        )
        let siblingsStartedExpectation = expectation(description: "parallel siblings started")
        siblingsStartedExpectation.expectedFulfillmentCount = 28
        let siblingsStarted = Phase52RequestSignal(expectation: siblingsStartedExpectation)
        let siblingsCompletedExpectation = expectation(description: "parallel siblings completed")
        siblingsCompletedExpectation.expectedFulfillmentCount = 28
        let siblingsCompleted = Phase52RequestSignal(expectation: siblingsCompletedExpectation)
        let siblingGate = Phase52AsyncGate()
        let interrupted = Task.detached { () -> Phase52RequestSnapshot in
            let row = rows[0]
            let plan = BeautyEffectResolver.resolve(
                parameters: row.makeParameters(1),
                faceGeometry: EyebrowSafetyFixtures.face(),
                onProviderResolutionStarted: resolverEntered.signal,
                onProviderWorkStarted: providerBarrier.enterAndWaitForRelease
            )
            return Phase52RequestSnapshot(
                identity: interruptedIdentity,
                fieldName: row.name,
                effectiveStrength: plan.effectiveStrengths[keyPath: row.effectiveValue],
                warningCodes: plan.warnings.map(\.code).sorted(),
                eyebrowActive: plan.activeDomains.contains(.eyebrows),
                eyebrowSkipped: plan.skippedDomains.contains(.eyebrows),
                activeCount: plan.metrics["beauty.effects.activeCount"] ?? 0,
                skippedEyebrowCount: plan.metrics["beauty.effects.skippedEyebrowDomains"] ?? 0,
                geometryPointCount: plan.metrics["beauty.effects.geometryPointCount"] ?? 0
            )
        }

        await fulfillment(
            of: [resolverEntered.expectation, providerBarrier.entered.expectation],
            timeout: 10
        )
        guard resolverEntered.count == 1, providerBarrier.entered.count == 1 else {
            interrupted.cancel()
            providerBarrier.release()
            await siblingGate.release()
            _ = await interrupted.value
            XCTFail("resolver/provider entry callbacks must complete before the bounded timeout")
            return
        }
        XCTAssertEqual(resolverEntered.count, 1)
        XCTAssertEqual(providerBarrier.entered.count, 1)
        XCTAssertEqual(providerBarrier.releaseCount, 0)

        let siblings = Task { () -> [Phase52RequestSnapshot] in
            await withTaskGroup(
                of: Phase52RequestSnapshot.self,
                returning: [Phase52RequestSnapshot].self
            ) { group in
                for index in 0..<28 {
                    let row = rows[index % rows.count]
                    group.addTask {
                        siblingsStarted.signal()
                        await siblingGate.wait()
                        let valid = index.isMultiple(of: 2)
                        let face = valid
                            ? EyebrowSafetyFixtures.face()
                            : EyebrowSafetyFixtures.unavailableFace(for: row.narrowestUnavailableFixture)
                        let plan = BeautyEffectResolver.resolve(
                            parameters: row.makeParameters(1),
                            faceGeometry: face
                        )
                        let snapshot = Phase52RequestSnapshot(
                            identity: index,
                            fieldName: row.name,
                            effectiveStrength: plan.effectiveStrengths[keyPath: row.effectiveValue],
                            warningCodes: plan.warnings.map(\.code).sorted(),
                            eyebrowActive: plan.activeDomains.contains(.eyebrows),
                            eyebrowSkipped: plan.skippedDomains.contains(.eyebrows),
                            activeCount: plan.metrics["beauty.effects.activeCount"] ?? 0,
                            skippedEyebrowCount: plan.metrics["beauty.effects.skippedEyebrowDomains"] ?? 0,
                            geometryPointCount: plan.metrics["beauty.effects.geometryPointCount"] ?? 0
                        )
                        siblingsCompleted.signal()
                        return snapshot
                    }
                }
                return await group.reduce(into: []) { $0.append($1) }
            }
        }

        await fulfillment(of: [siblingsStarted.expectation], timeout: 10)
        guard siblingsStarted.count == 28 else {
            interrupted.cancel()
            providerBarrier.release()
            await siblingGate.release()
            _ = await interrupted.value
            siblings.cancel()
            _ = await siblings.value
            XCTFail("all sibling requests must start before the bounded timeout")
            return
        }

        interrupted.cancel()
        XCTAssertTrue(interrupted.isCancelled)
        providerBarrier.release()
        let interruptedResult = await interrupted.value
        XCTAssertEqual(
            siblingsCompleted.count,
            0,
            "siblings must remain suspended until interrupted cancellation is released and joined"
        )

        await siblingGate.release()
        await fulfillment(of: [siblingsCompleted.expectation], timeout: 10)
        guard siblingsCompleted.count == 28 else {
            siblings.cancel()
            await siblingGate.release()
            _ = await siblings.value
            XCTFail("all sibling requests must complete before the bounded timeout")
            return
        }
        let results = await siblings.value

        XCTAssertEqual(results.count, 28)
        XCTAssertEqual(Set(results.map(\.identity)).count, 28)
        for result in results {
            let valid = result.identity.isMultiple(of: 2)
            XCTAssertEqual(result.effectiveStrength, valid ? 0.25 : 0, result.fieldName)
            XCTAssertEqual(result.eyebrowActive, valid, result.fieldName)
            XCTAssertEqual(result.eyebrowSkipped, !valid, result.fieldName)
            XCTAssertEqual(result.activeCount, valid ? 1 : 0, result.fieldName)
            XCTAssertEqual(result.skippedEyebrowCount, valid ? 0 : 1, result.fieldName)
            XCTAssertEqual(result.geometryPointCount > 0, valid, result.fieldName)
            XCTAssertEqual(
                result.warningCodes.contains("eyebrow_inputs_missing"),
                !valid,
                result.fieldName
            )
        }
        XCTAssertEqual(resolverEntered.count, 1, "nil callbacks in sibling requests cannot signal")
        XCTAssertEqual(providerBarrier.entered.count, 1, "sibling requests cannot enter another request's barrier")

        XCTAssertEqual(interruptedResult.identity, interruptedIdentity)
        XCTAssertEqual(interruptedResult.effectiveStrength, rows[0].cap)
        XCTAssertTrue(interruptedResult.eyebrowActive)
        XCTAssertFalse(interruptedResult.eyebrowSkipped)
        XCTAssertFalse(interruptedResult.warningCodes.contains("eyebrow_inputs_missing"))
        XCTAssertEqual(interruptedResult.activeCount, 1)
        XCTAssertEqual(interruptedResult.skippedEyebrowCount, 0)
        XCTAssertGreaterThan(interruptedResult.geometryPointCount, 0)
        XCTAssertEqual(providerBarrier.releaseCount, 1)
        XCTAssertFalse(providerBarrier.waitTimedOut)

        for (offset, row) in rows.enumerated() {
            let identity = 20_000 + offset
            let plan = BeautyEffectResolver.resolve(
                parameters: row.makeParameters(1),
                faceGeometry: EyebrowSafetyFixtures.face()
            )
            XCTAssertEqual(plan.effectiveStrengths[keyPath: row.effectiveValue], row.cap, row.name)
            XCTAssertTrue(plan.activeDomains.contains(.eyebrows), "\(identity) \(row.name)")
            XCTAssertFalse(plan.skippedDomains.contains(.eyebrows), "\(identity) \(row.name)")
            XCTAssertFalse(plan.warnings.contains { $0.code == "eyebrow_inputs_missing" }, row.name)
            XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0, row.name)
            assertRedacted(plan)
        }
        XCTAssertEqual(resolverEntered.count, 1)
        XCTAssertEqual(providerBarrier.entered.count, 1)
        XCTAssertEqual(providerBarrier.releaseCount, 1)
    }

    private var phase50AllEyebrowParameters: BeautyParameters {
        BeautyParameters(
            eyebrowYPosition: -1,
            eyebrowThickness: 1,
            eyebrowLength: -1,
            eyebrowSpacing: 1,
            eyebrowHeadSpacing: -1,
            eyebrowTilt: 1,
            eyebrowPeakDefinition: 1
        )
    }

    private var phase50EyebrowEffectiveKeyPaths: [KeyPath<BeautyEffectiveStrengths, Float>] {
        [
            \.eyebrowYPosition, \.eyebrowThickness, \.eyebrowLength, \.eyebrowSpacing,
            \.eyebrowHeadSpacing, \.eyebrowTilt, \.eyebrowPeakDefinition,
        ]
    }

    private func phase50EyebrowTrace(
        side: BeautyObservedEyebrowSide,
        points: [SIMD2<Float>]? = nil,
        apexIndex: Int? = 2
    ) -> BeautyEyebrowSemanticTrace {
        let canonical = points ?? (side == .left
            ? [.init(0.25, 0.40), .init(0.30, 0.36), .init(0.36, 0.34), .init(0.42, 0.37), .init(0.47, 0.41)]
            : [.init(0.75, 0.40), .init(0.70, 0.36), .init(0.64, 0.34), .init(0.58, 0.37), .init(0.53, 0.41)])
        return BeautyEyebrowSemanticTrace(
            side: side,
            points: canonical,
            innerEndpoint: canonical[0],
            outerEndpoint: canonical[canonical.count - 1],
            center: canonical.reduce(.zero, +) / Float(canonical.count),
            apexIndex: apexIndex
        )
    }

    private func phase50EyebrowFace(
        support: BeautyEyebrowSemanticSupport?,
        freshness: LandmarkGeometryFreshness = .fresh
    ) -> FaceGeometry {
        let base = FaceGeometry.fixture
        return FaceGeometry(
            bounds: base.bounds,
            faceContour: base.faceContour,
            observedFaceSupport: base.observedFaceSupport,
            leftEye: base.leftEye,
            rightEye: base.rightEye,
            nose: base.nose,
            noseRoot: base.noseRoot,
            noseTip: base.noseTip,
            outerLips: base.outerLips,
            upperLips: base.upperLips,
            lowerLips: base.lowerLips,
            innerLips: base.innerLips,
            leftEyeSupport: base.leftEyeSupport,
            rightEyeSupport: base.rightEyeSupport,
            freshness: freshness,
            observedEyebrowSupport: support
        )
    }

    func testPhase35ReviewConflictThresholdCrossingSignedMouthFieldsAreSkippedAndExcluded() {
        let fields: [(
            name: String,
            parameter: WritableKeyPath<BeautyParameters, Float>,
            effective: WritableKeyPath<BeautyEffectiveStrengths, Float>,
            emission: KeyPath<MouthWarpFieldEmissions, [WarpControlPoint]>
        )] = [
            ("mouthSize", \.mouthSize, \.mouthSize, \.mouthSize),
            ("mouthWidth", \.mouthWidth, \.mouthWidth, \.mouthWidth),
        ]
        let expectedTotal = phase35EyeAndNoseConflictTotal
        let expectedScale = 1 / expectedTotal

        for field in fields {
            for direction: Float in [1, -1] {
                var parameters = phase35EyeAndNoseConflictParameters
                let requested = direction * Float.ulpOfOne * 2
                parameters[keyPath: field.parameter] = requested
                var preConflictStrengths = BeautyEffectiveStrengths()
                preConflictStrengths[keyPath: field.effective] = requested
                XCTAssertFalse(
                    MouthWarpProvider()
                        .fieldEmissions(face: .fixture, strengths: preConflictStrengths)[keyPath: field.emission]
                        .isEmpty,
                    "The regression fixture must emit before conflict weakening: \(field.name)."
                )

                let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
                let finalEmissions = MouthWarpProvider().fieldEmissions(
                    face: .fixture,
                    strengths: plan.effectiveStrengths
                )

                XCTAssertEqual(plan.effectiveStrengths[keyPath: field.effective], 0, field.name)
                XCTAssertTrue(finalEmissions[keyPath: field.emission].isEmpty, field.name)
                XCTAssertEqual(
                    finalEmissions.sanitizing(plan.effectiveStrengths),
                    plan.effectiveStrengths,
                    "Every retained mouth strength must emit at its final effective value: \(field.name)."
                )
                XCTAssertTrue(plan.activeDomains.isSuperset(of: [.eyes, .nose]), field.name)
                XCTAssertFalse(plan.activeDomains.contains(.mouth), field.name)
                XCTAssertTrue(plan.skippedDomains.contains(.mouth), field.name)
                XCTAssertEqual(plan.metrics["beauty.effects.skippedMouthDomains"], 1, field.name)
                XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 10, field.name)
                XCTAssertEqual(
                    plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
                    Double(expectedScale),
                    accuracy: 0.0000001,
                    field.name
                )
                XCTAssertEqual(
                    plan.warnings.filter { $0.code == "combined_geometry_weakened" }.count,
                    1,
                    field.name
                )
                XCTAssertEqual(
                    plan.warnings.filter { $0.code == "mouth_inputs_missing" }.count,
                    1,
                    field.name
                )
                assertRedacted(plan)
            }
        }
    }

    func testPhase35ReviewConflictThresholdCrossingSignedMouthFieldsKeepSupportedSibling() {
        let cases: [(
            name: String,
            droppedParameter: WritableKeyPath<BeautyParameters, Float>,
            droppedEffective: WritableKeyPath<BeautyEffectiveStrengths, Float>,
            droppedEmission: KeyPath<MouthWarpFieldEmissions, [WarpControlPoint]>,
            siblingParameter: WritableKeyPath<BeautyParameters, Float>,
            siblingEffective: KeyPath<BeautyEffectiveStrengths, Float>,
            siblingEmission: KeyPath<MouthWarpFieldEmissions, [WarpControlPoint]>,
            siblingCap: Float
        )] = [
            ("mouthSize with mouthWidth", \.mouthSize, \.mouthSize, \.mouthSize, \.mouthWidth, \.mouthWidth, \.mouthWidth, BeautySafetyCaps.mouthWidth),
            ("mouthWidth with mouthSize", \.mouthWidth, \.mouthWidth, \.mouthWidth, \.mouthSize, \.mouthSize, \.mouthSize, BeautySafetyCaps.mouthSize),
        ]

        for entry in cases {
            for direction: Float in [1, -1] {
                var parameters = phase35EyeAndNoseConflictParameters
                let requested = direction * Float.ulpOfOne * 2
                parameters[keyPath: entry.droppedParameter] = requested
                parameters[keyPath: entry.siblingParameter] = 1
                let expectedScale = 1 / (phase35EyeAndNoseConflictTotal + entry.siblingCap)
                var preConflictStrengths = BeautyEffectiveStrengths()
                preConflictStrengths[keyPath: entry.droppedEffective] = requested
                XCTAssertFalse(
                    MouthWarpProvider()
                        .fieldEmissions(face: .fixture, strengths: preConflictStrengths)[keyPath: entry.droppedEmission]
                        .isEmpty,
                    "The regression fixture must emit before conflict weakening: \(entry.name)."
                )

                let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
                let finalEmissions = MouthWarpProvider().fieldEmissions(
                    face: .fixture,
                    strengths: plan.effectiveStrengths
                )

                XCTAssertEqual(plan.effectiveStrengths[keyPath: entry.droppedEffective], 0, entry.name)
                XCTAssertEqual(
                    plan.effectiveStrengths[keyPath: entry.siblingEffective],
                    entry.siblingCap * expectedScale,
                    accuracy: 0.0000001,
                    entry.name
                )
                XCTAssertTrue(finalEmissions[keyPath: entry.droppedEmission].isEmpty, entry.name)
                XCTAssertFalse(finalEmissions[keyPath: entry.siblingEmission].isEmpty, entry.name)
                XCTAssertEqual(
                    finalEmissions.sanitizing(plan.effectiveStrengths),
                    plan.effectiveStrengths,
                    "Every retained mouth strength must emit at its final effective value: \(entry.name)."
                )
                XCTAssertTrue(plan.activeDomains.isSuperset(of: [.eyes, .nose, .mouth]), entry.name)
                XCTAssertFalse(plan.skippedDomains.contains(.mouth), entry.name)
                XCTAssertNil(plan.metrics["beauty.effects.skippedMouthDomains"], entry.name)
                XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 11, entry.name)
                XCTAssertEqual(
                    plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
                    Double(expectedScale),
                    accuracy: 0.0000001,
                    entry.name
                )
                XCTAssertEqual(
                    plan.warnings.filter { $0.code == "combined_geometry_weakened" }.count,
                    1,
                    entry.name
                )
                XCTAssertFalse(plan.warnings.contains { $0.code == "mouth_inputs_missing" }, entry.name)
                assertRedacted(plan)
            }
        }
    }

    func testNOSE12AllSixRequestedFieldsConvergeWithProviderEmptyRootAndSupportedSiblings() {
        let provider = NoseWarpProvider()
        let retainedTotal = BeautySafetyCaps.faceSlim +
            BeautySafetyCaps.eyeSize +
            BeautySafetyCaps.noseSlim +
            BeautySafetyCaps.noseWingSlim +
            BeautySafetyCaps.noseTipSize +
            BeautySafetyCaps.noseBridge +
            BeautySafetyCaps.noseTipLift +
            BeautySafetyCaps.mouthSize
        let expectedScale = 1 / retainedTotal

        XCTAssertEqual(retainedTotal, 2.95, accuracy: 0.000001)
        for tipDirection: Float in [1, -1] {
            let plan = BeautyEffectResolver.resolve(
                parameters: BeautyParameters(
                    faceSlim: 1,
                    eyeSize: 1,
                    noseSlim: 1,
                    noseWingSlim: 1,
                    noseTipSize: tipDirection,
                    noseBridge: 1,
                    noseRootNarrowing: 1,
                    noseTipLift: 1,
                    mouthSize: 1
                ),
                faceGeometry: phase37ProviderEmptyRootFace
            )
            let emissions = provider.fieldEmissions(
                face: phase37ProviderEmptyRootFace,
                strengths: plan.effectiveStrengths
            )

            XCTAssertEqual(plan.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim * expectedScale, accuracy: 0.0000001)
            XCTAssertEqual(plan.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize * expectedScale, accuracy: 0.0000001)
            XCTAssertEqual(plan.effectiveStrengths.noseSlim, BeautySafetyCaps.noseSlim * expectedScale, accuracy: 0.0000001)
            XCTAssertEqual(plan.effectiveStrengths.noseWingSlim, BeautySafetyCaps.noseWingSlim * expectedScale, accuracy: 0.0000001)
            XCTAssertEqual(plan.effectiveStrengths.noseTipSize, tipDirection * BeautySafetyCaps.noseTipSize * expectedScale, accuracy: 0.0000001)
            XCTAssertEqual(plan.effectiveStrengths.noseBridge, BeautySafetyCaps.noseBridge * expectedScale, accuracy: 0.0000001)
            XCTAssertEqual(plan.effectiveStrengths.noseRootNarrowing, 0)
            XCTAssertEqual(plan.effectiveStrengths.noseTipLift, BeautySafetyCaps.noseTipLift * expectedScale, accuracy: 0.0000001)
            XCTAssertEqual(plan.effectiveStrengths.mouthSize, BeautySafetyCaps.mouthSize * expectedScale, accuracy: 0.0000001)
            XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 8)
            XCTAssertEqual(
                plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
                Double(expectedScale),
                accuracy: 0.0000001
            )
            XCTAssertEqual(plan.warnings.filter { $0.code == "combined_geometry_weakened" }.count, 1)
            XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth]))
            XCTAssertFalse(plan.skippedDomains.contains(.nose))
            XCTAssertFalse(plan.warnings.contains { $0.code == "nose_inputs_missing" })

            XCTAssertFalse(emissions.noseSlim.isEmpty)
            XCTAssertFalse(emissions.noseWingSlim.isEmpty)
            XCTAssertFalse(emissions.noseTipSize.isEmpty)
            XCTAssertFalse(emissions.noseBridge.isEmpty)
            XCTAssertTrue(emissions.noseRootNarrowing.isEmpty)
            XCTAssertFalse(emissions.noseTipLift.isEmpty)
            XCTAssertEqual(
                emissions.sanitizing(plan.effectiveStrengths),
                plan.effectiveStrengths,
                "Final effective strengths and final provider eligibility must converge."
            )
            XCTAssertFalse(
                FaceShapeWarpProvider()
                    .makeControlPoints(face: phase37ProviderEmptyRootFace, strengths: plan.effectiveStrengths)
                    .points
                    .isEmpty
            )
            XCTAssertFalse(
                EyeWarpProvider()
                    .makeControlPoints(face: phase37ProviderEmptyRootFace, strengths: plan.effectiveStrengths)
                    .points
                    .isEmpty
            )
            XCTAssertFalse(
                MouthWarpProvider()
                    .fieldEmissions(face: phase37ProviderEmptyRootFace, strengths: plan.effectiveStrengths)
                    .mouthSize
                    .isEmpty
            )
            assertRedacted(plan)
        }
    }

    func testNOSE12ProviderEmptyOnlyNoseRequestIsRemovedFromConflictAndDomainEvidence() {
        let retainedTotal = BeautySafetyCaps.faceSlim + BeautySafetyCaps.eyeSize + BeautySafetyCaps.mouthSize
        let expectedScale = 1 / retainedTotal
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                faceSlim: 1,
                eyeSize: 1,
                noseRootNarrowing: 1,
                mouthSize: 1
            ),
            faceGeometry: phase37ProviderEmptyRootFace
        )
        let emissions = NoseWarpProvider().fieldEmissions(
            face: phase37ProviderEmptyRootFace,
            strengths: plan.effectiveStrengths
        )

        XCTAssertEqual(retainedTotal, 1.40, accuracy: 0.0000001)
        XCTAssertEqual(plan.effectiveStrengths.noseRootNarrowing, 0)
        XCTAssertTrue(emissions.points.isEmpty)
        XCTAssertEqual(emissions.sanitizing(plan.effectiveStrengths), plan.effectiveStrengths)
        XCTAssertEqual(plan.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim * expectedScale, accuracy: 0.0000001)
        XCTAssertEqual(plan.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize * expectedScale, accuracy: 0.0000001)
        XCTAssertEqual(plan.effectiveStrengths.mouthSize, BeautySafetyCaps.mouthSize * expectedScale, accuracy: 0.0000001)
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 3)
        XCTAssertEqual(
            plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
            Double(expectedScale),
            accuracy: 0.0000001
        )
        XCTAssertEqual(plan.warnings.filter { $0.code == "combined_geometry_weakened" }.count, 1)
        XCTAssertEqual(plan.warnings.filter { $0.code == "nose_inputs_missing" }.count, 1)
        XCTAssertFalse(plan.activeDomains.contains(.nose))
        XCTAssertTrue(plan.skippedDomains.contains(.nose))
        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .eyes, .mouth]))
        assertRedacted(plan)
    }

    func testNoseGeometryProducesDeterministicProxyEvidenceAndCapMetadata() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(noseSlim: 1, noseTipSize: 1),
            faceGeometry: .fixture
        )
        let input: [UInt8] = [
            30, 40, 50, 255,
            90, 100, 110, 255
        ]

        let output = BeautyGeometryEffectPipeline.applyMVPProxy(toBGRA: input, plan: plan, face: .fixture)

        XCTAssertTrue(plan.activeDomains.contains(.nose))
        XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertNotEqual(output, input)
    }

    private func assertConflictThresholdCrossingNoseField(
        parameters: BeautyParameters,
        dropped: KeyPath<BeautyEffectiveStrengths, Float>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
        let expectedTotal = BeautySafetyCaps.faceSlim +
            BeautySafetyCaps.faceSmall +
            BeautySafetyCaps.faceVShape +
            BeautySafetyCaps.jawSlim +
            BeautySafetyCaps.chinLength +
            BeautySafetyCaps.noseSlim
        let expectedScale = 1 / expectedTotal
        let finalEmissions = NoseWarpProvider().fieldEmissions(
            face: .fixture,
            strengths: plan.effectiveStrengths
        )

        XCTAssertEqual(plan.effectiveStrengths[keyPath: dropped], 0, file: file, line: line)
        XCTAssertEqual(
            plan.effectiveStrengths.noseSlim,
            BeautySafetyCaps.noseSlim * expectedScale,
            accuracy: 0.0000001,
            file: file,
            line: line
        )
        XCTAssertEqual(
            plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
            Double(expectedScale),
            accuracy: 0.0000001,
            file: file,
            line: line
        )
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 6, file: file, line: line)
        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .nose]), file: file, line: line)
        XCTAssertFalse(plan.skippedDomains.contains(.nose), file: file, line: line)
        XCTAssertEqual(
            plan.warnings.filter { $0.code == "combined_geometry_weakened" }.count,
            1,
            file: file,
            line: line
        )
        XCTAssertFalse(plan.warnings.contains { $0.code == "nose_inputs_missing" }, file: file, line: line)
        XCTAssertFalse(finalEmissions.noseSlim.isEmpty, file: file, line: line)
        XCTAssertEqual(
            finalEmissions.sanitizing(plan.effectiveStrengths),
            plan.effectiveStrengths,
            "Every retained nose strength must emit at its final effective value.",
            file: file,
            line: line
        )
        assertRedacted(plan, file: file, line: line)
    }

    private var phase35EyeAndNoseConflictParameters: BeautyParameters {
        BeautyParameters(
            eyeSize: 1,
            eyeDistance: 1,
            eyeYPosition: 1,
            eyeTailLift: 1,
            noseSlim: 1,
            noseWingSlim: 1,
            noseTipSize: 1,
            noseBridge: 1,
            noseRootNarrowing: 1,
            noseTipLift: 1
        )
    }

    private var phase35EyeAndNoseConflictTotal: Float {
        BeautySafetyCaps.eyeSize +
            BeautySafetyCaps.eyeDistance +
            BeautySafetyCaps.eyeYPosition +
            BeautySafetyCaps.eyeTailLift +
            BeautySafetyCaps.noseSlim +
            BeautySafetyCaps.noseWingSlim +
            BeautySafetyCaps.noseTipSize +
            BeautySafetyCaps.noseBridge +
            BeautySafetyCaps.noseRootNarrowing +
            BeautySafetyCaps.noseTipLift
    }

    private var phase37ProviderEmptyRootFace: FaceGeometry {
        FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: FaceGeometry.fixture.leftEye,
            rightEye: FaceGeometry.fixture.rightEye,
            nose: FaceGeometry.fixture.nose,
            noseRoot: [
                SIMD2<Float>(0.49989995, 0.488),
                SIMD2<Float>(0.50010005, 0.488)
            ],
            noseTip: FaceGeometry.fixture.noseTip,
            outerLips: FaceGeometry.fixture.outerLips
        )
    }

    func testReusedEyeGeometrySkipsEyesZerosStrengthsAndPreservesNonEyeReuseReduction() {
        let eyeOnlyPlan = BeautyEffectResolver.resolve(
            parameters: allFourteenEyeParameters,
            faceGeometry: .reused
        )
        XCTAssertNil(eyeOnlyPlan.metrics["beauty.effects.geometryPointCount"])
        assertEyeStrengthsAreZero(eyeOnlyPlan)
        assertNoEyeSideOrRawGeometryDisclosure(eyeOnlyPlan)

        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                faceSlim: 1,
                eyeSize: 1,
                eyeDistance: -1,
                eyeYPosition: 1,
                eyeTailLift: 1,
                eyeHeight: 1,
                eyeLength: 1,
                upperEyelidLift: 1,
                pupilSize: 1,
                gazeCorrection: 1,
                lowerEyelidDrop: 1,
                eyeTilt: -1,
                innerCornerOpen: 1,
                outerCornerOpen: 1,
                eyeSymmetry: 1,
                noseSlim: 1,
                mouthSize: 1
            ),
            faceGeometry: .reused
        )

        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.skippedDomains.contains(.eyes))
        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .nose, .mouth]))
        assertEyeStrengthsAreZero(plan)
        XCTAssertEqual(plan.metrics["beauty.effects.skippedEyeDomains"], 1)
        XCTAssertEqual(plan.metrics["beauty.effects.reusedGeometryScale"], 0.5)
        XCTAssertTrue(plan.warnings.contains {
            $0.code == "eye_geometry_reused_skipped" && $0.message == "Eye effects skipped: inputs reused."
        })
        XCTAssertLessThan(plan.effectiveStrengths.noseSlim, BeautySafetyCaps.noseSlim)
        XCTAssertTrue(plan.warnings.contains { $0.code == "geometry_stale_reduced" })
        assertRedacted(plan)
        assertNoEyeSideOrRawGeometryDisclosure(plan)
    }

    func testStaleEyeGeometrySkipsEyesZerosStrengthsWithDistinctReason() {
        let plan = BeautyEffectResolver.resolve(
            parameters: allFourteenEyeParameters,
            faceGeometry: .stale
        )

        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.skippedDomains.contains(.eyes))
        assertEyeStrengthsAreZero(plan)
        XCTAssertEqual(plan.metrics["beauty.effects.skippedEyeDomains"], 1)
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
        XCTAssertTrue(plan.warnings.contains {
            $0.code == "eye_geometry_stale_skipped" && $0.message == "Eye effects skipped: inputs stale."
        })
        assertRedacted(plan)
        assertNoEyeSideOrRawGeometryDisclosure(plan)
    }

    func testMissingMouthSkipsOnlyMouthAndKeepsEyeNoseAndSafeDomainsActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                eyeSize: 0.2,
                noseSlim: 0.2,
                mouthSize: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            ),
            faceGeometry: .missingMouth
        )

        XCTAssertFalse(plan.activeDomains.contains(.mouth))
        XCTAssertTrue(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.activeDomains.contains(.nose))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertEqual(plan.skippedDomains, [.mouth])
        XCTAssertTrue(plan.warnings.contains { $0.code == "mouth_inputs_missing" })
        XCTAssertEqual(plan.effectiveStrengths.mouthSize, 0)
        XCTAssertEqual(plan.effectiveStrengths.mouthWidth, 0)
        XCTAssertEqual(plan.effectiveStrengths.smile, 0)
    }

    func testReusedLandmarksReduceMouthGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(mouthSize: -1, mouthWidth: 1, smile: 1, lipColor: 1),
            faceGeometry: .reused
        )

        XCTAssertTrue(plan.activeDomains.contains(.mouth))
        XCTAssertTrue(plan.activeDomains.contains(.lipColor))
        XCTAssertEqual(plan.effectiveStrengths.mouthSize, -0.175, accuracy: 0.0001)
        XCTAssertEqual(plan.effectiveStrengths.mouthWidth, 0.175, accuracy: 0.0001)
        XCTAssertEqual(plan.effectiveStrengths.smile, 0.25, accuracy: 0.0001)
        XCTAssertEqual(plan.effectiveStrengths.lipColor, 0.50, accuracy: 0.0001)
        XCTAssertTrue(plan.warnings.contains { $0.code == "geometry_stale_reduced" })
    }

    func testPhase38MOUTH08LocalSupportFailuresZeroOnlyDependentFields() {
        let requested = BeautyParameters(
            mouthYPosition: 1,
            mouthTilt: -1,
            mouthXPosition: 1,
            lipPeakDefinition: 1,
            lipPlump: 1
        )
        let cases: [(String, FaceGeometry, Bool, Bool)] = [
            ("missing inner", .missingInnerLips, false, false),
            ("missing upper", .missingUpperLips, false, false),
            ("missing lower", .missingLowerLips, true, false),
            ("non-finite inner", .nonFiniteInnerLips, false, false),
            ("duplicate upper", .duplicateUpperLips, false, false),
            ("duplicate lower", .duplicateLowerLips, true, false),
        ]

        for (name, face, peakEligible, plumpEligible) in cases {
            let plan = BeautyEffectResolver.resolve(parameters: requested, faceGeometry: face)
            XCTAssertTrue(plan.activeDomains.contains(.mouth), name)
            XCTAssertEqual(plan.effectiveStrengths.mouthYPosition, 0.25, accuracy: 0.000001, name)
            XCTAssertEqual(plan.effectiveStrengths.mouthTilt, -0.25, accuracy: 0.000001, name)
            XCTAssertEqual(plan.effectiveStrengths.mouthXPosition, 0.25, accuracy: 0.000001, name)
            XCTAssertEqual(plan.effectiveStrengths.lipPeakDefinition, peakEligible ? 0.25 : 0, accuracy: 0.000001, name)
            XCTAssertEqual(plan.effectiveStrengths.lipPlump, plumpEligible ? 0.25 : 0, accuracy: 0.000001, name)
            XCTAssertFalse(plan.warnings.contains { $0.code == "mouth_inputs_missing" }, name)
            XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0, name)
            assertRedacted(plan)
        }
    }

    func testPhase38MOUTH08ReusedStaleMissingOuterAndNoFaceApplyPerMouthGeometry() {
        let requested = BeautyParameters(
            mouthYPosition: -1,
            mouthTilt: 1,
            mouthXPosition: -1,
            lipPeakDefinition: 1,
            lipPlump: 1
        )
        let reused = BeautyEffectResolver.resolve(parameters: requested, faceGeometry: .reused)
        XCTAssertEqual(reused.effectiveStrengths.mouthYPosition, -0.125, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.mouthTilt, 0.125, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.mouthXPosition, -0.125, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.lipPeakDefinition, 0.125, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.lipPlump, 0.125, accuracy: 0.000001)
        XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5)
        XCTAssertTrue(reused.activeDomains.contains(.mouth))

        for (name, face) in [("stale", FaceGeometry.stale), ("missing outer", .missingOuterLips)] {
            let plan = BeautyEffectResolver.resolve(parameters: requested, faceGeometry: face)
            assertPhase38MouthGeometryIsZero(plan, name: name)
            XCTAssertTrue(plan.skippedDomains.contains(.mouth), name)
            XCTAssertFalse(plan.activeDomains.contains(.mouth), name)
        }
        let noFace = BeautyEffectResolver.resolve(parameters: requested, faceGeometry: nil)
        assertPhase38MouthGeometryIsZero(noFace, name: "no face")
        XCTAssertTrue(noFace.skippedDomains.contains(.mouth))
    }

    func testMOUTH13AllEightFieldsReuseAndSequentialFreshnessDoNotCarryState() {
        let parameters = BeautyParameters(
            brightness: 0.2,
            mouthSize: -1,
            mouthWidth: 1,
            smile: 1,
            mouthYPosition: -1,
            mouthTilt: 1,
            mouthXPosition: -1,
            lipPeakDefinition: 1,
            lipPlump: 1,
            lipColor: 1,
            filterId: "soft_clean",
            filterIntensity: 0.5
        )

        let fresh = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
        let freshTotal: Float = 0.35 + 0.35 + 0.50 + (5 * 0.25)
        let freshScale: Float = 1 / freshTotal
        XCTAssertEqual(fresh.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(freshScale), accuracy: 0.000001)
        XCTAssertEqual(fresh.metrics["beauty.effects.weakenedCount"], 8)
        XCTAssertEqual(fresh.effectiveStrengths.mouthSize, -0.35 * freshScale, accuracy: 0.000001)
        XCTAssertEqual(fresh.effectiveStrengths.mouthWidth, 0.35 * freshScale, accuracy: 0.000001)
        XCTAssertEqual(fresh.effectiveStrengths.smile, 0.50 * freshScale, accuracy: 0.000001)
        XCTAssertEqual(fresh.effectiveStrengths.mouthYPosition, -0.25 * freshScale, accuracy: 0.000001)
        XCTAssertEqual(fresh.effectiveStrengths.mouthTilt, 0.25 * freshScale, accuracy: 0.000001)
        XCTAssertEqual(fresh.effectiveStrengths.mouthXPosition, -0.25 * freshScale, accuracy: 0.000001)
        XCTAssertEqual(fresh.effectiveStrengths.lipPeakDefinition, 0.25 * freshScale, accuracy: 0.000001)
        XCTAssertEqual(fresh.effectiveStrengths.lipPlump, 0.25 * freshScale, accuracy: 0.000001)

        let reused = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .reused)
        XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5)
        let reusedTotal = freshTotal * 0.5
        let reusedScale: Float = 1 / reusedTotal
        XCTAssertEqual(reused.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(reusedScale), accuracy: 0.000001)
        XCTAssertEqual(reused.metrics["beauty.effects.weakenedCount"], 8)
        XCTAssertEqual(reused.effectiveStrengths.mouthSize, -0.175 * reusedScale, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.mouthWidth, 0.175 * reusedScale, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.smile, 0.25 * reusedScale, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.mouthYPosition, -0.125 * reusedScale, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.mouthTilt, 0.125 * reusedScale, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.mouthXPosition, -0.125 * reusedScale, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.lipPeakDefinition, 0.125 * reusedScale, accuracy: 0.000001)
        XCTAssertEqual(reused.effectiveStrengths.lipPlump, 0.125 * reusedScale, accuracy: 0.000001)

        let transitions: [(String, FaceGeometry?)] = [
            ("stale", .stale),
            ("no face", nil),
            ("fresh again", .fixture),
        ]
        for (name, face) in transitions {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            if name == "fresh again" {
                XCTAssertEqual(plan.effectiveStrengths.mouthSize, fresh.effectiveStrengths.mouthSize, accuracy: 0.000001)
                XCTAssertEqual(plan.effectiveStrengths.lipPlump, fresh.effectiveStrengths.lipPlump, accuracy: 0.000001)
            } else {
                assertAllMouthGeometryIsZero(plan, name: name)
                XCTAssertTrue(plan.skippedDomains.contains(.mouth), name)
            }
            XCTAssertTrue(plan.activeDomains.contains(.color), name)
            XCTAssertTrue(plan.activeDomains.contains(.filter), name)
            XCTAssertEqual(plan.effectiveStrengths.lipColor, name == "no face" ? 0 : 0.50, accuracy: 0.000001, name)
            assertRedacted(plan)
        }
    }

    func testMOUTH14MissingInnerFieldsAreExcludedFromExactCombinedEvidenceAndDispatch() {
        let parameters = BeautyParameters(
            faceSlim: 1,
            eyeSize: 1,
            noseSlim: 1,
            noseWingSlim: 1,
            noseTipSize: -1,
            noseBridge: 1,
            noseRootNarrowing: 1,
            noseTipLift: 1,
            mouthSize: -1,
            mouthWidth: 1,
            smile: 1,
            mouthYPosition: -1,
            mouthTilt: 1,
            mouthXPosition: -1,
            lipPeakDefinition: 1,
            lipPlump: 1
        )
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .missingInnerLips)
        let retainedTotal: Float = 0.60 + 0.45 + 0.35 + 0.35 + 0.30 + 0.30 + 0.25 + 0.25 +
            0.35 + 0.35 + 0.50 + 0.25 + 0.25 + 0.25
        let expectedScale: Float = 1 / retainedTotal

        XCTAssertEqual(retainedTotal, 4.80, accuracy: 0.000001)
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 14)
        XCTAssertEqual(plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(expectedScale), accuracy: 0.000001)
        XCTAssertEqual(plan.warnings.filter { $0.code == "combined_geometry_weakened" }.count, 1)
        XCTAssertEqual(plan.effectiveStrengths.lipPeakDefinition, 0)
        XCTAssertEqual(plan.effectiveStrengths.lipPlump, 0)
        XCTAssertEqual(plan.effectiveStrengths.mouthYPosition, -0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(plan.effectiveStrengths.mouthTilt, 0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertEqual(plan.effectiveStrengths.mouthXPosition, -0.25 * expectedScale, accuracy: 0.000001)
        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth]))

        let emissions = MouthWarpProvider().fieldEmissions(face: .missingInnerLips, strengths: plan.effectiveStrengths)
        XCTAssertFalse(emissions.mouthSize.isEmpty)
        XCTAssertFalse(emissions.mouthYPosition.isEmpty)
        XCTAssertTrue(emissions.lipPeakDefinition.isEmpty)
        XCTAssertTrue(emissions.lipPlump.isEmpty)
        XCTAssertEqual(emissions.sanitizing(plan.effectiveStrengths), plan.effectiveStrengths)
        assertRedacted(plan)
    }

    func testPhase38MOUTH08ProviderEmptyTinyFieldIsRemovedFromFinalEvidence() {
        let parameters = BeautyParameters(mouthYPosition: Float.ulpOfOne * 2)
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)

        XCTAssertEqual(plan.effectiveStrengths.mouthYPosition, 0)
        XCTAssertFalse(plan.activeDomains.contains(.mouth))
        XCTAssertTrue(plan.skippedDomains.contains(.mouth))
        XCTAssertEqual(plan.metrics["beauty.effects.skippedMouthDomains"], 1)
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
        XCTAssertEqual(plan.warnings.filter { $0.code == "mouth_inputs_missing" }.count, 1)
        assertRedacted(plan)
    }

    func testStaleLandmarksSkipStrongMouthGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(brightness: 0.2, mouthSize: -1, mouthWidth: 1, smile: 1, lipColor: 1),
            faceGeometry: .stale
        )

        XCTAssertFalse(plan.activeDomains.contains(.mouth))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.skippedDomains.contains(.mouth))
        XCTAssertTrue(plan.activeDomains.contains(.lipColor), "stale lip color remains a color-domain operation")
        XCTAssertEqual(plan.effectiveStrengths.mouthSize, 0)
        XCTAssertEqual(plan.effectiveStrengths.mouthWidth, 0)
        XCTAssertEqual(plan.effectiveStrengths.smile, 0)
        XCTAssertEqual(plan.effectiveStrengths.lipColor, 0.50, accuracy: 0.0001)
        XCTAssertTrue(plan.warnings.contains { $0.code == "geometry_stale_skipped" })
    }

    private func assertPhase38MouthGeometryIsZero(
        _ plan: BeautyEffectPlan,
        name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(plan.effectiveStrengths.mouthYPosition, 0, name, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.mouthTilt, 0, name, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.mouthXPosition, 0, name, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.lipPeakDefinition, 0, name, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.lipPlump, 0, name, file: file, line: line)
    }

    private func assertAllMouthGeometryIsZero(
        _ plan: BeautyEffectPlan,
        name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(plan.effectiveStrengths.mouthSize, 0, name, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.mouthWidth, 0, name, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.smile, 0, name, file: file, line: line)
        assertPhase38MouthGeometryIsZero(plan, name: name, file: file, line: line)
    }

    func testMissingMouthSkipsLipColorAndKeepsSafeDomainsActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                lipColor: 1,
                filterId: "warm_light",
                filterIntensity: 0.5
            ),
            faceGeometry: .missingMouth
        )

        XCTAssertFalse(plan.activeDomains.contains(.lipColor))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertTrue(plan.skippedDomains.contains(.lipColor))
        XCTAssertTrue(plan.warnings.contains { $0.code == "lip_inputs_missing" })
        XCTAssertEqual(plan.effectiveStrengths.lipColor, 0)
    }

    func testSelectedFaceRoutePreservesGroupSpecificDegradation() {
        let parameters = BeautyParameters(
            brightness: 0.2,
            eyeSize: 1,
            noseSlim: 1,
            mouthSize: 1,
            lipColor: 1,
            filterId: "soft_clean",
            filterIntensity: 0.5
        )

        let missingEye = BeautyEffectResolver.resolve(
            parameters: parameters,
            selectedFaceObservation: .fixture(missing: [.leftEye])
        )
        XCTAssertFalse(missingEye.activeDomains.contains(.eyes))
        XCTAssertTrue(missingEye.activeDomains.contains(.nose))
        XCTAssertTrue(missingEye.activeDomains.contains(.mouth))
        XCTAssertTrue(missingEye.activeDomains.contains(.lipColor))
        XCTAssertTrue(missingEye.activeDomains.contains(.color))
        XCTAssertTrue(missingEye.activeDomains.contains(.filter))
        XCTAssertTrue(missingEye.warnings.contains { $0.code == "eye_inputs_missing" })

        let missingNose = BeautyEffectResolver.resolve(
            parameters: parameters,
            selectedFaceObservation: .fixture(missing: [.nose])
        )
        XCTAssertTrue(missingNose.activeDomains.contains(.eyes))
        XCTAssertFalse(missingNose.activeDomains.contains(.nose))
        XCTAssertTrue(missingNose.activeDomains.contains(.mouth))
        XCTAssertTrue(missingNose.activeDomains.contains(.lipColor))
        XCTAssertTrue(missingNose.warnings.contains { $0.code == "nose_inputs_missing" })

        let missingMouth = BeautyEffectResolver.resolve(
            parameters: parameters,
            selectedFaceObservation: .fixture(missing: [.outerLips])
        )
        XCTAssertTrue(missingMouth.activeDomains.contains(.eyes))
        XCTAssertTrue(missingMouth.activeDomains.contains(.nose))
        XCTAssertFalse(missingMouth.activeDomains.contains(.mouth))
        XCTAssertFalse(missingMouth.activeDomains.contains(.lipColor))
        XCTAssertTrue(missingMouth.warnings.contains { $0.code == "mouth_inputs_missing" })
        XCTAssertTrue(missingMouth.warnings.contains { $0.code == "lip_inputs_missing" })

        for plan in [missingEye, missingNose, missingMouth] {
            assertRedacted(plan)
        }
    }

    func testSelectedFaceRouteNilFaceSkipsFaceDependentDomainsOnly() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                faceSlim: 1,
                eyeSize: 1,
                noseSlim: 1,
                mouthSize: 1,
                lipColor: 1,
                filterId: "warm_light",
                filterIntensity: 0.5
            ),
            selectedFaceObservation: nil
        )

        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertFalse(plan.activeDomains.contains(.faceShape))
        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertFalse(plan.activeDomains.contains(.nose))
        XCTAssertFalse(plan.activeDomains.contains(.mouth))
        XCTAssertFalse(plan.activeDomains.contains(.lipColor))
        XCTAssertTrue(plan.skippedDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth, .lipColor]))
        XCTAssertTrue(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
        XCTAssertEqual(plan.effectiveStrengths.mouthSize, 0)
        XCTAssertEqual(plan.effectiveStrengths.mouthWidth, 0)
        XCTAssertEqual(plan.effectiveStrengths.smile, 0)
        XCTAssertEqual(plan.effectiveStrengths.lipColor, 0)
        assertRedacted(plan)
    }

    private var phase46DegradationRows: [Phase46DegradationFieldRow] {
        [
            Phase46DegradationFieldRow(
                name: "faceContourSmooth",
                parameter: \.faceContourSmooth,
                effective: \.faceContourSmooth,
                emission: .face(\.faceContourSmooth),
                requiredSupport: .contour
            ),
            Phase46DegradationFieldRow(
                name: "templeFullness",
                parameter: \.templeFullness,
                effective: \.templeFullness,
                emission: .face(\.templeFullness),
                requiredSupport: .contour
            ),
            Phase46DegradationFieldRow(
                name: "cheekboneSlim",
                parameter: \.cheekboneSlim,
                effective: \.cheekboneSlim,
                emission: .face(\.cheekboneSlim),
                requiredSupport: .contour
            ),
            Phase46DegradationFieldRow(
                name: "chinTaper",
                parameter: \.chinTaper,
                effective: \.chinTaper,
                emission: .chin(\.chinTaper),
                requiredSupport: .contourAndCenterline
            ),
        ]
    }

    private var phase48FaceRows: [Phase48FaceFieldRow] {
        [
            Phase48FaceFieldRow(
                name: "faceSlim",
                parameter: \.faceSlim,
                effective: \.faceSlim,
                emission: .face(\.faceSlim),
                requiredSupport: .compatibility,
                requestedValue: 0.05
            ),
            Phase48FaceFieldRow(
                name: "faceSmall",
                parameter: \.faceSmall,
                effective: \.faceSmall,
                emission: .face(\.faceSmall),
                requiredSupport: .compatibility,
                requestedValue: 0.05
            ),
            Phase48FaceFieldRow(
                name: "faceVShape",
                parameter: \.faceVShape,
                effective: \.faceVShape,
                emission: .face(\.faceVShape),
                requiredSupport: .compatibility,
                requestedValue: 0.05
            ),
            Phase48FaceFieldRow(
                name: "jawSlim",
                parameter: \.jawSlim,
                effective: \.jawSlim,
                emission: .face(\.jawSlim),
                requiredSupport: .compatibility,
                requestedValue: 0.05
            ),
            Phase48FaceFieldRow(
                name: "chinLength",
                parameter: \.chinLength,
                effective: \.chinLength,
                emission: .chin(\.chinLength),
                requiredSupport: .compatibility,
                requestedValue: -0.05
            ),
            Phase48FaceFieldRow(
                name: "faceContourSmooth",
                parameter: \.faceContourSmooth,
                effective: \.faceContourSmooth,
                emission: .face(\.faceContourSmooth),
                requiredSupport: .contour,
                requestedValue: 0.05
            ),
            Phase48FaceFieldRow(
                name: "templeFullness",
                parameter: \.templeFullness,
                effective: \.templeFullness,
                emission: .face(\.templeFullness),
                requiredSupport: .contour,
                requestedValue: 0.05
            ),
            Phase48FaceFieldRow(
                name: "cheekboneSlim",
                parameter: \.cheekboneSlim,
                effective: \.cheekboneSlim,
                emission: .face(\.cheekboneSlim),
                requiredSupport: .contour,
                requestedValue: 0.05
            ),
            Phase48FaceFieldRow(
                name: "chinTaper",
                parameter: \.chinTaper,
                effective: \.chinTaper,
                emission: .chin(\.chinTaper),
                requiredSupport: .contourAndCenterline,
                requestedValue: 0.05
            ),
        ]
    }

    private var phase48AllFaceParameters: BeautyParameters {
        var parameters = BeautyParameters()
        for row in phase48FaceRows {
            parameters[keyPath: row.parameter] = row.requestedValue
        }
        return parameters
    }

    private var phase46AllRequestedParameters: BeautyParameters {
        var parameters = BeautyParameters()
        for row in phase46DegradationRows {
            parameters[keyPath: row.parameter] = 1
        }
        return parameters
    }

    private func phase46Face(
        _ face: FaceGeometry,
        freshness: LandmarkGeometryFreshness
    ) -> FaceGeometry {
        FaceGeometry(
            bounds: face.bounds,
            faceContour: face.faceContour,
            observedFaceSupport: face.observedFaceSupport,
            leftEye: face.leftEye,
            rightEye: face.rightEye,
            nose: face.nose,
            noseRoot: face.noseRoot,
            noseTip: face.noseTip,
            outerLips: face.outerLips,
            upperLips: face.upperLips,
            lowerLips: face.lowerLips,
            innerLips: face.innerLips,
            leftEyeSupport: face.leftEyeSupport,
            rightEyeSupport: face.rightEyeSupport,
            freshness: freshness
        )
    }

    private func phase46NamedPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> [WarpControlPoint] {
        FaceShapeWarpProvider().fieldEmissions(face: face, strengths: strengths).points +
            ChinWarpProvider().fieldEmissions(face: face, strengths: strengths).points
    }

    private func assertRedacted(_ plan: BeautyEffectPlan, file: StaticString = #filePath, line: UInt = #line) {
        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")

        for forbidden in ["land" + "mark", "control point", "control" + "Point", "bounding", "VNFace" + "Observation", "/private" + "/var", "image" + " bytes", "SI" + "MD", "[0.", "coordinate", "support", "path", "detector", "Face" + "Geometry", "NoseWarp" + "Provider"] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
        }
    }

    private var allFourteenEyeParameters: BeautyParameters {
        BeautyParameters(
            eyeSize: 1,
            eyeDistance: -1,
            eyeYPosition: 1,
            eyeTailLift: 1,
            eyeHeight: 1,
            eyeLength: 1,
            upperEyelidLift: 1,
            pupilSize: 1,
            gazeCorrection: 1,
            lowerEyelidDrop: 1,
            eyeTilt: -1,
            innerCornerOpen: 1,
            outerCornerOpen: 1,
            eyeSymmetry: 1
        )
    }

    private func assertEyeStrengthsAreZero(_ plan: BeautyEffectPlan, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(plan.effectiveStrengths.eyeSize, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.eyeDistance, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.eyeYPosition, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.eyeTailLift, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.eyeHeight, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.eyeLength, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.upperEyelidLift, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.pupilSize, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.gazeCorrection, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.lowerEyelidDrop, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.eyeTilt, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.innerCornerOpen, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.outerCornerOpen, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.eyeSymmetry, 0, file: file, line: line)
    }

    private func assertNoseStrengthsAreZero(_ plan: BeautyEffectPlan, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(plan.effectiveStrengths.noseSlim, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.noseWingSlim, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.noseTipSize, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.noseBridge, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.noseRootNarrowing, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.noseTipLift, 0, file: file, line: line)
    }

    private func assertNoEyeSideOrRawGeometryDisclosure(
        _ plan: BeautyEffectPlan,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ").lowercased()
        let forbidden = [
            "left", "right", "eye side", "landmark", "coordinate", "bounding", "bounds",
            "control point", "path", "image bytes", "raw", "vnfaceobservation", "nserror", "averror",
        ]
        for term in forbidden {
            XCTAssertFalse(metadata.contains(term), "Unexpected sensitive term: \(term)", file: file, line: line)
        }
    }
}

extension BeautyFaceObservation {
    static func fixture(missing groups: Set<BeautyLandmarkGroup> = []) -> BeautyFaceObservation {
        let availableGroups = Set(BeautyLandmarkGroup.allCases).subtracting(groups)
        return BeautyFaceObservation(
            stableID: "selected",
            confidence: 0.96,
            imageBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
            landmarks: BeautyFaceLandmarks(availableGroups: availableGroups)
        )
    }

    static let fixtureWithMalformedObservedEyes: BeautyFaceObservation = {
        let bounds = CoordinateRect(x: 0.10, y: 0.10, width: 0.80, height: 0.80)
        let malformed = [CoordinatePoint(x: .infinity, y: .infinity)]
        return BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyeSupport: [
                BeautyObservedEyeSupport(side: .left, contour: malformed),
                BeautyObservedEyeSupport(side: .right, contour: malformed)
            ],
            observedEyeOrder: .canonical
        )
    }()
}
