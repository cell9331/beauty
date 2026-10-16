import BeautyCore
import BeautyDetection
import Foundation

/// Request-local source measurements. RGB qualifies and locates the core; it
/// never becomes a pixel mask, replacement texture, or deformation strength.
enum BeautyEyebrowSourceGeometry {
    static func frame(face: FaceGeometry, width: Int, height: Int, onFailure: ((String) -> Void)? = nil)
        -> (horizontal: SIMD2<Double>, vertical: SIMD2<Double>, midpoint: SIMD2<Double>)? {
        guard width > 1, height > 1,
              let left = eyeCenter(face.leftEyeSupport?.contour ?? face.leftEye, width: width, height: height),
              let right = eyeCenter(face.rightEyeSupport?.contour ?? face.rightEye, width: width, height: height)
        else { onFailure?("frame_eye_contour"); return nil }
        let difference = right - left, separation = hypot(difference.x, difference.y)
        guard separation > Double(min(width, height)) * 0.04,
              difference.x > separation * 0.35 else { onFailure?("frame_eye_axis"); return nil }
        let horizontal = difference / separation
        return (horizontal, SIMD2(-horizontal.y, horizontal.x), (left + right) * 0.5)
    }

    static func make(width: Int, height: Int, face: FaceGeometry,
        trace: BeautyEyebrowSemanticTrace, sourceRGBA: [UInt8],
        horizontal: SIMD2<Double>, vertical: SIMD2<Double>,
        onFailure: ((String) -> Void)? = nil) -> BeautyEyebrowDisplacementModel.Geometry? {
        func reject(_ reason: String) -> BeautyEyebrowDisplacementModel.Geometry? { onFailure?(reason); return nil }
        guard width > 1, height > 1, width <= Int.max / height / 4,
              sourceRGBA.count == width * height * 4, face.freshness != .stale,
              finite(horizontal), finite(vertical), abs(dot(horizontal, vertical)) < 1e-6,
              abs(dot(horizontal, horizontal) - 1) < 1e-6,
              abs(dot(vertical, vertical) - 1) < 1e-6,
              horizontal.x > 0, vertical.y > 0,
              validTrace(trace, face: face),
              let leftEye = eyeCenter(face.leftEyeSupport?.contour ?? face.leftEye, width: width, height: height),
              let rightEye = eyeCenter(face.rightEyeSupport?.contour ?? face.rightEye, width: width, height: height)
        else { return reject("source_inputs") }
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> {
            SIMD2(Double(p.x) * Double(width) - 0.5, Double(p.y) * Double(height) - 0.5)
        }
        let origin = pixel(trace.innerEndpoint), end = pixel(trace.outerEndpoint)
        let isLeft = trace.side == .left, outward = horizontal * (isLeft ? -1.0 : 1.0)
        let length = dot(end - origin, outward)
        guard length >= 6, length < Double(min(width, height)) * 0.50,
              hypot((end-origin).x, (end-origin).y) <= length * 2 else { return reject("source_axis") }
        let midline = (leftEye + rightEye) * 0.5
        func local(_ p: SIMD2<Float>) -> SIMD2<Double> {
            let d = pixel(p) - origin
            return SIMD2(dot(d, outward), dot(d, vertical))
        }
        let priors: [Prior]
        if let dense = face.denseSupport {
            let indices = isLeft ? MediaPipeFaceTopology.leftBrowEnvelope : MediaPipeFaceTopology.rightBrowEnvelope
            let envelope = BeautyDenseFaceSupport.path(dense.mesh, indices)
            guard validPath(envelope), BeautyDenseFaceSupport.simplePolygon(envelope) else { return reject("dense_envelope_polygon") }
            guard let closedPrior = closedStations(envelope.map(local), length: length, onFailure: onFailure) else { return nil }
            // The mesh trace is the upper anatomical edge, not an independent
            // ridge. Its vertical end edge may legitimately repeat r while the
            // full envelope still has one connected section at every station.
            priors = closedPrior
        } else {
            // Without a closed envelope, the open trace owns the only geometric
            // branch; do not select a replacement from unrelated darker pixels.
            guard let openPrior = openStations(trace.points.map(local), length: length) else { return reject("open_trace_projection") }
            priors = openPrior.map { Prior(center: $0, half: nil) }
        }

        let nose = face.observedNoseSupport.map {
            ($0.crest + $0.contour).map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        } ?? (face.nose + face.noseRoot + face.noseTip)
        let paths = [face.leftEyeSupport?.contour ?? face.leftEye,
            face.rightEyeSupport?.contour ?? face.rightEye, nose, face.observedOuterLips ?? face.outerLips]
        guard paths.allSatisfy(validPath) else { return reject("source_protection_paths") }
        let boxes = paths.compactMap { Box(points: $0.map(pixel), padding: max(1, length * 0.012)) }
        guard boxes.count == paths.count else { return reject("source_protection_boxes") }
        func position(_ r: Double, _ v: Double) -> SIMD2<Double> { origin + outward * r + vertical * v }
        func owned(_ p: SIMD2<Double>) -> Bool {
            let side = dot(p - midline, horizontal)
            return isLeft ? side < 0 : side > 0
        }
        // Pixel centres are integer indices throughout. Every bilinear tap is
        // independently admitted before any RGB, including donor RGB, is read.
        func color(_ p: SIMD2<Double>) -> SIMD3<Double>? {
            guard finite(p), p.x >= 0, p.y >= 0,
                  p.x < Double(width - 1), p.y < Double(height - 1) else { return nil }
            let x = Int(floor(p.x)), y = Int(floor(p.y))
            let taps = [(x,y),(x+1,y),(x,y+1),(x+1,y+1)]
            guard taps.allSatisfy({ xx, yy in
                let point = SIMD2(Double(xx), Double(yy))
                return owned(point) && !boxes.contains(where: { $0.contains(point) }) &&
                    sourceRGBA[(yy * width + xx) * 4 + 3] == 255
            }) else { return nil }
            func rgb(_ x: Int, _ y: Int) -> SIMD3<Double> {
                let index = (y * width + x) * 4
                return SIMD3(Double(sourceRGBA[index]), Double(sourceRGBA[index+1]), Double(sourceRGBA[index+2]))
            }
            let fx = p.x - Double(x), fy = p.y - Double(y)
            let a = rgb(x,y) * (1-fx) + rgb(x+1,y) * fx
            let b = rgb(x,y+1) * (1-fx) + rgb(x+1,y+1) * fx
            return a * (1-fy) + b * fy
        }
        func patch(_ r: Double, _ v: Double) -> SIMD3<Double>? {
            var samples = [SIMD3<Double>]()
            let radius = min(0.75, length * 0.012)
            for dr in [-radius, 0, radius] { for dv in [-radius, 0, radius] {
                if let value = color(position(r+dr, v+dv)) { samples.append(value) }
            } }
            guard samples.count >= 5 else { return nil }
            let median = samples.count / 2
            return SIMD3(samples.map(\.x).sorted()[median], samples.map(\.y).sorted()[median], samples.map(\.z).sorted()[median])
        }
        func donor(_ r: Double, _ center: Double, _ half: Double?, _ sign: Double) -> Donor? {
            let start = max(length * 0.075, (half ?? 0) + length * 0.035)
            let finish = max(start + length * 0.05, length * 0.25)
            guard finish <= length * 0.36 else { return nil }
            var candidates = [Donor]()
            for k in 0...15 {
                let v = center + sign * (start + (finish-start) * Double(k) / 15)
                guard let rgb = patch(r,v), luma(rgb) >= 35,
                      let a = patch(r,v-0.5), let b = patch(r,v+0.5),
                      abs(luma(a)-luma(b)) <= 16 else { continue }
                candidates.append(Donor(v: v, rgb: rgb))
            }
            guard let brightest = candidates.map({ luma($0.rgb) }).max() else { return nil }
            // A nearby bright plateau estimates bare skin; isolated bright
            // hair-edge pixels cannot become a baseline through one sample.
            return candidates.first { luma($0.rgb) >= brightest - 8 }
        }
        var stationFailures = [String: Int]()
        func stationRejected(_ reason: String) -> Measurement? {
            stationFailures[reason, default: 0] += 1
            return nil
        }
        func reportStationFailure() {
            // Only an aggregate category leaves this request. Never report
            // station locations, sampled RGB, profiles, or image identity.
            if let reason = stationFailures.keys.sorted().max(by: { stationFailures[$0, default: 0] < stationFailures[$1, default: 0] }) {
                onFailure?(reason)
            }
        }
        func measure(_ r: Double, _ prior: Prior) -> Measurement? {
            guard let upper = donor(r, prior.center, prior.half, -1) else { return stationRejected("source_upper_skin") }
            guard let lower = donor(r, prior.center, prior.half, 1), lower.v > upper.v else { return stationRejected("source_lower_skin") }
            let radius = min(length * 0.22, max(length * 0.14, (prior.half ?? 0) + length * 0.08))
            let steps = max(40, min(192, Int(ceil(radius * 2 / 0.5))))
            let step = radius * 2 / Double(steps), low = prior.center - radius
            var scores = [Double?](repeating: nil, count: steps+1)
            for k in 0...steps {
                let v = low + Double(k) * step
                guard let rgb = color(position(r,v)) else { continue }
                let t = min(1, max(0, (v-upper.v)/(lower.v-upper.v)))
                let difference = upper.rgb * (1-t) + lower.rgb * t - rgb
                scores[k] = max(0, min(luma(difference), min(difference.x, min(difference.y, difference.z)) * 1.5))
            }
            // Ownership is seeded by this trace, never the peer eyebrow or a
            // distant hair patch. Colour thresholds are confidence gates only.
            let search = max(length * 0.10, (prior.half ?? 0) + length * 0.045)
            let candidates = scores.indices.filter {
                (scores[$0].map { $0 >= 18 } ?? false) && abs(low + Double($0)*step-prior.center) <= search
            }
            guard let peak = candidates.max(by: { a,b in
                let da = (low+Double(a)*step-prior.center)/(length * 0.055)
                let db = (low+Double(b)*step-prior.center)/(length * 0.055)
                return scores[a]!/(1+da*da) < scores[b]!/(1+db*db)
            }), let maximum = scores[peak], maximum >= 22 else { return stationRejected("source_core_contrast") }
            // Qualification uses the connected half-maximum dark core. The
            // weaker fringe can contain low-frequency skin shading and must
            // not be subjected to the dark-core width budget.
            let threshold = maximum * 0.50
            var first = peak, last = peak
            while first > 0, let previous = scores[first-1], previous >= threshold { first -= 1 }
            while last < steps, let next = scores[last+1], next >= threshold { last += 1 }
            guard first > 0, last < steps,
                  let before = scores[first-1], let insideUpper = scores[first],
                  let insideLower = scores[last], let after = scores[last+1],
                  before < threshold, after < threshold else { return stationRejected("source_core_boundary") }
            func crossing(_ a: Int, _ va: Double, _ b: Int, _ vb: Double) -> Double {
                let t = min(1, max(0, (threshold-va)/(vb-va)))
                return low + (Double(a) + Double(b-a)*t) * step
            }
            let lo = crossing(first-1,before,first,insideUpper)
            let hi = crossing(last,insideLower,last+1,after)
            let measuredWidth = hi-lo, center = (hi+lo)*0.5
            guard measuredWidth >= 0.5 else { return stationRejected("source_core_narrow") }
            guard measuredWidth <= length * 0.19 else { return stationRejected("source_core_width") }
            guard abs(center-prior.center) <= search else { return stationRejected("source_core_position") }
            if let half = prior.half {
                // A qualified dark lobe must still belong to the observed
                // source envelope. The existing registration margin tolerates
                // detector placement error without choosing remote hair.
                let margin = length * 0.045
                guard hi >= prior.center-half, lo <= prior.center+half,
                      center >= prior.center-half-margin, center <= prior.center+half+margin
                else { return stationRejected("source_core_prior") }
            }
            // A contrast-weighted core centroid retains natural upper/lower
            // asymmetry while staying inside the connected measured core.
            var weight = 0.0, moment = 0.0
            for k in first...last {
                let w = max(0, (scores[k] ?? 0)-threshold)
                weight += w; moment += (low+Double(k)*step)*w
            }
            let ridge = weight > 0 ? min(hi-step*0.1, max(lo+step*0.1, moment/weight)) : center
            guard ridge > lo, ridge < hi else { return stationRejected("source_core_ridge") }
            // After registration, measure the connected weak fringe separately.
            // Its outward reach is confined to this brow's observed envelope
            // and registration margin. A broad skin shadow is never promoted
            // into a wider strong core or borrowed from a neighbouring organ.
            let fringeThreshold = max(10, maximum * 0.20)
            let priorRadius = prior.half.map { $0+length*0.045 } ?? search
            let allowedLo = min(lo, prior.center-priorRadius)
            let allowedHi = max(hi, prior.center+priorRadius)
            var fringeFirst = first, fringeLast = last
            while fringeFirst > 0, let previous = scores[fringeFirst-1], previous >= fringeThreshold,
                  low+Double(fringeFirst-1)*step >= allowedLo { fringeFirst -= 1 }
            while fringeLast < steps, let next = scores[fringeLast+1], next >= fringeThreshold,
                  low+Double(fringeLast+1)*step <= allowedHi { fringeLast += 1 }
            var outerLo = low+Double(fringeFirst)*step, outerHi = low+Double(fringeLast)*step
            if fringeFirst > 0, let outside = scores[fringeFirst-1], let inside = scores[fringeFirst],
               outside < fringeThreshold, inside >= fringeThreshold {
                let t = (fringeThreshold-outside)/(inside-outside)
                outerLo = low+(Double(fringeFirst-1)+t)*step
            } else { outerLo -= step*0.5 }
            if fringeLast < steps, let inside = scores[fringeLast], let outside = scores[fringeLast+1],
               inside >= fringeThreshold, outside < fringeThreshold {
                let t = (fringeThreshold-inside)/(outside-inside)
                outerHi = low+(Double(fringeLast)+t)*step
            } else { outerHi += step*0.5 }
            outerLo = max(allowedLo,min(lo,outerLo)); outerHi = min(allowedHi,max(hi,outerHi))
            return Measurement(ridge: ridge, upper: ridge-outerLo, lower: outerHi-ridge)
        }

        let stations = (0..<stationCount).map { length * Double($0) / Double(stationCount-1) }
        var measurements = zip(stations, priors).map { measure($0.0, $0.1) }
        let reliable = measurements.indices.filter { measurements[$0] != nil }
        guard reliable.count >= stationCount * 2 / 3,
              let first = reliable.first, let last = reliable.last,
              first <= 7, last >= stationCount-8,
              reliable.contains(where: { $0 <= stationCount/4 }),
              reliable.contains(where: { $0 >= stationCount*3/4 }) else {
            reportStationFailure()
            return reject("source_core_coverage")
        }
        for pair in zip(reliable, reliable.dropFirst()) {
            guard pair.1-pair.0 <= 5 else { reportStationFailure(); return reject("source_core_gap") }
            guard let a = measurements[pair.0], let b = measurements[pair.1],
                  abs(b.ridge-a.ridge) <= length * 0.07 * Double(pair.1-pair.0) else { return reject("source_core_branch") }
            if pair.1 > pair.0+1 {
                for index in (pair.0+1)..<pair.1 {
                    let t = Double(index-pair.0) / Double(pair.1-pair.0)
                    measurements[index] = mix(a,b,t)
                }
            }
        }
        // Only short missing caps may borrow the local first derivative of
        // this same measured brow. No middle gap or opposite brow is invented.
        if first > 0 {
            let a = measurements[first]!, b = measurements[reliable[1]]!
            let span = Double(reliable[1]-first)
            for index in 0..<first { measurements[index] = extrapolate(a,b,Double(index-first)/span) }
        }
        if last < stationCount-1 {
            let previous = reliable[reliable.count-2], a = measurements[previous]!, b = measurements[last]!
            let span = Double(last-previous)
            for index in (last+1)..<stationCount { measurements[index] = extrapolate(b,a,Double(last-index)/span) }
        }
        guard measurements.allSatisfy({ $0 != nil }) else { return reject("source_core_completion") }
        var measured = measurements.map { $0! }
        // Remove column-scale RGB noise before the C1 profiles are fitted;
        // thickness still comes entirely from source widths at every station.
        for _ in 0..<2 {
            let previous = measured
            for index in 1..<(stationCount-1) {
                measured[index] = mix(mix(previous[index-1],previous[index+1],0.5),previous[index],0.5)
            }
        }
        guard measured.allSatisfy({ $0.ridge.isFinite && $0.upper.isFinite && $0.lower.isFinite && $0.upper > 0 && $0.lower > 0 }),
              let ridge = BeautyEyebrowDisplacementModel.Profile(samples: zip(stations,measured).map { SIMD2($0.0,$0.1.ridge) }),
              let upper = BeautyEyebrowDisplacementModel.Profile(samples: zip(stations,measured).map { SIMD2($0.0,$0.1.upper) }, endpointDerivatives: .zero),
              let lower = BeautyEyebrowDisplacementModel.Profile(samples: zip(stations,measured).map { SIMD2($0.0,$0.1.lower) }, endpointDerivatives: .zero) else { return reject("source_core_profiles") }
        return BeautyEyebrowDisplacementModel.Geometry(origin: origin, horizontal: horizontal, vertical: vertical,
            isLeft: isLeft, length: length, ridge: ridge, upper: upper, lower: lower)
    }

