#!/usr/bin/env python3
"""In-memory material localization for an independently admitted horizontal sampler.

No CLI, file pixels, production fields, anatomy detector, or sibling claims.
Every feasible RGB source cell is retained before conservative monotone-map
propagation. Integer source rows are mandatory; no unobserved continuous-Y
interpolation or locally constant/affine deformation assumption is made.
"""
from dataclasses import dataclass
from fractions import Fraction as F
from pathlib import Path
import math
import hashlib
import runpy

import numpy as np

HERE=Path(__file__).parent
SAMPLER=runpy.run_path(str(HERE/'phase95-root-sampler-correspondence.py'))
FORWARD=runpy.run_path(str(HERE/'phase95-root-forward-span.py'))
# Reuse only input/patch and zero-motion photometric-feasibility helpers.
# LK estimates, empirical floors, and its output decisions are never used.
PHOTOMETRY=runpy.run_path(str(HERE/'phase95-root-regional-motion.py'))


class Unavailable(ValueError):
    pass


@dataclass(frozen=True)
class HorizontalModel:
    minimum_slope:F
    maximum_slope:F
    maximum_displacement:int


@dataclass(frozen=True)
class HorizontalCohort:
    shape:tuple
    points:tuple
    source_digest:str


def _model(model):
    if (type(model) is not HorizontalModel or type(model.minimum_slope) is not F
        or type(model.maximum_slope) is not F
        or not F(1,100)<=model.minimum_slope<=model.maximum_slope<=100
        or type(model.maximum_displacement) is not int or not 1<=model.maximum_displacement<=96):
        raise Unavailable('invalid_horizontal_model')


def _pairs(pairs,shape):
    if type(pairs) not in (list,tuple) or not 4<=len(pairs)<=96:
        raise Unavailable('invalid_pairs')
    result=[];h,w,_=shape
    for pair in pairs:
        if type(pair) not in (list,tuple) or len(pair)!=2:raise Unavailable('invalid_pairs')
        p=[]
        for point in pair:
            if (type(point) not in (list,tuple) or len(point)!=2
                or any(type(v) not in (int,float) or not math.isfinite(v) for v in point)):
                raise Unavailable('invalid_pairs')
            x,y=point
            if y!=int(y):raise Unavailable('integer_source_rows_required')
            if not 7<=x<w-7 or not 7<=y<h-7:raise Unavailable('invalid_pairs')
            p.append((F(str(x)),int(y)))
        if p[0][0]>=p[1][0]:raise Unavailable('unordered_pairs')
        result.append(tuple(p))
    return tuple(result)


def register(source,pairs):
    """Keep every fixed semantic parameter's weight, including raster aliases.

    Multiple distinct source parameters can project to the same integer-row
    pixel. They are repeated weights, never independent error observations;
    interval reduction does not divide uncertainty by sqrt(sample_count).
    """
    try:source=PHOTOMETRY['_image'](source)
    except PHOTOMETRY['Unavailable']:raise Unavailable('invalid_rgb') from None
    checked=_pairs(pairs,source.shape)
    points=tuple(tuple((float(x),y) for x,y in pair) for pair in checked)
    return HorizontalCohort(tuple(source.shape),points,hashlib.sha256(source.tobytes()).hexdigest())


def _tighten(samples,m,M):
    """Necessary interval propagation on a chain; keeps every feasible map."""
    values=[list(p) for p in samples]
    for i in range(1,len(values)):
        a,b=values[i-1],values[i];dx=b[0]-a[0]
        b[1]=max(b[1],a[1]+m*dx);b[2]=min(b[2],a[2]+M*dx)
    for i in range(len(values)-2,-1,-1):
        a,b=values[i],values[i+1];dx=b[0]-a[0]
        a[1]=max(a[1],b[1]-M*dx);a[2]=min(a[2],b[2]-m*dx)
    if any(lo>hi for _,lo,hi in values):raise Unavailable('inconsistent_correspondence')
    return tuple(tuple(p) for p in values)


def localize(source,output,pairs,model):
    """Return all fixed point X intervals as paired ((lo,hi,y),(lo,hi,y)).

    Caller must prove actual canonical pixel-center horizontal interpolation,
    unchanged color/alpha, <=1 byte image formation error, secant bounds, and
    displacement ceiling. These are model applicability, never measured motion.
    Search windows are source-owned and contain the ENTIRE admitted motion
    range; missing crop context fails instead of truncating feasible donors.
    """
    _model(model)
    try:source=PHOTOMETRY['_image'](source);output=PHOTOMETRY['_image'](output)
    except PHOTOMETRY['Unavailable']:raise Unavailable('invalid_rgb') from None
    if source.shape!=output.shape:raise Unavailable('image_shape')
    pairs=_pairs(pairs,source.shape)
    # Equal RGB does not prove a material point stayed fixed: flat or periodic
    # texture can hide nonzero admissible motion. Only separately qualified
    # no-influence roles may use identity_positions()'s exact-anchor shortcut.
    displacement=model.maximum_displacement;h,w,_=source.shape
    row_cache={};sample_cache={};result=[]
    for pair in pairs:
        localized=[]
        for anchor,y in pair:
            start=math.floor(anchor)-displacement-2;end=math.ceil(anchor)+displacement+2
            if start-displacement<0 or end+displacement>=w:
                raise Unavailable('insufficient_crop_context')
            row=row_cache.setdefault(y,source[y].tolist())
            samples=[]
            for x in range(start,end+1):
                key=(y,x)
                if key not in sample_cache:
                    try:
                        lo,hi=SAMPLER['inverse_hull'](row,output[y,x].tolist(),x-displacement,x+displacement)
                    except SAMPLER['Unavailable']:
                        raise Unavailable('no_sampler_correspondence') from None
                    sample_cache[key]=(F(x),lo,hi)
                samples.append(sample_cache[key])
            samples=_tighten(samples,model.minimum_slope,model.maximum_slope)
            try:
                lo,hi=FORWARD['position']((anchor,anchor),samples,model.minimum_slope,model.maximum_slope)
            except FORWARD['Rejected']:
                raise Unavailable('unavailable_forward_position') from None
            point=(float(anchor),float(y))
            if PHOTOMETRY['_zero_motion_photometry'](PHOTOMETRY['_patch'](source,point),PHOTOMETRY['_patch'](output,point)):
                lo=min(lo,anchor);hi=max(hi,anchor)
            localized.append((lo,hi,y))
        if localized[0][1]>=localized[1][0]:raise Unavailable('ambiguous_pair_order')
        result.append(tuple(localized))
    return tuple(result)


