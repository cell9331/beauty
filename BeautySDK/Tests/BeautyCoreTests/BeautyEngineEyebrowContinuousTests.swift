import BeautyCore
import BeautyDetection
import BeautyEffects
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautySDK

/// Source-defined eyebrow material exercises the public facade and actual
/// selected backends. The injected observations are deterministic carriers,
/// not native detector or photographic appearance evidence. Operation domains
/// come from the source trace, material thickness and declared cap travel.
final class BeautyEngineEyebrowContinuousTests: XCTestCase {
    private struct Field {
        let name: String
        let key: WritableKeyPath<BeautyParameters, Float>
        /// A source-relative bound on the field's single-cap material travel.
        let travelFraction: Double
    }

    private let fields: [Field] = [
        Field(name: "vertical", key: \.eyebrowYPosition, travelFraction: 0.041),
        Field(name: "thickness", key: \.eyebrowThickness, travelFraction: 0),
        Field(name: "length", key: \.eyebrowLength, travelFraction: 0.05),
        Field(name: "spacing", key: \.eyebrowSpacing, travelFraction: 0.055),
        Field(name: "head", key: \.eyebrowHeadSpacing, travelFraction: 0.095),
        Field(name: "tilt", key: \.eyebrowTilt, travelFraction: 0),
        Field(name: "peak", key: \.eyebrowPeakDefinition, travelFraction: 0.065)
    ]
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    func testSevenSignedFieldsMoveVisibleSourceMaterialAndKeepCompactExteriorExact() throws {
        let fixture = Fixture()
        let source = fixture.raster()
        let engine = try makeEngine(fixture)
        for field in fields {
            var endpoints: [[UInt8]] = []
            for sign: Float in [-1, 1] {
                let result = try render(engine, fixture: fixture, parameters: parameters(field, sign))
                let output = fixture.bytes(result.output)
                XCTAssertFalse(output == source, "\(field.name) must materialize the requested sign")
                assertDirection(source, output, field: field, sign: sign, fixture: fixture)
                assertProtected(source, output, field: field, fixture: fixture)
                assertMetadata(result, fixture: fixture, active: true, canonical: false)
                endpoints.append(output)
            }
            XCTAssertFalse(endpoints[0] == endpoints[1], "\(field.name) signed endpoints are distinct")
        }
    }

    func testNeutralRepeatCanonicalMetadataAndIndependentControlsRemainStable() throws {
        let fixture = Fixture()
        let source = fixture.raster()
        let engine = try makeEngine(fixture)
        let neutral = try render(engine, fixture: fixture, parameters: .init())
        XCTAssertTrue(fixture.bytes(neutral.output) == source, "neutral preserves original RGBA")
        for field in fields {
            let input = parameters(field, -1)
            let first = try render(engine, fixture: fixture, parameters: input)
            let repeated = try render(engine, fixture: fixture, parameters: input)
            let output = fixture.bytes(first.output)
            XCTAssertTrue(output == fixture.bytes(repeated.output), "\(field.name) repeat RGBA")
            XCTAssertEqual(first.metrics, repeated.metrics)
            XCTAssertEqual(first.warnings, repeated.warnings)
            XCTAssertEqual(first.detectionSummary, repeated.detectionSummary)
            let canonical = try render(engine, fixture: fixture, parameters: input, canonical: true)
            XCTAssertTrue(output == fixture.bytes(canonical.output), "\(field.name) canonical opaque route")
            assertMetadata(canonical, fixture: fixture, active: true, canonical: true)
            assertProtected(source, output, field: field, fixture: fixture)
        }
        let reset = try render(engine, fixture: fixture, parameters: .init())
        XCTAssertTrue(fixture.bytes(reset.output) == source, "active requests retain no prior work")
    }

    func testUnilateralHeadMotionProtectsMissingPeerAndWholeSpacingRequiresPair() throws {
        let fixture = Fixture()
        let source = fixture.raster()
        let head = fields[4]
        for sign: Float in [-1, 1] {
            let engine = try makeEngine(fixture, support: .leftOnly)
            let result = try render(engine, fixture: fixture, parameters: parameters(head, sign))
            let output = fixture.bytes(result.output)
            XCTAssertFalse(output == source, "a valid observed side retains head motion")
            assertProtected(source, output, field: head, fixture: fixture, sides: [0])
            assertMetadata(result, fixture: fixture, active: true)
            let unavailable = try render(engine, fixture: fixture, parameters: parameters(fields[3], sign))
            XCTAssertTrue(fixture.bytes(unavailable.output) == source, "whole spacing must not borrow a missing peer")
            XCTAssertEqual(unavailable.metrics["beauty.effects.activeCount"], 0)
        }
    }

