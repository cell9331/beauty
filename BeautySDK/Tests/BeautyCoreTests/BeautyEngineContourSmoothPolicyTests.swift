import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import ImageIO
import XCTest
@testable import BeautyEffects
@testable import BeautySDK

/// This source-only policy is independent of the refiner's private protection
/// and of the width candidate. Old C39 tests, masks and failures stay intact.
/// A native run detects its own original source; Vision geometry is never
/// substituted for MediaPipe. Raw material stays under the ignored opt-in.
final class BeautyEngineContourSmoothPolicyTests: XCTestCase {
    private enum Failure: Error { case invalidInput, invalidSource, invalidOutput }
    private let space = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
    // SHA of the frozen canonical PNG FILE, distinct from a raster digest.
    private let expectedSourceHash = "bd5fe998c2e49b0812a9bd881bbc4c345eb15c10445b16bc790ba7f40c4b2213"
    private let maskHashes = [
        "ears_core": "d8a609c613fdb6761e58886b8cf5d94e29af6c0fe74b26cf46286245cc477d1a",
        "eyes_core": "a8219b5a697f2feed1e3b3e4a33f0f49a777a60779d76f7aaba188125016f958",
        "brows_core": "99cea5696cba82870200beead7c6edbe32443e76bdf3a7796c5f89560dfa2e6e",
        "nose_core": "ad5258bf511fe2e553049d9e1c05307942269c1d94d52ebe0c2f580e2f186452",
        "lips_core": "cde38241edb193ba5eef0b856b5486900776fa9f2b3456d326536b638be6aa64",
        "hair_core": "23566188baca12ac9383890400191839abd6e2d56781ad02c2a5ef8b7edd844b",
        "crossing_hair_core": "25312aa75a324d863ccaef45fe1f564f7cb6e24c6e8c6f29004f303f17ba2202",
        "semantic_core_union": "f907f32982aac47b2ad0cf50d7c4a4ec898b5af2ff49c8865378251bd9d3a640"
    ]

