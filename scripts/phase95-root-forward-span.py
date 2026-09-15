#!/usr/bin/env python3
"""Generated-only forward localization from bounded inverse correspondences.

No image I/O, anatomical registrar, production-map admission or portrait gate.
All positions are Fractions in memory; CLI exports aggregate checks only.
"""
from fractions import Fraction as F
import json
import sys


class Rejected(Exception):
    pass


def position(anchor, samples, minimum_slope, maximum_slope):
    """Enclose q^{-1}(anchor) for every admitted increasing inverse map q.

    samples contain (output_x, source_q_lower, source_q_upper). A separate
    admission owner must establish m <= (q(y)-q(x))/(y-x) <= M for y>x.
    Merely observing an increasing set of samples does not establish this.
    """
    if (not isinstance(anchor, tuple) or len(anchor) != 2
            or not all(isinstance(v, F) for v in anchor)
            or anchor[0] > anchor[1]
            or not isinstance(minimum_slope, F) or not isinstance(maximum_slope, F)
            or not 0 < minimum_slope <= maximum_slope
            or not isinstance(samples, (list, tuple)) or not 2 <= len(samples) <= 257
            or any(not isinstance(p, tuple) or len(p) != 3
                   or not all(isinstance(v, F) for v in p) or p[1] > p[2]
                   for p in samples)):
        raise Rejected('invalid_input')
    if any(a[0] >= b[0] for a, b in zip(samples, samples[1:])):
        raise Rejected('invalid_input')
    m, M = minimum_slope, maximum_slope

    def low_delta(delta):
        return delta * (m if delta >= 0 else M)

    def high_delta(delta):
        return delta * (M if delta >= 0 else m)

    # Necessary compatibility of all correspondence intervals with the same
    # secant bounds. No best fit, field coordinates or favorable sample drops.
    for x, lo, hi in samples:
        implied_lo = max(qlo + low_delta(x - y) for y, qlo, _ in samples)
        implied_hi = min(qhi + high_delta(x - y) for y, _, qhi in samples)
        if max(lo, implied_lo) > min(hi, implied_hi):
            raise Rejected('inconsistent_correspondence')
    if samples[0][2] > anchor[0] or samples[-1][1] < anchor[1]:
        raise Rejected('unbracketed_anchor')
    lower, upper = samples[0][0], samples[-1][0]
    for x, lo, hi in samples:
        # For negative source displacement the larger inverse distance uses
        # the lower slope. A sign-independent division would be unsound.
        delta_lo, delta_hi = anchor[0] - hi, anchor[1] - lo
        lower = max(lower, x + delta_lo / (M if delta_lo >= 0 else m))
        upper = min(upper, x + delta_hi / (m if delta_hi >= 0 else M))
    if lower > upper:
        raise Rejected('inconsistent_correspondence')
    return lower, upper


def span(left, right):
    if (any(not isinstance(p, tuple) or len(p) != 2
            or not all(isinstance(v, F) for v in p) or p[0] > p[1]
            for p in (left, right)) or left[1] >= right[0]):
        raise Rejected('unordered_structure')
    return right[0] - left[1], right[1] - left[0]


def self_test():
    checks = 0

    def require(value):
        nonlocal checks
        if not value:
            raise Rejected('self_test_failed')
        checks += 1

    # Independently construct piecewise-linear q and solve its exact forward
    # crossing by enumerating source knots, rather than using position().
    for slopes in ((F(1, 5), F(13, 5)), (F(13, 5), F(1, 5)),
                   (F(1), F(1)), (F(2, 3), F(7, 4))):
        knots = [(F(0), F(-3)), (F(10), F(-3) + 10 * slopes[0])]
        knots.append((F(20), knots[-1][1] + 10 * slopes[1]))
        for numerator in range(1, 40):
            truth_x = F(numerator, 2)
            i = 0 if truth_x <= 10 else 1
            source_anchor = knots[i][1] + slopes[i] * (truth_x - knots[i][0])
            for error in (F(0), F(1, 20)):
                samples = []
                for x in map(F, range(21)):
                    j = 0 if x <= 10 else 1
                    q = knots[j][1] + slopes[j] * (x - knots[j][0])
                    samples.append((x, q - error, q + error))
                result = position((source_anchor, source_anchor), samples, F(1, 5), F(13, 5))
                require(result[0] <= truth_x <= result[1])
    # The same source material boundaries, not arbitrary output probes.
    identity = [(F(x), F(x), F(x)) for x in range(21)]
    for shift in (-2, 0, 2):
        translated = [(x, lo - shift, hi - shift) for x, lo, hi in identity]
        left = position((F(5), F(5)), translated, F(1), F(1))
        right = position((F(15), F(15)), translated, F(1), F(1))
        require(span(left, right) == (F(10), F(10)))
    # Independent semantic-review counterexample: an increasing map compresses
    # only interior texture; the actual source boundaries 0 and10 stay fixed.
    samples = [(F(0), F(0), F(0)), (F(3), F(2), F(2)),
               (F(7), F(8), F(8)), (F(10), F(10), F(10))]
    left = position((F(0), F(0)), samples, F(2, 3), F(3, 2))
    right = position((F(10), F(10)), samples, F(2, 3), F(3, 2))
    require(span(left, right) == (F(10), F(10)))
    require((samples[1][0] - samples[1][1])
            - (samples[2][0] - samples[2][1]) == 2)
    for slope in (F(4, 5), F(1), F(5, 4)):
        samples = [(F(x), slope * x, slope * x) for x in range(21)]
        left = position((F(5), F(5)), samples, slope, slope)
        right = position((F(15), F(15)), samples, slope, slope)
        require(span(left, right) == (10 / slope, 10 / slope))
        uncertain = position((F(19, 4), F(21, 4)), samples, slope, slope)
        require(uncertain == (F(19, 4) / slope, F(21, 4) / slope))
    mutations = [
        ((F(5), F(5)), [(F(0), F(0), F(0)), (F(10), F(-1), F(-1))], F(1, 5), F(13, 5)),
        ((F(0), F(0)), [(F(0), F(-1), F(1)), (F(10), F(9), F(11))], F(1), F(1)),
        ((F(5), F(5)), identity[::-1], F(1), F(1)),
        ((F(5), F(4)), identity, F(1), F(1)),
        ((F(5), F(5)), identity, F(0), F(1)),
    ]
    for args in mutations:
        try:
            position(*args)
        except Rejected:
            checks += 1
        else:
            raise Rejected('mutation_survived')
    return {'kind': 'generated_forward_localization', 'checks': checks,
            'portrait_scoring_attempts': 0, 'acceptance_credit': False,
            'phase_complete': False}


if __name__ == '__main__':
    try:
        if sys.argv[1:] != ['--self-test']:
            raise Rejected('arguments')
        print(json.dumps(self_test(), sort_keys=True))
    except Rejected as failure:
        print(json.dumps({'status': 'rejected', 'reason': str(failure)}))
        sys.exit(2)
