import Foundation
import BeautyCore
@testable import BeautyEffects
@testable import BeautyDetection

enum EyebrowUnavailableFixture: String, CaseIterable {
    case nilSupport
    case singleSide
    case degenerateChord
    case missingApex
}

struct EyebrowSafetyRow: @unchecked Sendable {
    let name: String
    let makeParameters: @Sendable (Float) -> BeautyParameters
    let publicValue: KeyPath<BeautyParameters, Float>
    let effectiveValue: WritableKeyPath<BeautyEffectiveStrengths, Float>
    let emission: @Sendable (EyebrowWarpFieldEmissions) -> [WarpControlPoint]
    let isSigned: Bool
    let cap: Float
    let reusedStrength: Float
    let maximumRadiusFraction: Float
    let narrowestUnavailableFixture: EyebrowUnavailableFixture

    func strengths(_ value: Float) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths[keyPath: effectiveValue] = value
        return strengths
    }
}

enum EyebrowSafetyFixtures {
    static let rows: [EyebrowSafetyRow] = [
        EyebrowSafetyRow(
            name: "eyebrowYPosition",
            makeParameters: { BeautyParameters(eyebrowYPosition: $0) },
            publicValue: \.eyebrowYPosition,
            effectiveValue: \.eyebrowYPosition,
            emission: { $0.eyebrowYPosition },
            isSigned: true,
            cap: BeautySafetyCaps.eyebrowYPosition,
            reusedStrength: 0.125,
            maximumRadiusFraction: 0.08,
            narrowestUnavailableFixture: .nilSupport
        ),
        EyebrowSafetyRow(
            name: "eyebrowThickness",
            makeParameters: { BeautyParameters(eyebrowThickness: $0) },
            publicValue: \.eyebrowThickness,
            effectiveValue: \.eyebrowThickness,
            emission: { $0.eyebrowThickness },
            isSigned: true,
            cap: BeautySafetyCaps.eyebrowThickness,
            reusedStrength: 0.125,
            maximumRadiusFraction: 0.055,
            narrowestUnavailableFixture: .nilSupport
        ),
        EyebrowSafetyRow(
            name: "eyebrowLength",
            makeParameters: { BeautyParameters(eyebrowLength: $0) },
            publicValue: \.eyebrowLength,
            effectiveValue: \.eyebrowLength,
            emission: { $0.eyebrowLength },
            isSigned: true,
            cap: BeautySafetyCaps.eyebrowLength,
            reusedStrength: 0.125,
            maximumRadiusFraction: 0.07,
            narrowestUnavailableFixture: .degenerateChord
        ),
        EyebrowSafetyRow(
            name: "eyebrowSpacing",
            makeParameters: { BeautyParameters(eyebrowSpacing: $0) },
            publicValue: \.eyebrowSpacing,
            effectiveValue: \.eyebrowSpacing,
            emission: { $0.eyebrowSpacing },
            isSigned: true,
            cap: BeautySafetyCaps.eyebrowSpacing,
            reusedStrength: 0.125,
            maximumRadiusFraction: 0.08,
            narrowestUnavailableFixture: .singleSide
        ),
        EyebrowSafetyRow(
            name: "eyebrowHeadSpacing",
            makeParameters: { BeautyParameters(eyebrowHeadSpacing: $0) },
            publicValue: \.eyebrowHeadSpacing,
            effectiveValue: \.eyebrowHeadSpacing,
            emission: { $0.eyebrowHeadSpacing },
            isSigned: true,
            cap: BeautySafetyCaps.eyebrowHeadSpacing,
            reusedStrength: 0.125,
            maximumRadiusFraction: 0.06,
            narrowestUnavailableFixture: .degenerateChord
        ),
        EyebrowSafetyRow(
            name: "eyebrowTilt",
            makeParameters: { BeautyParameters(eyebrowTilt: $0) },
            publicValue: \.eyebrowTilt,
            effectiveValue: \.eyebrowTilt,
            emission: { $0.eyebrowTilt },
            isSigned: true,
            cap: BeautySafetyCaps.eyebrowTilt,
            reusedStrength: 0.125,
            maximumRadiusFraction: 0.075,
            narrowestUnavailableFixture: .degenerateChord
        ),
        EyebrowSafetyRow(
            name: "eyebrowPeakDefinition",
            makeParameters: { BeautyParameters(eyebrowPeakDefinition: $0) },
            publicValue: \.eyebrowPeakDefinition,
            effectiveValue: \.eyebrowPeakDefinition,
            emission: { $0.eyebrowPeakDefinition },
            isSigned: false,
            cap: BeautySafetyCaps.eyebrowPeakDefinition,
            reusedStrength: 0.125,
            maximumRadiusFraction: 0.055,
            narrowestUnavailableFixture: .missingApex
        ),
    ]

    static var pairedSupport: BeautyEyebrowSemanticSupport {
        BeautyEyebrowSemanticSupport(left: trace(side: .left), right: trace(side: .right))
    }

    static func trace(
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

    static func face(
        support: BeautyEyebrowSemanticSupport? = pairedSupport,
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

    static func unavailableFace(for fixture: EyebrowUnavailableFixture) -> FaceGeometry {
        switch fixture {
        case .nilSupport:
            return face(support: nil)
        case .singleSide:
            return face(support: BeautyEyebrowSemanticSupport(left: trace(side: .left), right: nil))
        case .degenerateChord:
            let point = SIMD2<Float>(0.30, 0.40)
            let points = [point, point, point, point]
            return face(support: BeautyEyebrowSemanticSupport(
                left: trace(side: .left, points: points, apexIndex: nil),
                right: nil
            ))
        case .missingApex:
            return face(support: BeautyEyebrowSemanticSupport(
                left: trace(side: .left, apexIndex: nil),
                right: trace(side: .right, apexIndex: nil)
            ))
        }
    }

    static var adjacentStrengthFace: FaceGeometry {
        let leftPoints: [SIMD2<Float>] = [
            .init(0.05, 0.02030), .init(0.14, 0.02016), .init(0.23, 0.02010),
            .init(0.32, 0.02017), .init(0.41, 0.02031),
        ]
        let rightPoints: [SIMD2<Float>] = [
            .init(0.95, 0.02030), .init(0.86, 0.02016), .init(0.77, 0.02010),
            .init(0.68, 0.02017), .init(0.59, 0.02031),
        ]
        return FaceGeometry(
            bounds: FaceBounds(x: 0, y: 0, width: 1, height: 1),
            faceContour: [.init(0, 0), .init(0.5, 1), .init(1, 0)],
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(
                left: trace(side: .left, points: leftPoints),
                right: trace(side: .right, points: rightPoints)
            )
        )
    }
}
