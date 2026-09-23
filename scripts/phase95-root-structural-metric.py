#!/usr/bin/env python3
"""Generated-only cohort reduction for source-anchored root width intervals.

This consumes in-memory widths from the forward primitive; it cannot register
anatomy, read images, approve a metric, or issue a portrait/closeout receipt.
"""
from fractions import Fraction as F

ROLES = ('source', 'neutral', 'candidate', 'noseBridge_0p30', 'noseSlim_0p35', 'noseTipLift_0p25')

class Rejected(Exception):
    pass

def measure(image_width, registered_rows, widths):
    """Equal-row means, full-image Q16 units, outward rounding only at the end.

    Each role maps the identical pre-registered integer row IDs to (lo, hi)
    Fractions. They are physical widths, not displacement of interior probes.
    The caller must independently establish anatomy, correspondence validity,
    metadata and original target/protection predicates before acceptance.
    """
    if (type(image_width) is not int or not 32 <= image_width <= 8192
        or type(registered_rows) is not tuple or not 12 <= len(registered_rows) <= 16
        or any(type(x) is not int or not 0 <= x < 16 for x in registered_rows)
        or tuple(sorted(set(registered_rows))) != registered_rows
        or type(widths) is not dict or set(widths) != set(ROLES)):
        raise Rejected('invalid_cohort')
    intervals = {}
    scale = F(65536, image_width * len(registered_rows))
    for role in ROLES:
        rows = widths[role]
        if type(rows) is not dict or set(rows) != set(registered_rows) or any(type(k) is not int for k in rows):
            raise Rejected('correspondence_rows_changed')
        for value in rows.values():
            if (type(value) is not tuple or len(value) != 2
                or any(type(v) is not F or v.numerator.bit_length() > 128
                       or v.denominator.bit_length() > 128 for v in value)
                or not 0 < value[0] <= value[1] <= image_width):
                raise Rejected('invalid_width_interval')
        lo = sum((rows[y][0] for y in registered_rows), F(0)) * scale
        hi = sum((rows[y][1] for y in registered_rows), F(0)) * scale
        intervals[role] = (lo.numerator // lo.denominator, -((-hi.numerator) // hi.denominator))
    candidate = intervals['candidate']
    source_margin = intervals['source'][0] - candidate[1]
    neutral_margin = intervals['neutral'][0] - candidate[1]
    sibling_margins = [max(0, intervals[role][0] - candidate[1], candidate[0] - intervals[role][1])
                       for role in ROLES[3:]]
    return {'source_margin_q16': source_margin, 'neutral_margin_q16': neutral_margin,
            'sibling_margin_q16': min(sibling_margins),
            'structural_pass': min(source_margin, neutral_margin, *sibling_margins) >= 16}


def measure_hypotheses(image_width, registered_rows, hypotheses):
    """Require contraction/distinctness for every source-owned interpretation.

    A hypothesis is one complete role→row→width-interval mapping. Its position
    in the tuple is fixed by source registration, never selected from outputs.
    This reducer cannot prove that a registrar supplied a complete set, nor
    substitute for visible-structure ownership or correspondence admission.
    """
    if type(hypotheses) is not tuple or not 1 <= len(hypotheses) <= 64:
        raise Rejected('invalid_hypotheses')
    measured = [measure(image_width, registered_rows, value) for value in hypotheses]
    result = {key: min(value[key] for value in measured) for key in
              ('source_margin_q16', 'neutral_margin_q16', 'sibling_margin_q16')}
    result['hypotheses'] = len(measured)
    result['structural_pass'] = min(result[key] for key in
        ('source_margin_q16', 'neutral_margin_q16', 'sibling_margin_q16')) >= 16
    return result
