#!/usr/bin/env python3
"""Generated-only shared-anchor change bounds. No image I/O or admission."""
from fractions import Fraction as F
from pathlib import Path
import runpy

_forward = runpy.run_path(str(Path(__file__).with_name('phase95-root-forward-span.py')))


class Rejected(Exception):
    pass


def _fraction(value):
    return type(value) is F and value.numerator.bit_length() <= 128 and value.denominator.bit_length() <= 128


def _model(value):
    if type(value) is not tuple or len(value) != 3:
        raise Rejected('invalid_model')
    samples, low, high = value
    if (type(samples) is not tuple or not 2 <= len(samples) <= 33
        or not _fraction(low) or not _fraction(high) or not 0 < low <= high
        or any(type(p) is not tuple or len(p) != 3 or not all(_fraction(v) for v in p) for p in samples)):
        raise Rejected('invalid_model')
    return samples, low, high


def _envelope(a, b, width, low, high):
    # For d(s)=f_reference(s)-f_candidate(s), derivative/secant bounds
    # low <= (d(t)-d(s))/(t-s) <= high follow from BOTH admitted maps.
    # Lower envelope is max of two lines; upper is min of two lines.
    lower_lines = ((a[0], low), (b[0]-high*width, high))
    upper_lines = ((a[1], high), (b[1]-low*width, low))
    def extrema(lines, maximum, minimum_over_domain):
        xs = [F(0), width]
        (u, v), (r, s) = lines
        if v != s:
            x = (r-u)/(v-s)
            if 0 <= x <= width:
                xs.append(x)
        values = [(max if maximum else min)(u+v*x,r+s*x) for x in xs]
        return (min if minimum_over_domain else max)(values)
    return extrema(lower_lines,True,True), extrema(upper_lines,False,False)


def change(anchor, reference, candidate, cells=8):
    """Enclose f_reference(s)-f_candidate(s) for the SAME s in anchor.

    Input model is (inverse samples, minimum secant slope, maximum slope).
    Secant bounds and structural identity must be independently admitted.
    Source uncertainty is retained once, never replaced by its midpoint.
    Every subcell and every feasible map contributes to the returned hull.
    """
    if (type(anchor) is not tuple or len(anchor) != 2 or not all(_fraction(v) for v in anchor)
        or not anchor[0] <= anchor[1] or anchor[1]-anchor[0] > 64
        or type(cells) is not int or not 1 <= cells <= 32):
        raise Rejected('invalid_anchor')
    rs, rm, rM = _model(reference)
    cs, cm, cM = _model(candidate)
    low, high = 1/rM-1/cm, 1/rm-1/cM
    count = cells if anchor[0] < anchor[1] else 1
    points = [anchor[0]+(anchor[1]-anchor[0])*F(i,count) for i in range(count+1)]
    intervals = []
    try:
        for s in points:
            r = _forward['position']((s,s),rs,rm,rM)
            c = _forward['position']((s,s),cs,cm,cM)
            intervals.append((r[0]-c[1],r[1]-c[0]))
    except _forward['Rejected'] as error:
        raise Rejected('invalid_correspondence') from error
    if anchor[0] == anchor[1]:
        return intervals[0]
    bounds = [_envelope(a,b,y-x,low,high) for x,y,a,b in zip(points,points[1:],intervals,intervals[1:])]
    if any(lo > hi for lo,hi in bounds):
        raise Rejected('inconsistent_change')
    return min(v[0] for v in bounds), max(v[1] for v in bounds)


def width_change(left_anchor, right_anchor, reference, candidate, cells=8):
    """Reference width minus candidate width; shared source pair in both.

    Left/right uncertainty may be independently combined conservatively.
    Positive bounds must still meet source, neutral, sibling and protection gates.
    """
    left = change(left_anchor,reference,candidate,cells)
    right = change(right_anchor,reference,candidate,cells)
    if left_anchor[1] >= right_anchor[0]:
        raise Rejected('unordered_structure')
    return right[0]-left[1], right[1]-left[0]


REFERENCES = ('source','neutral','noseBridge_0p30','noseSlim_0p35','noseTipLift_0p25')


def measure_changes(image_width, rows, differences):
    """Reduce signed reference-minus-candidate width changes, then round.

    Same pre-registered rows and all references are mandatory. Sibling distance
    is computed AFTER the signed mean; opposite row differences may cancel.
    This still requires independently admitted source structure and pixels.
    """
    if (type(image_width) is not int or not 32 <= image_width <= 8192
        or type(rows) is not tuple or not 12 <= len(rows) <= 16
        or any(type(x) is not int or not 0 <= x < 16 for x in rows)
        or tuple(sorted(set(rows))) != rows
        or type(differences) is not dict or set(differences) != set(REFERENCES)):
        raise Rejected('invalid_cohort')
    intervals = {}
    scale = F(65536,image_width*len(rows))
    for role in REFERENCES:
        values=differences[role]
        if (type(values) is not dict or set(values) != set(rows)
            or any(type(k) is not int for k in values)
            or any(type(v) is not tuple or len(v) != 2 or not all(_fraction(x) for x in v)
                   or not -image_width <= v[0] <= v[1] <= image_width for v in values.values())):
            raise Rejected('invalid_row_changes')
        lo=sum((v[0] for v in values.values()),F(0))*scale
        hi=sum((v[1] for v in values.values()),F(0))*scale
        intervals[role]=(lo.numerator//lo.denominator,-((-hi.numerator)//hi.denominator))
    sibling=min(max(0,intervals[role][0],-intervals[role][1]) for role in REFERENCES[2:])
    result={'source_margin_q16':intervals['source'][0],'neutral_margin_q16':intervals['neutral'][0],
            'sibling_margin_q16':sibling}
    result['structural_pass']=min(result.values()) >= 16
    return result
