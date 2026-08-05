# Feature Research

**Domain:** Still-image cosmetic teeth whitening and guarded sclera redness reduction
**Researched:** 2026-08-05
**Confidence:** HIGH for repository contracts and safety mechanics; MEDIUM for product calibration until genuine bundles are reviewed
**Execution note:** Completed inline because this Codex session exposed no GSD subagent dispatch tool.

## Feature Landscape

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
| --- | --- | --- | --- |
| Independent positive-only public strength | Integrators need explicit, zero-default control and compatibility | MEDIUM | `teethWhitening` and `scleraRednessReduction` cannot alias global brightness, whitening, lip color, eye geometry, or one another. |
| Genuine positive and negative evidence | A cosmetic effect must improve the target and abstain on already-normal input | HIGH | Each feature needs its own rights-approved original/mask/after bundle, polarity, structured review, and decision. |
| Anatomical containment | Any edit to lip, gum, tongue, iris, pupil, highlight, lash, or skin is a visible defect | HIGH | Hard envelopes remain authoritative after growth/blur/feather. |
| Natural bounded color change | Users expect improvement without flat white enamel or porcelain eyes | HIGH | Teeth reduce yellowness with small luminance lift; sclera reduces measured red excess while retaining luminance and detail. |
| Local fail-closed behavior | Missing/unsafe support must not corrupt the image or disable unrelated eligible work | HIGH | Teeth abstains per mouth; sclera abstains per eye. |
| Public-facade output proof | A field/provider existing internally is not a completed feature | HIGH | Isolated output cases, strict decoded comparisons, original-detail review, and exact ledger promotion are required. |
| Compatibility and no-op neutrality | Existing hosts and presets must remain stable | MEDIUM | Append-only Codable/source behavior, default zero, unchanged legacy output, and exact inventory checks. |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
| --- | --- | --- | --- |
| Immutable-original composition | Combined effects cannot feed color changes into one another | MEDIUM | Every accepted output pixel derives from the canonical source under exactly one owner. |
| Collision-to-source safety | Unexpected provider overlap produces no hidden priority | MEDIUM | Preserve original pixel and report only an aggregate collision count. |
| Independent left/right eye failure | A blink, occlusion, or bad pupil on one side does not erase a safe peer-eye result | HIGH | Requires side-specific support, masks, diagnostics, and tests. |
| Adversarial protected-region oracles | Safety is proven even when native colors would hide bad geometry | HIGH | Sclera needs both color-independent geometry and recolored-iris final-output oracles. |
| Privacy-minimized evidence | Sensitive portrait-derived support never becomes public or durable | HIGH | Only opaque IDs, fixed judgments, reasons, and aggregates persist. |

### Anti-Features

| Feature | Why Requested | Why Problematic | Alternative |
| --- | --- | --- | --- |
| One slider that whitens teeth and eyes | Simpler surface | Couples unrelated anatomy, evidence, strength, failure, and promotion | Two independent fields and production slices. |
| Aggressive maximum whitening | Strong before/after effect | Flattens texture, clips highlights, shifts enamel/eye color, and over-processes negatives | Conservative cap plus target-specific measured color reduction. |
| Whole aperture selection | Easy mask | Includes protected tissue and relies on color to hide leaks | Seeded tooth candidates and guarded per-eye sclera envelopes. |
| Treating one candidate as proof | Faster launch | A visible target or authorization alone does not establish polarity, negatives, mask quality, or naturalness | Complete feature-specific bundles and frozen review criteria. |
| Model substitution | Broader masks | Adds unapproved licensing, package, performance, and opaque failure risk | Deterministic path; separately gate any future model comparator. |
| `去脂` proxy via warp/smoothing | Appears to close another row | Changes eye/brow/aperture/identity and violates the named product semantics | Keep `去脂` future until a credible non-warp design and evidence exist. |

## Feature Dependencies

```text
v1.14 canonical request + request-local support + original-pixel composer
    ├──requires──> teeth evidence decision
    │                  └──requires──> teeth field/provider/output/safety/promotion
    └──requires──> sclera evidence decision
                       └──requires──> per-eye field/provider/output/safety/promotion

completed teeth slice ──precedes──> start of production sclera slice
teeth evidence ──must-not-authorize──> sclera
sclera evidence ──must-not-authorize──> teeth
either feature ──must-not-authorize──> 去脂
```

### Dependency Notes

- **Production work requires its own evidence decision:** candidate authorization is context, not eligibility.
- **Teeth precedes sclera by user choice:** close and verify the teeth slice before creating the sclera production field/provider route.
- **Combined closeout requires both standalone slices:** combined requests may be tested only after each standalone feature independently passes.
- **Branch promotion differs:** qualified `白牙` can close the remaining `嘴唇` taxonomy row; `祛红血丝` alone cannot close `眼睛` while `去脂` remains future.

