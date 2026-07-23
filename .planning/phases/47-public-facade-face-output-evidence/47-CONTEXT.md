# Phase 47: Public-Facade Face Output Evidence — Context

**Gathered:** 2026-07-23
**Status:** Ready for planning
**Mode:** Auto-resolved by `$gsd-autonomous --auto`

<domain>
## Phase Boundary

Prove the four Phase 45/46 face controls through the existing `BeautySDK`
public-facade renderer and decoded PNG output. This phase owns the exact
renderer case inventory, bounded strict decode/output matrix, fixed face-local
visibility and locality comparisons, nearest-neighbor independence evidence,
representative no-face/missing/malformed support behavior, and ignored gallery
containment. Phase 48 owns final caps/dead zones, exhaustive nine-face-field and
37-field safety matrices, active-source security closeout, exact four-row
promotion, branch status, and final owner synchronization.

</domain>

<decisions>
## Implementation Decisions

### Renderer Case Matrix

- Add exactly four isolated public-facade cases:
  `faceContourSmooth_0p25`, `templeFullness_0p25`,
  `cheekboneSlim_0p25`, and `chinTaper_0p25`.
- Each case uses only its matching public scalar at the Phase 46 provisional
  value `0.25`. The value is an output-evidence input, not a final-cap,
  dead-zone, naturalness, or promotion decision.
- Preserve the existing 55 renderer cases and seven committed fixtures,
  deriving live inventories and freezing the expected matrix at exactly
  `59 cases × 7 fixtures = 413` PNG outputs. Duplicate IDs or fixture stems,
  missing required face IDs, missing outputs, and stale/unexpected paths fail
  closed.
- Keep `BeautyExampleRenderer` a scalar-public client importing only
  `BeautySDK` and using the single existing `BeautyEngine.processResult` loop.
  Do not import providers, adapters, support carriers, or raw landmarks and do
  not add a render pass or Demo route.

### Strict Decode, Visibility, and Locality

- Create a self-contained Phase 47 helper by adapting the hardened Phase 43
  standard-library decoder and descriptor-safe acquisition pattern: bounded
  regular-file opens, strict PNG CRC/chunk/zlib/filter validation, bounded JPEG
  dimensions, cached RGB rows, and exact missing/extra matrix enforcement.
- Use a guarded clean measurement render followed by frozen thresholds and a
  second independent clean strict render. Strict mode must consume committed
  constants and must never derive, lower, or select its thresholds from the
  matrix being accepted.
- Every expected output must be regular, non-empty, fully decoded, and exactly
  the input fixture dimensions. Portrait acceptance excludes the renderer
  watermark and uses fixed normalized face-local regions chosen once during
  calibration, with no fixture-specific ROI branches.
- Prove each new case differs from `geometryBaseline_noop` on every eligible
  portrait at fixed changed-pixel and absolute-RGB floors. Locality must show
  the intended region carries the required signal while disallowed regions do
  not become the sole source of acceptance.

### Semantic Independence

- Keep semantic families separate:
  - smooth contour versus `faceSmall_0p35` and `faceSlim_0p35`, with local
    contour evidence rather than whole-face shrink acceptance;
  - temple fullness versus `faceSmall_0p35`, `faceSlim_0p35`, and
    `cheekboneSlim_0p25`, with upper-lateral output distinct from mid/lower
    output;
  - cheekbone slim versus `faceSlim_0p35`, `jawSlim_0p35`, and
    `templeFullness_0p25`, with mid-lateral output distinct from temple/jaw;
  - chin taper versus both signed `chinLength` cases and
    `faceVShape_0p35`, with lower-center narrowing distinct from vertical
    length change and V-face behavior.
- Comparators and normalized regions are fixed before strict acceptance.
  Whole-image-only changes, watermark differences, dynamic comparator
  selection, or provider-unit assertions cannot satisfy OUT-02.

### Eligibility and Representative Degradation

- Real portrait output evidence is eligibility-aware. A portrait without valid
  observed contour or centerline support still must decode and preserve
  dimensions, but its field-local no-op is recorded outside that field's
  visibility denominator rather than counted as a pass or failure.
- Add public-facade focused tests for all four controls with a representative
  no-face fixture. Results preserve extent, report the established aggregate
  no-face degradation, and remain baseline no-ops outside the watermark.
- Extend testing SPI with aggregate fixture choices for a usable face missing
  observed contour and a usable face carrying malformed observed contour.
  Both must traverse the production detector/mapper/adapter boundary without
  exposing raw support. The four new fields fail closed while an eligible
  shipped face sibling continues through the same public facade.
- Do not claim the exhaustive no-face/missing/malformed/provider-empty/fresh/
  reused/stale matrix; Phase 48 owns complete transition and safety evidence.

### Gallery and Artifact Containment

- Extend the existing descriptor-anchored ignored gallery generator's
  `face-shape` group by exactly the four new IDs. Require duplicate-free set
  equality between renderer source, flat generated outputs, and gallery source
  paths across all 59 cases × seven fixtures.
- Generate only under ignored `example-images/output/` and
  `example-images/gallery/`. Generated PNGs must remain untracked, unstaged,
  and non-ignored-untracked count zero.
- Reuse the hardened staging/quarantine behavior. Do not commit binary
  baselines or add another gallery/product surface.

### Documentation and Scope

- Close only OUT-01, OUT-02, and OUT-03. Leave SAFE-01 through SAFE-03 and
  DOC-01 assigned to Phase 48; do not edit final caps, feature-ledger row
  status, or branch-level `脸型` status.
- Record exact case/fixture/output counts, fixed regions/floors, observed
  eligibility and family minima, degradation results, and artifact containment
  in Phase 47 evidence/validation/verification artifacts plus the live example
  image validation docs.
- Use conservative wording: “observed public-facade output evidence.” Do not
  claim subjective naturalness, final calibration, exhaustive safety, product
  promotion, Demo/device parity, commercial review, optimized performance,
  packaging, shipping, launch readiness, or whole-branch completion.

### the agent's Discretion

- Choose private helper names, exact normalized face regions, fixed floors,
  locality ratios, family metric shapes, and eligibility inventory schema by
  adapting the archived Phase 43/39 patterns, provided they are deterministic,
  bounded, self-tested, and frozen before strict acceptance.
- Choose eligible portrait subsets from the existing six committed portraits
  after measurement. Record aggregate fixture names/counts and margins; do not
  add or alter committed media and do not expose raw support.

</decisions>

<specifics>
## Specific Ideas

- Keep `59 × 7 = 413` as a live-derived and frozen expected total. The four new
  cases contribute 28 outputs; six portrait fixtures form the eligibility pool
  and the 64×64 no-face fixture forms the explicit safe-no-op pool.
- The strict helper should report decoded matrix, per-field visibility,
  intended-region locality, nearest-neighbor semantic distinctions, eligibility
  partitions, and four no-face no-ops as separate groups.
- Case labels, helper output, evidence docs, warnings, and metrics remain
  aggregate/path-redacted: no contour/median coordinates, apex index, provider
  arrays, framework objects, file contents, or image bytes are serialized.

</specifics>

<deferred>
## Deferred Ideas

- Final caps/dead zones, exhaustive nine-face-field transitions, complete
  37-field convergence, active-source privacy/security gates, exact four-row
  promotion, branch-status closeout, and root owner synchronization — Phase 48.
- `去双下巴`, `去双下巴 Pro`, `发际线`, Demo UI, physical-device parity,
  commercial naturalness, optimized profiling, packaging, shipping, and launch
  evidence — future or outside this SDK-core output phase.

</deferred>
