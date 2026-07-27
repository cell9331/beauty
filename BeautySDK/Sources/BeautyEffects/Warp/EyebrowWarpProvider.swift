import Foundation
import BeautyDetection

struct EyebrowWarpFieldEmissions: Equatable, Sendable {
    let eyebrowYPosition: [WarpControlPoint]
    let eyebrowThickness: [WarpControlPoint]
    let eyebrowLength: [WarpControlPoint]
    let eyebrowSpacing: [WarpControlPoint]
    let eyebrowHeadSpacing: [WarpControlPoint]
    let eyebrowTilt: [WarpControlPoint]
    let eyebrowPeakDefinition: [WarpControlPoint]

    var points: [WarpControlPoint] {
        eyebrowYPosition + eyebrowThickness + eyebrowLength + eyebrowSpacing +
            eyebrowHeadSpacing + eyebrowTilt + eyebrowPeakDefinition
    }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.eyebrowYPosition != 0, eyebrowYPosition.isEmpty { sanitized.eyebrowYPosition = 0 }
        if strengths.eyebrowThickness != 0, eyebrowThickness.isEmpty { sanitized.eyebrowThickness = 0 }
        if strengths.eyebrowLength != 0, eyebrowLength.isEmpty { sanitized.eyebrowLength = 0 }
        if strengths.eyebrowSpacing != 0, eyebrowSpacing.isEmpty { sanitized.eyebrowSpacing = 0 }
        if strengths.eyebrowHeadSpacing != 0, eyebrowHeadSpacing.isEmpty { sanitized.eyebrowHeadSpacing = 0 }
        if strengths.eyebrowTilt != 0, eyebrowTilt.isEmpty { sanitized.eyebrowTilt = 0 }
        if strengths.eyebrowPeakDefinition != 0, eyebrowPeakDefinition.isEmpty { sanitized.eyebrowPeakDefinition = 0 }
        return sanitized
    }
}

struct EyebrowWarpProvider: WarpControlPointProvider {
    private let strengthDeadZone = Float.ulpOfOne
    private let geometryEpsilon: Float = 0.000_001

    func makeControlPoints(face: FaceGeometry, strengths: BeautyEffectiveStrengths) -> WarpControlPointResult {
        let emissions = fieldEmissions(face: face, strengths: strengths)
        let requestedWork = [
            strengths.eyebrowYPosition, strengths.eyebrowThickness, strengths.eyebrowLength,
            strengths.eyebrowSpacing, strengths.eyebrowHeadSpacing, strengths.eyebrowTilt,
            strengths.eyebrowPeakDefinition,
        ].contains { $0.isFinite && abs($0) > Float.ulpOfOne }
        return WarpControlPointResult(
            points: emissions.points,
            skipReason: requestedWork && emissions.points.isEmpty ? "eyebrow_inputs_missing" : nil
        )
    }

