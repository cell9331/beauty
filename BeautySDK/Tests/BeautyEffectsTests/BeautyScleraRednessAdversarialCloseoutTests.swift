import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class BeautyScleraRednessAdversarialCloseoutTests: XCTestCase {
    private let width = 80
    private let height = 48

    private enum OracleEye: String, CaseIterable {
        case left
        case right

        var centerX: Double { self == .left ? 21 : 59 }
        var normalizedCenterX: Double { centerX / 80 }
        var side: BeautyObservedEyeSide { self == .left ? .left : .right }
        var horizontalDirection: Double { self == .left ? 1 : -1 }
    }

    private enum ProtectedRegion: String, CaseIterable {
        case iris
        case pupil
        case highlight
        case lashMargin
        case skin
        case apertureExterior
    }

    private enum ScenarioClass: String {
        case baseline
        case acceptedLeft = "accepted_left"
        case acceptedRight = "accepted_right"
        case rejectedLeft = "rejected_left"
        case rejectedRight = "rejected_right"
    }

    private enum AcceptedVariant: String, CaseIterable {
        case contourContract = "contour_contract"
        case contourExpand = "contour_expand"
        case contourNasal = "contour_nasal"
        case contourTemporal = "contour_temporal"
        case contourUp = "contour_up"
        case contourDown = "contour_down"
        case pupilNasal = "pupil_nasal"
        case pupilTemporal = "pupil_temporal"
        case pupilUp = "pupil_up"
        case pupilDown = "pupil_down"
        case asymmetricContourOppositePupil = "asymmetric_contour_opposite_pupil"
    }

    private struct EyeGeometry {
        var centerX: Double
        var centerY: Double = 0.50
        var radiusX: Double = 0.1625
        var radiusY: Double = 0.0833
        var pupilX: Double
        var pupilY: Double = 0.50
        var asymmetricSkew: Double = 0
    }

    private struct Scenario {
        let id: String
        let scenarioClass: ScenarioClass
        let left: EyeGeometry
        let right: EyeGeometry
        let rejectedEye: OracleEye?
    }

    private enum BoundaryDisposition: String {
        case accepted
        case localRejected = "local_rejected"
    }

    private struct BoundarySample {
        let id: String
        let centerOffset: Double
        let pupilOffset: Double
        let skew: Double
        let expected: BoundaryDisposition
    }

    private struct ProtectedTruth {
        let families: [OracleEye: [ProtectedRegion: Set<Int>]]

        var allPixels: Set<Int> {
            families.values.reduce(into: Set<Int>()) { all, eye in
                for pixels in eye.values { all.formUnion(pixels) }
            }
        }

        func familyCounts() -> [String: [String: Int]] {
            Dictionary(uniqueKeysWithValues: OracleEye.allCases.map { eye in
                let counts = Dictionary(uniqueKeysWithValues: ProtectedRegion.allCases.map { region in
                    (region.rawValue, families[eye]?[region]?.count ?? 0)
                })
                return (eye.rawValue, counts)
            })
        }
    }

    private struct Aggregate {
        let scenarioIDs: [String]
        let scenarioClasses: [String]
        let familyCounts: [String: [String: Int]]
        let acceptedScenarioCount: Int
        let rejectedScenarioCount: Int
        let leftOnlyPerturbationCount: Int
        let rightOnlyPerturbationCount: Int
        let actualProposalCount: Int
        let protectedTruthPixelCount: Int
        let protectedIntersectionCount: Int
        let recoloredProtectedPixelCount: Int
        let protectedByteMismatchCount: Int
        let outsideProposalByteMismatchCount: Int
        let actualProposalCountMismatchCount: Int
        let rejectedEyeProposalCount: Int
        let activePeerScenarioCount: Int
        let activePeerProposalCount: Int

        var jsonObject: [String: Any] {
            [
                "schema": "phase64-adversarial-aggregate-v1",
                "status": "passed",
                "scenario_ids": scenarioIDs,
                "scenario_classes": scenarioClasses,
                "scenario_count": scenarioIDs.count,
                "family_counts": familyCounts,
                "accepted_scenario_count": acceptedScenarioCount,
                "rejected_scenario_count": rejectedScenarioCount,
                "left_only_perturbation_count": leftOnlyPerturbationCount,
                "right_only_perturbation_count": rightOnlyPerturbationCount,
                "actual_proposal_count": actualProposalCount,
                "protected_truth_pixel_count": protectedTruthPixelCount,
                "protected_intersection_count": protectedIntersectionCount,
                "recolored_protected_pixel_count": recoloredProtectedPixelCount,
                "protected_byte_mismatch_count": protectedByteMismatchCount,
                "outside_proposal_byte_mismatch_count": outsideProposalByteMismatchCount,
                "actual_proposal_count_mismatch_count": actualProposalCountMismatchCount,
                "rejected_eye_proposal_count": rejectedEyeProposalCount,
                "active_peer_scenario_count": activePeerScenarioCount,
                "active_peer_proposal_count": activePeerProposalCount,
            ]
        }
    }

    func testColorIndependentProtectedTruthUsesEveryBilateralFullResolutionFamily() throws {
        let aggregate = try evaluateBilateralMatrix()

        XCTAssertEqual(aggregate.scenarioIDs, expectedScenarioIDs)
        XCTAssertEqual(Set(aggregate.scenarioIDs).count, 27)
        XCTAssertEqual(aggregate.protectedIntersectionCount, 0)
        XCTAssertEqual(aggregate.actualProposalCountMismatchCount, 0)
        XCTAssertGreaterThan(aggregate.actualProposalCount, 0)
        for eye in OracleEye.allCases {
            for region in ProtectedRegion.allCases {
                XCTAssertGreaterThan(
                    aggregate.familyCounts[eye.rawValue]?[region.rawValue] ?? 0,
                    0,
                    "empty protected truth: \(eye.rawValue)/\(region.rawValue)"
                )
            }
        }
    }

    func testEveryRecoloredProtectedAndOutsideProposalRGBAByteRemainsExact() throws {
        let aggregate = try evaluateBilateralMatrix()

        XCTAssertEqual(aggregate.recoloredProtectedPixelCount, aggregate.protectedTruthPixelCount)
        XCTAssertEqual(aggregate.protectedByteMismatchCount, 0)
        XCTAssertEqual(aggregate.outsideProposalByteMismatchCount, 0)
    }

    func testAffectedEyeFailuresRetainActivePeerWithoutStaleClaims() throws {
        let aggregate = try evaluateBilateralMatrix()

        XCTAssertEqual(aggregate.rejectedScenarioCount, 4)
        XCTAssertEqual(aggregate.rejectedEyeProposalCount, 0)
        XCTAssertEqual(aggregate.activePeerScenarioCount, 4)
        XCTAssertGreaterThan(aggregate.activePeerProposalCount, 0)
    }

    func testHistoricalRightEyeLeakAndCalibratedContainmentEnvelope() throws {
        let samples = calibratedRightEyeEnvelope
        XCTAssertEqual(samples.count, 27)
        XCTAssertEqual(Set(samples.map(\.id)).count, samples.count)
        XCTAssertEqual(samples.map(\.id), calibratedRightEyeEnvelopeIDs)

        let historical = try XCTUnwrap(samples.first { $0.id == historicalRightEyeTupleID })
        XCTAssertEqual(historical.centerOffset, 0.004)
        XCTAssertEqual(historical.pupilOffset, -0.006)
        XCTAssertEqual(historical.skew, 0.003)
        XCTAssertEqual(historical.expected, .localRejected)

        let accepted = samples.filter { $0.expected == .accepted }
        let rejected = samples.filter { $0.expected == .localRejected }
        XCTAssertEqual(accepted.count, 3)
        XCTAssertEqual(rejected.count, 24)
        for rejectedSample in rejected {
            XCTAssertFalse(accepted.contains { acceptedSample in
                acceptedSample.centerOffset >= rejectedSample.centerOffset
                    && abs(acceptedSample.pupilOffset) >= abs(rejectedSample.pupilOffset)
                    && acceptedSample.skew >= rejectedSample.skew
            }, "non-monotone calibrated envelope after \(rejectedSample.id)")
        }

        let truth = fullResolutionProtectedTruth()
        let protected = truth.allPixels
        XCTAssertFalse(protected.isEmpty)
        for eye in OracleEye.allCases {
            for region in ProtectedRegion.allCases {
                XCTAssertFalse(truth.families[eye]?[region]?.isEmpty ?? true)
            }
        }
        var recoloredSource = makeEyeBytes(truth: truth)
        for pixel in protected {
            recoloredSource = replacingRGBA(
                in: recoloredSource,
                index: pixel,
                with: (214, 151, 151, 255)
            )
        }

        let baselineLeft = baselineGeometry(for: .left)
        let baselineRight = baselineGeometry(for: .right)
        for sample in samples {
            var challengedRight = baselineRight
            challengedRight.centerX += sample.centerOffset * OracleEye.right.horizontalDirection
            challengedRight.pupilX += sample.pupilOffset * OracleEye.right.horizontalDirection
            challengedRight.asymmetricSkew = sample.skew * OracleEye.right.horizontalDirection

            let source = try canonical(recoloredSource)
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: [
                    support(side: .left, geometry: baselineLeft),
                    support(side: .right, geometry: challengedRight),
                ],
                eyeOrder: .canonical,
                strength: 1,
                owner: owner
            )
            let proposals = Set(result.proposalPixelIndices)
            let rightProposals = proposals.filter { isPixel($0, in: .right) }
            let leftProposals = proposals.filter { isPixel($0, in: .left) }
            let output = Array(try owner.compose(result.units).canonicalImage.rgba8Data)
            let overlappingFamilies = OracleEye.allCases.flatMap { eye in
                ProtectedRegion.allCases.compactMap { region -> String? in
                    let count = proposals.intersection(truth.families[eye]?[region] ?? []).count
                    return count > 0 ? "\(eye.rawValue)/\(region.rawValue)=\(count)" : nil
                }
            }

            XCTAssertEqual(result.summary.proposalPixelCount, proposals.count, sample.id)
            XCTAssertEqual(result.summary.leftOutcome, .accepted, sample.id)
            XCTAssertFalse(leftProposals.isEmpty, "left peer empty: \(sample.id)")
            XCTAssertTrue(
                proposals.intersection(protected).isEmpty,
                "protected overlap: \(sample.id) [\(overlappingFamilies.joined(separator: ","))]"
            )
            XCTAssertEqual(
                protected.filter { rgba(output, at: $0) != rgba(recoloredSource, at: $0) }.count,
                0,
                "protected byte mismatch: \(sample.id)"
            )
            XCTAssertEqual(
                Set(0..<(width * height))
                    .subtracting(proposals)
                    .filter { rgba(output, at: $0) != rgba(recoloredSource, at: $0) }
                    .count,
                0,
                "outside-proposal byte mismatch: \(sample.id)"
            )

            switch sample.expected {
            case .accepted:
                XCTAssertEqual(result.summary.rightOutcome, .accepted, sample.id)
                XCTAssertEqual(result.units.count, 2, sample.id)
                XCTAssertFalse(rightProposals.isEmpty, "accepted right proposal empty: \(sample.id)")
            case .localRejected:
                XCTAssertNotEqual(result.summary.rightOutcome, .accepted, sample.id)
                XCTAssertEqual(result.units.count, 1, sample.id)
                XCTAssertTrue(rightProposals.isEmpty, "rejected right proposal nonempty: \(sample.id)")
            }
        }
    }

    func testBilateralAdversarialAggregateContract() throws {
        let aggregate = try evaluateBilateralMatrix()
        let data = try JSONSerialization.data(withJSONObject: aggregate.jsonObject, options: [.sortedKeys])
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        print("PHASE64_ADVERSARIAL_AGGREGATE:\(json)")
    }

    func testProposalIndicesHaveNoProductionOrDurableExposure() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let repositoryRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let beautySDK = repositoryRoot.appendingPathComponent("BeautySDK")
        let allowed = Set([
            "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift",
            "BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift",
            "BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift",
            "BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift",
        ])
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: beautySDK,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
        )
        var containingFiles = Set<String>()
        for case let url as URL in enumerator {
            guard try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true,
                  let source = try? String(contentsOf: url, encoding: .utf8),
                  source.contains("proposalPixelIndices")
            else { continue }
            containingFiles.insert(url.path.replacingOccurrences(of: repositoryRoot.path + "/", with: ""))
        }

        XCTAssertEqual(containingFiles, allowed)
        let providerPath = repositoryRoot.appendingPathComponent(
            "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift"
        )
        let provider = try String(contentsOf: providerPath, encoding: .utf8)
        XCTAssertTrue(provider.contains("internal let proposalPixelIndices"))
        XCTAssertNil(provider.range(
            of: #"(public|open|package|@_spi)[^\n]*proposalPixelIndices|proposalPixelIndices[^\n]*(Codable|Encodable|Decodable|log|persist|diagnostic|Testing)"#,
            options: .regularExpression
        ))
    }

    private var expectedScenarioIDs: [String] {
        ["baseline"]
            + AcceptedVariant.allCases.map { "left_\($0.rawValue)" }
            + AcceptedVariant.allCases.map { "right_\($0.rawValue)" }
            + [
                "left_pupil_boundary_rejected",
                "left_collapsed_contour_rejected",
                "right_pupil_boundary_rejected",
                "right_collapsed_contour_rejected",
            ]
    }

    private var historicalRightEyeTupleID: String {
        "historical_right_center_p004_pupil_n006_skew_p003"
    }

    private var calibratedRightEyeEnvelopeIDs: [String] {
        [
            "right_c003_p005_s002",
            "right_c003_p005_s003",
            "right_c003_p005_s004",
            "right_c003_p006_s002",
            "right_c003_p006_s003",
            "right_c003_p006_s004",
            "right_c003_p007_s002",
            "right_c003_p007_s003",
            "right_c003_p007_s004",
            "right_c004_p005_s002",
            "right_c004_p005_s003",
            "right_c004_p005_s004",
            "right_c004_p006_s002",
            "historical_right_center_p004_pupil_n006_skew_p003",
            "right_c004_p006_s004",
            "right_c004_p007_s002",
            "right_c004_p007_s003",
            "right_c004_p007_s004",
            "right_c005_p005_s002",
            "right_c005_p005_s003",
            "right_c005_p005_s004",
            "right_c005_p006_s002",
            "right_c005_p006_s003",
            "right_c005_p006_s004",
            "right_c005_p007_s002",
            "right_c005_p007_s003",
            "right_c005_p007_s004",
        ]
    }

    private var calibratedRightEyeEnvelope: [BoundarySample] {
        [
            BoundarySample(id: "right_c003_p005_s002", centerOffset: 0.003, pupilOffset: -0.005, skew: 0.002, expected: .accepted),
            BoundarySample(id: "right_c003_p005_s003", centerOffset: 0.003, pupilOffset: -0.005, skew: 0.003, expected: .accepted),
            BoundarySample(id: "right_c003_p005_s004", centerOffset: 0.003, pupilOffset: -0.005, skew: 0.004, expected: .accepted),
            BoundarySample(id: "right_c003_p006_s002", centerOffset: 0.003, pupilOffset: -0.006, skew: 0.002, expected: .localRejected),
            BoundarySample(id: "right_c003_p006_s003", centerOffset: 0.003, pupilOffset: -0.006, skew: 0.003, expected: .localRejected),
            BoundarySample(id: "right_c003_p006_s004", centerOffset: 0.003, pupilOffset: -0.006, skew: 0.004, expected: .localRejected),
            BoundarySample(id: "right_c003_p007_s002", centerOffset: 0.003, pupilOffset: -0.007, skew: 0.002, expected: .localRejected),
            BoundarySample(id: "right_c003_p007_s003", centerOffset: 0.003, pupilOffset: -0.007, skew: 0.003, expected: .localRejected),
            BoundarySample(id: "right_c003_p007_s004", centerOffset: 0.003, pupilOffset: -0.007, skew: 0.004, expected: .localRejected),
            BoundarySample(id: "right_c004_p005_s002", centerOffset: 0.004, pupilOffset: -0.005, skew: 0.002, expected: .localRejected),
            BoundarySample(id: "right_c004_p005_s003", centerOffset: 0.004, pupilOffset: -0.005, skew: 0.003, expected: .localRejected),
            BoundarySample(id: "right_c004_p005_s004", centerOffset: 0.004, pupilOffset: -0.005, skew: 0.004, expected: .localRejected),
            BoundarySample(id: "right_c004_p006_s002", centerOffset: 0.004, pupilOffset: -0.006, skew: 0.002, expected: .localRejected),
            BoundarySample(id: "historical_right_center_p004_pupil_n006_skew_p003", centerOffset: 0.004, pupilOffset: -0.006, skew: 0.003, expected: .localRejected),
            BoundarySample(id: "right_c004_p006_s004", centerOffset: 0.004, pupilOffset: -0.006, skew: 0.004, expected: .localRejected),
            BoundarySample(id: "right_c004_p007_s002", centerOffset: 0.004, pupilOffset: -0.007, skew: 0.002, expected: .localRejected),
            BoundarySample(id: "right_c004_p007_s003", centerOffset: 0.004, pupilOffset: -0.007, skew: 0.003, expected: .localRejected),
            BoundarySample(id: "right_c004_p007_s004", centerOffset: 0.004, pupilOffset: -0.007, skew: 0.004, expected: .localRejected),
            BoundarySample(id: "right_c005_p005_s002", centerOffset: 0.005, pupilOffset: -0.005, skew: 0.002, expected: .localRejected),
            BoundarySample(id: "right_c005_p005_s003", centerOffset: 0.005, pupilOffset: -0.005, skew: 0.003, expected: .localRejected),
            BoundarySample(id: "right_c005_p005_s004", centerOffset: 0.005, pupilOffset: -0.005, skew: 0.004, expected: .localRejected),
            BoundarySample(id: "right_c005_p006_s002", centerOffset: 0.005, pupilOffset: -0.006, skew: 0.002, expected: .localRejected),
            BoundarySample(id: "right_c005_p006_s003", centerOffset: 0.005, pupilOffset: -0.006, skew: 0.003, expected: .localRejected),
            BoundarySample(id: "right_c005_p006_s004", centerOffset: 0.005, pupilOffset: -0.006, skew: 0.004, expected: .localRejected),
            BoundarySample(id: "right_c005_p007_s002", centerOffset: 0.005, pupilOffset: -0.007, skew: 0.002, expected: .localRejected),
            BoundarySample(id: "right_c005_p007_s003", centerOffset: 0.005, pupilOffset: -0.007, skew: 0.003, expected: .localRejected),
            BoundarySample(id: "right_c005_p007_s004", centerOffset: 0.005, pupilOffset: -0.007, skew: 0.004, expected: .localRejected),
        ]
    }

    private func scenarios() -> [Scenario] {
        let baselineLeft = baselineGeometry(for: .left)
        let baselineRight = baselineGeometry(for: .right)
        var result = [Scenario(
            id: "baseline",
            scenarioClass: .baseline,
            left: baselineLeft,
            right: baselineRight,
            rejectedEye: nil
        )]
        for eye in OracleEye.allCases {
            for variant in AcceptedVariant.allCases {
                result.append(Scenario(
                    id: "\(eye.rawValue)_\(variant.rawValue)",
                    scenarioClass: eye == .left ? .acceptedLeft : .acceptedRight,
                    left: eye == .left ? acceptedGeometry(for: eye, variant: variant) : baselineLeft,
                    right: eye == .right ? acceptedGeometry(for: eye, variant: variant) : baselineRight,
                    rejectedEye: nil
                ))
            }
        }
        for eye in OracleEye.allCases {
            var pupilBoundary = baselineGeometry(for: eye)
            pupilBoundary.pupilX += 0.145 * eye.horizontalDirection
            result.append(Scenario(
                id: "\(eye.rawValue)_pupil_boundary_rejected",
                scenarioClass: eye == .left ? .rejectedLeft : .rejectedRight,
                left: eye == .left ? pupilBoundary : baselineLeft,
                right: eye == .right ? pupilBoundary : baselineRight,
                rejectedEye: eye
            ))
            var collapsed = baselineGeometry(for: eye)
            collapsed.radiusY = 0.015
            result.append(Scenario(
                id: "\(eye.rawValue)_collapsed_contour_rejected",
                scenarioClass: eye == .left ? .rejectedLeft : .rejectedRight,
                left: eye == .left ? collapsed : baselineLeft,
                right: eye == .right ? collapsed : baselineRight,
                rejectedEye: eye
            ))
        }
        return result
    }

    private func baselineGeometry(for eye: OracleEye) -> EyeGeometry {
        EyeGeometry(centerX: eye.normalizedCenterX, pupilX: eye.normalizedCenterX)
    }

    private func acceptedGeometry(for eye: OracleEye, variant: AcceptedVariant) -> EyeGeometry {
        var geometry = baselineGeometry(for: eye)
        switch variant {
        case .contourContract:
            geometry.radiusX = 0.1575
            geometry.radiusY = 0.0800
        case .contourExpand:
            geometry.radiusX = 0.1675
            geometry.radiusY = 0.0860
        case .contourNasal:
            geometry.centerX += 0.004 * eye.horizontalDirection
            geometry.pupilX += 0.004 * eye.horizontalDirection
        case .contourTemporal:
            geometry.centerX -= 0.004 * eye.horizontalDirection
            geometry.pupilX -= 0.004 * eye.horizontalDirection
        case .contourUp:
            geometry.centerY -= 0.004
            geometry.pupilY -= 0.004
        case .contourDown:
            geometry.centerY += 0.004
            geometry.pupilY += 0.004
        case .pupilNasal:
            geometry.pupilX += 0.006 * eye.horizontalDirection
        case .pupilTemporal:
            geometry.pupilX -= 0.006 * eye.horizontalDirection
        case .pupilUp:
            geometry.pupilY -= 0.006
        case .pupilDown:
            geometry.pupilY += 0.006
        case .asymmetricContourOppositePupil:
            geometry.centerX += 0.003 * eye.horizontalDirection
            geometry.pupilX -= 0.005 * eye.horizontalDirection
            geometry.asymmetricSkew = 0.002 * eye.horizontalDirection
        }
        return geometry
    }

    private func evaluateBilateralMatrix() throws -> Aggregate {
        let scenarios = scenarios()
        XCTAssertEqual(scenarios.map(\.id), expectedScenarioIDs)
        XCTAssertEqual(Set(scenarios.map(\.id)).count, scenarios.count)
        XCTAssertEqual(scenarios.count, 27)
        XCTAssertEqual(scenarios.filter { $0.scenarioClass == .acceptedLeft }.count, 11)
        XCTAssertEqual(scenarios.filter { $0.scenarioClass == .acceptedRight }.count, 11)

        let truth = fullResolutionProtectedTruth()
        let protected = truth.allPixels
        XCTAssertFalse(protected.isEmpty)
        for eye in OracleEye.allCases {
            for region in ProtectedRegion.allCases {
                XCTAssertFalse(truth.families[eye]?[region]?.isEmpty ?? true)
            }
        }

        var recoloredSource = makeEyeBytes(truth: truth)
        for pixel in protected {
            recoloredSource = replacingRGBA(
                in: recoloredSource,
                index: pixel,
                with: (214, 151, 151, 255)
            )
        }

        var actualProposalCount = 0
        var protectedIntersectionCount = 0
        var protectedByteMismatchCount = 0
        var outsideProposalByteMismatchCount = 0
        var actualProposalCountMismatchCount = 0
        var rejectedEyeProposalCount = 0
        var activePeerScenarioCount = 0
        var activePeerProposalCount = 0

        for scenario in scenarios {
            let source = try canonical(recoloredSource)
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let result = BeautyScleraRednessProvider.makeResult(
                source: source,
                eyeSupport: [support(side: .left, geometry: scenario.left), support(side: .right, geometry: scenario.right)],
                eyeOrder: .canonical,
                strength: 1,
                owner: owner
            )
            let actualProposalPixelIndices = Set(result.proposalPixelIndices)
            let output = Array(try owner.compose(result.units).canonicalImage.rgba8Data)
            let protectedIntersection = actualProposalPixelIndices.intersection(protected)
            let protectedMismatchCount = protected.filter {
                rgba(output, at: $0) != rgba(recoloredSource, at: $0)
            }.count

            XCTAssertTrue(protectedIntersection.isEmpty, "protected overlap: \(scenario.id)")
            XCTAssertEqual(protectedMismatchCount, 0, "protected byte change: \(scenario.id)")

            actualProposalCount += actualProposalPixelIndices.count
            protectedIntersectionCount += protectedIntersection.count
            actualProposalCountMismatchCount += result.summary.proposalPixelCount == actualProposalPixelIndices.count ? 0 : 1
            protectedByteMismatchCount += protectedMismatchCount
            outsideProposalByteMismatchCount += Set(0..<(width * height))
                .subtracting(actualProposalPixelIndices)
                .filter { rgba(output, at: $0) != rgba(recoloredSource, at: $0) }
                .count

            if let rejectedEye = scenario.rejectedEye {
                let affected = actualProposalPixelIndices.filter { isPixel($0, in: rejectedEye) }
                let peer = actualProposalPixelIndices.filter { !isPixel($0, in: rejectedEye) }
                rejectedEyeProposalCount += affected.count
                if !peer.isEmpty { activePeerScenarioCount += 1 }
                activePeerProposalCount += peer.count
                XCTAssertNotEqual(outcome(for: rejectedEye, result: result), .accepted)
                XCTAssertEqual(outcome(for: rejectedEye == .left ? .right : .left, result: result), .accepted)
                XCTAssertEqual(result.units.count, 1)
            } else {
                XCTAssertEqual(result.summary.leftOutcome, .accepted, scenario.id)
                XCTAssertEqual(result.summary.rightOutcome, .accepted, scenario.id)
                XCTAssertEqual(result.units.count, 2, scenario.id)
                XCTAssertFalse(actualProposalPixelIndices.isEmpty, scenario.id)
            }
        }

        return Aggregate(
            scenarioIDs: scenarios.map(\.id),
            scenarioClasses: scenarios.map { $0.scenarioClass.rawValue },
            familyCounts: truth.familyCounts(),
            acceptedScenarioCount: scenarios.filter { $0.rejectedEye == nil }.count,
            rejectedScenarioCount: scenarios.filter { $0.rejectedEye != nil }.count,
            leftOnlyPerturbationCount: scenarios.filter { $0.scenarioClass == .acceptedLeft }.count,
            rightOnlyPerturbationCount: scenarios.filter { $0.scenarioClass == .acceptedRight }.count,
            actualProposalCount: actualProposalCount,
            protectedTruthPixelCount: protected.count,
            protectedIntersectionCount: protectedIntersectionCount,
            recoloredProtectedPixelCount: protected.count,
            protectedByteMismatchCount: protectedByteMismatchCount,
            outsideProposalByteMismatchCount: outsideProposalByteMismatchCount,
            actualProposalCountMismatchCount: actualProposalCountMismatchCount,
            rejectedEyeProposalCount: rejectedEyeProposalCount,
            activePeerScenarioCount: activePeerScenarioCount,
            activePeerProposalCount: activePeerProposalCount
        )
    }

    private func fullResolutionProtectedTruth() -> ProtectedTruth {
        var families: [OracleEye: [ProtectedRegion: Set<Int>]] = [:]
        for eye in OracleEye.allCases {
            var eyeFamilies = Dictionary(
                uniqueKeysWithValues: ProtectedRegion.allCases.map { ($0, Set<Int>()) }
            )
            let centerX = Int(eye.centerX)
            for y in 0..<height {
                for x in 0..<width {
                    let dx = Double(x - centerX)
                    let dy = Double(y - 24)
                    let ellipse = dx * dx / (13 * 13) + dy * dy / (7 * 7)
                    let distance = hypot(dx, dy)
                    let index = pixelIndex(x: x, y: y)
                    let isAperture = ellipse <= 1
                    let isBoundary = isAperture && (-1...1).contains { offsetY in
                        (-1...1).contains { offsetX in
                            let nextDX = Double(x + offsetX - centerX)
                            let nextDY = Double(y + offsetY - 24)
                            return nextDX * nextDX / (13 * 13) + nextDY * nextDY / (7 * 7) > 1
                        }
                    }
                    if distance <= 3.2 { eyeFamilies[.pupil]?.insert(index) }
                    if distance > 3.2, distance <= 7.0 { eyeFamilies[.iris]?.insert(index) }
                    if (x == centerX - 2 || x == centerX - 1), (y == 21 || y == 22) {
                        eyeFamilies[.highlight]?.insert(index)
                    }
                    if isBoundary { eyeFamilies[.lashMargin]?.insert(index) }
                    if !isAperture, ellipse > 1, ellipse <= 1.65 {
                        eyeFamilies[.skin]?.insert(index)
                    }
                    if !isAperture,
                       x >= centerX - 18, x <= centerX + 18,
                       y >= 12, y <= 35,
                       ellipse > 1.65
                    {
                        eyeFamilies[.apertureExterior]?.insert(index)
                    }
                }
            }
            families[eye] = eyeFamilies
        }
        return ProtectedTruth(families: families)
    }

    private func support(
        side: BeautyObservedEyeSide,
        geometry: EyeGeometry
    ) -> BeautyObservedEyeSupport {
        BeautyObservedEyeSupport(
            side: side,
            contour: (0..<16).map { index in
                let angle = Double(index) * 2 * .pi / 16
                return CoordinatePoint(
                    x: geometry.centerX + geometry.radiusX * cos(angle) + geometry.asymmetricSkew * sin(2 * angle),
                    y: geometry.centerY + geometry.radiusY * sin(angle)
                )
            },
            pupil: [CoordinatePoint(x: geometry.pupilX, y: geometry.pupilY)]
        )
    }

    private func makeEyeBytes(truth: ProtectedTruth) -> [UInt8] {
        var bytes = uniform(red: 164, green: 118, blue: 105)
        for eye in OracleEye.allCases {
            let centerX = Int(eye.centerX)
            for y in 17...30 {
                for x in (centerX - 13)...(centerX + 13) {
                    let dx = Double(x - centerX) / 13
                    let dy = Double(y - 24) / 7
                    guard dx * dx + dy * dy <= 1 else { continue }
                    bytes = replacingRGBA(
                        in: bytes,
                        index: pixelIndex(x: x, y: y),
                        with: (210, 150, 150, 255)
                    )
                }
            }
        }
        for eye in OracleEye.allCases {
            let eyeTruth = truth.families[eye] ?? [:]
            for index in eyeTruth[.iris] ?? [] {
                bytes = replacingRGBA(in: bytes, index: index, with: (70, 75, 82, 255))
            }
            for index in eyeTruth[.pupil] ?? [] {
                bytes = replacingRGBA(in: bytes, index: index, with: (32, 38, 45, 255))
            }
            for index in eyeTruth[.highlight] ?? [] {
                bytes = replacingRGBA(in: bytes, index: index, with: (248, 248, 248, 255))
            }
            for index in eyeTruth[.lashMargin] ?? [] {
                bytes = replacingRGBA(in: bytes, index: index, with: (38, 28, 30, 255))
            }
        }
        return bytes
    }

    private func outcome(
        for eye: OracleEye,
        result: BeautyScleraRednessProviderResult
    ) -> BeautyScleraEyeOutcome {
        eye == .left ? result.summary.leftOutcome : result.summary.rightOutcome
    }

    private func isPixel(_ index: Int, in eye: OracleEye) -> Bool {
        eye == .left ? index % width < width / 2 : index % width >= width / 2
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

    private func uniform(red: UInt8, green: UInt8, blue: UInt8) -> [UInt8] {
        Array(repeating: [red, green, blue, UInt8.max], count: width * height).flatMap { $0 }
    }
}
