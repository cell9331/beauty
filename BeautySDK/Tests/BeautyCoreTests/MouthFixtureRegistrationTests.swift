import BeautyCore
import BeautyDetection
@testable import BeautyEffects
@_spi(Testing) import BeautySDK
import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import XCTest

final class MouthFixtureRegistrationTests: XCTestCase {
    private let width = 640
    private let height = 800

    func testSourceRecipeAndActualRegistration() throws {
        let bytes = MouthRepairFixture.source()
        XCTAssertTrue(bytes == MouthRepairFixture.source(), "P94_SOURCE_DETERMINISM")
        XCTAssertTrue(bytes.count == width * height * 4, "P94_SOURCE_LENGTH")
        XCTAssertTrue(stride(from: 0, to: bytes.count, by: 4).allSatisfy {
            bytes[$0] == bytes[$0 + 1] && bytes[$0] == bytes[$0 + 2] && bytes[$0 + 3] == 255
        }, "P94_SOURCE_CHANNELS")
        let metadata = MouthRepairFixture.metadata()
        XCTAssertTrue(metadata.orientation == .up && !metadata.isInputMirrored && !metadata.isPreviewMirrored,
                      "P94_SOURCE_METADATA")
        let image = try MouthRepairFixture.image()
        let color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB), "P94_COLOR")
        XCTAssertTrue(image.extent == CGRect(x: 0, y: 0, width: width, height: height)
                      && image.colorSpace?.name == CGColorSpace.sRGB, "P94_IMAGE_METADATA")
        var extracted = [UInt8](repeating: 0, count: bytes.count)
        let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
        extracted.withUnsafeMutableBytes { buffer in
            context.render(image, toBitmap: buffer.baseAddress!, rowBytes: width * 4,
                           bounds: image.extent, format: .RGBA8, colorSpace: color)
        }
        XCTAssertTrue(extracted == bytes, "P94_IMAGE_CARRIER")
        let frame = try MouthRepairFixture.sourceFrame()
        XCTAssertTrue(frame.orientation == .up && !frame.isInputMirrored && !frame.isPreviewMirrored,
                      "P94_FRAME_METADATA")
        let buffer = frame.pixelBuffer
        guard CVPixelBufferLockBaseAddress(buffer, .readOnly) == kCVReturnSuccess else { throw Admission.carrier }
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        guard let address = CVPixelBufferGetBaseAddress(buffer) else { throw Admission.carrier }
        var same = true
        for y in 0..<height {
            let row = address.advanced(by: y * CVPixelBufferGetBytesPerRow(buffer)).assumingMemoryBound(to: UInt8.self)
            for x in 0..<width {
                let i = (y * width + x) * 4
                same = same && row[x * 4] == bytes[i + 2] && row[x * 4 + 1] == bytes[i + 1]
                    && row[x * 4 + 2] == bytes[i] && row[x * 4 + 3] == bytes[i + 3]
            }
        }
        XCTAssertTrue(same, "P94_FRAME_CARRIER")
        let observation = try detect(.phase94MouthPortrait)
        let bounds = try XCTUnwrap(observation.imageBounds, "P94_MAPPED_HEAD")
        XCTAssertTrue(abs(bounds.x - 64.0 / 640) < 1e-12 && abs(bounds.y - 48.0 / 800) < 1e-12
                      && abs(bounds.width - 512.0 / 640) < 1e-12 && abs(bounds.height - 672.0 / 800) < 1e-12,
                      "P94_SINGLE_Y_MAPPING")
        XCTAssertTrue(abs(observation.normalizedArea - (512.0 / 640) * (672.0 / 800)) < 1e-12
                      && observation.confidence == 0.96 && observation.stableID == "phase-94-mouth-fixture",
                      "P94_OBSERVATION_IDENTITY")
        XCTAssertTrue(observation.landmarks.availableGroups == Set(BeautyLandmarkGroup.allCases), "P94_GROUPS")
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        XCTAssertTrue(registered(bytes, geometry), "P94_SOURCE_ACTUAL_REGISTRATION")
        let targets = try targetRegions()
        let corners = geometry.outerLips.sorted { $0.x < $1.x }
        guard let first = corners.first, let last = corners.last else { throw Admission.mapping }
        XCTAssertTrue(targets.count == 2 && targets[0].contains(216, 560) && targets[1].contains(424, 560)
                      && targets[0].contains(Double(first.x) * 640, Double(first.y) * 800)
                      && targets[1].contains(Double(last.x) * 640, Double(last.y) * 800), "P94_RASTER_REGISTRATION")
        XCTAssertTrue(targets[0].edges == [128, 256, 480, 608]
                      && targets[1].edges == [384, 512, 480, 608], "P94_LITERAL_TARGETS")
        let literal = try Raster([100001, 900001, 200001, 800001], 13, 17)
        XCTAssertTrue(literal.edges == [1, 11, 3, 13] && literal.contains(1, 3)
                      && literal.contains(10, 12) && !literal.contains(11, 3)
                      && !literal.contains(1, 13) && !literal.contains(0, 3), "P94_LITERAL_EXCLUSIVE")
        for raster in try protectedRegions() {
            var lo = UInt8.max
            var hi = UInt8.min
            for y in raster.edges[2]..<raster.edges[3] {
                for x in raster.edges[0]..<raster.edges[1] {
                    let v = bytes[(y * width + x) * 4]
                    lo = min(lo, v)
                    hi = max(hi, v)
                }
            }
            XCTAssertTrue(hi > lo, "P94_FULL_PROTECTED_GUARD")
        }
    }

    func testMismatchedAndDisconnectedMouthsAreRejected() throws {
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: try detect(.phase94MouthPortrait))
        let source = MouthRepairFixture.source()
        XCTAssertTrue(registered(source, geometry), "P94_REJECTION_POSITIVE_CONTROL")
        for (dx, dy, reflect) in [(24, 0, false), (0, 24, false), (24, 0, true)] {
            let altered = shiftedMouth(source, dx: dx, dy: dy, reflect: reflect)
            XCTAssertTrue(!registered(altered, geometry), "P94_SHIFT_REFLECTION_REJECTED")
        }
        var displaced = source
        // Move only a disk around the left centerline corner; other anatomy is
        // retained. This is a rejection attack, never an admitted drawing.
        for y in 540..<580 {
            for x in 196..<236 where (x - 216) * (x - 216) + (y - 560) * (y - 560) <= 16 * 16 {
                set(&displaced, x, y, 224 + (x / 64 + y / 64) % 2)
                let i = (y * width + x) * 4
                set(&displaced, x + 24, y, Int(source[i]))
            }
        }
        XCTAssertTrue(!registered(displaced, geometry), "P94_ONE_CORNER_REJECTED")
        var disconnected = removedMouth(source)
        for y in 548..<572 {
            for x in 204..<436 where min((x - 216) * (x - 216), (x - 424) * (x - 424))
                + (y - 560) * (y - 560) <= 64 {
                set(&disconnected, x, y, 80)
            }
        }
        XCTAssertTrue(!connected(disconnected) && !registered(disconnected, geometry), "P94_DISCONNECTED_REJECTED")
    }

    func testMissingOuterLipsAndCanonicalRemainUnregistered() throws {
        let present = try detect(.phase94MouthPortrait)
        let provider = SDKTestingFaceDetectionProvider([.phase94MouthPortraitMissingOuterLips])
        var detector = VisionFaceDetector(observationProvider: provider.makeObservationProvider())
        let rejected = detector.detect(metadata: MouthRepairFixture.metadata(), imageExtent: CGSize(width: width, height: height))
        XCTAssertTrue(provider.invocationCount == 1 && rejected.observations.isEmpty, "P94_MISSING_GEOMETRY_REJECTED")
        let missing = try detect(.phase94MouthPortraitMissingOuterLips, partial: true)
        XCTAssertTrue(missing.imageBounds == present.imageBounds && missing.stableID == present.stableID
                      && missing.confidence == present.confidence && missing.normalizedArea == present.normalizedArea
                      && missing.landmarks.availableGroups == present.landmarks.availableGroups.subtracting([.outerLips]),
                      "P94_ONLY_OUTER_GROUP_REMOVED")
        let good = BeautyFaceGeometryAdapter.makeGeometry(from: present)
        let empty = BeautyFaceGeometryAdapter.makeGeometry(from: missing)
        XCTAssertTrue(empty.outerLips.isEmpty && empty.upperLips.isEmpty && empty.lowerLips.isEmpty,
                      "P94_OUTER_FAIL_CLOSED")
        XCTAssertTrue(empty.innerLips == good.innerLips && empty.faceContour == good.faceContour
                      && empty.leftEye == good.leftEye && empty.rightEye == good.rightEye
                      && empty.nose == good.nose && empty.noseRoot == good.noseRoot && empty.noseTip == good.noseTip,
                      "P94_OTHER_GROUPS_RETAINED")
        let canonical = try detect(.usableFace)
        let original = BeautyFaceGeometryAdapter.makeGeometry(from: canonical)
        let corners = original.outerLips.sorted { $0.x < $1.x }
        guard let left = corners.first, let right = corners.last else { throw Admission.mapping }
        let targets = try targetRegions()
        let membership = [targets[0].contains(Double(left.x) * 640, Double(left.y) * 800),
                          targets[1].contains(Double(right.x) * 640, Double(right.y) * 800)]
        XCTAssertTrue(membership.filter { $0 }.count == 0 && canonical.stableID == "fixture"
                      && abs(canonical.normalizedArea - 0.24) < 1e-12, "P94_CANONICAL_ZERO_OF_TWO")
    }

    private func detect(_ fixture: SDKTestingFaceDetectionFixture, partial: Bool = false) throws -> BeautyFaceObservation {
        let provider = SDKTestingFaceDetectionProvider([fixture])
        var detector = VisionFaceDetector(observationProvider: provider.makeObservationProvider())
        let result = detector.detect(metadata: MouthRepairFixture.metadata(), imageExtent: CGSize(width: width, height: height),
                                     purpose: partial ? .geometryAndLocalSupport : .geometry)
        guard provider.invocationCount == 1, result.observations.count == 1,
              let observation = result.observations.first else { throw Admission.mapping }
        return observation
    }

    private func registered(_ bytes: [UInt8], _ geometry: FaceGeometry) -> Bool {
        guard bytes.count == width * height * 4, geometry.outerLips.count == 8,
              geometry.innerLips.count == 6, connected(bytes) else { return false }
        let corners = geometry.outerLips.sorted { $0.x < $1.x }
        guard let left = corners.first, let right = corners.last else { return false }
        for (point, x) in [(left, 216.0), (right, 424.0)] {
            let dx = Double(point.x) * 640 - x
            let dy = Double(point.y) * 800 - 560
            if dx * dx + dy * dy > 16 { return false }
            if !(80...81).contains(Int(bytes[(560 * width + Int(x)) * 4])) { return false }
        }
        for (points, rx, ry, outer) in [(geometry.outerLips, 104.0, 52.0, true),
                                         (geometry.innerLips, 52.0, 24.0, false)] {
            for point in points {
                let x = Double(point.x) * 640
                let y = Double(point.y) * 800
                guard x.isFinite, y.isFinite, x >= 0, x < 640, y >= 0, y < 800 else { return false }
                let dx = (x - 320) / rx
                let dy = (y - 560) / ry
                let q = dx * dx + dy * dy
                guard q >= 0.80 && q <= 1.20 else { return false }
                let v = Int(bytes[(Int(y) * width + Int(x)) * 4])
                if outer ? !(80...81).contains(v) : !([32, 33, 144, 145].contains(v)) { return false }
            }
        }
        return true
    }

    private func connected(_ bytes: [UInt8]) -> Bool {
        guard bytes.count == width * height * 4 else { return false }
        let anchors = [(216, 560), (424, 560), (320, 508), (320, 612), (320, 560)]
        guard anchors.allSatisfy({ bytes[($0.1 * width + $0.0) * 4] <= 145 }),
              bytes[(508 * width + 320) * 4] <= 81, bytes[(612 * width + 320) * 4] <= 81,
              bytes[(560 * width + 320) * 4] <= 33 else { return false }
        // Restrict to the independently declared mouth rectangle, never ROI.
        var dark = Set<Int>()
        for y in 508...612 {
            for x in 216...424 where bytes[(y * width + x) * 4] <= 145 { dark.insert(y * width + x) }
        }
        let start = 560 * width + 216
        guard dark.remove(start) != nil else { return false }
        var queue = [start]
        var cursor = 0
        while cursor < queue.count {
            let p = queue[cursor]
            cursor += 1
            for dy in -1...1 {
                for dx in -1...1 where dx != 0 || dy != 0 {
                    let next = p + dy * width + dx
                    if dark.remove(next) != nil { queue.append(next) }
                }
            }
        }
        return dark.isEmpty && anchors.allSatisfy { queue.contains($0.1 * width + $0.0) }
    }

    private func set(_ bytes: inout [UInt8], _ x: Int, _ y: Int, _ v: Int) {
        guard x >= 0, x < width, y >= 0, y < height else { return }
        let i = (y * width + x) * 4
        bytes[i] = UInt8(v)
        bytes[i + 1] = UInt8(v)
        bytes[i + 2] = UInt8(v)
    }

    private func removedMouth(_ source: [UInt8]) -> [UInt8] {
        var bytes = source
        for y in 500...620 {
            for x in 204...436 { set(&bytes, x, y, 224 + (x / 64 + y / 64) % 2) }
        }
        return bytes
    }

    private func shiftedMouth(_ source: [UInt8], dx: Int, dy: Int, reflect: Bool) -> [UInt8] {
        var bytes = removedMouth(source)
        for y in 500...620 {
            for x in 204...436 where source[(y * width + x) * 4] <= 145 {
                let tx = reflect ? width - 1 - (x + dx) : x + dx
                set(&bytes, tx, y + dy, Int(source[(y * width + x) * 4]))
            }
        }
        return bytes
    }

    private func contract() throws -> [String: Any] {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        guard let object = try JSONSerialization.jsonObject(with: Data(contentsOf: root.appendingPathComponent(
            "scripts/face-feature-batch-manifest.json"))) as? [String: Any],
              let rows = object["semanticContracts"] as? [[String: Any]] else { throw Admission.contract }
        let matches = rows.filter { $0["caseID"] as? String == "mouthWidth_minus0p35" }
        guard matches.count == 1, let row = matches.first else { throw Admission.contract }
        return row
    }

    private func raster(_ row: [String: Any]) throws -> Raster {
        let ppm = try ["minXPPM", "maxXPPM", "minYPPM", "maxYPPM"].map { key -> Int64 in
            guard let value = row[key] as? Int64 else { throw Admission.contract }
            return value
        }
        return try Raster(ppm, width, height)
    }

    private func targetRegions() throws -> [Raster] {
        guard let rows = try contract()["targetRegions"] as? [[String: Any]],
              rows.map({ $0["id"] as? String }) == ["leftCorner", "rightCorner"] else { throw Admission.contract }
        return try rows.map(raster)
    }

    private func protectedRegions() throws -> [Raster] {
        guard let groups = try contract()["protectedRegions"] as? [[String: Any]],
              groups.map({ $0["id"] as? String }) == ["mouthHeight", "surroundingFace", "background", "watermark"]
        else { throw Admission.contract }
        return try groups.flatMap { group -> [Raster] in
            guard let rows = group["regions"] as? [[String: Any]], !rows.isEmpty else { throw Admission.contract }
            return try rows.map(raster)
        }
    }

    private struct Raster {
        let edges: [Int]
        init(_ ppm: [Int64], _ width: Int, _ height: Int) throws {
            guard ppm.count == 4, width > 0, height > 0,
                  ppm.allSatisfy({ (0...1_000_000).contains($0) }) else { throw Admission.contract }
            edges = try zip(ppm, [width, width, height, height]).map { edge, dimension in
                let value = edge.multipliedReportingOverflow(by: Int64(dimension))
                guard !value.overflow, let result = Int(exactly: value.partialValue / 1_000_000) else { throw Admission.contract }
                return result
            }
            guard edges[0] < edges[1], edges[2] < edges[3] else { throw Admission.contract }
        }
        func contains(_ x: Double, _ y: Double) -> Bool {
            x >= Double(edges[0]) && x < Double(edges[1]) && y >= Double(edges[2]) && y < Double(edges[3])
        }
    }
    private enum Admission: Error { case carrier, mapping, contract }
}
