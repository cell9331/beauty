import BeautyCore

struct WarpControlPointResult: Equatable, Sendable {
    let points: [WarpControlPoint]
    let skipReason: String?

    static let missingFaceContour = WarpControlPointResult(
        points: [],
        skipReason: "missing_face_contour"
    )

    init(points: [WarpControlPoint], skipReason: String? = nil) {
        self.points = points
        self.skipReason = skipReason
    }
}

protocol WarpControlPointProvider: Sendable {
    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult
}
