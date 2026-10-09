#if os(iOS)
import CoreImage
import Foundation
import MediaPipeTasksVision
import UIKit

/// The lock protects the non-Sendable native task captured by a Sendable
/// provider. Engine serialization remains a caller requirement. Only the task
/// is cached, never images, results, landmarks or selection IDs.
final class MediaPipeFaceObservationProvider: @unchecked Sendable {
    private let lock = NSLock()
    private var landmarker: FaceLandmarker?
    private var faceBudget: Int?

    func reset() {
        lock.withLock {
            landmarker = nil
            faceBudget = nil
        }
    }

    func detect(_ input: VisionFaceDetectionInput) throws -> BeautyMappedFaceObservations {
        // numFaces controls native graph allocation, unlike Vision's
        // post-detection selection cap. Bound it before crossing into C++.
        guard input.maximumFaceCount <= 32 else {
            throw BeautyFaceDetector.Failure.detectorUnavailable
        }
        let raster = try MediaPipeDetectionRaster.make(input)
        return try lock.withLock {
            if landmarker == nil || faceBudget != input.maximumFaceCount {
                let options = FaceLandmarkerOptions()
                options.baseOptions.modelAssetPath = try MediaPipeModelResource.verifiedURL().path
                options.baseOptions.delegate = .CPU
                options.runningMode = .image
                options.numFaces = input.maximumFaceCount
                options.minFaceDetectionConfidence = 0.5
                options.minFacePresenceConfidence = 0.5
                options.minTrackingConfidence = 0.5
                options.outputFaceBlendshapes = false
                options.outputFacialTransformationMatrixes = true
                landmarker = try FaceLandmarker(options: options)
                faceBudget = input.maximumFaceCount
            }
            guard let landmarker else { throw BeautyFaceDetector.Failure.detectorUnavailable }
            let result = try landmarker.detect(image: MPImage(uiImage: UIImage(cgImage: raster)))
            var observations: [BeautyFaceObservation] = []
            for (index, landmarks) in result.faceLandmarks.enumerated() {
                let transform: [Float]?
                if result.facialTransformationMatrixes.indices.contains(index) {
                    let matrix = result.facialTransformationMatrixes[index]
                    // The iOS helper copies MatrixData's column-major buffer
                    // without its layout metadata. Its valueAtRow accessor
                    // indexes that buffer as row-major in 1.1.0. Transpose the
                    // documented packed layout explicitly at this boundary.
                    transform = matrix.rows == 4 && matrix.columns == 4
                        ? (0..<4).flatMap { row in (0..<4).map { column in
                            matrix.data[column * 4 + row]
                        }} : nil
                } else { transform = nil }
                if let mesh = BeautyFaceMesh(points: landmarks.map { SIMD3<Float>($0.x, $0.y, $0.z) },
                                             facialTransformation: transform),
                   let observation = MediaPipeFaceTopology.observation(from: mesh) {
                    observations.append(observation)
                }
            }
            return BeautyMappedFaceObservations(observations: observations,
                rejectedFaceCount: result.faceLandmarks.count - observations.count)
        }
    }
}
#endif
