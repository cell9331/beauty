import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import BeautyEffects

/// Integration guards for the reference-derived mouth fields. These prove
/// routing and request isolation; photographs still need owner acceptance.
final class BeautyMouthReferenceIntegrationTests: XCTestCase {
    private let width = 240
    private let height = 320
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private let sliders = BeautyMouthSlider.allCases.filter { $0 != .teethWhitening }

    func testEightSignedSliderEndpointsReachContinuousCPUStageFromTheSameSource() throws {
        let observation = sourceObservation()
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let source = raster()
        let original = try canonical(source)
        let neutralPlan = BeautyEffectResolver.resolve(parameters: .init(), faceGeometry: face)
        let neutral = try output(plan: neutralPlan, observation: observation, original: original)
        XCTAssertEqual(neutral.bytes, source)
        XCTAssertEqual(sliders.count, 8)

        for slider in sliders {
            for position: Float in [0, 1] {
                let label = "\(slider.rawValue)/\(position)"
                let parameters = slider.applying(position: position, to: .init())
                XCTAssertEqual(parameters.teethWhitening, 0, label)
                XCTAssertTrue(BeautyEffectResolver.localRetouchAdmission(parameters: parameters).isEmpty, label)
                let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
                XCTAssertTrue(plan.activeDomains.contains(.mouth), label)
                XCTAssertFalse(plan.skippedDomains.contains(.mouth), label)
                let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                    face: face, strengths: plan.effectiveStrengths), label)
                let stage = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
                    plan: plan, face: face)
                XCTAssertTrue(stage.controlPoints.isEmpty, label)
                let expected = map.applyRGBA(source)
                XCTAssertFalse(expected == source, label)
                XCTAssertEqual(stage.applyingContinuousMouth(to: source), expected, label)
                let actual = try output(plan: plan, observation: observation, original: original)
                let repeated = try output(plan: plan, observation: observation, original: original)
                XCTAssertEqual(actual.bytes, expected, label)
                XCTAssertEqual(repeated.bytes, expected, label)
                XCTAssertEqual(actual.image.extent, original.ciImage.extent, label)
                XCTAssertEqual(actual.image.colorSpace?.name, CGColorSpace.sRGB, label)
                XCTAssertTrue(stride(from: 3, to: actual.bytes.count, by: 4).allSatisfy {
                    actual.bytes[$0] == 255
                }, label)
                assertProtectedPixels(actual.bytes, source: source, label: label)
            }
        }
        // A reset is a fresh request on the immutable canonical source.
        XCTAssertEqual(try output(plan: neutralPlan, observation: observation, original: original).bytes, source)
        XCTAssertEqual(original.rgba8Data, Data(source))
    }

    func testMissingInnerEvidenceOnlyAbstainsMShapeAndFullnessWithoutLegacyFallback() throws {
        let observation = sourceObservation(includeInner: false)
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let source = raster()
        let original = try canonical(source)
        for slider in sliders {
            let parameters = slider.applying(position: 1, to: .init())
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            let stage = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
                plan: plan, face: face)
            XCTAssertTrue(stage.controlPoints.isEmpty, slider.rawValue)
            let actual = try output(plan: plan, observation: observation, original: original).bytes
            if slider == .mShape || slider == .fullness {
                XCTAssertTrue(plan.skippedDomains.contains(.mouth), slider.rawValue)
                XCTAssertEqual(actual, source, slider.rawValue)
            } else {
                XCTAssertTrue(plan.activeDomains.contains(.mouth), slider.rawValue)
                XCTAssertFalse(actual == source, slider.rawValue)
            }
        }
    }

    func testEightFieldCombinationRemainsDeterministicAndPreservesProtectedSourcePixels() throws {
        let observation = sourceObservation()
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let source = raster()
        let original = try canonical(source)
        for position: Float in [0, 1] {
            let parameters = sliders.reduce(BeautyParameters()) { sliderParameters, slider in
                slider.applying(position: position, to: sliderParameters)
            }
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            let actual = try output(plan: plan, observation: observation, original: original).bytes
            XCTAssertFalse(actual == source)
            XCTAssertEqual(actual, try output(plan: plan, observation: observation, original: original).bytes)
            XCTAssertEqual(parameters.teethWhitening, 0)
            XCTAssertTrue(BeautyEffectResolver.localRetouchAdmission(parameters: parameters).isEmpty)
            assertProtectedPixels(actual, source: source, label: "combined")
        }
    }

    func testEnablingAnInfinitesimalSiblingDoesNotJumpTheExistingForwardOrInverseEdit() throws {
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: sourceObservation())
        let cases: [(BeautyMouthSlider, BeautyMouthSlider)] = [
            (.fullness, .size), (.horizontalPosition, .mShape), (.smile, .fullness),
            (.tilt, .width), (.mShape, .verticalPosition)
        ]
        // Source points are selected before querying any map and cover both
        // lip tissue and its skin transitions. Existing target queries use
        // F_existing(p), so the inverse checks follow the same material points.
        let sources = stride(from: 0.57, through: 0.82, by: 0.025).flatMap { y in
            stride(from: 0.24, through: 0.76, by: 0.04).map { x in
                SIMD2(x * Double(width), y * Double(height))
            }
        }
        for (existingControl, siblingControl) in cases {
            for existingPosition: Float in [0, 1] {
                let existingParameters = existingControl.applying(position: existingPosition, to: .init())
                let existingPlan = BeautyEffectResolver.resolve(parameters: existingParameters, faceGeometry: face)
                let existing = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                    face: face, strengths: existingPlan.effectiveStrengths))
                for siblingDirection: Float in [-1, 1] {
                    var previousForwardDifference = Double.infinity
                    var previousInverseDifference = Double.infinity
                    for fraction: Float in [0.01, 0.0001, 0.000001] {
                        let position = 0.5 + siblingDirection * fraction * 0.5
                        let parameters = siblingControl.applying(position: position, to: existingParameters)
                        XCTAssertEqual(parameters.teethWhitening, 0)
                        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
                        let composite = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                            face: face, strengths: plan.effectiveStrengths))
                        var maximumForwardDifference = 0.0, maximumInverseDifference = 0.0
                        for source in sources {
                            let existingDisplacement = existing.forwardDisplacement(at: source)
                            let compositeDisplacement = composite.forwardDisplacement(at: source)
                            let difference = compositeDisplacement - existingDisplacement
                            maximumForwardDifference = max(maximumForwardDifference, hypot(difference.x, difference.y))
                            let query = source + existingDisplacement
                            let existingSource = try XCTUnwrap(existing.sourcePoint(for: query))
                            let compositeSource = try XCTUnwrap(composite.sourcePoint(for: query))
                            let inverseDifference = compositeSource - existingSource
                            maximumInverseDifference = max(maximumInverseDifference,
                                hypot(inverseDifference.x, inverseDifference.y))
                        }
                        let label = "\(existingControl.rawValue)+epsilon*\(siblingControl.rawValue)"
                        let limit = Double(max(width, height)) * Double(fraction) * 4 + 0.0001
                        XCTAssertLessThanOrEqual(maximumForwardDifference, limit, label)
                        XCTAssertLessThanOrEqual(maximumInverseDifference, limit, label)
                        XCTAssertLessThanOrEqual(maximumForwardDifference,
                            previousForwardDifference * 0.05 + 0.0001, label)
                        XCTAssertLessThanOrEqual(maximumInverseDifference,
                            previousInverseDifference * 0.05 + 0.0001, label)
                        previousForwardDifference = maximumForwardDifference
                        previousInverseDifference = maximumInverseDifference
                    }
                }
            }
        }
    }

    private func canonical(_ bytes: [UInt8]) throws -> BeautyCanonicalStillImage {
        try BeautyCanonicalStillImage(rgba8Data: Data(bytes), width: width, height: height,
            rowBytes: width * 4, metadata: metadata)
    }

    private func output(plan: BeautyEffectPlan, observation: BeautyFaceObservation,
                        original: BeautyCanonicalStillImage) throws -> (image: CIImage, bytes: [UInt8]) {
        let request = try BeautyBackendRequest(policy: .cpu, input: .stillImage(original.ciImage),
            metadata: metadata, plan: plan, selectedFaceSupport: observation, canonicalImage: original)
        let result = try BeautyCPUBackend().execute(request)
        guard case .stillImage(let image) = result.output else { throw BeautyError.invalidInput }
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let context = CIContext(options: [.cacheIntermediates: false, .workingColorSpace: colorSpace])
        bytes.withUnsafeMutableBytes { buffer in
            context.render(image, toBitmap: buffer.baseAddress!, rowBytes: width * 4,
                bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        }
        return (image, bytes)
    }

    private func sourceObservation(includeInner: Bool = true) -> BeautyFaceObservation {
        func point(_ x: Double, _ y: Double) -> CoordinatePoint { .init(x: x, y: y) }
        func ellipse(_ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, count: Int) -> [CoordinatePoint] {
            (0..<count).map {
                let angle = Double($0) * 2 * Double.pi / Double(count)
                return point(cx + rx * cos(angle), cy + ry * sin(angle))
            }
        }
        let outer = (0..<40).map { index -> CoordinatePoint in
            let angle = Double(index) * 2 * Double.pi / 40
            let x = 0.5 + 0.18 * cos(angle)
            let y = sin(angle) < 0
                ? 0.69 - 0.055 * abs(sin(angle)) + 0.011 * exp(-pow((x - 0.5) / 0.025, 2))
                : 0.69 + 0.060 * sin(angle)
            return point(x, y)
        }
        return BeautyFaceObservation(imageBounds: .init(x: 0.12, y: 0.08, width: 0.76, height: 0.84),
            landmarks: .complete,
            observedEyeSupport: [
                .init(side: .left, contour: ellipse(0.34, 0.34, 0.065, 0.025, count: 12)),
                .init(side: .right, contour: ellipse(0.66, 0.34, 0.065, 0.025, count: 12))
            ], observedEyeOrder: .canonical,
            observedLipSupport: .init(outer: outer,
                inner: includeInner ? ellipse(0.5, 0.69, 0.14, 0.008, count: 20) : []),
            observedNoseSupport: .init(
                crest: [point(0.5, 0.43), point(0.5, 0.48), point(0.5, 0.53)],
                contour: [point(0.45, 0.52), point(0.47, 0.55), point(0.5, 0.56),
                          point(0.53, 0.55), point(0.55, 0.52)]))
    }

    private func raster() -> [UInt8] {
        (0..<(width * height)).flatMap { index -> [UInt8] in
            let x = index % width, y = index / width
            return [UInt8(30 + (x * 7 + y * 3) % 190), UInt8(20 + (x * 5 + y * 11) % 200),
                    UInt8(25 + (x * 13 + y * 7) % 195), 255]
        }
    }

    private func assertProtectedPixels(_ bytes: [UInt8], source: [UInt8], label: String,
                                      file: StaticString = #filePath, line: UInt = #line) {
        // Source-defined rectangles outside every mouth support. They exercise
        // actual output bytes and do not read the candidate's envelope weights.
        var changed = 0
        for y in 0..<height { for x in 0..<width {
            if y < Int(Double(height) * 0.40)
                || x < Int(Double(width) * 0.02) || x > Int(Double(width) * 0.98) {
                let offset = (y * width + x) * 4
                if bytes[offset] != source[offset] || bytes[offset + 1] != source[offset + 1]
                    || bytes[offset + 2] != source[offset + 2] || bytes[offset + 3] != source[offset + 3] {
                    changed += 1
                }
            }
        } }
        XCTAssertEqual(changed, 0, label, file: file, line: line)
    }
}

