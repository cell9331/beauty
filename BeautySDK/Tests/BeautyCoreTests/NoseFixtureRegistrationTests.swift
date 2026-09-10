import BeautyCore
import BeautyDetection
@testable import BeautyEffects
@_spi(Testing) import BeautySDK
import CoreGraphics
import CoreVideo
import Foundation
import XCTest

final class NoseFixtureRegistrationTests: XCTestCase {
    func testSourceAnatomyRegistersIndependently() throws {
        let f = NoseRepairFixture.self
        XCTAssertTrue(f.width == 512 && f.height == 512, "source dimensions")
        XCTAssertTrue(f.headHeight == 2 * f.headWidth, "source tall head")
        XCTAssertTrue(f.headX + f.headWidth / 2 == 0.5, "source centered")
        XCTAssertTrue(abs(f.headY / (1 - f.headHeight) - 0.35) < 1e-12, "source composition")
        XCTAssertTrue(f.browPlane < f.rootPlane && f.rootPlane < f.innerCanthusPlane, "source nasion ordering")
        XCTAssertTrue(f.innerCanthusPlane < f.bridgeTop && f.bridgeTop < f.bridgeBottom
                      && f.bridgeBottom < f.tipPlane, "source nose ordering")
        XCTAssertTrue(f.rootFlanks.count == 2 && f.rootFlanks[0] < 0.5 && f.rootFlanks[1] > 0.5,
                      "source root pair")
        XCTAssertTrue(abs(f.rootFlanks[0] + f.rootFlanks[1] - 1) < 1e-12, "source symmetry")

        let literal = try Raster(ppm: [100001, 900001, 200001, 800001], width: 13, height: 17)
        XCTAssertTrue(literal.minX == 1, "literal floor min X")
        XCTAssertTrue(literal.maxX == 11, "literal floor max X")
        XCTAssertTrue(literal.minY == 3, "literal floor min Y")
        XCTAssertTrue(literal.maxY == 13, "literal floor max Y")
        XCTAssertTrue(literal.contains(1, 3), "inclusive minima")
        XCTAssertTrue(!literal.contains(0, 3), "below min X")
        XCTAssertTrue(!literal.contains(1, 2), "below min Y")
        XCTAssertTrue(literal.contains(10, 3), "before max X")
        XCTAssertTrue(literal.contains(1, 12), "before max Y")
        XCTAssertTrue(!literal.contains(11, 3), "exclusive max X")
        XCTAssertTrue(!literal.contains(1, 13), "exclusive max Y")

        let source = f.source()
        XCTAssertTrue(source == f.source(), "independent source determinism")
        XCTAssertTrue(source.count == 512 * 512 * 4, "source byte count")
        XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy { source[$0] == 255 }, "opaque alpha")
        var achromatic = true
        for offset in stride(from: 0, to: source.count, by: 4) {
            let red = source[offset]
            let green = source[offset + 1]
            let blue = source[offset + 2]
            achromatic = achromatic && red == green && red == blue
        }
        XCTAssertTrue(achromatic, "achromatic recipe")
        let image = try f.image()
        XCTAssertTrue(image.extent == CGRect(x: 0, y: 0, width: 512, height: 512), "source extent")
        XCTAssertTrue(image.colorSpace?.name == CGColorSpace.sRGB, "source named sRGB")
        let frame = try f.sourceFrame()
        XCTAssertTrue(frame.orientation == .up && !frame.isInputMirrored && !frame.isPreviewMirrored,
                      "frame metadata")
        let buffer = frame.pixelBuffer
        XCTAssertTrue(CVPixelBufferLockBaseAddress(buffer, .readOnly) == kCVReturnSuccess, "frame admission")
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        let address = try XCTUnwrap(CVPixelBufferGetBaseAddress(buffer), "frame carrier")
        let rowStride = CVPixelBufferGetBytesPerRow(buffer)
        var frameMatches = true
        for y in 0..<512 {
            let row = address.advanced(by: y * rowStride).assumingMemoryBound(to: UInt8.self)
            for x in 0..<512 {
                let offset = (y * 512 + x) * 4
                frameMatches = frameMatches && row[x * 4] == source[offset + 2]
                    && row[x * 4 + 1] == source[offset + 1] && row[x * 4 + 2] == source[offset]
                    && row[x * 4 + 3] == 255
            }
        }
        XCTAssertTrue(frameMatches, "same source carriers")

