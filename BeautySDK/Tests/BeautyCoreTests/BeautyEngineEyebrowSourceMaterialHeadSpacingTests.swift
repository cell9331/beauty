import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautySDK

/// Prospective source-material regression, separate from the frozen Phase 92
/// dark-block oracle. The source, observed traces, head windows and all gates
/// below are declared before rendering. Passing this class does not change the
/// qualification or historical outcome of the frozen dark-block fixture.
final class BeautyEngineEyebrowSourceMaterialHeadSpacingTests: XCTestCase {
    private let leftHead = Region(minX: 400_000, maxX: 500_000, minY: 240_000, maxY: 430_000)
    private let rightHead = Region(minX: 500_000, maxX: 600_000, minY: 240_000, maxY: 430_000)
    private let leftOuter = Region(minX: 240_000, maxX: 400_000, minY: 240_000, maxY: 430_000)
    private let rightOuter = Region(minX: 600_000, maxX: 760_000, minY: 240_000, maxY: 430_000)
    private let eyes = Region(minX: 250_000, maxX: 750_000, minY: 430_000, maxY: 500_000)
    private let backgrounds = [
        Region(minX: 0, maxX: 140_000, minY: 80_000, maxY: 820_000),
        Region(minX: 860_000, maxX: 1_000_000, minY: 80_000, maxY: 820_000),
    ]
    private let watermark = Region(minX: 820_000, maxX: 980_000, minY: 920_000, maxY: 985_000)
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    func testPairedSignedHeadMaterialRetainsOriginalSignalDirectionSiblingAndProtectionGates() throws {
        let fixture = Fixture()
        let source = fixture.source()
        let image = fixture.image(source)
        let provider = SequenceProvider([[fixture.observation()]])
        let engine = try BeautyEngine(faceDetector: provider.detector())
        let neutral = try process(engine, image: image, fixture: fixture, parameters: .init())
        XCTAssertTrue(neutral.bytes == source, "neutral retains source RGBA")
        XCTAssertEqual(provider.calls, 0)
        XCTAssertEqual(neutral.result.detectionSummary?.availability, .notRun)

        let plus = try process(engine, image: image, fixture: fixture, parameters: .init(eyebrowHeadSpacing: 0.25))
        let repeated = try process(engine, image: image, fixture: fixture, parameters: .init(eyebrowHeadSpacing: 0.25))
        let minus = try process(engine, image: image, fixture: fixture, parameters: .init(eyebrowHeadSpacing: -0.25))
        let wholePlus = try process(engine, image: image, fixture: fixture, parameters: .init(eyebrowSpacing: 0.25))
        let wholeMinus = try process(engine, image: image, fixture: fixture, parameters: .init(eyebrowSpacing: -0.25))
        XCTAssertEqual(provider.calls, 5)
        XCTAssertTrue(plus.bytes == repeated.bytes, "repeat retains identical RGBA")
        XCTAssertEqual(plus.result.metrics, repeated.result.metrics)
        XCTAssertEqual(plus.result.warnings, repeated.result.warnings)
        XCTAssertEqual(plus.result.detectionSummary, repeated.result.detectionSummary)

        for rendered in [plus, minus, wholePlus, wholeMinus] {
            assertCanonical(rendered, image: image, source: source)
            assertUsableMetadata(rendered.result)
            XCTAssertFalse(rendered.bytes == source, "signed material request must render")
        }

        let sourceGap = headGapQ16(source, fixture: fixture)
        let neutralGap = headGapQ16(neutral.bytes, fixture: fixture)
        XCTAssertEqual(neutralGap, sourceGap)
        var signalAggregates: [Signal] = []
        for (name, candidate) in [("positive head", plus.bytes), ("negative head", minus.bytes)] {
            for baseline in [source, neutral.bytes] {
                let value = signal(baseline, candidate, fixture: fixture, regions: [leftHead, rightHead])
                // Unchanged Phase 92 signal thresholds and >2-channel delta definition.
                XCTAssertGreaterThanOrEqual(value.changed, 500, name)
                XCTAssertGreaterThanOrEqual(value.rgb, 2_000, name)
                assertProtection(baseline, candidate, fixture: fixture, name: name)
                signalAggregates.append(value)
            }
        }
        let plusGap = headGapQ16(plus.bytes, fixture: fixture)
        let minusGap = headGapQ16(minus.bytes, fixture: fixture)
        for baseline in [sourceGap, neutralGap] {
            XCTAssertGreaterThanOrEqual(plusGap - baseline, 16)
            XCTAssertLessThanOrEqual(minusGap - baseline, -16)
        }
        XCTAssertGreaterThanOrEqual(abs(plusGap - minusGap), 16)
        let siblingGaps = [headGapQ16(wholePlus.bytes, fixture: fixture), headGapQ16(wholeMinus.bytes, fixture: fixture)]
        for head in [plusGap, minusGap] {
            for whole in siblingGaps { XCTAssertGreaterThanOrEqual(abs(head - whole), 16) }
        }
        let reset = try process(engine, image: image, fixture: fixture, parameters: .init())
        XCTAssertTrue(reset.bytes == source, "neutral after active requests retains source")
        XCTAssertEqual(provider.calls, 5)
        // Anonymous aggregate values only; no source bytes or observed points.
        print("BROW_MATERIAL_HEAD_SIGNAL positive_changed=\(signalAggregates[0].changed) negative_changed=\(signalAggregates[2].changed) positive_rgb=\(signalAggregates[0].rgb) negative_rgb=\(signalAggregates[2].rgb) positive_q16=\(plusGap - sourceGap) negative_q16=\(minusGap - sourceGap)")
    }

