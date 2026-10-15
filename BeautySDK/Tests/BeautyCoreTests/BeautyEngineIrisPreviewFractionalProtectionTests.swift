import BeautyCore
import BeautyDetection
import BeautyEffects
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@testable import BeautySDK

/// Fractional ImageIO scaling must preserve the ordinary thumbnail sibling
/// result outside the source-defined iris operation window. Neither the
/// protected region nor its exact tolerance comes from the candidate output.
final class BeautyEngineIrisPreviewFractionalProtectionTests: XCTestCase {
    private let sourceWidth = 512, sourceHeight = 384
    private let previewWidth = 300, previewHeight = 225
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private let context = CIContext(options: [.cacheIntermediates: false,
        .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
        .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])

    func testStrongColorAtFractionalScaleKeepsLegacyThumbnailOutsideIris() throws {
        var parameters = BeautyParameters()
        parameters.contrast = 0.7
        parameters.brightness = 0.3
        try assertLegacyProtection(parameters: parameters, activityRegion:
            CGRect(x: 0.02, y: 0.80, width: 0.14, height: 0.12), name: "strong color")
    }

    func testUnmaskedActiveTextureAtFractionalScaleKeepsLegacyThumbnailOutsideIris() throws {
        try assertLegacyProtection(parameters: BeautyParameters(skinSmoothing: 0.3),
            activityRegion: CGRect(x: 0.30, y: 0.53, width: 0.10, height: 0.06),
            name: "unmasked smoothing")
    }

    private func assertLegacyProtection(parameters: BeautyParameters, activityRegion: CGRect,
                                        name: String, file: StaticString = #filePath, line: UInt = #line) throws {
        let source = try makeSource()
        let thumbnail = try legacyThumbnail(source)
        XCTAssertEqual(thumbnail.width, previewWidth, file: file, line: line)
        XCTAssertEqual(thumbnail.height, previewHeight, file: file, line: line)
        let observed = try observation()
        let originalProbe = Probe(observation: observed)
        let preview = try BeautyEngine(faceDetector: originalProbe.detector())
        let originalPrepared = try preview.prepareStillImage(image: source)
        // B is independently generated through the ordinary prepared engine.
        // It is deliberately not the new preview cutpoint's p0 output.
        let legacyProbe = Probe(observation: observed)
        let legacy = try BeautyEngine(faceDetector: legacyProbe.detector())
        let legacyPrepared = try legacy.prepareStillImage(image: thumbnail)
        let neutral = try legacy.processResult(preparedImage: legacyPrepared, parameters: .init())
        let ordinary = try legacy.processResult(preparedImage: legacyPrepared, parameters: parameters)
        let baseline = pixels(ordinary.output), neutralPixels = pixels(neutral.output)
        let legacyActivity = regionDelta(baseline, neutralPixels, in: activityRegion)
        XCTAssertGreaterThan(legacyActivity, 0,
            "\(name) source fixture must exercise an actually admitted ordinary sibling", file: file, line: line)
        let zero = try preview.processIrisPreviewResult(preparedImage: originalPrepared,
            maximumPreviewEdge: previewWidth, parameters: parameters)
        let zeroDelta = delta(pixels(zero.output), baseline)
        XCTAssertEqual(zeroDelta, 0,
            "\(name) p0 fullRGBA must equal independent legacy thumbnail B; aggregate delta=\(zeroDelta)",
            file: file, line: line)
        // A signed quarter of the existing +/-0.25 safety cap. The two
        // directions reuse the original; neither can accumulate the other.
        for fraction: Float in [-0.25, 0.25] {
            var combined = parameters
            combined.pupilSize = 0.25 * fraction
            let result = try preview.processIrisPreviewResult(preparedImage: originalPrepared,
                maximumPreviewEdge: previewWidth, parameters: combined)
            XCTAssertEqual(result.output.extent,
                CGRect(x: 0, y: 0, width: previewWidth, height: previewHeight), file: file, line: line)
            XCTAssertEqual(result.output.colorSpace?.name, colorSpace.name, file: file, line: line)
            let actual = pixels(result.output)
            let protectedDelta = outsideIrisDelta(actual, baseline)
            XCTAssertEqual(protectedDelta, 0,
                "\(name) iris quarter \(fraction) must retain legacy B outside fixed source windows; fullRGBA delta=\(protectedDelta)",
                file: file, line: line)
            XCTAssertGreaterThan(insideIrisDelta(actual, baseline), 0,
                "the source circle must produce a real iris change", file: file, line: line)
            XCTAssertGreaterThan(result.metrics["beauty.irisPreview.completedEyeCount"] ?? 0, 0,
                file: file, line: line)
            XCTAssertEqual(result.metrics["beauty.irisPreview.originalFirstCPU"], 1, file: file, line: line)
            XCTAssertTrue(stride(from: 3, to: actual.count, by: 4).allSatisfy { actual[$0] == 255 },
                file: file, line: line)
        }
        XCTAssertEqual(originalProbe.calls, 1, "all signed combinations reuse original detection", file: file, line: line)
        XCTAssertEqual(originalProbe.extents, [CGSize(width: sourceWidth, height: sourceHeight)], file: file, line: line)
        let legacyNeedsFace = BeautyEffectResolver.requiresFaceGeometry(parameters: parameters)
            || parameters.skinSmoothing > 0 || parameters.skinSharpen > 0
        XCTAssertEqual(legacyProbe.extents, legacyNeedsFace ? [CGSize(width: previewWidth, height: previewHeight)] : [],
            file: file, line: line)
    }