## v1.15 Definition

### Launch With

- [ ] A rights-approved genuine yellow/discolored-teeth positive and already-light/negative review bundle.
- [ ] Independent `teethWhitening` public field, provider, bounded transform, public-facade output, safety matrix, and exact row promotion.
- [ ] A separate rights-approved genuine sclera-redness positive and normal-sclera negative review bundle.
- [ ] Independent `scleraRednessReduction` field, per-eye provider, bounded transform, public-facade output, adversarial safety matrix, and exact row promotion.
- [ ] Combined teeth+sclera regression preserving standalone equivalence, collision-to-source, request privacy, compatibility, and shipped effects.

### Add After Validation

- [ ] Optimized ROI/Metal implementation — only if device profiling finds the deterministic path over an approved budget.
- [ ] Demo activation and presets — only after a separate UI/product contract.
- [ ] Transparent/HDR/multi-face support — only after explicit input and ownership contracts.

### Future Consideration

- [ ] `去脂` — requires genuine upper-eyelid-fullness evidence and a credible non-warp design.
- [ ] Realtime/pixel-buffer local retouch — requires temporal state, latency, memory, backpressure, and device evidence.
- [ ] Learned segmentation — requires complete rights/resource/performance/superiority approval.

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
| --- | --- | --- | --- |
| Teeth evidence + production slice | HIGH | HIGH | P1 |
| Teeth standalone safety/output/promotion | HIGH | HIGH | P1 |
| Sclera evidence + per-eye production slice | HIGH | HIGH | P1 after teeth |
| Sclera standalone safety/output/promotion | HIGH | HIGH | P1 after teeth |
| Combined closeout | HIGH | MEDIUM | P1 |
| `去脂` | MEDIUM | VERY HIGH / unresolved | P3 |
| Demo/realtime/model expansion | MEDIUM | HIGH | P3 |

## Product-Evidence Analysis

| Concern | Research Signal | v1.15 Approach |
| --- | --- | --- |
| Tooth color improvement | Clinical digital-imaging studies quantify whitening through increased lightness and reduced yellowness in calibrated CIELAB terms | Use yellow-excess/luminance metrics only as bounded internal evidence; final acceptance still requires natural original-detail review on real portraits. |
| Perceptible but natural whitening | Psychophysical research identifies perceptibility thresholds and dentistry-specific whiteness indices | Avoid “maximum white”; predeclare bounded change and compare positives with already-light negatives. |
| Eye-redness grading | Digital bulbar-redness research uses segmented conjunctival regions and calibrated/structured grading | Evaluate per-eye target presence and bounded reduction, not global face redness or whole-eye whiteness. |
| Eye segmentation in the wild | Research shows explicit iris/sclera segmentation is a difficult shape-constrained task | Retain conservative Vision-supported guards, fail closed under uncertainty, and do not claim complete sclera segmentation. |

## Sources

- [Apple Vision face-landmark regions](https://developer.apple.com/documentation/vision/analyzing-a-selfie-and-visualizing-its-content) — available eye, pupil, inner-lip, and outer-lip support.
- [Application of digital imaging in tooth whitening randomized controlled trials](https://pubmed.ncbi.nlm.nih.gov/19681252/) — repeatable digital L*, a*, b* measurement under controlled acquisition.
- [Development of a customized whiteness index for dentistry](https://pubmed.ncbi.nlm.nih.gov/26778404/) — perceived dental whiteness depends on lightness and chromatic axes, not brightness alone.
- [Investigation of perceptual thresholds of tooth whiteness](https://pubmed.ncbi.nlm.nih.gov/29233258/) — perceptibility and naturalness need observer-based bounds.
- [A New Scale for the Assessment of Conjunctival Bulbar Redness](https://pmc.ncbi.nlm.nih.gov/articles/PMC6574084/) — digital, region-specific, structured redness grading and reproducibility.
- [Shape Constrained Network for Eye Segmentation in the Wild](https://openaccess.thecvf.com/content_WACV_2020/papers/Luo_Shape_Constrained_Network_for_Eye_Segmentation_in_the_Wild_WACV_2020_paper.pdf) — sclera/iris segmentation is an explicit shape-sensitive problem rather than a simple whole-eye threshold.
- Repository `spike-findings-beauty` and v1.14 evidence/audit — deterministic mechanics, privacy, and promotion boundaries.

---
*Feature research for: v1.15 independent teeth and sclera retouch*
*Researched: 2026-08-05*
