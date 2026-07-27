import Foundation
import BeautyCore
import XCTest
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
    private static let unitBounds = FaceBounds(x: 0, y: 0, width: 1, height: 1)

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

    static func validatedTrace(
        side: BeautyObservedEyebrowSide,
        points: [SIMD2<Float>]?,
        bounds: FaceBounds = FaceGeometry.fixture.bounds
    ) -> BeautyEyebrowSemanticTrace? {
        BeautyFaceGeometryAdapter.validatedBrowTrace(
            points?.map { CoordinatePoint(x: Double($0.x), y: Double($0.y)) },
            side: side,
            bounds: bounds
        )
    }

    static func trace(
        side: BeautyObservedEyebrowSide,
        points: [SIMD2<Float>]? = nil,
        apexIndex: Int? = 2,
        bounds: FaceBounds = FaceGeometry.fixture.bounds,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> BeautyEyebrowSemanticTrace {
        let canonical = points ?? canonicalPoints(side: side, hasApex: apexIndex != nil)
        guard let validated = validatedTrace(side: side, points: canonical, bounds: bounds) else {
            XCTFail("eyebrow fixture must pass production adapter validation", file: file, line: line)
            return fallbackTrace(side: side, bounds: bounds)
        }
        let faceCenterX = bounds.x + bounds.width / 2
        XCTAssertLessThan(
            abs(validated.innerEndpoint.x - faceCenterX),
            abs(validated.outerEndpoint.x - faceCenterX),
            "eyebrow fixture must remain canonical inner-to-outer",
            file: file,
            line: line
        )
        let relativeChord = abs(validated.outerEndpoint.x - validated.innerEndpoint.x) / bounds.width
        XCTAssertTrue(
            (BeautyFaceGeometryAdapter.minimumBrowChord...BeautyFaceGeometryAdapter.maximumBrowChord)
                .contains(relativeChord),
            file: file,
            line: line
        )
        let yValues = validated.points.map(\.y)
        let relativeVerticalSpan = (yValues.max()! - yValues.min()!) / bounds.height
        XCTAssertLessThanOrEqual(
            relativeVerticalSpan,
            BeautyFaceGeometryAdapter.maximumBrowVerticalSpan,
            file: file,
            line: line
        )
        return validated
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
                left: validatedTrace(side: .left, points: points),
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
            .init(0.1815, 0.00130), .init(0.16125, 0.00116), .init(0.141, 0.00110),
            .init(0.12075, 0.00117), .init(0.1005, 0.00131),
        ]
        let rightPoints: [SIMD2<Float>] = [
            .init(0.8185, 0.00130), .init(0.83875, 0.00116), .init(0.859, 0.00110),
            .init(0.87925, 0.00117), .init(0.8995, 0.00131),
        ]
        return FaceGeometry(
            bounds: unitBounds,
            faceContour: [.init(0, 0), .init(0.5, 1), .init(1, 0)],
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(
                left: trace(side: .left, points: leftPoints, bounds: unitBounds),
                right: trace(side: .right, points: rightPoints, bounds: unitBounds)
            )
        )
    }

    static var adjacentTiltFace: FaceGeometry {
        let leftPoints: [SIMD2<Float>] = [
            .init(0.1815, 0.00030), .init(0.16125, 0.00016), .init(0.141, 0.00010),
            .init(0.12075, 0.00017), .init(0.1005, 0.00031),
        ]
        let rightPoints: [SIMD2<Float>] = [
            .init(0.8185, 0.00030), .init(0.83875, 0.00016), .init(0.859, 0.00010),
            .init(0.87925, 0.00017), .init(0.8995, 0.00031),
        ]
        return FaceGeometry(
            bounds: unitBounds,
            faceContour: [.init(0, 0), .init(0.5, 1), .init(1, 0)],
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(
                left: trace(side: .left, points: leftPoints, bounds: unitBounds),
                right: trace(side: .right, points: rightPoints, bounds: unitBounds)
            )
        )
    }

    static var adjacentThicknessFace: FaceGeometry {
        let leftPoints: [SIMD2<Float>] = [
            .init(0.1815, 0.0121), .init(0.16125, 0.0121), .init(0.141, 0.0121),
            .init(0.12075, 0.0121), .init(0.1005, 0.0121),
        ]
        let rightPoints: [SIMD2<Float>] = [
            .init(0.8185, 0.0121), .init(0.83875, 0.0121), .init(0.859, 0.0121),
            .init(0.87925, 0.0121), .init(0.8995, 0.0121),
        ]
        return FaceGeometry(
            bounds: unitBounds,
            faceContour: [.init(0, 0), .init(0.5, 1), .init(1, 0)],
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(
                left: trace(side: .left, points: leftPoints, apexIndex: nil, bounds: unitBounds),
                right: trace(side: .right, points: rightPoints, apexIndex: nil, bounds: unitBounds)
            )
        )
    }

    private static func canonicalPoints(
        side: BeautyObservedEyebrowSide,
        hasApex: Bool
    ) -> [SIMD2<Float>] {
        let yValues: [Float] = hasApex
            ? [0.41, 0.37, 0.34, 0.37, 0.41]
            : [0.39, 0.38, 0.37, 0.36, 0.35]
        let xValues: [Float] = side == .left
            ? [0.47, 0.43, 0.39, 0.35, 0.31]
            : [0.53, 0.57, 0.61, 0.65, 0.69]
        return zip(xValues, yValues).map { SIMD2<Float>($0.0, $0.1) }
    }

    private static func fallbackTrace(
        side: BeautyObservedEyebrowSide,
        bounds: FaceBounds
    ) -> BeautyEyebrowSemanticTrace {
        let fallback = canonicalPoints(side: side, hasApex: true)
        guard let validated = validatedTrace(side: side, points: fallback, bounds: bounds) else {
            preconditionFailure("canonical eyebrow fixture must pass production validation")
        }
        return validated
    }
}
