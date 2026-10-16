import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class BeautyContinuousEyebrowMapTests: XCTestCase {
    private let width = 320, height = 400
    private let bounds = FaceBounds(x: 0.1, y: 0.1, width: 0.8, height: 0.8)

    private func trace(_ side: BeautyObservedEyebrowSide, flat: Bool = false) throws -> BeautyEyebrowSemanticTrace {
        let xs: [Float] = side == .left ? [0.44, 0.39, 0.34, 0.28, 0.23] : [0.56, 0.61, 0.66, 0.72, 0.77]
        let ys: [Float] = flat ? [0.32, 0.32, 0.32, 0.32, 0.32] : [0.32, 0.304, 0.285, 0.296, 0.32]
        return try XCTUnwrap(BeautyFaceGeometryAdapter.validatedBrowTrace(zip(xs, ys).map {
            CoordinatePoint(x: Double($0.0), y: Double($0.1))
        }, side: side, bounds: bounds))
    }

    private func face(left: BeautyEyebrowSemanticTrace? = nil, right: BeautyEyebrowSemanticTrace? = nil,
                      freshness: LandmarkGeometryFreshness = .fresh, flat: Bool = false) throws -> FaceGeometry {
        func path(_ points: [(Float, Float)]) -> [SIMD2<Float>] { points.map { SIMD2($0.0, $0.1) } }
        return FaceGeometry(bounds: bounds, faceContour: [],
            leftEye: path([(0.24,0.41),(0.32,0.40),(0.42,0.41),(0.42,0.45),(0.32,0.46),(0.24,0.45)]),
            rightEye: path([(0.58,0.41),(0.68,0.40),(0.76,0.41),(0.76,0.45),(0.68,0.46),(0.58,0.45)]),
            nose: path([(0.48,0.43),(0.52,0.43),(0.55,0.60),(0.45,0.60)]),
            outerLips: path([(0.42,0.69),(0.5,0.67),(0.58,0.69),(0.58,0.73),(0.5,0.75),(0.42,0.73)]),
            freshness: freshness,
            observedEyebrowSupport: BeautyEyebrowSemanticSupport(
                left: try left ?? trace(.left, flat: flat), right: try right ?? trace(.right, flat: flat)))
    }

    private func source(face: FaceGeometry, alphaStripe: Bool = false, halfThickness: Double = 3.5) -> [UInt8] {
        var pixels = [UInt8](repeating: 255, count: width * height * 4)
        let traces = [face.observedEyebrowSupport?.left, face.observedEyebrowSupport?.right].compactMap { $0 }
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4, p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            var distance = Double.infinity
            for trace in traces {
                let line = trace.points.map { SIMD2(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
                for j in 1..<line.count {
                    let a = line[j - 1], b = line[j], v = b - a, q = p - a
                    let t = min(1, max(0, (q.x * v.x + q.y * v.y) / (v.x * v.x + v.y * v.y)))
                    let d = q - v * t; distance = min(distance, hypot(d.x, d.y))
                }
            }
            let hair = distance <= halfThickness
            pixels[i] = hair ? 35 : UInt8(185 + (x * 3 + y) % 35)
            pixels[i + 1] = hair ? 30 : UInt8(145 + (x + y * 3) % 35)
            pixels[i + 2] = hair ? 25 : UInt8(125 + (x * 2 + y * 2) % 35)
            if alphaStripe { pixels[i + 3] = x % 2 == 0 ? 120 : 255 }
        } }
        return pixels
    }

    private func strengths(_ index: Int, _ value: Float) -> BeautyEffectiveStrengths {
        var s = BeautyEffectiveStrengths()
        s[keyPath: BeautyContinuousEyebrowMap.keys[index]] = BeautyContinuousEyebrowMap.caps[index] * value
        return s
    }

    /// Complete source-skin luma deficit, including antialiased fringe. The
    /// independent latent skin pattern belongs to this generated source;
    /// strong-core R<100 truncation cannot erase the warp's new soft edge.
    private func darknessMass(_ pixels: [UInt8], left: Bool) -> Double {
        var sum=0.0
        let xs=left ? 0..<(width/2) : (width/2)..<width
        for y in Int(0.22*Double(height))..<Int(0.39*Double(height)) { for x in xs {
            let i=(y*width+x)*4
            let skin=0.299*Double(185+(x*3+y)%35)+0.587*Double(145+(x+y*3)%35)+0.114*Double(125+(x*2+y*2)%35)
            let color=0.299*Double(pixels[i])+0.587*Double(pixels[i+1])+0.114*Double(pixels[i+2])
            sum += max(0,skin-color)
        } }
        return sum
    }

    private func metric(_ pixels: [UInt8], side: Bool, band: ClosedRange<Double> = -0.25...1.25) -> (center: SIMD2<Double>, mass: Double, tail: Double) {
        let originX = (side ? 0.44 : 0.56) * Double(width)
        let direction = side ? -1.0 : 1.0, length = 0.21 * Double(width)
        var sum = SIMD2<Double>.zero, mass = 0.0, tail = -Double.infinity
        for y in Int(Double(height) * 0.22)..<Int(Double(height) * 0.39) {
            for x in 0..<width {
                let px = Double(x) + 0.5, u = (px - originX) * direction / length
                guard band.contains(u) else { continue }
                let weight = Double(max(0, 100 - Int(pixels[(y * width + x) * 4])))
                if weight > 20 { tail = max(tail, u * length) }
                mass += weight; sum += SIMD2(px, Double(y) + 0.5) * weight
            }
        }
        return (mass > 0 ? sum / mass : SIMD2(.nan, .nan), mass, tail)
    }

    func testAllSevenSignedFieldsMoveActualBrowRasterInTheirOwnDirection() throws {
        let face = try face(), source = source(face: face)
        let originalMass=darknessMass(source,left:true)
        let thinnerMass=darknessMass(self.source(face:face,halfThickness:2.8),left:true)
        let thickerMass=darknessMass(self.source(face:face,halfThickness:4.2),left:true)
        XCTAssertGreaterThan(originalMass-thinnerMass,originalMass*0.08,"independent thinner source control")
        XCTAssertGreaterThan(thickerMass-originalMass,originalMass*0.08,"independent thicker source control")
        for sign: Float in [-1, 1] {
            for index in 0..<7 {
                let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                    face: face, strengths: strengths(index, sign), sourceRGBA: source))
                var appliedCounts = [Int]()
                let result = map.applyRGBA(source, onAppliedSideCount: { appliedCounts.append($0) })
                XCTAssertEqual(appliedCounts, [2], "both admitted sides actually retain source ownership")
                XCTAssertNotEqual(source, result, "field \(index) sign \(sign)")
                XCTAssertLessThanOrEqual(map.maximumInverseContraction, BeautyContinuousEyebrowMap.gradientBudget + 1e-9)
                if ![3,4].contains(index) {
                    XCTAssertLessThanOrEqual(map.maximumGradient,BeautyContinuousEyebrowMap.gradientBudget+1e-9)
                }
                XCTAssertLessThanOrEqual(map.maximumDisplacement, 0.21 * Double(width) * 0.150001)
                XCTAssertEqual(result, map.applyRGBA(source))
                let before = metric(source, side: true, band: -0.10...1.18)
                let after = metric(result, side: true, band: -0.10...1.18)
                switch index {
                case 0: XCTAssertGreaterThan((after.center.y - before.center.y) * Double(sign), 0.5)
                case 1:
                    XCTAssertGreaterThan((darknessMass(result,left:true)-originalMass)*Double(sign),originalMass*0.08,
                        "thickness complete source luma deficit sign \(sign)")
                case 2: XCTAssertGreaterThan((after.tail - before.tail) * Double(sign), 0.5)
                case 3:
                    let oldGap = metric(source, side: false).center.x - metric(source, side: true).center.x
                    let gap = metric(result, side: false).center.x - metric(result, side: true).center.x
                    XCTAssertGreaterThan((gap - oldGap) * Double(sign), 0.5)
                case 4:
                    let oldHead = metric(source, side: true, band: -0.10...0.35).center.x
                    let head = metric(result, side: true, band: -0.10...0.35).center.x
                    XCTAssertGreaterThan((oldHead - head) * Double(sign), 0.15)
                case 5:
                    let oldTilt = metric(source, side: true, band: 0.65...1.10).center.y - metric(source, side: true, band: -0.1...0.35).center.y
                    let tilt = metric(result, side: true, band: 0.65...1.10).center.y - metric(result, side: true, band: -0.1...0.35).center.y
                    XCTAssertGreaterThan((oldTilt - tilt) * Double(sign), 0.3)
                case 6:
                    let oldPeak = metric(source, side: true, band: 0.35...0.65).center.y
                    let peak = metric(result, side: true, band: 0.35...0.65).center.y
                    XCTAssertGreaterThan((oldPeak - peak) * Double(sign), 0.4)
                default: break
                }
            }
        }
    }

    func testSignedSingleControlsKeepRespondingAtEveryQuarterStep() throws {
        let face = try face(flat: true), original = source(face: face)
        let frame = try XCTUnwrap(BeautyEyebrowSourceGeometry.frame(face: face, width: width, height: height))
        let traces = try [XCTUnwrap(face.observedEyebrowSupport?.left),
                          XCTUnwrap(face.observedEyebrowSupport?.right)]
        let levels: [Float] = [0.25, 0.50, 0.75, 1]
        // Source-defined core positions: thickness must be off the ridge;
        // length must be past its anchor; head spacing must be before its zero.
        let locations = [0.45, 0.45, 0.85, 0.15, 0.12, 0.0, 0.65]
        let minimumFullMotion = [0.25, 0.02, 0.25, 0.20, 0.20, 0.0, 0.10]
        func dot(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double { a.x*b.x+a.y*b.y }
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> {
            SIMD2(Double(p.x)*Double(width)-0.5, Double(p.y)*Double(height)-0.5)
        }
        let neutral = BeautyContinuousEyebrowMap(width: width, height: height, face: face,
            strengths: BeautyEffectiveStrengths(), sourceRGBA: original)
        XCTAssertNil(neutral)
        XCTAssertEqual(neutral?.applyRGBA(original) ?? original, original, "neutral preserves every source byte")

        for index in [0, 1, 2, 3, 4, 6] { for sign: Float in [-1, 1] {
            let maps = try levels.map { level in
                try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                    face: face, strengths: strengths(index, sign*level), sourceRGBA: original),
                    "field \(index), sign \(sign), level \(level) must remain admitted")
            }
            for trace in traces {
                let outward = frame.horizontal * (trace.side == .left ? -1.0 : 1.0)
                let head = pixel(trace.innerEndpoint), tail = pixel(trace.outerEndpoint)
                let length = dot(tail-head, outward)
                let point = head + outward*(length*locations[index]) + frame.vertical*(index == 1 ? 2.0 : 0.0)
                let displacements = maps.map { $0.displacement(at: point) }
                let full = try XCTUnwrap(displacements.last), magnitude = hypot(full.x, full.y)
                let axis = [2, 3, 4].contains(index) ? outward : frame.vertical
                let expectedSign = Double(sign) * (index == 6 ? -1.0 : 1.0)
                let label = "field \(index), sign \(sign), side \(trace.side)"
                XCTAssertGreaterThan(dot(full,axis)*expectedSign, minimumFullMotion[index],
                    "\(label): the chosen source core point is a positive motion control")
                XCTAssertEqual(dot(full, SIMD2(-axis.y,axis.x)), 0, accuracy: 1e-9,
                    "\(label): the single control retains its horizontal or vertical direction")
                var previous = SIMD2<Double>.zero
                for (level, displacement) in zip(levels,displacements) {
                    let expected = full * Double(level)
                    XCTAssertEqual(displacement.x, expected.x, accuracy: 1e-8, "\(label), level \(level)")
                    XCTAssertEqual(displacement.y, expected.y, accuracy: 1e-8, "\(label), level \(level)")
                    if magnitude > 0 {
                        XCTAssertGreaterThan(dot(displacement-previous,full)/magnitude, magnitude*0.20,
                            "\(label): every quarter step must add motion, including 75% to full")
                    }
                    previous = displacement
                }
            }
        } }
    }

    func testSignedTiltQuarterStepsScaleRigidAngleThroughTheFullSliderRange() throws {
        let face = try face(flat: true), original = source(face: face)
        let frame = try XCTUnwrap(BeautyEyebrowSourceGeometry.frame(face: face, width: width, height: height))
        let traces = try [XCTUnwrap(face.observedEyebrowSupport?.left),
                          XCTUnwrap(face.observedEyebrowSupport?.right)]
        let levels: [Float] = [0.25, 0.50, 0.75, 1]
        func dot(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double { a.x*b.x+a.y*b.y }
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> {
            SIMD2(Double(p.x)*Double(width)-0.5, Double(p.y)*Double(height)-0.5)
        }
        for sign: Float in [-1, 1] {
            let maps = try levels.map { level in
                try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                    face: face, strengths: strengths(5, sign*level), sourceRGBA: original))
            }
            for trace in traces {
                let outward = frame.horizontal * (trace.side == .left ? -1.0 : 1.0)
                let head = pixel(trace.innerEndpoint), tail = pixel(trace.outerEndpoint)
                let length = dot(tail-head, outward)
                // Both points lie inside the flat source core, away from the
                // end tapers. A rigid rotation preserves this segment's length.
                let a = head + outward*(length*0.15), b = head + outward*(length*0.85)
                let sourceVector = b-a, sourceLength = hypot(sourceVector.x, sourceVector.y)
                let angles = maps.map { map -> Double in
                    let targetVector = (b+map.displacement(at:b))-(a+map.displacement(at:a))
                    XCTAssertEqual(hypot(targetVector.x,targetVector.y), sourceLength, accuracy: 1e-8,
                        "a single tilt must remain rigid on the source core at every level")
                    let cross = sourceVector.x*targetVector.y-sourceVector.y*targetVector.x
                    return atan2(cross,dot(sourceVector,targetVector))
                }
                let full = try XCTUnwrap(angles.last)
                let orientation = trace.side == .left ? 1.0 : -1.0
                XCTAssertGreaterThan(full*Double(sign)*orientation, 0.002,
                    "the independent segment oracle must observe actual tilt in the requested direction")
                var previous = 0.0
                for (level,angle) in zip(levels,angles) {
                    XCTAssertEqual(angle,full*Double(level),accuracy:1e-9,
                        "finite rotation angle must follow the slider; displacement itself need not be linear")
                    XCTAssertGreaterThan(abs(angle-previous),abs(full)*0.20,
                        "every tilt quarter step must add angle, including 75% to full")
                    previous = angle
                }
            }
        }
    }

    func testEveryExteriorFeatureAndAlphaByteIsExactForAllFieldsAndMixedSigns() throws {
        let face = try face(), opaque = source(face: face), transparent = source(face: face, alphaStripe: true)
        var cases = (0..<7).flatMap { i in [strengths(i, -1), strengths(i, 1)] }
        var combination = BeautyEffectiveStrengths()
        for i in 0..<7 { combination[keyPath: BeautyContinuousEyebrowMap.keys[i]] = BeautyContinuousEyebrowMap.caps[i] * (i % 2 == 0 ? 1 : -1) }
        cases.append(combination)
        let paths = [face.leftEye, face.rightEye, face.nose, face.outerLips]
        for s in cases {
            let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height, face: face, strengths: s, sourceRGBA: opaque))
            let source = opaque, output = map.applyRGBA(opaque)
            XCTAssertNotEqual(output, source)
            XCTAssertEqual(map.applyRGBA(transparent), transparent)
            var alphaDelta = 0, protectedDelta = 0
            for y in 0..<height { for x in 0..<width {
                let i = (y * width + x) * 4, p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                alphaDelta += abs(Int(output[i + 3]) - Int(source[i + 3]))
                let protected = paths.contains { path in
                    p.x >= Double(path.map(\.x).min()!) * Double(width) - 2 &&
                    p.x <= Double(path.map(\.x).max()!) * Double(width) + 2 &&
                    p.y >= Double(path.map(\.y).min()!) * Double(height) - 2 &&
                    p.y <= Double(path.map(\.y).max()!) * Double(height) + 2
                }
                // The generated photograph above uses edge-origin centres;
                // the displacement API follows the new integer-centre contract.
                if !map.operationContains(p - SIMD2(0.5, 0.5)) || protected {
                    for c in 0..<4 { protectedDelta += abs(Int(output[i + c]) - Int(source[i + c])) }
                }
            } }
            XCTAssertEqual(alphaDelta, 0); XCTAssertEqual(protectedDelta, 0)
            XCTAssertLessThanOrEqual(map.maximumInverseContraction, BeautyContinuousEyebrowMap.gradientBudget + 1e-9)
            if s.eyebrowSpacing == 0 && s.eyebrowHeadSpacing == 0 {
                XCTAssertLessThanOrEqual(map.maximumGradient,BeautyContinuousEyebrowMap.gradientBudget+1e-9)
            }
        }
    }

    func testIndependentCapAdmissionIsContinuousThroughSiblingZeroAndAcrossSign() throws {
        let face = try face(), original = source(face: face)
        let baseline = try XCTUnwrap(BeautyContinuousEyebrowMap(
            width: width, height: height, face: face, strengths: strengths(0, 0.5), sourceRGBA: original))
        let p = SIMD2(0.34 * Double(width), 0.285 * Double(height))
        for index in 1..<7 { for sign: Float in [-1, 1] {
            var s = strengths(0, 0.5)
            s[keyPath: BeautyContinuousEyebrowMap.keys[index]] = BeautyContinuousEyebrowMap.caps[index] * sign * 0.00001
            let sibling = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height, face: face, strengths: s, sourceRGBA: original))
            XCTAssertLessThan(hypot((sibling.displacement(at: p) - baseline.displacement(at: p)).x,
                (sibling.displacement(at: p) - baseline.displacement(at: p)).y), 0.001)
        } }
        for index in 0..<7 {
            let negative = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height, face: face, strengths: strengths(index, -0.00001), sourceRGBA: original))
            let positive = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height, face: face, strengths: strengths(index, 0.00001), sourceRGBA: original))
            XCTAssertLessThan(negative.maximumDisplacement + positive.maximumDisplacement, 0.001)
        }
    }

    func testContinuousSupportMovesNeighboringSkinWithoutHairCoverageBlending() throws {
        let face = try face(flat: true), original = source(face: face)
        let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
            face: face, strengths: strengths(0, 1), sourceRGBA: original))
        let output = map.applyRGBA(original)
        var movedSkin = 0
        // This source-defined window is entirely above the flat hair tube.
        // A mask that only transports dark hair leaves these skin pixels still.
        for y in 105..<119 { for x in 100..<120 {
            let i = (y * width + x) * 4
            XCTAssertGreaterThan(original[i], 100)
            if output[i] != original[i] || output[i+1] != original[i+1] || output[i+2] != original[i+2] {
                movedSkin += 1
            }
            XCTAssertEqual(output[i+3], original[i+3])
        } }
        XCTAssertGreaterThan(movedSkin, 100)
    }

    func testInvalidSideFailsLocallyWithoutBorrowingPeerAndSpacingRequiresPair() throws {
        let valid = try trace(.left), point = SIMD2<Float>(0.7, 0.3)
        let invalid = BeautyEyebrowSemanticTrace(side: .right, points: [point, point, point, point],
            innerEndpoint: point, outerEndpoint: point, center: point, apexIndex: nil)
        let face = try face(left: valid, right: invalid)
        XCTAssertTrue(BeautyContinuousEyebrowMap.replacesLegacy(for: face))
        let source = source(face: face)
        let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
            face: face, strengths: strengths(0, 1), sourceRGBA: source))
        let result = map.applyRGBA(source)
        XCTAssertNotEqual(result, source)
        var peerDelta = 0
        for y in 0..<height { for x in (width / 2)..<width {
            let i = (y * width + x) * 4
            for c in 0..<4 { peerDelta += abs(Int(result[i + c]) - Int(source[i + c])) }
        } }
        XCTAssertEqual(peerDelta, 0)
        XCTAssertNil(BeautyContinuousEyebrowMap(width: width, height: height, face: face, strengths: strengths(3, 1), sourceRGBA: source))
        let flat = try self.face(flat: true)
        let flatSource = self.source(face: flat)
        let peak = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
            face: flat, strengths: strengths(6, 1), sourceRGBA: flatSource))
        XCTAssertNotEqual(peak.applyRGBA(flatSource), flatSource,
                          "a calibrated displacement peak does not require a source anatomical apex")
    }

    func testWholeSpacingIsAtomicAfterOneSideLosesSourceOwnership() throws {
        let face=try face(),original=source(face:face)
        let spacing=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:strengths(3,1),sourceRGBA:original))
        XCTAssertEqual(spacing.admittedBrowCount,2)
        var changed=original
        let point=(Int(0.285*Double(height))*width+Int(0.66*Double(width)))*4
        XCTAssertLessThan(changed[point],100,"source control lies in the actual right eyebrow")
        changed[point] += 20
        var spacingCounts = [Int]()
        XCTAssertEqual(spacing.applyRGBA(changed,onAppliedSideCount:{ spacingCounts.append($0) }),changed,
                       "one refused side cancels whole spacing")
        XCTAssertEqual(spacingCounts,[0],"planned sides are not actual applied sides after pair refusal")

        let headStrength=strengths(4,0.6)
        let head=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:headStrength,sourceRGBA:original))
        var combination=headStrength;combination.eyebrowSpacing=BeautyContinuousEyebrowMap.caps[3]
        let mixed=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:combination,sourceRGBA:original))
        var headCounts = [Int](), mixedCounts = [Int]()
        let expected=head.applyRGBA(changed,onAppliedSideCount:{ headCounts.append($0) })
        let actual=mixed.applyRGBA(changed,onAppliedSideCount:{ mixedCounts.append($0) })
        XCTAssertEqual(actual,expected,"independent fields survive the pair refusal")
        XCTAssertEqual(headCounts,[1],"the side whose source changed must not be counted")
        XCTAssertEqual(mixedCounts,[1],"only the safe independent side survives pair refusal")
        var leftChanged=false
        for y in 0..<height { for x in 0..<(width/2) {
            let i=(y*width+x)*4
            if actual[i] != changed[i] { leftChanged=true }
        } }
        XCTAssertTrue(leftChanged,"the safe eyebrow retains its head-spacing effect")
    }

    func testWholeSpacingIsRemovedAfterOneSideFailsTargetAlphaAdmission() throws {
        let face=try face(),original=source(face:face),headStrength=strengths(4,-0.8)
        let head=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:headStrength,sourceRGBA:original))
        var combination=headStrength;combination.eyebrowSpacing = -BeautyContinuousEyebrowMap.caps[3]
        let control=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:combination,sourceRGBA:original))
        let transported=control.applyRGBA(original), independent=head.applyRGBA(original)
        XCTAssertNotEqual(transported,original,"the combined request has an actual positive control")
        XCTAssertNotEqual(independent,original,"the independent head field has an actual positive control")
        let right=try XCTUnwrap(face.observedEyebrowSupport?.right)
        let tailX=Double(right.outerEndpoint.x)*Double(width)-0.5
        let browLength=Double(right.outerEndpoint.x-right.innerEndpoint.x)*Double(width)
        var candidate:Int?
        // At the head these fields share the same support, so an independent
        // head field is not a valid stationary control there. Instead choose
        // bare skin beyond the tail: spacing still has a finite transition,
        // head spacing is already zero, and RGB source measurements at r<=L
        // do not read this remote destination's alpha.
        search: for y in Int(0.22*Double(height))..<Int(0.39*Double(height)) {
            for x in Int(ceil(tailX+5))..<Int(floor(tailX+0.18*browLength)) {
                let i=(y*width+x)*4,p=SIMD2(Double(x),Double(y))
                let spacingChangesPixel=(0..<3).contains { transported[i+$0] != original[i+$0] }
                let headPreservesPixel=(0..<4).allSatisfy { independent[i+$0] == original[i+$0] }
                if original[i] >= 100,spacingChangesPixel,headPreservesPixel,!head.operationContains(p) {
                    candidate=i;break search
                }
            }
        }
        let i=try XCTUnwrap(candidate,"positive control exposes tail-side spacing motion outside the independent head field")
        var translucent=original;translucent[i+3]=254
        var admissions=[String]()
        let actualMap=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:combination,sourceRGBA:translucent,onAdmission:{ admissions.append($0) }))
        XCTAssertTrue(admissions.contains("eyebrow_left_source_geometry_admitted"))
        XCTAssertTrue(admissions.contains("eyebrow_right_source_geometry_admitted"))
        XCTAssertTrue(admissions.contains("eyebrow_right_sampling_rejected"),"failure occurs after both source geometries were admitted")
        XCTAssertTrue(admissions.contains("eyebrow_spacing_pair_rejected"))
        let expectedMap=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:headStrength,sourceRGBA:translucent))
        var expectedCounts=[Int](),actualCounts=[Int]()
        let expected=expectedMap.applyRGBA(translucent,onAppliedSideCount:{ expectedCounts.append($0) })
        let actual=actualMap.applyRGBA(translucent,onAppliedSideCount:{ actualCounts.append($0) })
        XCTAssertEqual(actual,expected)
        XCTAssertNotEqual(actual,translucent,"safe independent head fields remain active")
        XCTAssertEqual(expectedCounts,[2],"the remote alpha marker cannot reject either independent head field")
        XCTAssertEqual(actualCounts,[2],"after pair cancellation both independent siblings actually apply")
        XCTAssertEqual(actual[i+3],254)
    }

    func testWholeSpacingAndPeakFallBackToSafePeakAfterEitherSideLosesOwnership() throws {
        let face=try face(),original=source(face:face)
        let peakStrength=strengths(6,0.8)
        let peak=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:peakStrength,sourceRGBA:original))
        var combined=peakStrength
        combined.eyebrowSpacing=BeautyContinuousEyebrowMap.caps[3]*0.8
        let map=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:combined,sourceRGBA:original))
        var initialCounts=[Int]()
        let initial=map.applyRGBA(original,onAppliedSideCount:{ initialCounts.append($0) })
        XCTAssertEqual(initialCounts,[2])
        XCTAssertNotEqual(initial,original,"the original pair is an actual positive control")
        XCTAssertLessThanOrEqual(map.maximumInverseContraction,BeautyContinuousEyebrowMap.gradientBudget+1e-9)
        for refusedSide in [BeautyObservedEyebrowSide.left,.right] {
            let trace=try XCTUnwrap(refusedSide == .left
                ? face.observedEyebrowSupport?.left : face.observedEyebrowSupport?.right)
            let point=trace.points[2]
            let x=Int((Double(point.x)*Double(width)-0.5).rounded())
            let y=Int((Double(point.y)*Double(height)-0.5).rounded())
            let offset=(y*width+x)*4
            XCTAssertLessThan(original[offset],100,"the refusal marker belongs to this source hair core")
            var changed=original
            changed[offset] += 20
            var peakCounts=[Int](),mixedCounts=[Int]()
            let expected=peak.applyRGBA(changed,onAppliedSideCount:{ peakCounts.append($0) })
            let actual=map.applyRGBA(changed,onAppliedSideCount:{ mixedCounts.append($0) })
            XCTAssertEqual(peakCounts,[1],"\(refusedSide): the modified side loses peak source ownership")
            XCTAssertEqual(mixedCounts,[1],"\(refusedSide): whole spacing cancels and only the safe peak remains")
            XCTAssertEqual(actual,expected,"\(refusedSide): the applied result equals the independently built peak-only fallback")
            var safeChanged=0,refusedChanged=0
            for yy in 0..<height { for xx in 0..<width {
                let i=(yy*width+xx)*4
                guard (0..<4).contains(where:{ actual[i+$0] != changed[i+$0] }) else { continue }
                let onRefusedSide=refusedSide == .left ? xx < width/2 : xx >= width/2
                if onRefusedSide { refusedChanged += 1 } else { safeChanged += 1 }
            } }
            XCTAssertEqual(refusedChanged,0,"\(refusedSide): no spacing or peak may write the refused side")
            XCTAssertGreaterThan(safeChanged,0,"\(refusedSide): the safe peer must retain actual peak texture motion")
        }
    }

    func testWholeSpacingRejectsAlphaChangedOnlyInInterpolationFootprint() throws {
        let face=try face(),original=source(face:face)
        let map=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:strengths(3,1),sourceRGBA:original))
        XCTAssertEqual(map.admittedBrowCount,2)
        XCTAssertNotEqual(map.applyRGBA(original),original,"two visible sides supply the positive control")
        var candidate:Int?
        search: for y in Int(0.22*Double(height))+1..<Int(0.39*Double(height)) {
            for x in (width/2)..<width {
                let i=(y*width+x)*4,p=SIMD2(Double(x)+0.5,Double(y)+0.5)
                let above=SIMD2(p.x,p.y-1)
                if original[i] >= 100,map.operationContains(above - SIMD2(0.5,0.5)),!map.operationContains(p - SIMD2(0.5,0.5)) {
                    candidate=i;break search
                }
            }
        }
        let i=try XCTUnwrap(candidate,"opaque skin adjacent to the raw operation boundary is outside its writable union")
        var changed=original;changed[i+3]=254
        var appliedCounts = [Int]()
        XCTAssertEqual(map.applyRGBA(changed,onAppliedSideCount:{ appliedCounts.append($0) }),changed,
                       "a late alpha mismatch in the inverse interpolation basis cancels the pair")
        XCTAssertEqual(appliedCounts,[0])
    }

    func testSubQuantizationFieldsAreAppliedEvenWhenAllOutputBytesRemainExact() throws {
        let face = try face(), original = source(face: face)
        for index in [1, 2] {
            let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: face, strengths: strengths(index, 1e-8), sourceRGBA: original))
            XCTAssertEqual(map.admittedBrowCount, 2)
            XCTAssertGreaterThan(map.maximumDisplacement, 0)
            var appliedCounts = [Int]()
            let output = map.applyRGBA(original,onAppliedSideCount:{ appliedCounts.append($0) })
            XCTAssertEqual(output,original,"a sub-quantization field may preserve every RGB byte")
            XCTAssertEqual(appliedCounts,[2],"actual ownership is independent of integer RGB changes")
        }
    }

    func testAnalyticBudgetCoversFiniteDifferenceGradientsAcrossWholeCanvas() throws {
        let face = try face(), original = source(face: face)
        var cases = (0..<7).map { strengths($0, $0.isMultiple(of: 2) ? 1 : -1) }
        var mixed = BeautyEffectiveStrengths()
        for index in 0..<7 {
            mixed[keyPath: BeautyContinuousEyebrowMap.keys[index]] =
                BeautyContinuousEyebrowMap.caps[index] * (index.isMultiple(of: 2) ? -1 : 1)
        }
        cases.append(mixed)
        let epsilon = 1e-3
        for values in cases {
            let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: face, strengths: values, sourceRGBA: original))
            var measuredMaximum = 0.0, minimumDeterminant = Double.infinity
            // This grid covers both sides, the stationary ownership band, all
            // support transitions and protected regions. Numerical samples are
            // lower bounds only; production supplies the analytic global bound.
            for y in stride(from: 0.0, through: Double(height), by: 4) {
                for x in stride(from: 0.0, through: Double(width), by: 4) {
                    let p = SIMD2(x,y)
                    let dx = (map.displacement(at: p + SIMD2(epsilon,0)) -
                              map.displacement(at: p - SIMD2(epsilon,0))) / (2*epsilon)
                    let dy = (map.displacement(at: p + SIMD2(0,epsilon)) -
                              map.displacement(at: p - SIMD2(0,epsilon))) / (2*epsilon)
                    let xx=dx.x*dx.x+dx.y*dx.y, yy=dy.x*dy.x+dy.y*dy.y
                    let xy=dx.x*dy.x+dx.y*dy.y
                    let norm=sqrt(max(0,(xx+yy+sqrt((xx-yy)*(xx-yy)+4*xy*xy))*0.5))
                    measuredMaximum=max(measuredMaximum,norm)
                    minimumDeterminant=min(minimumDeterminant,(1+dx.x)*(1+dy.y)-dy.x*dx.y)
                }
            }
            XCTAssertGreaterThan(measuredMaximum,0,"the grid must observe actual field motion")
            XCTAssertLessThanOrEqual(measuredMaximum,map.maximumGradient+1e-6)
            XCTAssertLessThanOrEqual(map.maximumInverseContraction,BeautyContinuousEyebrowMap.gradientBudget+1e-9)
            if values.eyebrowSpacing == 0 && values.eyebrowHeadSpacing == 0 {
                XCTAssertLessThanOrEqual(map.maximumGradient,BeautyContinuousEyebrowMap.gradientBudget+1e-9)
            }
            XCTAssertGreaterThan(minimumDeterminant,0,"the observed forward Jacobians retain orientation")
        }
    }

    func testProtectionFarBelowFullSupportDoesNotClipAxialTransitions() throws {
        let base = try face(), original = source(face: base)
        func withNose(_ minimumX: Float, _ maximumX: Float) -> FaceGeometry {
            FaceGeometry(bounds: base.bounds, faceContour: base.faceContour,
                leftEye: base.leftEye, rightEye: base.rightEye,
                nose: [SIMD2(minimumX,0.60),SIMD2(maximumX,0.60),
                       SIMD2(maximumX,0.65),SIMD2(minimumX,0.65)],
                outerLips: base.outerLips, observedEyebrowSupport: base.observedEyebrowSupport)
        }
        // Both independent nose boxes are vertically remote from the complete
        // source support. Changing only their horizontal reach cannot alter the
        // head/tail transition or silently reduce an eyebrow's amplitude.
        let broad = withNose(0.46,0.54), narrow = withNose(0.49,0.51)
        let traces = [base.observedEyebrowSupport?.left,base.observedEyebrowSupport?.right].compactMap { $0 }
        for index in [2,4] {
            let a = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: broad, strengths: strengths(index,1), sourceRGBA: original))
            let b = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: narrow, strengths: strengths(index,1), sourceRGBA: original))
            for trace in traces { for point in trace.points {
                let pixel = SIMD2(Double(point.x)*Double(width)-0.5,Double(point.y)*Double(height)-0.5)
                let difference = a.displacement(at:pixel)-b.displacement(at:pixel)
                XCTAssertLessThan(hypot(difference.x,difference.y),1e-9)
            } }
            XCTAssertEqual(a.maximumGradient,b.maximumGradient,accuracy:1e-9)
            XCTAssertEqual(a.maximumDisplacement,b.maximumDisplacement,accuracy:1e-9)
        }
    }

    func testWeakCompleteHeadBeyondCoreMovesAgainstBrighterLocalSkin() throws {
        let face = try face(flat: true)
        let traces = try [XCTUnwrap(face.observedEyebrowSupport?.left),
                          XCTUnwrap(face.observedEyebrowSupport?.right)]
        let heads = traces.map { trace in
            (x: Double(trace.innerEndpoint.x) * Double(width),
             y: Double(trace.innerEndpoint.y) * Double(height),
             direction: trace.side == .left ? -1.0 : 1.0,
             length: abs(Double(trace.outerEndpoint.x - trace.innerEndpoint.x)) * Double(width))
        }
        let coreRadius = 3.5, headExtent = 8.0, minimumMotion = 1.0
        let bodySkin = SIMD3<Double>(120, 100, 80)
        let capSkin = SIMD3<Double>(235, 215, 195)
        let weakHair = capSkin - SIMD3<Double>(repeating: 20)
        // These independent illumination plateaus deliberately put the complete
        // weak head beyond the strong source capsule. Bare body observations
        // are constant and darker in every channel than this real head signal;
        // extrapolating their surface cannot qualify the brighter head skin.
        XCTAssertGreaterThan(weakHair.x, bodySkin.x + 60)
        XCTAssertGreaterThan(weakHair.y, bodySkin.y + 60)
        XCTAssertGreaterThan(weakHair.z, bodySkin.z + 60)

        func fixture(includeWeakHead: Bool = true) -> [UInt8] {
            var pixels = source(face: face, halfThickness: coreRadius)
            for y in 0..<height { for x in 0..<width {
                let i = (y * width + x) * 4, px = Double(x) + 0.5, py = Double(y) + 0.5
                // The existing source fixture's dark capsule is left intact.
                guard pixels[i] >= 100 else { continue }
                let brightCap = px > heads[0].x + coreRadius && px < heads[1].x - coreRadius
                var color = brightCap ? capSkin : bodySkin
                if includeWeakHead, heads.contains(where: { head in
                    let u = (px - head.x) * head.direction
                    return u >= -headExtent && u < -coreRadius && abs(py - head.y) <= 2
                }) { color = weakHair }
                pixels[i] = UInt8(color.x); pixels[i + 1] = UInt8(color.y); pixels[i + 2] = UInt8(color.z)
            } }
            return pixels
        }
        // This marker comes only from the analytic source: a 20-level deficit
        // on a vertically constant bright plateau, axially outside the core.
        // It does not inspect material opacity, admission, fitted skin or flow.
        func headMarker(_ pixels: [UInt8], side: Int) -> (mass: Double, y: Double) {
            let head = heads[side]
            var mass = 0.0, moment = 0.0
            for y in 0..<height { for x in 0..<width {
                let px = Double(x) + 0.5, py = Double(y) + 0.5
                let u = (px - head.x) * head.direction
                guard u >= -headExtent - 1, u < -coreRadius, abs(py - head.y) <= 10 else { continue }
                let i = (y * width + x) * 4
                let deficit = min(capSkin.x - Double(pixels[i]),
                                  capSkin.y - Double(pixels[i + 1]), capSkin.z - Double(pixels[i + 2]))
                let weight = max(0, deficit)
                mass += weight; moment += py * weight
            } }
            return (mass, mass > 0 ? moment / mass : .nan)
        }
        let opaque = fixture(), noHead = fixture(includeWeakHead: false)
        let before = (0..<2).map { headMarker(opaque, side: $0) }
        for side in 0..<2 {
            XCTAssertGreaterThan(before[side].mass, 300, "the complete weak source head must be present")
            XCTAssertEqual(headMarker(noHead, side: side).mass, 0, "bare cap skin is not a head marker")
        }
        let neutral = BeautyContinuousEyebrowMap(width: width, height: height, face: face,
            strengths: BeautyEffectiveStrengths(), sourceRGBA: opaque)
        XCTAssertNil(neutral)
        let unchanged = neutral?.applyRGBA(opaque) ?? opaque
        XCTAssertTrue(unchanged == opaque, "neutral output retains all source bytes")
        for side in 0..<2 {
            let noOpMotion = headMarker(unchanged, side: side).y - before[side].y
            XCTAssertEqual(noOpMotion, 0)
            XCTAssertLessThan(abs(noOpMotion), minimumMotion, "a safe no-op fails the positive motion oracle")
        }

        var transparentCaps = opaque
        for y in 0..<height { for x in 0..<width {
            let px = Double(x) + 0.5, py = Double(y) + 0.5
            if heads.contains(where: { head in
                let u = (px - head.x) * head.direction
                return u >= -headExtent - 1 && u < -coreRadius && abs(py - head.y) <= 10
            }) { transparentCaps[(y * width + x) * 4 + 3] = 120 }
        } }
        let paths = [face.leftEye, face.rightEye, face.nose, face.outerLips]
        for sign: Float in [-1, 1] {
            let s = strengths(0, sign)
            let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: face, strengths: s, sourceRGBA: opaque))
            let output = map.applyRGBA(opaque)
            XCTAssertTrue(output == map.applyRGBA(opaque), "repeated output retains exact RGBA")
            for side in 0..<2 {
                let after = headMarker(output, side: side)
                XCTAssertGreaterThan(after.mass, before[side].mass * 0.70, "transport the weak source signal")
                XCTAssertLessThan(after.mass, before[side].mass * 1.25,
                    "leaving the original head plus a second copy must not pass the motion oracle")
                XCTAssertGreaterThan((after.y - before[side].y) * Double(sign), minimumMotion,
                    "direct API Y must move the complete weak head in the requested direction")
            }
            let noHeadMap = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: face, strengths: s, sourceRGBA: noHead))
            let noHeadOutput = noHeadMap.applyRGBA(noHead)
            for side in 0..<2 {
                XCTAssertEqual(headMarker(noHeadOutput, side: side).mass, 0, "no invented weak head on bare skin")
            }
            var alphaDelta = 0, protectedDelta = 0, exteriorDelta = 0
            for y in 0..<height { for x in 0..<width {
                let i = (y * width + x) * 4, p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
                alphaDelta += abs(Int(output[i + 3]) - Int(opaque[i + 3]))
                let protected = paths.contains { path in
                    p.x >= Double(path.map(\.x).min()!) * Double(width) - 2 &&
                    p.x <= Double(path.map(\.x).max()!) * Double(width) + 2 &&
                    p.y >= Double(path.map(\.y).min()!) * Double(height) - 2 &&
                    p.y <= Double(path.map(\.y).max()!) * Double(height) + 2
                }
                // Fixed source geometry plus a generous Y transport margin;
                // this exterior oracle does not use operationContains.
                let inBrowNeighborhood = heads.contains { head in
                    let u = (p.x - head.x) * head.direction
                    return u >= -12 && u <= head.length + 10 && abs(p.y - head.y) <= 14
                }
                for c in 0..<4 {
                    let delta = abs(Int(output[i + c]) - Int(opaque[i + c]))
                    if protected { protectedDelta += delta }
                    if !inBrowNeighborhood { exteriorDelta += delta }
                }
            } }
            XCTAssertEqual(alphaDelta, 0); XCTAssertEqual(protectedDelta, 0); XCTAssertEqual(exteriorDelta, 0)
            let transparentMap = BeautyContinuousEyebrowMap(width: width, height: height,
                face: face, strengths: s, sourceRGBA: transparentCaps)
            XCTAssertTrue((transparentMap?.applyRGBA(transparentCaps) ?? transparentCaps) == transparentCaps,
                          "transparent cap source remains exact")
            XCTAssertTrue(map.applyRGBA(transparentCaps) == transparentCaps,
                          "changed cap alpha invalidates source ownership")
        }
        var invalid = strengths(0, 1); invalid.eyebrowYPosition = .nan
        XCTAssertNil(BeautyContinuousEyebrowMap(width: width, height: height, face: face,
            strengths: invalid, sourceRGBA: opaque))
        XCTAssertNil(BeautyContinuousEyebrowMap(width: width, height: height, face: face,
            strengths: strengths(0, 1), sourceRGBA: Array(opaque.dropLast())))
    }

    func testNeutralStaleMalformedDimensionsAndTransparentSamplingAbstain() throws {
        let face = try face()
        let opaque = source(face: face)
        XCTAssertNil(BeautyContinuousEyebrowMap(width: width, height: height, face: face, strengths: BeautyEffectiveStrengths(), sourceRGBA: opaque))
        XCTAssertNil(BeautyContinuousEyebrowMap(width: width, height: height, face: face, strengths: strengths(0, 1)))
        XCTAssertNil(BeautyContinuousEyebrowMap(width: width, height: height, face: try self.face(freshness: .stale), strengths: strengths(0, 1), sourceRGBA: opaque))
        XCTAssertNil(BeautyContinuousEyebrowMap(width: 1, height: height, face: face, strengths: strengths(0, 1)))
        XCTAssertNil(BeautyContinuousEyebrowMap(width: Int.max, height: height, face: face, strengths: strengths(0, 1)))
        var invalid = strengths(0, 1); invalid.eyebrowYPosition = .nan
        XCTAssertNil(BeautyContinuousEyebrowMap(width: width, height: height, face: face, strengths: invalid, sourceRGBA: opaque))
        let source = source(face: face, alphaStripe: true)
        XCTAssertNil(BeautyContinuousEyebrowMap(width: width, height: height, face: face, strengths: strengths(3, 1), sourceRGBA: source))
        let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height, face: face, strengths: strengths(3, 1), sourceRGBA: opaque))
        // This horizontal shift always includes two unlike-alpha columns in
        // its bilinear support; it cannot blend their RGB or overwrite alpha.
        var transparentCounts = [Int](), invalidSizeCounts = [Int]()
        XCTAssertEqual(map.applyRGBA(source,onAppliedSideCount:{ transparentCounts.append($0) }), source)
        XCTAssertEqual(transparentCounts,[0])
        XCTAssertEqual(map.applyRGBA([1, 2, 3],onAppliedSideCount:{ invalidSizeCounts.append($0) }), [1, 2, 3])
        XCTAssertEqual(invalidSizeCounts,[0])
        let mirror = String(reflecting: map)
        XCTAssertFalse(mirror.contains("offsets")); XCTAssertFalse(mirror.contains("line"))
        XCTAssertEqual(Set(Mirror(reflecting: map).children.compactMap(\.label)), ["width", "height", "browCount"])
    }
}