def measure(source,candidate,neutral,pairs,full_image_width,model):
    """Source/neutral-only prototype; exact original Q16 normalization."""
    if (type(full_image_width) is not int or not isinstance(source,np.ndarray)
        or source.ndim!=3 or not source.shape[1]<=full_image_width<=8192):
        raise Unavailable('invalid_full_image_width')
    if not isinstance(neutral,np.ndarray) or not np.array_equal(source,neutral):
        raise Unavailable('neutral_not_identity')
    coordinates=_pairs(pairs,source.shape)
    positioned=localize(source,candidate,pairs,model)
    lower=upper=F(0)
    for original,(left,right) in zip(coordinates,positioned):
        original_width=original[1][0]-original[0][0]
        lower+=original_width-(right[1]-left[0])
        upper+=original_width-(right[0]-left[1])
    scale=F(65536,full_image_width*len(pairs))
    interval=(math.floor(lower*scale),math.ceil(upper*scale))
    return {'schema':'phase95-horizontal-material-prototype-v1','pair_count':len(pairs),
            'source_interval_q16':interval,'neutral_interval_q16':interval,
            'source_threshold_pass':interval[0]>=16,'measurement_admitted':False,
            'includes_siblings':False}


REFERENCES=('source','neutral','noseBridge_0p30','noseSlim_0p35','noseTipLift_0p25')


def identity_positions(source,output,pairs,region):
    """Require actual identity of the WHOLE supplied original root rectangle.

    Caller separately proves absence of sampling influence in that rectangle;
    this function cannot turn same-looking ambiguous texture into that proof.
    Context outside the rectangle may differ. No point-specific masks are used.
    """
    try:source=PHOTOMETRY['_image'](source);output=PHOTOMETRY['_image'](output)
    except PHOTOMETRY['Unavailable']:raise Unavailable('invalid_rgb') from None
    if source.shape!=output.shape:raise Unavailable('image_shape')
    h,w,_=source.shape
    if (type(region) not in (list,tuple) or len(region)!=4 or any(type(v) is not int for v in region)
        or not 0<=region[0]<region[2]<=w or not 0<=region[1]<region[3]<=h):
        raise Unavailable('invalid_identity_region')
    coordinates=_pairs(pairs,source.shape);x0,y0,x1,y1=region
    if any(not x0<=x<x1 or not y0<=y<y1 for pair in coordinates for x,y in pair):
        raise Unavailable('identity_points_outside_region')
    if not np.array_equal(source[y0:y1,x0:x1],output[y0:y1,x0:x1]):
        raise Unavailable('identity_region_changed')
    return tuple(tuple((x,x,y) for x,y in pair) for pair in coordinates)


def measure_roles(source,outputs,pairs,full_image_width,models,identity_region):
    """All-role reducer; every sampler or identity eligibility is caller-proved.

    Each exact role requires a HorizontalModel or literal 'identity'. Identity
    still executes the complete rectangle byte check. No unsupported sibling
    can be silently replaced with source pixels or dropped from the result.
    """
    expected={'candidate',*REFERENCES[1:]}
    if (type(outputs) is not dict or set(outputs)!=expected
        or type(models) is not dict or set(models)!=expected):raise Unavailable('missing_roles')
    if (not isinstance(source,np.ndarray) or source.ndim!=3 or type(full_image_width) is not int
        or not source.shape[1]<=full_image_width<=8192):raise Unavailable('invalid_full_image_width')
    coordinates=_pairs(pairs,source.shape)
    positions={'source':tuple(tuple((x,x,y) for x,y in p) for p in coordinates)}
    for role in ('candidate',*REFERENCES[1:]):
        model=models[role]
        positions[role]=(identity_positions(source,outputs[role],pairs,identity_region)
                         if model=='identity' else localize(source,outputs[role],pairs,model))
    intervals={};counts={};scale=F(65536,full_image_width*len(pairs));candidate=positions['candidate']
    for role in REFERENCES:
        lower=upper=F(0);positive=0
        for (left,right),(cl,cr) in zip(positions[role],candidate):
            lo=(right[0]-left[1])-(cr[1]-cl[0]);hi=(right[1]-left[0])-(cr[0]-cl[1])
            lower+=lo;upper+=hi;positive+=int(lo*F(65536,full_image_width)>=16)
        intervals[role]=(math.floor(lower*scale),math.ceil(upper*scale));counts[role]=positive
    passed=(intervals['source'][0]>=16 and intervals['neutral'][0]>=16
            and all(intervals[r][0]>=16 or intervals[r][1]<=-16 for r in REFERENCES[2:]))
    return {'schema':'phase95-horizontal-material-prototype-v1','pair_count':len(pairs),
            'intervals_q16':intervals,'positive_pair_counts':counts,'threshold_pass':passed,
            'measurement_admitted':False,'includes_siblings':True}
