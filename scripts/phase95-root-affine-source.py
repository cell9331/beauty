#!/usr/bin/env python3
"""Output-blind affine-flank visible-transition model; no anatomy approval.

Exact set-valued line fits retain null explanations and every feasible knot
interval in the declared finite support family. No private file I/O or scoring.
"""
from fractions import Fraction as F
import time


class Unavailable(Exception):
    pass


ERROR=F(2)
SUPPORTS=(4,8,16,32)
MIN_CONTRAST=F(8)


def clip(poly,a,b,rhs):
    if not poly:return ()
    result=[]
    for p,q in zip(poly,poly[1:]+poly[:1]):
        dp,dq=a*p[0]+b*p[1]-rhs,a*q[0]+b*q[1]-rhs
        if dp<=0:result.append(p)
        if (dp<0<dq) or (dq<0<dp):
            t=dp/(dp-dq)
            result.append(tuple(x+t*(y-x) for x,y in zip(p,q)))
    return tuple(dict.fromkeys(result))


def box():
    return ((F(-512),F(-2)),(F(512),F(-2)),(F(512),F(257)),(F(-512),F(257)))


def add(poly,x,value):
    return clip(clip(poly,F(x),F(1),value+ERROR),-F(x),-F(1),ERROR-value)


def fit(values,origin,deadline):
    # Intercept is at the first sample; translate back to global local-row x.
    poly=box()
    for i,value in enumerate(values):
        if time.monotonic()>deadline:raise Unavailable('work_limit')
        poly=add(poly,i,value)
        if not poly:return ()
    return tuple((a,b-a*origin) for a,b in poly)


def side(values,deadline=None):
    """Values are ordered from admitted exterior toward the original ROI split."""
    if (type(values) is not tuple or not 12<=len(values)<=512
        or any(type(v) is not int or not 0<=v<=255*256 for v in values)):
        raise Unavailable('invalid_affine_profile')
    deadline=time.monotonic()+30 if deadline is None else deadline
    values=tuple(F(v,256) for v in values)
    if fit(values,0,deadline):return {'null':True,'knots':()}
    outer=box();knots=[]
    for cut in range(len(values)-3):
        if time.monotonic()>deadline:raise Unavailable('work_limit')
        if cut:
            outer=add(outer,cut-1,values[cut-1])
        if not outer:break
        if cut<4:continue
        for count in SUPPORTS:
            if cut+count>len(values):continue
            inner=fit(values[cut:cut+count],cut,deadline)
            if not inner:continue
            slopes=[a1-a0 for a0,b0 in outer for a1,b1 in inner]
            lo,hi=min(slopes),max(slopes)
            sign=1 if lo*(count-1)>=MIN_CONTRAST else -1 if hi*(count-1)<=-MIN_CONTRAST else 0
            if not sign:continue
            # Denominator has one strict sign over the convex product. A
            # linear-fractional function attains extrema at product vertices.
            positions=[(b0-b1)/(a1-a0) for a0,b0 in outer for a1,b1 in inner]
            left,right=max(F(cut-1),min(positions)),min(F(cut),max(positions))
            if left<=right:knots.append((left,right,sign))
    # Merge overlap of same-sign intervals; never bridge a gap or choose a peak.
    result=[]
    for sign in (-1,1):
        for lo,hi,_ in sorted(k for k in knots if k[2]==sign):
            if result and result[-1][2]==sign and lo<=result[-1][1]:
                result[-1]=(result[-1][0],max(result[-1][1],hi),sign)
            else:result.append((lo,hi,sign))
    return {'null':False,'knots':tuple(result)}


def _register(profiles,bounds,counts):
    if (type(profiles) is not tuple or len(profiles)!=16
        or type(bounds) is not tuple or len(bounds)!=16
        or any(type(p) is not tuple for p in profiles)
        or len({len(p) for p in profiles})!=1):
        raise Unavailable('invalid_inventory')
    layers=[]
    deadline=time.monotonic()+120
    cache={}
    def cached_side(values):
        if values not in cache:cache[values]=side(values,deadline)
        return cache[values]
    null_rows=0
    for row,(profile,bound) in enumerate(zip(profiles,bounds)):
        if (type(bound) is not tuple or len(bound)!=3
            or any(type(x) is not int for x in bound)
            or not 0<=bound[0]<bound[1]<bound[2]<=len(profile)):
            raise Unavailable('invalid_bounds')
        lo,split,hi=bound
        left,right=cached_side(profile[lo:split]),cached_side(tuple(reversed(profile[split:hi])))
        counts['processed_rows']+=1
        if left['null'] or right['null']:
            null_rows+=1
            counts['null_rows']=null_rows
            continue
        pairs=tuple((a+lo,b+lo,F(hi-1)-d,F(hi-1)-c,sign)
                    for a,b,sign in left['knots'] for c,d,other in right['knots']
                    if sign==other and b+lo<F(hi-1)-d)
        if len(pairs)>64:raise Unavailable('candidate_budget')
        if pairs:
            layers.append((row,pairs))
            counts['paired_candidate_rows']+=1
            counts['candidate_nodes_before']+=len(pairs)
    counts['scan_complete']=True
    if len(layers)<12:raise Unavailable('affine_visible_coverage')
    def neighbors(a,b):
        return (a[4]==b[4] and max(F(0),a[0]-b[1],b[0]-a[1])<=4
                and max(F(0),a[2]-b[3],b[2]-a[3])<=4)
    # Keep a layered graph, not an exponentially truncated enumeration of paths.
    for i in range(1,len(layers)):
        row,current=layers[i]
        kept=tuple(p for p in current if any(neighbors(q,p) for q in layers[i-1][1]))
        if not kept:raise Unavailable('affine_discontinuous')
        layers[i]=(row,kept)
    for i in range(len(layers)-2,-1,-1):
        row,current=layers[i]
        layers[i]=(row,tuple(p for p in current if any(neighbors(p,q) for q in layers[i+1][1])))
    counts['candidate_nodes_after']=sum(len(pairs) for _,pairs in layers)
    counts['continuity_complete']=True
    return tuple(layers),null_rows


def collect(profiles,bounds):
    counts={'processed_rows':0,'null_rows':0,'paired_candidate_rows':0,
            'candidate_nodes_before':0,'candidate_nodes_after':0,
            'scan_complete':False,'continuity_complete':False}
    try:
        return _register(profiles,bounds,counts),counts
    except Unavailable as error:
        error.counts=counts.copy()
        raise


def register(profiles,bounds):
    return collect(profiles,bounds)[0]


def diagnostic(profiles,bounds):
    try:
        (layers,null_rows),counts=collect(profiles,bounds)
        return {'status':'source_candidates','candidate_rows':len(layers),
                'candidate_nodes':sum(len(p) for _,p in layers),'null_rows':null_rows,
                'scan':counts,
                'anatomical_boundary_qualified':False,'portrait_scoring_enabled':False}
    except Unavailable as error:
        return {'status':'metric_unavailable','reason':str(error),'scan':error.counts,
                'anatomical_boundary_qualified':False,'portrait_scoring_enabled':False}
