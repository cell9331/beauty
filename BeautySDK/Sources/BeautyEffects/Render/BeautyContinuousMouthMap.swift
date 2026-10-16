import BeautyCore
import Foundation

/// Eight source-domain reference fields, composed before one inverse sampling.
/// The public-to-module displacement accessor retains its inverse-map meaning.
struct BeautyContinuousMouthMap {
    typealias Point = SIMD2<Double>
    typealias Model = BeautyMouthReferenceModel
    static var keys: [WritableKeyPath<BeautyEffectiveStrengths,Float>] { [
        \.mouthSize,\.mouthWidth,\.smile,\.mouthYPosition,\.mouthTilt,\.mouthXPosition,\.lipPeakDefinition,\.lipPlump
    ] }
    static func replacesLegacy(for face: FaceGeometry) -> Bool { face.observedOuterLips != nil || face.denseSupport != nil }
    static func eligibleFieldMask(face: FaceGeometry) -> UInt8 { BeautyMouthReferenceGeometry.eligible(face: face) }
    let width: Int
    let height: Int
    /// Upper bound for the inverse displacement gradient, not a sampled max.
    let maximumGradient: Double
    let maximumDisplacement: Double
    let safetyScale: Double
    private let geometry: BeautyMouthReferenceGeometry
    private let model: Model
    private let values: [Double]
    private let fieldScales: [Double]
    private let inverseTolerances: [Double]
    private let active: [Model.Field]
    private let sourceMinimum: Point
    private let sourceMaximum: Point
    private let rasterMinimum: Point
    private let rasterMaximum: Point

