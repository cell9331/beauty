import Foundation

extension RetouchTerminalTests {
    struct Bounds {
        let x0: Int, x1: Int, y0: Int, y1: Int
        var width: Int { x1-x0+1 }
        var height: Int { y1-y0+1 }
        func taper(_ x: Int, _ y: Int) -> Double {
            let u=Double(x-x0)/Double(x1-x0),v=Double(y-y0)/Double(y1-y0)
            return pow(sin(.pi*u)*sin(.pi*v),2)
        }
    }
    func bounds(_ image: Raster) -> [Bounds] {
        requests(image).compactMap { request in
            let e=request.permittedEnvelope
            let b=Bounds(x0:max(0,Int(ceil(e.minX*Double(image.width)))),
                x1:min(image.width-1,Int(floor((e.minX+e.width)*Double(image.width)))-1),
                y0:max(0,Int(ceil(e.minY*Double(image.height)))),
                y1:min(image.height-1,Int(floor((e.minY+e.height)*Double(image.height)))-1))
            return b.width>6 && b.height>6 ? b : nil
        }
    }
    func quantile(_ values: [Double], _ fraction: Double) -> Double {
        let sorted=values.sorted()
        return sorted[Int(Double(sorted.count-1)*fraction)]
    }
    func apply(_ delta: Double, _ p: Int, _ strength: Double, _ image: Raster, _ output: inout Raster) {
        let d=Int((delta*strength).rounded())
        for c in 0..<3 { output.bytes[p*4+c]=UInt8(clamping:Int(image.bytes[p*4+c])-d) }
    }
    func candidateE1V2(_ image: Raster, _ strength: Double) -> Raster {
        guard strength>0 else { return image }
        var output=image
        for b in bounds(image) {
            let lower=quantile((b.x0...b.x1).map{image.luma(b.y0*image.width+$0,eye:true)},0.5)
            let upper=quantile((b.x0...b.x1).map{image.luma(b.y1*image.width+$0,eye:true)},0.5)
            let radius=max(1,(b.height-1)/4)
            var corrections=[(Int,Double)](),center=0.0,count=0
            for y in b.y0...b.y1 { for x in b.x0...b.x1 {
                var local=0.0,samples=0
                for dy in -radius...radius { for dx in -radius...radius {
                    let q=min(b.y1,max(b.y0,y+dy))*image.width+min(b.x1,max(b.x0,x+dx))
                    local+=image.luma(q,eye:true);samples+=1
                }}
                let u=Double(x-b.x0)/Double(b.width-1),v=Double(y-b.y0)/Double(b.height-1)
                let residual=local/Double(samples)-(lower*(1-v)+upper*v)
                if u>0.25 && u<0.75 && v>0.25 && v<0.75 { center+=residual;count+=1 }
                corrections.append((y*image.width+x,min(4,max(0,residual)*0.18)*b.taper(x,y)))
            }}
            guard count>0 && center/Double(count)>3 else { continue }
            for (p,delta) in corrections { apply(delta,p,strength,image,&output) }
        }
        return output
    }
    func highlightCorrection(_ image: Raster, _ b: Bounds) -> [Double] {
        var boundary=[Double]()
        for x in b.x0...b.x1 {
            boundary.append(image.luma(b.y0*image.width+x,eye:true))
            boundary.append(image.luma(b.y1*image.width+x,eye:true))
        }
        for y in (b.y0+1)..<b.y1 {
            boundary.append(image.luma(y*image.width+b.x0,eye:true))
            boundary.append(image.luma(y*image.width+b.x1,eye:true))
        }
        let level=quantile(boundary,0.75)+3
        var field=[Double](repeating:0,count:b.width*b.height)
        for y in b.y0...b.y1 { for x in b.x0...b.x1 {
            field[(y-b.y0)*b.width+x-b.x0]=min(4,max(0,image.luma(y*image.width+x,eye:true)-level)*0.20)
        }}
        return field
    }
    func candidateE2V1(_ image: Raster, _ strength: Double) -> Raster {
        guard strength>0 else { return image }
        var output=image
        for b in bounds(image) {
            let field=highlightCorrection(image,b)
            for y in b.y0...b.y1 { for x in b.x0...b.x1 {
                apply(field[(y-b.y0)*b.width+x-b.x0]*b.taper(x,y),y*image.width+x,strength,image,&output)
            }}
        }
        return output
    }
    func candidateE2V2(_ image: Raster, _ strength: Double) -> Raster {
        guard strength>0 else { return image }
        var output=image
        for b in bounds(image) {
            let field=highlightCorrection(image,b),radius=max(1,(b.height-1)/3)
            for y in b.y0...b.y1 { for x in b.x0...b.x1 {
                var average=0.0,count=0
                for dy in -radius...radius { for dx in -radius...radius {
                    let row=min(b.height-1,max(0,y-b.y0+dy)),column=min(b.width-1,max(0,x-b.x0+dx))
                    average+=field[row*b.width+column];count+=1
                }}
                apply(average/Double(count)*b.taper(x,y),y*image.width+x,strength,image,&output)
            }}
        }
        return output
    }
}
