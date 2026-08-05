# Pitfalls Research

**Domain:** Adding teeth whitening and sclera redness reduction to an existing local-first iOS beauty SDK
**Researched:** 2026-08-05
**Confidence:** HIGH for known mechanics/integration failures; MEDIUM for real-population calibration
**Execution note:** Completed inline because this Codex session exposed no GSD subagent dispatch tool.

## Critical Pitfalls

### Pitfall 1: Candidate Media Is Mistaken for an Open Product Gate

**What goes wrong:** A visible smile or red eye is treated as sufficient evidence, so production fields/providers are added before complete positive/negative review.

**Why it happens:** Authorization, target visibility, polarity, mask containment, and naturalness are collapsed into one informal judgment.

**How to avoid:** Require exact feature-specific grants, genuine positive and negative polarity, original/mask/after assets, frozen structured criteria, original-detail review, and a tracked sanitized decision before any route exists.

**Warning signs:** A ledger row references only `portrait_002`; missing negative; no mask/after digest; review criteria created after looking at output; candidate counts treated as accepted counts.

**Phase to address:** Suggested Phase 59 for teeth and Phase 62 for sclera.

---

### Pitfall 2: Vision Support Is Treated as a Semantic Mask

**What goes wrong:** The whole lip aperture becomes teeth or the whole eye aperture becomes sclera, editing gums, tongue, iris, lashes, or skin.

**Why it happens:** Landmark polygons are easy to rasterize and appear plausible on one fixture.

**How to avoid:** Use lips/eyes only as hard support envelopes; require target-specific color-qualified candidates, connected seeds for teeth, guarded pupil/iris/highlight exclusions for sclera, and post-filter hard re-clipping.

**Warning signs:** Mask equals polygon fill; no seed plausibility; no protected-tissue counts; no adversarial iris recolor test; feathering occurs after the last hard clip.

**Phase to address:** Suggested Phases 60 and 63.

---

### Pitfall 3: Native Color Hides Unsafe Sclera Geometry

**What goes wrong:** An unsafe mask overlaps the iris but tests pass because the dark native iris receives a low redness score.

**Why it happens:** Only final changed pixels on ordinary fixtures are measured.

**How to avoid:** Run both a color-independent open-gate geometry oracle and a final-output oracle that recolors protected iris pixels to sclera-like red before recomputing the real mask and transform.

**Warning signs:** Zero iris changes without an independent overlap count; no pupil/contour perturbation grid; no post-feather re-clip assertion.

**Phase to address:** Suggested Phases 63–64.

---

### Pitfall 4: Whitening Strength Replaces Mask Quality

**What goes wrong:** Weak global color shifts hide leakage in tests, while stronger user values visibly alter lips/skin or flatten enamel and eye texture.

**Why it happens:** Teams tune the transform before proving the selection boundary.

**How to avoid:** Freeze mask/protected-region acceptance independently from color transform; test maximum admitted strength; require zero outside-owned changes and natural texture/detail review.

**Warning signs:** Safety passes only at low strength; changed-pixel thresholds substitute for named protected regions; luminance clips near white; vessel/texture metrics vanish.

**Phase to address:** Suggested Phases 60–61 and 63–64.

---

### Pitfall 5: Independent Features Become Coupled

**What goes wrong:** Teeth and sclera share one field, gate, provider state, failure status, renderer row, or promotion decision; one failure disables the other or one success authorizes the other.

**Why it happens:** Both are local color edits and reuse one composition core.

**How to avoid:** Separate IDs, fields, admission flags, provider units, evidence rows, tests, output cases, and promotion records. Combine only after standalone completion.

**Warning signs:** Generic `localWhitening` name; one aggregate “eligible” Boolean; shared mask buffer; sclera code appears before teeth standalone closeout; combined tests are the only effect proof.

**Phase to address:** All phases; especially suggested Phases 59, 62, and 65.

---

### Pitfall 6: Feature Output Exists but Public Completion Is Unproven

**What goes wrong:** Unit tests show a private transform, but the public facade remains unrouted, defaults break compatibility, or renderer output is invisible/incorrect.

**Why it happens:** Internal algorithm completion is confused with SDK feature completion.

**How to avoid:** Require exact public field/normalization/Codable tests, production admission, isolated facade renderer case, strict decoded output, original-detail review, full regression, and owner-ledger equality before promotion.

**Warning signs:** Testing-only hook drives output; production admission remains `.none`; no exact inventory update; no public facade test; Demo row is enabled before SDK evidence.

**Phase to address:** Suggested Phases 61 and 64.

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
| --- | --- | --- | --- |
| Hardcode spike thresholds as product constants | Fast implementation | Unknown demographic, pose, lighting, and capture behavior | Only as explicit calibration seeds behind a closed evidence gate. |
| Keep exact-empty checker unchanged after activation | Avoid checker rewrite | New legitimate routes are either blocked or broadly allowlisted, weakening absence guarantees | Never; transition it to exact admitted-set validation. |
| Use one positive portrait and synthetic negatives | Easy evidence | Cannot prove abstention or naturalness on real already-normal input | Mechanics tests only; zero product weight. |
| Optimize fused full-frame CPU loop first | Appears efficient | Prior spike measured it slower than sparse sequential loops; obscures correctness | Never before profiling a verified implementation. |
| Track masks/output portraits | Reproducible review | Privacy, rights, and repository-history exposure | Never for portrait-derived evidence under current contract. |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
| --- | --- | --- |
| Vision | Run separate requests or use different orientation/color inputs per feature | One existing request over the same canonical `.up` image used by rendering. |
| Public parameters | Add both fields at once because both are planned | Add teeth only after teeth evidence; add sclera only after teeth closure and sclera evidence. |
| Composer | Sequentially apply teeth then sclera | Submit source-bound proposals; disjoint output matches standalone oracles; overlap retains source. |
| Demo taxonomy | Enable rows when fields compile | Keep rows disabled unless a separate Demo activation scope is approved. |
| Evidence export | Persist paths, digests of portraits, notes, or reviewer identity | Export only opaque IDs, fixed judgments/reasons, decisions, and aggregates. |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
| --- | --- | --- | --- |
| Per-request `CIContext` or model load | Cold latency and memory spikes | Reuse existing context; add no model in v1.15 | Large photos and repeated calls. |
| Full-frame mask growth/blur | CPU scales with entire image despite tiny ROIs | Establish reference semantics first, then profile bounded ROIs with byte-equivalence | Multi-megapixel portraits. |
| Duplicate Vision requests | Increased latency and detector drift | Share one request context | Every combined request. |
| Dense intermediate mask copies | Peak memory rises with image size and feature count | Bound allocations, use request-local lifetimes, and measure high-resolution cases | Large canonical RGBA8 inputs. |

