import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyEffects

/// Synthetic observed contours only. These exercise the closed-mouth fallback;
/// real MediaPipe admission remains a separate physical-iOS qualification.
final class BeautyMouthClosedSeamTests: XCTestCase {
    private typealias P = SIMD2<Double>
    private let width = 240, height = 280
    private let xs: [Double] = [-0.4, -0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4]
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

    func testCollapsedObservedTracesAdmitAdjacentDuplicatesAndSharedContacts() throws {
        let raw = closedTrace(adjacentDuplicates: true)
        let observation = fixture(inner: raw), face = geometry(observation)
        XCTAssertFalse(BeautyDenseFaceSupport.simplePolygon(face.observedInnerLips ?? []),
            "This source deliberately cannot use the ordinary polygon path")
        let g = try XCTUnwrap(BeautyMouthReferenceGeometry(width: width, height: height, face: face))
        XCTAssertNotNil(g.inner)
        XCTAssertEqual(BeautyContinuousMouthMap.eligibleFieldMask(face: face), 255)
        for knot in g.seam.knots { XCTAssertEqual(knot.y, 0, accuracy: 3e-7) }
        XCTAssertEqual(g.seam.knots.count, 9)
        for slider in [BeautyMouthSlider.mShape, .fullness] {
            let plan = BeautyEffectResolver.resolve(parameters: slider.applying(position: 1, to: .init()), faceGeometry: face)
            XCTAssertTrue(plan.activeDomains.contains(.mouth))
            XCTAssertFalse(plan.skippedDomains.contains(.mouth))
            XCTAssertNotNil(BeautyContinuousMouthMap(width: width, height: height, face: face,
                strengths: plan.effectiveStrengths))
        }
    }

    func testSmallCrossingsUseBothObservedTracesWithoutInventingAnOpening() throws {
        let raw = crossingTrace(amplitude: 0.003)
        let face = geometry(fixture(inner: raw))
        XCTAssertFalse(BeautyDenseFaceSupport.simplePolygon(face.observedInnerLips ?? []))
        let g = try XCTUnwrap(BeautyMouthReferenceGeometry(width: width, height: height, face: face))
        XCTAssertNotNil(g.inner)
        XCTAssertEqual(BeautyContinuousMouthMap.eligibleFieldMask(face: face), 255)
        let collapsed = try XCTUnwrap(BeautyMouthReferenceGeometry(width: width, height: height,
            face: geometry(fixture(inner: closedTrace()))))
        for i in 0...80 {
            let x = -0.4 + 0.8 * Double(i) / 80
            XCTAssertEqual(g.seam.sample(at: x).value, collapsed.seam.sample(at: x).value, accuracy: 3e-7,
                "Opposite micro-crossings have the same observed midpoint, rather than a guessed aperture")
        }
    }