    init?(width: Int,height: Int,face: FaceGeometry,strengths: BeautyEffectiveStrengths) {
        guard width > 1,height > 1,width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              Self.keys.allSatisfy({ strengths[keyPath:$0].isFinite }),
              let geometry=BeautyMouthReferenceGeometry(width:width,height:height,face:face),
              let configuration=geometry.configuration(),let model=Model(configuration:configuration) else { return nil }
        let caps:[Float]=[BeautySafetyCaps.mouthSize,BeautySafetyCaps.mouthWidth,BeautySafetyCaps.smile,
            BeautySafetyCaps.mouthYPosition,BeautySafetyCaps.mouthTilt,BeautySafetyCaps.mouthXPosition,
            BeautySafetyCaps.lipPeakDefinition,BeautySafetyCaps.lipPlump]
        var values=zip(Self.keys,caps).map { min(1,max(-1,Double(strengths[keyPath:$0.0]/$0.1))) }
        if geometry.inner == nil { values[6]=0;values[7]=0 }
        guard values.contains(where:{$0 != 0}) else { return nil }
        let active=Model.Field.allCases.filter { values[$0.rawValue] != 0 }
        // Each signed field owns one fixed endpoint admission. Composing
        // admitted diffeomorphisms keeps small newly enabled edits continuous;
        // no active-set endpoint budget changes an already applied field.
        var scales=[Double](repeating:0,count:8),forwardNorms=[Double](repeating:1,count:8)
        var inverseLipschitz=1.0,magnitude=0.0
        for field in active {
            let sign=values[field.rawValue]<0 ? -1.0:1.0
            let bounds=BeautyMouthReferenceCertificate.bounds(model:model,field:field,strength:sign)
            guard bounds.maximumGradient.isFinite,bounds.maximumDisplacement.isFinite else { return nil }
            let scale:Double,inverseGradient:Double
            if field == .fullness {
                let minimum=model.minimumVerticalDerivativeForFullness(strength:sign)
                guard minimum.isFinite else { return nil }
                scale=min(1,minimum<0 ? 0.78 / -minimum:1)*geometry.pose
                let lower=max(0.22,1+minimum*scale)
                let inverseNorm=sqrt(1+pow(bounds.maximumGradient*scale/lower,2)+1/(lower*lower))
                inverseGradient=inverseNorm*bounds.maximumGradient*scale
            } else if field == .mShape {
                let minimum=Self.minimumMVerticalDerivative(model)
                scale=min(1,0.78/max(-minimum,1e-15))*geometry.pose
                inverseGradient=bounds.maximumGradient*scale/max(0.22,1+minimum*scale)
            } else if field == .tilt {
                let minimum=BeautyMouthReferenceCertificate.minimumTiltDeterminantOffset(model:model,strength:sign)
                guard minimum.isFinite else { return nil }
                scale=min(1,minimum<0 ? 0.78 / -minimum:1)*geometry.pose
                let admitted=BeautyMouthReferenceCertificate.bounds(model:model,field:field,strength:sign*scale)
                inverseGradient=admitted.maximumGradient*(1+admitted.maximumGradient)/0.22
            } else if field == .size || field == .width || field == .smile {
                scale=BeautyMouthReferenceCertificate.maximumLinearScale(model:model,field:field,strength:sign)*geometry.pose
                inverseGradient=bounds.maximumGradient*scale*(1+bounds.maximumGradient*scale)/0.25
            } else if field == .vertical || field == .horizontal {
                let minimum=BeautyMouthReferenceCertificate.minimumTranslationDeterminantOffset(model:model,field:field,strength:sign)
                guard minimum.isFinite else { return nil }
                scale=min(1,minimum<0 ? 0.78 / -minimum:1)*geometry.pose
                inverseGradient=bounds.maximumGradient*scale/max(0.22,1+minimum*scale)
            } else {
                scale=min(1,0.72/max(bounds.maximumGradient,1e-15))*geometry.pose
                inverseGradient=bounds.maximumGradient*scale/max(1e-12,1-bounds.maximumGradient*scale)
            }
            scales[field.rawValue]=scale
            forwardNorms[field.rawValue] = 1 + (field == .tilt
                ? BeautyMouthReferenceCertificate.bounds(model:model,field:field,strength:sign*scale).maximumGradient
                : bounds.maximumGradient*scale)
            inverseLipschitz *= 1+inverseGradient
            magnitude += field == .tilt
                ? BeautyMouthReferenceCertificate.bounds(model:model,field:field,strength:sign*scale).maximumDisplacement
                : bounds.maximumDisplacement*scale
        }
        guard inverseLipschitz.isFinite,magnitude.isFinite else { return nil }
        // A local inverse residual is amplified by every later forward field.
        // Allocate the final pixel residual across components using certified
        // forward Lipschitz bounds, rather than a fixed tolerance per field.
        var tolerances=[Double](repeating:0,count:8),laterNorm=1.0
        for field in active.reversed() {
            tolerances[field.rawValue]=0.0001/(Double(active.count)*geometry.span*laterNorm)
            laterNorm *= forwardNorms[field.rawValue]
        }
        guard laterNorm.isFinite else { return nil }
        self.width=width;self.height=height;self.geometry=geometry;self.model=model
        self.values=values;self.fieldScales=scales;self.active=active
        self.inverseTolerances=tolerances
        self.safetyScale=active.map { scales[$0.rawValue] }.min() ?? 1
        self.maximumGradient=inverseLipschitz-1
        self.maximumDisplacement=magnitude*geometry.span
        let envelopes=[configuration.size.envelope,configuration.width.envelope,configuration.smile.envelope,
            configuration.vertical.envelope,configuration.tilt.envelope,configuration.horizontal.envelope,
            configuration.mShape.envelope,configuration.fullness.envelope]
        var lo=Point(Double.infinity,Double.infinity),hi=Point(-Double.infinity,-Double.infinity)
        for field in active {
            let e=envelopes[field.rawValue]
            var a=e.outerMin,b=e.outerMax
            if field == .mShape || field == .fullness { a.y += geometry.seam.minimumValue;b.y += geometry.seam.maximumValue }
            lo=Point(min(lo.x,a.x),min(lo.y,a.y));hi=Point(max(hi.x,b.x),max(hi.y,b.y))
        }
        self.sourceMinimum=lo;self.sourceMaximum=hi
        let corners=[Point(lo.x,lo.y),Point(lo.x,hi.y),Point(hi.x,lo.y),Point(hi.x,hi.y)].map(geometry.image)
        self.rasterMinimum=Point(corners.map(\.x).min()!,corners.map(\.y).min()!)
        self.rasterMaximum=Point(corners.map(\.x).max()!,corners.map(\.y).max()!)
    }

    func forwardDisplacement(at source:Point)->Point {
        let p=geometry.local(source)
        let displacement=forwardLocal(p)-p
        return geometry.span*(geometry.axisX*displacement.x+geometry.axisY*displacement.y)
    }

    private func forwardLocal(_ source:Point)->Point {
        var p=source
        for field in active { p += sampleLocal(p,field:field).displacement }
        return p
    }

    /// Solve F(p)=q in reverse composition order. Translations, vertical shape
    /// fields and tilt have monotone scalar inverses; affine/peak fields use
    /// damped Newton with a certified identity-homotopy fallback. Every inverse
    /// is checked by its forward residual before sampling the original raster.
    func sourcePoint(for target:Point)->Point? {
        guard target.x.isFinite,target.y.isFinite else { return nil }
        let q=geometry.local(target)
        if q.x<=sourceMinimum.x || q.x>=sourceMaximum.x || q.y<=sourceMinimum.y || q.y>=sourceMaximum.y { return target }
        var p=q
        for field in active.reversed() {
            guard let point=inverseLocal(p,field:field) else { return nil }
            p=point
        }
        let residual=forwardLocal(p)-q
        return hypot(residual.x,residual.y)*geometry.span<=0.001 ? geometry.image(p):nil
    }

