# Phase 93 attempt 2 — reconstruction-safe draft

Status: ready for independent source review, **not evaluated or accepted**.
The owner requested a first-principles repair after attempt 1's safety stop.
This is one replacement candidate for the remaining attempt, not a free retry,
radius alternative, new research pass, or phase-completion record. Parent owns
recovery admission, production application, evaluation and durable GSD records.

## Scope and provenance

The complete companion provider is based on failed committed candidate
`e4e89680`, not the rolled-back live provider. Only the body of `phase93Field`
differs from that failed candidate. Radius factors stay **0.08 bridge / 0.07
root**, with the retained `[0.03, 0.20]` clamp. Root/bridge laws, exact caps,
source/cap-target/final-target disk guards, root validator and straddle checks,
six-field dispatch, sanitation, shared `makePoint` and all legacy helpers are
unchanged. No tests, thresholds, fixture, sampler, shader or public API change.

| Input/artifact | SHA-256 |
|---|---|
| Failed committed provider | `dd6da052ce300b1b18608ee57d8b067e43c9fabe20fba173d8acb8092da51fe3` |
| Replacement provider draft | `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45` |
| Rolled-back live provider at inspection | `0684e2689cd5f3b780a69f13f701339879c3f418691a586205f4dda028ea23c8` |
| Frozen `NoseRepairFieldTests.swift` | `a55f48e4c99157eb7f142a624a3030248e86712c4fa9f633cb1fc603217445e8` |
| Frozen `NoseWarpProviderTests.swift` | `69bb20ae06a2aa339c07331a21aedbbe160effc215561b9bbb1e62202b8ba837` |
| Retained `BeautyGeometryEffectPipeline.swift` | `1e66a90509b1b70d31707bb675d39b4a81145d96a9b8a58750f5b9231b78238a` |

## Why the old slack failed

The sampler uses reconstructed Float `target - source`; strength metadata does
not multiply amplitude. Shrinking a mathematical displacement by 64 Float ulps
does not bound the absolute error from adding it to a much larger source
coordinate. Same-sign endpoint errors accumulate across a dense field. The
existing failure analysis found a 16-support reconstructed budget above 0.45;
the guard abstained, violating the frozen applicable-cap nonempty predicate.
That historical finding neither proves folding nor isolates every predicate.

## Fixed arithmetic, with directed bounds

Let `d_i` be the existing finite nonzero Float cap X displacement, `r` the
final Float radius, and `u = Float(strength / cap)` exactly as before. Input
guards imply `0 < u <= 1`. Float inputs promote exactly to Double. All formulas
below refer to the values of those stored inputs, not hypothetical unrounded
landmarks. `RN64`/`RN32` mean IEEE round-to-nearest; `down(x)` is
`RN64(x).nextDown`, and `up(x)` is `RN64(x).nextUp`.

1. In retained source order compute
   `t_i = up(2 * abs(d_i) / r)` and `U_i = up(U_(i-1) + t_i)`, starting at zero.
   Multiplication by two is exact here. Each positive quotient/addition is
   bounded upward, so `U >= L = sum(2 * abs(d_i) / r)`. Nonfinite/zero U rejects.
2. Set `B = Double(0.45).nextDown`, which is below exact `9/20`. Set `s = 1`
   if `U <= B`, otherwise `s = down(B/U)`. Thus `0 < s <= 1` and `s*L <= B`.
   There is no empirical Float safety factor or cardinality-dependent tuning.
3. Per point set `a_i = down(abs(d_i)*s)` and `m_i = down(a_i*u)`.
   Positive products rounded this way cannot exceed their exact products:
   `0 < m_i <= u*s*abs(d_i)`. Reject nonpositive/nonfinite results. Therefore
   `sum(2*m_i/r) <= u*B <= B`, and individually `m_i < 0.225*r`.
4. Form `q = Float(Double(source.x) +/- m_i)` using the sign of `d_i`.
   Compare `abs(Double(q)-Double(source.x))` with `m_i`. Only if it exceeds
   `m_i`, move q **one** Float neighbor toward the source (`nextDown` for
   positive d, `nextUp` for negative d). There is no loop or alternative target.
5. Keep the original final disk, root straddle and `makePoint` identity guards.
   Compute actual Float `target-source`, require the original X sign and
   `abs(Double(actual.x)) <= m_i`, then apply the unchanged strict radius/L1
   cutoff. A failed required point returns the entire field empty, including
   both root points. Keep the original deterministic final Double accumulation
   and **`finalBudget.isFinite && finalBudget <= 0.45`** guard.

This removes the demonstrated reconstruction overspend mechanism. The final
sum guard still guards the implemented computation; universal nonempty output
is not promised. In particular, cutoff/containment abstention remains required,
and no point receives another point's quantization loss or unused allocation.

## Why one neighbor and exact subtraction suffice for every admitted point

