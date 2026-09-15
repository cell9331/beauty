#!/usr/bin/env python3
"""Generated-only signed affine motion/photometry experiment, NOT a metric.

Exact bounded polytopes retain all feasible displacements, slopes, gains and
offsets. No private input, production field, source registration or scoring API.
"""
from fractions import Fraction as F
from itertools import combinations, product
import json
import sys

ERROR = F(1, 2) + F(1, 512)
RADIUS = 2


class Rejected(Exception):
    pass


def dot(a, b):
    return sum(x * y for x, y in zip(a, b))


def solve4(matrix, vector):
    rows = [[F(v) for v in row] + [F(value)] for row, value in zip(matrix, vector)]
    for col in range(4):
        pivot = next((r for r in range(col, 4) if rows[r][col]), None)
        if pivot is None:
            return None
        rows[col], rows[pivot] = rows[pivot], rows[col]
        scale = rows[col][col]
        rows[col] = [v / scale for v in rows[col]]
        for r in range(4):
            if r != col and rows[r][col]:
                scale = rows[r][col]
                rows[r] = [v - scale * p for v, p in zip(rows[r], rows[col])]
    return tuple(row[4] for row in rows)


def box():
    # displacement[-1,1], slope[-.5,.5], inverse gain[.5,2], beta[-64,64].
    bounds = ((F(-1), F(1)), (F(-1, 2), F(1, 2)), (F(1, 2), F(2)), (F(-64), F(64)))
    constraints = []
    for i, (lo, hi) in enumerate(bounds):
        for sign, rhs in ((-1, -lo), (1, hi)):
            constraints.append((tuple(F(sign if j == i else 0) for j in range(4)), rhs))
    vertices = {}
    for choices in product((0, 1), repeat=4):
        point = tuple(bounds[i][choice] for i, choice in enumerate(choices))
        vertices[point] = frozenset(2 * i + choice for i, choice in enumerate(choices))
    return constraints, vertices


def clip(constraints, vertices, normal, rhs):
    """Exact vertex clipping, including lower-dimensional intersections.

An edge has three independent common active normals. A crossing cut provides
the fourth plane. Extra dependent active planes are tried without tolerances.
    """
    normal, rhs = tuple(map(F, normal)), F(rhs)
    index = len(constraints)
    distances = {p: dot(normal, p) - rhs for p in vertices}
    inside = [p for p, d in distances.items() if d < 0]
    outside = [p for p, d in distances.items() if d > 0]
    retained = {p: active | ({index} if distances[p] == 0 else set())
                for p, active in vertices.items() if distances[p] <= 0}
    for a in inside:
        for b in outside:
            common = vertices[a] & vertices[b]
            for basis in combinations(sorted(common), 3):
                planes = [constraints[i] for i in basis] + [(normal, rhs)]
                point = solve4([v[0] for v in planes], [v[1] for v in planes])
                if point is not None:
                    fraction = distances[a] / (distances[a] - distances[b])
                    expected = tuple(x + fraction * (y - x) for x, y in zip(a, b))
                    if point != expected:
                        raise Rejected('clipping_edge_invariant')
                    retained[point] = frozenset(common | {index})
                    break
    constraints.append((normal, rhs))
    return retained


def patterns(count):
    # An affine displacement changes sign at most once along a row.
    result = {(1,) * count, (-1,) * count}
    for k in range(1, count):
        result.add((1,) * k + (-1,) * (count - k))
        result.add((-1,) * k + (1,) * (count - k))
    return sorted(result)


def constraints_for(source, output, center, signs, error):
    # (C-E)*alpha+beta <= P <= (C+E)*alpha+beta; alpha=1/g, beta=-offset/g.
    # |offset|<=32; box supplies gain bounds. Both motion directions are searched.
    result = [((0, 0, -32, 1), 0), ((0, 0, -32, -1), 0)]
    for index, (pixel, sign) in enumerate(zip(output, signs)):
        x = center - RADIUS + index
        t = F(index - RADIUS, RADIUS)
        result.extend([((-sign, -sign * t, 0, 0), 0),
                       ((sign, sign * t, 0, 0), 1)])
        for channel, observed in enumerate(pixel):
            base = source[x][channel]
            gradient = (source[x - 1][channel] - base if sign == 1
                        else base - source[x + 1][channel])
            result.extend([
                ((-gradient, -gradient * t, observed - error, 1), base),
                ((gradient, gradient * t, -(observed + error), -1), -base)])
    return result


def interval(source, output, center, error=ERROR):
    if (type(center) is not int or not RADIUS + 1 <= center < len(source) - RADIUS - 1
            or not 16 <= len(source) <= 4096 or len(output) != 2 * RADIUS + 1
            or not isinstance(error, F) or not 0 <= error <= 2
            or any(len(p) != 3 or any(type(v) is not int or not 0 <= v <= 255 for v in p)
                   for p in (*source, *output))):
        raise Rejected('invalid_input')
    pieces = []
    for signs in patterns(len(output)):
        constraints, vertices = box()
        for normal, rhs in constraints_for(source, output, center, signs, error):
            vertices = clip(constraints, vertices, normal, rhs)
            if not vertices:
                break
        if vertices:
            pieces.append((min(p[0] for p in vertices), max(p[0] for p in vertices)))
    if not pieces:
        raise Rejected('no_feasible_motion')
    # Hull, not best component: ambiguity widens the result, never grants credit.
    return min(p[0] for p in pieces), max(p[1] for p in pieces)


