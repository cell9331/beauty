# Phase 63 Pattern Map

**Mapped:** 2026-08-07
**Mode:** Main-thread sequential fallback because typed GSD subagent quota is unavailable

## Scope Boundary

Phase 63 converts the already admitted `scleraRednessReduction` intent into
zero-to-two guarded still-image per-eye composition units. Phase 64 retains
strict public output, adversarial protected-color closeout, final visual review
and product promotion. Renderer inventory, Demo, pixel-buffer/realtime, models,
network and `去脂` remain unchanged.

## File and Pattern Assignments

| Planned artifact | Role | Closest analog | Required difference |
| --- | --- | --- | --- |
| `BeautyScleraRednessProvider.swift` | per-eye guard/score/unit provider | teeth provider | zero-to-two side-specific units, guard-before-score, no connected mouth growth |
| `BeautyScleraRednessTransform.swift` | bounded source target | teeth transform | measured red-excess reduction and luminance restore, no whitening/yellow gate |
| `BeautyScleraRednessProviderTests.swift` | mechanics/safety oracles | teeth provider tests | left/right independence, pupil/iris/highlight/lash protection |
| `BeautyEngineScleraRednessIntegrationTests.swift` | production routing/lifecycle | teeth integration tests | teeth/sclera independent invocation and shared one composition |
| `BeautyScleraRednessRealFixtureTests.swift` | private actual-Vision gate | teeth genuine fixture tests | per-eye red-excess/naturalness and reviewed-mask containment |
| `check_phase63_sclera_provider_boundaries.py` | static/mutation gate | Phase 60 checker | eight sclera-specific HIGH threats and Phase 64 absence |
| `63-SECURITY.md` / `63-VERIFICATION.md` | sanitized closeout | Phase 60 records | per-eye claims, exact nonpromotion and Phase 64 handoff |

## Production Data Flow

```text
direct normalized sclera intent
  -> one canonical image
  -> one Vision detect/map
  -> request context with actual mapped eye support + order
  -> one sclera provider invocation
       -> left validation -> hard guard -> score -> reclip -> optional unit
       -> right validation -> hard guard -> score -> reclip -> optional unit
  -> shared local-retouch composition owner (teeth + zero/two eye units)
  -> one compose
  -> existing render
```

## Ownership and Ordering Rules

- Invalid anatomical order rejects all sclera work because side identity is
  ambiguous; missing/invalid support under canonical order rejects only that eye.
- Inputs may arrive in any array order, but accepted units and aggregate
  outcomes are emitted in stable left-then-right order.
- Hard-envelope membership is binary and decided before color scoring.
- The same envelope is applied after every blur and to every proposal.
- Each target reads immutable source bytes; Q16 soft weight is applied once by
  the shared owner; overlapping teeth/eye units preserve original pixels.
- All dense allocations use checked ROI/pixel arithmetic and request-local data.

## Landmines

- Do not reuse paired eye-warp semantics that would make one malformed eye
  disable a valid peer.
- Do not infer iris from dark color, face bounds, eye center or peer geometry.
- Do not reduce protection to gain coverage after private results are visible.
- Do not let blur create weight outside the pre-score envelope.
- Do not return or serialize masks, pupils, source colors or per-pixel metrics.
- Do not make Testing demand activate production sclera behavior.
- Do not add the deferred Phase 64 renderer/output/adversarial/promotion work.

## Dependency and Wave Map

```text
63-01 RED contracts + checker + frozen calibration procedure
  -> 63-02 provider + transform
    -> 63-03 engine integration + peer/lifecycle isolation
      -> 63-04 private genuine pair + full security/regression + Phase 64 handoff
```

