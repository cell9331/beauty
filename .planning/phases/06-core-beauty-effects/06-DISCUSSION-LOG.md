# Phase 6: Core Beauty Effects - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-20T06:40:03Z
**Phase:** 6-Core Beauty Effects
**Areas discussed:** Visible effect baseline, Naturalness caps, Missing landmark behavior, Preset and Demo feedback

---

## Visible Effect Baseline

### Question: What level of real visual output should Phase 6 prove?

| Option | Description | Selected |
|--------|-------------|----------|
| Fixture-visible MVP across all domains | Skin/color, face shape, eyes, nose, mouth, and lip color all produce deterministic visible differences in tests/fixtures, but stay conservative. | ✓ |
| Skin/color visible first | Skin, color, and lip color become visibly effective; geometry providers can be structurally tested with limited visual proof. | |
| Pipeline scaffold only | Wire `BeautyEffects`/`RenderGraph` and safety logic, but leave most output visually close to no-op. | |
| Other | Freeform target. | |

**User's choice:** Fixture-visible MVP across all domains.
**Notes:** This locks Phase 6 as the first full visible-effect milestone, not a scaffold-only pass.

### Question: How strong should the first visible results be?

| Option | Description | Selected |
|--------|-------------|----------|
| Plainly visible but conservative | Enough change for fixture tests and human smoke checks, but never max beauty or identity-changing. | ✓ |
| Very subtle natural preview | Closer to production taste, but visual tests may need tighter fixtures to detect changes. | |
| Obvious demo strength | Make effects easy to see in the Demo, accepting more artificial output during MVP. | |
| Other | Freeform target. | |

**User's choice:** Plainly visible but conservative.
**Notes:** Output should prove value without violating naturalness.

### Question: What should count as proved for Phase 6 visual output?

| Option | Description | Selected |
|--------|-------------|----------|
| Automated fixture evidence + focused Demo smoke | Deterministic SDK fixture tests prove visible changes; Demo simulator/manual smoke confirms controls visibly update. | ✓ |
| Automated fixture evidence only | Enough for CI-style confidence, with manual visual QA deferred. | |
| Demo smoke first | Prioritize human-visible Demo behavior, with fixture rigor added later. | |
| Other | Freeform proof bar. | |

**User's choice:** Automated fixture evidence plus focused Demo smoke.
**Notes:** Planner should include both automated and smoke evidence.

### Question: Where must the visible effect work in Phase 6?

| Option | Description | Selected |
|--------|-------------|----------|
| Camera and Photo paths | Both realtime `CVPixelBuffer` and still `CIImage`/image path show effects or equivalent tested output behavior. | ✓ |
| Photo path first | Still-image fixtures prove output; realtime Camera can stay structurally wired with limited visual proof. | |
| Camera path first | Realtime preview proves output; still-image fixture parity can follow. | |
| Other | Freeform path scope. | |

**User's choice:** Camera and Photo paths.
**Notes:** Both public processing paths are in scope for Phase 6 evidence.

---

## Naturalness Caps

### Question: How should Phase 6 treat maximum UI slider values for geometry controls?

| Option | Description | Selected |
|--------|-------------|----------|
| Safety-capped, not literal max | UI can reach 100, but effective face/eye/nose/mouth geometry is capped by algorithm rules so output stays plausible. | ✓ |
| Mostly literal with soft caps | High UI values produce strong visible changes, with caps only for obviously broken combinations. | |
| Very conservative caps | Even 100 should look close to a natural preset, prioritizing identity preservation over visible strength. | |
| Other | Freeform cap behavior. | |

**User's choice:** Safety-capped, not literal max.
**Notes:** Public display range and internal effective strength are intentionally separate.

### Question: Where should the first Phase 6 cap values come from?

| Option | Description | Selected |
|--------|-------------|----------|
| Use existing parameter spec caps | Start from `docs/06_beauty_parameters_spec.md` cap guidance, then encode as tested SDK constants. | ✓ |
| Planner chooses fresh conservative caps | Use the spec as background only; let implementation tune per fixture. | |
| One global cap per domain | Simpler, but less precise for risky controls like eyes, nose, and mouth. | |
| Other | Freeform source of truth. | |

**User's choice:** Use existing parameter spec caps.
**Notes:** The historical parameter spec becomes the initial cap source of truth.

### Question: How should combined geometry controls behave when several are high at once?

| Option | Description | Selected |
|--------|-------------|----------|
| Reduce combined strength | Individual controls keep their caps, but overlapping/compound geometry is weakened so edits stay plausible together. | ✓ |
| Priority order wins | Apply strongest/most important controls first and skip weaker overlapping controls. | |
| Independent caps only | Each control caps independently; combined distortion is handled later if fixtures fail. | |
| Other | Freeform combination policy. | |

**User's choice:** Reduce combined strength.
**Notes:** Combined safety is required, not a later bug-fix-only concern.

### Question: What should happen when a high-strength value is capped internally?

| Option | Description | Selected |
|--------|-------------|----------|
| Return warnings/metrics in debug-style result metadata | Normal UI stays clean, while `BeautyResult.warnings` or metrics show output was capped/weakened. | ✓ |
| Show normal UI status copy | Tell users when caps are applied. | |
| Silent cap | Cap internally with no public warning unless there is a failure. | |
| Other | Freeform visibility policy. | |

**User's choice:** Return warnings/metrics in debug-style result metadata.
**Notes:** Cap evidence is for diagnostics and tests, not normal UI noise.

---

