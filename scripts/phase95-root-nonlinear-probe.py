#!/usr/bin/env python3
"""Generated-only arbitrary horizontal displacement plus shared photometry.

Each sample has its own displacement; no affine/constant motion assumption.
All source interpolation cells and feasible photometric components are retained.
Not a portrait metric, anatomical registrar, or production acceptance route.
"""
from fractions import Fraction as F
from pathlib import Path
import hashlib
import importlib.util
import json
import sys
import time

DEPENDENCY_SHA = '0d99954325288c2b7da43cb4dcb90412decb7aeb441fcc82ae605d4edfe8f06c'


class Rejected(Exception):
    pass


def dependency():
    path = Path(__file__).with_name('phase95-root-affine-motion-probe.py')
    data = path.read_bytes()
    if hashlib.sha256(data).hexdigest() != DEPENDENCY_SHA:
        raise Rejected('dependency_changed')
    spec = importlib.util.spec_from_file_location('reviewed_affine', path)
    module = importlib.util.module_from_spec(spec)
    exec(compile(data, str(path), 'exec'), module.__dict__)
    return module


def hull(points):
    points = sorted(set(points))
    if len(points) <= 2:
        return tuple(points)
    def cross(a, b, c):
        return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
    halves = []
    for sequence in (points, list(reversed(points))):
        half = []
        for p in sequence:
            while len(half) >= 2 and cross(half[-2], half[-1], p) <= 0:
                half.pop()
            half.append(p)
        halves.append(half[:-1])
    return tuple(halves[0] + halves[1])


def clip2(poly, a, b, rhs):
    if not poly:
        return ()
    result = []
    for p, q in zip(poly, poly[1:] + poly[:1]):
        dp, dq = a * p[0] + b * p[1] - rhs, a * q[0] + b * q[1] - rhs
        if dp <= 0:
            result.append(p)
        if (dp < 0 < dq) or (dq < 0 < dp):
            t = dp / (dp - dq)
            result.append(tuple(x + t * (y - x) for x, y in zip(p, q)))
    return hull(result)


def cell_constraints(source, observed, j, error):
    # Variables(t,alpha,beta), q=j+t, t in[0,1].
    result = [(F(-1), F(0), F(0), F(0)), (F(1), F(0), F(0), F(1))]
    for c in range(3):
        base, gradient = F(source[j][c]), F(source[j + 1][c] - source[j][c])
        result.extend([(gradient, -F(observed[c]) - error, F(-1), -base),
                       (-gradient, F(observed[c]) - error, F(1), base)])
    return result


def project_t(constraints):
    """Exact Fourier-Motzkin elimination of bounded interpolation fraction."""
    positive = [v for v in constraints if v[0] > 0]
    negative = [v for v in constraints if v[0] < 0]
    result = [v[1:] for v in constraints if v[0] == 0]
    for p in positive:
        for n in negative:
            result.append(tuple(-n[0] * p[i] + p[0] * n[i] for i in range(1, 4)))
    return tuple(result)


def polygon_constraints(poly):
    # Degenerate photometric sets require equality constraints as well.
    if len(poly) == 1:
        a, b = poly[0]
        return [(1, 0, a), (-1, 0, -a), (0, 1, b), (0, -1, -b)]
    if len(poly) == 2:
        p, q = poly
        dx, dy = q[0] - p[0], q[1] - p[1]
        line = dy * p[0] - dx * p[1]
        lo, hi = sorted((dx * p[0] + dy * p[1], dx * q[0] + dy * q[1]))
        return [(dy, -dx, line), (-dy, dx, -line), (dx, dy, hi), (-dx, -dy, -lo)]
    result = []
    for p, q in zip(poly, poly[1:] + poly[:1]):
        dx, dy = q[0] - p[0], q[1] - p[1]
        result.append((dy, -dx, dy * p[0] - dx * p[1]))
    return result


def area(poly):
    return abs(sum((p[0] * q[1] - p[1] * q[0]
                    for p, q in zip(poly, poly[1:] + poly[:1])), F(0))) / 2


def exact_union_insert(states, poly, deadline):
    """Merge only when the convex hull equals the union, never bridge a gap."""
    index = 0
    while index < len(states):
        if time.monotonic() > deadline:
            raise Rejected('work_limit')
        other = states[index]
        intersection = poly
        for a, b, rhs in polygon_constraints(other):
            intersection = clip2(intersection, a, b, rhs)
            if not intersection:
                break
        if intersection:
            combined = hull(poly + other)
            if area(combined) == area(poly) + area(other) - area(intersection):
                poly = combined
                states.pop(index)
                index = 0
                continue
        index += 1
    states.append(poly)


