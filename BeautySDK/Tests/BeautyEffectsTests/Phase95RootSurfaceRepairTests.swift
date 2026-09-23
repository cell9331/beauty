import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyEffects

/// Actual generated pixels validate the repaired inner dorsal material span.
/// The marker positions, measurement rows and protection boxes are independent
/// of the provider's emitted control points; no portrait pixels are involved.
final class Phase95RootSurfaceRepairTests: XCTestCase {
    private func face(rootSplit: Double = 0.35) -> FaceGeometry {
        let shift = rootSplit - 0.35
        let crest = [0.30, 0.35, 0.40, 0.45, 0.50].map { CoordinatePoint(x: 0.50, y: $0 + shift) }
        let contour = [CoordinatePoint(x: 0.44, y: 0.51), .init(x: 0.46, y: 0.55),
                       .init(x: 0.50, y: 0.56), .init(x: 0.54, y: 0.55), .init(x: 0.56, y: 0.51)]
        let base = BeautyFaceGeometryAdapter.makeGeometry(from: BeautyFaceObservation(
            imageBounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
            landmarks: .complete, observedNoseSupport: .init(crest: crest, contour: contour)))
        func eye(_ side: BeautyObservedEyeSide, _ x: Float) -> BeautyEyeSemanticSupport {
            let trace: [SIMD2<Float>] = [.init(x - 0.04, 0.28), .init(x, 0.26),
                                       .init(x + 0.04, 0.28), .init(x, 0.30)]
            return .init(side: side, contour: trace, upper: Array(trace.prefix(3)),
                lower: [trace[0], trace[3], trace[2]], inner: [side == .left ? trace[2] : trace[0]],
                outer: [side == .left ? trace[0] : trace[2]], corners: [trace[0], trace[2]],
                center: .init(x, 0.28), pupil: nil, span: .init(0.08, 0.04), tilt: 0)
        }
        return FaceGeometry(bounds: base.bounds, faceContour: base.faceContour, nose: base.nose,
            leftEyeSupport: eye(.left, 0.38), rightEyeSupport: eye(.right, 0.62),
            observedNoseSupport: base.observedNoseSupport)
    }

    private func pixels(size: Int, phase: Double) -> [UInt8] {
        var result = [UInt8](repeating: 255, count: size * size * 4)
        let left = 0.476 * Double(size) + phase
        let right = 0.524 * Double(size) + phase
        for y in 0..<size { for x in 0..<size {
            // Integrate a fixed, vertical red step over each source pixel. The
            // fractional coverage changes its subpixel phase without changing
            // the independently chosen physical marker separation.
            let coverage = max(0, min(Double(x + 1), right) - max(Double(x), left))
            let index = (y * size + x) * 4
            result[index] = UInt8((220 - 180 * coverage).rounded())
            for channel in 1..<3 {
                let a = UInt64(x + y + 17 * channel) &* 1_103_515_245 &+ 12_345
                let b = UInt64(x * x + y * 7_919 + channel * 107) &* 2_654_435_761
                result[index + channel] = UInt8(40 + (a ^ b) % 176)
            }
        } }
        return result
    }

    private func span(_ pixels: [UInt8], size: Int, row: Int) throws -> Double {
        var entering: [Double] = [], leaving: [Double] = []
        let half = 130.0 // Halfway between the independent 40/220 source levels.
        for x in 0..<size - 1 {
            let a = Double(pixels[(row * size + x) * 4])
            let b = Double(pixels[(row * size + x + 1) * 4])
            if a > half && b <= half {
                entering.append(Double(x) + (half - a) / (b - a))
            }
            if a <= half && b > half {
                leaving.append(Double(x) + (half - a) / (b - a))
            }
        }
        XCTAssertEqual(entering.count, 1, "The generated surface must have one left material marker")
        XCTAssertEqual(leaving.count, 1, "The generated surface must have one right material marker")
        let left = try XCTUnwrap(entering.first), right = try XCTUnwrap(leaving.first)
        XCTAssertGreaterThan(right, left)
        return right - left
    }

