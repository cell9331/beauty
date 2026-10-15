import BeautyCore
import BeautyDetection
import Foundation
import CoreImage
import XCTest
@testable import BeautyEffects

/// Source-fixed adversarial carriers: complete feature envelopes and textured
/// near-background pixels are independent of the implementation's lattice.
final class FaceContinuousProtectionTests: XCTestCase {
    private let width = 480, height = 640
    private typealias Region = (Double, Double, Double, Double)
    private let browRegions: [Region] = [(0.29, 0.45, 0.24, 0.29), (0.55, 0.71, 0.24, 0.29)]
    // A wide, asymmetric observed nasal envelope deliberately approaches the
    // contour band; the caller's protected tissue must win over cheek geometry.
    private let noseRegion: Region = (0.29, 0.38, 0.40, 0.52)

    private func points(_ region: Region) -> [SIMD2<Float>] {
        [SIMD2(Float(region.0), Float(region.2)), SIMD2(Float(region.1), Float(region.2)),
         SIMD2(Float(region.1), Float(region.3)), SIMD2(Float(region.0), Float(region.3))]
    }

    private func anatomy(dense: Bool = false, malformedNose: Bool = false) throws -> FaceGeometry {
        let contour = (0...20).map { i -> SIMD2<Float> in
            let a = Float(i) / 20 * .pi
            return SIMD2(0.5 - 0.24 * cos(a), 0.36 + 0.42 * sin(a))
        }
        func trace(_ region: Region, side: BeautyObservedEyebrowSide) -> BeautyEyebrowSemanticTrace {
            let p = points(region)
            return BeautyEyebrowSemanticTrace(side: side, points: p,
                innerEndpoint: side == .left ? p[1] : p[0],
                outerEndpoint: side == .left ? p[0] : p[1],
                center: (p[0] + p[2]) * 0.5, apexIndex: 0)
        }
        let nosePoints = points(noseRegion)
        let nasal = BeautyObservedNoseSupport(
            crest: malformedNose ? [CoordinatePoint(x: .nan, y: 0.4)] :
                nosePoints.map { CoordinatePoint(x: Double($0.x), y: Double($0.y)) },
            contour: nosePoints.map { CoordinatePoint(x: Double($0.x), y: Double($0.y)) })
        var mesh: BeautyFaceMesh?
        if dense {
            var meshPoints = [SIMD3<Float>](repeating: SIMD3(0.5, 0.5, 0), count: 478)
            func assign(_ indices: [Int], _ region: Region) {
                for (i, index) in indices.enumerated() {
                    let a = Double(i) / Double(indices.count) * 2 * .pi
                    meshPoints[index] = SIMD3(
                        Float((region.0 + region.1) * 0.5 + (region.1 - region.0) * 0.5 * cos(a)),
                        Float((region.2 + region.3) * 0.5 + (region.3 - region.2) * 0.5 * sin(a)), 0)
                }
            }
            assign(MediaPipeFaceTopology.leftBrowEnvelope, browRegions[0])
            assign(MediaPipeFaceTopology.rightBrowEnvelope, browRegions[1])
            assign(MediaPipeFaceTopology.noseContour, noseRegion)
            assign(MediaPipeFaceTopology.noseCrest, noseRegion)
            mesh = try XCTUnwrap(BeautyFaceMesh(points: meshPoints))
        }
        return FaceGeometry(bounds: FaceBounds(x: 0.24, y: 0.14, width: 0.52, height: 0.66),
            faceContour: contour,
            observedFaceSupport: BeautyFaceSemanticSupport(contour: contour,
                medianLine: [SIMD2(0.5, 0.34), SIMD2(0.5, 0.55), SIMD2(0.5, 0.78)], apexIndex: 10),
            leftEye: points((0.34, 0.44, 0.30, 0.36)),
            rightEye: points((0.56, 0.66, 0.30, 0.36)),
            nose: nosePoints,
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(
                left: trace(browRegions[0], side: .left), right: trace(browRegions[1], side: .right)),
            observedOuterLips: points((0.40, 0.60, 0.57, 0.64)),
            observedNoseSupport: nasal,
            denseSupport: mesh.map(BeautyDenseFaceSupport.init(mesh:)))
    }

