import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

final class BeautyBackendSafetyParityTests: XCTestCase {
    func testGeometryContainmentPreservesOutsideProtectedAndAlphaBytes() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let fixture = CPUReferenceFixtureFactory.protectedOutsidePattern(width: 24, height: 20)
        let observation = BeautyFaceObservation(
            imageBounds: CoordinateRect(x: 0.25, y: 0.15, width: 0.50, height: 0.70),
            landmarks: .complete
        )
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 0.8),
            faceGeometry: face
        )
        let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face)
        XCTAssertFalse(points.isEmpty)
        let envelope = localityEnvelope(points, width: fixture.width, height: fixture.height)
        let request = try BeautyBackendParityFixtureFactory.makeRequest(
            policy: .metal,
            fixture: fixture,
            plan: plan,
            stillImage: true
        )
        let result = try metal.execute(request)
        let output = try BeautyBackendParityFixtureFactory.rgbaBytes(from: result.output)
        let changed = try CPUReferenceMetrics.changedIndices(before: fixture.rgba8, after: output)
        XCTAssertTrue(changed.isSubset(of: envelope), "changed=\(changed.count) outside=\(changed.subtracting(envelope).count)")
        XCTAssertTrue(changed.isDisjoint(with: fixture.indices(in: .outside)))
        XCTAssertTrue(changed.isDisjoint(with: fixture.indices(in: .protected)))
        XCTAssertEqual(CPUReferenceMetrics.alphaValues(in: output), fixture.alphaValues)
        XCTAssertEqual(output.count, fixture.rgba8.count)
    }

    func testTranslatedStillImagePreservesContainmentExtentAndFiniteBoundedDeltas() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let fixture = CPUReferenceFixtureFactory.geometryPattern(width: 24, height: 20)
        let face = FaceGeometry.phase46AsymmetricComplete
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 0.55),
            faceGeometry: face
        )
        let cpuRequest = try BeautyBackendParityFixtureFactory.makeRequest(
            policy: .cpu, fixture: fixture, plan: plan, stillImage: true, translated: true
        )
        let gpuRequest = try BeautyBackendParityFixtureFactory.makeRequest(
            policy: .metal, fixture: fixture, plan: plan, stillImage: true, translated: true
        )
        let cpu = try BeautyCPUBackend().execute(cpuRequest)
        let gpu = try metal.execute(gpuRequest)
        guard case .stillImage(let cpuImage) = cpu.output,
              case .stillImage(let gpuImage) = gpu.output
        else { return XCTFail("backend changed still-image kind") }
        XCTAssertEqual(cpuImage.extent, gpuImage.extent)
        XCTAssertEqual(gpuImage.extent, CGRect(x: 3, y: -2, width: 24, height: 20))
        let observation = try BeautyBackendParityFixtureFactory.observation(
            inputKind: .stillImage,
            fixture: fixture,
            before: try BeautyBackendParityFixtureFactory.rgbaBytes(from: cpu.output),
            after: try BeautyBackendParityFixtureFactory.rgbaBytes(from: gpu.output),
            diagnostics: gpu.diagnostics
        )
        XCTAssertTrue(observation.preservesExtent)
        XCTAssertTrue(observation.meanRGBDelta.isFinite)
        XCTAssertLessThanOrEqual(observation.maxChannelDelta, 12)
        XCTAssertLessThan(observation.meanRGBDelta, 8.0)
    }

    func testCompositionCollisionAndRejectedUnitRemainAggregateAndSourceBound() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 8, height: 6)
        let metadata = BeautyBackendParityFixtureFactory.metadata
        let canonical = try BeautyCanonicalStillImage(
            rgba8Data: Data(fixture.rgba8),
            width: fixture.width,
            height: fixture.height,
            rowBytes: fixture.rowBytes,
            metadata: metadata
        )
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(brightness: 0.25))
        let summary = BeautyLocalRetouchCompositionSummary(
            acceptedUnitCount: 1,
            rejectedUnitCount: 1,
            ownedPixelCount: 2,
            changedPixelCount: 1,
            changedOutsideUnionPixelCount: 0,
            collisionPixelCount: 1
        )
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .stillImage(canonical.ciImage),
            metadata: metadata,
            plan: plan,
            canonicalImage: canonical,
            compositionSummary: summary
        )
        let result = try metal.execute(request)
        XCTAssertEqual(result.diagnostics.failureCount, 1)
        XCTAssertEqual(result.diagnostics.collisionCount, 1)
        XCTAssertEqual(result.diagnostics.unitCount, 1)
        XCTAssertEqual(result.diagnostics.width, fixture.width)
        XCTAssertEqual(result.diagnostics.height, fixture.height)
        XCTAssertTrue(result.diagnostics.preservesExtent)
        XCTAssertTrue(result.diagnostics.preservesAlpha)
    }

    func testNoFaceMalformedAndRejectedLocalUnitsDoNotEraseColorSibling() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 24, height: 20)
        let colorPlan = BeautyEffectResolver.resolve(parameters: BeautyParameters(brightness: 0.3))
        let unsupportedGeometryPlan = BeautyEffectResolver.resolve(parameters: BeautyParameters(faceSlim: 0.8))
        let malformed = BeautyFaceObservation(landmarks: .missingRequiredGeometry)
        let backend = metal

        let noFaceRequest = try BeautyBackendParityFixtureFactory.makeRequest(
            policy: .metal, fixture: fixture, plan: unsupportedGeometryPlan, stillImage: true
        )
        let noFaceBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: backend.execute(noFaceRequest).output)
        XCTAssertEqual(noFaceBytes, fixture.rgba8)

        let malformedRequest = try BeautyBackendRequest(
            policy: .metal,
            input: .stillImage(BeautyBackendParityFixtureFactory.makeStillImage(fixture)),
            metadata: BeautyBackendParityFixtureFactory.metadata,
            plan: colorPlan,
            selectedFaceSupport: malformed
        )
        let colorRequest = try BeautyBackendParityFixtureFactory.makeRequest(
            policy: .metal, fixture: fixture, plan: colorPlan, stillImage: true
        )
        let malformedBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: backend.execute(malformedRequest).output)
        let colorBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: backend.execute(colorRequest).output)
        XCTAssertEqual(malformedBytes, colorBytes)
        XCTAssertNotEqual(colorBytes, fixture.rgba8)
        XCTAssertEqual(malformedBytes.count, fixture.rgba8.count)
    }

    private func localityEnvelope(
        _ points: [WarpControlPoint],
        width: Int,
        height: Int
    ) -> Set<Int> {
        var result = Set<Int>()
        for row in 0..<height {
            let y = (Float(row) + 0.5) / Float(height)
            for column in 0..<width {
                let x = (Float(column) + 0.5) / Float(width)
                if points.contains(where: { point in
                    let dx = x - point.target.x
                    let dy = y - point.target.y
                    return (dx * dx + dy * dy).squareRoot() <= point.radius
                }) {
                    result.insert(row * width + column)
                }
            }
        }
        return result
    }
}
