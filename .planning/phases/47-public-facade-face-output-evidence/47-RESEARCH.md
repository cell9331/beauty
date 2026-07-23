# Phase 47: Public-Facade Face Output Evidence — Research

**Researched:** 2026-07-23
**Domain:** Swift public-facade renderer, bounded decoded PNG evidence, face-local locality/independence checks, and ignored gallery containment
**Confidence:** HIGH for repository seams and validation patterns; MEDIUM for fixed visual regions/floors until calibration

<user_constraints>
## User Constraints (from CONTEXT.md)

Phase 47 owns decoded public-facade evidence for
`faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper`.
It must add exactly four isolated renderer cases at provisional `0.25`, preserve
the existing 55 cases and seven inputs, and freeze a duplicate-free
`59 × 7 = 413` output matrix. The renderer remains a `BeautySDK`-only public
client with one shared `BeautyEngine.processResult` call.

Every expected PNG must be regular, non-empty, strictly decoded, and exactly
the source dimensions. Evidence must use fixed watermark-safe face regions,
fixed floors/locality rules, and direct comparisons against the baseline and
nearest shipped/new neighbors. Measurement happens once; strict acceptance is
an independent clean rerun that cannot derive or lower its own thresholds.

Representative no-face, missing-observed-contour, and malformed-contour public
routes must fail closed while an eligible shipped sibling may continue.
Generated output and gallery files remain disposable ignored state. Phase 47
closes only OUT-01 through OUT-03; Phase 48 retains final caps, exhaustive
safety, active-source closeout, promotion, and root owner synchronization.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research support |
|---|---|---|
| OUT-01 | One isolated public renderer case per new control without borrowing shipped fields. | Current renderer has exactly 55 ordered cases, a single facade call, and source-inventory XCTest patterns from Phases 36/39/43. |
| OUT-02 | Bounded strict helper verifies decoded dimensions, fixed-region visibility, locality, and independence. | Archived Phase 43 helper provides bounded decoder/inventory/self-test machinery; Phase 46 providers and tests define intended regions and nearest semantic neighbors. |
| OUT-03 | No-face/missing/malformed routes are safe and generated output/gallery remain contained. | Testing SPI supports deterministic facade fixtures; existing descriptor-safe gallery generator and ignore policy provide exact bijection/containment seams. |
</phase_requirements>

## Summary

Phase 47 is an evidence extension, not a production-provider phase. Phase 46
already routes all four fields through resolver, conflict, public facade, and
the unified geometry pipeline. The production delta should therefore be
limited to four renderer entries, focused source/degradation tests, aggregate
testing fixtures, a phase-owned Python evidence helper, and gallery/docs
updates. Provider math, caps, conflict behavior, public model, Demo, and render
passes should remain unchanged.

The current repository contains exactly 55 `RenderCase` entries and seven
committed image fixtures. Four additions produce the frozen expected matrix of
59 cases and 413 PNG files. The newest suitable strict helper is the archived
Phase 43 eye helper: it already implements descriptor/no-follow acquisition,
bounded PNG/JPEG parsing, CRC/zlib/filter checks, exact live/frozen inventories,
cached RGB rows, watermark exclusion, measurement versus strict modes, and
deterministic adversarial self-tests. Copying and specializing that helper is
lower risk than reviving earlier broad-region helpers.

### Primary recommendation

First freeze the four renderer/test cases and deterministic public degradation
fixtures. Next adapt the Phase 43 helper, replace eye-specific comparisons with
face contour/temple/cheek/chin regions and fixed neighbor families, then run one
measurement matrix and one independent strict matrix. Publish the exact ignored
gallery only after strict acceptance. Record only aggregate counts, minima,
regions, floors, and eligibility facts.

## Current Repository Facts

| Fact | Current value | Evidence |
|---|---:|---|
| Renderer cases | 55 | `RenderCase(` source count and XCTest inventory |
| Committed fixtures | 7 | six portraits plus `negatives/no-face-gradient.png` |
| New cases | 4 | one per Phase 46 field |
| Frozen Phase 47 matrix | 59 × 7 = 413 | live-derived inventory plus required exact count |
| Provisional evidence strength | 0.25 | exact Phase 46 cap for every new field |
| Public render entry | one | existing `engine.processResult(` occurrence |
| Python | 3.9.6 | local runtime |
| Swift | 6.3.3; tools 6.0 | local runtime and package manifest |
| Output/gallery policy | ignored | `.gitignore` entries for both roots |

## Architecture Responsibility Map

