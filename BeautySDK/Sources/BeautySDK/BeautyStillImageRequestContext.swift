import BeautyCore
import BeautyDetection

/// One stack-local owner for the canonical still raster and selected mapped
/// support used by an admitted request.
///
/// This value is package-only and non-Codable. Its diagnostic surface contains
/// counts only; pixel bytes, landmark coordinates, stable IDs, and file/source
/// details never cross the request boundary.
package struct BeautyStillImageRequestContext: @unchecked Sendable {
    package let canonicalImage: BeautyCanonicalStillImage
    package let selectedFaceObservation: BeautyFaceObservation?

    package var redactedSummary: RedactedSummary {
        RedactedSummary(
            selectedFaceCount: selectedFaceObservation == nil ? 0 : 1,
            outerLipPointCount: selectedFaceObservation?.observedLipSupport?.outer?.count ?? 0,
            innerLipPointCount: selectedFaceObservation?.observedLipSupport?.inner?.count ?? 0
        )
    }

    package struct RedactedSummary: Equatable, Sendable, CustomStringConvertible {
        package let selectedFaceCount: Int
        package let outerLipPointCount: Int
        package let innerLipPointCount: Int

        package var description: String {
            "BeautyStillImageRequestContext(selectedFaceCount: \(selectedFaceCount), outerLipPointCount: \(outerLipPointCount), innerLipPointCount: \(innerLipPointCount))"
        }
    }
}
