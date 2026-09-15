---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T04:04:41Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - scripts/phase95-root-affine-motion-probe.py
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-AFFINE-MODEL.md
sha256:
  scripts/phase95-root-affine-motion-probe.py: 0d99954325288c2b7da43cb4dcb90412decb7aeb441fcc82ae605d4edfe8f06c
  .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-AFFINE-MODEL.md: e5b344daf59ffeb8e8d13423c46c450ea2e0a0390de375cc1b88ab6b1d0eea36
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
acceptance_credit: false
production_correctness_credit: false
phase_complete: false
---

# Phase 95: Independent signed affine-motion review

## Narrative Findings (AI reviewer)

No reproducible correctness, security, or reliability defect was established in the two submitted files within this bounded standard-depth review. This conclusion concerns the generated mathematical prototype at the exact hashes above. It is not metric approval, source registration approval, portrait acceptance, or production correctness evidence.

Both hashes matched before and after the independent checks. The explanatory model was reviewed in full as the explicitly requested companion to the script. No structural pre-pass was supplied.

## Independent evidence

The reviewer executed three bounded, memory-only Python checks using the standard library. No oracle file, generated pixels, vertices, geometry, or child transcript was persisted. Each command had a 110-second alarm; observed durations were 6.34, 3.84, and 19.80 seconds.

| Check | Aggregate result |
| --- | --- |
| Independent exhaustive vertex enumeration versus `clip` | 22 bounded polytopes, 97 prefix comparisons, zero vertex-set mismatches |
| Complete active-constraint sets | 1,172 vertex checks, zero mismatches |
| Empty intersections | 10 empty prefixes agreed with enumeration |
| Signed affine displacement coverage | 17 admissible grid cases covered |
| Known motion/gain/offset tuples against observation inequalities | 306 checks passed |
| Halfspace feasibility versus independently evaluated piecewise sampling and photometry | 1,350 agreements |
| Contraction endpoint extrema | 675 checks passed |
| Conservative candidate/neutral margin | 225 checks passed |
| Newly added malformed-input controls | 3 rejected with exact `invalid_input` reason |
| Newly added error-budget widening control | Wider interval enclosed narrower interval |
| Independently rendered motion/photometry boundary cases | 6 true displacements retained |
| Flat and brightness-ramp ambiguity controls | Both passed |

The enumeration oracle independently intersected **every combination of four constraint planes**, using forward elimination and back-substitution, then tested each resulting rational point against every halfspace. It did not call the script's `solve4`, use the script's edge selection, or seed enumeration with clipped vertices. Each prefix was compared by complete vertex-set equality, not merely by matching displacement extrema. Cases included redundant and scaled duplicate cuts, tangent cuts, zero normals, oblique cuts, empty intersections, successive face/line/point collapse, and deterministic random rational cuts. All remained bounded by the initial box.

## Mathematical assessment

- **Exact clipping and degeneracy (`script:40–81`).** Active constraints are initialized correctly. For a bounded polytope in ambient dimension four, an edge has common active normals of rank three, including equality normals when the feasible set has lower dimension. A strict crossing supplies the independent fourth plane. Trying all common triples finds that basis. Retaining zero-distance vertices handles supporting cuts and collapse; exact interpolation guards the intersection calculation. Independent enumeration also checked that all active-plane identities remain complete.
- **Sign partitions and inequality signs (`script:84–109`).** A scalar affine function on the ordered sample positions has at most one sign transition. Uniform and single-transition patterns cover the allowed motions; zero displacements belong to either adjacent cell. The two directional gradients produce the correct inverse sample. Both residual inequalities agree with direct evaluation of the observation equation.
- **Gain/offset bounds (`script:40–46,93–108`).** Positive inverse gain has the stated reciprocal range. The beta constraints impose the original offset bound after division by alpha. The enclosing beta box contains that entire wedge, including its endpoints. Independent cases exercised the gain and offset endpoints, including zero-error cases.
- **All-feasible hull (`script:119–131`).** Every nonempty sign polytope contributes its minimum and maximum center displacement. Taking the outer extrema preserves every projected component, zero crossing, and search boundary. A gap between components can enlarge the hull but cannot make it narrower than the feasible union.
- **Conservative margin (`script:158–163,184–191`).** Left-minus-right interval extrema have the correct order and positive width scaling. The margin requires both an absolute lower bound and a candidate-versus-neutral lower bound. Separate-side and neutral uncertainty can make this conservative; no best-component selection or interval-width cutoff grants credit.

## Truth, controls, and limits

The self-test's per-side truth assertions check the known analytic center displacements; the paired assertion checks the known contraction. Those are generated fixture parameters, as the script and model now explicitly state. They do not measure independent production geometry. The negative-control assertion forbids promotion of the tested amounts at or below 16 Q16, while the explicit 32 Q16 assertion prevents a universally abstaining implementation from passing. Intermediate power is reported without an invented success requirement.

The independently rendered boundary cases used a separate interpolation calculation, without calling `render`, and covered both displacement endpoints, both slope directions through zero, endpoint-zero sign overlap, and extreme allowed photometry. The newly added truncation, unsafe-center, byte-range, and one-byte widening checks were rerun successfully.

The full 42-pair self-test was **not rerun by this reviewer**. Its reported power distribution remains supplied context; the main thread owns collection of its already-running final session 7375. This report must not be substituted for that result.

The model appropriately leaves actual SDK sampling error, anatomical correspondence, non-affine deformation, source identifiability, and portrait effectiveness unproven. Its supplementary research citation was not independently evaluated; no conclusion here relies on it. No private fixtures, production execution, package installation, external AI, agents, source edits, or commits were used. Only this new review artifact was written; previous reviews were preserved.