    private func inverseLocal(_ q:Point,field:Model.Field)->Point? {
        var p=q
        let tolerance=inverseTolerances[field.rawValue]
        if field == .vertical || field == .horizontal {
            let vector=field == .vertical ? model.configuration.vertical.vector:model.configuration.horizontal.vector
            let length=hypot(vector.x,vector.y)
            guard length>0 else { return q }
            let e=vector/length
            var lo = -maximumDisplacement/geometry.span,hi = maximumDisplacement/geometry.span,t=0.0
            for _ in 0..<48 {
                p=q+e*t
                let s=sampleLocal(p,field:field)
                let residual=t+s.displacement.x*e.x+s.displacement.y*e.y
                if abs(residual)<=tolerance { return p }
                if residual<0 { lo=t } else { hi=t }
                let directional=s.gradientX*e.x+s.gradientY*e.y
                let derivative=1+directional.x*e.x+directional.y*e.y
                let next=t-residual/derivative
                t=next>lo && next<hi ? next:(lo+hi)*0.5
            }
        } else if field == .tilt {
            let center=model.configuration.tilt.center,r=q-center,radius=hypot(r.x,r.y)
            if radius<1e-14 { return q }
            let beta=atan2(r.y,r.x)
            let reach=abs(model.configuration.tilt.angle*values[field.rawValue]*fieldScales[field.rawValue])+1e-12
            var lo=beta-reach,hi=beta+reach,angle=beta
            for _ in 0..<48 {
                let v=Point(radius*cos(angle),radius*sin(angle));p=center+v
                let s=sampleLocal(p,field:field),moved=v+s.displacement
                let turn=atan2(v.x*moved.y-v.y*moved.x,v.x*moved.x+v.y*moved.y)
                let residual=angle+turn-beta
                if abs(residual)*radius<=tolerance { return p }
                if residual<0 { lo=angle } else { hi=angle }
                let tangent=Point(-v.y,v.x)
                let derivativeVector=tangent+s.gradientX*tangent.x+s.gradientY*tangent.y
                let derivative=(moved.x*derivativeVector.y-moved.y*derivativeVector.x)/(radius*radius)
                let next=angle-residual/derivative
                angle=next>lo && next<hi ? next:(lo+hi)*0.5
            }
        } else if field == .fullness || field == .mShape {
            var lo=sourceMinimum.y,hi=sourceMaximum.y
            for _ in 0..<48 {
                let s=sampleLocal(Point(q.x,p.y),field:field),residual=p.y+s.displacement.y-q.y
                if abs(residual)<=tolerance { return Point(q.x,p.y) }
                if residual<0 { lo=p.y } else { hi=p.y }
                let derivative=1+s.gradientY.y,candidate=p.y-residual/derivative
                p.y=candidate>lo && candidate<hi ? candidate:(lo+hi)*0.5
            }
        } else {
            func solve(_ start:Point,_ amount:Double)->Point? {
                var value=start
                for _ in 0..<24 {
                    let s=sampleLocal(value,field:field).scaled(by:amount),r=value+s.displacement-q
                    let error=hypot(r.x,r.y)
                    if error<=tolerance { return value }
                    let a=1+s.gradientX.x,b=s.gradientY.x,c=s.gradientX.y,d=1+s.gradientY.y
                    let determinant=a*d-b*c
                    guard determinant>0 else { return nil }
                    let step=Point((d*r.x-b*r.y)/determinant,(-c*r.x+a*r.y)/determinant)
                    var damping=1.0,accepted=false
                    for _ in 0..<12 {
                        let next=value-step*damping
                        let residual=next+sampleLocal(next,field:field).displacement*amount-q
                        if hypot(residual.x,residual.y)<error { value=next;accepted=true;break }
                        damping *= 0.5
                    }
                    if !accepted { return nil }
                }
                return nil
            }
            if let solved=solve(q,1) { return solved }
            // The certified linear homotopy stays nonsingular throughout.
            // Continue from identity if the direct damped Newton step failed.
            p=q
            for step in 1...16 {
                guard let next=solve(p,Double(step)/16) else { return nil };p=next
            }
        }
        let residual=p+sampleLocal(p,field:field).displacement-q
        return hypot(residual.x,residual.y)<=tolerance ? p:nil
    }

