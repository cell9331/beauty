import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// One synthetic anatomical source, reused by integration tests. Landmarks are
/// generated from named feature outlines independently of the nasal field.
enum ContinuousNoseTestFixture {
    static func point(_ p: SIMD2<Double>, angle: Double = 0, aspect: Double = 1) -> SIMD2<Double> {
        let x = (p.x - 0.5) * aspect, y = p.y - 0.5
        return SIMD2(0.5 + (x * cos(angle) - y * sin(angle)) / aspect,
                     0.5 + x * sin(angle) + y * cos(angle))
    }

    static func observation(angle: Double = 0, aspect: Double = 1) throws -> BeautyFaceObservation {
        var points = [SIMD3<Float>](repeating: SIMD3(0.5, 0.5, 0), count: 478)
        func put(_ index: Int, _ x: Double, _ y: Double) { points[index] = SIMD3(Float(x), Float(y), 0) }
        for (i, index) in MediaPipeFaceTopology.oval.enumerated() {
            let a = -.pi / 2 + Double(i) * 2 * .pi / Double(MediaPipeFaceTopology.oval.count)
            put(index, 0.5 + cos(a) * 0.30, 0.49 + sin(a) * 0.39)
        }
        for (i, index) in MediaPipeFaceTopology.lowerContour.enumerated() {
            let a = Double(i) * .pi / Double(MediaPipeFaceTopology.lowerContour.count - 1)
            put(index, 0.5 - cos(a) * 0.30, 0.35 + sin(a) * 0.53)
        }
        for (indices, cx, direction) in [(MediaPipeFaceTopology.leftEye, 0.365, -1.0),
                                          (MediaPipeFaceTopology.rightEye, 0.635, 1.0)] {
            for (i, index) in indices.enumerated() {
                let a = Double(i) * 2 * .pi / Double(indices.count)
                put(index, cx + direction * cos(a) * 0.060, 0.32 + sin(a) * 0.027)
            }
        }
        for (indices, cx) in [(MediaPipeFaceTopology.leftIris, 0.365), (MediaPipeFaceTopology.rightIris, 0.635)] {
            for (i, index) in indices.enumerated() {
                let a = Double(i) * 2 * .pi / Double(indices.count)
                put(index, cx + cos(a) * 0.018, 0.32 + sin(a) * 0.018)
            }
        }
        put(468, 0.365, 0.32); put(473, 0.635, 0.32)
        for (indices, side) in [(MediaPipeFaceTopology.leftBrowEnvelope, -1.0),
                                (MediaPipeFaceTopology.rightBrowEnvelope, 1.0)] {
            for (i, index) in indices.enumerated() {
                let column = i < 5 ? i : 9 - i
                let x = 0.5 + side * (0.067 + 0.035 * Double(column))
                let y = 0.245 - 0.018 * sin(Double(column) * .pi / 4) + (i < 5 ? 0 : 0.018)
                put(index, x, y)
            }
        }
        for (indices, rx, ry) in [(MediaPipeFaceTopology.outerLip, 0.105, 0.034),
                                  (MediaPipeFaceTopology.innerLip, 0.085, 0.014)] {
            for (i, index) in indices.enumerated() {
                let a = .pi + Double(i) * 2 * .pi / Double(indices.count)
                put(index, 0.5 + cos(a) * rx, 0.75 + sin(a) * ry)
            }
        }
        let contour: [(Double, Double)] = [(0.43,0.63),(0.46,0.64),(0.5,0.655),(0.54,0.64),
            (0.57,0.63),(0.59,0.61),(0.60,0.585),(0.585,0.54),(0.55,0.50),(0.535,0.555),
            (0.50,0.575),(0.465,0.555),(0.45,0.50),(0.415,0.54),(0.40,0.585),(0.41,0.61)]
        for (index, p) in zip(MediaPipeFaceTopology.noseContour, contour) { put(index, p.0, p.1) }
        for (index, y) in zip(MediaPipeFaceTopology.noseCrest, [0.35,0.39,0.45,0.50,0.545,0.575,0.615]) {
            put(index, 0.5, y)
        }
        put(193, 0.47, 0.35); put(417, 0.53, 0.35)
        put(151, 0.5, 0.18); put(9, 0.5, 0.22); put(8, 0.5, 0.27)
        put(164, 0.5, 0.69); put(18, 0.5, 0.81)
        points = points.map { p in
            let q = point(SIMD2(Double(p.x), Double(p.y)), angle: angle, aspect: aspect)
            return SIMD3(Float(q.x), Float(q.y), p.z)
        }
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points))
        return try XCTUnwrap(MediaPipeFaceTopology.observation(from: mesh))
    }

    static func face(angle: Double = 0, aspect: Double = 1) throws -> FaceGeometry {
        BeautyFaceGeometryAdapter.makeGeometry(from: try observation(angle: angle, aspect: aspect))
    }

    static func raster(width: Int, height: Int, marks: [SIMD2<Double>], angle: Double = 0) -> [UInt8] {
        let aspect = Double(width) / Double(height)
        var result = [UInt8](repeating: 173, count: width * height * 4)
        let centers = marks.map { point($0, angle: angle, aspect: aspect) * SIMD2(Double(width), Double(height)) }
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            let p = SIMD2(Double(x) + 0.5, Double(y) + 0.5)
            let dark = centers.contains { center in abs(p.x - center.x) <= 3 && abs(p.y - center.y) <= 3 }
            result[i] = dark ? 20 : 200
            result[i + 1] = UInt8((x * 53 + y * 17) % 150)
            result[i + 2] = UInt8((x * 11 + y * 43) % 150)
        } }
        return result
    }

    static func centroid(_ source: [UInt8], width: Int, height: Int,
                         around center: SIMD2<Double>, radius: Int = 20) -> SIMD2<Double> {
        let cx = Int(center.x * Double(width)), cy = Int(center.y * Double(height))
        var total = 0.0, sum = SIMD2<Double>.zero
        for y in max(0, cy - radius)..<min(height, cy + radius + 1) {
            for x in max(0, cx - radius)..<min(width, cx + radius + 1) {
                let weight = Double(max(0, 200 - Int(source[(y * width + x) * 4])))
                total += weight; sum += SIMD2(Double(x) + 0.5, Double(y) + 0.5) * weight
            }
        }
        return total > 0 ? sum / total : SIMD2(.nan, .nan)
    }
}