    private func inIrisWindow(x: Int, y: Int) -> Bool {
        let p = SIMD2((Double(x) + 0.5) * Double(sourceWidth) / Double(previewWidth),
                      (Double(y) + 0.5) * Double(sourceHeight) / Double(previewHeight))
        // Both source circles have R0=12. The full positive cap defines a
        // conservative fixed window, shared by p0 and both quarter signs.
        let window = (1 + 100.0 / 79) * 12
        return [0.32, 0.68].contains { centerX in
            let d = p - SIMD2(centerX * Double(sourceWidth), 0.4 * Double(sourceHeight))
            return hypot(d.x, d.y) < window
        }
    }

    private func outsideIrisDelta(_ actual: [UInt8], _ baseline: [UInt8]) -> Int {
        windowDelta(actual, baseline, inside: false)
    }

    private func insideIrisDelta(_ actual: [UInt8], _ baseline: [UInt8]) -> Int {
        windowDelta(actual, baseline, inside: true)
    }

    private func windowDelta(_ a: [UInt8], _ b: [UInt8], inside: Bool) -> Int {
        var result = 0
        for y in 0..<previewHeight { for x in 0..<previewWidth where inIrisWindow(x: x, y: y) == inside {
            let index = (y * previewWidth + x) * 4
            for channel in 0..<4 { result += abs(Int(a[index + channel]) - Int(b[index + channel])) }
        } }
        return result
    }

    private func delta(_ a: [UInt8], _ b: [UInt8]) -> Int {
        zip(a, b).reduce(0) { $0 + abs(Int($1.0) - Int($1.1)) }
    }

    private func regionDelta(_ a: [UInt8], _ b: [UInt8], in region: CGRect) -> Int {
        var result = 0
        for y in 0..<previewHeight { for x in 0..<previewWidth {
            let point = CGPoint(x: (Double(x) + 0.5) / Double(previewWidth),
                                y: (Double(y) + 0.5) / Double(previewHeight))
            if region.contains(point) {
                let index = (y * previewWidth + x) * 4
                for channel in 0..<3 { result += abs(Int(a[index + channel]) - Int(b[index + channel])) }
            }
        } }
        return result
    }