    func fieldEmissions(face: FaceGeometry, strengths: BeautyEffectiveStrengths) -> EyebrowWarpFieldEmissions {
        let traces = semanticTraces(in: face)
        let yPositionCap = BeautySafetyCaps.eyebrowYPosition
        let thicknessCap = BeautySafetyCaps.eyebrowThickness
        let lengthCap = BeautySafetyCaps.eyebrowLength
        let spacingCap = BeautySafetyCaps.eyebrowSpacing
        let headSpacingCap = BeautySafetyCaps.eyebrowHeadSpacing
        let tiltCap = BeautySafetyCaps.eyebrowTilt
        let peakDefinitionCap = BeautySafetyCaps.eyebrowPeakDefinition
        return EyebrowWarpFieldEmissions(
            eyebrowYPosition: isSignedWork(strengths.eyebrowYPosition, maximum: yPositionCap)
                ? traces.flatMap { verticalPoints(trace: $0, face: face, strength: strengths.eyebrowYPosition, maximum: yPositionCap) } : [],
            eyebrowThickness: isSignedWork(strengths.eyebrowThickness, maximum: thicknessCap)
                ? traces.flatMap { thicknessPoints(trace: $0, face: face, strength: strengths.eyebrowThickness, maximum: thicknessCap) } : [],
            eyebrowLength: isSignedWork(strengths.eyebrowLength, maximum: lengthCap)
                ? traces.flatMap { lengthPoints(trace: $0, face: face, strength: strengths.eyebrowLength, maximum: lengthCap) } : [],
            eyebrowSpacing: isSignedWork(strengths.eyebrowSpacing, maximum: spacingCap)
                ? spacingPoints(face: face, strength: strengths.eyebrowSpacing, maximum: spacingCap) : [],
            eyebrowHeadSpacing: isSignedWork(strengths.eyebrowHeadSpacing, maximum: headSpacingCap)
                ? traces.flatMap { headSpacingPoints(trace: $0, face: face, strength: strengths.eyebrowHeadSpacing, maximum: headSpacingCap) } : [],
            eyebrowTilt: isSignedWork(strengths.eyebrowTilt, maximum: tiltCap)
                ? traces.flatMap { tiltPoints(trace: $0, face: face, strength: strengths.eyebrowTilt, maximum: tiltCap) } : [],
            eyebrowPeakDefinition: strengths.eyebrowPeakDefinition.isFinite &&
                strengths.eyebrowPeakDefinition > strengthDeadZone &&
                strengths.eyebrowPeakDefinition <= peakDefinitionCap
                ? traces.flatMap { peakPoints(trace: $0, face: face, strength: strengths.eyebrowPeakDefinition, maximum: peakDefinitionCap) } : []
        )
    }

    private func semanticTraces(in face: FaceGeometry) -> [BeautyEyebrowSemanticTrace] {
        guard let support = face.observedEyebrowSupport else { return [] }
        return [support.left, support.right].compactMap { $0 }
    }

    private func verticalPoints(
        trace: BeautyEyebrowSemanticTrace,
        face: FaceGeometry,
        strength: Float,
        maximum: Float
    ) -> [WarpControlPoint] {
        guard validFace(face), validTrace(trace) else { return [] }
        let displacement = face.bounds.height * 0.025 * strength / maximum
        guard displacement.isFinite, displacement != 0 else { return [] }
        let targets = trace.points.map { SIMD2<Float>($0.x, $0.y + displacement) }
        return makePoints(
            sources: trace.points, targets: targets, radius: face.bounds.width * 0.08,
            strength: abs(strength), maximumStrength: maximum
        )
    }

    private func thicknessPoints(
        trace: BeautyEyebrowSemanticTrace,
        face: FaceGeometry,
        strength: Float,
        maximum: Float
    ) -> [WarpControlPoint] {
        guard validFace(face), validTrace(trace), trace.points.count >= 2 else { return [] }
        let baseOffset = face.bounds.height * 0.012
        let change = face.bounds.height * 0.006 * strength / maximum
        let targetOffset = baseOffset + change
        guard baseOffset.isFinite, targetOffset.isFinite,
              baseOffset > geometryEpsilon, targetOffset > geometryEpsilon, change != 0 else { return [] }

        var sources: [SIMD2<Float>] = []
        var targets: [SIMD2<Float>] = []
        for index in trace.points.indices {
            let previous = trace.points[index == trace.points.startIndex ? index : trace.points.index(before: index)]
            let next = trace.points[index == trace.points.index(before: trace.points.endIndex) ? index : trace.points.index(after: index)]
            guard let tangent = normalized(next - previous) else { continue }
            let normal = SIMD2<Float>(-tangent.y, tangent.x)
            let center = trace.points[index]
            sources.append(center + normal * baseOffset)
            targets.append(center + normal * targetOffset)
            sources.append(center - normal * baseOffset)
            targets.append(center - normal * targetOffset)
        }
        return makePoints(
            sources: sources, targets: targets, radius: face.bounds.width * 0.055,
            strength: abs(strength), maximumStrength: maximum
        )
    }

