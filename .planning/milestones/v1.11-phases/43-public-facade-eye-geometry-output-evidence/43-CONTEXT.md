# Phase 43: Public-Facade Eye Geometry Output Evidence — Context

**Gathered:** 2026-07-16  
**Status:** Ready for planning  
**Mode:** Auto-resolved by `$gsd-autonomous --auto`

<domain>
## Phase Boundary

Prove the ten Phase 41/42 eye controls through the existing `BeautySDK`
public-facade renderer and saved PNG output. This phase owns the exact renderer
case inventory, bounded strict decoder/output matrix, fixed eye-local ROI
comparisons, signed direction and semantic-independence evidence, eligibility-
aware gaze/symmetry/no-face safe no-ops, and ignored gallery containment. Phase
44 owns exact final caps, exhaustive transition/safety ledgers, fail-closed
boundary closeout, promotion, and owner-document synchronization.

</domain>

<decisions>
## Implementation Decisions

### Renderer Case Matrix

- Add exactly eleven isolated public-facade cases: one positive case for each
  positive-only field (`eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`,
  `gazeCorrection`, `lowerEyelidDrop`, `innerCornerOpen`, `outerCornerOpen`,
  `eyeSymmetry`) plus positive and negative `eyeTilt`.
- Use the Phase 42 provisional evidence value `0.25` for positive-only fields
  and `+0.25`/`-0.25` for signed tilt in IDs, labels, and
  `BeautyParameters` construction. These are output-evidence inputs, not
  Phase 44 final-cap or promotion decisions.
- Preserve the existing 44 renderer cases and seven committed fixtures,
  deriving live inventories and freezing the expected matrix at exactly
  `55 cases × 7 fixtures = 385` PNG outputs. Duplicate case IDs, duplicate
  fixture stems, missing required eye IDs, missing outputs, and stale/unexpected
  output paths fail closed.
- Keep `BeautyExampleRenderer` as a scalar-public client: import only
  `BeautySDK`, construct one-field `BeautyParameters`, and use the existing
  shared `BeautyEngine.processResult` loop. Do not import providers, adapters,
  internal observation types, raw landmarks, or add a render pass/Demo route.

### Strict Decoding and Output Invariants

- The Phase 43 helper is self-contained and bounded, following the hardened
  archived Phase 39/36 decoder: no-follow regular-file opens, bounded PNG/JPEG
  reads and dimensions, complete PNG CRC/chunk/zlib/filter validation, cached
  RGB rows, exact missing/extra matrix checks, and deterministic negative
  self-tests. Every expected output must be regular, non-empty, fully
  decodable, and have the exact input fixture dimensions.
- Acceptance uses a guarded clean render followed by a measurement run and a
  second clean strict run. Changed-pixel and absolute-RGB-delta floors are
  fixed before the accepting run and are documented with weakest-family
  margins; strict mode must never derive thresholds from the matrix it accepts.
- All portrait comparisons exclude the renderer watermark band and use one
  normalized eye-local rectangle shared by all eligible portraits. No
  fixture-specific ROI branches, whole-image-only comparisons, or watermark-
  only differences can satisfy visibility.

### Eye-Local Semantics and Direction

- Compare each of the eleven new cases against `geometryBaseline_noop` in a
  fixed eye-local ROI. Visibility, signed direction, and semantic-independence
  families are reported separately rather than collapsed to one aggregate.
- Positive and negative `eyeTilt` must both differ from baseline, differ from
  each other, and show opposite tangential direction in the same ROI. A tilt
  case must not be accepted merely because it aliases `eyeTailLift`, vertical
  eye position, or a watermark change.
- Distinguish nearest eye families directly in fixed eye-local regions:
  height versus length; upper- versus lower-lid; inner- versus outer-corner;
  pupil-size versus eye-size; gaze-correction versus pupil-size; and symmetry
  versus eye-distance/eye-size. Comparisons should use changed pixels and
  signed/region-local displacement metrics appropriate to each family, with
  fixed case/fixture mapping and no dynamically selected comparator.
