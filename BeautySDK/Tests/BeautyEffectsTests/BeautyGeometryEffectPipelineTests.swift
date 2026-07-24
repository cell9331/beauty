import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class BeautyGeometryEffectPipelineTests: XCTestCase {
    func testGEOMFinalNamedEmissionsDispatchOnceThroughExistingPipeline() {
        let face = phase50AllProviderFace
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                faceSlim: 0.10,
                chinLength: -0.10,
                faceContourSmooth: 0.10,
                templeFullness: 0.10,
                cheekboneSlim: 0.10,
                chinTaper: 0.10,
                eyeHeight: 0.10,
                eyebrowYPosition: -0.10,
                noseRootNarrowing: 0.10,
                mouthYPosition: -0.10
            ),
            faceGeometry: face
        )
        let strengths = plan.effectiveStrengths
        let faceEmissions = FaceShapeWarpProvider().fieldEmissions(
            face: face,
            strengths: strengths
        )
        let chinEmissions = ChinWarpProvider().fieldEmissions(
            face: face,
            strengths: strengths
        )
        let eyeEmissions = EyeWarpProvider().fieldEmissions(
            face: face,
            strengths: strengths
        )
        let eyebrowEmissions = EyebrowWarpProvider().fieldEmissions(
            face: face,
            strengths: strengths
        )
        let noseEmissions = NoseWarpProvider().fieldEmissions(
            face: face,
            strengths: strengths
        )
        let mouthEmissions = MouthWarpProvider().fieldEmissions(
            face: face,
            strengths: strengths
        )

        XCTAssertFalse(faceEmissions.faceSlim.isEmpty)
        XCTAssertFalse(faceEmissions.faceContourSmooth.isEmpty)
        XCTAssertFalse(faceEmissions.templeFullness.isEmpty)
        XCTAssertFalse(faceEmissions.cheekboneSlim.isEmpty)
        XCTAssertFalse(chinEmissions.chinLength.isEmpty)
        XCTAssertFalse(chinEmissions.chinTaper.isEmpty)
        XCTAssertFalse(eyeEmissions.eyeHeight.isEmpty)
        XCTAssertFalse(eyebrowEmissions.eyebrowYPosition.isEmpty)
        XCTAssertFalse(noseEmissions.noseRootNarrowing.isEmpty)
        XCTAssertFalse(mouthEmissions.mouthYPosition.isEmpty)

        let providerArrays: [[WarpControlPoint]] = [
            faceEmissions.points,
            chinEmissions.points,
            eyeEmissions.points,
            eyebrowEmissions.points,
            noseEmissions.points,
            mouthEmissions.points,
        ]
        let expected = providerArrays.flatMap { $0 }
        let expectedCount = providerArrays.reduce(0) { $0 + $1.count }

        XCTAssertEqual(expected.count, expectedCount)
        XCTAssertEqual(
            BeautyGeometryEffectPipeline.controlPoints(for: strengths, face: face),
            expected,
            "Final named provider arrays must enter the existing face→chin→eye→eyebrow→nose→mouth order exactly once."
        )
        XCTAssertEqual(
            BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face),
            expected,
            "The existing plan-gated render path must dispatch the same final provider arrays."
        )
        XCTAssertEqual(
            plan.metrics["beauty.effects.geometryPointCount"],
            Double(expectedCount),
            "Face-domain accounting must not count the unified eye/nose/mouth arrays a second time."
        )
        XCTAssertTrue(
            plan.activeDomains.isSuperset(
                of: Set<BeautyEffectDomain>([.faceShape, .eyes, .eyebrows, .nose, .mouth])
            )
        )
    }

    func testBROW08EyebrowOnlyDispatchesOnceAndRemovedWorkDispatchesNothing() {
        let face = phase50AllProviderFace
        let active = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(eyebrowYPosition: 1),
            faceGeometry: face
        )
        let expected = EyebrowWarpProvider().fieldEmissions(
            face: face,
            strengths: active.effectiveStrengths
        ).eyebrowYPosition
        XCTAssertFalse(expected.isEmpty)
        XCTAssertEqual(BeautyGeometryEffectPipeline.controlPoints(for: active, face: face), expected)
        XCTAssertEqual(active.metrics["beauty.effects.geometryPointCount"], Double(expected.count))

        let removedFace = phase50Face(eyebrowSupport: nil)
        let removed = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(eyebrowYPosition: 1),
            faceGeometry: removedFace
        )
        XCTAssertFalse(removed.activeDomains.contains(.eyebrows))
        XCTAssertTrue(BeautyGeometryEffectPipeline.controlPoints(for: removed, face: removedFace).isEmpty)
    }

    func testCIImageGeometryWarpMovesLocalPixelsWithoutGlobalColorBias() throws {
        let width = 160
        let height = 160
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let input = gradientRGBABytes(width: width, height: height)
        let image = CIImage(
            bitmapData: Data(input),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 1),
            faceGeometry: .fixture
        )
        let controlPoint = try XCTUnwrap(
            BeautyGeometryEffectPipeline
                .controlPoints(for: plan, face: .fixture)
                .first { $0.source.x < FaceGeometry.fixture.center.x }
        )

        let output = BeautyGeometryEffectPipeline.applyMVPProxy(to: image, plan: plan, face: .fixture)
        let baseline = renderedRGBABytes(from: image, width: width, height: height, colorSpace: colorSpace)
        let warped = renderedRGBABytes(from: output, width: width, height: height, colorSpace: colorSpace)
        let sourceLocation = pixelLocation(for: controlPoint.source, width: width, height: height)
        let targetLocation = pixelLocation(for: controlPoint.target, width: width, height: height)
        let baselineAtSource = pixel(in: baseline, width: width, column: sourceLocation.column, row: sourceLocation.row)
        let baselineAtTarget = pixel(in: baseline, width: width, column: targetLocation.column, row: targetLocation.row)
        let warpedAtTarget = pixel(in: warped, width: width, column: targetLocation.column, row: targetLocation.row)

        XCTAssertEqual(pixel(in: warped, width: width, column: 2, row: 2), pixel(in: baseline, width: width, column: 2, row: 2))
        XCTAssertNotEqual(warpedAtTarget, baselineAtTarget)
        XCTAssertLessThan(
            pixelDistance(warpedAtTarget, baselineAtSource),
            pixelDistance(warpedAtTarget, baselineAtTarget)
        )
        XCTAssertEqual(warpedAtTarget.alpha, 255)
    }

    private var phase50AllProviderFace: FaceGeometry {
        phase50Face(
            eyebrowSupport: BeautyEyebrowSemanticSupport(
                left: phase50Trace(side: .left),
                right: phase50Trace(side: .right)
            )
        )
    }

    private func phase50Trace(side: BeautyObservedEyebrowSide) -> BeautyEyebrowSemanticTrace {
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

    private func phase50Face(eyebrowSupport: BeautyEyebrowSemanticSupport?) -> FaceGeometry {
        let base = FaceGeometry.phase46AsymmetricComplete
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
            freshness: .fresh,
            observedEyebrowSupport: eyebrowSupport
        )
    }

    private func gradientRGBABytes(width: Int, height: Int) -> [UInt8] {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(width * height * 4)
        for row in 0..<height {
            for column in 0..<width {
                bytes.append(UInt8(column * 255 / max(width - 1, 1)))
                bytes.append(UInt8(row * 255 / max(height - 1, 1)))
                bytes.append(UInt8((column + row) * 255 / max(width + height - 2, 1)))
                bytes.append(255)
            }
        }
        return bytes
    }

    private func renderedRGBABytes(
        from image: CIImage,
        width: Int,
        height: Int,
        colorSpace: CGColorSpace
    ) -> [UInt8] {
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace
        ])
        var output = [UInt8](repeating: 0, count: width * height * 4)
        output.withUnsafeMutableBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress else {
                return
            }
            context.render(
                image,
                toBitmap: baseAddress,
                rowBytes: width * 4,
                bounds: CGRect(x: 0, y: 0, width: width, height: height),
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return output
    }

    private func pixelLocation(
        for point: SIMD2<Float>,
        width: Int,
        height: Int
    ) -> (column: Int, row: Int) {
        (
            column: min(max(Int((point.x * Float(width - 1)).rounded()), 0), width - 1),
            row: min(max(Int(((1 - point.y) * Float(height - 1)).rounded()), 0), height - 1)
        )
    }

    private func pixel(
        in bytes: [UInt8],
        width: Int,
        column: Int,
        row: Int
    ) -> Pixel {
        let offset = (row * width + column) * 4
        return Pixel(
            red: bytes[offset],
            green: bytes[offset + 1],
            blue: bytes[offset + 2],
            alpha: bytes[offset + 3]
        )
    }

    private func pixelDistance(
        _ lhs: Pixel,
        _ rhs: Pixel
    ) -> Int {
        abs(Int(lhs.red) - Int(rhs.red)) +
            abs(Int(lhs.green) - Int(rhs.green)) +
            abs(Int(lhs.blue) - Int(rhs.blue)) +
            abs(Int(lhs.alpha) - Int(rhs.alpha))
    }

    private struct Pixel: Equatable {
        let red: UInt8
        let green: UInt8
        let blue: UInt8
        let alpha: UInt8
    }
}
