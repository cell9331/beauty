import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class FaceContourSmoothRepairTests: XCTestCase {
    func testFACE01ExistingProviderEmitsOneCenteredObservedContourCorrection() throws {
        let provider = FaceShapeWarpProvider()
        let face = Self.face

        for requested in [BeautySafetyCaps.faceContourSmooth, BeautySafetyCaps.faceContourSmooth * 0.5] {
            let first = provider.fieldEmissions(
                face: face,
                strengths: strengths(faceContourSmooth: requested)
            ).faceContourSmooth
            let second = provider.fieldEmissions(
                face: face,
                strengths: strengths(faceContourSmooth: requested)
            ).faceContourSmooth
            let contour = try XCTUnwrap(face.observedFaceSupport?.contour)
            let minimumXIndex = try XCTUnwrap(contour.indices.min { contour[$0].x < contour[$1].x })
            let maximumXIndex = try XCTUnwrap(contour.indices.max { contour[$0].x < contour[$1].x })
            let eligibleIndices = [1, 3, 4, 5, 10, 11, 12, 14]

            XCTAssertEqual(first, second)
            XCTAssertEqual(first.map(\.source), eligibleIndices.map { contour[$0] })
            XCTAssertFalse(first.isEmpty)
            XCTAssertTrue(first.allSatisfy {
                $0.source.y == $0.target.y &&
                    $0.radius == face.bounds.width * 0.014 &&
                    $0.strength == requested &&
                    $0.falloff == 2 &&
                    $0.source.x.isFinite && $0.target.x.isFinite
            })
            XCTAssertFalse(first.contains { $0.source == contour.first || $0.source == contour.last })
            XCTAssertFalse(first.contains { $0.source == contour[minimumXIndex] || $0.source == contour[maximumXIndex] })

            let displacements = first.map { $0.target.x - $0.source.x }
            let ceiling = 0.004 * face.bounds.width * requested / BeautySafetyCaps.faceContourSmooth
            XCTAssertTrue(displacements.allSatisfy { abs($0) <= ceiling + 0.000_001 })
            XCTAssertEqual(displacements.reduce(0, +), 0, accuracy: 0.000_001)
            XCTAssertEqual(displacements.reduce(0, +) / Float(displacements.count), 0, accuracy: 0.000_001)

            var proposed = contour
            for point in first {
                proposed[try XCTUnwrap(contour.firstIndex(of: point.source))] = point.target
            }
            XCTAssertLessThan(
                roughness(proposed, indices: eligibleIndices),
                roughness(contour, indices: eligibleIndices)
            )
            XCTAssertLessThan(roughness(proposed), roughness(contour))

            for sibling in siblingEmissions(face: face) {
                XCTAssertNotEqual(first, sibling)
                XCTAssertFalse(first.allSatisfy(sibling.contains))
            }
        }

        let reversed = Self.face(contour: Array(Self.contour.reversed()))
        let reversedFirst = provider.fieldEmissions(
            face: reversed,
            strengths: strengths(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
        ).faceContourSmooth
        let reversedSecond = provider.fieldEmissions(
            face: reversed,
            strengths: strengths(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
        ).faceContourSmooth
        XCTAssertFalse(reversedFirst.isEmpty)
        XCTAssertEqual(reversedFirst, reversedSecond)

        let quantized = Self.face(contour: Self.contour.enumerated().map { index, point in
            SIMD2<Float>(point.x + (index.isMultiple(of: 2) ? 0.000_000_12 : -0.000_000_12), point.y)
        })
        XCTAssertFalse(provider.fieldEmissions(
            face: quantized,
            strengths: strengths(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
        ).faceContourSmooth.isEmpty)
    }

    func testFACE01ProviderFailsOnlyNamedFieldClosedForInvalidSupportAndInputs() {
        let provider = FaceShapeWarpProvider()
        let validSibling = strengths(
            faceSlim: BeautySafetyCaps.faceSlim,
            faceContourSmooth: BeautySafetyCaps.faceContourSmooth
        )
        let missing = Self.face(observedSupport: nil, useDefaultSupport: false)
        let malformedSupports: [BeautyFaceSemanticSupport?] = [
            BeautyFaceSemanticSupport(contour: [], medianLine: nil, apexIndex: nil),
            BeautyFaceSemanticSupport(contour: [SIMD2<Float>(.nan, 0.5)], medianLine: nil, apexIndex: nil),
            BeautyFaceSemanticSupport(
                contour: [
                    SIMD2<Float>(0.20, 0.30), SIMD2<Float>(0.20, 0.45),
                    SIMD2<Float>(0.20, 0.60), SIMD2<Float>(0.20, 0.75),
                ],
                medianLine: nil,
                apexIndex: nil
            ),
        ]

        let missingEmissions = provider.fieldEmissions(face: missing, strengths: validSibling)
        XCTAssertTrue(missingEmissions.faceContourSmooth.isEmpty)
        XCTAssertFalse(missingEmissions.faceSlim.isEmpty)
        XCTAssertEqual(missingEmissions.sanitizing(validSibling).faceContourSmooth, 0)
        XCTAssertEqual(missingEmissions.sanitizing(validSibling).faceSlim, BeautySafetyCaps.faceSlim)

        for support in malformedSupports {
            XCTAssertTrue(provider.fieldEmissions(
                face: Self.face(observedSupport: support, useDefaultSupport: false),
                strengths: strengths(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
            ).faceContourSmooth.isEmpty)
        }

        for invalid in [Float.zero, -0.25, Float.nan, Float.infinity, -Float.infinity] {
            XCTAssertTrue(provider.fieldEmissions(
                face: Self.face,
                strengths: strengths(faceContourSmooth: invalid)
            ).faceContourSmooth.isEmpty)
        }
    }

    func testFACE01GeneratedCPUFixtureMeetsFrozenContract() throws {
        let width = 1_000
        let height = 1_000
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let source = Self.generatedImage(width: width, height: height, colorSpace: colorSpace)
        let sourceBytes = renderedBytes(source, width: width, height: height, colorSpace: colorSpace)

        let neutral = render(
            source,
            parameters: BeautyParameters(),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        let active = render(
            source,
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        let repeated = render(
            source,
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        let frozenSiblings = [
            BeautyParameters(faceSmall: 0.35),
            BeautyParameters(faceSlim: 0.35),
        ].map {
            render(source, parameters: $0, width: width, height: height, colorSpace: colorSpace)
        }
        let strengtheningSiblings = [
            BeautyParameters(faceVShape: 0.35),
            BeautyParameters(jawSlim: 0.35),
            BeautyParameters(chinTaper: 0.25),
        ].map {
            render(source, parameters: $0, width: width, height: height, colorSpace: colorSpace)
        }

        XCTAssertEqual(neutral, sourceBytes)
        XCTAssertEqual(active, repeated)
        XCTAssertTrue(stride(from: 3, to: active.count, by: 4).allSatisfy { active[$0] == 255 })

        let snapshot = try semanticSnapshot(
            source: sourceBytes,
            neutral: neutral,
            candidate: active,
            frozenSiblings: frozenSiblings,
            strengtheningSiblings: strengtheningSiblings,
            width: width,
            height: height
        )
        XCTAssertGreaterThanOrEqual(snapshot.sourceTarget.changedPixels, 1_000)
        XCTAssertGreaterThanOrEqual(snapshot.sourceTarget.absoluteRGBDelta, 3_000)
        XCTAssertGreaterThanOrEqual(snapshot.neutralTarget.changedPixels, 1_000)
        XCTAssertGreaterThanOrEqual(snapshot.neutralTarget.absoluteRGBDelta, 3_000)
        // Preserve every original FACE-01 threshold. This positive result is
        // a generated CPU gate, not portrait or backend qualification.
        let predicates: [String: Bool] = [
            "source_direction": snapshot.sourceSignedMarginQ16 >= 16,
            "neutral_direction": snapshot.neutralSignedMarginQ16 >= 16,
            "frozen_siblings": snapshot.frozenSiblingDistinctMarginsQ16.allSatisfy { $0 >= 16 },
            "strengthening_siblings": snapshot.strengtheningSiblingDistinctMarginsQ16.allSatisfy { $0 >= 16 },
            "outside_pixels": snapshot.outside.changedPixels <= 500,
            "outside_rgb": snapshot.outside.absoluteRGBDelta <= 1_500,
            "central_pixels": snapshot.central.changedPixels <= 128,
            "central_rgb": snapshot.central.absoluteRGBDelta <= 512,
        ]
        XCTAssertTrue(predicates.values.allSatisfy { $0 }, "FACE-01 generated gate must pass: \(predicates)")
        XCTAssertEqual(snapshot.background.changedPixels, 0)
        XCTAssertEqual(snapshot.background.absoluteRGBDelta, 0)
        XCTAssertEqual(snapshot.watermark.changedPixels, 0)
        XCTAssertEqual(snapshot.watermark.absoluteRGBDelta, 0)
    }

    func testFACE01GeneratedRoughSilhouetteHasSmootherMeasuredBoundary() throws {
        let width = 1_000
        let height = 1_000
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let sourceImage = Self.generatedSilhouette(width: width, height: height, colorSpace: colorSpace)
        let source = renderedBytes(sourceImage, width: width, height: height, colorSpace: colorSpace)
        let candidate = render(
            sourceImage,
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        let sourceRoughness = try silhouetteRoughness(source, width: width, height: height)
        let candidateRoughness = try silhouetteRoughness(candidate, width: width, height: height)
        let repeated = render(
            sourceImage,
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        XCTAssertGreaterThan(sourceRoughness, 0.5)
        XCTAssertLessThan(candidateRoughness, sourceRoughness / 2)
        XCTAssertEqual(candidate, repeated)
        XCTAssertGreaterThan(signal(source, candidate, regions: Self.targetRegions, width: width, height: height).changedPixels, 0)
        XCTAssertEqual(signal(source, candidate, regions: Self.centralRegions, width: width, height: height).changedPixels, 0)
        XCTAssertEqual(signal(source, candidate, regions: Self.backgroundRegions, width: width, height: height).changedPixels, 0)

        let offsetImage = Self.generatedSilhouette(
            width: width, height: height, colorSpace: colorSpace,
            contour: Self.contour, rasterizeInward: true
        )
        let offsetSource = renderedBytes(offsetImage, width: width, height: height, colorSpace: colorSpace)
        let offsetCandidate = render(
            offsetImage,
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            width: width,
            height: height,
            colorSpace: colorSpace
        )
        let offsetSourceRoughness = try silhouetteRoughness(offsetSource, width: width, height: height)
        let offsetCandidateRoughness = try silhouetteRoughness(offsetCandidate, width: width, height: height)
        XCTAssertGreaterThan(offsetSourceRoughness, 0.5)
        XCTAssertLessThan(offsetCandidateRoughness, offsetSourceRoughness / 2)
        XCTAssertEqual(signal(offsetSource, offsetCandidate, regions: Self.centralRegions, width: width, height: height).changedPixels, 0)
        XCTAssertEqual(signal(offsetSource, offsetCandidate, regions: Self.backgroundRegions, width: width, height: height).changedPixels, 0)

        // A genuinely straight observed side has no contour residual to repair.
        let straightContour = Self.contour.enumerated().map { index, point in
            SIMD2<Float>(index <= 6 ? 0.20 : index >= 9 ? 0.80 : point.x, point.y)
        }
        let straightFace = Self.face(contour: straightContour)
        XCTAssertTrue(FaceShapeWarpProvider().fieldEmissions(
            face: straightFace,
            strengths: strengths(faceContourSmooth: BeautySafetyCaps.faceContourSmooth)
        ).faceContourSmooth.isEmpty)
        let straightImage = Self.generatedSilhouette(
            width: width, height: height, colorSpace: colorSpace, contour: straightContour
        )
        let straightPlan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceContourSmooth: 0.25), faceGeometry: straightFace
        )
        let straightOutput = BeautyGeometryEffectPipeline.applyMVPProxy(
            to: straightImage, plan: straightPlan, face: straightFace
        )
        XCTAssertEqual(
            renderedBytes(straightImage, width: width, height: height, colorSpace: colorSpace),
            renderedBytes(straightOutput, width: width, height: height, colorSpace: colorSpace)
        )
    }

    func testFACE01SubpixelCorrectionPreservesNeutralAlphaAndCentralRegionAcrossSizes() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        for (width, height) in [(320, 320), (768, 512)] {
            let image = Self.generatedImage(width: width, height: height, colorSpace: colorSpace)
            var source = renderedBytes(image, width: width, height: height, colorSpace: colorSpace)
            let transparentColumn = Int((0.22 * Float(width)).rounded())
            let transparentOffset = ((height / 2) * width + transparentColumn) * 4
            source[transparentOffset + 3] = 0

            let neutral = FaceContourSubpixelRefiner.refine(
                source, width: width, height: height, face: Self.face, strength: 0
            )
            let first = FaceContourSubpixelRefiner.refine(
                source,
                width: width,
                height: height,
                face: Self.face,
                strength: BeautySafetyCaps.faceContourSmooth
            )
            let repeated = FaceContourSubpixelRefiner.refine(
                source,
                width: width,
                height: height,
                face: Self.face,
                strength: BeautySafetyCaps.faceContourSmooth
            )
            XCTAssertEqual(neutral, source)
            XCTAssertEqual(first, repeated)
            XCTAssertEqual(
                Array(first[transparentOffset..<(transparentOffset + 4)]),
                Array(source[transparentOffset..<(transparentOffset + 4)])
            )
            XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy { first[$0] == source[$0] })
            XCTAssertGreaterThan(signal(source, first, regions: Self.targetRegions, width: width, height: height).changedPixels, 0)
            XCTAssertEqual(signal(source, first, regions: Self.centralRegions, width: width, height: height).absoluteRGBDelta, 0)
            XCTAssertEqual(signal(source, first, regions: Self.backgroundRegions, width: width, height: height).absoluteRGBDelta, 0)
        }
    }

    func testFACE01StillImageCPUAndMetalUseTheSameContourRefinement() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let width = 320
        let height = 320
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let image = Self.generatedImage(width: width, height: height, colorSpace: colorSpace)
        let observation = BeautyFaceObservation(
            imageBounds: CoordinateRect(x: 0.10, y: 0.20, width: 0.80, height: 0.64),
            observedFaceSupport: BeautyObservedFaceSupport(contour: Self.contour.map {
                CoordinatePoint(x: Double($0.x), y: Double($0.y))
            })
        )
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceContourSmooth: 0.25),
            faceGeometry: face
        )
        XCTAssertFalse(FaceShapeWarpProvider().fieldEmissions(
            face: face, strengths: plan.effectiveStrengths
        ).faceContourSmooth.isEmpty)

        func request(_ policy: BeautyBackendExecutionPolicy) throws -> BeautyBackendRequest {
            try BeautyBackendRequest(
                policy: policy,
                input: .stillImage(image),
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                plan: plan,
                selectedFaceSupport: observation
            )
        }
        let cpu = try BeautyCPUBackend().execute(request(.cpu))
        let gpu = try metal.execute(request(.metal))
        guard case .stillImage(let cpuImage) = cpu.output,
              case .stillImage(let gpuImage) = gpu.output else {
            return XCTFail("FACE-01 backend changed still-image output kind")
        }
        XCTAssertEqual(cpuImage.extent, image.extent)
        XCTAssertEqual(gpuImage.extent, image.extent)
        XCTAssertEqual(gpuImage.colorSpace?.name, CGColorSpace.sRGB)
        let source = renderedBytes(image, width: width, height: height, colorSpace: colorSpace)
        let cpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: cpu.output)
        let gpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: gpu.output)
        XCTAssertGreaterThan(signal(source, cpuBytes, regions: Self.targetRegions, width: width, height: height).changedPixels, 0)
        XCTAssertEqual(stride(from: 3, to: cpuBytes.count, by: 4).map { cpuBytes[$0] },
                       stride(from: 3, to: gpuBytes.count, by: 4).map { gpuBytes[$0] })
        let channelDeltas = zip(cpuBytes, gpuBytes).enumerated().compactMap { index, pair -> Int? in
            index.isMultiple(of: 4) || index % 4 == 1 || index % 4 == 2
                ? abs(Int(pair.0) - Int(pair.1)) : nil
        }
        XCTAssertLessThanOrEqual(channelDeltas.max() ?? 0, BeautyBackendParityFixtureFactory.activeMaxChannelDelta)
        XCTAssertLessThan(Double(channelDeltas.reduce(0, +)) / Double(channelDeltas.count),
                          BeautyBackendParityFixtureFactory.activeMeanRGBDelta)
    }

    private func siblingEmissions(face: FaceGeometry) -> [[WarpControlPoint]] {
        let provider = FaceShapeWarpProvider()
        let emissions = provider.fieldEmissions(
            face: face,
            strengths: strengths(
                faceSlim: BeautySafetyCaps.faceSlim,
                faceSmall: BeautySafetyCaps.faceSmall,
                faceVShape: BeautySafetyCaps.faceVShape,
                jawSlim: BeautySafetyCaps.jawSlim
            )
        )
        return [emissions.faceSlim, emissions.faceSmall, emissions.faceVShape, emissions.jawSlim]
    }

    private func strengths(
        faceSlim: Float = 0,
        faceSmall: Float = 0,
        faceVShape: Float = 0,
        jawSlim: Float = 0,
        faceContourSmooth: Float = 0
    ) -> BeautyEffectiveStrengths {
        var value = BeautyEffectiveStrengths()
        value.faceSlim = faceSlim
        value.faceSmall = faceSmall
        value.faceVShape = faceVShape
        value.jawSlim = jawSlim
        value.faceContourSmooth = faceContourSmooth
        return value
    }

    private func roughness(_ contour: [SIMD2<Float>], indices: [Int]? = nil) -> Float {
        let evaluated = indices ?? Array(1..<(contour.count - 1))
        return evaluated.reduce(0) {
            $0 + abs(contour[$1].x - (contour[$1 - 1].x + contour[$1 + 1].x) / 2)
        }
    }

    private func render(
        _ image: CIImage,
        parameters: BeautyParameters,
        width: Int,
        height: Int,
        colorSpace: CGColorSpace
    ) -> [UInt8] {
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: Self.face)
        let output = BeautyGeometryEffectPipeline.applyMVPProxy(to: image, plan: plan, face: Self.face)
        return renderedBytes(output, width: width, height: height, colorSpace: colorSpace)
    }

    private func renderedBytes(
        _ image: CIImage,
        width: Int,
        height: Int,
        colorSpace: CGColorSpace
    ) -> [UInt8] {
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ])
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        bytes.withUnsafeMutableBytes { rawBytes in
            context.render(
                image,
                toBitmap: rawBytes.baseAddress!,
                rowBytes: width * 4,
                bounds: CGRect(x: 0, y: 0, width: width, height: height),
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return bytes
    }
}

