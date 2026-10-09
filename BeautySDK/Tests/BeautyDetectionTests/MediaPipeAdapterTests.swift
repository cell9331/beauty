import BeautyCore
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@testable import BeautyDetection

final class MediaPipeAdapterTests: XCTestCase {
    func testBundledModelIsPinnedAndCorruptionIsRejected() throws {
        let bytes = try Data(contentsOf: MediaPipeModelResource.verifiedURL())
        XCTAssertTrue(MediaPipeModelResource.validate(bytes))
        XCTAssertFalse(MediaPipeModelResource.validate(Data()))
        var corrupt = bytes
        corrupt[0] ^= 1
        XCTAssertFalse(MediaPipeModelResource.validate(corrupt))
    }

    func testMeshRequiresExactly478FiniteBoundedPoints() throws {
        let valid = Array(repeating: SIMD3<Float>(0.5, 0.4, -0.01), count: 478)
        XCTAssertNotNil(BeautyFaceMesh(points: valid))
        XCTAssertNil(BeautyFaceMesh(points: Array(valid.dropLast())))
        XCTAssertNil(BeautyFaceMesh(points: valid + [valid[0]]))
        for invalid in [SIMD3<Float>(.nan, 0.4, 0), SIMD3<Float>(0.5, .infinity, 0),
                        SIMD3<Float>(0.5, 0.4, .nan), SIMD3<Float>(-0.001, 0.4, 0),
                        SIMD3<Float>(0.5, 1.001, 0)] {
            var points = valid
            points[120] = invalid
            XCTAssertNil(BeautyFaceMesh(points: points))
        }
    }

