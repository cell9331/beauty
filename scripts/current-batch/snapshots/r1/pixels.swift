import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import ImageIO

enum Failure: Error { case invalidInput }
let space = CGColorSpace(name: CGColorSpace.sRGB)!
let context = CIContext(options: [.workingColorSpace: space, .outputColorSpace: space])
struct Raster {
    let width: Int, height: Int, bytes: [UInt8], srgb: Bool
    var count: Int { width * height }
    func luma(_ p: Int) -> Double {
        let k=p*4
        return (77*Double(bytes[k])+150*Double(bytes[k+1])+29*Double(bytes[k+2]))/256
    }
    var hash: String { SHA256.hash(data: Data(bytes)).map { String(format:"%02x",$0) }.joined() }
}
func load(_ path: String) throws -> Raster {
    let url=URL(fileURLWithPath:path)
    guard let source=CGImageSourceCreateWithURL(url as CFURL,nil), CGImageSourceGetCount(source)==1,
          CGImageSourceGetType(source) as String? == "public.png",
          let properties=CGImageSourceCopyPropertiesAtIndex(source,0,nil) as? [String:Any],
          let w=properties[kCGImagePropertyPixelWidth as String] as? Int,
          let h=properties[kCGImagePropertyPixelHeight as String] as? Int,
          w>0, h>0, w<=1_048_576/h,
          (properties[kCGImagePropertyOrientation as String] as? Int ?? 1)==1,
          let cg=CGImageSourceCreateImageAtIndex(source,0,nil), cg.width==w, cg.height==h
    else { throw Failure.invalidInput }
    let srgb=cg.colorSpace?.name == CGColorSpace.sRGB
    let image=CIImage(cgImage:cg)
    var bytes=[UInt8](repeating:0,count:w*h*4)
    context.render(image,toBitmap:&bytes,rowBytes:w*4,bounds:CGRect(x:0,y:0,width:w,height:h),format:.RGBA8,colorSpace:space)
    return Raster(width:w,height:h,bytes:bytes,srgb:srgb)
}
func write(_ raster: Raster, _ path: String) throws {
    let image=CIImage(bitmapData:Data(raster.bytes),bytesPerRow:raster.width*4,
                      size:CGSize(width:raster.width,height:raster.height),format:.RGBA8,colorSpace:space)
    try context.writePNGRepresentation(of:image,to:URL(fileURLWithPath:path),format:.RGBA8,colorSpace:space)
}
func fixture() -> Raster {
    let w=256,h=192
    var bytes=[UInt8](repeating:255,count:w*h*4)
    for y in 0..<h { for x in 0..<w {
        let k=(y*w+x)*4, value=40+(x*145/(w-1))+(y*25/(h-1))
        bytes[k]=UInt8(value+8);bytes[k+1]=UInt8(value);bytes[k+2]=UInt8(value-8)
    }}
    return Raster(width:w,height:h,bytes:bytes,srgb:true)
}
struct Request: Decodable {
    let case_id: String, source: String, output: String, repeated: String
    let target: [Double], protected: [[Double]]
}
func contains(_ rect:[Double], _ x:Int, _ y:Int, _ r:Raster) -> Bool {
    let u=(Double(x)+0.5)/Double(r.width),v=(Double(y)+0.5)/Double(r.height)
    return u>=rect[0] && v>=rect[1] && u<rect[2] && v<rect[3]
}
func stats(_ a:Raster,_ b:Raster,_ c:Raster,_ target:[Double],_ protected:[[Double]]) throws -> [String:Any] {
    guard a.width==b.width,a.height==b.height,b.width==c.width,b.height==c.height else { throw Failure.invalidInput }
    var changed=0,alpha=0,protectedChanged=0,maxDelta=0,count=0
    var sumA=0.0,sumB=0.0,squareA=0.0,squareB=0.0,rbA=0.0,rbB=0.0
    for p in 0..<a.count {
        let k=p*4,x=p%a.width,y=p/a.width
        let delta=(0..<3).map { abs(Int(a.bytes[k+$0])-Int(b.bytes[k+$0])) }.max()!
        if delta>0 { changed+=1 }
        maxDelta=max(maxDelta,delta)
        if a.bytes[k+3] != b.bytes[k+3] { alpha+=1 }
        if (delta>0 || a.bytes[k+3] != b.bytes[k+3]) && protected.contains(where:{contains($0,x,y,a)}) { protectedChanged+=1 }
        if contains(target,x,y,a) {
            let av=a.luma(p),bv=b.luma(p);count+=1;sumA+=av;sumB+=bv;squareA+=av*av;squareB+=bv*bv
            rbA+=Double(Int(a.bytes[k])-Int(a.bytes[k+2]));rbB+=Double(Int(b.bytes[k])-Int(b.bytes[k+2]))
        }
    }
    guard count>0 else { throw Failure.invalidInput }
    let n=Double(count),meanA=sumA/n,meanB=sumB/n
    let contrast=sqrt(max(0,squareB/n-meanB*meanB))-sqrt(max(0,squareA/n-meanA*meanA))
    return ["width":b.width,"height":b.height,"srgb":a.srgb && b.srgb && c.srgb,
            "source_opaque":stride(from:3,to:a.bytes.count,by:4).allSatisfy{a.bytes[$0]==255},
            "alpha_changed":alpha,"protected_changed":protectedChanged,"changed_pixels":changed,
            "maximum_rgb_delta":maxDelta,"repeat_exact":b.bytes==c.bytes,"source_exact":a.bytes==b.bytes,
            "luma_delta":meanB-meanA,"contrast_delta":contrast,"red_blue_delta":(rbB-rbA)/n,
            "source_rgba_sha256":a.hash,"output_rgba_sha256":b.hash]
}
func controls() throws -> [[String:Any]] {
    let a=fixture()
    func altered(_ f:(Int,inout [UInt8])->Void) -> Raster {
        var bytes=a.bytes
        for p in 0..<a.count { f(p,&bytes) }
        return Raster(width:a.width,height:a.height,bytes:bytes,srgb:true)
    }
    let up=altered {p,b in for c in 0..<3 {b[p*4+c]+=5} }
    let down=altered {p,b in for c in 0..<3 {b[p*4+c]-=5} }
    let red=altered {p,b in b[p*4]+=5;b[p*4+2]-=5 }
    let contrast=altered {p,b in for c in 0..<3 {b[p*4+c]=UInt8(min(255,max(0,(Int(b[p*4+c])-128)*11/10+128)))} }
    let alpha=altered {p,b in if p==0 {b[p*4+3]=254} }
    let tuples:[(String,Raster,Raster,[[Double]])]=[
        ("unchanged",a,a,[]),("brighter",up,up,[]),("darker",down,down,[]),
        ("redder",red,red,[]),("contrast",contrast,contrast,[]),
        ("protected_leak",up,up,[[0,0,1,1]]),("repeat_mismatch",up,down,[]),("alpha_changed",alpha,alpha,[])]
    return try tuples.map {name,b,c,regions in
        var row=try stats(a,b,c,[0,0,1,1],regions);row["case_id"]=name;return row
    }
}
func main() throws {
    let args=Array(CommandLine.arguments.dropFirst())
    let result:Any
    if args.count==2 && args[0]=="fixture" {
        try write(fixture(),args[1]);result=["created":true]
    } else if args==["controls"] {
        result=try controls()
    } else if args.count==2 && args[0]=="measure" {
        let requests=try JSONDecoder().decode([Request].self,from:Data(contentsOf:URL(fileURLWithPath:args[1])))
        guard !requests.isEmpty,requests.count<=98 else { throw Failure.invalidInput }
        result=requests.map { request -> [String:Any] in
            do {
                let rectangles=[request.target]+request.protected
                guard rectangles.count<=17, rectangles.allSatisfy({r in r.count==4 && r.allSatisfy{$0.isFinite && $0>=0 && $0<=1} && r[0]<r[2] && r[1]<r[3]}) else { throw Failure.invalidInput }
                var row=try stats(load(request.source),load(request.output),load(request.repeated),request.target,request.protected)
                row["case_id"]=request.case_id;return row
            } catch { return ["case_id":request.case_id,"error":"pixel_input_invalid"] }
        }
    } else { throw Failure.invalidInput }
    let data=try JSONSerialization.data(withJSONObject:result,options:[.sortedKeys])
    FileHandle.standardOutput.write(data);FileHandle.standardOutput.write(Data([10]))
}
do { try main() } catch {
    FileHandle.standardOutput.write(Data("{\"error\":\"pixel_input_invalid\"}\n".utf8))
    exit(2)
}
