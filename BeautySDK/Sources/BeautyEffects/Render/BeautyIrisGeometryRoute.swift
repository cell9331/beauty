import BeautyCore
import BeautyDetection
import Foundation

/// Explicit package research route. The public pupil-size contract keeps its
/// legacy response until a production neutral and support are established.
package enum BeautyIrisGeometryRoute: Sendable {
    case legacy
    case calibrated(BeautyIrisFollowingRequest)

    /// A positive whitelist: any future/non-whitelisted strength must still be
    /// zero. No geometry or source refiner can silently join this first slice.
    static func permitsIsolatedGeometry(_ strengths: BeautyEffectiveStrengths) -> Bool {
        var allowed = BeautyEffectiveStrengths()
        allowed.pupilSize = strengths.pupilSize
        allowed.skinSmoothing = strengths.skinSmoothing
        allowed.skinWhitening = strengths.skinWhitening
        allowed.skinRosy = strengths.skinRosy
        allowed.skinSharpen = strengths.skinSharpen
        allowed.brightness = strengths.brightness
        allowed.contrast = strengths.contrast
        allowed.saturation = strengths.saturation
        allowed.temperature = strengths.temperature
        allowed.tint = strengths.tint
        allowed.exposure = strengths.exposure
        allowed.highlight = strengths.highlight
        allowed.shadow = strengths.shadow
        allowed.filterIntensity = strengths.filterIntensity
        allowed.lipColor = strengths.lipColor
        return strengths == allowed
    }

    static func hasSourcePrefixEffects(_ strengths: BeautyEffectiveStrengths) -> Bool {
        var irisOnly = BeautyEffectiveStrengths()
        irisOnly.pupilSize = strengths.pupilSize
        return strengths != irisOnly
    }

    /// Existing validated observations only qualify a side; they do not supply
    /// the unknown calibrated center, envelope, gain, or endpoint response.
    static func availableObservedSides(_ face: FaceGeometry?, width: Int, height: Int) -> Set<BeautyIrisFollowingSide> {
        guard let face, face.freshness == .fresh, width > 1, height > 1 else { return [] }
        func adequate(_ support: BeautyEyeSemanticSupport?, side: BeautyObservedEyeSide) -> Bool {
            func valid(_ point: SIMD2<Float>) -> Bool {
                point.x.isFinite && point.y.isFinite &&
                    (0...1).contains(point.x) && (0...1).contains(point.y)
            }
            func pixel(_ point: SIMD2<Float>) -> SIMD2<Double> {
                SIMD2(Double(point.x) * Double(width), Double(point.y) * Double(height))
            }
            guard let support, support.side == side,
                  (BeautyFaceGeometryAdapter.minimumContourPointCount...BeautyFaceGeometryAdapter.maximumContourPointCount)
                    .contains(support.contour.count),
                  support.contour.allSatisfy(valid), valid(support.center),
                  BeautyDenseFaceSupport.simplePolygon(support.contour),
                  face.bounds.width > 0, face.bounds.height > 0,
                  let minX = support.contour.map(\.x).min(), let maxX = support.contour.map(\.x).max(),
                  let minY = support.contour.map(\.y).min(), let maxY = support.contour.map(\.y).max(),
                  BeautyFaceGeometryAdapter.contourWidthIsValid((maxX - minX) / face.bounds.width),
                  BeautyFaceGeometryAdapter.contourHeightIsValid((maxY - minY) / face.bounds.height),
                  BeautyFaceGeometryAdapter.contourAreaIsValid(
                    (maxX - minX) / face.bounds.width * (maxY - minY) / face.bounds.height),
                  // A trace must contain an actual segment; duplicated or
                  // absent lid samples cannot qualify a visible eye side.
                  Set(support.upper).count >= 2, Set(support.lower).count >= 2,
                  support.upper.allSatisfy({ valid($0) && support.contour.contains($0) }),
                  support.lower.allSatisfy({ valid($0) && support.contour.contains($0) }),
                  let inner = support.inner.first, let outer = support.outer.first,
                  valid(inner), valid(outer)
            else { return false }
            // Reuse the existing continuous-eye/legacy iris admission budget;
            // these are visibility/degeneracy checks, not fitted effect gains.
            let a = pixel(inner), b = pixel(outer), midpoint = (a + b) * 0.5
            var axis = b - a
            if axis.x < 0 { axis = -axis }
            let span = hypot(axis.x, axis.y)
            guard span >= 6, span < Double(min(width, height)) * 0.45,
                  axis.x > span * 0.40 else { return false }
            let normal = SIMD2(-axis.y / span, axis.x / span)
            let heights = support.contour.map { point -> Double in
                let offset = pixel(point) - midpoint
                return offset.x * normal.x + offset.y * normal.y
            }
            guard let top = heights.min(), let bottom = heights.max(),
                  top < -0.5, bottom > 0.5,
                  bottom - top >= span * 0.08, bottom - top <= span * 0.85 else { return false }
            return true
        }
        var result = Set<BeautyIrisFollowingSide>()
        if adequate(face.leftEyeSupport, side: .left) { result.insert(.left) }
        if adequate(face.rightEyeSupport, side: .right) { result.insert(.right) }
        return result
    }

    static func refusal(_ request: BeautyIrisFollowingRequest, sourceRGBA: [UInt8],
                        reason: BeautyIrisFollowingRefusalReason) -> BeautyIrisFollowingResult {
        let count = max(1, request.eyes.count)
        return BeautyIrisFollowingResult(rgba: sourceRGBA, status: .refused,
            appliedEyeCount: 0, refusedEyeCount: count, refusalCounts: [reason: count])
    }
}