    func displacement(at pixel:Point)->Point {
        guard let p=sourcePoint(for:pixel) else { return .zero }
        return pixel-p
    }

    func applyRGBA(_ source:[UInt8])->[UInt8] {
        guard source.count==width*height*4 else { return source }
        var output=source
        let x0=max(0,Int(floor(rasterMinimum.x))),x1=min(width,Int(ceil(rasterMaximum.x)))
        let y0=max(0,Int(floor(rasterMinimum.y))),y1=min(height,Int(ceil(rasterMaximum.y)))
        guard x1>x0,y1>y0 else { return source }
        for y in y0..<y1 { for x in x0..<x1 {
            let q=Point(Double(x)+0.5,Double(y)+0.5)
            guard let p=sourcePoint(for:q) else { return source }
            guard hypot(p.x-q.x,p.y-q.y)>1e-8 else { continue }
            let sx=min(Double(width-1),max(0,p.x-0.5)),sy=min(Double(height-1),max(0,p.y-0.5))
            let ix=Int(floor(sx)),iy=Int(floor(sy)),jx=min(ix+1,width-1),jy=min(iy+1,height-1)
            let indices=[(iy*width+ix)*4,(iy*width+jx)*4,(jy*width+ix)*4,(jy*width+jx)*4]
            let destination=(y*width+x)*4,alpha=source[destination+3]
            guard indices.allSatisfy({source[$0+3]==alpha}) else { continue }
            let ax=sx-Double(ix),ay=sy-Double(iy)
            for channel in 0..<3 {
                let a=Double(source[indices[0]+channel]),b=Double(source[indices[1]+channel])
                let c=Double(source[indices[2]+channel]),d=Double(source[indices[3]+channel])
                let value=((1-ax)*a+ax*b)*(1-ay)+((1-ax)*c+ax*d)*ay
                output[destination+channel]=UInt8(min(255,max(0,Int(value.rounded()))))
            }
        } }
        return output
    }

    /// Pure M shape keeps source s fixed. Only its complete y derivative
    /// controls column monotonicity; profile x slopes are harmless shear.
    private static func minimumMVerticalDerivative(_ model:Model)->Double {
        let c=model.configuration.mShape,profile=c.profile.maximumValue
        let lower=c.lowerCenter
        let amplitude=lower.map { abs($0.vector.y) } ?? 0
        let lowerDerivative=lower.map { amplitude*8/(3*sqrt(3.0)*$0.radius.y) } ?? 0
        let total=profile+amplitude
        var bound=total*c.envelope.gradientBounds.y+lowerDerivative
        bound += profile*(c.profileEnvelope?.gradientBounds.y ?? 0)
        if let source=c.sourceEnvelope {
            // A lower peak cannot contribute to an upper protective feather
            // when their complete source-y supports are disjoint.
            let lowY=lower.map { model.configuration.seam.minimumValue+$0.center.y-$0.radius.y } ?? .infinity
            let highY=lower.map { model.configuration.seam.maximumValue+$0.center.y+$0.radius.y } ?? -.infinity
            let upperOverlap=highY>=source.outerMin.y && lowY<=source.innerMin.y
            let lowerOverlap=highY>=source.innerMax.y && lowY<=source.outerMax.y
            let upper=(profile+(upperOverlap ? amplitude:0))*1.5/(source.innerMin.y-source.outerMin.y)
            let bottom=(profile+(lowerOverlap ? amplitude:0))*1.5/(source.outerMax.y-source.innerMax.y)
            bound += max(upper,bottom)
        }
        return -bound
    }

    private func sampleLocal(_ p:Point,field:Model.Field)->Model.Sample {
        guard p.x>sourceMinimum.x,p.x<sourceMaximum.x,p.y>sourceMinimum.y,p.y<sourceMaximum.y else { return .zero }
        if field == .tilt {
            // Attenuate the angle itself, retaining radius and an exact circle
            // inverse even under pose admission. Scaling a rotation vector
            // instead would introduce a radial contraction.
            return model.sample(field:field,strength:values[field.rawValue]*fieldScales[field.rawValue],at:p)
        }
        return model.sample(field:field,strength:values[field.rawValue],at:p).scaled(by:fieldScales[field.rawValue])
    }
}

extension BeautyContinuousMouthMap: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String { "BeautyContinuousMouthMap(fields: \(active.count), privateGeometry: redacted)" }
    var debugDescription: String { description }
    var customMirror: Mirror { Mirror(self, children: ["fieldCount": active.count], displayStyle: .struct) }
}
