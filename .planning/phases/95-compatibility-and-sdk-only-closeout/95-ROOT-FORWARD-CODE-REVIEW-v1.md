---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T05:48:47Z
depth: standard
files_reviewed: 1
files_reviewed_list:
  - scripts/phase95-root-forward-span.py
git_head: a097f4b0d73ad243a626ef1fa37a9310129684b9
source_sha256: 0cfac9277c2efdbc47ec65f120c2a43f659d0a8d279e716940ed17051660fa2d
model_sha256: 7a3fa76a0c57b9c0c535b29f2b8a5077b3263c8ac7a18f8f59c88f750dd516a4
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
---

# Phase 95: Forward Localization Code Review

## Narrative Findings (AI reviewer)

No actionable BLOCKER or WARNING found in the scoped helper. This is a standard-depth review of all 148 lines, its internal call paths, mathematical preconditions and generated CLI behavior. No structural pre-pass was supplied. The source was untracked at the recorded HEAD; the SHA-256 above identifies the actual reviewed bytes, and remained unchanged through verification.

### Mathematical analysis

All line references below refer to `/Users/yakangwang/codes/beauty/scripts/phase95-root-forward-span.py`.

- **Sign-dependent inversion, lines 52–57:** Write `t = q^-1(s) - x` and `d = s - q(x)`. For `d >= 0`, the secant assumption yields `d/M <= t <= d/m`; for `d < 0`, it yields `d/m <= t <= d/M`. Both piecewise endpoint functions are increasing and agree at zero. Thus evaluating the lower function at `sLo-qHi` and the upper function at `sHi-qLo` encloses every allowed source anchor and sample value, including intervals crossing zero. Intersecting these necessary bounds cannot exclude an admitted map's true crossing.
- **Uncertain observations and compatibility, lines 36–47:** Each sample propagates a lower and upper source-value constraint to every other sample using the correct sign of the output-coordinate difference. An empty intersection proves inconsistency, so rejection is sound. All samples participate, including nonadjacent constraints hidden by a broad intervening interval. The documented promise is a necessary compatibility check; it is not a certificate that a production field satisfies the secant assumptions.
- **Bracketing, lines 48–50:** `first.qHi <= sLo` and `last.qLo >= sHi` ensure the entire anchor interval is inside every admitted map's endpoint source range. Positive bounded secants imply continuity and strict increase on the sampled domain, giving a unique crossing for each anchor. Equality at an endpoint is valid. Rejecting a merely possible bracket is deliberate conservative behavior under the stated contract.
- **Span and ordering, lines 63–69:** Strict `left.hi < right.lo` ensures positive, unambiguous ordering. The interval `[right.lo-left.hi, right.hi-left.lo]` contains every width from the two supplied position intervals. Touching, overlapping and reversed intervals reject. The result need not be the tight joint width hull because shared-map correlations are not retained; the contract promises an enclosure.
- **Execution and input handling, lines 22–33 and 72–148:** Input shapes, rational values, slope order and sample-count bounds are checked before arithmetic. The CLI permits only the generated self-test and emits aggregate JSON. Test gates use explicit exceptions and remain active under optimization. No image input, private-path input, dynamic evaluation, network access or subprocess execution exists in the reviewed helper.

### Reviewer-executed verification

These results were executed independently in this review. The main agent's previously reported results were not counted as reviewer execution. All tests used Python's standard library, generated in-memory rationals and explicit exceptions rather than removable assertions. No test scripts or generated data were written to disk; `-B` disabled bytecode persistence.

