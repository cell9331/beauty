import Foundation
import XCTest
import BeautyCore
@testable import BeautyEffects

final class MouthNegativeFieldTests: XCTestCase {
    private typealias V = SIMD2<Float>
    private let provider = MouthWarpProvider()
    private func check(_ value: Bool, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(value, "P94N_STAGE_METRIC", file: file, line: line)
    }
    private func face(outer: [V]? = nil, inner: [V]? = nil, bounds: FaceBounds? = nil,
                      freshness: LandmarkGeometryFreshness = .fresh) -> FaceGeometry {
        let f = FaceGeometry.fixture
        return FaceGeometry(bounds: bounds ?? f.bounds, faceContour: f.faceContour,
                            observedFaceSupport: f.observedFaceSupport, leftEye: f.leftEye, rightEye: f.rightEye,
                            nose: f.nose, noseRoot: f.noseRoot, noseTip: f.noseTip,
                            outerLips: outer ?? f.outerLips, upperLips: f.upperLips, lowerLips: f.lowerLips,
                            innerLips: inner ?? f.innerLips, leftEyeSupport: f.leftEyeSupport,
                            rightEyeSupport: f.rightEyeSupport, freshness: freshness,
                            observedEyebrowSupport: f.observedEyebrowSupport)
    }
    private func strengths(_ width: Float) -> BeautyEffectiveStrengths {
        var s = BeautyEffectiveStrengths(); s.mouthWidth = width; return s
    }
    private func points(_ width: Float, face: FaceGeometry = .fixture) -> [WarpControlPoint] {
        provider.fieldEmissions(face: face, strengths: strengths(width)).mouthWidth
    }
    private func admitted(_ p: WarpControlPoint) -> Bool {
        let d = p.target - p.source
        return p.radius > 0.0001 && abs(d.x) + abs(d.y) > 0.0001
    }
    private func scales(_ actual: [WarpControlPoint], _ full: [WarpControlPoint], _ factor: Float) -> Bool {
        guard actual.count == 2 && full.count == 2 else { return false }
        for (p, cap) in zip(actual, full) {
            let d = p.target.x - p.source.x
            let expected = (cap.target.x - cap.source.x) * factor
            let ulp = max(max(p.target.x.ulp, p.source.x.ulp), max(cap.target.x.ulp, expected.ulp))
            if p.source != cap.source || p.radius != cap.radius || p.target.y != p.source.y
                || abs(d - expected) > 8 * ulp || p.falloff != 2 { return false }
        }
        return true
    }

    func testFinalFloatScalingAndRendererCutoff() {
        let full = points(-0.35)
        check(full.count == 2 && full.allSatisfy(admitted))
        for factor: Float in [0.25,0.5,1] {
            check(scales(points(-0.35 * factor), full, factor))
        }
        for sign: Float in [-1,1] {
            let cap = BeautyEffectResolver.resolve(parameters: .init(mouthWidth: sign * 0.35), faceGeometry: .fixture)
            let overflow = BeautyEffectResolver.resolve(parameters: .init(mouthWidth: sign), faceGeometry: .fixture)
            check(cap.effectiveStrengths.mouthWidth == sign * 0.35)
            check(cap.effectiveStrengths.mouthWidth == overflow.effectiveStrengths.mouthWidth)
            check(provider.fieldEmissions(face: .fixture, strengths: cap.effectiveStrengths)
                  == provider.fieldEmissions(face: .fixture, strengths: overflow.effectiveStrengths))
        }
        // Zero source makes the final Float L1 exactly representable at the
        // cutoff; do not confuse requested displacement with target subtraction.
        let cut = Float(0.0001)
        for d in [cut.nextDown,cut,cut.nextUp] {
            let p = WarpControlPoint(source: V(0,0), target: V(d,0), radius: 0.1, strength: 0.35, falloff: 2)
            check(admitted(p) == (d > cut))
        }
        for r in [cut.nextDown,cut,cut.nextUp] {
            let p = WarpControlPoint(source: V(0,0), target: V(0.01,0), radius: r, strength: 0.35, falloff: 2)
            check(admitted(p) == (r > cut))
        }
        // Tiny emitted fields may be discarded by the renderer. Sanitation
        // follows provider emission, not a newly imposed tiny public policy.
        for value: Float in [-Float.ulpOfOne * 2, -0.00001, -0.0001, -0.001] {
            let requested = strengths(value)
            let emitted = provider.fieldEmissions(face: .fixture, strengths: requested)
            check(emitted.mouthWidth.isEmpty || emitted.mouthWidth.count == 2)
            check(emitted.sanitizing(requested).mouthWidth == (emitted.mouthWidth.isEmpty ? 0 : value))
            check(finiteSamples(emitted.mouthWidth))
        }
    }

