import BeautyCore
import BeautyDetection
@testable import BeautyEffects
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@testable import BeautySDK

/// Independent source-defined lip silhouette and landmark registration. These
/// checks measure materialized public-facade pixels, not the displacement map
/// or the number of changed pixels. They do not claim photographic parity.
final class BeautyEngineMouthReferenceTests: XCTestCase {
    private typealias Field = (String, WritableKeyPath<BeautyParameters, Float>, Float)
    private let fields: [Field] = [
        ("size", \.mouthSize, BeautySafetyCaps.mouthSize),
        ("width", \.mouthWidth, BeautySafetyCaps.mouthWidth),
        ("smile", \.smile, BeautySafetyCaps.smile),
        ("vertical", \.mouthYPosition, BeautySafetyCaps.mouthYPosition),
        ("tilt", \.mouthTilt, BeautySafetyCaps.mouthTilt),
        ("horizontal", \.mouthXPosition, BeautySafetyCaps.mouthXPosition),
        ("bow", \.lipPeakDefinition, BeautySafetyCaps.lipPeakDefinition),
        ("thickness", \.lipPlump, BeautySafetyCaps.lipPlump)
    ]
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    func testSizeChangesBothVisibleDimensionsAndWidthChangesOnlyWidthAtFourSignedSteps() throws {
        let fixture = Fixture()
        let source = fixture.raster()
        let baseline = try fixture.shape(source)
        for field in fields.prefix(2) {
            for sign: Float in [-1, 1] {
                var previousWidth = 0.0, previousHeight = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    let output = try render(fixture, field: field, value: sign * fraction)
                    let measured = try fixture.shape(output.bytes)
                    let widthChange = (measured.width - baseline.width) * Double(sign)
                    XCTAssertGreaterThan(widthChange, previousWidth + 0.1, field.0)
                    previousWidth = widthChange
                    if field.0 == "size" {
                        let heightChange = (measured.height - baseline.height) * Double(sign)
                        XCTAssertGreaterThan(heightChange, previousHeight + 0.05)
                        previousHeight = heightChange
                    } else {
                        XCTAssertEqual(measured.height, baseline.height, accuracy: 0.5,
                                       "width must not become a second mouth-size control")
                    }
                    assertProtected(source, output.bytes, fixture: fixture)
                }
                XCTAssertGreaterThan(previousWidth, baseline.width * 0.035)
                if field.0 == "size" { XCTAssertGreaterThan(previousHeight, baseline.height * 0.025) }
            }
        }
    }

    func testPositionsMoveWholeMouthWithoutStretchingAtFourSignedSteps() throws {
        let fixture = Fixture()
        let baseline = try fixture.cornerGeometry(fixture.raster())
        for field in fields.filter({ $0.0 == "vertical" || $0.0 == "horizontal" }) {
            for sign: Float in [-1, 1] {
                var previous = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    let output = try render(fixture, field: field, value: sign * fraction)
                    let value = try fixture.cornerGeometry(output.bytes)
                    let delta = value.center - baseline.center
                    let directed = (field.0 == "horizontal" ? delta.x : delta.y) * Double(sign)
                    XCTAssertGreaterThan(directed, previous + 0.1, field.0)
                    previous = directed
                    XCTAssertEqual(value.span, baseline.span, accuracy: 0.45, field.0)
                    XCTAssertEqual(field.0 == "horizontal" ? delta.y : delta.x, 0, accuracy: 0.3)
                }
                XCTAssertGreaterThan(previous, 2)
            }
        }
    }

    func testTiltRotatesInPixelsAtBothImageAspectsAndFourSignedSteps() throws {
        let field = fields[4]
        for fixture in [Fixture(), Fixture(width: 640, height: 480)] {
            let baseline = try fixture.cornerGeometry(fixture.raster())
            for sign: Float in [-1, 1] {
                var previous = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    let output = try render(fixture, field: field, value: sign * fraction)
                    let current = try fixture.cornerGeometry(output.bytes)
                    let angle = (current.angle - baseline.angle) * Double(sign)
                    XCTAssertGreaterThan(angle, previous + 0.002)
                    previous = angle
                    XCTAssertEqual(current.span, baseline.span, accuracy: 0.6,
                                   "pixel rotation must preserve corner distance on rectangular input")
                    XCTAssertEqual(current.center.x, baseline.center.x, accuracy: 0.4)
                    XCTAssertEqual(current.center.y, baseline.center.y, accuracy: 0.4)
                }
                XCTAssertGreaterThan(previous, 0.025)
            }
        }
    }

    func testSmileRaisesOrLowersBothCornersWithoutTranslatingCenter() throws {
        let fixture = Fixture()
        let source = fixture.raster()
        let left = try fixture.marker(source, .left), right = try fixture.marker(source, .right)
        let center = try fixture.marker(source, .upperCenter)
        for sign: Float in [-1, 1] {
            var previousLeft = 0.0, previousRight = 0.0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = try render(fixture, field: fields[2], value: sign * fraction)
                let a = try fixture.marker(output.bytes, .left), b = try fixture.marker(output.bytes, .right)
                let da = (left.y - a.y) * Double(sign), db = (right.y - b.y) * Double(sign)
                XCTAssertGreaterThan(da, previousLeft + 0.08)
                XCTAssertGreaterThan(db, previousRight + 0.08)
                previousLeft = da; previousRight = db
                XCTAssertEqual(da, db, accuracy: 0.35)
                XCTAssertEqual(try fixture.marker(output.bytes, .upperCenter).y, center.y, accuracy: 0.35)
            }
            XCTAssertGreaterThan(previousLeft, 1)
            XCTAssertGreaterThan(previousRight, 1)
        }
    }

    func testCupidBowChangesPeakToCenterDifferenceAndKeepsOralPixelsExact() throws {
        let fixture = Fixture()
        let source = fixture.raster()
        let baseline = try fixture.bowDepth(source)
        XCTAssertGreaterThan(baseline, 1, "negative bow needs a source with a visible Cupid's bow")
        for sign: Float in [-1, 1] {
            var previous = 0.0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = try render(fixture, field: fields[6], value: sign * fraction)
                let amount = (try fixture.bowDepth(output.bytes) - baseline) * Double(sign)
                XCTAssertGreaterThan(amount, previous + 0.015)
                previous = amount
                assertOralExact(source, output.bytes, fixture: fixture)
                assertProtected(source, output.bytes, fixture: fixture)
            }
            XCTAssertGreaterThan(previous, 0.25)
        }
    }

    func testPlumpChangesOuterLipThicknessAtBothSignsWithoutOpeningMouth() throws {
        let fixture = Fixture()
        let source = fixture.raster()
        let baseline = try fixture.shape(source)
        for sign: Float in [-1, 1] {
            var previous = 0.0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = try render(fixture, field: fields[7], value: sign * fraction)
                let current = try fixture.shape(output.bytes)
                let amount = (current.height - baseline.height) * Double(sign)
                XCTAssertGreaterThan(amount, previous + 0.03)
                previous = amount
                XCTAssertEqual(current.width, baseline.width, accuracy: 0.45)
                assertOralExact(source, output.bytes, fixture: fixture)
            }
            XCTAssertGreaterThan(previous, 1)
        }
    }

    func testNeutralRepeatsCombinedProtectionAndTypedNoFaceRecovery() throws {
        let fixture = Fixture()
        let source = fixture.raster(), image = fixture.image()
        let engine = try makeEngine(fixture)
        let neutral = try engine.processResult(image: image, metadata: metadata, parameters: .init())
        XCTAssertEqual(fixture.bytes(neutral.output), source)
        var combined = BeautyParameters()
        for (_, key, cap) in fields { combined[keyPath: key] = cap * 0.25 }
        let first = try engine.processResult(image: image, metadata: metadata, parameters: combined)
        let repeated = try engine.processResult(image: image, metadata: metadata, parameters: combined)
        let actual = fixture.bytes(first.output)
        XCTAssertEqual(actual, fixture.bytes(repeated.output))
        XCTAssertEqual(first.metrics, repeated.metrics)
        XCTAssertEqual(first.warnings, repeated.warnings)
        assertProtected(source, actual, fixture: fixture)
        XCTAssertEqual(fixture.bytes(try engine.processResult(image: image, metadata: metadata,
            parameters: .init()).output), source)
        let probe = SequenceProbe([fixture.observation(), nil, fixture.observation()])
        let recovering = try BeautyEngine(faceDetector: probe.detector())
        let valid = try recovering.processResult(image: image, metadata: metadata, parameters: combined)
        recovering.reset()
        let missing = try recovering.processResult(image: image, metadata: metadata, parameters: combined)
        recovering.reset()
        let recovered = try recovering.processResult(image: image, metadata: metadata, parameters: combined)
        XCTAssertEqual(fixture.bytes(missing.output), source)
        XCTAssertEqual(missing.detectionSummary?.availability, .noFace)
        XCTAssertTrue(missing.detectionSummary?.reasons.contains(.noFaceDetected) == true)
        XCTAssertEqual(missing.detectionSummary?.usedFaceCount, 0)
        XCTAssertEqual(fixture.bytes(valid.output), fixture.bytes(recovered.output))
        XCTAssertEqual(probe.calls, 3)
        for result in [neutral, first, repeated, missing, recovered] { assertMetadata(result, fixture: fixture) }
    }

    func testMissingInnerSupportAbstainsOnlyForBowAndPlump() throws {
        let fixture = Fixture()
        let source = fixture.raster()
        for field in fields.suffix(2) {
            for sign: Float in [-1, 1] {
                let result = try render(fixture, field: field, value: sign, inner: false)
                XCTAssertEqual(result.bytes, source, field.0)
                XCTAssertEqual(result.result.metrics["beauty.effects.activeCount"], 0)
            }
        }
        let validPosition = try render(fixture, field: fields[5], value: 1, inner: false)
        let original = try fixture.cornerGeometry(source)
        XCTAssertGreaterThan(try fixture.cornerGeometry(validPosition.bytes).center.x, original.center.x + 2)
        for field in fields {
            let result = try render(fixture, field: field, value: 1, outer: false)
            XCTAssertEqual(result.bytes, source, field.0)
        }
    }

    func testAvailableMetalActuallyExecutesAndMatchesAllSignedEndpoints() throws {
        let fixture = Fixture(width: 320, height: 400)
        let counter = InvocationCounter()
        let metal: BeautyMetalBackend
        do { metal = try BeautyMetalBackend(hooks: .init(onRuntimeInvocation: { counter.increment() })) }
        catch BeautyError.metalUnavailable { throw XCTSkip("Metal unavailable; no executed parity claim") }
        let engine = try makeEngine(fixture, metal: metal)
        for field in fields {
            for sign: Float in [-1, 1] {
                var parameters = BeautyParameters(); parameters[keyPath: field.1] = field.2 * sign
                let cpu = try render(fixture, field: field, value: sign)
                let gpu = try engine.processResult(image: fixture.image(), metadata: metadata, parameters: parameters)
                let bytes = fixture.bytes(gpu.output)
                let error = zip(cpu.bytes, bytes).map { abs(Int($0) - Int($1)) }.max() ?? 0
                XCTAssertLessThanOrEqual(error, 2, field.0)
                XCTAssertEqual(bytes, fixture.bytes(try engine.processResult(image: fixture.image(),
                    metadata: metadata, parameters: parameters).output))
                XCTAssertEqual(gpu.output.colorSpace?.name, CGColorSpace.sRGB)
            }
        }
        XCTAssertEqual(counter.value, 32, "must execute the Metal runtime, including repeats")
    }

    func testAlphaExtentAndInvalidInputKeepDeclaredFacadeContracts() throws {
        let fixture = Fixture(width: 320, height: 400)
        let opaque = fixture.raster()
        var translucent = opaque
        for i in stride(from: 0, to: translucent.count, by: 4) {
            for channel in 0..<3 { translucent[i + channel] /= 2 }
            translucent[i + 3] = 173
        }
        let image = fixture.image(translucent).transformed(by: CGAffineTransform(translationX: 13, y: -7))
        let engine = try makeEngine(fixture)
        let result = try engine.processResult(image: image, metadata: metadata, parameters: .init(mouthSize: 0.25))
        XCTAssertEqual(result.output.extent, image.extent)
        let bytes = fixture.bytes(result.output)
        XCTAssertTrue(stride(from: 3, to: bytes.count, by: 4).allSatisfy { bytes[$0] == 173 })
        XCTAssertThrowsError(try engine.processResult(image: CIImage.empty(), metadata: metadata,
            parameters: .init(mouthSize: 0.25))) { XCTAssertEqual($0 as? BeautyError, .invalidInput) }
        let counter = InvocationCounter()
        let detector = VisionFaceDetector(observationProvider: { _ in counter.increment(); return [fixture.observation()] })
        let limited = try BeautyEngine(configuration: .init(maximumInputPixelCount: 100), faceDetector: detector)
        XCTAssertThrowsError(try limited.processResult(image: fixture.image(), metadata: metadata,
            parameters: .init(mouthSize: 0.25))) { XCTAssertEqual($0 as? BeautyError, .invalidInput) }
        XCTAssertEqual(counter.value, 0)
    }

    func testCanonicalPublicRoutePreservesMouthDirectionAcrossEXIFAndMirrors() throws {
        let fixture = Fixture(width: 320, height: 400)
        let original = fixture.image()
        // An empty public exclusion mask selects the existing canonical still
        // route without protecting or altering any source pixel.
        let mask = try BeautyTextureExclusionMask(width: fixture.width, height: fixture.height,
            bytes: [UInt8](repeating: 0, count: fixture.width * fixture.height))
        let parameters = BeautyParameters(mouthWidth: -0.25)
        let engine = try makeEngine(fixture)
        let baseline = try engine.processResult(image: original, metadata: metadata,
            parameters: parameters, textureExclusionMask: mask)
        let expected = fixture.bytes(baseline.output)
        XCTAssertLessThan(try fixture.shape(expected).width, try fixture.shape(fixture.raster()).width - 1)
        let orientations: [(CGImagePropertyOrientation, CGImagePropertyOrientation)] = [
            (.up, .up), (.upMirrored, .upMirrored), (.down, .down), (.downMirrored, .downMirrored),
            (.leftMirrored, .leftMirrored), (.right, .left), (.rightMirrored, .rightMirrored), (.left, .right)
        ]
        for (orientation, inverse) in orientations {
            for mirrored in [false, true] {
                let canonical = mirrored ? original.oriented(.upMirrored) : original
                let encoded = canonical.oriented(inverse)
                let requestMetadata = BeautyInputMetadata(orientation: orientation,
                    isInputMirrored: mirrored, isPreviewMirrored: true, source: .testFixture)
                let result = try engine.processResult(image: encoded, metadata: requestMetadata,
                    parameters: parameters, textureExclusionMask: mask)
                XCTAssertEqual(result.output.extent, original.extent)
                XCTAssertEqual(result.output.colorSpace?.name, CGColorSpace.sRGB)
                XCTAssertEqual(fixture.bytes(result.output), expected,
                               "EXIF \(orientation.rawValue), mirrored \(mirrored)")
            }
        }
    }

    private func makeEngine(_ fixture: Fixture, inner: Bool = true, outer: Bool = true,
                            metal: BeautyMetalBackend? = nil) throws -> BeautyEngine {
        let observation = fixture.observation(inner: inner, outer: outer)
        let detector = VisionFaceDetector(observationProvider: { _ in [observation] })
        if let metal {
            return try BeautyEngine(configuration: .init(renderBackend: .gpu), faceDetector: detector,
                                    backendExecutor: metal)
        }
        return try BeautyEngine(faceDetector: detector)
    }

    private func render(_ fixture: Fixture, field: Field, value: Float, inner: Bool = true,
                        outer: Bool = true) throws -> (bytes: [UInt8], result: BeautyResult<CIImage>) {
        var parameters = BeautyParameters(); parameters[keyPath: field.1] = field.2 * value
        let result = try makeEngine(fixture, inner: inner, outer: outer).processResult(
            image: fixture.image(), metadata: metadata, parameters: parameters)
        assertMetadata(result, fixture: fixture)
        return (fixture.bytes(result.output), result)
    }

    private func assertMetadata(_ result: BeautyResult<CIImage>, fixture: Fixture,
                                file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(result.output.extent, CGRect(x: 0, y: 0, width: fixture.width, height: fixture.height), file: file, line: line)
        XCTAssertEqual(result.output.colorSpace?.model, .rgb, file: file, line: line)
        XCTAssertTrue(result.metrics.values.allSatisfy(\.isFinite), file: file, line: line)
        let text = (result.warnings.map { $0.code + " " + $0.message } + Array(result.metrics.keys)).joined(separator: " ").lowercased()
        XCTAssertFalse(["landmark", "coordinate", "transcript", "/private/", "file://", "raw pixels"].contains(where: text.contains), file: file, line: line)
    }

    private func assertProtected(_ source: [UInt8], _ output: [UInt8], fixture: Fixture,
                                 file: StaticString = #filePath, line: UInt = #line) {
        var upper = 0, lower = 0, lateral = 0, alpha = 0
        for y in 0..<fixture.height { for x in 0..<fixture.width {
            let nx = Double(x) / Double(fixture.width), ny = Double(y) / Double(fixture.height)
            let i = (y * fixture.width + x) * 4
            if source[i..<(i + 4)] != output[i..<(i + 4)] {
                if ny < 0.56 { upper += 1 }
                if ny > 0.87 { lower += 1 }
                if nx < 0.12 || nx > 0.88 { lateral += 1 }
            }
            if source[i + 3] != output[i + 3] { alpha += 1 }
        } }
        XCTAssertTrue(upper + lower + lateral + alpha == 0,
                      "protected differences: upper=\(upper), lower=\(lower), lateral=\(lateral), alpha=\(alpha)",
                      file: file, line: line)
    }

    private func assertOralExact(_ source: [UInt8], _ output: [UInt8], fixture: Fixture,
                                file: StaticString = #filePath, line: UInt = #line) {
        var exact = true
        for y in 0..<fixture.height { for x in 0..<fixture.width {
            let p = SIMD2((Double(x) + 0.5) / Double(fixture.width), (Double(y) + 0.5) / Double(fixture.height))
            if pow((p.x - 0.5) / 0.112, 2) + pow((p.y - 0.7) / 0.009, 2) <= 1 {
                let i = (y * fixture.width + x) * 4
                if source[i..<(i + 4)] != output[i..<(i + 4)] { exact = false }
            }
        } }
        XCTAssertTrue(exact, "the inner opening and teeth texture must remain exact", file: file, line: line)
    }

    private final class InvocationCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var count = 0
        var value: Int { lock.lock(); defer { lock.unlock() }; return count }
        func increment() { lock.lock(); count += 1; lock.unlock() }
    }

    private final class SequenceProbe: @unchecked Sendable {
        private let lock = NSLock()
        private let observations: [VisionDetectionObservation?]
        private(set) var calls = 0
        init(_ observations: [VisionDetectionObservation?]) { self.observations = observations }
        func detector() -> VisionFaceDetector {
            VisionFaceDetector(observationProvider: { [self] _ in
                lock.lock(); defer { lock.unlock() }
                let selected = observations[min(calls, observations.count - 1)]
                calls += 1
                return selected.map { [$0] } ?? []
            })
        }
    }

    private struct Fixture: Sendable {
        let width: Int, height: Int
        private var source: [UInt8] = []
        init(width: Int = 480, height: Int = 640) {
            self.width = width; self.height = height
            source = makeRaster()
        }
        enum Mark: CaseIterable { case left, right, upperLeft, upperRight, upperCenter, lowerCenter }
        func upper(_ x: Double) -> Double {
            let t = (x - 0.5) / 0.14
            return 0.7 - 0.037 * sqrt(max(0, 1 - t * t)) + 0.013 * exp(-t * t / 0.035)
        }
        func center(_ mark: Mark) -> SIMD2<Double> {
            switch mark {
            case .left: return SIMD2(0.371, 0.7)
            case .right: return SIMD2(0.629, 0.7)
            case .upperLeft: return SIMD2(0.4608, upper(0.4608) + 0.003)
            case .upperRight: return SIMD2(0.5392, upper(0.5392) + 0.003)
            case .upperCenter: return SIMD2(0.5, upper(0.5) + 0.003)
            case .lowerCenter: return SIMD2(0.5, 0.731)
            }
        }
        func observation(inner: Bool = true, outer: Bool = true) -> VisionDetectionObservation {
            let bounds = CoordinateRect(x: 0.10, y: 0.06, width: 0.80, height: 0.88)
            func raw(_ p: SIMD2<Double>) -> CoordinatePoint {
                CoordinatePoint(x: (p.x - bounds.x) / bounds.width,
                                y: (1 - p.y - bounds.y) / bounds.height)
            }
            let outside = (0..<32).map { i -> SIMD2<Double> in
                let angle = .pi + Double(i) * 2 * .pi / 32
                let x = 0.5 + 0.14 * cos(angle)
                return SIMD2(x, sin(angle) < 0 ? upper(x) : 0.7 + 0.035 * sin(angle))
            }
            let opening = (0..<20).map { i -> SIMD2<Double> in
                let angle = Double(i) * 2 * .pi / 20
                return SIMD2(0.5 + 0.112 * cos(angle), 0.7 + 0.009 * sin(angle))
            }
            func eye(_ cx: Double, _ side: BeautyObservedEyeSide) -> BeautyObservedEyeSupport {
                BeautyObservedEyeSupport(side: side, contour: (0..<12).map { i in
                    let angle = Double(i) * 2 * .pi / 12
                    return raw(SIMD2(cx + 0.06 * cos(angle), 0.36 + 0.025 * sin(angle)))
                })
            }
            return VisionDetectionObservation(confidence: 0.98, visionBounds: bounds,
                observedEyeSupport: [eye(0.35, .left), eye(0.65, .right)],
                observedLipSupport: BeautyObservedLipSupport(outer: outer ? outside.map(raw) : [],
                                                            inner: inner ? opening.map(raw) : []),
                observedNoseSupport: BeautyObservedNoseSupport(
                    crest: [SIMD2(0.5, 0.43), SIMD2(0.5, 0.49), SIMD2(0.5, 0.55)].map(raw),
                    contour: [SIMD2(0.445, 0.53), SIMD2(0.46, 0.56), SIMD2(0.5, 0.565),
                              SIMD2(0.54, 0.56), SIMD2(0.555, 0.53)].map(raw)))
        }
        func raster() -> [UInt8] {
            source
        }
        private func makeRaster() -> [UInt8] {
            var bytes = [UInt8](repeating: 255, count: width * height * 4)
            let markers = Mark.allCases.map { center($0) * SIMD2(Double(width), Double(height)) }
            let taggedNoncornerMarkers = Mark.allCases.filter { $0 != .left && $0 != .right }
                .map { center($0) * SIMD2(Double(width), Double(height)) }
            for y in 0..<height { for x in 0..<width {
                let px = Double(x) + 0.5, py = Double(y) + 0.5
                let nx = px / Double(width), ny = py / Double(height)
                let t = (nx - 0.5) / 0.14
                let lower = 0.7 + 0.035 * sqrt(max(0, 1 - t * t))
                var color: [UInt8] = [UInt8(218 + (x + y) % 7), UInt8(182 + (x * 3 + y) % 11), 155]
                if abs(t) <= 1 && ny >= upper(nx) && ny <= lower { color = [190, 55, 85] }
                if pow((nx - 0.5) / 0.112, 2) + pow((ny - 0.7) / 0.009, 2) <= 1 {
                    color = [UInt8(220 + (x / 3 + y) % 22), UInt8(205 + (x + y / 2) % 29), 198]
                }
                if markers.contains(where: { hypot(px - $0.x, py - $0.y) <= 2.2 }) { color = [12, 12, 12] }
                // Source identity only: retain every original red/green marker value.
                if taggedNoncornerMarkers.contains(where: { hypot(px - $0.x, py - $0.y) <= 2.2 }) {
                    color[2] = 255
                }
                let i = (y * width + x) * 4
                bytes[i] = color[0]; bytes[i + 1] = color[1]; bytes[i + 2] = color[2]
            } }
            return bytes
        }
        func image(_ bytes: [UInt8]? = nil) -> CIImage {
            CIImage(bitmapData: Data(bytes ?? raster()), bytesPerRow: width * 4,
                    size: CGSize(width: width, height: height), format: .RGBA8,
                    colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
        }
        func bytes(_ image: CIImage) -> [UInt8] {
            var output = [UInt8](repeating: 0, count: width * height * 4)
            let color = CGColorSpace(name: CGColorSpace.sRGB)!
            let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color, .cacheIntermediates: false])
            output.withUnsafeMutableBytes { data in
                context.render(image, toBitmap: data.baseAddress!, rowBytes: width * 4,
                               bounds: image.extent, format: .RGBA8, colorSpace: color)
            }
            return output
        }
        func marker(_ bytes: [UInt8], _ mark: Mark) throws -> SIMD2<Double> {
            let p = center(mark) * SIMD2(Double(width), Double(height))
            let radius = (mark == .left || mark == .right) ? 24 : 9
            var weight = 0.0, sum = SIMD2<Double>.zero
            for y in max(0, Int(p.y) - radius)...min(height - 1, Int(p.y) + radius) {
                for x in max(0, Int(p.x) - radius)...min(width - 1, Int(p.x) + radius) {
                    let w = Double(max(0, 120 - Int(bytes[(y * width + x) * 4])))
                    // B <= R is the source-derived corner label half-space.
                    // It does not change the original R120 weight or ROI.
                    if (mark == .left || mark == .right),
                       bytes[(y * width + x) * 4 + 2] > bytes[(y * width + x) * 4] { continue }
                    sum += SIMD2(Double(x) + 0.5, Double(y) + 0.5) * w; weight += w
                }
            }
            XCTAssertGreaterThan(weight, 50, "semantic source marker disappeared")
            guard weight > 0 else { throw BeautyError.invalidInput }
            return sum / weight
        }
        func cornerGeometry(_ bytes: [UInt8]) throws -> (center: SIMD2<Double>, span: Double, angle: Double) {
            let a = try marker(bytes, .left), b = try marker(bytes, .right), v = b - a
            return ((a + b) * 0.5, hypot(v.x, v.y), atan2(v.y, v.x))
        }
        func bowDepth(_ bytes: [UInt8]) throws -> Double {
            try marker(bytes, .upperCenter).y - (marker(bytes, .upperLeft).y + marker(bytes, .upperRight).y) * 0.5
        }
        func shape(_ bytes: [UInt8]) throws -> (width: Double, height: Double) {
            // Recover the red silhouette through linearly interpolated color
            // boundaries. Black fiducials are excluded from the edge scan.
            func red(_ x: Int, _ y: Int) -> Double {
                let i = (y * width + x) * 4
                return Double(Int(bytes[i]) - Int(bytes[i + 1]))
            }
            var left = Double.infinity, right = -Double.infinity
            var top = Double.infinity, bottom = -Double.infinity
            for y in Int(Double(height) * 0.64)..<Int(Double(height) * 0.77) {
                for x in Int(Double(width) * 0.31)..<Int(Double(width) * 0.69) {
                    let a = red(x, y), bx = red(x + 1, y), by = red(x, y + 1)
                    if (a < 90 && bx >= 90) || (a >= 90 && bx < 90) {
                        let edge = Double(x) + 0.5 + (90 - a) / (bx - a)
                        left = min(left, edge); right = max(right, edge)
                    }
                    if (a < 90 && by >= 90) || (a >= 90 && by < 90) {
                        let edge = Double(y) + 0.5 + (90 - a) / (by - a)
                        top = min(top, edge); bottom = max(bottom, edge)
                    }
                }
            }
            XCTAssertTrue(left.isFinite && right.isFinite && top.isFinite && bottom.isFinite)
            return (right - left, bottom - top)
        }
    }
}