    func testSmoothPhotoRetainsSourceFixedNarrowPolicyAndFrozenActivityGate() throws {
        let env = ProcessInfo.processInfo.environment
        guard let path = env["BEAUTY_FACE_REFERENCE_INPUT"] else {
            try testSourceFixedPolicyDetectsKnownPermanentExteriorAndAlphaChanges()
            return
        }
        let inputURL = sourceURL(path)
        let values = try inputURL.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        guard values.isRegularFile == true, values.isSymbolicLink != true,
              let size = values.fileSize, size > 0, size <= BeautyConfiguration.defaultMaximumInputByteCount,
              hash(try Data(contentsOf: inputURL)) == expectedSourceHash,
              let input = CIImage(contentsOf: inputURL, options: [.applyOrientationProperty: true])
        else { throw Failure.invalidInput }
        let output = try outputDirectory(env["BEAUTY_FACE_REFERENCE_OUTPUT"])
        let canonicalizer = BeautyStillImageCanonicalizer()
        let full = try canonicalizer.canonicalize(image: input, metadata: metadata,
            maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
        var records = [[String: Any]]()
        for (id, scale) in [("full", 1.0), ("preview960", min(1, 960 / Double(max(full.width, full.height))))] {
            let image = full.ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
                .cropped(to: CGRect(x: 0, y: 0, width: floor(Double(full.width) * scale),
                    height: floor(Double(full.height) * scale)))
            let raster = try canonicalizer.canonicalize(image: image, metadata: metadata,
                maximumPixelCount: BeautyConfiguration.defaultMaximumInputPixelCount)
            let width = raster.width, height = raster.height, source = Array(raster.rgba8Data)
            XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy { source[$0] == 255 })
            var detector = BeautyFaceDetector.production()
            let detection = detector.detect(image: raster.ciImage, metadata: metadata,
                imageExtent: raster.ciImage.extent.size, purpose: .geometryAndLocalSupport)
            XCTAssertEqual(detection.summary.availability, .usable)
            XCTAssertEqual(detection.observations.count, 1)
            let observation = try XCTUnwrap(detection.observations.first)
            let frame = try sourceFrame(observation, width: width, height: height)
            let masks = try ["ears_core", "eyes_core", "brows_core", "nose_core", "lips_core", "hair_core", "crossing_hair_core"]
                .map { try mask($0, width: width, height: height) }
            // Complete domain/masks, including the old activity denominator,
            // are frozen before even the first candidate is requested.
            let policy = Policy(frame: frame, width: width, height: height, masks: masks,
                frozenActivityUnion: try oldActivityUnion(width: width, height: height))
            let admittedCount = policy.allowed.filter { $0 }.count, activityCount = policy.activity.filter { $0 }.count
            XCTAssertGreaterThan(admittedCount, 16)
            XCTAssertGreaterThan(activityCount, 16)
            XCTAssertEqual(policy.circleEarOverlap, 0, "\(id) the entire declared source circle must avoid permanent ears BEFORE rendering")
            XCTAssertEqual(policy.circleFeatureOverlap, 0, "\(id) the entire declared source circle must avoid permanent features BEFORE rendering")
            let sourceDeclarationQualified = admittedCount > 16 && activityCount > 16 && policy.segmentCount > 0 &&
                policy.circleEarOverlap == 0 && policy.circleFeatureOverlap == 0 &&
                stride(from: 3, to: source.count, by: 4).allSatisfy { source[$0] == 255 }
            guard sourceDeclarationQualified else {
                records.append(["layer": id, "sourceGeometry": observation.mesh == nil ? "production-Vision" : "production-MediaPipe",
                    "sourceDeclarationQualified": false, "candidateRendered": false,
                    "sourceCircleEarOverlapPixels": policy.circleEarOverlap,
                    "sourceCircleFeatureOverlapPixels": policy.circleFeatureOverlap,
                    "sourceClippedArcCount": policy.segmentCount, "admittedSourcePixelCount": admittedCount,
                    "oldActivityDenominatorPixels": activityCount])
                continue
            }
            let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
            let parameters = BeautyParameters(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            let direct = FaceContourSubpixelRefiner.refineWithProtection(source, width: width,
                height: height, face: face, strength: plan.effectiveStrengths.faceContourSmooth)
            let stage = BeautyStillImageGeometryStage(sourceRGBA: source, width: width,
                height: height, plan: plan, face: face)
            let dense = stage.applyingDenseMap(to: stage.sourceRGBA)
            XCTAssertTrue(stage.sourceRGBA == direct.bytes, "isolated smooth source stage")
            XCTAssertTrue(dense == stage.sourceRGBA, "observed source smoothing cannot receive a second proxy")
            XCTAssertTrue(stage.controlPoints.isEmpty, "isolated source smoothing owns the raster")
            let engine = try BeautyEngine()
            let context = CIContext(options: [.workingColorSpace: space, .outputColorSpace: space])
            let cg = try XCTUnwrap(context.createCGImage(raster.ciImage, from: raster.ciImage.extent,
                format: .RGBA8, colorSpace: space))
            let prepared = try engine.prepareStillImage(image: cg, metadata: metadata)
            let result = try engine.processResult(preparedImage: prepared, parameters: parameters)
            let actual = try pixels(result.output, width: width, height: height)
            var phases = [[String: Any]]()
            for (name, bytes) in [("direct", direct.bytes), ("stage", stage.sourceRGBA), ("dense", dense), ("public", actual)] {
                let counts = policy.counts(source: source, output: bytes)
                XCTAssertEqual(counts.permanent, 0, "\(id)_\(name) ears and complete source features remain permanent")
                XCTAssertEqual(counts.bodyHair, 0, "\(id)_\(name) source hair outside the predeclared circle")
                XCTAssertEqual(counts.exterior, 0, "\(id)_\(name) every source texel outside the circle remains exact")
                XCTAssertEqual(counts.alpha, 0, "\(id)_\(name) alpha")
                phases.append(["phase": name, "permanentChangedPixels": counts.permanent,
                    "bodyHairChangedPixels": counts.bodyHair, "exteriorChangedPixels": counts.exterior,
                    "alphaChangedPixels": counts.alpha, "oldFineCoreChangedDiagnostic": counts.oldFine,
                    "oldActivityRMSByteDelta": counts.rms, "oldActivityMaximumByteDelta": counts.maximum,
                    "oldActivityChangedPixels": counts.changed])
            }
            let activity = policy.counts(source: source, output: actual)
            let useful = activity.rms >= 0.25 && activity.maximum >= 3 && activity.changed >= 16
            XCTAssertTrue(useful, "\(id) keeps the old C39 denominator and .25/3/16 gate; no-op is not delivery")
            let repeated = try engine.processResult(preparedImage: prepared, parameters: parameters)
            let repeatedExact = actual == (try pixels(repeated.output, width: width, height: height))
            XCTAssertTrue(repeatedExact)
            let neutral = try engine.processResult(preparedImage: prepared, parameters: .init())
            let neutralExact = source == (try pixels(neutral.output, width: width, height: height))
            XCTAssertTrue(neutralExact)
            XCTAssertEqual(result.output.extent, raster.ciImage.extent)
            // Isolated coarse geometry keeps the original legacy CI tag;
            // dense geometry names the source sRGB carrier. All pixel checks
            // still materialize through the explicit sRGB context above.
            let activeSpace = face.denseSupport == nil ? CGColorSpaceCreateDeviceRGB() : space
            let resultSpace = try XCTUnwrap(result.output.colorSpace)
            XCTAssertTrue(CFEqual(resultSpace, activeSpace))
            XCTAssertEqual(neutral.output.colorSpace?.name, space.name)
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1)
            try save(result.output, to: output.appendingPathComponent("\(id)-smooth-narrow-policy.png"))
            records.append(["layer": id, "sourceGeometry": observation.mesh == nil ? "production-Vision" : "production-MediaPipe",
                "sourceContourCount": frame.contour.count, "sourceClippedArcCount": policy.segmentCount,
                "sourceCircleRadiusPixels": policy.radius, "sourceCircleNormalizedRadius": policy.radius / frame.localSpan,
                "circleSelectedFromCandidateOutput": false, "permanentSourcePixelCount": policy.permanent.filter { $0 }.count,
                "sourceDeclarationQualified": true, "candidateRendered": true,
                "sourceCircleEarOverlapPixels": policy.circleEarOverlap,
                "sourceCircleFeatureOverlapPixels": policy.circleFeatureOverlap,
                "admittedSourcePixelCount": admittedCount, "oldActivityDenominatorPixels": activityCount,
                "retainedProxyPointCount": stage.controlPoints.count, "usesDenseMap": stage.usesDenseMap,
                "oldActivityGatePassed": useful, "neutralExact": neutralExact, "repeatedExact": repeatedExact, "phases": phases])
        }
        let receipt: [String: Any] = ["schema": "smooth-source-fixed-narrow-policy/v2",
            "sourceOnlyDomainBeforeRendering": true, "candidatePointSelection": false,
            "oldC39TestsAndFailuresReplaced": false, "oldActivityDenominatorPreserved": true,
            "appearanceParity": false, "curvatureImprovementQualified": false,
            "fullSDKRegression": false, "records": records]
        let url = output.appendingPathComponent("smooth-narrow-policy-aggregate.json")
        guard !FileManager.default.fileExists(atPath: url.path) else { throw Failure.invalidOutput }
        try JSONSerialization.data(withJSONObject: receipt, options: [.prettyPrinted, .sortedKeys]).write(to: url)
    }

