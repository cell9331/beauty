#!/usr/bin/env python3
"""Exact horizontal RGB inverse correspondence for an admitted sampler only.

No photometry/blur fitting. The caller must independently establish horizontal
canonical sampling, unchanged color processing and the specified byte bound.
No image I/O, field-coordinate oracle, source registrar or portrait acceptance.
"""
from fractions import Fraction as F


class Unavailable(Exception):
    pass


def inverse_intervals(source, observed, lower, upper, error=F(1)):
    """All q with |linear_RGB(source,q)-observed| <= error in every channel.

    Every closed source cell is checked using exact rational inequalities;
    disconnected explanations stay disconnected. No best-match selection.
    """
    if (type(source) not in (tuple,list) or not 2 <= len(source) <= 8192
        or type(observed) not in (tuple,list) or len(observed) != 3
        or any(type(p) not in (tuple,list) or len(p) != 3 for p in source)
        or any(type(v) is not int or not 0 <= v <= 255 for p in (*source,observed) for v in p)
        or type(lower) is not int or type(upper) is not int
        or not 0 <= lower < upper <= len(source)-1
        or type(error) is not F or not 0 <= error <= 1):
        raise Unavailable('invalid_sampler_input')
    result = []
    for j in range(lower,upper):
        lo,hi = F(0),F(1)
        for channel in range(3):
            base = source[j][channel]
            gradient = source[j+1][channel]-base
            a = F(observed[channel])-error-base
            b = F(observed[channel])+error-base
            if gradient == 0:
                if not a <= 0 <= b:
                    lo,hi = F(1),F(0)
                    break
            else:
                a,b = a/gradient,b/gradient
                lo,hi = max(lo,min(a,b)),min(hi,max(a,b))
                if lo > hi:
                    break
        if lo <= hi:
            interval = (F(j)+lo,F(j)+hi)
            if result and interval[0] <= result[-1][1]:
                result[-1] = (result[-1][0],max(result[-1][1],interval[1]))
            else:
                result.append(interval)
    if not result:
        raise Unavailable('no_sampler_correspondence')
    return tuple(result)


def inverse_hull(source, observed, lower, upper, error=F(1)):
    intervals = inverse_intervals(source,observed,lower,upper,error)
    return intervals[0][0],intervals[-1][1]