    private func assertProtectedPixels(_ source: [UInt8], _ output: [UInt8], size: Int,
                                       context: String) {
        // Precomputed original registration for the observed fixture: noseX .5,
        // face width .8, eye top .26, crest split (.30 + .40) / 2 = .35.
        // Floor at the seam deliberately includes the first bridge pixel row.
        let minX = Int(floor(0.388 * Double(size))), maxX = Int(ceil(0.612 * Double(size)))
        let minY = Int(floor(0.232 * Double(size))), maxY = Int(ceil(0.350 * Double(size)))
        let bridgeMinY = Int(floor(0.350 * Double(size))), bridgeMaxY = Int(ceil(0.500 * Double(size)))
        var bridgeChanged = 0, bridgeDelta = 0, outsideChanged = 0, outsideDelta = 0
        var nonopaque = 0
        for y in 0..<size { for x in 0..<size {
            let index = (y * size + x) * 4
            let delta = (0..<3).map { abs(Int(source[index + $0]) - Int(output[index + $0])) }
            let changed = delta.max()! > 2 ? 1 : 0
            let sum = delta.reduce(0, +)
            if y >= bridgeMinY && y < bridgeMaxY && x >= minX && x < maxX {
                bridgeChanged += changed; bridgeDelta += sum
            }
            if x < minX || x >= maxX || y < minY || y >= maxY {
                outsideChanged += changed; outsideDelta += sum
            }
            if output[index + 3] != 255 { nonopaque += 1 }
        } }
        XCTAssertLessThanOrEqual(bridgeChanged, 64, "Bridge seam changed pixels: \(context)")
        XCTAssertLessThanOrEqual(bridgeDelta, 256, "Bridge seam RGB delta: \(context)")
        XCTAssertLessThanOrEqual(outsideChanged, 128, "Outside-root changed pixels: \(context)")
        XCTAssertLessThanOrEqual(outsideDelta, 512, "Outside-root RGB delta: \(context)")
        XCTAssertEqual(nonopaque, 0, "Opaque alpha: \(context)")
    }

    func testCanonicalPixelsNarrowInnerRootAtBothRowsAndPreserveBridgeSeam() throws {
        let color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
        let geometry = face()
        for size in [512, 1024] {
            let rows = [0.278, 0.325].map { Int(floor($0 * Double(size))) }
            for phase in [-0.25, 0.25] {
                let source = pixels(size: size, phase: phase)
                let canonical = try BeautyCanonicalStillImage(rgba8Data: Data(source), width: size,
                    height: size, rowBytes: size * 4,
                    metadata: .init(orientation: .up, source: .testFixture))
                let original = try rows.map { try span(source, size: size, row: $0) }
                var previous = original
                for strength: Float in [0, 0.0625, 0.125, 0.25] {
                    let plan = BeautyEffectResolver.resolve(parameters: .init(noseRootNarrowing: strength),
                                                            faceGeometry: geometry)
                    let rendered = BeautyGeometryEffectPipeline.applyMVPProxy(to: canonical.ciImage,
                        canonicalImage: canonical, plan: plan, face: geometry)
                    XCTAssertEqual(rendered.extent, canonical.ciImage.extent)
                    var output = [UInt8](repeating: 0, count: source.count)
                    context.render(rendered, toBitmap: &output, rowBytes: size * 4,
                                   bounds: rendered.extent, format: .RGBA8, colorSpace: color)
                    let label = "size=\(size) phase=\(phase) strength=\(strength)"
                    if strength == 0 {
                        XCTAssertTrue(output == source, "Neutral must preserve every canonical byte: \(label)")
                    }
                    for (index, row) in rows.enumerated() {
                        let measured = try span(output, size: size, row: row)
                        // Four interpolated half-level positions can differ by
                        // a few hundredths of a pixel under byte quantization.
                        // This tolerance is below the cap's 16-Q16 requirement.
                        XCTAssertLessThanOrEqual(measured, original[index] + 0.05,
                            "Root may not expand: row=\(row) \(label)")
                        XCTAssertLessThanOrEqual(measured, previous[index] + 0.05,
                            "Increasing strength may not reverse narrowing: row=\(row) \(label)")
                        if strength == 0.25 {
                            let contractionQ16 = (original[index] - measured) * 65536 / Double(size)
                            XCTAssertGreaterThanOrEqual(contractionQ16, 16,
                                "Inner root material must narrow at cap: row=\(row) \(label)")
                        }
                        previous[index] = measured
                    }
                    assertProtectedPixels(source, output, size: size, context: label)
                }
            }
        }
    }

