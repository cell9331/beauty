import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects
@testable import BeautySDK

extension SegG0Tests {
    func automaticCase(_ id:String) throws {
        caseID=id
        let (negative,positive)=try inputs()
        let expected=try JSONSerialization.jsonObject(with:Data(contentsOf:root.appendingPathComponent("expected-inputs.json"))) as! [String:String]
        let engine=try BeautyEngine(configuration:BeautyConfiguration(renderBackend:.cpu))
        for (polarity,base) in [("negative",negative),("positive",positive)] {
            for item in [base,half(base)] {
                let image=item.image,s=image.side,logical="SEG-\(id)-\(polarity)"
                let hash=SHA256.hash(data:Data(image.bytes)).map{String(format:"%02x",$0)}.joined()
                XCTAssertEqual(hash,expected["\(logical)-\(s)"],"frozen_input_exact")
                var detector=VisionFaceDetector()
                let detection=detector.detect(image:image.ci(space),metadata:metadata,imageExtent:CGSize(width:s,height:s),configuration:.default)
                XCTAssertEqual(detection.observations.count,1,"real_face_support")
                let face=try XCTUnwrap(detection.observations.first)
                let neutral=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:.init())
                XCTAssertTrue(try canonical(neutral.output).bytes==image.bytes,"automatic_neutral_identity")
                for smoothing in [true,false] {
                    let parameters=smoothing ? BeautyParameters(skinSmoothing:1) : BeautyParameters(skinSharpen:1)
                    let plan=BeautyEffectResolver.resolve(parameters:parameters)
                    var baseline=Set<Int>(),support=Set<Int>()
                    _=BeautySkinTexturePipeline.applyRGBA(image.bytes,width:s,height:s,plan:plan,faceBounds:face.imageBounds,pilotAutomatic:false,pilotObserver:{baseline.insert($0)})
                    let observed=BeautySkinTexturePipeline.applyRGBA(image.bytes,width:s,height:s,plan:plan,faceBounds:face.imageBounds,pilotObserver:{support.insert($0)})
                    let plain=BeautySkinTexturePipeline.applyRGBA(image.bytes,width:s,height:s,plan:plan,faceBounds:face.imageBounds)
                    XCTAssertTrue(observed==plain,"automatic_observer_equivalence")
                    // No host mask or oracle input: the isolated texture owner creates protection.
                    let result=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:parameters)
                    XCTAssertEqual(result.detectionSummary?.faceCount,1)
                    XCTAssertEqual(result.output.extent,image.ci(space).extent)
                    XCTAssertEqual(result.output.colorSpace?.name,space.name)
                    let output=try canonical(result.output)
                    XCTAssertTrue(output.bytes==observed,"automatic_public_equivalence")
                    let repeatResult=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:parameters)
                    XCTAssertTrue(try canonical(repeatResult.output).bytes==output.bytes,"automatic_repeat")
                    let score=measure(output,item,support,baseline,smoothing)
                    var protectedChanged=0,objectChanged=0,coreChanged=0,edgeOver=0,totalChanged=0
                    for p in 0..<image.count {
                        let ds=(0..<3).map { abs(Int(output.bytes[p*4+$0])-Int(image.bytes[p*4+$0])) }
                        if !ds.contains(where:{$0>0}) { continue }
                        totalChanged += 1
                        if item.protected.contains(p) { protectedChanged += 1 }
                        if item.object.contains(p) {
                            objectChanged += 1
                            let x=p%s,y=p/s
                            let boundary=(-2...2).contains { dy in (-2...2).contains { dx in
                                x+dx<0 || x+dx>=s || y+dy<0 || y+dy>=s || !item.object.contains((y+dy)*s+x+dx)
                            }}
                            if !boundary { coreChanged += 1 }
                            if boundary && ds.contains(where:{$0>2}) { edgeOver += 1 }
                        }
                    }
                    let pass=score.numeric && score.direction >= (smoothing ? 0.20 : 0.10)
                    emit(["kind":"automatic","id":logical,"side":s,"smoothing":smoothing,
                          "coverage":score.coverage,"excluded":score.excluded,"direction":score.direction,
                          "hard":score.hard,"protected_changed":protectedChanged,"object_changed":objectChanged,
                          "object_core_changed":coreChanged,"object_edge_over_limit":edgeOver,
                          "object_pixels":item.object.count,"total_changed":totalChanged,
                          "numeric":pass,"source_exact":image.bytes==output.bytes,
                          "output_sha256":SHA256.hash(data:Data(output.bytes)).map{String(format:"%02x",$0)}.joined()])
                    try export(output,"automatic-\(polarity)-\(smoothing ? "smooth" : "sharpen")-\(s)")
                }
                try export(image,"automatic-\(polarity)-source-\(s)")
                emit(["kind":"automatic_input","id":logical,"side":s,"rgba_sha256":hash])
            }
        }
    }
    func testAutoD01() throws { try automaticCase("D01") }
    func testAutoD02() throws { try automaticCase("D02") }
    func testAutoD03() throws { try automaticCase("D03") }
    func testAutoD04() throws { try automaticCase("D04") }
    func testAutoD05() throws { try automaticCase("D05") }
    func testAutoD06() throws { try automaticCase("D06") }
}