    func testSourceFixedPolicyDetectsKnownPermanentExteriorAndAlphaChanges() throws {
        let width = 240, height = 320
        let contour: [SIMD2<Double>] = [SIMD2(70, 95), SIMD2(65, 125), SIMD2(75, 150), SIMD2(85, 185),
            SIMD2(100, 215), SIMD2(120, 235), SIMD2(140, 215), SIMD2(155, 185), SIMD2(165, 150), SIMD2(175, 125), SIMD2(170, 95)]
        let frame = Frame(contour: contour, featureBoxes: [], extraPermanentBoxes: [], origin: SIMD2(120, 110),
            axisX: SIMD2(1, 0), axisY: SIMD2(0, 1), span: 110, localSpan: 110, chin: 125, lowerBound: 45.88)
        var masks = Array(repeating: [Bool](repeating: false, count: width * height), count: 7)
        // Immutable known semantic points: one ear on the eligible arc, one
        // hair point far outside it. Geometry alone must never exempt the ear.
        let ear = 170 * width + 81, hair = 80 * width + 20
        masks[0][ear] = true; masks[5][hair] = true
        let policy = Policy(frame: frame, width: width, height: height, masks: masks)
        XCTAssertFalse(policy.allowed[ear]); XCTAssertTrue(policy.permanent[ear])
        XCTAssertFalse(policy.allowed[hair]); XCTAssertTrue(policy.bodyHair[hair])
        XCTAssertEqual(policy.circleEarOverlap, 1, "a circle intersecting the permanent ear is rejected before rendering")
        XCTAssertEqual(policy.circleFeatureOverlap, 0)
        var cleanMasks = masks; cleanMasks[0][ear] = false
        let cleanPolicy = Policy(frame: frame, width: width, height: height, masks: cleanMasks)
        XCTAssertEqual(cleanPolicy.circleEarOverlap, 0); XCTAssertEqual(cleanPolicy.circleFeatureOverlap, 0)
        let admitted = try XCTUnwrap(policy.allowed.indices.first { policy.allowed[$0] })
        let pixel: [UInt8] = [160, 120, 95, 255]
        let source = Array(repeating: pixel, count: width * height).flatMap { $0 }
        XCTAssertEqual(policy.counts(source: source, output: source).exterior, 0)
        var legal = source; legal[admitted * 4] += 1
        let legalCounts = policy.counts(source: source, output: legal)
        XCTAssertEqual(legalCounts.exterior, 0); XCTAssertEqual(legalCounts.permanent, 0)
        XCTAssertEqual(legalCounts.changed, 1); XCTAssertEqual(legalCounts.maximum, 1)
        var invalid = source
        invalid[ear * 4] += 1; invalid[hair * 4] += 1; invalid[3] = 254
        let counts = policy.counts(source: source, output: invalid)
        XCTAssertEqual(counts.permanent, 1); XCTAssertEqual(counts.bodyHair, 1)
        XCTAssertEqual(counts.exterior, 3); XCTAssertEqual(counts.alpha, 1)
        XCTAssertEqual(counts.oldFine, 2)
        // The no-env entry is useful correctness coverage, not a photograph
        // effect or a source-segmentation qualification claim.
    }