    func testMalformedSupportAndSiblingIsolation() {
        let original = FaceGeometry.fixture
        let valid = points(-0.35)
        check(!valid.isEmpty)
        check(points(-0.35, face: face(inner: [])) == valid)
        let support = original.outerLips
        guard support.count >= 4 else { check(false); return }
        var bad: [[V]] = [[], [V(0.5,0.65)], [V(0.5,0.65),V(0.5,0.65)]]
        // Full valid cardinality ensures each corruption reaches coordinate,
        // containment or uniqueness admission rather than the minimum count.
        for replacement in [V(.nan,support[0].y), V(.infinity,support[0].y),
                            V(-0.1,support[0].y), V(1.1,support[0].y),
                            V(original.bounds.minX - 0.01,support[0].y), support[1]] {
            var damaged = support
            damaged[0] = replacement
            bad.append(damaged)
        }
        // Four distinct in-bounds points isolate each required axis span.
        let fractions: [Float] = [0.35,0.45,0.55,0.65]
        bad.append(fractions.map { V(original.bounds.midX, original.bounds.minY + original.bounds.height * $0) })
        bad.append(fractions.map { V(original.bounds.minX + original.bounds.width * $0, original.bounds.midY) })
        for outer in bad {
            let f = face(outer: outer)
            var s = strengths(-0.35); s.lipPlump = 0.1; s.noseSlim = 0.1
            let emitted = provider.fieldEmissions(face: f, strengths: s)
            let retained = provider.fieldEmissions(face: f, strengths: {
                var sibling = s; sibling.mouthWidth = 0; return sibling
            }())
            check(emitted.mouthWidth.isEmpty && emitted.sanitizing(s).mouthWidth == 0)
            check(!emitted.lipPlump.isEmpty && emitted.lipPlump == retained.lipPlump)
            check(NoseWarpProvider().fieldEmissions(face: f, strengths: s)
                  == NoseWarpProvider().fieldEmissions(face: .fixture, strengths: s))
        }
        let bounds = [FaceBounds(x: 0.1,y: 0.1,width: 0,height: 0.8),
                      FaceBounds(x: 0.1,y: 0.1,width: -0.8,height: 0.8),
                      FaceBounds(x: 0.1,y: 0.1,width: 0.8,height: 0),
                      FaceBounds(x: 0.1,y: 0.1,width: 0.8,height: -0.8),
                      FaceBounds(x: .nan,y: 0.1,width: 0.8,height: 0.8),
                      FaceBounds(x: 0.1,y: .infinity,width: 0.8,height: 0.8),
                      FaceBounds(x: 0.1,y: 0.1,width: .infinity,height: 0.8),
                      FaceBounds(x: -0.2,y: 0.1,width: 1.1,height: 0.8),
                      FaceBounds(x: 0.1,y: 0.1,width: 1.1,height: 0.8)]
        for b in bounds { check(points(-0.35, face: face(bounds: b)).isEmpty) }
    }