| Capability | Owner | Secondary evidence | Boundary |
|---|---|---|---|
| Four case IDs and scalar construction | `BeautyExampleRenderer/main.swift` | renderer source XCTest | Public `BeautySDK` only |
| No-face/missing/malformed route | `BeautyEngine` plus testing SPI provider | facade XCTest | Aggregate fixture names only; no raw support exposure |
| Strict decode and face-local comparisons | Phase 47 Python helper | evidence document | Reads saved bytes only; no provider/landmark access |
| Gallery publication | `example-images/generate_gallery.py` | ignore/tracked/staged scans | Descriptor-anchored ignored roots |
| Final cap/safety/promotion | Phase 48 | none in Phase 47 | Must remain unchanged |

## Reusable Patterns

### Pattern 1: Exact live inventory before fixed expectations

Parse ordered renderer IDs, reject duplicate IDs, discover regular PNG/JPEG
fixtures recursively, reject duplicate stems, build the complete
`fixture__case.png` set, and then enforce 59 cases, seven fixtures, and 413
outputs. Missing, extra, stale, symlinked, or non-regular paths are fatal.

### Pattern 2: Strict bounded decode

Reuse Phase 43's limits and decoder structure:

- descriptor/no-follow regular-file acquisition with identity/snapshot checks;
- 16 MiB compressed-file ceiling;
- 4096 × 4096 dimension ceiling and bounded decoded-byte budget;
- strict PNG signature, IHDR/IDAT/IEND ordering, CRC, zlib, filter, and row-size
  validation;
- bounded JPEG SOF dimension parsing;
- exact input/output dimension equality.

No new package is needed.

### Pattern 3: One measurement run, frozen strict rerun

The helper may expose `--measure` to print candidate region/family minima. The
operator selects conservative committed constants below observed minima with
explicit margins. A physical-path-guarded cleanup then produces a new output
matrix; strict mode consumes only constants embedded in the helper.

Calibration output is not acceptance. Strict mode must not calculate percentiles,
choose fixtures, change comparators, or reduce floors based on the matrix it is
validating.

### Pattern 4: Fixed face-local regions and family metrics

Provider ownership suggests four vertical families:

- upper-lateral temple;
- mid-lateral cheekbone;
- lower-center chin;
- broad contour excluding watermark and interior-only false positives.

Exact normalized rectangles should be selected after measurement, but they must
be shared across fixtures and frozen. Useful aggregate metrics include changed
pixel count, absolute RGB delta, change centroid, and intended-to-disallowed
signal ratio. The helper should verify that each case:

1. crosses baseline visibility floors on eligible portraits;
2. crosses its intended-region floor;
3. cannot pass solely from outside-region or watermark changes; and
4. differs from fixed nearest-neighbor cases in the intended family.

The helper does not need to infer landmark coordinates or reproduce provider
math.

### Pattern 5: Fixed nearest-neighbor comparisons

| New case | Required fixed comparators | Output distinction |
|---|---|---|
| `faceContourSmooth_0p25` | `faceSmall_0p35`, `faceSlim_0p35` | local contour continuity, not global/whole-cheek shrink |
| `templeFullness_0p25` | `faceSmall_0p35`, `faceSlim_0p35`, `cheekboneSlim_0p25` | upper-lateral expansion distinct from shrink/mid-lateral work |
| `cheekboneSlim_0p25` | `faceSlim_0p35`, `jawSlim_0p35`, `templeFullness_0p25` | mid-lateral contraction distinct from whole cheek/jaw/temple |
| `chinTaper_0p25` | `chinLength_plus0p30`, `chinLength_minus0p30`, `faceVShape_0p35` | lower-center narrowing distinct from vertical/signed/V-face work |

The comparison set is constant, never chosen dynamically from the strongest
difference.

### Pattern 6: Representative public degradation without raw test data

Add two testing fixture enum cases rather than public geometry types:

- usable face with observed contour absent;
- usable face with malformed observed contour.

Both produce ordinary `VisionDetectionObservation` values inside the SDK test
support target, pass through the real mapper/adapter, and yield only public
aggregate results. Tests request each new field plus a shipped `faceSlim`
sibling. The new field must disappear, the sibling must keep `.faceShape`
active, extent must be preserved, and warnings/metrics/detection summaries must
contain no contour, median, coordinate, provider, index, or path payload.

### Pattern 7: Exact descriptor-safe gallery bijection

Append four IDs to `CASE_GROUPS["face-shape"]`. Reuse the existing generator's
duplicate rejection, renderer set equality, safe staging/quarantine, no-follow
copy, and final publication swap. After one safe publication require 413
regular gallery PNGs, ignore success for representative output/gallery paths,
and zero tracked/staged/non-ignored generated files.