    private struct Frame {
        let contour: [SIMD2<Double>]
        let featureBoxes: [CGRect]
        let extraPermanentBoxes: [CGRect]
        let origin: SIMD2<Double>, axisX: SIMD2<Double>, axisY: SIMD2<Double>
        let span: Double, localSpan: Double, chin: Double, lowerBound: Double
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let d = p - origin
            return SIMD2(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
        }
        func image(_ p: SIMD2<Double>) -> SIMD2<Double> { origin + axisX * p.x + axisY * p.y }
    }

    private func sourceFrame(_ observation: BeautyFaceObservation, width: Int, height: Int) throws -> Frame {
        guard let raw = observation.observedFaceSupport?.contour, (7...32).contains(raw.count),
              let eyes = observation.observedEyeSupport, eyes.count == 2,
              let left = eyes.first(where: { $0.side == .left })?.contour, left.count >= 4,
              let right = eyes.first(where: { $0.side == .right })?.contour, right.count >= 4,
              let brows = observation.observedEyebrowSupport, let lb = brows.left, lb.count >= 4,
              let rb = brows.right, rb.count >= 4, let lips = observation.observedLipSupport?.outer, lips.count >= 4,
              let nose = observation.observedNoseSupport, nose.contour.count >= 4, nose.crest.count >= 3
        else { throw Failure.invalidSource }
        let paths = [left, right, lb, rb, lips + (observation.observedLipSupport?.inner ?? []), nose.contour + nose.crest]
        guard (raw + paths.flatMap { $0 }).allSatisfy({ $0.x.isFinite && $0.y.isFinite &&
            (0...1).contains($0.x) && (0...1).contains($0.y) }) else { throw Failure.invalidSource }
        func pixel(_ p: CoordinatePoint) -> SIMD2<Double> { SIMD2(p.x * Double(width), p.y * Double(height)) }
        func mean(_ p: [CoordinatePoint]) -> SIMD2<Double> { p.map(pixel).reduce(.zero, +) / Double(p.count) }
        let vector = mean(right) - mean(left), distance = hypot(vector.x, vector.y)
        guard distance > 4 else { throw Failure.invalidSource }
        let axisX = vector / distance, axisY = SIMD2(-axisX.y, axisX.x), origin = (mean(left) + mean(right)) * 0.5
        let contour = raw.map(pixel)
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let d = p - origin
            return SIMD2(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
        }
        let points = contour.map(local), span = contour.map(\.x).max()! - contour.map(\.x).min()!
        let localSpan = points.map(\.x).max()! - points.map(\.x).min()!, chin = points.map(\.y).max()!
        guard span > 8, localSpan > 8, chin > 8 else { throw Failure.invalidSource }
        func box(_ p: [CoordinatePoint]) -> CGRect {
            let q = p.map(pixel), margin = max(2, span * 0.008)
            return CGRect(x: q.map(\.x).min()! - margin, y: q.map(\.y).min()! - margin,
                width: q.map(\.x).max()! - q.map(\.x).min()! + 2 * margin,
                height: q.map(\.y).max()! - q.map(\.y).min()! + 2 * margin)
        }
        let featureBoxes = paths.map(box)
        var extra = [CGRect]()
        if let mesh = observation.mesh {
            let densePaths = [mesh.path(MediaPipeFaceTopology.leftBrowEnvelope), mesh.path(MediaPipeFaceTopology.rightBrowEnvelope)]
            guard densePaths.allSatisfy({ $0.count >= 4 && $0.allSatisfy {
                $0.x.isFinite && $0.y.isFinite && (0...1).contains($0.x) && (0...1).contains($0.y)
            } }) else { throw Failure.invalidSource }
            extra = densePaths.map(box)
        }
        let noseBottom = paths[5].map { local(pixel($0)).y }.max()!
        return Frame(contour: contour, featureBoxes: featureBoxes, extraPermanentBoxes: extra,
            origin: origin, axisX: axisX, axisY: axisY, span: span, localSpan: localSpan, chin: chin,
            lowerBound: max(chin * 0.32, noseBottom + localSpan * 0.008))
    }

