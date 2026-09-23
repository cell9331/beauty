// Internal in-memory transport appended to the fixed comparator prefix.
// stdout contains ephemeral pixels; only the bounded Python parent may consume it.
import BeautySDK
private enum RootSurfaceNative {
    static func samplingProof(points:[WarpControlPoint],roi:[Int],width:Int,height:Int,root:Bool) throws -> [String:Any] {
        // Refuse any input whose support would be changed by RenderableWarpPoint.
        // Conservatively retaining an inactive disk can only reject identity.
        let unchangedGeometry=points.allSatisfy { p in
            p.radius.isFinite && p.radius>=0.001 && p.radius<=1 &&
            p.target.x.isFinite && p.target.y.isFinite &&
            p.target.x>=0 && p.target.x<=1 && p.target.y>=0 && p.target.y<=1 &&
            p.source.x.isFinite && p.source.y.isFinite
        }
        guard unchangedGeometry else {
            if root { throw SemanticContractError.admission }
            return ["kind":"unsupported","source_roi_identity":false]
        }
        if !root {
            let x0=(Double(roi[0])+0.5)/Double(width),x1=(Double(roi[2])-0.5)/Double(width)
            let y0=(Double(roi[1])+0.5)/Double(height),y1=(Double(roi[3])-0.5)/Double(height)
            let clear=points.allSatisfy { p in
                let x=Double(p.target.x),y=Double(p.target.y),radius=Double(p.radius)+0.000001
                let dx=max(x0-x,0,x-x1),dy=max(y0-y,0,y-y1)
                return dx*dx+dy*dy>radius*radius
            }
            return ["kind":clear ? "identity" : "unsupported","source_roi_identity":clear]
        }
        guard !points.isEmpty,points.count%2==0,
              points.allSatisfy({$0.pixelCenterSampling && $0.source.y==$0.target.y && $0.falloff==1})
        else { throw SemanticContractError.admission }
        var bottom = -Double.infinity
        for row in stride(from:0,to:points.count,by:2) {
            let pair=Array(points[row..<row+2])
            guard HorizontalInwardWarpSafety.accepts(pair,maximumSlope:0.8),
                  pair[0].target.y==pair[1].target.y,pair[0].radius==pair[1].radius,
                  pair[0].exclusiveMaximumY==pair[1].exclusiveMaximumY,
                  Double(pair[0].target.x-pair[0].source.x)*Double(pair[1].target.x-pair[1].source.x)<0,
                  Double(pair[0].target.y)-Double(pair[0].radius)>bottom else { throw SemanticContractError.admission }
            bottom=Double(pair[0].target.y)+Double(pair[0].radius)
        }
        // These are applicability/error bounds, never the measured displacement.
        // Rows have disjoint supports; within a row the two signed inward
        // contributions oppose. Their sum cannot exceed the larger magnitude.
        var maximumDisplacement:Double=0
        for p in points {
            let displacement:Double=abs(Double(p.target.x)-Double(p.source.x))
            maximumDisplacement=max(maximumDisplacement,displacement)
        }
        let search:Int=Int(ceil(maximumDisplacement*Double(width)))+2
        return ["kind":"canonical_horizontal","minimum_slope":0.2,"maximum_slope":2.6,"maximum_displacement_pixels":search]
    }
    static func image(_ ci: CIImage, context: CIContext) throws -> CanonicalImage {
        let extent=ci.extent.integral
        guard extent==ci.extent,extent.minX==0,extent.minY==0,
              let cg=context.createCGImage(ci,from:extent) else { throw SemanticContractError.admission }
        let w=cg.width,h=cg.height
        guard w>0,h>0,w<=8192,h<=8192,w*h<=16_777_216 else { throw SemanticContractError.admission }
        var bytes=[UInt8](repeating:0,count:w*h*4)
        let ok=bytes.withUnsafeMutableBytes { raw -> Bool in
            guard let bitmap=CGContext(data:raw.baseAddress,width:w,height:h,bitsPerComponent:8,bytesPerRow:w*4,
                space:CGColorSpace(name:CGColorSpace.sRGB)!,bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return false }
            bitmap.interpolationQuality = .none;bitmap.draw(cg,in:CGRect(x:0,y:0,width:w,height:h));return true
        }
        guard ok,stride(from:3,to:bytes.count,by:4).allSatisfy({bytes[$0]==255}) else { throw SemanticContractError.admission }
        return CanonicalImage(width:w,height:h,rgba:bytes)
    }
    static func rgb(_ image:CanonicalImage,box:[Int]) throws -> String {
        let x0=box[0],y0=box[1],x1=box[2],y1=box[3]
        guard 0<=x0,x0<x1,x1<=image.width,0<=y0,y0<y1,y1<=image.height,(x1-x0)*(y1-y0)<=1_048_576
        else { throw SemanticContractError.admission }
        var bytes:[UInt8]=[];bytes.reserveCapacity((x1-x0)*(y1-y0)*3)
        for y in y0..<y1 { for x in x0..<x1 { let o=4*(y*image.width+x);bytes.append(contentsOf:image.rgba[o..<o+3]) } }
        return Data(bytes).base64EncodedString()
    }
    static func checkRaster(_ ci:CIImage,expected:CanonicalImage,context:CIContext) throws {
        var bytes=[UInt8](repeating:0,count:expected.width*expected.height*4)
        context.render(ci,toBitmap:&bytes,rowBytes:expected.width*4,bounds:ci.extent,format:.RGBA8,colorSpace:CGColorSpace(name:CGColorSpace.sRGB)!)
        guard bytes==expected.rgba else { throw SemanticContractError.admission }
    }
    static func checkHorizontalBytes(source:CanonicalImage,output:CanonicalImage,points:[WarpControlPoint],crop:[Int]) throws -> Double {
        let w=source.width,h=source.height
        var maximum=0.0
        for y in crop[1]..<crop[3] { for x in crop[0]..<crop[2] {
            let nx=(Double(x)+0.5)/Double(w),ny=(Double(y)+0.5)/Double(h)
            var q=Double(x)
            for p in points {
                if let maximumY=p.exclusiveMaximumY,y>=Int(floor(Double(maximumY)*Double(h))) { continue }
                let dx=nx-Double(p.target.x),dy=ny-Double(p.target.y)
                let weight=max(0,1-sqrt(dx*dx+dy*dy)/Double(p.radius))
                q-=(Double(p.target.x)-Double(p.source.x))*Double(w)*weight
            }
            guard q>=0,q<=Double(w-1) else { throw SemanticContractError.admission }
            let lo=Int(floor(q)),hi=min(w-1,lo+1),a=q-Double(lo)
            for c in 0..<3 {
                let expected=Double(source.rgba[(y*w+lo)*4+c])*(1-a)+Double(source.rgba[(y*w+hi)*4+c])*a
                maximum=max(maximum,abs(Double(output.rgba[(y*w+x)*4+c])-expected))
            }
        } }
        guard maximum<=1 else { throw SemanticContractError.admission }
        return maximum
    }
    static func run(render:Bool) throws -> [String:Any] {
        let root=URL(fileURLWithPath:FileManager.default.currentDirectoryPath)
        let sources=try admittedFixtureURLs(in:root.appendingPathComponent("example-images/input"))
        guard sources.count==1 else { throw SemanticContractError.admission }
        let source=sources[0],sourceHash="707e9106e394421a00732b0efa2fbd2e1dc4dfee79d9244fcc763e2dbb106818"
        guard sha256Hex(try Data(contentsOf:source))==sourceHash else { throw SemanticContractError.admission }
        let manifestData=try Data(contentsOf:root.appendingPathComponent("scripts/face-feature-batch-manifest.json"))
        guard sha256Hex(manifestData)=="5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e",
              let base=try validateManifestData(manifestData).semanticContracts else { throw SemanticContractError.admission }
        let color=CGColorSpace(name:CGColorSpace.sRGB)!,context=CIContext(options:[.workingColorSpace:CGColorSpace(name:CGColorSpace.sRGB)!, .outputColorSpace:CGColorSpace(name:CGColorSpace.sRGB)!])
        let original=try canonicalImage(at:source,context:context)
        let contracts=try portraitContracts(source:source,context:context,base:base),contractHash=try semanticContractsDigest(contracts)
        guard contractHash=="68d192c37821c4c059ac3763722bea491e5dd27850c2ab0a69ec5aa6246cd168",
              let contract=contracts.first(where:{$0.caseID=="noseRootNarrowing_0p25"}) else { throw SemanticContractError.admission }
        let region=try rasterize(contract.targetRegions[0],width:Int64(original.width),height:Int64(original.height))
        let roi=[Int(region.minX),Int(region.minY),Int(region.maxX),Int(region.maxY)]
        let crop=[max(0,roi[0]-64),max(0,roi[1]-64),min(original.width,roi[2]+64),min(original.height,roi[3]+64)]
        guard let ci=CIImage(contentsOf:source,options:[.applyOrientationProperty:true]),let cg=context.createCGImage(ci,from:ci.extent),
              try image(ci,context:context).rgba==original.rgba else { throw SemanticContractError.admission }
        _=color
        let request=VNDetectFaceLandmarksRequest();try VNImageRequestHandler(cgImage:cg,orientation:.up).perform([request])
        guard request.results?.count==1,let face=request.results?.first,let landmarks=face.landmarks else { throw SemanticContractError.admission }
        let eyes=try [landmarks.leftEye,landmarks.rightEye].map { item -> [Int] in
            guard let item,item.pointCount>=3 else { throw SemanticContractError.admission }
            let points=item.normalizedPoints.map { p in CGPoint(x:face.boundingBox.minX+CGFloat(p.x)*face.boundingBox.width,y:1-face.boundingBox.minY-CGFloat(p.y)*face.boundingBox.height) }
            return [Int(floor(points.map(\.x).min()!*CGFloat(original.width))),Int(floor(points.map(\.y).min()!*CGFloat(original.height))),Int(ceil(points.map(\.x).max()!*CGFloat(original.width))),Int(ceil(points.map(\.y).max()!*CGFloat(original.height)))]
        }
        var images=["source":try rgb(original,box:crop)],signals:[String:Any]=[:],sampling:[String:Any]=[:]
        if render {
            var detector=VisionFaceDetector()
            let detection=detector.detect(image:ci,metadata:.init(orientation:.up,source:.testFixture),imageExtent:ci.extent.size)
            guard detection.observations.count==1,let observation=detection.observations.first else { throw SemanticContractError.admission }
            let geometry=BeautyFaceGeometryAdapter.makeGeometry(from:observation)
            let canonical=try BeautyCanonicalStillImage(rgba8Data:Data(original.rgba),width:original.width,height:original.height,rowBytes:original.width*4,metadata:.init(orientation:.up,source:.testFixture))
            try checkRaster(canonical.ciImage,expected:original,context:context)
            let roles:[(String,BeautyParameters)]=[("neutral",.init()),("candidate",.init(noseRootNarrowing:0.25)),("noseBridge_0p30",.init(noseBridge:0.30)),("noseSlim_0p35",.init(noseSlim:0.35)),("noseTipLift_0p25",.init(noseTipLift:0.25))]
            var all:[String:CanonicalImage]=["source":original]
            for (role,parameters) in roles {
                let engine=try BeautyEngine(configuration:.init(renderBackend:.cpu))
                let result=try engine.processResult(image:ci,metadata:.init(orientation:.up,source:.testFixture),parameters:parameters)
                guard result.output.extent==ci.extent else { throw SemanticContractError.admission }
                let output=try image(result.output,context:context);try validateCanonicalPair(original,output)
                let plan=BeautyEffectResolver.resolve(parameters:parameters,faceGeometry:geometry)
                let points=BeautyGeometryEffectPipeline.controlPoints(for:plan,face:geometry)
                let manual=BeautyGeometryEffectPipeline.applyMVPProxy(to:canonical.ciImage,canonicalImage:canonical,plan:plan,face:geometry)
                guard try image(manual,context:context).rgba==output.rgba else { throw SemanticContractError.admission }
                try checkRaster(manual,expected:output,context:context)
                var proof=try samplingProof(points:points,roi:roi,width:original.width,height:original.height,root:role=="candidate")
                if role=="candidate" { proof["maximum_byte_error"]=try checkHorizontalBytes(source:original,output:output,points:points,crop:crop) }
                if role != "candidate" {
                    let identical=try rgb(output,box:roi)==rgb(original,box:roi)
                    proof["source_roi_identity"]=identical && (proof["source_roi_identity"] as? Bool == true)
                    if !identical { proof["kind"]="unsupported" }
                }
                sampling[role]=proof
                all[role]=output;images[role]=try rgb(output,box:crop)
            }
            guard all["neutral"]!.rgba==original.rgba else { throw SemanticContractError.admission }
            let target=try watermarkSafeRegions(contract.targetRegions,image:original,excludedRows:watermarkExcludedRows(width:original.width)),candidate=all["candidate"]!
            let signal=try regionSignal(original,candidate,include:{contains(target,x:$0,y:$1)},watermarkRows:watermarkExcludedRows(width:original.width))
            let outside=try regionSignal(original,candidate,include:{!contains(target,x:$0,y:$1)},watermarkRows:watermarkExcludedRows(width:original.width))
            var protections:[[String:Any]]=[]
            for p in contract.protectedRegions {
                let boxes=try p.regions.map{try rasterize($0,width:Int64(original.width),height:Int64(original.height))}
                let observed=try regionSignal(original,candidate,include:{contains(boxes,x:$0,y:$1)},watermarkRows:0)
                protections.append(["id":p.id,"changedPixels":observed.changedPixels,"absoluteRGBDelta":observed.absoluteRGBDelta])
            }
            signals=["targetChangedPixels":signal.changedPixels,"targetAbsoluteRGBDelta":signal.absoluteRGBDelta,"outsideChangedPixels":outside.changedPixels,"outsideAbsoluteRGBDelta":outside.absoluteRGBDelta,"protectedRegions":protections,"neutralIdentity":true]
        }
        let scale=min(1.0,512.0/Double(max(original.width,original.height))),sw=max(1,Int(Double(original.width)*min(1.0,512.0/Double(max(original.width,original.height)))))
        let sh=max(1,Int(Double(original.height)*scale));var small:[UInt8]=[]
        for y in 0..<sh { for x in 0..<sw {
            let sx=min(original.width-1,(2*x+1)*original.width/(2*sw)),sy=min(original.height-1,(2*y+1)*original.height/(2*sh)),o=4*(sy*original.width+sx)
            small.append(contentsOf:original.rgba[o..<o+3])
        } }
        guard sha256Hex(try Data(contentsOf:source))==sourceHash else { throw SemanticContractError.admission }
        return ["schema":"phase95-root-surface-pixels-v1","source_sha256":sourceHash,"contracts_sha256":contractHash,"width":original.width,"height":original.height,"roi":roi,"crop":crop,"eyes":eyes,"mesh_input":["width":sw,"height":sh,"rgb":Data(small).base64EncodedString()],"images":images,"signals":signals,"sampling":sampling]
    }
}