    func testAnatomicalSplitPixelPhasesKeepFirstBridgeRowSourceExact() throws {
        let color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
        for size in [128, 512, 1024] {
            let integerSplit = Int(floor(0.35 * Double(size)))
            for phase in [0.49, 0.51, 0.99] {
                // Shift anatomy itself, independently of marker phase. These
                // cases straddle the pixel-center decision, while the bridge
                // starts at the same integer floor-owned row in both cases.
                let split = (Double(integerSplit) + phase) / Double(size)
                let source = pixels(size: size, phase: 0.25)
                let canonical = try BeautyCanonicalStillImage(rgba8Data: Data(source), width: size,
                    height: size, rowBytes: size * 4,
                    metadata: .init(orientation: .up, source: .testFixture))
                let geometry = face(rootSplit: split)
                let plan = BeautyEffectResolver.resolve(parameters: .init(noseRootNarrowing: 0.25),
                                                        faceGeometry: geometry)
                let rendered = BeautyGeometryEffectPipeline.applyMVPProxy(to: canonical.ciImage,
                    canonicalImage: canonical, plan: plan, face: geometry)
                XCTAssertEqual(rendered.extent, canonical.ciImage.extent)
                var output = [UInt8](repeating: 0, count: source.count)
                context.render(rendered, toBitmap: &output, rowBytes: size * 4,
                               bounds: rendered.extent, format: .RGBA8, colorSpace: color)
                let label = "size=\(size) anatomicalSplitPixelPhase=\(phase)"
                let firstBridgeByte = integerSplit * size * 4
                let nextRowByte = (integerSplit + 1) * size * 4
                XCTAssertTrue(output[firstBridgeByte..<nextRowByte] == source[firstBridgeByte..<nextRowByte],
                    "The integer-owned first bridge row must stay source exact: \(label)")
                let bridgeEnd = Int(ceil(0.5 * Double(size))) * size * 4
                XCTAssertTrue(output[firstBridgeByte..<bridgeEnd] == source[firstBridgeByte..<bridgeEnd],
                    "All following bridge rows must stay source exact: \(label)")
                if size == 128 && phase == 0.99 {
                    // At this low-resolution anatomical phase the final cone
                    // genuinely covers the first bridge row. Evaluate its
                    // unclipped inverse sample independently, in Double, to
                    // prove the unchanged actual row exercises the cutoff.
                    // Emitted points are used only for this sampler-branch
                    // counterfactual, never to select the marker or cut row.
                    let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: geometry)
                    XCTAssertTrue(!points.isEmpty && points.allSatisfy {
                        $0.pixelCenterSampling && $0.falloff == 1 && $0.source.y == $0.target.y
                    })
                    var changedWithoutCutoff = 0
                    for x in 0..<size {
                        let px = (Double(x) + 0.5) / Double(size)
                        let py = (Double(integerSplit) + 0.5) / Double(size)
                        let displacement = points.reduce(0.0) { sum, point in
                            let dx = px - Double(point.target.x), dy = py - Double(point.target.y)
                            let weight = max(0, 1 - sqrt(dx * dx + dy * dy) / Double(point.radius))
                            return sum + (Double(point.target.x) - Double(point.source.x)) * weight * Double(size)
                        }
                        let sample = min(Double(size - 1), max(0, Double(x) - displacement))
                        let left = Int(floor(sample)), right = min(size - 1, left + 1)
                        let fraction = sample - Double(left)
                        let differs = (0..<3).contains { channel in
                            let a = Double(source[(integerSplit * size + left) * 4 + channel])
                            let b = Double(source[(integerSplit * size + right) * 4 + channel])
                            let uncut = Int((a * (1 - fraction) + b * fraction).rounded())
                            return abs(uncut - Int(source[(integerSplit * size + x) * 4 + channel])) > 2
                        }
                        if differs { changedWithoutCutoff += 1 }
                    }
                    XCTAssertGreaterThan(changedWithoutCutoff, 0,
                        "Removing the integer cutoff must change this protected row; otherwise the seam test is vacuous")
                }
                // The final cone tapers toward the seam; demanding the very
                // last root row change would incorrectly prohibit safe falloff.
                // Instead check a fixed 1%-image band immediately above it.
                let aboveStart = max(0, integerSplit - Int(ceil(0.01 * Double(size))))
                var changedAbove = 0, deltaAbove = 0
                for row in aboveStart..<integerSplit { for x in 0..<size {
                    let offset = (row * size + x) * 4
                    let delta = (0..<3).map { abs(Int(output[offset + $0]) - Int(source[offset + $0])) }
                    if delta.max()! > 2 { changedAbove += 1 }
                    deltaAbove += delta.reduce(0, +)
                } }
                XCTAssertGreaterThan(changedAbove, 0, "The admitted root above the seam must actually change: \(label)")
                XCTAssertGreaterThan(deltaAbove, 0, "The protected seam cannot pass by an entirely neutral root: \(label)")
                let measuredRow = Int(floor(0.325 * Double(size)))
                let contraction = try span(source, size: size, row: measuredRow)
                    - span(output, size: size, row: measuredRow)
                XCTAssertGreaterThanOrEqual(contraction * 65536 / Double(size), 16,
                    "The shifted source anatomy still needs meaningful inner-root contraction: \(label)")
            }
        }
    }

    func testMaterialSpanOracleIgnoresInteriorTextureMotion() throws {
        let size = 128
        let source = pixels(size: size, phase: 0.25)
        var changed = source
        for y in 0..<size { for x in 1..<size - 1 {
            for channel in 1..<3 {
                changed[(y * size + x) * 4 + channel] = source[(y * size + x - 1) * 4 + channel]
            }
        } }
        XCTAssertTrue(source != changed)
        for row in [35, 42] {
            XCTAssertEqual(try span(source, size: size, row: row),
                           try span(changed, size: size, row: row), accuracy: 0)
        }
    }
}