def interval(source, output, center, search=16, error=F(1), state_limit=512):
    deadline = time.monotonic() + 90
    if (type(center) is not int or type(search) is not int or not 1 <= search <= 64
            or type(state_limit) is not int or not 1 <= state_limit <= 512
            or not isinstance(error, F) or not 0 <= error <= 2
            or not 2 <= len(output) <= 7 or len(output) % 2 != 1
            or not 32 <= len(source) <= 4096
            or any(len(p) != 3 or any(type(v) is not int or not 0 <= v <= 255 for v in p)
                   for p in (*source, *output))):
        raise Rejected('invalid_input')
    radius = len(output) // 2
    if center - radius - search < 0 or center + radius + search >= len(source):
        raise Rejected('unsafe_window')
    model = dependency()
    # CCW polygon: inverse gain[.5,2], |offset|<=32 -> |beta|<=32*alpha.
    states = [((F(1, 2), F(-16)), (F(2), F(-64)), (F(2), F(64)), (F(1, 2), F(16)))]
    operations = 0
    for index, observed in enumerate(output):
        if index == radius:
            continue
        x = center - radius + index
        next_states = []
        for j in range(x - search, x + search):
            constraints = project_t(cell_constraints(source, observed, j, error))
            for state in states:
                operations += 1
                if operations > 100000 or time.monotonic() > deadline:
                    raise Rejected('work_limit')
                poly = state
                for a, b, rhs in constraints:
                    poly = clip2(poly, a, b, rhs)
                    if not poly:
                        break
                if poly:
                    exact_union_insert(next_states, poly, deadline)
                    if len(next_states) > state_limit:
                        raise Rejected('state_limit')
        states = next_states
        if not states:
            raise Rejected('no_feasible_motion')
    bounds = []
    for state in states:
        for j in range(center - search, center + search):
            operations += 1
            if operations > 100000 or time.monotonic() > deadline:
                raise Rejected('work_limit')
            constraints, vertices = model.box()
            extra = [((0, 0, a, b), rhs) for a, b, rhs in polygon_constraints(state)]
            extra += [((a, 0, b, c), rhs)
                      for a, b, c, rhs in cell_constraints(source, output[radius], j, error)]
            for normal, rhs in extra:
                vertices = model.clip(constraints, vertices, normal, rhs)
                if not vertices:
                    break
            if vertices:
                bounds.append((F(center - j) - max(p[0] for p in vertices),
                               F(center - j) - min(p[0] for p in vertices)))
    if not bounds:
        raise Rejected('no_feasible_motion')
    return min(v[0] for v in bounds), max(v[1] for v in bounds)


def render(source, center, motion, gain=F(1), offset=F(0)):
    output = []
    radius = len(motion) // 2
    for index, d in enumerate(motion):
        q = F(center - radius + index) - d
        j = q.numerator // q.denominator
        t = q - j
        pixel = []
        for c in range(3):
            value = gain * ((1 - t) * source[j][c] + t * source[j + 1][c]) + offset
            if not 0 <= value <= 255:
                raise Rejected('fixture_clipping')
            pixel.append(int(value + F(1, 2)))
        output.append(tuple(pixel))
    return output


def self_test():
    model = dependency()
    source = model.texture(256, 5)
    profiles = [(F(3), F(2), F(4), F(1), F(2)),
                (F(-3), F(1), F(-4), F(2), F(-2)),
                (F(0),) * 5]
    contained = 0
    for motion in profiles:
        for gain, offset in ((F(1), F(0)), (F(5, 4), F(-7))):
            result = interval(source, render(source, 128, motion, gain, offset), 128)
            if not result[0] <= motion[2] <= result[1]:
                raise Rejected('truth_excluded')
            contained += 1
    power = {}
    source = model.texture(1024, 17)
    centers = (480, 544)
    neutral = model.contraction(*(interval(source, render(source, c, (F(0),) * 5), c)
                                  for c in centers), 1024)
    for amount in (-32, 0, 15, 16, 17, 20, 32, 1024):
        passed = 0
        for gain, offset in ((F(1), F(0)), (F(5, 4), F(-7))):
            measured = []
            for center, sign in zip(centers, (1, -1)):
                d = F(amount, 128) * sign
                motion = (tuple(d + F(v, 4) for v in (2, -1, 0, 1, -2))
                          if amount else (F(0),) * 5)
                bounds = interval(source, render(source, center, motion, gain, offset), center)
                if not bounds[0] <= d <= bounds[1]:
                    raise Rejected('power_truth_excluded')
                contained += 1
                measured.append(bounds)
            change = model.contraction(*measured, 1024)
            accepts = model.margin(change, neutral) >= 16
            if amount <= 16 and accepts:
                raise Rejected('false_promotion')
            if amount in (32, 1024) and not accepts:
                raise Rejected('power_failed')
            passed += int(accepts)
        power[str(amount)] = passed
    flat = interval([(120, 120, 120)] * 64, [(130, 130, 130)] * 5, 32, search=8)
    if flat != (F(-8), F(8)):
        raise Rejected('flat_ambiguity_lost')
    ramp = [(40 + x, 50 + x, 60 + x) for x in range(64)]
    ambiguous = interval(ramp, render(ramp, 32, (F(0),) * 5, offset=F(1)), 32, search=8)
    if not ambiguous[0] <= -1 <= 0 <= ambiguous[1]:
        raise Rejected('brightness_equivalence_lost')
    return dict(kind='generated_nonlinear_motion_probe', true_motion_containments=contained,
                search_pixels=16, error_bytes=1, portrait_scoring_attempts=0,
                power=power, pairs_per_amount=2, ambiguity_controls=2,
                acceptance_credit=False, phase_complete=False)


if __name__ == '__main__':
    if sys.argv[1:] != ['--self-test']:
        raise SystemExit('usage: phase95-root-nonlinear-probe.py --self-test')
    try:
        print(json.dumps(self_test(), sort_keys=True))
    except Rejected as error:
        print(json.dumps(dict(kind='nonlinear_probe_failed', reason=str(error))))
        raise SystemExit(2)
