import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
@testable import BeautyEffects

final class BeautyGeometryEffectPipelineTests: XCTestCase {
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