/// Explicit local image review. Inputs and all outputs live in the repository's
/// ignored measurement directory. No raw photo, path, geometry, field or mask is
/// attached to XCTest or emitted in diagnostic output. This uses approximate
/// source geometry, so it does not qualify native detection or facade routing.
final class BeautyMouthReferenceLocalReviewTests: XCTestCase {
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private let controls: [(String, BeautyMouthSlider)] = [
        ("size", .size), ("width", .width), ("vertical", .verticalPosition),
        ("tilt", .tilt), ("horizontal", .horizontalPosition), ("mShape", .mShape),
        ("fullness", .fullness), ("smile", .smile)
    ]

    func testOptInEightLocalReferenceSourcePreviewsAndFields() throws {
        let environment = ProcessInfo.processInfo.environment
        guard environment["BEAUTYSDK_MOUTH_REFERENCE_LOCAL_REVIEW"] == "1" else {
            throw XCTSkip("Owner-local mouth photo review is opt-in")
        }
        let identifier = environment["BEAUTYSDK_MOUTH_REFERENCE_RUN_ID"] ?? "candidate"
        guard !identifier.isEmpty, identifier.count <= 64,
              identifier.allSatisfy({ $0.isASCII && ($0.isLowercase || $0.isNumber || $0 == "-") }) else {
            throw ReviewFailure.invalidRunIdentifier
        }
        let repository = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        let local = repository.appendingPathComponent("example-images/参考效果分析/嘴唇/本地测量")
        let inputs = local.appendingPathComponent("implementation-calibration")
        let output = local.appendingPathComponent("implementation-review").appendingPathComponent(identifier)
        let manifest: ReviewGeometryBundle
        do {
            manifest = try JSONDecoder().decode(ReviewGeometryBundle.self,
                from: Data(contentsOf: inputs.appendingPathComponent("manual_geometry.json")))
        } catch { throw ReviewFailure.geometryInputInvalid }
        guard manifest.schema_version == 1, controls.allSatisfy({ manifest.features[$0.0] != nil }) else {
            throw ReviewFailure.geometryInputInvalid
        }
        var queries: [String: Any]
        let referenceFeatures: [String: [String: Any]]
        do {
            guard let decoded = try JSONSerialization.jsonObject(with: Data(contentsOf:
                inputs.appendingPathComponent("reference_queries.json"))) as? [String: Any],
                  decoded["schema_version"] as? Int == 1,
                  let features = decoded["features"] as? [String: [String: Any]],
                  features.count == controls.count,
                  Set(features.values.compactMap { $0["sdk_feature"] as? String }) == Set(controls.map(\.0)) else {
                throw ReviewFailure.queryInputInvalid
            }
            queries = decoded
            referenceFeatures = features
        } catch { throw ReviewFailure.queryInputInvalid }
        guard !FileManager.default.fileExists(atPath: output.path) else { throw ReviewFailure.outputAlreadyExists }
        do { try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true) }
        catch { throw ReviewFailure.outputWriteFailed }

