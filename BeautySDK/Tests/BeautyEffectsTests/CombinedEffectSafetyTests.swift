import CoreImage
import XCTest
import BeautyCore
import BeautyDetection
import BeautyResources
@testable import BeautyEffects

final class CombinedEffectSafetyTests: XCTestCase {
    func testEYE21AllTwentyEightProviderFieldsFailClosedWithoutReentry() {
        struct Row {
            let name: String
            let domain: BeautyEffectDomain
            let makeParameters: (Float) -> BeautyParameters
            let effective: KeyPath<BeautyEffectiveStrengths, Float>
        }
        let rows: [Row] = [
            Row(name: "eyeSize", domain: .eyes, makeParameters: { BeautyParameters(eyeSize: $0) }, effective: \.eyeSize),
            Row(name: "eyeDistance", domain: .eyes, makeParameters: { BeautyParameters(eyeDistance: $0) }, effective: \.eyeDistance),
            Row(name: "eyeYPosition", domain: .eyes, makeParameters: { BeautyParameters(eyeYPosition: $0) }, effective: \.eyeYPosition),
            Row(name: "eyeTailLift", domain: .eyes, makeParameters: { BeautyParameters(eyeTailLift: $0) }, effective: \.eyeTailLift),
            Row(name: "eyeHeight", domain: .eyes, makeParameters: { BeautyParameters(eyeHeight: $0) }, effective: \.eyeHeight),
            Row(name: "eyeLength", domain: .eyes, makeParameters: { BeautyParameters(eyeLength: $0) }, effective: \.eyeLength),
            Row(name: "upperEyelidLift", domain: .eyes, makeParameters: { BeautyParameters(upperEyelidLift: $0) }, effective: \.upperEyelidLift),
            Row(name: "pupilSize", domain: .eyes, makeParameters: { BeautyParameters(pupilSize: $0) }, effective: \.pupilSize),
            Row(name: "gazeCorrection", domain: .eyes, makeParameters: { BeautyParameters(gazeCorrection: $0) }, effective: \.gazeCorrection),
            Row(name: "lowerEyelidDrop", domain: .eyes, makeParameters: { BeautyParameters(lowerEyelidDrop: $0) }, effective: \.lowerEyelidDrop),
            Row(name: "eyeTilt", domain: .eyes, makeParameters: { BeautyParameters(eyeTilt: $0) }, effective: \.eyeTilt),
            Row(name: "innerCornerOpen", domain: .eyes, makeParameters: { BeautyParameters(innerCornerOpen: $0) }, effective: \.innerCornerOpen),
            Row(name: "outerCornerOpen", domain: .eyes, makeParameters: { BeautyParameters(outerCornerOpen: $0) }, effective: \.outerCornerOpen),
            Row(name: "eyeSymmetry", domain: .eyes, makeParameters: { BeautyParameters(eyeSymmetry: $0) }, effective: \.eyeSymmetry),
            Row(name: "noseSlim", domain: .nose, makeParameters: { BeautyParameters(noseSlim: $0) }, effective: \.noseSlim),
            Row(name: "noseWingSlim", domain: .nose, makeParameters: { BeautyParameters(noseWingSlim: $0) }, effective: \.noseWingSlim),
            Row(name: "noseTipSize", domain: .nose, makeParameters: { BeautyParameters(noseTipSize: $0) }, effective: \.noseTipSize),
            Row(name: "noseBridge", domain: .nose, makeParameters: { BeautyParameters(noseBridge: $0) }, effective: \.noseBridge),
            Row(name: "noseRootNarrowing", domain: .nose, makeParameters: { BeautyParameters(noseRootNarrowing: $0) }, effective: \.noseRootNarrowing),
            Row(name: "noseTipLift", domain: .nose, makeParameters: { BeautyParameters(noseTipLift: $0) }, effective: \.noseTipLift),
            Row(name: "mouthSize", domain: .mouth, makeParameters: { BeautyParameters(mouthSize: $0) }, effective: \.mouthSize),
            Row(name: "mouthWidth", domain: .mouth, makeParameters: { BeautyParameters(mouthWidth: $0) }, effective: \.mouthWidth),
            Row(name: "smile", domain: .mouth, makeParameters: { BeautyParameters(smile: $0) }, effective: \.smile),
            Row(name: "mouthYPosition", domain: .mouth, makeParameters: { BeautyParameters(mouthYPosition: $0) }, effective: \.mouthYPosition),
            Row(name: "mouthTilt", domain: .mouth, makeParameters: { BeautyParameters(mouthTilt: $0) }, effective: \.mouthTilt),
            Row(name: "mouthXPosition", domain: .mouth, makeParameters: { BeautyParameters(mouthXPosition: $0) }, effective: \.mouthXPosition),
            Row(name: "lipPeakDefinition", domain: .mouth, makeParameters: { BeautyParameters(lipPeakDefinition: $0) }, effective: \.lipPeakDefinition),
            Row(name: "lipPlump", domain: .mouth, makeParameters: { BeautyParameters(lipPlump: $0) }, effective: \.lipPlump),
        ]

        XCTAssertEqual(rows.count, 28)
        for row in rows {
            var parameters = row.makeParameters(row.name.contains("Tilt") || row.name.contains("Position") || row.name == "eyeDistance" || row.name == "noseTipSize" || row.name.hasPrefix("mouthS") || row.name == "mouthWidth" ? -1 : 1)
            parameters.faceSlim = 1
            parameters.faceSmall = 1
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: providerEmptyGeometry)

            XCTAssertEqual(plan.effectiveStrengths[keyPath: row.effective], 0, row.name)
            XCTAssertTrue(plan.skippedDomains.contains(row.domain), row.name)
            XCTAssertFalse(plan.activeDomains.contains(row.domain), row.name)
            XCTAssertTrue(plan.activeDomains.contains(.faceShape), row.name)
            XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 2, row.name)
            XCTAssertEqual(plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(1 / (BeautySafetyCaps.faceSlim + BeautySafetyCaps.faceSmall)), accuracy: 0.000_001, row.name)
            XCTAssertEqual(plan.warnings.filter { $0.code == "combined_geometry_weakened" }.count, 1, row.name)
            assertCombinedMetadataRedacted(plan)
        }
    }

    func testSAFE02ConvergenceLoopHasExactFortyFourRemovalCeiling() throws {
        let testURL = URL(fileURLWithPath: #filePath)
        let sourceURL = testURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/BeautyEffects/Planning/BeautyEffectResolver.swift")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)
        XCTAssertEqual(source.components(separatedBy: "for _ in 0..<44").count - 1, 1)
        XCTAssertEqual(source.components(separatedBy: "for _ in 0..<37").count - 1, 0)
        XCTAssertEqual(source.components(separatedBy: "for _ in 0..<28").count - 1, 0)
        XCTAssertTrue(source.contains("Each pass can only remove fields"))
        XCTAssertTrue(source.contains("strengths: resolution.strengths"))
        XCTAssertTrue(source.contains(".sanitizing(retainedBaseline)"))
        XCTAssertEqual(
            source.components(separatedBy: "let conflict = Self.resolveGeometryConflict(").count - 1,
            1,
            "All geometry domains must enter one shared convergence path."
        )
        XCTAssertFalse(source.contains("resolveEyebrowConflict"))
        XCTAssertFalse(source.contains("eyebrowConflictScale"))
    }

    func testSAFE02EveryEyebrowRowIsRemovedMonotonicallyWhenSharedScaleMakesProviderEmpty() {
        let provider = EyebrowWarpProvider()
        let face = EyebrowSafetyFixtures.face()

        XCTAssertEqual(EyebrowSafetyFixtures.rows.count, 7)
        for row in EyebrowSafetyFixtures.rows {
            let requested = row.isSigned ? -row.cap : row.cap
            let retainedBaseline = row.strengths(requested)
            let providerEmptyThreshold = Float.ulpOfOne / 2
            XCTAssertFalse(
                row.emission(provider.fieldEmissions(face: face, strengths: retainedBaseline)).isEmpty,
                "\(row.name) must emit before the late shared scale."
            )

            let lateResolution = GeometryConflictResolver(totalThreshold: providerEmptyThreshold)
                .resolve(strengths: retainedBaseline)
            XCTAssertEqual(lateResolution.metrics["beauty.effects.weakenedCount"], 1, row.name)
            XCTAssertEqual(lateResolution.warnings.map(\.code), ["combined_geometry_weakened"], row.name)
            XCTAssertEqual(
                abs(lateResolution.strengths[keyPath: row.effectiveValue]),
                providerEmptyThreshold,
                accuracy: Float.ulpOfOne,
                row.name
            )

            let lateEmissions = provider.fieldEmissions(
                face: face,
                strengths: lateResolution.strengths
            )
            XCTAssertTrue(row.emission(lateEmissions).isEmpty, row.name)

            let removedBaseline = lateEmissions.sanitizing(retainedBaseline)
            XCTAssertEqual(removedBaseline[keyPath: row.effectiveValue], 0, row.name)

            let repeated = GeometryConflictResolver(totalThreshold: providerEmptyThreshold)
                .resolve(strengths: removedBaseline)
            XCTAssertEqual(repeated.strengths[keyPath: row.effectiveValue], 0, row.name)
            XCTAssertTrue(
                row.emission(provider.fieldEmissions(face: face, strengths: repeated.strengths)).isEmpty,
                "\(row.name) must not re-enter after removal."
            )
        }
    }

    func testSAFE02PairPerSideApexReuseAndRequestOrderShareOneFinalMask() {
        let allEyebrows = BeautyParameters(
            eyebrowYPosition: -1,
            eyebrowThickness: 1,
            eyebrowLength: -1,
            eyebrowSpacing: 1,
            eyebrowHeadSpacing: -1,
            eyebrowTilt: 1,
            eyebrowPeakDefinition: 1
        )
        let pairedFace = EyebrowSafetyFixtures.face()
        let singleSideFace = EyebrowSafetyFixtures.face(
            support: BeautyEyebrowSemanticSupport(
                left: EyebrowSafetyFixtures.trace(side: .left),
                right: nil
            )
        )
        let missingApexFace = EyebrowSafetyFixtures.face(
            support: BeautyEyebrowSemanticSupport(
                left: EyebrowSafetyFixtures.trace(side: .left, apexIndex: nil),
                right: EyebrowSafetyFixtures.trace(side: .right, apexIndex: nil)
            )
        )
        let reusedFace = EyebrowSafetyFixtures.face(freshness: .reused)

        let paired = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: pairedFace)
        let singleSide = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: singleSideFace)
        let missingApex = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: missingApexFace)
        let reused = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: reusedFace)
        let pairedAgain = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: pairedFace)

        XCTAssertEqual(pairedAgain, paired)
        XCTAssertEqual(singleSide.effectiveStrengths.eyebrowSpacing, 0)
        XCTAssertGreaterThan(singleSide.effectiveStrengths.eyebrowPeakDefinition, 0)
        for row in EyebrowSafetyFixtures.rows where row.name != "eyebrowSpacing" {
            XCTAssertNotEqual(singleSide.effectiveStrengths[keyPath: row.effectiveValue], 0, row.name)
        }
        XCTAssertEqual(missingApex.effectiveStrengths.eyebrowPeakDefinition, 0)
        for row in EyebrowSafetyFixtures.rows where row.name != "eyebrowPeakDefinition" {
            XCTAssertNotEqual(missingApex.effectiveStrengths[keyPath: row.effectiveValue], 0, row.name)
        }

        XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5)
        XCTAssertNil(reused.metrics["beauty.effects.geometryStrengthScale"])
        XCTAssertFalse(reused.warnings.contains { $0.code == "combined_geometry_weakened" })
        for row in EyebrowSafetyFixtures.rows {
            let requestedSign: Float = allEyebrows[keyPath: row.publicValue] < 0 ? -1 : 1
            let expected = row.reusedStrength * requestedSign
            XCTAssertEqual(
                reused.effectiveStrengths[keyPath: row.effectiveValue],
                expected,
                accuracy: 0.000_001,
                row.name
            )
        }

        assertFinalMaskMatchesNamedProviders(paired, face: pairedFace)
        assertFinalMaskMatchesNamedProviders(singleSide, face: singleSideFace)
        assertFinalMaskMatchesNamedProviders(missingApex, face: missingApexFace)
        assertFinalMaskMatchesNamedProviders(reused, face: reusedFace)

        let mixedFirst = BeautyEffectResolver.resolve(
            parameters: phase48AllGeometryParameters,
            faceGeometry: phase48AllProviderGeometry
        )
        _ = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: singleSideFace)
        let mixedAfterDifferentRequest = BeautyEffectResolver.resolve(
            parameters: phase48AllGeometryParameters,
            faceGeometry: phase48AllProviderGeometry
        )
        _ = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: missingApexFace)
        let mixedAfterReverseOrder = BeautyEffectResolver.resolve(
            parameters: phase48AllGeometryParameters,
            faceGeometry: phase48AllProviderGeometry
        )

        XCTAssertEqual(mixedAfterDifferentRequest, mixedFirst)
        XCTAssertEqual(mixedAfterReverseOrder, mixedFirst)
        XCTAssertLessThan(mixedFirst.effectiveStrengths.chinLength, 0)
        XCTAssertLessThan(mixedFirst.effectiveStrengths.eyeDistance, 0)
        XCTAssertLessThan(mixedFirst.effectiveStrengths.eyebrowYPosition, 0)
        XCTAssertLessThan(mixedFirst.effectiveStrengths.noseTipSize, 0)
        XCTAssertLessThan(mixedFirst.effectiveStrengths.mouthSize, 0)
        assertFinalMaskMatchesNamedProviders(mixedFirst, face: phase48AllProviderGeometry)
    }

    func testSAFE02AllFortyFourFinalStrengthsMatchNamedProviderEmissions() {
        let face = phase48AllProviderGeometry
        XCTAssertNotNil(face.observedEyebrowSupport)
        var eyebrowProbe = BeautyEffectiveStrengths()
        eyebrowProbe.eyebrowYPosition = 0.25
        XCTAssertFalse(EyebrowWarpProvider().fieldEmissions(face: face, strengths: eyebrowProbe).eyebrowYPosition.isEmpty)
        let plan = BeautyEffectResolver.resolve(
            parameters: phase48AllGeometryParameters,
            faceGeometry: face
        )
        let expectedScale: Float = 1 / 13.45
        let faceEmissions = FaceShapeWarpProvider().fieldEmissions(
            face: face,
            strengths: plan.effectiveStrengths
        )
        let chinEmissions = ChinWarpProvider().fieldEmissions(
            face: face,
            strengths: plan.effectiveStrengths
        )
        let eyeEmissions = EyeWarpProvider().fieldEmissions(
            face: face,
            strengths: plan.effectiveStrengths
        )
        let eyebrowEmissions = EyebrowWarpProvider().fieldEmissions(
            face: face,
            strengths: plan.effectiveStrengths
        )
        let noseEmissions = NoseWarpProvider().fieldEmissions(
            face: face,
            strengths: plan.effectiveStrengths
        )
        let mouthEmissions = MouthWarpProvider().fieldEmissions(
            face: face,
            strengths: plan.effectiveStrengths
        )

        let reflectedValues = Dictionary(
            uniqueKeysWithValues: Mirror(reflecting: plan.effectiveStrengths).children.compactMap {
                child -> (String, Float)? in
                guard let name = child.label, let value = child.value as? Float else {
                    return nil
                }
                return (name, value)
            }
        )
        XCTAssertEqual(finalGeometryFieldNames.count, 44)
        XCTAssertEqual(Set(finalGeometryFieldNames).count, 44)
        for name in finalGeometryFieldNames {
            XCTAssertNotEqual(reflectedValues[name], 0, name)
        }
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 44)
        XCTAssertEqual(
            plan.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
            Double(expectedScale),
            accuracy: 0.000_000_1
        )
        XCTAssertEqual(
            plan.warnings.filter { $0.code == "combined_geometry_weakened" }.count,
            1
        )
        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .eyes, .eyebrows, .nose, .mouth]))
        XCTAssertTrue(plan.skippedDomains.intersection([.faceShape, .eyes, .eyebrows, .nose, .mouth]).isEmpty)

        var sanitized = faceEmissions.sanitizing(plan.effectiveStrengths)
        sanitized = chinEmissions.sanitizing(sanitized)
        sanitized = eyeEmissions.sanitizing(sanitized)
        sanitized = eyebrowEmissions.sanitizing(sanitized)
        sanitized = noseEmissions.sanitizing(sanitized)
        sanitized = mouthEmissions.sanitizing(sanitized)
        XCTAssertEqual(
            sanitized,
            plan.effectiveStrengths,
            "Every final nonzero field must own non-empty provider work from the same mask."
        )

        let expectedPoints =
            faceEmissions.points +
            chinEmissions.points +
            eyeEmissions.points +
            eyebrowEmissions.points +
            noseEmissions.points +
            mouthEmissions.points
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
        assertCombinedMetadataRedacted(plan)
    }

    func testGEOMProviderEmptyFieldsNeverReenterAfterCombinedWeakening() {
        let face = phase46PostScaleEmptySmoothGeometry
        let smoothOnly = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            faceGeometry: face
        )
        let preConflictSmooth = FaceShapeWarpProvider().fieldEmissions(
            face: face,
            strengths: smoothOnly.effectiveStrengths
        ).faceContourSmooth
        XCTAssertEqual(smoothOnly.effectiveStrengths.faceContourSmooth, 0.25, accuracy: 0.000_001)
        XCTAssertFalse(preConflictSmooth.isEmpty)

        let parameters = BeautyParameters(
            faceSlim: 1,
            faceSmall: 1,
            faceVShape: 1,
            jawSlim: 1,
            chinLength: -1,
            faceContourSmooth: 1,
            eyeSize: 1,
            eyeHeight: 1,
            noseSlim: 1,
            noseRootNarrowing: 1,
            mouthSize: -1,
            mouthYPosition: -1
        )
        let first = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
        let repeated = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
        let retainedTotal: Float = 4.35
        let expectedScale: Float = 1 / retainedTotal

        XCTAssertEqual(first, repeated)
        XCTAssertEqual(first.effectiveStrengths.faceContourSmooth, 0)
        XCTAssertEqual(first.metrics["beauty.effects.weakenedCount"], 11)
        XCTAssertEqual(
            first.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
            Double(expectedScale),
            accuracy: 0.000_001
        )
        XCTAssertEqual(first.warnings.filter { $0.code == "combined_geometry_weakened" }.count, 1)
        XCTAssertTrue(first.activeDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth]))

        XCTAssertEqual(first.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim * expectedScale, accuracy: 0.000_001)
        XCTAssertEqual(first.effectiveStrengths.chinLength, -BeautySafetyCaps.chinLength * expectedScale, accuracy: 0.000_001)
        XCTAssertEqual(first.effectiveStrengths.eyeHeight, BeautySafetyCaps.eyeHeight * expectedScale, accuracy: 0.000_001)
        XCTAssertEqual(first.effectiveStrengths.noseRootNarrowing, BeautySafetyCaps.noseRootNarrowing * expectedScale, accuracy: 0.000_001)
        XCTAssertEqual(first.effectiveStrengths.mouthYPosition, -BeautySafetyCaps.mouthYPosition * expectedScale, accuracy: 0.000_001)

        let faceEmissions = FaceShapeWarpProvider().fieldEmissions(
            face: face,
            strengths: first.effectiveStrengths
        )
        let chinEmissions = ChinWarpProvider().fieldEmissions(
            face: face,
            strengths: first.effectiveStrengths
        )
        let eyeEmissions = EyeWarpProvider().fieldEmissions(
            face: face,
            strengths: first.effectiveStrengths
        )
        let noseEmissions = NoseWarpProvider().fieldEmissions(
            face: face,
            strengths: first.effectiveStrengths
        )
        let mouthEmissions = MouthWarpProvider().fieldEmissions(
            face: face,
            strengths: first.effectiveStrengths
        )
        let directPoints =
            faceEmissions.points +
            chinEmissions.points +
            eyeEmissions.points +
            noseEmissions.points +
            mouthEmissions.points

        XCTAssertTrue(faceEmissions.faceContourSmooth.isEmpty)
        XCTAssertFalse(faceEmissions.faceSlim.isEmpty)
        XCTAssertFalse(chinEmissions.chinLength.isEmpty)
        XCTAssertFalse(eyeEmissions.eyeHeight.isEmpty)
        XCTAssertFalse(noseEmissions.noseRootNarrowing.isEmpty)
        XCTAssertFalse(mouthEmissions.mouthYPosition.isEmpty)
        XCTAssertEqual(
            BeautyGeometryEffectPipeline.controlPoints(
                for: first.effectiveStrengths,
                face: face
            ),
            directPoints
        )
        XCTAssertEqual(
            first.metrics["beauty.effects.geometryPointCount"],
            Double(directPoints.count)
        )
        assertCombinedMetadataRedacted(first)
    }

    func testEYE21MixedEyeMasksPreserveSafeDomainsAndSignedDirection() {
        let parameters = BeautyParameters(
            brightness: 0.2,
            faceSlim: 1,
            eyeSize: 1,
            eyeHeight: 1,
            pupilSize: 1,
            gazeCorrection: 1,
            eyeTilt: -1,
            eyeSymmetry: 1,
            noseSlim: 1,
            mouthSize: -1,
            filterId: "soft_clean",
            filterIntensity: 0.5
        )

        let fresh = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
        XCTAssertTrue(fresh.activeDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth, .color, .filter]))
        XCTAssertEqual(fresh.effectiveStrengths.pupilSize, 0)
        XCTAssertEqual(fresh.effectiveStrengths.gazeCorrection, 0)
        XCTAssertEqual(fresh.effectiveStrengths.eyeSymmetry, 0)
        XCTAssertLessThan(fresh.effectiveStrengths.eyeTilt, 0)
        XCTAssertGreaterThan(fresh.effectiveStrengths.eyeHeight, 0)
        XCTAssertGreaterThan(fresh.effectiveStrengths.noseSlim, 0)
        XCTAssertLessThan(fresh.effectiveStrengths.mouthSize, 0)
        XCTAssertEqual(fresh.warnings.filter { $0.code == "combined_geometry_weakened" }.count, 1)

        let reused = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .reused)
        XCTAssertFalse(reused.activeDomains.contains(.eyes))
        XCTAssertTrue(reused.skippedDomains.contains(.eyes))
        XCTAssertEqual(reused.effectiveStrengths.eyeTilt, 0)
        XCTAssertTrue(reused.activeDomains.isSuperset(of: [.faceShape, .nose, .mouth, .color, .filter]))

        let noFace = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: nil)
        XCTAssertFalse(noFace.activeDomains.contains(.eyes))
        XCTAssertTrue(noFace.skippedDomains.contains(.eyes))
        XCTAssertEqual(noFace.effectiveStrengths.eyeTilt, 0)
        XCTAssertTrue(noFace.activeDomains.isSuperset(of: [.color, .filter]))
        XCTAssertFalse(noFace.activeDomains.contains(.nose))
        XCTAssertFalse(noFace.activeDomains.contains(.mouth))

        for plan in [fresh, reused, noFace] {
            assertCombinedMetadataRedacted(plan)
        }
    }
    func testMOUTH05ExactCapsSignedSemanticsWarningAndCappedCount() {
        let cases: [(BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>, Float)] = [
            (BeautyParameters(mouthSize: 1), \.mouthSize, 0.35),
            (BeautyParameters(mouthSize: -1), \.mouthSize, -0.35),
            (BeautyParameters(mouthWidth: 1), \.mouthWidth, 0.35),
            (BeautyParameters(mouthWidth: -1), \.mouthWidth, -0.35),
            (BeautyParameters(smile: 1), \.smile, 0.50),
            (BeautyParameters(lipColor: 1), \.lipColor, 0.50),
        ]
        for (parameters, keyPath, expected) in cases {
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .fixture)
            XCTAssertEqual(plan.effectiveStrengths[keyPath: keyPath], expected, accuracy: 0.0001)
            XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 1)
            XCTAssertTrue(plan.warnings.contains {
                $0.code == "beauty_strength_capped" &&
                    $0.message == "Effective beauty strength was capped for natural output."
            })
            assertCombinedMetadataRedacted(plan)
        }
    }

    func testNoFaceSkipsFaceDependentDomainsButKeepsColorAndFilterActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                skinSmoothing: 0.6,
                brightness: 0.2,
                faceSlim: 1,
                faceSmall: 1,
                faceVShape: 1,
                jawSlim: 1,
                chinLength: -1,
                eyeSize: 1,
                noseSlim: 1,
                mouthSize: 1,
                lipColor: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            ),
            faceGeometry: nil
        )

        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertFalse(plan.activeDomains.contains(.skin))
        XCTAssertFalse(plan.activeDomains.contains(.faceShape))
        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertFalse(plan.activeDomains.contains(.nose))
        XCTAssertFalse(plan.activeDomains.contains(.mouth))
        XCTAssertFalse(plan.activeDomains.contains(.lipColor))

        XCTAssertTrue(plan.skippedDomains.contains(.skin))
        XCTAssertTrue(plan.skippedDomains.contains(.faceShape))
        XCTAssertTrue(plan.skippedDomains.contains(.eyes))
        XCTAssertTrue(plan.skippedDomains.contains(.nose))
        XCTAssertTrue(plan.skippedDomains.contains(.mouth))
        XCTAssertTrue(plan.skippedDomains.contains(.lipColor))
        XCTAssertGreaterThanOrEqual(plan.metrics["beauty.effects.skippedFaceDomains"] ?? 0, 6)
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
        XCTAssertTrue(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
    }

    func testCombinedHighStrengthAllDomainsCapAndWeakenGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                skinSmoothing: 1,
                skinWhitening: 1,
                skinRosy: 1,
                skinSharpen: 1,
                brightness: 0.2,
                faceSlim: 1,
                faceSmall: 1,
                faceVShape: 1,
                jawSlim: 1,
                chinLength: 1,
                eyeSize: 1,
                eyeDistance: 1,
                eyeYPosition: 1,
                eyeTailLift: 1,
                noseSlim: 1,
                noseWingSlim: 1,
                noseTipSize: 1,
                noseBridge: 1,
                mouthSize: 1,
                mouthWidth: 1,
                smile: 1,
                lipColor: 1,
                filterId: "warm_light",
                filterIntensity: 1
            ),
            faceGeometry: .fixture
        )

        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.skin, .color, .filter, .faceShape, .eyes, .nose, .mouth, .lipColor]))
        XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertTrue(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertGreaterThan(plan.metrics["beauty.effects.cappedCount"] ?? 0, 0)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.weakenedCount"] ?? 0, 0)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertLessThan(plan.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim)
        XCTAssertLessThan(plan.effectiveStrengths.faceSmall, BeautySafetyCaps.faceSmall)
        XCTAssertLessThan(plan.effectiveStrengths.faceVShape, BeautySafetyCaps.faceVShape)
        XCTAssertLessThan(plan.effectiveStrengths.jawSlim, BeautySafetyCaps.jawSlim)
        XCTAssertLessThan(abs(plan.effectiveStrengths.chinLength), BeautySafetyCaps.chinLength)
        XCTAssertLessThan(plan.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize)
        XCTAssertLessThan(plan.effectiveStrengths.noseSlim, BeautySafetyCaps.noseSlim)
        XCTAssertLessThan(plan.effectiveStrengths.mouthSize, BeautySafetyCaps.mouthSize)
    }

    func testPERF03HighCappedTimingParametersPreserveSafetyCapsAndRedactedMetrics() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                skinSmoothing: 1,
                skinWhitening: 1,
                brightness: 0.2,
                faceSlim: 1,
                faceSmall: 1,
                faceVShape: 1,
                jawSlim: 1,
                eyeSize: 1,
                noseSlim: 1,
                noseWingSlim: 1,
                noseTipSize: 1,
                noseBridge: 1,
                mouthSize: 1,
                mouthWidth: 1,
                smile: 1,
                lipColor: 1,
                filterId: "warm_light",
                filterIntensity: 1
            ),
            faceGeometry: .fixture
        )

        XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertTrue(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertGreaterThan(plan.metrics["beauty.effects.cappedCount"] ?? 0, 0)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.weakenedCount"] ?? 0, 0)
        XCTAssertLessThanOrEqual(plan.effectiveStrengths.skinSmoothing, BeautySafetyCaps.skinSmoothing)
        XCTAssertLessThanOrEqual(plan.effectiveStrengths.skinWhitening, BeautySafetyCaps.skinWhitening)
        XCTAssertLessThan(plan.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim)
        XCTAssertLessThan(plan.effectiveStrengths.faceSmall, BeautySafetyCaps.faceSmall)
        XCTAssertLessThan(plan.effectiveStrengths.faceVShape, BeautySafetyCaps.faceVShape)
        XCTAssertLessThan(plan.effectiveStrengths.jawSlim, BeautySafetyCaps.jawSlim)
        XCTAssertLessThan(plan.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize)
        XCTAssertLessThan(plan.effectiveStrengths.noseSlim, BeautySafetyCaps.noseSlim)
        XCTAssertLessThan(plan.effectiveStrengths.mouthSize, BeautySafetyCaps.mouthSize)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)

        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")
        for forbidden in ["VNFace" + "Observation", "bounding" + "Box", "/private" + "/var", "NSE" + "rror", "rawPreset" + "Json", "image" + " bytes", "SI" + "MD", "[0."] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
        }
    }

    func testBuiltInPresetsStayWithinCapsAndProduceVisibleFixtureEvidence() throws {
        let image = CIImage(color: CIColor(red: 0.25, green: 0.30, blue: 0.35, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 2, height: 1))
        let inputBytes = rgbaBytes(from: image)
        let catalog = try BeautyResourceCatalog.bundled()

        for presetID in ["natural", "clear", "refined", "male-natural", "id-photo-natural"] {
            let preset = try catalog.preset(id: presetID)
            let plan = BeautyEffectResolver.resolve(
                parameters: preset.parameters,
                faceGeometry: .fixture
            )
            let output = BeautyColorEffectPipeline.apply(to: image, plan: plan, face: .fixture)

            XCTAssertLessThanOrEqual(abs(plan.effectiveStrengths.faceSlim), BeautySafetyCaps.faceSlim, presetID)
            XCTAssertLessThanOrEqual(abs(plan.effectiveStrengths.eyeSize), BeautySafetyCaps.eyeSize, presetID)
            XCTAssertLessThanOrEqual(abs(plan.effectiveStrengths.noseSlim), BeautySafetyCaps.noseSlim, presetID)
            XCTAssertLessThanOrEqual(abs(plan.effectiveStrengths.mouthSize), BeautySafetyCaps.mouthSize, presetID)
            XCTAssertLessThanOrEqual(plan.effectiveStrengths.lipColor, BeautySafetyCaps.lipColor, presetID)
            XCTAssertNotEqual(rgbaBytes(from: output), inputBytes, presetID)
        }
    }

    func testWarningAndMetricMetadataStayRedactedForCombinedPlan() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                skinSmoothing: 1,
                faceSlim: 1,
                eyeSize: 1,
                noseSlim: 1,
                mouthSize: 1,
                lipColor: 1
            ),
            faceGeometry: .fixture
        )
        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")

        for forbidden in ["VNFace" + "Observation", "bounding" + "Box", "land" + "mark", "/private" + "/var", "NSE" + "rror", "rawPreset" + "Json", "image" + " bytes", "SI" + "MD", "[0."] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
        }
    }

    func testEYE06EachVisibleEyeBehaviorWeakensWithFaceShapeAndPreservesDirection() {
        let cases: [(name: String, parameters: BeautyParameters, keyPath: KeyPath<BeautyEffectiveStrengths, Float>, expected: Float)] = [
            ("eyeSize positive", BeautyParameters(eyeSize: 1), \.eyeSize, BeautySafetyCaps.eyeSize),
            ("eyeDistance positive", BeautyParameters(eyeDistance: 1), \.eyeDistance, BeautySafetyCaps.eyeDistance),
            ("eyeDistance negative", BeautyParameters(eyeDistance: -1), \.eyeDistance, -BeautySafetyCaps.eyeDistance),
            ("eyeYPosition positive", BeautyParameters(eyeYPosition: 1), \.eyeYPosition, BeautySafetyCaps.eyeYPosition),
            ("eyeYPosition negative", BeautyParameters(eyeYPosition: -1), \.eyeYPosition, -BeautySafetyCaps.eyeYPosition),
            ("eyeTailLift positive", BeautyParameters(eyeTailLift: 1), \.eyeTailLift, BeautySafetyCaps.eyeTailLift),
        ]

        for entry in cases {
            let normal = BeautyEffectResolver.resolve(parameters: entry.parameters, faceGeometry: .fixture)
            var combinedParameters = entry.parameters
            combinedParameters.faceSlim = 1
            combinedParameters.faceSmall = 1
            let combined = BeautyEffectResolver.resolve(parameters: combinedParameters, faceGeometry: .fixture)
            let normalValue = normal.effectiveStrengths[keyPath: entry.keyPath]
            let combinedValue = combined.effectiveStrengths[keyPath: entry.keyPath]

            XCTAssertEqual(normalValue, entry.expected, accuracy: 0.0001, entry.name)
            XCTAssertTrue(combined.activeDomains.isSuperset(of: [.eyes, .faceShape]), entry.name)
            XCTAssertGreaterThan(abs(combinedValue), 0, entry.name)
            XCTAssertLessThan(abs(combinedValue), abs(normalValue), entry.name)
            XCTAssertEqual(combinedValue.sign, normalValue.sign, entry.name)
            XCTAssertTrue(combined.warnings.contains { $0.code == "combined_geometry_weakened" }, entry.name)
            XCTAssertGreaterThan(combined.metrics["beauty.effects.weakenedCount"] ?? 0, 0, entry.name)
            XCTAssertLessThan(combined.metrics["beauty.effects.geometryStrengthScale"] ?? 1, 1, entry.name)
        }
    }

    func testEYE06AllEyeMultiDomainCaseEmitsStableWeakeningEvidence() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                faceSlim: 1,
                eyeSize: 1,
                eyeDistance: -1,
                eyeYPosition: 1,
                eyeTailLift: 1,
                noseSlim: 1
            ),
            faceGeometry: .fixture
        )

        XCTAssertTrue(plan.activeDomains.isSuperset(of: [.eyes, .faceShape, .nose]))
        XCTAssertLessThan(plan.effectiveStrengths.eyeDistance, 0)
        XCTAssertGreaterThan(plan.effectiveStrengths.eyeYPosition, 0)
        XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], 6)
        XCTAssertTrue(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
        XCTAssertLessThan(plan.metrics["beauty.effects.geometryStrengthScale"] ?? 1, 1)
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        assertCombinedMetadataRedacted(plan)
    }

    func testNOSE12EveryNoseDirectionUsesExactOnceOnlyFaceEyeMouthScaling() {
        let cases: [(name: String, parameters: BeautyParameters, keyPath: KeyPath<BeautyEffectiveStrengths, Float>, unscaled: Float)] = [
            ("noseSlim", BeautyParameters(noseSlim: 1), \.noseSlim, BeautySafetyCaps.noseSlim),
            ("noseWingSlim", BeautyParameters(noseWingSlim: 1), \.noseWingSlim, BeautySafetyCaps.noseWingSlim),
            ("noseTipSize positive", BeautyParameters(noseTipSize: 1), \.noseTipSize, BeautySafetyCaps.noseTipSize),
            ("noseTipSize negative", BeautyParameters(noseTipSize: -1), \.noseTipSize, -BeautySafetyCaps.noseTipSize),
            ("noseBridge", BeautyParameters(noseBridge: 1), \.noseBridge, BeautySafetyCaps.noseBridge),
            ("noseRootNarrowing", BeautyParameters(noseRootNarrowing: 1), \.noseRootNarrowing, BeautySafetyCaps.noseRootNarrowing),
            ("noseTipLift", BeautyParameters(noseTipLift: 1), \.noseTipLift, BeautySafetyCaps.noseTipLift),
        ]

        for entry in cases {
            let normal = BeautyEffectResolver.resolve(parameters: entry.parameters, faceGeometry: .fixture)
            var combinedParameters = entry.parameters
            combinedParameters.faceSlim = 1
            combinedParameters.eyeSize = 1
            combinedParameters.mouthSize = 1
            let combined = BeautyEffectResolver.resolve(parameters: combinedParameters, faceGeometry: .fixture)
            let retainedTotal = BeautySafetyCaps.faceSlim +
                BeautySafetyCaps.eyeSize +
                BeautySafetyCaps.mouthSize +
                abs(entry.unscaled)
            let expectedScale = 1 / retainedTotal

            XCTAssertEqual(normal.effectiveStrengths[keyPath: entry.keyPath], entry.unscaled, accuracy: 0.0000001, entry.name)
            XCTAssertEqual(combined.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim * expectedScale, accuracy: 0.0000001, entry.name)
            XCTAssertEqual(combined.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize * expectedScale, accuracy: 0.0000001, entry.name)
            XCTAssertEqual(combined.effectiveStrengths.mouthSize, BeautySafetyCaps.mouthSize * expectedScale, accuracy: 0.0000001, entry.name)
            XCTAssertEqual(combined.effectiveStrengths[keyPath: entry.keyPath], entry.unscaled * expectedScale, accuracy: 0.0000001, entry.name)
            XCTAssertEqual(combined.effectiveStrengths[keyPath: entry.keyPath].sign, entry.unscaled.sign, entry.name)
            XCTAssertEqual(combined.metrics["beauty.effects.weakenedCount"], 4, entry.name)
            XCTAssertEqual(
                combined.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
                Double(expectedScale),
                accuracy: 0.0000001,
                entry.name
            )
            XCTAssertEqual(combined.warnings.filter { $0.code == "combined_geometry_weakened" }.count, 1, entry.name)
            XCTAssertTrue(combined.activeDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth]), entry.name)
            assertCombinedMetadataRedacted(combined)
        }
    }

    func testMOUTH14EveryMouthDirectionUsesExactOnceOnlyFaceEyeSixNoseScaling() {
        let cases: [(BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>, Float)] = [
            (BeautyParameters(mouthSize: 1, lipColor: 1), \.mouthSize, 0.35),
            (BeautyParameters(mouthSize: -1, lipColor: 1), \.mouthSize, -0.35),
            (BeautyParameters(mouthWidth: 1, lipColor: 1), \.mouthWidth, 0.35),
            (BeautyParameters(mouthWidth: -1, lipColor: 1), \.mouthWidth, -0.35),
            (BeautyParameters(smile: 1, lipColor: 1), \.smile, 0.50),
            (BeautyParameters(mouthYPosition: 1, lipColor: 1), \.mouthYPosition, 0.25),
            (BeautyParameters(mouthYPosition: -1, lipColor: 1), \.mouthYPosition, -0.25),
            (BeautyParameters(mouthTilt: 1, lipColor: 1), \.mouthTilt, 0.25),
            (BeautyParameters(mouthTilt: -1, lipColor: 1), \.mouthTilt, -0.25),
            (BeautyParameters(mouthXPosition: 1, lipColor: 1), \.mouthXPosition, 0.25),
            (BeautyParameters(mouthXPosition: -1, lipColor: 1), \.mouthXPosition, -0.25),
            (BeautyParameters(lipPeakDefinition: 1, lipColor: 1), \.lipPeakDefinition, 0.25),
            (BeautyParameters(lipPlump: 1, lipColor: 1), \.lipPlump, 0.25),
        ]

        for (mouthParameters, keyPath, expected) in cases {
            let normal = BeautyEffectResolver.resolve(parameters: mouthParameters, faceGeometry: .fixture)
            var combinedParameters = mouthParameters
            combinedParameters.faceSlim = 1
            combinedParameters.eyeSize = 1
            combinedParameters.noseSlim = 1
            combinedParameters.noseWingSlim = 1
            combinedParameters.noseTipSize = -1
            combinedParameters.noseBridge = 1
            combinedParameters.noseRootNarrowing = 1
            combinedParameters.noseTipLift = 1
            let combined = BeautyEffectResolver.resolve(parameters: combinedParameters, faceGeometry: .fixture)
            let normalValue = normal.effectiveStrengths[keyPath: keyPath]
            let combinedValue = combined.effectiveStrengths[keyPath: keyPath]
            let retainedTotal = BeautySafetyCaps.faceSlim +
                BeautySafetyCaps.eyeSize +
                BeautySafetyCaps.noseSlim +
                BeautySafetyCaps.noseWingSlim +
                BeautySafetyCaps.noseTipSize +
                BeautySafetyCaps.noseBridge +
                BeautySafetyCaps.noseRootNarrowing +
                BeautySafetyCaps.noseTipLift +
                abs(expected)
            let expectedScale: Float = 1 / retainedTotal

            XCTAssertEqual(normalValue, expected, accuracy: 0.0001)
            XCTAssertEqual(combinedValue, expected * expectedScale, accuracy: 0.000001)
            XCTAssertEqual(combinedValue.sign, normalValue.sign)
            XCTAssertEqual(combined.effectiveStrengths.lipColor, 0.50, accuracy: 0.0001)
            XCTAssertEqual(combined.warnings.filter { $0.code == "combined_geometry_weakened" }.count, 1)
            XCTAssertEqual(combined.metrics["beauty.effects.geometryStrengthScale"] ?? 0, Double(expectedScale), accuracy: 0.000001)
            XCTAssertEqual(combined.metrics["beauty.effects.weakenedCount"], 9)
            XCTAssertTrue(combined.activeDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth, .lipColor]))
            assertCombinedMetadataRedacted(combined)
        }
    }

    private var phase48AllGeometryParameters: BeautyParameters {
        BeautyParameters(
            faceSlim: 1,
            faceSmall: 1,
            faceVShape: 1,
            jawSlim: 1,
            chinLength: -1,
            faceContourSmooth: 1,
            templeFullness: 1,
            cheekboneSlim: 1,
            chinTaper: 1,
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
            eyebrowYPosition: -1,
            eyebrowThickness: 1,
            eyebrowLength: -1,
            eyebrowSpacing: 1,
            eyebrowHeadSpacing: -1,
            eyebrowTilt: 1,
            eyebrowPeakDefinition: 1,
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
    }

    private var phase48AllProviderGeometry: FaceGeometry {
        let base = FaceGeometry.phase46AsymmetricComplete
        let observedContour = [
            SIMD2<Float>(0.310, 0.360),
            SIMD2<Float>(0.290, 0.440),
            SIMD2<Float>(0.344, 0.520),
            SIMD2<Float>(0.392, 0.620),
            SIMD2<Float>(0.448, 0.730),
            SIMD2<Float>(0.496, 0.800),
            SIMD2<Float>(0.552, 0.710),
            SIMD2<Float>(0.600, 0.600),
            SIMD2<Float>(0.656, 0.490),
            SIMD2<Float>(0.705, 0.410),
            SIMD2<Float>(0.680, 0.340),
        ]
        let left = phase48EyeSupport(
            side: .left,
            contour: base.leftEye,
            pupil: SIMD2<Float>(0.420, 0.380),
            tilt: 0
        )
        let rightBase = phase48EyeSupport(
            side: .right,
            contour: base.rightEye,
            pupil: SIMD2<Float>(0.580, 0.380),
            tilt: 0.08
        )
        let right = BeautyEyeSemanticSupport(
            side: rightBase.side,
            contour: rightBase.contour,
            upper: rightBase.upper,
            lower: rightBase.lower,
            inner: rightBase.inner,
            outer: rightBase.outer,
            corners: rightBase.corners,
            center: rightBase.center,
            pupil: rightBase.pupil,
            span: SIMD2<Float>(rightBase.span.x + 0.01, rightBase.span.y),
            tilt: rightBase.tilt
        )
        let leftEyebrow = phase50EyebrowTrace(side: .left)
        let rightEyebrow = phase50EyebrowTrace(side: .right)
        return FaceGeometry(
            bounds: base.bounds,
            faceContour: base.faceContour,
            observedFaceSupport: BeautyFaceSemanticSupport(
                contour: observedContour,
                medianLine: base.observedFaceSupport?.medianLine,
                apexIndex: 5
            ),
            leftEye: left.contour,
            rightEye: right.contour,
            nose: base.nose,
            noseRoot: base.noseRoot,
            noseTip: base.noseTip,
            outerLips: base.outerLips,
            upperLips: base.upperLips,
            lowerLips: base.lowerLips,
            innerLips: base.innerLips,
            leftEyeSupport: left,
            rightEyeSupport: right,
            freshness: .fresh,
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(
                left: leftEyebrow,
                right: rightEyebrow
            )
        )
    }

    private func phase50EyebrowTrace(
        side: BeautyObservedEyebrowSide
    ) -> BeautyEyebrowSemanticTrace {
        let points: [SIMD2<Float>] = side == .left
            ? [.init(0.25, 0.40), .init(0.30, 0.36), .init(0.36, 0.34), .init(0.42, 0.37), .init(0.47, 0.41)]
            : [.init(0.75, 0.40), .init(0.70, 0.36), .init(0.64, 0.34), .init(0.58, 0.37), .init(0.53, 0.41)]
        return BeautyEyebrowSemanticTrace(
            side: side,
            points: points,
            innerEndpoint: points[0],
            outerEndpoint: points[points.count - 1],
            center: points.reduce(.zero, +) / Float(points.count),
            apexIndex: 2
        )
    }

    private func phase48EyeSupport(
        side: BeautyObservedEyeSide,
        contour: [SIMD2<Float>],
        pupil: SIMD2<Float>,
        tilt: Float
    ) -> BeautyEyeSemanticSupport {
        let center = LandmarkGeometryHelper.center(of: contour)!
        let upper = contour.filter { $0.y <= center.y }
        let lower = contour.filter { $0.y >= center.y }
        let outer = side == .left
            ? contour.min { $0.x < $1.x }!
            : contour.max { $0.x < $1.x }!
        let inner = side == .left
            ? contour.max { $0.x < $1.x }!
            : contour.min { $0.x < $1.x }!
        let xs = contour.map(\.x)
        let ys = contour.map(\.y)
        return BeautyEyeSemanticSupport(
            side: side,
            contour: contour,
            upper: upper,
            lower: lower,
            inner: [inner],
            outer: [outer],
            corners: [outer, inner],
            center: center,
            pupil: pupil,
            span: SIMD2<Float>(
                xs.max()! - xs.min()!,
                ys.max()! - ys.min()!
            ),
            tilt: tilt
        )
    }

    private func assertCombinedMetadataRedacted(
        _ plan: BeautyEffectPlan,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } + Array(plan.metrics.keys)
        ).joined(separator: " ")
        for forbidden in ["VNFace" + "Observation", "bounding" + "Box", "land" + "mark", "/private" + "/var", "NSE" + "rror", "rawPreset" + "Json", "image" + " bytes", "SI" + "MD", "[0."] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
        }
    }

    private func assertFinalMaskMatchesNamedProviders(
        _ plan: BeautyEffectPlan,
        face: FaceGeometry,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let faceEmissions = FaceShapeWarpProvider().fieldEmissions(face: face, strengths: plan.effectiveStrengths)
        let chinEmissions = ChinWarpProvider().fieldEmissions(face: face, strengths: plan.effectiveStrengths)
        let eyeEmissions = EyeWarpProvider().fieldEmissions(face: face, strengths: plan.effectiveStrengths)
        let eyebrowEmissions = EyebrowWarpProvider().fieldEmissions(face: face, strengths: plan.effectiveStrengths)
        let noseEmissions = NoseWarpProvider().fieldEmissions(face: face, strengths: plan.effectiveStrengths)
        let mouthEmissions = MouthWarpProvider().fieldEmissions(face: face, strengths: plan.effectiveStrengths)

        var sanitized = faceEmissions.sanitizing(plan.effectiveStrengths)
        sanitized = chinEmissions.sanitizing(sanitized)
        sanitized = eyeEmissions.sanitizing(sanitized)
        sanitized = eyebrowEmissions.sanitizing(sanitized)
        sanitized = noseEmissions.sanitizing(sanitized)
        sanitized = mouthEmissions.sanitizing(sanitized)
        XCTAssertEqual(sanitized, plan.effectiveStrengths, file: file, line: line)

        let reflectedValues = Dictionary(
            uniqueKeysWithValues: Mirror(reflecting: plan.effectiveStrengths).children.compactMap {
                child -> (String, Float)? in
                guard let name = child.label, let value = child.value as? Float else { return nil }
                return (name, value)
            }
        )
        let finalValues = finalGeometryFieldNames.compactMap { reflectedValues[$0] }
        XCTAssertEqual(finalValues.count, 44, file: file, line: line)
        let finalCount = finalValues.filter { abs($0) > Float.ulpOfOne }.count
        let finalTotal = finalValues.reduce(Float(0)) { $0 + abs($1) }

        if let scale = plan.metrics["beauty.effects.geometryStrengthScale"] {
            XCTAssertEqual(plan.metrics["beauty.effects.weakenedCount"], Double(finalCount), file: file, line: line)
            XCTAssertEqual(plan.warnings.map(\.code).filter { $0 == "combined_geometry_weakened" }, ["combined_geometry_weakened"], file: file, line: line)
            XCTAssertLessThan(scale, 1, file: file, line: line)
            XCTAssertEqual(finalTotal, 1, accuracy: 0.000_001, file: file, line: line)
        } else {
            XCTAssertFalse(plan.warnings.contains { $0.code == "combined_geometry_weakened" }, file: file, line: line)
            XCTAssertLessThanOrEqual(finalTotal, 1, file: file, line: line)
        }

        for row in EyebrowSafetyFixtures.rows {
            XCTAssertEqual(
                plan.effectiveStrengths[keyPath: row.effectiveValue] != 0,
                !row.emission(eyebrowEmissions).isEmpty,
                row.name,
                file: file,
                line: line
            )
        }
        let expectedPoints =
            faceEmissions.points +
            chinEmissions.points +
            eyeEmissions.points +
            eyebrowEmissions.points +
            noseEmissions.points +
            mouthEmissions.points
        XCTAssertEqual(
            BeautyGeometryEffectPipeline.controlPoints(for: plan.effectiveStrengths, face: face),
            expectedPoints,
            file: file,
            line: line
        )
        XCTAssertEqual(
            plan.metrics["beauty.effects.geometryPointCount"],
            Double(expectedPoints.count),
            file: file,
            line: line
        )
        let hasEyebrowWork = EyebrowSafetyFixtures.rows.contains {
            plan.effectiveStrengths[keyPath: $0.effectiveValue] != 0
        }
        XCTAssertEqual(plan.activeDomains.contains(.eyebrows), hasEyebrowWork, file: file, line: line)
        XCTAssertEqual(plan.skippedDomains.contains(.eyebrows), !hasEyebrowWork, file: file, line: line)
        assertCombinedMetadataRedacted(plan, file: file, line: line)
    }

    private var providerEmptyGeometry: FaceGeometry {
        FaceGeometry(
            bounds: FaceGeometry.fixture.bounds,
            faceContour: FaceGeometry.fixture.faceContour,
            leftEye: [],
            rightEye: [],
            nose: [],
            noseRoot: [],
            noseTip: [],
            outerLips: [],
            upperLips: [],
            lowerLips: [],
            innerLips: []
        )
    }

    private var phase46PostScaleEmptySmoothGeometry: FaceGeometry {
        let base = FaceGeometry.phase46LocallyStraightContour
        var contour = base.observedFaceSupport!.contour
        contour[2].x += Float.ulpOfOne * 4
        return FaceGeometry(
            bounds: base.bounds,
            faceContour: base.faceContour,
            observedFaceSupport: BeautyFaceSemanticSupport(
                contour: contour,
                medianLine: nil,
                apexIndex: nil
            ),
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
            freshness: .fresh
        )
    }

    private func rgbaBytes(from image: CIImage) -> [UInt8] {
        let context = CIContext(options: [.workingColorSpace: CGColorSpaceCreateDeviceRGB()])
        var output = [UInt8](repeating: 0, count: 2 * 1 * 4)
        context.render(
            image,
            toBitmap: &output,
            rowBytes: 2 * 4,
            bounds: CGRect(x: 0, y: 0, width: 2, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        return output
    }
}
