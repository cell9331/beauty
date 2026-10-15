import Foundation

/// Request-local evidence for the lateral head attachments. This does not
/// identify ears or segment hair. The strict attachment proof and an independent
/// connected-inner-skin proofs can shorten the geometric reserve; all source
/// content outside a proved inner boundary remains fixed. Unknown rows
/// retain the broad reserve, including source-pixel sampling footprints.
enum BeautySourceContourAttachments {
    enum Side: Int, Sendable { case left = -1, right = 1 }

    struct Row: Sendable {
        let localY: Double
        let innerBoundaryX: Double
        let sourceBoundaryX: Double?
        let innerSkinBoundaryX: Double?
        let departureSkinBoundaryX: Double?
        var qualified: Bool { sourceBoundaryX != nil }
    }

    struct SideEvidence: Sendable {
        let side: Side
        let isQualified: Bool
        let rows: [Row]
        let diagnostics: AdmissionDiagnostics
        let innerSkinDiagnostics: AdmissionDiagnostics
        let departureSkinDiagnostics: AdmissionDiagnostics
        var hasInnerSkinRecovery: Bool { innerSkinDiagnostics.qualifiedRows > 0 }
        var hasDepartureSkinRecovery: Bool { departureSkinDiagnostics.qualifiedRows > 0 }
        var hasRecoveredReserve: Bool { isQualified || hasInnerSkinRecovery || hasDepartureSkinRecovery }
    }

    /// Aggregate admission counts only. No sampled colors, source positions,
    /// masks or private input identity are retained by these diagnostics.
    struct AdmissionDiagnostics: Equatable, Sendable {
        var totalRows = 0
        var candidateRows = 0
        var firstDepartureStrongJumpRows = 0
        var firstDepartureGradualRows = 0
        var departureWithoutPreviousSkinRows = 0
        var continuityBreaks = 0
        var shortRunRejectedRows = 0
        var nonReducingRows = 0
        var qualifiedRows = 0
        var adaptedSkinRows = 0
        fileprivate var rejections: [Rejection: Int] = [:]
        var rejectedRows: Int { rejections.values.reduce(0, +) }
        var aggregates: [String: Int] {
            var result = Dictionary(uniqueKeysWithValues: Rejection.allCases.map {
                ($0.rawValue, rejections[$0, default: 0])
            })
            result["totalRows"] = totalRows
            result["candidateRows"] = candidateRows
            result["firstDepartureStrongJumpRows"] = firstDepartureStrongJumpRows
            result["firstDepartureGradualRows"] = firstDepartureGradualRows
            result["departureWithoutPreviousSkinRows"] = departureWithoutPreviousSkinRows
            result["continuityBreaks"] = continuityBreaks
            result["shortRunRejectedRows"] = shortRunRejectedRows
            result["nonReducingRows"] = nonReducingRows
            result["qualifiedRows"] = qualifiedRows
            result["adaptedSkinRows"] = adaptedSkinRows
            return result
        }
        fileprivate mutating func reject(_ reason: Rejection) {
            rejections[reason, default: 0] += 1
        }
    }

    fileprivate enum Rejection: String, CaseIterable, Hashable, Sendable {
        case sourceUnavailableRows, observedIntersectionRejectedRows
        case seedSamplesRejectedRows, seedChromaRejectedRows, seedVarianceRejectedRows
        case innerSkinDepartureRejectedRows, observedAgreementRejectedRows
        case cleftWidthRejectedRows, outerAttachmentRejectedRows
        case roiSampleRejectedRows, missingAttachmentRejectedRows, competingCleftRejectedRows
    }

    struct Evidence: Sendable {
        let left: SideEvidence
        let right: SideEvidence
        private let origin: SIMD2<Double>
        private let axisX: SIMD2<Double>
        private let axisY: SIMD2<Double>
        private let width: Int
        private let height: Int
        private let reserveGroups: [[Reserve]]
        private let pixelHalfX: Double
        private let pixelHalfY: Double
        var reserveRegionCount: Int { reserveGroups.reduce(0) { $0 + $1.count } }