        let exportFields = environment["BEAUTYSDK_MOUTH_REFERENCE_PRIVATE_FIELDS"] == "1"
        let nativeMode = environment["BEAUTYSDK_MOUTH_REFERENCE_NATIVE_DETECTION"] == "1"
        #if os(iOS)
        let nativeDetectorName = "production-MediaPipe"
        #else
        let nativeDetectorName = "production-Apple-Vision"
        #endif
        let geometrySource = nativeMode ? nativeDetectorName : "approximate-source-texture-and-manual-observation-boxes"
        let stride = 4
        var endpoints = 0
        var records: [[String: Any]] = []
        var sampledFeatures: [String: [String: Any]] = [:]
        var sparseQueryCount = 0, gridQueryCount = 0, failedQueries = 0
        var nativeInvocations = 0, nativeFailures = 0, cpuRequests = 0, endpointFailures = 0
        for (key, slider) in controls {
            guard let entry = manifest.features[key] else { throw ReviewFailure.geometryInputInvalid }
            let source = try sourcePixels(inputs.appendingPathComponent("input-\(key).png"),
                width: entry.width, height: entry.height)
            try writePNG(source, width: entry.width, height: entry.height,
                to: output.appendingPathComponent("\(key)-source.png"))
            guard let reference = referenceFeatures.first(where: { $0.value["sdk_feature"] as? String == key }) else {
                throw ReviewFailure.queryInputInvalid
            }
            let original = try BeautyCanonicalStillImage(rgba8Data: Data(source), width: entry.width,
                height: entry.height, rowBytes: entry.width*4,
                metadata: .init(orientation: .up, source: .testFixture))
            let face: FaceGeometry
            var observation: BeautyFaceObservation?
            var nativeReceipt: [String: Any] = [:]
            if nativeMode {
                var detector = BeautyFaceDetector.production()
                let detection = detector.detect(image: original.ciImage,
                    metadata: .init(orientation: .up, source: .testFixture),
                    imageExtent: original.ciImage.extent.size, configuration: .init(maximumFaceCount: 1))
                nativeInvocations += 1
                nativeReceipt = ["nativeDetectionRequested": true,
                    "nativeUsedFaceCount": detection.summary.usedFaceCount,
                    "nativeObservationCount": detection.observations.count,
                    "nativeDetector": nativeDetectorName]
                guard detection.summary.usedFaceCount == 1, detection.observations.count == 1,
                      let detected = detection.observations.first else {
                    nativeFailures += 1
                    let failed = try failedQueryFeature(reference.value, reason: "native_detection_failed")
                    sampledFeatures[reference.key] = failed.feature
                    sparseQueryCount += failed.sparseCount; gridQueryCount += failed.gridCount
                    failedQueries += failed.sparseCount+failed.gridCount
                    records.append(nativeReceipt.merging(["control": key, "status": "native_detection_failed"]) { _, new in new })
                    continue
                }
                observation = detected
                face = BeautyFaceGeometryAdapter.makeGeometry(from: detected)
                nativeReceipt["nativeOuterLipCount"] = detected.observedLipSupport?.outer?.count ?? 0
                nativeReceipt["nativeInnerLipCount"] = detected.observedLipSupport?.inner?.count ?? 0
                nativeReceipt["nativeMeshPointCount"] = detected.mesh?.points.count ?? 0
                let neutralPlan = BeautyEffectResolver.resolve(parameters: .init(), faceGeometry: face)
                let neutralValid: Bool
                do {
                    cpuRequests += 1
                    neutralValid = try productionCPUPixels(original: original, observation: detected, plan: neutralPlan) == source
                } catch { neutralValid = false }
                guard neutralValid else {
                    endpointFailures += 2
                    let failed = try failedQueryFeature(reference.value, reason: "native_cpu_neutral_failed")
                    sampledFeatures[reference.key] = failed.feature
                    sparseQueryCount += failed.sparseCount; gridQueryCount += failed.gridCount
                    failedQueries += failed.sparseCount+failed.gridCount
                    records.append(nativeReceipt.merging(["control": key, "status": "native_cpu_neutral_failed"]) { _, new in new })
                    continue
                }
            } else {
                face = try entry.face()
            }
            let span = sourceMouthSpan(face, width: entry.width, height: entry.height)
            var endpointMaps: [String: BeautyContinuousMouthMap] = [:]
            for (label, position) in [("left", Float(0)), ("right", Float(1))] {
                let parameters = slider.applying(position: position, to: .init())
                let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
                guard parameters.teethWhitening == 0,
                      BeautyEffectResolver.localRetouchAdmission(parameters: parameters).isEmpty,
                      let map = BeautyContinuousMouthMap(width: entry.width, height: entry.height,
                        face: face, strengths: plan.effectiveStrengths) else {
                    endpointFailures += 1
                    records.append(nativeReceipt.merging(["control": key, "sliderEndpoint": label,
                        "status": "endpoint_not_admitted", "geometrySource": geometrySource]) { _, new in new })
                    continue
                }
                let expected = map.applyRGBA(source)
                let rendered: [UInt8]
                if nativeMode, let observation {
                    do {
                        cpuRequests += 1
                        rendered = try productionCPUPixels(original: original, observation: observation, plan: plan)
                    } catch {
                        endpointFailures += 1
                        records.append(nativeReceipt.merging(["control": key, "sliderEndpoint": label,
                            "status": "production_cpu_backend_failed"]) { _, new in new })
                        continue
                    }
                    guard rendered == expected else {
                        endpointFailures += 1
                        records.append(nativeReceipt.merging(["control": key, "sliderEndpoint": label,
                            "status": "production_cpu_map_mismatch", "actualCPUOutputMatchesDumpedMap": false]) { _, new in new })
                        try writePNG(rendered, width: entry.width, height: entry.height,
                            to: output.appendingPathComponent("\(key)-\(label)-mismatched-cpu.png"))
                        try writePNG(expected, width: entry.width, height: entry.height,
                            to: output.appendingPathComponent("\(key)-\(label)-expected-map.png"))
                        continue
                    }
                } else { rendered = expected }
                guard rendered != source,
                      map.maximumGradient.isFinite, map.maximumDisplacement.isFinite else {
                    throw ReviewFailure.endpointInvalid
                }
                guard Swift.stride(from: 3, to: rendered.count, by: 4).allSatisfy({ rendered[$0] == source[$0] }) else {
                    throw ReviewFailure.alphaChanged
                }
                try writePNG(rendered, width: entry.width, height: entry.height,
                    to: output.appendingPathComponent("\(key)-\(label).png"))
                if exportFields {
                    try writePrivateInverseField(map, stride: stride,
                        to: output.appendingPathComponent("\(key)-\(label)-inverse-offset.f32"))
                }
                records.append(nativeReceipt.merging(["control": key, "sliderEndpoint": label,
                    "width": entry.width, "height": entry.height,
                    "maximumGradientBound": map.maximumGradient,
                    "maximumDisplacementBound": map.maximumDisplacement,
                    "sourceMouthSpanPx": span,
                    "maximumDisplacementBoundOverSourceMouthSpan": map.maximumDisplacement/max(span, 0.000001),
                    "safetyScale": map.safetyScale, "status": "ok",
                    "productionCPUBackendExecuted": nativeMode, "productionFacadeExecuted": false,
                    "actualCPUOutputMatchesDumpedMap": nativeMode,
                    "nonNeutralRGBA": true, "repeatRenderedInThisPhotoRun": false, "alphaExact": true]) { _, new in new })
                endpoints += 1
                endpointMaps[label] = map
            }
            guard let low = endpointMaps["left"], let high = endpointMaps["right"] else {
                let failed = try failedQueryFeature(reference.value, reason: "endpoint_map_unavailable")
                sampledFeatures[reference.key] = failed.feature
                sparseQueryCount += failed.sparseCount; gridQueryCount += failed.gridCount
                failedQueries += failed.sparseCount+failed.gridCount
                continue
            }
            let sampled = try sampleSameSourceQueries(reference.value, low: low, high: high)
            var sampledFeature = sampled.feature
            sampledFeature["sdk_source_mouth_span_px"] = span
            sampledFeature["sdk_geometry_source"] = geometrySource
            sampledFeatures[reference.key] = sampledFeature
            sparseQueryCount += sampled.sparseCount
            gridQueryCount += sampled.gridCount
            failedQueries += sampled.failures
        }
        queries["features"] = sampledFeatures
        queries["sdk_sampling"] = [
            "schema_version": 1,
            "coordinate": "photo-px x-right y-down",
            "geometry_source": geometrySource,
            "native_detection_executed": nativeMode,
            "native_detection_invocations": nativeInvocations,
            "native_detection_failures": nativeFailures,
            "production_cpu_backend_executed": cpuRequests > 0,
            "production_cpu_backend_requests": cpuRequests,
            "production_facade_executed": false,
            "reference_neutral_known": false,
            "source_geometry_anchor": "reference-low-photo-is-an-arbitrary-design-source",
            "mapping": "reference_low=F_low(neutral); endpoint_span=F_high(neutral)-F_low(neutral)",
            "inverse_method": "actual-SDK-constrained-sourcePoint-for-target",
            "forward_method": "actual-SDK-forwardDisplacement-at-source",
            "uses_field_grid_interpolation": false,
            "inverse_residual_limit_px": 0.001,
            "sparse_query_count": sparseQueryCount,
            "grid_query_count": gridQueryCount,
            "failed_query_count": failedQueries,
            "query_completeness": "every-input-correspondence-and-grid-query-has-a-result-or-explicit-failure",
            "appearance_accepted": false
        ] as [String: Any]
        let receipt: [String: Any] = [
            "schema": 1, "probe": nativeMode ? "mouth-reference-native-detection-cpu-backend" : "mouth-reference-internal-map-preview",
            "geometrySource": geometrySource,
            "nativeDetectionExecuted": nativeMode, "productionFacadeExecuted": false,
            "nativeDetectionInvocations": nativeInvocations, "nativeDetectionFailures": nativeFailures,
            "productionCPUBackendExecuted": cpuRequests > 0, "productionCPUBackendRequests": cpuRequests,
            "endpointFailures": endpointFailures,
            "referenceNeutralKnown": false,
            "sourceInterpretation": "each-reference-left-image-is-an-arbitrary-design-source",
            "referenceAppearanceAccepted": false, "ownerAcceptancePending": true,
            "sourceCount": controls.count, "signedEndpointCount": endpoints,
            "teethWhiteningRequested": false,
            "selectedBackend": nativeMode ? "production-BeautyCPUBackend" : "shared-continuous-map-cpu-sampler",
            "privateInverseOffsetFieldsWritten": exportFields,
            "sameSourceSparseQueryCount": sparseQueryCount,
            "sameSourceGridQueryCount": gridQueryCount,
            "sameSourceQueryFailures": failedQueries,
            "fieldFormat": "row-major-little-endian-float32-dx-dy",
            "fieldCoordinates": "target-pixel-centers-x-right-y-down-offset-is-target-minus-source",
            "fieldGridStride": stride, "fieldGridOrigin": "pixel-center-0.5",
            "records": records
        ]
        do {
            let queryData = try JSONSerialization.data(withJSONObject: queries, options: [.sortedKeys])
            try queryData.write(to: output.appendingPathComponent("same-source-fields.json"), options: [.withoutOverwriting])
            let data = try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys, .prettyPrinted])
            try data.write(to: output.appendingPathComponent("aggregate.json"), options: [.withoutOverwriting])
        } catch { throw ReviewFailure.outputWriteFailed }
        XCTAssertEqual(failedQueries, 0, "Every private query must produce a valid same-source endpoint prediction")
        XCTAssertEqual(nativeFailures+endpointFailures, 0, "Native or map admission failures must remain explicit")
        XCTAssertEqual(endpoints, 16)
        print("MOUTH_REFERENCE_LOCAL_REVIEW sourceCount=8 signedEndpointCount=\(endpoints) nativeDetectionExecuted=\(nativeMode) nativeDetectionFailures=\(nativeFailures) endpointFailures=\(endpointFailures) ownerAcceptancePending=true")
    }

    private func sourceMouthSpan(_ face: FaceGeometry, width: Int, height: Int) -> Double {
        guard let outer = face.observedOuterLips,
              let left = outer.min(by: { $0.x < $1.x }), let right = outer.max(by: { $0.x < $1.x }) else { return 0 }
        return hypot(Double(right.x-left.x)*Double(width), Double(right.y-left.y)*Double(height))
    }

    private func productionCPUPixels(original: BeautyCanonicalStillImage, observation: BeautyFaceObservation,
                                     plan: BeautyEffectPlan) throws -> [UInt8] {
        let request = try BeautyBackendRequest(policy: .cpu, input: .stillImage(original.ciImage),
            metadata: .init(orientation: .up, source: .testFixture), plan: plan,
            selectedFaceSupport: observation, canonicalImage: original)
        let result = try BeautyCPUBackend().execute(request)
        guard case .stillImage(let image) = result.output,
              image.extent == original.ciImage.extent,
              image.colorSpace?.name == CGColorSpace.sRGB else { throw ReviewFailure.nativeBackendMetadataChanged }
        var bytes = [UInt8](repeating: 0, count: original.width*original.height*4)
        let context = CIContext(options: [.cacheIntermediates: false, .workingColorSpace: colorSpace])
        bytes.withUnsafeMutableBytes { raw in
            context.render(image, toBitmap: raw.baseAddress!, rowBytes: original.rowBytes,
                bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        }
        return bytes
    }

    private func failedQueryFeature(_ reference: [String: Any], reason: String) throws ->
        (feature: [String: Any], sparseCount: Int, gridCount: Int) {
        guard let correspondences = reference["correspondences"] as? [[String: Any]],
              let grid = reference["field_low_query_xy"] as? [[Any]] else { throw ReviewFailure.queryInputInvalid }
        let failure: [String: Any] = ["sdk_status": reason, "sdk_neutral_xy": NSNull(),
            "sdk_low_xy": NSNull(), "sdk_high_xy": NSNull(), "sdk_endpoint_span": NSNull(),
            "sdk_low_inverse_residual_px": NSNull()]
        var feature = reference
        feature["correspondences"] = correspondences.map { $0.merging(failure) { _, new in new } }
        feature["field_sdk_rows"] = grid.enumerated().map { index, query in
            let row: [String: Any] = ["index": index, "reference_low_xy": query]
            return row.merging(failure) { _, new in new }
        }
        feature["sdk_sparse_query_count"] = correspondences.count
        feature["sdk_grid_query_count"] = grid.count
        feature["sdk_failed_query_count"] = correspondences.count+grid.count
        return (feature, correspondences.count, grid.count)
    }

    private func sampleSameSourceQueries(_ reference: [String: Any], low: BeautyContinuousMouthMap,
                                         high: BeautyContinuousMouthMap) throws ->
        (feature: [String: Any], sparseCount: Int, gridCount: Int, failures: Int) {
        guard let correspondences = reference["correspondences"] as? [[String: Any]],
              let grid = reference["field_low_query_xy"] as? [[Any]],
              let fieldGrid = reference["field_grid"] as? [String: Any],
              let shape = fieldGrid["shape"] as? [Int], shape.count == 2,
              shape[0] > 0, shape[1] > 0, shape[0] <= Int.max / shape[1],
              shape[0] * shape[1] == grid.count else { throw ReviewFailure.queryInputInvalid }
        var sparseRows: [[String: Any]] = [], gridRows: [[String: Any]] = []
        var failures = 0
        for referenceRow in correspondences {
            guard let values = referenceRow["reference_low_xy"] as? [Any],
                  referenceRow["id"] is String, referenceRow["method"] is String else {
                throw ReviewFailure.queryInputInvalid
            }
            let query = try point(values)
            let sampled = sampleSameSourcePoint(query, low: low, high: high)
            var row = referenceRow
            for (key, value) in sampled.values { row[key] = value }
            sparseRows.append(row)
            if !sampled.success { failures += 1 }
        }
        for (index, values) in grid.enumerated() {
            let query = try point(values)
            let sampled = sampleSameSourcePoint(query, low: low, high: high)
            var row: [String: Any] = ["index": index, "reference_low_xy": values]
            for (key, value) in sampled.values { row[key] = value }
            gridRows.append(row)
            if !sampled.success { failures += 1 }
        }
        guard sparseRows.count == correspondences.count, gridRows.count == grid.count else {
            throw ReviewFailure.queryInputInvalid
        }
        var feature = reference
        feature["correspondences"] = sparseRows
        feature["field_sdk_rows"] = gridRows
        feature["sdk_sparse_query_count"] = sparseRows.count
        feature["sdk_grid_query_count"] = gridRows.count
        feature["sdk_failed_query_count"] = failures
        return (feature, sparseRows.count, gridRows.count, failures)
    }

    private func sampleSameSourcePoint(_ referenceLow: SIMD2<Double>, low: BeautyContinuousMouthMap,
                                      high: BeautyContinuousMouthMap) -> (values: [String: Any], success: Bool) {
        var row: [String: Any] = ["sdk_status": "inverse_failed", "sdk_neutral_xy": NSNull(),
            "sdk_low_xy": NSNull(), "sdk_high_xy": NSNull(), "sdk_endpoint_span": NSNull(),
            "sdk_low_inverse_residual_px": NSNull()]
        guard let neutral = low.sourcePoint(for: referenceLow) else { return (row, false) }
        let mappedLow = neutral + low.forwardDisplacement(at: neutral)
        let mappedHigh = neutral + high.forwardDisplacement(at: neutral)
        let span = mappedHigh - mappedLow
        let residual = hypot(mappedLow.x - referenceLow.x, mappedLow.y - referenceLow.y)
        guard [neutral.x, neutral.y, mappedLow.x, mappedLow.y, mappedHigh.x, mappedHigh.y,
               span.x, span.y, residual].allSatisfy(\.isFinite) else {
            row["sdk_status"] = "nonfinite_result"
            return (row, false)
        }
        row["sdk_neutral_xy"] = [neutral.x, neutral.y]
        row["sdk_low_xy"] = [mappedLow.x, mappedLow.y]
        row["sdk_high_xy"] = [mappedHigh.x, mappedHigh.y]
        row["sdk_endpoint_span"] = [span.x, span.y]
        row["sdk_low_inverse_residual_px"] = residual
        let success = residual <= 0.001
        row["sdk_status"] = success ? "ok" : "inverse_residual_exceeded"
        return (row, success)
    }

    private func point(_ values: [Any]) throws -> SIMD2<Double> {
        guard values.count == 2, let x = values[0] as? NSNumber, let y = values[1] as? NSNumber,
              x.doubleValue.isFinite, y.doubleValue.isFinite else { throw ReviewFailure.queryInputInvalid }
        return SIMD2(x.doubleValue, y.doubleValue)
    }

    private func sourcePixels(_ url: URL, width: Int, height: Int) throws -> [UInt8] {
        guard width > 1, height > 1,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height else {
            throw ReviewFailure.imageInputInvalid
        }
        let data: Data
        do {
            let info = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
            guard info.isRegularFile == true, info.isSymbolicLink == false,
                  let size = info.fileSize, size > 0, size <= 32 * 1_024 * 1_024 else {
                throw ReviewFailure.imageInputInvalid
            }
            data = try Data(contentsOf: url)
        } catch { throw ReviewFailure.imageInputInvalid }
        guard let input = CGImageSourceCreateWithData(data as CFData, nil), CGImageSourceGetCount(input) == 1,
              let image = CGImageSourceCreateImageAtIndex(input, 0, nil), image.width == width, image.height == height else {
            throw ReviewFailure.imageInputInvalid
        }
        let properties = CGImageSourceCopyPropertiesAtIndex(input, 0, nil) as? [CFString: Any]
        guard ((properties?[kCGImagePropertyOrientation] as? NSNumber)?.intValue ?? 1) == 1 else {
            throw ReviewFailure.imageInputInvalid
        }
        // CGContext draws the original CGImage into one canonical RGBA8 raster;
        // the CGImage's row order is retained in the emitted PNG as well.
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let success = bytes.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(data: buffer.baseAddress, width: width, height: height,
                bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
            context.setBlendMode(.copy)
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard success, Swift.stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else {
            throw ReviewFailure.imageInputInvalid
        }
        return bytes
    }

    private func writePNG(_ bytes: [UInt8], width: Int, height: Int, to url: URL) throws {
        guard let provider = CGDataProvider(data: Data(bytes) as CFData),
              let image = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
                bytesPerRow: width * 4, space: colorSpace,
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent),
              let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw ReviewFailure.outputWriteFailed
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw ReviewFailure.outputWriteFailed }
    }

    private func writePrivateInverseField(_ map: BeautyContinuousMouthMap, stride: Int, to url: URL) throws {
        var data = Data()
        for y in Swift.stride(from: 0, to: map.height, by: stride) {
            for x in Swift.stride(from: 0, to: map.width, by: stride) {
                let displacement = map.displacement(at: SIMD2(Double(x) + 0.5, Double(y) + 0.5))
                for component in [displacement.x, displacement.y] {
                    var bits = Float(component).bitPattern.littleEndian
                    withUnsafeBytes(of: &bits) { data.append(contentsOf: $0) }
                }
            }
        }
        do { try data.write(to: url, options: [.withoutOverwriting]) }
        catch { throw ReviewFailure.outputWriteFailed }
    }

    private struct ReviewGeometryBundle: Decodable {
        let schema_version: Int
        let features: [String: ReviewGeometry]
    }

    private struct ReviewGeometry: Decodable {
        let width: Int
        let height: Int
        let faceBounds: [Double]
        let outerLips: [[Double]]
        let innerLips: [[Double]]
        let leftEye: [[Double]]
        let rightEye: [[Double]]
        let nose: [[Double]]

        func face() throws -> FaceGeometry {
            func path(_ values: [[Double]]) throws -> [SIMD2<Float>] {
                guard values.allSatisfy({ $0.count == 2 && $0.allSatisfy({ $0.isFinite && (0...1).contains($0) }) }) else {
                    throw ReviewFailure.geometryInputInvalid
                }
                return values.map { SIMD2(Float($0[0]), Float($0[1])) }
            }
            guard faceBounds.count == 4, faceBounds.allSatisfy({ $0.isFinite && (0...1).contains($0) }),
                  faceBounds[2] > 0, faceBounds[3] > 0 else { throw ReviewFailure.geometryInputInvalid }
            let outer = try path(outerLips), inner = try path(innerLips)
            return FaceGeometry(bounds: .init(x: Float(faceBounds[0]), y: Float(faceBounds[1]),
                width: Float(faceBounds[2]), height: Float(faceBounds[3])), faceContour: [],
                leftEye: try path(leftEye), rightEye: try path(rightEye), nose: try path(nose),
                outerLips: outer, upperLips: [], lowerLips: [], innerLips: inner,
                observedOuterLips: outer, observedInnerLips: inner)
        }
    }

    private enum ReviewFailure: Error {
        case invalidRunIdentifier, geometryInputInvalid, imageInputInvalid, queryInputInvalid
        case outputAlreadyExists, outputWriteFailed, endpointNotAdmitted, endpointInvalid, alphaChanged
        case nativeNeutralChanged, nativeBackendMapMismatch, nativeBackendMetadataChanged
    }
}