    private struct Counts {
        var permanent = 0, bodyHair = 0, exterior = 0, alpha = 0, oldFine = 0
        var rms = 0.0, maximum = 0, changed = 0
    }

    private struct Policy {
        let allowed: [Bool], permanent: [Bool], bodyHair: [Bool], oldFine: [Bool], activity: [Bool]
        let radius: Double, segmentCount: Int, circleEarOverlap: Int, circleFeatureOverlap: Int
        init(frame: Frame, width: Int, height: Int, masks: [[Bool]], frozenActivityUnion: [Bool]? = nil) {
            let radius = min(0.06 * frame.localSpan, 48 * Double(max(width, height)) / 1920)
            var segments = [(SIMD2<Double>, SIMD2<Double>)]()
            for (a, b) in zip(frame.contour, frame.contour.dropFirst()) {
                let ya = frame.local(a).y, yb = frame.local(b).y, dy = yb - ya
                var low = 0.0, high = 1.0
                if dy == 0 {
                    guard ya >= frame.lowerBound && ya <= frame.chin * 0.70 else { continue }
                } else {
                    let t0 = (frame.lowerBound - ya) / dy, t1 = (frame.chin * 0.70 - ya) / dy
                    low = max(0, min(t0, t1)); high = min(1, max(t0, t1))
                }
                if high > low { segments.append((a + (b - a) * low, a + (b - a) * high)) }
            }
            var path = frame.contour
            if frame.local(path[0]).x > frame.local(path.last!).x { path.reverse() }
            let left = frame.local(path[0]), right = frame.local(path.last!)
            // Exact original C39 activity domain and denominator. The new
            // circle does not shrink the denominator or erase old hair cores.
            path = [frame.image(SIMD2(left.x * 0.96, -frame.chin * 0.32)),
                frame.image(SIMD2(left.x, -frame.chin * 0.12))] + path +
                [frame.image(SIMD2(right.x, -frame.chin * 0.12)), frame.image(SIMD2(right.x * 0.96, -frame.chin * 0.32))]
            func distanceSquared(_ q: SIMD2<Double>, _ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double {
                let d = b - a, length = d.x * d.x + d.y * d.y
                guard length > 0 else { return .infinity }
                let v = q - a, t = max(0, min(1, (v.x * d.x + v.y * d.y) / length)), r = v - d * t
                return r.x * r.x + r.y * r.y
            }
            var allowed = [Bool](repeating: false, count: width * height), permanent = allowed
            var bodyHair = allowed, oldFine = allowed, activity = allowed
            var circleEarOverlap = 0, circleFeatureOverlap = 0
            for y in 0..<height { for x in 0..<width {
                let p = y * width + x, q = SIMD2(Double(x) + 0.5, Double(y) + 0.5), point = CGPoint(x: q.x, y: q.y)
                let inCircle = segments.contains { distanceSquared(q, $0.0, $0.1) <= radius * radius }
                var inside = false
                for (a, b) in zip(path, Array(path.dropFirst()) + [path[0]]) where (a.y > q.y) != (b.y > q.y) {
                    if q.x < (b.x - a.x) * (q.y - a.y) / (b.y - a.y) + a.x { inside.toggle() }
                }
                let oldRadiusSquared = pow(inside ? frame.span * 0.20 : frame.span * 0.06 + 2, 2)
                let oldTarget = zip(path, path.dropFirst()).contains { distanceSquared(q, $0.0, $0.1) <= oldRadiusSquared }
                let feature = frame.featureBoxes.contains { $0.contains(point) }
                let wholeFeature = masks[1..<5].contains { $0[p] } || feature ||
                    frame.extraPermanentBoxes.contains { $0.contains(point) }
                permanent[p] = masks[0][p] || wholeFeature
                if inCircle && masks[0][p] { circleEarOverlap += 1 }
                if inCircle && wholeFeature { circleFeatureOverlap += 1 }
                oldFine[p] = frozenActivityUnion?[p] ?? masks.contains { $0[p] }
                bodyHair[p] = (masks[5][p] || masks[6][p]) && !inCircle
                allowed[p] = inCircle && oldTarget && !permanent[p]
                activity[p] = oldTarget && !feature && !oldFine[p]
            } }
            self.allowed = allowed; self.permanent = permanent; self.bodyHair = bodyHair
            self.oldFine = oldFine; self.activity = activity; self.radius = radius; segmentCount = segments.count
            self.circleEarOverlap = circleEarOverlap; self.circleFeatureOverlap = circleFeatureOverlap
        }
        func counts(source: [UInt8], output: [UInt8]) -> Counts {
            var result = Counts(), square = 0.0, samples = 0
            for p in allowed.indices {
                let i = p * 4, differs = (0..<4).contains { source[i + $0] != output[i + $0] }
                if differs {
                    if permanent[p] { result.permanent += 1 }
                    if bodyHair[p] { result.bodyHair += 1 }
                    if !allowed[p] { result.exterior += 1 }
                    if oldFine[p] { result.oldFine += 1 }
                }
                if source[i + 3] != output[i + 3] { result.alpha += 1 }
                if activity[p] {
                    var pixelChanged = false
                    for c in 0..<3 {
                        let delta = abs(Int(output[i + c]) - Int(source[i + c]))
                        square += Double(delta * delta); samples += 1
                        result.maximum = max(result.maximum, delta); pixelChanged = pixelChanged || delta != 0
                    }
                    if pixelChanged { result.changed += 1 }
                }
            }
            result.rms = sqrt(square / Double(max(1, samples)))
            return result
        }
    }

