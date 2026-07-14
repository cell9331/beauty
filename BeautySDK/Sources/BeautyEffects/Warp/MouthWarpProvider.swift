import Foundation

struct MouthWarpFieldEmissions: Equatable, Sendable {
    let mouthSize: [WarpControlPoint]
    let mouthWidth: [WarpControlPoint]
    let smile: [WarpControlPoint]
    let mouthYPosition: [WarpControlPoint]
    let mouthTilt: [WarpControlPoint]
    let mouthXPosition: [WarpControlPoint]
    let lipPeakDefinition: [WarpControlPoint]
    let lipPlump: [WarpControlPoint]

    var points: [WarpControlPoint] {
        mouthSize +
            mouthWidth +
            smile +
            mouthYPosition +
            mouthTilt +
            mouthXPosition +
            lipPeakDefinition +
            lipPlump
    }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.mouthSize != 0, mouthSize.isEmpty {
            sanitized.mouthSize = 0
        }
        if strengths.mouthWidth != 0, mouthWidth.isEmpty {
            sanitized.mouthWidth = 0
        }
        if strengths.smile != 0, smile.isEmpty {
            sanitized.smile = 0
        }
        if strengths.mouthYPosition != 0, mouthYPosition.isEmpty {
            sanitized.mouthYPosition = 0
        }
        if strengths.mouthTilt != 0, mouthTilt.isEmpty {
            sanitized.mouthTilt = 0
        }
        if strengths.mouthXPosition != 0, mouthXPosition.isEmpty {
            sanitized.mouthXPosition = 0
        }
        if strengths.lipPeakDefinition != 0, lipPeakDefinition.isEmpty {
            sanitized.lipPeakDefinition = 0
        }
        if strengths.lipPlump != 0, lipPlump.isEmpty {
            sanitized.lipPlump = 0
        }
        return sanitized
    }
}

struct MouthWarpProvider: WarpControlPointProvider {
    private let displacementThreshold = Float.ulpOfOne

    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult {
        let emissions = fieldEmissions(face: face, strengths: strengths)
        let requestedWork = strengths.mouthSize != 0 ||
            strengths.mouthWidth != 0 ||
            strengths.smile != 0 ||
            strengths.mouthYPosition != 0 ||
            strengths.mouthTilt != 0 ||
            strengths.mouthXPosition != 0 ||
            strengths.lipPeakDefinition != 0 ||
            strengths.lipPlump != 0

        return WarpControlPointResult(
            points: emissions.points,
            skipReason: requestedWork && emissions.points.isEmpty ? "mouth_inputs_missing" : nil
        )
    }

    func fieldEmissions(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> MouthWarpFieldEmissions {
        MouthWarpFieldEmissions(
            mouthSize: sizePoints(face: face, strength: strengths.mouthSize),
            mouthWidth: widthPoints(face: face, strength: strengths.mouthWidth),
            smile: smilePoints(face: face, strength: strengths.smile),
            mouthYPosition: yPositionPoints(face: face, strength: strengths.mouthYPosition),
            mouthTilt: tiltPoints(face: face, strength: strengths.mouthTilt),
            mouthXPosition: xPositionPoints(face: face, strength: strengths.mouthXPosition),
            lipPeakDefinition: peakDefinitionPoints(face: face, strength: strengths.lipPeakDefinition),
            lipPlump: plumpPoints(face: face, strength: strengths.lipPlump)
        )
    }

    private func sizePoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let signedStrength = validatedSignedStrength(strength, cap: BeautySafetyCaps.mouthSize),
              let support = validatedWholeSupport(in: face),
              let center = validatedCenter(of: support, in: face.bounds)
        else {
            return []
        }

        let requestedDisplacement = face.bounds.width * 0.035 * abs(signedStrength) / BeautySafetyCaps.mouthSize
        guard let displacement = legacyRenderableDisplacement(requestedDisplacement) else {
            return []
        }

        let sources = cardinalLipPoints(support)
        let targets = sources.map { source in
            signedStrength < 0 ?
                move(source, toward: center, by: displacement) :
                move(source, awayFrom: center, by: displacement)
        }
        return makePoints(
            sources: sources,
            targets: targets,
            bounds: face.bounds,
            radius: face.bounds.width * 0.13,
            strength: abs(signedStrength)
        )
    }

    private func widthPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let signedStrength = validatedSignedStrength(strength, cap: BeautySafetyCaps.mouthWidth),
              let support = validatedWholeSupport(in: face),
              let left = support.min(by: { $0.x < $1.x }),
              let right = support.max(by: { $0.x < $1.x }),
              left != right
        else {
            return []
        }

