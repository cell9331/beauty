import Foundation
import BeautyCore
import BeautyDetection
import CoreImage
import XCTest
@testable import BeautyEffects

final class BeautySourceContourAttachmentsTests: XCTestCase {
    private let width = 240, height = 240
    private let origin = SIMD2<Double>(120, 80)
    private let contour = [SIMD2<Double>(-50, -8), SIMD2(-50, 48), SIMD2(0, 100),
                           SIMD2(50, 48), SIMD2(50, -8)]

    func testSourceOnlyAdmissionAggregatesOrMeaningfulColoredFallback() throws {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            let positive = try XCTUnwrap(qualify(carrier()))
            let competing = try XCTUnwrap(qualify(carrier(.competing)))
            XCTAssertTrue(positive.left.isQualified && positive.right.isQualified)
            XCTAssertFalse(competing.left.isQualified || competing.right.isQualified)
            try checkAndPrintAggregates(positive, sourceKind: "generated-colored-positive")
            try checkAndPrintAggregates(competing, sourceKind: "generated-competing-negative")
            return
        }
        // Same actual detector, canonical RGBA render and pixel frame used by
        // the production map. Paths and transient source geometry are omitted
        // from the only diagnostic payload, which consists of integer counts.
        let image = try XCTUnwrap(CIImage(contentsOf: URL(fileURLWithPath: path),
                                        options: [.applyOrientationProperty: true]))
        XCTAssertEqual(image.extent.origin, .zero)
        var detector = BeautyFaceDetector.production()
        let detected = detector.detect(image: image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            imageExtent: image.extent.size, purpose: .geometryAndLocalSupport)
        let observation = try XCTUnwrap(detected.observations.first)
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let sourceWidth = Int(image.extent.width), sourceHeight = Int(image.extent.height)
        var source = [UInt8](repeating: 0, count: sourceWidth * sourceHeight * 4)
        let cs = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        CIContext(options: [.workingColorSpace: cs, .outputColorSpace: cs]).render(image,
            toBitmap: &source, rowBytes: sourceWidth * 4, bounds: image.extent,
            format: .RGBA8, colorSpace: cs)
        let evidence = try attachmentEvidence(face: face, source: source,
                                             width: sourceWidth, height: sourceHeight)
        let repeated = try attachmentEvidence(face: face, source: source,
                                             width: sourceWidth, height: sourceHeight)
        XCTAssertTrue(evidence.left.diagnostics == repeated.left.diagnostics &&
                      evidence.right.diagnostics == repeated.right.diagnostics)
        try checkAndPrintAggregates(evidence, sourceKind: "actual-production-source")
    }

    func testColoredConnectedCheekShortensOnlyClearSkinReserve() throws {
        let source = carrier()
        let evidence = try XCTUnwrap(qualify(source))
        XCTAssertTrue(evidence.left.isQualified)
        XCTAssertTrue(evidence.right.isQualified)
        XCTAssertTrue(evidence.left.rows.contains { $0.qualified && $0.innerBoundaryX < -42 })
        XCTAssertTrue(evidence.right.rows.contains { $0.qualified && $0.innerBoundaryX > 42 })
        // This independently declared cheek pixel lies in the former .08 span
        // reserve; source-connected evidence recovers useful interior tissue.
        XCTAssertFalse(evidence.protectsPixel(x: 79, y: 102))
        XCTAssertGreaterThan(evidence.distanceToReserve(x: 79.5, y: 102.5), 0)
        for y in 84..<120 {
            for x in 52..<188 where actualEarOrHair(x: x, y: y) {
                XCTAssertTrue(evidence.protectsPixel(x: x, y: y), "source attachment pixel escaped reserve")
            }
        }
    }

    func testProposalFieldMovesPredeclaredCheekFeatureBothDirectionsAndKeepsAttachmentsExact() throws {
        let source = carrier()
        let evidence = try XCTUnwrap(qualify(source))
        for displacement in [-1.0, 1.0] {
            let output = proposalRender(source, evidence: evidence, displacement: displacement)
            var usefulChanges = 0
            for y in 94..<113 {
                for x in 77..<84 {
                    let i = (y * width + x) * 4
                    if source[i..<i + 4] != output[i..<i + 4] { usefulChanges += 1 }
                }
            }
            XCTAssertGreaterThan(usefulChanges, 16, "clear cheek inside former broad collar must remain useful")
            for y in 80..<129 {
                for x in 0..<width where actualEarOrHair(x: x, y: y) {
                    let i = (y * width + x) * 4
                    XCTAssertTrue(source[i..<i + 4] == output[i..<i + 4], "attachment RGBA changed")
                }
            }
            // Independent stripe's red gradient determines the requested sign.
            let index = (102 * width + 79) * 4
            XCTAssertEqual(Double(Int(output[index]) - Int(source[index])) * displacement < 0, true)
            XCTAssertTrue(output == proposalRender(source, evidence: evidence, displacement: displacement))
        }
    }

    func testMissingMalformedTransparentAndGrayscaleSourcesKeepBroadFallback() throws {
        var transparent = carrier(); transparent[3] = 0
        var grayscale = carrier()
        for i in stride(from: 0, to: grayscale.count, by: 4) {
            let value = UInt8((Int(grayscale[i]) + Int(grayscale[i + 1]) + Int(grayscale[i + 2])) / 3)
            grayscale[i] = value; grayscale[i + 1] = value; grayscale[i + 2] = value
        }
        for input in [nil, [UInt8](repeating: 255, count: 7), transparent, grayscale] {
            let evidence = try XCTUnwrap(qualify(input))
            XCTAssertFalse(evidence.left.isQualified)
            XCTAssertFalse(evidence.right.isQualified)
            XCTAssertEqual(evidence.reserveRegionCount, 2, "continuous fallback has two exact rectangular unions")
            XCTAssertTrue(evidence.left.rows.allSatisfy { $0.innerBoundaryX == -42 && !$0.qualified })
            XCTAssertTrue(evidence.right.rows.allSatisfy { $0.innerBoundaryX == 42 && !$0.qualified })
            XCTAssertTrue(evidence.protectsPixel(x: 79, y: 102))
        }
    }

    func testCompetingCleftOcclusionAndNoDarkCleftDoNotRecoverGuard() throws {
        for kind in [CarrierKind.competing, .occluded, .noCleft, .texturedSeed, .shortRun] {
            let evidence = try XCTUnwrap(qualify(carrier(kind)))
            XCTAssertFalse(evidence.left.isQualified, "ambiguous carrier \(kind) qualified left")
            XCTAssertFalse(evidence.right.isQualified, "ambiguous carrier \(kind) qualified right")
            XCTAssertTrue(evidence.protectsPixel(x: 79, y: 102), "ambiguous carrier \(kind) recovered its protected interior")
        }
    }

    func testObservedBoundaryDisagreementAndInvalidFrameFailClosed() throws {
        let source = carrier()
        let shifted = contour.map { SIMD2($0.x * 0.7, $0.y) }
        let disagreement = try XCTUnwrap(qualify(source, contour: shifted))
        XCTAssertFalse(disagreement.left.isQualified)
        XCTAssertFalse(disagreement.right.isQualified)
        XCTAssertNil(BeautySourceContourAttachments.qualify(
            sourceRGBA: source, width: width, height: height, contour: contour, origin: origin,
            axisX: SIMD2(1, 0), axisY: SIMD2(1, 0), span: 100, chin: 100, attachmentBottom: 48))
        XCTAssertEqual(disagreement.distanceToReserve(x: .nan, y: 80), 0)
    }

    func testWholePixelCoverageAndInterpolatedSourceFootprintsAreReserved() throws {
        let evidence = try XCTUnwrap(qualify(carrier()))
        // The complete dark cleft and ear are immutable even if a requested
        // destination is skin. The renderer must reject any of its four source
        // footprint pixels touching this reserve, independent of warp sign.
        for x in [68, 69, 70, 169, 170, 171] {
            XCTAssertTrue(evidence.protectsPixel(x: x, y: 100))
            XCTAssertEqual(evidence.distanceToReserve(x: Double(x) + 0.5, y: 100.5), 0)
        }
        let rotated = try XCTUnwrap(BeautySourceContourAttachments.qualify(
            sourceRGBA: nil, width: width, height: height, contour: contour, origin: origin,
            axisX: SIMD2(sqrt(0.5), sqrt(0.5)), axisY: SIMD2(-sqrt(0.5), sqrt(0.5)),
            span: 100, chin: 100, attachmentBottom: 48))
        XCTAssertTrue(rotated.protectsPixel(x: 83, y: 46))
        XCTAssertFalse(rotated.protectsPixel(x: 120, y: 90))
    }

    func testConnectedShadowedSkinRecoversInteriorWithoutQualifyingStrictOuterAttachment() throws {
        let source = carrier(.shadowed)
        let evidence = try XCTUnwrap(qualify(source))
        for side in [evidence.left, evidence.right] {
            XCTAssertFalse(side.isQualified)
            XCTAssertEqual(side.diagnostics.qualifiedRows, 0)
            XCTAssertTrue(side.hasInnerSkinRecovery)
            XCTAssertTrue(side.hasRecoveredReserve)
            XCTAssertGreaterThan(side.innerSkinDiagnostics.adaptedSkinRows, 0)
        }
        XCTAssertFalse(evidence.protectsPixel(x: 79, y: 102))
        for displacement in [-1.0, 1.0] {
            let output = proposalRender(source, evidence: evidence, displacement: displacement)
            let index = (102 * width + 79) * 4
            XCTAssertTrue(Double(Int(output[index]) - Int(source[index])) * displacement < 0)
            for y in 80..<129 { for x in 0..<width where actualEarOrHair(x: x, y: y) {
                let i = (y * width + x) * 4
                XCTAssertTrue(source[i..<i + 4] == output[i..<i + 4])
            } }
        }
        try checkAndPrintAggregates(evidence, sourceKind: "generated-connected-shadow-positive")
    }

    func testConnectedSkinBranchRejectsGoldenHairNeutralOcclusionAndCompetingCleft() throws {
        for kind in [CarrierKind.goldenHair, .shadowedNeutralOcclusion, .shadowedCompeting] {
            let evidence = try XCTUnwrap(qualify(carrier(kind)))
            for side in [evidence.left, evidence.right] {
                XCTAssertFalse(side.isQualified)
                XCTAssertFalse(side.hasInnerSkinRecovery)
                XCTAssertFalse(side.hasRecoveredReserve)
            }
            XCTAssertTrue(evidence.protectsPixel(x: 79, y: 102))
        }
    }

    func testIndexedQueriesPreserveIndependentSlabUnionIncludingMixedFallbackRuns() throws {
        for kind in [CarrierKind.shadowed, .partialShadowed] {
            let evidence = try XCTUnwrap(qualify(carrier(kind)))
            XCTAssertTrue(evidence.left.hasInnerSkinRecovery && evidence.right.hasInnerSkinRecovery)
            func exhaustive(_ x: Double, _ y: Double) -> Double {
                let p = SIMD2(x - origin.x, y - origin.y)
                var result = Double.infinity
                for side in [evidence.left, evidence.right] {
                    let outer = Double(side.side.rawValue) * 74
                    for row in side.rows {
                        let minX = min(outer, row.innerBoundaryX) - 2.5
                        let maxX = max(outer, row.innerBoundaryX) + 2.5
                        let dx = max(0, max(minX - p.x, p.x - maxX))
                        let dy = max(0, max(row.localY - 3 - p.y, p.y - row.localY - 3))
                        result = min(result, hypot(dx, dy))
                    }
                }
                return result
            }
            for y in 72...135 { for x in stride(from: 44, through: 196, by: 4) {
                XCTAssertEqual(evidence.protectsPixel(x: x, y: y),
                               exhaustive(Double(x) + 0.5, Double(y) + 0.5) == 0)
                XCTAssertEqual(evidence.distanceToReserve(x: Double(x) + 0.25, y: Double(y) + 0.75),
                               exhaustive(Double(x) + 0.25, Double(y) + 0.75), accuracy: 0.0000001)
            } }
        }
    }

    func testDepartureOwnershipAt512And1280KeepsWholeWideUnknownExteriorFixed() throws {
        for size in [512, 1280] {
            let scale = Double(size) / Double(width)
            let source = scaledCarrier(.wideUnknown, size: size)
            let evidence = try XCTUnwrap(BeautySourceContourAttachments.qualify(
                sourceRGBA: source, width: size, height: size, contour: contour.map { $0 * scale },
                origin: origin * scale, axisX: SIMD2(1, 0), axisY: SIMD2(0, 1),
                span: 100 * scale, chin: 100 * scale, attachmentBottom: 48 * scale))
            for side in [evidence.left, evidence.right] {
                XCTAssertFalse(side.isQualified)
                XCTAssertFalse(side.hasInnerSkinRecovery)
                XCTAssertTrue(side.hasDepartureSkinRecovery)
                XCTAssertGreaterThan(side.departureSkinDiagnostics.qualifiedRows, 0)
            }
            var unreservedUnknownPixels = 0
            for y in Int(94 * scale)..<Int(113 * scale) {
                for x in 0..<size where abs((Double(x) + 0.5) / scale - 120) >= 49 {
                    if !evidence.protectsPixel(x: x, y: y) { unreservedUnknownPixels += 1 }
                }
            }
            XCTAssertEqual(unreservedUnknownPixels, 0, "whole unknown exterior must remain reserved at size \(size)")
            for displacement in [-scale, scale] {
                let output = proposalRenderSized(source, size: size, scale: scale,
                                                 evidence: evidence, displacement: displacement)
                var changed = 0, changedUnknownPixels = 0
                for y in Int(94 * scale)..<Int(113 * scale) { for x in 0..<size {
                    let i = (y * size + x) * 4
                    let same = source[i..<i + 4] == output[i..<i + 4]
                    if abs((Double(x) + 0.5) / scale - 120) >= 49 {
                        if !same { changedUnknownPixels += 1 }
                    }
                    else if !same { changed += 1 }
                } }
                XCTAssertEqual(changedUnknownPixels, 0, "whole unknown exterior must remain byte-exact at size \(size)")
                XCTAssertGreaterThan(changed, 16)
            }
            try checkAndPrintAggregates(evidence, sourceKind: "generated-wide-unknown-\(size)")
        }
    }

    func testDepartureOwnershipRejectsGoldenColdNeutralCompetitionAndShortRuns() throws {
        for size in [512, 1280] {
            let scale = Double(size) / Double(width)
            for kind in [CarrierKind.goldenHair, .occluded, .shadowedNeutralOcclusion,
                         .shadowedCompeting, .departureShortRun] {
                let evidence = try XCTUnwrap(BeautySourceContourAttachments.qualify(
                    sourceRGBA: scaledCarrier(kind, size: size), width: size, height: size,
                    contour: contour.map { $0 * scale }, origin: origin * scale,
                    axisX: SIMD2(1, 0), axisY: SIMD2(0, 1), span: 100 * scale,
                    chin: 100 * scale, attachmentBottom: 48 * scale))
                XCTAssertFalse(evidence.left.hasDepartureSkinRecovery)
                XCTAssertFalse(evidence.right.hasDepartureSkinRecovery)
            }
        }
    }

    private func qualify(_ source: [UInt8]?, contour path: [SIMD2<Double>]? = nil)
        -> BeautySourceContourAttachments.Evidence? {
        BeautySourceContourAttachments.qualify(
            sourceRGBA: source, width: width, height: height, contour: path ?? contour, origin: origin,
            axisX: SIMD2(1, 0), axisY: SIMD2(0, 1), span: 100, chin: 100, attachmentBottom: 48)
    }

    private func attachmentEvidence(face: FaceGeometry, source: [UInt8], width: Int, height: Int)
        throws -> BeautySourceContourAttachments.Evidence {
        let support = try XCTUnwrap(face.observedFaceSupport)
        let nasal = try XCTUnwrap(face.observedNoseSupport)
        let left = face.leftEyeSupport?.contour ?? face.leftEye
        let right = face.rightEyeSupport?.contour ?? face.rightEye
        XCTAssertGreaterThanOrEqual(left.count, 4); XCTAssertGreaterThanOrEqual(right.count, 4)
        XCTAssertNotNil(face.observedEyebrowSupport)
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> {
            SIMD2(Double(p.x) * Double(width), Double(p.y) * Double(height))
        }
        func mean(_ points: [SIMD2<Float>]) -> SIMD2<Double> {
            points.map(pixel).reduce(.zero, +) / Double(points.count)
        }
        let eyeVector = mean(right) - mean(left), distance = hypot(eyeVector.x, eyeVector.y)
        XCTAssertGreaterThan(distance, 4)
        let axisX = eyeVector / distance, axisY = SIMD2(-axisX.y, axisX.x)
        let frameOrigin = (mean(left) + mean(right)) * 0.5
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let delta = p - frameOrigin
            return SIMD2(delta.x * axisX.x + delta.y * axisX.y,
                         delta.x * axisY.x + delta.y * axisY.y)
        }
        let path = support.contour.map { local(pixel($0)) }
        let lowX = try XCTUnwrap(path.map(\.x).min()), highX = try XCTUnwrap(path.map(\.x).max())
        let chin = try XCTUnwrap(path.map(\.y).max()), span = highX - lowX
        let bottom = (nasal.crest + nasal.contour).map {
            local(pixel(SIMD2(Float($0.x), Float($0.y)))).y
        }.max() ?? 0
        return try XCTUnwrap(BeautySourceContourAttachments.qualify(
            sourceRGBA: source, width: width, height: height, contour: path, origin: frameOrigin,
            axisX: axisX, axisY: axisY, span: span, chin: chin,
            attachmentBottom: max(0, bottom) + span * 0.04))
    }

    private func checkAndPrintAggregates(_ evidence: BeautySourceContourAttachments.Evidence,
                                        sourceKind: String) throws {
        for side in [evidence.left, evidence.right] {
            let d = side.diagnostics
            XCTAssertGreaterThan(d.totalRows, 0)
            XCTAssertEqual(d.rejectedRows + d.candidateRows, d.totalRows)
            XCTAssertEqual(d.candidateRows, d.shortRunRejectedRows + d.nonReducingRows + d.qualifiedRows)
            XCTAssertEqual(d.qualifiedRows, side.rows.filter { $0.qualified }.count)
            XCTAssertEqual(side.isQualified, d.qualifiedRows > 0)
            let inner = side.innerSkinDiagnostics
            XCTAssertEqual(inner.rejectedRows + inner.candidateRows, inner.totalRows)
            XCTAssertEqual(inner.candidateRows, inner.shortRunRejectedRows + inner.nonReducingRows + inner.qualifiedRows)
            XCTAssertEqual(inner.qualifiedRows, side.rows.filter { $0.innerSkinBoundaryX != nil }.count)
            let departure = side.departureSkinDiagnostics
            XCTAssertEqual(departure.rejectedRows + departure.candidateRows, departure.totalRows)
            XCTAssertEqual(departure.candidateRows,
                departure.shortRunRejectedRows + departure.nonReducingRows + departure.qualifiedRows)
            XCTAssertEqual(departure.qualifiedRows, side.rows.filter { $0.departureSkinBoundaryX != nil }.count)
        }
        let object: [String: Any] = ["kind": "source-attachment-admission-counts",
            "sourceKind": sourceKind, "left": evidence.left.diagnostics.aggregates,
            "right": evidence.right.diagnostics.aggregates,
            "innerSkinLeft": evidence.left.innerSkinDiagnostics.aggregates,
            "innerSkinRight": evidence.right.innerSkinDiagnostics.aggregates,
            "departureSkinLeft": evidence.left.departureSkinDiagnostics.aggregates,
            "departureSkinRight": evidence.right.departureSkinDiagnostics.aggregates,
            "departureSkinRecoverySideCount": (evidence.left.hasDepartureSkinRecovery ? 1 : 0) + (evidence.right.hasDepartureSkinRecovery ? 1 : 0),
            "innerSkinRecoverySideCount": (evidence.left.hasInnerSkinRecovery ? 1 : 0) + (evidence.right.hasInnerSkinRecovery ? 1 : 0),
            "qualifiedSideCount": (evidence.left.isQualified ? 1 : 0) + (evidence.right.isQualified ? 1 : 0),
            "reserveRegionCount": evidence.reserveRegionCount]
        let data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        print(try XCTUnwrap(String(data: data, encoding: .utf8)))
    }

    private enum CarrierKind {
        case clear, competing, occluded, noCleft, texturedSeed, shortRun
        case shadowed, goldenHair, shadowedNeutralOcclusion, shadowedCompeting
        case partialShadowed
        case wideUnknown
        case departureShortRun
    }

    /// Warm cheek tissue with a subdued independent stripe, warm outer ear
    /// tissue, dark brown cleft and cool background. Qualification receives no
    /// semantic labels; those labels below are an independent pixel oracle.
    private func carrier(_ kind: CarrierKind = .clear) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let dx = abs(Double(x) + 0.5 - origin.x)
                let localY = Double(y) + 0.5 - origin.y
                var color = [70, 115, 140]
                if dx < 49 {
                    let stripe = max(0, 12 - abs(x - 81) * 3)
                    let texture = ((x * 7 + y * 3) % 3) - 1
                    color = [211 + stripe + texture, 161 + stripe / 2 + texture, 132 + texture]
                    if kind == .shadowed || kind == .partialShadowed || kind == .wideUnknown || kind == .departureShortRun || kind == .shadowedNeutralOcclusion || kind == .shadowedCompeting {
                        let scale = 1 - min(0.3, max(0, dx - 41) * 0.03)
                        color = color.map { Int((Double($0) * scale).rounded()) }
                    }
                } else if dx < 55 { color = [67, 43, 28] }
                else if dx < 68 { color = [194, 145, 117] }
                if (kind == .competing || kind == .shadowedCompeting) && (57..<60).contains(dx) { color = [66, 42, 27] }
                if kind == .goldenHair && dx >= 42 && dx < 68 { color = [243, 189, 58] }
                if kind == .shadowedNeutralOcclusion && dx >= 49 && dx < 55 { color = [25, 25, 25] }
                if kind == .occluded && dx >= 49 && dx < 68 { color = [33, 110, 130] }
                if kind == .noCleft && dx >= 49 && dx < 55 { color = [207, 158, 130] }
                if kind == .texturedSeed && dx >= 34 && dx <= 42 {
                    color = x % 2 == 0 ? [225, 188, 146] : [140, 80, 54]
                }
                if kind == .shortRun && !(20..<24).contains(localY) && dx >= 49 && dx < 68 {
                    color = [33, 110, 130]
                }
                if kind == .partialShadowed && !(12..<35).contains(localY) && dx >= 49 && dx < 68 {
                    color = [33, 110, 130]
                }
                if (kind == .wideUnknown || kind == .departureShortRun) && dx >= 49 { color = [67, 43, 28] }
                if kind == .departureShortRun && !(20..<21).contains(localY) && dx >= 49 {
                    color = [33, 110, 130]
                }
                let i = (y * width + x) * 4
                for c in 0..<3 { bytes[i + c] = UInt8(color[c]) }
            }
        }
        return bytes
    }

    private func scaledCarrier(_ kind: CarrierKind, size: Int) -> [UInt8] {
        let base = carrier(kind), scale = Double(size) / Double(width)
        var result = [UInt8](repeating: 255, count: size * size * 4)
        for y in 0..<size { for x in 0..<size {
            let px = max(0, min(Double(width - 1), (Double(x) + 0.5) / scale - 0.5))
            let py = max(0, min(Double(height - 1), (Double(y) + 0.5) / scale - 0.5))
            let x0 = Int(floor(px)), y0 = Int(floor(py)), x1 = min(width - 1, x0 + 1), y1 = min(height - 1, y0 + 1)
            let fx = px - Double(x0), fy = py - Double(y0)
            for c in 0..<3 {
                let top = Double(base[(y0 * width + x0) * 4 + c]) * (1 - fx) + Double(base[(y0 * width + x1) * 4 + c]) * fx
                let bottom = Double(base[(y1 * width + x0) * 4 + c]) * (1 - fx) + Double(base[(y1 * width + x1) * 4 + c]) * fx
                result[(y * size + x) * 4 + c] = UInt8((top * (1 - fy) + bottom * fy).rounded())
            }
        } }
        return result
    }

    private func proposalRenderSized(_ source: [UInt8], size: Int, scale: Double,
        evidence: BeautySourceContourAttachments.Evidence, displacement: Double) -> [UInt8] {
        var result = source
        for y in Int(94 * scale)..<Int(113 * scale) { for x in Int(76 * scale)..<Int(89 * scale) {
            let distance = evidence.distanceToReserve(x: Double(x) + 0.5, y: Double(y) + 0.5)
            let q = min(1, distance / (4 * scale)), fade = q * q * (3 - 2 * q)
            let sampleX = Double(x) - displacement * fade
            let x0 = Int(floor(sampleX)), x1 = x0 + 1
            guard !evidence.protectsPixel(x: x, y: y),
                  !evidence.protectsPixel(x: x0, y: y), !evidence.protectsPixel(x: x1, y: y),
                  !evidence.protectsPixel(x: x0, y: y + 1), !evidence.protectsPixel(x: x1, y: y + 1) else { continue }
            let i = (y * size + x) * 4, a = (y * size + x0) * 4, b = (y * size + x1) * 4
            let f = sampleX - Double(x0)
            for c in 0..<3 { result[i + c] = UInt8((Double(source[a + c]) * (1 - f) + Double(source[b + c]) * f).rounded()) }
        } }
        return result
    }

    private func actualEarOrHair(x: Int, y: Int) -> Bool {
        let d = abs(Double(x) + 0.5 - origin.x)
        return d >= 49 && d < 68
    }

    /// A small continuous proposal field, not an SDK appearance oracle. This
    /// tests the helper's source/destination reserve contract against labelled
    /// attachment pixels and a separately declared cheek feature.
    private func proposalRender(_ source: [UInt8], evidence: BeautySourceContourAttachments.Evidence,
                                displacement: Double) -> [UInt8] {
        var result = source
        for y in 94..<113 {
            for x in 76..<89 {
                let distance = evidence.distanceToReserve(x: Double(x) + 0.5, y: Double(y) + 0.5)
                let q = min(1, distance / 3), fade = q * q * (3 - 2 * q)
                let sampleX = Double(x) - displacement * fade
                let x0 = Int(floor(sampleX)), x1 = x0 + 1
                guard !evidence.protectsPixel(x: x, y: y),
                      !evidence.protectsPixel(x: x0, y: y), !evidence.protectsPixel(x: x1, y: y),
                      !evidence.protectsPixel(x: x0, y: y + 1), !evidence.protectsPixel(x: x1, y: y + 1)
                else { continue }
                let i = (y * width + x) * 4, a = (y * width + x0) * 4, b = (y * width + x1) * 4
                let f = sampleX - Double(x0)
                for c in 0..<3 {
                    result[i + c] = UInt8((Double(source[a + c]) * (1 - f) + Double(source[b + c]) * f).rounded())
                }
            }
        }
        return result
    }
}