    func testCyclicStartAndReversedWindingKeepSeamAndForwardMapUnchanged() throws {
        for raw in [closedTrace(adjacentDuplicates: true), crossingTrace(amplitude: 0.003)] {
            let baselineFace = geometry(fixture(inner: raw))
            let baselineGeometry = try XCTUnwrap(BeautyMouthReferenceGeometry(width: width, height: height, face: baselineFace))
            let parameters = BeautyMouthSlider.fullness.applying(position: 1, to: .init())
            let baselinePlan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: baselineFace)
            let baseline = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                face: baselineFace, strengths: baselinePlan.effectiveStrengths))
            for offset in [0, 1, raw.count / 2, raw.count - 1] {
                let rotated = Array(raw[offset...]) + Array(raw[..<offset])
                for variant in [rotated, Array(rotated.reversed())] {
                    let face = geometry(fixture(inner: variant))
                    let g = try XCTUnwrap(BeautyMouthReferenceGeometry(width: width, height: height, face: face))
                    XCTAssertNotNil(g.inner)
                    XCTAssertEqual(BeautyContinuousMouthMap.eligibleFieldMask(face: face), 255)
                    let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
                    let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                        face: face, strengths: plan.effectiveStrengths))
                    for i in 0...24 {
                        let x = -0.4 + 0.8 * Double(i) / 24
                        XCTAssertEqual(g.seam.sample(at: x).value, baselineGeometry.seam.sample(at: x).value, accuracy: 1e-11)
                        XCTAssertEqual(g.seam.sample(at: x).slope, baselineGeometry.seam.sample(at: x).slope, accuracy: 1e-10)
                        let p = baselineGeometry.image(P(x, 0.11))
                        let d = map.forwardDisplacement(at: p) - baseline.forwardDisplacement(at: p)
                        XCTAssertLessThan(hypot(d.x, d.y), 1e-9)
                    }
                }
            }
        }
    }

    func testBothSignedLipFieldsMoveInvertAndReachActualCPUResampling() throws {
        let source = raster()
        let original = try BeautyCanonicalStillImage(rgba8Data: Data(source), width: width, height: height,
            rowBytes: width * 4, metadata: metadata)
        for raw in [closedTrace(adjacentDuplicates: true), crossingTrace(amplitude: 0.003)] {
            let observation = fixture(inner: raw), face = geometry(observation)
            let g = try XCTUnwrap(BeautyMouthReferenceGeometry(width: width, height: height, face: face))
            for slider in [BeautyMouthSlider.mShape, .fullness] {
                for position: Float in [0, 1] {
                    let label = slider.rawValue + ":" + String(position)
                    let parameters = slider.applying(position: position, to: .init())
                    let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
                    let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                        face: face, strengths: plan.effectiveStrengths), label)
                    var maximumMotion = 0.0
                    for x in [-0.25, -0.1, 0, 0.1, 0.25] {
                        for depth in [-0.14, -0.06, 0.04, 0.14] {
                            let p = g.image(P(x, g.seam.sample(at: x).value + depth))
                            let forward = map.forwardDisplacement(at: p)
                            maximumMotion = max(maximumMotion, hypot(forward.x, forward.y))
                            let target = p + forward
                            let recovered = try XCTUnwrap(map.sourcePoint(for: target), label)
                            XCTAssertLessThan(hypot(recovered.x - p.x, recovered.y - p.y), 0.001, label)
                            let inverseDisplacement = map.displacement(at: target)
                            XCTAssertLessThan(hypot(inverseDisplacement.x - forward.x,
                                inverseDisplacement.y - forward.y), 0.001, label)
                        }
                    }
                    XCTAssertGreaterThan(maximumMotion, 0.01, label)
                    let expected = map.applyRGBA(source)
                    XCTAssertNotEqual(expected, source, label)
                    let stage = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
                        plan: plan, face: face)
                    XCTAssertTrue(stage.controlPoints.isEmpty, label)
                    XCTAssertEqual(stage.applyingContinuousMouth(to: source), expected, label)
                    let request = try BeautyBackendRequest(policy: .cpu, input: .stillImage(original.ciImage),
                        metadata: metadata, plan: plan, selectedFaceSupport: observation, canonicalImage: original)
                    let result = try BeautyCPUBackend().execute(request)
                    guard case .stillImage(let output) = result.output else { return XCTFail("still image required") }
                    XCTAssertEqual(bytes(output), expected, label)
                    XCTAssertEqual(output.extent, original.ciImage.extent, label)
                    XCTAssertTrue(stride(from: 3, to: expected.count, by: 4).allSatisfy { expected[$0] == source[$0] }, label)
                    // Source-defined upper-face and far-side strips; no field
                    // envelope is read to choose these protected pixels.
                    var protectedChanges = 0
                    for y in 0..<height { for x in 0..<width where y < height / 2 || x < 8 || x >= width - 8 {
                        let offset = (y * width + x) * 4
                        if (0..<4).contains(where: { expected[offset + $0] != source[offset + $0] }) { protectedChanges += 1 }
                    } }
                    XCTAssertEqual(protectedChanges, 0, label)
                    XCTAssertEqual(original.rgba8Data, Data(source), label)
                    XCTAssertEqual(parameters.teethWhitening, 0, label)
                }
            }
        }
    }

    func testMissingDisorderedVerticalWideCrossingAndOutOfBoundsEvidenceAbstainsOnlyLipFields() throws {
        let valid = closedTrace()
        var disordered = valid; disordered.swapAt(2, 3)
        var vertical = valid; vertical.insert(P(valid[3].x, valid[3].y + 0.002), at: 4)
        var unitBounds = valid; unitBounds[3] = P(2, 0)
        var outerBounds = valid; outerBounds[3] = P(valid[3].x, 0.30)
        var nonfinite = valid; nonfinite[3] = P(.nan, 0)
        let cases: [(String, [P]?)] = [("missing", nil), ("empty", []), ("disordered", disordered),
            ("same_x_different_y", vertical), ("wide_crossing", crossingTrace(amplitude: 0.030)),
            ("unit_bounds", unitBounds), ("outer_bounds", outerBounds), ("nonfinite", nonfinite),
            ("two_points", [P(-0.4, 0), P(0.4, 0)]),
            ("two_distinct_x", [P(-0.4, 0), P(-0.4, 0), P(0.4, 0), P(0.4, 0)])]
        for (label, raw) in cases { try assertRejectedInner(raw, label: label) }
    }

    func testGapAtAnOriginalUnionKnotCannotHideBetweenTheNineSeamSamples() throws {
        var upper = xs.map { P($0, 0) }
        upper += [P(-0.289, 0), P(-0.287, 0.030), P(-0.285, 0)]
        upper.sort { $0.x < $1.x }
        let lower = xs.map { P($0, 0) }
        let raw = upper + lower.reversed()
        // Every planned seam-grid query misses this narrow aperture; the
        // original union knot still exceeds the explicit 0.025W allowance.
        for i in 0...8 {
            let x = -0.399 + 0.798 * Double(i) / 8
            XCTAssertEqual(try XCTUnwrap(linear(upper, x: x)), 0, accuracy: 1e-12)
        }
        XCTAssertEqual(try XCTUnwrap(linear(upper, x: -0.287)), 0.030, accuracy: 1e-12)
        try assertRejectedInner(Array(raw), label: "original_union_gap")
    }

    func testNarrowSharedMidlineSpikeCannotHideBetweenSeamSamples() throws {
        var trace = xs.map { P($0, 0) }
        trace += [P(-0.289, 0), P(-0.287, 0.040), P(-0.285, 0)]
        trace.sort { $0.x < $1.x }
        let raw = trace + trace.reversed()
        XCTAssertEqual(try XCTUnwrap(linear(trace, x: -0.287)), 0.040, accuracy: 1e-12)
        for i in 0...8 {
            let x = -0.399 + 0.798 * Double(i) / 8
            XCTAssertEqual(try XCTUnwrap(linear(trace, x: x)), 0, accuracy: 1e-12)
        }
        // Trace gap is exactly zero. Rejection must retain the actual observed
        // midpoint constraint rather than silently flattening its narrow peak.
        try assertRejectedInner(Array(raw), label: "shared_midline_spike")
    }

    func testAnalyticC1OvershootOutsideObservedSupportIsRejected() throws {
        let values: [Double] = [0.22, 0.22, -0.22, -0.22, -0.22, 0.22, 0.22, 0.22, 0.22]
        let trace = zip(xs, values).map { P($0.0, $0.1) }
        let raw = trace + trace.reversed()
        // All original segments remain inside the flat-sided source outer
        // contour. Only the reconstructed C1 polynomial crosses its tolerance.
        XCTAssertTrue(trace.allSatisfy { $0.y >= -0.22 && $0.y <= 0.22 })
        let samples = try (0...8).map { i -> P in
            let x = -0.399 + 0.798 * Double(i) / 8
            return P(x, try XCTUnwrap(linear(trace, x: x)))
        }
        let seam = try XCTUnwrap(BeautyMouthReferenceModel.Seam(knots: samples))
        XCTAssertLessThan(seam.minimumValue, -0.22 - 0.025,
            "The test must actually cross the analytic extremum gate")
        try assertRejectedInner(Array(raw), label: "C1_analytic_overshoot")
    }

    func testOrdinarySimplePolygonRetainsTheOriginalVerticalIntersectionSeam() throws {
        func center(_ x: Double) -> Double { 0.012 * x + 0.010 * exp(-pow(x / 0.15, 2)) }
        let upper = xs.map { x in P(x, center(x) - 0.050 * sqrt(max(0, 1 - pow(x / 0.4, 2)))) }
        let lower = xs.map { x in P(x, center(x) + 0.050 * sqrt(max(0, 1 - pow(x / 0.4, 2)))) }
        let raw = upper + lower.dropFirst().dropLast().reversed()
        let face = geometry(fixture(inner: Array(raw)))
        let observed = try XCTUnwrap(face.observedInnerLips)
        XCTAssertTrue(BeautyDenseFaceSupport.simplePolygon(observed))
        let g = try XCTUnwrap(BeautyMouthReferenceGeometry(width: width, height: height, face: face))
        let admitted = try XCTUnwrap(g.inner)
        let points = observed.map { g.local(P(Double($0.x) * Double(width), Double($0.y) * Double(height))) }
        XCTAssertEqual(admitted, points, "An ordinary polygon retains its actual vertices")
        let low = max(-0.48, try XCTUnwrap(points.map(\.x).min()) + 0.001)
        let high = min(0.48, try XCTUnwrap(points.map(\.x).max()) - 0.001)
        let knots = try (0...8).map { i -> P in
            let x = low + (high - low) * Double(i) / 8
            let intersections = crossings(points, x: x)
            return P(x, (try XCTUnwrap(intersections.min()) + XCTUnwrap(intersections.max())) * 0.5)
        }
        let expected = try XCTUnwrap(BeautyMouthReferenceModel.Seam(knots: knots))
        XCTAssertEqual(BeautyContinuousMouthMap.eligibleFieldMask(face: face), 255)
        for i in 0...100 {
            let x = low + (high - low) * Double(i) / 100
            XCTAssertEqual(g.seam.sample(at: x).value, expected.sample(at: x).value, accuracy: 1e-12)
            XCTAssertEqual(g.seam.sample(at: x).slope, expected.sample(at: x).slope, accuracy: 1e-12)
        }
    }

    private func closedTrace(adjacentDuplicates: Bool = false) -> [P] {
        var trace = xs.map { P($0, 0) }
        if adjacentDuplicates { trace.insert(trace[3], at: 4) }
        return trace + trace.reversed()
    }
    private func crossingTrace(amplitude: Double) -> [P] {
        let upper = xs.enumerated().map { i, x -> P in
            P(x, i == 0 || i == xs.count - 1 ? 0 : (i.isMultiple(of: 2) ? amplitude : -amplitude))
        }
        return upper + upper.reversed().map { P($0.x, -$0.y) }
    }
    private func fixture(inner: [P]?) -> BeautyFaceObservation {
        func p(_ x: Double, _ y: Double) -> CoordinatePoint { .init(x: x, y: y) }
        func lip(_ q: P) -> CoordinatePoint { p(0.5 + 0.36 * q.x, 0.66 + 0.36 * q.y) }
        func eye(_ x: Double) -> [CoordinatePoint] {
            (0..<12).map { i in let a = Double(i) * .pi / 6
                return p(x + 0.055 * cos(a), 0.34 + 0.022 * sin(a)) }
        }
        let outer = [P(-0.5, 0), P(-0.4, -0.22), P(0.4, -0.22),
                     P(0.5, 0), P(0.4, 0.22), P(-0.4, 0.22)]
        return BeautyFaceObservation(imageBounds: .init(x: 0.12, y: 0.08, width: 0.76, height: 0.84),
            landmarks: .complete,
            observedEyeSupport: [.init(side: .left, contour: eye(0.34)), .init(side: .right, contour: eye(0.66))],
            observedEyeOrder: .canonical,
            observedLipSupport: .init(outer: outer.map(lip), inner: inner?.map(lip)),
            observedNoseSupport: .init(crest: [p(0.5, 0.43), p(0.5, 0.47), p(0.5, 0.50)],
                contour: [p(0.45, 0.50), p(0.47, 0.53), p(0.5, 0.54), p(0.53, 0.53), p(0.55, 0.50)]))
    }
    private func geometry(_ observation: BeautyFaceObservation) -> FaceGeometry {
        BeautyFaceGeometryAdapter.makeGeometry(from: observation)
    }
    private func assertRejectedInner(_ raw: [P]?, label: String,
                                     file: StaticString = #filePath, line: UInt = #line) throws {
        let face = geometry(fixture(inner: raw))
        let g = try XCTUnwrap(BeautyMouthReferenceGeometry(width: width, height: height, face: face), label, file: file, line: line)
        XCTAssertNil(g.inner, label, file: file, line: line)
        XCTAssertEqual(BeautyContinuousMouthMap.eligibleFieldMask(face: face), 63, label, file: file, line: line)
        for slider in [BeautyMouthSlider.mShape, .fullness] {
            let plan = BeautyEffectResolver.resolve(parameters: slider.applying(position: 1, to: .init()), faceGeometry: face)
            XCTAssertTrue(plan.skippedDomains.contains(.mouth), label, file: file, line: line)
            XCTAssertEqual(plan.effectiveStrengths.lipPeakDefinition, 0, label, file: file, line: line)
            XCTAssertEqual(plan.effectiveStrengths.lipPlump, 0, label, file: file, line: line)
            XCTAssertNil(BeautyContinuousMouthMap(width: width, height: height, face: face,
                strengths: plan.effectiveStrengths), label, file: file, line: line)
        }
    }
    private func linear(_ trace: [P], x: Double) -> Double? {
        for (a, b) in zip(trace, trace.dropFirst()) where a.x <= x && x <= b.x && a.x < b.x {
            return a.y + (b.y - a.y) * (x - a.x) / (b.x - a.x)
        }
        return nil
    }
    private func crossings(_ polygon: [P], x: Double) -> [Double] {
        polygon.indices.compactMap { i in
            let a = polygon[i], b = polygon[(i + 1) % polygon.count]
            guard a.x != b.x, min(a.x, b.x) <= x, x <= max(a.x, b.x) else { return nil }
            return a.y + (b.y - a.y) * (x - a.x) / (b.x - a.x)
        }
    }
    private func raster() -> [UInt8] {
        (0..<(width * height)).flatMap { i -> [UInt8] in
            let x = i % width, y = i / width
            return [UInt8(30 + (x * 11 + y * 7) % 190), UInt8(20 + (x * 3 + y * 13) % 200),
                    UInt8(25 + (x * 17 + y * 5) % 195), 255]
        }
    }
    private func bytes(_ image: CIImage) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: width * height * 4)
        let context = CIContext(options: [.cacheIntermediates: false])
        result.withUnsafeMutableBytes { context.render(image, toBitmap: $0.baseAddress!, rowBytes: width * 4,
            bounds: image.extent, format: .RGBA8, colorSpace: colorSpace) }
        return result
    }
}
