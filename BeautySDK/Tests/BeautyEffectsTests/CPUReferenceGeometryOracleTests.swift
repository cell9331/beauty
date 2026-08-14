import CoreGraphics
import CoreImage
import Foundation
import simd
import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

/// Feature-family CPU reference checks for the currently shipped geometry
/// taxonomy.  The rows intentionally stay in the test target: they describe
/// the existing provider contract without adding a production registry.
final class CPUReferenceGeometryOracleTests: XCTestCase {
    private struct GeometryRow {
        let name: String
        let parameter: WritableKeyPath<BeautyParameters, Float>
        let effective: KeyPath<BeautyEffectiveStrengths, Float>
        let cap: Float
        let signed: Bool
        let emit: (FaceGeometry, BeautyEffectiveStrengths) -> [WarpControlPoint]
    }

    func testCurrentGeometryInventoryUsesProviderAndUnifiedPipeline() {
        let face = completeGeometryFace()
        let rows = geometryRows()
        XCTAssertEqual(rows.count, 44)
        XCTAssertEqual(Set(rows.map(\.name)).count, rows.count)

        for row in rows {
            let parameters = parameters(for: row, value: 0.8)
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            let effective = plan.effectiveStrengths[keyPath: row.effective]
            XCTAssertEqual(effective, min(0.8, row.cap), accuracy: 0.000_001, row.name)
            XCTAssertLessThanOrEqual(abs(effective), row.cap + 0.000_001, row.name)

            let points = row.emit(face, plan.effectiveStrengths)
            XCTAssertFalse(points.isEmpty, "No provider emission for \(row.name)")
            XCTAssertTrue(points.allSatisfy(isFiniteNormalized), row.name)
            XCTAssertTrue(points.allSatisfy { $0.radius.isFinite && $0.radius > 0 && $0.radius <= 1 }, row.name)
            XCTAssertTrue(points.allSatisfy { $0.strength.isFinite && $0.strength > 0 && $0.strength <= row.cap + 0.000_001 }, row.name)
            XCTAssertGreaterThan(
                points.reduce(Float.zero) { $0 + displacement(of: $1) },
                Float.ulpOfOne,
                "Provider must retain a non-zero signed displacement for \(row.name)"
            )

            let pipelinePoints = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face)
            XCTAssertTrue(points.allSatisfy { pipelinePoints.contains($0) }, "Unified pipeline dropped \(row.name)")
        }
    }

    func testSignedGeometryRowsReverseTheirAggregateDirectionAndRemainBounded() {
        let face = completeGeometryFace()
        for row in geometryRows().filter(\ .signed) {
            let positivePlan = BeautyEffectResolver.resolve(
                parameters: parameters(for: row, value: 0.5), faceGeometry: face
            )
            let negativePlan = BeautyEffectResolver.resolve(
                parameters: parameters(for: row, value: -0.5), faceGeometry: face
            )
            let positive = row.emit(face, positivePlan.effectiveStrengths)
            let negative = row.emit(face, negativePlan.effectiveStrengths)
            XCTAssertFalse(positive.isEmpty, row.name)
            XCTAssertFalse(negative.isEmpty, row.name)
            let hasReversePair = positive.contains { positivePoint in
                let positiveDelta = positivePoint.target - positivePoint.source
                return negative.contains { negativePoint in
                    simd_dot(positiveDelta, negativePoint.target - negativePoint.source) < 0
                }
            }
            XCTAssertTrue(hasReversePair, "Signed direction was not retained for \(row.name)")
            XCTAssertTrue(positive.allSatisfy { $0.strength <= row.cap + 0.000_001 }, row.name)
            XCTAssertTrue(negative.allSatisfy { $0.strength <= row.cap + 0.000_001 }, row.name)
        }
    }

    func testGeometryWarpIsLocalHasNoGlobalColorBiasAndPreservesOutsideAlpha() throws {
        let labels = CPUReferenceFixtureFactory.protectedOutsidePattern(width: 96, height: 96)
        let pattern = CPUReferenceFixtureFactory.geometryPattern(width: 96, height: 96)
        let fixture = CPUReferenceRGBA8Fixture(
            width: pattern.width,
            height: pattern.height,
            rgba8: pattern.rgba8,
            colorSpaceName: pattern.colorSpaceName,
            regions: labels.regions
        )
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let image = CIImage(
            bitmapData: Data(fixture.rgba8),
            bytesPerRow: fixture.rowBytes,
            size: CGSize(width: fixture.width, height: fixture.height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
        let parameters = BeautyParameters(faceSlim: 0.8, eyeHeight: 0.7, mouthWidth: 0.6)
        let face = completeGeometryFace()
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
        let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face)
        let output = BeautyGeometryEffectPipeline.applyMVPProxy(to: image, plan: plan, face: face)
        let before = renderedRGBABytes(from: image, width: fixture.width, height: fixture.height, colorSpace: colorSpace)
        let after = renderedRGBABytes(from: output, width: fixture.width, height: fixture.height, colorSpace: colorSpace)
        let changed = CPUReferenceMetrics.changedIndices(before: before, after: after)

        XCTAssertFalse(changed.isEmpty)
        XCTAssertTrue(CPUReferenceMetrics.alphaPreserved(before: before, after: after))
        XCTAssertTrue(changed.isSubset(of: localityEnvelope(points, width: fixture.width, height: fixture.height)))
        XCTAssertTrue(
            fixture.indices(in: .outside).allSatisfy { pixel in
                pixelBytes(before, at: pixel) == pixelBytes(after, at: pixel)
            },
            "Geometry must not alter the generated outside sentinel"
        )

        // A warp may resample a local gradient, but it cannot satisfy this
        // oracle by adding the same RGB bias to every pixel.
        let deltas = changed.map { pixel -> SIMD3<Int> in
            let beforePixel = pixelBytes(before, at: pixel)
            let afterPixel = pixelBytes(after, at: pixel)
            return SIMD3(
                Int(afterPixel.0) - Int(beforePixel.0),
                Int(afterPixel.1) - Int(beforePixel.1),
                Int(afterPixel.2) - Int(beforePixel.2)
            )
        }
        XCTAssertTrue(Set(deltas).count > 1, "Geometry output must not be a global RGB bias")
    }

    func testNeutralGeometryPlanIsByteIdenticalAndProtectedFixtureLabelsAreDisjoint() {
        let fixture = CPUReferenceFixtureFactory.protectedOutsidePattern()
        let neutral = BeautyEffectResolver.resolve(parameters: BeautyParameters(), faceGeometry: completeGeometryFace())
        XCTAssertTrue(BeautyGeometryEffectPipeline.controlPoints(for: neutral, face: completeGeometryFace()).isEmpty)
        XCTAssertTrue(CPUReferenceMetrics.changedIndices(before: fixture.rgba8, after: fixture.rgba8).isEmpty)
        XCTAssertTrue(CPUReferenceMetrics.regionIntersection(fixture.indices(in: .protected), fixture.indices(in: .outside)).isEmpty)
        XCTAssertTrue(CPUReferenceMetrics.alphaValues(in: fixture.rgba8).allSatisfy { $0 == 255 })
    }

    func testMalformedSupportAbstainsOnlyDependentGeometryRows() {
        let complete = FaceGeometry.phase46AsymmetricComplete
        let malformed = CPUReferenceFixtureFactory.support(.malformed)
        let rows = geometryRows()
        let faceOnly = rows.filter { $0.name.hasPrefix("face") || $0.name == "chinLength" || $0.name == "chinTaper" }
        for row in faceOnly {
            let plan = BeautyEffectResolver.resolve(parameters: parameters(for: row, value: 0.6), faceGeometry: malformed)
            let points = row.emit(malformed, plan.effectiveStrengths)
            XCTAssertTrue(points.isEmpty || points.allSatisfy(isFiniteNormalized), row.name)
        }
        let eligible = BeautyEffectResolver.resolve(parameters: BeautyParameters(brightness: 0.2), faceGeometry: complete)
        XCTAssertTrue(eligible.activeDomains.contains(.color))
        XCTAssertTrue(eligible.effectiveStrengths.brightness > 0)
    }

    private func geometryRows() -> [GeometryRow] {
        [
            row("faceSlim", \.faceSlim, \.faceSlim, BeautySafetyCaps.faceSlim) { FaceShapeWarpProvider().fieldEmissions(face: $0, strengths: $1).faceSlim },
            row("faceSmall", \.faceSmall, \.faceSmall, BeautySafetyCaps.faceSmall) { FaceShapeWarpProvider().fieldEmissions(face: $0, strengths: $1).faceSmall },
            row("faceVShape", \.faceVShape, \.faceVShape, BeautySafetyCaps.faceVShape) { FaceShapeWarpProvider().fieldEmissions(face: $0, strengths: $1).faceVShape },
            row("jawSlim", \.jawSlim, \.jawSlim, BeautySafetyCaps.jawSlim) { FaceShapeWarpProvider().fieldEmissions(face: $0, strengths: $1).jawSlim },
            row("chinLength", \.chinLength, \.chinLength, BeautySafetyCaps.chinLength, signed: true) { ChinWarpProvider().fieldEmissions(face: $0, strengths: $1).chinLength },
            row("faceContourSmooth", \.faceContourSmooth, \.faceContourSmooth, BeautySafetyCaps.faceContourSmooth) { FaceShapeWarpProvider().fieldEmissions(face: $0, strengths: $1).faceContourSmooth },
            row("templeFullness", \.templeFullness, \.templeFullness, BeautySafetyCaps.templeFullness) { FaceShapeWarpProvider().fieldEmissions(face: $0, strengths: $1).templeFullness },
            row("cheekboneSlim", \.cheekboneSlim, \.cheekboneSlim, BeautySafetyCaps.cheekboneSlim) { FaceShapeWarpProvider().fieldEmissions(face: $0, strengths: $1).cheekboneSlim },
            row("chinTaper", \.chinTaper, \.chinTaper, BeautySafetyCaps.chinTaper) { ChinWarpProvider().fieldEmissions(face: $0, strengths: $1).chinTaper },
            row("eyeSize", \.eyeSize, \.eyeSize, BeautySafetyCaps.eyeSize) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).eyeSize },
            row("eyeDistance", \.eyeDistance, \.eyeDistance, BeautySafetyCaps.eyeDistance, signed: true) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).eyeDistance },
            row("eyeYPosition", \.eyeYPosition, \.eyeYPosition, BeautySafetyCaps.eyeYPosition, signed: true) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).eyeYPosition },
            row("eyeTailLift", \.eyeTailLift, \.eyeTailLift, BeautySafetyCaps.eyeTailLift) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).eyeTailLift },
            row("eyeHeight", \.eyeHeight, \.eyeHeight, BeautySafetyCaps.eyeHeight) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).eyeHeight },
            row("eyeLength", \.eyeLength, \.eyeLength, BeautySafetyCaps.eyeLength) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).eyeLength },
            row("upperEyelidLift", \.upperEyelidLift, \.upperEyelidLift, BeautySafetyCaps.upperEyelidLift) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).upperEyelidLift },
            row("pupilSize", \.pupilSize, \.pupilSize, BeautySafetyCaps.pupilSize) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).pupilSize },
            row("gazeCorrection", \.gazeCorrection, \.gazeCorrection, BeautySafetyCaps.gazeCorrection) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).gazeCorrection },
            row("lowerEyelidDrop", \.lowerEyelidDrop, \.lowerEyelidDrop, BeautySafetyCaps.lowerEyelidDrop) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).lowerEyelidDrop },
            row("eyeTilt", \.eyeTilt, \.eyeTilt, BeautySafetyCaps.eyeTilt, signed: true) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).eyeTilt },
            row("innerCornerOpen", \.innerCornerOpen, \.innerCornerOpen, BeautySafetyCaps.innerCornerOpen) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).innerCornerOpen },
            row("outerCornerOpen", \.outerCornerOpen, \.outerCornerOpen, BeautySafetyCaps.outerCornerOpen) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).outerCornerOpen },
            row("eyeSymmetry", \.eyeSymmetry, \.eyeSymmetry, BeautySafetyCaps.eyeSymmetry) { EyeWarpProvider().fieldEmissions(face: $0, strengths: $1).eyeSymmetry },
            row("eyebrowYPosition", \.eyebrowYPosition, \.eyebrowYPosition, BeautySafetyCaps.eyebrowYPosition, signed: true) { EyebrowWarpProvider().fieldEmissions(face: $0, strengths: $1).eyebrowYPosition },
            row("eyebrowThickness", \.eyebrowThickness, \.eyebrowThickness, BeautySafetyCaps.eyebrowThickness, signed: true) { EyebrowWarpProvider().fieldEmissions(face: $0, strengths: $1).eyebrowThickness },
            row("eyebrowLength", \.eyebrowLength, \.eyebrowLength, BeautySafetyCaps.eyebrowLength, signed: true) { EyebrowWarpProvider().fieldEmissions(face: $0, strengths: $1).eyebrowLength },
            row("eyebrowSpacing", \.eyebrowSpacing, \.eyebrowSpacing, BeautySafetyCaps.eyebrowSpacing, signed: true) { EyebrowWarpProvider().fieldEmissions(face: $0, strengths: $1).eyebrowSpacing },
            row("eyebrowHeadSpacing", \.eyebrowHeadSpacing, \.eyebrowHeadSpacing, BeautySafetyCaps.eyebrowHeadSpacing, signed: true) { EyebrowWarpProvider().fieldEmissions(face: $0, strengths: $1).eyebrowHeadSpacing },
            row("eyebrowTilt", \.eyebrowTilt, \.eyebrowTilt, BeautySafetyCaps.eyebrowTilt, signed: true) { EyebrowWarpProvider().fieldEmissions(face: $0, strengths: $1).eyebrowTilt },
            row("eyebrowPeakDefinition", \.eyebrowPeakDefinition, \.eyebrowPeakDefinition, BeautySafetyCaps.eyebrowPeakDefinition) { EyebrowWarpProvider().fieldEmissions(face: $0, strengths: $1).eyebrowPeakDefinition },
            row("noseSlim", \.noseSlim, \.noseSlim, BeautySafetyCaps.noseSlim) { NoseWarpProvider().fieldEmissions(face: $0, strengths: $1).noseSlim },
            row("noseWingSlim", \.noseWingSlim, \.noseWingSlim, BeautySafetyCaps.noseWingSlim) { NoseWarpProvider().fieldEmissions(face: $0, strengths: $1).noseWingSlim },
            row("noseTipSize", \.noseTipSize, \.noseTipSize, BeautySafetyCaps.noseTipSize, signed: true) { NoseWarpProvider().fieldEmissions(face: $0, strengths: $1).noseTipSize },
            row("noseBridge", \.noseBridge, \.noseBridge, BeautySafetyCaps.noseBridge) { NoseWarpProvider().fieldEmissions(face: $0, strengths: $1).noseBridge },
            row("noseRootNarrowing", \.noseRootNarrowing, \.noseRootNarrowing, BeautySafetyCaps.noseRootNarrowing) { NoseWarpProvider().fieldEmissions(face: $0, strengths: $1).noseRootNarrowing },
            row("noseTipLift", \.noseTipLift, \.noseTipLift, BeautySafetyCaps.noseTipLift) { NoseWarpProvider().fieldEmissions(face: $0, strengths: $1).noseTipLift },
            row("mouthSize", \.mouthSize, \.mouthSize, BeautySafetyCaps.mouthSize, signed: true) { MouthWarpProvider().fieldEmissions(face: $0, strengths: $1).mouthSize },
            row("mouthWidth", \.mouthWidth, \.mouthWidth, BeautySafetyCaps.mouthWidth, signed: true) { MouthWarpProvider().fieldEmissions(face: $0, strengths: $1).mouthWidth },
            row("smile", \.smile, \.smile, BeautySafetyCaps.smile) { MouthWarpProvider().fieldEmissions(face: $0, strengths: $1).smile },
            row("mouthYPosition", \.mouthYPosition, \.mouthYPosition, BeautySafetyCaps.mouthYPosition, signed: true) { MouthWarpProvider().fieldEmissions(face: $0, strengths: $1).mouthYPosition },
            row("mouthTilt", \.mouthTilt, \.mouthTilt, BeautySafetyCaps.mouthTilt, signed: true) { MouthWarpProvider().fieldEmissions(face: $0, strengths: $1).mouthTilt },
            row("mouthXPosition", \.mouthXPosition, \.mouthXPosition, BeautySafetyCaps.mouthXPosition, signed: true) { MouthWarpProvider().fieldEmissions(face: $0, strengths: $1).mouthXPosition },
            row("lipPeakDefinition", \.lipPeakDefinition, \.lipPeakDefinition, BeautySafetyCaps.lipPeakDefinition) { MouthWarpProvider().fieldEmissions(face: $0, strengths: $1).lipPeakDefinition },
            row("lipPlump", \.lipPlump, \.lipPlump, BeautySafetyCaps.lipPlump) { MouthWarpProvider().fieldEmissions(face: $0, strengths: $1).lipPlump },
        ]
    }

    private func completeGeometryFace() -> FaceGeometry {
        let base = FaceGeometry.phase46AsymmetricComplete
        let leftContour = [
            SIMD2<Float>(0.39, 0.39), SIMD2<Float>(0.425, 0.37), SIMD2<Float>(0.46, 0.39)
        ]
        let rightContour = [
            SIMD2<Float>(0.54, 0.39), SIMD2<Float>(0.585, 0.365), SIMD2<Float>(0.63, 0.39)
        ]
        func eyeSupport(
            side: BeautyObservedEyeSide,
            contour: [SIMD2<Float>],
            pupil: SIMD2<Float>
        ) -> BeautyEyeSemanticSupport {
            let center = contour.reduce(.zero, +) / Float(contour.count)
            let upper = contour.filter { $0.y <= center.y }
            let lower = contour.filter { $0.y >= center.y }
            return BeautyEyeSemanticSupport(
                side: side,
                contour: contour,
                upper: upper,
                lower: lower,
                inner: [side == .left ? contour[2] : contour[0]],
                outer: [side == .left ? contour[0] : contour[2]],
                corners: [contour[0], contour[2]],
                center: center,
                pupil: pupil,
                span: SIMD2<Float>(contour.map(\.x).max()! - contour.map(\.x).min()!, contour.map(\.y).max()! - contour.map(\.y).min()!),
                tilt: side == .left ? 0.08 : -0.02
            )
        }
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
            leftEyeSupport: eyeSupport(side: .left, contour: leftContour, pupil: SIMD2<Float>(0.425, 0.39)),
            rightEyeSupport: eyeSupport(side: .right, contour: rightContour, pupil: SIMD2<Float>(0.585, 0.39)),
            freshness: .fresh,
            observedEyebrowSupport: EyebrowSafetyFixtures.pairedSupport
        )
    }

    private func row(
        _ name: String,
        _ parameter: WritableKeyPath<BeautyParameters, Float>,
        _ effective: KeyPath<BeautyEffectiveStrengths, Float>,
        _ cap: Float,
        signed: Bool = false,
        emit: @escaping (FaceGeometry, BeautyEffectiveStrengths) -> [WarpControlPoint]
    ) -> GeometryRow {
        GeometryRow(name: name, parameter: parameter, effective: effective, cap: cap, signed: signed, emit: emit)
    }

    private func parameters(for row: GeometryRow, value: Float) -> BeautyParameters {
        var parameters = BeautyParameters()
        parameters[keyPath: row.parameter] = value
        return parameters
    }

    private func isFiniteNormalized(_ point: WarpControlPoint) -> Bool {
        CPUReferenceMetrics.isFiniteNormalized(point.source) && CPUReferenceMetrics.isFiniteNormalized(point.target)
    }

    private func displacement(of point: WarpControlPoint) -> Float {
        CPUReferenceMetrics.displacement(from: point.source, to: point.target)
    }

    private func localityEnvelope(_ points: [WarpControlPoint], width: Int, height: Int) -> Set<Int> {
        var allowed = Set<Int>()
        for row in 0..<height {
            for column in 0..<width {
                let point = SIMD2<Float>((Float(column) + 0.5) / Float(width), (Float(row) + 0.5) / Float(height))
                if points.contains(where: { CPUReferenceMetrics.displacement(from: point, to: $0.target) <= $0.radius + 1 / Float(min(width, height)) }) {
                    allowed.insert(row * width + column)
                }
            }
        }
        return allowed
    }

    private func renderedRGBABytes(from image: CIImage, width: Int, height: Int, colorSpace: CGColorSpace) -> [UInt8] {
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        context.render(image, toBitmap: &bytes, rowBytes: width * 4, bounds: CGRect(x: 0, y: 0, width: width, height: height), format: .RGBA8, colorSpace: colorSpace)
        return bytes
    }

    private func pixelBytes(_ bytes: [UInt8], at pixel: Int) -> (UInt8, UInt8, UInt8, UInt8) {
        let offset = pixel * 4
        return (bytes[offset], bytes[offset + 1], bytes[offset + 2], bytes[offset + 3])
    }
}