        let root = try region("root")
        let bridge = try region("bridge")
        // Source landmarks come only from the drawing, without detection or a
        // production helper. These samples do not score rendered efficacy.
        let sourceRoots = f.rootFlanks.map { SIMD2<Float>(Float($0), Float(f.rootPlane)) }
        XCTAssertTrue(sourceRoots.allSatisfy { root.contains($0) }, "source root membership")
        XCTAssertTrue(root.contains(Int(0.5 * 512), Int(f.rootPlane * 512)), "source nasion membership")
        XCTAssertTrue(bridge.contains(Int(0.5 * 512), Int((f.bridgeTop + f.bridgeBottom) * 256)), "source bridge membership")
        for row in try protectedRegions() {
            var minimum = UInt8.max
            var maximum = UInt8.min
            for y in row.minY..<row.maxY {
                for x in row.minX..<row.maxX {
                    let value = source[(y * 512 + x) * 4]
                    minimum = min(minimum, value)
                    maximum = max(maximum, value)
                }
            }
            XCTAssertTrue(maximum > minimum, "non-flat protected guard")
        }
    }

    func testAdapterMatchesSourceRootAndBridge() throws {
        let observation = try detect(.phase93RegisteredNose)
        let f = NoseRepairFixture.self
        let bounds = try XCTUnwrap(observation.imageBounds, "mapped source head")
        XCTAssertTrue(abs(bounds.x - f.headX) < 1e-12 && abs(bounds.y - f.headY) < 1e-12
                      && abs(bounds.width - f.headWidth) < 1e-12 && abs(bounds.height - f.headHeight) < 1e-12,
                      "single Vision mapping of independent source")
        XCTAssertTrue(abs(observation.normalizedArea - f.headWidth * f.headHeight) < 1e-12,
                      "source area")
        XCTAssertTrue(observation.confidence == 0.96 && observation.stableID == "phase-93-nose-fixture",
                      "source observation identity")
        XCTAssertTrue(observation.landmarks.availableGroups == Set(BeautyLandmarkGroup.allCases), "complete groups")
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        XCTAssertTrue(geometry.nose.count == 4 && geometry.noseRoot.count == 2 && geometry.noseTip.count == 3,
                      "nose support cardinality")
        // Independent source-side copies of the retained legacy/tip template.
        // Neither the expected registration nor target envelopes call a provider.
        let expectedNose = sourcePoints([(0.46, 0.43), (0.50, 0.55), (0.40, 0.64), (0.60, 0.64)])
        let expectedTip = sourcePoints([(0.44, 0.62), (0.50, 0.66), (0.56, 0.62)])
        XCTAssertTrue(matches(geometry.nose, expectedNose), "unchanged legacy mapping")
        XCTAssertTrue(matches(geometry.noseTip, expectedTip), "unchanged tip mapping")
        let rootROI = try region("root")
        let bridgeROI = try region("bridge")
        let average = expectedNose.reduce(SIMD2<Float>.zero, +) / Float(expectedNose.count)
        let expectedBridge = expectedNose.filter { $0.y <= average.y && $0.x != average.x }
        let actualAverage = geometry.nose.reduce(SIMD2<Float>.zero, +) / Float(geometry.nose.count)
        let actualBridge = geometry.nose.filter { $0.y <= actualAverage.y && $0.x != actualAverage.x }
        XCTAssertTrue(expectedBridge.count == 2 && matches(actualBridge, expectedBridge), "two noncentral upper supports")
        XCTAssertTrue(actualBridge.allSatisfy { bridgeROI.contains($0) }, "bridge membership")
        let expectedRoots = f.rootFlanks.map { SIMD2<Float>(Float($0), Float(f.rootPlane)) }
        var rootRegistered = matches(geometry.noseRoot, expectedRoots)
            && geometry.noseRoot.allSatisfy { rootROI.contains($0) }
        for (bridgeFactor, rootFactor): (Float, Float) in [(0.08, 0.07), (0.09, 0.08)] {
            let width = Float(f.headWidth)
            let bridgeRadius = min(max(width * bridgeFactor, 0.03), 0.20)
            let rootRadius = min(max(width * rootFactor, 0.03), 0.20)
            let bridgeDisplacements = actualBridge.map { actualAverage.x - $0.x }
            XCTAssertTrue(envelope(actualBridge, displacements: bridgeDisplacements,
                                   radius: bridgeRadius, roi: bridgeROI), "bridge full source/cap-target envelope")
            let rootDisplacement = min(width * 0.025,
                min(Float(0.5) - expectedRoots[0].x, expectedRoots[1].x - Float(0.5)) - 0.0001)
            XCTAssertTrue(envelope(expectedRoots, displacements: [rootDisplacement, -rootDisplacement],
                                   radius: rootRadius, roi: rootROI), "independent source root envelope")
            rootRegistered = rootRegistered && envelope(geometry.noseRoot,
                displacements: [rootDisplacement, -rootDisplacement], radius: rootRadius, roi: rootROI)
        }
        // The sole old-adapter RED predicate; no root helper supplies expected.
        XCTAssertTrue(rootRegistered, "P93_ROOT_PLACEMENT")
    }

    func testMissingNoseAndCanonicalControl() throws {
        let present = try detect(.phase93RegisteredNose)
        let missingProvider = SDKTestingFaceDetectionProvider([.phase93MissingNose])
        var missingDetector = VisionFaceDetector(observationProvider: missingProvider.makeObservationProvider())
        let missingGeometry = missingDetector.detect(metadata: NoseRepairFixture.metadata(),
                                                    imageExtent: CGSize(width: 512, height: 512))
        XCTAssertTrue(missingProvider.invocationCount == 1 && missingGeometry.observations.isEmpty,
                      "geometry-purpose detector rejects missing nose")
        // The existing combined-purpose path maps partial support, allowing an
        // independent adapter-local group-isolation assertion as well.
        let missing = try detect(.phase93MissingNose, includeMissingSupport: true)
        XCTAssertTrue(present.imageBounds == missing.imageBounds && present.stableID == missing.stableID
                      && present.confidence == missing.confidence && present.normalizedArea == missing.normalizedArea,
                      "missing differs only by nose group")
        XCTAssertTrue(missing.landmarks.availableGroups == present.landmarks.availableGroups.subtracting([.nose]),
                      "nose-only group removal")
        let good = BeautyFaceGeometryAdapter.makeGeometry(from: present)
        let empty = BeautyFaceGeometryAdapter.makeGeometry(from: missing)
        XCTAssertTrue(empty.nose.isEmpty && empty.noseRoot.isEmpty && empty.noseTip.isEmpty, "missing nose fails closed")
        XCTAssertTrue(good.faceContour == empty.faceContour && good.leftEye == empty.leftEye
                      && good.rightEye == empty.rightEye && good.outerLips == empty.outerLips,
                      "non-target templates unchanged")
        let canonical = try detect(.usableFace)
        let original = BeautyFaceGeometryAdapter.makeGeometry(from: canonical)
        XCTAssertTrue(canonical.stableID == "fixture" && canonical.confidence == 0.96, "canonical identity")
        XCTAssertTrue(abs(canonical.normalizedArea - 0.24) < 1e-12, "canonical area")
        let nose: [SIMD2<Float>] = [(0.484, 0.458), (0.500, 0.530), (0.460, 0.584), (0.540, 0.584)].map { SIMD2($0.0, $0.1) }
        let tip: [SIMD2<Float>] = [(0.476, 0.572), (0.500, 0.596), (0.524, 0.572)].map { SIMD2($0.0, $0.1) }
        XCTAssertTrue(matches(original.nose, nose) && matches(original.noseTip, tip), "canonical legacy/tip control")
        let root = try region("root")
        XCTAssertTrue(!original.noseRoot.allSatisfy { root.contains($0) }, "canonical remains registration counterexample")
    }

    private func detect(_ fixture: SDKTestingFaceDetectionFixture,
                        includeMissingSupport: Bool = false) throws -> BeautyFaceObservation {
        let provider = SDKTestingFaceDetectionProvider([fixture])
        var detector = VisionFaceDetector(observationProvider: provider.makeObservationProvider())
        let result = detector.detect(metadata: NoseRepairFixture.metadata(), imageExtent: CGSize(width: 512, height: 512),
                                     purpose: includeMissingSupport ? .geometryAndLocalSupport : .geometry)
        XCTAssertTrue(provider.invocationCount == 1 && result.observations.count == 1, "one actual detector mapping")
        return try XCTUnwrap(result.observations.first, "mapped observation available")
    }

    private func sourcePoints(_ local: [(Float, Float)]) -> [SIMD2<Float>] {
        let f = NoseRepairFixture.self
        return local.map { SIMD2(Float(f.headX) + Float(f.headWidth) * $0.0,
                                 Float(f.headY) + Float(f.headHeight) * $0.1) }
    }

    private func matches(_ actual: [SIMD2<Float>], _ expected: [SIMD2<Float>]) -> Bool {
        actual.count == expected.count && zip(actual, expected).allSatisfy {
            abs($0.x - $1.x) <= 0.000001 && abs($0.y - $1.y) <= 0.000001
        }
    }

    private func envelope(_ sources: [SIMD2<Float>], displacements: [Float], radius: Float, roi: Raster) -> Bool {
        guard sources.count == displacements.count, !sources.isEmpty, radius.isFinite, radius > 0 else { return false }
        let budget = displacements.reduce(0.0) { $0 + 2 * abs(Double($1)) / Double(radius) }
        guard budget.isFinite, budget > 0 else { return false }
        let scale = Float(min(1, 0.45 / budget) * Double(1 - 64 * Float.ulpOfOne))
        return zip(sources, displacements).allSatisfy { source, displacement in
            let target = SIMD2<Float>(source.x + scale * displacement, source.y)
            return roi.containsDisk(source, radius: radius) && roi.containsDisk(target, radius: radius)
        }
    }

    private func contracts() throws -> [[String: Any]] {
        let repo = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let data = try Data(contentsOf: repo.appendingPathComponent("scripts/face-feature-batch-manifest.json"))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any], "manifest schema")
        return try XCTUnwrap(object["semanticContracts"] as? [[String: Any]], "manifest rows")
    }

    private func region(_ name: String) throws -> Raster {
        let caseID = name == "root" ? "noseRootNarrowing_0p25" : "noseBridge_0p30"
        let rows = try contracts().filter { $0["caseID"] as? String == caseID }
        XCTAssertTrue(rows.count == 1, "unique frozen contract")
        let row = try XCTUnwrap(rows.first, "frozen contract")
        let regions = try XCTUnwrap(row["targetRegions"] as? [[String: Any]], "target regions")
        XCTAssertTrue(regions.count == 1, "single target region")
        return try raster(try XCTUnwrap(regions.first, "target present"))
    }

    private func protectedRegions() throws -> [Raster] {
        let rows = try contracts().filter { ($0["caseID"] as? String)?.hasPrefix("nose") == true }
        var regions: [Raster] = []
        for row in rows {
            let groups = try XCTUnwrap(row["protectedRegions"] as? [[String: Any]], "protected groups")
            for group in groups {
                for region in try XCTUnwrap(group["regions"] as? [[String: Any]], "protected regions") {
                    regions.append(try raster(region))
                }
            }
        }
        XCTAssertTrue(!regions.isEmpty, "nonzero protected guard coverage")
        return regions
    }

    private func raster(_ row: [String: Any]) throws -> Raster {
        let ppm = try ["minXPPM", "maxXPPM", "minYPPM", "maxYPPM"].map {
            try XCTUnwrap(row[$0] as? Int64, "integer region edge")
        }
        return try Raster(ppm: ppm, width: 512, height: 512)
    }

    private struct Raster {
        let minX: Int
        let maxX: Int
        let minY: Int
        let maxY: Int
        let width: Int
        let height: Int

        init(ppm: [Int64], width: Int, height: Int) throws {
            guard ppm.count == 4, width > 0, height > 0,
                  ppm.allSatisfy({ (0...1_000_000).contains($0) }) else { throw Admission.invalidRegion }
            var edges: [Int] = []
            for (edge, extent) in zip(ppm, [width, width, height, height]) {
                let product = edge.multipliedReportingOverflow(by: Int64(extent))
                guard !product.overflow, let result = Int(exactly: product.partialValue / 1_000_000) else {
                    throw Admission.invalidRegion
                }
                edges.append(result)
            }
            guard edges[0] < edges[1], edges[2] < edges[3] else { throw Admission.invalidRegion }
            (minX, maxX, minY, maxY) = (edges[0], edges[1], edges[2], edges[3])
            self.width = width
            self.height = height
        }

        func contains(_ x: Int, _ y: Int) -> Bool {
            x >= minX && x < maxX && y >= minY && y < maxY
        }

        func contains(_ point: SIMD2<Float>) -> Bool {
            let x = Double(point.x) * Double(width)
            let y = Double(point.y) * Double(height)
            return x >= Double(minX) && x < Double(maxX) && y >= Double(minY) && y < Double(maxY)
        }

        func containsDisk(_ center: SIMD2<Float>, radius: Float) -> Bool {
            let x = Double(center.x) * Double(width)
            let y = Double(center.y) * Double(height)
            let rx = Double(radius) * Double(width)
            let ry = Double(radius) * Double(height)
            return x - rx >= Double(minX) && x + rx < Double(maxX)
                && y - ry >= Double(minY) && y + ry < Double(maxY)
        }
    }

    private enum Admission: Error { case invalidRegion }
}