private extension FaceContourSmoothRepairTests {
    struct Region {
        let minXPPM: Int
        let maxXPPM: Int
        let minYPPM: Int
        let maxYPPM: Int
    }

    struct Signal {
        var changedPixels = 0
        var absoluteRGBDelta = 0
    }

    struct Snapshot {
        let sourceTarget: Signal
        let neutralTarget: Signal
        let sourceSignedMarginQ16: Int64
        let neutralSignedMarginQ16: Int64
        let frozenSiblingDistinctMarginsQ16: [Int64]
        let strengtheningSiblingDistinctMarginsQ16: [Int64]
        let outside: Signal
        let central: Signal
        let background: Signal
        let watermark: Signal
    }

    static let targetRegions = [
        Region(minXPPM: 100_000, maxXPPM: 240_000, minYPPM: 280_000, maxYPPM: 820_000),
        Region(minXPPM: 760_000, maxXPPM: 920_000, minYPPM: 280_000, maxYPPM: 820_000),
    ]
    static let centralRegions = [
        Region(minXPPM: 250_000, maxXPPM: 750_000, minYPPM: 280_000, maxYPPM: 820_000),
    ]
    static let backgroundRegions = [
        Region(minXPPM: 0, maxXPPM: 90_000, minYPPM: 80_000, maxYPPM: 820_000),
        Region(minXPPM: 930_000, maxXPPM: 1_000_000, minYPPM: 80_000, maxYPPM: 820_000),
    ]
    static let watermarkRegions = [
        Region(minXPPM: 820_000, maxXPPM: 980_000, minYPPM: 920_000, maxYPPM: 985_000),
    ]

