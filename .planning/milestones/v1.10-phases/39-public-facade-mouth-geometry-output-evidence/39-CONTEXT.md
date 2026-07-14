# Phase 39: Public-Facade Mouth Geometry Output Evidence - Context

**Gathered:** 2026-07-14
**Status:** Ready for planning
**Mode:** Autonomous smart discuss (`--auto` recommendations accepted)

<domain>
## Phase Boundary

Produce deterministic saved-output evidence for the five Phase 38 mouth geometry controls through the public `BeautySDK` facade. This phase owns isolated renderer cases, strict decoded mouth-ROI and independence checks, representative no-face behavior, and ignored output/gallery containment. Final cap calibration, exhaustive all-eight-field safety, active-source boundary closeout, and product-row promotion remain Phase 40 scope.

</domain>

<decisions>
## Implementation Decisions

### Renderer Cases
- Add exactly eight isolated public-facade cases: positive and negative cases for `mouthYPosition`, `mouthTilt`, and `mouthXPosition`, plus one positive `lipPeakDefinition` and one positive `lipPlump` case.
- Use the current provisional `0.25` effective values in renderer IDs, labels, and public `BeautyParameters` construction; these are evidence inputs, not final-cap approval.
- Preserve the existing 36 cases and seven committed fixtures, yielding a frozen current expectation of exactly `44 cases × 7 fixtures = 308 PNGs` while deriving and validating both inventories from live source and fixture files.
- The renderer continues to import only `BeautySDK` and call `BeautyEngine.processResult`; it must not reach package-internal geometry, providers, adapters, or raw landmarks.

### Output Visibility and Direction
- Require every expected PNG to exist, be regular, non-empty, fully decodable, and dimension-preserving relative to its input fixture; duplicate case IDs and duplicate fixture stems fail closed.
- Compare each of the eight new cases with `geometryBaseline_noop` inside one deterministic normalized mouth ROI that is wholly above the rendered watermark band for every usable portrait.
- Compare each signed positive/negative pair directly in the same ROI so translation and tilt direction cannot collapse to an identical output.
- Use fixed changed-pixel and absolute-RGB-delta thresholds selected from an initial calibration run, document observed minima and margins, then rerun from a clean generated matrix; do not derive acceptance thresholds dynamically during the accepting run.

### Semantic Independence
- Compare `lipPeakDefinition_0p25` directly with `smile_0p50` and `mouthSize_plus0p35` in the mouth ROI, and compare `lipPlump_0p25` directly with `mouthSize_plus0p35`, `lipColor_0p50`, and `lipPeakDefinition_0p25`.
- Report visibility, three signed-direction families, peak independence, and plump independence separately; aggregate whole-image or watermark-only differences are insufficient.
- Do not interpret `lipColor` as geometry or allow it to prove true plumping; it is only a nearest shipped non-alias comparator.

### No-Face and Artifact Containment
- For the representative no-face fixture, all eight new outputs must exist, decode, remain non-empty, preserve extent, and match the geometry baseline above the excluded watermark band; no-face cases are excluded from portrait visibility totals.
- Extend the existing safe gallery generator's `mouth` group by exactly the eight renderer IDs and require a duplicate-free bijection with the live renderer inventory.
- Generate only under ignored `example-images/output/` and `example-images/gallery/`; no generated PNG may be staged or tracked, and stale/unexpected renderer-shaped outputs must not satisfy the exact-count gate.

### Documentation and Scope
- Close only MOUTH-09 through MOUTH-11 in this phase and preserve MOUTH-12 through MOUTH-16 plus DOC-01 for Phase 40.
- Update renderer/output evidence owners factually, but keep `上下`, `倾斜`, `左右`, `M唇`, true `丰唇`, and branch-level `嘴唇` unpromoted.
- Do not claim final caps, exhaustive degradation safety, Demo UI, device parity, commercial visual approval, packaging, shipping, or launch readiness.

### the agent's Discretion
- Exact helper names, private parsing/decoding organization, the single normalized mouth rectangle, and fixed numeric difference floors may follow the hardened archived Phase 33 and Phase 36 patterns, provided they are deterministic, self-contained, bounded, archive-rerunnable, and documented with observed evidence.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` owns the current 36-case public-facade matrix and already contains the baseline plus shipped mouth comparators.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` owns exact case inventory, one-field construction, facade-only imports, and representative no-face public behavior.
- Archived Phase 33 owns the nearest mouth-ROI helper pattern; archived Phase 36 owns the newest self-contained strict decoder, inventory, no-face, and artifact-evidence pattern.
- `example-images/generate_gallery.py` already publishes descriptor-anchored ignored galleries and validates its case inventory against renderer source.

### Established Patterns
- Exact matrix totals are derived from live renderer cases and recursively discovered fixtures, then checked against the phase's frozen expected inventory.
- Generated output/gallery PNGs are disposable local evidence and must never become committed baselines.
- Output evidence proves visibility and non-alias behavior, not artistic naturalness or release readiness.

### Integration Points
- Runtime edits should be limited to the example renderer; focused contract changes belong in `BeautyRendererOutputRegressionTests`.
- The v1.10 helper, evidence, validation, review, security, and verification artifacts belong in this Phase 39 directory.
- `example-images/README.md` and `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` may record observed Phase 39 output evidence without changing product promotion ledgers.

</code_context>

<specifics>
## Specific Ideas

Treat `44 × 7 = 308`, `48` portrait new-vs-baseline checks, `18` signed-pair checks, and the direct peak/plump comparator families as expected current evidence counts derived from six usable portraits, not unconditional strings detached from live inventories.

</specifics>

<deferred>
## Deferred Ideas

- Exact final caps, capped-count and directionality closeout, exhaustive no-face/missing/reused/stale/provider-empty transitions, once-only convergence, and redacted diagnostic boundary scans — Phase 40.
- Exact five-row promotion and owning-ledger/branch synchronization — Phase 40.
- `白牙`, teeth segmentation/retouch, Demo UI, device/commercial/packaging/shipping/launch evidence — outside Phase 39 and v1.10 geometry scope.

</deferred>