    private func pixels(_ image: CIImage) -> [UInt8] {
        let width = Int(image.extent.width), height = Int(image.extent.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        context.render(image, toBitmap: &bytes, rowBytes: width * 4, bounds: image.extent,
                       format: .RGBA8, colorSpace: colorSpace)
        return bytes
    }

    private func legacyThumbnail(_ source: CGImage) throws -> CGImage {
        let data = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(data, "public.png" as CFString, 1, nil))
        CGImageDestinationAddImage(destination, source, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        let source = try XCTUnwrap(CGImageSourceCreateWithData(data, nil))
        return try XCTUnwrap(CGImageSourceCreateThumbnailAtIndex(source, 0, [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: previewWidth,
            kCGImageSourceShouldCacheImmediately: true,
        ] as CFDictionary))
    }

    private func makeSource() throws -> CGImage {
        var rgba = [UInt8](repeating: 255, count: sourceWidth * sourceHeight * 4)
        let colors = [SIMD3<Double>(4, 10, 8), SIMD3(245, 240, 248), SIMD3(254, 8, 12), SIMD3(4, 245, 252)]
        for y in 0..<sourceHeight { for x in 0..<sourceWidth {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let nx = p.x / Double(sourceWidth), ny = p.y / Double(sourceHeight)
            // Chroma-safe shared luminance detail, with source period 7/9
            // pixels. Full source and fractional thumbnail neighborhoods are
            // active texture; saturated side panels are outside the face.
            let detail = 8 * sin(2 * Double.pi * p.x / 7) + 8 * sin(2 * Double.pi * p.y / 9)
            var rgb = SIMD3<Double>(210 + detail, 174 + detail, 146 + detail)
            if x < 96 || x >= 416 { rgb = colors[(x / 5 + y / 7) % colors.count] }
            for centerX in [0.32, 0.68] {
                if pow((nx - centerX) / 0.09, 2) + pow((ny - 0.4) / 0.07, 2) < 1 {
                    let d = p - SIMD2(centerX * Double(sourceWidth), 0.4 * Double(sourceHeight))
                    let coverage = max(0, min(1, 12.5 - hypot(d.x, d.y)))
                    rgb = SIMD3(200 - 160 * coverage,
                        220 + coverage * (105 + 25 * sin(d.x * 0.7) - 220),
                        220 + coverage * (112 + 22 * cos(d.y * 0.8) - 220))
                }
            }
            let index = (y * sourceWidth + x) * 4
            for channel in 0..<3 { rgba[index + channel] = UInt8(rgb[channel].rounded()) }
        } }
        return try XCTUnwrap(CGImage(width: sourceWidth, height: sourceHeight,
            bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: sourceWidth * 4,
            space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
            provider: CGDataProvider(data: Data(rgba) as CFData)!, decode: nil,
            shouldInterpolate: false, intent: .defaultIntent))
    }

    private func observation() throws -> BeautyFaceObservation {
        func ellipse(_ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, count: Int = 16) -> [CoordinatePoint] {
            (0..<count).map { i in
                let angle = Double(i) * 2 * Double.pi / Double(count)
                return CoordinatePoint(x: cx + rx * cos(angle), y: cy + ry * sin(angle))
            }
        }
        var points = Array(repeating: SIMD3<Float>(0.5, 0.5, 0), count: 478)
        func putEllipse(_ indices: [Int], _ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double) {
            for (index, point) in zip(indices, ellipse(cx, cy, rx, ry, count: indices.count)) {
                points[index] = SIMD3(Float(point.x), Float(point.y), 0)
            }
        }
        // Texture admission requires a genuine simple dense oval and distinct
        // protection paths. The fixed cheek ROI lies below the coarse eye
        // zone (.268... .452), above the lip zone (.628... .82), and inside
        // both the .43 face-bounds ellipse and this oval.
        putEllipse(MediaPipeFaceTopology.oval, 0.5, 0.5, 0.32, 0.4)
        putEllipse(MediaPipeFaceTopology.leftEye, 0.32, 0.4, 0.09, 0.07)
        putEllipse(MediaPipeFaceTopology.rightEye, 0.68, 0.4, 0.09, 0.07)
        putEllipse(MediaPipeFaceTopology.leftBrowEnvelope, 0.32, 0.26, 0.09, 0.02)
        putEllipse(MediaPipeFaceTopology.rightBrowEnvelope, 0.68, 0.26, 0.09, 0.02)
        putEllipse(MediaPipeFaceTopology.outerLip, 0.5, 0.7, 0.10, 0.03)
        putEllipse(MediaPipeFaceTopology.innerLip, 0.5, 0.7, 0.075, 0.008)
        for (indices, centerX) in [(MediaPipeFaceTopology.leftIris, 0.32), (MediaPipeFaceTopology.rightIris, 0.68)] {
            putEllipse(indices, centerX, 0.4, 12 / Double(sourceWidth), 12 / Double(sourceHeight))
        }
        points[468] = SIMD3(0.32, 0.4, 0); points[473] = SIMD3(0.68, 0.4, 0)
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points))
        return BeautyFaceObservation(stableID: "iris-preview-fractional-source", confidence: 1,
            imageBounds: CoordinateRect(x: 0.13, y: 0.1, width: 0.74, height: 0.8),
            observedEyeSupport: [
                BeautyObservedEyeSupport(side: .left, contour: ellipse(0.32, 0.4, 0.09, 0.07),
                    pupil: [CoordinatePoint(x: 0.32, y: 0.4)]),
                BeautyObservedEyeSupport(side: .right, contour: ellipse(0.68, 0.4, 0.09, 0.07),
                    pupil: [CoordinatePoint(x: 0.68, y: 0.4)])
            ], observedEyeOrder: .canonical,
            observedFaceSupport: BeautyObservedFaceSupport(contour: ellipse(0.5, 0.5, 0.32, 0.4),
                medianLine: [CoordinatePoint(x: 0.5, y: 0.25), CoordinatePoint(x: 0.5, y: 0.85)]), mesh: mesh)
    }

    private final class Probe: @unchecked Sendable {
        private let lock = NSLock()
        private let observation: BeautyFaceObservation
        private var count = 0, seenExtents = [CGSize]()
        var calls: Int { lock.withLock { count } }
        var extents: [CGSize] { lock.withLock { seenExtents } }
        init(observation: BeautyFaceObservation) { self.observation = observation }
        func detector() -> BeautyFaceDetector {
            BeautyFaceDetector(mappedObservationProvider: { [self] input in
                lock.withLock {
                    count += 1; seenExtents.append(input.imageExtent)
                    return BeautyMappedFaceObservations(observations: [observation])
                }
            })
        }
    }
}

