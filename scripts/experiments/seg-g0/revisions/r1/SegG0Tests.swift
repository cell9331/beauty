import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects
@testable import BeautySDK

final class SegG0Tests: XCTestCase {
    struct Image {
        var bytes: [UInt8]; let side: Int
        var count: Int { side*side }
        func luma(_ p: Int) -> Double {
            let k=p*4
            return (77*Double(bytes[k])+150*Double(bytes[k+1])+29*Double(bytes[k+2]))/256
        }
        func ci(_ space: CGColorSpace) -> CIImage {
            CIImage(bitmapData:Data(bytes),bytesPerRow:side*4,size:CGSize(width:side,height:side),format:.RGBA8,colorSpace:space)
        }
    }
    struct Author: Decodable {
        let skin_negative: [[Double]], skin_positive: [[Double]], patch: [Double], protected: [[Double]]
    }
    struct Case {
        let image: Image, skin: Set<Int>, object: Set<Int>, protected: Set<Int>
    }
    struct Metrics {
        let direction: Double, coverage: Double, excluded: Double
        let hard: Int
        var numeric: Bool { hard==0 && coverage>=0.50 && excluded<=0.25 }
    }
    enum InputError: Error { case unavailable, unsupported, invalidAnnotation }
    let metadata=BeautyInputMetadata(orientation:.up,source:.testFixture)
    let space=CGColorSpace(name:CGColorSpace.sRGB)!
    var root: URL { URL(fileURLWithPath:ProcessInfo.processInfo.environment["SEG_G0_INPUT"]!) }
    var caseID: String { ProcessInfo.processInfo.environment["SEG_G0_ID"]! }
    func emit(_ row:[String:Any]) {
        let data=try! JSONSerialization.data(withJSONObject:row,options:[.sortedKeys])
        print("SEG_G0 "+String(decoding:data,as:UTF8.self))
    }
    func canonical(_ image:CIImage) throws -> Image {
        let c=try BeautyStillImageCanonicalizer().canonicalize(image:image,metadata:metadata,maximumPixelCount:4_000_000)
        guard c.width==c.height else { throw InputError.unsupported }
        return Image(bytes:Array(c.rgba8Data),side:c.width)
    }
    func region(_ rects:[[Double]],_ side:Int) -> Set<Int> {
        var result=Set<Int>()
        for y in 0..<side { for x in 0..<side {
            let u=(Double(x)+0.5)/Double(side),v=(Double(y)+0.5)/Double(side)
            if rects.contains(where:{$0.count==4 && u >= $0[0] && v >= $0[1] && u < $0[2] && v < $0[3]}) { result.insert(y*side+x) }
        }}
        return result
    }
    func inputs() throws -> (Case,Case) {
        let image=try XCTUnwrap(CIImage(contentsOf:root.appendingPathComponent("SEG-\(caseID)-source.png")))
        let scale=1024/max(image.extent.width,image.extent.height)
        let grid=CGRect(x:0,y:0,width:1024,height:1024)
        let negative=try canonical(image.clampedToExtent().transformed(by:CGAffineTransform(scaleX:scale,y:scale)).cropped(to:grid))
        let author=try JSONDecoder().decode(Author.self,from:Data(contentsOf:root.appendingPathComponent("SEG-\(caseID)-author.json")))
        guard author.patch.count==5 else { throw InputError.invalidAnnotation }
        let s=negative.side, q=author.patch
        var object=Set<Int>()
        for y in 0..<s { for x in 0..<s {
            let u=(Double(x)+0.5)/Double(s),v=(Double(y)+0.5)/Double(s)
            if pow(abs((u-q[0])/q[2]),q[4])+pow(abs((v-q[1])/q[3]),q[4])<1 { object.insert(y*s+x) }
        }}
        guard object.count>100 else { throw InputError.invalidAnnotation }
        let means=(0..<3).map { c in Int((Double(object.reduce(0){$0+Int(negative.bytes[$1*4+c])})/Double(object.count)).rounded())+8 }
        guard means.allSatisfy({$0>2 && $0<254}) else { throw InputError.invalidAnnotation }
        var positive=negative
        for p in object {
            let detail=((p%s)/3+(p/s)/3)%2==0 ? 1 : -1
            for c in 0..<3 { positive.bytes[p*4+c]=UInt8(means[c]+detail) }
        }
        let protected=region(author.protected,s)
        let negativeSkin=region(author.skin_negative,s),positiveSkin=region(author.skin_positive,s)
        guard !negativeSkin.isEmpty && !positiveSkin.isEmpty && object.isDisjoint(with:positiveSkin),
            protected.isDisjoint(with:object),protected.isDisjoint(with:negativeSkin),
            positiveSkin.isSubset(of:negativeSkin) else { throw InputError.invalidAnnotation }
        return (Case(image:negative,skin:negativeSkin,object:[],protected:protected),
                Case(image:positive,skin:positiveSkin,object:object,protected:protected))
    }
    func half(_ input:Case) -> Case {
        let s=input.image.side/2;var pixels=[UInt8](repeating:255,count:s*s*4)
        var skin=Set<Int>(),object=Set<Int>(),protected=Set<Int>()
        for y in 0..<s { for x in 0..<s {
            let p=y*s+x
            let block=[(2*y)*2*s+2*x,(2*y)*2*s+2*x+1,(2*y+1)*2*s+2*x,(2*y+1)*2*s+2*x+1]
            for c in 0..<4 { pixels[p*4+c]=UInt8((block.reduce(0){$0+Int(input.image.bytes[$1*4+c])}+2)/4) }
            if block.allSatisfy({input.skin.contains($0)}) { skin.insert(p) }
            if block.contains(where:{input.object.contains($0)}) { object.insert(p) }
            if block.contains(where:{input.protected.contains($0)}) { protected.insert(p) }
        }}
        return Case(image:Image(bytes:pixels,side:s),skin:skin,object:object,protected:protected)
    }
    func export(_ image:Image,_ name:String) throws {
        let directory=URL(fileURLWithPath:ProcessInfo.processInfo.environment["SEG_G0_REVIEW"]!)
        try CIContext().writePNGRepresentation(of:image.ci(space),to:directory.appendingPathComponent(name+".png"),format:.RGBA8,colorSpace:space)
    }
    func variation(_ image:Image,_ roi:Set<Int>) -> Double {
        var sum=0.0,count=0
        for p in roi { for q in [p%image.side<image.side-1 ? p+1 : -1,p+image.side] where roi.contains(q) {
            sum += abs(image.luma(p)-image.luma(q));count += 1
        }}
        return count>0 ? sum/Double(count) : .nan
    }
    func measure(_ output:Image,_ input:Case,_ support:Set<Int>,_ baseline:Set<Int>,_ smoothing:Bool) -> Metrics {
        let image=input.image,s=image.side
        var hard=0,unchanged=0
        for p in 0..<image.count {
            if output.bytes[p*4+3] != image.bytes[p*4+3] { hard += 1 }
            let deltas=(0..<3).map { abs(Int(output.bytes[p*4+$0])-Int(image.bytes[p*4+$0])) }
            if deltas.contains(where:{$0>0}) {
                if input.protected.contains(p) { hard += 1 }
                if input.object.contains(p) {
                    let x=p%s,y=p/s
                    let boundary=(-2...2).contains { dy in (-2...2).contains { dx in
                        x+dx<0 || x+dx>=s || y+dy<0 || y+dy>=s || !input.object.contains((y+dy)*s+x+dx)
                    }}
                    if !boundary || deltas.contains(where:{$0>2}) { hard += 1 }
                }
            } else if input.object.contains(p) { unchanged += 1 }
        }
        if unchanged*100<input.object.count*95 { hard += 1 }
        if !support.isSubset(of:baseline) { hard += 1 }
        let before=variation(image,input.skin),after=variation(output,input.skin)
        return Metrics(direction:smoothing ? 1-after/before : after/before-1,
            coverage:Double(support.intersection(input.skin).count)/Double(input.skin.count),
            excluded:Double(baseline.subtracting(support).intersection(input.skin).count)/Double(input.skin.count),hard:hard)
    }
    func exercise(_ input:Case,_ polarity:String,_ engine:BeautyEngine) throws {
        let image=input.image,s=image.side
        var detector=VisionFaceDetector()
        let detection=detector.detect(image:image.ci(space),metadata:metadata,imageExtent:CGSize(width:s,height:s),configuration:.default)
        XCTAssertEqual(detection.summary.faceCount,1,"live_face_count")
        XCTAssertEqual(detection.observations.count,1,"live_used_face")
        guard let face=detection.observations.first else { throw InputError.unavailable }
        let maskBytes=(0..<image.count).map { input.skin.contains($0) ? UInt8(0) : UInt8(255) }
        let mask=try BeautyTextureExclusionMask(width:s,height:s,bytes:maskBytes)
        let neutral=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:.init(),textureExclusionMask:mask)
        XCTAssertTrue(try canonical(neutral.output).bytes==image.bytes,"neutral_identity")
        for smoothing in [true,false] {
            var strengths=BeautyEffectiveStrengths()
            if smoothing { strengths.skinSmoothing=1 } else { strengths.skinSharpen=1 }
            let plan=BeautyEffectPlan(effectiveStrengths:strengths)
            var a0=Set<Int>(),a1=Set<Int>()
            _=BeautySkinTexturePipeline.applyRGBA(image.bytes,width:s,height:s,plan:plan,faceBounds:face.imageBounds,pilotObserver:{a0.insert($0)})
            let observed=BeautySkinTexturePipeline.applyRGBA(image.bytes,width:s,height:s,plan:plan,faceBounds:face.imageBounds,exclusionMask:mask,pilotObserver:{a1.insert($0)})
            let plain=BeautySkinTexturePipeline.applyRGBA(image.bytes,width:s,height:s,plan:plan,faceBounds:face.imageBounds,exclusionMask:mask)
            XCTAssertTrue(observed==plain,"observer_equivalence")
            let parameters=smoothing ? BeautyParameters(skinSmoothing:1) : BeautyParameters(skinSharpen:1)
            let result=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:parameters,textureExclusionMask:mask)
            XCTAssertEqual(result.detectionSummary?.faceCount,1)
            XCTAssertEqual(result.output.extent,image.ci(space).extent)
            XCTAssertEqual(result.output.colorSpace?.name,space.name)
            let output=try canonical(result.output)
            XCTAssertTrue(output.bytes==observed,"public_observer_equivalence")
            let score=measure(output,input,a1,a0,smoothing)
            let pass=score.numeric && score.direction >= (smoothing ? 0.20 : 0.10)
            emit(["kind":"control","id":"SEG-\(caseID)-\(polarity)","side":s,"smoothing":smoothing,
                "source_variation":variation(image,input.skin)/255,"direction":score.direction,"coverage":score.coverage,
                "excluded":score.excluded,"hard":score.hard,"numeric":pass])
            XCTAssertTrue(pass,"correct_control_joint_gate")
            XCTAssertGreaterThan(variation(image,input.skin),0,"nonflat_source")
            XCTAssertEqual(measure(image,input,a1,a0,smoothing).direction,0,"noop_control")
            let whole=try BeautyTextureExclusionMask(width:s,height:s,bytes:[UInt8](repeating:255,count:image.count))
            let excluded=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:parameters,textureExclusionMask:whole)
            XCTAssertTrue(try canonical(excluded.output).bytes==image.bytes,"whole_exclusion")
            XCTAssertFalse(measure(image,input,[],a0,smoothing).numeric,"exclusion_rejected")
            var broken=output
            let protectedPixel=input.protected.min()!;broken.bytes[protectedPixel*4] ^= 1
            XCTAssertGreaterThan(measure(broken,input,a1,a0,smoothing).hard,0,"protected_leak_rejected")
            if !input.object.isEmpty {
                let core=try XCTUnwrap(input.object.sorted().first { p in
                    (-2...2).allSatisfy { dy in (-2...2).allSatisfy { dx in input.object.contains(p+dy*s+dx) } }
                })
                broken=output;broken.bytes[core*4] ^= 1
                XCTAssertGreaterThan(measure(broken,input,a1,a0,smoothing).hard,0,"core_leak_rejected")
                broken=output;broken.bytes[input.object.min()!*4] += 3
                XCTAssertGreaterThan(measure(broken,input,a1,a0,smoothing).hard,0,"edge_delta_rejected")
            }
            let wrong=try BeautyTextureExclusionMask(width:s-1,height:s,bytes:[UInt8](repeating:0,count:(s-1)*s))
            XCTAssertThrowsError(try engine.processResult(image:image.ci(space),metadata:metadata,parameters:parameters,textureExclusionMask:wrong)) { error in
                XCTAssertEqual(error as? BeautyError,.invalidInput,"typed_grid_error")
            }
            let repeated=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:parameters,textureExclusionMask:mask)
            XCTAssertTrue(try canonical(repeated.output).bytes==output.bytes,"repeat_after_failure")
            if s==1024 { try export(output,"\(polarity)-\(smoothing ? "smooth" : "sharpen")") }
        }
        try export(image,"\(polarity)-source-\(s)")
        emit(["kind":"input","id":"SEG-\(caseID)-\(polarity)","side":s,
            "rgba_sha256":SHA256.hash(data:Data(image.bytes)).map{String(format:"%02x",$0)}.joined(),
            "skin_pixels":input.skin.count,"object_pixels":input.object.count])
    }
    func testG0SourceControls() throws {
        do {
            let (negative,positive)=try inputs()
            let engine=try BeautyEngine(configuration:BeautyConfiguration(renderBackend:.cpu))
            for (name,source) in [("negative",negative),("positive",positive)] {
                try exercise(source,name,engine)
                try exercise(half(source),name,engine)
            }
        } catch {
            emit(["kind":"error","code":(error as? BeautyError)?.code ?? "fixture_or_internal"])
            throw error
        }
    }
}