        let requestedDisplacement = face.bounds.width * 0.040 * abs(signedStrength) / BeautySafetyCaps.mouthWidth
        guard let displacement = legacyRenderableDisplacement(requestedDisplacement) else {
            return []
        }
        let direction: Float = signedStrength < 0 ? -1 : 1
        return makePoints(
            sources: [left, right],
            targets: [
                SIMD2<Float>(left.x - displacement * direction, left.y),
                SIMD2<Float>(right.x + displacement * direction, right.y)
            ],
            bounds: face.bounds,
            radius: face.bounds.width * 0.11,
            strength: abs(signedStrength)
        )
    }

    private func smilePoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let positiveStrength = validatedPositiveStrength(strength, cap: BeautySafetyCaps.smile),
              let support = validatedWholeSupport(in: face),
              let left = support.min(by: { $0.x < $1.x }),
              let right = support.max(by: { $0.x < $1.x }),
              left != right
        else {
            return []
        }

        let displacement = face.bounds.height * 0.035 * positiveStrength / BeautySafetyCaps.smile
        guard isRenderableScalar(displacement) else {
            return []
        }
        return makePoints(
            sources: [left, right],
            targets: [
                SIMD2<Float>(left.x, left.y - displacement),
                SIMD2<Float>(right.x, right.y - displacement)
            ],
            bounds: face.bounds,
            radius: face.bounds.width * 0.12,
            strength: positiveStrength
        )
    }

    private func yPositionPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let signedStrength = validatedSignedStrength(strength, cap: BeautySafetyCaps.mouthYPosition),
              let support = validatedWholeSupport(in: face)
        else {
            return []
        }

        let displacement = face.bounds.height * 0.025 * signedStrength / BeautySafetyCaps.mouthYPosition
        guard isRenderableScalar(abs(displacement)) else {
            return []
        }
        return makePoints(
            sources: support,
            targets: support.map { SIMD2<Float>($0.x, $0.y + displacement) },
            bounds: face.bounds,
            radius: face.bounds.width * 0.10,
            strength: abs(signedStrength)
        )
    }

    private func xPositionPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let signedStrength = validatedSignedStrength(strength, cap: BeautySafetyCaps.mouthXPosition),
              let support = validatedWholeSupport(in: face)
        else {
            return []
        }

        let displacement = face.bounds.width * 0.025 * signedStrength / BeautySafetyCaps.mouthXPosition
        guard isRenderableScalar(abs(displacement)) else {
            return []
        }
        return makePoints(
            sources: support,
            targets: support.map { SIMD2<Float>($0.x + displacement, $0.y) },
            bounds: face.bounds,
            radius: face.bounds.width * 0.10,
            strength: abs(signedStrength)
        )
    }

    private func tiltPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let signedStrength = validatedSignedStrength(strength, cap: BeautySafetyCaps.mouthTilt),
              let support = validatedWholeSupport(in: face),
              let center = validatedCenter(of: support, in: face.bounds)
        else {
            return []
        }

        // Image-normalized Y grows downward, so a positive angle is visually clockwise.
        let angle = 0.10 * signedStrength / BeautySafetyCaps.mouthTilt
        let cosine = cos(angle)
        let sine = sin(angle)
        guard angle.isFinite, cosine.isFinite, sine.isFinite else {
            return []
        }

        let noncentralSources = support.filter {
            LandmarkGeometryHelper.distance($0, center) > displacementThreshold
        }
        let targets = noncentralSources.map { source -> SIMD2<Float> in
            let vector = source - center
            return center + SIMD2<Float>(
                vector.x * cosine - vector.y * sine,
                vector.x * sine + vector.y * cosine
            )
        }
        return makePoints(
            sources: noncentralSources,
            targets: targets,
            bounds: face.bounds,
            radius: face.bounds.width * 0.10,
            strength: abs(signedStrength)
        )
    }

    private func peakDefinitionPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let positiveStrength = validatedPositiveStrength(strength, cap: BeautySafetyCaps.lipPeakDefinition),
              let upper = validatedSurfaceSupport(face.upperLips, in: face.bounds),
              let inner = validatedInnerSupport(in: face),
              let innerCenter = validatedCenter(of: inner, in: face.bounds),
              averageY(of: upper) < innerCenter.y
        else {
            return []
        }

        let sources = upper.sorted { lhs, rhs in
            lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
        }
        let displacement = face.bounds.height * 0.014 * positiveStrength / BeautySafetyCaps.lipPeakDefinition
        guard isRenderableScalar(displacement), sources.count >= 3 else {
            return []
        }

        let centerIndex = sources.count / 2
        let targets = sources.enumerated().map { index, source in
            let deltaY = index == centerIndex ? displacement * 0.5 : -displacement
            return SIMD2<Float>(source.x, source.y + deltaY)
        }
        return makePoints(
            sources: sources,
            targets: targets,
            bounds: face.bounds,
            radius: face.bounds.width * 0.08,
            strength: positiveStrength
        )
    }

    private func plumpPoints(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        guard let positiveStrength = validatedPositiveStrength(strength, cap: BeautySafetyCaps.lipPlump),
              let upper = validatedSurfaceSupport(face.upperLips, in: face.bounds),
              let lower = validatedSurfaceSupport(face.lowerLips, in: face.bounds),
              let inner = validatedInnerSupport(in: face),
              let innerCenter = validatedCenter(of: inner, in: face.bounds),
              averageY(of: upper) < innerCenter.y,
              averageY(of: lower) > innerCenter.y
        else {
            return []
        }

        let upperSources = upper.sorted { lhs, rhs in
            lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
        }
        let lowerSources = lower.sorted { lhs, rhs in
            lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
        }
        let sources = upperSources + lowerSources
        let displacement = face.bounds.height * 0.014 * positiveStrength / BeautySafetyCaps.lipPlump
        guard isRenderableScalar(displacement) else {
            return []
        }

        let targets = sources.map { move($0, awayFrom: innerCenter, by: displacement) }
        let points = makePoints(
            sources: sources,
            targets: targets,
            bounds: face.bounds,
            radius: face.bounds.width * 0.09,
            strength: positiveStrength
        )
        guard points.count == sources.count,
              !points.prefix(upperSources.count).isEmpty,
              !points.dropFirst(upperSources.count).isEmpty
        else {
            return []
        }
        return points
    }

    private func validatedWholeSupport(in face: FaceGeometry) -> [SIMD2<Float>]? {
        guard isValidBounds(face.bounds),
              let support = validatedSupport(face.outerLips, minimumCount: 4, in: face.bounds),
              hasSpan(support, keyPath: \.x),
              hasSpan(support, keyPath: \.y)
        else {
            return nil
        }
        return support
    }

    private func validatedSurfaceSupport(
        _ points: [SIMD2<Float>],
        in bounds: FaceBounds
    ) -> [SIMD2<Float>]? {
        guard isValidBounds(bounds),
              let support = validatedSupport(points, minimumCount: 3, in: bounds),
              hasSpan(support, keyPath: \.x)
        else {
            return nil
        }
        return support
    }

    private func validatedInnerSupport(in face: FaceGeometry) -> [SIMD2<Float>]? {
        guard isValidBounds(face.bounds),
              let support = validatedSupport(face.innerLips, minimumCount: 4, in: face.bounds),
              hasSpan(support, keyPath: \.x),
              hasSpan(support, keyPath: \.y)
        else {
            return nil
        }
        return support
    }

    private func validatedSupport(
        _ points: [SIMD2<Float>],
        minimumCount: Int,
        in bounds: FaceBounds
    ) -> [SIMD2<Float>]? {
        guard points.count >= minimumCount,
              points.allSatisfy({ isValidSupportPoint($0, in: bounds) }),
              hasOnlyDistinctPoints(points)
        else {
            return nil
        }
        return points
    }

    private func validatedCenter(
        of points: [SIMD2<Float>],
        in bounds: FaceBounds
    ) -> SIMD2<Float>? {
        guard let center = LandmarkGeometryHelper.center(of: points),
              isValidSupportPoint(center, in: bounds)
        else {
            return nil
        }
        return center
    }

    private func validatedSignedStrength(_ strength: Float, cap: Float) -> Float? {
        guard strength.isFinite, cap.isFinite, cap > 0, abs(strength) > Float.ulpOfOne else {
            return nil
        }
        return min(abs(strength), cap) * (strength < 0 ? -1 : 1)
    }

    private func validatedPositiveStrength(_ strength: Float, cap: Float) -> Float? {
        guard strength.isFinite, cap.isFinite, cap > 0, strength > Float.ulpOfOne else {
            return nil
        }
        return min(strength, cap)
    }

    private func isValidBounds(_ bounds: FaceBounds) -> Bool {
        bounds.x.isFinite && bounds.y.isFinite &&
            bounds.width.isFinite && bounds.height.isFinite &&
            bounds.width > 0 && bounds.height > 0 &&
            bounds.minX >= 0 && bounds.maxX <= 1 &&
            bounds.minY >= 0 && bounds.maxY <= 1
    }

    private func isValidSupportPoint(_ point: SIMD2<Float>, in bounds: FaceBounds) -> Bool {
        isValidNormalizedPoint(point) &&
            point.x >= bounds.minX && point.x <= bounds.maxX &&
            point.y >= bounds.minY && point.y <= bounds.maxY
    }

    private func isValidNormalizedPoint(_ point: SIMD2<Float>) -> Bool {
        point.x.isFinite && point.y.isFinite &&
            (0...1).contains(point.x) && (0...1).contains(point.y)
    }

    private func hasOnlyDistinctPoints(_ points: [SIMD2<Float>]) -> Bool {
        for index in points.indices {
            for otherIndex in points.indices where otherIndex > index && points[index] == points[otherIndex] {
                return false
            }
        }
        return true
    }

    private func hasSpan(
        _ points: [SIMD2<Float>],
        keyPath: KeyPath<SIMD2<Float>, Float>
    ) -> Bool {
        guard let minimum = points.map({ $0[keyPath: keyPath] }).min(),
              let maximum = points.map({ $0[keyPath: keyPath] }).max()
        else {
            return false
        }
        return maximum - minimum > displacementThreshold
    }

    private func averageY(of points: [SIMD2<Float>]) -> Float {
        points.reduce(0) { $0 + $1.y } / Float(points.count)
    }

    private func isRenderableScalar(_ value: Float) -> Bool {
        value.isFinite && value > displacementThreshold
    }

    private func legacyRenderableDisplacement(_ requested: Float) -> Float? {
        guard requested.isFinite, requested > 0 else {
            return nil
        }
        // Existing signed size/width convergence relies on work just above the scalar threshold
        // emitting before conflict scaling. Keep it renderable without changing normal-strength output.
        return max(requested, Float.ulpOfOne * 2)
    }

    private func cardinalLipPoints(_ points: [SIMD2<Float>]) -> [SIMD2<Float>] {
        var result: [SIMD2<Float>] = []
        if let left = points.min(by: { $0.x < $1.x }) {
            result.append(left)
        }
        if let right = points.max(by: { $0.x < $1.x }), !result.contains(right) {
            result.append(right)
        }
        if let top = points.min(by: { $0.y < $1.y }), !result.contains(top) {
            result.append(top)
        }
        if let bottom = points.max(by: { $0.y < $1.y }), !result.contains(bottom) {
            result.append(bottom)
        }
        if result.count < 4 {
            result.append(contentsOf: points.filter { !result.contains($0) }.prefix(4 - result.count))
        }
        return result
    }

    private func move(_ point: SIMD2<Float>, awayFrom center: SIMD2<Float>, by amount: Float) -> SIMD2<Float> {
        let vector = point - center
        let length = LandmarkGeometryHelper.distance(point, center)
        guard length > displacementThreshold else {
            return point
        }
        return point + vector / length * amount
    }

    private func move(_ point: SIMD2<Float>, toward center: SIMD2<Float>, by amount: Float) -> SIMD2<Float> {
        let vector = center - point
        let length = LandmarkGeometryHelper.distance(point, center)
        guard length > displacementThreshold else {
            return point
        }
        return point + vector / length * amount
    }

    private func makePoints(
        sources: [SIMD2<Float>],
        targets: [SIMD2<Float>],
        bounds: FaceBounds,
        radius: Float,
        strength: Float
    ) -> [WarpControlPoint] {
        guard !sources.isEmpty,
              sources.count == targets.count,
              radius.isFinite,
              radius > 0,
              strength.isFinite,
              strength > Float.ulpOfOne,
              sources.allSatisfy({ isValidSupportPoint($0, in: bounds) }),
              targets.allSatisfy({ isValidSupportPoint($0, in: bounds) }),
              zip(sources, targets).allSatisfy({ source, target in
                  LandmarkGeometryHelper.distance(source, target).isFinite &&
                      LandmarkGeometryHelper.distance(source, target) > displacementThreshold
              })
        else {
            return []
        }

        return zip(sources, targets).map { source, target in
            WarpControlPoint(
                source: LandmarkGeometryHelper.clamp(source),
                target: LandmarkGeometryHelper.clamp(target),
                radius: min(max(radius, 0.035), 0.20),
                strength: strength,
                falloff: 2
            )
        }
    }
}