    private func lengthPoints(
        trace: BeautyEyebrowSemanticTrace,
        face: FaceGeometry,
        strength: Float,
        maximum: Float
    ) -> [WarpControlPoint] {
        guard validFace(face), validTrace(trace), trace.points.count >= 2,
              let axis = normalized(trace.outerEndpoint - trace.innerEndpoint)
        else { return [] }
        let displacement = face.bounds.width * 0.025 * strength / maximum
        guard displacement.isFinite, displacement != 0 else { return [] }
        let sources = [trace.points[trace.points.count - 2], trace.outerEndpoint]
        let targets = [sources[0] + axis * displacement * 0.5, sources[1] + axis * displacement]
        return makePoints(
            sources: sources, targets: targets, radius: face.bounds.width * 0.07,
            strength: abs(strength), maximumStrength: maximum
        )
    }

    private func spacingPoints(face: FaceGeometry, strength: Float, maximum: Float) -> [WarpControlPoint] {
        guard validFace(face), let support = face.observedEyebrowSupport,
              support.pairedEligible, let left = support.left, let right = support.right,
              left.side == .left, right.side == .right,
              validTrace(left), validTrace(right), let axis = normalized(right.center - left.center)
        else { return [] }
        let displacement = face.bounds.width * 0.025 * strength / maximum
        guard displacement.isFinite, displacement != 0 else { return [] }
        let sources = left.points + right.points
        let targets = left.points.map { $0 - axis * displacement } +
            right.points.map { $0 + axis * displacement }
        return makePoints(
            sources: sources, targets: targets, radius: face.bounds.width * 0.08,
            strength: abs(strength), maximumStrength: maximum
        )
    }

    private func headSpacingPoints(
        trace: BeautyEyebrowSemanticTrace,
        face: FaceGeometry,
        strength: Float,
        maximum: Float
    ) -> [WarpControlPoint] {
        guard validFace(face), validTrace(trace), trace.points.count >= 2,
              let axis = normalized(trace.outerEndpoint - trace.innerEndpoint)
        else { return [] }
        let displacement = face.bounds.width * 0.020 * strength / maximum
        guard displacement.isFinite, displacement != 0 else { return [] }
        let sources = [trace.innerEndpoint, trace.points[1]]
        let targets = [sources[0] + axis * displacement, sources[1] + axis * displacement * 0.5]
        return makePoints(
            sources: sources, targets: targets, radius: face.bounds.width * 0.06,
            strength: abs(strength), maximumStrength: maximum
        )
    }

    private func tiltPoints(
        trace: BeautyEyebrowSemanticTrace,
        face: FaceGeometry,
        strength: Float,
        maximum: Float
    ) -> [WarpControlPoint] {
        guard validFace(face), validTrace(trace),
              let axis = normalized(trace.outerEndpoint - trace.innerEndpoint)
        else { return [] }
        let orientation: Float = axis.x >= 0 ? -1 : 1
        let angle = orientation * 0.12 * strength / maximum
        guard angle.isFinite, angle != 0 else { return [] }
        let cosine = cos(angle)
        let sine = sin(angle)
        let samples = trace.points.filter { vectorLength($0 - trace.center) > geometryEpsilon }
        let targets = samples.map { point -> SIMD2<Float> in
            let offset = point - trace.center
            return trace.center + SIMD2<Float>(
                offset.x * cosine - offset.y * sine,
                offset.x * sine + offset.y * cosine
            )
        }
        return makePoints(
            sources: samples, targets: targets, radius: face.bounds.width * 0.075,
            strength: abs(strength), maximumStrength: maximum
        )
    }

