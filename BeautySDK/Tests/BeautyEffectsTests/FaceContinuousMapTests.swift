import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

final class FaceContinuousMapTests: XCTestCase {
    private func face(dense: Bool = false, count: Int = 21, qualified: Bool = false) throws -> FaceGeometry {
        let contour = (0..<count).map { i -> SIMD2<Float> in
            let a = Float(i) / Float(count-1) * .pi
            return SIMD2(0.5 - 0.24*cos(a), 0.36 + 0.42*sin(a))
        }
        func box(_ x: Float, _ y: Float, _ w: Float, _ h: Float) -> [SIMD2<Float>] {
            [SIMD2(x,y), SIMD2(x+w,y), SIMD2(x+w,y+h), SIMD2(x,y+h)]
        }
        func eye(_ side: BeautyObservedEyeSide, _ x: Float) -> BeautyEyeSemanticSupport {
            let path = box(x, 0.30, 0.10, 0.06)
            return BeautyEyeSemanticSupport(side: side, contour: path,
                upper: Array(path.prefix(2)), lower: Array(path.suffix(2)),
                inner: [path[0]], outer: [path[1]], corners: [path[0], path[1]],
                center: (path[0] + path[2]) * 0.5, pupil: nil, span: SIMD2(0.10, 0.06), tilt: 0)
        }
        let mesh = dense ? try XCTUnwrap(BeautyFaceMesh(points: (0..<478).map {
            SIMD3<Float>(0.18 + Float($0 % 23)/36, 0.10 + Float($0/23)/27, 0)
        })) : nil
        return FaceGeometry(bounds: FaceBounds(x: 0.24,y: 0.14,width: 0.52,height: 0.66),
            faceContour: contour,
            observedFaceSupport: BeautyFaceSemanticSupport(contour: contour,
                medianLine: [SIMD2(0.5,0.34),SIMD2(0.5,0.55),SIMD2(0.5,0.78)], apexIndex: count/2),
            leftEye: box(0.34,0.30,0.10,0.06), rightEye: box(0.56,0.30,0.10,0.06),
            outerLips: box(0.40,0.57,0.20,0.07),
            leftEyeSupport: qualified ? eye(.left, 0.34) : nil,
            rightEyeSupport: qualified ? eye(.right, 0.56) : nil,
            observedOuterLips: box(0.40,0.57,0.20,0.07),
            observedNoseSupport: qualified ? BeautyObservedNoseSupport(
                crest: [CoordinatePoint(x: 0.5, y: 0.40), CoordinatePoint(x: 0.5, y: 0.46), CoordinatePoint(x: 0.5, y: 0.52)],
                contour: [CoordinatePoint(x: 0.46, y: 0.51), CoordinatePoint(x: 0.5, y: 0.54), CoordinatePoint(x: 0.54, y: 0.51)]) : nil,
            denseSupport: mesh.map(BeautyDenseFaceSupport.init(mesh:)))
    }

    private func raster(_ width: Int, _ height: Int, _ marks: [SIMD2<Double>]) -> [UInt8] {
        var result = [UInt8](repeating: 255, count: width*height*4)
        for y in 0..<height { for x in 0..<width {
            let distance = marks.map {
                pow(Double(x)+0.5-$0.x*Double(width),2) + pow(Double(y)+0.5-$0.y*Double(height),2)
            }.min()!
            let i=(y*width+x)*4
            result[i]=UInt8((128-110*exp(-distance/12)).rounded())
            result[i+1]=UInt8(x*100/width); result[i+2]=UInt8(y*100/height)
        } }
        return result
    }

    private func measure(_ bytes: [UInt8], _ width: Int, _ height: Int, vertical: Bool) -> Double {
        var total=[0.0,0.0], weighted=total
        for y in 0..<height { for x in 0..<width {
            let v=Double(max(0,128-Int(bytes[(y*width+x)*4])))
            let side=vertical ? 0 : (x < width/2 ? 0 : 1)
            total[side]+=v; weighted[side]+=v*Double(vertical ? y : x)
        } }
        return vertical ? weighted[0]/total[0] : weighted[1]/total[1]-weighted[0]/total[0]
    }

