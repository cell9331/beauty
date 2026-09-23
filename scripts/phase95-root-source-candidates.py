#!/usr/bin/env python3
"""Source-only visible transition candidates, never anatomical admission.

Bounded diagnostic prototype for a deliberately narrow plateau-edge image
model. Completeness outside that model is NOT established. No image/file I/O.
"""

class Unavailable(Exception):
    pass


# Luminance is exact integer Q8. Visibility/model bounds, not effect thresholds.
NOISE_RANGE = 4 * 256
MIN_CONTRAST = 8 * 256
SUPPORT = 4
MAX_HYPOTHESES = 64


def flat(values):
    return bool(values) and max(values) - min(values) <= NOISE_RANGE


def row_pairs(profile, lo, split, hi):
    """Keep all opposite-polarity pairs with supported OUTER flanks.

    An edge index denotes the gap [x-1,x] between source pixel centers.
    Full exterior-flank flatness prevents an obvious strong interior edge
    from taking ownership while another visible exterior boundary exists.
    """
    if (type(profile) is not tuple or not 32 <= len(profile) <= 8192
        or any(type(v) is not int or not 0 <= v <= 255 * 256 for v in profile)
        or any(type(v) is not int for v in (lo, split, hi))
        or not 0 <= lo < split < hi <= len(profile)):
        raise Unavailable('invalid_profile')
    sides = []
    for a, b in ((lo, split), (split, hi)):
        edges = []
        for x in range(a + SUPPORT, b - SUPPORT + 1):
            before, after = profile[x-SUPPORT:x], profile[x:x+SUPPORT]
            if not flat(before) or not flat(after):
                continue
            delta = sum(after) - sum(before)
            if abs(delta) >= SUPPORT * MIN_CONTRAST:
                edges.append((x, 1 if delta > 0 else -1))
        sides.append(edges)
    pairs = []
    for left, sign in sides[0]:
        if not flat(profile[lo:left]):
            continue
        for right, other in sides[1]:
            if sign == -other and flat(profile[right:hi]):
                pairs.append((left, right, sign))
                if len(pairs) > MAX_HYPOTHESES:
                    raise Unavailable('candidate_budget')
    return tuple(pairs)


def hypotheses(profiles, bounds):
    """Preserve every continuous paired path through all source-visible rows.

    The caller supplies exactly the original16 row bins and fixed source-only
    exclusion bounds. Rows lacking visible pairs are recorded before scoring;
    at least12 remain required. No output-dependent omission is possible here.
    """
    if (type(profiles) is not tuple or len(profiles) != 16
        or type(bounds) is not tuple or len(bounds) != 16
        or any(type(b) is not tuple or len(b) != 3 for b in bounds)):
        raise Unavailable('invalid_inventory')
    if any(type(p) is not tuple for p in profiles) or len({len(p) for p in profiles}) != 1:
        raise Unavailable('inconsistent_dimensions')
    rows = []
    for row, (profile, bound) in enumerate(zip(profiles, bounds)):
        pairs = row_pairs(profile, *bound)
        if pairs:
            rows.append((row, pairs))
    if len(rows) < 12:
        raise Unavailable('visible_coverage')
    paths = [()]
    for row, pairs in rows:
        next_paths = []
        for path in paths:
            for left, right, sign in pairs:
                if path:
                    prior = path[-1]
                    if sign != prior[3] or max(abs(left-prior[1]), abs(right-prior[2])) > 4:
                        continue
                next_paths.append(path + ((row, left, right, sign),))
                if len(next_paths) > MAX_HYPOTHESES:
                    raise Unavailable('hypothesis_budget')
        paths = next_paths
        if not paths:
            raise Unavailable('discontinuous_structure')
    return tuple(paths)


def diagnostic(profiles, bounds):
    try:
        candidates = hypotheses(profiles, bounds)
        return {'status': 'source_candidates', 'hypotheses': len(candidates),
                'registered_rows': len(candidates[0]), 'anatomical_boundary_qualified': False,
                'portrait_scoring_enabled': False}
    except Unavailable as error:
        return {'status': 'metric_unavailable', 'reason': str(error),
                'anatomical_boundary_qualified': False, 'portrait_scoring_enabled': False}