    private func peakPoints(
        trace: BeautyEyebrowSemanticTrace,
        face: FaceGeometry,
        strength: Float,
        maximum: Float
    ) -> [WarpControlPoint] {
        guard validFace(face), validTrace(trace), strength <= maximum,
              let apexIndex = trace.apexIndex,
              apexIndex > trace.points.startIndex,
              apexIndex < trace.points.index(before: trace.points.endIndex),
              let chordAxis = normalized(trace.outerEndpoint - trace.innerEndpoint)
        else { return [] }
        let apex = trace.points[apexIndex]
        let fromInner = apex - trace.innerEndpoint
        let projection = trace.innerEndpoint + chordAxis * dot(fromInner, chordAxis)
        guard let normal = normalized(apex - projection) else { return [] }
        let displacement = face.bounds.height * 0.012 * strength / maximum
        guard displacement.isFinite, displacement > 0 else { return [] }
        let indices = [apexIndex - 1, apexIndex, apexIndex + 1]
        let weights: [Float] = [0.5, 1, 0.5]
        let sources = indices.map { trace.points[$0] }
        let targets = zip(sources, weights).map { $0.0 + normal * displacement * $0.1 }
        return makePoints(
            sources: sources, targets: targets, radius: face.bounds.width * 0.055,
            strength: strength, maximumStrength: maximum
        )
    }

    private func makePoints(
        sources: [SIMD2<Float>],
        targets: [SIMD2<Float>],
        radius: Float,
        strength: Float,
        maximumStrength: Float
    ) -> [WarpControlPoint] {
        guard sources.count == targets.count, !sources.isEmpty,
              radius.isFinite, radius > geometryEpsilon, radius <= 1,
              strength.isFinite, strength > strengthDeadZone, strength <= maximumStrength,
              sources.indices.allSatisfy({
                  isUnitPoint(sources[$0]) && isUnitPoint(targets[$0])
              })
        else { return [] }
        let representablePairs = zip(sources, targets).filter { pair in pair.0 != pair.1 }
        guard !representablePairs.isEmpty else { return [] }
        return representablePairs.map {
            WarpControlPoint(source: $0.0, target: $0.1, radius: radius, strength: strength, falloff: 2)
        }
    }

    private func validFace(_ face: FaceGeometry) -> Bool {
        face.bounds.x.isFinite && face.bounds.y.isFinite &&
            face.bounds.width.isFinite && face.bounds.height.isFinite &&
            face.bounds.width > geometryEpsilon && face.bounds.height > geometryEpsilon &&
            (0...1).contains(face.bounds.minX) && (0...1).contains(face.bounds.minY) &&
            (0...1).contains(face.bounds.maxX) && (0...1).contains(face.bounds.maxY)
    }

    private func validTrace(_ trace: BeautyEyebrowSemanticTrace) -> Bool {
        (4...16).contains(trace.points.count) && trace.points.allSatisfy(isUnitPoint) &&
            trace.points.first == trace.innerEndpoint && trace.points.last == trace.outerEndpoint &&
            isUnitPoint(trace.innerEndpoint) && isUnitPoint(trace.outerEndpoint) && isUnitPoint(trace.center)
    }

    private func normalized(_ vector: SIMD2<Float>) -> SIMD2<Float>? {
        let length = vectorLength(vector)
        guard length.isFinite, length > geometryEpsilon else { return nil }
        let result = vector / length
        return result.x.isFinite && result.y.isFinite ? result : nil
    }

    private func vectorLength(_ vector: SIMD2<Float>) -> Float {
        sqrt(vector.x * vector.x + vector.y * vector.y)
    }

    private func dot(_ lhs: SIMD2<Float>, _ rhs: SIMD2<Float>) -> Float {
        lhs.x * rhs.x + lhs.y * rhs.y
    }

    private func isUnitPoint(_ point: SIMD2<Float>) -> Bool {
        point.x.isFinite && point.y.isFinite && (0...1).contains(point.x) && (0...1).contains(point.y)
    }

    private func isSignedWork(_ strength: Float, maximum: Float) -> Bool {
        strength.isFinite && abs(strength) > strengthDeadZone && abs(strength) <= maximum
    }
}