    func testEightFieldsHaveVisibleMonotoneDirectionsOnSparseAndDenseCarriers() throws {
        let cases: [(WritableKeyPath<BeautyEffectiveStrengths,Float>,Float,Double,Double,Bool,Double)] = [
            (\.faceSlim,0.60,0.305,0.61,false,-1),
            (\.faceSmall,0.45,0.305,0.61,false,-1),
            (\.jawSlim,0.45,0.36,0.70,false,-1),
            (\.faceVShape,0.50,0.36,0.70,false,-1),
            (\.templeFullness,0.25,0.26,0.29,false,1),
            (\.cheekboneSlim,0.25,0.265,0.43,false,-1),
            (\.chinTaper,0.25,0.41,0.75,false,-1),
            (\.chinLength,0.35,0.50,0.78,true,1)
        ]
        for dense in [false,true] { for (width,height) in [(480,640),(640,480)] {
            let anatomy=try face(dense:dense)
            for (key,cap,x,y,vertical,direction) in cases {
                let source=raster(width,height,vertical ? [SIMD2(x,y)] : [SIMD2(x,y),SIMD2(1-x,y)])
                let baseline=measure(source,width,height,vertical:vertical)
                for sign: Float in (key == \.faceVShape ? [1] : [-1,1]) {
                    var previous=0.0
                    for fraction: Float in [0.25,0.5,0.75,1] {
                        var s=BeautyEffectiveStrengths(); s[keyPath:key]=sign*cap*fraction
                        let map=try XCTUnwrap(BeautyContinuousFaceMap(width:width,height:height,face:anatomy,strengths:s))
                        let output=map.applyRGBA(source)
                        let amplitude=(measure(output,width,height,vertical:vertical)-baseline)*direction*Double(sign)
                        XCTAssertGreaterThan(amplitude,previous+0.1,"\(key) \(fraction) dense=\(dense)")
                        if fraction==1 { XCTAssertGreaterThan(amplitude,1) }
                        previous=amplitude
                        XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
                        XCTAssertEqual(output,map.applyRGBA(source))
                        var protectedDelta=0, alphaDelta=0
                        for py in 0..<height { for px in 0..<width {
                            let nx=(Double(px)+0.5)/Double(width), ny=(Double(py)+0.5)/Double(height)
                            let eye=((0.34...0.44).contains(nx)||(0.56...0.66).contains(nx)) && (0.30...0.36).contains(ny)
                            let mouth=(0.40...0.60).contains(nx)&&(0.57...0.64).contains(ny)
                            let exterior=nx<0.12 || nx>0.88 || ny<0.10 || ny>0.90
                            let i=(py*width+px)*4
                            if eye || mouth || exterior { for c in 0..<3 { protectedDelta += abs(Int(output[i+c])-Int(source[i+c])) } }
                            alphaDelta += abs(Int(output[i+3])-Int(source[i+3]))
                        } }
                        XCTAssertEqual(protectedDelta,0); XCTAssertEqual(alphaDelta,0)
                    }
                }
            }
        } }
    }

