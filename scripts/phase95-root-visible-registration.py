#!/usr/bin/env python3
"""Generated-only local visible-knot registrar prototype, not source admission.

The prior is a conditional semantic input, NOT a certified detector error.
Every plausible outward alternative survives. No output pixels or files enter
this module. End-to-end anatomical applicability remains to be established.
"""
from fractions import Fraction as F
from pathlib import Path
import runpy
import time

_affine = runpy.run_path(str(Path(__file__).with_name('phase95-root-affine-source.py')))
Unavailable = _affine['Unavailable']
SUPPORTS = (4, 8, 16)


def local_knots(values, deadline):
    if (type(values) is not tuple or not 12 <= len(values) <= 512
            or any(type(v) is not int or not 0 <= v <= 255 * 256 for v in values)):
        raise Unavailable('invalid_profile')
    values = tuple(F(v, 256) for v in values)
    knots = set()
    for cut in range(4, len(values) - 3):
        for count in SUPPORTS:
            if cut < count or cut + count > len(values):
                continue
            outer = _affine['fit'](values[cut-count:cut], cut-count, deadline)
            inner = _affine['fit'](values[cut:cut+count], cut, deadline)
            if not outer or not inner:
                continue
            slopes = [a1-a0 for a0, _ in outer for a1, _ in inner]
            sign = (1 if min(slopes)*(count-1) >= 8 else
                    -1 if max(slopes)*(count-1) <= -8 else 0)
            if not sign:
                continue
            positions = [(b0-b1)/(a1-a0) for a0, b0 in outer for a1, b1 in inner]
            lo, hi = max(F(cut-1), min(positions)), min(F(cut), max(positions))
            if lo <= hi:
                knots.add((lo, hi, sign))
    return tuple(sorted(knots))


def supported_side(values, prior, deadline=None):
    """Exterior-to-interior coordinates; preserve outward competing structures.

    The input interval is a proposed semantic search band. A visible knot must
    intersect it; it cannot manufacture support. Knots outward of it are kept
    even if the prediction is incorrectly attracted to stronger inner texture.
    """
    if type(values) is not tuple:
        raise Unavailable('invalid_profile')
    if (type(prior) is not tuple or len(prior) != 2
            or any(type(v) not in (int, F) for v in prior)
            or any(F(v).numerator.bit_length() > 128 or
                   F(v).denominator.bit_length() > 128 for v in prior)
            or not 0 <= prior[0] <= prior[1] < len(values)):
        raise Unavailable('invalid_prior')
    deadline = time.monotonic()+30 if deadline is None else deadline
    knots = local_knots(values, deadline)
    if not any(lo <= prior[1] and hi >= prior[0] for lo, hi, _ in knots):
        raise Unavailable('prior_without_visible_support')
    # Keep all polarities outward too: source ambiguity is not resolved by
    # choosing whichever sign matches the prediction.
    result = tuple(k for k in knots if k[0] <= prior[1])
    if len(result) > 64:
        raise Unavailable('candidate_budget')
    return result


def row_candidates(profile, bounds, priors):
    if (type(profile) is not tuple or type(bounds) is not tuple or len(bounds) != 3
            or any(type(x) is not int for x in bounds)
            or not 0 <= bounds[0] < bounds[1] < bounds[2] <= len(profile)
            or type(priors) is not tuple or len(priors) != 2):
        raise Unavailable('invalid_row')
    lo, split, hi = bounds
    deadline = time.monotonic()+30
    left = supported_side(profile[lo:split], priors[0], deadline)
    right = supported_side(tuple(reversed(profile[split:hi])), priors[1], deadline)
    # Side lighting need not be symmetric. Deleting mixed-polarity pairs can
    # remove the actual stationary outer interpretation while retaining inner
    # candidates. Carry both signs instead of using them as a pairing filter.
    pairs = tuple((a+lo, b+lo, F(hi-1)-d, F(hi-1)-c, (sign, other))
                  for a, b, sign in left for c, d, other in right
                  if b+lo < F(hi-1)-d)
    if not pairs:
        raise Unavailable('bilateral_support_missing')
    if len(pairs) > 256:
        raise Unavailable('candidate_budget')
    return pairs