    private func hash(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }
    private func privateBundleURL(_ name: String) -> URL {
        Bundle(for: BeautyEngineContourSmoothPolicyTests.self).bundleURL
            .appendingPathComponent("NativePrivatePhoto", isDirectory: true)
            .appendingPathComponent(name + ".png")
    }
    private func sourceURL(_ optInPath: String) -> URL {
        #if os(iOS)
        // The environment is still the explicit opt-in. Resolve the staged
        // source relative to the installed bundle rather than a Mac URL.
        return privateBundleURL("portrait")
        #else
        return URL(fileURLWithPath: optInPath).standardizedFileURL
        #endif
    }
    private func annotationURL(_ name: String) throws -> URL {
        // Native preparation stages exact private files beside portrait.png
        // inside the hostless test bundle. No Mac source-tree path is used on
        // iOS, and missing bundle fixtures cannot become an empty-mask pass.
        let bundled = privateBundleURL(name)
        if FileManager.default.fileExists(atPath: bundled.path) { return bundled }
        #if os(iOS)
        throw Failure.invalidSource
        #else
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return package.appendingPathComponent(".build/face-reference/protection-masks-v2/\(name).png")
        #endif
    }
    /// The C39 activity oracle used Core Image's existing scale/render and
    /// >=128 threshold for its union, including preview. Preserve that exact
    /// denominator separately from nearest-registered semantic categories.
    private func oldActivityUnion(width: Int, height: Int) throws -> [Bool] {
        let url = try annotationURL("semantic_core_union")
        guard hash(try Data(contentsOf: url)) == maskHashes["semantic_core_union"],
              let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]),
              image.extent.width > 1, image.extent.height > 1,
              abs(image.extent.width / image.extent.height - Double(width) / Double(height)) < 0.002
        else { throw Failure.invalidSource }
        let target = CGRect(x: 0, y: 0, width: width, height: height)
        let scaled = image.transformed(by: CGAffineTransform(scaleX: Double(width) / image.extent.width,
            y: Double(height) / image.extent.height)).cropped(to: target)
        let bytes = try pixels(scaled, width: width, height: height)
        guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else { throw Failure.invalidSource }
        return (0..<(width * height)).map { bytes[$0 * 4] >= 128 }
    }
    private func mask(_ name: String, width: Int, height: Int) throws -> [Bool] {
        let url = try annotationURL(name)
        guard hash(try Data(contentsOf: url)) == maskHashes[name], let image = CIImage(contentsOf: url),
              image.extent.origin == .zero else { throw Failure.invalidSource }
        let w = Int(image.extent.width), h = Int(image.extent.height)
        guard w > 1, h > 1, abs(Double(w) / Double(h) - Double(width) / Double(height)) < 0.002 else { throw Failure.invalidSource }
        let bytes = try pixels(image, width: w, height: h)
        guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else { throw Failure.invalidSource }
        return (0..<(width * height)).map { p in
            let x = min(w - 1, Int((Double(p % width) + 0.5) * Double(w) / Double(width)))
            let y = min(h - 1, Int((Double(p / width) + 0.5) * Double(h) / Double(height)))
            return bytes[(y * w + x) * 4] >= 128
        }
    }
    private func pixels(_ image: CIImage, width: Int, height: Int) throws -> [UInt8] {
        guard image.extent == CGRect(x: 0, y: 0, width: width, height: height) else { throw Failure.invalidSource }
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        CIContext(options: [.workingColorSpace: space, .outputColorSpace: space]).render(image,
            toBitmap: &bytes, rowBytes: width * 4, bounds: image.extent, format: .RGBA8, colorSpace: space)
        return bytes
    }
    private func outputDirectory(_ path: String?) throws -> URL {
        guard let path else { throw Failure.invalidOutput }
        let output = URL(fileURLWithPath: path).standardizedFileURL
        guard output.resolvingSymlinksInPath().path == output.path else { throw Failure.invalidOutput }
        #if os(iOS)
        // Existing hostless preparation supplies this owner-local run folder.
        // Never try to derive an iOS output root from the Mac #filePath.
        guard output.path.contains("/.build/face-reference/native/outputs/") else { throw Failure.invalidOutput }
        #else
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let allowed = package.appendingPathComponent(".build/face-reference").standardizedFileURL
        guard output.path.hasPrefix(allowed.path + "/") else { throw Failure.invalidOutput }
        #endif
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        return output
    }
    private func save(_ image: CIImage, to url: URL) throws {
        guard !FileManager.default.fileExists(atPath: url.path) else { throw Failure.invalidOutput }
        let context = CIContext(options: [.workingColorSpace: space, .outputColorSpace: space])
        let cg = try XCTUnwrap(context.createCGImage(image, from: image.extent, format: .RGBA8, colorSpace: space))
        let destination = try XCTUnwrap(CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil))
        CGImageDestinationAddImage(destination, cg, nil)
        guard CGImageDestinationFinalize(destination) else { throw Failure.invalidOutput }
    }
}
