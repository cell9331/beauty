import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class FaceContourSmoothRepairTests: XCTestCase {
    private func sourceCleanFixture(kind: Int = 0) throws -> [UInt8] {
        let width = 800, height = 800, face = FaceGeometry.phase46AsymmetricComplete
        let runs = try XCTUnwrap(FaceContourLateralRuns.make(from:
            try XCTUnwrap(face.observedFaceSupport?.contour)))
        func center(_ run: FaceContourLateralRuns.Run, _ y: Float) -> Float? {
            guard let first = run.ordered.first, let last = run.ordered.last,
                  y >= first.y, y < last.y else { return nil }
            for (a, b) in zip(run.ordered, run.ordered.dropFirst()) where y >= a.y && y <= b.y {
                return (a.x + (b.x - a.x) * (y - a.y) / (b.y - a.y)) * Float(width)
            }
            return nil
        }
        var source = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            let left = center(runs[0], (Float(y) + 0.5) / Float(height)).map { $0 - 12 }
            let right = center(runs[1], (Float(y) + 0.5) / Float(height)).map { $0 + 12 }
            let wave = Float(4 * sin(Double(y) * 2 * .pi / 28))
            for x in 0..<width {
                let q = Float(x), i = (y * width + x) * 4
                let inside = left.map { q >= $0 + wave } == true && right.map { q <= $0 - wave } == true
                let hair = (kind == 1 ? (424..<528) : (424..<448)).contains(y) &&
                    (left.map { q >= $0 - 10 && q <= $0 + 12 } == true ||
                     right.map { q >= $0 - 12 && q <= $0 + 10 } == true)
                let competing = kind == 2 && (left.map { q >= $0 - 20 && q < $0 - 14 } == true ||
                    right.map { q > $0 + 14 && q <= $0 + 20 } == true)
                let color: [UInt8] = hair ? [22, 20, 18] : inside || competing ? [170, 120, 105] : [220, 220, 220]
                for c in 0..<3 { source[i + c] = color[c] }
                if (300..<500).contains(x) {
                    source[i] = UInt8(110 + (x * 7 + y * 3) % 100)
                    source[i + 1] = UInt8(90 + (x * 5 + y * 11) % 80)
                    source[i + 2] = UInt8(65 + (x * 3 + y * 7) % 80)
                }
                if kind == 3 && y >= 448 { source[i + 3] = 254 }
            }
        }
        return source
    }

    private func sourceCleanRoughness(_ bytes: [UInt8], left: Bool) throws -> Double {
        let width = 800
        let points = try (480..<520).map { y -> Int in
            let columns = left ? Array(100..<300) : Array((500..<700).reversed())
            return try XCTUnwrap(columns.first { x in
                let i = (y * width + x) * 4
                return Int(bytes[i]) - Int(bytes[i + 2]) > 20
            })
        }
        let lag = 6
        var total = 0
        for i in lag..<(points.count - lag) {
            let secondDifference = points[i - lag] - 2 * points[i] + points[i + lag]
            total += abs(secondDifference)
        }
        return Double(total) / Double(points.count - 2 * lag)
    }

    func testCompleteSourceCurveFitRetainsBroadCurvatureAndCentersRoughResidual() throws {
        let count = 96
        var clean = [Float](), rough = [Float](), weights = [Float]()
        for i in 0..<count {
            let t = 2 * Float(i) / Float(count - 1) - 1
            let curve = 200 + 4 * t + 8 * t * t + 2 * t * t * t
            clean.append(curve)
            rough.append(curve + 0.8 * Float(sin(Double(i) * 2 * .pi / 13)))
            let end = min(1, Float(i) / 20, Float(count - 1 - i) / 20)
            weights.append(end * end * (3 - 2 * end))
        }
        let retained = try XCTUnwrap(FaceContourSubpixelRefiner.sourceCleanCurveTargets(clean, weights: weights))
        let smoothed = try XCTUnwrap(FaceContourSubpixelRefiner.sourceCleanCurveTargets(rough, weights: weights))
        var maximumCleanError: Float = 0, weightedResidual: Double = 0
        var sourceCurvature: Double = 0, targetCurvature: Double = 0
        for i in 0..<count {
            maximumCleanError = max(maximumCleanError, abs(retained[i] - clean[i]))
            weightedResidual += Double(smoothed[i] - rough[i]) * Double(weights[i])
            if i > 0, i + 1 < count {
                sourceCurvature += Double(abs(rough[i - 1] - 2 * rough[i] + rough[i + 1]))
                targetCurvature += Double(abs(smoothed[i - 1] - 2 * smoothed[i] + smoothed[i + 1]))
            }
        }
        XCTAssertLessThan(maximumCleanError, 0.001)
        XCTAssertEqual(weightedResidual, 0, accuracy: 0.001)
        XCTAssertLessThan(targetCurvature, sourceCurvature)
        XCTAssertNil(FaceContourSubpixelRefiner.sourceCleanCurveTargets(Array(clean.prefix(39)),
            weights: Array(weights.prefix(39))))
        XCTAssertNil(FaceContourSubpixelRefiner.sourceCleanCurveTargets(clean,
            weights: [Float](repeating: 0, count: count)))
    }

    func testCompleteSourceFairingCannotLeaveLocalSourceEnvelope() throws {
        let count = 96, radius = 24, peak = count / 2
        var source = [Float](repeating: 0, count: count), weights = source
        source[peak] = 1
        for i in 0..<count {
            let end = min(1, Float(i) / 20, Float(count - 1 - i) / 20)
            weights[i] = end * end * (3 - 2 * end)
        }
        let target = try XCTUnwrap(FaceContourSubpixelRefiner.sourceCleanCurveTargets(source,
            weights: weights, smoothingRadius: radius))
        var outsideChanges = 0
        for i in target.indices {
            XCTAssertGreaterThanOrEqual(target[i], 0)
            XCTAssertLessThanOrEqual(target[i], 1)
            if abs(i - peak) > radius, target[i] != source[i] { outsideChanges += 1 }
        }
        XCTAssertEqual(outsideChanges, 0, "source window with no supported peak stays exact")
        XCTAssertEqual(target[0], source[0]); XCTAssertEqual(target[1], source[1])
        XCTAssertEqual(target[count - 2], source[count - 2]); XCTAssertEqual(target[count - 1], source[count - 1])
        let residual = target.indices.reduce(Double.zero) { $0 + Double(target[$1] - source[$1]) * Double(weights[$1]) }
        XCTAssertEqual(residual, 0, accuracy: 0.001)
    }

    func testSourceCleanSegmentsImproveRoughnessBesideProtectedHairAndRetainSourceCore() throws {
        let source = try sourceCleanFixture(), face = FaceGeometry.phase46AsymmetricComplete
        let neutral = FaceContourSubpixelRefiner.refine(source, width: 800, height: 800, face: face, strength: 0)
        XCTAssertTrue(neutral == source)
        var previous = [try sourceCleanRoughness(source, left: true), try sourceCleanRoughness(source, left: false)]
        for fraction: Float in [0.25, 0.5, 0.75, 1] {
            let strength = BeautySafetyCaps.faceContourSmooth * fraction
            let output = FaceContourSubpixelRefiner.refineWithProtection(source, width: 800,
                height: 800, face: face, strength: strength)
            XCTAssertTrue(output.protectedLeft); XCTAssertTrue(output.protectedRight)
            XCTAssertEqual(output.sourceTrace.count, 2)
            let traceCounts = output.sourceTrace.enumerated().map { side, trace in
                "side=\(side),hair=\(trace.protectedHairRows),clean=\(trace.cleanBoundaryRows),segment=\(trace.maximumCleanSegmentRows),analysisAdmitted=\(trace.analysisAdmittedCleanSegments),recentered=\(trace.sourceRecenteredRows),nativeAmbiguous=\(trace.nativeAmbiguousRows),nativeWeak=\(trace.nativeWeakRows),nativeRequalified=\(trace.nativeRequalifiedRows),nativeRejected=\(trace.nativeRejectedCandidateRows),nativeHairGuards=\(trace.nativeHairGuardRows),sourceHaloCount=\(trace.nativeSourceHairHaloCount),sourceHaloPixels=\(trace.nativeSourceHairHaloPixels),sourceHairWidth=\(trace.maximumNativeSourceHairWidth),haloRejectedWidth=\(trace.nativeSourceHairHaloRejectedWidth),rejectedHairWidth=\(trace.maximumRejectedNativeSourceHairWidth),haloRejectedSplit=\(trace.nativeSourceHairHaloRejectedContourSplit),haloRejectedEndpoints=\(trace.nativeSourceHairHaloRejectedEndpoints),nativeCandidates=\(trace.nativeCandidatePixels),nativeBefore=\(trace.maximumNativeShiftBeforeConstraint),nativeAfter=\(trace.maximumNativeShiftAfterConstraint),nativeChanged=\(trace.nativeChangedPixels),nativeAdmitted=\(trace.admittedCleanSegments)"
            }.joined(separator: ";")
            XCTAssertTrue(output.sourceTrace.allSatisfy { $0.admittedCleanSegments > 0 },
                "fraction=\(fraction);\(traceCounts)")
            for (i, left) in [true, false].enumerated() {
                let roughness = try sourceCleanRoughness(output.bytes, left: left)
                XCTAssertLessThanOrEqual(roughness, previous[i] + 0.05, "fraction=\(fraction),side=\(i);\(traceCounts)")
                if fraction == 1 { XCTAssertLessThan(roughness, try sourceCleanRoughness(source, left: left) * 0.95,
                    "fraction=\(fraction),side=\(i);\(traceCounts)") }
                previous[i] = roughness
            }
            var protected = 0, active = 0, alpha = 0, nearHair = 0, interiorCore = 0, exterior = 0
            for y in 0..<800 { for x in 0..<800 {
                let i = (y * 800 + x) * 4
                let changed = (0..<4).contains { source[i + $0] != output.bytes[i + $0] }
                if changed { active += 1 }
                if changed && (y < 470 || (300..<500).contains(x) || x < 100 || x >= 700) { protected += 1 }
                if changed && y < 470 { nearHair += 1 }
                if changed && (300..<500).contains(x) { interiorCore += 1 }
                if changed && (x < 100 || x >= 700) { exterior += 1 }
                if source[i + 3] != output.bytes[i + 3] { alpha += 1 }
            } }
            XCTAssertGreaterThan(active, 16)
            XCTAssertEqual(protected, 0, "fraction=\(fraction),nearHair=\(nearHair),interiorCore=\(interiorCore),exterior=\(exterior);\(traceCounts)")
            XCTAssertEqual(alpha, 0)
            XCTAssertTrue(output.bytes == FaceContourSubpixelRefiner.refine(source, width: 800,
                height: 800, face: face, strength: strength), "repeat")
        }
    }

    func testSourceCleanSegmentsCannotCrossSustainedHairCompetitionOrTransparentSupport() throws {
        for kind in [1, 2, 3] {
            let source = try sourceCleanFixture(kind: kind)
            let output = FaceContourSubpixelRefiner.refineWithProtection(source, width: 800,
                height: 800, face: .phase46AsymmetricComplete, strength: BeautySafetyCaps.faceContourSmooth)
            XCTAssertTrue(output.bytes == source, "source-only negative kind=\(kind)")
            XCTAssertTrue(output.sourceTrace.allSatisfy { $0.admittedCleanSegments == 0 })
        }
    }

    private func completeSourceFace(invalidNose: Bool = false) -> FaceGeometry {
        let base = FaceGeometry.phase46AsymmetricComplete
        func rectangle(_ a: Float, _ b: Float, _ c: Float, _ d: Float) -> [SIMD2<Float>] {
            [SIMD2(a, c), SIMD2(b, c), SIMD2(b, d), SIMD2(a, d)]
        }
        func brow(_ side: BeautyObservedEyebrowSide) -> BeautyEyebrowSemanticTrace {
            let p = side == .left ? rectangle(0.38, 0.46, 0.32, 0.34) : rectangle(0.54, 0.62, 0.32, 0.34)
            return BeautyEyebrowSemanticTrace(side: side, points: p,
                innerEndpoint: side == .left ? p[1] : p[0], outerEndpoint: side == .left ? p[0] : p[1],
                center: (p[0] + p[2]) * 0.5, apexIndex: 0)
        }
        var nasal = base.nose.map { CoordinatePoint(x: Double($0.x), y: Double($0.y)) }
        if invalidNose { nasal[0] = CoordinatePoint(x: .nan, y: 0.45) }
        return FaceGeometry(bounds: base.bounds, faceContour: base.faceContour,
            observedFaceSupport: base.observedFaceSupport,
            leftEye: rectangle(0.39, 0.46, 0.37, 0.40), rightEye: rectangle(0.54, 0.61, 0.37, 0.40),
            nose: base.nose, noseRoot: base.noseRoot, noseTip: base.noseTip,
            outerLips: base.outerLips, upperLips: base.upperLips, lowerLips: base.lowerLips, innerLips: base.innerLips,
            freshness: .fresh, observedEyebrowSupport: BeautyEyebrowSemanticSupport(left: brow(.left), right: brow(.right)),
            observedOuterLips: base.outerLips, observedNoseSupport: BeautyObservedNoseSupport(crest: nasal, contour: nasal))
    }

    /// Scope reconstruction uses only the predefined source geometry. Neither
    /// this scope nor the unchanged roughness rows are selected from output.
    private func completeSourceScope(_ face: FaceGeometry) throws -> BeautyContourTransitionScope {
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> { SIMD2(Double(p.x) * 800, Double(p.y) * 800) }
        func mean(_ p: [SIMD2<Float>]) -> SIMD2<Double> { p.map(pixel).reduce(.zero, +) / Double(p.count) }
        let vector = mean(face.rightEye) - mean(face.leftEye)
        let axisX = vector / hypot(vector.x, vector.y), axisY = SIMD2(-axisX.y, axisX.x)
        let origin = (mean(face.leftEye) + mean(face.rightEye)) * 0.5
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let d = p - origin
            return SIMD2(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
        }
        let raw = try XCTUnwrap(face.observedFaceSupport).contour.map(pixel), points = raw.map(local)
        let span = points.map(\.x).max()! - points.map(\.x).min()!, chin = points.map(\.y).max()!
        let nose = try XCTUnwrap(face.observedNoseSupport)
        let bottom = (nose.crest + nose.contour).map { local(SIMD2($0.x * 800, $0.y * 800)).y }.max()!
        return try XCTUnwrap(BeautyContourTransitionScope(width: 800, height: 800, contour: raw,
            origin: origin, axisX: axisX, axisY: axisY, span: span, chin: chin,
            lowerBound: max(chin * 0.32, bottom + span * 0.008)))
    }

    func testCompleteObservedSourceFairingImprovesFrozenRoughnessInsideNarrowScope() throws {
        let source = try sourceCleanFixture(), face = completeSourceFace(), scope = try completeSourceScope(face)
        let neutral = FaceContourSubpixelRefiner.refine(source, width: 800, height: 800, face: face, strength: 0)
        XCTAssertTrue(neutral == source)
        let output = FaceContourSubpixelRefiner.refineWithProtection(source, width: 800, height: 800,
            face: face, strength: BeautySafetyCaps.faceContourSmooth)
        var changed = 0, outside = 0, darkCore = 0, central = 0, alpha = 0
        for y in 0..<800 { for x in 0..<800 {
            let i = (y * 800 + x) * 4
            let delta = source[i..<i + 4] != output.bytes[i..<i + 4]
            if delta {
                changed += 1
                if !scope.allowsDestination(x: x, y: y) { outside += 1 }
                if max(source[i], source[i + 1], source[i + 2]) < 70 { darkCore += 1 }
                if (300..<500).contains(x) { central += 1 }
            }
            if source[i + 3] != output.bytes[i + 3] { alpha += 1 }
        } }
        XCTAssertGreaterThan(changed, 16, "safe refusal cannot satisfy a source-smoothing positive")
        XCTAssertEqual(outside, 0)
        XCTAssertEqual(darkCore, 0)
        XCTAssertEqual(central, 0)
        XCTAssertEqual(alpha, 0)
        for left in [true, false] {
            XCTAssertLessThan(try sourceCleanRoughness(output.bytes, left: left),
                try sourceCleanRoughness(source, left: left) * 0.95,
                "the same fixed source rows must actually become smoother")
        }
        XCTAssertEqual(output.sourceTrace.count, 2)
        XCTAssertTrue(output.sourceTrace.allSatisfy { $0.nativeMappedFieldPixels > 0 &&
            $0.maximumNativeGeometryGradient > 0 && $0.maximumNativeGeometryGradient <= 0.450001 })
        XCTAssertTrue(output.bytes == FaceContourSubpixelRefiner.refine(source, width: 800, height: 800,
            face: face, strength: BeautySafetyCaps.faceContourSmooth))
    }

    func testCompleteObservedSourceRefusalDoesNotReviveDetectorRegistration() throws {
        let face = completeSourceFace()
        for kind in [1, 2, 3] {
            let source = try sourceCleanFixture(kind: kind)
            let output = FaceContourSubpixelRefiner.refineWithProtection(source, width: 800, height: 800,
                face: face, strength: BeautySafetyCaps.faceContourSmooth)
            XCTAssertTrue(output.bytes == source, "the original sustained-hair/competition/alpha negative stays fixed")
        }
        let pixel: [UInt8] = [170, 120, 105, 255]
        let uniform: [UInt8] = Array(repeating: pixel, count: 800 * 800).flatMap { $0 }
        XCTAssertTrue(uniform == FaceContourSubpixelRefiner.refine(uniform, width: 800, height: 800,
            face: face, strength: BeautySafetyCaps.faceContourSmooth))
        let source = try sourceCleanFixture()
        XCTAssertTrue(source == FaceContourSubpixelRefiner.refine(source, width: 800, height: 800,
            face: completeSourceFace(invalidNose: true), strength: BeautySafetyCaps.faceContourSmooth))
    }

    /// This new permission is fixed from source geometry before any render:
    /// a local occluder inside the already admitted narrow transition can
    /// follow the trusted contour. The same material outside it stays exact.
    /// It does not supersede the original dominant-hair/competition negatives.
    func testCompleteRawShapeTermCanMoveLocalTransitionOcclusionWithoutCopyingItsExterior() throws {
        let face = completeSourceFace(), scope = try completeSourceScope(face)
        let runs = try XCTUnwrap(FaceContourLateralRuns.make(from:
            try XCTUnwrap(face.observedFaceSupport?.contour)))
        var source = try sourceCleanFixture(), insideOcclusion = Set<Int>(), outsideHair = Set<Int>()
        for row in 486...502 {
            let y = (Float(row) + 0.5) / 800
            for run in runs {
                guard let pair = zip(run.ordered, run.ordered.dropFirst()).first(where: { y >= $0.0.y && y <= $0.1.y }) else { continue }
                let center = Int(((pair.0.x + (pair.1.x - pair.0.x) * (y - pair.0.y) /
                    (pair.1.y - pair.0.y)) * 800).rounded())
                for x in (center - 2)...(center + 2) where scope.allowsDestination(x: x, y: row) {
                    let p = row * 800 + x
                    insideOcclusion.insert(p)
                    source[p * 4] = 22; source[p * 4 + 1] = 20; source[p * 4 + 2] = 18
                }
            }
        }
        for row in 450...535 { for x in [79, 80, 81, 718, 719, 720] {
            XCTAssertFalse(scope.allowsDestination(x: x, y: row))
            let p = row * 800 + x
            outsideHair.insert(p)
            source[p * 4] = 22; source[p * 4 + 1] = 20; source[p * 4 + 2] = 18
        } }
        XCTAssertFalse(insideOcclusion.isEmpty)
        let output = FaceContourSubpixelRefiner.refineWithProtection(source, width: 800, height: 800,
            face: face, strength: BeautySafetyCaps.faceContourSmooth)
        var changed = 0, localOcclusionChanged = 0, exterior = 0, outsideHairChanged = 0, alpha = 0, central = 0
        for p in 0..<(800 * 800) {
            let i = p * 4, differs = (0..<4).contains { source[i + $0] != output.bytes[i + $0] }
            if differs {
                changed += 1
                if insideOcclusion.contains(p) { localOcclusionChanged += 1 }
                if outsideHair.contains(p) { outsideHairChanged += 1 }
                if !scope.allowsDestination(x: p % 800, y: p / 800) { exterior += 1 }
                if (300..<500).contains(p % 800) { central += 1 }
            }
            if source[i + 3] != output.bytes[i + 3] { alpha += 1 }
        }
        XCTAssertGreaterThan(changed, 16)
        XCTAssertGreaterThan(localOcclusionChanged, 0, "local dark material is permitted by source geometry, not relabelled skin")
        XCTAssertEqual(exterior, 0); XCTAssertEqual(outsideHairChanged, 0)
        XCTAssertEqual(alpha, 0); XCTAssertEqual(central, 0)
        XCTAssertTrue(output.sourceTrace.contains { $0.admittedGeometryShapeRows > 0 && $0.geometryShapeOnlyRows > 0 })
        XCTAssertTrue(output.sourceTrace.allSatisfy { $0.maximumNativeGeometryGradient <= 0.450001 })
        XCTAssertTrue(output.bytes == FaceContourSubpixelRefiner.refine(source, width: 800, height: 800,
            face: face, strength: BeautySafetyCaps.faceContourSmooth))
    }

    /// Actual source detection and adapter, with aggregate gate outcomes only.
    /// Without the owner-local source, the ordinary generated positive/negative
    /// smoothing contract is exercised instead of leaving an empty execution.
    func testFACE01ProductionSourceContourAdmissionDiagnostics() throws {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try testFACE01GeneratedRoughSilhouetteHasSmootherMeasuredBoundary()
            return
        }
        let url = URL(fileURLWithPath: path).standardizedFileURL
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        guard values.isRegularFile == true, values.isSymbolicLink != true,
              let fileSize = values.fileSize, fileSize > 0,
              fileSize <= BeautyConfiguration.defaultMaximumInputByteCount,
              let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]),
              image.extent.width.isFinite, image.extent.height.isFinite,
              image.extent.width >= 2, image.extent.height >= 2,
              image.extent.width * image.extent.height <= CGFloat(BeautyConfiguration.defaultMaximumInputPixelCount)
        else { XCTFail("invalid owner-local source"); return }
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
        func raster(_ image: CIImage, width: Int, height: Int) -> ([UInt8], CIImage) {
            let extent = CGRect(x: 0, y: 0, width: Double(width), height: Double(height))
            var source = [UInt8](repeating: 0, count: width * height * 4)
            context.render(image, toBitmap: &source, rowBytes: width * 4, bounds: extent,
                format: .RGBA8, colorSpace: colorSpace)
            return (source, CIImage(bitmapData: Data(source), bytesPerRow: width * 4,
                size: extent.size, format: .RGBA8, colorSpace: colorSpace))
        }
        let fullWidth = Int(image.extent.width), fullHeight = Int(image.extent.height)
        let (fullSource, fullImage) = raster(image.transformed(by: CGAffineTransform(
            translationX: -image.extent.minX, y: -image.extent.minY)), width: fullWidth, height: fullHeight)
        let scale = min(1, 960 / Double(max(fullWidth, fullHeight)))
        let width = Int(floor(Double(fullWidth) * scale)), height = Int(floor(Double(fullHeight) * scale))
        let (previewSource, previewImage) = raster(fullImage.transformed(by: CGAffineTransform(scaleX: scale,
            y: scale)), width: width, height: height)
        for (label, source, input, width, height) in [
            ("full", fullSource, fullImage, fullWidth, fullHeight),
            ("preview960", previewSource, previewImage, width, height)
        ] {
            var detector = BeautyFaceDetector.production()
            let detection = detector.detect(image: input, metadata: metadata,
                imageExtent: input.extent.size, purpose: .geometryAndLocalSupport)
            XCTAssertEqual(detection.summary.availability, .usable)
            XCTAssertEqual(detection.observations.count, 1)
            let observation = try XCTUnwrap(detection.observations.first)
            let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
            var strengths = BeautyEffectiveStrengths(); strengths.faceContourSmooth = BeautySafetyCaps.faceContourSmooth
            let emission = FaceShapeWarpProvider().fieldEmissions(face: face, strengths: strengths)
            let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(faceContourSmooth:
                BeautySafetyCaps.faceContourSmooth), faceGeometry: face)
            let direct = FaceContourSubpixelRefiner.refineWithProtection(source, width: width,
                height: height, face: face, strength: BeautySafetyCaps.faceContourSmooth)
            var changed = 0, alpha = 0
            for p in 0..<(width * height) {
                let i = p * 4
                if (0..<4).contains(where: { direct.bytes[i + $0] != source[i + $0] }) { changed += 1 }
                if direct.bytes[i + 3] != source[i + 3] { alpha += 1 }
            }
            let aggregate: [String: Any] = ["kind": "production-source-contour-smooth-gate-diagnostic",
                "layer": label, "observedContourCount": face.observedFaceSupport?.contour.count ?? 0,
                "observedContourEligible": face.observedFaceSupport?.contourEligible ?? false,
                "lateralRunCount": face.observedFaceSupport.flatMap { FaceContourLateralRuns.make(from: $0.contour) }?.count ?? 0,
                "proxyPointCount": emission.faceContourSmooth.count,
                "retainedStrength": plan.effectiveStrengths.faceContourSmooth,
                "activeFaceDomain": plan.activeDomains.contains(.faceShape),
                "directChangedPixels": changed, "directAlphaChangedPixels": alpha,
                "protectedLeftSourceHair": direct.protectedLeft, "protectedRightSourceHair": direct.protectedRight,
                "sourceRunTraces": direct.sourceTrace.map { trace -> [String: Any] in
                    ["activeRows": trace.activeRows, "protectedHairRows": trace.protectedHairRows,
                     "cleanBoundaryRows": trace.cleanBoundaryRows, "maximumCleanSegmentRows": trace.maximumCleanSegmentRows,
                     "admittedCleanSegments": trace.admittedCleanSegments, "cleanAnalysisLongEdge": trace.cleanAnalysisLongEdge,
                     "analysisAdmittedCleanSegments": trace.analysisAdmittedCleanSegments,
                     "nativeCandidatePixels": trace.nativeCandidatePixels,
                     "maximumNativeShiftBeforeConstraint": trace.maximumNativeShiftBeforeConstraint,
                     "maximumNativeShiftAfterConstraint": trace.maximumNativeShiftAfterConstraint,
                     "sourceRecenteredRows": trace.sourceRecenteredRows,
                     "nativeAmbiguousRows": trace.nativeAmbiguousRows,
                     "nativeWeakRows": trace.nativeWeakRows,
                     "nativeRequalifiedRows": trace.nativeRequalifiedRows,
                     "nativeRejectedCandidateRows": trace.nativeRejectedCandidateRows,
                     "nativeHairGuardRows": trace.nativeHairGuardRows,
                     "nativeMappedFieldPixels": trace.nativeMappedFieldPixels,
                     "nativeDomainRejectedPixels": trace.nativeDomainRejectedPixels,
                     "nativeCoreRejectedPixels": trace.nativeCoreRejectedPixels,
                     "nativeBandRejectedPixels": trace.nativeBandRejectedPixels,
                     "nativeFootprintRejectedPixels": trace.nativeFootprintRejectedPixels,
                     "nativeSourceHairHaloCount": trace.nativeSourceHairHaloCount,
                     "nativeSourceHairHaloPixels": trace.nativeSourceHairHaloPixels,
                     "maximumNativeSourceHairWidth": trace.maximumNativeSourceHairWidth,
                     "maximumRejectedNativeSourceHairWidth": trace.maximumRejectedNativeSourceHairWidth,
                     "nativeSourceHairHaloRejectedWidth": trace.nativeSourceHairHaloRejectedWidth,
                     "nativeSourceHairHaloRejectedContourSplit": trace.nativeSourceHairHaloRejectedContourSplit,
                     "nativeSourceHairHaloRejectedEndpoints": trace.nativeSourceHairHaloRejectedEndpoints,
                     "nativeChangedPixels": trace.nativeChangedPixels,
                     "nativeGeometryRejectedPixels": trace.nativeGeometryRejectedPixels,
                     "nativeGeometryFootprintRejectedPixels": trace.nativeGeometryFootprintRejectedPixels,
                     "maximumNativeGeometryGradient": trace.maximumNativeGeometryGradient,
                     "admittedGeometryShapeRows": trace.admittedGeometryShapeRows,
                     "geometryShapeOnlyRows": trace.geometryShapeOnlyRows]
                }]
            let data = try JSONSerialization.data(withJSONObject: aggregate, options: [.sortedKeys])
            print(String(decoding: data, as: UTF8.self))
        }
    }

    func testFACE01ExistingProviderEmitsOneCenteredObservedContourCorrection() throws {
        let provider = FaceShapeWarpProvider()
        let face = Self.face

        for requested in [BeautySafetyCaps.faceContourSmooth, BeautySafetyCaps.faceContourSmooth * 0.5] {
            let first = provider.fieldEmissions(
                face: face,
                strengths: strengths(faceContourSmooth: requested)
            ).faceContourSmooth
            let second = provider.fieldEmissions(
                face: face,
                strengths: strengths(faceContourSmooth: requested)
            ).faceContourSmooth
            let contour = try XCTUnwrap(face.observedFaceSupport?.contour)
            let minimumXIndex = try XCTUnwrap(contour.indices.min { contour[$0].x < contour[$1].x })
            let maximumXIndex = try XCTUnwrap(contour.indices.max { contour[$0].x < contour[$1].x })
            let eligibleIndices = [1, 3, 4, 5, 10, 11, 12, 14]

            XCTAssertEqual(first, second)
            XCTAssertEqual(first.map(\.source), eligibleIndices.map { contour[$0] })
            XCTAssertFalse(first.isEmpty)
            XCTAssertTrue(first.allSatisfy {
                $0.source.y == $0.target.y &&
                    $0.radius == face.bounds.width * 0.014 &&
                    $0.strength == requested &&
                    $0.falloff == 2 &&
                    $0.source.x.isFinite && $0.target.x.isFinite
            })
            XCTAssertFalse(first.contains { $0.source == contour.first || $0.source == contour.last })
            XCTAssertFalse(first.contains { $0.source == contour[minimumXIndex] || $0.source == contour[maximumXIndex] })

            let displacements = first.map { $0.target.x - $0.source.x }
            let ceiling = 0.004 * face.bounds.width * requested / BeautySafetyCaps.faceContourSmooth
            XCTAssertTrue(displacements.allSatisfy { abs($0) <= ceiling + 0.000_001 })
            XCTAssertEqual(displacements.reduce(0, +), 0, accuracy: 0.000_001)
            XCTAssertEqual(displacements.reduce(0, +) / Float(displacements.count), 0, accuracy: 0.000_001)

            var proposed = contour
            for point in first {
                proposed[try XCTUnwrap(contour.firstIndex(of: point.source))] = point.target
            }
            XCTAssertLessThan(
                roughness(proposed, indices: eligibleIndices),
                roughness(contour, indices: eligibleIndices)
            )
            XCTAssertLessThan(roughness(proposed), roughness(contour))

            for sibling in siblingEmissions(face: face) {
                XCTAssertNotEqual(first, sibling)
                XCTAssertFalse(first.allSatisfy(sibling.contains))
            }
        }

        let reversed = Self.face(contour: Array(Self.contour.reversed()))
        let reversedFirst = provider.fieldEmissions(
            face: reversed,
            strengths: strengths(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
        ).faceContourSmooth
        let reversedSecond = provider.fieldEmissions(
            face: reversed,
            strengths: strengths(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
        ).faceContourSmooth
        XCTAssertFalse(reversedFirst.isEmpty)
        XCTAssertEqual(reversedFirst, reversedSecond)

        let quantized = Self.face(contour: Self.contour.enumerated().map { index, point in
            SIMD2<Float>(point.x + (index.isMultiple(of: 2) ? 0.000_000_12 : -0.000_000_12), point.y)
        })
        XCTAssertFalse(provider.fieldEmissions(
            face: quantized,
            strengths: strengths(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
        ).faceContourSmooth.isEmpty)
    }

    func testFACE01ProviderFailsOnlyNamedFieldClosedForInvalidSupportAndInputs() {
        let provider = FaceShapeWarpProvider()
        let validSibling = strengths(
            faceSlim: BeautySafetyCaps.faceSlim,
            faceContourSmooth: BeautySafetyCaps.faceContourSmooth
        )
        let missing = Self.face(observedSupport: nil, useDefaultSupport: false)
        let malformedSupports: [BeautyFaceSemanticSupport?] = [
            BeautyFaceSemanticSupport(contour: [], medianLine: nil, apexIndex: nil),
            BeautyFaceSemanticSupport(contour: [SIMD2<Float>(.nan, 0.5)], medianLine: nil, apexIndex: nil),
            BeautyFaceSemanticSupport(
                contour: [
                    SIMD2<Float>(0.20, 0.30), SIMD2<Float>(0.20, 0.45),
                    SIMD2<Float>(0.20, 0.60), SIMD2<Float>(0.20, 0.75),
                ],
                medianLine: nil,
                apexIndex: nil
            ),
        ]

        let missingEmissions = provider.fieldEmissions(face: missing, strengths: validSibling)
        XCTAssertTrue(missingEmissions.faceContourSmooth.isEmpty)
        XCTAssertFalse(missingEmissions.faceSlim.isEmpty)
        XCTAssertEqual(missingEmissions.sanitizing(validSibling).faceContourSmooth, 0)
        XCTAssertEqual(missingEmissions.sanitizing(validSibling).faceSlim, BeautySafetyCaps.faceSlim)

        for support in malformedSupports {
            XCTAssertTrue(provider.fieldEmissions(
                face: Self.face(observedSupport: support, useDefaultSupport: false),
                strengths: strengths(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
            ).faceContourSmooth.isEmpty)
        }

        for invalid in [Float.zero, -0.25, Float.nan, Float.infinity, -Float.infinity] {
            XCTAssertTrue(provider.fieldEmissions(
                face: Self.face,
                strengths: strengths(faceContourSmooth: invalid)
            ).faceContourSmooth.isEmpty)
        }
    }

    func testFACE01GeneratedCPUFixtureMeetsFrozenContract() throws {
        let width = 1_000
        let height = 1_000
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let source = Self.generatedImage(width: width, height: height, colorSpace: colorSpace)
        let sourceBytes = renderedBytes(source, width: width, height: height, colorSpace: colorSpace)

        let neutral = render(
            source,
            parameters: BeautyParameters(),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        let active = render(
            source,
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        let repeated = render(
            source,
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        let frozenSiblings = [
            BeautyParameters(faceSmall: 0.35),
            BeautyParameters(faceSlim: 0.35),
        ].map {
            render(source, parameters: $0, width: width, height: height, colorSpace: colorSpace)
        }
        let strengtheningSiblings = [
            BeautyParameters(faceVShape: 0.35),
            BeautyParameters(jawSlim: 0.35),
            BeautyParameters(chinTaper: 0.25),
        ].map {
            render(source, parameters: $0, width: width, height: height, colorSpace: colorSpace)
        }

        XCTAssertEqual(neutral, sourceBytes)
        XCTAssertEqual(active, repeated)
        XCTAssertTrue(stride(from: 3, to: active.count, by: 4).allSatisfy { active[$0] == 255 })

        let snapshot = try semanticSnapshot(
            source: sourceBytes,
            neutral: neutral,
            candidate: active,
            frozenSiblings: frozenSiblings,
            strengtheningSiblings: strengtheningSiblings,
            width: width,
            height: height
        )
        XCTAssertGreaterThanOrEqual(snapshot.sourceTarget.changedPixels, 1_000)
        XCTAssertGreaterThanOrEqual(snapshot.sourceTarget.absoluteRGBDelta, 3_000)
        XCTAssertGreaterThanOrEqual(snapshot.neutralTarget.changedPixels, 1_000)
        XCTAssertGreaterThanOrEqual(snapshot.neutralTarget.absoluteRGBDelta, 3_000)
        // Preserve every original FACE-01 threshold. This positive result is
        // a generated CPU gate, not portrait or backend qualification.
        let predicates: [String: Bool] = [
            "source_direction": snapshot.sourceSignedMarginQ16 >= 16,
            "neutral_direction": snapshot.neutralSignedMarginQ16 >= 16,
            "frozen_siblings": snapshot.frozenSiblingDistinctMarginsQ16.allSatisfy { $0 >= 16 },
            "strengthening_siblings": snapshot.strengtheningSiblingDistinctMarginsQ16.allSatisfy { $0 >= 16 },
            "outside_pixels": snapshot.outside.changedPixels <= 500,
            "outside_rgb": snapshot.outside.absoluteRGBDelta <= 1_500,
            "central_pixels": snapshot.central.changedPixels <= 128,
            "central_rgb": snapshot.central.absoluteRGBDelta <= 512,
        ]
        XCTAssertTrue(predicates.values.allSatisfy { $0 }, "FACE-01 generated gate must pass: \(predicates)")
        XCTAssertEqual(snapshot.background.changedPixels, 0)
        XCTAssertEqual(snapshot.background.absoluteRGBDelta, 0)
        XCTAssertEqual(snapshot.watermark.changedPixels, 0)
        XCTAssertEqual(snapshot.watermark.absoluteRGBDelta, 0)
    }

    func testFACE01GeneratedRoughSilhouetteHasSmootherMeasuredBoundary() throws {
        let width = 1_000
        let height = 1_000
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let sourceImage = Self.generatedSilhouette(width: width, height: height, colorSpace: colorSpace)
        let source = renderedBytes(sourceImage, width: width, height: height, colorSpace: colorSpace)
        let candidate = render(
            sourceImage,
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        let sourceRoughness = try silhouetteRoughness(source, width: width, height: height)
        let candidateRoughness = try silhouetteRoughness(candidate, width: width, height: height)
        let repeated = render(
            sourceImage,
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        XCTAssertGreaterThan(sourceRoughness, 0.5)
        XCTAssertLessThan(candidateRoughness, sourceRoughness / 2)
        XCTAssertEqual(candidate, repeated)
        XCTAssertGreaterThan(signal(source, candidate, regions: Self.targetRegions, width: width, height: height).changedPixels, 0)
        XCTAssertEqual(signal(source, candidate, regions: Self.centralRegions, width: width, height: height).changedPixels, 0)
        XCTAssertEqual(signal(source, candidate, regions: Self.backgroundRegions, width: width, height: height).changedPixels, 0)

        let offsetImage = Self.generatedSilhouette(
            width: width, height: height, colorSpace: colorSpace,
            contour: Self.contour, rasterizeInward: true
        )
        let offsetSource = renderedBytes(offsetImage, width: width, height: height, colorSpace: colorSpace)
        let offsetCandidate = render(
            offsetImage,
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        let offsetSourceRoughness = try silhouetteRoughness(offsetSource, width: width, height: height)
        let offsetCandidateRoughness = try silhouetteRoughness(offsetCandidate, width: width, height: height)
        XCTAssertGreaterThan(offsetSourceRoughness, 0.5)
        XCTAssertLessThan(offsetCandidateRoughness, offsetSourceRoughness / 2)
        XCTAssertEqual(signal(offsetSource, offsetCandidate, regions: Self.centralRegions, width: width, height: height).changedPixels, 0)
        XCTAssertEqual(signal(offsetSource, offsetCandidate, regions: Self.backgroundRegions, width: width, height: height).changedPixels, 0)

        // A genuinely straight observed side has no contour residual to repair.
        let straightContour = Self.contour.enumerated().map { index, point in
            SIMD2<Float>(index <= 6 ? 0.20 : index >= 9 ? 0.80 : point.x, point.y)
        }
        let straightFace = Self.face(contour: straightContour)
        XCTAssertTrue(FaceShapeWarpProvider().fieldEmissions(
            face: straightFace,
            strengths: strengths(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
        ).faceContourSmooth.isEmpty)
        let straightImage = Self.generatedSilhouette(
            width: width, height: height, colorSpace: colorSpace, contour: straightContour
        )
        let straightPlan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceContourSmooth: 0.25), faceGeometry: straightFace
        )
        let straightOutput = BeautyGeometryEffectPipeline.applyMVPProxy(
            to: straightImage, plan: straightPlan, face: straightFace
        )
        XCTAssertEqual(
            renderedBytes(straightImage, width: width, height: height, colorSpace: colorSpace),
            renderedBytes(straightOutput, width: width, height: height, colorSpace: colorSpace)
        )
    }

    func testFACE01SubpixelCorrectionPreservesNeutralAlphaAndCentralRegionAcrossSizes() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        for (width, height) in [(320, 320), (768, 512)] {
            let image = Self.generatedImage(width: width, height: height, colorSpace: colorSpace)
            var source = renderedBytes(image, width: width, height: height, colorSpace: colorSpace)
            let transparentColumn = Int((0.22 * Float(width)).rounded())
            let transparentOffset = ((height / 2) * width + transparentColumn) * 4
            source[transparentOffset + 3] = 0

            let neutral = FaceContourSubpixelRefiner.refine(
                source, width: width, height: height, face: Self.face, strength: 0
            )
            let first = FaceContourSubpixelRefiner.refine(
                source,
                width: width,
                height: height,
                face: Self.face,
                strength: BeautySafetyCaps.faceContourSmooth
            )
            let repeated = FaceContourSubpixelRefiner.refine(
                source,
                width: width,
                height: height,
                face: Self.face,
                strength: BeautySafetyCaps.faceContourSmooth
            )
            XCTAssertEqual(neutral, source)
            XCTAssertEqual(first, repeated)
            XCTAssertEqual(
                Array(first[transparentOffset..<(transparentOffset + 4)]),
                Array(source[transparentOffset..<(transparentOffset + 4)])
            )
            XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy { first[$0] == source[$0] })
            XCTAssertGreaterThan(signal(source, first, regions: Self.targetRegions, width: width, height: height).changedPixels, 0)
            XCTAssertEqual(signal(source, first, regions: Self.centralRegions, width: width, height: height).absoluteRGBDelta, 0)
            XCTAssertEqual(signal(source, first, regions: Self.backgroundRegions, width: width, height: height).absoluteRGBDelta, 0)
        }
    }

    func testFACE01StillImageCPUAndMetalUseTheSameContourRefinement() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let width = 320
        let height = 320
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let image = Self.generatedImage(width: width, height: height, colorSpace: colorSpace)
        let observation = BeautyFaceObservation(
            imageBounds: CoordinateRect(x: 0.10, y: 0.20, width: 0.80, height: 0.64),
            observedFaceSupport: BeautyObservedFaceSupport(contour: Self.contour.map {
                CoordinatePoint(x: Double($0.x), y: Double($0.y))
            })
        )
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            faceGeometry: face
        )
        XCTAssertFalse(FaceShapeWarpProvider().fieldEmissions(
            face: face, strengths: plan.effectiveStrengths
        ).faceContourSmooth.isEmpty)

        func request(_ policy: BeautyBackendExecutionPolicy) throws -> BeautyBackendRequest {
            try BeautyBackendRequest(
                policy: policy,
                input: .stillImage(image),
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                plan: plan,
                selectedFaceSupport: observation
            )
        }
        let cpu = try BeautyCPUBackend().execute(request(.cpu))
        let gpu = try metal.execute(request(.metal))
        guard case .stillImage(let cpuImage) = cpu.output,
              case .stillImage(let gpuImage) = gpu.output else {
            return XCTFail("FACE-01 backend changed still-image output kind")
        }
        XCTAssertEqual(cpuImage.extent, image.extent)
        XCTAssertEqual(gpuImage.extent, image.extent)
        XCTAssertEqual(gpuImage.colorSpace?.name, CGColorSpace.sRGB)
        let source = renderedBytes(image, width: width, height: height, colorSpace: colorSpace)
        let cpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: cpu.output)
        let gpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: gpu.output)
        XCTAssertGreaterThan(signal(source, cpuBytes, regions: Self.targetRegions, width: width, height: height).changedPixels, 0)
        XCTAssertEqual(stride(from: 3, to: cpuBytes.count, by: 4).map { cpuBytes[$0] },
                       stride(from: 3, to: gpuBytes.count, by: 4).map { gpuBytes[$0] })
        let channelDeltas = zip(cpuBytes, gpuBytes).enumerated().compactMap { index, pair -> Int? in
            index.isMultiple(of: 4) || index % 4 == 1 || index % 4 == 2
                ? abs(Int(pair.0) - Int(pair.1)) : nil
        }
        XCTAssertLessThanOrEqual(channelDeltas.max() ?? 0, BeautyBackendParityFixtureFactory.activeMaxChannelDelta)
        XCTAssertLessThan(Double(channelDeltas.reduce(0, +)) / Double(channelDeltas.count),
                          BeautyBackendParityFixtureFactory.activeMeanRGBDelta)
    }

    private func siblingEmissions(face: FaceGeometry) -> [[WarpControlPoint]] {
        let provider = FaceShapeWarpProvider()
        let emissions = provider.fieldEmissions(
            face: face,
            strengths: strengths(
                faceSlim: BeautySafetyCaps.faceSlim,
                faceSmall: BeautySafetyCaps.faceSmall,
                faceVShape: BeautySafetyCaps.faceVShape,
                jawSlim: BeautySafetyCaps.jawSlim
            )
        )
        return [emissions.faceSlim, emissions.faceSmall, emissions.faceVShape, emissions.jawSlim]
    }

    private func strengths(
        faceSlim: Float = 0,
        faceSmall: Float = 0,
        faceVShape: Float = 0,
        jawSlim: Float = 0,
        faceContourSmooth: Float = 0
    ) -> BeautyEffectiveStrengths {
        var value = BeautyEffectiveStrengths()
        value.faceSlim = faceSlim
        value.faceSmall = faceSmall
        value.faceVShape = faceVShape
        value.jawSlim = jawSlim
        value.faceContourSmooth = faceContourSmooth
        return value
    }

    private func roughness(_ contour: [SIMD2<Float>], indices: [Int]? = nil) -> Float {
        let evaluated = indices ?? Array(1..<(contour.count - 1))
        return evaluated.reduce(0) {
            $0 + abs(contour[$1].x - (contour[$1 - 1].x + contour[$1 + 1].x) / 2)
        }
    }

    private func render(
        _ image: CIImage,
        parameters: BeautyParameters,
        width: Int,
        height: Int,
        colorSpace: CGColorSpace
    ) -> [UInt8] {
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: Self.face)
        let output = BeautyGeometryEffectPipeline.applyMVPProxy(to: image, plan: plan, face: Self.face)
        return renderedBytes(output, width: width, height: height, colorSpace: colorSpace)
    }

    private func renderedBytes(
        _ image: CIImage,
        width: Int,
        height: Int,
        colorSpace: CGColorSpace
    ) -> [UInt8] {
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ])
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        bytes.withUnsafeMutableBytes { rawBytes in
            context.render(
                image,
                toBitmap: rawBytes.baseAddress!,
                rowBytes: width * 4,
                bounds: CGRect(x: 0, y: 0, width: width, height: height),
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return bytes
    }
}

private extension FaceContourSmoothRepairTests {
    struct Region {
        let minXPPM: Int
        let maxXPPM: Int
        let minYPPM: Int
        let maxYPPM: Int
    }

    struct Signal {
        var changedPixels = 0
        var absoluteRGBDelta = 0
    }

    struct Snapshot {
        let sourceTarget: Signal
        let neutralTarget: Signal
        let sourceSignedMarginQ16: Int64
        let neutralSignedMarginQ16: Int64
        let frozenSiblingDistinctMarginsQ16: [Int64]
        let strengtheningSiblingDistinctMarginsQ16: [Int64]
        let outside: Signal
        let central: Signal
        let background: Signal
        let watermark: Signal
    }

    static let targetRegions = [
        Region(minXPPM: 100_000, maxXPPM: 240_000, minYPPM: 280_000, maxYPPM: 820_000),
        Region(minXPPM: 760_000, maxXPPM: 920_000, minYPPM: 280_000, maxYPPM: 820_000),
    ]
    static let centralRegions = [
        Region(minXPPM: 250_000, maxXPPM: 750_000, minYPPM: 280_000, maxYPPM: 820_000),
    ]
    static let backgroundRegions = [
        Region(minXPPM: 0, maxXPPM: 90_000, minYPPM: 80_000, maxYPPM: 820_000),
        Region(minXPPM: 930_000, maxXPPM: 1_000_000, minYPPM: 80_000, maxYPPM: 820_000),
    ]
    static let watermarkRegions = [
        Region(minXPPM: 820_000, maxXPPM: 980_000, minYPPM: 920_000, maxYPPM: 985_000),
    ]

    static let contour: [SIMD2<Float>] = [
        .init(0.190, 0.300), .init(0.215, 0.360), .init(0.165, 0.430),
        .init(0.220, 0.500), .init(0.175, 0.580), .init(0.225, 0.660),
        .init(0.185, 0.750), .init(0.420, 0.815), .init(0.580, 0.815),
        .init(0.815, 0.750), .init(0.775, 0.660), .init(0.825, 0.580),
        .init(0.780, 0.500), .init(0.835, 0.430), .init(0.785, 0.360),
        .init(0.810, 0.300),
    ]

    static var face: FaceGeometry { face(contour: contour) }

    static func face(
        contour: [SIMD2<Float>] = contour,
        observedSupport: BeautyFaceSemanticSupport? = nil,
        useDefaultSupport: Bool = true
    ) -> FaceGeometry {
        FaceGeometry(
            bounds: FaceBounds(x: 0.10, y: 0.20, width: 0.80, height: 0.64),
            faceContour: contour,
            observedFaceSupport: useDefaultSupport
                ? BeautyFaceSemanticSupport(contour: contour, medianLine: nil, apexIndex: nil)
                : observedSupport
        )
    }

    static func generatedImage(width: Int, height: Int, colorSpace: CGColorSpace) -> CIImage {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for region in targetRegions {
            let minX = region.minXPPM * width / 1_000_000
            let maxX = region.maxXPPM * width / 1_000_000
            let minY = region.minYPPM * height / 1_000_000
            let maxY = region.maxYPPM * height / 1_000_000
            for row in minY..<maxY {
                for column in minX..<maxX {
                    let offset = (row * width + column) * 4
                    bytes[offset] = 254
                    bytes[offset + 1] = 254
                    bytes[offset + 2] = 254
                }
            }
        }
        for row in 0..<height {
            let y = (Float(row) + 0.5) / Float(height)
            for side in 0..<2 {
                guard let center = contourX(at: y, rightSide: side == 1) else { continue }
                let centerColumn = Int((center * Float(width)).rounded())
                for column in max(0, centerColumn - 7)...min(width - 1, centerColumn + 7) {
                    let distance = abs(column - centerColumn)
                    let value = UInt8(min(220, distance * 22))
                    let offset = (row * width + column) * 4
                    bytes[offset] = value
                    bytes[offset + 1] = value
                    bytes[offset + 2] = value
                }
            }
        }
        return CIImage(
            bitmapData: Data(bytes),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    static func generatedSilhouette(
        width: Int,
        height: Int,
        colorSpace: CGColorSpace,
        contour: [SIMD2<Float>] = contour,
        rasterizeInward: Bool = false
    ) -> CIImage {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for row in 0..<height {
            let y = (Float(row) + 0.5) / Float(height)
            guard let left = contourX(at: y, rightSide: false, contour: contour),
                  let right = contourX(at: y, rightSide: true, contour: contour) else { continue }
            let leftColumn = Int(rasterizeInward
                ? ceil(left * Float(width)) : (left * Float(width)).rounded())
            let rightColumn = Int(rasterizeInward
                ? floor(right * Float(width)) : (right * Float(width)).rounded())
            for column in 0..<width {
                let inside = column >= leftColumn && column <= rightColumn
                let value: UInt8 = inside ? 80 : 220
                let offset = (row * width + column) * 4
                bytes[offset] = value
                bytes[offset + 1] = value
                bytes[offset + 2] = value
            }
        }
        return CIImage(
            bitmapData: Data(bytes),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    static func contourX(
        at y: Float,
        rightSide: Bool,
        contour: [SIMD2<Float>] = contour
    ) -> Float? {
        let sidePoints: [SIMD2<Float>] = rightSide
            ? Array(contour[8...].reversed())
            : Array(contour[...7])
        let ordered = sidePoints.sorted { $0.y < $1.y }
        guard let first = ordered.first, let last = ordered.last else { return nil }
        if y < first.y { return first.x }
        if y > last.y { return last.x }
        for pair in zip(ordered, ordered.dropFirst()) where y >= pair.0.y && y <= pair.1.y {
            let span = pair.1.y - pair.0.y
            let progress = span > 0 ? (y - pair.0.y) / span : 0
            return pair.0.x + (pair.1.x - pair.0.x) * progress
        }
        return last.x
    }

    func semanticSnapshot(
        source: [UInt8],
        neutral: [UInt8],
        candidate: [UInt8],
        frozenSiblings: [[UInt8]],
        strengtheningSiblings: [[UInt8]],
        width: Int,
        height: Int
    ) throws -> Snapshot {
        let sourceMetric = try continuityMetric(source, width: width, height: height)
        let neutralMetric = try continuityMetric(neutral, width: width, height: height)
        let candidateMetric = try continuityMetric(candidate, width: width, height: height)
        let frozenSiblingMetrics = try frozenSiblings.map {
            try continuityMetric($0, width: width, height: height)
        }
        let strengtheningSiblingMetrics = try strengtheningSiblings.map {
            try continuityMetric($0, width: width, height: height)
        }
        return Snapshot(
            sourceTarget: signal(source, candidate, regions: Self.targetRegions, width: width, height: height),
            neutralTarget: signal(neutral, candidate, regions: Self.targetRegions, width: width, height: height),
            sourceSignedMarginQ16: candidateMetric - sourceMetric,
            neutralSignedMarginQ16: candidateMetric - neutralMetric,
            frozenSiblingDistinctMarginsQ16: frozenSiblingMetrics.map { abs(candidateMetric - $0) },
            strengtheningSiblingDistinctMarginsQ16: strengtheningSiblingMetrics.map {
                abs(candidateMetric - $0)
            },
            outside: signal(source, candidate, excluding: Self.targetRegions, width: width, height: height),
            central: signal(source, candidate, regions: Self.centralRegions, width: width, height: height),
            background: signal(source, candidate, regions: Self.backgroundRegions, width: width, height: height),
            watermark: signal(source, candidate, regions: Self.watermarkRegions, width: width, height: height)
        )
    }

    func continuityMetric(_ bytes: [UInt8], width: Int, height: Int) throws -> Int64 {
        var roughness: Int64 = 0
        var count: Int64 = 0
        for region in Self.targetRegions {
            let raster = rasterize(region, width: width, height: height)
            var centroids: [Int64] = []
            let comparableMaxY = min(raster.maxY, height - watermarkExcludedRows(width: width))
            for row in raster.minY..<comparableMaxY {
                var weight: Int64 = 0
                var weightedX: Int64 = 0
                for column in raster.minX..<raster.maxX {
                    let offset = (row * width + column) * 4
                    let lumaQ8 = Int64(bytes[offset]) * 77 + Int64(bytes[offset + 1]) * 150 + Int64(bytes[offset + 2]) * 29
                    let darkness = max(0, 255 * 256 - lumaQ8)
                    weight += darkness
                    weightedX += darkness * Int64(column * 2 + 1)
                }
                guard weight > 0 else { throw OracleError.emptyDarknessRow }
                centroids.append(weightedX * 65_536 / (weight * Int64(width * 2)))
            }
            for index in 1..<(centroids.count - 1) {
                roughness += abs(centroids[index - 1] + centroids[index + 1] - centroids[index] * 2)
                count += 1
            }
        }
        guard count > 0 else { throw OracleError.emptyDarknessRow }
        return -(roughness / count)
    }

    func silhouetteRoughness(_ bytes: [UInt8], width: Int, height: Int) throws -> Double {
        var total = 0.0
        var count = 0
        for rightSide in [false, true] {
            var edges: [Double] = []
            for row in Int(0.34 * Double(height))..<Int(0.72 * Double(height)) {
                let y = (Float(row) + 0.5) / Float(height)
                let reference = try XCTUnwrap(Self.contourX(at: y, rightSide: rightSide))
                let center = Int((reference * Float(width)).rounded())
                var edge: Double?
                for column in max(0, center - 12)..<min(width - 1, center + 12) {
                    let a = Double(bytes[(row * width + column) * 4])
                    let b = Double(bytes[(row * width + column + 1) * 4])
                    if rightSide ? (a <= 150 && b > 150) : (a > 150 && b <= 150) {
                        edge = Double(column) + (150 - a) / (b - a)
                        break
                    }
                }
                edges.append(try XCTUnwrap(edge))
            }
            for index in 1..<(edges.count - 1) {
                total += abs(edges[index - 1] + edges[index + 1] - 2 * edges[index])
                count += 1
            }
        }
        return total / Double(count)
    }

    func signal(
        _ lhs: [UInt8],
        _ rhs: [UInt8],
        regions: [Region],
        width: Int,
        height: Int
    ) -> Signal {
        signal(lhs, rhs, include: { column, row in
            regions.contains { contains($0, column: column, row: row, width: width, height: height) }
        }, width: width, height: height)
    }

    func signal(
        _ lhs: [UInt8],
        _ rhs: [UInt8],
        excluding regions: [Region],
        width: Int,
        height: Int
    ) -> Signal {
        signal(lhs, rhs, include: { column, row in
            !regions.contains { contains($0, column: column, row: row, width: width, height: height) }
        }, width: width, height: height)
    }

    func signal(
        _ lhs: [UInt8],
        _ rhs: [UInt8],
        include: (Int, Int) -> Bool,
        width: Int,
        height: Int
    ) -> Signal {
        var result = Signal()
        let comparableRows = max(0, height - watermarkExcludedRows(width: width))
        for row in 0..<comparableRows {
            for column in 0..<width where include(column, row) {
                let offset = (row * width + column) * 4
                let deltas = (0..<3).map { abs(Int(lhs[offset + $0]) - Int(rhs[offset + $0])) }
                if deltas.max()! > 2 { result.changedPixels += 1 }
                result.absoluteRGBDelta += deltas.reduce(0, +)
            }
        }
        return result
    }

    func rasterize(_ region: Region, width: Int, height: Int) -> (minX: Int, maxX: Int, minY: Int, maxY: Int) {
        (
            region.minXPPM * width / 1_000_000,
            region.maxXPPM * width / 1_000_000,
            region.minYPPM * height / 1_000_000,
            region.maxYPPM * height / 1_000_000
        )
    }

    func contains(_ region: Region, column: Int, row: Int, width: Int, height: Int) -> Bool {
        let raster = rasterize(region, width: width, height: height)
        return column >= raster.minX && column < raster.maxX && row >= raster.minY && row < raster.maxY
    }

    func watermarkExcludedRows(width: Int) -> Int {
        let fontSize = max(34.0, min(72.0, Double(width) / 30.0))
        let padding = max(24.0, Double(width) / 70.0)
        return Int(ceil(padding * 2.0 + fontSize * 1.75))
    }

    enum OracleError: Error {
        case emptyDarknessRow
    }
}