        fileprivate init(left: SideEvidence, right: SideEvidence,
                         width: Int, height: Int,
                         origin: SIMD2<Double>, axisX: SIMD2<Double>, axisY: SIMD2<Double>,
                         reserves: [Reserve], leftReserveCount: Int) {
            self.left = left; self.right = right
            self.origin = origin; self.axisX = axisX; self.axisY = axisY
            self.width = width; self.height = height
            reserveGroups = [Array(reserves[..<leftReserveCount]), Array(reserves[leftReserveCount...])]
            pixelHalfX = (abs(axisX.x) + abs(axisX.y)) * 0.5
            pixelHalfY = (abs(axisY.x) + abs(axisY.y)) * 0.5
        }

        /// x/y are upright pixel indices. A pixel is reserved if any part of
        /// its unit square intersects a source-owned reserve. Call for the
        /// destination and each source pixel in an interpolation footprint.
        func protectsPixel(x: Int, y: Int) -> Bool {
            guard x >= 0, y >= 0, x < width, y < height else { return true }
            let p = localPoint(x: Double(x) + 0.5, y: Double(y) + 0.5)
            for group in reserveGroups {
                var i = firstOverlappingRow(group, y: p.y)
                while i < group.count, group[i].minY - pixelHalfY <= p.y {
                    let r = group[i]
                    if p.x >= r.minX - pixelHalfX, p.x <= r.maxX + pixelHalfX { return true }
                    i += 1
                }
            }
            return false
        }

        private func localPoint(x: Double, y: Double) -> SIMD2<Double> {
            let delta = SIMD2(x, y) - origin
            return SIMD2(delta.x * axisX.x + delta.y * axisX.y,
                         delta.x * axisY.x + delta.y * axisY.y)
        }

        // Every group's minY/maxY are monotonic: slabs are emitted in source
        // row order, and only consecutive identical fallback slabs are merged.
        private func firstOverlappingRow(_ group: [Reserve], y: Double) -> Int {
            var low = 0, high = group.count
            while low < high {
                let middle = (low + high) / 2
                if group[middle].maxY + pixelHalfY < y { low = middle + 1 }
                else { high = middle }
            }
            return low
        }

        /// Continuous upright image coordinates, with half-pixel conservative
        /// coverage. The caller can feather displacement before rendering;
        /// output-only clipping would create a discontinuous contour field.
        func distanceToReserve(x: Double, y: Double) -> Double {
            guard x.isFinite, y.isFinite, x >= 0, y >= 0,
                  x <= Double(width), y <= Double(height) else { return 0 }
            let p = localPoint(x: x, y: y)
            var result = Double.infinity
            func distance(_ r: Reserve) -> Double {
                let dx = max(0, max(r.minX - pixelHalfX - p.x, p.x - r.maxX - pixelHalfX))
                let dy = max(0, max(r.minY - pixelHalfY - p.y, p.y - r.maxY - pixelHalfY))
                return hypot(dx, dy)
            }
            for group in reserveGroups where !group.isEmpty {
                let nearest = min(group.count - 1, firstOverlappingRow(group, y: p.y))
                result = min(result, distance(group[nearest]))
                if result == 0 { return 0 }
                var i = nearest + 1
                while i < group.count, group[i].minY - pixelHalfY - p.y < result {
                    result = min(result, distance(group[i])); if result == 0 { return 0 }
                    i += 1
                }
                i = nearest - 1
                while i >= 0, p.y - group[i].maxY - pixelHalfY < result {
                    result = min(result, distance(group[i])); if result == 0 { return 0 }
                    i -= 1
                }
            }
            return result
        }
    }

    fileprivate struct Reserve: Sendable {
        let minX: Double, maxX: Double, minY: Double, maxY: Double
    }

    private struct Color {
        let r: Double, g: Double, b: Double
        var luma: Double { r * 0.2126 + g * 0.7152 + b * 0.0722 }
        var redGreen: Double { r - g }
        var greenBlue: Double { g - b }
        var chromatic: Bool { r - b >= 12 && g - b >= 3 && r >= g - 4 }
    }

    private struct Candidate {
        let boundary: Double
        let cleftWidth: Double
    }

