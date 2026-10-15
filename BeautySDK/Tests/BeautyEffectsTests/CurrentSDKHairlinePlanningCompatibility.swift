import BeautyDetection
import Foundation
@testable import BeautyEffects

// Selected original-SDK test target only. This diagnostic predicate is not a
// production planner hook, does not change emissions, and is not compiled into
// BeautyEffects. The research worktree already owns its production definition;
// do not add this file to that target or it would be a duplicate declaration.
extension FaceShapeWarpProvider {
    static func hasSourceHairlineGeometry(face: FaceGeometry, strength: Float) -> Bool {
        func unit(_ point: SIMD2<Float>) -> Bool {
            point.x.isFinite && point.y.isFinite &&
                (0...1).contains(point.x) && (0...1).contains(point.y)
        }
        func brow(_ trace: BeautyEyebrowSemanticTrace) -> Bool {
            guard trace.points.count >= 2, trace.points.allSatisfy(unit),
                  unit(trace.innerEndpoint), unit(trace.outerEndpoint), unit(trace.center),
                  trace.innerEndpoint != trace.outerEndpoint,
                  let first = trace.points.first,
                  trace.points.contains(where: { $0 != first }) else { return false }
            return trace.apexIndex.map { trace.points.indices.contains($0) } ?? true
        }
        let bounds = face.bounds
        guard strength.isFinite, abs(strength) > Float.ulpOfOne,
              abs(strength) <= BeautySafetyCaps.hairlineHeight,
              face.freshness == .fresh, bounds.width > 0, bounds.height > 0,
              [bounds.minX, bounds.maxX, bounds.minY, bounds.maxY].allSatisfy({
                  $0.isFinite && (0...1).contains($0)
              }),
              face.faceContour.count >= 6, face.faceContour.allSatisfy(unit),
              let minX = face.faceContour.map(\.x).min(),
              let maxX = face.faceContour.map(\.x).max(),
              let minY = face.faceContour.map(\.y).min(),
              let maxY = face.faceContour.map(\.y).max(), maxX > minX, maxY > minY,
              let support = face.observedEyebrowSupport,
              let left = support.left, let right = support.right,
              left.side == .left, right.side == .right, brow(left), brow(right)
        else { return false }
        return true
    }
}