    func testEachSignedUnilateralHeadRequestKeepsItsRejectedPeerExact() throws {
        let fixture = Fixture()
        let source = fixture.source()
        let image = fixture.image(source)
        for support in [Fixture.Support.leftOnly, .rightOnly] {
            let provider = SequenceProvider([[fixture.observation(support)]])
            let engine = try BeautyEngine(faceDetector: provider.detector())
            for amount: Float in [-0.25, 0.25] {
                let rendered = try process(engine, image: image, fixture: fixture,
                    parameters: .init(eyebrowHeadSpacing: amount))
                let own = support == .leftOnly ? leftHead : rightHead
                let peer = support == .leftOnly ? rightHead : leftHead
                XCTAssertGreaterThan(signal(source, rendered.bytes, fixture: fixture, regions: [own]).changed, 0)
                assertSignal(source, rendered.bytes, fixture: fixture, regions: [peer],
                    maxChanged: 0, maxRGB: 0, name: "unilateral rejected peer")
                assertProtection(source, rendered.bytes, fixture: fixture, name: "unilateral head")
                assertCanonical(rendered, image: image, source: source)
                assertUsableMetadata(rendered.result)
                // Whole spacing must not turn the remaining valid side into a pair.
                let sibling = try process(engine, image: image, fixture: fixture,
                    parameters: .init(eyebrowSpacing: amount))
                XCTAssertTrue(sibling.bytes == source)
                XCTAssertEqual(sibling.result.metrics["beauty.effects.activeCount"], 0)
                assertRedacted(sibling.result)
            }
            XCTAssertEqual(provider.calls, 4)
        }
    }

