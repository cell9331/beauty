import BeautyCore
import BeautyDetection
import BeautyEffects
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautySDK

/// Source-defined analytic marks exercise the public facade and actual backends.
/// Injected observations are deterministic carriers, not native model evidence.
final class BeautyEngineEyeSliderTests: XCTestCase {
    private let width = 480, height = 400
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

    private struct Probe {
        let slider: BeautyEyeShapeSlider
        let field: WritableKeyPath<BeautyParameters, Float>
        let cap: Float
        let mark: SIMD2<Double>
        let direction: SIMD2<Double>
        let control: SIMD2<Double>
        /// Zero means the independent control mark must remain stationary.
        let controlDirection: SIMD2<Double>
    }

    private var probes: [Probe] {
        [
            Probe(slider: .eyeSize, field: \.eyeSize, cap: 0.45,
                  mark: SIMD2(0.41, 0.40), direction: SIMD2(1, 0),
                  control: SIMD2(0.36, 0.376), controlDirection: SIMD2(0, -1)),
            Probe(slider: .verticalPosition, field: \.eyeYPosition, cap: 0.25,
                  mark: SIMD2(0.36, 0.40), direction: SIMD2(0, 1),
                  control: SIMD2(0.36, 0.40), controlDirection: SIMD2(0, 1)),
            Probe(slider: .height, field: \.eyeHeight, cap: 0.35,
                  mark: SIMD2(0.36, 0.376), direction: SIMD2(0, -1),
                  control: SIMD2(0.425, 0.40), controlDirection: .zero),
            Probe(slider: .length, field: \.eyeLength, cap: 0.35,
                  mark: SIMD2(0.415, 0.40), direction: SIMD2(1, 0),
                  control: SIMD2(0.36, 0.376), controlDirection: .zero),
            Probe(slider: .spacing, field: \.eyeDistance, cap: 0.30,
                  mark: SIMD2(0.36, 0.40), direction: SIMD2(-1, 0),
                  control: SIMD2(0.36, 0.40), controlDirection: SIMD2(-1, 0)),
            Probe(slider: .irisSize, field: \.pupilSize, cap: 0.25,
                  mark: SIMD2(0.373, 0.40), direction: SIMD2(1, 0),
                  control: SIMD2(0.295, 0.40), controlDirection: .zero),
            Probe(slider: .lowerEyelid, field: \.lowerEyelidDrop, cap: 0.30,
                  mark: SIMD2(0.325, 0.42), direction: SIMD2(0, 1),
                  control: SIMD2(0.40, 0.42), controlDirection: .zero),
            Probe(slider: .outerTail, field: \.eyeTailLift, cap: 0.30,
                  mark: SIMD2(0.295, 0.40), direction: SIMD2(0, -1),
                  control: SIMD2(0.425, 0.40), controlDirection: .zero),
            // The reference slider reverses the direct API's tilt polarity.
            Probe(slider: .tilt, field: \.eyeTilt, cap: 0.25,
                  mark: SIMD2(0.295, 0.40), direction: SIMD2(0, 1),
                  control: SIMD2(0.425, 0.40), controlDirection: SIMD2(0, -1)),
            Probe(slider: .innerCorner, field: \.innerCornerOpen, cap: 0.25,
                  mark: SIMD2(0.425, 0.40), direction: SIMD2(1, 0),
                  control: SIMD2(0.295, 0.40), controlDirection: .zero),
            Probe(slider: .outerCorner, field: \.outerCornerOpen, cap: 0.25,
                  mark: SIMD2(0.295, 0.40), direction: SIMD2(-1, 0),
                  control: SIMD2(0.425, 0.40), controlDirection: .zero)
        ]
    }

