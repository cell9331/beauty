# Phase 94: Negative Mouth-Width Repair — Context

Gathered: 2026-09-11
Status: Ready for bounded research/planning

This context carries forward existing ROADMAP/REQUIREMENTS/project decisions after the owner requested continuation. No new product choices were inferred from an unanswered question. All meaningful product scope is already specified; technical diagnosis remains implementation work.

<domain>
MOUTH-01: contract mouth width through negative mouthWidth, retain existing positive expansion and distinguish both from whole-mouth mouthSize. Preserve mouth height, surrounding face and background. Owner-local SDK still-image scope only.
</domain>

<decisions>
- D-01: Existing signed mouthWidth and exact ±0.35 cap remain; preserve positive outputs and all sibling controls. Do not alias mouthSize or invert both signed directions.
- D-02: Phase89 mouthWidth_minus0p35 contract remains frozen: all five comparisons (source, neutral, positive width and both signed sizes), target/protected regions and numeric predicates unchanged. Measure real public-facade input/output pixels; arbitrary changed pixels or provider targets alone cannot establish contraction.
- D-03: Establish independent source/observation/adapter/raster registration before scoring or changing production. Use deterministic generated in-memory fixtures; retain baseline positive/sibling pixel digests before repair. Do not relocate fixture anatomy after observing candidate results. Bounds-derived adapter templates are not observed individual anatomy.
- D-04: Preserve actual metadata contract, neutral identity, alpha, size/extent, supported orientation/mirror behavior, deterministic output, invalid/missing support isolation and recovery. Derive renderer-effective displacement/cutoff and whole-field safety from existing sampler; do not infer rendered motion solely from point.strength.
- D-05: Keep production changes within private negative width implementation unless evidence establishes a required broader contract change and it is explicitly authorized. Preserve positive width, all siblings, shared renderer/sampler, retained Warp.metal, backend policy, 62 fields, five presets and 75 renderer cases.
- D-06: One bounded research pass, one independently checked plan set and at most two substantive implementation attempts. Freeze tests and oracle before first production mutation; retain failures, source hashes and rollback evidence. A terminal prerequisite failure or two failed attempts requires explicit repair/defer/stop disposition, never an automatic third attempt or gate relaxation. Phase93-specific adapter/attempt authorizations do not transfer.
- D-07: Independent code review and goal verification plus affected owner synchronization precede completion. Persist only bounded aggregates/status/hashes; raw pixels, geometry, private locators and child transcripts remain absent from durable evidence. Reuse finite child deadlines with cold-build costs accounted for, exact test selection and cleanup.
- D-08: Phase95 owns private portrait/final65-output/full-no-skip closeout. No UI, network, model/weight/data work, real-device requirement or external-distribution claim is added. FACE-01 remains deferred.
</decisions>

<canonical_refs>
- AGENTS.md and PLANS.md — repository authority, tracking and scope.
- .planning/PROJECT.md and .planning/REQUIREMENTS.md — v1.22/MOUTH-01.
- .planning/ROADMAP.md — Phase94 success criteria and finite attempt policy.
- DESIGN.md, RELIABILITY.md, SECURITY.md, PRODUCT_SENSE.md, QUALITY_SCORE.md — current owner contracts.
- docs/SDK_EFFECT_TAXONOMY.md — effect taxonomy.
- scripts/face-feature-batch-manifest.json and scripts/compare-face-feature-batches.swift — frozen semantic authority.
- BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift — signed provider and emission sanitation.
- BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift — actual mouth support ownership.
- BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift — retained positive/sibling and fail-closed regressions.
- .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-VERIFICATION.md — completed prior evidence and metadata/orientation limitations; historical gates are not reusable candidate authority.
No external specifications or dependency changes.
</canonical_refs>

<code_context>
widthPoints already moves negative targets inward; provider-coordinate polarity is not proof of public pixel efficacy. It selects extrema of validated outerLips and shares makePoints with other mouth effects. Preserve shared helper/sibling behavior. Independent pixel and metric tests from prior repair phases are structural patterns, not interchangeable fixtures or acceptance receipts.
</code_context>

<deferred>
Phase95 closeout, optional later device feedback and all out-of-scope controls remain separate.
</deferred>
