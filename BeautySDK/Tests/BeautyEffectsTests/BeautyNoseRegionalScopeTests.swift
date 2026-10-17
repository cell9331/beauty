import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Regional behavior is measured from independent synthetic source textures.
/// These feature locations belong to ContinuousNoseTestFixture's anatomy, not
/// to a captured portrait or to the displacement field's support functions.
final class BeautyNoseRegionalScopeTests: XCTestCase {
    private let width = 480
    private let height = 640

    private func motion(source: [UInt8], output: [UInt8],
                        at mark: SIMD2<Double>) -> SIMD2<Double> {
        let before = ContinuousNoseTestFixture.centroid(source, width: width,
            height: height, around: mark, radius: 12)
        let after = ContinuousNoseTestFixture.centroid(output, width: width,
            height: height, around: mark, radius: 12)
        return after - before
    }

    private func magnitude(_ value: SIMD2<Double>) -> Double {
        hypot(value.x, value.y)
    }

    func testRootAndBridgeHaveVisibleCoreMotionAtLowMiddleAndFullStrength() throws {
        let face = try ContinuousNoseTestFixture.face()
        typealias Field = (name: String, key: WritableKeyPath<BeautyEffectiveStrengths, Float>,
            cap: Float, marks: [SIMD2<Double>], minimumPerSide: [Double])
        let fields: [Field] = [
            ("root", \.noseRootNarrowing, BeautySafetyCaps.noseRootNarrowing,
             [SIMD2(0.46, 0.29), SIMD2(0.54, 0.29)], [0.60, 1.30, 3.00]),
            ("bridge", \.noseBridge, BeautySafetyCaps.noseBridge,
             [SIMD2(0.455, 0.49), SIMD2(0.545, 0.49)], [0.40, 0.85, 2.00])
        ]
        for field in fields {
            let source = ContinuousNoseTestFixture.raster(width: width, height: height,
                marks: field.marks)
            for sign: Float in [-1, 1] {
                var previousLeft = 0.0, previousRight = 0.0
                for (fraction, minimum) in zip([Float(0.25), 0.5, 1], field.minimumPerSide) {
                    var strengths = BeautyEffectiveStrengths()
                    strengths[keyPath: field.key] = sign * fraction * field.cap
                    let map = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                        height: height, face: face, strengths: strengths))
                    let output = map.applyRGBA(source)
                    let left = motion(source: source, output: output, at: field.marks[0]).x * Double(sign)
                    let right = -motion(source: source, output: output, at: field.marks[1]).x * Double(sign)
                    let context = "\(field.name), sign \(sign), fraction \(fraction)"
                    // These are visible source-feature motions, not limits on
                    // an inverse-map coefficient or a requested field offset.
                    // Both sides must pass so a stronger side cannot hide a
                    // visually inactive sibling in a mean-width statistic.
                    XCTAssertGreaterThan(left, minimum, context)
                    XCTAssertGreaterThan(right, minimum, context)
                    XCTAssertGreaterThan(left, previousLeft + 0.10, context)
                    XCTAssertGreaterThan(right, previousRight + 0.10, context)
                    previousLeft = left
                    previousRight = right
                }
            }
        }
    }

    func testRootHasVisibleSignedResponseAndLeavesLowerNoseQuiet() throws {
        let face = try ContinuousNoseTestFixture.face()
        // The anatomical root lies between the inner brow ends (lower edge
        // near y=.263) and the inner eye corners (near y=.32). Both markers
        // remain horizontally clear of the complete eye protection boxes.
        let core = [SIMD2(0.46, 0.29), SIMD2(0.54, 0.29)]
        let upperDorsum = [SIMD2(0.46, 0.385), SIMD2(0.54, 0.385)]
        let middle = [SIMD2(0.46, 0.45), SIMD2(0.54, 0.45)]
        let lower = [SIMD2(0.465, 0.585), SIMD2(0.535, 0.585),
                     SIMD2(0.41, 0.63), SIMD2(0.59, 0.63)]
        let source = ContinuousNoseTestFixture.raster(width: width, height: height,
            marks: core + upperDorsum + middle + lower)
        for sign: Float in [-1, 1] {
            var previous = 0.0
            for fraction: Float in [0.05, 0.25, 0.5, 0.75, 1] {
                var strengths = BeautyEffectiveStrengths()
                strengths.noseRootNarrowing = sign * fraction * BeautySafetyCaps.noseRootNarrowing
                let map = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                    height: height, face: face, strengths: strengths))
                let output = map.applyRGBA(source)
                let left = motion(source: source, output: output, at: core[0])
                let right = motion(source: source, output: output, at: core[1])
                let inward = (left.x - right.x) * Double(sign) * 0.5
                XCTAssertGreaterThan(inward, previous + 0.02,
                    "root width responds through the slider at sign \(sign), fraction \(fraction)")
                for (index, mark) in upperDorsum.enumerated() {
                    let transition = motion(source: source, output: output, at: mark)
                    XCTAssertLessThan(magnitude(transition), max(0.10, inward * 0.60),
                        "the root effect tapers as it reaches the upper dorsum")
                    let signedInward = transition.x * Double(sign) * (index == 0 ? 1 : -1)
                    XCTAssertGreaterThanOrEqual(signedInward, -0.05,
                        "the root's transition does not reverse the core's signed direction")
                }
                for mark in middle + lower {
                    XCTAssertLessThan(magnitude(motion(source: source, output: output, at: mark)), 0.20,
                        "root narrowing must not become a whole-nose width adjustment")
                }
                XCTAssertEqual(left.y, 0, accuracy: 0.10)
                XCTAssertEqual(right.y, 0, accuracy: 0.10)
                XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                if fraction == 1 {
                    XCTAssertGreaterThan(inward, 1.5,
                        "full root strength visibly changes each upper nasal side in this synthetic image")
                }
                previous = inward
            }
        }
    }

    func testBridgeFocusesOnDorsumWithLimitedLowerContinuationAndQuietOuterAlae() throws {
        let face = try ContinuousNoseTestFixture.face()
        let core = [SIMD2(0.455, 0.49), SIMD2(0.545, 0.49)]
        let root = [SIMD2(0.46, 0.29), SIMD2(0.54, 0.29)]
        let bulb = [SIMD2(0.465, 0.60), SIMD2(0.535, 0.60)]
        let alae = [SIMD2(0.40, 0.585), SIMD2(0.60, 0.585)]
        let source = ContinuousNoseTestFixture.raster(width: width, height: height,
            marks: core + root + bulb + alae)
        for sign: Float in [-1, 1] {
            var previous = 0.0
            for fraction: Float in [0.05, 0.25, 0.5, 0.75, 1] {
                var strengths = BeautyEffectiveStrengths()
                strengths.noseBridge = sign * fraction * BeautySafetyCaps.noseBridge
                let map = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                    height: height, face: face, strengths: strengths))
                let output = map.applyRGBA(source)
                let left = motion(source: source, output: output, at: core[0])
                let right = motion(source: source, output: output, at: core[1])
                let inward = (left.x - right.x) * Double(sign) * 0.5
                XCTAssertGreaterThan(inward, previous + 0.02,
                    "bridge width responds through the slider at sign \(sign), fraction \(fraction)")
                for mark in root + alae {
                    let outside = magnitude(motion(source: source, output: output, at: mark))
                    XCTAssertLessThan(outside, max(0.10, inward * 0.25),
                        "a bridge adjustment must be concentrated on the dorsum")
                }
                for (index, mark) in bulb.enumerated() {
                    let continuation = motion(source: source, output: output, at: mark)
                    XCTAssertLessThan(magnitude(continuation), max(0.10, inward * 0.60),
                        "the lower inner nose may follow, with less motion than the bridge core")
                    let signedInward = continuation.x * Double(sign) * (index == 0 ? 1 : -1)
                    XCTAssertGreaterThanOrEqual(signedInward, -0.05,
                        "the admitted lower continuation follows the bridge's signed width change")
                }
                XCTAssertEqual(left.y, 0, accuracy: 0.10)
                XCTAssertEqual(right.y, 0, accuracy: 0.10)
                XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                if fraction == 1 { XCTAssertGreaterThan(inward, 1.0) }
                previous = inward
            }
        }
    }

    func testRootFollowsRolledPixelAxesInPortraitAndLandscapeImages() throws {
        let marks = [SIMD2(0.46, 0.29), SIMD2(0.54, 0.29)]
        for (width, height, angle) in [(480, 640, 0.20), (640, 480, -0.20)] {
            let aspect = Double(width) / Double(height)
            // Fixture anatomy and source textures use the same aspect-aware
            // pixel rotation, so neither gains a normalized-coordinate skew.
            let face = try ContinuousNoseTestFixture.face(angle: angle, aspect: aspect)
            let source = ContinuousNoseTestFixture.raster(width: width, height: height,
                marks: marks, angle: angle)
            for sign: Float in [-1, 1] {
                var previous = 0.0
                for fraction: Float in [0.25, 1] {
                    var strengths = BeautyEffectiveStrengths()
                    strengths.noseRootNarrowing = sign * fraction * BeautySafetyCaps.noseRootNarrowing
                    let map = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                        height: height, face: face, strengths: strengths))
                    let output = map.applyRGBA(source)
                    var local = [SIMD2<Double>]()
                    for mark in marks {
                        let center = ContinuousNoseTestFixture.point(mark, angle: angle, aspect: aspect)
                        let before = ContinuousNoseTestFixture.centroid(source, width: width,
                            height: height, around: center, radius: 12)
                        let after = ContinuousNoseTestFixture.centroid(output, width: width,
                            height: height, around: center, radius: 12)
                        let delta = after - before
                        local.append(SIMD2(delta.x * cos(angle) + delta.y * sin(angle),
                            -delta.x * sin(angle) + delta.y * cos(angle)))
                    }
                    let leftInward = local[0].x * Double(sign)
                    let rightInward = -local[1].x * Double(sign)
                    let inward = (leftInward + rightInward) * 0.5
                    let context = "\(width)x\(height), roll \(angle), sign \(sign), fraction \(fraction)"
                    XCTAssertGreaterThan(leftInward, 0.10, context)
                    XCTAssertGreaterThan(rightInward, 0.10, context)
                    XCTAssertGreaterThan(inward, previous + 0.10, context)
                    XCTAssertEqual(local[0].y, 0, accuracy: 0.20, context)
                    XCTAssertEqual(local[1].y, 0, accuracy: 0.20, context)
                    XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                    if fraction == 1 { XCTAssertGreaterThan(inward, 1.0, context) }
                    previous = inward
                }
            }
        }
    }

    func testSizeTapersAcrossAdjacentSkinAndPreservesBothOuterTexturePatches() throws {
        let face = try ContinuousNoseTestFixture.face()
        let nose = [SIMD2(0.415, 0.60), SIMD2(0.585, 0.60)]
        // Adjacent skin is permitted to follow as the field returns to zero;
        // the farther cheek texture has no part in a nasal size control.
        let adjacent = [SIMD2(0.365, 0.53), SIMD2(0.635, 0.53)]
        let outer = [SIMD2(0.30, 0.53), SIMD2(0.70, 0.53)]
        let source = ContinuousNoseTestFixture.raster(width: width, height: height,
            marks: nose + adjacent + outer)
        for sign: Float in [-1, 1] {
            var previous = 0.0
            for fraction: Float in [0.05, 0.25, 0.5, 0.75, 1] {
                var strengths = BeautyEffectiveStrengths()
                strengths.noseSlim = sign * fraction * BeautySafetyCaps.noseSlim
                let map = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                    height: height, face: face, strengths: strengths))
                let output = map.applyRGBA(source)
                let left = motion(source: source, output: output, at: nose[0])
                let right = motion(source: source, output: output, at: nose[1])
                let inward = (left.x - right.x) * Double(sign) * 0.5
                XCTAssertGreaterThan(inward, previous + 0.02)
                for mark in adjacent {
                    XCTAssertLessThan(magnitude(motion(source: source, output: output, at: mark)),
                        max(0.10, inward * 0.65),
                        "the skin transition must remain weaker than the nose")
                }
                for mark in outer {
                    assertExactPatch(source: source, output: output, center: mark,
                        radius: 7, message: "nasal size must preserve distant cheek texture")
                }
                XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                if fraction == 1 { XCTAssertGreaterThan(inward, 1.5) }
                previous = inward
            }
        }
    }

    func testRegionalControlsRetainProtectionAlphaAndCombinedSafetyBudget() throws {
        let face = try ContinuousNoseTestFixture.face()
        let source = ContinuousNoseTestFixture.raster(width: width, height: height,
            marks: [SIMD2(0.46, 0.29), SIMD2(0.455, 0.49), SIMD2(0.415, 0.60)])
        let dense = try XCTUnwrap(face.denseSupport)
        let protectedPaths = [MediaPipeFaceTopology.leftEye, MediaPipeFaceTopology.rightEye,
            MediaPipeFaceTopology.leftBrowEnvelope, MediaPipeFaceTopology.rightBrowEnvelope,
            MediaPipeFaceTopology.outerLip].map { BeautyDenseFaceSupport.path(dense.mesh, $0) }
        let boxes = protectedPaths.map { path in
            (Int(ceil(Double(path.map(\.x).min()!) * Double(width))),
             Int(floor(Double(path.map(\.x).max()!) * Double(width))),
             Int(ceil(Double(path.map(\.y).min()!) * Double(height))),
             Int(floor(Double(path.map(\.y).max()!) * Double(height))))
        }
        for sign: Float in [-1, 1] {
            var strengths = BeautyEffectiveStrengths()
            strengths.noseSlim = sign * BeautySafetyCaps.noseSlim
            strengths.noseBridge = sign * BeautySafetyCaps.noseBridge
            strengths.noseRootNarrowing = sign * BeautySafetyCaps.noseRootNarrowing
            let map = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                height: height, face: face, strengths: strengths))
            let output = map.applyRGBA(source)
            XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
            let faceSpan = min(Double(face.bounds.width) * Double(width),
                Double(face.bounds.height) * Double(height))
            XCTAssertLessThanOrEqual(map.maximumDisplacement, faceSpan * 0.060001)
            XCTAssertTrue(stride(from: 3, to: output.count, by: 4).allSatisfy { output[$0] == source[$0] })
            var protectedDifferences = 0
            for (minX, maxX, minY, maxY) in boxes {
                for y in minY...maxY { for x in minX...maxX {
                    let index = (y * width + x) * 4
                    for channel in 0..<4 where output[index + channel] != source[index + channel] {
                        protectedDifferences += 1
                    }
                } }
            }
            XCTAssertEqual(protectedDifferences, 0, "eyes, brows and full lips retain their source pixels")
            for key in [\BeautyEffectiveStrengths.noseSlim, \.noseBridge, \.noseRootNarrowing] {
                var nearZero = BeautyEffectiveStrengths()
                nearZero[keyPath: key] = sign * 0.00001
                let small = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                    height: height, face: face, strengths: nearZero))
                XCTAssertLessThan(small.maximumDisplacement, 0.01,
                    "the new regional envelopes do not introduce a jump at zero")
            }
        }
    }

    func testInvalidRootAnchorRejectsOnlyRootAndPreservesValidSizeOutput() throws {
        let observation = try ContinuousNoseTestFixture.observation()
        var points = try XCTUnwrap(observation.mesh).points
        // Keep each brow's valid open trace and protection envelope, but move
        // the complete pair below the inner canthi. This makes the anatomical
        // root anchor inconsistent without corrupting shared nasal evidence.
        for index in MediaPipeFaceTopology.leftBrowEnvelope + MediaPipeFaceTopology.rightBrowEnvelope {
            points[index].y += 0.14
        }
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points))
        let malformedRoot = try XCTUnwrap(MediaPipeFaceTopology.observation(from: mesh))
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: malformedRoot)
        XCTAssertTrue(BeautyContinuousNoseMap.isEligible(face: face),
            "a root-specific ordering problem must not invalidate shared nose eligibility")
        let source = ContinuousNoseTestFixture.raster(width: width, height: height,
            marks: [SIMD2(0.415, 0.60), SIMD2(0.585, 0.60)])
        for sign: Float in [-1, 1] {
            var root = BeautyEffectiveStrengths()
            root.noseRootNarrowing = sign * BeautySafetyCaps.noseRootNarrowing
            XCTAssertNil(BeautyContinuousNoseMap(width: width,
                height: height, face: face, strengths: root),
                "an invalid root anchor must abstain for either requested direction")

            var size = BeautyEffectiveStrengths()
            size.noseSlim = sign * BeautySafetyCaps.noseSlim
            let sizeMap = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                height: height, face: face, strengths: size))
            let expected = sizeMap.applyRGBA(source)
            XCTAssertNotEqual(expected, source, "valid sibling geometry must remain active")
            var combined = size
            combined.noseRootNarrowing = root.noseRootNarrowing
            let combinedMap = try XCTUnwrap(BeautyContinuousNoseMap(width: width,
                height: height, face: face, strengths: combined))
            XCTAssertEqual(combinedMap.applyRGBA(source), expected,
                "a rejected root control must neither move pixels nor rescale valid size geometry")
        }
    }

    private func assertExactPatch(source: [UInt8], output: [UInt8], center: SIMD2<Double>,
                                  radius: Int, message: String,
                                  file: StaticString = #filePath, line: UInt = #line) {
        let cx = Int(center.x * Double(width)), cy = Int(center.y * Double(height))
        var differences = 0
        for y in (cy - radius)...(cy + radius) { for x in (cx - radius)...(cx + radius) {
            let index = (y * width + x) * 4
            for channel in 0..<4 where source[index + channel] != output[index + channel] {
                differences += 1
            }
        } }
        XCTAssertEqual(differences, 0, message, file: file, line: line)
    }
}
