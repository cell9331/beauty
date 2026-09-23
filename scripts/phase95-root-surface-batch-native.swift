import BeautyCore
import BeautyDetection
@testable import BeautyEffects
// Appended to the comparator prefix and existing RootSurfaceNative helpers.
// Decodes caller-supplied source bytes; never renders a candidate or opens a fixture path.
private enum RootSurfaceBatchNative {
    static let roles = ["source", "neutral", "candidate", "noseBridge_0p30", "noseSlim_0p35", "noseTipLift_0p25"]

    static func execute(_ request:[String:Any]) throws -> [String:Any] {
        guard Set(request.keys)==Set(["schema","source_encoded","source_sha256","source_rgba_sha256","contracts_sha256","images"]),
              request["schema"] as? String == "phase95-root-batch-native-input-v1",
              let encoded=request["source_encoded"] as? String,encoded.count<=96*1024*1024,
              let originalData=Data(base64Encoded:encoded),
              let sourceHash=request["source_sha256"] as? String,sha256Hex(originalData)==sourceHash,
              let canonicalHash=request["source_rgba_sha256"] as? String,
              let contractHash=request["contracts_sha256"] as? String,
              let received=request["images"] as? [String:String],
              received.isEmpty || Set(received.keys)==Set(roles) else { throw SemanticContractError.admission }
        let color=CGColorSpace(name:CGColorSpace.sRGB)!
        let context=CIContext(options:[.workingColorSpace:color,.outputColorSpace:color])
        guard let ci=CIImage(data:originalData,options:[.applyOrientationProperty:true]),
              let cg=context.createCGImage(ci,from:ci.extent) else { throw SemanticContractError.admission }
        let original=try RootSurfaceNative.image(ci,context:context)
        guard sha256Hex(Data(original.rgba))==canonicalHash else { throw SemanticContractError.admission }
        // Use the same raw source image for Vision as the actual renderer. All
        // numerical efficacy is subsequently derived from the received batch RGB.
        var detector=VisionFaceDetector()
        let detection=detector.detect(image:ci,metadata:.init(orientation:.up,source:.testFixture),imageExtent:ci.extent.size)
        guard detection.observations.count==1,let observation=detection.observations.first else { throw SemanticContractError.admission }
        let geometry=BeautyFaceGeometryAdapter.makeGeometry(from:observation)
        let vision=VNDetectFaceLandmarksRequest()
        try VNImageRequestHandler(cgImage:cg,orientation:.up).perform([vision])
        guard vision.results?.count==1,let face=vision.results?.first,let anatomy=face.landmarks,
              let crest=anatomy.noseCrest,crest.pointCount>=3,
              let le=anatomy.leftEye,let re=anatomy.rightEye else { throw SemanticContractError.admission }
        func mapped(_ item:VNFaceLandmarkRegion2D)->[CGPoint] {
            item.normalizedPoints.map { CGPoint(x:face.boundingBox.minX+CGFloat($0.x)*face.boundingBox.width,
                y:1-face.boundingBox.minY-CGFloat($0.y)*face.boundingBox.height) }
        }
        let eyePoints=[mapped(le),mapped(re)],crestPoints=mapped(crest).sorted{$0.y<$1.y}
        guard eyePoints.allSatisfy({$0.count>=3}) else { throw SemanticContractError.admission }
        let eyes=eyePoints.map { p in [Int(floor(p.map(\.x).min()!*CGFloat(original.width))),Int(floor(p.map(\.y).min()!*CGFloat(original.height))),Int(ceil(p.map(\.x).max()!*CGFloat(original.width))),Int(ceil(p.map(\.y).max()!*CGFloat(original.height)))] }
        let w=Double(face.boundingBox.width)
        let center=crestPoints.reduce(0.0){$0+Double($1.x)}/Double(crestPoints.count)
        let top=min(Double(crestPoints[0].y),Double(eyePoints.flatMap{$0}.map(\.y).min()!))-w*0.035
        let bottom=(Double(crestPoints[0].y)+Double(crestPoints[crestPoints.count/2].y))/2
        let region=NormalizedRegion(id:"root",minXPPM:Int(floor((center-w*0.14)*1e6)),maxXPPM:Int(ceil((center+w*0.14)*1e6)),minYPPM:Int(floor(top*1e6)),maxYPPM:Int(ceil(bottom*1e6)))
        let r=try rasterize(region,width:Int64(original.width),height:Int64(original.height))
        let roi=[Int(r.minX),Int(r.minY),Int(r.maxX),Int(r.maxY)]
        let crop=[max(0,roi[0]-64),max(0,roi[1]-64),min(original.width,roi[2]+64),min(original.height,roi[3]+64)]
        let sourceRGB=try RootSurfaceNative.rgb(original,box:crop)
        var images=["source":sourceRGB],sampling:[String:Any]=[:]
        if !received.isEmpty {
            guard received["source"]==sourceRGB else { throw SemanticContractError.admission }
            images=received
            let cw=crop[2]-crop[0],ch=crop[3]-crop[1]
            let data=try received.mapValues { value -> [UInt8] in
                guard value.count<=4*1_048_576,let bytes=Data(base64Encoded:value),bytes.count==cw*ch*3 else { throw SemanticContractError.admission }
                return Array(bytes)
            }
            let params:[(String,BeautyParameters)]=[("neutral",.init()),("candidate",.init(noseRootNarrowing:0.25)),("noseBridge_0p30",.init(noseBridge:0.30)),("noseSlim_0p35",.init(noseSlim:0.35)),("noseTipLift_0p25",.init(noseTipLift:0.25))]
            for (role,parameters) in params {
                let plan=BeautyEffectResolver.resolve(parameters:parameters,faceGeometry:geometry)
                let points=BeautyGeometryEffectPipeline.controlPoints(for:plan,face:geometry)
                var proof=try RootSurfaceNative.samplingProof(points:points,roi:roi,width:original.width,height:original.height,root:role=="candidate")
                if role=="candidate" {
                    var error=0.0
                    for y in crop[1]..<crop[3] { for x in crop[0]..<crop[2] {
                        let nx=(Double(x)+0.5)/Double(original.width),ny=(Double(y)+0.5)/Double(original.height)
                        var q=Double(x)
                        for p in points {
                            if let limit=p.exclusiveMaximumY,y>=Int(floor(Double(limit)*Double(original.height))) {continue}
                            let dx=nx-Double(p.target.x),dy=ny-Double(p.target.y)
                            let weight=max(0,1-sqrt(dx*dx+dy*dy)/Double(p.radius))
                            q-=(Double(p.target.x)-Double(p.source.x))*Double(original.width)*weight
                        }
                        guard q>=0,q<=Double(original.width-1) else { throw SemanticContractError.admission }
                        let lo=Int(floor(q)),hi=min(lo+1,original.width-1),a=q-Double(lo)
                        for c in 0..<3 {
                            let expected=Double(original.rgba[(y*original.width+lo)*4+c])*(1-a)+Double(original.rgba[(y*original.width+hi)*4+c])*a
                            error=max(error,abs(Double(data[role]![((y-crop[1])*cw+x-crop[0])*3+c])-expected))
                        }
                    } }
                    guard error<=1 else { throw SemanticContractError.admission }
                    proof["maximum_byte_error"]=error
                } else {
                    var identical=true
                    for y in roi[1]..<roi[3] { for x in roi[0]..<roi[2] { for c in 0..<3 {
                        let i=((y-crop[1])*cw+x-crop[0])*3+c
                        identical = identical && data[role]![i]==data["source"]![i]
                    } } }
                    proof["source_roi_identity"]=identical && (proof["source_roi_identity"] as? Bool == true)
                    if !identical { proof["kind"]="unsupported" }
                }
                sampling[role]=proof
            }
            guard data["neutral"]==data["source"] else { throw SemanticContractError.admission }
        }
        let scale=min(1.0,512.0/Double(max(original.width,original.height)))
        let sw=max(1,Int(Double(original.width)*scale)),sh=max(1,Int(Double(original.height)*scale))
        var small:[UInt8]=[]
        for y in 0..<sh { for x in 0..<sw {
            let sx=min(original.width-1,(2*x+1)*original.width/(2*sw)),sy=min(original.height-1,(2*y+1)*original.height/(2*sh)),o=(sy*original.width+sx)*4
            small.append(contentsOf:original.rgba[o..<o+3])
        } }
        return ["schema":"phase95-root-surface-pixels-v1","source_sha256":sourceHash,"contracts_sha256":contractHash,
            "width":original.width,"height":original.height,"roi":roi,"crop":crop,"eyes":eyes,
            "mesh_input":["width":sw,"height":sh,"rgb":Data(small).base64EncodedString()],"images":images,"signals":[:],"sampling":sampling]
    }
}
