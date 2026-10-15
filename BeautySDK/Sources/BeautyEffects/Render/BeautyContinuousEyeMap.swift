import BeautyCore
import Foundation

/// Request-local, source-anchored eye deformation. Detector samples define an
/// organ frame, not a sum of point pulls. Both still-image backends derive
/// every output from immutable source; dense iris blends two inverse color
/// samples. Cap admission bounds the bilinear lattices, not raster color or
/// occlusion gates.
struct BeautyContinuousEyeMap {
    static var keys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] { [
        \.eyeSize, \.eyeYPosition, \.eyeHeight, \.eyeLength, \.eyeDistance,
        \.pupilSize, \.lowerEyelidDrop, \.eyeTailLift, \.eyeTilt,
        \.innerCornerOpen, \.outerCornerOpen
    ] }
    static var caps: [Float] { [
        BeautySafetyCaps.eyeSize, BeautySafetyCaps.eyeYPosition,
        BeautySafetyCaps.eyeHeight, BeautySafetyCaps.eyeLength,
        BeautySafetyCaps.eyeDistance, BeautySafetyCaps.pupilSize,
        BeautySafetyCaps.lowerEyelidDrop, BeautySafetyCaps.eyeTailLift,
        BeautySafetyCaps.eyeTilt, BeautySafetyCaps.innerCornerOpen,
        BeautySafetyCaps.outerCornerOpen
    ] }
    static func replacesLegacy(for face: FaceGeometry) -> Bool {
        face.leftEyeSupport != nil || face.rightEyeSupport != nil
    }

    private struct Eye {
        let center: SIMD2<Double>
        let axisX: SIMD2<Double>
        let axisY: SIMD2<Double>
        let contour: [SIMD2<Double>]
        let span: Double
        let halfHeight: Double
        let apertureOffset: Double
        let apertureHalfHeight: Double
        let visibleSpan: Double
        let horizontalPivot: Double
        let side: Double
        let pupil: SIMD2<Double>?
        let irisRadius: Double?
        let protection: [[Double]]
        let shapeProtection: [[Double]]
        var spacingMidline: Double? = nil
        var registeredLowerCore = false
        var lowerCenterX: Double? = nil
        var lowerVisibleSpan: Double? = nil

        // Derived only from the immutable observed contour and bounded visible
        // width refinement. It is geometry, not a new tissue/iris inference.
        var upperLid: [(SIMD2<Double>,SIMD2<Double>)] = []

        func local(_ p: SIMD2<Double>) -> SIMD2<Double> {
            let d = p-center
            return SIMD2(d.x*axisX.x+d.y*axisX.y, d.x*axisY.x+d.y*axisY.y)
        }

        func lowerClearance(_ q: SIMD2<Double>) -> Double {
            var boundary=Double.infinity,distance=Double.infinity
            var lo=Double.infinity,hi = -Double.infinity
            for (a,b) in upperLid {
                lo=min(lo,a.x,b.x);hi=max(hi,a.x,b.x)
                let dx=b.x-a.x
                if abs(dx)>1e-9,q.x >= min(a.x,b.x),q.x <= max(a.x,b.x) {
                    boundary=min(boundary,a.y+(q.x-a.x)*(b.y-a.y)/dx)
                }
                let v=b-a,d=q-a,length=v.x*v.x+v.y*v.y
                if length>0 {
                    let t=min(1,max(0,(d.x*v.x+d.y*v.y)/length)),offset=d-v*t
                    distance=min(distance,hypot(offset.x,offset.y))
                }
            }
            guard boundary.isFinite,q.y>boundary else { return 0 }
            // Fix the upper trace plus a narrow source-scaled neighborhood;
            // use Euclidean distance so sloping lids do not amplify gradients.
            // Preserve the sampling neighborhood on small apertures;
            // scale the margin on larger ones without freezing a large band
            // of a shallow lower lid merely because its horizontal span grew.
            // A dense iris with RGB contrast confirmed at its observed core uses
            // a source-scaled raster rim; sparse/ambiguous evidence keeps the
            // wider sampling neighborhood. This keeps preview/original rims
            // proportionate without borrowing unsupported iris evidence.
            let margin=registeredLowerCore
                ? max(1.5,span*0.0170):max(3.5,span*0.015)
            return max(0,min(distance-margin,q.x-lo,hi-q.x))
        }
    }

    private struct SparsePupilAperture {
        let contour: [SIMD2<Double>]
        let featherDistance: Double
    }

    private struct DensePupilAperture {
        let contour: [SIMD2<Double>]
        let protectedRim: Double
        let featherDistance: Double
        let corners: [SIMD2<Double>]
        let cornerRim: Double
        let pupil: SIMD2<Double>
        let radius: Double
        let protection: [[Double]]
        let irisOffsets: [SIMD2<Double>]
        let projectsOcclusion: Bool
    }

    private let xs: [Double]
    private let ys: [Double]
    private let offsets: [SIMD2<Double>]
    private let irisOffsets: [SIMD2<Double>]
    private let irisApertures: [[SIMD2<Double>]]
    private let sparseIrisOffsets: [SIMD2<Double>]
    private let sparsePupilApertures: [SparsePupilAperture]
    private let densePupilApertures: [DensePupilAperture]
    let width: Int
    let height: Int
    let maximumGradient: Double
    let maximumDisplacement: Double

    init?(width: Int, height: Int, face: FaceGeometry, strengths: BeautyEffectiveStrengths,
          sourceRGBA: [UInt8]? = nil) {
        guard width > 1, height > 1,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              face.freshness == .fresh,
              Self.keys.allSatisfy({ strengths[keyPath: $0].isFinite }),
              Self.keys.contains(where: { strengths[keyPath: $0] != 0 })
        else { return nil }
        let w=Double(width), h=Double(height)
        func pixel(_ p: SIMD2<Float>) -> SIMD2<Double> { SIMD2(Double(p.x)*w,Double(p.y)*h) }
        func box(_ points: [SIMD2<Float>], pad: Double = 1.5) -> [Double]? {
            guard !points.isEmpty, points.allSatisfy(Self.valid) else { return nil }
            let p=points.map(pixel)
            return [p.map(\.x).min()!-pad,p.map(\.x).max()!+pad,
                    p.map(\.y).min()!-pad,p.map(\.y).max()!+pad]
        }
        let supports=[face.leftEyeSupport,face.rightEyeSupport].compactMap { $0 }
        let featurePaths=[face.nose+face.noseTip+face.noseRoot,face.outerLips,
            face.observedEyebrowSupport?.left?.points ?? [],
            face.observedEyebrowSupport?.right?.points ?? []]
        let protectedBoxes=featurePaths.compactMap { box($0) }
        // A combined nose/root/tip rectangle also covers unobserved space
        // beside the bridge. The five whole-eye controls preserve each source
        // path's envelope separately rather than fixing that intervening space.
        let shapePaths=[face.nose,face.noseTip,face.noseRoot,face.outerLips,
            face.observedEyebrowSupport?.left?.points ?? [],
            face.observedEyebrowSupport?.right?.points ?? []]
        var shapeBoxes=shapePaths.compactMap { box($0) }
        let browPoints=(face.observedEyebrowSupport?.left?.points ?? [])
            + (face.observedEyebrowSupport?.right?.points ?? [])
        // Preserve the source brow band between the two observed traces too.
        // A broader translation envelope must not introduce forehead drift.
        if let band=box(browPoints),face.observedEyebrowSupport?.left != nil,
           face.observedEyebrowSupport?.right != nil { shapeBoxes.append(band) }
        var eyes=[Eye]()
        for support in supports {
            guard (4...64).contains(support.contour.count),
                  support.contour.allSatisfy(Self.valid), Self.valid(support.center),
                  BeautyDenseFaceSupport.simplePolygon(support.contour),
                  let inner=support.inner.first, let outer=support.outer.first,
                  Self.valid(inner), Self.valid(outer)
            else { continue }
            let a=pixel(inner), b=pixel(outer)
            var vector=b-a
            if vector.x < 0 { vector = -vector }
            let span=hypot(vector.x,vector.y)
            guard span >= 6, span < min(w,h)*0.45, vector.x > span*0.40 else { continue }
            let axisX=vector/span, axisY=SIMD2(-axisX.y,axisX.x)
            let center=(a+b)*0.5
            let contour=support.contour.map(pixel)
            let heights=contour.map { p -> Double in
                let d=p-center; return d.x*axisY.x+d.y*axisY.y
            }
            let top=heights.min()!, bottom=heights.max()!
            guard top < -0.5, bottom > 0.5,
                  bottom-top >= span*0.08, bottom-top <= span*0.85
            else { continue }
            var pupil: SIMD2<Double>?, radius: Double?
            if let sourcePupil=support.pupil, Self.valid(sourcePupil) {
                let p=pixel(sourcePupil)
                if let ring=face.denseSupport?.iris(side:support.side,eye:support) {
                    let distances=ring.map { let d=pixel($0)-p; return hypot(d.x,d.y) }
                    let r=distances.reduce(0,+)/Double(distances.count)
                    if r.isFinite, r >= 1, r <= span*0.32 {
                        pupil=p; radius=r
                    }
                } else if face.denseSupport == nil, Self.contains(p,contour),
                          Self.distanceToContour(p,contour) >= 1 {
                    // A measured pupil center and aperture permit only the
                    // bounded positive compatibility transform. They do not
                    // establish an iris radius or evidence for shrinking it.
                    pupil=p
                }
            }
            // An observed corner can sit inside the visible lash boundary.
            // Refine only a bounded, strongly registered dark RGB aperture;
            // monochannel marks, transparent pixels and ambiguous edges keep
            // the measured geometric span/pivot. This does not infer tissue.
            let visible=Self.visibleAperture(sourceRGBA,width:width,height:height,
                center:center,axisX:axisX,axisY:axisY,span:span,
                offset:(top+bottom)*0.5,halfHeight:(bottom-top)*0.5)
            let peerBoxes=supports.filter { $0.side != support.side }.compactMap { box($0.contour) }
            eyes.append(Eye(center:center,axisX:axisX,axisY:axisY,contour:contour,
                span:span,halfHeight:max(abs(top),abs(bottom)),
                apertureOffset:(top+bottom)*0.5,apertureHalfHeight:(bottom-top)*0.5,
                visibleSpan:visible?.span ?? span,horizontalPivot:visible?.pivot ?? 0,
                side:support.side == .left ? -1:1,pupil:pupil,irisRadius:radius,
                protection:protectedBoxes+peerBoxes,shapeProtection:shapeBoxes+peerBoxes))
        }
        guard !eyes.isEmpty else { return nil }
        let left=eyes.first(where:{ $0.side < 0 }),right=eyes.first(where:{ $0.side > 0 })
        let paired:Bool
        if eyes.count == 2,let left,let right {
            paired=left.center.x+left.span*left.axisX.x*0.5+1
                < right.center.x-right.span*right.axisX.x*0.5
        } else { paired=false }
        if paired,let a=supports.first(where:{ $0.side == .left })?.inner.first,
           let b=supports.first(where:{ $0.side == .right })?.inner.first,
           let lipBox=box(face.outerLips) {
            let left=pixel(a),right=pixel(b),gap=right.x-left.x
            let top=min(left.y,right.y)-1.5
            if gap > 0,lipBox[2] > top {
                let pad=min(1.5,gap/6)
                let bridge=[left.x+gap/3-pad,right.x-gap/3+pad,top,lipBox[2]+1.5]
                eyes=eyes.map { eye in
                    Eye(center:eye.center,axisX:eye.axisX,axisY:eye.axisY,
                        contour:eye.contour,span:eye.span,halfHeight:eye.halfHeight,
                        apertureOffset:eye.apertureOffset,apertureHalfHeight:eye.apertureHalfHeight,
                        visibleSpan:eye.visibleSpan,horizontalPivot:eye.horizontalPivot,
                        side:eye.side,pupil:eye.pupil,irisRadius:eye.irisRadius,
                        protection:eye.protection,shapeProtection:eye.shapeProtection+[bridge])
                }
            }
        }
        if paired {
            let midline=(eyes[0].center.x+eyes[1].center.x)*0.5
            for i in eyes.indices { eyes[i].spacingMidline=midline }
        }
        if strengths.lowerEyelidDrop != 0 || strengths.outerCornerOpen != 0 {
            for i in eyes.indices {
                eyes[i].registeredLowerCore=Self.registeredLowerCore(sourceRGBA,width:width,height:height,eye:eyes[i])
                let eye=eyes[i]
                // A local lid lobe can register a moderately narrower visible
                // aperture without changing the whole-eye scale or admitting
                // new geometric support. Keep the same three-row coherence.
                if let visible=Self.visibleAperture(sourceRGBA,width:width,height:height,
                    center:eye.center,axisX:eye.axisX,axisY:eye.axisY,span:eye.span,
                    offset:eye.apertureOffset,halfHeight:eye.apertureHalfHeight,
                    minimumSpanRatio:0.80,pivotLimit:0.22,coherentRows:true) {
                    eyes[i].lowerCenterX=eye.center.x+eye.axisX.x*visible.pivot
                    eyes[i].lowerVisibleSpan=visible.span
                }

            }
        }
        for i in eyes.indices {
            let eye=eyes[i],local=eye.contour.map(eye.local)
            func upper(_ x:Double) -> Double {
                var result=Double.infinity
                for j in local.indices {
                    let a=local[j],b=local[(j+1)%local.count],dx=b.x-a.x
                    if abs(dx)>1e-9,x >= min(a.x,b.x),x <= max(a.x,b.x) {
                        result=min(result,a.y+(x-a.x)*(b.y-a.y)/dx)
                    }
                }
                return result
            }
            for j in local.indices {
                let a=local[j],b=local[(j+1)%local.count],mid=(a+b)*0.5
                guard abs(a.x-b.x)>1e-9,abs(mid.y-upper(mid.x))<1e-6 else { continue }
                func visible(_ p:SIMD2<Double>) -> SIMD2<Double> {
                    // The local lower-lid lobe and its upper zero boundary must
                    // share one source frame. A stricter whole-eye fallback
                    // must not clip a separately registered visible lid.
                    let width=strengths.lowerEyelidDrop != 0
                        ? (eye.lowerVisibleSpan ?? eye.visibleSpan):eye.visibleSpan
                    let pivot=strengths.lowerEyelidDrop != 0
                        ? eye.lowerCenterX.map { ($0-eye.center.x)/eye.axisX.x } ?? eye.horizontalPivot
                        : eye.horizontalPivot
                    return SIMD2(p.x*width/eye.span+pivot,p.y)
                }
                eyes[i].upperLid.append((visible(a),visible(b)))
            }
        }
        // A single admitted eye can edit itself, but paired spacing needs both.
        var actualStrengths=strengths
        if !paired { actualStrengths.eyeDistance=0 }
        if actualStrengths.pupilSize < 0 {
            if eyes.allSatisfy({ $0.irisRadius == nil }) { actualStrengths.pupilSize=0 }
        } else if eyes.allSatisfy({ $0.pupil == nil }) { actualStrengths.pupilSize=0 }
        guard Self.keys.contains(where: { actualStrengths[keyPath:$0] != 0 }) else { return nil }
        for (key,limit) in zip(Self.keys,Self.caps) {
            let v=actualStrengths[keyPath:key]
            actualStrengths[keyPath:key]=min(limit,max(-limit,v))
        }
        // Uniform local grids and mandatory protected edges are independent of
        // strength and mesh density. The grid owns an explicit fixed boundary.
        var xNodes=[Double](), yNodes=[Double]()
        for eye in eyes {
            let r=eye.span*1.12
            let loX=max(0,eye.center.x-r), hiX=min(w,eye.center.x+r)
            let loY=max(0,eye.center.y-r), hiY=min(h,eye.center.y+r)
            xNodes += (0...48).map { loX+(hiX-loX)*Double($0)/48 }
            yNodes += (0...48).map { loY+(hiY-loY)*Double($0)/48 }
            for b in eye.protection+eye.shapeProtection { xNodes += [b[0],b[1]]; yNodes += [b[2],b[3]] }
            // Source anatomy, never active strengths, selects these knots.
            // Keep the sparse and dense grids stable through sibling zero.
            let anchors=[eye.center,
                eye.contour.min(by:{ $0.x < $1.x })!,eye.contour.max(by:{ $0.x < $1.x })!,
                eye.contour.min(by:{ $0.y < $1.y })!,eye.contour.max(by:{ $0.y < $1.y })!]
            xNodes += anchors.map(\.x);yNodes += anchors.map(\.y)
            if let midline=eye.spacingMidline { xNodes.append(midline) }
        }
        let loX=max(0,eyes.map { $0.center.x-$0.span*1.12 }.min()!)
        let hiX=min(w,eyes.map { $0.center.x+$0.span*1.12 }.max()!)
        let loY=max(0,eyes.map { $0.center.y-$0.span*1.12 }.min()!)
        let hiY=min(h,eyes.map { $0.center.y+$0.span*1.12 }.max()!)
        let xs=Array(Set(xNodes.filter { $0 >= loX && $0 <= hiX })).sorted()
        let ys=Array(Set(yNodes.filter { $0 >= loY && $0 <= hiY })).sorted()
        guard xs.count > 1,ys.count > 1,xs.count <= 160,ys.count <= 160 else { return nil }
        func gradient(_ deltas:[SIMD2<Double>]) -> Double {
            var result=0.0
            for row in 0..<(ys.count-1) { for col in 0..<(xs.count-1) {
                let i=row*xs.count+col
                let tl=deltas[i],tr=deltas[i+1],bl=deltas[i+xs.count],br=deltas[i+xs.count+1]
                let dx=xs[col+1]-xs[col],dy=ys[row+1]-ys[row]
                // Every derivative of the bilinear cell is a convex blend of
                // these edge derivatives; the norm bound therefore holds inside.
                for gx in [(tr-tl)/dx,(br-bl)/dx] { for gy in [(bl-tl)/dy,(br-tr)/dy] {
                    result=max(result,sqrt(gx.x*gx.x+gx.y*gx.y+gy.x*gy.x+gy.y*gy.y))
                } }
            } }
            return result
        }
        func magnitude(_ deltas:[SIMD2<Double>]) -> Double {
            deltas.map { hypot($0.x,$0.y) }.max() ?? 0
        }
        let span=eyes.map(\.span).min()!
        var actual=[SIMD2<Double>](repeating:.zero,count:xs.count*ys.count)
        var iris=actual
        var sparseIris=actual
        let denseEyeIndices=actualStrengths.pupilSize != 0
            ? eyes.indices.filter { eyes[$0].pupil != nil && eyes[$0].irisRadius != nil }:[]
        var denseIris=denseEyeIndices.map { _ in actual }
        // Each organ component is admitted against its own immutable source
        // and positive cap. Adding an arbitrarily small sibling must not admit
        // that sibling at full cap and abruptly rescale an existing edit.
        for (key,limit) in zip(Self.keys,Self.caps) where actualStrengths[keyPath:key] != 0 {
            var capped=BeautyEffectiveStrengths();capped[keyPath:key]=limit
            var component=[SIMD2<Double>]();component.reserveCapacity(actual.count)
            let hasSparseComponent=key == \.pupilSize && eyes.contains { $0.pupil != nil && $0.irisRadius == nil }
            var sparseComponent=[SIMD2<Double>]()
            if hasSparseComponent { sparseComponent.reserveCapacity(actual.count) }
            var denseComponents=key == \.pupilSize
                ? denseEyeIndices.map { _ in [SIMD2<Double>]() }:[]
            for index in denseComponents.indices { denseComponents[index].reserveCapacity(actual.count) }
            for y in ys { for x in xs {
                var d=SIMD2<Double>.zero
                var sparse=SIMD2<Double>.zero
                for index in denseComponents.indices { denseComponents[index].append(.zero) }
                if x != xs.first! && x != xs.last! && y != ys.first! && y != ys.last! {
                    for (eyeIndex,eye) in eyes.enumerated() {
                        let delta=Self.displacement(SIMD2(x,y),eye:eye,values:capped)
                        d += delta
                        if hasSparseComponent && eye.irisRadius == nil { sparse += delta }
                        if key == \.pupilSize,let index=denseEyeIndices.firstIndex(of:eyeIndex) {
                            denseComponents[index][component.count]=delta
                        }
                    }
                }
                component.append(d)
                if hasSparseComponent { sparseComponent.append(sparse) }
            } }
            let mixedSparse=hasSparseComponent && !denseComponents.isEmpty
            let capMagnitude=max(magnitude(component),denseComponents.map(magnitude).max() ?? 0,
                                 mixedSparse ? magnitude(sparseComponent):0)
            let capGradient=max(gradient(component),denseComponents.map(gradient).max() ?? 0,
                                mixedSparse ? gradient(sparseComponent):0)
            guard capMagnitude.isFinite,capGradient.isFinite else { return nil }
            if capMagnitude == 0 { continue }
            let admission=min(1,capGradient > 0 ? 0.45/capGradient:1,span*0.15/capMagnitude)
            // The outer-corner endpoint keeps a softer admitted response than
            // the geometric ceiling. Apply this after admission so a change
            // of field steepness cannot cancel the intended response gain.
            let responseGain=key == \.outerCornerOpen ? 0.93:1.0
            let fraction=Double(actualStrengths[keyPath:key]/limit)*admission*responseGain
            for i in actual.indices {
                let delta=component[i]*fraction
                actual[i] += delta
                if key == \.pupilSize {
                    iris[i]=delta
                    if hasSparseComponent { sparseIris[i]=sparseComponent[i]*fraction }
                    for index in denseIris.indices { denseIris[index][i]=denseComponents[index][i]*fraction }
                }
            }
        }
        // Raster containment selects the shape-only field outside the iris
        // aperture. Include that actual field in the joint bound as well:
        // iris/shape cancellation must not hide an out-of-aperture excess.
        let shape=zip(actual,iris).map { $0-$1 }
        var ownedFull=denseIris.map { field in zip(shape,field).map { $0+$1 } }
        // Negative occlusion projects between these full/hybrid endpoints;
        // both lattices retain the existing joint bounds before projection.
        let ownedHybrid=ownedFull.map { field in zip(field,shape).map { SIMD2($0.x,$1.y) } }
        if !denseIris.isEmpty,actualStrengths.pupilSize > 0,
           eyes.contains(where: { $0.pupil != nil && $0.irisRadius == nil }) {
            ownedFull.append(zip(shape,sparseIris).map { $0+$1 })
        }
        let actualMagnitude=max(magnitude(actual),magnitude(shape),ownedFull.map(magnitude).max() ?? 0,
                                ownedHybrid.map(magnitude).max() ?? 0)
        let g=max(gradient(actual),gradient(shape),ownedFull.map(gradient).max() ?? 0,
                  ownedHybrid.map(gradient).max() ?? 0)
        let pose=Double(face.denseSupport?.geometryScale ?? 1)
        guard actualMagnitude.isFinite,actualMagnitude > 0,g.isFinite,pose.isFinite,pose > 0 else { return nil }
        // Only the actual combination receives the final joint safety bound.
        // Both the cap admission and this bound are continuous through zero.
        let scale=min(1,g > 0 ? 0.45/g:1,span*0.15/actualMagnitude)*pose
        self.width=width;self.height=height;self.xs=xs;self.ys=ys
        irisApertures=actualStrengths.pupilSize != 0
            ? eyes.filter { $0.pupil != nil }.map(\.contour):[]
        irisOffsets=irisApertures.isEmpty ? []:iris.map { $0*scale }
        sparsePupilApertures=actualStrengths.pupilSize > 0
            ? eyes.filter { $0.pupil != nil && $0.irisRadius == nil }.map {
                SparsePupilAperture(contour:$0.contour,featherDistance:max(1,$0.halfHeight*0.45))
            }:[]
        sparseIrisOffsets=sparsePupilApertures.isEmpty ? []:sparseIris.map { $0*scale }
        densePupilApertures=denseEyeIndices.enumerated().map { index,eyeIndex in
                let eye=eyes[eyeIndex],radius=eye.irisRadius!
                return DensePupilAperture(contour:eye.contour,protectedRim:max(1.5,radius*0.20),
                    featherDistance:max(1,radius*0.25),
                    corners:[eye.contour.min(by: { $0.x < $1.x })!,
                             eye.contour.max(by: { $0.x < $1.x })!],
                    cornerRim:max(1.5,radius*0.20),pupil:eye.pupil!,radius:radius,
                    protection:eye.protection,
                    irisOffsets:denseIris[index].map { $0*scale },
                    projectsOcclusion:actualStrengths.pupilSize < 0)
            }
        offsets=actual.map { $0*scale }
        maximumGradient=g*scale
        maximumDisplacement=actualMagnitude*scale
    }

    private static func valid(_ p:SIMD2<Float>) -> Bool {
        p.x.isFinite && p.y.isFinite && (0...1).contains(p.x) && (0...1).contains(p.y)
    }
    private static func visibleAperture(_ bytes:[UInt8]?,width:Int,height:Int,
        center:SIMD2<Double>,axisX:SIMD2<Double>,axisY:SIMD2<Double>,
        span:Double,offset:Double,halfHeight:Double,
        minimumSpanRatio:Double = 0.98,pivotLimit:Double = 0.12,
        coherentRows:Bool = false) -> (span:Double,pivot:Double)? {
        guard let bytes,bytes.count == width*height*4,halfHeight >= 2 else { return nil }
        func pixel(_ x:Double,_ y:Double) -> SIMD3<Double>? {
            let p=center+axisX*x+axisY*(y+offset)
            let ix=Int(p.x.rounded()),iy=Int(p.y.rounded())
            guard ix >= 0,ix < width,iy >= 0,iy < height else { return nil }
            let i=(iy*width+ix)*4
            guard bytes[i+3] == 255 else { return nil }
            return SIMD3(Double(bytes[i]),Double(bytes[i+1]),Double(bytes[i+2]))
        }
        var skin=[SIMD3<Double>]()
        for sign:Double in [-1,1] { for x:Double in [-0.15,0,0.15] { for dy:Double in [-1,0,1] {
            if let p=pixel(x*span,sign*halfHeight*2+dy) { skin.append(p) }
        } } }
        guard skin.count == 18 else { return nil }
        func median(_ values:[Double]) -> Double { values.sorted()[values.count/2] }
        let reference=SIMD3(median(skin.map(\.x)),median(skin.map(\.y)),median(skin.map(\.z)))
        let threshold=SIMD3(max(18,reference.x*0.12),max(18,reference.y*0.12),max(18,reference.z*0.12))
        var edges=[(Double,Double)]()
        let radius=Int(ceil(span*0.72))
        for row in -4...4 {
            let y=Double(row)*halfHeight*0.20
            let dark=(-radius...radius).compactMap { x -> Double? in
                guard let p=pixel(Double(x),y) else { return nil }
                let d=reference-p
                return d.x > threshold.x && d.y > threshold.y && d.z > threshold.z ? Double(x):nil
            }
            if let first=dark.first,let last=dark.last,last-first >= span*0.80,
               first > -Double(radius),last < Double(radius) {
                edges.append((first,last))
            }
        }
        guard edges.count >= 3 else { return nil }
        // The three widest rows must independently agree on both boundaries.
        // A union of displaced shadows is not a registered aperture. Require
        // coherence before preserving the outermost visible lash samples.
        let tolerance=max(1,span*0.08)
        let widest:[(Double,Double)]
        if coherentRows {
            // A wider inconsistent row must not veto three rows agreeing on
            // both boundaries. Use the original three-row coherence contract;
            // requiring adjacency would discard valid source evidence merely
            // because raster sampling selects nonconsecutive scan rows.
            // Contrast, span/pivot limits and whole-eye registration stay fixed.
            var groups=[[(Double,Double)]]()
            for first in 0..<(edges.count-2) {
                for second in (first+1)..<(edges.count-1) {
                    for third in (second+1)..<edges.count {
                        let rows=[edges[first],edges[second],edges[third]]
                        guard rows.map(\.0).max()!-rows.map(\.0).min()! <= tolerance,
                              rows.map(\.1).max()!-rows.map(\.1).min()! <= tolerance else { continue }
                        let left=rows.map(\.0).min()!,right=rows.map(\.1).max()!
                        let measured=right-left,pivot=(left+right)*0.5
                        guard measured >= span*minimumSpanRatio,measured <= span*1.25,
                              abs(pivot) <= span*pivotLimit else { continue }
                        groups.append(rows)
                    }
                }
            }
            guard let best=groups.max(by: {
                $0.reduce(0) { $0+$1.1-$1.0 } < $1.reduce(0) { $0+$1.1-$1.0 }
            }) else { return nil }
            widest=best
        } else {
            widest=Array(edges.sorted { $0.1-$0.0 > $1.1-$1.0 }.prefix(3))
        }
        guard widest.map(\.0).max()!-widest.map(\.0).min()! <= tolerance,
              widest.map(\.1).max()!-widest.map(\.1).min()! <= tolerance else { return nil }
        let left=widest.map(\.0).min()!,right=widest.map(\.1).max()!
        let measured=right-left,pivot=(left+right)*0.5
        guard measured >= span*minimumSpanRatio,measured <= span*1.25,abs(pivot) <= span*pivotLimit else { return nil }
        return (min(span*1.18,measured),pivot)
    }
    /// Confirm contrast at an already observed dense iris center. This does
    /// not locate a new pupil/radius or replace failed geometric support.
    private static func registeredLowerCore(_ rgba:[UInt8]?,width:Int,height:Int,eye:Eye) -> Bool {
        guard let rgba,rgba.count == width*height*4,
              let pupil=eye.pupil,eye.irisRadius != nil else { return false }
        func rgb(_ p:SIMD2<Double>) -> SIMD3<Double>? {
            let x=Int(p.x.rounded()),y=Int(p.y.rounded())
            guard x >= 0,x < width,y >= 0,y < height else { return nil }
            let i=(y*width+x)*4
            guard rgba[i+3] == 255 else { return nil }
            return SIMD3(Double(rgba[i]),Double(rgba[i+1]),Double(rgba[i+2]))
        }
        let skin=(-4...4).flatMap { step in [-1.0,1.0].compactMap { sign in
            rgb(pupil+eye.axisX*(Double(step)*eye.span*0.06)+eye.axisY*(sign*eye.span*0.38))
        } }
        let core=(-1...1).flatMap { y in (-1...1).compactMap { x in rgb(pupil+SIMD2(Double(x),Double(y))) } }
        guard skin.count == 18,core.count == 9 else { return false }
        func median(_ v:[Double]) -> Double { v.sorted()[v.count/2] }
        let background=SIMD3(median(skin.map(\.x)),median(skin.map(\.y)),median(skin.map(\.z)))
        let dark=SIMD3(median(core.map(\.x)),median(core.map(\.y)),median(core.map(\.z)))
        let d=background-dark
        return d.x > max(18,background.x*0.12) && d.y > max(18,background.y*0.12)
            && d.z > max(18,background.z*0.12)
    }
    private static func smooth(_ x:Double) -> Double { let t=min(1,max(0,x));return t*t*(3-2*t) }
    private static func distanceToContour(_ p:SIMD2<Double>,_ contour:[SIMD2<Double>]) -> Double {
        var result=Double.infinity
        for i in contour.indices {
            let a=contour[i],b=contour[(i+1)%contour.count],v=b-a,d=p-a
            let length=v.x*v.x+v.y*v.y
            guard length > 0 else { continue }
            let t=min(1,max(0,(d.x*v.x+d.y*v.y)/length)),q=d-v*t
            result=min(result,hypot(q.x,q.y))
        }
        return result
    }
    private static func contains(_ p:SIMD2<Double>,_ contour:[SIMD2<Double>]) -> Bool {
        var inside=false
        for i in contour.indices {
            let a=contour[i],b=contour[(i+1)%contour.count]
            if (a.y > p.y) != (b.y > p.y),p.x < (b.x-a.x)*(p.y-a.y)/(b.y-a.y)+a.x { inside.toggle() }
        }
        return inside
    }
    private static func displacement(_ p:SIMD2<Double>,eye:Eye,values:BeautyEffectiveStrengths) -> SIMD2<Double> {
        let q=eye.local(p),span=eye.span
        let rho=hypot(q.x/(span*0.95),q.y/(span*0.55))
        var weight=1-smooth((rho-0.60)/0.40)
        for b in eye.protection {
            let dx=max(b[0]-p.x,0,p.x-b[1]),dy=max(b[2]-p.y,0,p.y-b[3])
            weight *= smooth(hypot(dx,dy)/(span*0.18))
        }
        let apertureQ=SIMD2(q.x,q.y-eye.apertureOffset)
        let shapeRho=hypot(apertureQ.x/(span*1.08),apertureQ.y/(span*0.75))
        // Whole-eye spacing needs a translation plateau. A product of orbital
        // and feature fades adds their derivatives in overlapping transitions,
        // so cap admission otherwise attenuates even the unaffected eye center.
        // The minimum of source-fixed 1-Lipschitz distances avoids that sum.
        var shapeDistance=max(0,(1-shapeRho)*span*0.75)
        func protectionFade(_ t:Double) -> Double {
            let t=min(1,max(0,t))
            // C1 end caps around a mostly linear ramp avoid the 1.5x peak
            // derivative of smoothstep suppressing a whole-eye translation.
            if t < 0.1 { return t*t/0.18 }
            if t > 0.9 { let a=1-t;return 1-a*a/0.18 }
            return (t-0.05)/0.9
        }
        for b in eye.shapeProtection {
            let dx=max(b[0]-p.x,0,p.x-b[1]),dy=max(b[2]-p.y,0,p.y-b[3])
            let distance=hypot(dx,dy)
            shapeDistance=min(shapeDistance,distance)
        }
        let shapeWeight=protectionFade(shapeDistance/(span*0.22))
        let spacingRho=hypot(apertureQ.x/(span*1.12),apertureQ.y/(span*0.85))
        var spacingDistance=max(0,(1-spacingRho)*span*0.85)
        if let midline=eye.spacingMidline {
            // Opposite translations meet at a source-fixed zero line rather
            // than summing two orbital transition derivatives on the bridge.
            spacingDistance=min(spacingDistance,max(0,eye.side*(p.x-midline)))
        }
        for b in eye.shapeProtection {
            let dx=max(b[0]-p.x,0,p.x-b[1]),dy=max(b[2]-p.y,0,p.y-b[3])
            spacingDistance=min(spacingDistance,hypot(dx,dy))
        }
        let spacingWeight=protectionFade(spacingDistance/(span*0.30))
        guard weight > 0 || shapeWeight > 0 || spacingWeight > 0
            || (values.pupilSize != 0 && eye.pupil != nil && eye.irisRadius != nil)
        else { return .zero }
        func value(_ v:Float,_ cap:Float) -> Double { Double(v/cap) }
        var irisPreservation=1.0
        if let pupil=eye.pupil,let r=eye.irisRadius {
            let d=p-pupil
            irisPreservation=smooth((hypot(d.x,d.y)/r-0.80)/0.65)
        }
        func limited(_ v:Double,core:Double,transition:Double) -> Double {
            let a=abs(v),sign=v < 0 ? -1.0:1.0
            if a <= core { return v }
            let t=min(transition,a-core)
            return sign*(core+t-t*t/(2*transition))
        }
        let shapeQ=SIMD2(limited(apertureQ.x,core:span*0.55,transition:span*0.20),
            limited(apertureQ.y,core:eye.apertureHalfHeight*1.05,transition:eye.apertureHalfHeight*0.80))
        let interior=contains(p,eye.contour)
            ? smooth(distanceToContour(p,eye.contour)/max(1,eye.halfHeight)):0
        // Visible iris evidence may include occluded ring points. It must not
        // freeze a measured eyelid merely because the eyelid crosses the ring.
        let aperturePreservation=1-(1-irisPreservation)*interior
        let horizontalX=limited(apertureQ.x-eye.horizontalPivot,core:span*0.55,transition:span*0.20)
        var shape=SIMD2(horizontalX,shapeQ.y)*(0.063*value(values.eyeSize,BeautySafetyCaps.eyeSize))
        shape.x += horizontalX*0.066*value(values.eyeLength,BeautySafetyCaps.eyeLength)*aperturePreservation
        let heightAlong=pow(max(0,1-pow(apertureQ.x/(span*0.52),2)),2)
        shape.y += shapeQ.y*0.200*value(values.eyeHeight,BeautySafetyCaps.eyeHeight)
            * aperturePreservation*heightAlong
        var d=SIMD2<Double>.zero
        // The corner line can lie below most of the observed aperture. Use
        // its source-fixed upper/lower midpoint for the lower-lid gate too.
        // An outer-half plateau keeps this control distinct from eye height;
        // its zero center/inner side and corner fade preserve those features.
        let detailPivot=eye.pupil ?? (eye.center+eye.axisX*eye.horizontalPivot+eye.axisY*eye.apertureOffset)
        let visibleCenter=eye.center+eye.axisX*eye.horizontalPivot
        // Local corner/lid components share the same registered visible edge,
        // including the lid's outer zero boundary. Whole-eye fallback must not
        // truncate a separately registered lobe. Tail/tilt keep their frame.
        let localEdge=values.outerCornerOpen != 0 || values.lowerEyelidDrop != 0
        let cornerCenter=localEdge ? (eye.lowerCenterX ?? visibleCenter.x):visibleCenter.x
        let cornerSpan=localEdge ? (eye.lowerVisibleSpan ?? eye.visibleSpan):eye.visibleSpan
        let outerX=cornerCenter+eye.side*cornerSpan*eye.axisX.x*0.5
        let outerDistance=max(span*0.22,eye.side*(outerX-detailPivot.x))
        let outward=eye.side*(p.x-detailPivot.x)/outerDistance
        var lowerIrisDistance=Double.infinity,innerIrisDistance=Double.infinity
        if let pupil=eye.pupil,let radius=eye.irisRadius {
            let v=p-pupil
            // Fix the visible iris core while allowing its occluding lower
            // lid and corner neighborhoods to deform. The observed ring may
            // extend beyond the visible aperture; freezing that full circle
            // suppresses a valid lid/corner on an asymmetric source eye.
            lowerIrisDistance=max(0,hypot(v.x,v.y)-radius*0.60)
            innerIrisDistance=max(0,hypot(v.x,v.y)-radius*0.70)
        }
        // The outer lower-lid lobe belongs to the registered visible aperture,
        // whose midpoint can differ from the iris center in an asymmetric eye.
        // Keep the center sampling neighborhood fixed on small apertures.
        let lowerCenterX=eye.lowerCenterX ?? visibleCenter.x
        let lowerWidth=eye.lowerVisibleSpan ?? eye.visibleSpan
        var centralGuard=lowerWidth*0.055
        if eye.registeredLowerCore,eye.lowerCenterX != nil,let pupil=eye.pupil {
            // The registered aperture and observed iris can have different
            // centers. Allocate the flat central neighborhood from that fixed
            // source offset, instead of consuming a narrow outer-half lobe
            // with a common width fraction. Keep a bounded geometric fallback.
            centralGuard=min(lowerWidth*0.065,abs(lowerCenterX-pupil.x)*0.55)
        }
        let lowerHorizontal=max(0,eye.side*(p.x-lowerCenterX)-max(2,centralGuard))
        let lowerOuter=max(0,(1.10-outward)*outerDistance)
        let lowerVertical=values.lowerEyelidDrop != 0 ? eye.lowerClearance(q):0
        // A single linear distance ramp does not spend the admitted gradient
        // budget on a steeper end cap. Bilinear sampling keeps the field
        // continuous; the source upper/central neighborhoods remain fixed.
        let lowerRamp=min(1,max(0,min(shapeDistance,lowerHorizontal,lowerOuter,lowerVertical,lowerIrisDistance)/(span*0.18)))
        let plateau=max(0,lowerRamp-0.96)
        let lower=lowerRamp-plateau*plateau/0.08
        let lowerImage=SIMD2(0,span*0.083
            * value(values.lowerEyelidDrop,BeautySafetyCaps.lowerEyelidDrop)*lower)
        let outer=pow(smooth((outward-0.08)/0.92),1.5)
        d.y -= span*0.066*value(values.eyeTailLift,BeautySafetyCaps.eyeTailLift)
            * outer*aperturePreservation
        let tilt=0.069*value(values.eyeTilt,BeautySafetyCaps.eyeTilt)*eye.side
        let rotation=p-(detailPivot+SIMD2(eye.side*span*0.08,0))
        let rotationY=limited(rotation.y,core:eye.apertureHalfHeight*0.80,
                              transition:eye.apertureHalfHeight*0.80)
        let upperTilt=1-0.20*smooth(-apertureQ.y/max(1,eye.apertureHalfHeight))
        let tiltDelta=SIMD2(rotationY*tilt,-rotation.x*tilt
            * (1-0.045*smooth(outward/0.95))*upperTilt)
        func outerCornerWeight() -> Double {
            // Keep the visible corner and its lash neighborhood on a plateau;
            // a Gaussian centered on the nominal detector tip loses response
            // when that tip sits inside the visible edge. Narrow the central
            // transition so the other corner and iris remain independent.
            let horizontal=smooth((outward-0.50)/0.44)
                * (1-smooth((outward-1.25)/0.30))
            let vertical=1-smooth((abs(apertureQ.y)-eye.apertureHalfHeight*1.10)/(span*0.22))
            return horizontal*vertical*aperturePreservation
        }
        // The inner transition meets the bridge protection. One minimum-
        // distance ramp avoids adding the derivatives of two overlapping
        // fades and attenuating the entire component at cap admission.
        let innerHorizontal=max(0,-eye.side*apertureQ.x-span*0.20)
        let innerVertical=max(0,span*0.30-max(0,abs(apertureQ.y)-eye.apertureHalfHeight*0.90))
        let innerWeight=protectionFade(min(shapeDistance,innerHorizontal,innerVertical,innerIrisDistance)/(span*0.22))
        let innerImage=SIMD2(-eye.side*span*0.102
            * value(values.innerCornerOpen,BeautySafetyCaps.innerCornerOpen)*innerWeight,0)
        d.x += eye.side*span*0.0465*value(values.outerCornerOpen,BeautySafetyCaps.outerCornerOpen)*outerCornerWeight()
        let shapeImage: SIMD2<Double> = (eye.axisX * shape.x + eye.axisY * shape.y) * shapeWeight
        // Separate observed nose/root/tip envelopes avoid fixing the empty
        // space beside the bridge. Minimum-distance protection limits the
        // transition derivative without multiplying overlapping fades.
        let detailImage: SIMD2<Double> = (d+tiltDelta)*shapeWeight+innerImage+lowerImage
        // Position controls use the image axes rather than each eye's opposing
        // canthal tilt, so vertical movement cannot also spread the two eyes.
        let spacingImage=SIMD2<Double>(eye.visibleSpan*0.0828*eye.side
            * value(values.eyeDistance,BeautySafetyCaps.eyeDistance)*spacingWeight,0)
        let positionImage=SIMD2<Double>(0,eye.visibleSpan*0.0603
            * value(values.eyeYPosition,BeautySafetyCaps.eyeYPosition)*shapeWeight)
        var imageDelta = shapeImage + detailImage + spacingImage + positionImage
        if values.pupilSize != 0,let pupil=eye.pupil {
            let v=p-pupil
            if let radius=eye.irisRadius {
                let distance=hypot(v.x,v.y)
                if distance > 1e-9 {
                    // Keep the radial grid response independent of an occluding
                    // lid; source aperture/rim containment owns the raster gate.
                    // Limit the peripheral magnitude by source radius distance.
                    // On each distance
                    // branch the unweighted radial Jacobian is bounded by
                    // sqrt(.21^2 + .35^2); normal grid/joint admission still applies.
                    let response=0.21, slope=0.35
                    // The positive inverse scale places the enlarged limbus at
                    // R/(1-response). The margin targets the source-pixel
                    // sampling footprint, not every bilinear lattice knot.
                    let plateau=radius/(1-response)+1.5
                    let outerRadius=plateau*(1+response/slope)
                    let magnitude=max(0,min(response*distance,
                                             slope*(outerRadius-distance)))
                    imageDelta += v*(magnitude/distance
                        * value(values.pupilSize,BeautySafetyCaps.pupilSize))
                }
            } else if values.pupilSize > 0,contains(p,eye.contour) {
                let aperture=smooth(distanceToContour(p,eye.contour)/max(1,eye.halfHeight*0.45))
                imageDelta += v*(0.18*value(values.pupilSize,BeautySafetyCaps.pupilSize)*aperture)*weight
            }
        }
        return imageDelta
    }

    private static func isProtected(_ p:SIMD2<Double>,_ boxes:[[Double]]) -> Bool {
        boxes.contains { p.x >= $0[0] && p.x <= $0[1] && p.y >= $0[2] && p.y <= $0[3] }
    }

    private func sampleRGB(_ source:[UInt8],x:Int,y:Int,delta:SIMD2<Double>,alpha:UInt8,
                           aperture:DensePupilAperture? = nil) -> SIMD3<Double>? {
        let position=SIMD2(Double(x)-delta.x,Double(y)-delta.y)
        return sampleRGB(source,position:position,alpha:alpha,aperture:aperture)
    }

    private func sampleRGB(_ source:[UInt8],position:SIMD2<Double>,alpha:UInt8,
                           aperture:DensePupilAperture? = nil) -> SIMD3<Double>? {
        guard position.x.isFinite,position.y.isFinite else { return nil }
        if aperture != nil {
            guard position.x >= 0,position.x <= Double(width-1),
                  position.y >= 0,position.y <= Double(height-1) else { return nil }
        }
        let sx=min(Double(width-1),max(0,position.x))
        let sy=min(Double(height-1),max(0,position.y))
        let x0=Int(floor(sx)),y0=Int(floor(sy)),x1=min(width-1,x0+1),y1=min(height-1,y0+1)
        let indices=[(y0*width+x0)*4,(y0*width+x1)*4,(y1*width+x0)*4,(y1*width+x1)*4]
        guard indices.allSatisfy({ source[$0+3] == alpha }) else { return nil }
        if let aperture {
            let centers=[SIMD2(Double(x0)+0.5,Double(y0)+0.5),
                         SIMD2(Double(x1)+0.5,Double(y0)+0.5),
                         SIMD2(Double(x0)+0.5,Double(y1)+0.5),
                         SIMD2(Double(x1)+0.5,Double(y1)+0.5)]
            guard centers.allSatisfy({ Self.contains($0,aperture.contour)
                && !Self.isProtected($0,aperture.protection) }) else { return nil }
        }
        let ax=sx-Double(x0),ay=sy-Double(y0)
        var color=SIMD3<Double>.zero
        for channel in 0..<3 {
            let a=Double(source[indices[0]+channel]),b=Double(source[indices[1]+channel])
            let c=Double(source[indices[2]+channel]),e=Double(source[indices[3]+channel])
            color[channel]=(a+(b-a)*ax)*(1-ay)+(c+(e-c)*ax)*ay
        }
        return color
    }

    private static func singleVerticalInterval(_ x:Double,_ contour:[SIMD2<Double>]) -> ClosedRange<Double>? {
        var crossings=[Double]()
        for index in contour.indices {
            let a=contour[index],b=contour[(index+1)%contour.count]
            if (a.x > x) != (b.x > x) {
                crossings.append(a.y+(b.y-a.y)*(x-a.x)/(b.x-a.x))
            }
        }
        guard crossings.count >= 2,crossings.count%2 == 0 else { return nil }
        crossings.sort()
        var interval:ClosedRange<Double>?
        for index in stride(from:0,to:crossings.count,by:2) where crossings[index] < crossings[index+1] {
            guard interval == nil else { return nil }
            interval=crossings[index]...crossings[index+1]
        }
        return interval
    }

    private func projectedDenseRGB(_ source:[UInt8],x:Int,y:Int,fullDelta:SIMD2<Double>,
                                   shapeDelta:SIMD2<Double>,alpha:UInt8,
                                   aperture:DensePupilAperture) -> SIMD3<Double>? {
        let full=SIMD2(Double(x)-fullDelta.x,Double(y)-fullDelta.y)
        let shapeY=Double(y)-shapeDelta.y
        guard full.x.isFinite,full.y.isFinite,shapeY.isFinite,
              full.x >= 0,full.x <= Double(width-1),full.y != shapeY else { return nil }
        let x0=Int(floor(full.x)),x1=min(width-1,x0+1)
        let columns=[Double(x0)+0.5,Double(x1)+0.5]
        if full.y >= 0,full.y <= Double(height-1) {
            let y0=Int(floor(full.y)),y1=min(height-1,y0+1)
            // Projection repairs geometric occlusion only. A stencil already
            // inside the aperture cannot evade an alpha/protection rejection.
            if columns.allSatisfy({ column in
                Self.contains(SIMD2(column,Double(y0)+0.5),aperture.contour)
                    && Self.contains(SIMD2(column,Double(y1)+0.5),aperture.contour)
            }) { return nil }
        }
        guard let first=Self.singleVerticalInterval(columns[0],aperture.contour),
              let second=Self.singleVerticalInterval(columns[1],aperture.contour) else { return nil }
        let low=max(first.lowerBound,second.lowerBound),high=min(first.upperBound,second.upperBound)
        guard low < high else { return nil }
        var firstRow=max(0,Int(ceil(low-0.5)))
        var lastRow=min(height-1,Int(floor(high-0.5)))
        func rowIsInside(_ row:Int) -> Bool {
            columns.allSatisfy { Self.contains(SIMD2($0,Double(row)+0.5),aperture.contour) }
        }
        while firstRow <= lastRow && !rowIsInside(firstRow) { firstRow += 1 }
        while firstRow <= lastRow && !rowIsInside(lastRow) { lastRow -= 1 }
        guard firstRow < lastRow || (firstRow == lastRow && lastRow == height-1) else { return nil }
        // Both y0 and y1 centers must fit. Ordinary sample-index Y is in
        // [firstRow,lastRow); only the image's final row duplicates y0/y1.
        let lower=Double(firstRow)
        let upper=lastRow == height-1 ? Double(lastRow):Double(lastRow).nextDown
        let travelLow=min(full.y,shapeY),travelHigh=max(full.y,shapeY)
        let allowedLow=max(lower,travelLow),allowedHigh=min(upper,travelHigh)
        guard allowedLow <= allowedHigh else { return nil }
        let projectedY=min(allowedHigh,max(allowedLow,full.y))
        let fraction=(projectedY-shapeY)/(full.y-shapeY)
        guard fraction >= 0,fraction <= 1,
              abs(projectedY-shapeY) <= abs(full.y-shapeY) else { return nil }
        // Keep the exact projected source coordinate: reconstructing it from
        // a displacement could round an excluded lastRow back into the stencil.
        return sampleRGB(source,position:SIMD2(full.x,projectedY),alpha:alpha,aperture:aperture)
    }

    func applyRGBA(_ source:[UInt8]) -> [UInt8] {
        guard source.count == width*height*4 else { return source }
        var output=source,row=0
        for y in max(0,Int(ys[0]))..<min(height,Int(ceil(ys.last!))) {
            let py=Double(y)+0.5
            guard py >= ys[0],py < ys.last! else { continue }
            while row+1 < ys.count-1 && py >= ys[row+1] { row += 1 }
            let fy=(py-ys[row])/(ys[row+1]-ys[row]);var col=0
            for x in max(0,Int(xs[0]))..<min(width,Int(ceil(xs.last!))) {
                let px=Double(x)+0.5
                guard px >= xs[0],px < xs.last! else { continue }
                while col+1 < xs.count-1 && px >= xs[col+1] { col += 1 }
                let fx=(px-xs[col])/(xs[col+1]-xs[col]),i=row*xs.count+col
                let top=offsets[i]*(1-fx)+offsets[i+1]*fx
                let bottom=offsets[i+xs.count]*(1-fx)+offsets[i+xs.count+1]*fx
                var d=top*(1-fy)+bottom*fy
                let p=SIMD2(px,py)
                if let aperture=densePupilApertures.first(where: { Self.contains(p,$0.contour) }) {
                    let allIrisTop=irisOffsets[i]*(1-fx)+irisOffsets[i+1]*fx
                    let allIrisBottom=irisOffsets[i+xs.count]*(1-fx)+irisOffsets[i+xs.count+1]*fx
                    let shapeDelta=d-(allIrisTop*(1-fy)+allIrisBottom*fy)
                    let irisTop=aperture.irisOffsets[i]*(1-fx)+aperture.irisOffsets[i+1]*fx
                    let irisBottom=aperture.irisOffsets[i+xs.count]*(1-fx)+aperture.irisOffsets[i+xs.count+1]*fx
                    let irisDelta=irisTop*(1-fy)+irisBottom*fy
                    let fullDelta=shapeDelta+irisDelta
                    let dst=(y*width+x)*4,alpha=source[dst+3]
                    let original=SIMD3(Double(source[dst]),Double(source[dst+1]),Double(source[dst+2]))
                    let shapeColor=sampleRGB(source,x:x,y:y,delta:shapeDelta,alpha:alpha) ?? original
                    var color=shapeColor
                    let distance=hypot(p.x-aperture.pupil.x,p.y-aperture.pupil.y)
                    let plateau=aperture.radius/(1-0.21)+1.5
                    let shoulder=Self.smooth((distance-plateau)/(aperture.radius*0.10))
                    let rim=1.5+(aperture.protectedRim-1.5)*shoulder
                    let contourClearance=Self.distanceToContour(p,aperture.contour)-rim
                    let cornerClearance=aperture.corners.map {
                        hypot(p.x-$0.x,p.y-$0.y)-aperture.cornerRim
                    }.min() ?? 0
                    var clearance=min(contourClearance,cornerClearance)
                    for box in aperture.protection {
                        let dx=max(box[0]-p.x,0,p.x-box[1]),dy=max(box[2]-p.y,0,p.y-box[3])
                        clearance=min(clearance,hypot(dx,dy))
                    }
                    // The observed iris owns this fixed material disk. The
                    // 1.5-pixel buffers cover AA/bilinear sampling footprints;
                    // surrounding sclera keeps the shape-only color.
                    let materialOuterRadius=aperture.projectsOcclusion
                        ? aperture.radius+3:plateau+1.5
                    let materialClearance=(materialOuterRadius-distance)/1.5
                    let feather=Self.smooth(min(clearance/aperture.featherDistance,materialClearance))
                    // Feather immutable-source colors, never the iris vector:
                    // every full sample retains the admitted radial scaling.
                    // Negative occlusion may reduce only the iris Y component;
                    // other unsafe iris samples keep the shape-only result.
                    if feather > 0,!Self.isProtected(p,aperture.protection) {
                        var fullColor=sampleRGB(source,x:x,y:y,delta:fullDelta,alpha:alpha,aperture:aperture)
                        if fullColor == nil,aperture.projectsOcclusion {
                            fullColor=projectedDenseRGB(source,x:x,y:y,fullDelta:fullDelta,
                                shapeDelta:shapeDelta,alpha:alpha,aperture:aperture)
                        }
                        if let fullColor { color += (fullColor-shapeColor)*feather }
                    }
                    for channel in 0..<3 {
                        output[dst+channel]=UInt8(min(255,max(0,Int(color[channel].rounded()))))
                    }
                    continue
                }
                // Always contain the iris component within the measured eye
                // aperture, including when a shape component crosses zero.
                // Shape fields retain their smooth orbital support, and the
                // sum still owns one inverse pixel sample.
                if !irisApertures.isEmpty,
                   !irisApertures.contains(where: { Self.contains(SIMD2(px,py),$0) }) {
                    let irisTop=irisOffsets[i]*(1-fx)+irisOffsets[i+1]*fx
                    let irisBottom=irisOffsets[i+xs.count]*(1-fx)+irisOffsets[i+xs.count+1]*fx
                    d -= irisTop*(1-fy)+irisBottom*fy
                } else if !sparseIrisOffsets.isEmpty {
                    if !densePupilApertures.isEmpty {
                        // A sparse destination owns only its sparse carrier;
                        // compact dense fields may extend beyond their eyes.
                        let allTop=irisOffsets[i]*(1-fx)+irisOffsets[i+1]*fx
                        let allBottom=irisOffsets[i+xs.count]*(1-fx)+irisOffsets[i+xs.count+1]*fx
                        let sparseTop=sparseIrisOffsets[i]*(1-fx)+sparseIrisOffsets[i+1]*fx
                        let sparseBottom=sparseIrisOffsets[i+xs.count]*(1-fx)+sparseIrisOffsets[i+xs.count+1]*fx
                        d -= allTop*(1-fy)+allBottom*fy
                        d += sparseTop*(1-fy)+sparseBottom*fy
                    }
                    // Interpolation may cross the fixed aperture edge. A
                    // destination-space feather keeps the sparse positive
                    // compatibility component soft at that edge, independently
                    // of sibling shape fields and their sign through zero.
                    let p=SIMD2(px,py)
                    let feather=sparsePupilApertures.map { aperture -> Double in
                        guard Self.contains(p,aperture.contour) else { return 0 }
                        return Self.smooth(Self.distanceToContour(p,aperture.contour)/aperture.featherDistance)
                    }.max() ?? 0
                    let top=sparseIrisOffsets[i]*(1-fx)+sparseIrisOffsets[i+1]*fx
                    let bottom=sparseIrisOffsets[i+xs.count]*(1-fx)+sparseIrisOffsets[i+xs.count+1]*fx
                    d -= (top*(1-fy)+bottom*fy)*(1-feather)
                }
                guard abs(d.x)+abs(d.y) > 1e-10 else { continue }
                let sx=min(Double(width-1),max(0,Double(x)-d.x))
                let sy=min(Double(height-1),max(0,Double(y)-d.y))
                let x0=Int(floor(sx)),y0=Int(floor(sy)),x1=min(width-1,x0+1),y1=min(height-1,y0+1)
                let indices=[(y0*width+x0)*4,(y0*width+x1)*4,(y1*width+x0)*4,(y1*width+x1)*4]
                let dst=(y*width+x)*4,alpha=source[dst+3]
                guard indices.allSatisfy({ source[$0+3] == alpha }) else { continue }
                let ax=sx-Double(x0),ay=sy-Double(y0)
                for channel in 0..<3 {
                    let a=Double(source[indices[0]+channel]),b=Double(source[indices[1]+channel])
                    let c=Double(source[indices[2]+channel]),e=Double(source[indices[3]+channel])
                    let v=(a+(b-a)*ax)*(1-ay)+(c+(e-c)*ax)*ay
                    output[dst+channel]=UInt8(min(255,max(0,Int(v.rounded()))))
                }
            }
        }
        return output
    }
}

extension BeautyContinuousEyeMap: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description:String { "BeautyContinuousEyeMap(width: \(width), height: \(height), nodeCount: \(offsets.count))" }
    var debugDescription:String { description }
    var customMirror:Mirror { Mirror(self,children:["width":width,"height":height,"nodeCount":offsets.count]) }
}
