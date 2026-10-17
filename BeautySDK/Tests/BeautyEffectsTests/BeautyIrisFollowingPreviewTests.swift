import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyEffects

final class BeautyIrisFollowingPreviewTests: XCTestCase {
    private let fixture = IrisFollowingIntegrationFixture()
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private lazy var context = CIContext(options: [.cacheIntermediates: false,
        .workingColorSpace: colorSpace, .outputColorSpace: colorSpace])

    private func carrier(source: [UInt8]? = nil) throws -> BeautyCanonicalStillImage {
        try BeautyCanonicalStillImage(rgba8Data: Data(source ?? fixture.source), width: fixture.width,
            height: fixture.height, rowBytes: fixture.width * 4,
            metadata: .init(orientation: .up, source: .photo))
    }

    private func pixels(_ image: CIImage) -> [UInt8] {
        let width = Int(image.extent.width), height = Int(image.extent.height)
        var rgba = [UInt8](repeating: 0, count: width * height * 4)
        rgba.withUnsafeMutableBytes {
            context.render(image, toBitmap: $0.baseAddress!, rowBytes: width * 4,
                bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        }
        return rgba
    }

    private func preview(_ request: BeautyIrisFollowingRequest, edge: Int = 200,
                         plan: BeautyEffectPlan? = nil,
                         observation: BeautyFaceObservation? = nil,
                         source: [UInt8]? = nil) throws -> BeautyIrisPreviewCutpoint.Result {
        try BeautyIrisPreviewCutpoint.execute(original: carrier(source: source), plan: plan ?? fixture.plan(),
            selectedFaceObservation: observation ?? fixture.observation(), maximumPreviewEdge: edge,
            irisGeometryRoute: .calibrated(request))
    }

    /// Independent footprint definition for the published research resize
    /// convention; no production owner, mask, coordinate or sampler is called.
    private func taps(column: Int, row: Int, width: Int, height: Int) -> [(Int, Double)] {
        let x = min(Double(fixture.width - 1), max(0,
            (Double(column) + 0.5) * Double(fixture.width) / Double(width) - 0.5))
        let y = min(Double(fixture.height - 1), max(0,
            (Double(row) + 0.5) * Double(fixture.height) / Double(height) - 0.5))
        let left = Int(floor(x)), top = Int(floor(y))
        let right = min(fixture.width - 1, left + 1), bottom = min(fixture.height - 1, top + 1)
        let fx = x - Double(left), fy = y - Double(top)
        return [((top * fixture.width + left) * 4, (1 - fx) * (1 - fy)),
                ((top * fixture.width + right) * 4, fx * (1 - fy)),
                ((bottom * fixture.width + left) * 4, (1 - fx) * fy),
                ((bottom * fixture.width + right) * 4, fx * fy)]
    }

    func testFullSizeCandidatePreviewUsesSameMapperAndReportsItsActualRoute() throws {
        let request = fixture.request(), expected = BeautyIrisFollowingMap.render(request)
        let result = try preview(request)
        XCTAssertEqual(result.output.extent, CGRect(x: 0, y: 0, width: fixture.width, height: fixture.height))
        XCTAssertEqual(result.output.colorSpace?.name, colorSpace.name)
        XCTAssertTrue(pixels(result.output) == expected.rgba, "full-size preview must equal the mapper raster")
        XCTAssertTrue(result.irisFollowingResult?.rgba == expected.rgba, "preview must retain the qualified mapper result")
        XCTAssertEqual(result.irisFollowingResult?.status, .applied)
        XCTAssertEqual(result.metrics["beauty.irisFollowingPreview.calibratedCPU"], 1)
        XCTAssertEqual(result.metrics["beauty.irisFollowingPreview.appliedEyeCount"], 2)
        XCTAssertEqual(result.metrics["beauty.irisFollowingPreview.sourcePrefixPasses"], 0)
        XCTAssertNil(result.metrics["beauty.irisPreview.originalFirstCPU"], "the legacy executor was never used")
        XCTAssertNil(result.metrics["beauty.irisPreview.postGeometryPasses"])
    }

    func testFractionalResizeMatchesFullFieldAndKeepsEveryUnchangedFootprintExactlyBaseline() throws {
        let request = fixture.request(), full = BeautyIrisFollowingMap.render(request).rgba
        let source = fixture.source
        for edge in [73, 41] {
            let result = try preview(request, edge: edge)
            let baseline = try preview(fixture.request(progress: 0), edge: edge)
            let actual = pixels(result.output), base = pixels(baseline.output)
            let width = Int(result.output.extent.width), height = Int(result.output.extent.height)
            XCTAssertEqual(width, edge)
            XCTAssertEqual(height, Int((Double(fixture.height) * Double(edge) / Double(fixture.width)).rounded()))
            var unchangedFootprints = 0, changedFollowingPixels = 0
            for row in 0..<height { for column in 0..<width {
                let footprint = taps(column: column, row: row, width: width, height: height)
                let outputIndex = (row * width + column) * 4
                let unchanged = footprint.allSatisfy { offset, weight in
                    weight == 0 || Array(full[offset..<offset + 4]) == Array(source[offset..<offset + 4])
                }
                if unchanged {
                    unchangedFootprints += 1
                    XCTAssertTrue(Array(actual[outputIndex..<outputIndex + 4]) ==
                        Array(base[outputIndex..<outputIndex + 4]), "fractional footprints cannot expand changed coverage")
                }
                for channel in 0..<3 {
                    let measured = footprint.reduce(0.0) { $0 + Double(full[$1.0 + channel]) * $1.1 }
                    XCTAssertEqual(Double(actual[outputIndex + channel]), measured.rounded(), accuracy: 1,
                        "independent weighted full-source oracle; one LSB permits arithmetic rounding order")
                }
                XCTAssertEqual(actual[outputIndex + 3], 255)
                let sourceY = (Double(row) + 0.5) * Double(fixture.height) / Double(height) - 0.5
                if sourceY < 44 || sourceY > 64,
                   Array(actual[outputIndex..<outputIndex + 3]) != Array(base[outputIndex..<outputIndex + 3]) {
                    changedFollowingPixels += 1
                }
            } }
            XCTAssertGreaterThan(unchangedFootprints, width * height / 2)
            XCTAssertGreaterThan(changedFollowingPixels, 0,
                "following pixels outside the old eye aperture must survive the preview cutpoint")
        }
    }

    func testRefusedCalibrationReturnsActualSourceThumbnailWithoutFixedLidRetry() throws {
        let source = fixture.legacyIrisSource, observation = try fixture.denseObservation()
        let baseline = try preview(fixture.request(progress: 0, source: source), edge: 73,
            observation: observation, source: source)
        var staleSource = source
        staleSource[0] ^= 1
        let cases: [(BeautyIrisFollowingRequest, BeautyIrisFollowingRefusalReason)] = [
            (fixture.request(source: staleSource), .sourceMismatch),
            (fixture.request(progress: .infinity, source: source), .invalidProgress),
            (fixture.request(eyes: [fixture.eye(.left, gain: .nan)], source: source), .invalidCalibration),
            (fixture.request(eyes: [fixture.eye(.left, gain: 3)], source: source), .unsafeContraction)
        ]
        for (request, reason) in cases {
            let result = try preview(request, edge: 73, observation: observation, source: source)
            XCTAssertEqual(result.irisFollowingResult?.status, .refused)
            XCTAssertNotNil(result.irisFollowingResult?.refusalCounts[reason])
            XCTAssertTrue(result.irisFollowingResult?.rgba == source, "refusal preserves the actual dense-control source")
            XCTAssertTrue(pixels(result.output) == pixels(baseline.output), "refused preview must equal actual-source baseline")
        }
        let legacy = try BeautyIrisPreviewCutpoint.execute(original: carrier(source: source), plan: fixture.plan(),
            selectedFaceObservation: observation, maximumPreviewEdge: 73)
        let legacyNeutral = try BeautyIrisPreviewCutpoint.execute(original: carrier(source: source),
            plan: fixture.plan { $0.pupilSize = 0 }, selectedFaceObservation: observation, maximumPreviewEdge: 73)
        XCTAssertGreaterThan(legacy.metrics["beauty.irisPreview.completedEyeCount"] ?? 0, 0,
            "the dense source must actually complete the legacy iris sampler")
        XCTAssertTrue(pixels(legacy.output) != pixels(legacyNeutral.output),
            "a nonzero legacy pupil is the control against accidental fallback")
        XCTAssertNil(legacy.irisFollowingResult)
        XCTAssertEqual(legacy.metrics["beauty.irisPreview.originalFirstCPU"], 1)
    }

    func testNoFaceAndUnsupportedSiblingsStayIdentityWhileOneObservedPeerCanApply() throws {
        let original = try carrier(), request = fixture.request()
        let noFace = try BeautyIrisPreviewCutpoint.execute(original: original, plan: fixture.plan(),
            selectedFaceObservation: nil, maximumPreviewEdge: 73, irisGeometryRoute: .calibrated(request))
        XCTAssertEqual(noFace.irisFollowingResult?.refusalCounts[.missingObservedEyeSupport], 2)
        let baseline = try preview(fixture.request(progress: 0), edge: 73)
        XCTAssertTrue(pixels(noFace.output) == pixels(baseline.output), "no-face preview must preserve baseline")
        for key in [\BeautyEffectiveStrengths.eyeTilt, \.hairlineHeight, \.wholeFaceXPosition, \.faceContourSmooth] {
            let unsupported = try preview(request, edge: 73, plan: fixture.plan { $0[keyPath: key] = 0.2 })
            XCTAssertEqual(unsupported.irisFollowingResult?.refusalCounts[.unsupportedStageCombination], 2)
            XCTAssertTrue(pixels(unsupported.output) == pixels(baseline.output), "unsupported preview must preserve baseline")
            XCTAssertEqual(unsupported.metrics["beauty.irisFollowingPreview.sourcePrefixPasses"], 0)
        }
        let one = try preview(request, observation: fixture.observation(sides: [.right]))
        let expected = BeautyIrisFollowingMap.render(fixture.request(eyes: [fixture.eye(.right)]))
        XCTAssertEqual(one.irisFollowingResult?.status, .partiallyApplied)
        XCTAssertEqual(one.irisFollowingResult?.refusalCounts[.missingObservedEyeSupport], 1)
        XCTAssertTrue(pixels(one.output) == expected.rgba, "qualified peer must match its independent raster")
    }

    func testColorPrefixCannotReuseOriginalCalibrationAndRefusalKeepsActualPrefix() throws {
        let base = fixture.plan { $0.brightness = 0.12 }
        let plan = BeautyEffectPlan(activeDomains: [.eyes, .color], effectiveStrengths: base.effectiveStrengths)
        let original = try carrier()
        let prefixed = BeautyColorEffectPipeline.prepareStillImagePrefix(to: original, plan: plan,
            renderQuality: .balanced, selectedFaceObservation: fixture.observation(), textureExclusionMask: nil)
        let actualPrefix = pixels(prefixed)
        XCTAssertTrue(actualPrefix != fixture.source, "the active color prefix must actually change source bytes")
        let result = try preview(fixture.request(), plan: plan)
        XCTAssertEqual(result.irisFollowingResult?.refusalCounts[.sourceMismatch], 2)
        XCTAssertTrue(result.irisFollowingResult?.rgba == actualPrefix, "binding refusal must preserve actual color prefix")
        XCTAssertTrue(pixels(result.output) == actualPrefix, "refused full preview must equal actual color prefix")
        XCTAssertEqual(result.metrics["beauty.irisFollowingPreview.sourcePrefixPasses"], 1)
        let rebound = fixture.request(source: actualPrefix)
        let qualified = try preview(rebound, plan: plan)
        XCTAssertEqual(qualified.irisFollowingResult?.status, .applied)
        XCTAssertTrue(pixels(qualified.output) == BeautyIrisFollowingMap.render(rebound).rgba,
            "explicitly rebound prefix must use the same mapper")
    }
}