    func testActualNegativeMapAndOverlapSafety() {
        var octagon: [V] = []
        for i in 0..<8 {
            let angle = Double(i) * Double.pi / 4
            octagon.append(V(0.50 + 0.02 * Float(cos(angle)), 0.65 + 0.02 * Float(sin(angle))))
        }
        let narrow = face(outer: octagon, bounds: FaceBounds(x: 0.10,y: 0.10,width: 0.80,height: 0.80))
        var crossing = false
        var reversal = false
        for f in [FaceGeometry.fixture, narrow] {
            let p = points(-0.35, face: f)
            guard p.count == 2 else { check(false); continue }
            check(p.allSatisfy(admitted))
            check(p[0].source.x < p[1].source.x)
            check(p[0].target.x > p[0].source.x && p[1].target.x < p[1].source.x)
            check(p.allSatisfy { $0.target.y == $0.source.y })
            crossing = p[0].target.x >= p[1].target.x || crossing
            check(finiteSamples(p))
            if sufficientBound(p) >= 1 { print("P94N_BOUND_INCONCLUSIVE") }
            let extent = union(p)
            for row in 0...32 {
                var previous: V?
                for column in 0...128 {
                    let q = V(extent.0.x + (extent.1.x - extent.0.x) * Float(column) / 128,
                              extent.0.y + (extent.1.y - extent.0.y) * Float(row) / 32)
                    let mapped = sample(q,p)
                    if let old = previous, interior(mapped) && interior(old), mapped.x < old.x { reversal = true }
                    previous = mapped
                }
            }
            let center = (p[0].source + p[1].source) / 2
            let h = min(p[0].radius,p[1].radius) / 1024
            let left = sample(center - V(h,0),p), right = sample(center + V(h,0),p)
            let upper = sample(center - V(0,h),p), lower = sample(center + V(0,h),p)
            let dx = (right-left)/(2*h), dy = (lower-upper)/(2*h)
            let determinant = dx.x*dy.y-dx.y*dy.x
            check(determinant.isFinite)
            if interior(left) && interior(right) && interior(upper) && interior(lower) && determinant < 0 { reversal = true }
        }
        // One assertion per semantic class, after both actual support cases.
        XCTAssertFalse(crossing, "P94N_FIELD_CROSSING")
        XCTAssertFalse(reversal, "P94N_FIELD_INTERIOR_REVERSAL")
    }

    func testReuseConflictAndRetainedEmissions() {
        let cap = points(-0.35)
        for (freshness,factor): (LandmarkGeometryFreshness,Float) in [(.fresh,1),(.reused,0.5),(.stale,0)] {
            let f = face(freshness: freshness)
            let plan = BeautyEffectResolver.resolve(parameters: .init(mouthWidth: -1), faceGeometry: f)
            let emitted = provider.fieldEmissions(face: f, strengths: plan.effectiveStrengths)
            if factor == 0 { check(emitted.mouthWidth.isEmpty && plan.effectiveStrengths.mouthWidth == 0) }
            else { check(scales(emitted.mouthWidth,cap,factor)) }
            check(emitted.sanitizing(plan.effectiveStrengths) == plan.effectiveStrengths)
        }
        for sibling in 0..<3 {
            var request = BeautyParameters(mouthWidth: -0.35)
            if sibling == 0 { request.mouthSize = 0.10 }
            if sibling == 1 { request.smile = 0.10 }
            if sibling == 2 { request.noseSlim = 0.10 }
            let resolved = BeautyEffectResolver.resolve(parameters: request, faceGeometry: .fixture)
            let effective = resolved.effectiveStrengths
            var without = effective; without.mouthWidth = 0
            let combined = provider.fieldEmissions(face: .fixture, strengths: effective)
            let retained = provider.fieldEmissions(face: .fixture, strengths: without)
            check(combined.mouthSize == retained.mouthSize && combined.smile == retained.smile)
            check(combined.mouthYPosition == retained.mouthYPosition && combined.mouthTilt == retained.mouthTilt)
            check(combined.mouthXPosition == retained.mouthXPosition
                  && combined.lipPeakDefinition == retained.lipPeakDefinition && combined.lipPlump == retained.lipPlump)
            let nose = NoseWarpProvider().fieldEmissions(face: .fixture, strengths: effective)
            check(nose == NoseWarpProvider().fieldEmissions(face: .fixture, strengths: without))
            let all = combined.points + nose.points
            if sufficientBound(all) >= 1 { print("P94N_BOUND_INCONCLUSIVE") }
            check(finiteSamples(all))
            var positive = effective; positive.mouthWidth = 0.35
            let before = provider.fieldEmissions(face: .fixture, strengths: positive)
            _ = provider.fieldEmissions(face: .fixture, strengths: effective)
            check(provider.fieldEmissions(face: .fixture, strengths: positive) == before)
        }
        var conflict = BeautyParameters(eyeSize: 1, eyeDistance: 1, eyeYPosition: 1, eyeTailLift: 1,
                                        noseSlim: 1, noseWingSlim: 1, noseTipSize: 1, noseBridge: 1,
                                        noseRootNarrowing: 1, noseTipLift: 1)
        for sign: Float in [-1,1] {
            conflict.mouthWidth = sign * Float.ulpOfOne * 2
            check(!points(conflict.mouthWidth).isEmpty)
            let plan = BeautyEffectResolver.resolve(parameters: conflict, faceGeometry: .fixture)
            let emitted = provider.fieldEmissions(face: .fixture, strengths: plan.effectiveStrengths)
            check(plan.effectiveStrengths.mouthWidth == 0 && emitted.mouthWidth.isEmpty)
            check(emitted.sanitizing(plan.effectiveStrengths) == plan.effectiveStrengths)
        }
    }