Source disk admission gives `source.x >= r >= Float(0.03)`. Even though the
disk predicate uses Float arithmetic, a smaller nonnegative Float source
cannot make `source.x-r` round to a nonnegative value at this normal scale.
Since `m_i < 0.225*r <= 0.225*source.x`, the ideal endpoint lies between
`0.775*source.x` and `1.225*source.x`. Endpoint rounding is far smaller than
the distance to either `source.x/2` or `2*source.x`. Thus both the tentative
Float endpoint and the corrected endpoint are positive and within that wider
factor-of-two interval for every admitted input, not merely the fixed fixture.

Sterbenz's lemma consequently makes both the Double endpoint comparison and
the sampler's Float `target-source` subtraction exact. There is no hidden
subtraction-rounding overspend after the comparison.

The Double addition error is much smaller than a Float spacing throughout this
normal endpoint interval. Double-to-Float rounding can select only a bracketing
Float of the ideal endpoint, even at a double-rounding tie. If it selected the
outward bracket, one neighbor reaches the inward bracket. The exact comparison
detects that case. The source is itself representable and belongs to the closed
source-to-ideal interval, so this step cannot cross the source. The explicit
final sign and magnitude checks also fail closed if these premises are ever
violated by the implementation. The final target remains on its own intended
segment; original cap-target and root clearance checks still apply.

## Scaling and sampler implications

The scale and radius depend on cap support only. Quarter/half/cap and weakened
calls use the same cap field and retained Float ratio u; emitted strength
metadata is unchanged. Directed endpoint quantization loses less than one
local Float spacing relative to its allocated endpoint. Each of the two
directed Double products contributes less than two Double spacings, many orders
smaller than a target Float spacing. Comparing reduced and full displacements
therefore adds at most two endpoint quantization errors, the Float multiply
error in the frozen expected value, and (for caller-supplied factors) the
existing multiply/divide ratio error. With displacement below 0.225*r and
source at least r, these remain below the frozen **8 target-ulp** tolerance;
no tolerance or exact-cap/reuse assertion is changed. This is an error-bound
argument, not an executed scaling-test result.

For the retained quadratic target-centered kernel
`w(z) = max(0, 1 - distance(z,target)/r)^2`, its Lipschitz constant is at most
`2/r`. Since actual reconstructed X displacement is bounded by m_i, the
real-arithmetic inverse map has horizontal increase at least `0.55*dx` for one
repaired field and `0.10*dx` for isolated bridge+root. Disk centers and edges
need not be differentiable for this Lipschitz argument. It does **not** prove
arbitrary Float sampling, clamped-raster, GPU or mixed-legacy injectivity.

## Full failed safety-conjunction inspection

| Frozen subpredicate | Source-review finding / remaining evidence |
|---|---|
| Per-field 0.45 and isolated 0.90 budgets | Continuous bound and exact reconstructed displacement proved above; final stored-sum guard retained. Native independent `hypot` accumulation remains to be checked. |
| Finite unit/face source and target disks | Original bounds, source/cap-target/target checks retained; no invalid-source clamping into eligibility. Existing checks express Float containment, not exact-real geometric clearance at every rounding boundary. |
| 129x129 dense maps, disk neighbors, midline | Real-map argument covers the repaired fields; finite-precision strict comparisons in the frozen sampler remain unexecuted. |
| Nonempty cap fields for 2/4/16/64 supports | Reconstruction can no longer expand any allocation. The frozen applicable-cap denominators still require evaluation; the empty-field guard is not treated as success. |
| 64-support quarter/half abstention and strict cutoff | No cutoff compensation, rounding-up or point removal. Whole-field rejection remains mandatory when any allocated point cannot clear the strict cutoff. |
| Bridge/root plus each of five signed legacy sibling cases | All sibling helper bytes and dispatch are preserved. Their displacements are outside the 0.90 theorem; fixed mixed-field dense sampling remains a required independent runtime regression. |
| Final unexecuted cutoff/reuse/sibling methods | All assertions and digest literals retained; no pass inferred from source identity alone. |

No second concrete failing subpredicate was established by source inspection.
In particular, a sum of individual legacy bounds exceeding one would only
make that sufficient proof inconclusive, not prove a folded mixed field.
The known Float-boundary and mixed-field proof limitations above are retained,
not silently promoted into stronger guarantees or broadened into this repair.

## Review/evaluation boundary

Performed: local source/contract inspection; byte comparison proving that only
`phase93Field` differs from `e4e89680`; SHA-256 and whitespace/static artifact
checks. No numerical sweep, candidate arithmetic emulator, Swift build/test,
render, network, gate/ledger invocation or live source/test/owner edit occurred.
Read-only GSD context queries loaded existing phase/state; no plan advancement,
commit or completion claim was made. Serena tools were unavailable.

Independent review must precede parent-owned recovery admission/application
and the complete frozen provider, registration, metrics, pixels, lifecycle,
authority and sibling conjunction. Earlier original-provider pixel passes do
not validate this draft. Failure remains failure within the two-attempt ceiling.
Only the two requested `/tmp` artifacts were authored; evidence contains no raw
geometry, pixels, masks, private fixture locators or child transcripts.
