import CoreVideo
import Foundation
import Metal
import XCTest
import BeautyCore
import BeautyDetection
import BeautyRender
@testable import BeautyEffects

final class BeautyMetalGeometryPassTests: XCTestCase {
    func testGeneratedInventoryUsesOneUnifiedFiniteBoundedPointSource() {
        let face = FaceGeometry.phase46AsymmetricComplete
        let rows = geometryRows()
        XCTAssertEqual(rows.count, 44)
        XCTAssertEqual(Set(rows.map(\.name)).count, rows.count)

        for row in rows {
            var parameters = BeautyParameters()
            parameters[keyPath: row.keyPath] = 0.8
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face)
            XCTAssertTrue(points.allSatisfy { point in
                point.source.x.isFinite && point.source.y.isFinite &&
                    point.target.x.isFinite && point.target.y.isFinite &&
                    point.radius.isFinite && point.radius > 0 && point.radius <= 1 &&
                    point.falloff.isFinite && point.falloff >= 1 && point.falloff <= 3
            }, row.name)
            XCTAssertTrue(points.allSatisfy { point in
                (0...1).contains(point.source.x) && (0...1).contains(point.source.y) &&
                    (0...1).contains(point.target.x) && (0...1).contains(point.target.y)
            }, row.name)
            XCTAssertLessThanOrEqual(points.count, BeautyMetalGeometryParameters.maximumPointCount, row.name)
        }
    }

    func testMetalGeometryMatchesCPUDirectionLocalityAndAlpha() throws {
        guard let runtime = makeRuntime() else { return }
        let fixture = geometryFixture(width: 96, height: 96)
        let face = FaceGeometry.phase46AsymmetricComplete
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 0.8),
            faceGeometry: face
        )
        let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face)
        XCTAssertFalse(points.isEmpty)
        let payload = points.compactMap { point -> BeautyMetalWarpPoint? in
            guard point.source.x.isFinite, point.source.y.isFinite,
                  point.target.x.isFinite, point.target.y.isFinite,
                  point.radius.isFinite, point.strength.isFinite, point.falloff.isFinite
            else { return nil }
            return try? BeautyMetalWarpPoint(
                sourceX: min(max(point.source.x, 0), 1),
                sourceY: min(max(point.source.y, 0), 1),
                targetX: min(max(point.target.x, 0), 1),
                targetY: min(max(point.target.y, 0), 1),
                radius: min(max(point.radius, 0.001), 1),
                strength: min(max(point.strength, -1), 1),
                falloff: min(max(point.falloff, 1), 3)
            )
        }
        XCTAssertFalse(payload.isEmpty)
        let metal = try runtime.render(
            width: fixture.width,
            height: fixture.height,
            rgba8Bytes: fixture.rgba8,
            passes: [.geometry(try BeautyMetalGeometryParameters(points: payload))]
        )
        let source = fixture.rgba8
        XCTAssertEqual(metal.count, source.count)
        XCTAssertEqual(alphaValues(metal), alphaValues(source))

        let changed = Set(0..<(source.count / 4)).filter { index in
            let offset = index * 4
            return Array(metal[offset..<offset + 3]) != Array(source[offset..<offset + 3])
        }
        XCTAssertFalse(changed.isEmpty)
        let envelope = localityEnvelope(points, width: fixture.width, height: fixture.height)
        XCTAssertTrue(changed.isSubset(of: envelope))

    }

    func testNoFaceGeometryIsExactNoOpWhileColorSiblingContinuesAndRequestsRecover() throws {
        guard let runtime = makeRuntime() else { return }
        let fixture = geometryFixture(width: 24, height: 20)
        let geometryPlan = BeautyEffectResolver.resolve(parameters: BeautyParameters(faceSlim: 0.8))
        let colorPlan = BeautyEffectResolver.resolve(parameters: BeautyParameters(brightness: 0.3))
        let backend = BeautyMetalBackend(runtime: runtime)

        let noFaceGeometry = try makeRequest(fixture: fixture, plan: geometryPlan, observation: nil)
        let first = try rgba(backend.execute(noFaceGeometry))
        XCTAssertEqual(first, fixture.rgba8)
        let color = try makeRequest(fixture: fixture, plan: colorPlan, observation: nil)
        XCTAssertNotEqual(try rgba(backend.execute(color)), fixture.rgba8)

        let supported = BeautyFaceObservation(
            imageBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
            landmarks: .complete
        )
        let supportedPlan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 0.8),
            faceGeometry: BeautyFaceGeometryAdapter.makeGeometry(from: supported)
        )
        let valid = try makeRequest(fixture: fixture, plan: supportedPlan, observation: supported)
        let recovered = try rgba(backend.execute(valid))
        XCTAssertNotEqual(recovered, fixture.rgba8)
        XCTAssertEqual(recovered, try rgba(backend.execute(valid)))

        XCTAssertEqual(first, try rgba(backend.execute(noFaceGeometry)))
    }

    func testStillImageExtentAndCompositionCollisionRemainRequestOwned() throws {
        guard let runtime = makeRuntime() else { return }
        let fixture = geometryFixture(width: 8, height: 6)
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let image = CIImage(
            bitmapData: Data(fixture.rgba8),
            bytesPerRow: fixture.width * 4,
            size: CGSize(width: fixture.width, height: fixture.height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(faceSlim: 0.4))
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let canonical = try BeautyCanonicalStillImage(
            rgba8Data: Data(fixture.rgba8),
            width: fixture.width,
            height: fixture.height,
            rowBytes: fixture.width * 4,
            metadata: metadata
        )
        let summary = BeautyLocalRetouchCompositionSummary(
            acceptedUnitCount: 2,
            rejectedUnitCount: 1,
            ownedPixelCount: 3,
            changedPixelCount: 2,
            changedOutsideUnionPixelCount: 0,
            collisionPixelCount: 1
        )
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .stillImage(image),
            metadata: metadata,
            plan: plan,
            canonicalImage: canonical,
            compositionSummary: summary
        )
        let result = try BeautyMetalBackend(runtime: runtime).execute(request)
        guard case .stillImage(let output) = result.output else {
            return XCTFail("Metal changed the output kind")
        }
        XCTAssertEqual(output.extent, image.extent)
        XCTAssertEqual(result.diagnostics.collisionCount, summary.collisionPixelCount)
        XCTAssertEqual(result.diagnostics.unitCount, summary.acceptedUnitCount)
    }

    private struct GeometryRow {
        let name: String
        let keyPath: WritableKeyPath<BeautyParameters, Float>
        let signed: Bool
    }

    private func geometryRows() -> [GeometryRow] {
        [
            row("faceSlim", \.faceSlim), row("faceSmall", \.faceSmall), row("faceVShape", \.faceVShape),
            row("jawSlim", \.jawSlim), row("chinLength", \.chinLength, signed: true), row("faceContourSmooth", \.faceContourSmooth),
            row("templeFullness", \.templeFullness), row("cheekboneSlim", \.cheekboneSlim), row("chinTaper", \.chinTaper),
            row("eyeSize", \.eyeSize), row("eyeDistance", \.eyeDistance, signed: true), row("eyeYPosition", \.eyeYPosition, signed: true),
            row("eyeTailLift", \.eyeTailLift), row("eyeHeight", \.eyeHeight), row("eyeLength", \.eyeLength),
            row("upperEyelidLift", \.upperEyelidLift), row("pupilSize", \.pupilSize), row("gazeCorrection", \.gazeCorrection),
            row("lowerEyelidDrop", \.lowerEyelidDrop), row("eyeTilt", \.eyeTilt, signed: true), row("innerCornerOpen", \.innerCornerOpen),
            row("outerCornerOpen", \.outerCornerOpen), row("eyeSymmetry", \.eyeSymmetry), row("eyebrowYPosition", \.eyebrowYPosition, signed: true),
            row("eyebrowThickness", \.eyebrowThickness, signed: true), row("eyebrowLength", \.eyebrowLength, signed: true), row("eyebrowSpacing", \.eyebrowSpacing, signed: true),
            row("eyebrowHeadSpacing", \.eyebrowHeadSpacing, signed: true), row("eyebrowTilt", \.eyebrowTilt, signed: true), row("eyebrowPeakDefinition", \.eyebrowPeakDefinition),
            row("noseSlim", \.noseSlim), row("noseWingSlim", \.noseWingSlim), row("noseTipSize", \.noseTipSize, signed: true), row("noseBridge", \.noseBridge),
            row("noseRootNarrowing", \.noseRootNarrowing), row("noseTipLift", \.noseTipLift), row("mouthSize", \.mouthSize, signed: true),
            row("mouthWidth", \.mouthWidth, signed: true), row("smile", \.smile), row("mouthYPosition", \.mouthYPosition, signed: true),
            row("mouthTilt", \.mouthTilt, signed: true), row("mouthXPosition", \.mouthXPosition, signed: true), row("lipPeakDefinition", \.lipPeakDefinition),
            row("lipPlump", \.lipPlump),
        ]
    }

    private func row(_ name: String, _ keyPath: WritableKeyPath<BeautyParameters, Float>, signed: Bool = false) -> GeometryRow {
        GeometryRow(name: name, keyPath: keyPath, signed: signed)
    }

    private func makeRuntime() -> BeautyMetalRuntime? {
        do { return try BeautyMetalRuntime() }
        catch BeautyError.metalUnavailable { return nil }
        catch { XCTFail("unexpected runtime setup failure: \(error)"); return nil }
    }

    private func geometryFixture(width: Int, height: Int) -> (width: Int, height: Int, rgba8: [UInt8]) {
        var bytes: [UInt8] = []
        for y in 0..<height {
            for x in 0..<width {
                let value = (x * 13 + y * 17) % 256
                bytes.append(contentsOf: [UInt8(value), UInt8((value + x * 3) % 256), UInt8((value + y * 5) % 256), 255])
            }
        }
        return (width, height, bytes)
    }

    private func makeRequest(
        fixture: (width: Int, height: Int, rgba8: [UInt8]),
        plan: BeautyEffectPlan,
        observation: BeautyFaceObservation?
    ) throws -> BeautyBackendRequest {
        let pixelBuffer = try makePixelBuffer(width: fixture.width, height: fixture.height, bytes: bgra(fixture.rgba8))
        return try BeautyBackendRequest(
            policy: .metal,
            input: .pixelBuffer(pixelBuffer),
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            plan: plan,
            selectedFaceSupport: observation
        )
    }

    private func rgba(_ result: BeautyBackendResult) throws -> [UInt8] {
        guard case .pixelBuffer(let output) = result.output,
              CVPixelBufferLockBaseAddress(output, .readOnly) == kCVReturnSuccess
        else { throw BeautyError.invalidInput }
        defer { CVPixelBufferUnlockBaseAddress(output, .readOnly) }
        let width = CVPixelBufferGetWidth(output)
        let height = CVPixelBufferGetHeight(output)
        let rowBytes = CVPixelBufferGetBytesPerRow(output)
        guard let base = CVPixelBufferGetBaseAddress(output) else { throw BeautyError.invalidInput }
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        bytes.withUnsafeMutableBytes { destination in
            for row in 0..<height {
                memcpy(destination.baseAddress!.advanced(by: row * width * 4), base.advanced(by: row * rowBytes), width * 4)
            }
        }
        return bgra(bytes)
    }

    private func makePixelBuffer(width: Int, height: Int, bytes: [UInt8]) throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:],
        ]
        guard CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &pixelBuffer) == kCVReturnSuccess,
              let pixelBuffer,
              CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess
        else { throw BeautyError.pixelBufferCreationFailed }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { throw BeautyError.invalidInput }
        let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        bytes.withUnsafeBytes { source in
            for row in 0..<height {
                memcpy(base.advanced(by: row * rowBytes), source.baseAddress!.advanced(by: row * width * 4), width * 4)
            }
        }
        return pixelBuffer
    }

    private func bgra(_ bytes: [UInt8]) -> [UInt8] {
        var output = bytes
        for offset in stride(from: 0, to: output.count, by: 4) { output.swapAt(offset, offset + 2) }
        return output
    }

    private func alphaValues(_ bytes: [UInt8]) -> [UInt8] {
        stride(from: 3, to: bytes.count, by: 4).map { bytes[$0] }
    }

    private func localityEnvelope(_ points: [WarpControlPoint], width: Int, height: Int) -> Set<Int> {
        var result = Set<Int>()
        for row in 0..<height {
            let y = (Float(row) + 0.5) / Float(height)
            for column in 0..<width {
                let x = (Float(column) + 0.5) / Float(width)
                if points.contains(where: { point in
                    let dx = x - point.target.x
                    let dy = y - point.target.y
                    return dx * dx + dy * dy < point.radius * point.radius
                }) {
                    result.insert(row * width + column)
                }
            }
        }
        return result
    }
}
