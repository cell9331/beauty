import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

final class MissingLandmarkDegradationTests: XCTestCase {
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

    func testReusedEyeGeometrySkipsEyesZerosStrengthsAndPreservesNonEyeReuseReduction() {
        let eyeOnlyPlan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(eyeSize: 1, eyeDistance: -1, eyeYPosition: 1, eyeTailLift: 1),
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
            parameters: BeautyParameters(eyeSize: 1, eyeDistance: -1, eyeYPosition: 1, eyeTailLift: 1),
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

    private func assertRedacted(_ plan: BeautyEffectPlan, file: StaticString = #filePath, line: UInt = #line) {
        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")

        for forbidden in ["land" + "mark", "control point", "control" + "Point", "bounding", "VNFace" + "Observation", "/private" + "/var", "image" + " bytes", "SI" + "MD", "[0."] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
        }
    }

    private func assertEyeStrengthsAreZero(_ plan: BeautyEffectPlan, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(plan.effectiveStrengths.eyeSize, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.eyeDistance, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.eyeYPosition, 0, file: file, line: line)
        XCTAssertEqual(plan.effectiveStrengths.eyeTailLift, 0, file: file, line: line)
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
}