## Missing Landmark Behavior

### Question: When no usable face is available, which effects should still run?

| Option | Description | Selected |
|--------|-------------|----------|
| Color/filter only; skip face-dependent effects | Color, LUT/filter, and other non-face effects can run; skin/face/eye/nose/mouth geometry and lip effects skip or no-op with warning metadata. | ✓ |
| Skin can still run full-image | Color/filter plus skin smoothing/whitening/rosy/sharpen run over the full image; geometry skips. | |
| Everything weakens globally | All effects attempt a weakened fallback, even without reliable landmarks. | |
| Other | Freeform policy. | |

**User's choice:** Color/filter only; skip face-dependent effects.
**Notes:** No-face behavior stays conservative and privacy-safe.

### Question: When only some landmark groups are missing, how targeted should the skip be?

| Option | Description | Selected |
|--------|-------------|----------|
| Skip only affected domains | Missing eyes skip eye effects, missing nose skips nose effects, missing mouth skips mouth/lip effects; unrelated safe effects continue. | ✓ |
| Skip all geometry | If any required facial landmark group is missing, skip face, eyes, nose, and mouth together. | |
| Apply weak fallback geometry | Estimate missing groups from available landmarks and apply reduced effects. | |
| Other | Freeform behavior. | |

**User's choice:** Skip only affected domains.
**Notes:** Partial degradation should be precise and testable.

### Question: How should stale or reused detection affect geometry?

| Option | Description | Selected |
|--------|-------------|----------|
| Allow weak/reduced geometry briefly | Reused landmarks can drive moderate effects within the reuse window; stale landmarks disable strong geometry and produce warning metadata. | ✓ |
| Disable all geometry on reused/stale | Only fresh usable detection can drive geometry. | |
| Treat reused as fresh | Keep geometry fully active until detection is explicitly lost. | |
| Other | Freeform behavior. | |

**User's choice:** Allow weak/reduced geometry briefly.
**Notes:** This aligns with Phase 4 detection-state decisions.

### Question: What should normal Demo UI do when face-dependent output is skipped or weakened?

| Option | Description | Selected |
|--------|-------------|----------|
| Reuse existing detection status only | Keep sliders enabled and rely on the existing short detection status/debug model; do not add per-slider disablement or cap banners. | ✓ |
| Disable affected controls | Visibly disable eye/nose/mouth/face sliders when required landmarks are missing. | |
| Show per-domain inline warnings | Keep controls enabled but show short messages under affected groups. | |
| Other | Freeform UI policy. | |

**User's choice:** Reuse existing detection status only.
**Notes:** Phase 6 should not expand UI warning surfaces.

---

## Preset and Demo Feedback

### Question: What should happen to existing built-in presets in Phase 6?

| Option | Description | Selected |
|--------|-------------|----------|
| Make presets visibly effective | Natural, Clear, Refined, Male Natural, and ID Photo Natural should produce conservative visible output using the new effect pipeline. | ✓ |
| Keep presets as parameter bundles only | Effects can be tested through manual sliders; preset visual tuning waits until Phase 7. | |
| Only Natural becomes visually tuned | Prove one end-to-end preset now, tune the rest later. | |
| Other | Freeform preset target. | |

**User's choice:** Make presets visibly effective.
**Notes:** All Phase 5 built-in presets now need visible output evidence.

### Question: What should replace the current "Visual update pending Phase 6" status after Phase 6 lands?

| Option | Description | Selected |
|--------|-------------|----------|
| Effect-applied status only for transient feedback | Replace pending copy with short applied/degraded feedback when useful, then keep normal UI quiet. | ✓ |
| Always show effect status | Show a persistent "Effects active" style row whenever parameters are non-default. | |
| No parameter status row | Remove the status row unless there is a resource/detection/degradation issue. | |
| Other | Freeform feedback behavior. | |

**User's choice:** Effect-applied status only for transient feedback.
**Notes:** Normal UI should remain quiet.

### Question: Should Phase 6 add new UI controls or change category structure?

| Option | Description | Selected |
|--------|-------------|----------|
| No new controls/categories | Use the existing skin/color/face/eyes/nose/mouth controls and existing category structure; implementation changes behavior behind them. | ✓ |
| Add small effect-state indicators | Keep categories but add subtle per-domain effect state indicators. | |
| Add a quality/debug toggle | Add visible control for quality/debug behavior in Demo. | |
| Other | Freeform UI change. | |

**User's choice:** No new controls/categories.
**Notes:** Existing controls become visually effective; category structure stays fixed.

### Question: What focused Demo smoke should Phase 6 require?

| Option | Description | Selected |
|--------|-------------|----------|
| Panel-path smoke across main domains | Manually or simulator-smoke Beauty, Face Shape, Eyes, Nose, Mouth, Filters/Presets enough to confirm visible update and no clipping/regression. | ✓ |
| Photo-only smoke | Use still image mode as the stable visual smoke path; Camera remains covered by automated pipeline tests. | |
| Camera-only smoke | Prioritize realtime preview feel; still image stays fixture-tested. | |
| Other | Freeform smoke scope. | |

**User's choice:** Panel-path smoke across main domains.
**Notes:** Smoke should cover visible updates and panel layout regressions.

---

## the agent's Discretion

- Concrete internal effect protocols, provider names, pass names, fixture assets, pixel-difference thresholds, metrics keys, and transient status copy.
- Pragmatic implementation mechanism for MVP visual evidence, provided SDK target boundaries and public facade rules hold.

## Deferred Ideas

None.