- Treat a real portrait's pupil/correction eligibility as observed evidence:
  inventory which fixtures have valid pupil support and which safely no-op.
  Synthetic/private support remains Phase 42's unit-test concern and must not
  be surfaced through renderer APIs or diagnostics.

### Eligibility, No-Face, and Diagnostics

- Add focused public-facade tests for all eleven new cases on the committed
  `negatives/no-face-gradient.png` fixture. Every result must preserve extent,
  remain equal to the geometry baseline in the watermark-safe region, report
  `.noFace`/`.noFaceDetected`, and keep aggregate diagnostics redacted.
- Add output evidence for at least one eligible pupil fixture where automatic
  gaze correction measurably reduces the observed pupil-to-neutral deviation;
  neutral or ineligible pupil fixtures must be explicitly counted as safe
  no-ops, not treated as failed visibility. Symmetry must likewise be
  eligibility-aware and never be proven by a fabricated/mirrored pair.
- Keep field-local no-op behavior distinct from renderer failure: an output
  must still decode and preserve dimensions, but a case lacking its required
  observed support is excluded from that field's portrait-visibility totals
  and recorded in the eligibility inventory.

### Gallery and Artifact Containment

- Extend the existing descriptor-anchored ignored gallery generator's `eyes`
  group by exactly the eleven new IDs. Require duplicate-free set equality
  between renderer source, generated output, and gallery source paths (a
  bijection) across all 55 cases × seven fixtures.
- Generate only below ignored `example-images/output/` and
  `example-images/gallery/`; generated PNGs must remain untracked, unstaged,
  and non-ignored-untracked count zero. Keep gallery publication path-safe and
  reuse the hardened staging/quarantine behavior; do not commit binary
  baselines or add a separate gallery/product surface.

### Documentation and Scope

- Close only EYE-16, EYE-17, and EYE-18 in this phase. Keep EYE-19 through
  EYE-23 and DOC-01 assigned to Phase 44; do not change final caps, promotion
  rows, or branch-level `眼睛` status.
- Record observed provisional output facts, eligibility counts, fixed ROI/floor
  values, strict matrix counts, no-face results, and artifact containment in
  Phase 43 evidence/validation/verification artifacts plus the live example
  image validation docs. Use conservative wording such as “observed
  public-facade output evidence”; do not claim naturalness, final cap approval,
  production readiness, device parity, Demo UI, commercial review, packaging,
  shipping, launch readiness, or whole-branch completion.

### the agent's Discretion

- Choose private helper names, exact eye ROI rectangle, fixed difference
  floors, comparator grouping, and eligibility inventory schema by adapting
  the archived Phase 39/36 patterns, provided they are deterministic,
  bounded, self-tested, and frozen before strict acceptance.
- Choose the portrait fixture(s) used for pupil/gaze and asymmetry evidence
  from the existing seven-fixture inventory after measurement; record the
  observed choice and margins rather than adding or modifying committed input
  media.

</decisions>

<specifics>
## Specific Ideas

- Keep `55 × 7 = 385` as a live-derived and frozen expected total. The eleven
  new cases contribute 77 outputs; six portrait fixtures remain the normal
  visibility pool and the 64×64 no-face fixture remains a safe-no-op pool.
- The strict helper should report separate groups for new-field visibility,
  tilt direction, nearest-neighbor semantic distinctions, gaze reduction, and
  symmetry eligibility. A whole-image pixel count is not sufficient.
- Case labels and helper output must remain aggregate/path-redacted; no pupil
  coordinates, contour points, side labels, or raw observation payload may be
  serialized into output metadata or diagnostics.

</specifics>

<deferred>
## Deferred Ideas

- Exact natural caps, neutral dead-zone constants, exhaustive malformed/fresh/
  reused/stale/provider-empty transitions, 28-field convergence ledger,
  active-source/security boundary gate, exact ten-row promotion, and owner
  synchronization — Phase 44.
- `去脂`, `祛红血丝`, manual gaze direction, per-eye manual asymmetry, Demo UI,
  device/commercial/packaging/shipping/launch evidence — future or out of
  scope for this SDK-core output phase.

</deferred>
