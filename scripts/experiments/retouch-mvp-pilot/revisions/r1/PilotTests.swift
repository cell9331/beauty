import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects
@testable import BeautySDK

// Development diagnostics only. Reference data never enters Candidate methods.
final class RetouchPilotTests: XCTestCase {
    let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    struct Raster {
        var bytes: [UInt8]; let width: Int; let height: Int
        var count: Int { width * height }
        func luma(_ p: Int, eye: Bool = false) -> Double {
            let k = p * 4
            return eye ? (2126 * Double(bytes[k]) + 7152 * Double(bytes[k+1]) + 722 * Double(bytes[k+2])) / 10000
                : (77 * Double(bytes[k]) + 150 * Double(bytes[k+1]) + 29 * Double(bytes[k+2])) / 256
        }
        func image(_ space: CGColorSpace) -> CIImage {
            CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
                    size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: space)
        }
    }
    struct EyePair { let source: Raster; let target: Raster; let rois: [[Int]]; let allowed: Set<Int> }
    struct SegScene { let image: Raster; let object: Set<Int>; let skin: Set<Int>; let protected: Set<Int> }
    struct EyeScore { let improvement: [Double]; let hp: [Double]; let hard: Int; let direction: Bool }
    struct SegScore { let direction: Double; let coverage: Double; let excluded: Double; let hard: Int; let pass: Bool }
    final class Requests: @unchecked Sendable { var value: [BeautyUpperEyelidSemanticRequest] = [] }
    enum PilotError: Error { case invalidFixture, invalidGeometry }
    let face = CoordinateRect(x: 0.18, y: 0.12, width: 0.64, height: 0.78)

    func emit(_ row: [String: Any]) {
        let data = try! JSONSerialization.data(withJSONObject: row, options: [.sortedKeys])
        print("PILOT " + String(decoding: data, as: UTF8.self))
    }
    func canonical(_ image: CIImage) throws -> Raster {
        let c = try BeautyStillImageCanonicalizer().canonicalize(image: image, metadata: metadata, maximumPixelCount: 4_000_000)
        return Raster(bytes: Array(c.rgba8Data), width: c.width, height: c.height)
    }
    func fixture(_ name: String) throws -> Raster {
        let root = try XCTUnwrap(ProcessInfo.processInfo.environment["PILOT_FIXTURES"])
        let url = URL(fileURLWithPath: root).appendingPathComponent(name)
        let image = try XCTUnwrap(CIImage(contentsOf: url, options: [.applyOrientationProperty: true]))
        let scale = 1024 / max(image.extent.width, image.extent.height)
        return try canonical(image.transformed(by: CGAffineTransform(scaleX: scale, y: scale)))
    }
    func export(_ image: Raster, _ name: String) throws {
        let root = try XCTUnwrap(ProcessInfo.processInfo.environment["PILOT_REVIEW"])
        try CIContext().writePNGRepresentation(of: image.image(space),
            to: URL(fileURLWithPath: root).appendingPathComponent(name + ".png"), format: .RGBA8, colorSpace: space)
    }
    func requests(_ image: Raster) -> [BeautyUpperEyelidSemanticRequest] {
        var detector = VisionFaceDetector(); let box = Requests()
        _ = detector.detectWithUpperEyelidSupport(image: image.image(space), metadata: metadata,
            imageExtent: CGSize(width: image.width, height: image.height), configuration: BeautyConfiguration(),
            semanticOwner: { input in box.value = input; return [] })
        return box.value
    }
    func eyePair() throws -> EyePair {
        let target = try fixture("upper-eyelid-generated-base.png")
        let detected = requests(target)
        guard detected.count == 2 else { throw PilotError.invalidGeometry }
        var source = target; var rois = [[Int]](); var allowed = Set<Int>()
        for request in detected {
            let e = request.permittedEnvelope
            let cx = (e.minX + e.width / 2) * Double(target.width)
            let cy = (e.minY + e.height / 2) * Double(target.height)
            let rx = e.width * Double(target.width) * 0.45
            let ry = e.height * Double(target.height) * 0.45
            var roi = [Int]()
            for y in 0..<target.height { for x in 0..<target.width {
                let p = y * target.width + x
                let nx = (Double(x)+0.5)/Double(target.width), ny = (Double(y)+0.5)/Double(target.height)
                if nx >= e.minX && nx <= e.minX+e.width && ny >= e.minY && ny <= e.minY+e.height { allowed.insert(p) }
                let r2 = pow((Double(x)+0.5-cx)/rx, 2) + pow((Double(y)+0.5-cy)/ry, 2)
                if r2 < 1 {
                    roi.append(p)
                    let increment = Int((16 * pow(1-r2, 2)).rounded())
                    for c in 0..<3 {
                        let v = Int(source.bytes[p*4+c]) + increment
                        guard v <= 255 else { throw PilotError.invalidFixture }
                        source.bytes[p*4+c] = UInt8(v)
                    }
                }
            }}
            guard !roi.isEmpty else { throw PilotError.invalidFixture }
            let mae = roi.reduce(0.0) { $0 + abs(source.luma($1,eye:true)-target.luma($1,eye:true)) } / Double(roi.count)
            guard mae >= 4 else { throw PilotError.invalidFixture }
            rois.append(roi)
        }
        return EyePair(source: source, target: target, rois: rois, allowed: allowed)
    }
    func highpass(_ image: Raster, _ p: Int) -> Double {
        let x = p % image.width, y = p / image.width
        var mean = 0.0
        for dy in -1...1 { for dx in -1...1 {
            let q = min(image.height-1,max(0,y+dy))*image.width + min(image.width-1,max(0,x+dx))
            mean += image.luma(q,eye:true)/9
        }}
        return image.luma(p,eye:true) - mean
    }
    func eyeScore(_ output: Raster, _ pair: EyePair, _ strength: Double) -> EyeScore {
        var hard = 0; var improvements = [Double](); var hp = [Double]()
        for p in 0..<output.count {
            if output.bytes[p*4+3] != pair.source.bytes[p*4+3] { hard += 1 }
            for c in 0..<3 {
                let delta = Int(output.bytes[p*4+c]) - Int(pair.source.bytes[p*4+c])
                if delta > 0 || delta < -16 || (!pair.allowed.contains(p) && delta != 0) { hard += 1 }
            }
        }
        for roi in pair.rois {
            var before = 0.0, after = 0.0, baseHP = 0.0, deltaHP = 0.0
            for p in roi {
                before += abs(pair.source.luma(p,eye:true)-pair.target.luma(p,eye:true))
                after += abs(output.luma(p,eye:true)-pair.target.luma(p,eye:true))
                let srcHP = highpass(pair.source,p)
                baseHP += abs(srcHP); deltaHP += abs(highpass(output,p)-srcHP)
            }
            improvements.append(1-after/before)
            hp.append(baseHP / Double(roi.count) >= 1 ? deltaHP/baseHP : -1)
        }
        // -1 denotes low-texture, requiring visual review, never a visual pass.
        let direction = improvements.allSatisfy { $0 >= 0.10*strength }
        if hp.contains(where: { $0 > 0.10 }) { hard += 1 }
        return EyeScore(improvement: improvements, hp: hp, hard: hard, direction: direction)
    }
    func variation(_ image: Raster, _ region: Set<Int>) -> Double {
        var total = 0.0, count = 0
        for p in region {
            for q in [p%image.width < image.width-1 ? p+1 : -1, p+image.width] where region.contains(q) {
                total += abs(image.luma(p)-image.luma(q)); count += 1
            }
        }
        return count > 0 ? total / Double(count) : .nan
    }
    func segScene(_ side: Int, _ tone: Int, _ shape: Int) -> SegScene {
        let tones = [[110,76,61], [170,125,110], [215,180,164]]
        let rgb = tones[tone]; var bytes = [UInt8](repeating:255,count:side*side*4)
        var object = Set<Int>(), skin = Set<Int>(), protected = Set<Int>()
        for y in 0..<side { for x in 0..<side {
            let u = (Double(x)+0.5)/Double(side), v = (Double(y)+0.5)/Double(side), p = y*side+x
            let onFace = pow((u-0.5)/0.30,2)+pow((v-0.51)/0.37,2) < 1
            let eye = (v > 0.30 && v < 0.37 && ((u > 0.32 && u < 0.43)||(u > 0.57 && u < 0.68)))
            let lip = v > 0.65 && v < 0.71 && u > 0.40 && u < 0.60
            let inSkin = v > 0.49 && v < 0.59 && u > 0.31 && u < 0.43
            let ellipse = pow((u-0.625)/0.053,2)+pow((v-0.53)/0.043,2)<1
            let rounded = pow(abs((u-0.625)/0.053),4)+pow(abs((v-0.53)/0.043),4)<1
            let patch = shape >= 0 && (shape == 0 ? ellipse : rounded)
            var color = [35,45,65]
            if onFace {
                let texture = ((x/2 + y/2)%2 == 0 ? 6 : -6)
                color = rgb.map { $0 + texture }
                if patch {
                    let detail = ((x/3 + y/3)%2 == 0 ? 2 : -2)
                    color = rgb.map { $0 + 12 + detail }; object.insert(p)
                }
                if eye { color = [45,35,33] }
                if lip { color = [125,63,70] }
                if inSkin { skin.insert(p) }
            }
            if !onFace || eye || lip { protected.insert(p) }
            for c in 0..<3 { bytes[p*4+c] = UInt8(color[c]) }
        }}
        return SegScene(image: Raster(bytes:bytes,width:side,height:side),object:object,skin:skin,protected:protected)
    }
    func plan(_ smoothing: Bool, neutral: Bool = false) -> BeautyEffectPlan {
        var strengths = BeautyEffectiveStrengths()
        if !neutral { if smoothing { strengths.skinSmoothing = 1 } else { strengths.skinSharpen = 1 } }
        return BeautyEffectPlan(effectiveStrengths: strengths)
    }
    func texture(_ scene: SegScene, _ exclusion: Set<Int>, _ smoothing: Bool,
                 neutral: Bool = false, noFace: Bool = false) throws -> (Raster, Set<Int>) {
        let image = scene.image
        var maskBytes = [UInt8](repeating:0,count:image.count)
        for p in exclusion { maskBytes[p] = 255 }
        let mask = try BeautyTextureExclusionMask(width:image.width,height:image.height,bytes:maskBytes)
        var support = Set<Int>()
        let output = BeautySkinTexturePipeline.applyRGBA(image.bytes,width:image.width,height:image.height,
            plan:plan(smoothing,neutral:neutral),faceBounds:noFace ? nil : face,exclusionMask:mask,
            pilotObserver:{ support.insert($0) })
        let plain = BeautySkinTexturePipeline.applyRGBA(image.bytes,width:image.width,height:image.height,
            plan:plan(smoothing,neutral:neutral),faceBounds:noFace ? nil : face,exclusionMask:mask)
        XCTAssertTrue(output == plain, "observer_output_equivalence")
        return (Raster(bytes:output,width:image.width,height:image.height),support)
    }
    func segScore(_ output: Raster, _ scene: SegScene, _ support: Set<Int>, _ baseline: Set<Int>, _ smoothing: Bool) -> SegScore {
        var hard = 0, unchanged = 0
        let src = scene.image
        for p in 0..<src.count {
            if output.bytes[p*4+3] != src.bytes[p*4+3] { hard += 1 }
            let deltas = (0..<3).map { abs(Int(output.bytes[p*4+$0])-Int(src.bytes[p*4+$0])) }
            let changed = deltas.contains { $0 != 0 }
            if scene.protected.contains(p) && changed { hard += 1 }
            if scene.object.contains(p) {
                if !changed { unchanged += 1 }
                else {
                    let x = p%src.width, y = p/src.width
                    var boundary = false
                    for dy in -2...2 { for dx in -2...2 {
                        if x+dx < 0 || x+dx >= src.width || y+dy < 0 || y+dy >= src.height || !scene.object.contains((y+dy)*src.width+x+dx) { boundary = true }
                    }}
                    if !boundary || deltas.contains(where:{$0>2}) { hard += 1 }
                }
            }
        }
        if unchanged*100 < scene.object.count*95 { hard += 1 }
        if !support.isSubset(of:baseline) { hard += 1 }
        let v = variation(src,scene.skin), after = variation(output,scene.skin)
        let direction = smoothing ? 1-after/v : after/v-1
        let coverage = Double(support.intersection(scene.skin).count)/Double(scene.skin.count)
        let excluded = Double(baseline.subtracting(support).intersection(scene.skin).count)/Double(scene.skin.count)
        return SegScore(direction:direction,coverage:coverage,excluded:excluded,hard:hard,
            pass:hard==0 && direction >= (smoothing ? 0.20 : 0.10) && coverage >= 0.50 && (scene.object.isEmpty ? excluded <= 0.25 : true))
    }
    func testEyeControls() throws {
        let pair = try eyePair()
        var witness = pair.source
        for k in stride(from:0,to:witness.bytes.count,by:4) { for c in 0..<3 {
            let signal = Int(pair.source.bytes[k+c])-Int(pair.target.bytes[k+c])
            witness.bytes[k+c] = UInt8(Int(pair.source.bytes[k+c])-Int((0.125*Double(signal)).rounded()))
        }}
        let correct = eyeScore(witness,pair,1)
        XCTAssertTrue(correct.direction && correct.hard==0,"eye_correct_control")
        XCTAssertFalse(eyeScore(pair.source,pair,1).direction,"eye_noop_rejection")
        var global = pair.source
        for k in stride(from:0,to:global.bytes.count,by:4) { for c in 0..<3 { global.bytes[k+c] = global.bytes[k+c] > 0 ? global.bytes[k+c]-1 : 0 } }
        XCTAssertGreaterThan(eyeScore(global,pair,1).hard,0,"eye_global_rejection")
        var ring = witness
        for roi in pair.rois {
            for p in roi where abs(Double(p % ring.width)-Double(roi[roi.count/2] % ring.width)) < 2 {
                for c in 0..<3 { ring.bytes[p*4+c] = UInt8(clamping:Int(ring.bytes[p*4+c])-12) }
            }
        }
        try export(pair.source,"eye-source"); try export(pair.target,"eye-reference")
        try export(witness,"eye-correct-control"); try export(ring,"eye-wrong-trough")
        emit(["kind":"eye_controls","direction":correct.direction,"hard":correct.hard,
              "improvement":correct.improvement,"hp":correct.hp,"visual":"pending"])
    }
    func testSegControls() throws {
        var checked = 0
        for side in [512,1024] { for tone in 0..<3 { for shape in [-1,0,1] {
            let scene = segScene(side,tone,shape)
            let (base,a0) = try texture(scene,[],true)
            XCTAssertGreaterThan(variation(scene.image,scene.skin),0)
            for smoothing in [true,false] {
                let (correct,a1) = try texture(scene,scene.object.union(scene.protected),smoothing)
                let score = segScore(correct,scene,a1,a0,smoothing)
                XCTAssertTrue(score.pass,"seg_correct_control")
                let (whole,a2) = try texture(scene,Set(0..<scene.image.count),smoothing)
                XCTAssertTrue(whole.bytes == scene.image.bytes)
                XCTAssertFalse(segScore(whole,scene,a2,a0,smoothing).pass,"seg_whole_rejection")
                XCTAssertFalse(segScore(scene.image,scene,a0,a0,smoothing).pass,"seg_noop_rejection")
                if !scene.object.isEmpty {
                    let core = try XCTUnwrap(scene.object.first { p in
                        (-2...2).allSatisfy { dy in (-2...2).allSatisfy { dx in scene.object.contains(p+dy*side+dx) } }
                    })
                    var leak = correct; leak.bytes[core*4] += 1
                    XCTAssertGreaterThan(segScore(leak,scene,a1,a0,smoothing).hard,0,"core_leak_rejection")
                    let edge = scene.object.min()!
                    leak = correct; leak.bytes[edge*4] += 3
                    XCTAssertGreaterThan(segScore(leak,scene,a1,a0,smoothing).hard,0,"edge_limit_rejection")
                } else {
                    let (falseMask,a3) = try texture(scene,scene.skin,smoothing)
                    let bad = segScore(falseMask,scene,a3,a0,smoothing)
                    XCTAssertGreaterThan(bad.excluded,0.25)
                    XCTAssertFalse(bad.pass,"false_exclusion_rejection")
                }
                checked += 1
            }
            if side==512 && tone==1 && shape==0 {
                try export(scene.image,"seg-source")
                try export(try texture(scene,scene.object.union(scene.protected),true).0,"seg-correct-control")
            }
            for (neutral,noFace) in [(true,false),(false,true)] {
                let (image,support) = try texture(scene,[],true,neutral:neutral,noFace:noFace)
                XCTAssertTrue(image.bytes == scene.image.bytes); XCTAssertTrue(support.isEmpty)
            }
            let wrong = try BeautyTextureExclusionMask(width:side-1,height:side,bytes:[UInt8](repeating:0,count:(side-1)*side))
            var invalidSupport = Set<Int>()
            let invalid = BeautySkinTexturePipeline.applyRGBA(scene.image.bytes,width:side,height:side,
                plan:plan(true),faceBounds:face,exclusionMask:wrong,pilotObserver:{invalidSupport.insert($0)})
            XCTAssertTrue(invalid == scene.image.bytes); XCTAssertTrue(invalidSupport.isEmpty)
            XCTAssertTrue(try texture(scene,[],true).0.bytes == base.bytes,"observer_request_recovery")
        }}}
        emit(["kind":"seg_controls","comparisons":checked,"observer":"checked","backend":"cpu_internal"])
    }

    // Candidate E1-v1: image-only low-frequency positive residual correction.
    // No reference image, fixture ID or author ROI argument is accepted.
    func eyeCandidate(_ image: Raster, _ strength: Double) -> Raster {
        guard strength > 0 else { return image }
        var output = image
        for request in requests(image) {
            let e = request.permittedEnvelope
            let x0 = max(0,Int(ceil(e.minX*Double(image.width))))
            let x1 = min(image.width-1,Int(floor((e.minX+e.width)*Double(image.width)))-1)
            let y0 = max(0,Int(ceil(e.minY*Double(image.height))))
            let y1 = min(image.height-1,Int(floor((e.minY+e.height)*Double(image.height)))-1)
            guard x1>x0+5 && y1>y0+5 else { continue }
            let radius = max(1,(y1-y0)/8)
            var residuals = [(Int,Double)](); var center = 0.0; var centers = 0
            for y in y0...y1 { for x in x0...x1 {
                let u = Double(x-x0)/Double(x1-x0), v = Double(y-y0)/Double(y1-y0)
                let baseline = image.luma(y0*image.width+x,eye:true)*(1-v)+image.luma(y1*image.width+x,eye:true)*v
                var local = 0.0; var count = 0
                for dy in -radius...radius { for dx in -radius...radius {
                    let q = min(y1,max(y0,y+dy))*image.width+min(x1,max(x0,x+dx))
                    local += image.luma(q,eye:true); count += 1
                }}
                let residual = local/Double(count)-baseline
                if u > 0.25 && u < 0.75 && v > 0.25 && v < 0.75 { center += residual; centers += 1 }
                let feather = pow(sin(.pi*u)*sin(.pi*v),2)
                residuals.append((y*image.width+x,min(8,max(0,residual)*0.30)*feather))
            }}
            guard centers>0 && center/Double(centers)>6 else { continue }
            for (p,value) in residuals {
                let delta = Int((value*strength).rounded())
                for c in 0..<3 { output.bytes[p*4+c] = UInt8(clamping:Int(image.bytes[p*4+c])-delta) }
            }
        }
        return output
    }
    // Candidate S1-v1: closed boundaries, compact components and conservative lip zone.
    // SegScene and its reference masks are deliberately absent from this signature.
    func segCandidate(_ image: Raster, _ bounds: CoordinateRect) -> Set<Int> {
        let w=image.width, h=image.height, scale=max(1,w/512)
        let radius=2*scale
        var integral=[Double](repeating:0,count:(w+1)*(h+1))
        for y in 0..<h { var row=0.0; for x in 0..<w {
            row += image.luma(y*w+x)
            integral[(y+1)*(w+1)+x+1]=integral[y*(w+1)+x+1]+row
        }}
        var smooth=[Double](repeating:0,count:w*h)
        for y in 0..<h { for x in 0..<w {
            let a=max(0,x-radius),b=min(w,x+radius+1),c=max(0,y-radius),d=min(h,y+radius+1)
            smooth[y*w+x]=(integral[d*(w+1)+b]-integral[c*(w+1)+b]-integral[d*(w+1)+a]+integral[c*(w+1)+a])/Double((b-a)*(d-c))
        }}
        var edge=[Bool](repeating:false,count:w*h)
        let step=3*scale
        for y in step..<(h-step) { for x in step..<(w-step) {
            let p=y*w+x
            edge[p]=max(abs(smooth[p+step]-smooth[p-step]),abs(smooth[p+step*w]-smooth[p-step*w]))>3
        }}
        var visited=edge, selected=Set<Int>()
        for start in 0..<(w*h) where !visited[start] {
            visited[start]=true; var queue=[start]; var head=0
            var minX=w,maxX=0,minY=h,maxY=0,touches=false
            while head<queue.count {
                let p=queue[head];head+=1;let x=p%w,y=p/w
                minX=min(minX,x);maxX=max(maxX,x);minY=min(minY,y);maxY=max(maxY,y)
                if x==0 || x==w-1 || y==0 || y==h-1 { touches=true }
                for q in [x>0 ? p-1 : -1,x<w-1 ? p+1 : -1,y>0 ? p-w : -1,y<h-1 ? p+w : -1] where q>=0 {
                    if !visited[q] { visited[q]=true;queue.append(q) }
                }
            }
            let fraction=Double(queue.count)/Double(w*h)
            let compact=Double(queue.count)/Double((maxX-minX+1)*(maxY-minY+1))
            let centerX=Double(minX+maxX)/Double(2*w), centerY=Double(minY+maxY)/Double(2*h)
            if !touches && fraction>=0.0005 && fraction<=0.035 && compact>=0.55 &&
                centerX>bounds.minX && centerX<bounds.minX+bounds.width && centerY>bounds.minY && centerY<bounds.minY+bounds.height {
                // Conservative box expansion protects both the core and contour.
                for y in max(0,minY-8*scale)...min(h-1,maxY+8*scale) {
                    for x in max(0,minX-8*scale)...min(w-1,maxX+8*scale) { selected.insert(y*w+x) }
                }
            }
        }
        for y in 0..<h { for x in 0..<w {
            let u=(Double(x)/Double(w)-bounds.minX)/bounds.width
            let v=(Double(y)/Double(h)-bounds.minY)/bounds.height
            if u>=0.14 && u<=0.86 && v>=0.62 && v<=0.94 { selected.insert(y*w+x) }
        }}
        return selected
    }
    func testEyeCandidates() throws {
        let pair=try eyePair()
        let negatives=[pair.target,try fixture("upper-eyelid-negative-control.png")]
        let engine=try BeautyEngine(configuration:BeautyConfiguration(renderBackend:.cpu))
        for mode in ["baseline","E1-v1"] {
            var passes=true, previous=pair.source
            for strength in [0.0,0.5,1.0] {
                let output: Raster
                if mode=="baseline" {
                    let result=try engine.processResult(image:pair.source.image(space),metadata:metadata,
                        parameters:BeautyParameters(upperEyelidFullnessReduction:Float(strength)))
                    XCTAssertEqual(result.output.extent,pair.source.image(space).extent)
                    XCTAssertEqual(result.output.colorSpace?.name,space.name)
                    output=try canonical(result.output)
                } else { output=eyeCandidate(pair.source,strength) }
                if strength==0 { XCTAssertTrue(output.bytes==pair.source.bytes);continue }
                let score=eyeScore(output,pair,strength)
                var reversal=0
                for k in stride(from:0,to:output.bytes.count,by:4) {
                    if output.bytes[k]>previous.bytes[k] { reversal+=1 }
                }
                if !score.direction || score.hard>0 || reversal>0 { passes=false }
                emit(["kind":"eye_candidate","mode":mode,"strength":strength,"improvement":score.improvement,
                    "hp":score.hp,"hard":score.hard,"reversal":reversal,"numeric":score.direction && score.hard==0 && reversal==0])
                if mode=="E1-v1" { XCTAssertTrue(eyeCandidate(pair.source,strength).bytes==output.bytes,"eye_repeat") }
                try export(output,"eye-\(mode)-\(Int(strength*100))")
                previous=output
            }
            var changedNegatives=0
            for negative in negatives {
                let output: Raster
                if mode=="baseline" {
                    let result=try engine.processResult(image:negative.image(space),metadata:metadata,
                        parameters:BeautyParameters(upperEyelidFullnessReduction:1))
                    output=try canonical(result.output)
                } else { output=eyeCandidate(negative,1) }
                if output.bytes != negative.bytes { changedNegatives+=1 }
            }
            if changedNegatives>0 { passes=false }
            emit(["kind":"eye_outcome","mode":mode,"negative_changes":changedNegatives,"numeric":passes,"visual":"pending"])
        }
    }
    func testSegCandidates() throws {
        for mode in ["baseline","S1-v1"] {
            var passed=0,hard=0,total=0,negativeFailures=0
            for side in [512,1024] { for tone in 0..<3 { for shape in [-1,0,1] {
                let scene=segScene(side,tone,shape)
                let mask=mode=="baseline" ? Set<Int>() : segCandidate(scene.image,face)
                let (_,a0)=try texture(scene,[],true)
                var pairPass=true, pairHard=0
                var directions=[Double](),coverages=[Double](),exclusions=[Double]()
                for smoothing in [true,false] {
                    let (output,a1)=try texture(scene,mask,smoothing)
                    let score=segScore(output,scene,a1,a0,smoothing)
                    pairPass = pairPass && score.pass;pairHard += score.hard
                    directions.append(score.direction);coverages.append(score.coverage);exclusions.append(score.excluded)
                    XCTAssertTrue(try texture(scene,mask,smoothing).0.bytes==output.bytes,"seg_repeat")
                    if side==512 && tone==1 && shape==0 && smoothing { try export(output,"seg-\(mode)") }
                }
                if shape<0 && !pairPass { negativeFailures+=1 }
                if pairPass { passed+=1 }; if pairHard>0 { hard+=1 }; total+=1
                emit(["kind":"seg_candidate","mode":mode,"side":side,"tone":tone,"shape":shape,
                    "direction":directions,"coverage":coverages,"excluded":exclusions,"hard":pairHard,"numeric":pairPass])
            }}}
            emit(["kind":"seg_outcome","mode":mode,"passed":passed,"total":total,"hard_cases":hard,
                "negative_failures":negativeFailures,"numeric":passed==total && hard==0])
        }
    }
}