    func testSliderMappingReconstructionCapsAndJointPlanning() throws {
        let keys: [WritableKeyPath<BeautyParameters,Float>] = [\.faceSlim,\.faceSmall,\.jawSlim,\.templeFullness,\.cheekboneSlim,\.chinTaper]
        for key in keys {
            var p=BeautyParameters(); p[keyPath:key] = -2
            let normalized=p.normalized()
            XCTAssertEqual(normalized[keyPath:key],-1)
            let decoded=try JSONDecoder().decode(BeautyParameters.self,from:JSONEncoder().encode(normalized))
            XCTAssertEqual(decoded,normalized)
        }
        for control in BeautyFaceShapeSlider.allCases {
            let neutral=control.applying(position:control.neutralPosition,to:BeautyParameters())
            XCTAssertEqual(neutral,BeautyParameters())
            XCTAssertEqual(control.applying(position:.nan,to:BeautyParameters()),neutral)
        }
        XCTAssertEqual(BeautyFaceShapeSlider.chinLength.applying(position:1,to:BeautyParameters()).chinLength,-BeautySafetyCaps.chinLength)
        XCTAssertEqual(BeautyFaceShapeSlider.faceWidth.applying(position:1,to:BeautyParameters()).faceSlim,BeautySafetyCaps.faceSlim)
        XCTAssertEqual(BeautyFaceShapeSlider.smallFace.applying(position:1,to:BeautyParameters()).faceSmall,BeautySafetyCaps.faceSmall)
        let endpoints: [(BeautyFaceShapeSlider,KeyPath<BeautyParameters,Float>,Float)] = [
            (.faceWidth,\.faceSlim,BeautySafetyCaps.faceSlim),
            (.smallFace,\.faceSmall,BeautySafetyCaps.faceSmall),
            (.jawAngle,\.jawSlim,BeautySafetyCaps.jawSlim),
            (.vFace,\.faceVShape,BeautySafetyCaps.faceVShape),
            (.temple,\.templeFullness,BeautySafetyCaps.templeFullness),
            (.cheekbone,\.cheekboneSlim,BeautySafetyCaps.cheekboneSlim),
            (.chinTaper,\.chinTaper,BeautySafetyCaps.chinTaper),
            (.chinLength,\.chinLength,-BeautySafetyCaps.chinLength),
            (.contourSmooth,\.faceContourSmooth,BeautySafetyCaps.faceContourSmooth),
            (.hairline,\.hairlineHeight,BeautySafetyCaps.hairlineHeight)]
        for (slider,key,cap) in endpoints {
            XCTAssertEqual(slider.applying(position:1,to:BeautyParameters())[keyPath:key],cap)
            XCTAssertEqual(slider.applying(position:2,to:BeautyParameters())[keyPath:key],cap)
            XCTAssertEqual(slider.applying(position:-1,to:BeautyParameters())[keyPath:key],
                slider.neutralPosition == 0 ? 0 : -cap)
            XCTAssertEqual(slider.applying(position:1,to:BeautyParameters(noseBridge:0.1)).noseBridge,0.1)
        }
        let anatomy=try face(qualified:true)
        let parameters=BeautyParameters(faceSlim:-1,faceSmall:-1,jawSlim:-1,templeFullness:-1,cheekboneSlim:-1,chinTaper:-1)
        let plan=BeautyEffectResolver.resolve(parameters:parameters,faceGeometry:anatomy)
        XCTAssertLessThan(plan.effectiveStrengths.faceSlim,0)
        XCTAssertLessThan(plan.effectiveStrengths.templeFullness,0)
        XCTAssertLessThan(plan.effectiveStrengths.chinTaper,0)
        XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        let joint=GeometryConflictResolver().resolve(strengths:plan.effectiveStrengths)
        XCTAssertLessThan(joint.strengths.faceSmall,0)
        let map=try XCTUnwrap(BeautyContinuousFaceMap(width:480,height:640,face:anatomy,strengths:joint.strengths))
        var dumpText=""; dump(map,to:&dumpText)
        XCTAssertFalse(dumpText.contains("offsets"));XCTAssertFalse(dumpText.contains("SIMD2"))
    }

