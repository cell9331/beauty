import Foundation
import BeautyCore
import BeautyDetection

// Pure request-local candidate. No case IDs, oracle masks, files, or detector calls.
struct SegAutomaticCandidate {
    func protection(_ bytes: [UInt8], width w: Int, height h: Int,
                    bounds: CoordinateRect, face: BeautyFaceObservation?) -> Set<Int> {
        let n = w * h, scale = max(1, w / 512)
        guard let face, face.confidence >= 0.8,
              let contour = face.observedFaceSupport?.contour, (12...32).contains(contour.count),
              let lips = face.observedLipSupport?.outer, (8...32).contains(lips.count),
              let eyes = face.observedEyeSupport, eyes.count == 2,
              eyes.allSatisfy({ (6...32).contains($0.contour.count) }),
              bounds.width >= 0.2, bounds.height >= 0.2,
              (contour + lips + eyes.flatMap(\.contour)).allSatisfy({ $0.isFinite })
        else { return Set(0..<n) }
        let lx=lips.map(\.x).min()!, ly=lips.map(\.y).min()!
        let lipBox = CoordinateRect(x:lx,y:ly,width:lips.map(\.x).max()!-lx,height:lips.map(\.y).max()!-ly)
        let eyeBottom = eyes.flatMap(\.contour).map(\.y).max()!
        let inset = bounds.width * 0.035
        func inside(_ x: Double, _ y: Double) -> Bool {
            var contained = false
            for i in contour.indices {
                let a = contour[i], b = contour[(i + 1) % contour.count]
                if (a.y > y) != (b.y > y), x < a.x + (y-a.y)*(b.x-a.x)/(b.y-a.y) {
                    contained.toggle()
                }
                let dx=b.x-a.x, dy=b.y-a.y, length=dx*dx+dy*dy
                let t=length > 0 ? min(1,max(0,((x-a.x)*dx+(y-a.y)*dy)/length)) : 0
                if hypot(x-a.x-t*dx,y-a.y-t*dy) < inset { return false }
            }
            return contained
        }
        func nearLip(_ x: Double, _ y: Double) -> Bool {
            x >= lipBox.minX-bounds.width*0.08 && x <= lipBox.maxX+bounds.width*0.08 &&
            y >= lipBox.minY-bounds.height*0.08 && y <= lipBox.maxY+bounds.height*0.08
        }
        var excluded = Set<Int>()
        for y in 0..<h { for x in 0..<w {
            let nx=(Double(x)+0.5)/Double(w), ny=(Double(y)+0.5)/Double(h)
            let u=(nx-bounds.minX)/bounds.width, v=(ny-bounds.minY)/bounds.height
            let cheek = ((u >= 0.12 && u <= 0.42) || (u >= 0.58 && u <= 0.88)) && v >= 0.43 && v <= 0.62
            if !cheek || ny <= eyeBottom+bounds.height*0.04 || nearLip(nx,ny) || !inside(nx,ny) {
                excluded.insert(y*w+x)
            }
        }}
        // Local RGB variance, independently of closed-gradient boundary topology.
        let stride=w+1, radius=2*scale
        var flat = [Bool](repeating:true,count:n)
        for channel in 0..<3 {
            var sum=[Double](repeating:0,count:(w+1)*(h+1))
            var squares=sum
            for y in 0..<h { var row=0.0, row2=0.0; for x in 0..<w {
                let value=Double(bytes[(y*w+x)*4+channel]);row+=value;row2+=value*value
                sum[(y+1)*stride+x+1]=sum[y*stride+x+1]+row
                squares[(y+1)*stride+x+1]=squares[y*stride+x+1]+row2
            }}
            for y in 0..<h { for x in 0..<w where flat[y*w+x] {
                let a=max(0,x-radius),b=min(w,x+radius+1),c=max(0,y-radius),d=min(h,y+radius+1)
                let count=Double((b-a)*(d-c))
                let mean=(sum[d*stride+b]-sum[c*stride+b]-sum[d*stride+a]+sum[c*stride+a])/count
                let second=(squares[d*stride+b]-squares[c*stride+b]-squares[d*stride+a]+squares[c*stride+a])/count
                flat[y*w+x]=second-mean*mean <= 2.25
            }}
        }
        var visited=flat.map { !$0 }, admittedComponents=0
        for start in 0..<n where !visited[start] {
            visited[start]=true
            var queue=[start],head=0,minX=w,maxX=0,minY=h,maxY=0
            while head < queue.count {
                let p=queue[head];head+=1;let x=p%w,y=p/w
                minX=min(minX,x);maxX=max(maxX,x);minY=min(minY,y);maxY=max(maxY,y)
                for q in [x>0 ? p-1 : -1,x<w-1 ? p+1 : -1,y>0 ? p-w : -1,y<h-1 ? p+w : -1] where q>=0 {
                    if !visited[q] { visited[q]=true;queue.append(q) }
                }
            }
            let area=Double(queue.count)/Double(n)
            guard area >= 0.0004 else { continue }
            let cx=Double(minX+maxX+1)/Double(2*w),cy=Double(minY+maxY+1)/Double(2*h)
            guard cx>bounds.minX && cx<bounds.maxX && cy>bounds.minY && cy<bounds.maxY else { continue }
            // Large or non-contained smooth occlusions cannot support this route.
            if area>0.035 || !inside(cx,cy) || nearLip(cx,cy) { return Set(0..<n) }
            let compact=Double(queue.count)/Double((maxX-minX+1)*(maxY-minY+1))
            guard compact>=0.50, maxX-minX>=6*scale, maxY-minY>=6*scale else { continue }
            admittedComponents+=1
            if admittedComponents>8 { return Set(0..<n) }
            for y in max(0,minY-6*scale)...min(h-1,maxY+6*scale) {
                for x in max(0,minX-6*scale)...min(w-1,maxX+6*scale) { excluded.insert(y*w+x) }
            }
        }
        return excluded
    }
}