## Don't Hand-Roll

| Problem | Avoid | Reuse |
|---|---|---|
| Public rendering | Direct provider/adapter calls | existing `BeautyEngine.processResult` loop |
| Image parser | Pillow or unbounded `read_bytes()` | archived Phase 43 stdlib decoder |
| Landmark eligibility | Python/Vision inference | existing SDK route plus aggregate eligibility partition |
| Gallery copy | recursive ad-hoc deletion/copy | current descriptor-safe generator |
| Final safety | new cap/dead-zone/promotion logic | Phase 48 |

## Common Pitfalls

1. **Watermark false positives.** All strict regions must end above the
   renderer-derived watermark band.
2. **Provider tests masquerading as output evidence.** OUT-02 requires decoded
   pixels; Phase 46 vector tests remain supporting, not accepting, evidence.
3. **Dynamic ROI or comparator choice.** A helper that selects the strongest
   region/case from the accepting matrix is circular.
4. **Ineligible portrait counted as visible.** Missing centerline may be a
   legitimate chin-taper no-op; record it outside the denominator.
5. **Broad face differences hiding aliases.** A global shrink can differ from
   baseline while still failing temple/cheek/chin locality.
6. **Stale matrix inflation.** Clean only the allow-listed ignored output root
   before both measurement and strict runs; reject extras.
7. **Premature promotion.** `0.25` remains provisional and the four feature
   rows stay unpromoted until Phase 48.

## Validation Architecture

| Gate | Command family |
|---|---|
| Renderer/source/degradation | focused `BeautyRendererOutputRegressionTests` and `BeautyEngineGeometryFacadeTests` |
| Helper correctness | `--self-test` plus `python3 -m py_compile` |
| Output matrix | guarded clean render plus strict helper |
| Gallery | generator self-test, one publication, exact counts and ignore/tracked/staged scans |
| Regression | full SwiftPM suite |
| Scope | source/public/import/network/status/artifact scans and `git diff --check` |

## Security Domain

ASVS L1 input-validation and artifact-boundary controls apply. Untrusted image
files must be bounded and decoded fail-closed. Observed support remains
biometric-adjacent, package-only, non-Codable, ephemeral, and absent from
helper output, evidence docs, gallery metadata, public diagnostics, persistence,
and network paths. The helper records filenames only as committed aggregate
fixture labels, never raw geometry or image content.

## Environment Availability

No external service or package install is required. Swift/XCTest, Xcode/AppKit,
Python 3.9.6, the existing renderer, seven committed fixtures, and the gallery
generator are present. If Apple Vision/Xcode host behavior fails, record the
exact environment failure and do not fabricate output acceptance.

## Assumptions Log

| ID | Assumption | Risk / required response |
|---|---|---|
| A1 | Provisional 0.25 produces measurable output on at least one committed eligible portrait per field. | If false, Phase 47 is blocked; do not increase final caps or claim visibility without a scoped decision. |
| A2 | Fixed repository-wide face regions can prove all four families. | If false, use fixed family-specific regions, never fixture-specific or dynamic regions. |
| A3 | At least one committed portrait has complete contour+centerline eligibility for chin taper. | Phase 45 aggregate fixture evidence suggests yes; strict output must confirm. |
| A4 | Four IDs can extend the existing `face-shape` gallery group without generator redesign. | Current exact-set generator architecture supports additive IDs. |
| A5 | Representative malformed/missing support can be expressed by aggregate testing SPI enum cases. | If compiler/access boundaries reject this, keep the carrier internal and expose no new raw type. |

## Sources

### Primary

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`
- `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift`
- `.planning/phases/46-independent-contour-and-chin-geometry/46-VERIFICATION.md`
- `.planning/phases/46-independent-contour-and-chin-geometry/46-SECURITY.md`
- `.planning/milestones/v1.11-phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py`
- `example-images/generate_gallery.py`
- `example-images/README.md`
- `.planning/REQUIREMENTS.md` and `.planning/ROADMAP.md`

### Secondary

- Archived Phase 39/36 strict renderer helpers and evidence documents for
  earlier face-local output families.

## Metadata

- Stack confidence: HIGH.
- Repository seam confidence: HIGH.
- Fixed region/floor confidence: MEDIUM until measurement.
- Security/containment confidence: HIGH.

**Research date:** 2026-07-23
**Valid until:** 2026-08-22 for repository-stable seams; remeasure after renderer, fixture, or provider changes.
