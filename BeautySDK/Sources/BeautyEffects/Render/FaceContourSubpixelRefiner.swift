import Foundation
import BeautyDetection

/// Request-local raster alignment of the observed lateral contour. It reads
/// every sample from the immutable input and never retains pixels or support.
enum FaceContourSubpixelRefiner {
    struct SourceRunTrace {
        var activeRows = 0
        var protectedHairRows = 0
        var cleanBoundaryRows = 0
        var maximumCleanSegmentRows = 0
        var admittedCleanSegments = 0
        var cleanAnalysisLongEdge = 0
        var analysisAdmittedCleanSegments = 0
        var nativeCandidatePixels = 0
        var maximumNativeShiftBeforeConstraint: Float = 0
        var maximumNativeShiftAfterConstraint: Float = 0
        var sourceRecenteredRows = 0
        var nativeAmbiguousRows = 0
        var nativeWeakRows = 0
        var nativeRequalifiedRows = 0
        var nativeRejectedCandidateRows = 0
        var nativeHairGuardRows = 0
        var nativeMappedFieldPixels = 0
        var nativeDomainRejectedPixels = 0
        var nativeCoreRejectedPixels = 0
        var nativeBandRejectedPixels = 0
        var nativeFootprintRejectedPixels = 0
        var nativeChangedPixels = 0
        var nativeSourceHairHaloCount = 0
        var nativeSourceHairHaloPixels = 0
        var maximumNativeSourceHairWidth = 0
        var maximumRejectedNativeSourceHairWidth = 0
        var nativeSourceHairHaloRejectedWidth = 0
        var nativeSourceHairHaloRejectedContourSplit = 0
        var nativeSourceHairHaloRejectedEndpoints = 0
        var nativeGeometryRejectedPixels = 0
        var nativeGeometryFootprintRejectedPixels = 0
        var maximumNativeGeometryGradient: Float = 0
        var admittedGeometryShapeRows = 0
        var geometryShapeOnlyRows = 0
    }

    struct Refinement {
        let bytes: [UInt8]
        let protectedLeft: Bool
        let protectedRight: Bool
        /// Counts only. Source rows, landmarks and pixels remain request-local.
        var sourceTrace: [SourceRunTrace] = []
    }

    private enum BoundaryDetection {
        case found(Float, Int)
        case ambiguous
        case weak
        case unavailable
    }

    /// Source geometry fixed before observing a smoothing result. It retains
    /// the narrow-circle candidate's source arc/radius and permanent feature
    /// envelopes. The lateral attachment reserve remains conservative; this
    /// does not claim automatic ear or hair segmentation.
    private struct SourceProtection {
        struct Box {
            let minX: Double, maxX: Double, minY: Double, maxY: Double
            func intersects(x: Int, y: Int) -> Bool {
                Double(x + 1) >= minX && Double(x) <= maxX &&
                    Double(y + 1) >= minY && Double(y) <= maxY
            }
            func distance(x: Double, y: Double) -> Double {
                hypot(max(0, max(minX - x - 0.5, x - 0.5 - maxX)),
                      max(0, max(minY - y - 0.5, y - 0.5 - maxY)))
            }
        }
        let scope: BeautyContourTransitionScope
        let boxes: [Box]

        func allows(x: Int, y: Int) -> Bool {
            scope.allowsDestination(x: x, y: y) && !boxes.contains { $0.intersects(x: x, y: y) }
        }
        func distance(x: Double, y: Double) -> Double {
            boxes.reduce(scope.distanceToFixed(x: x, y: y)) { min($0, $1.distance(x: x, y: y)) }
        }
        func weight(x: Int, y: Int) -> Float {
            guard allows(x: x, y: y) else { return 0 }
            let t = min(1, max(0, distance(x: Double(x) + 0.5, y: Double(y) + 0.5) /
                max(2, min(8, scope.radius / 3))))
            return Float(t * t * (3 - 2 * t))
        }
        func allowsSample(destination: Int, sample: Float, row: Int) -> Bool {
            guard sample.isFinite,
                  scope.allowsSourceFootprint(x: Double(sample) + 0.5, y: Double(row) + 0.5) else { return false }
            let first = Int(floor(sample))
            // The full sweep is admitted before projection; projection only
            // shortens it. Include the zero-weight second source row as well.
            return (min(destination, first)...max(destination, first + 1)).allSatisfy {
                allows(x: $0, y: row) && allows(x: $0, y: row + 1)
            }
        }
    }

