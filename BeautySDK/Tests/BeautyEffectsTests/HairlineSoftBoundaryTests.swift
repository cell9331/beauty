import BeautyCore
import Foundation
import XCTest
@testable import BeautyEffects

final class HairlineSoftBoundaryTests: XCTestCase {
    private let size=512
    private func face() -> FaceGeometry {
        let contour=(0...10).map { i -> SIMD2<Float> in
            let a=Float(i)/10 * .pi
            return SIMD2(0.5-0.3*cos(a),0.35+0.45*sin(a))
        }
        let left=BeautyEyebrowSemanticTrace(side:.left,points:[SIMD2(0.3,0.45),SIMD2(0.4,0.45)],innerEndpoint:SIMD2(0.4,0.45),outerEndpoint:SIMD2(0.3,0.45),center:SIMD2(0.35,0.45),apexIndex:0)
        let right=BeautyEyebrowSemanticTrace(side:.right,points:[SIMD2(0.6,0.45),SIMD2(0.7,0.45)],innerEndpoint:SIMD2(0.6,0.45),outerEndpoint:SIMD2(0.7,0.45),center:SIMD2(0.65,0.45),apexIndex:0)
        return FaceGeometry(bounds:FaceBounds(x:0.2,y:0.15,width:0.6,height:0.7),faceContour:contour,
            observedEyebrowSupport:BeautyEyebrowSemanticSupport(left:left,right:right))
    }
    private func pixels(kind: Int=0) -> [UInt8] {
        var bytes=[UInt8](repeating:255,count:size*size*4)
        for y in 0..<size { for x in 0..<size {
            let u=(Double(x)-256)/154
            let boundary=128+(kind==1 ? 40*(1-u*u) : 10*u*u)
            let t=min(1,max(0,(Double(y)-boundary)/16))
            let v=t*t*(3-2*t)
            let hair=[50.0,45.0,40.0],skin=[220.0,170.0,130.0]
            for c in 0..<3 {
                bytes[(y*size+x)*4+c]=UInt8((hair[c]+(skin[c]-hair[c])*v).rounded())
                if kind==2 { bytes[(y*size+x)*4+c]=UInt8(skin[c]) }
            }
        } }
        return bytes
    }
    private func edge(_ bytes: [UInt8]) -> Double {
        var sum=0.0,total=0.0
        for x in 230...282 { for y in 80..<190 {
            let v=max(0,Int(bytes[(y*size+x)*4])-Int(bytes[((y-1)*size+x)*4]))
            sum += Double(v*y);total += Double(v)
        } }
        return sum/total
    }
    func testDistributedBoundaryMovesBothDirectionsMonotonicallyAndProtectsBrows() {
        let source=pixels(),anatomy=face(),baseline=edge(source)
        XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source,width:size,height:size,face:anatomy),
            "soft forehead support does not authorize head wrap")
        XCTAssertFalse(HairlineBoundaryRefiner.apply(source,width:size,height:size,face:anatomy,strength:0.25)==source,"positive must be active")
        for sign:Float in [-1,1] {
            var previous=0.0
            for fraction:Float in [0.25,0.5,0.75,1] {
                let output=HairlineBoundaryRefiner.apply(source,width:size,height:size,face:anatomy,strength:sign*0.25*fraction)
                let movement=(edge(output)-baseline)*Double(sign)
                XCTAssertGreaterThan(movement,previous+0.1)
                if fraction==1 { XCTAssertGreaterThan(movement,1) }
                previous=movement
                XCTAssertEqual(output,HairlineBoundaryRefiner.apply(source,width:size,height:size,face:anatomy,strength:sign*0.25*fraction))
                var delta=0
                for y in 220..<size { for x in 0..<size {
                    let i=(y*size+x)*4
                    for c in 0..<4 { delta += abs(Int(output[i+c])-Int(source[i+c])) }
                } }
                XCTAssertEqual(delta,0)
                XCTAssertTrue(stride(from:3,to:output.count,by:4).allSatisfy { output[$0]==255 })
            }
        }
    }
    func testBangsLikeDipAndHairlessSourcesRemainExact() {
        for kind in [1,2] {
            let source=pixels(kind:kind)
            for sign:Float in [-1,1] {
                XCTAssertEqual(HairlineBoundaryRefiner.apply(source,width:size,height:size,face:face(),strength:sign*0.25),source)
            }
        }
        let anatomy=face(),source=pixels()
        let invalidTrace=BeautyEyebrowSemanticTrace(side:.left,points:[SIMD2(.nan,.nan)],
            innerEndpoint:SIMD2(.nan,.nan),outerEndpoint:SIMD2(.nan,.nan),
            center:SIMD2(.nan,.nan),apexIndex:0)
        let invalid=FaceGeometry(bounds:anatomy.bounds,faceContour:anatomy.faceContour,
            observedEyebrowSupport:BeautyEyebrowSemanticSupport(left:invalidTrace,right:nil))
        XCTAssertEqual(HairlineBoundaryRefiner.apply(source,width:size,height:size,face:invalid,strength:0.25),source)
        XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source,width:size,height:size,face:invalid))
    }
}
