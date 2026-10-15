import BeautyCore
import BeautyDetection
import BeautyEffects
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautySDK

/// Generated source/observation pairs exercise the public facade and actual
/// executors. They are deterministic carriers, not native detector evidence.
final class BeautyEngineFaceSliderTests: XCTestCase {
    private let width = 480, height = 640
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

    private func observation() -> BeautyFaceObservation {
        func box(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> [CoordinatePoint] {
            [CoordinatePoint(x:x,y:y),CoordinatePoint(x:x+w,y:y),
             CoordinatePoint(x:x+w,y:y+h),CoordinatePoint(x:x,y:y+h)]
        }
        func eye(_ x: Double) -> [CoordinatePoint] {
            (0..<8).map { i in
                let a=Double(i)/8 * 2 * .pi
                return CoordinatePoint(x:x+0.05*cos(a),y:0.33+0.03*sin(a))
            }
        }
        let contour=(0...20).map { i -> CoordinatePoint in
            let a=Double(i)/20 * .pi
            return CoordinatePoint(x:0.5-0.24*cos(a),y:0.36+0.42*sin(a))
        }
        return BeautyFaceObservation(stableID:"generated-face",confidence:1,
            imageBounds:CoordinateRect(x:0.24,y:0.14,width:0.52,height:0.66),
            observedEyeSupport:[
                BeautyObservedEyeSupport(side:.left,contour:eye(0.39)),
                BeautyObservedEyeSupport(side:.right,contour:eye(0.61))],
            observedEyeOrder:.canonical,
            observedFaceSupport:BeautyObservedFaceSupport(contour:contour,medianLine:[
                CoordinatePoint(x:0.5,y:0.34),CoordinatePoint(x:0.5,y:0.55),CoordinatePoint(x:0.5,y:0.78)]),
            observedLipSupport:BeautyObservedLipSupport(outer:box(0.40,0.57,0.20,0.07)))
    }

    private func engine(gpu: Bool = false, noFace: Bool = false) throws -> BeautyEngine {
        let observations=noFace ? [] : [observation()]
        let detector=BeautyFaceDetector(mappedObservationProvider: { _ in
            BeautyMappedFaceObservations(observations:observations)
        })
        let executor: BeautyBackendExecutor = gpu ? try BeautyMetalBackend() : BeautyCPUBackend()
        return try BeautyEngine(configuration:.init(renderBackend:gpu ? .gpu : .cpu),
            faceDetector:detector,backendExecutor:executor)
    }

    private func image(x: Double, y: Double, vertical: Bool = false) -> CIImage {
        var bytes=[UInt8](repeating:255,count:width*height*4)
        let marks=vertical ? [SIMD2(x,y)] : [SIMD2(x,y),SIMD2(1-x,y)]
        for py in 0..<height { for px in 0..<width {
            let distance=marks.map { pow(Double(px)+0.5-$0.x*Double(width),2)+pow(Double(py)+0.5-$0.y*Double(height),2) }.min()!
            let i=(py*width+px)*4
            bytes[i]=UInt8((128-110*exp(-distance/12)).rounded())
            bytes[i+1]=UInt8(px*100/width);bytes[i+2]=UInt8(py*100/height)
        } }
        // Use the same explicit RGBA8 row order as the SDK raster boundary.
        return CIImage(bitmapData:Data(bytes),bytesPerRow:width*4,
            size:CGSize(width:width,height:height),format:.RGBA8,colorSpace:colorSpace)
    }

    private func pixels(_ image: CIImage) -> [UInt8] {
        var bytes=[UInt8](repeating:0,count:width*height*4)
        CIContext(options:[.workingColorSpace:colorSpace,.outputColorSpace:colorSpace]).render(
            image,toBitmap:&bytes,rowBytes:width*4,
            bounds:CGRect(x:0,y:0,width:width,height:height),format:.RGBA8,colorSpace:colorSpace)
        return bytes
    }

    private func measure(_ bytes:[UInt8],vertical:Bool) -> Double {
        var total=[0.0,0.0],weighted=total
        for y in 0..<height { for x in 0..<width {
            let v=Double(max(0,128-Int(bytes[(y*width+x)*4])))
            let side=vertical ? 0 : (x<width/2 ? 0 : 1)
            total[side]+=v;weighted[side]+=v*Double(vertical ? y : x)
        } }
        return vertical ? weighted[0]/total[0] : weighted[1]/total[1]-weighted[0]/total[0]
    }

    func testPublicSlidersMovePixelsInReferenceDirectionsAndMatchActualMetal() throws {
        let cpu=try engine(),gpu=try engine(gpu:true)
        let metadata=BeautyInputMetadata(orientation:.up,source:.testFixture)
        let cases:[(BeautyFaceShapeSlider,Double,Double,Bool,Double)]=[
            (.faceWidth,0.305,0.61,false,-1),(.smallFace,0.305,0.61,false,-1),
            (.jawAngle,0.36,0.70,false,-1),(.vFace,0.36,0.70,false,-1),
            (.temple,0.26,0.29,false,1),(.cheekbone,0.265,0.43,false,-1),
            (.chinTaper,0.41,0.75,false,1),(.chinLength,0.5,0.78,true,-1)]
        for (slider,x,y,vertical,direction) in cases {
            let source=image(x:x,y:y,vertical:vertical),before=pixels(source)
            let baseline=measure(before,vertical:vertical)
            for position:Float in (slider == .vFace ? [1] : [0,1]) {
                let parameters=slider.applying(position:position,to:BeautyParameters())
                let result=try cpu.processResult(image:source,metadata:metadata,parameters:parameters)
                let output=pixels(result.output)
                let sign=position==0 ? -1.0 : 1.0
                XCTAssertGreaterThan((measure(output,vertical:vertical)-baseline)*direction*sign,1,"\(slider) \(position)")
                let metal=try gpu.processResult(image:source,metadata:metadata,parameters:parameters)
                XCTAssertTrue(output==pixels(metal.output),"actual CPU/Metal parity")
                XCTAssertEqual(result.output.extent,source.extent)
                XCTAssertEqual(result.output.colorSpace?.name,colorSpace.name)
                XCTAssertEqual(result.detectionSummary?.usedFaceCount,1)
                let repeated=try cpu.processResult(image:source,metadata:metadata,parameters:parameters)
                XCTAssertTrue(output==pixels(repeated.output),"determinism")
                var protectedDelta=0,alphaDelta=0
                for py in 0..<height { for px in 0..<width {
                    let nx=(Double(px)+0.5)/Double(width),ny=(Double(py)+0.5)/Double(height)
                    let eye=((0.34...0.44).contains(nx)||(0.56...0.66).contains(nx)) && (0.30...0.36).contains(ny)
                    let mouth=(0.40...0.60).contains(nx)&&(0.57...0.64).contains(ny)
                    let exterior=nx<0.12 || nx>0.88 || ny<0.10 || ny>0.90
                    let i=(py*width+px)*4
                    if eye || mouth || exterior { for c in 0..<3 { protectedDelta += abs(Int(output[i+c])-Int(before[i+c])) } }
                    alphaDelta += abs(Int(output[i+3])-Int(before[i+3]))
                } }
                XCTAssertEqual(protectedDelta,0);XCTAssertEqual(alphaDelta,0)
            }
        }
    }

    func testChinTaperReferenceSliderReversesDirectPolarityAndPreservesOtherFields() {
        let source = BeautyParameters(faceSlim: 0.2, faceSmall: -0.1,
            faceVShape: 0.12, jawSlim: 0.1, chinLength: 0.1,
            faceContourSmooth: 0.1, templeFullness: 0.12, cheekboneSlim: -0.08,
            chinTaper: 0.15, noseBridge: 0.1, hairlineHeight: -0.1)
        let cap: Float = 0.25
        let mappings: [(Float, Float)] = [
            (0, cap), (0.25, cap * 0.5), (0.5, 0), (0.75, -cap * 0.5),
            (1, -cap), (-1, cap), (2, -cap), (.nan, 0)
        ]
        for (position, directValue) in mappings {
            var expected = source.normalized()
            expected.chinTaper = directValue
            XCTAssertEqual(BeautyFaceShapeSlider.chinTaper.applying(position: position, to: source), expected,
                "reference mapping changes only chinTaper")
        }
        XCTAssertEqual(BeautyParameters(chinTaper: cap).normalized().chinTaper, cap,
            "the direct positive taper API retains its polarity")
    }

    func testPublicNeutralNoFaceAndTypedFailureRecovery() throws {
        let cpu=try engine(),missing=try engine(noFace:true)
        let source=image(x:0.305,y:0.61),metadata=BeautyInputMetadata(orientation:.up,source:.testFixture)
        let before=pixels(source)
        for slider in BeautyFaceShapeSlider.allCases {
            let neutral=try cpu.processResult(image:source,metadata:metadata,
                parameters:slider.applying(position:slider.neutralPosition,to:BeautyParameters()))
            XCTAssertTrue(pixels(neutral.output)==before)
            let noFace=try missing.processResult(image:source,metadata:metadata,
                parameters:slider.applying(position:1,to:BeautyParameters()))
            XCTAssertTrue(pixels(noFace.output)==before)
        }
        XCTAssertThrowsError(try cpu.processResult(image:CIImage.empty(),metadata:metadata,
            parameters:BeautyFaceShapeSlider.smallFace.applying(position:1,to:BeautyParameters()))) {
            XCTAssertEqual($0 as? BeautyError,.invalidInput)
        }
        let recovered=try cpu.processResult(image:source,metadata:metadata,
            parameters:BeautyFaceShapeSlider.smallFace.applying(position:1,to:BeautyParameters()))
        XCTAssertFalse(pixels(recovered.output)==before)
        let rotated=try cpu.processResult(image:source,
            metadata:BeautyInputMetadata(orientation:.right,isInputMirrored:true,source:.testFixture),
            parameters:BeautyFaceShapeSlider.faceWidth.applying(position:1,to:BeautyParameters()))
        XCTAssertEqual(rotated.output.extent,source.extent)
        XCTAssertEqual(rotated.output.colorSpace?.name,colorSpace.name)
        let rotatedBytes=pixels(rotated.output)
        XCTAssertTrue(stride(from:3,to:rotatedBytes.count,by:4).allSatisfy { rotatedBytes[$0]==255 })
        let shiftedSource=source.transformed(by:CGAffineTransform(translationX:13,y:17))
        let shifted=try cpu.processResult(image:shiftedSource,metadata:metadata,
            parameters:BeautyFaceShapeSlider.smallFace.applying(position:1,to:BeautyParameters()))
        XCTAssertEqual(shifted.output.extent,shiftedSource.extent)
    }
}