    private static func sourceProtection(width: Int, height: Int, face: FaceGeometry) -> SourceProtection? {
        func valid(_ p: SIMD2<Float>) -> Bool {
            p.x.isFinite && p.y.isFinite && (0...1).contains(p.x) && (0...1).contains(p.y)
        }
        guard face.freshness == .fresh, let support = face.observedFaceSupport,
              let brows = face.observedEyebrowSupport, let lb = brows.left, let rb = brows.right,
              lb.side == .left, rb.side == .right, let nose = face.observedNoseSupport,
              let mouth = face.observedOuterLips else { return nil }
        let left = face.leftEyeSupport?.contour ?? face.leftEye
        let right = face.rightEyeSupport?.contour ?? face.rightEye
        let nasal = (nose.crest + nose.contour).map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        guard left.count >= 4, right.count >= 4, mouth.count >= 4,
              (2...16).contains(lb.points.count), (2...16).contains(rb.points.count),
              nose.crest.count >= 3, nose.contour.count >= 3, Set(nasal).count >= 3,
              [lb.innerEndpoint, lb.outerEndpoint, lb.center, rb.innerEndpoint, rb.outerEndpoint, rb.center].allSatisfy(valid)
        else { return nil }
        var paths = [left, right, lb.points, rb.points, mouth, nasal]
        if let dense = face.denseSupport {
            paths[2] += BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.leftBrowEnvelope)
            paths[3] += BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.rightBrowEnvelope)
            paths[5] += BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.noseCrest)
                + BeautyDenseFaceSupport.path(dense.mesh, MediaPipeFaceTopology.noseContour)
        }
        guard (support.contour + paths.flatMap { $0 }).allSatisfy(valid) else { return nil }
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> { SIMD2(Double(p.x) * Double(width), Double(p.y) * Double(height)) }
        func mean(_ p: [SIMD2<Float>]) -> SIMD2<Double> { p.map(pixel).reduce(.zero, +) / Double(p.count) }
        let eyeVector = mean(right) - mean(left), eyeDistance = hypot(eyeVector.x, eyeVector.y)
        guard eyeDistance >= 4 else { return nil }
        let axisX = eyeVector / eyeDistance, axisY = SIMD2(-axisX.y, axisX.x), origin = (mean(left) + mean(right)) * 0.5
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let d = p - origin
            return SIMD2(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
        }
        let raw = support.contour.map(pixel), coordinates = raw.map(local)
        guard let minX = coordinates.map(\.x).min(), let maxX = coordinates.map(\.x).max(),
              let chin = coordinates.map(\.y).max(), maxX - minX >= 24,
              maxX - minX > eyeDistance * 1.1, maxX - minX < eyeDistance * 4,
              chin > eyeDistance * 0.4 else { return nil }
        let span = maxX - minX, noseBottom = paths[5].map { local(pixel($0)).y }.max()!
        guard let scope = BeautyContourTransitionScope(width: width, height: height, contour: raw,
            origin: origin, axisX: axisX, axisY: axisY, span: span, chin: chin,
            lowerBound: max(chin * 0.32, noseBottom + span * 0.008)) else { return nil }
        let collars = [0.055, 0.055, 0.045, 0.045, 0.08, 0.008]
        var boxes = zip(paths, collars).map { path, collar -> SourceProtection.Box in
            let pixels = path.map(pixel), padding = max(2, span * collar)
            return SourceProtection.Box(minX: pixels.map(\.x).min()! - padding, maxX: pixels.map(\.x).max()! + padding,
                minY: pixels.map(\.y).min()! - padding, maxY: pixels.map(\.y).max()! + padding)
        }
        // Lateral fairing cannot acquire the central feature corridor merely
        // because a lower round cap approaches it. Reuse the existing eye
        // envelope and its collar, extending its source-fixed x ownership
        // down to the chin. This reserve enters the field BEFORE projection.
        let eyeCoordinates = (paths[0] + paths[1]).map { local(pixel($0)) }
        let eyePadding = max(2, span * collars[0])
        let centralX0 = eyeCoordinates.map(\.x).min()! - eyePadding
        let centralX1 = eyeCoordinates.map(\.x).max()! + eyePadding
        let centralY0 = min(0, eyeCoordinates.map(\.y).min()!)
        let central = [SIMD2(centralX0, centralY0), SIMD2(centralX1, centralY0),
            SIMD2(centralX0, chin), SIMD2(centralX1, chin)].map { origin + axisX * $0.x + axisY * $0.y }
        boxes.append(SourceProtection.Box(minX: central.map(\.x).min()!, maxX: central.map(\.x).max()!,
            minY: central.map(\.y).min()!, maxY: central.map(\.y).max()!))
        // Preserve the existing conservative lateral attachment geometry.
        // A same-colour ear/cheek junction is never released by a skin guess.
        let y0 = -span * 0.04, y1 = min(chin * 0.48, max(0, noseBottom) + span * 0.04)
        if y1 > y0, let first = coordinates.first, let last = coordinates.last {
            let ordered = first.x <= last.x ? [first, last] : [last, first]
            for (endpoint, sign) in [(ordered[0], -1.0), (ordered[1], 1.0)] {
                let inner = endpoint.x - sign * span * 0.08, outer = endpoint.x + sign * span * 0.24
                let p = [SIMD2(inner, y0), SIMD2(outer, y0), SIMD2(inner, y1), SIMD2(outer, y1)]
                    .map { origin + axisX * $0.x + axisY * $0.y }
                let padding = max(2, span * 0.008)
                boxes.append(SourceProtection.Box(minX: p.map(\.x).min()! - padding, maxX: p.map(\.x).max()! + padding,
                    minY: p.map(\.y).min()! - padding, maxY: p.map(\.y).max()! + padding))
            }
        }
        return SourceProtection(scope: scope, boxes: boxes)
    }

    static func refine(
        _ source: [UInt8],
        width: Int,
        height: Int,
        face: FaceGeometry,
        strength: Float
    ) -> [UInt8] {
        refineWithProtection(source, width: width, height: height, face: face, strength: strength).bytes
    }

    static func refineWithProtection(
        _ source: [UInt8],
        width: Int,
        height: Int,
        face: FaceGeometry,
        strength: Float
    ) -> Refinement {
        let identity = Refinement(bytes: source, protectedLeft: false, protectedRight: false)
        guard width > 1, height > 1 else { return identity }
        let pixels = width.multipliedReportingOverflow(by: height)
        guard !pixels.overflow else { return identity }
        let byteCount = pixels.partialValue.multipliedReportingOverflow(by: 4)
        guard !byteCount.overflow,
              source.count == byteCount.partialValue,
              strength.isFinite, strength > 0,
              let contour = face.observedFaceSupport?.contour,
              let runs = FaceContourLateralRuns.make(from: contour)
        else { return identity }

        let requested = min(1, strength / BeautySafetyCaps.faceContourSmooth)
        guard requested.isFinite, requested > 0 else { return identity }
        var strengths = BeautyEffectiveStrengths()
        strengths.faceContourSmooth = strength
        guard !FaceShapeWarpProvider().fieldEmissions(
            face: face,
            strengths: strengths
        ).faceContourSmooth.isEmpty else { return identity }
        let hasCompleteSourcePayload = face.observedNoseSupport != nil &&
            face.observedEyebrowSupport != nil && face.observedOuterLips != nil
        let geometryProtection: SourceProtection?
        if hasCompleteSourcePayload {
            guard stride(from: 3, to: source.count, by: 4).allSatisfy({ source[$0] == 255 }),
                  let admitted = sourceProtection(width: width, height: height, face: face) else { return identity }
            geometryProtection = admitted
        } else { geometryProtection = nil }
        var result = source
        var protectedLeft = false
        var protectedRight = false
        var sourceTrace = [SourceRunTrace]()
        let outerRadius = 14
        let feather = 6.0 as Float
        let endpointTaper = 20.0 as Float
        let contourSpan = (face.observedFaceSupport?.contour.map(\.x).max() ?? 0) -
            (face.observedFaceSupport?.contour.map(\.x).min() ?? 0)

        for (runIndex, run) in runs.enumerated() {
            guard let first = run.ordered.first, let last = run.ordered.last else { return identity }
            let isLeftSide = runIndex == 0
            var protected = false
            var runTrace = SourceRunTrace()
            let refined = refineObservedBoundary(
                source, result: &result, width: width, height: height,
                faceWidth: face.bounds.width, run: run,
                isLeftSide: isLeftSide, requested: requested,
                protected: &protected, trace: &runTrace, sourceContourSpan: contourSpan,
                sourceProtection: geometryProtection
            )
            sourceTrace.append(runTrace)
            if refined {
                if isLeftSide { protectedLeft = protected } else { protectedRight = protected }
                continue
            }
            // Complete observed input owns a source-curve smoother. Failure
            // cannot revive detector-row registration on a protected source.
            if geometryProtection != nil { continue }
            let start = max(0, Int(ceil(first.y * Float(height) - 0.5)))
            let end = min(height, Int(ceil(last.y * Float(height) - 0.5)))
            let lowerColumn = max(0, Int((run.ordered.map(\.x).min()! * Float(width)).rounded()) - outerRadius)
            let upperColumn = min(width - 1, Int((run.ordered.map(\.x).max()! * Float(width)).rounded()) + outerRadius)
            guard var field = LegacyCapField(lowerColumn: lowerColumn, upperColumn: upperColumn,
                startRow: start, endRow: end) else { continue }
            var segment = 0
            for row in start..<end {
                let y = (Float(row) + 0.5) / Float(height)
                guard y >= first.y, y < last.y else { continue }
                while segment + 1 < run.ordered.count - 1 && y > run.ordered[segment + 1].y {
                    segment += 1
                }
                let lower = run.ordered[segment]
                let upper = run.ordered[segment + 1]
                let progress = (y - lower.y) / (upper.y - lower.y)
                let continuousCenter = (lower.x + (upper.x - lower.x) * progress) * Float(width)
                guard continuousCenter.isFinite else { return identity }
                let roundedCenter = Int(continuousCenter.rounded())
                let fractionalShift = strongBoundaryShift(
                    source,
                    width: width,
                    row: row,
                    center: roundedCenter,
                    continuousCenter: continuousCenter,
                    isLeftSide: isLeftSide
                ) ?? (continuousCenter - Float(roundedCenter))
                let yWeight = min(
                    1,
                    (y - first.y) * Float(height) / endpointTaper,
                    (last.y - y) * Float(height) / endpointTaper
                )
                guard yWeight > 0, abs(fractionalShift) > Float.ulpOfOne else { continue }
                let lowerColumn = max(0, roundedCenter - outerRadius)
                let upperColumn = min(width - 1, roundedCenter + outerRadius)
                guard lowerColumn <= upperColumn else { continue }

                for column in lowerColumn...upperColumn {
                    let distance = abs(Float(column - roundedCenter))
                    let xWeight = min(1, max(0, (Float(outerRadius) - distance) / feather))
                    let domainWeight = sourceContourWeight(column: Float(column), center: continuousCenter,
                        span: contourSpan * Float(width), isLeftSide: isLeftSide)
                    let shift = fractionalShift * yWeight * xWeight * domainWeight
                    guard abs(shift) > Float.ulpOfOne else { continue }
                    let sampleX = Float(column) - shift
                    guard sampleX >= 0, sampleX <= Float(width - 1) else { continue }
                    let x0 = Int(floor(sampleX))
                    let x1 = min(width - 1, x0 + 1)
                    guard (min(column, x0)...max(column, x1)).allSatisfy({
                        sourceContourWeight(column: Float($0), center: continuousCenter,
                            span: contourSpan * Float(width), isLeftSide: isLeftSide) > 0 &&
                            source[(row * width + $0) * 4 + 3] == 255
                    }) else { continue }
                    field.shifts[(row - field.originY) * field.width + column - field.originX] = shift
                }
            }
            applyLegacyCapField(field, source: source, result: &result, width: width,
                height: height, requested: requested, registration: true)
        }
        return Refinement(
            bytes: result,
            protectedLeft: protectedLeft,
            protectedRight: protectedRight,
            sourceTrace: sourceTrace
        )
    }

    /// The legacy local samplers share the original observed contour domain.
    /// Searching for a source edge never moves or enlarges this admission
    /// band. Check the whole sampling sweep as well as its destination.
    private static func sourceContourWeight(
        column: Float, center: Float, span: Float, isLeftSide: Bool
    ) -> Float {
        guard column.isFinite, center.isFinite, span.isFinite, span > 0 else { return 0 }
        let physicalColumn = column + 0.5
        let inside = isLeftSide ? physicalColumn >= center : physicalColumn <= center
        let radius = span * (inside ? 0.20 : 0.06)
        let t = min(1, max(0, (radius - abs(physicalColumn - center)) / max(2, span * 0.008)))
        return t * t * (3 - 2 * t)
    }

    /// A compact source run has a pinned zero ring, including when it touches
    /// the canvas. Domain or footprint refusal is represented before the
    /// gradient constraint, rather than cutting an already constrained field.
    private struct LegacyCapField {
        let originX: Int
        let originY: Int
        let width: Int
        let height: Int
        var shifts: [Float]

        init?(lowerColumn: Int, upperColumn: Int, startRow: Int, endRow: Int) {
            guard lowerColumn >= 0, upperColumn >= lowerColumn,
                  startRow >= 0, endRow > startRow else { return nil }
            originX = lowerColumn - 1
            originY = startRow - 1
            width = upperColumn - lowerColumn + 3
            height = endRow - startRow + 2
            let count = width.multipliedReportingOverflow(by: height)
            guard !count.overflow else { return nil }
            shifts = [Float](repeating: 0, count: count.partialValue)
        }
    }

    /// Constrain every corner of each bilinear horizontal-displacement cell.
    /// The Frobenius norm is hypot(dx, dy); all reductions preserve the source
    /// sign and only shorten its admitted sampling sweep. No new support is
    /// introduced at a zero, a rejected footprint or the pinned border.
    static func constrainedLegacyCapField(
        _ field: [Float], width: Int, height: Int
    ) -> [Float]? {
        guard width >= 3, height >= 3 else { return nil }
        let count = width.multipliedReportingOverflow(by: height)
        guard !count.overflow, field.count == count.partialValue,
              field.allSatisfy(\.isFinite),
              (0..<width).allSatisfy({ field[$0] == 0 && field[(height - 1) * width + $0] == 0 }),
              (0..<height).allSatisfy({ field[$0 * width] == 0 && field[$0 * width + width - 1] == 0 })
        else { return nil }
        var output = field
        // Leave a representable margin for the final Float conversion. The
        // actual verified safety ceiling remains .45 on all four corners.
        let limit = 0.45 - 4 * Double(Float.ulpOfOne)
        func reduce(_ i: Int, to value: Double) {
            let prior = output[i]
            output[i] = prior >= 0 ? max(0, min(prior, Float(value))) : min(0, max(prior, Float(value)))
        }
        func constrainPair(_ a: Int, _ b: Int, scale: Double) {
            let first = Double(output[a]), second = Double(output[b])
            if first * second < 0 {
                reduce(a, to: first * scale)
                reduce(b, to: second * scale)
            } else if abs(first) > abs(second) {
                reduce(a, to: second + (first - second) * scale)
            } else {
                reduce(b, to: first + (second - first) * scale)
            }
        }
        func constrainCorner(_ a: Int, _ b: Int, _ c: Int, _ d: Int) {
            let dx = Double(output[b]) - Double(output[a])
            let dy = Double(output[d]) - Double(output[c])
            let gradient = hypot(dx, dy)
            guard gradient > limit else { return }
            let scale = limit / gradient
            constrainPair(a, b, scale: scale)
            constrainPair(c, d, scale: scale)
        }
        func constrainCell(_ i: Int) {
            let tr = i + 1, bl = i + width, br = bl + 1
            constrainCorner(i, tr, i, bl)
            constrainCorner(i, tr, tr, br)
            constrainCorner(bl, br, i, bl)
            constrainCorner(bl, br, tr, br)
        }
        func maximumGradient() -> Double {
            var maximum = 0.0
            for y in 0..<(height - 1) { for x in 0..<(width - 1) {
                let i = y * width + x
                let top = Double(output[i + 1]) - Double(output[i])
                let bottom = Double(output[i + width + 1]) - Double(output[i + width])
                let left = Double(output[i + width]) - Double(output[i])
                let right = Double(output[i + width + 1]) - Double(output[i + 1])
                maximum = max(maximum, hypot(top, left), hypot(top, right),
                    hypot(bottom, left), hypot(bottom, right))
            } }
            return maximum
        }
        guard maximumGradient() > limit else { return output }
        // Local reduction retains useful corrections far from a refusal.
        // A finite pass budget is followed by a complete verified scalar cap.
        for _ in 0..<16 {
            for y in 0..<(height - 1) { for x in 0..<(width - 1) { constrainCell(y * width + x) } }
            for y in (0..<(height - 1)).reversed() {
                for x in (0..<(width - 1)).reversed() { constrainCell(y * width + x) }
            }
        }
        let maximum = maximumGradient()
        if maximum > limit {
            let scale = limit / maximum
            output = output.map { Float(Double($0) * scale) }
        }
        guard output.allSatisfy(\.isFinite), maximumGradient() <= 0.45 else { return nil }
        return output
    }

    /// Raster registration keeps each row's source phase. Its original
    /// fractional fallback is at most .5 pixel and a unique strong-edge
    /// registration is at most 1.5 pixels. With y unchanged, bounding the
    /// horizontal derivative makes the inverse monotone; it does not claim
    /// the full shape-field Frobenius bound for the quantized row-phase shear.
    static func constrainedLegacyRegistrationField(
        _ field: [Float], width: Int, height: Int
    ) -> [Float]? {
        guard width >= 3, height >= 3 else { return nil }
        let count = width.multipliedReportingOverflow(by: height)
        guard !count.overflow, field.count == count.partialValue,
              field.allSatisfy({ $0.isFinite && abs($0) <= 1.5 }),
              (0..<width).allSatisfy({ field[$0] == 0 && field[(height - 1) * width + $0] == 0 }),
              (0..<height).allSatisfy({ field[$0 * width] == 0 && field[$0 * width + width - 1] == 0 })
        else { return nil }
        var output = field
        let limit = 0.45 - 4 * Double(Float.ulpOfOne)
        for row in 1..<(height - 1) {
            let first = row * width
            var maximum = 0.0
            for x in 0..<(width - 1) {
                maximum = max(maximum, abs(Double(field[first + x + 1]) - Double(field[first + x])))
            }
            guard maximum > limit else { continue }
            let scale = limit / maximum
            // One source-owned scalar per row preserves its signed phase and
            // relative feather. Rejected texels and the zero ring stay zero.
            for x in 1..<(width - 1) { output[first + x] = Float(Double(field[first + x]) * scale) }
        }
        for row in 0..<height { for x in 0..<(width - 1) {
            let first = row * width + x
            guard abs(Double(output[first + 1]) - Double(output[first])) <= 0.45 else { return nil }
        } }
        return output
    }

    /// Complete observed sources use a shape field, including both vertical
    /// and horizontal derivatives. The legacy row-phase helper stays intact
    /// for its independently frozen compatibility contract.
    static func constrainedProtectedSourceField(
        _ field: [Float], width: Int, height: Int
    ) -> [Float]? {
        guard width > 0, height > 0, width <= Int.max - 2, height <= Int.max - 2 else { return nil }
        let count = width.multipliedReportingOverflow(by: height)
        let paddedWidth = width + 2, paddedHeight = height + 2
        let paddedCount = paddedWidth.multipliedReportingOverflow(by: paddedHeight)
        guard !count.overflow, field.count == count.partialValue, !paddedCount.overflow,
              field.allSatisfy(\.isFinite) else { return nil }
        var padded = [Float](repeating: 0, count: paddedCount.partialValue)
        for y in 0..<height { for x in 0..<width {
            padded[(y + 1) * paddedWidth + x + 1] = field[y * width + x]
        } }
        guard let bounded = constrainedLegacyCapField(padded, width: paddedWidth, height: paddedHeight) else { return nil }
        return field.indices.map { bounded[($0 / width + 1) * paddedWidth + $0 % width + 1] }
    }

    private static func applyLegacyCapField(
        _ field: LegacyCapField, source: [UInt8], result: inout [UInt8],
        width: Int, height: Int, requested: Float, registration: Bool = false
    ) {
        let constrained = registration ?
            constrainedLegacyRegistrationField(field.shifts, width: field.width, height: field.height) :
            constrainedLegacyCapField(field.shifts, width: field.width, height: field.height)
        guard let shifts = constrained else { return }
        for y in 1..<(field.height - 1) { for x in 1..<(field.width - 1) {
            let row = field.originY + y, column = field.originX + x
            guard row >= 0, row < height, column >= 0, column < width else { continue }
            let shift = shifts[y * field.width + x] * requested
            guard shift != 0 else { continue }
            let sample = Float(column) - shift
            guard sample >= 0, sample <= Float(width - 1) else { continue }
            let x0 = Int(floor(sample)), x1 = min(width - 1, x0 + 1)
            let destination = (row * width + column) * 4
            let a = (row * width + x0) * 4, b = (row * width + x1) * 4
            guard source[destination + 3] == 255, source[a + 3] == 255,
                  source[b + 3] == 255 else { continue }
            let fraction = sample - Float(x0)
            for c in 0..<3 {
                let value = Float(source[a + c]) + (Float(source[b + c]) - Float(source[a + c])) * fraction
                result[destination + c] = UInt8(min(255, max(0, Int(value.rounded()))))
            }
        } }
    }

    /// Vision's sparse contour can sit well inside the visible cheek boundary.
    /// Admit a wider correction only when source pixels locate one coherent
    /// outer edge across the observed lateral run. Ambiguous rows remain local
    /// no-ops; an unqualified run keeps the former subpixel alignment.
    private static func refineObservedBoundary(
        _ source: [UInt8], result: inout [UInt8],
        width: Int, height: Int, faceWidth: Float,
        run: FaceContourLateralRuns.Run, isLeftSide: Bool,
        requested: Float,
        protected: inout Bool,
        trace: inout SourceRunTrace,
        sourceContourSpan: Float = 0,
        sourceProtection: SourceProtection? = nil,
        isCleanAnalysis: Bool = false,
        usesScaleSeparatedSourceModel: Bool = false,
        onCleanFieldSample: ((Int, Int, Float) -> Void)? = nil,
        onCleanEdgeRow: ((Int, Float) -> Void)? = nil,
        onCleanTargetEdgeRow: ((Int, Float, Float) -> Void)? = nil
    ) -> Bool {
        guard let first = run.ordered.first, let last = run.ordered.last,
              faceWidth.isFinite, faceWidth > 0 else { return false }
        let start = max(0, Int(ceil(first.y * Float(height) - 0.5)))
        let end = min(height, Int(ceil(last.y * Float(height) - 0.5)))
        guard end - start >= 80 else { return false }
        let facePixels = faceWidth * Float(width)
        let searchRadius = min(48, max(8, Int((facePixels * 0.08).rounded())))
        let outerRadius = min(32, max(8, Int((facePixels * 0.05).rounded())))
        let maximumShift = min(6, max(0.5, facePixels * 0.01))
        let smoothingRadius = min(24, max(8, Int((facePixels * 0.035).rounded())))
        let inset = max(20, (end - start) / 12)
        // The upper run includes the ear/temple junction. Its silhouette can
        // be a stronger edge than the cheek. An admitted wide pass leaves
        // that upper portion untouched by this raster preprocessor.
        let activeStart = start + max(inset, Int(Float(end - start) * 0.48))
        let activeEnd = end - inset
        guard activeEnd - activeStart >= 40 else { return false }

        var centers = [Float?](repeating: nil, count: end - start)
        var edges = [Float?](repeating: nil, count: end - start)
        var directions = [Int?](repeating: nil, count: end - start)
        var ambiguousRows = 0
        var weakRows = 0
        var boundedHairRows = 0
        var hairRows = [Bool](repeating: false, count: end - start)
        var hairColumns = [Int?](repeating: nil, count: end - start)
        var boundaryStates = [BoundaryDetection](repeating: .unavailable, count: end - start)
        var segment = 0
        for row in start..<end {
            let y = (Float(row) + 0.5) / Float(height)
            while segment + 1 < run.ordered.count - 1 && y > run.ordered[segment + 1].y {
                segment += 1
            }
            let lower = run.ordered[segment]
            let upper = run.ordered[segment + 1]
            let progress = (y - lower.y) / (upper.y - lower.y)
            let center = (lower.x + (upper.x - lower.x) * progress) * Float(width)
            guard center.isFinite else { return false }
            centers[row - start] = center
            if row >= activeStart && row < activeEnd {
                let rounded = Int(center.rounded())
                let lowerHair = max(0, rounded - searchRadius)
                let upperHair = min(width - 1, rounded + searchRadius)
                let hair = (lowerHair...upperHair).contains(where: { column in
                    let offset = (row * width + column) * 4
                    guard max(source[offset], source[offset + 1], source[offset + 2]) < 70 else { return false }
                    let inward = isLeftSide ? 1 : -1
                    return (1...4).contains(where: { multiple in
                        let reference = column + inward * min(32, max(8, width / 40)) * multiple
                        guard reference >= 0, reference < width else { return false }
                        let sample = (row * width + reference) * 4
                        return Int(source[sample]) - Int(source[sample + 2]) >= 18 &&
                            max(source[sample], source[sample + 1], source[sample + 2]) >= 90
                    })
                })
                let compactColumn = hair ? (lowerHair...upperHair).first(where: { column in
                    let offset = (row * width + column) * 4
                    guard max(source[offset], source[offset + 1], source[offset + 2]) < 70 else { return false }
                    return (1...4).contains(where: { multiple in
                        let distance = min(16, max(4, width / 80)) * multiple
                        guard column - distance >= 0, column + distance < width else { return false }
                        let outer = (row * width + column - distance) * 4
                        let inner = (row * width + column + distance) * 4
                        return min(source[outer], source[inner]) >= 90
                    })
                }) : nil
                if let compactColumn {
                    boundedHairRows += 1
                    hairRows[row - start] = true
                    hairColumns[row - start] = compactColumn
                }
            }
            let originalBoundary = strongOuterBoundary(
                source, width: width, row: row,
                center: Int(center.rounded()), searchRadius: searchRadius,
                isLeftSide: isLeftSide
            )
            boundaryStates[row - start] = originalBoundary
            let boundary: BoundaryDetection
            if isCleanAnalysis, case .unavailable = originalBoundary {
                boundary = qualifiedCandidateBoundary(source, width: width, row: row,
                    center: Int(center.rounded()), searchRadius: searchRadius,
                    candidateRadius: outerRadius, isLeftSide: isLeftSide)
                if case .found = boundary { trace.sourceRecenteredRows += 1 }
            } else { boundary = originalBoundary }
            switch boundary {
            case .found(let location, let direction):
                edges[row - start] = location
                directions[row - start] = direction
                if isCleanAnalysis, hairRows[row - start] {
                    let candidate = Int(location.rounded())
                    hairRows[row - start] = (max(0, candidate - outerRadius)...min(width - 1, candidate + outerRadius)).contains {
                        let p = (row * width + $0) * 4
                        return max(source[p], source[p + 1], source[p + 2]) < 70
                    }
                }
            case .ambiguous:
                if row >= activeStart && row < activeEnd { ambiguousRows += 1 }
            case .weak:
                if row >= activeStart && row < activeEnd { weakRows += 1 }
            case .unavailable: break
            }
        }
        trace.activeRows = activeEnd - activeStart
        trace.protectedHairRows = boundedHairRows
        if isCleanAnalysis {
            protected = boundedHairRows > 0
            let geometryCenters: [Float]?, geometryTrend: [Float]?
            if usesScaleSeparatedSourceModel {
                let raw = centers.compactMap { $0 }
                guard raw.count == centers.count else { return true }
                let weights = raw.indices.map { i -> Float in
                    let t = min(1, Float(i) / 20, Float(raw.count - 1 - i) / 20)
                    return t * t * (3 - 2 * t)
                }
                guard let trend = sourceLowFrequencyTrend(raw, weights: weights,
                    envelopeRadius: smoothingRadius) else { return true }
                geometryCenters = raw; geometryTrend = trend
            } else { geometryCenters = nil; geometryTrend = nil }
            refineSourceCleanSegments(source, result: &result, width: width, height: height,
                start: start, activeStart: activeStart, activeEnd: activeEnd,
                edges: edges, directions: directions, hairRows: hairRows,
                smoothingRadius: smoothingRadius, outerRadius: outerRadius,
                maximumShift: maximumShift, requested: requested, trace: &trace,
                onFieldSample: onCleanFieldSample, onEdgeRow: onCleanEdgeRow,
                onTargetEdgeRow: onCleanTargetEdgeRow,
                geometryCenters: geometryCenters, geometryTrend: geometryTrend)
            return true
        }
        if let sourceProtection {
            protected = boundedHairRows > 0
            // Preserve sustained-occlusion and contradictory-edge refusal.
            // A bounded local occluder can receive a source-geometry term
            // inside the admitted transition, without acquiring an inferred
            // colour edge or weakening the former dominant-hair negative.
            guard boundedHairRows < (activeEnd - activeStart) * 2 / 3 else { return true }
            let permitsGeometry = ambiguousRows < max(20, (activeEnd - activeStart) / 4) &&
                weakRows < max(20, (activeEnd - activeStart) * 2 / 3)
            refineCompleteObservedShape(source, result: &result, width: width, height: height,
                faceWidth: faceWidth, run: run, isLeftSide: isLeftSide,
                requested: requested, maximumShift: maximumShift, nativeOuterRadius: outerRadius,
                nativeStart: start, nativeHairRows: hairRows, nativeHairColumns: hairColumns,
                nativeCenters: centers, nativeBoundaryStates: boundaryStates,
                nativeContourSpan: sourceContourSpan * Float(width), trace: &trace,
                sourceProtection: sourceProtection, permitsGeometry: permitsGeometry)
            return true
        }
        // A compact dark band bounded by brighter pixels can be foreground
        // hair crossing a chromatic cheek edge. With many such rows, neither
        // the broad edge pass nor a contour-centered fallback is safe.
        let wholeSideHairGuard = boundedHairRows >= max(20, (activeEnd - activeStart) / 8)
        var continuousHair = 0, maximumContinuousHair = 0, priorHairColumn: Int?
        for row in activeStart..<activeEnd {
            if let column = hairColumns[row - start] {
                continuousHair = priorHairColumn.map { abs(column - $0) <= 4 } == true ? continuousHair + 1 : 1
                priorHairColumn = column
            } else { continuousHair = 0; priorHairColumn = nil }
            maximumContinuousHair = max(maximumContinuousHair, continuousHair)
        }
        if wholeSideHairGuard || maximumContinuousHair >= 8 {
            protected = true
            // The former dominant, sustained occluder remains a whole-side
            // no-op. A local supplement needs a substantial clean source
            // portion, rather than the short tail after a sustained hair band.
            guard boundedHairRows < (activeEnd - activeStart) * 2 / 3 else { return true }
            // The original whole-side guard still removes proxy work. A
            // separate complete source-clean segment may repair only its
            // own visible edge; every suspected hair row and neighborhood
            // remains source-exact, with no inferred rows across an occluder.
            refineNormalizedCleanSegments(source, result: &result, width: width, height: height,
                faceWidth: faceWidth, run: run, isLeftSide: isLeftSide,
                requested: requested, maximumShift: maximumShift,
                nativeOuterRadius: outerRadius,
                nativeStart: start, nativeHairRows: hairRows,
                nativeHairColumns: hairColumns,
                nativeCenters: centers, nativeBoundaryStates: boundaryStates,
                nativeContourSpan: sourceContourSpan * Float(width), trace: &trace)
            return true
        }
        // Many competing edges make the entire side unsafe to infer. Do not
        // fall back to a point-center shift that could follow one of them.
        if ambiguousRows >= max(20, (activeEnd - activeStart) / 4) {
            return true
        }
        // A coherent but weak source edge cannot justify either the wider
        // shift or the old point-centered shift near the ear junction.
        if weakRows >= max(20, (activeEnd - activeStart) * 2 / 3) {
            return true
        }

        let activeDirections = (activeStart..<activeEnd).compactMap { directions[$0 - start] }
        let positive = activeDirections.filter { $0 > 0 }.count
        let negative = activeDirections.count - positive
        guard max(positive, negative) >= max(40, (activeEnd - activeStart) * 2 / 3)
        else {
            // A well-observed but contradictory edge is unsafe for either
            // wide correction or point-centered fallback.
            return activeDirections.count >= max(40, (activeEnd - activeStart) * 2 / 3)
        }
        let dominantDirection = positive >= negative ? 1 : -1
        for row in start..<end where directions[row - start] != dominantDirection {
            edges[row - start] = nil
        }

        let admitted = (activeStart..<activeEnd).compactMap { row -> Float? in
            guard let center = centers[row - start], let edge = edges[row - start] else { return nil }
            return abs(center - edge)
        }
        guard admitted.count >= max(40, (activeEnd - activeStart) * 2 / 3),
              admitted.reduce(0, +) / Float(admitted.count) >= 2.5
        else { return false }

        let activeEdges = (activeStart..<activeEnd).compactMap { edges[$0 - start] }
        guard let minimumEdge = activeEdges.min(), let maximumEdge = activeEdges.max(),
              var field = LegacyCapField(
                lowerColumn: max(0, Int(minimumEdge.rounded()) - outerRadius),
                upperColumn: min(width - 1, Int(maximumEdge.rounded()) + outerRadius),
                startRow: activeStart, endRow: activeEnd)
        else { return true }
        let feather = min(8, Float(outerRadius) / 2)
        for row in activeStart..<activeEnd {
            guard let boundary = edges[row - start], let center = centers[row - start] else { continue }
            var weightedSum: Float = 0
            var totalWeight: Float = 0
            var valid = 0
            for neighbor in max(start, row - smoothingRadius)...min(end - 1, row + smoothingRadius) {
                guard let value = edges[neighbor - start] else { continue }
                let weight = Float(smoothingRadius + 1 - abs(neighbor - row))
                weightedSum += value * weight
                totalWeight += weight
                valid += 1
            }
            guard valid >= smoothingRadius,
                  totalWeight > 0 else { continue }
            let target = weightedSum / totalWeight
            let endWeight = min(
                1, Float(row - activeStart + 1) / 20,
                Float(activeEnd - row) / 20
            )
            let shift = max(-maximumShift, min(maximumShift, target - boundary)) * endWeight
            guard shift.isFinite, abs(shift) >= 0.05 else { continue }
            let edgeColumn = Int(boundary.rounded())
            for column in max(0, edgeColumn - outerRadius)...min(width - 1, edgeColumn + outerRadius) {
                let distance = abs(Float(column) - boundary)
                let xWeight = min(1, max(0, (Float(outerRadius) - distance) / feather))
                let domainWeight = sourceContourWeight(column: Float(column), center: center,
                    span: sourceContourSpan * Float(width), isLeftSide: isLeftSide)
                let capShift = shift * xWeight * domainWeight
                let sampleX = Float(column) - capShift
                guard xWeight > 0, sampleX >= 0,
                      sampleX <= Float(width - 1), domainWeight > 0 else { continue }
                let x0 = Int(floor(sampleX))
                let x1 = min(width - 1, x0 + 1)
                guard (min(column, x0)...max(column, x1)).allSatisfy({
                    sourceContourWeight(column: Float($0), center: center,
                        span: sourceContourSpan * Float(width), isLeftSide: isLeftSide) > 0 &&
                        source[(row * width + $0) * 4 + 3] == 255
                }) else { trace.nativeFootprintRejectedPixels += 1; continue }
                field.shifts[(row - field.originY) * field.width + column - field.originX] = capShift
            }
        }
        applyLegacyCapField(field, source: source, result: &result, width: width,
            height: height, requested: requested)
        return true
    }

    private static func refineSourceCleanSegments(
        _ source: [UInt8], result: inout [UInt8], width: Int, height: Int,
        start: Int, activeStart: Int, activeEnd: Int,
        edges: [Float?], directions: [Int?], hairRows: [Bool],
        smoothingRadius: Int, outerRadius: Int, maximumShift: Float,
        requested: Float, trace: inout SourceRunTrace,
        onFieldSample: ((Int, Int, Float) -> Void)? = nil,
        onEdgeRow: ((Int, Float) -> Void)? = nil,
        onTargetEdgeRow: ((Int, Float, Float) -> Void)? = nil,
        geometryCenters: [Float]? = nil, geometryTrend: [Float]? = nil
    ) {
        var safe = [Bool](repeating: false, count: edges.count)
        for row in activeStart..<activeEnd {
            let i = row - start
            let guardRadius = max(20, smoothingRadius) + 2
            safe[i] = edges[i] != nil && directions[i] != nil &&
                !hairRows[max(0, i - guardRadius)...min(hairRows.count - 1, i + guardRadius)].contains(true)
            if safe[i] { trace.cleanBoundaryRows += 1 }
        }
        var first = activeStart
        while first < activeEnd {
            guard safe[first - start], let polarity = directions[first - start] else { first += 1; continue }
            var last = first + 1
            while last < activeEnd && safe[last - start] && directions[last - start] == polarity { last += 1 }
            let count = last - first
            trace.maximumCleanSegmentRows = max(trace.maximumCleanSegmentRows, count)
            defer { first = last }
            guard count >= 40 else { continue }
            let boundary = (first..<last).compactMap { edges[$0 - start] }
            guard boundary.count == count else { continue }
            for i in boundary.indices { onEdgeRow?(first + i, boundary[i]) }
            var residual = [Float](repeating: 0, count: count), taper = residual
            for i in boundary.indices {
                let t = min(1, Float(i) / 20, Float(count - 1 - i) / 20)
                taper[i] = t * t * (3 - 2 * t)
            }
            // Fair only the complete admitted source segment, using the
            // former physical radius and a local source envelope. Centering,
            // endpoint taper and the former shift ceiling remain unchanged.
            let target: [Float], usesGeometryTrend: Bool
            if let geometryCenters, let geometryTrend {
                guard geometryCenters.count == edges.count, geometryTrend.count == edges.count else { continue }
                // The complete observed side owns long-scale shape. A local
                // visible segment owns only its detector-to-material residual;
                // it must not redefine the low-frequency shape at each hair
                // interruption. No source rows are inferred across a gap.
                let localGeometry = Array(geometryCenters[(first - start)..<(last - start)])
                let sourceResidual = zip(boundary, localGeometry).map { $0.0 - $0.1 }
                guard let residualTrend = sourceLowFrequencyTrend(sourceResidual, weights: taper,
                    envelopeRadius: smoothingRadius) else { continue }
                var proposed = boundary
                for i in boundary.indices {
                    let envelope = boundary[max(0, i - smoothingRadius)...min(count - 1, i + smoothingRadius)]
                    proposed[i] = min(envelope.max()!, max(envelope.min()!,
                        geometryTrend[first - start + i] + residualTrend[i]))
                }
                proposed[0] = boundary[0]; proposed[1] = boundary[1]
                proposed[count - 2] = boundary[count - 2]; proposed[count - 1] = boundary[count - 1]
                target = proposed; usesGeometryTrend = true
            } else {
                guard let localTarget = sourceCleanCurveTargets(boundary, weights: taper,
                    smoothingRadius: smoothingRadius) else { continue }
                target = localTarget; usesGeometryTrend = false
            }
            for i in boundary.indices { residual[i] = target[i] - boundary[i] }
            let total = taper.reduce(0, +)
            guard total > 0 else { continue }
            // The geometry trend is centred over the complete observed side;
            // its residual is centred over this visible source segment. A
            // second local re-centring would erase the long-scale shape term.
            let mean = usesGeometryTrend ? 0 : zip(residual, taper).reduce(Float.zero) { $0 + $1.0 * $1.1 } / total
            var delta = zip(residual, taper).map { ($0.0 - mean) * $0.1 }
            guard let maximum = delta.map({ abs($0) }).max(), maximum >= 0.05 else { continue }
            let scale = min(1, maximumShift / maximum)
            // C1 compact support plus a conservative no-fold slope bound.
            // Centering prevents this smoother from becoming a width edit.
            delta = delta.map { $0 * scale * requested }
            var changed = false
            for i in boundary.indices {
                let row = first + i, edge = boundary[i], shift = delta[i]
                // Keep the fitted destination curve separate from this
                // analysis raster's quantized source-edge phase.
                onTargetEdgeRow?(row, edge + shift, taper[i])
                // The segment's source residual already passed .05 above.
                // Preserve the continuous cap field through its zeroes.
                guard abs(shift) > Float.ulpOfOne else { continue }
                let edgeColumn = Int(edge.rounded())
                for column in max(0, edgeColumn - outerRadius)...min(width - 1, edgeColumn + outerRadius) {
                    let distance = abs(Float(column) - edge) / Float(outerRadius)
                    let xWeight = pow(max(0, 1 - distance * distance), 2)
                    let sample = Float(column) - shift * xWeight
                    guard xWeight > 0, sample >= 0, sample < Float(width - 1) else { continue }
                    let x0 = Int(floor(sample)), x1 = x0 + 1, fraction = sample - Float(x0)
                    let destination = (row * width + column) * 4
                    let a = (row * width + x0) * 4, b = (row * width + x1) * 4
                    guard source[destination + 3] == 255, source[a + 3] == 255, source[b + 3] == 255 else { continue }
                    onFieldSample?(column, row, shift * xWeight)
                    for c in 0..<3 {
                        let value = UInt8(min(255, max(0, Int((Float(source[a + c]) +
                            (Float(source[b + c]) - Float(source[a + c])) * fraction).rounded()))))
                        changed = changed || value != source[destination + c]
                        result[destination + c] = value
                    }
                }
            }
            if changed { trace.admittedCleanSegments += 1 }
        }
    }

    /// Complete fresh geometry owns shape where a local source edge is
    /// occluded. A qualified native source edge instead owns its whole joint
    /// target g+h_low. Qualification blends between those two descriptions;
    /// the geometry term is never added twice. Both share one source profile,
    /// gradient projection and immutable-source sampling operation.
    private static func refineCompleteObservedShape(
        _ source: [UInt8], result: inout [UInt8], width: Int, height: Int,
        faceWidth: Float, run: FaceContourLateralRuns.Run, isLeftSide: Bool,
        requested: Float, maximumShift: Float, nativeOuterRadius: Int, nativeStart: Int,
        nativeHairRows: [Bool], nativeHairColumns: [Int?],
        nativeCenters: [Float?], nativeBoundaryStates: [BoundaryDetection],
        nativeContourSpan: Float, trace: inout SourceRunTrace,
        sourceProtection: SourceProtection, permitsGeometry: Bool
    ) {
        guard permitsGeometry else {
            refineNormalizedCleanSegments(source, result: &result, width: width, height: height,
                faceWidth: faceWidth, run: run, isLeftSide: isLeftSide, requested: requested,
                maximumShift: maximumShift, nativeOuterRadius: nativeOuterRadius,
                nativeStart: nativeStart, nativeHairRows: nativeHairRows, nativeHairColumns: nativeHairColumns,
                nativeCenters: nativeCenters, nativeBoundaryStates: nativeBoundaryStates,
                nativeContourSpan: nativeContourSpan, trace: &trace, sourceProtection: sourceProtection)
            return
        }
        let centers = nativeCenters.compactMap { $0 }
        guard centers.count == nativeCenters.count, centers.count >= 40,
              let minimum = centers.min(), let maximum = centers.max() else { return }
        let physicalScale = Float(1920) / Float(max(width, height))
        let weights = centers.indices.map { i -> Float in
            let t = min(1, Float(i) * physicalScale / 20,
                Float(centers.count - 1 - i) * physicalScale / 20)
            return t * t * (3 - 2 * t)
        }
        let analysisRadius = min(24, max(8, Int((faceWidth * Float(width) * physicalScale * 0.035).rounded())))
        guard let trend = sourceLowFrequencyTrend(centers, weights: weights,
            envelopeRadius: max(1, Int(ceil(Float(analysisRadius) / physicalScale)))) else { return }
        let search = min(48, max(8, Int((faceWidth * Float(width) * 0.08).rounded())))
        let geometryReach = Int(ceil(sourceProtection.scope.radius + Double(maximumShift)))
        let left = max(0, Int(floor(minimum)) - search - max(nativeOuterRadius, geometryReach) - 4)
        let right = min(width - 1, Int(ceil(maximum)) + search + max(nativeOuterRadius, geometryReach) + 4)
        let top = max(0, nativeStart - 2), bottom = min(height - 1, nativeStart + centers.count + 1)
        let w = right - left + 1, h = bottom - top + 1
        guard w > 1, h > 1 else { return }
        var shape = [Float](repeating: 0, count: w * h)
        var jointCorrection = [Float?](repeating: nil, count: centers.count)
        var jointWeight = [Float](repeating: 0, count: centers.count)
        // This source-only curve is independent of any RGB edge selection.
        // Missing/occluded material rows receive no estimated RGB residual.
        for i in centers.indices {
            let y = nativeStart + i
            guard y >= top, y <= bottom else { continue }
            let center = centers[i]
            let correction = max(-maximumShift, min(maximumShift, trend[i] - center)) * weights[i]
            guard abs(correction) > Float.ulpOfOne else { continue }
            var admitted = false
            for x in left...right {
                guard sourceProtection.allows(x: x, y: y) else { continue }
                let domain = sourceContourWeight(column: Float(x), center: center,
                    span: nativeContourSpan, isLeftSide: isLeftSide)
                // g-c is a contour shape term, not a colour-edge registration
                // kernel. Its only lateral profile is the fixed circle's C1
                // distance weight; an extra raw-centred phase kernel can miss
                // a supported visible edge and deform texture instead.
                let amount = correction * domain * sourceProtection.weight(x: x, y: y)
                guard abs(amount) > Float.ulpOfOne,
                      sourceProtection.allowsSample(destination: x, sample: Float(x) - amount, row: y) else { continue }
                shape[(y - top) * w + x - left] = amount; admitted = true
            }
            if admitted { trace.admittedGeometryShapeRows += 1 }
        }
        var scratch = source
        refineNormalizedCleanSegments(source, result: &scratch, width: width, height: height,
            faceWidth: faceWidth, run: run, isLeftSide: isLeftSide, requested: requested,
            maximumShift: maximumShift, nativeOuterRadius: nativeOuterRadius,
            nativeStart: nativeStart, nativeHairRows: nativeHairRows, nativeHairColumns: nativeHairColumns,
            nativeCenters: nativeCenters, nativeBoundaryStates: nativeBoundaryStates,
            nativeContourSpan: nativeContourSpan, trace: &trace, sourceProtection: sourceProtection,
            onNativeTarget: { y, correction, weight in
                let row = y - nativeStart
                guard row >= 0, row < centers.count else { return }
                jointCorrection[row] = correction; jointWeight[row] = weight
            })
        var field = shape
        for y in top...bottom { for x in left...right {
            let i = (y - top) * w + x - left
            let row = y - nativeStart
            let amount: Float
            if row >= 0, row < centers.count, let correction = jointCorrection[row] {
                // One native source edge e owns one joint target g+h_low.
                // The qualified correction already contains its g term.
                // Blend out the independent geometry term with the SAME
                // source qualification weight, then use one shared profile.
                let profile = sourceContourWeight(column: Float(x), center: centers[row],
                    span: nativeContourSpan, isLeftSide: isLeftSide) * sourceProtection.weight(x: x, y: y)
                amount = max(-maximumShift, min(maximumShift,
                    shape[i] * (1 - jointWeight[row]) + correction * profile))
            } else { amount = shape[i] }
            guard abs(amount) > Float.ulpOfOne,
                  sourceProtection.allows(x: x, y: y),
                  sourceProtection.allowsSample(destination: x, sample: Float(x) - amount, row: y) else {
                field[i] = 0; continue
            }
            field[i] = amount
        } }
        trace.geometryShapeOnlyRows = centers.indices.filter { row in
            jointCorrection[row] == nil && (0..<w).contains { shape[(nativeStart + row - top) * w + $0] != 0 }
        }.count
        trace.nativeCandidatePixels = field.filter { abs($0) >= 0.05 }.count
        trace.maximumNativeShiftBeforeConstraint = field.map { abs($0) }.max() ?? 0
        guard let bounded = constrainedProtectedSourceField(field, width: w, height: h) else { return }
        trace.maximumNativeShiftAfterConstraint = bounded.map { abs($0) }.max() ?? 0
        trace.nativeMappedFieldPixels = bounded.filter { $0 != 0 }.count
        for y in 0..<(h - 1) { for x in 0..<(w - 1) {
            let i = y * w + x, a = bounded[i + 1] - bounded[i], b = bounded[i + w] - bounded[i]
            let c = bounded[i + w + 1] - bounded[i + w], d = bounded[i + w + 1] - bounded[i + 1]
            trace.maximumNativeGeometryGradient = max(trace.maximumNativeGeometryGradient,
                hypot(a, b), hypot(a, d), hypot(c, b), hypot(c, d))
        } }
        var changed = 0
        for y in top...bottom { for x in left...right {
            let shift = bounded[(y - top) * w + x - left] * requested
            guard abs(shift) > Float.ulpOfOne,
                  sourceProtection.allowsSample(destination: x, sample: Float(x) - shift, row: y) else { continue }
            let sample = Float(x) - shift, sx = Int(floor(sample)), fraction = sample - Float(sx)
            let dst = (y * width + x) * 4, a = (y * width + sx) * 4, b = a + 4
            guard source[dst + 3] == 255, source[a + 3] == 255, source[b + 3] == 255 else { continue }
            var different = false
            for c in 0..<3 {
                let value = Float(source[a + c]) + (Float(source[b + c]) - Float(source[a + c])) * fraction
                let byte = UInt8(min(255, max(0, Int(value.rounded()))))
                result[dst + c] = byte; different = different || byte != source[dst + c]
            }
            if different { changed += 1 }
        } }
        trace.nativeChangedPixels = changed
        trace.admittedCleanSegments = changed > 0 ? trace.analysisAdmittedCleanSegments : 0
    }

    /// Curvature fairing over one complete source segment, at the former
    /// physical smoothing radius. The fixed source endpoint pairs retain
    /// broad linear/cubic shape, and every target stays within its local
    /// source envelope. No missing rows are inferred by this solve.
    static func sourceCleanCurveTargets(
        _ boundary: [Float], weights: [Float], smoothingRadius: Int = 24
    ) -> [Float]? {
        guard boundary.count >= 40, weights.count == boundary.count, smoothingRadius > 0,
              boundary.allSatisfy(\.isFinite), weights.allSatisfy({ $0.isFinite && $0 >= 0 }) else { return nil }
        let weightSum = weights.reduce(Double.zero) { $0 + Double($1) }
        guard weightSum > 0 else { return nil }
        let origin = zip(boundary, weights).reduce(Double.zero) { $0 + Double($1.0) * Double($1.1) } / weightSum
        let source = boundary.map { Double($0) - origin }, n = boundary.count, count = boundary.count - 4
        let lambda = pow(Double(smoothingRadius) / 2, 4)
        var diagonal = [Double](repeating: 0, count: count), first = diagonal, second = diagonal
        var right = diagonal, intermediate = diagonal, solved = diagonal
        for i in 0..<count {
            let row = i + 2
            right[i] = source[row]
            for offset in [-2, -1, 1, 2] {
                let neighbor = row + offset
                if neighbor < 2 || neighbor >= n - 2 {
                    let coefficient = abs(offset) == 2 ? lambda : -4 * lambda
                    right[i] -= coefficient * source[neighbor]
                }
            }
            if i >= 2 { second[i] = lambda / diagonal[i - 2] }
            if i >= 1 { first[i] = (-4 * lambda - second[i] * first[i - 1]) / diagonal[i - 1] }
            let square = 1 + 6 * lambda - first[i] * first[i] - second[i] * second[i]
            guard square.isFinite, square > 0 else { return nil }
            diagonal[i] = sqrt(square)
            var value = right[i]
            if i >= 1 { value -= first[i] * intermediate[i - 1] }
            if i >= 2 { value -= second[i] * intermediate[i - 2] }
            intermediate[i] = value / diagonal[i]
        }
        for i in (0..<count).reversed() {
            var value = intermediate[i]
            if i + 1 < count { value -= first[i + 1] * solved[i + 1] }
            if i + 2 < count { value -= second[i + 2] * solved[i + 2] }
            solved[i] = value / diagonal[i]
        }
        var target = source, lower = source, upper = source
        for i in 2..<(n - 2) {
            target[i] = solved[i - 2]
            let neighbors = source[max(0, i - smoothingRadius)...min(n - 1, i + smoothingRadius)]
            lower[i] = neighbors.min() ?? source[i]
            upper[i] = neighbors.max() ?? source[i]
        }
        // One offset balances signed residual while respecting every source
        // window and retaining the fixed endpoint pairs. This prevents the
        // fairing solve's possible negative lobes from leaving that envelope.
        var low = (2..<(n - 2)).map { target[$0] - upper[$0] }.min() ?? 0
        var high = (2..<(n - 2)).map { target[$0] - lower[$0] }.max() ?? 0
        for _ in 0..<48 {
            let offset = (low + high) / 2
            var residual: Double = 0
            for i in 2..<(n - 2) {
                let value = min(upper[i], max(lower[i], target[i] - offset))
                residual += (value - source[i]) * Double(weights[i])
            }
            if residual > 0 { low = offset } else { high = offset }
        }
        let offset = (low + high) / 2
        for i in 2..<(n - 2) { target[i] = min(upper[i], max(lower[i], target[i] - offset)) }
        let result = target.map { Float($0 + origin) }
        return result.allSatisfy(\.isFinite) ? result : nil
    }

    /// A complete source side defines one low-frequency cubic shape trend.
    /// Unlike a short physical denoise kernel, it retains coherent curvature
    /// across the whole independently observed side. Cubic source shape is
    /// reproduced exactly; only higher-order residual is removed. The same
    /// local source envelope, pinned endpoint pairs and weighted centre bound
    /// the fit, without a strength multiplier or an enlarged edit domain.
    private static func sourceLowFrequencyTrend(
        _ source: [Float], weights: [Float], envelopeRadius: Int
    ) -> [Float]? {
        let n = source.count
        guard n >= 40, weights.count == n, envelopeRadius > 0,
              source.allSatisfy(\.isFinite), weights.allSatisfy({ $0.isFinite && $0 >= 0 }) else { return nil }
        let total = weights.reduce(Double.zero) { $0 + Double($1) }
        guard total > 0 else { return nil }
        let origin = zip(source, weights).reduce(Double.zero) { $0 + Double($1.0) * Double($1.1) } / total
        var system = Array(repeating: [Double](repeating: 0, count: 5), count: 4)
        for i in 0..<n {
            let t = 2 * Double(i) / Double(n - 1) - 1
            let basis = [1, t, t * t, t * t * t], weight = Double(weights[i])
            for row in 0..<4 {
                for column in 0..<4 { system[row][column] += weight * basis[row] * basis[column] }
                system[row][4] += weight * basis[row] * (Double(source[i]) - origin)
            }
        }
        for column in 0..<4 {
            guard let pivot = (column..<4).max(by: { abs(system[$0][column]) < abs(system[$1][column]) }),
                  abs(system[pivot][column]) > 0.000_000_000_1 else { return nil }
            system.swapAt(column, pivot)
            let divisor = system[column][column]
            for j in column...4 { system[column][j] /= divisor }
            for row in 0..<4 where row != column {
                let factor = system[row][column]
                for j in column...4 { system[row][j] -= factor * system[column][j] }
            }
        }
        var fit = source.map(Double.init), lower = fit, upper = fit
        for i in 2..<(n - 2) {
            let t = 2 * Double(i) / Double(n - 1) - 1
            fit[i] = origin + system[0][4] + t * (system[1][4] + t * (system[2][4] + t * system[3][4]))
            let envelope = source[max(0, i - envelopeRadius)...min(n - 1, i + envelopeRadius)]
            lower[i] = Double(envelope.min()!); upper[i] = Double(envelope.max()!)
        }
        var low = (2..<(n - 2)).map { fit[$0] - upper[$0] }.min()!, high = (2..<(n - 2)).map { fit[$0] - lower[$0] }.max()!
        for _ in 0..<48 {
            let offset = (low + high) / 2
            var residual = 0.0
            for i in 2..<(n - 2) {
                residual += (min(upper[i], max(lower[i], fit[i] - offset)) - Double(source[i])) * Double(weights[i])
            }
            if residual > 0 { low = offset } else { high = offset }
        }
        let offset = (low + high) / 2
        let result = source.indices.map { Float(min(upper[$0], max(lower[$0], fit[$0] - offset))) }
        return result.allSatisfy(\.isFinite) ? result : nil
    }

    private struct SourceHairHalo {
        let minX: Int, maxX: Int, minY: Int, maxY: Int
        let sourceWidth: Int
        func contains(_ x: Int, _ y: Int) -> Bool {
            x >= minX && x <= maxX && y >= minY && y <= maxY
        }
    }

    /// A halo needs the original compact-band evidence, both actual bright
    /// endpoints and warm support on the inner side of the source contour.
    /// Its whole source width must fit the unchanged physical edge support;
    /// an unknown wide dark mass retains its core without acquiring a halo.
    private static func compactSourceHairHalos(
        _ source: [UInt8], width: Int, height: Int, start: Int,
        hairRows: [Bool], hairColumns: [Int?], centers: [Float?], isLeftSide: Bool,
        physicalScale: Float, maximumPhysicalWidth: Float, trace: inout SourceRunTrace
    ) -> [SourceHairHalo] {
        guard hairRows.count == hairColumns.count, centers.count == hairRows.count,
              physicalScale.isFinite, physicalScale > 0, maximumPhysicalWidth > 0 else { return [] }
        let reach = min(16, max(4, width / 80)) * 4
        var halos = [SourceHairHalo]()
        for i in hairRows.indices where hairRows[i] {
            let y = start + i
            guard y >= 0, y < height, let seed = hairColumns[i], seed >= 0, seed < width else { continue }
            func dark(_ x: Int) -> Bool {
                let p = (y * width + x) * 4
                return source[p + 3] == 255 && max(source[p], source[p + 1], source[p + 2]) < 70
            }
            guard dark(seed) else { continue }
            var low = seed, high = seed
            while low > max(0, seed - reach), dark(low - 1) { low -= 1 }
            while high < min(width - 1, seed + reach), dark(high + 1) { high += 1 }
            guard low > 0, high < width - 1 else { continue }
            let a = (y * width + low - 1) * 4, b = (y * width + high + 1) * 4
            let inner = isLeftSide ? b : a
            guard source[a + 3] == 255, source[b + 3] == 255,
                  min(source[a], source[b]) >= 90,
                  Int(source[inner]) - Int(source[inner + 2]) >= 18 else {
                trace.nativeSourceHairHaloRejectedEndpoints += 1
                continue
            }
            let sourceWidth = high - low + 1
            guard Float(sourceWidth) * physicalScale <= maximumPhysicalWidth else {
                trace.nativeSourceHairHaloRejectedWidth += 1
                trace.maximumRejectedNativeSourceHairWidth = max(trace.maximumRejectedNativeSourceHairWidth, sourceWidth)
                continue
            }
            guard let center = centers[i], center >= Float(low - 2), center <= Float(high + 2) else {
                trace.nativeSourceHairHaloRejectedContourSplit += 1
                continue
            }
            let radius = sourceWidth + 2
            halos.append(SourceHairHalo(minX: max(0, low - radius), maxX: min(width - 1, high + radius),
                minY: max(0, y - radius), maxY: min(height - 1, y + radius), sourceWidth: sourceWidth))
        }
        return halos
    }

    private static func sourceProtectionDistances(_ hard: [Bool], width w: Int, height h: Int) -> [Float] {
        var distance = hard.map { $0 ? Float.zero : Float.infinity }
        let diagonal = Float(2).squareRoot()
        for y in 0..<h { for x in 0..<w {
            let i = y * w + x
            if x > 0 { distance[i] = min(distance[i], distance[i - 1] + 1) }
            if y > 0 {
                distance[i] = min(distance[i], distance[i - w] + 1)
                if x > 0 { distance[i] = min(distance[i], distance[i - w - 1] + diagonal) }
                if x + 1 < w { distance[i] = min(distance[i], distance[i - w + 1] + diagonal) }
            }
        } }
        for y in (0..<h).reversed() { for x in (0..<w).reversed() {
            let i = y * w + x
            if x + 1 < w { distance[i] = min(distance[i], distance[i + 1] + 1) }
            if y + 1 < h {
                distance[i] = min(distance[i], distance[i + w] + 1)
                if x > 0 { distance[i] = min(distance[i], distance[i + w - 1] + diagonal) }
                if x + 1 < w { distance[i] = min(distance[i], distance[i + w + 1] + diagonal) }
            }
        } }
        return distance
    }

    /// The new complete-support gate is expressed at one physical row scale.
    /// Only its displacement field returns to native size; final sampling
    /// always uses the original RGBA and native protection/shift ceilings.
    private static func refineNormalizedCleanSegments(
        _ source: [UInt8], result: inout [UInt8], width: Int, height: Int,
        faceWidth: Float, run: FaceContourLateralRuns.Run, isLeftSide: Bool,
        requested: Float, maximumShift: Float, nativeOuterRadius: Int, nativeStart: Int,
        nativeHairRows: [Bool], nativeHairColumns: [Int?],
        nativeCenters: [Float?], nativeBoundaryStates: [BoundaryDetection],
        nativeContourSpan: Float, trace: inout SourceRunTrace,
        sourceProtection: SourceProtection? = nil,
        onNativeTarget: ((Int, Float, Float) -> Void)? = nil
    ) {
        let scale = 1920.0 / Double(max(width, height))
        let aw = Int(floor(Double(width) * scale)), ah = Int(floor(Double(height) * scale))
        guard aw >= 128, ah >= 128 else { return }
        let analysis = normalizedOpaqueSource(source, width: width, height: height, targetWidth: aw, targetHeight: ah)
        var scratch = analysis, field = [Float](repeating: 0, count: aw * ah)
        var analysisEdges = [Float?](repeating: nil, count: ah)
        var analysisTargets = [Float?](repeating: nil, count: ah)
        var analysisPhaseWeights = [Float](repeating: 0, count: ah)
        let analysisOuterRadius = min(32, max(8, Int((faceWidth * Float(aw) * 0.05).rounded())))
        var firstColumns = [Int](repeating: aw, count: ah), lastColumns = [Int](repeating: -1, count: ah)
        var analysisProtected = false, analysisTrace = SourceRunTrace()
        _ = refineObservedBoundary(analysis, result: &scratch, width: aw, height: ah,
            faceWidth: faceWidth, run: run, isLeftSide: isLeftSide, requested: 1,
            protected: &analysisProtected, trace: &analysisTrace, isCleanAnalysis: true,
            usesScaleSeparatedSourceModel: sourceProtection != nil,
            onCleanFieldSample: { x, y, amount in
                field[y * aw + x] = amount
                firstColumns[y] = min(firstColumns[y], x); lastColumns[y] = max(lastColumns[y], x)
            }, onCleanEdgeRow: { y, edge in analysisEdges[y] = edge },
            onCleanTargetEdgeRow: { y, target, phaseWeight in
                guard sourceProtection != nil else { return }
                analysisTargets[y] = target; analysisPhaseWeights[y] = phaseWeight
                // Zero residual rows inside a qualified rough segment still
                // own a destination and can require native phase alignment.
                firstColumns[y] = min(firstColumns[y], max(0, Int(floor(target)) - analysisOuterRadius))
                lastColumns[y] = max(lastColumns[y], min(aw - 1, Int(ceil(target)) + analysisOuterRadius))
            })
        trace.cleanBoundaryRows = analysisTrace.cleanBoundaryRows
        trace.maximumCleanSegmentRows = analysisTrace.maximumCleanSegmentRows
        trace.analysisAdmittedCleanSegments = analysisTrace.admittedCleanSegments
        trace.cleanAnalysisLongEdge = 1920
        trace.sourceRecenteredRows = analysisTrace.sourceRecenteredRows
        guard analysisTrace.admittedCleanSegments > 0 else { return }
        let ratioX = Float(aw) / Float(width), ratioY = Float(ah) / Float(height)
        let validRows = firstColumns.indices.filter { lastColumns[$0] >= firstColumns[$0] }
        guard let firstRow = validRows.first, let lastRow = validRows.last,
              let firstColumn = validRows.map({ firstColumns[$0] }).min(),
              let lastColumn = validRows.map({ lastColumns[$0] }).max() else { return }
        let left = max(0, Int(floor((Float(firstColumn) + 0.5) / ratioX - 0.5)) - 2)
        let right = min(width - 1, Int(ceil((Float(lastColumn) + 0.5) / ratioX - 0.5)) + 2)
        let top = max(0, Int(floor((Float(firstRow) + 0.5) / ratioY - 0.5)) - 2)
        let bottom = min(height - 1, Int(ceil((Float(lastRow) + 0.5) / ratioY - 0.5)) + 2)
        let w = right - left + 1, h = bottom - top + 1
        guard w > 1, h > 1 else { return }
        func sourceCandidate(_ row: Int) -> Float? {
            let yy = (Float(row) + 0.5) * ratioY - 0.5
            guard yy >= 0, yy < Float(ah - 1) else { return nil }
            let y0 = Int(floor(yy)), f = yy - Float(y0)
            guard let a = analysisEdges[y0], let b = analysisEdges[y0 + 1] else { return nil }
            return (a * (1 - f) + b * f + 0.5) / ratioX - 0.5
        }
        func sourceTarget(_ row: Int) -> (edge: Float, phaseWeight: Float)? {
            let yy = (Float(row) + 0.5) * ratioY - 0.5
            guard yy >= 0, yy < Float(ah - 1) else { return nil }
            let y0 = Int(floor(yy)), f = yy - Float(y0)
            guard let a = analysisTargets[y0], let b = analysisTargets[y0 + 1] else { return nil }
            return ((a * (1 - f) + b * f + 0.5) / ratioX - 0.5,
                analysisPhaseWeights[y0] * (1 - f) + analysisPhaseWeights[y0 + 1] * f)
        }
        var relevantHair = [Bool](repeating: false, count: nativeHairRows.count)
        for i in nativeHairRows.indices where nativeHairRows[i] {
            guard let center = sourceCandidate(nativeStart + i) ?? nativeCenters[i] else { continue }
            let row = nativeStart + i, column = Int(center.rounded())
            relevantHair[i] = (max(0, column - nativeOuterRadius)...min(width - 1, column + nativeOuterRadius)).contains {
                let p = (row * width + $0) * 4
                return max(source[p], source[p + 1], source[p + 2]) < 70
            }
        }
        let hairHalos = compactSourceHairHalos(source, width: width, height: height,
            start: nativeStart, hairRows: relevantHair, hairColumns: nativeHairColumns,
            centers: nativeCenters, isLeftSide: isLeftSide, physicalScale: ratioX,
            maximumPhysicalWidth: Float(2 * analysisOuterRadius), trace: &trace)
        trace.nativeSourceHairHaloCount = hairHalos.count
        trace.maximumNativeSourceHairWidth = hairHalos.map(\.sourceWidth).max() ?? 0
        var core = [Bool](repeating: false, count: w * h)
        for y in top...bottom { for x in left...right {
            let p = (y * width + x) * 4
            core[(y - top) * w + x - left] = source[p + 3] != 255 ||
                max(source[p], source[p + 1], source[p + 2]) < 70
        } }
        var hard = core
        for y in 0..<h { for x in 0..<w where core[y * w + x] {
            for yy in max(0, y - 2)...min(h - 1, y + 2) {
                for xx in max(0, x - 2)...min(w - 1, x + 2) { hard[yy * w + xx] = true }
            }
        } }
        for halo in hairHalos {
            let minY = max(top, halo.minY), maxY = min(bottom, halo.maxY)
            let minX = max(left, halo.minX), maxX = min(right, halo.maxX)
            guard minY <= maxY, minX <= maxX else { continue }
            for y in minY...maxY { for x in minX...maxX {
                let i = (y - top) * w + x - left
                if !hard[i] { trace.nativeSourceHairHaloPixels += 1 }
                hard[i] = true
            } }
        }
        let protectionDistance = sourceProtectionDistances(hard, width: w, height: h)
        func protected(_ x: Int, _ y: Int) -> Bool {
            guard x >= 0, y >= 0, x < width, y < height else { return true }
            if x >= left, y >= top, x <= right, y <= bottom { return hard[(y - top) * w + x - left] }
            if hairHalos.contains(where: { $0.contains(x, y) }) { return true }
            // A full cap footprint can leave the stored field rectangle.
            // Its source core and AA neighborhood still own those samples.
            for yy in max(0, y - 2)...min(height - 1, y + 2) {
                for xx in max(0, x - 2)...min(width - 1, x + 2) {
                    let p = (yy * width + xx) * 4
                    if source[p + 3] != 255 || max(source[p], source[p + 1], source[p + 2]) < 70 { return true }
                }
            }
            return false
        }
        func sourceDomainRadius(_ x: Float, row: Int) -> Float? {
            let i = row - nativeStart
            guard i >= 0, i < nativeCenters.count, let center = nativeCenters[i], nativeContourSpan > 0 else { return nil }
            let inside = isLeftSide ? x >= center : x <= center
            return nativeContourSpan * (inside ? 0.20 : 0.06)
        }
        func isInSourceDomain(_ x: Float, row: Int) -> Bool {
            guard let radius = sourceDomainRadius(x, row: row), let center = nativeCenters[row - nativeStart] else { return false }
            return abs(x - center) <= radius
        }
        var nativeField = [Float](repeating: 0, count: w * h)
        for y in top...bottom {
            let rowIndex = y - nativeStart
            guard rowIndex >= 0, rowIndex < nativeBoundaryStates.count,
                  let center = sourceCandidate(y) else { continue }
            switch nativeBoundaryStates[rowIndex] {
            case .ambiguous: trace.nativeAmbiguousRows += 1; continue
            case .weak: trace.nativeWeakRows += 1; continue
            case .found, .unavailable: break
            }
            let candidate = Int(center.rounded())
            let nativeQualification = strongOuterBoundary(source, width: width, row: y,
                center: candidate, searchRadius: nativeOuterRadius, isLeftSide: isLeftSide)
            guard case .found(let nativeEdge, _) = nativeQualification,
                  abs(nativeEdge - center) < 4
            else { trace.nativeRejectedCandidateRows += 1; continue }
            let nativeTarget: (edge: Float, phaseWeight: Float)?
            if sourceProtection != nil {
                guard let target = sourceTarget(y) else { continue }
                nativeTarget = target
            } else { nativeTarget = nil }
            if case .unavailable = nativeBoundaryStates[rowIndex] {
                guard candidateHasOpaqueWarmSupport(source, width: width, row: y,
                    center: candidate, radius: nativeOuterRadius, isLeftSide: isLeftSide)
                else { trace.nativeRejectedCandidateRows += 1; continue }
                trace.nativeRequalifiedRows += 1
            }
            // These guard/fade distances belong to the 1920-unit clean
            // analysis, just like its 40-row qualification. Compare native
            // source rows in that same physical unit before applying them.
            let nativeSearch = max(1, Int(ceil(42 / ratioY)))
            var nearest = nativeSearch
            for i in max(0, rowIndex - nativeSearch)...min(relevantHair.count - 1, rowIndex + nativeSearch) where relevantHair[i] {
                nearest = min(nearest, abs(i - rowIndex))
            }
            let physicalDistance = Float(nearest) * ratioY
            guard physicalDistance > 22 else { trace.nativeHairGuardRows += 1; continue }
            let hairT = min(1, (physicalDistance - 22) / 20)
            let hairFade = hairT * hairT * (3 - 2 * hairT)
            let yy = (Float(y) + 0.5) * ratioY - 0.5
            guard yy >= 0, yy < Float(ah - 1) else { continue }
            let y0 = Int(floor(yy)), fy = yy - Float(y0)
            guard lastColumns[y0] >= firstColumns[y0], lastColumns[y0 + 1] >= firstColumns[y0 + 1] else { continue }
            if let target = nativeTarget, let onNativeTarget {
                // Native qualification supplies the observed source edge e.
                // This target already includes the complete geometry trend;
                // returning a second residual-only spatial field would apply
                // two incompatible profiles to the same physical boundary.
                let correction = (target.edge - center) + (center - nativeEdge) * target.phaseWeight
                onNativeTarget(y, max(-maximumShift, min(maximumShift, correction)) * hairFade,
                    min(1, max(0, target.phaseWeight * hairFade)))
                continue
            }
            let feather = min(8, Float(nativeOuterRadius) / 2)
            for x in left...right {
                if let sourceProtection, !sourceProtection.allows(x: x, y: y) {
                    trace.nativeGeometryRejectedPixels += 1; continue
                }
                guard !protected(x, y) else { trace.nativeCoreRejectedPixels += 1; continue }
                guard let sourceRadius = sourceDomainRadius(Float(x), row: y),
                      let sourceCenter = nativeCenters[rowIndex] else { continue }
                let sourceT = min(1, max(0, (sourceRadius - abs(Float(x) - sourceCenter)) / max(2, nativeContourSpan * 0.008)))
                let sourceFade = sourceT * sourceT * (3 - 2 * sourceT)
                guard sourceFade > 0 else { trace.nativeDomainRejectedPixels += 1; continue }
                let distance = abs(Float(x) - center)
                guard distance < Float(nativeOuterRadius) else { trace.nativeBandRejectedPixels += 1; continue }
                let t = min(1, max(0, (Float(nativeOuterRadius) - distance) / feather))
                let bandFade = t * t * (3 - 2 * t)
                let xx = (Float(x) + 0.5) * ratioX - 0.5
                guard xx >= 0, xx < Float(aw - 1) else { continue }
                let x0 = Int(floor(xx)), fx = xx - Float(x0)
                let rawShift: Float
                if let target = nativeTarget {
                    // The immutable source fit defines a DESTINATION edge.
                    // Recenter its residual on this native row's separately
                    // qualified edge, with the same source endpoint taper.
                    // Resizing a field alone retains analysis/native phase
                    // error and feathers the correction at the wrong x.
                    let correction = (target.edge - center) + (center - nativeEdge) * target.phaseWeight
                    let radius = Float(analysisOuterRadius) / ratioX
                    let normalizedDistance = (Float(x) - target.edge) / radius
                    let weight = pow(max(0, 1 - normalizedDistance * normalizedDistance), 2)
                    rawShift = correction * weight
                } else {
                    let a = field[y0 * aw + x0] * (1 - fx) + field[y0 * aw + x0 + 1] * fx
                    let b = field[(y0 + 1) * aw + x0] * (1 - fx) + field[(y0 + 1) * aw + x0 + 1] * fx
                    rawShift = (a * (1 - fy) + b * fy) / ratioX
                }
                var shift = max(-maximumShift, min(maximumShift, rawShift)) * hairFade * bandFade * sourceFade
                let d = protectionDistance[(y - top) * w + x - left]
                if d.isFinite {
                    let limit = 0.42 * (sqrt(d * d + 1) - 1)
                    let low = min(abs(shift), limit), high = max(abs(shift), limit)
                    guard high > 0 else { continue }
                    let magnitude = low / pow(1 + pow(low / high, 16), 0.0625)
                    shift = shift >= 0 ? magnitude : -magnitude
                }
                if let sourceProtection { shift *= sourceProtection.weight(x: x, y: y) }
                if abs(shift) > Float.ulpOfOne { trace.nativeMappedFieldPixels += 1 }
                guard abs(shift) > Float.ulpOfOne else { continue }
                let sample = Float(x) - shift
                guard sample >= 0, sample < Float(width - 1) else { continue }
                let sx = Int(floor(sample))
                guard abs(Float(sx) - center) <= Float(nativeOuterRadius),
                      abs(Float(sx + 1) - center) <= Float(nativeOuterRadius) else { continue }
                let dst = (y * width + x) * 4, first = (y * width + sx) * 4, second = first + 4
                guard source[dst + 3] == 255, source[first + 3] == 255, source[second + 3] == 255,
                      !protected(sx, y), !protected(sx + 1, y) else { continue }
                guard (min(x, sx)...max(x, sx + 1)).allSatisfy({
                    !protected($0, y) && source[(y * width + $0) * 4 + 3] == 255 && isInSourceDomain(Float($0), row: y)
                }) else { trace.nativeFootprintRejectedPixels += 1; continue }
                if let sourceProtection, !sourceProtection.allowsSample(destination: x, sample: sample, row: y) {
                    trace.nativeGeometryFootprintRejectedPixels += 1; continue
                }
                nativeField[(y - top) * w + x - left] = shift
            }
        }
        if onNativeTarget != nil { return }
        func reduce(_ i: Int, to value: Float) {
            let prior = nativeField[i]
            nativeField[i] = prior >= 0 ? max(0, min(prior, value)) : min(0, max(prior, value))
        }
        trace.nativeCandidatePixels = nativeField.filter { abs($0) >= 0.05 }.count
        trace.maximumNativeShiftBeforeConstraint = nativeField.map { abs($0) }.max() ?? 0
        func constrainPair(_ a: Int, _ b: Int, scale: Float) {
            let first = nativeField[a], second = nativeField[b]
            if first * second < 0 {
                // Opposite signs both approach zero. Choosing by the signed
                // difference alone cannot reduce the more negative endpoint.
                reduce(a, to: first * scale)
                reduce(b, to: second * scale)
            } else if abs(first) > abs(second) {
                reduce(a, to: second + (first - second) * scale)
            } else {
                reduce(b, to: first + (second - first) * scale)
            }
        }
        func constrain(_ i: Int, _ a: Int, _ b: Int) {
            let dx = nativeField[a] - nativeField[i], dy = nativeField[b] - nativeField[i]
            let gradient = hypot(dx, dy)
            guard gradient > 0.45 else { return }
            let scale = 0.45 / gradient
            constrainPair(i, a, scale: scale)
            constrainPair(i, b, scale: scale)
        }
        if sourceProtection != nil {
            // The source mask contributes zero nodes BEFORE projection. A
            // padded zero ring bounds every corner including field borders.
            guard let constrained = constrainedProtectedSourceField(nativeField, width: w, height: h) else { return }
            nativeField = constrained
        } else {
            for _ in 0..<8 {
                for y in 0..<(h - 1) { for x in 0..<(w - 1) { let i = y * w + x; constrain(i, i + 1, i + w) } }
                for y in (0..<(h - 1)).reversed() { for x in (0..<(w - 1)).reversed() { let i = y * w + x; constrain(i, i + 1, i + w) } }
            }
        }
        var maximumGradient: Float = 0
        for y in 0..<(h - 1) { for x in 0..<(w - 1) {
            let i = y * w + x
            maximumGradient = max(maximumGradient, hypot(nativeField[i + 1] - nativeField[i], nativeField[i + w] - nativeField[i]))
        } }
        if maximumGradient > 0.45 { nativeField = nativeField.map { $0 * 0.45 / maximumGradient } }
        if sourceProtection != nil {
            for y in 0..<(h - 1) { for x in 0..<(w - 1) {
                let i = y * w + x, top = nativeField[i + 1] - nativeField[i]
                let bottom = nativeField[i + w + 1] - nativeField[i + w]
                let left = nativeField[i + w] - nativeField[i], right = nativeField[i + w + 1] - nativeField[i + 1]
                trace.maximumNativeGeometryGradient = max(trace.maximumNativeGeometryGradient,
                    hypot(top, left), hypot(top, right), hypot(bottom, left), hypot(bottom, right))
            } }
        }
        trace.maximumNativeShiftAfterConstraint = nativeField.map { abs($0) }.max() ?? 0
        var changed = 0
        for y in top...bottom { for x in left...right {
            let shift = nativeField[(y - top) * w + x - left] * requested
            // Qualification retains its original .05 source residual gate.
            // Once constrained, sample the continuous cap field without a
            // second hard cutoff that could turn a .04/.48 pair into 0/.48.
            guard abs(shift) > Float.ulpOfOne, !protected(x, y) else { continue }
            let sample = Float(x) - shift
            guard sample >= 0, sample < Float(width - 1) else { continue }
            let sx = Int(floor(sample)), fraction = sample - Float(sx)
            let dst = (y * width + x) * 4, a = (y * width + sx) * 4, b = a + 4
            guard !protected(sx, y), !protected(sx + 1, y), source[dst + 3] == 255,
                  source[a + 3] == 255, source[b + 3] == 255 else { continue }
            if let sourceProtection, !sourceProtection.allowsSample(destination: x, sample: sample, row: y) { continue }
            var pixelChanged = false
            for c in 0..<3 {
                let value = Float(source[a + c]) + (Float(source[b + c]) - Float(source[a + c])) * fraction
                let byte = UInt8(min(255, max(0, Int(value.rounded()))))
                result[dst + c] = byte; pixelChanged = pixelChanged || byte != source[dst + c]
            }
            if pixelChanged { changed += 1 }
        } }
        trace.nativeChangedPixels = changed
        trace.admittedCleanSegments = changed > 0 ? analysisTrace.admittedCleanSegments : 0
    }

    /// An analysis pixel is opaque only when its full source footprint is.
    /// Upsampling changes the analysis unit, never the available evidence.
    private static func normalizedOpaqueSource(
        _ source: [UInt8], width: Int, height: Int, targetWidth: Int, targetHeight: Int
    ) -> [UInt8] {
        let rx = Double(width) / Double(targetWidth), ry = Double(height) / Double(targetHeight)
        var output = [UInt8](repeating: 0, count: targetWidth * targetHeight * 4)
        for y in 0..<targetHeight { for x in 0..<targetWidth {
            var values = [Double](repeating: 0, count: 3), weight = 0.0, opaque = true
            if rx >= 1 && ry >= 1 {
                let lowX = Double(x) * rx, highX = Double(x + 1) * rx
                let lowY = Double(y) * ry, highY = Double(y + 1) * ry
                for sy in max(0, Int(floor(lowY)))..<min(height, Int(ceil(highY))) {
                    for sx in max(0, Int(floor(lowX)))..<min(width, Int(ceil(highX))) {
                        let areaX = max(0, min(highX, Double(sx + 1)) - max(lowX, Double(sx)))
                        let areaY = max(0, min(highY, Double(sy + 1)) - max(lowY, Double(sy)))
                        let area = areaX * areaY, i = (sy * width + sx) * 4
                        guard area > 0 else { continue }
                        opaque = opaque && source[i + 3] == 255; weight += area
                        for c in 0..<3 { values[c] += Double(source[i + c]) * area }
                    }
                }
            } else {
                let xx = min(Double(width - 1), max(0, (Double(x) + 0.5) * rx - 0.5))
                let yy = min(Double(height - 1), max(0, (Double(y) + 0.5) * ry - 0.5))
                let x0 = Int(floor(xx)), y0 = Int(floor(yy)), fx = xx - Double(x0), fy = yy - Double(y0)
                for (sx, wx) in [(x0, 1 - fx), (min(width - 1, x0 + 1), fx)] {
                    for (sy, wy) in [(y0, 1 - fy), (min(height - 1, y0 + 1), fy)] {
                        let area = wx * wy, i = (sy * width + sx) * 4
                        guard area > 0 else { continue }
                        opaque = opaque && source[i + 3] == 255; weight += area
                        for c in 0..<3 { values[c] += Double(source[i + c]) * area }
                    }
                }
            }
            guard opaque, weight > 0 else { continue }
            let i = (y * targetWidth + x) * 4
            for c in 0..<3 { output[i + c] = UInt8(min(255, max(0, Int((values[c] / weight).rounded())))) }
            output[i + 3] = 255
        } }
        return output
    }

    /// A mapped source candidate keeps the old photometric and alpha gates.
    /// Its inner/outer prototypes must support a warm face edge in this actual
    /// source row; an interior texture peak cannot self-qualify by recentering.
    private static func candidateHasOpaqueWarmSupport(
        _ source: [UInt8], width: Int, row: Int, center: Int,
        radius: Int, isLeftSide: Bool
    ) -> Bool {
        let lower = center - radius - 4, upper = center + radius + 4
        guard lower >= 0, upper < width,
              (lower...upper).allSatisfy({ source[(row * width + $0) * 4 + 3] == 255 }) else { return false }
        let inward = isLeftSide ? 1 : -1
        let inner = center + inward * min(24, radius)
        let outer = center - inward * radius
        guard inner >= 2, outer >= 2, inner < width - 2, outer < width - 2 else { return false }
        let p = (row * width + inner) * 4
        return max(source[p], source[p + 1], source[p + 2]) >= 90 &&
            chroma(source, width: width, row: row, column: inner) -
            chroma(source, width: width, row: row, column: outer) >= 20
    }

    /// Only a former unavailable result may propose a new local candidate.
    /// Original ambiguous/weak rows remain vetoes. All candidates are actual
    /// source RGB peaks in the old search extent and are requalified within
    /// the unchanged field width; two distinct qualified edges still abstain.
    private static func qualifiedCandidateBoundary(
        _ source: [UInt8], width: Int, row: Int, center: Int,
        searchRadius: Int, candidateRadius: Int, isLeftSide: Bool
    ) -> BoundaryDetection {
        let lower = max(4, center - searchRadius), upper = min(width - 5, center + searchRadius)
        guard lower <= upper else { return .unavailable }
        var qualified: [(Float, Int)] = []
        for column in lower...upper {
            guard isLeftSide ? column <= center + 8 : column >= center - 8 else { continue }
            var contrast = 0, opaque = true
            for c in 0..<3 {
                var before = 0, after = 0
                for offset in 0..<4 {
                    let a = (row * width + column - 4 + offset) * 4
                    let b = (row * width + column + 1 + offset) * 4
                    opaque = opaque && source[a + 3] == 255 && source[b + 3] == 255
                    before += Int(source[a + c]); after += Int(source[b + c])
                }
                contrast += abs(before - after)
            }
            guard opaque, contrast / 12 >= 24,
                  candidateHasOpaqueWarmSupport(source, width: width, row: row,
                    center: column, radius: candidateRadius, isLeftSide: isLeftSide) else { continue }
            let local = strongOuterBoundary(source, width: width, row: row,
                center: column, searchRadius: candidateRadius, isLeftSide: isLeftSide)
            if case .found(let edge, let direction) = local, abs(edge - Float(column)) < 4 {
                qualified.append((edge, direction))
            }
        }
        guard let candidate = qualified.first else { return .unavailable }
        guard qualified.allSatisfy({ abs($0.0 - candidate.0) < 4 && $0.1 == candidate.1 }) else { return .ambiguous }
        return .found(candidate.0, candidate.1)
    }

    private static func strongOuterBoundary(
        _ source: [UInt8], width: Int, row: Int,
        center: Int, searchRadius: Int,
        isLeftSide: Bool
    ) -> BoundaryDetection {
        let lower = max(4, center - searchRadius)
        let upper = min(width - 5, center + searchRadius)
        guard lower <= upper else { return .unavailable }
        var candidates: [(column: Int, contrast: Int)] = []
        for column in lower...upper {
            let left = (row * width + column - 4) * 4
            let right = (row * width + column + 1) * 4
            guard (0..<4).allSatisfy({ offset in
                source[left + offset * 4 + 3] == 255 &&
                    source[right + offset * 4 + 3] == 255
            }) else { continue }
            var contrast = 0
            for channel in 0..<3 {
                var before = 0
                var after = 0
                for offset in 0..<4 {
                    before += Int(source[left + offset * 4 + channel])
                    after += Int(source[right + offset * 4 + channel])
                }
                contrast += abs(before - after)
            }
            candidates.append((column, contrast / 12))
        }
        guard let strongest = candidates.max(by: { $0.contrast < $1.contrast })
        else { return .unavailable }
        guard strongest.contrast >= 24 else {
            return chromaticOuterBoundary(
                source, width: width, row: row, center: center,
                searchRadius: searchRadius,
                isLeftSide: isLeftSide
            ) ?? (strongest.contrast >= 4 ? .weak : .unavailable)
        }
        let competing = candidates.filter {
            abs($0.column - strongest.column) >= 8 &&
                $0.contrast * 5 >= strongest.contrast * 2
        }
        if !competing.isEmpty {
            // A dark hair band can put one very strong edge outside the
            // observed contour and a weaker return edge just inside it. Even
            // when that second edge is not strong enough to win the search,
            // moving the outer edge would move hair instead of the cheek.
            // Rows with a nearby competing edge cannot anchor the wide pass.
            let outward = { (column: Int) in
                isLeftSide ? column <= center - 4 : column >= center + 4
            }
            let original: BoundaryDetection = outward(strongest.column) &&
                competing.contains(where: { outward($0.column) })
                ? .ambiguous : .unavailable
            // Two individually strong RGB edges can be a second silhouette or
            // an occluder even if a blurred hue signal merges them. Keep the
            // existing fail-closed result in that case.
            guard strongest.contrast < 40 else { return original }
            return chromaticOuterBoundary(
                source, width: width, row: row, center: center,
                searchRadius: searchRadius,
                isLeftSide: isLeftSide
            ) ?? original
        }
        guard isLeftSide ? strongest.column <= center + 8 : strongest.column >= center - 8 else {
            return chromaticOuterBoundary(
                source, width: width, row: row, center: center,
                searchRadius: searchRadius,
                isLeftSide: isLeftSide
            ) ?? .unavailable
        }
        // Either background can be lighter. The calling run admits only one
        // coherent contrast direction across its lower-cheek rows.
        let before = (row * width + strongest.column - 4) * 4
        let after = (row * width + strongest.column + 1) * 4
        let beforeLight = (0..<4).reduce(0) { sum, offset in
            sum + Int(source[before + offset * 4]) + Int(source[before + offset * 4 + 1]) +
                Int(source[before + offset * 4 + 2])
        }
        let afterLight = (0..<4).reduce(0) { sum, offset in
            sum + Int(source[after + offset * 4]) + Int(source[after + offset * 4 + 1]) +
                Int(source[after + offset * 4 + 2])
        }
        guard beforeLight != afterLight else {
            return chromaticOuterBoundary(
                source, width: width, row: row, center: center,
                searchRadius: searchRadius,
                isLeftSide: isLeftSide
            ) ?? .unavailable
        }
        return .found(Float(strongest.column) + 0.5, afterLight > beforeLight ? 1 : -1)
    }

    /// Fallback for source edges whose hue separates face and background while
    /// their averaged RGB brightness is too weak or locally textured. Both
    /// prototypes and the unique crossing come from the current source row.
    private static func chromaticOuterBoundary(
        _ source: [UInt8], width: Int, row: Int,
        center: Int, searchRadius: Int,
        isLeftSide: Bool
    ) -> BoundaryDetection? {
        let lower = max(4, center - searchRadius)
        let upper = min(width - 5, center + searchRadius)
        guard lower + 2 < upper else { return nil }
        let innerX = min(width - 3, max(2, center + (isLeftSide ? 24 : -24)))
        let outerX = min(width - 3, max(2,
            center + (isLeftSide ? -(searchRadius + 24) : searchRadius + 24)
        ))
        let inside = chroma(source, width: width, row: row, column: innerX)
        let outside = chroma(source, width: width, row: row, column: outerX)
        let separation = inside - outside
        guard abs(separation) >= 20 else { return nil }

        let midpoint = (inside + outside) / 2
        let polarity = separation > 0 ? 1 : -1
        func score(_ column: Int) -> Int {
            (chroma(source, width: width, row: row, column: column) - midpoint) * polarity
        }
        var crossings: [Int] = []
        for column in (lower + 1)..<upper {
            let exterior = isLeftSide ? column - 1 : column + 1
            if score(exterior) < 0 && score(column) >= 0 {
                crossings.append(column)
            }
        }
        guard let boundary = isLeftSide ? crossings.min() : crossings.max() else { return nil }
        guard crossings.allSatisfy({ abs($0 - boundary) < 4 }) else {
            return .ambiguous
        }
        guard isLeftSide ? boundary <= center + 8 : boundary >= center - 8 else {
            return nil
        }
        return .found(Float(boundary) + 0.5, polarity)
    }

    private static func chroma(
        _ source: [UInt8], width: Int, row: Int, column: Int
    ) -> Int {
        let base = (row * width + column) * 4
        var difference = 0
        for offset in -2...2 {
            difference += Int(source[base + offset * 4]) -
                Int(source[base + offset * 4 + 2])
        }
        return difference / 5
    }

    /// A single high-contrast edge near the observed contour reveals which
    /// pixel column owns that edge. Ambiguous or textured rows retain the
    /// existing bounded fractional alignment.
    private static func strongBoundaryShift(
        _ source: [UInt8],
        width: Int,
        row: Int,
        center: Int,
        continuousCenter: Float,
        isLeftSide: Bool
    ) -> Float? {
        let lower = max(0, center - 2)
        let upper = min(width - 2, center + 1)
        guard lower <= upper else { return nil }
        var largest = 0
        var second = 0
        var edgeColumn = lower
        for column in lower...upper {
            let first = (row * width + column) * 4
            let next = first + 4
            guard source[first + 3] == 255, source[next + 3] == 255 else { return nil }
            let contrast = (0..<3).reduce(0) {
                $0 + abs(Int(source[first + $1]) - Int(source[next + $1]))
            } / 3
            if contrast > largest {
                second = largest
                largest = contrast
                edgeColumn = column
            } else if contrast > second {
                second = contrast
            }
        }
        guard largest >= 64, second * 2 < largest else { return nil }
        let measuredCrossing = Float(edgeColumn) + 0.5
        let desiredCrossing = continuousCenter + (isLeftSide ? -0.5 : 0.5)
        let shift = desiredCrossing - measuredCrossing
        guard shift.isFinite, abs(shift) <= 1.5 else { return nil }
        return shift
    }

}