    private func texture(silhouette: Bool = false) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            let nx = (Double(x) + 0.5) / Double(width), ny = (Double(y) + 0.5) / Double(height)
            let inside = pow((nx - 0.5) / 0.24, 2) + pow((ny - 0.36) / 0.42, 2) <= 1
            if silhouette && inside {
                bytes[i] = 220; bytes[i + 1] = 170; bytes[i + 2] = 130
            } else {
                bytes[i] = UInt8((x * 17 + y * 3) % 256)
                bytes[i + 1] = UInt8((x * 11 + y * 7) % 256)
                bytes[i + 2] = UInt8((x * 5 + y * 13) % 256)
            }
        } }
        return bytes
    }

    private var fields: [(WritableKeyPath<BeautyEffectiveStrengths, Float>, Float)] { [
        (\.faceSlim, BeautySafetyCaps.faceSlim), (\.faceSmall, BeautySafetyCaps.faceSmall),
        (\.jawSlim, BeautySafetyCaps.jawSlim), (\.faceVShape, BeautySafetyCaps.faceVShape),
        (\.templeFullness, BeautySafetyCaps.templeFullness), (\.cheekboneSlim, BeautySafetyCaps.cheekboneSlim),
        (\.chinLength, BeautySafetyCaps.chinLength), (\.chinTaper, BeautySafetyCaps.chinTaper)
    ] }

    func testSourceCapConstraintDiagnostics() throws {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            let face = try anatomy()
            var strengths = BeautyEffectiveStrengths(); strengths.faceSlim = BeautySafetyCaps.faceSlim
            let map = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height, face: face, strengths: strengths))
            XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
            XCTAssertGreaterThan(map.maximumDisplacement, 1)
            return
        }
        let image = try XCTUnwrap(CIImage(contentsOf: URL(fileURLWithPath: path), options: [.applyOrientationProperty: true]))
        var detector = BeautyFaceDetector.production()
        let detected = detector.detect(image: image, metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            imageExtent: image.extent.size, purpose: .geometryAndLocalSupport)
        let observation = try XCTUnwrap(detected.observations.first)
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let sourceWidth = Int(image.extent.width), sourceHeight = Int(image.extent.height)
        var source = [UInt8](repeating: 0, count: sourceWidth * sourceHeight * 4)
        let cs = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        CIContext(options: [.workingColorSpace: cs, .outputColorSpace: cs]).render(image,
            toBitmap: &source, rowBytes: sourceWidth * 4, bounds: image.extent, format: .RGBA8, colorSpace: cs)
        for (index, entry) in fields.enumerated() { for sign: Float in (entry.0 == \.faceVShape ? [1] : [-1, 1]) {
            var strengths = BeautyEffectiveStrengths(); strengths[keyPath: entry.0] = entry.1 * sign
            let map = try XCTUnwrap(BeautyContinuousFaceMap(width: Int(image.extent.width),
                height: Int(image.extent.height), face: face, strengths: strengths, sourceRGBA: source))
            XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
            XCTAssertGreaterThan(map.maximumDisplacement, 1)
            print("source-cap-bounds fieldOrdinal=\(index) sign=\(Int(sign)) capResidualGradient=\(map.capGradientBeforeFinalBound) maximumDisplacement=\(map.maximumDisplacement) minimumLatticeSpacing=\(map.minimumLatticeSpacing) qualifiedAttachmentSides=\(map.qualifiedAttachmentSideCount) recoveredInnerSkinSides=\(map.recoveredInnerSkinSideCount) recoveredDepartureSkinSides=\(map.recoveredDepartureSkinSideCount) reversedCapDirectionNodes=\(map.reversedCapDirectionNodeCount)")
        } }
    }

    func testCompleteObservedNoseAndBrowBoxesStaySourceExactAtEverySignedQuarterLevel() throws {
        let source = texture()
        for dense in [false, true] {
            let face = try anatomy(dense: dense)
            for (key, cap) in fields { for sign: Float in (key == \.faceVShape ? [1] : [-1, 1]) {
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    var strengths = BeautyEffectiveStrengths()
                    strengths[keyPath: key] = cap * sign * fraction
                    let map = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height,
                        face: face, strengths: strengths))
                    let output = map.applyRGBA(source)
                    var protectedChanges = 0, changed = 0, alphaChanges = 0
                    for y in 0..<height { for x in 0..<width {
                        let px = Double(x) + 0.5, py = Double(y) + 0.5
                        let protected = (browRegions + [noseRegion]).contains { b in
                            px >= b.0 * Double(width) - 2 && px <= b.1 * Double(width) + 2 &&
                            py >= b.2 * Double(height) - 2 && py <= b.3 * Double(height) + 2
                        }
                        let i = (y * width + x) * 4
                        if (0..<4).contains(where: { output[i + $0] != source[i + $0] }) {
                            changed += 1
                            if protected { protectedChanges += 1 }
                        }
                        if output[i + 3] != source[i + 3] { alphaChanges += 1 }
                    } }
                    XCTAssertEqual(protectedChanges, 0, "\(key) sign=\(sign) level=\(fraction) dense=\(dense)")
                    XCTAssertEqual(alphaChanges, 0)
                    XCTAssertGreaterThan(changed, 128, "protection cannot pass by disabling the requested effect")
                    XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                    XCTAssertTrue(output == map.applyRGBA(source), "determinism")
                }
            } }
        }
    }

    func testTexturedNearBackgroundOutsideMaximumSilhouetteSweepStaysSourceExact() throws {
        let source = texture(silhouette: true), face = try anatomy()
        // The frozen 6% contour-span budget plus whole-texel padding encloses
        // every legal silhouette sweep, independently of the generated map.
        let margin = 0.48 * Double(width) * 0.06 + 3
        for (key, cap) in fields { for sign: Float in (key == \.faceVShape ? [1] : [-1, 1]) {
            var strengths = BeautyEffectiveStrengths(); strengths[keyPath: key] = cap * sign
            let map = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height,
                face: face, strengths: strengths))
            let output = map.applyRGBA(source)
            var backgroundChanges = 0, changed = 0
            for y in 0..<height { for x in 0..<width {
                let px = Double(x) + 0.5, py = Double(y) + 0.5, ny = py / Double(height)
                var protected = false
                if (0.45...0.70).contains(ny) {
                    let half = 0.24 * Double(width) * sqrt(max(0, 1 - pow((ny - 0.36) / 0.42, 2)))
                    protected = abs(px - Double(width) * 0.5) > half + margin
                }
                if py > 0.78 * Double(height) + margin { protected = true }
                let i = (y * width + x) * 4
                if (0..<4).contains(where: { output[i + $0] != source[i + $0] }) {
                    changed += 1
                    if protected { backgroundChanges += 1 }
                }
            } }
            XCTAssertEqual(backgroundChanges, 0, "\(key) sign=\(sign)")
            XCTAssertGreaterThan(changed, 128, "silhouette must remain active")
        } }
    }

    func testMalformedPresentNasalProtectionCannotReviveUnprotectedContourWarp() throws {
        let face = try anatomy(malformedNose: true)
        var strengths = BeautyEffectiveStrengths(); strengths.faceSlim = BeautySafetyCaps.faceSlim
        XCTAssertNil(BeautyContinuousFaceMap(width: width, height: height, face: face, strengths: strengths))
    }

    func testSourceLateralAttachmentsRemainFixedWhileLowerContourStillMoves() throws {
        let source = texture(), face = try anatomy()
        // Independent carrier ears and strands lie across the two contour
        // joins. They must remain original at both ends of every control;
        // these rectangles are fixed before constructing any displacement.
        let attachments: [Region] = [(0.16, 0.29, 0.31, 0.39), (0.71, 0.84, 0.31, 0.39)]
        for (key, cap) in fields { for sign: Float in (key == \.faceVShape ? [1] : [-1, 1]) {
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                var strengths = BeautyEffectiveStrengths()
                strengths[keyPath: key] = cap * sign * fraction
                let map = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height,
                    face: face, strengths: strengths))
                let output = map.applyRGBA(source)
                var protectedChanges = 0, changes = 0
                for y in 0..<height { for x in 0..<width {
                    let nx = (Double(x) + 0.5) / Double(width)
                    let ny = (Double(y) + 0.5) / Double(height)
                    let i = (y * width + x) * 4
                    if (0..<4).contains(where: { source[i + $0] != output[i + $0] }) {
                        changes += 1
                        if attachments.contains(where: { nx >= $0.0 && nx <= $0.1 && ny >= $0.2 && ny <= $0.3 }) {
                            protectedChanges += 1
                        }
                    }
                } }
                XCTAssertEqual(protectedChanges, 0, "\(key) sign=\(sign) level=\(fraction)")
                XCTAssertGreaterThan(changes, 128, "attachment protection must retain useful contour work")
            }
        } }
    }

    func testTempleSweepKeepsDestinationsInsideFixedAsymmetricSourcePolylineBand() throws {
        let face = try anatomy(), source = texture()
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> {
            SIMD2(Double(p.x) * Double(width), Double(p.y) * Double(height))
        }
        func mean(_ points: [SIMD2<Float>]) -> SIMD2<Double> {
            points.map(pixel).reduce(.zero, +) / Double(points.count)
        }
        let leftEye = mean(face.leftEye), rightEye = mean(face.rightEye)
        let origin = (leftEye + rightEye) * 0.5
        let delta = rightEye - leftEye, axisX = delta / hypot(delta.x, delta.y)
        let axisY = SIMD2(-axisX.y, axisX.x)
        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let d = p - origin
            return SIMD2(d.x * axisX.x + d.y * axisX.y, d.x * axisY.x + d.y * axisY.y)
        }
        func image(_ p: SIMD2<Double>) -> SIMD2<Double> { origin + axisX * p.x + axisY * p.y }
        var path = try XCTUnwrap(face.observedFaceSupport).contour.map { local(pixel($0)) }
        if path[0].x > path.last!.x { path.reverse() }
        let span = path.map(\.x).max()! - path.map(\.x).min()!, chin = path.map(\.y).max()!
        let first = path[0], last = path.last!
        path = ([SIMD2(first.x * 0.96, -chin * 0.32), SIMD2(first.x, -chin * 0.12)] + path +
            [SIMD2(last.x, -chin * 0.12), SIMD2(last.x * 0.96, -chin * 0.32)]).map(image)
        let segments = Array(zip(path, path.dropFirst()))
        let polygon = Array(zip(path, Array(path.dropFirst()) + [path[0]]))
        var allowed = [Bool](repeating: false, count: width * height)
        for y in 0..<height { for x in 0..<width {
            let q = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            var inside = false
            for (a, b) in polygon where (a.y > q.y) != (b.y > q.y) {
                if q.x < (b.x - a.x) * (q.y - a.y) / (b.y - a.y) + a.x { inside.toggle() }
            }
            let limit = pow(inside ? span * 0.20 : span * 0.06 + 2, 2)
            for (a, b) in segments {
                let d = b - a, length = d.x * d.x + d.y * d.y
                guard length > 0 else { continue }
                let t = max(0, min(1, ((q - a).x * d.x + (q - a).y * d.y) / length))
                let r = q - (a + d * t)
                if r.x * r.x + r.y * r.y <= limit { allowed[y * width + x] = true; break }
            }
        } }
        for sign: Float in [-1, 1] { for fraction: Float in [0.25, 0.5, 0.75, 1] {
            var strengths = BeautyEffectiveStrengths()
            strengths.templeFullness = BeautySafetyCaps.templeFullness * sign * fraction
            let map = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height,
                face: face, strengths: strengths))
            let output = map.applyRGBA(source)
            var outside = 0, changed = 0
            for p in allowed.indices {
                let i = p * 4
                if (0..<4).contains(where: { source[i + $0] != output[i + $0] }) {
                    changed += 1
                    if !allowed[p] { outside += 1 }
                }
            }
            XCTAssertEqual(outside, 0, "sign=\(sign) level=\(fraction)")
            XCTAssertGreaterThan(changed, 128)
            XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
        } }
    }

    func testLinearSourceDoesNotGainSamplingSeamsAtOriginalSilhouetteOrOuterBand() throws {
        let face = try anatomy()
        var source = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            source[i] = UInt8((Double(x) * 0.45).rounded())
            source[i + 1] = UInt8((Double(y) * 0.35).rounded())
            source[i + 2] = UInt8((Double(x + y) * 0.19).rounded())
        } }
        // With the frozen .45 field-gradient bound, these source slopes and
        // byte quantization permit at most a two-level adjacent RGB step.
        // A hard material-ownership cutoff leaves a larger sampling seam.
        for (key, cap) in fields { for sign: Float in (key == \.faceVShape ? [1] : [-1, 1]) {
            var strengths = BeautyEffectiveStrengths(); strengths[keyPath: key] = cap * sign
            let map = try XCTUnwrap(BeautyContinuousFaceMap(width: width, height: height,
                face: face, strengths: strengths))
            let output = map.applyRGBA(source)
            var maximumJump = 0, changed = 0
            for y in 0..<height { for x in 0..<width {
                let i = (y * width + x) * 4
                if (0..<3).contains(where: { source[i + $0] != output[i + $0] }) { changed += 1 }
                if x + 1 < width {
                    for c in 0..<3 { maximumJump = max(maximumJump, abs(Int(output[i + c]) - Int(output[i + 4 + c]))) }
                }
                if y + 1 < height {
                    for c in 0..<3 { maximumJump = max(maximumJump, abs(Int(output[i + c]) - Int(output[i + width * 4 + c]))) }
                }
            } }
            XCTAssertLessThanOrEqual(maximumJump, 2, "\(key) sign=\(sign)")
            XCTAssertGreaterThan(changed, 128, "continuous transition cannot pass by becoming neutral")
            XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
        } }
    }
}
