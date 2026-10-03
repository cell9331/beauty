import Foundation
import BeautyCore
import BeautyDetection

// Pure candidate: canonical pixels and actual face bounds only.
struct SegAutomaticCandidate {
    struct Raster {
        let bytes: [UInt8]; let width: Int; let height: Int
        func luma(_ p: Int) -> Double {
            let k=p*4
            return (77*Double(bytes[k])+150*Double(bytes[k+1])+29*Double(bytes[k+2]))/256
        }
    }
    func protection(_ bytes:[UInt8], width:Int, height:Int, bounds:CoordinateRect) -> Set<Int> {
        segCandidate(Raster(bytes:bytes,width:width,height:height),bounds)
    }
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
}