    private static let stationCount = 49
    private struct Prior { let center: Double; let half: Double? }
    private struct Donor { let v: Double; let rgb: SIMD3<Double> }
    private struct Measurement { let ridge: Double; let upper: Double; let lower: Double }
    private struct Box {
        let minX: Double, maxX: Double, minY: Double, maxY: Double
        init?(points: [SIMD2<Double>], padding: Double) {
            guard !points.isEmpty, points.allSatisfy(finite) else { return nil }
            minX = points.map(\.x).min()!-padding; maxX = points.map(\.x).max()!+padding
            minY = points.map(\.y).min()!-padding; maxY = points.map(\.y).max()!+padding
        }
        func contains(_ p: SIMD2<Double>) -> Bool { p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY }
    }
    private static func openStations(_ points: [SIMD2<Double>], length: Double) -> [Double]? {
        guard points.count >= 4, points.allSatisfy(finite),
              abs(points[0].x) < 1e-6, abs(points.last!.x-length) < 1e-6 else { return nil }
        for pair in zip(points,points.dropFirst()) {
            guard pair.1.x > pair.0.x + length * 1e-5 else { return nil }
        }
        return (0..<stationCount).map { index in
            let r = length * Double(index) / Double(stationCount-1)
            let i = max(1, points.firstIndex(where: { $0.x >= r }) ?? points.count-1)
            let a = points[i-1], b = points[i]
            return a.y + (b.y-a.y) * (r-a.x)/(b.x-a.x)
        }
    }
    private static func closedStations(_ points: [SIMD2<Double>], length: Double,
                                       onFailure: ((String) -> Void)?) -> [Prior]? {
        guard points.count >= 8, points.allSatisfy(finite),
              points.map(\.x).min()! <= 1e-6, points.map(\.x).max()! >= length-1e-6
        else { onFailure?("dense_envelope_extent"); return nil }
        var result = [Prior]()
        for index in 0..<stationCount {
            let r = length * Double(index)/Double(stationCount-1)
            var values = [Double]()
            for edge in points.indices {
                let a = points[edge], b = points[(edge+1)%points.count]
                guard abs(b.x-a.x) > 1e-8, r >= min(a.x,b.x)-1e-6, r <= max(a.x,b.x)+1e-6 else { continue }
                values.append(a.y+(b.y-a.y)*(r-a.x)/(b.x-a.x))
            }
            var unique = [Double]()
            for value in values.sorted() where unique.last.map({ abs($0-value) > length*1e-6 }) ?? true { unique.append(value) }
            guard let lo = unique.first, let hi = unique.last else { onFailure?("dense_envelope_section_missing"); return nil }
            guard unique.count <= 2 else { onFailure?("dense_envelope_section_branch"); return nil }
            guard hi-lo <= length * 0.28 else { onFailure?("dense_envelope_section_width"); return nil }
            result.append(Prior(center: (lo+hi)*0.5, half: max(0,(hi-lo)*0.5)))
        }
        return result
    }
    private static func eyeCenter(_ path: [SIMD2<Float>], width: Int, height: Int) -> SIMD2<Double>? {
        guard validPath(path), BeautyDenseFaceSupport.simplePolygon(path) else { return nil }
        let points = path.map { SIMD2(Double($0.x)*Double(width)-0.5, Double($0.y)*Double(height)-0.5) }
        // Closed-contour area centroid avoids point-density-dependent roll.
        var twiceArea = 0.0, moment = SIMD2<Double>.zero
        for index in points.indices {
            let a = points[index], b = points[(index+1)%points.count], cross = a.x*b.y-b.x*a.y
            twiceArea += cross; moment += (a+b)*cross
        }
        guard abs(twiceArea) > 1 else { return nil }
        let center = moment/(3*twiceArea)
        return finite(center) ? center : nil
    }
    private static func validTrace(_ trace: BeautyEyebrowSemanticTrace, face: FaceGeometry) -> Bool {
        let bounds = face.bounds
        guard (4...16).contains(trace.points.count), trace.points.allSatisfy(valid),
              Set(trace.points).count == trace.points.count,
              trace.points.first == trace.innerEndpoint, trace.points.last == trace.outerEndpoint,
              valid(trace.center), bounds.x.isFinite, bounds.y.isFinite,
              bounds.width.isFinite, bounds.height.isFinite, bounds.width > 0, bounds.height > 0,
              bounds.minX >= 0, bounds.minY >= 0, bounds.maxX <= 1, bounds.maxY <= 1,
              abs(trace.innerEndpoint.x-bounds.midX) < abs(trace.outerEndpoint.x-bounds.midX) else { return false }
        return trace.side == .left ? trace.outerEndpoint.x < trace.innerEndpoint.x && trace.center.x < bounds.midX :
            trace.outerEndpoint.x > trace.innerEndpoint.x && trace.center.x > bounds.midX
    }
    private static func mix(_ a: Measurement, _ b: Measurement, _ t: Double) -> Measurement {
        Measurement(ridge: a.ridge+(b.ridge-a.ridge)*t, upper: a.upper+(b.upper-a.upper)*t, lower: a.lower+(b.lower-a.lower)*t)
    }
    private static func extrapolate(_ a: Measurement, _ b: Measurement, _ t: Double) -> Measurement {
        let value = mix(a,b,t)
        // Extrapolated cap width is limited by its own nearest source width.
        return Measurement(ridge: value.ridge,
            upper: min(a.upper*2,max(a.upper*0.25,value.upper)),
            lower: min(a.lower*2,max(a.lower*0.25,value.lower)))
    }
    private static func valid(_ p: SIMD2<Float>) -> Bool { p.x.isFinite && p.y.isFinite && (0...1).contains(p.x) && (0...1).contains(p.y) }
    private static func validPath(_ p: [SIMD2<Float>]) -> Bool { p.count >= 3 && p.allSatisfy(valid) && Set(p).count >= 3 }
    private static func finite(_ p: SIMD2<Double>) -> Bool { p.x.isFinite && p.y.isFinite }
    private static func dot(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double { a.x*b.x+a.y*b.y }
    private static func luma(_ rgb: SIMD3<Double>) -> Double { (rgb.x+rgb.y+rgb.z)/3 }
}