    func testNeutralMissingStaleAndMalformedSupportsAbstainWithoutLegacyFallback() throws {
        let anatomy=try face(); var s=BeautyEffectiveStrengths(); s.faceSmall=0.45
        XCTAssertNil(BeautyContinuousFaceMap(width:480,height:640,face:anatomy,strengths:BeautyEffectiveStrengths()))
        let invalid=FaceGeometry(bounds:anatomy.bounds,faceContour:anatomy.faceContour,
            observedFaceSupport:BeautyFaceSemanticSupport(contour:[SIMD2(.nan,.nan)],medianLine:nil,apexIndex:nil),
            observedOuterLips:anatomy.observedOuterLips)
        let source=raster(480,640,[SIMD2(0.5,0.78)])
        let plan=BeautyEffectPlan(activeDomains:[.faceShape],effectiveStrengths:s)
        let stage=BeautyStillImageGeometryStage(sourceRGBA:source,width:480,height:640,plan:plan,face:invalid)
        XCTAssertTrue(stage.controlPoints.isEmpty)
        XCTAssertEqual(stage.applyingContinuousContour(to:source),source)
        XCTAssertNil(BeautyContinuousFaceMap(width:480,height:640,face:invalid,strengths:s))
        let stale=FaceGeometry(bounds:anatomy.bounds, faceContour:anatomy.faceContour,
            observedFaceSupport:anatomy.observedFaceSupport,
            leftEye:anatomy.leftEye, rightEye:anatomy.rightEye,
            freshness:.stale, observedOuterLips:anatomy.observedOuterLips)
        XCTAssertNil(BeautyContinuousFaceMap(width:480,height:640,face:stale,strengths:s))
        let coarse=FaceGeometry(bounds:anatomy.bounds, faceContour:anatomy.faceContour,
            observedFaceSupport:anatomy.observedFaceSupport,
            leftEye:anatomy.leftEye, rightEye:anatomy.rightEye)
        var negative=s; negative.faceSmall = -0.45; negative.chinTaper = -0.25
        XCTAssertTrue(FaceShapeWarpProvider().fieldEmissions(face:coarse,strengths:negative).faceSmall.isEmpty)
        XCTAssertTrue(ChinWarpProvider().fieldEmissions(face:coarse,strengths:negative).chinTaper.isEmpty)
        let missing=BeautyStillImageGeometryStage(sourceRGBA:source,width:480,height:640,plan:plan,face:nil)
        XCTAssertEqual(missing.applyingContinuousContour(to:source),source)
    }

    func testSmallFaceKeepsSmoothGeneratedChinConnectedAtEveryQuarterLevel() throws {
        let width=480,height=640,anatomy=try face()
        var source=[UInt8](repeating:255,count:width*height*4)
        for y in 0..<height { for x in 0..<width {
            let nx=(Double(x)+0.5)/Double(width), ny=(Double(y)+0.5)/Double(height)
            let inside=pow((nx-0.5)/0.24,2)+pow((ny-0.36)/0.42,2) <= 1
            let i=(y*width+x)*4
            source[i]=inside ? 220 : 20; source[i+1]=source[i]; source[i+2]=source[i]
        } }
        for fraction:Float in [0.25,0.5,0.75,1] {
            var s=BeautyEffectiveStrengths(); s.faceSmall=0.45*fraction
            let map=try XCTUnwrap(BeautyContinuousFaceMap(width:width,height:height,face:anatomy,strengths:s))
            let output=map.applyRGBA(source)
            var bottoms=[Int]()
            for x in 175...305 {
                let hits=(400..<540).filter { output[($0*width+x)*4] > 120 }
                bottoms.append(try XCTUnwrap(hits.last))
                XCTAssertEqual(hits.count,(hits.last ?? 399)-399,"connected silhouette")
            }
            let turns=zip(bottoms,bottoms.dropFirst()).map { $1-$0 }
            XCTAssertLessThanOrEqual(turns.map(abs).max() ?? 0,2)
            let upward=turns.prefix(65), downward=turns.suffix(65)
            XCTAssertTrue(upward.allSatisfy { $0>=0 },"no new left chin scallop")
            XCTAssertTrue(downward.allSatisfy { $0<=0 },"no new right chin scallop")
        }
    }
}