## Security and Privacy Mistakes

| Mistake | Risk | Prevention |
| --- | --- | --- |
| Persist sclera vessel-like detail | Conjunctival vasculature has been studied as a biometric | Keep masks/detail request-local and diagnostics aggregate-only. |
| Log paths, raw errors, coordinates, or candidate pixels | Leaks portrait identity/context and implementation support | Typed payload-free errors and fixed allowlisted reason codes. |
| Cache masks or support across requests | Cross-user image leakage and stale edits | Strong request identity, no engine retention, repeated/parallel/reset tests. |
| Package unapproved learned weights | License and supply-chain exposure | Separate rights/checksum/resource audit before any model scope. |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
| --- | --- | --- |
| Already-white teeth get brighter | Artificial clipping and lost enamel detail | Yellow-excess-aware bounded change or no-op. |
| Eye whites become flat/blue | Porcelain appearance and identity/detail loss | Reduce only measured red excess and restore luminance/detail. |
| One eye changes while unsafe peer is guessed | Asymmetry or iris damage | Independent per-eye abstention and honest partial result. |
| Unsupported cases silently distort | Users cannot trust the SDK | Deterministic no-op/fail-closed behavior with privacy-safe aggregate outcome. |

## “Looks Done But Isn’t” Checklist

- [ ] **Teeth evidence:** A candidate exists but a genuine positive, negative, complete assets, and frozen review may still be missing.
- [ ] **Teeth algorithm:** A mask changes teeth but protected lips/gums/tongue/braces/skin and already-light negatives may be unverified.
- [ ] **Teeth product:** A provider exists but public field, production admission, facade output, compatibility, and ledger may still be absent.
- [ ] **Sclera evidence:** Visible redness exists but per-eye polarity, normal negatives, mask/after, and review may still be missing.
- [ ] **Sclera safety:** Native outputs look clean but color-independent and recolored-iris adversarial oracles may be absent.
- [ ] **Sclera product:** Both eyes work on one portrait but blink/gaze/glasses/highlights, independent failure, public output, and promotion may be unverified.
- [ ] **Combined closeout:** Standalone features pass but overlap, parallel/repeated/reset, full regression, privacy, and owner equality may still be open.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
| --- | --- | --- |
| Premature field/provider before evidence | MEDIUM | Revert the unadmitted surface, restore exact absence, complete the bundle, then replan. |
| Protected-region leakage | HIGH | Close admission, isolate provider/feather boundary, add adversarial oracle, recalibrate only on approved data. |
| Cross-request retention | HIGH | Disable feature route, remove shared state, add identity/lifecycle stress tests, rerun privacy review. |
| Overprocessed naturalness | MEDIUM | Reduce caps/transform, retain mask contract, repeat blinded positive/negative original-detail review. |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
| --- | --- | --- |
| Candidate mistaken for evidence | 59 / 62 | Exact grant/media/polarity/review/decision schema and zero borrowing. |
| Support treated as mask | 60 / 63 | Protected-region masks and hard post-filter containment. |
| Native color hides iris leak | 63 / 64 | Geometry-open and recolored-iris final-output grids. |
| Strength hides leakage | 60–61 / 63–64 | Maximum-strength outside/protected byte checks plus original-detail review. |
| Coupled features | 59–65 | Separate fields, units, evidence, output, promotion, and injected failure tests. |
| Internal-only completion | 61 / 64 | Public-facade output, exact inventory, full regression, ledger equality. |

## Sources

- [Apple: rightPupil](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/rightpupil) — pupil support may be inaccurate during blink.
- [Shape Constrained Network for Eye Segmentation in the Wild](https://openaccess.thecvf.com/content_WACV_2020/papers/Luo_Shape_Constrained_Network_for_Eye_Segmentation_in_the_Wild_WACV_2020_paper.pdf) — explicit eye-region segmentation remains shape-sensitive in unconstrained images.
- [A New Scale for the Assessment of Conjunctival Bulbar Redness](https://pmc.ncbi.nlm.nih.gov/articles/PMC6574084/) — region segmentation, calibrated imagery, and structured grading matter for redness assessment.
- [On the use of multispectral conjunctival vasculature as a soft biometric](https://www.cse.msu.edu/~rossarun/pubs/CrihalmeanuRossMSConjunctiva_WACV2011.pdf) — conjunctival vasculature has identifying potential.
- [Application of digital imaging in tooth whitening randomized controlled trials](https://pubmed.ncbi.nlm.nih.gov/19681252/) — controlled digital color measurement and reproducibility.
- Repository v1.14 audit, Spikes 002–013, and `spike-findings-beauty` references — observed leakage, performance, licensing, privacy, and evidence failures.

---
*Pitfalls research for: v1.15 independent teeth and sclera retouch*
*Researched: 2026-08-05*