final class BeautyContinuousNoseMapTests: XCTestCase {
    private typealias Field = (String, WritableKeyPath<BeautyEffectiveStrengths, Float>, Float, SIMD2<Double>, SIMD2<Double>)
    private let fields: [Field] = [
        ("size", \.noseSlim, 0.35, SIMD2(0.415,0.60), SIMD2(0.585,0.60)),
        ("wing", \.noseWingSlim, 0.35, SIMD2(0.43,0.63), SIMD2(0.57,0.63)),
        ("tip", \.noseTipSize, 0.30, SIMD2(0.475,0.585), SIMD2(0.525,0.585)),
        ("bridge", \.noseBridge, 0.30, SIMD2(0.455,0.51), SIMD2(0.545,0.51)),
        ("root", \.noseRootNarrowing, 0.25, SIMD2(0.46,0.385), SIMD2(0.54,0.385)),
        ("lift", \.noseTipLift, 0.25, SIMD2(0.5,0.615), SIMD2(0.5,0.615))
    ]

    func testSixFieldsMoveIndependentSourceFeaturesMonotonicallyAtBothSignsAndAspects() throws {
        for (width, height) in [(480,640),(640,480)] {
            let face = try ContinuousNoseTestFixture.face(aspect: Double(width) / Double(height))
            XCTAssertTrue(BeautyContinuousNoseMap.isEligible(face: face))
            for (name, key, cap, left, right) in fields {
                let source = ContinuousNoseTestFixture.raster(width: width, height: height,
                    marks: name == "lift" ? [left] : [left,right])
                func measure(_ bytes: [UInt8]) -> Double {
                    let a = ContinuousNoseTestFixture.centroid(bytes, width: width, height: height, around: left,
                        radius: name == "tip" ? 10 : 20)
                    if name == "lift" { return a.y }
                    let b = ContinuousNoseTestFixture.centroid(bytes, width: width, height: height, around: right,
                        radius: name == "tip" ? 10 : 20)
                    return b.x - a.x
                }
                let original = measure(source)
                for sign: Float in [-1,1] {
                    var previous = 0.0
                    for fraction: Float in [0.25,0.5,0.75,1] {
                        var s = BeautyEffectiveStrengths(); s[keyPath:key] = cap * sign * fraction
                        let map = try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:s))
                        let output = map.applyRGBA(source)
                        let amount = (original - measure(output)) * Double(sign)
                        XCTAssertGreaterThan(amount, previous + 0.05, "\(name) \(sign) \(fraction)")
                        if fraction == 1 {
                            XCTAssertGreaterThan(amount, name == "lift" ? 1 : original * 0.03, name)
                        }
                        previous = amount
                        XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
                        XCTAssertEqual(output,map.applyRGBA(source))
                    }
                }
            }
        }
    }

    func testSizePreservesBaseHeightWhileTipKeepsOuterWingsAndRootStable() throws {
        let width=480,height=640,face=try ContinuousNoseTestFixture.face()
        let marks:[SIMD2<Double>] = [SIMD2(0.415,0.60),SIMD2(0.585,0.60),
            SIMD2(0.5,0.655),SIMD2(0.46,0.385),SIMD2(0.54,0.385)]
        let source=ContinuousNoseTestFixture.raster(width:width,height:height,marks:marks)
        for sign:Float in [-1,1] {
            var size=BeautyEffectiveStrengths();size.noseSlim=sign*0.35
            let map=try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:size))
            let result=map.applyRGBA(source)
            let a=ContinuousNoseTestFixture.centroid(source,width:width,height:height,around:marks[2])
            let b=ContinuousNoseTestFixture.centroid(result,width:width,height:height,around:marks[2])
            XCTAssertEqual(a.y,b.y,accuracy:0.03,"size does not shorten the nose")
            var tip=BeautyEffectiveStrengths();tip.noseTipSize=sign*0.30
            let tipMap=try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:tip))
            let tipResult=tipMap.applyRGBA(source)
            for p in [marks[0],marks[1],marks[3],marks[4]] {
                let before=ContinuousNoseTestFixture.centroid(source,width:width,height:height,around:p)
                let after=ContinuousNoseTestFixture.centroid(tipResult,width:width,height:height,around:p)
                XCTAssertLessThan(hypot(after.x-before.x,after.y-before.y),0.8,"tip isolates the bulb")
            }
        }
    }

    func testEyesBrowsFullLipsExteriorAndAlphaRemainExactForEveryFieldAndComposition() throws {
        let width=480,height=640,face=try ContinuousNoseTestFixture.face()
        let source=ContinuousNoseTestFixture.raster(width:width,height:height,marks:[SIMD2(0.5,0.6)])
        let dense=try XCTUnwrap(face.denseSupport)
        let paths=[MediaPipeFaceTopology.leftEye,MediaPipeFaceTopology.rightEye,
                   MediaPipeFaceTopology.leftBrowEnvelope,MediaPipeFaceTopology.rightBrowEnvelope,
                   MediaPipeFaceTopology.outerLip].map { BeautyDenseFaceSupport.path(dense.mesh,$0) }
        let boxes=paths.map { path in
            (Double(path.map(\.x).min()!)*Double(width)-2,
             Double(path.map(\.x).max()!)*Double(width)+2,
             Double(path.map(\.y).min()!)*Double(height)-2,
             Double(path.map(\.y).max()!)*Double(height)+2)
        }
        var samples=[BeautyEffectiveStrengths]()
        for (_,key,cap,_,_) in fields { for sign:Float in [-1,1] {
            var s=BeautyEffectiveStrengths();s[keyPath:key]=sign*cap;samples.append(s)
        } }
        var combination=BeautyEffectiveStrengths()
        for (_,key,cap,_,_) in fields { combination[keyPath:key]=cap }
        samples.append(combination)
        for s in samples {
            let map=try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:s))
            let result=map.applyRGBA(source)
            var alphaDelta=0, protectedDelta=0
            for y in 0..<height { for x in 0..<width {
                let px=Double(x)+0.5,py=Double(y)+0.5,i=(y*width+x)*4
                let feature=boxes.contains { px >= $0.0 && px <= $0.1 && py >= $0.2 && py <= $0.3 }
                let exterior=x<70 || x>410 || y<100 || y>510
                alphaDelta += abs(Int(result[i+3])-Int(source[i+3]))
                if feature || exterior { for c in 0..<3 { protectedDelta += abs(Int(result[i+c])-Int(source[i+c])) } }
            } }
            XCTAssertEqual(alphaDelta,0);XCTAssertEqual(protectedDelta,0)
        }
    }

    func testRollUsesPixelAxesAndKeepsSignedDirection() throws {
        let width=480,height=640,angle=0.20,aspect=Double(width)/Double(height)
        let face=try ContinuousNoseTestFixture.face(angle:angle,aspect:aspect)
        let a=SIMD2(0.415,0.60),b=SIMD2(0.585,0.60)
        let pa=ContinuousNoseTestFixture.point(a,angle:angle,aspect:aspect)
        let pb=ContinuousNoseTestFixture.point(b,angle:angle,aspect:aspect)
        let source=ContinuousNoseTestFixture.raster(width:width,height:height,marks:[a,b],angle:angle)
        func span(_ bytes:[UInt8])->Double {
            let l=ContinuousNoseTestFixture.centroid(bytes,width:width,height:height,around:pa)
            let r=ContinuousNoseTestFixture.centroid(bytes,width:width,height:height,around:pb)
            return (r.x-l.x)*cos(angle)+(r.y-l.y)*sin(angle)
        }
        for sign:Float in [-1,1] {
            var s=BeautyEffectiveStrengths();s.noseSlim=sign*0.35
            let map=try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:s))
            XCTAssertGreaterThan((span(source)-span(map.applyRGBA(source)))*Double(sign),3)
        }
    }

    func testNewSiblingApproachesZeroWithoutRescalingTheVisibleNose() throws {
        let width=480,height=640,face=try ContinuousNoseTestFixture.face()
        let source=ContinuousNoseTestFixture.raster(width:width,height:height,
            marks:[SIMD2(0.415,0.60),SIMD2(0.585,0.60),SIMD2(0.5,0.655)])
        for key in [\BeautyEffectiveStrengths.noseSlim, \.noseTipSize, \.noseTipLift] {
            var single=BeautyEffectiveStrengths();single[keyPath:key]=0.25
            let originalMap=try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:single))
            let expected=originalMap.applyRGBA(source)
            for sign:Float in [-1,1] {
                var nearZero=single;nearZero.noseRootNarrowing=sign*0.000001
                let map=try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:nearZero))
                let actual=map.applyRGBA(source)
                let differences=zip(actual,expected).map { abs(Int($0)-Int($1)) }
                XCTAssertLessThanOrEqual(differences.max() ?? 0,1,"only final byte rounding may differ")
                XCTAssertLessThan(Double(differences.reduce(0,+))/Double(source.count),0.01,
                    "an infinitesimal new control cannot dim an existing effect")
                XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
                XCTAssertLessThanOrEqual(map.maximumDisplacement,
                    min(Double(face.bounds.width)*Double(width),Double(face.bounds.height)*Double(height))*0.060001)
                nearZero.noseRootNarrowing=0
                let reset=try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:nearZero))
                XCTAssertEqual(reset.applyRGBA(source),expected)
            }
        }
        for sign:Float in [-1,1] {
            var mixed=BeautyEffectiveStrengths()
            for (_,key,cap,_,_) in fields { mixed[keyPath:key]=cap*sign }
            let map=try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:mixed))
            XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
            XCTAssertLessThanOrEqual(map.maximumDisplacement,
                min(Double(face.bounds.width)*Double(width),Double(face.bounds.height)*Double(height))*0.060001)
            XCTAssertNotEqual(map.applyRGBA(source),source)
        }
    }

    func testRootLeavesMiddleDorsumStableAndLiftReachesItWithoutMovingAsMuchAsBase() throws {
        let width=480,height=640,face=try ContinuousNoseTestFixture.face()
        let middle=SIMD2(0.46,0.45),base=SIMD2(0.5,0.615)
        for sign:Float in [-1,1] {
            let source=ContinuousNoseTestFixture.raster(width:width,height:height,marks:[middle])
            let before=ContinuousNoseTestFixture.centroid(source,width:width,height:height,around:middle)
            var root=BeautyEffectiveStrengths();root.noseRootNarrowing=sign*0.25
            let rootMap=try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:root))
            let after=ContinuousNoseTestFixture.centroid(rootMap.applyRGBA(source),width:width,height:height,around:middle)
            XCTAssertLessThan(hypot(after.x-before.x,after.y-before.y),0.20,
                "root width should fade before the middle nasal sides")
            var lift=BeautyEffectiveStrengths();lift.noseTipLift=sign*0.25
            let liftMap=try XCTUnwrap(BeautyContinuousNoseMap(width:width,height:height,face:face,strengths:lift))
            func verticalMovement(_ mark:SIMD2<Double>)->Double {
                let input=ContinuousNoseTestFixture.raster(width:width,height:height,marks:[mark])
                let a=ContinuousNoseTestFixture.centroid(input,width:width,height:height,around:mark)
                let b=ContinuousNoseTestFixture.centroid(liftMap.applyRGBA(input),width:width,height:height,around:mark)
                return (a.y-b.y)*Double(sign)
            }
            let middleMove=verticalMovement(SIMD2(0.5,0.455)),baseMove=verticalMovement(base)
            XCTAssertGreaterThan(middleMove,baseMove*0.30,
                "lift includes a visible middle-nose transition")
            XCTAssertLessThan(middleMove,baseMove*0.65,
                "the middle transitions smoothly into the stronger lower lift")
        }
    }

    func testNeutralMalformedInputsAndReflectionExposeNoRawGeometry() throws {
        let face=try ContinuousNoseTestFixture.face()
        XCTAssertNil(BeautyContinuousNoseMap(width:480,height:640,face:face,strengths:BeautyEffectiveStrengths()))
        var s=BeautyEffectiveStrengths();s.noseSlim=0.35
        XCTAssertNil(BeautyContinuousNoseMap(width:1,height:640,face:face,strengths:s))
        var invalid=s;invalid.noseTipSize = .nan
        XCTAssertNil(BeautyContinuousNoseMap(width:480,height:640,face:face,strengths:invalid))
        let missing=FaceGeometry(bounds:face.bounds,faceContour:[],denseSupport:face.denseSupport)
        XCTAssertTrue(BeautyContinuousNoseMap.replacesLegacy(for:missing))
        XCTAssertFalse(BeautyContinuousNoseMap.isEligible(face:missing))
        XCTAssertNil(BeautyContinuousNoseMap(width:480,height:640,face:missing,strengths:s))
        let map=try XCTUnwrap(BeautyContinuousNoseMap(width:480,height:640,face:face,strengths:s))
        XCTAssertEqual(map.applyRGBA([1,2,3]),[1,2,3])
        var dumpText="";dump(map,to:&dumpText)
        XCTAssertFalse(dumpText.contains("offsets"));XCTAssertFalse(dumpText.contains("SIMD2"))
    }
}