extension BeautyEngineIrisPreviewFractionalProtectionTests {
    func testUnchangedFarWhiteFootprintsKeepViewBaselineInsideHardIrisOwner() throws {
        let source = try farWhiteSource(), observed = try observation()
        var sibling = BeautyParameters()
        sibling.contrast = 0.7; sibling.brightness = 0.3
        var combined = sibling; combined.pupilSize = 0.25 * 0.25
        let originalProbe = Probe(observation: observed)
        let original = try BeautyEngine(faceDetector: originalProbe.detector())
        let originalPrepared = try original.prepareStillImage(image: source)
        let originalP0 = try original.processResult(preparedImage: originalPrepared, parameters: sibling)
        let originalIR = try original.processResult(preparedImage: originalPrepared, parameters: combined)
        let fullP0 = pixels(originalP0.output), fullIR = pixels(originalIR.output)
        for centerX in [0.32, 0.68] {
            var irisChange = 0
            for y in 0..<sourceHeight { for x in 0..<sourceWidth {
                let d = SIMD2(Double(x) + 0.5 - centerX * Double(sourceWidth),
                              Double(y) + 0.5 - 0.4 * Double(sourceHeight))
                if hypot(d.x, d.y) < 16 {
                    let index = (y * sourceWidth + x) * 4
                    for channel in 0..<3 { irisChange += abs(Int(fullIR[index + channel]) - Int(fullP0[index + channel])) }
                }
            } }
            XCTAssertGreaterThan(irisChange, 0, "both original circles must actually complete an iris edit")
        }
        let resizedOriginalP0 = try independentlyResized(originalP0.output)
        let resizedOriginalIR = try independentlyResized(originalIR.output)
        let legacy = try BeautyEngine(faceDetector: Probe(observation: observed).detector())
        let legacyPrepared = try legacy.prepareStillImage(image: legacyThumbnail(source))
        let legacyResult = try legacy.processResult(preparedImage: legacyPrepared, parameters: sibling)
        let viewBaseline = pixels(legacyResult.output)

        // Frozen before candidate rendering: two lateral observed-eye bands,
        // R0=12 and +quarter s=100/94.75. All 16 pixel centres are outside
        // material union + source AA/bilinear halo + C1 fade by >=5.73 source
        // pixels, yet inside the independent hard owner/window. Equality of
        // the complete independently resized original IR pair below further
        // certifies that ImageIO's actual sampling footprint is unchanged.
        let scale = 100.0 / 94.75, radius = 12.0
        let materialOuter = scale * radius + 1.3 * (sqrt(0.5) + sqrt(2.0)) + 1
        var probes = [Int]()
        for y in 0..<previewHeight { for x in 0..<previewWidth {
            let p = SIMD2((Double(x) + 0.5) * Double(sourceWidth) / Double(previewWidth),
                          (Double(y) + 0.5) * Double(sourceHeight) / Double(previewHeight))
            for centerX in [0.32, 0.68] {
                let center = SIMD2(centerX * Double(sourceWidth), 0.4 * Double(sourceHeight))
                let d = p - center, r = hypot(d.x, d.y)
                guard (22.0...22.75).contains(r), abs(d.y) <= 8 else { continue }
                let contour = (0..<16).map { i -> SIMD2<Double> in
                    let angle = Double(i) * 2 * Double.pi / 16
                    return center + SIMD2(0.09 * Double(sourceWidth) * cos(angle),
                                          0.07 * Double(sourceHeight) * sin(angle))
                }
                XCTAssertGreaterThan(farWhiteSignedDistance(p, polygon: contour), 1)
                XCTAssertGreaterThan((scale + 1) * radius - r - sqrt(2.0), 0)
                XCTAssertGreaterThan(r - materialOuter, 5.7)
                for corner in [center - SIMD2(0.09 * Double(sourceWidth), 0),
                               center + SIMD2(0.09 * Double(sourceWidth), 0)] {
                    let v = p - corner
                    XCTAssertGreaterThan(hypot(v.x, v.y) - 0.08 * 0.18 * Double(sourceWidth), 0)
                }
                probes.append((y * previewWidth + x) * 4)
            }
        } }
        XCTAssertEqual(probes.count, 16, "the source-defined band must remain fixed")
        let footprintDelta = probes.reduce(0) { sum, index in
            sum + (0..<4).reduce(0) { $0 + abs(Int(resizedOriginalIR[index + $1]) - Int(resizedOriginalP0[index + $1])) }
        }
        XCTAssertEqual(footprintDelta, 0,
            "the complete original IR versus original p0 ImageIO footprint must be source-exact before judging the preview")
        let changedBaselineCount = probes.filter { index in
            (0..<4).contains { resizedOriginalP0[index + $0] != viewBaseline[index + $0] }
        }.count
        XCTAssertGreaterThan(changedBaselineCount, 0,
            "the fixed far-white source must expose original-prefix versus view-prefix order, independent of candidate output")

        let previewProbe = Probe(observation: observed)
        let preview = try BeautyEngine(faceDetector: previewProbe.detector())
        let prepared = try preview.prepareStillImage(image: source)
        let result = try preview.processIrisPreviewResult(preparedImage: prepared,
            maximumPreviewEdge: previewWidth, parameters: combined)
        let actual = pixels(result.output)
        let leakDelta = probes.reduce(0) { sum, index in
            sum + (0..<4).reduce(0) { $0 + abs(Int(actual[index + $1]) - Int(viewBaseline[index + $1])) }
        }
        XCTAssertEqual(leakDelta, 0,
            "unchanged original IR footprints must preserve legacy view baseline inside the hard owner; fullRGBA delta=\(leakDelta)")
        XCTAssertGreaterThan(result.metrics["beauty.irisPreview.completedEyeCount"] ?? 0, 0)
        XCTAssertEqual(previewProbe.extents, [CGSize(width: sourceWidth, height: sourceHeight)])
    }

