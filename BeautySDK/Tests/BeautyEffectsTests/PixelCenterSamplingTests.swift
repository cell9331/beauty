import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

final class PixelCenterSamplingTests: XCTestCase {
    func testHorizontalOnlyWarpPreservesVerticalGradientExactly() throws {
        let size = 256
        let color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        var source = [UInt8](repeating: 255, count: size * size * 4)
        for y in 0..<size { for x in 0..<size {
            for c in 0..<3 { source[(y * size + x) * 4 + c] = UInt8((y * 17) % 256) }
        } }
        let input = CIImage(bitmapData: Data(source), bytesPerRow: size * 4,
            size: CGSize(width: size, height: size), format: .RGBA8, colorSpace: color)
        let lips = [CoordinatePoint(x: 0.35, y: 0.60), CoordinatePoint(x: 0.50, y: 0.57),
                    CoordinatePoint(x: 0.65, y: 0.60), CoordinatePoint(x: 0.50, y: 0.63)]
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: BeautyFaceObservation(
            imageBounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
            landmarks: .complete, observedLipSupport: .init(outer: lips)))
        let plan = BeautyEffectResolver.resolve(parameters: .init(mouthWidth: -0.35), faceGeometry: face)
        let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face)
        XCTAssertEqual(points.count, 2)
        XCTAssertTrue(points.allSatisfy { $0.source.y == $0.target.y })
        let result = BeautyGeometryEffectPipeline.applyMVPProxy(to: input, plan: plan, face: face)
        var output = [UInt8](repeating: 0, count: source.count)
        CIContext(options: [.workingColorSpace: color, .outputColorSpace: color]).render(
            result, toBitmap: &output, rowBytes: size * 4, bounds: input.extent,
            format: .RGBA8, colorSpace: color)
        XCTAssertEqual(zip(source, output).filter { $0 != $1 }.count, 0,
            "A horizontal field cannot change an image that is constant along x")
    }
}
