import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Synthetic source geometry and opaque coordinate encodings only. These tests
/// verify the existing lattice seam, not reference reproduction or new tuning.
final class BeautyContinuousEyeCoordinateProbeTests: XCTestCase {
    private let width=240,height=200

    private func face(leftCenter:Float=0.32,dense:Bool=false) throws -> FaceGeometry {
        func eye(_ x:Float,_ side:BeautyObservedEyeSide) -> BeautyEyeSemanticSupport {
            let points=(0..<16).map { index -> SIMD2<Float> in
                let angle=Float(index)*2*Float.pi/16
                return SIMD2(x+0.07*cos(angle),0.4+0.025*sin(angle))
            }
            let inner=SIMD2<Float>(x+(side == .left ? 0.07:-0.07),0.4)
            let outer=SIMD2<Float>(x+(side == .left ? -0.07:0.07),0.4)
            return BeautyEyeSemanticSupport(side:side,contour:points,
                upper:points.filter { $0.y < 0.4 },lower:points.filter { $0.y > 0.4 },
                inner:[inner],outer:[outer],corners:[inner,outer],center:SIMD2(x,0.4),
                pupil:SIMD2(x,0.4),span:SIMD2(0.14,0.05),tilt:0)
        }
        let left=eye(leftCenter,.left),right=eye(0.68,.right)
        var carrier:BeautyDenseFaceSupport?
        if dense {
            var points=[SIMD3<Float>](repeating:SIMD3(0.5,0.5,0),count:478)
            for (indices,x) in [(MediaPipeFaceTopology.leftIris,leftCenter),(MediaPipeFaceTopology.rightIris,Float(0.68))] {
                for (index,landmark) in indices.enumerated() {
                    let angle=Float(index)*2*Float.pi/Float(indices.count)
                    points[landmark]=SIMD3(x+0.017*cos(angle),0.4+0.017*Float(width)/Float(height)*sin(angle),0)
                }
            }
            points[468]=SIMD3(leftCenter,0.4,0);points[473]=SIMD3(0.68,0.4,0)
            carrier=BeautyDenseFaceSupport(mesh:try XCTUnwrap(BeautyFaceMesh(points:points)))
        }
        return FaceGeometry(bounds:FaceBounds(x:0,y:0.1,width:0.98,height:0.8),faceContour:[],
            leftEye:left.contour,rightEye:right.contour,leftEyeSupport:left,rightEyeSupport:right,
            freshness:.fresh,denseSupport:carrier)
    }
    private func source() -> [UInt8] {
        var rgba=[UInt8](repeating:255,count:width*height*4)
        for y in 0..<height { for x in 0..<width {
            let offset=(y*width+x)*4
            rgba[offset]=UInt8(x);rgba[offset+1]=UInt8(y)
            rgba[offset+2]=UInt8(20+((x+y)%2)*210)
        } }
        return rgba
    }
    private func tilt(_ fraction:Float=1) -> BeautyEffectiveStrengths {
        var strengths=BeautyEffectiveStrengths();strengths.eyeTilt=BeautySafetyCaps.eyeTilt*fraction
        return strengths
    }

