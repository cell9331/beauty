import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

final class BeautyContinuousEyeWarpTests: XCTestCase {
    private func face(width:Int=320,height:Int=400,dense:Bool=true,
                      missingLeft:Bool=false,malformedLeft:Bool=false,
                      missingLeftPupil:Bool=false,misplacedLeftPupil:Bool=false,
                      collapsedLeftIris:Bool=false,
                      freshness:LandmarkGeometryFreshness = .fresh,
                      apertureAspect:Float? = nil,
                      upperScale:Float = 1,lowerScale:Float = 1) throws -> FaceGeometry {
        func contour(_ x:Float) -> [SIMD2<Float>] {
            (0..<16).map { i in
                let t=Float(i)*2*Float.pi/16
                let ry=apertureAspect.map { 0.07*Float(width)/Float(height)*$0 } ?? 0.025
                let vertical=sin(t)
                return SIMD2(x+0.07*cos(t),0.40+ry*vertical*(vertical < 0 ? upperScale:lowerScale))
            }
        }
        func eye(_ x:Float,_ side:BeautyObservedEyeSide) -> BeautyEyeSemanticSupport {
            let points=contour(x),inner=SIMD2<Float>(x+(side == .left ? 0.07:-0.07),0.4)
            let outer=SIMD2<Float>(x+(side == .left ? -0.07:0.07),0.4)
            return BeautyEyeSemanticSupport(side:side,contour:points,
                upper:points.filter { $0.y < 0.4 },lower:points.filter { $0.y > 0.4 },
                inner:[inner],outer:[outer],corners:[inner,outer],center:SIMD2(x,0.4),
                pupil:side == .left && missingLeftPupil ? nil:SIMD2(x,side == .left && misplacedLeftPupil ? 0.35:0.4),
                span:SIMD2(0.14,0.05),tilt:0)
        }
        var left=eye(0.36,.left)
        let right=eye(0.64,.right)
        if malformedLeft {
            left=BeautyEyeSemanticSupport(side:.left,contour:[SIMD2(.nan,0.4)],
                upper:[],lower:[],inner:[],outer:[],corners:[],center:SIMD2(0.36,0.4),
                pupil:nil,span:SIMD2(0.14,0.05),tilt:0)
        }
        var points=Array(repeating:SIMD3<Float>(0.5,0.5,0),count:478)
        for (indices,x) in [(MediaPipeFaceTopology.leftIris,Float(0.36)),
                            (MediaPipeFaceTopology.rightIris,Float(0.64))] {
            let irisRadius:Float=collapsedLeftIris && x < 0.5 ? 0:0.017
            for (i,index) in indices.enumerated() {
                let t=Float(i)*2*Float.pi/Float(indices.count)
                points[index]=SIMD3(x+irisRadius*cos(t),0.4+irisRadius*Float(width)/Float(height)*sin(t),0)
            }
        }
        points[468]=SIMD3(0.36,0.4,0);points[473]=SIMD3(0.64,0.4,0)
        let carrier=dense ? BeautyDenseFaceSupport(mesh:try XCTUnwrap(BeautyFaceMesh(points:points))):nil
        let lips:[SIMD2<Float>]=[SIMD2(0.43,0.61),SIMD2(0.57,0.61),SIMD2(0.57,0.65),SIMD2(0.43,0.65)]
        func brow(_ side:BeautyObservedEyebrowSide,_ x:Float) -> BeautyEyebrowSemanticTrace {
            let points=[SIMD2<Float>(x-0.08,0.335),SIMD2(x,0.32),SIMD2(x+0.08,0.335)]
            return BeautyEyebrowSemanticTrace(side:side,points:points,innerEndpoint:points[0],
                outerEndpoint:points[2],center:points[1],apexIndex:1)
        }
        return FaceGeometry(bounds:FaceBounds(x:0.16,y:0.14,width:0.68,height:0.7),faceContour:[],
            leftEye:missingLeft ? []:left.contour,rightEye:right.contour,
            nose:[SIMD2(0.48,0.40),SIMD2(0.52,0.40),SIMD2(0.52,0.54),SIMD2(0.48,0.54)],
            outerLips:lips,leftEyeSupport:missingLeft ? nil:left,rightEyeSupport:right,
            freshness:freshness,
            observedEyebrowSupport:BeautyEyebrowSemanticSupport(left:brow(.left,0.36),right:brow(.right,0.64)),
            observedOuterLips:lips,denseSupport:carrier)
    }

    private func raster(_ width:Int,_ height:Int,mark:SIMD2<Double>) -> [UInt8] {
        var bytes=[UInt8](repeating:255,count:width*height*4)
        for y in 0..<height { for x in 0..<width {
            let dx=Double(x)+0.5-mark.x*Double(width),dy=Double(y)+0.5-mark.y*Double(height)
            let i=(y*width+x)*4
            bytes[i]=UInt8((160-120*exp(-(dx*dx+dy*dy)/5)).rounded())
            bytes[i+1]=UInt8(40+x*140/width);bytes[i+2]=UInt8(40+y*140/height)
        } }
        return bytes
    }

    private func centroid(_ bytes:[UInt8],_ width:Int,_ height:Int) -> SIMD2<Double> {
        var mass=0.0,moment=SIMD2<Double>.zero
        for y in 0..<height { for x in 0..<width {
            let weight=Double(max(0,160-Int(bytes[(y*width+x)*4])))
            mass += weight;moment += SIMD2(Double(x)+0.5,Double(y)+0.5)*weight
        } }
        return moment/mass
    }