    func testMissingMalformedNoFaceAndValidInvalidValidKeepRequestLocalSourceSafety() throws {
        let fixture = Fixture()
        let source = fixture.source()
        let image = fixture.image(source)
        for support in [Fixture.Support.missing, .malformed, .noFace] {
            let observations = support == .noFace ? [] : [fixture.observation(support)]
            let provider = SequenceProvider([observations])
            let engine = try BeautyEngine(faceDetector: provider.detector())
            for amount: Float in [-0.25, 0.25] {
                let rejected = try process(engine, image: image, fixture: fixture,
                    parameters: .init(eyebrowHeadSpacing: amount))
                XCTAssertTrue(rejected.bytes == source)
                XCTAssertEqual(rejected.result.metrics["beauty.effects.activeCount"], 0)
                assertRedacted(rejected.result)
            }
            XCTAssertEqual(provider.calls, 2)
        }
        let provider = SequenceProvider([[fixture.observation()], [fixture.observation(.malformed)], [fixture.observation()]])
        let engine = try BeautyEngine(faceDetector: provider.detector())
        let parameters = BeautyParameters(eyebrowHeadSpacing: 0.25)
        let first = try process(engine, image: image, fixture: fixture, parameters: parameters)
        let rejected = try process(engine, image: image, fixture: fixture, parameters: parameters)
        let recovered = try process(engine, image: image, fixture: fixture, parameters: parameters)
        XCTAssertFalse(first.bytes == source)
        XCTAssertTrue(rejected.bytes == source)
        XCTAssertTrue(first.bytes == recovered.bytes)
        XCTAssertEqual(first.result.metrics, recovered.result.metrics)
        XCTAssertEqual(first.result.warnings, recovered.result.warnings)
        XCTAssertEqual(first.result.detectionSummary, recovered.result.detectionSummary)
        XCTAssertEqual(provider.calls, 3)
        for rendered in [first, recovered] {
            assertUsableMetadata(rendered.result)
            assertCanonical(rendered, image: image, source: source)
            assertProtection(source, rendered.bytes, fixture: fixture, name: "recovered head")
        }
        assertRedacted(rejected.result)
    }

    func testHistoricalThickBlocksAreSourceExactRejectedMaterialInThisProspectiveClass() throws {
        let fixture = Fixture()
        // Exact historical block membership and RGB source formula are copied
        // as a counterexample, never substituted into the new positive fixture.
        // The frozen original positive test remains unchanged and independently
        // reports its own historical contract; this negative cannot relabel it.
        let source = fixture.source(historicalBlocks: true)
        let image = fixture.image(source)
        let provider = SequenceProvider([[fixture.observation()]])
        let engine = try BeautyEngine(faceDetector: provider.detector())
        for amount: Float in [-0.25, 0.25] {
            let rendered = try process(engine, image: image, fixture: fixture,
                parameters: .init(eyebrowHeadSpacing: amount))
            XCTAssertTrue(rendered.bytes == source, "unsupported broad blocks must not synthesize brow material")
            XCTAssertEqual(rendered.result.detectionSummary?.availability, .usable)
            XCTAssertEqual(rendered.result.detectionSummary?.faceCount, 1)
            assertCanonical(rendered, image: image, source: source)
        }
        XCTAssertEqual(provider.calls, 2)
    }

    private func process(_ engine: BeautyEngine, image: CIImage, fixture: Fixture,
                         parameters: BeautyParameters) throws -> Rendered {
        // Active brow work uses the canonical opaque carrier for its sRGB tag.
        // Neutral omits the mask so source passthrough performs no detection.
        let normalized = parameters.normalized()
        let hasBrowWork = [normalized.eyebrowYPosition, normalized.eyebrowThickness,
            normalized.eyebrowLength, normalized.eyebrowSpacing, normalized.eyebrowHeadSpacing,
            normalized.eyebrowTilt, normalized.eyebrowPeakDefinition].contains { $0 != 0 }
        let mask = hasBrowWork ? try BeautyTextureExclusionMask(width: fixture.width, height: fixture.height,
            bytes: [UInt8](repeating: 0, count: fixture.width * fixture.height)) : nil
        let result = try engine.processResult(image: image, metadata: metadata, parameters: parameters,
            textureExclusionMask: mask)
        return Rendered(result: result, bytes: fixture.bytes(result.output))
    }