    func testMissingMalformedNoFaceAndValidInvalidValidNeverCarryPriorBrowWork() throws {
        let fixture = Fixture()
        let source = fixture.raster()
        for support in [Fixture.Support.missing, .malformed, .noFace] {
            let engine = try makeEngine(fixture, support: support)
            for field in fields {
                let result = try render(engine, fixture: fixture, parameters: parameters(field, -1))
                XCTAssertTrue(fixture.bytes(result.output) == source, "\(field.name) rejected support stays source-exact")
                XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 0)
                assertMetadata(result, fixture: fixture, active: false)
            }
        }
        let probe = SequenceProbe([fixture.observation(), fixture.observation(support: .malformed),
                                   fixture.observation()])
        let engine = try BeautyEngine(faceDetector: probe.detector())
        let input = parameters(fields[6], -1)
        let first = try render(engine, fixture: fixture, parameters: input)
        let rejected = try render(engine, fixture: fixture, parameters: input)
        let recovered = try render(engine, fixture: fixture, parameters: input)
        XCTAssertFalse(fixture.bytes(first.output) == source, "negative peak is real source material motion")
        XCTAssertTrue(fixture.bytes(rejected.output) == source)
        XCTAssertTrue(fixture.bytes(first.output) == fixture.bytes(recovered.output))
        XCTAssertEqual(first.metrics, recovered.metrics)
        XCTAssertEqual(first.warnings, recovered.warnings)
        XCTAssertEqual(probe.calls, 3)
    }

    func testAvailableSelectedMetalExecutesAllFourteenSignedEndpointsAndMatchesCPU() throws {
        let fixture = Fixture()
        let source = fixture.raster()
        let counter = InvocationCounter()
        let metal: BeautyMetalBackend
        do { metal = try BeautyMetalBackend(hooks: .init(onRuntimeInvocation: { counter.increment() })) }
        catch BeautyError.metalUnavailable { throw XCTSkip("Metal unavailable; no executed eyebrow parity claim") }
        let cpu = try makeEngine(fixture)
        let gpu = try makeEngine(fixture, metal: metal)
        for field in fields {
            for sign: Float in [-1, 1] {
                let input = parameters(field, sign)
                let reference = try render(cpu, fixture: fixture, parameters: input, canonical: true)
                let selected = try render(gpu, fixture: fixture, parameters: input, canonical: true)
                let a = fixture.bytes(reference.output), b = fixture.bytes(selected.output)
                let maximumChannelError = zip(a, b).reduce(0) { max($0, abs(Int($1.0) - Int($1.1))) }
                XCTAssertLessThanOrEqual(maximumChannelError, 2, "\(field.name) actual CPU/Metal endpoint")
                XCTAssertFalse(b == source, "\(field.name) selected Metal must contain the eyebrow effect")
                assertDirection(source, b, field: field, sign: sign, fixture: fixture)
                assertProtected(source, b, field: field, fixture: fixture)
                assertMetadata(selected, fixture: fixture, active: true, canonical: true)
            }
        }
        XCTAssertEqual(counter.value, 14, "all fourteen selected requests must invoke the Metal runtime")
    }

    func testSourceMarkerTrackerRejectsIdentityAndRecoversIndependentIntegerTranslations() throws {
        let fixture = Fixture(), source = fixture.raster()
        for offset in [-3, 3] {
            var translated = source
            for y in 140..<235 { for x in 130..<383 {
                let donorX = x-offset, donorY = y-offset
                let i = (y*fixture.width+x)*4, j = (donorY*fixture.width+donorX)*4
                for c in 0..<4 { translated[i+c] = source[j+c] }
            } }
            for side in 0..<2 { for channel in 0..<3 {
                let before = try fixture.marker(source, side: side, channel: channel)
                let after = try fixture.marker(translated, side: side, channel: channel)
                XCTAssertEqual(after.x-before.x, Double(offset), accuracy: 0.01)
                XCTAssertEqual(after.y-before.y, Double(offset), accuracy: 0.01)
                XCTAssertEqual(try fixture.marker(source, side: side, channel: channel), before)
            } }
        }
    }

    func testSelectedMetalCombinesColorWithBrowMaterialAndProtectsColorOnlyExterior() throws {
        let fixture = Fixture()
        let counter = InvocationCounter()
        let metal: BeautyMetalBackend
        do { metal = try BeautyMetalBackend(hooks: .init(onRuntimeInvocation: { counter.increment() })) }
        catch BeautyError.metalUnavailable { throw XCTSkip("Metal unavailable; no executed color/brow parity claim") }
        let cpu = try makeEngine(fixture), gpu = try makeEngine(fixture, metal: metal)
        var color = BeautyParameters(); color.brightness = 0.20
        var combined = color; combined.eyebrowYPosition = 0.25
        let cpuColor = fixture.bytes(try render(cpu, fixture: fixture, parameters: color, canonical: true).output)
        let gpuColor = fixture.bytes(try render(gpu, fixture: fixture, parameters: color, canonical: true).output)
        let cpuCombined = fixture.bytes(try render(cpu, fixture: fixture, parameters: combined, canonical: true).output)
        let gpuCombined = fixture.bytes(try render(gpu, fixture: fixture, parameters: combined, canonical: true).output)
        XCTAssertFalse(cpuCombined == cpuColor, "CPU retains the requested brow alongside color")
        XCTAssertFalse(gpuCombined == gpuColor, "selected Metal retains the requested brow alongside color")
        XCTAssertLessThanOrEqual(zip(cpuCombined, gpuCombined).reduce(0) { max($0, abs(Int($1.0)-Int($1.1))) }, 2)
        assertProtected(cpuColor, cpuCombined, field: fields[0], fixture: fixture)
        assertProtected(gpuColor, gpuCombined, field: fields[0], fixture: fixture)
        XCTAssertGreaterThanOrEqual(counter.value, 2, "both selected requests execute the runtime")
    }

    func testInvalidInputFailsBeforeDetectionAndValidSiblingStillRecovers() throws {
        let fixture = Fixture()
        let counter = InvocationCounter()
        let observation = fixture.observation()
        let detector = BeautyFaceDetector(mappedObservationProvider: { _ in
            counter.increment()
            return BeautyMappedFaceObservations(observations: [observation])
        })
        let engine = try BeautyEngine(faceDetector: detector)
        XCTAssertThrowsError(try engine.processResult(image: CIImage.empty(), metadata: metadata,
            parameters: parameters(fields[6], -1))) { XCTAssertEqual($0 as? BeautyError, .invalidInput) }
        XCTAssertEqual(counter.value, 0)
        let valid = try render(engine, fixture: fixture, parameters: parameters(fields[6], -1))
        XCTAssertEqual(counter.value, 1)
        XCTAssertFalse(fixture.bytes(valid.output) == fixture.raster())
    }

    private func parameters(_ field: Field, _ sign: Float) -> BeautyParameters {
        var result = BeautyParameters()
        result[keyPath: field.key] = sign * 0.25
        return result
    }

    private func makeEngine(_ fixture: Fixture, support: Fixture.Support = .paired,
                            metal: BeautyMetalBackend? = nil) throws -> BeautyEngine {
        let observations = support == .noFace ? [] : [fixture.observation(support: support)]
        let detector = BeautyFaceDetector(mappedObservationProvider: { _ in
            BeautyMappedFaceObservations(observations: observations)
        })
        if let metal {
            return try BeautyEngine(configuration: .init(renderBackend: .gpu),
                                    faceDetector: detector, backendExecutor: metal)
        }
        return try BeautyEngine(faceDetector: detector)
    }

    private func render(_ engine: BeautyEngine, fixture: Fixture, parameters: BeautyParameters,
                        canonical: Bool = false) throws -> BeautyResult<CIImage> {
        let mask = canonical ? try BeautyTextureExclusionMask(width: fixture.width, height: fixture.height,
            bytes: [UInt8](repeating: 0, count: fixture.width * fixture.height)) : nil
        return try engine.processResult(image: fixture.image(), metadata: metadata,
                                        parameters: parameters, textureExclusionMask: mask)
    }

    private func assertDirection(_ source: [UInt8], _ output: [UInt8], field: Field, sign: Float,
                                 fixture: Fixture, file: StaticString = #filePath, line: UInt = #line) {
        for side in 0..<2 {
            let outward = side == 0 ? -1.0 : 1.0
            let head = try? fixture.marker(source, side: side, channel: 0)
            let tail = try? fixture.marker(source, side: side, channel: 2)
            let peak = try? fixture.marker(source, side: side, channel: 1)
            let movedHead = try? fixture.marker(output, side: side, channel: 0)
            let movedTail = try? fixture.marker(output, side: side, channel: 2)
            let movedPeak = try? fixture.marker(output, side: side, channel: 1)
            guard let head, let tail, let peak, let movedHead, let movedTail, let movedPeak else {
                XCTFail("\(field.name) must retain all observed source material markers", file: file, line: line)
                continue
            }
            let amount: Double
            switch field.name {
            case "vertical": amount = (movedHead.y + movedTail.y + movedPeak.y - head.y - tail.y - peak.y) / 3
            case "thickness": amount = fixture.darknessArea(output, side: side) - fixture.darknessArea(source, side: side)
            case "length": amount = (movedTail.x - tail.x) * outward
            case "spacing": amount = ((movedHead.x + movedTail.x - head.x - tail.x) * 0.5) * outward
            case "head":
                amount = (movedHead.x - head.x) * outward
                XCTAssertEqual(movedTail.x, tail.x, accuracy: 0.20, "head spacing keeps the source tail distinct", file: file, line: line)
                XCTAssertEqual(movedTail.y, tail.y, accuracy: 0.20, file: file, line: line)
            case "tilt": amount = (tail.y - head.y) - (movedTail.y - movedHead.y)
            default: amount = (peak.y - (head.y + tail.y) * 0.5) - (movedPeak.y - (movedHead.y + movedTail.y) * 0.5)
            }
            XCTAssertGreaterThan(amount * Double(sign), field.name == "thickness" ? 0.5 : 0.04,
                                 "\(field.name) has the declared signed material direction", file: file, line: line)
        }
    }

    private func assertProtected(_ source: [UInt8], _ output: [UInt8], field: Field, fixture: Fixture,
                                 sides: [Int] = [0, 1], file: StaticString = #filePath, line: UInt = #line) {
        var outside = 0, eyes = 0, nose = 0, lips = 0, alpha = 0
        for y in 0..<fixture.height { for x in 0..<fixture.width {
            let i = (y * fixture.width + x) * 4
            if source[i + 3] != output[i + 3] { alpha += 1 }
            guard source[i..<(i + 4)] != output[i..<(i + 4)] else { continue }
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            if !sides.contains(where: { fixture.operationDomainContains(p, side: $0, field: field) }) { outside += 1 }
            let nx = p.x / Double(fixture.width), ny = p.y / Double(fixture.height)
            if (0.27...0.73).contains(nx), (0.46...0.52).contains(ny) { eyes += 1 }
            if (0.44...0.56).contains(nx), (0.54...0.64).contains(ny) { nose += 1 }
            if (0.39...0.61).contains(nx), (0.68...0.75).contains(ny) { lips += 1 }
        } }
        XCTAssertEqual(outside, 0, "\(field.name) source-defined compact domain exterior RGBA", file: file, line: line)
        XCTAssertEqual(eyes, 0, "\(field.name) full eyes remain RGBA exact", file: file, line: line)
        XCTAssertEqual(nose, 0, "\(field.name) nose remains RGBA exact", file: file, line: line)
        XCTAssertEqual(lips, 0, "\(field.name) lips remain RGBA exact", file: file, line: line)
        XCTAssertEqual(alpha, 0, "\(field.name) alpha remains exact", file: file, line: line)
    }

    private func assertMetadata(_ result: BeautyResult<CIImage>, fixture: Fixture, active: Bool, canonical: Bool = false,
                                file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(result.output.extent, CGRect(x: 0, y: 0, width: fixture.width, height: fixture.height), file: file, line: line)
        // Only the explicit canonical carrier promises a tagged sRGB output.
        // Ordinary decoded CIImage retains the existing RGB route contract.
        XCTAssertEqual(result.output.colorSpace?.model, .rgb, file: file, line: line)
        if canonical { XCTAssertEqual(result.output.colorSpace?.name, CGColorSpace.sRGB, file: file, line: line) }
        XCTAssertTrue(result.metrics.values.allSatisfy(\.isFinite), file: file, line: line)
        if active {
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1, file: file, line: line)
            XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 1, file: file, line: line)
            XCTAssertFalse(result.warnings.contains { $0.code == "eyebrow_inputs_missing" }, file: file, line: line)
        }
        let diagnosticText = (result.warnings.map { $0.code + " " + $0.message }
            + Array(result.metrics.keys)).joined(separator: " ").lowercased()
        XCTAssertFalse(["coordinate", "transcript", "/private/", "file://", "raw pixels", "landmark"].contains(where: diagnosticText.contains), file: file, line: line)
    }

    private final class InvocationCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var count = 0
        var value: Int { lock.lock(); defer { lock.unlock() }; return count }
        func increment() { lock.lock(); defer { lock.unlock() }; count += 1 }
    }

    private final class SequenceProbe: @unchecked Sendable {
        private let lock = NSLock()
        private let observations: [BeautyFaceObservation]
        private var count = 0
        var calls: Int { lock.lock(); defer { lock.unlock() }; return count }
        init(_ observations: [BeautyFaceObservation]) { self.observations = observations }
        func detector() -> BeautyFaceDetector {
            BeautyFaceDetector(mappedObservationProvider: { [self] _ in
                lock.lock(); defer { lock.unlock() }
                let selected = observations[min(count, observations.count - 1)]
                count += 1
                return BeautyMappedFaceObservations(observations: [selected])
            })
        }
    }

    private struct Fixture: Sendable {
        let width = 512, height = 512
        let halfThickness = 0.009 * 512.0
        let capRim = 2.0
        enum Support { case paired, leftOnly, missing, malformed, noFace }

        /// Frozen canonical bowed traces from EyebrowSafetyFixtures. These are
        /// the source material centerlines; they do not come from rendered output.
        func trace(_ side: Int) -> [SIMD2<Double>] {
            let xs = side == 0 ? [0.47, 0.43, 0.39, 0.35, 0.31] : [0.53, 0.57, 0.61, 0.65, 0.69]
            return zip(xs, [0.41, 0.37, 0.34, 0.37, 0.41]).map {
                SIMD2($0.0 * Double(width), $0.1 * Double(height))
            }
        }

        func operationDomainContains(_ p: SIMD2<Double>, side: Int, field: Field) -> Bool {
            let points = trace(side)
            let span = abs(points.last!.x - points.first!.x)
            let travel: Double
            switch field.name {
            case "thickness": travel = halfThickness * 0.20
            case "tilt":
                // The declared rotation pivot is at 65% of the source chord,
                // on this frozen piecewise-linear source centerline.
                let pivot = points[2] + (points[3] - points[2]) * 0.60
                let radius = points.map { hypot($0.x - pivot.x, $0.y - pivot.y) }.max()!
                travel = 2 * radius * sin(0.0698132 * 0.5)
            default: travel = span * field.travelFraction
            }
            return distance(p, to: points) <= halfThickness + travel + capRim
        }

        func observation(support: Support = .paired) -> BeautyFaceObservation {
            func normalized(_ points: [SIMD2<Double>]) -> [CoordinatePoint] {
                points.map { CoordinatePoint(x: $0.x / Double(width), y: $0.y / Double(height)) }
            }
            func ellipse(_ x: Double, _ y: Double, _ rx: Double, _ ry: Double) -> [CoordinatePoint] {
                (0..<16).map { index in
                    let a = Double(index) * .pi * 2 / 16
                    return CoordinatePoint(x: x + rx * cos(a), y: y + ry * sin(a))
                }
            }
            let brows: BeautyObservedEyebrowSupport?
            switch support {
            case .missing, .noFace: brows = nil
            case .malformed:
                let repeated = Array(repeating: CoordinatePoint(x: 0.4, y: 0.35), count: 5)
                brows = BeautyObservedEyebrowSupport(left: repeated, right: repeated)
            default: brows = BeautyObservedEyebrowSupport(left: normalized(trace(0)),
                right: support == .leftOnly ? nil : normalized(trace(1)))
            }
            return BeautyFaceObservation(confidence: 1,
                imageBounds: CoordinateRect(x: 0.16, y: 0.16, width: 0.68, height: 0.68),
                observedEyeSupport: [
                    BeautyObservedEyeSupport(side: .left, contour: ellipse(0.36, 0.49, 0.065, 0.025)),
                    BeautyObservedEyeSupport(side: .right, contour: ellipse(0.64, 0.49, 0.065, 0.025))
                ], observedEyeOrder: .canonical, observedEyebrowSupport: brows,
                observedLipSupport: BeautyObservedLipSupport(outer: ellipse(0.5, 0.71, 0.095, 0.027)),
                observedNoseSupport: BeautyObservedNoseSupport(
                    crest: [CoordinatePoint(x: 0.5, y: 0.54), CoordinatePoint(x: 0.5, y: 0.60)],
                    contour: ellipse(0.5, 0.60, 0.04, 0.035)))
        }

        func raster() -> [UInt8] {
            var output = [UInt8](repeating: 255, count: width * height * 4)
            let paths = [trace(0), trace(1)]
            for y in 0..<height { for x in 0..<width {
                let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                let nx = p.x / Double(width), ny = p.y / Double(height)
                var rgb: [UInt8] = [UInt8(216 + (x * 7 + y * 3) % 13),
                                    UInt8(178 + (x * 5 + y * 11) % 17), UInt8(150 + (x + y * 3) % 13)]
                for path in paths where distance(p, to: path) <= halfThickness {
                    let texture = UInt8(28 + (x * 31 + y * 17) % 38)
                    rgb = [texture, texture, texture]
                    for (channel, index) in [(0, 0), (1, 2), (2, 4)] {
                        let marker = path[index]
                        if hypot(p.x - marker.x, p.y - marker.y) <= 2.3 {
                            rgb = [12, 12, 12]; rgb[channel] = 72
                        }
                    }
                }
                if (0.27...0.73).contains(nx), (0.47...0.51).contains(ny) {
                    rgb = [UInt8(25 + (x * 13 + y * 23) % 39), 96, 178]
                }
                if (0.46...0.54).contains(nx), (0.55...0.63).contains(ny) { rgb = [175, UInt8(93 + (x + y) % 31), 64] }
                if (0.40...0.60).contains(nx), (0.69...0.73).contains(ny) { rgb = [154, 44, UInt8(57 + (x * 3 + y) % 27)] }
                let i = (y * width + x) * 4
                for channel in 0..<3 { output[i + channel] = rgb[channel] }
            } }
            return output
        }

        func marker(_ source: [UInt8], side: Int, channel: Int) throws -> SIMD2<Double> {
            var mass = 0.0, moment = SIMD2<Double>.zero
            let expected = trace(side)[channel == 0 ? 0 : channel == 1 ? 2 : 4]
            // Independent cap travel plus marker radius, fixed from the source.
            let radius = 18.0
            for y in max(0, Int(expected.y-radius))..<min(height, Int(ceil(expected.y+radius))) {
                for x in max(0, Int(expected.x-radius))..<min(width, Int(ceil(expected.x+radius))) {
                    let i = (y * width + x) * 4
                    guard max(source[i], source[i + 1], source[i + 2]) < 120 else { continue }
                    let others = (0..<3).filter { $0 != channel }.map { Double(source[i + $0]) }
                    // Gray hair and brown skin interpolation are not the source's
                    // deliberately isolated 60-channel chromatic marker.
                    let weight = max(0, Double(source[i + channel]) - others.max()! - 35)
                    mass += weight
                    moment += SIMD2(Double(x) + 0.5, Double(y) + 0.5) * weight
                }
            }
            guard mass > 1 else { throw MarkerError.missing }
            return moment / mass
        }

        func darknessArea(_ source: [UInt8], side: Int) -> Double {
            var area = 0.0
            for y in Int(0.28 * Double(height))..<Int(0.45 * Double(height)) {
                let columns = side == 0 ? Int(0.26 * Double(width))..<width / 2 : width / 2..<Int(0.74 * Double(width))
                for x in columns {
                    let i = (y * width + x) * 4
                    let luma = 0.299 * Double(source[i]) + 0.587 * Double(source[i + 1]) + 0.114 * Double(source[i + 2])
                    area += max(0, 110 - luma) / 110
                }
            }
            return area
        }

        private enum MarkerError: Error { case missing }

        private func distance(_ p: SIMD2<Double>, to path: [SIMD2<Double>]) -> Double {
            zip(path, path.dropFirst()).map { a, b in
                let v = b - a, d = p - a
                let length = v.x * v.x + v.y * v.y
                let t = min(1, max(0, (d.x * v.x + d.y * v.y) / length))
                let offset = d - v * t
                return hypot(offset.x, offset.y)
            }.min()!
        }

        func image() -> CIImage {
            CIImage(bitmapData: Data(raster()), bytesPerRow: width * 4,
                    size: CGSize(width: width, height: height), format: .RGBA8,
                    colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
        }

        func bytes(_ image: CIImage) -> [UInt8] {
            let color = CGColorSpace(name: CGColorSpace.sRGB)!
            let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
            var output = [UInt8](repeating: 0, count: width * height * 4)
            output.withUnsafeMutableBytes { raw in
                context.render(image, toBitmap: raw.baseAddress!, rowBytes: width * 4,
                               bounds: image.extent, format: .RGBA8, colorSpace: color)
            }
            return output
        }
    }
}
