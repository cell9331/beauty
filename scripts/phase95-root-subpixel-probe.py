#!/usr/bin/env python3
"""Generated-only exact interval correspondence experiment; no portrait CLI.

The model is a locally constant horizontal translation of an RGB patch, with
piecewise-linear source interpolation and a fixed byte-error bound. It is NOT
the spatially varying root field, an anatomical registration, or a production
acceptance metric. All feasible shifts are retained, not an optimum score.
"""
from fractions import Fraction as F
import hashlib
import json
from pathlib import Path
import subprocess
import sys

SAMPLER_SHA = "bbffaffbeecb6432ee1c917e9b7d2143fae8ca46028aedeecb01f5f690b0981a"
ERROR = F(1, 2) + F(1, 512)
SEARCH = 4
RADIUS = 8


class Rejected(Exception):
    pass


def texture(width, seed):
    return [tuple(40 + (((x + 17 * c + seed) * 1103515245 + 12345)
                       ^ ((x * x + seed * 7919 + c * 107) * 2654435761)) % 176
                  for c in range(3)) for x in range(width)]


def translate(source, center, shift):
    """Independent exact-rational fixture rasterizer, positive shift moves right."""
    result = []
    for x in range(center - RADIUS, center + RADIUS + 1):
        q = F(x) - shift
        i = q.numerator // q.denominator
        f = q - i
        pixel = []
        for c in range(3):
            v = source[i][c] * (1 - f) + source[i + 1][c] * f
            pixel.append((v + F(1, 2)).numerator // (v + F(1, 2)).denominator)
        result.append(tuple(pixel))
    return result


def intervals(source, output, center, error=ERROR):
    """Solve each integer shift cell exactly; no grid approximation or fit winner."""
    if not (isinstance(error, F) and 0 <= error <= 2
            and 32 <= len(source) <= 8192 and type(center) is int
            and center - RADIUS - SEARCH >= 0
            and center + RADIUS + SEARCH + 1 < len(source)
            and len(output) == 2 * RADIUS + 1):
        raise Rejected("invalid_input")
    for row in (source, output):
        if any(len(p) != 3 or any(type(v) is not int or not 0 <= v <= 255 for v in p) for p in row):
            raise Rejected("invalid_input")
    accepted = []
    # On d in [j,j+1], x-d is in [x-j-1,x-j]. P(x-d) is affine in d.
    for j in range(-SEARCH, SEARCH):
        low, high = F(j), F(j + 1)
        for index, observed in enumerate(output):
            x = center - RADIUS + index
            for c in range(3):
                a, b = source[x - j - 1][c], source[x - j][c]
                slope = a - b
                intercept = b - slope * j
                if slope == 0:
                    if abs(F(observed[c]) - intercept) > error:
                        low, high = F(1), F(0)
                        break
                else:
                    q1 = (F(observed[c]) - error - intercept) / slope
                    q2 = (F(observed[c]) + error - intercept) / slope
                    low, high = max(low, min(q1, q2)), min(high, max(q1, q2))
                if low > high:
                    break
            if low > high:
                break
        if low <= high:
            if accepted and low <= accepted[-1][1]:
                accepted[-1] = (accepted[-1][0], max(high, accepted[-1][1]))
            else:
                accepted.append((low, high))
    if len(accepted) != 1:
        raise Rejected("unavailable_or_disconnected")
    lo, hi = accepted[0]
    if lo <= -SEARCH or hi >= SEARCH:
        raise Rejected("search_boundary")
    return lo, hi


def contraction(left, right, width):
    return ((left[0] - right[1]) * F(65536, width),
            (left[1] - right[0]) * F(65536, width))


def margin(candidate, neutral):
    # Source has zero change. Neutral's upper bound must also be subtracted.
    return min(candidate[0], candidate[0] - neutral[1])


def swift_outputs(cases):
    path = Path(__file__).resolve().parent.parent / "BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift"
    original = path.read_bytes()
    if hashlib.sha256(original).hexdigest() != SAMPLER_SHA:
        raise Rejected("sampler_identity")
    text = original.decode()
    start = "    private static func writeInterpolatedPixel("
    end = "    private static func falloffWeight("
    if text.count(start) != 1 or text.count(end) != 1:
        raise Rejected("sampler_entry")
    # Unmodified private sampler body; wrapper provides the same clamp helper.
    sampler = text[text.index(start):text.index(end)]
    swift = 'import Foundation\nenum ProbeSampler {\n' + sampler + r'''
    private static func clampedByte(_ value: Int) -> UInt8 { UInt8(min(max(value, 0), 255)) }
    static func run(_ width: Int, _ seed: Int, _ shift: Float) -> [[Int]] {
        let center = width / 2
        var source: [UInt8] = []
        for _ in 0..<2 { for x in 0..<width {
            for c in 0..<3 {
                let a = (x + 17 * c + seed) * 1103515245 + 12345
                let b = (x * x + seed * 7919 + c * 107) * 2654435761
                source.append(UInt8(40 + (a ^ b) % 176))
            }
            source.append(255)
        } }
        var output = source
        for x in (center - 8)...(center + 8) {
            writeInterpolatedPixel(source: source, output: &output, width: width, height: 2,
                column: x, row: 0, sampleX: Float(x) - shift, sampleY: 0)
        }
        return ((center - 8)...(center + 8)).map { x in (0..<3).map { Int(output[x * 4 + $0]) } }
    }
}
var output: [[[Int]]] = []
'''
    for width, seed, shift in cases:
        swift += f'output.append(ProbeSampler.run({width}, {seed}, Float({float(shift)!r})))\n'
    swift += 'print(String(data: try JSONSerialization.data(withJSONObject: output), encoding: .utf8)!)\n'
    run = subprocess.run(["swift", "-"], input=swift, text=True, capture_output=True, timeout=180)
    if run.returncode != 0:
        raise Rejected("sampler_execution")
    if path.read_bytes() != original:
        raise Rejected("sampler_changed")
    return json.loads(run.stdout)


def self_test():
    # Predeclared generated grid; no portrait or output-based anchor selection.
    widths, seeds, amounts = (512, 1024, 2304), (1, 7, 23), (-32, 0, 15, 16, 17, 20, 32)
    cases = [(w, s, sign * F(a * w, 2 * 65536))
             for w in widths for s in seeds for a in amounts for sign in (1, -1)]
    actual = swift_outputs(cases)
    if len(actual) != len(cases):
        raise Rejected("sampler_count")
    checked, containments, max_error = 0, 0, F(0)
    by_case, wider_by_case = {}, {}
    for (w, seed, shift), output in zip(cases, actual):
        source, center = texture(w, seed), w // 2
        # Compare actual unmodified sampler bytes to exact independently rasterized bytes.
        reference = translate(source, center, shift)
        if [list(p) for p in reference] != output:
            raise Rejected("sampler_reference_mismatch")
        for index, pixel in enumerate(output):
            q = F(center - RADIUS + index) - shift
            i = q.numerator // q.denominator
            for c, value in enumerate(pixel):
                exact = source[i][c] * (1 - (q - i)) + source[i + 1][c] * (q - i)
                max_error = max(max_error, abs(value - exact))
        interval = intervals(source, output, center)
        if not interval[0] <= shift <= interval[1]:
            raise Rejected("truth_excluded")
        containments += 1
        by_case[(w, seed, shift)] = interval
        wider_by_case[(w, seed, shift)] = intervals(source, output, center, error=F(1))
        wider = wider_by_case[(w, seed, shift)]
        if not wider[0] <= interval[0] <= interval[1] <= wider[1]:
            raise Rejected("uncertainty_not_monotone")
        checked += 1
    power = {str(a): {"passed": 0, "total": 0} for a in amounts}
    for w in widths:
        for seed in seeds:
            neutral = contraction(by_case[(w, seed, F(0))], by_case[(w, seed, F(0))], w)
            for a in amounts:
                shift = F(a * w, 2 * 65536)
                change = contraction(by_case[(w, seed, shift)], by_case[(w, seed, -shift)], w)
                if not change[0] <= a <= change[1]:
                    raise Rejected("contraction_truth_excluded")
                passes = margin(change, neutral) >= 16
                if a < 16 and passes:
                    raise Rejected("false_promotion")
                if a == 32 and not passes:
                    raise Rejected("declared_power_failed")
                power[str(a)]["passed"] += int(passes)
                power[str(a)]["total"] += 1
    wider_power = {str(a): {"passed": 0, "total": 0} for a in amounts}
    for w in widths:
        for seed in seeds:
            neutral = contraction(wider_by_case[(w, seed, F(0))], wider_by_case[(w, seed, F(0))], w)
            for a in amounts:
                shift = F(a * w, 2 * 65536)
                change = contraction(wider_by_case[(w, seed, shift)], wider_by_case[(w, seed, -shift)], w)
                passes = margin(change, neutral) >= 16
                if a < 16 and passes or a == 32 and not passes:
                    raise Rejected("wider_budget_power_or_soundness")
                wider_power[str(a)]["passed"] += int(passes)
                wider_power[str(a)]["total"] += 1
    negatives = 0
    def must_reject(source, output, center):
        nonlocal negatives
        try:
            intervals(source, output, center)
        except Rejected:
            negatives += 1
            return
        raise Rejected("negative_accepted")
    source, center = texture(512, 1), 256
    for source2 in [[(120, 120, 120)] * 512,
                    [(40, 80, 120) if x % 2 else (200, 160, 180) for x in range(512)]]:
        must_reject(source2, translate(source2, center, F(0)), center)
    neutral_pixels = translate(source, center, F(0))
    must_reject(source, [tuple(v + 12 for v in p) for p in neutral_pixels], center)
    must_reject(source, [tuple(round(v * 0.8) for v in p) for p in neutral_pixels], center)
    # Nonzero blur is not silently credited as displacement; tested kernels only.
    for kernel in [(F(1, 4), F(1, 2), F(1, 4)), (F(1, 4), F(3, 4), F(0))]:
        blurred = []
        for x in range(center - RADIUS, center + RADIUS + 1):
            blurred.append(tuple(round(sum(kernel[k] * source[x + k - 1][c] for k in range(3))) for c in range(3)))
        # An asymmetric two-tap kernel is exactly fractional translation and
        # CANNOT generally be rejected from pixels alone. Preserve that limit.
        if kernel[2] == 0:
            feasible = intervals(source, blurred, center)
            if not feasible[0] <= F(1, 4) <= feasible[1]:
                raise Rejected("shift_blur_equivalence_lost")
        else:
            must_reject(source, blurred, center)
    must_reject(source, neutral_pixels[:-1], center)
    must_reject(source, neutral_pixels, -1)
    return {"kind": "generated_subpixel_translation_probe", "sampler_sha256": SAMPLER_SHA,
            "sampler_cases": checked, "truth_containments": containments,
            "maximum_byte_error": float(max_error), "declared_byte_bound": float(ERROR),
            "threshold_q16": 16, "power": power, "one_byte_budget_power": wider_power,
            "negative_rejections": negatives,
            "asymmetric_blur_equivalence_retained": True,
            "portrait_scoring_attempts": 0, "acceptance_credit": False, "phase_complete": False}


if __name__ == "__main__":
    if sys.argv[1:] != ["--self-test"]:
        raise SystemExit("usage: phase95-root-subpixel-probe.py --self-test")
    try:
        print(json.dumps(self_test(), sort_keys=True))
    except (Rejected, subprocess.TimeoutExpired) as error:
        print(json.dumps({"kind": "subpixel_probe_failed", "reason": str(error) if isinstance(error, Rejected) else "timeout"}))
        raise SystemExit(2)