    // Renderer-equivalent target-centered inverse field, independently written.
    // Keep unclamped values for interior diagnostics, then separately validate
    // the bounded original-buffer sampling coordinate.
    private func sample(_ q: V, _ points: [WarpControlPoint]) -> V {
        var result = q
        for p in points where admitted(p) {
            let offset = q - p.target
            let distance = (offset.x*offset.x + offset.y*offset.y).squareRoot()
            let radius = min(max(p.radius,0.001),1)
            if distance < radius {
                let t = max(0,min(1,1-distance/radius))
                result -= (p.target-p.source)*(t*t)
            }
        }
        return result
    }
    private func interior(_ p: V) -> Bool { p.x > 0 && p.x < 1 && p.y > 0 && p.y < 1 }
    private func union(_ points: [WarpControlPoint]) -> (V,V) {
        var low = V(1,1), high = V(0,0)
        for p in points {
            low.x = min(low.x,min(p.source.x,p.target.x)-p.radius)
            low.y = min(low.y,min(p.source.y,p.target.y)-p.radius)
            high.x = max(high.x,max(p.source.x,p.target.x)+p.radius)
            high.y = max(high.y,max(p.source.y,p.target.y)+p.radius)
        }
        return (low,high)
    }
    private func sufficientBound(_ points: [WarpControlPoint]) -> Double {
        let p = points.filter(admitted)
        var maximum = 0.0
        // For each disk include every disk it intersects; this conservatively
        // bounds every active set, while truly disjoint disks use local bounds.
        for a in p {
            var sum = 0.0
            for b in p {
                let delta = a.target-b.target
                let distance = hypot(Double(delta.x),Double(delta.y))
                if distance <= Double(a.radius+b.radius) {
                    let d = b.target-b.source
                    sum += 2*hypot(Double(d.x),Double(d.y))/Double(min(max(b.radius,0.001),1))
                }
            }
            maximum = max(maximum,sum)
        }
        return maximum
    }
    private func finiteSamples(_ points: [WarpControlPoint]) -> Bool {
        if points.isEmpty { return true }
        for p in points {
            if !p.source.x.isFinite || !p.source.y.isFinite || !p.target.x.isFinite || !p.target.y.isFinite
                || !p.radius.isFinite || p.radius <= 0 { return false }
        }
        let bounds = union(points)
        for y in 0...32 {
            for x in 0...128 {
                let q = V(bounds.0.x+(bounds.1.x-bounds.0.x)*Float(x)/128,
                          bounds.0.y+(bounds.1.y-bounds.0.y)*Float(y)/32)
                let raw = sample(q,points)
                if !raw.x.isFinite || !raw.y.isFinite { return false }
                let clamped = V(min(max(raw.x,0),1),min(max(raw.y,0),1))
                if clamped.x < 0 || clamped.x > 1 || clamped.y < 0 || clamped.y > 1 { return false }
            }
        }
        return true
    }
}