    private func independentlyResized(_ image: CIImage) throws -> [UInt8] {
        let full = try XCTUnwrap(context.createCGImage(image, from: image.extent, format: .RGBA8, colorSpace: colorSpace))
        return pixels(CIImage(cgImage: try legacyThumbnail(full)))
    }

    private func farWhiteSource() throws -> CGImage {
        // Preserve the independently generated circle and all of its source
        // AA. Only known observed opening pixels well beyond that circle get
        // this source-fixed white texture; this is not a color admission mask.
        var rgba = pixels(CIImage(cgImage: try makeSource()))
        for y in 0..<sourceHeight { for x in 0..<sourceWidth {
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            for centerX in [0.32, 0.68] {
                let dx = p.x - centerX * Double(sourceWidth), dy = p.y - 0.4 * Double(sourceHeight)
                guard hypot(dx, dy) >= 18,
                      pow(dx / (0.09 * Double(sourceWidth)), 2) + pow(dy / (0.07 * Double(sourceHeight)), 2) < 0.8
                else { continue }
                let detail = (x / 3 + y / 4) % 2 == 0 ? -18 : 18
                let index = (y * sourceWidth + x) * 4
                rgba[index] = UInt8(211 + detail)
                rgba[index + 1] = UInt8(224 + detail)
                rgba[index + 2] = UInt8(230 + detail)
            }
        } }
        let source = CIImage(bitmapData: Data(rgba), bytesPerRow: sourceWidth * 4,
            size: CGSize(width: sourceWidth, height: sourceHeight), format: .RGBA8, colorSpace: colorSpace)
        return try XCTUnwrap(context.createCGImage(source, from: source.extent, format: .RGBA8, colorSpace: colorSpace))
    }

    private func farWhiteSignedDistance(_ p: SIMD2<Double>, polygon: [SIMD2<Double>]) -> Double {
        var distance = Double.infinity, inside = false
        for i in polygon.indices {
            let a = polygon[i], b = polygon[(i + 1) % polygon.count]
            let e = b - a, v = p - a
            let t = max(0, min(1, (v.x * e.x + v.y * e.y) / (e.x * e.x + e.y * e.y)))
            let q = v - e * t; distance = min(distance, hypot(q.x, q.y))
            if (a.y > p.y) != (b.y > p.y), p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x {
                inside.toggle()
            }
        }
        return inside ? distance : -distance
    }
}