    private func observation(dense: Bool = true) throws -> BeautyFaceObservation {
        func ellipse(_ x: Double, _ y: Double, _ rx: Double, _ ry: Double, count: Int = 16) -> [CoordinatePoint] {
            (0..<count).map { i in
                let a = Double(i) * 2 * .pi / Double(count)
                return CoordinatePoint(x: x + rx * cos(a), y: y + ry * sin(a))
            }
        }
        var points = Array(repeating: SIMD3<Float>(0.5, 0.5, 0), count: 478)
        for (indices, x) in [(MediaPipeFaceTopology.leftIris, Float(0.36)),
                             (MediaPipeFaceTopology.rightIris, Float(0.64))] {
            for (i, index) in indices.enumerated() {
                let a = Float(i) * 2 * .pi / Float(indices.count)
                points[index] = SIMD3(x + 0.017 * cos(a),
                    0.4 + 0.017 * Float(width) / Float(height) * sin(a), 0)
            }
        }
        points[468] = SIMD3(0.36, 0.4, 0)
        points[473] = SIMD3(0.64, 0.4, 0)
        let mesh = dense ? try XCTUnwrap(BeautyFaceMesh(points: points)) : nil
        return BeautyFaceObservation(stableID: "analytic-eyes", confidence: 1,
            imageBounds: CoordinateRect(x: 0.16, y: 0.14, width: 0.68, height: 0.70),
            observedEyeSupport: [
                BeautyObservedEyeSupport(side: .left, contour: ellipse(0.36, 0.4, 0.07, 0.025),
                    pupil: [CoordinatePoint(x: 0.36, y: 0.4)]),
                BeautyObservedEyeSupport(side: .right, contour: ellipse(0.64, 0.4, 0.07, 0.025),
                    pupil: [CoordinatePoint(x: 0.64, y: 0.4)])
            ], observedEyeOrder: .canonical,
            observedFaceSupport: BeautyObservedFaceSupport(contour: ellipse(0.5, 0.5, 0.30, 0.36),
                medianLine: [CoordinatePoint(x: 0.5, y: 0.3), CoordinatePoint(x: 0.5, y: 0.8)]),
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                // The public adapter requires at least four observed points.
                // Preserve the same source-defined envelope with an admissible trace.
                left: [CoordinatePoint(x: 0.28, y: 0.335), CoordinatePoint(x: 0.32, y: 0.325),
                       CoordinatePoint(x: 0.36, y: 0.32), CoordinatePoint(x: 0.40, y: 0.325), CoordinatePoint(x: 0.44, y: 0.335)],
                right: [CoordinatePoint(x: 0.56, y: 0.335), CoordinatePoint(x: 0.60, y: 0.325),
                        CoordinatePoint(x: 0.64, y: 0.32), CoordinatePoint(x: 0.68, y: 0.325), CoordinatePoint(x: 0.72, y: 0.335)]),
            observedLipSupport: BeautyObservedLipSupport(outer: ellipse(0.5, 0.63, 0.07, 0.025)),
            mesh: mesh)
    }

    private func engine(gpu: Bool = false, noFace: Bool = false, dense: Bool = true) throws -> BeautyEngine {
        let observations = noFace ? [] : [try observation(dense: dense)]
        let detector = BeautyFaceDetector(mappedObservationProvider: { _ in
            BeautyMappedFaceObservations(observations: observations)
        })
        let executor: BeautyBackendExecutor = gpu ? try BeautyMetalBackend() : BeautyCPUBackend()
        return try BeautyEngine(configuration: .init(renderBackend: gpu ? .gpu : .cpu),
            faceDetector: detector, backendExecutor: executor)
    }

    private func image(_ probe: Probe) -> CIImage {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let point = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let i = (y * width + x) * 4
            for (channel, mark) in [probe.mark, probe.control].enumerated() {
                let marks = [mark, SIMD2(1 - mark.x, mark.y)]
                let distance = marks.map { m -> Double in
                    let delta = point - SIMD2(m.x * Double(width), m.y * Double(height))
                    return delta.x * delta.x + delta.y * delta.y
                }.min()!
                bytes[i + channel] = UInt8((160 - 120 * exp(-distance / 5)).rounded())
            }
            // Spatial detail makes unintended exterior resampling observable.
            bytes[i + 2] = UInt8(30 + x * 120 / width + y * 60 / height)
        } }
        return CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: colorSpace)
    }

    private func pixels(_ image: CIImage) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace]).render(
            image, toBitmap: &bytes, rowBytes: width * 4, bounds: image.extent,
            format: .RGBA8, colorSpace: colorSpace)
        return bytes
    }

    private func centroids(_ bytes: [UInt8], channel: Int) -> [SIMD2<Double>] {
        var mass = [0.0, 0.0], moments = [SIMD2<Double>.zero, .zero]
        for y in 0..<height { for x in 0..<width {
            let side = x < width / 2 ? 0 : 1
            let weight = Double(max(0, 160 - Int(bytes[(y * width + x) * 4 + channel])))
            mass[side] += weight
            moments[side] += SIMD2(Double(x) + 0.5, Double(y) + 0.5) * weight
        } }
        return zip(moments, mass).map { $0 / $1 }
    }

    private func assertProtection(_ output: [UInt8], _ source: [UInt8], context: String,
                                  file: StaticString = #filePath, line: UInt = #line) {
        var regionDeltas = [0, 0, 0, 0], alphaDelta = 0
        for y in 0..<height { for x in 0..<width {
            let nx = (Double(x) + 0.5) / Double(width), ny = (Double(y) + 0.5) / Double(height)
            let i = (y * width + x) * 4
            let brows = (0.28...0.72).contains(nx) && (0.31...0.335).contains(ny)
            let nose = (0.48...0.52).contains(nx) && (0.46...0.57).contains(ny)
            let mouth = (0.42...0.58).contains(nx) && (0.60...0.66).contains(ny)
            let exterior = nx < 0.15 || nx > 0.85 || ny < 0.25 || ny > 0.55
            for (region, protected) in [brows, nose, mouth, exterior].enumerated() where protected {
                for c in 0..<3 { regionDeltas[region] += abs(Int(output[i + c]) - Int(source[i + c])) }
            }
            alphaDelta += abs(Int(output[i + 3]) - Int(source[i + 3]))
        } }
        for (name, delta) in zip(["brows", "nose", "mouth", "exterior"], regionDeltas) {
            XCTAssertEqual(delta, 0, "\(context) \(name) protection", file: file, line: line)
        }
        XCTAssertEqual(alphaDelta, 0, "\(context) alpha", file: file, line: line)
    }

    func testElevenHelpersPreserveSiblingsRoundTripAndMapReferenceTilt() throws {
        XCTAssertEqual(Set(probes.map(\.slider)), Set(BeautyEyeShapeSlider.allCases))
        var siblings = BeautyParameters()
        siblings.noseSlim = 0.2; siblings.mouthWidth = -0.1
        for probe in probes {
            XCTAssertEqual(probe.slider.neutralPosition, 0.5)
            for position: Float in [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1] {
                let parameters = probe.slider.applying(position: position, to: siblings)
                let polarity: Float = probe.slider == .tilt ? -1 : 1
                XCTAssertEqual(parameters[keyPath: probe.field], (2 * position - 1) * probe.cap * polarity, accuracy: 0.000001)
                XCTAssertEqual(probe.slider.position(in: parameters), position, accuracy: 0.000001)
                XCTAssertEqual(parameters.noseSlim, siblings.noseSlim)
                XCTAssertEqual(parameters.mouthWidth, siblings.mouthWidth)
                let restored = try JSONDecoder().decode(BeautyParameters.self, from: JSONEncoder().encode(parameters))
                XCTAssertEqual(restored[keyPath: probe.field], parameters[keyPath: probe.field])
            }
            for position: Float in [.nan, .infinity, -.infinity] {
                XCTAssertEqual(probe.slider.applying(position: position, to: siblings)[keyPath: probe.field], 0)
            }
        }
    }

    func testPublicEyeDirectionsFourStepsFeatureSeparationAndActualMetal() throws {
        try assertPublicDirectionsFourStepsFeatureSeparationAndActualMetal(probes)
    }

    func testTiltOnlyPreservesReferencePolarityDirectionsAndActualMetal() throws {
        let tilt = try XCTUnwrap(probes.first { $0.slider == .tilt })
        XCTAssertEqual(tilt.slider.applying(position: 0, to: .init()).eyeTilt, tilt.cap)
        XCTAssertEqual(tilt.slider.applying(position: 1, to: .init()).eyeTilt, -tilt.cap)
        try assertPublicDirectionsFourStepsFeatureSeparationAndActualMetal([tilt])
    }

    private func assertPublicDirectionsFourStepsFeatureSeparationAndActualMetal(_ selected: [Probe]) throws {
        let cpu = try engine(), gpu = try engine(gpu: true)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        for probe in selected {
            let source = image(probe), before = pixels(source)
            let baseline = centroids(before, channel: 0), controls = centroids(before, channel: 1)
            for sign: Float in [-1, 1] {
                var prior = [0.0, 0.0]
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    let parameters = probe.slider.applying(position: 0.5 + sign * fraction / 2, to: BeautyParameters())
                    let result = try cpu.processResult(image: source, metadata: metadata, parameters: parameters)
                    let output = pixels(result.output), measured = centroids(output, channel: 0)
                    for side in 0..<2 {
                        let delta = measured[side] - baseline[side]
                        let direction = SIMD2(probe.direction.x * (side == 0 ? 1 : -1), probe.direction.y)
                        let amplitude = (delta.x * direction.x + delta.y * direction.y) * Double(sign)
                        XCTAssertGreaterThan(amplitude, prior[side] + 0.012, "\(probe.slider) signed quarter response")
                        prior[side] = amplitude
                        // Translation and axis-scale controls must not invent orthogonal movement.
                        if [.verticalPosition, .height, .length, .spacing].contains(probe.slider) {
                            XCTAssertLessThan(abs(delta.x * direction.y - delta.y * direction.x), 0.08, "orthogonal separation")
                        }
                    }
                    XCTAssertEqual(result.output.extent, source.extent)
                    XCTAssertEqual(result.output.colorSpace?.name, colorSpace.name)
                    XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1)
                    assertProtection(output, before, context: "\(probe.slider) sign=\(sign) fraction=\(fraction)")
                    if fraction == 1 {
                        XCTAssertTrue(prior.allSatisfy { $0 > 0.12 }, "\(probe.slider) meaningful endpoint")
                        let auxiliary = centroids(output, channel: 1)
                        for side in 0..<2 {
                            let delta = auxiliary[side] - controls[side]
                            if probe.controlDirection == .zero {
                                XCTAssertLessThan(abs(delta.x) + abs(delta.y), 0.08, "\(probe.slider) protects distinct control feature")
                            } else {
                                let direction = SIMD2(probe.controlDirection.x * (side == 0 ? 1 : -1), probe.controlDirection.y)
                                XCTAssertGreaterThan((delta.x * direction.x + delta.y * direction.y) * Double(sign), 0.12, "\(probe.slider) second-axis or counter-corner direction")
                            }
                        }
                        let metal = try gpu.processResult(image: source, metadata: metadata, parameters: parameters)
                        XCTAssertTrue(output == pixels(metal.output), "actual CPU/Metal parity")
                        let repeated = try cpu.processResult(image: source, metadata: metadata, parameters: parameters)
                        XCTAssertTrue(output == pixels(repeated.output), "repeatability")
                    }
                }
            }
        }
    }

    func testSparsePositiveIrisPreservesApertureExteriorAndActualMetal() throws {
        let cpu = try engine(dense: false), gpu = try engine(gpu: true, dense: false)
        let probe = try XCTUnwrap(probes.first { $0.slider == .irisSize })
        let source = image(probe), before = pixels(source)
        let baseline = centroids(before, channel: 0)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        var prior = [0.0, 0.0]
        for fraction: Float in [0.25, 0.5, 0.75, 1] {
            let parameters = BeautyParameters(pupilSize: 0.25 * fraction)
            let result = try cpu.processResult(image: source, metadata: metadata, parameters: parameters)
            let output = pixels(result.output), measured = centroids(output, channel: 0)
            for side in 0..<2 {
                let amplitude = (measured[side].x - baseline[side].x) * (side == 0 ? 1 : -1)
                XCTAssertGreaterThan(amplitude, prior[side] + 0.012, "sparse positive iris quarter response")
                prior[side] = amplitude
            }
            // The analytic source's eye ellipse is an independent exterior
            // oracle. Sparse pupil evidence cannot authorize eyelid/brow motion.
            var exteriorDelta = 0
            for y in 0..<height { for x in 0..<width {
                let nx = (Double(x) + 0.5) / Double(width)
                let ny = (Double(y) + 0.5) / Double(height)
                let inside = [0.36, 0.64].contains { center in
                    pow((nx - center) / 0.07, 2) + pow((ny - 0.4) / 0.025, 2) <= 1
                }
                if !inside {
                    let i = (y * width + x) * 4
                    for channel in 0..<4 {
                        exteriorDelta += abs(Int(output[i + channel]) - Int(before[i + channel]))
                    }
                }
            } }
            XCTAssertEqual(exteriorDelta, 0, "sparse iris preserves complete aperture exterior")
            assertProtection(output, before, context: "sparse positive iris fraction=\(fraction)")
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1)
            XCTAssertEqual(result.output.extent, source.extent)
            if fraction == 1 {
                XCTAssertTrue(prior.allSatisfy { $0 > 0.12 }, "sparse compatibility has visible enlargement")
                let metal = try gpu.processResult(image: source, metadata: metadata, parameters: parameters)
                XCTAssertTrue(output == pixels(metal.output), "sparse actual CPU/Metal parity")
                let repeated = try cpu.processResult(image: source, metadata: metadata, parameters: parameters)
                XCTAssertTrue(output == pixels(repeated.output), "sparse repeatability")
            }
        }
    }

    func testPublicNeutralNoFaceMissingIrisAndFailureRecovery() throws {
        let cpu = try engine(), missing = try engine(noFace: true), sparse = try engine(dense: false)
        let source = image(probes[0]), before = pixels(source)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        for slider in BeautyEyeShapeSlider.allCases {
            let neutral = try cpu.processResult(image: source, metadata: metadata,
                parameters: slider.applying(position: slider.neutralPosition, to: BeautyParameters()))
            XCTAssertTrue(pixels(neutral.output) == before)
            for position: Float in [0, 1] {
                let noFace = try missing.processResult(image: source, metadata: metadata,
                    parameters: slider.applying(position: position, to: BeautyParameters()))
                XCTAssertTrue(pixels(noFace.output) == before)
            }
        }
        // Measured sparse eyes have bounded positive pupil compatibility;
        // absent iris evidence cannot fabricate the negative iris direction.
        let noIris = try sparse.processResult(image: source, metadata: metadata,
            parameters: BeautyEyeShapeSlider.irisSize.applying(position: 0, to: BeautyParameters()))
        XCTAssertTrue(pixels(noIris.output) == before)
        let parameters = BeautyEyeShapeSlider.eyeSize.applying(position: 1, to: BeautyParameters())
        XCTAssertThrowsError(try cpu.processResult(image: CIImage.empty(), metadata: metadata, parameters: parameters)) {
            XCTAssertEqual($0 as? BeautyError, .invalidInput)
        }
        let recovered = try cpu.processResult(image: source, metadata: metadata, parameters: parameters)
        XCTAssertFalse(pixels(recovered.output) == before)
        let neutral = try cpu.processResult(image: source, metadata: metadata, parameters: BeautyParameters())
        XCTAssertTrue(pixels(neutral.output) == before)
        let shiftedSource = source.transformed(by: CGAffineTransform(translationX: 13, y: 17))
        let shifted = try cpu.processResult(image: shiftedSource, metadata: metadata, parameters: parameters)
        XCTAssertEqual(shifted.output.extent, shiftedSource.extent)
        XCTAssertTrue(pixels(shifted.output) == pixels(recovered.output))
        let oriented = try cpu.processResult(image: source,
            metadata: BeautyInputMetadata(orientation: .right, isInputMirrored: true, source: .testFixture), parameters: parameters)
        XCTAssertEqual(oriented.output.extent, source.extent)
        XCTAssertEqual(oriented.output.colorSpace?.name, colorSpace.name)
        let orientedBytes = pixels(oriented.output)
        XCTAssertTrue(stride(from: 3, to: orientedBytes.count, by: 4).allSatisfy { orientedBytes[$0] == 255 })
    }
}
