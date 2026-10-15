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
                let result = map.applyRGBA(source)
                XCTAssertNotEqual(source, result, "field \(index) sign \(sign)")
                XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
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
                if !map.operationContains(p) || protected {
                    for c in 0..<4 { protectedDelta += abs(Int(output[i + c]) - Int(source[i + c])) }
                }
            } }
            XCTAssertEqual(alphaDelta, 0); XCTAssertEqual(protectedDelta, 0)
            XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
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
        XCTAssertNil(BeautyContinuousEyebrowMap(width: width, height: height, face: flat, strengths: strengths(6, 1), sourceRGBA: self.source(face: flat)))
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
        XCTAssertEqual(spacing.applyRGBA(changed),changed,"one refused side cancels whole spacing")

        let headStrength=strengths(4,0.6)
        let head=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:headStrength,sourceRGBA:original))
        var combination=headStrength;combination.eyebrowSpacing=BeautyContinuousEyebrowMap.caps[3]
        let mixed=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:combination,sourceRGBA:original))
        let expected=head.applyRGBA(changed),actual=mixed.applyRGBA(changed)
        XCTAssertEqual(actual,expected,"independent fields survive the pair refusal")
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
        let transported=control.applyRGBA(original)
        var candidate:Int?
        search: for y in Int(0.22*Double(height))..<Int(0.39*Double(height)) {
            for x in (width/2)..<Int(0.56*Double(width)-0.12*0.21*Double(width)) {
                let i=(y*width+x)*4,p=SIMD2(Double(x)+0.5,Double(y)+0.5)
                if original[i] >= 100,transported[i] != original[i],!head.operationContains(p) {
                    candidate=i;break search
                }
            }
        }
        let i=try XCTUnwrap(candidate,"positive control exposes a right-side destination outside the source and independent head field")
        var translucent=original;translucent[i+3]=254
        var admissions=[String]()
        let actualMap=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:combination,sourceRGBA:translucent,onAdmission:{ admissions.append($0) }))
        XCTAssertTrue(admissions.contains("eyebrow_left_material_admitted"))
        XCTAssertTrue(admissions.contains("eyebrow_right_material_admitted"))
        XCTAssertTrue(admissions.contains("eyebrow_right_sampling_rejected"),"failure occurs after both materials were admitted")
        XCTAssertTrue(admissions.contains("eyebrow_spacing_pair_rejected"))
        let expectedMap=try XCTUnwrap(BeautyContinuousEyebrowMap(width:width,height:height,face:face,
            strengths:headStrength,sourceRGBA:translucent))
        let expected=expectedMap.applyRGBA(translucent),actual=actualMap.applyRGBA(translucent)
        XCTAssertEqual(actual,expected)
        XCTAssertNotEqual(actual,translucent,"safe independent head fields remain active")
        XCTAssertEqual(actual[i+3],254)
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
                if original[i] >= 100,map.operationContains(above),!map.operationContains(p) {
                    candidate=i;break search
                }
            }
        }
        let i=try XCTUnwrap(candidate,"opaque skin adjacent to the raw operation boundary is outside its writable union")
        var changed=original;changed[i+3]=254
        XCTAssertEqual(map.applyRGBA(changed),changed,"a late alpha mismatch in the inverse interpolation basis cancels the pair")
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
        XCTAssertEqual(map.applyRGBA(source), source)
        XCTAssertEqual(map.applyRGBA([1, 2, 3]), [1, 2, 3])
        let mirror = String(reflecting: map)
        XCTAssertFalse(mirror.contains("offsets")); XCTAssertFalse(mirror.contains("line"))
        XCTAssertEqual(Set(Mirror(reflecting: map).children.compactMap(\.label)), ["width", "height", "browCount"])
    }
}
