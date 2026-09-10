# Phase 93: Distinct Nose Bridge and Root Repairs — Context

Gathered: 2026-09-08
Status: Ready for resumed planning after explicit owner scope authorization (2026-09-10)
Mode: --auto; defaults derived from existing owner requirements, not new user claims.

<domain>
Repair NOSE-01 positive noseBridge and NOSE-02 positive noseRootNarrowing in
existing owner-local still-image provider seams. Preserve all other controls,
62 stored fields, five presets, 75 renderer cases, both facades, CPU/GPU policy
and retained Warp.metal. Phase 95 owns portrait evaluation and full no-skip.
</domain>

<decisions>
- D-01: Keep bridge definition and root narrowing distinct. Use the frozen
  noseBridge_0p30/bridgeDefinitionGain and noseRootNarrowing_0p25/rootWidthContraction
  contracts and all exact source/neutral/sibling comparisons from Phase 89.
- D-02: Preserve exact current caps and fail-closed support semantics. Do not
  manufacture support from an unrelated face region or borrow nose-tip/slim behavior.
- D-03: Freeze target/protected regions and numeric gates before production:
  source/neutral target >=500 changed pixels and >=2000 RGB delta; signed and
  sibling margins >=16 Q16; outside <=128/512; other nose-region groups <=64/256;
  background/watermark exactly0/0. Manifest/comparator remain unchanged.
- D-04: Use deterministic in-memory generated public-facade pixels and metadata,
  with independent observation-to-raster registration before output scoring.
  Assert neutral identity, extent/orientation/color/alpha, deterministic bytes,
  malformed/missing/provider-empty and valid-invalid-valid recovery as applicable.
- D-05: Validate actual renderer-effective support and overlapping fields, not
  only individual provider coordinates. Phase92 dense folding is a relevant
  lesson; do not claim injectivity from per-point limits alone.
- D-06: Prefer provider-local formulas and private helpers. Preserve shared
  renderer, root/tip ownership, sibling behavior and public inventory. New API,
  model/data/weights, UI, network, live portrait or device work is out of scope.
- D-07: One bounded research pass, one independently checked plan set, at most
  two implementation attempts for Phase93 before explicit owner repair/defer/stop.
  Phase92's special reopening does not extend to Phase93. Count attempts honestly;
  no autonomous threshold relaxation or third attempt.
- D-08: Independent code review and goal verification precede phase completion.
  Synchronize affected owners from measured evidence only. Preserve archived and
  failed historical records. Store only bounded aggregates/status/hashes, never
  raw pixels, geometry, masks, private locators, media/reports or transcripts.
- D-09 (explicit owner authorization, 2026-09-10): The owner approved extending Phase 93 to correct the adapter internal noseRoot(in:) positioning contract and corresponding regression/independent registration tests, with affected owner synchronization. Establish source-side anatomical justification before scoring. This supersedes the prior provider-only scope limitation for this root correction only. Frozen ROIs, numeric thresholds, public interfaces/inventory, shared renderer/sampler/backend/shader and unrelated legacy nose/tip/sibling behavior remain unchanged. The existing two implementation attempts are not reset or expanded; authorization is not efficacy evidence. Continue planning and independent review without asking for this scope approval again.
</decisions>

<code_context>
NoseWarpProvider.swift has bridgePoints and rootNarrowingPoints within existing
field emissions. Root pair validation and shared makePoint behavior already
exist; NoseWarpProviderTests is the closest invariant-test owner. Generated
public-facade repair tests from Phases90–92 and Testing SPI are pattern sources.
Current bridgePoints maps upper nose samples toward center.x; hypotheses about
why outputs are weak require research and frozen tests, not presumed success.
</code_context>

<deferred>
Phase95 portraits/final65-output/no-skip; all UI/realtime/model/data/device or
external-distribution work; further FACE-01 repair remains separately deferred.
</deferred>
