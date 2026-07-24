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
    private let provisionalCap: Float = 0.25
    private let epsilon: Float = 0.000_001

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
        return EyebrowWarpFieldEmissions(
            eyebrowYPosition: isSignedWork(strengths.eyebrowYPosition)
                ? traces.flatMap { verticalPoints(trace: $0, face: face, strength: strengths.eyebrowYPosition) } : [],
            eyebrowThickness: isSignedWork(strengths.eyebrowThickness)
                ? traces.flatMap { thicknessPoints(trace: $0, face: face, strength: strengths.eyebrowThickness) } : [],
            eyebrowLength: isSignedWork(strengths.eyebrowLength)
                ? traces.flatMap { lengthPoints(trace: $0, face: face, strength: strengths.eyebrowLength) } : [],
            eyebrowSpacing: [],
            eyebrowHeadSpacing: [],
            eyebrowTilt: [],
            eyebrowPeakDefinition: []
        )
    }

    private func semanticTraces(in face: FaceGeometry) -> [BeautyEyebrowSemanticTrace] {
        guard let support = face.observedEyebrowSupport else { return [] }
        return [support.left, support.right].compactMap { $0 }
    }

    private func verticalPoints(
        trace: BeautyEyebrowSemanticTrace,
        face: FaceGeometry,
        strength: Float
    ) -> [WarpControlPoint] {
        guard validFace(face), validTrace(trace) else { return [] }
        let displacement = face.bounds.height * 0.025 * strength / provisionalCap
        guard displacement.isFinite, abs(displacement) > epsilon else { return [] }
        let targets = trace.points.map { SIMD2<Float>($0.x, $0.y + displacement) }
        return makePoints(
            sources: trace.points, targets: targets, radius: face.bounds.width * 0.08,
            strength: abs(strength)
        )
    }

    private func thicknessPoints(
        trace: BeautyEyebrowSemanticTrace,
        face: FaceGeometry,
        strength: Float
    ) -> [WarpControlPoint] {
        guard validFace(face), validTrace(trace), trace.points.count >= 2 else { return [] }
        let baseOffset = face.bounds.height * 0.012
        let change = face.bounds.height * 0.006 * strength / provisionalCap
        let targetOffset = baseOffset + change
        guard baseOffset.isFinite, targetOffset.isFinite, baseOffset > epsilon, targetOffset > epsilon,
              abs(change) > epsilon else { return [] }

        var sources: [SIMD2<Float>] = []
        var targets: [SIMD2<Float>] = []
        for index in trace.points.indices {
            let previous = trace.points[index == trace.points.startIndex ? index : trace.points.index(before: index)]
            let next = trace.points[index == trace.points.index(before: trace.points.endIndex) ? index : trace.points.index(after: index)]
            guard let tangent = normalized(next - previous) else { return [] }
            let normal = SIMD2<Float>(-tangent.y, tangent.x)
            let center = trace.points[index]
            sources.append(center + normal * baseOffset)
            targets.append(center + normal * targetOffset)
            sources.append(center - normal * baseOffset)
            targets.append(center - normal * targetOffset)
        }
        return makePoints(
            sources: sources, targets: targets, radius: face.bounds.width * 0.055,
            strength: abs(strength)
        )
    }

    private func lengthPoints(
        trace: BeautyEyebrowSemanticTrace,
        face: FaceGeometry,
        strength: Float
    ) -> [WarpControlPoint] {
        guard validFace(face), validTrace(trace), trace.points.count >= 2,
              let axis = normalized(trace.outerEndpoint - trace.innerEndpoint)
        else { return [] }
        let displacement = face.bounds.width * 0.025 * strength / provisionalCap
        guard displacement.isFinite, abs(displacement) > epsilon else { return [] }
        let sources = [trace.points[trace.points.count - 2], trace.outerEndpoint]
        let targets = [sources[0] + axis * displacement * 0.5, sources[1] + axis * displacement]
        return makePoints(
            sources: sources, targets: targets, radius: face.bounds.width * 0.07,
            strength: abs(strength)
        )
    }

    private func makePoints(
        sources: [SIMD2<Float>],
        targets: [SIMD2<Float>],
        radius: Float,
        strength: Float
    ) -> [WarpControlPoint] {
        guard sources.count == targets.count, !sources.isEmpty,
              radius.isFinite, radius > epsilon, strength.isFinite, strength > Float.ulpOfOne,
              sources.indices.allSatisfy({
                  isUnitPoint(sources[$0]) && isUnitPoint(targets[$0]) &&
                      vectorLength(targets[$0] - sources[$0]) > epsilon
              })
        else { return [] }
        return zip(sources, targets).map {
            WarpControlPoint(source: $0.0, target: $0.1, radius: radius, strength: strength, falloff: 2)
        }
    }

    private func validFace(_ face: FaceGeometry) -> Bool {
        face.bounds.width.isFinite && face.bounds.height.isFinite &&
            face.bounds.width > epsilon && face.bounds.height > epsilon
    }

    private func validTrace(_ trace: BeautyEyebrowSemanticTrace) -> Bool {
        (4...16).contains(trace.points.count) && trace.points.allSatisfy(isUnitPoint) &&
            isUnitPoint(trace.innerEndpoint) && isUnitPoint(trace.outerEndpoint) && isUnitPoint(trace.center)
    }

    private func normalized(_ vector: SIMD2<Float>) -> SIMD2<Float>? {
        let length = vectorLength(vector)
        guard length.isFinite, length > epsilon else { return nil }
        let result = vector / length
        return result.x.isFinite && result.y.isFinite ? result : nil
    }

    private func vectorLength(_ vector: SIMD2<Float>) -> Float {
        sqrt(vector.x * vector.x + vector.y * vector.y)
    }

    private func isUnitPoint(_ point: SIMD2<Float>) -> Bool {
        point.x.isFinite && point.y.isFinite && (0...1).contains(point.x) && (0...1).contains(point.y)
    }

    private func isSignedWork(_ strength: Float) -> Bool {
        strength.isFinite && abs(strength) > Float.ulpOfOne
    }
}