    private func assertCanonical(_ rendered: Rendered, image: CIImage, source: [UInt8],
                                 file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(rendered.result.output.extent, image.extent, file: file, line: line)
        XCTAssertEqual(image.colorSpace?.name, CGColorSpace.sRGB, file: file, line: line)
        XCTAssertEqual(rendered.result.output.colorSpace?.name, CGColorSpace.sRGB, file: file, line: line)
        XCTAssertEqual(rendered.bytes.count, source.count, file: file, line: line)
        XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy {
            rendered.bytes[$0] == source[$0]
        }, "all source alpha stays exact", file: file, line: line)
        assertRedacted(rendered.result, file: file, line: line)
    }

    private func assertUsableMetadata(_ result: BeautyResult<CIImage>,
                                      file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(result.detectionSummary?.availability, .usable, file: file, line: line)
        XCTAssertEqual(result.detectionSummary?.reasons, [], file: file, line: line)
        XCTAssertEqual(result.detectionSummary?.faceCount, 1, file: file, line: line)
        XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.detection.faceCount"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 1, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.effects.cappedCount"], 0, file: file, line: line)
        XCTAssertEqual(result.metrics["beauty.effects.continuousEyebrowFields"], 1, file: file, line: line)
        XCTAssertNil(result.metrics["beauty.effects.geometryPointCount"], file: file, line: line)
        XCTAssertFalse(result.warnings.contains { $0.code == "eyebrow_inputs_missing" }, file: file, line: line)
    }

    private func assertProtection(_ baseline: [UInt8], _ candidate: [UInt8], fixture: Fixture,
                                  name: String, file: StaticString = #filePath, line: UInt = #line) {
        let outside = signal(baseline, candidate, fixture: fixture) { x, y in
            !self.leftHead.contains(x, y, fixture: fixture) && !self.rightHead.contains(x, y, fixture: fixture)
        }
        // All ceilings and windows are the original head-spacing gates.
        XCTAssertLessThanOrEqual(outside.changed, 128, name, file: file, line: line)
        XCTAssertLessThanOrEqual(outside.rgb, 512, name, file: file, line: line)
        for (label, region) in [("left outer", leftOuter), ("right outer", rightOuter), ("eyes", eyes)] {
            assertSignal(baseline, candidate, fixture: fixture, regions: [region], maxChanged: 64,
                maxRGB: 256, name: name + " " + label, file: file, line: line)
        }
        assertSignal(baseline, candidate, fixture: fixture, regions: backgrounds, maxChanged: 0,
            maxRGB: 0, name: name + " backgrounds", file: file, line: line)
        assertSignal(baseline, candidate, fixture: fixture, regions: [watermark], maxChanged: 0,
            maxRGB: 0, name: name + " watermark", file: file, line: line)
    }

    private func assertSignal(_ baseline: [UInt8], _ candidate: [UInt8], fixture: Fixture,
                              regions: [Region], maxChanged: Int, maxRGB: Int, name: String,
                              file: StaticString = #filePath, line: UInt = #line) {
        let value = signal(baseline, candidate, fixture: fixture, regions: regions)
        XCTAssertLessThanOrEqual(value.changed, maxChanged, name, file: file, line: line)
        XCTAssertLessThanOrEqual(value.rgb, maxRGB, name, file: file, line: line)
    }

    private func signal(_ baseline: [UInt8], _ candidate: [UInt8], fixture: Fixture,
                        regions: [Region]) -> Signal {
        signal(baseline, candidate, fixture: fixture) { x, y in
            regions.contains { $0.contains(x, y, fixture: fixture) }
        }
    }

    private func signal(_ baseline: [UInt8], _ candidate: [UInt8], fixture: Fixture,
                        include: (Int, Int) -> Bool) -> Signal {
        var result = Signal()
        for y in 0..<fixture.height {
            for x in 0..<fixture.width where include(x, y) {
                let i = (y * fixture.width + x) * 4
                let red = abs(Int(baseline[i]) - Int(candidate[i]))
                let green = abs(Int(baseline[i + 1]) - Int(candidate[i + 1]))
                let blue = abs(Int(baseline[i + 2]) - Int(candidate[i + 2]))
                if max(red, green, blue) > 2 { result.changed += 1 }
                result.rgb += red + green + blue
            }
        }
        return result
    }

    private func headGapQ16(_ bytes: [UInt8], fixture: Fixture) -> Int64 {
        centroidXQ16(bytes, fixture: fixture, region: rightHead)
            - centroidXQ16(bytes, fixture: fixture, region: leftHead)
    }

    private func centroidXQ16(_ bytes: [UInt8], fixture: Fixture, region: Region,
                              file: StaticString = #filePath, line: UInt = #line) -> Int64 {
        // Identical integer darkness-centroid definition to the frozen oracle.
        var mass: Int64 = 0, moment: Int64 = 0
        for y in 0..<fixture.height {
            for x in 0..<fixture.width where region.contains(x, y, fixture: fixture) {
                let i = (y * fixture.width + x) * 4
                let lumaQ8 = Int64(bytes[i]) * 77 + Int64(bytes[i + 1]) * 150 + Int64(bytes[i + 2]) * 29
                let darkness = max(0, Int64(255 * 256) - lumaQ8)
                mass += darkness
                moment += darkness * Int64(x * 2 + 1)
            }
        }
        XCTAssertGreaterThan(mass, 0, file: file, line: line)
        guard mass > 0 else { return 0 }
        return moment * 65_536 / (mass * Int64(fixture.width * 2))
    }

    private func assertRedacted(_ result: BeautyResult<CIImage>,
                                file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(result.metrics.values.allSatisfy(\.isFinite), file: file, line: line)
        let text = (result.warnings.map { $0.code + " " + $0.message } + Array(result.metrics.keys)
            + (result.detectionSummary?.reasons.map(\.rawValue) ?? [])).joined(separator: " ").lowercased()
        for term in ["landmark", "coordinate", "controlpoint", "control point", "simd", "mask", "raw",
                     "pixel", "image bytes", "transcript", "path", "/private/", "file://"] {
            XCTAssertFalse(text.contains(term), "unexpected durable detail", file: file, line: line)
        }
    }

    private struct Rendered {
        let result: BeautyResult<CIImage>
        let bytes: [UInt8]
    }
    private struct Signal { var changed = 0, rgb = 0 }

    private struct Region {
        let minX: Int, maxX: Int, minY: Int, maxY: Int
        func contains(_ x: Int, _ y: Int, fixture: Fixture) -> Bool {
            let xx = x * 1_000_000 / fixture.width, yy = y * 1_000_000 / fixture.height
            return minX <= xx && xx < maxX && minY <= yy && yy < maxY
        }
    }

    private final class SequenceProvider: @unchecked Sendable {
        private let lock = NSLock()
        private let observations: [[BeautyFaceObservation]]
        private var count = 0
        var calls: Int { lock.lock(); defer { lock.unlock() }; return count }
        init(_ observations: [[BeautyFaceObservation]]) { self.observations = observations }
        func detector() -> BeautyFaceDetector {
            BeautyFaceDetector(mappedObservationProvider: { [self] _ in
                lock.lock(); defer { lock.unlock() }
                let selected = observations[min(count, observations.count - 1)]
                count += 1
                return BeautyMappedFaceObservations(observations: selected)
            })
        }
    }

    private struct Fixture: Sendable {
        let width = 512, height = 512
        // Source-defined 6.8px hair tube, with original head centers at columns
        // 253/259 and a narrow empty peer gap. No rendered output chooses this
        // material thickness, geometry, support or target/protection window.
        let halfThickness = 3.4
        enum Support { case paired, leftOnly, rightOnly, missing, malformed, noFace }

        func trace(_ side: Int) -> [SIMD2<Double>] {
            let head = side == 0 ? 253.5 : 259.5
            let tail = (side == 0 ? 0.388 : 0.612) * Double(width)
            return zip([0.0, 0.25, 0.50, 0.75, 1.0], [0.38, 0.362, 0.344, 0.362, 0.38]).map {
                SIMD2(head + (tail - head) * $0.0, Double(height) * $0.1)
            }
        }

        func observation(_ support: Support = .paired) -> BeautyFaceObservation {
            func normalized(_ points: [SIMD2<Double>]) -> [CoordinatePoint] {
                points.map { CoordinatePoint(x: $0.x / Double(width), y: $0.y / Double(height)) }
            }
            func ellipse(_ x: Double, _ y: Double, _ rx: Double, _ ry: Double) -> [CoordinatePoint] {
                (0..<16).map {
                    let a = Double($0) * .pi * 2 / 16
                    return CoordinatePoint(x: x + rx * cos(a), y: y + ry * sin(a))
                }
            }
            let brows: BeautyObservedEyebrowSupport?
            switch support {
            case .missing, .noFace: brows = nil
            case .malformed:
                let repeated = Array(repeating: CoordinatePoint(x: 0.4, y: 0.35), count: 5)
                brows = BeautyObservedEyebrowSupport(left: repeated, right: repeated)
            default:
                brows = BeautyObservedEyebrowSupport(left: support == .rightOnly ? nil : normalized(trace(0)),
                    right: support == .leftOnly ? nil : normalized(trace(1)))
            }
            return BeautyFaceObservation(confidence: 1,
                imageBounds: CoordinateRect(x: 0.16, y: 0.16, width: 0.68, height: 0.68),
                observedEyeSupport: [
                    BeautyObservedEyeSupport(side: .left, contour: ellipse(0.395, 0.465, 0.065, 0.015)),
                    BeautyObservedEyeSupport(side: .right, contour: ellipse(0.605, 0.465, 0.065, 0.015))
                ], observedEyeOrder: .canonical, observedEyebrowSupport: brows,
                observedLipSupport: BeautyObservedLipSupport(outer: ellipse(0.5, 0.71, 0.095, 0.027)),
                observedNoseSupport: BeautyObservedNoseSupport(
                    crest: [CoordinatePoint(x: 0.5, y: 0.54), CoordinatePoint(x: 0.5, y: 0.60)],
                    contour: ellipse(0.5, 0.60, 0.04, 0.035)))
        }

        func source(historicalBlocks: Bool = false) -> [UInt8] {
            var bytes = [UInt8](repeating: 255, count: width * height * 4)
            let paths = [trace(0), trace(1)]
            for y in 0..<height { for x in 0..<width {
                let xx = x * 1_000_000 / width, yy = y * 1_000_000 / height
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                let isBrow: Bool
                if historicalBlocks {
                    isBrow = yy >= 270_000 && yy < 410_000
                        && ((xx >= 270_000 && xx < 495_000) || (xx >= 505_000 && xx < 730_000))
                } else {
                    // Clip only the inner end caps at the declared head plane;
                    // this keeps material ownership separate across the peer gap.
                    isBrow = (p.x <= paths[0][0].x && distance(p, to: paths[0]) <= halfThickness)
                        || (p.x >= paths[1][0].x && distance(p, to: paths[1]) <= halfThickness)
                }
                let isEye = yy >= 450_000 && yy < 480_000
                    && ((xx >= 330_000 && xx < 460_000) || (xx >= 540_000 && xx < 670_000))
                let isBackground = yy >= 100_000 && yy < 180_000 && (xx < 120_000 || xx >= 880_000)
                let isWatermark = xx >= 850_000 && xx < 950_000 && yy >= 940_000 && yy < 970_000
                let i = (y * width + x) * 4
                if isBrow {
                    let t = UInt8((x * 31 + y * 17) % 61)
                    bytes[i] = 35 + t; bytes[i + 1] = 45 + t; bytes[i + 2] = 55 + t
                } else if isEye {
                    let t = UInt8((x * 13 + y * 23) % 37)
                    bytes[i] = 85 + t; bytes[i + 1] = 105 + t; bytes[i + 2] = 125 + t
                } else if isBackground {
                    bytes[i] = 205; bytes[i + 1] = 220; bytes[i + 2] = 235
                } else if isWatermark {
                    bytes[i] = 180; bytes[i + 1] = 190; bytes[i + 2] = 200
                }
            } }
            return bytes
        }

        private func distance(_ p: SIMD2<Double>, to path: [SIMD2<Double>]) -> Double {
            zip(path, path.dropFirst()).map { a, b in
                let v = b - a, d = p - a
                let t = min(1, max(0, (d.x * v.x + d.y * v.y) / (v.x * v.x + v.y * v.y)))
                let offset = d - v * t
                return hypot(offset.x, offset.y)
            }.min()!
        }

        func image(_ bytes: [UInt8]) -> CIImage {
            CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
                size: CGSize(width: width, height: height), format: .RGBA8,
                colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
        }

        func bytes(_ image: CIImage) -> [UInt8] {
            let color = CGColorSpace(name: CGColorSpace.sRGB)!
            let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
            var result = [UInt8](repeating: 0, count: width * height * 4)
            result.withUnsafeMutableBytes {
                context.render(image, toBitmap: $0.baseAddress!, rowBytes: width * 4,
                    bounds: image.extent, format: .RGBA8, colorSpace: color)
            }
            return result
        }
    }
}