    func testInvalidPoseDoesNotInventOrEraseValidLandmarks() throws {
        let points = Array(repeating: SIMD3<Float>(0.5, 0.4, 0), count: 478)
        let matrix: [Float] = [1,0,0,2, 0,1,0,3, 0,0,1,4, 0,0,0,1]
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points, facialTransformation: matrix))
        XCTAssertEqual(mesh.facialTransformation, matrix)
        for invalid in [Array(matrix.dropLast()), Array(repeating: Float(0), count: 16),
                        [Float.nan] + Array(matrix.dropFirst()),
                        [1,0,0,0, 0,1,0,0, 0,0,1,0, 2,3,4,1]] {
            let result = try XCTUnwrap(BeautyFaceMesh(points: points, facialTransformation: invalid))
            XCTAssertNil(result.facialTransformation)
            XCTAssertEqual(result.points.count, 478)
        }
        var dumpOutput = ""
        dump(mesh, to: &dumpOutput)
        XCTAssertFalse(dumpOutput.contains("SIMD"))
        XCTAssertTrue(dumpOutput.contains("pointCount"))
        XCTAssertFalse(String(reflecting: mesh).contains("0.5"))
    }

    func testTopologyUsesObservedPointsAndImageSideConvention() throws {
        var points: [SIMD3<Float>] = (0..<478).map { index in
            let x = Float(index % 23 + 1) / 25
            let y = Float(index / 23 + 1) / 23
            return SIMD3<Float>(x, y, -0.01)
        }
        for (indices, x) in [(MediaPipeFaceTopology.leftEye, Float(0.3)),
                             (MediaPipeFaceTopology.rightEye, Float(0.7))] {
            for (offset, index) in indices.enumerated() {
                let angle = Float(offset) * 2 * .pi / Float(indices.count)
                points[index] = SIMD3<Float>(x + cos(angle) * 0.06, 0.4 + sin(angle) * 0.025, 0)
            }
        }
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points))
        let observation = try XCTUnwrap(MediaPipeFaceTopology.observation(from: mesh))
        XCTAssertEqual(observation.observedEyeOrder, .canonical)
        XCTAssertEqual(observation.observedEyeSupport?.first?.contour, mesh.path(MediaPipeFaceTopology.leftEye))
        XCTAssertEqual(observation.observedEyeSupport?.first?.pupil, mesh.path([468]))
        XCTAssertEqual(observation.observedFaceSupport?.contour, mesh.path(MediaPipeFaceTopology.lowerContour))
        XCTAssertEqual(observation.observedEyebrowSupport?.left, mesh.path(MediaPipeFaceTopology.leftBrow))
        XCTAssertEqual(observation.observedNoseSupport?.crest, mesh.path(MediaPipeFaceTopology.noseCrest))
        XCTAssertEqual(observation.observedLipSupport?.outer?.count, 20)
        XCTAssertEqual(observation.observedLipSupport?.inner?.count, 20)
        XCTAssertTrue(observation.mesh == mesh)
        XCTAssertEqual(mesh.path([-1]), [])
        XCTAssertEqual(mesh.path([478]), [])
        var dumpOutput = ""
        dump(observation, to: &dumpOutput)
        XCTAssertFalse(dumpOutput.contains("SIMD"))
        XCTAssertFalse(dumpOutput.contains("CoordinatePoint"))
    }

    func testMappedProviderNeverAppliesOrientationTwiceAndRejectsBadPeer() throws {
        let bounds = CoordinateRect(x: 0.2, y: 0.3, width: 0.4, height: 0.5)
        let point = CoordinatePoint(x: 0.35, y: 0.42)
        let observation = BeautyFaceObservation(imageBounds: bounds,
            observedLipSupport: BeautyObservedLipSupport(outer: [point]))
        var detector = BeautyFaceDetector(mappedObservationProvider: { _ in
            BeautyMappedFaceObservations(observations: [observation], rejectedFaceCount: 1)
        })
        let result = detector.detect(metadata: BeautyInputMetadata(orientation: .rightMirrored,
            isInputMirrored: true, isPreviewMirrored: true, source: .testFixture))
        XCTAssertEqual(result.observations.first?.imageBounds, bounds)
        XCTAssertEqual(result.observations.first?.observedLipSupport?.outer, [point])
        XCTAssertEqual(result.summary.availability, .partial)
        XCTAssertEqual(result.summary.reasons, [.mappingFailed])
        XCTAssertEqual(result.summary.faceCount, 2)
        XCTAssertEqual(result.summary.usedFaceCount, 1)
        var rejected = BeautyFaceDetector(mappedObservationProvider: { _ in
            BeautyMappedFaceObservations(observations: [], rejectedFaceCount: 1)
        })
        XCTAssertEqual(rejected.detect(metadata: .init(orientation: .up, source: .testFixture)).summary.reasons, [.mappingFailed])
    }

    func testRasterAppliesAllExifOrientationsAndInputMirrorOnce() throws {
        // Six generated color cells allow an independent exact permutation
        // oracle. Preview mirroring must not change inference pixels.
        let bytes: [UInt8] = [
            255,0,0,255, 0,255,0,255, 0,0,255,255,
            255,255,0,255, 0,255,255,255, 255,0,255,255
        ]
        let source = CIImage(bitmapData: Data(bytes), bytesPerRow: 12,
            size: CGSize(width: 3, height: 2), format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
        let orders = [[0,1,2,3,4,5], [2,1,0,5,4,3], [5,4,3,2,1,0], [3,4,5,0,1,2],
                      [0,3,1,4,2,5], [3,0,4,1,5,2], [5,2,4,1,3,0], [2,5,1,4,0,3]]
        let base = try cellIDs(MediaPipeDetectionRaster.make(.init(metadata: .init(orientation: .up, source: .testFixture),
            imageExtent: source.extent.size, stillImage: source)))
        for raw in UInt32(1)...8 {
            let orientation = try XCTUnwrap(CGImagePropertyOrientation(rawValue: raw))
            for mirrored in [false, true] {
                let raster = try MediaPipeDetectionRaster.make(.init(metadata: .init(orientation: orientation,
                    isInputMirrored: mirrored, isPreviewMirrored: true, source: .testFixture),
                    imageExtent: source.extent.size, stillImage: source))
                XCTAssertEqual(raster.width, raw <= 4 ? 3 : 2)
                XCTAssertEqual(raster.height, raw <= 4 ? 2 : 3)
                var expected = orders[Int(raw - 1)].map { base[$0] }
                if mirrored {
                    expected = stride(from: 0, to: expected.count, by: raster.width)
                        .flatMap { Array(expected[$0..<($0 + raster.width)].reversed()) }
                }
                XCTAssertTrue(try cellIDs(raster) == expected, "orientation/mirror permutation mismatch")
            }
        }
    }

    func testRasterBoundsAndPreferredSizeFailBeforeInference() throws {
        let image = CIImage(color: CIColor(red: 0.5, green: 0.5, blue: 0.5))
            .cropped(to: CGRect(x: 11, y: 13, width: 80, height: 120))
        let metadata = BeautyInputMetadata(orientation: .right, source: .testFixture)
        let raster = try MediaPipeDetectionRaster.make(.init(metadata: metadata,
            imageExtent: image.extent.size, stillImage: image, preferredProcessingSize: CGSize(width: 30, height: 20)))
        XCTAssertEqual(raster.width, 30)
        XCTAssertEqual(raster.height, 20)
        XCTAssertThrowsError(try MediaPipeDetectionRaster.make(.init(metadata: metadata,
            imageExtent: image.extent.size, stillImage: image, maximumPixelCount: 100)))
        XCTAssertThrowsError(try MediaPipeDetectionRaster.make(.init(metadata: metadata,
            imageExtent: CGSize(width: 1, height: 1), stillImage: image)))
        XCTAssertThrowsError(try MediaPipeDetectionRaster.make(.init(metadata: metadata,
            imageExtent: image.extent.size, stillImage: image, preferredProcessingSize: CGSize(width: CGFloat.nan, height: 20))))
    }

    private func cellIDs(_ image: CGImage) throws -> [UInt32] {
        let data = try XCTUnwrap(image.dataProvider?.data) as Data
        return (0..<image.height).flatMap { row in
            (0..<image.width).map { column in
                let offset = row * image.bytesPerRow + column * 4
                return UInt32(data[offset]) << 16 | UInt32(data[offset + 1]) << 8 | UInt32(data[offset + 2])
            }
        }
    }
}