def texture(width, seed):
    return [tuple(48 + (((x + 19 * c + seed) * 1103515245 + 12345)
                       ^ ((x * x + seed * 6151 + c * 251) * 2654435761)) % 150
                  for c in range(3)) for x in range(width)]


def render(source, center, displacement, slope, gain=F(1), offset=F(0)):
    """Known analytic fixture truth, not an independent production-pixel oracle."""
    output = []
    for x in range(center - RADIUS, center + RADIUS + 1):
        q = F(x) - displacement - slope * F(x - center, RADIUS)
        i = q.numerator // q.denominator
        fraction = q - i
        pixel = []
        for channel in range(3):
            value = gain * (source[i][channel] * (1 - fraction)
                            + source[i + 1][channel] * fraction) + offset
            if not 0 <= value <= 255:
                raise Rejected('fixture_clipping')
            pixel.append(int(value + F(1, 2)))
        output.append(tuple(pixel))
    return output


def contraction(left, right, width):
    return (left[0] - right[1]) * F(65536, width), (left[1] - right[0]) * F(65536, width)


def margin(candidate, neutral):
    return min(candidate[0], candidate[0] - neutral[1])


def self_test():
    power = {str(v): 0 for v in (-32, 0, 15, 16, 17, 20, 32)}
    cases = 0
    for width, seed in ((512, 5), (1024, 17)):
        source = texture(width, seed)
        centers = (width // 2 - 12, width // 2 + 12)
        neutral = contraction(*(interval(source, render(source, c, F(0), F(0)), c)
                                for c in centers), width)
        for amount in map(int, power):
            d = F(amount * width, 2 * 65536)
            for gain, offset in ((F(1), F(0)), (F(5, 4), F(-7)), (F(3, 5), F(18))):
                measured = []
                for c, sign in zip(centers, (1, -1)):
                    truth = d * sign
                    bounds = interval(source, render(source, c, truth, truth / 4, gain, offset), c)
                    if not bounds[0] <= truth <= bounds[1]:
                        raise Rejected('true_motion_excluded')
                    measured.append(bounds)
                change = contraction(*measured, width)
                if not change[0] <= amount <= change[1]:
                    raise Rejected('true_contraction_excluded')
                passed = margin(change, neutral) >= 16
                if amount <= 16 and passed:
                    raise Rejected('false_promotion')
                if amount == 32 and not passed:
                    raise Rejected('power_failed')
                power[str(amount)] += int(passed)
                cases += 1
    # Ambiguity is preserved without a tuned quarter-pixel cutoff.
    flat = interval([(120, 120, 120)] * 64, [(130, 130, 130)] * 5, 32)
    if flat != (F(-1), F(1)):
        raise Rejected('flat_ambiguity_lost')
    ramp = [(40 + x, 50 + x, 60 + x) for x in range(64)]
    bounds = interval(ramp, render(ramp, 32, F(0), F(0), offset=F(1)), 32)
    if not bounds[0] <= -1 <= 0 <= bounds[1]:
        raise Rejected('brightness_equivalence_lost')
    source = texture(64, 7)
    crossing = interval(source, render(source, 32, F(0), F(1, 4)), 32)
    if not crossing[0] <= 0 <= crossing[1]:
        raise Rejected('crossing_motion_excluded')
    pixels = render(source, 32, F(-1, 4), F(1, 8))
    tight = interval(source, pixels, 32)
    wide = interval(source, pixels, 32, F(1))
    if not wide[0] <= tight[0] <= tight[1] <= wide[1]:
        raise Rejected('error_budget_not_monotone')
    invalid = 0
    for pixels, center in ((pixels[:-1], 32), (pixels, 0), ([(256, 0, 0)] * 5, 32)):
        try:
            interval(source, pixels, center)
        except Rejected:
            invalid += 1
        else:
            raise Rejected('invalid_input_accepted')
    return dict(kind='generated_signed_affine_motion_probe', generated_cases=cases,
                true_motion_containments=2 * cases, power=power, pairs_per_amount=6,
                ambiguity_controls=2, crossing_control=1, threshold_q16=16,
                error_budget_monotonicity=1, invalid_inputs_rejected=invalid,
                truth='known_analytic_fixture_parameters', portrait_scoring_attempts=0,
                acceptance_credit=False, phase_complete=False)


if __name__ == '__main__':
    if sys.argv[1:] != ['--self-test']:
        raise SystemExit('usage: phase95-root-affine-motion-probe.py --self-test')
    try:
        print(json.dumps(self_test(), sort_keys=True))
    except Rejected as error:
        print(json.dumps(dict(kind='affine_motion_probe_failed', reason=str(error))))
        raise SystemExit(2)