    private func denseIrisTexture(_ width:Int,_ height:Int,anatomy:FaceGeometry)
        -> (bytes:[UInt8],rimRegions:[[Int]]) {
        // Source-defined iris colors and eyelid pixels precede every map. The
        // .75-pixel inner strip is a fixed visible lid/lash core, independent
        // of the candidate's radius, radial profile and destination feather.
        let contours=[anatomy.leftEyeSupport!.contour,anatomy.rightEyeSupport!.contour]
            .map { $0.map { SIMD2(Double($0.x)*Double(width),Double($0.y)*Double(height)) } }
        var bytes=[UInt8](repeating:255,count:width*height*4)
        var rimRegions=[[Int]](repeating:[],count:8)
        for y in 0..<height { for x in 0..<width {
            let side=x < width/2 ? 0:1,contour=contours[side]
            let p=SIMD2(Double(x)+0.5,Double(y)+0.5)
            let center=SIMD2((side == 0 ? 0.36:0.64)*Double(width),0.4*Double(height))
            let v=p-center,distance=hypot(v.x,v.y),angle=atan2(v.y,v.x)
            var inside=false,edgeDistance=Double.infinity
            for index in contour.indices {
                let a=contour[index],b=contour[(index+1)%contour.count],edge=b-a,q=p-a
                let t=max(0,min(1,(q.x*edge.x+q.y*edge.y)/(edge.x*edge.x+edge.y*edge.y)))
                let nearest=a+edge*t
                edgeDistance=min(edgeDistance,hypot(p.x-nearest.x,p.y-nearest.y))
                if (a.y > p.y) != (b.y > p.y),
                   p.x < (b.x-a.x)*(p.y-a.y)/(b.y-a.y)+a.x { inside.toggle() }
            }
            var red=198.0,green=168.0,blue=145.0
            if inside {
                let iris=max(0,min(1,Double(width)*0.016+0.5-distance))
                red=180-140*iris
                green=198+iris*(80+24*sin(13*angle+distance*0.8)-198)
                blue=210+iris*(100+20*cos(11*angle-distance)-210)
            }
            if edgeDistance <= 1.25 {
                // High-contrast texture makes subpixel lid leakage observable;
                // a flat rim could remain numerically unchanged when warped.
                red=80+28*Double((x+y)%2)
                green=60+30*Double(x%3);blue=140+24*Double(y%3)
            }
            let offset=(y*width+x)*4
            bytes[offset]=UInt8(red.rounded());bytes[offset+1]=UInt8(green.rounded())
            bytes[offset+2]=UInt8(blue.rounded())
            if inside && edgeDistance <= 0.75 {
                let sector=v.x < -Double(width)*0.07*0.85 ? 2
                    :v.x > Double(width)*0.07*0.85 ? 3:v.y < 0 ? 0:1
                rimRegions[side*4+sector].append(offset)
            }
        } }
        return (bytes,rimRegions)
    }

    private func denseIrisDiameter(_ bytes:[UInt8],_ width:Int,_ height:Int,side:Int) throws -> Double {
        // The source radius, central two rows, scan extent and red=110 edge
        // threshold stay fixed as strength changes; G/B hold the iris texture.
        let centerX=(side == 0 ? 0.36:0.64)*Double(width),centerY=Int(0.4*Double(height))
        let radius=Double(width)*0.016
        var diameter=0.0
        for y in [centerY-1,centerY] {
            var crossings=[Double](),previous:Double?
            for x in Int(floor(centerX-radius*1.8))...Int(ceil(centerX+radius*1.8)) {
                let value=Double(bytes[(y*width+x)*4])-110
                if let before=previous,(before < 0 && value >= 0)||(before >= 0 && value < 0) {
                    crossings.append(Double(x)-0.5+before/(before-value))
                }
                previous=value
            }
            XCTAssertEqual(crossings.count,2,"independent visible iris edge")
            diameter += try XCTUnwrap(crossings.last)-XCTUnwrap(crossings.first)
        }
        return diameter/2
    }

