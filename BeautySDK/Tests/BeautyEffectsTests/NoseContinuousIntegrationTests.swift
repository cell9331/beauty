import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyEffects

/// These integration checks prove routing and isolation. The independent
/// anatomical and photographic oracles own useful shape/appearance acceptance.
final class NoseContinuousIntegrationTests: XCTestCase {
    private typealias Field = (String, WritableKeyPath<BeautyParameters, Float>, KeyPath<BeautyEffectiveStrengths, Float>, Float)
    private let fields: [Field] = [
        ("size", \.noseSlim, \.noseSlim, BeautySafetyCaps.noseSlim),
        ("wing", \.noseWingSlim, \.noseWingSlim, BeautySafetyCaps.noseWingSlim),
        ("tip", \.noseTipSize, \.noseTipSize, BeautySafetyCaps.noseTipSize),
        ("bridge", \.noseBridge, \.noseBridge, BeautySafetyCaps.noseBridge),
        ("root", \.noseRootNarrowing, \.noseRootNarrowing, BeautySafetyCaps.noseRootNarrowing),
        ("lift", \.noseTipLift, \.noseTipLift, BeautySafetyCaps.noseTipLift)
    ]
    private let width = 144, height = 192
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    func testSixSignedFieldsRemainActiveWithoutLegacyPointsAndReachCPUOutput() throws {
        let observation = try ContinuousNoseTestFixture.observation()
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let source = raster()
        for (name, parameterKey, strengthKey, cap) in fields {
            for sign: Float in [-1, 1] {
                var parameters = BeautyParameters(); parameters[keyPath: parameterKey] = cap * sign
                let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
                XCTAssertTrue(plan.activeDomains.contains(.nose), name)
                XCTAssertFalse(plan.skippedDomains.contains(.nose), name)
                XCTAssertEqual(plan.effectiveStrengths[keyPath: strengthKey], cap * sign, accuracy: 0.00001, name)
                let emissions = NoseWarpProvider().planningEmissions(face: face, strengths: plan.effectiveStrengths)
                XCTAssertTrue(emissions.hasAdmittedWork, name)
                XCTAssertTrue(emissions.points.isEmpty, name)
                let stage = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height, plan: plan, face: face)
                XCTAssertTrue(stage.controlPoints.isEmpty, name)
                let staged = stage.applyingContinuousNose(to: stage.sourceRGBA)
                XCTAssertNotEqual(staged, source, name)
                let request = try request(plan: plan, observation: observation, source: source)
                let result = try BeautyCPUBackend().execute(request)
                XCTAssertEqual(try pixels(result), staged, name)
                XCTAssertEqual(try pixels(BeautyCPUBackend().execute(request)), staged, name)
                XCTAssertEqual(try image(result).extent, CGRect(x: 0, y: 0, width: width, height: height))
                XCTAssertEqual(try image(result).colorSpace?.name, CGColorSpace.sRGB)
                XCTAssertTrue(stride(from: 3, to: staged.count, by: 4).allSatisfy { staged[$0] == 255 })
            }
        }
    }

    func testMissingRegionalEvidenceSanitizesAllNoseFieldsWithoutFallbackAndKeepsColor() throws {
        let complete = try ContinuousNoseTestFixture.observation()
        let source = raster()
        for omitted in ["eyes", "brows", "lips", "nose"] {
            let observation = removing(omitted, from: complete)
            let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
            XCTAssertTrue(BeautyContinuousNoseMap.replacesLegacy(for: face))
            XCTAssertFalse(BeautyContinuousNoseMap.isEligible(face: face), omitted)
            var parameters = BeautyParameters()
            for (_, key, _, cap) in fields { parameters[keyPath: key] = cap }
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            XCTAssertFalse(plan.activeDomains.contains(.nose), omitted)
            XCTAssertTrue(plan.skippedDomains.contains(.nose), omitted)
            for (_, _, key, _) in fields { XCTAssertEqual(plan.effectiveStrengths[keyPath: key], 0, omitted) }
            let actual = try pixels(BeautyCPUBackend().execute(request(plan: plan, observation: observation, source: source)))
            XCTAssertEqual(actual, source, omitted)
            // Even an unsanitized internal plan must not revive legacy kernels.
            var direct = BeautyEffectiveStrengths(); direct.noseSlim = BeautySafetyCaps.noseSlim
            let stage = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
                plan: BeautyEffectPlan(activeDomains: [.nose], effectiveStrengths: direct), face: face)
            XCTAssertTrue(stage.controlPoints.isEmpty, omitted)
            XCTAssertEqual(stage.applyingContinuousNose(to: source), source, omitted)
            parameters.brightness = 0.3
            let mixed = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            let color = BeautyEffectResolver.resolve(parameters: .init(brightness: 0.3), faceGeometry: face)
            let mixedPixels = try pixels(BeautyCPUBackend().execute(request(plan: mixed, observation: observation, source: source)))
            let colorPixels = try pixels(BeautyCPUBackend().execute(request(plan: color, observation: observation, source: source)))
            XCTAssertEqual(mixedPixels, colorPixels, omitted)
            XCTAssertNotEqual(colorPixels, source, omitted)
        }
    }

    func testReusedAndStaleDenseEvidenceDoesNotReenableNasalCircularKernels() throws {
        let face = try ContinuousNoseTestFixture.face()
        let source = raster()
        for freshness: LandmarkGeometryFreshness in [.reused, .stale] {
            let unavailable = FaceGeometry(bounds: face.bounds, faceContour: face.faceContour,
                observedFaceSupport: face.observedFaceSupport, leftEye: face.leftEye, rightEye: face.rightEye,
                nose: face.nose, noseRoot: face.noseRoot, noseTip: face.noseTip,
                outerLips: face.outerLips, upperLips: face.upperLips, lowerLips: face.lowerLips,
                innerLips: face.innerLips, leftEyeSupport: face.leftEyeSupport, rightEyeSupport: face.rightEyeSupport,
                freshness: freshness, observedEyebrowSupport: face.observedEyebrowSupport,
                observedOuterLips: face.observedOuterLips, observedNoseSupport: face.observedNoseSupport,
                denseSupport: face.denseSupport)
            var parameters = BeautyParameters()
            for (_, key, _, cap) in fields { parameters[keyPath: key] = -cap }
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: unavailable)
            XCTAssertTrue(plan.skippedDomains.contains(.nose))
            XCTAssertFalse(plan.activeDomains.contains(.nose))
            for (_, _, key, _) in fields { XCTAssertEqual(plan.effectiveStrengths[keyPath: key], 0) }
            let stage = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height, plan: plan, face: unavailable)
            XCTAssertTrue(stage.controlPoints.isEmpty)
            XCTAssertEqual(stage.applyingContinuousNose(to: source), source)
        }
    }

    func testNoseAndSelectedFaceEyeMouthSiblingsAllSurviveComposition() throws {
        let observation = try ContinuousNoseTestFixture.observation()
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let source = raster()
        let nose = BeautyParameters(noseWingSlim: 0.25)
        let nosePlan = BeautyEffectResolver.resolve(parameters: nose, faceGeometry: face)
        let nosePixels = try pixels(BeautyCPUBackend().execute(request(plan: nosePlan, observation: observation, source: source)))
        let siblings: [(BeautyEffectDomain, WritableKeyPath<BeautyParameters, Float>, Float)] = [
            (.faceShape, \.faceSmall, 0.25), (.eyes, \.eyeSize, 0.2), (.mouth, \.mouthWidth, -0.2)
        ]
        for (domain, key, value) in siblings {
            var sibling = BeautyParameters(); sibling[keyPath: key] = value
            let siblingPlan = BeautyEffectResolver.resolve(parameters: sibling, faceGeometry: face)
            let siblingPixels = try pixels(BeautyCPUBackend().execute(request(plan: siblingPlan, observation: observation, source: source)))
            var mixed = nose; mixed[keyPath: key] = value
            let plan = BeautyEffectResolver.resolve(parameters: mixed, faceGeometry: face)
            XCTAssertTrue(plan.activeDomains.contains(.nose))
            XCTAssertTrue(plan.activeDomains.contains(domain))
            XCTAssertEqual(plan.effectiveStrengths.noseWingSlim, nosePlan.effectiveStrengths.noseWingSlim, accuracy: 0.00001)
            let output = try pixels(BeautyCPUBackend().execute(request(plan: plan, observation: observation, source: source)))
            XCTAssertNotEqual(siblingPixels, source)
            XCTAssertNotEqual(output, source)
            XCTAssertNotEqual(output, nosePixels, "sibling discarded")
            XCTAssertNotEqual(output, siblingPixels, "nose discarded")
            XCTAssertEqual(output, try pixels(BeautyCPUBackend().execute(request(plan: plan, observation: observation, source: source))))
        }
    }

    func testTranslatedTransparentCPUInputKeepsExtentAlphaAndNeutralRecovery() throws {
        let observation = try ContinuousNoseTestFixture.observation()
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        var source = raster()
        for offset in stride(from: 0, to: source.count, by: 4) {
            for channel in 0..<3 { source[offset + channel] /= 2 }
            source[offset + 3] = 173
        }
        let original = CIImage(bitmapData: Data(source), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: colorSpace)
            .transformed(by: CGAffineTransform(translationX: 17, y: -9))
        let neutralPlan = BeautyEffectResolver.resolve(parameters: .init(), faceGeometry: face)
        let activePlan = BeautyEffectResolver.resolve(parameters: .init(noseTipSize: 0.3), faceGeometry: face)
        func perform(_ plan: BeautyEffectPlan) throws -> BeautyBackendResult {
            try BeautyCPUBackend().execute(BeautyBackendRequest(input: .stillImage(original), metadata: metadata,
                plan: plan, selectedFaceSupport: observation))
        }
        let neutral = try perform(neutralPlan)
        let active = try perform(activePlan)
        let a = try pixels(active), n = try pixels(neutral)
        XCTAssertNotEqual(a, n)
        XCTAssertEqual(try image(active).extent, original.extent)
        XCTAssertEqual(try image(active).colorSpace?.name, CGColorSpace.sRGB)
        XCTAssertEqual(active.diagnostics.width, width)
        XCTAssertEqual(active.diagnostics.height, height)
        XCTAssertTrue(stride(from: 3, to: a.count, by: 4).allSatisfy { a[$0] == 173 && n[$0] == 173 })
        XCTAssertEqual(try pixels(perform(neutralPlan)), n)
    }

    func testCPUAndAvailableMetalExecuteNoseIndependentlyFromSameCanonicalSource() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else {
            throw XCTSkip("Metal unavailable; no nasal CPU/Metal parity claim for this run")
        }
        let observation = try ContinuousNoseTestFixture.observation()
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let source = raster()
        for (name, key, _, cap) in fields {
            for sign: Float in [-1, 1] {
                var parameters = BeautyParameters(); parameters[keyPath: key] = cap * sign
                let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
                let cpuRequest = try request(plan: plan, observation: observation, source: source)
                let gpuRequest = try request(plan: plan, observation: observation, source: source, policy: .metal)
                let cpu = try pixels(BeautyCPUBackend().execute(cpuRequest))
                let gpu = try pixels(metal.execute(gpuRequest))
                XCTAssertNotEqual(cpu, source, name)
                XCTAssertEqual(gpu, cpu, name)
                XCTAssertEqual(try pixels(metal.execute(gpuRequest)), gpu, name)
            }
        }
    }

    private func raster() -> [UInt8] {
        (0..<(width * height)).flatMap { index -> [UInt8] in
            let x = index % width, y = index / width
            return [UInt8(40 + (x * 7 + y * 3) % 190), UInt8(30 + (x * 5 + y * 11) % 200),
                    UInt8(35 + (x * 13 + y * 7) % 195), 255]
        }
    }

    private func request(plan: BeautyEffectPlan, observation: BeautyFaceObservation, source: [UInt8],
                         policy: BeautyBackendExecutionPolicy = .cpu) throws -> BeautyBackendRequest {
        let canonical = try BeautyCanonicalStillImage(rgba8Data: Data(source), width: width, height: height,
            rowBytes: width * 4, metadata: metadata)
        return try BeautyBackendRequest(policy: policy, input: .stillImage(canonical.ciImage), metadata: metadata,
            plan: plan, selectedFaceSupport: observation, canonicalImage: canonical)
    }

    private func image(_ result: BeautyBackendResult) throws -> CIImage {
        guard case .stillImage(let image) = result.output else { throw BeautyError.invalidInput }
        return image
    }

    private func pixels(_ result: BeautyBackendResult) throws -> [UInt8] {
        let image = try image(result)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let context = CIContext(options: [.cacheIntermediates: false, .workingColorSpace: colorSpace])
        bytes.withUnsafeMutableBytes { raw in
            context.render(image, toBitmap: raw.baseAddress!, rowBytes: width * 4,
                bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        }
        return bytes
    }

    private func removing(_ component: String, from source: BeautyFaceObservation) -> BeautyFaceObservation {
        BeautyFaceObservation(imageBounds: source.imageBounds, landmarks: source.landmarks,
            observedEyeSupport: component == "eyes" ? [] : source.observedEyeSupport,
            observedEyeOrder: source.observedEyeOrder, observedFaceSupport: source.observedFaceSupport,
            observedEyebrowSupport: component == "brows" ? nil : source.observedEyebrowSupport,
            observedLipSupport: component == "lips" ? nil : source.observedLipSupport,
            observedNoseSupport: component == "nose" ? nil : source.observedNoseSupport, mesh: source.mesh)
    }
}
