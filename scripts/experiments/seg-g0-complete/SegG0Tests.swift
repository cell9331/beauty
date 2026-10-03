import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import ImageIO
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
        let face_envelope: [[Double]]
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
    var caseID = ""
    func emit(_ row:[String:Any]) {
        let data=try! JSONSerialization.data(withJSONObject:row,options:[.sortedKeys])
        // Keep aggregate rows separate from XCTest stdout/stderr interleaving.
        let directory=URL(fileURLWithPath:ProcessInfo.processInfo.environment["SEG_G0_REPORT"]!)
        try! data.write(to:directory.appendingPathComponent(UUID().uuidString+".json"),options:.atomic)
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
    func sourceImage() throws -> Image {
        let image=try XCTUnwrap(CIImage(contentsOf:root.appendingPathComponent("SEG-\(caseID)-source.png")))
        let scale=1024/max(image.extent.width,image.extent.height)
        let grid=CGRect(x:0,y:0,width:1024,height:1024)
        return try canonical(image.clampedToExtent().transformed(by:CGAffineTransform(scaleX:scale,y:scale)).cropped(to:grid))
    }
    func inputs() throws -> (Case,Case) {
        let negative=try sourceImage()
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
        guard author.face_envelope.count>=3,
              author.face_envelope.allSatisfy({$0.count==2 && $0.allSatisfy({$0.isFinite && $0>=0 && $0<=1})})
        else { throw InputError.invalidAnnotation }
        var protected=region(author.protected,s)
        // An independently drawn conservative face envelope contains no background.
        // Everything outside it is protected, including hair, neck and clothes.
        for y in 0..<s { for x in 0..<s {
            let u=(Double(x)+0.5)/Double(s),v=(Double(y)+0.5)/Double(s)
            var inside=false
            for i in author.face_envelope.indices {
                let a=author.face_envelope[i],b=author.face_envelope[(i+1)%author.face_envelope.count]
                if (a[1]>v) != (b[1]>v), u < (b[0]-a[0])*(v-a[1])/(b[1]-a[1])+a[0] { inside.toggle() }
            }
            if !inside { protected.insert(y*s+x) }
        }}
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
        try CIContext().writePNGRepresentation(of:image.ci(space),to:directory.appendingPathComponent(caseID+"-"+name+".png"),format:.RGBA8,colorSpace:space)
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
            let parameters=smoothing ? BeautyParameters(skinSmoothing:1) : BeautyParameters(skinSharpen:1)
            let plan=BeautyEffectResolver.resolve(parameters:parameters)
            var a0=Set<Int>(),a1=Set<Int>()
            _=BeautySkinTexturePipeline.applyRGBA(image.bytes,width:s,height:s,plan:plan,faceBounds:face.imageBounds,pilotObserver:{a0.insert($0)})
            let observed=BeautySkinTexturePipeline.applyRGBA(image.bytes,width:s,height:s,plan:plan,faceBounds:face.imageBounds,exclusionMask:mask,pilotObserver:{a1.insert($0)})
            let plain=BeautySkinTexturePipeline.applyRGBA(image.bytes,width:s,height:s,plan:plan,faceBounds:face.imageBounds,exclusionMask:mask)
            XCTAssertTrue(observed==plain,"observer_equivalence")
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
            try export(output,"\(polarity)-\(smoothing ? "smooth" : "sharpen")-\(s)")
            if caseID=="D01" {
                var dark=image
                for p in 0..<image.count { for c in 0..<3 { dark.bytes[p*4+c]=image.bytes[p*4+c]>0 ? image.bytes[p*4+c]-1 : 0 } }
                XCTAssertGreaterThan(measure(dark,input,a1,a0,smoothing).hard,0,"global_darkening_rejected")
                var flat=image
                for p in 0..<image.count { for c in 0..<3 { flat.bytes[p*4+c]=128 } }
                XCTAssertGreaterThan(measure(flat,input,a1,a0,smoothing).hard,0,"global_flattening_rejected")
                if polarity=="positive" {
                    let flipped=(0..<image.count).map { maskBytes[($0/s)*s+s-1-($0%s)] }
                    let misplaced=try BeautyTextureExclusionMask(width:s,height:s,bytes:flipped)
                    let moved=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:parameters,textureExclusionMask:misplaced)
                    XCTAssertGreaterThan(measure(try canonical(moved.output),input,a1,a0,smoothing).hard,0,"misplaced_protection_rejected")
                }
                for raw in UInt32(1)...UInt32(8) { for mirrored in [false,true] {
                    var stored=image.ci(space)
                    if mirrored { stored=stored.transformed(by:CGAffineTransform(a:-1,b:0,c:0,d:1,tx:CGFloat(s),ty:0)) }
                    let inverse:UInt32=raw==6 ? 8 : (raw==8 ? 6 : raw)
                    stored=stored.oriented(forExifOrientation:Int32(inverse))
                    let request=BeautyInputMetadata(orientation:CGImagePropertyOrientation(rawValue:raw)!,isInputMirrored:mirrored,isPreviewMirrored:!mirrored,source:.testFixture)
                    let oriented=try engine.processResult(image:stored,metadata:request,parameters:parameters,textureExclusionMask:mask)
                    XCTAssertEqual(oriented.output.extent,image.ci(space).extent,"orientation_extent")
                    XCTAssertEqual(oriented.output.colorSpace?.name,space.name,"orientation_color")
                    XCTAssertTrue(try canonical(oriented.output).bytes==output.bytes,"orientation_pixel_equivalence")
                }}
                emit(["kind":"matrix","id":"SEG-\(caseID)-\(polarity)","side":s,"smoothing":smoothing,"orientation_combinations":16])
            }
        }
        try export(image,"\(polarity)-source-\(s)")
        emit(["kind":"input","id":"SEG-\(caseID)-\(polarity)","side":s,
            "rgba_sha256":SHA256.hash(data:Data(image.bytes)).map{String(format:"%02x",$0)}.joined(),
            "skin_pixels":input.skin.count,"object_pixels":input.object.count])
    }
    func checkSource(_ id:String) throws {
        caseID=id
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
    func testD01() throws { try checkSource("D01") }
    func testD02() throws { try checkSource("D02") }
    func testD03() throws { try checkSource("D03") }
    func testD04() throws { try checkSource("D04") }
    func testD05() throws { try checkSource("D05") }
    func testD06() throws { try checkSource("D06") }
    func testH01() throws { try checkSource("H01") }
    func testH02() throws { try checkSource("H02") }
    func testH03() throws { try checkSource("H03") }
    func testH04() throws { try checkSource("H04") }
    func testH05() throws { try checkSource("H05") }
    func testH06() throws { try checkSource("H06") }

    struct RejectAuthor: Decodable { let kind:String; let rect:[Double]?; let sample:[Double]? }
    func rejectSource() throws -> Case {
        let author=try JSONDecoder().decode(RejectAuthor.self,from:Data(contentsOf:root.appendingPathComponent("SEG-\(caseID)-author.json")))
        var image:Image
        if author.kind=="no_face" {
            image=Image(bytes:[UInt8](repeating:255,count:1024*1024*4),side:1024)
            for p in 0..<image.count { for c in 0..<3 { image.bytes[p*4+c]=UInt8(128+((p%1024)/4+(p/1024)/4)%2*4) } }
        } else { image=try sourceImage() }
        if author.kind=="tiny_face" {
            let original=image
            for p in 0..<image.count { for c in 0..<3 { image.bytes[p*4+c]=128 } }
            for y in 0..<64 { for x in 0..<64 { for c in 0..<3 {
                image.bytes[((480+y)*1024+480+x)*4+c]=original.bytes[((y*16)*1024+x*16)*4+c]
            }}}
        }
        if let rectangle=author.rect,let sample=author.sample {
            let reference=region([sample],1024),covered=region([rectangle],1024)
            guard !reference.isEmpty && !covered.isEmpty else { throw InputError.invalidAnnotation }
            let means=(0..<3).map { c in Int((Double(reference.reduce(0){$0+Int(image.bytes[$1*4+c])})/Double(reference.count)).rounded()) }
            for p in covered {
                let detail=author.kind=="open_print" ? (((p%1024)/4+(p/1024)/4)%2==0 ? 6 : -6) : 0
                for c in 0..<3 { image.bytes[p*4+c]=UInt8(clamping:means[c]+detail) }
            }
        }
        return Case(image:image,skin:[],object:[],protected:Set(0..<image.count))
    }
    func checkRejection(_ id:String) throws {
        caseID=id
        let input=try rejectSource()
        let engine=try BeautyEngine(configuration:BeautyConfiguration(renderBackend:.cpu))
        for item in [input,half(input)] {
            let image=item.image,s=image.side
            let mask=try BeautyTextureExclusionMask(width:s,height:s,bytes:[UInt8](repeating:255,count:image.count))
            for parameters in [BeautyParameters(),BeautyParameters(skinSmoothing:1),BeautyParameters(skinSharpen:1)] {
                let result=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:parameters,textureExclusionMask:mask)
                XCTAssertTrue(try canonical(result.output).bytes==image.bytes,"rejection_reference_exact")
                XCTAssertEqual(result.output.extent,image.ci(space).extent)
                XCTAssertEqual(result.output.colorSpace?.name,space.name)
                let repeated=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:parameters,textureExclusionMask:mask)
                XCTAssertTrue(try canonical(repeated.output).bytes==image.bytes,"rejection_reference_repeat")
                if caseID=="R01" { XCTAssertEqual(result.detectionSummary?.faceCount ?? 0,0,"no_face_support") }
            }
            var damaged=image;damaged.bytes[(image.count/2)*4] ^= 1
            XCTAssertFalse(damaged.bytes==image.bytes,"rejection_mutation_detected")
            try export(image,"rejection-source-\(s)")
            emit(["kind":"rejection","id":"SEG-\(caseID)","side":s,"reference_exact":true,
                  "rgba_sha256":SHA256.hash(data:Data(image.bytes)).map{String(format:"%02x",$0)}.joined()])
        }
    }
    func testR01() throws { try checkRejection("R01") }
    func testR02() throws { try checkRejection("R02") }
    func testR03() throws { try checkRejection("R03") }
    func testR04() throws { try checkRejection("R04") }
    func testR05() throws { try checkRejection("R05") }
    func testR06() throws { try checkRejection("R06") }

    func testInputFailureControls() throws {
        caseID="D01"
        let (negative,_)=try inputs(),image=negative.image,s=image.side
        let engine=try BeautyEngine(configuration:BeautyConfiguration(renderBackend:.cpu))
        let mask=try BeautyTextureExclusionMask(width:s,height:s,bytes:[UInt8](repeating:255,count:image.count))
        let parameters=BeautyParameters(skinSmoothing:1)
        XCTAssertThrowsError(try engine.processResult(encodedImageData:Data([0,1,2,3]),metadata:metadata,parameters:parameters,textureExclusionMask:mask)) {
            XCTAssertEqual($0 as? BeautyError,.invalidInput,"corrupt_input_typed_error")
        }
        XCTAssertThrowsError(try engine.processResult(image:CIImage.empty(),metadata:metadata,parameters:parameters,textureExclusionMask:mask)) {
            XCTAssertEqual($0 as? BeautyError,.invalidInput,"empty_input_typed_error")
        }
        var transparent=image;transparent.bytes[3]=0
        XCTAssertThrowsError(try engine.processResult(image:transparent.ci(space),metadata:metadata,parameters:parameters,textureExclusionMask:mask)) {
            XCTAssertEqual($0 as? BeautyError,.invalidInput,"alpha_input_typed_error")
        }
        let recovered=try engine.processResult(image:image.ci(space),metadata:metadata,parameters:parameters,textureExclusionMask:mask)
        XCTAssertTrue(try canonical(recovered.output).bytes==image.bytes,"input_failure_recovery")
        let counterfeit=image.ci(CGColorSpace(name:CGColorSpace.displayP3)!)
        XCTAssertNotEqual(counterfeit.colorSpace?.name,space.name,"counterfeit_output_color_rejected")
        XCTAssertNotEqual(image.ci(space).transformed(by:CGAffineTransform(translationX:1,y:0)).extent,image.ci(space).extent,"counterfeit_extent_rejected")
        emit(["kind":"input_controls","corrupt":true,"empty":true,"alpha":true,"recovery":true,"metadata_mutations":2])
    }
    func testMetricControls() {
        let s=32,roi=Set(0..<400),baseline=roi
        var source=Image(bytes:[UInt8](repeating:255,count:s*s*4),side:s)
        for p in 0..<source.count { for c in 0..<3 { source.bytes[p*4+c]=UInt8(100+(p%s)%2*4) } }
        let input=Case(image:source,skin:roi,object:[],protected:[])
        let boundarySupport=Set(100..<400),excessSupport=Set(101..<400)
        let boundary=measure(source,input,boundarySupport,baseline,true)
        let excess=measure(source,input,excessSupport,baseline,true)
        XCTAssertEqual(boundary.excluded,0.25)
        XCTAssertTrue(boundary.numeric,"exclusion_boundary_allowed")
        XCTAssertGreaterThan(excess.coverage,0.50)
        XCTAssertGreaterThan(excess.excluded,0.25)
        XCTAssertFalse(excess.numeric,"exclusion_independently_rejected")
        XCTAssertEqual(boundary.direction,0,"noop_has_no_effect")
        XCTAssertTrue(measure(source,input,Set(0..<200),Set(0..<200),true).numeric,"coverage_boundary_allowed")
        XCTAssertFalse(measure(source,input,Set(0..<199),Set(0..<199),true).numeric,"coverage_below_rejected")
        let flat=Image(bytes:[UInt8](repeating:255,count:s*s*4),side:s)
        XCTAssertEqual(variation(flat,roi),0,"flat_source_not_measurable")
    }
}