    static let contour: [SIMD2<Float>] = [
        .init(0.190, 0.300), .init(0.215, 0.360), .init(0.165, 0.430),
        .init(0.220, 0.500), .init(0.175, 0.580), .init(0.225, 0.660),
        .init(0.185, 0.750), .init(0.420, 0.815), .init(0.580, 0.815),
        .init(0.815, 0.750), .init(0.775, 0.660), .init(0.825, 0.580),
        .init(0.780, 0.500), .init(0.835, 0.430), .init(0.785, 0.360),
        .init(0.810, 0.300),
    ]

    static var face: FaceGeometry { face(contour: contour) }

    static func face(
        contour: [SIMD2<Float>] = contour,
        observedSupport: BeautyFaceSemanticSupport? = nil,
        useDefaultSupport: Bool = true
    ) -> FaceGeometry {
        FaceGeometry(
            bounds: FaceBounds(x: 0.10, y: 0.20, width: 0.80, height: 0.64),
            faceContour: contour,
            observedFaceSupport: useDefaultSupport
                ? BeautyFaceSemanticSupport(contour: contour, medianLine: nil, apexIndex: nil)
                : observedSupport
        )
    }

    static func generatedImage(width: Int, height: Int, colorSpace: CGColorSpace) -> CIImage {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for region in targetRegions {
            let minX = region.minXPPM * width / 1_000_000
            let maxX = region.maxXPPM * width / 1_000_000
            let minY = region.minYPPM * height / 1_000_000
            let maxY = region.maxYPPM * height / 1_000_000
            for row in minY..<maxY {
                for column in minX..<maxX {
                    let offset = (row * width + column) * 4
                    bytes[offset] = 254
                    bytes[offset + 1] = 254
                    bytes[offset + 2] = 254
                }
            }
        }
        for row in 0..<height {
            let y = (Float(row) + 0.5) / Float(height)
            for side in 0..<2 {
                guard let center = contourX(at: y, rightSide: side == 1) else { continue }
                let centerColumn = Int((center * Float(width)).rounded())
                for column in max(0, centerColumn - 7)...min(width - 1, centerColumn + 7) {
                    let distance = abs(column - centerColumn)
                    let value = UInt8(min(220, distance * 22))
                    let offset = (row * width + column) * 4
                    bytes[offset] = value
                    bytes[offset + 1] = value
                    bytes[offset + 2] = value
                }
            }
        }
        return CIImage(
            bitmapData: Data(bytes),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    static func generatedSilhouette(
        width: Int,
        height: Int,
        colorSpace: CGColorSpace,
        contour: [SIMD2<Float>] = contour,
        rasterizeInward: Bool = false
    ) -> CIImage {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for row in 0..<height {
            let y = (Float(row) + 0.5) / Float(height)
            guard let left = contourX(at: y, rightSide: false, contour: contour),
                  let right = contourX(at: y, rightSide: true, contour: contour) else { continue }
            let leftColumn = Int(rasterizeInward
                ? ceil(left * Float(width)) : (left * Float(width)).rounded())
            let rightColumn = Int(rasterizeInward
                ? floor(right * Float(width)) : (right * Float(width)).rounded())
            for column in 0..<width {
                let inside = column >= leftColumn && column <= rightColumn
                let value: UInt8 = inside ? 80 : 220
                let offset = (row * width + column) * 4
                bytes[offset] = value
                bytes[offset + 1] = value
                bytes[offset + 2] = value
            }
        }
        return CIImage(
            bitmapData: Data(bytes),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    static func contourX(
        at y: Float,
        rightSide: Bool,
        contour: [SIMD2<Float>] = contour
    ) -> Float? {
        let sidePoints: [SIMD2<Float>] = rightSide
            ? Array(contour[8...].reversed())
            : Array(contour[...7])
        let ordered = sidePoints.sorted { $0.y < $1.y }
        guard let first = ordered.first, let last = ordered.last else { return nil }
        if y < first.y { return first.x }
        if y > last.y { return last.x }
        for pair in zip(ordered, ordered.dropFirst()) where y >= pair.0.y && y <= pair.1.y {
            let span = pair.1.y - pair.0.y
            let progress = span > 0 ? (y - pair.0.y) / span : 0
            return pair.0.x + (pair.1.x - pair.0.x) * progress
        }
        return last.x
    }

    func semanticSnapshot(
        source: [UInt8],
        neutral: [UInt8],
        candidate: [UInt8],
        frozenSiblings: [[UInt8]],
        strengtheningSiblings: [[UInt8]],
        width: Int,
        height: Int
    ) throws -> Snapshot {
        let sourceMetric = try continuityMetric(source, width: width, height: height)
        let neutralMetric = try continuityMetric(neutral, width: width, height: height)
        let candidateMetric = try continuityMetric(candidate, width: width, height: height)
        let frozenSiblingMetrics = try frozenSiblings.map {
            try continuityMetric($0, width: width, height: height)
        }
        let strengtheningSiblingMetrics = try strengtheningSiblings.map {
            try continuityMetric($0, width: width, height: height)
        }
        return Snapshot(
            sourceTarget: signal(source, candidate, regions: Self.targetRegions, width: width, height: height),
            neutralTarget: signal(neutral, candidate, regions: Self.targetRegions, width: width, height: height),
            sourceSignedMarginQ16: candidateMetric - sourceMetric,
            neutralSignedMarginQ16: candidateMetric - neutralMetric,
            frozenSiblingDistinctMarginsQ16: frozenSiblingMetrics.map { abs(candidateMetric - $0) },
            strengtheningSiblingDistinctMarginsQ16: strengtheningSiblingMetrics.map {
                abs(candidateMetric - $0)
            },
            outside: signal(source, candidate, excluding: Self.targetRegions, width: width, height: height),
            central: signal(source, candidate, regions: Self.centralRegions, width: width, height: height),
            background: signal(source, candidate, regions: Self.backgroundRegions, width: width, height: height),
            watermark: signal(source, candidate, regions: Self.watermarkRegions, width: width, height: height)
        )
    }

    func continuityMetric(_ bytes: [UInt8], width: Int, height: Int) throws -> Int64 {
        var roughness: Int64 = 0
        var count: Int64 = 0
        for region in Self.targetRegions {
            let raster = rasterize(region, width: width, height: height)
            var centroids: [Int64] = []
            let comparableMaxY = min(raster.maxY, height - watermarkExcludedRows(width: width))
            for row in raster.minY..<comparableMaxY {
                var weight: Int64 = 0
                var weightedX: Int64 = 0
                for column in raster.minX..<raster.maxX {
                    let offset = (row * width + column) * 4
                    let lumaQ8 = Int64(bytes[offset]) * 77 + Int64(bytes[offset + 1]) * 150 + Int64(bytes[offset + 2]) * 29
                    let darkness = max(0, 255 * 256 - lumaQ8)
                    weight += darkness
                    weightedX += darkness * Int64(column * 2 + 1)
                }
                guard weight > 0 else { throw OracleError.emptyDarknessRow }
                centroids.append(weightedX * 65_536 / (weight * Int64(width * 2)))
            }
            for index in 1..<(centroids.count - 1) {
                roughness += abs(centroids[index - 1] + centroids[index + 1] - centroids[index] * 2)
                count += 1
            }
        }
        guard count > 0 else { throw OracleError.emptyDarknessRow }
        return -(roughness / count)
    }

    func silhouetteRoughness(_ bytes: [UInt8], width: Int, height: Int) throws -> Double {
        var total = 0.0
        var count = 0
        for rightSide in [false, true] {
            var edges: [Double] = []
            for row in Int(0.34 * Double(height))..<Int(0.72 * Double(height)) {
                let y = (Float(row) + 0.5) / Float(height)
                let reference = try XCTUnwrap(Self.contourX(at: y, rightSide: rightSide))
                let center = Int((reference * Float(width)).rounded())
                var edge: Double?
                for column in max(0, center - 12)..<min(width - 1, center + 12) {
                    let a = Double(bytes[(row * width + column) * 4])
                    let b = Double(bytes[(row * width + column + 1) * 4])
                    if rightSide ? (a <= 150 && b > 150) : (a > 150 && b <= 150) {
                        edge = Double(column) + (150 - a) / (b - a)
                        break
                    }
                }
                edges.append(try XCTUnwrap(edge))
            }
            for index in 1..<(edges.count - 1) {
                total += abs(edges[index - 1] + edges[index + 1] - 2 * edges[index])
                count += 1
            }
        }
        return total / Double(count)
    }

    func signal(
        _ lhs: [UInt8],
        _ rhs: [UInt8],
        regions: [Region],
        width: Int,
        height: Int
    ) -> Signal {
        signal(lhs, rhs, include: { column, row in
            regions.contains { contains($0, column: column, row: row, width: width, height: height) }
        }, width: width, height: height)
    }

    func signal(
        _ lhs: [UInt8],
        _ rhs: [UInt8],
        excluding regions: [Region],
        width: Int,
        height: Int
    ) -> Signal {
        signal(lhs, rhs, include: { column, row in
            !regions.contains { contains($0, column: column, row: row, width: width, height: height) }
        }, width: width, height: height)
    }

    func signal(
        _ lhs: [UInt8],
        _ rhs: [UInt8],
        include: (Int, Int) -> Bool,
        width: Int,
        height: Int
    ) -> Signal {
        var result = Signal()
        let comparableRows = max(0, height - watermarkExcludedRows(width: width))
        for row in 0..<comparableRows {
            for column in 0..<width where include(column, row) {
                let offset = (row * width + column) * 4
                let deltas = (0..<3).map { abs(Int(lhs[offset + $0]) - Int(rhs[offset + $0])) }
                if deltas.max()! > 2 { result.changedPixels += 1 }
                result.absoluteRGBDelta += deltas.reduce(0, +)
            }
        }
        return result
    }

    func rasterize(_ region: Region, width: Int, height: Int) -> (minX: Int, maxX: Int, minY: Int, maxY: Int) {
        (
            region.minXPPM * width / 1_000_000,
            region.maxXPPM * width / 1_000_000,
            region.minYPPM * height / 1_000_000,
            region.maxYPPM * height / 1_000_000
        )
    }

    func contains(_ region: Region, column: Int, row: Int, width: Int, height: Int) -> Bool {
        let raster = rasterize(region, width: width, height: height)
        return column >= raster.minX && column < raster.maxX && row >= raster.minY && row < raster.maxY
    }

    func watermarkExcludedRows(width: Int) -> Int {
        let fontSize = max(34.0, min(72.0, Double(width) / 30.0))
        let padding = max(24.0, Double(width) / 70.0)
        return Int(ceil(padding * 2.0 + fontSize * 1.75))
    }

    enum OracleError: Error {
        case emptyDarknessRow
    }
}