    func testElevenSignedFieldsHaveOppositeMonotoneActualPixelDirections() throws {
        // Markers are defined from source anatomy before the map exists.
        // Thresholds intentionally allow subpixel corner and iris adjustment.
        let cases:[(WritableKeyPath<BeautyEffectiveStrengths,Float>,Float,SIMD2<Double>,SIMD2<Double>)]=[
            (\.eyeSize,BeautySafetyCaps.eyeSize,SIMD2(0.41,0.40),SIMD2(1,0)),
            (\.eyeYPosition,BeautySafetyCaps.eyeYPosition,SIMD2(0.36,0.40),SIMD2(0,1)),
            (\.eyeHeight,BeautySafetyCaps.eyeHeight,SIMD2(0.36,0.376),SIMD2(0,-1)),
            (\.eyeLength,BeautySafetyCaps.eyeLength,SIMD2(0.415,0.40),SIMD2(1,0)),
            (\.eyeDistance,BeautySafetyCaps.eyeDistance,SIMD2(0.36,0.40),SIMD2(-1,0)),
            (\.pupilSize,BeautySafetyCaps.pupilSize,SIMD2(0.373,0.40),SIMD2(1,0)),
            (\.lowerEyelidDrop,BeautySafetyCaps.lowerEyelidDrop,SIMD2(0.325,0.42),SIMD2(0,1)),
            (\.eyeTailLift,BeautySafetyCaps.eyeTailLift,SIMD2(0.295,0.40),SIMD2(0,-1)),
            (\.eyeTilt,BeautySafetyCaps.eyeTilt,SIMD2(0.295,0.40),SIMD2(0,-1)),
            (\.innerCornerOpen,BeautySafetyCaps.innerCornerOpen,SIMD2(0.425,0.40),SIMD2(1,0)),
            (\.outerCornerOpen,BeautySafetyCaps.outerCornerOpen,SIMD2(0.295,0.40),SIMD2(-1,0))
        ]
        for (width,height) in [(320,400),(400,320)] {
            let anatomy=try face(width:width,height:height)
            for (key,cap,mark,direction) in cases {
                let source=raster(width,height,mark:mark),baseline=centroid(source,width,height)
                for sign:Float in [-1,1] {
                    var prior=0.0
                    for fraction:Float in [0.25,0.5,0.75,1] {
                        var s=BeautyEffectiveStrengths();s[keyPath:key]=cap*fraction*sign
                        let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:s),"\(key)")
                        let output=map.applyRGBA(source),delta=centroid(output,width,height)-baseline
                        let amplitude=(delta.x*direction.x+delta.y*direction.y)*Double(sign)
                        XCTAssertGreaterThan(amplitude,prior+0.012,"\(key) \(sign) \(fraction)")
                        prior=amplitude
                        XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
                        XCTAssertLessThanOrEqual(map.maximumDisplacement,Double(width)*0.14*0.15+0.0001)
                        if fraction == 1 {
                            XCTAssertGreaterThan(amplitude,0.12,"\(key)")
                            XCTAssertEqual(output,map.applyRGBA(source))
                        }
                    }
                }
            }
        }
    }

    func testMeasuredSparseGeometryAndDenseIrisAdmissionAreDistinct() throws {
        for dense in [false,true] {
            let anatomy=try face(dense:dense)
            for (key,cap) in zip(BeautyContinuousEyeMap.keys,BeautyContinuousEyeMap.caps) {
                var s=BeautyEffectiveStrengths();s[keyPath:key] = -cap
                let map=BeautyContinuousEyeMap(width:320,height:400,face:anatomy,strengths:s)
                if key == \.pupilSize && !dense { XCTAssertNil(map) }
                else { XCTAssertNotNil(map,"\(key)") }
            }
        }
    }

    func testLowerLidUsesObservedApertureRatherThanBiasedCornerLine() throws {
        // Independent asymmetric source contours put the lower outer aperture
        // close to the corner line while the upper lid is much farther away.
        // A gate divided by max(abs(top),abs(bottom)) almost erases this edit.
        for (width,height) in [(320,400),(400,320)] {
            let anatomy=try face(width:width,height:height,dense:false,
                                 upperScale:1.8,lowerScale:0.25)
            let marks=[SIMD2<Double>(0.325,0.4053125), // observed outer lower edge
                       SIMD2<Double>(0.36,0.4053125),  // central lower lid
                       SIMD2<Double>(0.325,0.36175)]   // upper outer edge
            let sources=marks.map { raster(width,height,mark:$0) }
            let before=sources.map { centroid($0,width,height) }
            for sign:Float in [-1,1] {
                var strengths=BeautyEffectiveStrengths()
                strengths.lowerEyelidDrop=BeautySafetyCaps.lowerEyelidDrop*sign
                let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                    face:anatomy,strengths:strengths))
                let delta=zip(sources,before).map { centroid(map.applyRGBA($0),width,height)-$1 }
                XCTAssertGreaterThan(delta[0].y*Double(sign),0.45,"visible outer lower-lid response")
                XCTAssertLessThan(abs(delta[0].x),0.08,"image-axis lower-lid direction")
                for (index,control) in delta.dropFirst().enumerated() {
                    XCTAssertLessThan(abs(control.x)+abs(control.y),0.10,
                        index == 0 ? "central lower-lid protection":"upper outer-lid protection")
                }
                XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
                XCTAssertLessThanOrEqual(map.maximumDisplacement,Double(width)*0.14*0.15+0.0001)
            }
        }
    }


    func testFirstFiveReferenceResponseOnIndependentAnalyticApertures() throws {
        // Reference endpoint increments were frozen before candidate output.
        // The independent source is an antialiased aperture, not a map output.
        for (width,height) in [(320,400),(400,320)] {
            let anatomy=try face(width:width,height:height,apertureAspect:0.29)
            let span=Double(width)*0.14,rx=span/2,ry=rx*0.29
            var source=[UInt8](repeating:255,count:width*height*4)
            for y in 0..<height { for x in 0..<width {
                let px=Double(x)+0.5,py=Double(y)+0.5
                let centerX=(x < width/2 ? 0.36:0.64)*Double(width)
                let rho=hypot((px-centerX)/rx,(py-Double(height)*0.4)/ry)
                let foreground=1/(1+exp((rho-1)*ry*3))
                let offset=(y*width+x)*4
                source[offset]=UInt8((180-140*foreground).rounded())
                source[offset+1]=UInt8(40+x*140/width)
                source[offset+2]=UInt8(40+y*140/height)
            } }
            func edges(_ bytes:[UInt8],side:Int,horizontal:Bool) throws -> (Double,Double) {
                let centerX=Int((side == 0 ? 0.36:0.64)*Double(width))
                let centerY=Int(Double(height)*0.4)
                let limit=horizontal ? width:height
                var crossings=[Double]()
                var previous:Double?
                for position in 0..<limit {
                    let x=horizontal ? position:centerX,y=horizontal ? centerY:position
                    if horizontal && ((side == 0 && x >= width/2)||(side == 1 && x < width/2)) { continue }
                    let value=Double(bytes[(y*width+x)*4])-110
                    if let before=previous,(before < 0 && value >= 0)||(before >= 0 && value < 0) {
                        crossings.append(Double(position)-0.5+before/(before-value))
                    }
                    previous=value
                }
                XCTAssertEqual(crossings.count,2)
                return (try XCTUnwrap(crossings.first),try XCTUnwrap(crossings.last))
            }
            let fields:[(WritableKeyPath<BeautyEffectiveStrengths,Float>,Float,Double,Bool)]=[
                (\.eyeSize,BeautySafetyCaps.eyeSize,0.12658733188005067,true),
                (\.eyeHeight,BeautySafetyCaps.eyeHeight,0.11865411607639502,false),
                (\.eyeLength,BeautySafetyCaps.eyeLength,0.13323048900743945,true)
            ]
            for (key,cap,target,horizontal) in fields {
                var lo=BeautyEffectiveStrengths(),hi=BeautyEffectiveStrengths()
                lo[keyPath:key] = -cap;hi[keyPath:key]=cap
                let left=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:lo))
                let right=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:hi))
                let low=left.applyRGBA(source),high=right.applyRGBA(source)
                for side in 0..<2 {
                    let a=try edges(low,side:side,horizontal:horizontal)
                    let b=try edges(high,side:side,horizontal:horizontal)
                    let delta=(b.1-b.0)-(a.1-a.0)
                    XCTAssertEqual(delta,target*span,accuracy:max(1,target*span*0.10),"source-derived aperture response \(key)")
                    if key == \.eyeSize {
                        let va=try edges(low,side:side,horizontal:false)
                        let vb=try edges(high,side:side,horizontal:false)
                        XCTAssertEqual((vb.1-vb.0)-(va.1-va.0),0.03864618661029121*span,
                            accuracy:max(1,0.03864618661029121*span*0.10))
                    }
                }
                XCTAssertLessThanOrEqual(left.maximumGradient,0.450001)
                XCTAssertLessThanOrEqual(right.maximumDisplacement,span*0.15+0.0001)
            }
            for (key,cap,direction,target) in [
                (\BeautyEffectiveStrengths.eyeYPosition,BeautySafetyCaps.eyeYPosition,SIMD2<Double>(0,1),0.12058939729657835),
                (\BeautyEffectiveStrengths.eyeDistance,BeautySafetyCaps.eyeDistance,SIMD2<Double>(-1,0),0.3312674593686824/2)
            ] {
                let marks=raster(width,height,mark:SIMD2(0.36,0.4))
                var lo=BeautyEffectiveStrengths(),hi=BeautyEffectiveStrengths()
                lo[keyPath:key] = -cap;hi[keyPath:key]=cap
                let a=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:lo)).applyRGBA(marks)
                let b=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:hi)).applyRGBA(marks)
                let delta=centroid(b,width,height)-centroid(a,width,height)
                let response=delta.x*direction.x+delta.y*direction.y
                XCTAssertEqual(response,target*span,accuracy:max(1,target*span*0.10),"translation response \(key)")
            }
        }
    }

    func testVisibleRGBEyeBoundaryKeepsLengthCenteredAndPositionScaleRegistered() throws {
        let width=480,height=400,span=Double(width)*0.14
        let anatomy=try face(width:width,height:height,apertureAspect:0.29)
        let visibleWidth=span*1.15,rx=visibleWidth/2,ry=rx*0.29
        var source=[UInt8](repeating:255,count:width*height*4)
        for y in 0..<height { for x in 0..<width {
            let side=x < width/2 ? -1.0:1.0
            let centerX=(side < 0 ? 0.36:0.64)*Double(width)+side*span*0.08
            let rho=hypot((Double(x)+0.5-centerX)/rx,(Double(y)+0.5-Double(height)*0.4)/ry)
            let foreground=1/(1+exp((rho-1)*ry*3)),i=(y*width+x)*4
            source[i]=UInt8((190-145*foreground).rounded())
            source[i+1]=UInt8((150-120*foreground).rounded())
            source[i+2]=UInt8((120-95*foreground).rounded())
        } }
        func center(_ bytes:[UInt8],side:Int) -> SIMD2<Double> {
            var mass=0.0,moment=SIMD2<Double>.zero
            for y in 0..<height { for x in (side == 0 ? 0:width/2)..<(side == 0 ? width/2:width) {
                let weight=Double(max(0,160-Int(bytes[(y*width+x)*4])))
                mass += weight;moment += SIMD2(Double(x)+0.5,Double(y)+0.5)*weight
            } }
            return moment/mass
        }
        for (key,cap) in [(\BeautyEffectiveStrengths.eyeSize,BeautySafetyCaps.eyeSize),
                          (\BeautyEffectiveStrengths.eyeLength,BeautySafetyCaps.eyeLength),
                          (\BeautyEffectiveStrengths.eyeYPosition,BeautySafetyCaps.eyeYPosition),
                          (\BeautyEffectiveStrengths.eyeDistance,BeautySafetyCaps.eyeDistance)] {
            var outputs=[[UInt8]]()
            for sign:Float in [-1,1] {
                var s=BeautyEffectiveStrengths();s[keyPath:key]=cap*sign
                let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                    face:anatomy,strengths:s,sourceRGBA:source))
                outputs.append(map.applyRGBA(source))
                XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
                XCTAssertLessThanOrEqual(map.maximumDisplacement,span*0.15+0.0001)
            }
            let deltas=(0..<2).map { center(outputs[1],side:$0)-center(outputs[0],side:$0) }
            if key == \.eyeLength || key == \.eyeSize {
                    for d in deltas { XCTAssertLessThan(hypot(d.x,d.y),0.5,"visible aperture scale pivot") }
            } else if key == \.eyeYPosition {
                for d in deltas {
                    XCTAssertEqual(d.y,0.12058939729657835*visibleWidth,accuracy:visibleWidth*0.12058939729657835*0.10)
                    XCTAssertLessThan(abs(d.x),0.08)
                }
            } else {
                XCTAssertEqual(deltas[1].x-deltas[0].x,0.3312674593686824*visibleWidth,
                    accuracy:visibleWidth*0.3312674593686824*0.10)
                for d in deltas { XCTAssertLessThan(abs(d.y),0.08) }
            }
        }
        // A single-channel marker is not evidence of an RGB aperture. Neither
        // it nor a transparent raster may change the source geometric frame.
        let marker=raster(width,height,mark:SIMD2(0.36,0.4))
        var transparent=source
        for i in stride(from:3,to:transparent.count,by:4) { transparent[i]=127 }
        // Three shifted dark bands have individually plausible widths but no
        // coherent pair of eye edges. Their union must not enlarge the frame.
        var ambiguous=[UInt8](repeating:255,count:width*height*4)
        for i in stride(from:0,to:ambiguous.count,by:4) {
            ambiguous[i]=190;ambiguous[i+1]=150;ambiguous[i+2]=120
        }
        for cx in [0.36,0.64] {
            for (row,bounds) in [(-2,(-0.615,0.215)),(0,(-0.415,0.415)),(2,(-0.215,0.615))] {
                let y=Int((Double(height)*0.4+Double(row)*span*0.29*0.1).rounded())
                let x0=Int((cx*Double(width)+bounds.0*span).rounded())
                let x1=Int((cx*Double(width)+bounds.1*span).rounded())
                for x in x0...x1 {
                    let i=(y*width+x)*4;ambiguous[i]=45;ambiguous[i+1]=30;ambiguous[i+2]=25
                }
            }
        }
        var s=BeautyEffectiveStrengths();s.eyeLength=BeautySafetyCaps.eyeLength
        s.eyeYPosition=BeautySafetyCaps.eyeYPosition
        for input in [marker,transparent,ambiguous] {
            let geometry=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:s))
            let guarded=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:s,sourceRGBA:input))
            XCTAssertEqual(geometry.applyRGBA(input),guarded.applyRGBA(input))
            var lower=BeautyEffectiveStrengths()
            lower.lowerEyelidDrop=BeautySafetyCaps.lowerEyelidDrop
            let lowerGeometry=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                face:anatomy,strengths:lower))
            let lowerGuarded=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                face:anatomy,strengths:lower,sourceRGBA:input))
            XCTAssertEqual(lowerGeometry.applyRGBA(input),lowerGuarded.applyRGBA(input),
                "one-channel, transparent and ambiguous source cannot narrow the lower-lid protection rim")
            var corner=BeautyEffectiveStrengths()
            corner.outerCornerOpen=BeautySafetyCaps.outerCornerOpen
            let cornerGeometry=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                face:anatomy,strengths:corner))
            let cornerGuarded=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                face:anatomy,strengths:corner,sourceRGBA:input))
            XCTAssertEqual(cornerGeometry.applyRGBA(input),cornerGuarded.applyRGBA(input),
                "local corner registration requires coherent opaque RGB evidence")
        }
    }

    func testAdjacentRGBRowsKeepLocalFrameDespiteWiderInconsistentRows() throws {
        let width=320,height=400,span=44.8
        let anatomy=try face(width:width,height:height,dense:false,apertureAspect:0.29)
        var coherent=[UInt8](repeating:255,count:width*height*4)
        for i in stride(from:0,to:coherent.count,by:4) {
            coherent[i]=190;coherent[i+1]=150;coherent[i+2]=120
        }
        func addRow(_ row:Int,_ bounds:(Int,Int),to bytes:inout [UInt8]) {
            let y=Int((Double(height)*0.4+Double(row)*span*0.29*0.1).rounded())
            for cx in [0.36,0.64] {
                let center=Int((cx*Double(width)).rounded())
                for x in center+bounds.0...center+bounds.1 {
                    let i=(y*width+x)*4;bytes[i]=45;bytes[i+1]=30;bytes[i+2]=25
                }
            }
        }
        var gapped=coherent
        for row in [-3,0,3] { addRow(row,(-31,16),to:&gapped) }
        for row in 0...2 { addRow(row,(-31,16),to:&coherent) }
        var inconsistent=coherent
        addRow(-3,(-31,22),to:&inconsistent)
        addRow(-1,(-21,32),to:&inconsistent)
        // Both rasters have the same three adjacent source eye edges. The two
        // wider rows disagree with each other and must not cancel that frame.
        // Track an independent marker through each source-conditioned field.
        let marker=raster(width,height,mark:SIMD2(0.263125,0.415))
        for (key,cap) in [(\BeautyEffectiveStrengths.lowerEyelidDrop,BeautySafetyCaps.lowerEyelidDrop),
                          (\BeautyEffectiveStrengths.outerCornerOpen,BeautySafetyCaps.outerCornerOpen)] {
            for sign:Float in [-1,1] {
                var s=BeautyEffectiveStrengths();s[keyPath:key]=cap*sign
                let baseline=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                    face:anatomy,strengths:s,sourceRGBA:coherent))
                let guarded=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                    face:anatomy,strengths:s,sourceRGBA:inconsistent))
                let sampled=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                    face:anatomy,strengths:s,sourceRGBA:gapped))
                XCTAssertEqual(baseline.applyRGBA(marker),guarded.applyRGBA(marker))
                XCTAssertEqual(baseline.applyRGBA(marker),sampled.applyRGBA(marker),
                    "three agreeing source boundaries remain evidence when sampled rows have gaps")
                XCTAssertLessThanOrEqual(guarded.maximumGradient,0.450001)
                XCTAssertLessThanOrEqual(guarded.maximumDisplacement,span*0.15+0.0001)
            }
        }
        // This visible lower-lid witness lies within the registered aperture
        // but beyond the old geometric outer cutoff. A mixed-frame lobe would
        // erase its response even though the coherent source edge is admitted.
        let lowerMarker=raster(width,height,mark:SIMD2(0.281875,0.415))
        let lowerBefore=centroid(lowerMarker,width,height)
        for sign:Float in [-1,1] {
            var lower=BeautyEffectiveStrengths()
            lower.lowerEyelidDrop=BeautySafetyCaps.lowerEyelidDrop*sign
            let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                face:anatomy,strengths:lower,sourceRGBA:inconsistent))
            let delta=centroid(map.applyRGBA(lowerMarker),width,height)-lowerBefore
            XCTAssertGreaterThan(delta.y*Double(sign),0.20,
                "the upper, central and outer zero boundaries must share the admitted source frame")
            XCTAssertLessThan(abs(delta.x),0.08)
            XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
        }
    }

    func testSpacingRejectsReversedAndOverlappingPairsWhileKeepingIndependentEyeFields() throws {
        let base=try face(),source=raster(320,400,mark:SIMD2(0.36,0.40))
        func moved(_ support:BeautyEyeSemanticSupport,dx:Float) -> BeautyEyeSemanticSupport {
            func shift(_ p:SIMD2<Float>) -> SIMD2<Float> { p+SIMD2(dx,0) }
            return BeautyEyeSemanticSupport(side:support.side,contour:support.contour.map(shift),
                upper:support.upper.map(shift),lower:support.lower.map(shift),
                inner:support.inner.map(shift),outer:support.outer.map(shift),corners:support.corners.map(shift),
                center:shift(support.center),pupil:support.pupil.map(shift),span:support.span,tilt:support.tilt)
        }
        for shift:Float in [0.28,0.12] {
            let left=moved(try XCTUnwrap(base.leftEyeSupport),dx:shift)
            let right=moved(try XCTUnwrap(base.rightEyeSupport),dx:-shift)
            let anatomy=FaceGeometry(bounds:base.bounds,faceContour:base.faceContour,
                leftEye:left.contour,rightEye:right.contour,nose:base.nose,outerLips:base.outerLips,
                leftEyeSupport:left,rightEyeSupport:right,
                observedEyebrowSupport:base.observedEyebrowSupport,denseSupport:base.denseSupport)
            var spacing=BeautyEffectiveStrengths();spacing.eyeDistance=BeautySafetyCaps.eyeDistance
            XCTAssertNil(BeautyContinuousEyeMap(width:320,height:400,face:anatomy,strengths:spacing))
            var size=BeautyEffectiveStrengths();size.eyeSize=BeautySafetyCaps.eyeSize
            let independent=try XCTUnwrap(BeautyContinuousEyeMap(width:320,height:400,face:anatomy,strengths:size))
            size.eyeDistance=BeautySafetyCaps.eyeDistance
            let combined=try XCTUnwrap(BeautyContinuousEyeMap(width:320,height:400,face:anatomy,strengths:size))
            XCTAssertEqual(independent.applyRGBA(source),combined.applyRGBA(source))
        }
    }

    func testDenseIrisDiskAreaChangesBothWaysWithoutEditingOutsideAperture() throws {
        let width=320,height=400,anatomy=try face()
        var source=[UInt8](repeating:180,count:width*height*4)
        for y in 0..<height { for x in 0..<width {
            let i=(y*width+x)*4
            let distance=hypot(Double(x)+0.5-0.36*Double(width),Double(y)+0.5-0.4*Double(height))
            source[i]=distance < Double(width)*0.016 ? 40:180
            source[i+1]=UInt8(x*150/width);source[i+2]=UInt8(y*150/height);source[i+3]=255
        } }
        func mass(_ bytes:[UInt8]) -> Double {
            stride(from:0,to:bytes.count,by:4).reduce(0) { $0+Double(max(0,180-Int(bytes[$1]))) }
        }
        let baseline=mass(source)
        for sign:Float in [-1,1] {
            var s=BeautyEffectiveStrengths();s.pupilSize=sign*BeautySafetyCaps.pupilSize
            let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:s))
            let output=map.applyRGBA(source)
            XCTAssertGreaterThan((mass(output)-baseline)*Double(sign),baseline*0.08)
            let contours=[anatomy.leftEyeSupport!.contour,anatomy.rightEyeSupport!.contour]
            var outsideChanges=0
            for y in 0..<height { for x in 0..<width {
                let p=SIMD2<Float>((Float(x)+0.5)/Float(width),(Float(y)+0.5)/Float(height))
                if !contours.contains(where: { BeautyDenseFaceSupport.contains(p,in:$0) }) {
                    let i=(y*width+x)*4
                    for c in 0..<4 { outsideChanges += abs(Int(source[i+c])-Int(output[i+c])) }
                }
            } }
            XCTAssertEqual(outsideChanges,0)
        }
    }

    func testDenseIrisTextureHasFourSignedDiameterStepsAndSourceExactLidCornerRim() throws {
        let width=480,height=400
        let anatomy=try face(width:width,height:height,apertureAspect:0.29)
        let fixture=denseIrisTexture(width,height,anatomy:anatomy),source=fixture.bytes
        let baseline=try (0..<2).map { try denseIrisDiameter(source,width,height,side:$0) }
        for region in fixture.rimRegions { XCTAssertFalse(region.isEmpty,"upper/lower lid and both corners") }
        for sign:Float in [-1,1] {
            var prior=[Double](repeating:0,count:2)
            for fraction:Float in [0.25,0.5,0.75,1] {
                var strengths=BeautyEffectiveStrengths();strengths.pupilSize=sign*fraction*BeautySafetyCaps.pupilSize
                let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:strengths))
                let output=map.applyRGBA(source)
                for side in 0..<2 {
                    let excursion=(try denseIrisDiameter(output,width,height,side:side)-baseline[side])*Double(sign)
                    XCTAssertGreaterThan(excursion,prior[side]+0.10,"iris \(side), signed quarter \(sign*fraction)")
                    if fraction == 1 { XCTAssertGreaterThan(excursion,baseline[side]*0.08) }
                    prior[side]=excursion
                }
                var rimDelta=0
                for region in fixture.rimRegions { for offset in region { for channel in 0..<4 {
                    rimDelta += abs(Int(output[offset+channel])-Int(source[offset+channel]))
                } } }
                XCTAssertEqual(rimDelta,0,"source-fixed inner lid/lash and corner RGBA, \(sign*fraction)")
                XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
                XCTAssertLessThanOrEqual(map.maximumDisplacement,Double(width)*0.14*0.15+0.0001)
            }
        }
    }

    func testCollapsedDenseIrisRingAbstainsWithoutBorrowingSparsePupilEvidence() throws {
        let width=480,height=400
        let valid=try face(width:width,height:height,apertureAspect:0.29)
        let source=denseIrisTexture(width,height,anatomy:valid).bytes
        let anatomy=try face(width:width,height:height,collapsedLeftIris:true,apertureAspect:0.29)
        XCTAssertNotNil(anatomy.denseSupport,"a rejected dense ring must not become sparse support")
        let baseline=try denseIrisDiameter(source,width,height,side:1)
        for sign:Float in [-1,1] {
            var strengths=BeautyEffectiveStrengths();strengths.pupilSize=sign*BeautySafetyCaps.pupilSize
            let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:strengths))
            let output=map.applyRGBA(source)
            let excursion=(try denseIrisDiameter(output,width,height,side:1)-baseline)*Double(sign)
            XCTAssertGreaterThan(excursion,baseline*0.08,"valid peer iris keeps its signed response")
            var invalidPeerDelta=0
            for y in 0..<height { for x in 0..<width/2 { for channel in 0..<4 {
                let offset=(y*width+x)*4+channel
                invalidPeerDelta += abs(Int(output[offset])-Int(source[offset]))
            } } }
            XCTAssertEqual(invalidPeerDelta,0,"invalid dense iris is source-exact despite a valid pupil center")
        }
    }

    func testDenseIrisSourceStencilIsInvariantToUnknownApertureExterior() throws {
        let width=480,height=400
        // This source-generated shallow aperture occludes the vertical ring
        // points while retaining valid horizontal iris evidence on both eyes.
        let anatomy=try face(width:width,height:height,apertureAspect:0.23)
        let source=denseIrisTexture(width,height,anatomy:anatomy).bytes
        var perturbed=source,interior=[[Int]](repeating:[],count:2)
        var irisCore=[[Int]](repeating:[],count:2)
        let contours=[anatomy.leftEyeSupport!.contour,anatomy.rightEyeSupport!.contour]
            .map { $0.map { SIMD2(Double($0.x)*Double(width),Double($0.y)*Double(height)) } }
        for y in 0..<height { for x in 0..<width {
            let side=x < width/2 ? 0:1,contour=contours[side]
            let p=SIMD2(Double(x)+0.5,Double(y)+0.5)
            // Independent source-polygon ownership, not a displacement or
            // production gate formula, defines the equality oracle.
            var inside=false
            for index in contour.indices {
                let a=contour[index],b=contour[(index+1)%contour.count]
                if (a.y > p.y) != (b.y > p.y),
                   p.x < (b.x-a.x)*(p.y-a.y)/(b.y-a.y)+a.x { inside.toggle() }
            }
            let offset=(y*width+x)*4
            if inside {
                interior[side].append(offset)
                let centerX=(side == 0 ? 0.36:0.64)*Double(width)
                if abs(p.x-centerX) <= Double(width)*0.012,abs(p.y-Double(height)*0.4) <= 2 {
                    irisCore[side].append(offset)
                }
            } else {
                let bright=(x+y)%2 == 0
                perturbed[offset]=bright ? 255:0
                perturbed[offset+1]=x%3 == 0 ? 0:255
                perturbed[offset+2]=bright ? 0:255
                perturbed[offset+3]=bright ? 0:97
            }
        } }
        XCTAssertNotEqual(perturbed,source)
        for side in 0..<2 {
            XCTAssertFalse(interior[side].isEmpty);XCTAssertFalse(irisCore[side].isEmpty)
            var inputDelta=0
            for offset in interior[side] { for channel in 0..<4 {
                inputDelta += abs(Int(source[offset+channel])-Int(perturbed[offset+channel]))
            } }
            XCTAssertEqual(inputDelta,0,"identical owned source RGBA")
        }
        for sign:Float in [-1,1] { for fraction:Float in [0.25,0.5,0.75,1] {
            var strengths=BeautyEffectiveStrengths();strengths.pupilSize=sign*fraction*BeautySafetyCaps.pupilSize
            let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:strengths))
            // Reuse one fixed geometry/map so only unknown exterior material
            // differs, including at source stencils and occlusion projections.
            let baseline=map.applyRGBA(source),variant=map.applyRGBA(perturbed)
            for side in 0..<2 {
                var ownershipDelta=0,irisDelta=0
                for offset in interior[side] { for channel in 0..<4 {
                    ownershipDelta += abs(Int(baseline[offset+channel])-Int(variant[offset+channel]))
                } }
                for offset in irisCore[side] { for channel in 0..<3 {
                    irisDelta += abs(Int(baseline[offset+channel])-Int(source[offset+channel]))
                } }
                XCTAssertEqual(ownershipDelta,0,"eye \(side), signed quarter \(sign*fraction) source ownership")
                XCTAssertGreaterThan(irisDelta,0,"eye \(side), signed quarter \(sign*fraction) must edit iris texture")
            }
        } }
    }

    func testSparsePositivePupilHasFourVisibleStepsAndSourceExactApertureExterior() throws {
        for (width,height) in [(320,400),(400,320)] {
            let anatomy=try face(width:width,height:height,dense:false)
            let source=raster(width,height,mark:SIMD2(0.373,0.40)),position=centroid(source,width,height)
            var prior=0.0
            for fraction:Float in [0.25,0.5,0.75,1] {
                var strengths=BeautyEffectiveStrengths();strengths.pupilSize=BeautySafetyCaps.pupilSize*fraction
                let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:strengths))
                let output=map.applyRGBA(source),delta=centroid(output,width,height)-position
                XCTAssertGreaterThan(delta.x,prior+0.012,"sparse \(width)x\(height) \(fraction)")
                prior=delta.x
                if fraction == 1 { XCTAssertGreaterThan(delta.x,0.12) }
                XCTAssertEqual(output,map.applyRGBA(source))
                XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
                var protectedDelta=0,alphaDelta=0
                for y in 0..<height { for x in 0..<width {
                    // The source's eye apertures are analytic ellipses fixed
                    // before the provider or map is evaluated. Brows, eyelids,
                    // nose, lips and exterior all lie outside this envelope.
                    let nx=(Double(x)+0.5)/Double(width),ny=(Double(y)+0.5)/Double(height)
                    let left=pow((nx-0.36)/0.07,2)+pow((ny-0.40)/0.025,2) < 1
                    let right=pow((nx-0.64)/0.07,2)+pow((ny-0.40)/0.025,2) < 1
                    let i=(y*width+x)*4
                    if !left && !right {
                        for c in 0..<3 { protectedDelta += abs(Int(source[i+c])-Int(output[i+c])) }
                    }
                    alphaDelta += abs(Int(source[i+3])-Int(output[i+3]))
                } }
                XCTAssertEqual(protectedDelta,0);XCTAssertEqual(alphaDelta,0)
                let stage=BeautyStillImageGeometryStage(sourceRGBA:source,width:width,height:height,
                    plan:BeautyEffectPlan(activeDomains:[.eyes],effectiveStrengths:strengths),face:anatomy)
                XCTAssertTrue(stage.controlPoints.isEmpty,"measured sparse iris must not emit whole-image pulls")
                XCTAssertEqual(stage.applyingContinuousContour(to:source),output)
            }
        }
    }

    func testSparsePupilDoesNotBorrowMissingInvalidOrNegativeEvidence() throws {
        let width=320,height=400
        var source=raster(width,height,mark:SIMD2(0.373,0.40))
        for y in 0..<height { for x in 0..<width where x%13 == 0 { source[(y*width+x)*4+3]=100 } }
        var strengths=BeautyEffectiveStrengths();strengths.pupilSize=BeautySafetyCaps.pupilSize
        for anatomy in [try face(dense:false,missingLeftPupil:true),
                        try face(dense:false,misplacedLeftPupil:true),
                        try face(dense:false,malformedLeft:true)] {
            let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:strengths))
            let output=map.applyRGBA(source)
            XCTAssertNotEqual(output,source,"the independently valid right pupil remains editable")
            var leftDelta=0,alphaDelta=0
            for y in 0..<height { for x in 0..<width {
                let i=(y*width+x)*4
                if x < width/2 { for c in 0..<3 { leftDelta += abs(Int(source[i+c])-Int(output[i+c])) } }
                alphaDelta += abs(Int(source[i+3])-Int(output[i+3]))
            } }
            XCTAssertEqual(leftDelta,0);XCTAssertEqual(alphaDelta,0)
        }
        strengths.pupilSize = -BeautySafetyCaps.pupilSize
        let sparse=try face(dense:false)
        XCTAssertNil(BeautyContinuousEyeMap(width:width,height:height,face:sparse,strengths:strengths))
        let stage=BeautyStillImageGeometryStage(sourceRGBA:source,width:width,height:height,
            plan:BeautyEffectPlan(activeDomains:[.eyes],effectiveStrengths:strengths),face:sparse)
        XCTAssertTrue(stage.controlPoints.isEmpty)
        XCTAssertEqual(stage.applyingContinuousContour(to:source),source)
    }

    func testSparsePupilCompatibilityStaysContinuousThroughSiblingAndPupilZero() throws {
        let width=320,height=400,anatomy=try face(dense:false)
        let source=raster(width,height,mark:SIMD2(0.373,0.40))
        func pixels(_ strengths:BeautyEffectiveStrengths) throws -> [UInt8] {
            try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:strengths)).applyRGBA(source)
        }
        func changes(_ a:[UInt8],_ b:[UInt8]) -> Int {
            var count = 0
            for i in stride(from: 0, to: a.count, by: 4) {
                let redChanged: Bool = a[i] != b[i]
                let greenChanged: Bool = a[i + 1] != b[i + 1]
                let blueChanged: Bool = a[i + 2] != b[i + 2]
                if redChanged || greenChanged || blueChanged { count += 1 }
            }
            return count
        }
        var strengths=BeautyEffectiveStrengths();strengths.pupilSize=BeautySafetyCaps.pupilSize
        let pupilOnly=try pixels(strengths)
        for sign:Float in [-1,1] {
            strengths.eyeHeight=BeautySafetyCaps.eyeHeight*sign*0.0001
            XCTAssertLessThan(changes(pupilOnly,try pixels(strengths)),32)
        }
        strengths.pupilSize=0;strengths.eyeSize=BeautySafetyCaps.eyeSize;strengths.eyeHeight=0
        let shapeOnly=try pixels(strengths)
        for sign:Float in [-1,1] {
            strengths.pupilSize=BeautySafetyCaps.pupilSize*sign*0.0001
            XCTAssertLessThan(changes(shapeOnly,try pixels(strengths)),32)
        }
        strengths.pupilSize=BeautySafetyCaps.pupilSize
        let combined=try pixels(strengths)
        XCTAssertNotEqual(combined,pupilOnly);XCTAssertNotEqual(combined,shapeOnly)
        var protectedDelta=0
        for y in 0..<height { for x in 0..<width {
            let nx=(Double(x)+0.5)/Double(width),ny=(Double(y)+0.5)/Double(height),i=(y*width+x)*4
            let brow=(0.28...0.44).contains(nx)&&(0.32...0.335).contains(ny)
                || (0.56...0.72).contains(nx)&&(0.32...0.335).contains(ny)
            let nose=(0.48...0.52).contains(nx)&&(0.40...0.54).contains(ny)
            let lips=(0.43...0.57).contains(nx)&&(0.61...0.65).contains(ny)
            let exterior=ny < 0.25 || ny > 0.56 || nx > 0.88
            if brow || nose || lips || exterior { for c in 0..<4 {
                protectedDelta += abs(Int(source[i+c])-Int(combined[i+c]))
            } }
        } }
        XCTAssertEqual(protectedDelta,0)
    }

    func testAddingAnInfinitesimalSecondFieldDoesNotRescaleExistingPixels() throws {
        let width=400,height=320,anatomy=try face(width:width,height:height)
        let source=raster(width,height,mark:SIMD2(0.41,0.40))
        let pairs:[(WritableKeyPath<BeautyEffectiveStrengths,Float>,Float,WritableKeyPath<BeautyEffectiveStrengths,Float>,Float)]=[
            (\.eyeSize,BeautySafetyCaps.eyeSize,\.lowerEyelidDrop,BeautySafetyCaps.lowerEyelidDrop),
            (\.eyeSize,BeautySafetyCaps.eyeSize,\.eyeYPosition,BeautySafetyCaps.eyeYPosition),
            (\.eyeDistance,BeautySafetyCaps.eyeDistance,\.eyeYPosition,BeautySafetyCaps.eyeYPosition)
        ]
        for (baseKey,baseCap,addedKey,addedCap) in pairs {
            var strengths=BeautyEffectiveStrengths();strengths[keyPath:baseKey]=baseCap
            let baseline=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:strengths))
                .applyRGBA(source)
            let position=centroid(baseline,width,height)
            for sign:Float in [-1,1] {
                strengths[keyPath:addedKey]=addedCap*sign*0.0001
                let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:strengths))
                let output=map.applyRGBA(source),delta=centroid(output,width,height)-position
                XCTAssertLessThan(hypot(delta.x,delta.y),0.01,"\(baseKey) + epsilon \(addedKey) sign \(sign)")
                var changedPixels = 0
                for offset in stride(from: 0, to: source.count, by: 4) {
                    let redChanged = baseline[offset] != output[offset]
                    let greenChanged = baseline[offset + 1] != output[offset + 1]
                    let blueChanged = baseline[offset + 2] != output[offset + 2]
                    if redChanged || greenChanged || blueChanged { changedPixels += 1 }
                }
                XCTAssertLessThan(changedPixels,32,"cross-zero must be continuous after RGBA8 rounding")
                XCTAssertLessThanOrEqual(map.maximumGradient,0.450001)
            }
        }
    }

    func testInfinitesimalShapeFieldDoesNotDisableIrisApertureProtection() throws {
        let width=320,height=400,anatomy=try face()
        let source=raster(width,height,mark:SIMD2(0.373,0.4))
        var strengths=BeautyEffectiveStrengths();strengths.pupilSize=BeautySafetyCaps.pupilSize
        let baseline=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:strengths))
            .applyRGBA(source)
        for sign:Float in [-1,1] {
            strengths.eyeHeight=BeautySafetyCaps.eyeHeight*sign*0.0001
            let output=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:strengths))
                .applyRGBA(source)
            var changedPixels = 0
            for offset in stride(from: 0, to: source.count, by: 4) {
                let redChanged = baseline[offset] != output[offset]
                let greenChanged = baseline[offset + 1] != output[offset + 1]
                let blueChanged = baseline[offset + 2] != output[offset + 2]
                if redChanged || greenChanged || blueChanged { changedPixels += 1 }
            }
            XCTAssertLessThan(changedPixels,32,"epsilon must not turn off the iris aperture guard")
        }
    }

    func testProtectedFeaturesAlphaExteriorAndInvalidPeerRemainSourceExact() throws {
        let width=320,height=400,anatomy=try face(malformedLeft:true)
        var s=BeautyEffectiveStrengths()
        for (key,cap) in zip(BeautyContinuousEyeMap.keys,BeautyContinuousEyeMap.caps) { s[keyPath:key]=cap }
        var source=raster(width,height,mark:SIMD2(0.68,0.40))
        // Alpha discontinuity crossing the editable eye remains unchanged.
        for y in 0..<height { for x in 0..<width where x%13 == 0 { source[(y*width+x)*4+3]=100 } }
        let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:anatomy,strengths:s))
        let output=map.applyRGBA(source)
        XCTAssertNotEqual(output,source)
        var protectedDelta=0,alphaDelta=0
        for y in 0..<height { for x in 0..<width {
            let nx=(Double(x)+0.5)/Double(width),ny=(Double(y)+0.5)/Double(height),i=(y*width+x)*4
            let invalidPeer=nx < 0.45
            let brow=(0.56...0.72).contains(nx)&&(0.32...0.335).contains(ny)
            let nose=(0.48...0.52).contains(nx)&&(0.40...0.54).contains(ny)
            let mouth=(0.43...0.57).contains(nx)&&(0.61...0.65).contains(ny)
            let exterior=ny < 0.25 || ny > 0.56 || nx > 0.88
            if invalidPeer || brow || nose || mouth || exterior {
                for c in 0..<3 { protectedDelta += abs(Int(source[i+c])-Int(output[i+c])) }
            }
            alphaDelta += abs(Int(source[i+3])-Int(output[i+3]))
        } }
        XCTAssertEqual(protectedDelta,0);XCTAssertEqual(alphaDelta,0)
        XCTAssertEqual(map.applyRGBA([1,2,3]),[1,2,3])
        var dumpText="";dump(map,to:&dumpText)
        XCTAssertFalse(dumpText.contains("offsets"));XCTAssertFalse(dumpText.contains("SIMD2"))
    }

    func testNeutralStaleMalformedAndNonfiniteAbstainAndRecover() throws {
        let anatomy=try face(),source=raster(320,400,mark:SIMD2(0.36,0.4))
        XCTAssertNil(BeautyContinuousEyeMap(width:320,height:400,face:anatomy,strengths:BeautyEffectiveStrengths()))
        var s=BeautyEffectiveStrengths();s.eyeSize=BeautySafetyCaps.eyeSize
        XCTAssertNil(BeautyContinuousEyeMap(width:320,height:400,face:try face(freshness:.stale),strengths:s))
        var invalid=s;invalid.eyeSize = .nan
        XCTAssertNil(BeautyContinuousEyeMap(width:320,height:400,face:anatomy,strengths:invalid))
        XCTAssertNil(BeautyContinuousEyeMap(width:0,height:400,face:anatomy,strengths:s))
        let map=try XCTUnwrap(BeautyContinuousEyeMap(width:320,height:400,face:anatomy,strengths:s))
        let output=map.applyRGBA(source)
        XCTAssertNotEqual(output,source)
        XCTAssertEqual(output,try XCTUnwrap(BeautyContinuousEyeMap(width:320,height:400,face:anatomy,strengths:s)).applyRGBA(source))
    }

    func testStageSuppressesObservedPointProxiesAndPreservesLegacyAndSiblingRoutes() throws {
        let source=raster(320,400,mark:SIMD2(0.36,0.4)),anatomy=try face()
        var s=BeautyEffectiveStrengths();s.eyeSize = -BeautySafetyCaps.eyeSize
        let plan=BeautyEffectPlan(activeDomains:[.eyes],effectiveStrengths:s)
        let stage=BeautyStillImageGeometryStage(sourceRGBA:source,width:320,height:400,plan:plan,face:anatomy)
        XCTAssertTrue(stage.controlPoints.isEmpty)
        XCTAssertNotEqual(stage.applyingContinuousContour(to:source),source)
        let direct=try XCTUnwrap(BeautyContinuousEyeMap(width:320,height:400,face:anatomy,strengths:s))
        XCTAssertEqual(stage.applyingContinuousContour(to:source),direct.applyRGBA(source))
        let coarse=FaceGeometry(bounds:anatomy.bounds,faceContour:[],leftEye:anatomy.leftEye,rightEye:anatomy.rightEye)
        XCTAssertFalse(BeautyContinuousEyeMap.replacesLegacy(for:coarse))
        XCTAssertTrue(EyeWarpProvider().fieldEmissions(face:coarse,strengths:s).eyeSize.isEmpty)
        s.eyeSize=BeautySafetyCaps.eyeSize
        XCTAssertFalse(EyeWarpProvider().fieldEmissions(face:coarse,strengths:s).eyeSize.isEmpty)
        s.eyeSize=0;s.upperEyelidLift=BeautySafetyCaps.upperEyelidLift
        let siblingPlan=BeautyEffectPlan(activeDomains:[.eyes],effectiveStrengths:s)
        let sibling=BeautyStillImageGeometryStage(sourceRGBA:source,width:320,height:400,plan:siblingPlan,face:anatomy)
        XCTAssertFalse(sibling.controlPoints.isEmpty)
        XCTAssertEqual(sibling.applyingContinuousContour(to:source),source)
    }
}