    /// contour is the observed open jaw path in the caller's orthonormal local
    /// pixel frame, before any artificial temple extension. attachmentBottom
    /// is the pre-existing nasal attachment bound, in that same frame.
    static func qualify(
        sourceRGBA: [UInt8]?, width: Int, height: Int,
        contour: [SIMD2<Double>], origin: SIMD2<Double>,
        axisX: SIMD2<Double>, axisY: SIMD2<Double>,
        span: Double, chin: Double, attachmentBottom: Double
    ) -> Evidence? {
        guard width > 0, height > 0, width <= Int.max / height / 4,
              contour.count >= 3, contour.count <= 1024,
              contour.allSatisfy({ $0.x.isFinite && $0.y.isFinite }),
              origin.x.isFinite, origin.y.isFinite,
              axisX.x.isFinite, axisX.y.isFinite, axisY.x.isFinite, axisY.y.isFinite,
              abs(hypot(axisX.x, axisX.y) - 1) < 0.001,
              abs(hypot(axisY.x, axisY.y) - 1) < 0.001,
              abs(axisX.x * axisY.x + axisX.y * axisY.y) < 0.001,
              span.isFinite, span >= 24, span <= Double(max(width, height)) * 1.5,
              chin.isFinite, chin > 0, attachmentBottom.isFinite else { return nil }
        let ordered = contour.first!.x <= contour.last!.x ? contour : contour.reversed().map { $0 }
        let y0 = -span * 0.04, y1 = min(chin * 0.48, attachmentBottom)
        guard y1 > y0, y1 - y0 <= Double(max(width, height)) else { return nil }
        let opaque: Bool
        if let sourceRGBA, sourceRGBA.count == width * height * 4 {
            opaque = stride(from: 3, to: sourceRGBA.count, by: 4).allSatisfy { sourceRGBA[$0] == 255 }
        } else { opaque = false }
        let source = opaque ? sourceRGBA : nil
        let ys = stride(from: floor(y0), through: ceil(y1), by: 1).map { $0 }
        func observedX(_ y: Double, side: Side) -> Double? {
            var crossings = [Double]()
            for i in 0..<(ordered.count - 1) {
                let a = ordered[i], b = ordered[i + 1]
                guard abs(b.y - a.y) > 0.0001,
                      y >= min(a.y, b.y), y <= max(a.y, b.y) else { continue }
                crossings.append(a.x + (b.x - a.x) * (y - a.y) / (b.y - a.y))
            }
            guard crossings.count >= 2 else { return nil }
            return side == .left ? crossings.min() : crossings.max()
        }
        func sample(_ x: Double, _ y: Double) -> Color? {
            guard let source else { return nil }
            let p = origin + axisX * x + axisY * y
            guard p.x >= 0, p.y >= 0, p.x < Double(width), p.y < Double(height) else { return nil }
            let i = (Int(floor(p.y)) * width + Int(floor(p.x))) * 4
            return Color(r: Double(source[i]), g: Double(source[i + 1]), b: Double(source[i + 2]))
        }
        func candidate(_ y: Double, _ observed: Double, _ side: Side,
                       diagnostics: inout AdmissionDiagnostics) -> Candidate? {
            let outward = Double(side.rawValue), inward = -outward
            let seedOffsets = stride(from: span * 0.09, through: span * 0.14, by: 1)
            var seeds = [Color]()
            for offset in seedOffsets {
                guard let c = sample(observed + inward * offset, y) else {
                    diagnostics.reject(.seedSamplesRejectedRows); return nil
                }
                seeds.append(c)
            }
            guard seeds.count >= 3 else { diagnostics.reject(.seedSamplesRejectedRows); return nil }
            func median(_ values: [Double]) -> Double { values.sorted()[values.count / 2] }
            let seed = Color(r: median(seeds.map(\.r)), g: median(seeds.map(\.g)), b: median(seeds.map(\.b)))
            let deviation = median(seeds.map { abs($0.luma - seed.luma) })
            guard seed.chromatic else { diagnostics.reject(.seedChromaRejectedRows); return nil }
            guard deviation <= max(6, seed.luma * 0.035),
                  median(seeds.map { abs($0.redGreen - seed.redGreen) }) <= 6,
                  median(seeds.map { abs($0.greenBlue - seed.greenBlue) }) <= 6 else {
                diagnostics.reject(.seedVarianceRejectedRows); return nil
            }
            func skinLike(_ c: Color) -> Bool {
                c.chromatic && abs(c.luma - seed.luma) <= max(26, deviation * 4) &&
                    abs(c.redGreen - seed.redGreen) <= 18 && abs(c.greenBlue - seed.greenBlue) <= 16
            }
            func dark(_ c: Color) -> Bool {
                !skinLike(c) && c.luma < seed.luma - max(20, deviation * 5) &&
                    c.r < seed.r - 10 && c.g < seed.g - 10 && c.b < seed.b - 5
            }
            let start = observed + inward * span * 0.09
            let limit = Int(ceil(span * 0.30))
            var boundary: Double?, darkCount = 0, outerSkin = 0
            var sawNonDark = false, establishedOuterSkin = false
            var competingDark = 0, competingSkin = 0
            var previousSkin: Color?
            let minCleft = max(2, Int(ceil(span * 0.005)))
            let maxCleft = max(minCleft, Int(floor(span * 0.07)))
            let requiredOuterSkin = max(3, Int(ceil(span * 0.015)))
            for step in 0...limit {
                let x = start + outward * Double(step)
                guard let c = sample(x, y) else { diagnostics.reject(.roiSampleRejectedRows); return nil }
                if boundary == nil {
                    if skinLike(c) { previousSkin = c; continue }
                    // Diagnostic bins describe adjacent source change only;
                    // they do not participate in qualification or guard size.
                    if let previousSkin {
                        if abs(c.luma - previousSkin.luma) >= 12 ||
                            max(abs(c.redGreen - previousSkin.redGreen),
                                abs(c.greenBlue - previousSkin.greenBlue)) >= 16 {
                            diagnostics.firstDepartureStrongJumpRows += 1
                        } else { diagnostics.firstDepartureGradualRows += 1 }
                    } else { diagnostics.departureWithoutPreviousSkinRows += 1 }
                    guard dark(c) else { diagnostics.reject(.innerSkinDepartureRejectedRows); return nil }
                    guard abs(x - observed) <= span * 0.06 else {
                        diagnostics.reject(.observedAgreementRejectedRows); return nil
                    }
                    boundary = x - outward * 0.5; darkCount = 1
                } else if !sawNonDark {
                    if dark(c) {
                        darkCount += 1
                        guard darkCount <= maxCleft else { diagnostics.reject(.cleftWidthRejectedRows); return nil }
                    } else {
                        guard darkCount >= minCleft else { diagnostics.reject(.cleftWidthRejectedRows); return nil }
                        guard skinLike(c) else { diagnostics.reject(.outerAttachmentRejectedRows); return nil }
                        sawNonDark = true; outerSkin = 1
                    }
                } else if !establishedOuterSkin {
                    // The outer attachment must remain a coherent skin-like
                    // core; a second stripe or opaque occluder is competition.
                    guard skinLike(c) else { diagnostics.reject(.outerAttachmentRejectedRows); return nil }
                    outerSkin += 1
                    if outerSkin >= requiredOuterSkin {
                        establishedOuterSkin = true
                    }
                } else if dark(c) {
                    // A second similarly supported cleft in the search ROI
                    // competes with the first. The outer dark hair beyond an
                    // ear does not qualify a second edge without skin return.
                    competingDark += 1; competingSkin = 0
                } else if competingDark >= minCleft && skinLike(c) {
                    competingSkin += 1
                    if competingSkin >= requiredOuterSkin { diagnostics.reject(.competingCleftRejectedRows); return nil }
                } else {
                    competingDark = 0; competingSkin = 0
                }
            }
            guard establishedOuterSkin, let boundary else { diagnostics.reject(.missingAttachmentRejectedRows); return nil }
            return Candidate(boundary: boundary, cleftWidth: Double(darkCount))
        }
        // An independent proof of connected inner tissue. It never labels the
        // outside of the first uncertain boundary as ear or editable skin.
        // Illumination can change gradually while source chromatic family and
        // adjacent continuity remain stable. A sharp, bounded brown cleft must
        // still agree with the observed contour; otherwise nothing is released.
        func connectedSkinCandidate(_ y: Double, _ observed: Double, _ side: Side,
                                    diagnostics: inout AdmissionDiagnostics,
                                    fixedOuterOnly: Bool = false) -> Candidate? {
            let sign = Double(side.rawValue)
            var seeds = [Color]()
            for offset in stride(from: span * 0.09, through: span * 0.14, by: 1) {
                guard let c = sample(observed - sign * offset, y) else {
                    diagnostics.reject(.seedSamplesRejectedRows); return nil
                }
                seeds.append(c)
            }
            guard seeds.count >= 3 else { diagnostics.reject(.seedSamplesRejectedRows); return nil }
            func median(_ values: [Double]) -> Double { values.sorted()[values.count / 2] }
            let seed = Color(r: median(seeds.map(\.r)), g: median(seeds.map(\.g)), b: median(seeds.map(\.b)))
            let deviation = median(seeds.map { abs($0.luma - seed.luma) })
            guard seed.chromatic else { diagnostics.reject(.seedChromaRejectedRows); return nil }
            guard deviation <= max(6, seed.luma * 0.035),
                  median(seeds.map { abs($0.redGreen - seed.redGreen) }) <= 6,
                  median(seeds.map { abs($0.greenBlue - seed.greenBlue) }) <= 6 else {
                diagnostics.reject(.seedVarianceRejectedRows); return nil
            }
            func sameFamily(_ c: Color) -> Bool {
                guard c.chromatic, c.luma >= 35, seed.luma >= 35 else { return false }
                return max(abs(c.r / c.luma - seed.r / seed.luma),
                           abs(c.g / c.luma - seed.g / seed.luma),
                           abs(c.b / c.luma - seed.b / seed.luma)) <= 0.18
            }
            // Byte quantization plus subdued source texture can add to a slow
            // lighting ramp. This independent branch allows at most 10 bytes
            // per step; its three-pixel median dark drop remains at least 24.
            let stepLimit = max(8, min(10, deviation * 4 + 3))
            let darkDrop = max(24, deviation * 6)
            let minCleft = max(2, Int(ceil(span * 0.005)))
            let maxCleft = max(minCleft, Int(floor(span * 0.07)))
            let lightRun = max(3, Int(ceil(span * 0.015)))
            // The third proof observes a source-scale physical window while
            // visiting every native pixel. The earlier bounded-cleft proof
            // keeps its original native-pixel sampling and dated diagnostics.
            let inspectionStep = fixedOuterOnly ? max(1, min(12, span / 100)) : 1
            let startOffset = fixedOuterOnly ? 0.115 : 0.09
            let start = observed - sign * span * startOffset
            let limit = Int(ceil(fixedOuterOnly ? span * (0.21 + startOffset) : span * 0.30))
            func connectedWindow(_ x: Double) -> Color? {
                // A three-unit physical footprint suppresses resampling phase
                // in the illumination step, without looking beyond the tested
                // inner tissue. Every native position is still visited below
                // and must independently retain the source chromatic family.
                var r = 0.0, g = 0.0, b = 0.0, count = 0.0
                for offset in stride(from: 0.0, through: inspectionStep * 3, by: 1) {
                    let localX = sign * max(sign * start, sign * x - offset)
                    guard let c = sample(localX, y) else { return nil }
                    r += c.r; g += c.g; b += c.b; count += 1
                }
                return Color(r: r / count, g: g / count, b: b / count)
            }
            var tracked = seed, adapted = false
            var boundary: Double?, reference: Color?, darkReference: Color?
            var cleftWidth = 0, closingRun = 0, establishedReturn = false
            var competingWidth = 0, competingReturn = 0
            var sawActualDark = false
            for step in 0...limit {
                let x = start + sign * Double(step)
                guard let c = sample(x, y) else { diagnostics.reject(.roiSampleRejectedRows); return nil }
                if boundary == nil {
                    var ahead = [Color]()
                    for k in 0..<3 {
                        guard let next = sample(x + sign * Double(k) * inspectionStep, y) else {
                            diagnostics.reject(.roiSampleRejectedRows); return nil
                        }
                        ahead.append(next)
                    }
                    let localDark = Color(r: median(ahead.map(\.r)), g: median(ahead.map(\.g)),
                                          b: median(ahead.map(\.b)))
                    let strongDrop = tracked.luma - localDark.luma >= darkDrop &&
                        localDark.r < tracked.r - 10 && localDark.g < tracked.g - 10 &&
                        localDark.b < tracked.b - 5 && localDark.r - localDark.b >= 6 &&
                        localDark.g - localDark.b >= 2
                    if strongDrop {
                        diagnostics.firstDepartureStrongJumpRows += 1
                        guard abs(x - observed) <= span * 0.06 else {
                            diagnostics.reject(.observedAgreementRejectedRows); return nil
                        }
                        boundary = x - sign * 0.5; reference = tracked; darkReference = localDark
                        cleftWidth = 1
                    } else {
                        let previousX = sign * max(sign * start, sign * x - inspectionStep)
                        let stepReference: Color, stepColor: Color
                        if fixedOuterOnly {
                            guard let previous = connectedWindow(previousX), let current = connectedWindow(x) else {
                                diagnostics.reject(.roiSampleRejectedRows); return nil
                            }
                            stepReference = previous; stepColor = current
                        } else { stepReference = tracked; stepColor = c }
                        let connected = sameFamily(c) && abs(stepColor.luma - stepReference.luma) <= stepLimit &&
                            abs(stepColor.redGreen - stepReference.redGreen) <= 6 &&
                            abs(stepColor.greenBlue - stepReference.greenBlue) <= 6
                        guard connected else { diagnostics.reject(.innerSkinDepartureRejectedRows); return nil }
                        adapted = adapted || abs(c.luma - seed.luma) > max(26, deviation * 4)
                        tracked = c
                    }
                } else if let reference, let darkReference {
                    let dark = c.luma <= reference.luma - darkDrop * 0.55 &&
                        c.r < reference.r - 5 && c.g < reference.g - 5 && c.b < reference.b - 3
                    let lightReturn = c.luma >= darkReference.luma + darkDrop * 0.5
                    if fixedOuterOnly {
                        // All of this exterior stays reserved. Its width and
                        // a possible light return grant no editable ownership.
                        // A detected return is used only for the unchanged
                        // competing-boundary veto, never as positive evidence.
                        // A light return can also be darker than the original
                        // cheek. Classify it first so that it cannot swallow
                        // a second cleft. Confirm the warm dark departure in
                        // the actual native pixels, rather than only its
                        // anticipatory, possibly interpolated median.
                        let exteriorDark = dark && !lightReturn
                        if exteriorDark, !establishedReturn,
                           !(c.r - c.b >= 6 && c.g - c.b >= 2) {
                            diagnostics.reject(.innerSkinDepartureRejectedRows); return nil
                        }
                        if !sawActualDark {
                            if exteriorDark { sawActualDark = true; cleftWidth = 1 }
                        } else if closingRun == 0 {
                            if exteriorDark { cleftWidth += 1 }
                            else if lightReturn { closingRun = 1 }
                        } else if !establishedReturn {
                            guard !exteriorDark, lightReturn else { diagnostics.reject(.competingCleftRejectedRows); return nil }
                            closingRun += 1; establishedReturn = closingRun >= lightRun
                        } else if abs(x - observed) <= span * 0.12 {
                            if exteriorDark { competingWidth += 1; competingReturn = 0 }
                            else if competingWidth >= minCleft && lightReturn {
                                competingReturn += 1
                                if competingReturn >= lightRun { diagnostics.reject(.competingCleftRejectedRows); return nil }
                            } else { competingWidth = 0; competingReturn = 0 }
                        }
                        continue
                    }
                    if closingRun == 0 {
                        if dark {
                            cleftWidth += 1
                            guard cleftWidth <= maxCleft else { diagnostics.reject(.cleftWidthRejectedRows); return nil }
                        } else {
                            guard cleftWidth >= minCleft else { diagnostics.reject(.cleftWidthRejectedRows); return nil }
                            guard lightReturn else { diagnostics.reject(.outerAttachmentRejectedRows); return nil }
                            closingRun = 1
                        }
                    } else if !establishedReturn {
                        guard !dark, lightReturn else { diagnostics.reject(.competingCleftRejectedRows); return nil }
                        closingRun += 1; establishedReturn = closingRun >= lightRun
                    } else if abs(x - observed) <= span * 0.12 {
                        if dark { competingWidth += 1; competingReturn = 0 }
                        else if competingWidth >= minCleft && lightReturn {
                            competingReturn += 1
                            if competingReturn >= lightRun { diagnostics.reject(.competingCleftRejectedRows); return nil }
                        } else { competingWidth = 0; competingReturn = 0 }
                    }
                }
            }
            guard (fixedOuterOnly ? sawActualDark : establishedReturn), let boundary else {
                diagnostics.reject(.missingAttachmentRejectedRows); return nil
            }
            if adapted { diagnostics.adaptedSkinRows += 1 }
            return Candidate(boundary: boundary, cleftWidth: fixedOuterOnly ? 0 : Double(cleftWidth))
        }
        let imageLocalXs = [SIMD2<Double>(0, 0), SIMD2(Double(width), 0),
                            SIMD2(0, Double(height)), SIMD2(Double(width), Double(height))].map { p in
            let delta = p - origin
            return delta.x * axisX.x + delta.y * axisX.y
        }
        var reserves = [Reserve]()
        func sideEvidence(_ side: Side) -> SideEvidence {
            let sign = Double(side.rawValue), endpoint = side == .left ? ordered.first! : ordered.last!
            let broadInner = endpoint.x - sign * span * 0.08
            let outer = endpoint.x + sign * span * 0.24
            var diagnostics = AdmissionDiagnostics()
            var candidates = ys.map { y -> Candidate? in
                diagnostics.totalRows += 1
                guard source != nil else { diagnostics.reject(.sourceUnavailableRows); return nil }
                guard let x = observedX(y, side: side) else {
                    diagnostics.reject(.observedIntersectionRejectedRows); return nil
                }
                let result = candidate(y, x, side, diagnostics: &diagnostics)
                if result != nil { diagnostics.candidateRows += 1 }
                return result
            }
            // Qualification is continuous source evidence, not one lucky
            // edge. Every short/discontinuous run remains the broad fallback.
            let requiredRun = max(8, Int(ceil(span * 0.03)))
            var begin = 0
            while begin < candidates.count {
                guard candidates[begin] != nil else { begin += 1; continue }
                var end = begin + 1
                while end < candidates.count, let a = candidates[end - 1], let b = candidates[end],
                      abs(a.boundary - b.boundary) <= max(2, span * 0.004),
                      abs(a.cleftWidth - b.cleftWidth) <= max(2, span * 0.01) { end += 1 }
                if end - begin < requiredRun {
                    diagnostics.shortRunRejectedRows += end - begin
                    for i in begin..<end { candidates[i] = nil }
                }
                if end < candidates.count, candidates[end] != nil { diagnostics.continuityBreaks += 1 }
                begin = end
            }
            var innerDiagnostics = AdmissionDiagnostics()
            var innerCandidates = ys.enumerated().map { i, y -> Candidate? in
                guard candidates[i] == nil else { return nil }
                innerDiagnostics.totalRows += 1
                guard source != nil else { innerDiagnostics.reject(.sourceUnavailableRows); return nil }
                guard let x = observedX(y, side: side) else {
                    innerDiagnostics.reject(.observedIntersectionRejectedRows); return nil
                }
                let result = connectedSkinCandidate(y, x, side, diagnostics: &innerDiagnostics)
                if result != nil { innerDiagnostics.candidateRows += 1 }
                return result
            }
            begin = 0
            while begin < innerCandidates.count {
                guard innerCandidates[begin] != nil else { begin += 1; continue }
                var end = begin + 1
                while end < innerCandidates.count, let a = innerCandidates[end - 1], let b = innerCandidates[end],
                      abs(a.boundary - b.boundary) <= max(2, span * 0.004),
                      abs(a.cleftWidth - b.cleftWidth) <= max(2, span * 0.01) { end += 1 }
                if end - begin < requiredRun {
                    innerDiagnostics.shortRunRejectedRows += end - begin
                    for i in begin..<end { innerCandidates[i] = nil }
                }
                if end < innerCandidates.count, innerCandidates[end] != nil { innerDiagnostics.continuityBreaks += 1 }
                begin = end
            }
            var departureDiagnostics = AdmissionDiagnostics()
            var departureCandidates = ys.enumerated().map { i, y -> Candidate? in
                guard candidates[i] == nil, innerCandidates[i] == nil else { return nil }
                departureDiagnostics.totalRows += 1
                guard source != nil else { departureDiagnostics.reject(.sourceUnavailableRows); return nil }
                guard let x = observedX(y, side: side) else {
                    departureDiagnostics.reject(.observedIntersectionRejectedRows); return nil
                }
                let result = connectedSkinCandidate(y, x, side, diagnostics: &departureDiagnostics,
                                                    fixedOuterOnly: true)
                if result != nil { departureDiagnostics.candidateRows += 1 }
                return result
            }
            begin = 0
            while begin < departureCandidates.count {
                guard departureCandidates[begin] != nil else { begin += 1; continue }
                var end = begin + 1
                while end < departureCandidates.count,
                      let a = departureCandidates[end - 1], let b = departureCandidates[end],
                      abs(a.boundary - b.boundary) <= max(2, span * 0.004) { end += 1 }
                if end - begin < requiredRun {
                    departureDiagnostics.shortRunRejectedRows += end - begin
                    for i in begin..<end { departureCandidates[i] = nil }
                }
                if end < departureCandidates.count, departureCandidates[end] != nil {
                    departureDiagnostics.continuityBreaks += 1
                }
                begin = end
            }
            let margin = max(2, span * 0.008)
            var lastWasFallback = false
            let rows = ys.enumerated().map { i, y -> Row in
                let c = candidates[i]
                var inner = broadInner
                var qualifiedBoundary: Double?
                var innerSkinBoundary: Double?
                var departureSkinBoundary: Double?
                if let c {
                    let proposed = c.boundary - sign * margin
                    if sign * (proposed - broadInner) > 0 {
                        inner = proposed; qualifiedBoundary = c.boundary
                        diagnostics.qualifiedRows += 1
                    } else { diagnostics.nonReducingRows += 1 }
                }
                if c == nil, let recovery = innerCandidates[i] {
                    let proposed = recovery.boundary - sign * margin
                    if sign * (proposed - broadInner) > 0 {
                        inner = proposed; innerSkinBoundary = recovery.boundary
                        innerDiagnostics.qualifiedRows += 1
                    } else { innerDiagnostics.nonReducingRows += 1 }
                }
                if c == nil, innerCandidates[i] == nil, let recovery = departureCandidates[i] {
                    let proposed = recovery.boundary - sign * margin
                    if sign * (proposed - broadInner) > 0 {
                        inner = proposed; departureSkinBoundary = recovery.boundary
                        departureDiagnostics.qualifiedRows += 1
                    } else { departureDiagnostics.nonReducingRows += 1 }
                }
                // Preserve the former .008 collar and complete unit-pixel
                // coverage; the caller adds its continuous geometric feather.
                let padding = max(2, span * 0.008)
                let reserveOuter = departureSkinBoundary == nil ? outer :
                    (side == .left ? imageLocalXs.min()! : imageLocalXs.max()!)
                let reserve = Reserve(minX: min(reserveOuter, inner) - padding,
                                      maxX: max(reserveOuter, inner) + padding,
                                      minY: y - 0.5 - padding, maxY: y + 0.5 + padding)
                let fallback = qualifiedBoundary == nil && innerSkinBoundary == nil && departureSkinBoundary == nil
                if fallback, lastWasFallback, let previous = reserves.last,
                   previous.minX == reserve.minX, previous.maxX == reserve.maxX,
                   reserve.minY <= previous.maxY, reserve.maxY >= previous.minY {
                    // Identical horizontal bounds and overlapping consecutive
                    // fallback slabs have exactly the same rectangular union.
                    // Qualified or separated slabs are never merged here.
                    reserves[reserves.count - 1] = Reserve(
                        minX: previous.minX, maxX: previous.maxX,
                        minY: min(previous.minY, reserve.minY), maxY: max(previous.maxY, reserve.maxY))
                } else { reserves.append(reserve) }
                lastWasFallback = fallback
                return Row(localY: y, innerBoundaryX: inner, sourceBoundaryX: qualifiedBoundary,
                           innerSkinBoundaryX: innerSkinBoundary, departureSkinBoundaryX: departureSkinBoundary)
            }
            return SideEvidence(side: side, isQualified: rows.contains { $0.qualified }, rows: rows,
                                diagnostics: diagnostics, innerSkinDiagnostics: innerDiagnostics,
                                departureSkinDiagnostics: departureDiagnostics)
        }
        let left = sideEvidence(.left)
        let leftCount = reserves.count
        let right = sideEvidence(.right)
        return Evidence(left: left, right: right, width: width, height: height, origin: origin,
                        axisX: axisX, axisY: axisY, reserves: reserves, leftReserveCount: leftCount)
    }
}