    func testOrdinaryLatticeCoordinatesMatchIndependentOpaqueCoordinateRamps() throws {
        let geometry=try face(),rgba=source()
        for fraction:Float in [-1,1] {
            let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:geometry,strengths:tilt(fraction)))
            let output=map.applyRGBA(rgba)
            var moving=0,accepted=0
            for y in 0..<height { for x in 0..<width {
                let q=SIMD2(Double(x),Double(y))
                guard let p=map.ordinaryUnclippedSampleIndex(at:q) else { continue }
                let offset=(y*width+x)*4
                // Bilinear interpolation preserves a linear coordinate ramp.
                // This oracle does not reconstruct any displacement formula.
                XCTAssertEqual(Double(output[offset]),p.x,accuracy:0.5001)
                XCTAssertEqual(Double(output[offset+1]),p.y,accuracy:0.5001)
                XCTAssertEqual(output[offset+3],255)
                accepted += 1
                if hypot(p.x-q.x,p.y-q.y)>0.01 { moving += 1 }
            } }
            XCTAssertEqual(accepted,width*height)
            XCTAssertGreaterThan(moving,100)
        }
    }

    // Independent color oracle, used solely to distinguish a half-pixel lattice
    // phase error. Coordinates still come from the read-only production seam.
    private func blueSample(_ rgba:[UInt8],at p:SIMD2<Double>) -> Double {
        let x0=Int(floor(p.x)),y0=Int(floor(p.y)),x1=min(width-1,x0+1),y1=min(height-1,y0+1)
        let fx=p.x-Double(x0),fy=p.y-Double(y0)
        let a=Double(rgba[(y0*width+x0)*4+2]),b=Double(rgba[(y0*width+x1)*4+2])
        let c=Double(rgba[(y1*width+x0)*4+2]),d=Double(rgba[(y1*width+x1)*4+2])
        return a*(1-fx)*(1-fy)+b*fx*(1-fy)+c*(1-fx)*fy+d*fx*fy
    }
    func testArrayIndexUsesRendererHalfPixelPhaseAndWrongPhaseMutantFails() throws {
        let rgba=source(),map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
            face:try face(),strengths:tilt()))
        let output=map.applyRGBA(rgba)
        var correctMaximumError=0.0,wrongMaximumError=0.0
        for y in 1..<(height-1) { for x in 1..<(width-1) {
            let q=SIMD2(Double(x),Double(y)),half=SIMD2<Double>(repeating:0.5)
            guard let correct=map.ordinaryUnclippedSampleIndex(at:q),
                  let previousHalf=map.ordinaryUnclippedSampleIndex(at:q-half) else { continue }
            // Evaluating the seam half a sample earlier and translating its
            // source index back produces q-d(q), the deliberately WRONG phase.
            let wrong=previousHalf+half
            guard wrong.x>=0,wrong.x<=Double(width-1),wrong.y>=0,wrong.y<=Double(height-1) else { continue }
            let actual=Double(output[(y*width+x)*4+2])
            correctMaximumError=max(correctMaximumError,abs(actual-blueSample(rgba,at:correct)))
            wrongMaximumError=max(wrongMaximumError,abs(actual-blueSample(rgba,at:wrong)))
        } }
        XCTAssertLessThanOrEqual(correctMaximumError,0.5001)
        XCTAssertGreaterThan(wrongMaximumError,1.5)
    }

    func testInvalidPointsExteriorIdentityAndRequiredSourceClampRefusal() throws {
        let regular=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
            face:try face(),strengths:tilt()))
        for point in [SIMD2<Double>(.nan,50),SIMD2(.infinity,50),SIMD2(-0.01,50),
                      SIMD2(Double(width-1)+0.01,50),SIMD2(50,Double(height-1)+0.01)] {
            XCTAssertNil(regular.ordinaryUnclippedSampleIndex(at:point))
        }
        for point in [SIMD2<Double>(0,0),SIMD2(Double(width-1),Double(height-1)),SIMD2(100,0)] {
            XCTAssertEqual(regular.ordinaryUnclippedSampleIndex(at:point),point)
        }
        var clampedPixels=0
        let rgba=source(),edgeGeometry=try face(leftCenter:0.07)
        for sign:Float in [-1,1] {
            let edge=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,face:edgeGeometry,strengths:tilt(sign)))
            let output=edge.applyRGBA(rgba)
            for y in 0..<height where edge.ordinaryUnclippedSampleIndex(at:SIMD2(0,Double(y))) == nil {
                // The ordinary legacy renderer clamps this source X to zero;
                // the comparison seam must abstain instead of reporting it.
                XCTAssertEqual(output[(y*width)*4],0)
                clampedPixels += 1
            }
        }
        XCTAssertGreaterThan(clampedPixels,0)
    }

    func testEveryIrisCarrierIsUnsupportedIncludingSparseCompatibility() throws {
        for dense in [false,true] {
            var strengths=tilt();strengths.pupilSize=BeautySafetyCaps.pupilSize
            let map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
                face:try face(dense:dense),strengths:strengths))
            XCTAssertNil(map.ordinaryUnclippedSampleIndex(at:SIMD2(80,80)))
            XCTAssertNil(map.ordinaryUnclippedSampleIndex(at:.zero),"Iris carrier rejects even exterior queries")
        }
    }

    func testReadOnlyQueriesKeepLegacyPixelsAndRedactedMirrorUnchanged() throws {
        let rgba=source(),map=try XCTUnwrap(BeautyContinuousEyeMap(width:width,height:height,
            face:try face(),strengths:tilt()))
        let before=map.applyRGBA(rgba),description=String(reflecting:map)
        let labelsBefore=Mirror(reflecting:map).children.compactMap(\.label)
        for point in [SIMD2<Double>(73,78),SIMD2(76.25,80.75),SIMD2(0,0),SIMD2(.nan,10)] {
            _=map.ordinaryUnclippedSampleIndex(at:point)
        }
        XCTAssertTrue(map.applyRGBA(rgba)==before,"Read-only evaluation cannot alter legacy pixels")
        XCTAssertEqual(String(reflecting:map),description)
        XCTAssertEqual(Mirror(reflecting:map).children.compactMap(\.label),labelsBefore)
        XCTAssertEqual(Set(labelsBefore),Set(["width","height","nodeCount"]))
        var dumpText="";dump(map,to:&dumpText)
        XCTAssertFalse(dumpText.contains("offsets"));XCTAssertFalse(dumpText.contains("SIMD2"))
    }
}