| Check | Actual result |
| --- | --- |
| `python3 -B scripts/phase95-root-forward-span.py --self-test` | Exit 0; 328 checks |
| `python3 -B -O scripts/phase95-root-forward-span.py --self-test` | Exit 0; 328 checks |
| Independent forward-reachability interval oracle | 13,500 systems; zero discrepancies |
| Feasibility/rejection partition | 624 accepted; 8,972 inconsistent; 3,904 unbracketed; all reasons matched |
| Accepted-position interval endpoints | 1,248 feasible endpoint checks |
| Just outside returned bounds | 1,248 infeasible exterior checks |
| Position-grid membership versus oracle | 5,616 exact agreements |
| Exhaustive four-segment map family | 243 maps; 729 observation sets |
| Known forward-anchor interval containment | 7,290 checks; zero exclusions |
| Known structural-width containment | 729 checks; zero exclusions |
| Typed malformed/ordering/consistency/bracket controls | 28 expected rejections |
| Maximum admitted sample count | 257-sample positive control passed; 258-sample rejection included above |
| CLI argument rejection in normal and optimized modes | 6 checks; exit 2, fixed JSON reason, empty stderr |
| Interior-motion false-width counterexample | 3 translated variants returned exactly `[10,10]`; width 8 excluded |

#### Independent oracle construction

For output knots `0,1,2`, enumerate every sample interval whose integer endpoints satisfy `-1 <= lo <= hi <= 3`: 15 intervals at each knot. Combine all `15^3` observations with slope pairs `(1/2,3/2)` and `(1,1)`, and source anchors `[1,1]` and `[0,2]`, producing 13,500 systems.

The oracle propagates the set of reachable source values from left to right. If the previous reachable interval is `[a,b]`, the next observed interval is `[lo,hi]`, and the output step is `h`, replace it with:

```text
[max(lo, a + m*h), min(hi, b + M*h)]
```

An empty interval means infeasibility. Adjacent feasible values can be connected by line segments within the slope limits; any nonadjacent secant is a weighted average of those slopes. To test a proposed crossing, insert its output coordinate with the source-anchor interval as another node; duplicate output coordinates intersect at step zero. This oracle uses forward propagation only, with no inverse division or calls to the helper's bound formulas.

Every accepted result was tested at both returned endpoints, at `lower-1/1000` and `upper+1/1000`, and at the nine points `0,1/4,...,2`. Independently feasible systems were also checked against the helper's universal bracketing requirement before comparing rejection reasons.

The separate known-map family enumerated all `3^4` four-segment slope sequences over `{1/2,1,3/2}`, on output knots `-2,-1,0,1,2`, at three source offsets. Each map was tested with exact observations, symmetric interior uncertainty `1/8`, and asymmetric interior uncertainty up to `1/4`; endpoint observations stayed exact. All ten ordered pairs with repetition from forward positions `{-3/2,-1/2,1/2,3/2}` generated independently known source-anchor intervals. Additional crossings at `-1` and `1` supplied the known width 2.

The wrong-width control used the specified increasing map through `(0,0),(3,2),(7,8),(10,10)`, translated in output by `-7`, `0` and `11`. Localizing the actual source boundaries `0` and `10` gave width 10 in every case. Interior displacement difference 2 therefore received no structural narrowing credit.

### Limitations and scope

- Finite exhaustive families and the mathematical reasoning above support this exact generated primitive; they do not constitute exhaustive verification over all rational inputs or a machine-checked proof. The independent oracle and map sweeps ran in normal Python mode; the helper's own self-test and the CLI negative controls ran in both modes.
- Positive lower/upper secant slopes remain supplied assumptions. No production slope certificate, source anatomy registration, image-error model, private anatomy claim or downstream scoring integration was reviewed or established. Correlated correspondence information is conservatively reduced to intervals.
- Fraction numerator/denominator size and future private-input resource admission remain caller-owned as explicitly documented. No external-input service or private-input entry point is present here.
- No private media or fixture locations were inspected. No portrait tests, SwiftPM tests, full-package gates, agents, external AI CLI, installs or commits were run. This review grants no portrait acceptance, phase completion, device qualification or external distribution credit.
- Project instructions, relevant owner context and the local skill index were consulted. The GSD review workflow guided classification and the report format. Its bootstrap was found at the installed `.agents/gsd-core` location; project `agent_skills` was empty. Serena and dedicated Read/Write tools were unavailable, so shell reads and the local patch tool were used. Only this requested review artifact was created; source files and the separate semantic review were not edited.

_Reviewer: gsd-code-reviewer; standard depth; 2026-09-15T05:48:47Z._
