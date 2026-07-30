# Feature Research

**Domain:** Beauty v1.14 still-image local facial retouch (`白牙`, `祛红血丝`, conditional `去脂`)
**Researched:** 2026-07-30
**Confidence:** HIGH for scope, safety boundaries, and mechanics; MEDIUM for product feasibility until feature-specific rights-approved bundles pass review

## Research Conclusion

The minimum credible milestone is not an all-or-nothing three-feature launch. Build one reusable still-image local-retouch foundation, then promote `白牙` and `祛红血丝` through independent product-evidence gates. Each may ship if the other fails. Treat `去脂` as a conditional third slice: it may enter the public contract only after genuine upper-eyelid-fullness positives and negatives validate an independent non-warp method. If that gate does not pass, leave the row `future` and the `眼睛` branch `partial`.

The thirteen spikes establish useful mechanics, not product readiness. AI-generated fixtures can prove containment code, fail-closed behavior, composition invariants, and adversarial safety oracles. They cannot prove target recognition, useful coverage, naturalness, or demographic robustness. Product promotion requires a complete rights-approved positive/negative bundle for the exact feature, frozen acceptance rules, public-facade saved output, and blinded original/mask/after review at 100% detail.

The sole current rights-approved portrait is useful for exposed-smile teeth containment and for checking that already-light teeth are not over-whitened. It is not a yellow/gray-teeth positive. It has no established sclera-redness or upper-eyelid-fullness polarity. It therefore cannot open any feature's product gate by itself.

## Feature Landscape

### Shared Table Stakes

| ID | Feature | User / Host Expectation | Complexity | Requirement-ready behavior |
| --- | --- | --- | --- | --- |
| TS-01 | Independent, conservative controls | A host can request only the intended local correction without changing unrelated facial geometry or global color. | MEDIUM | Use independent positive-only, default-zero semantics. Recommended neutral names are `teethWhitening`, `scleraRednessReduction`, and conditionally `upperEyelidFullnessReduction`; final names belong to the public contract. No field aliases a shipped parameter. |
| TS-02 | Default and legacy neutrality | Existing integrations, payloads, and presets retain their exact prior output unless a new field is explicitly nonzero. | MEDIUM | Legacy 59-field data decodes with admitted new fields at zero; new fields clamp to their documented range and map non-finite values to zero. Default processing remains copy/render-neutral. The exact stored-field inventory is conditional on which feature gates pass. |
| TS-03 | Honest still-image scope | A host can tell when a requested retouch was not applied; realtime must not pretend to support it. | MEDIUM | Support the ordinary public still-image facade only. A nonzero local-retouch field on pixel-buffer/realtime input is a safe no-op with an aggregate unsupported-path reason while eligible shipped effects continue. No UI or realtime behavior is implied. |
| TS-04 | Canonical input | The edited pixels align with the anatomy that was analyzed. | HIGH | Normalize orientation and color representation once, then give the same canonical pixels to Vision and rendering. Reject transparent local-retouch inputs before Vision/mask creation until an explicit compositing policy exists. Preserve output extent/orientation contract. |
| TS-05 | Selected-face consistency | Retouch applies to the same deterministic selected face used by the existing facade. | MEDIUM | Run one selected-face Vision landmark request and share its request-local context. Do not add silent multi-face selection or apply a feature to a different face. |
| TS-06 | Region-local failure | Missing or unreliable support never produces guessed edits or suppresses unrelated valid work. | HIGH | Fail closed per feature, mouth region, eyelid band, or eye. An invalid left eye must not disable an eligible right eye; an invalid teeth mask must not suppress eligible sclera or shipped global effects. |
| TS-07 | Original-pixel composition | Combining local retouches must not amplify prior edits, broaden masks, or become order-dependent. | HIGH | Derive every accepted feature result from the original canonical pixel. Use one explicit owner for every local mask. Reject the affected local edit on an unexpected ownership collision; do not silently blend competing derived pixels. |
| TS-08 | Natural protected regions | Users see a subtle correction, not painted teeth, pink/gray eyes, erased eyelids, or altered identity. | HIGH | Enforce hard anatomical envelopes, bounded color/tone transforms, post-feather re-clipping, zero outside-mask change, and feature-specific protected-region review. High input strength remains bounded by a calibrated naturalness cap. |
| TS-09 | Private transient support | Portrait-derived anatomy does not leak through API, storage, logs, or evidence exports. | MEDIUM | Teeth/sclera/eyelid masks, landmarks, pupils, vein-like structure, coordinates, heatmaps, tensors, and asset paths remain request-local. Public and persisted diagnostics contain fixed reason codes and aggregates only. |
| TS-10 | Evidence-backed promotion | A visible effect is not called implemented from parameter plumbing, provider output, or mechanics fixtures alone. | HIGH | Require public-facade same-dimension output, deterministic safety tests, complete rights-approved positive/negative bundles, local blinded original-detail review, regression/privacy gates, synchronized ledgers, and independent milestone audit. |

### Per-Feature Table Stakes

| Feature | User-visible behavior | SDK-visible behavior | Fail-closed / protected behavior | Complexity |
| --- | --- | --- | --- | --- |
| `白牙` / teeth whitening | On genuinely discolored visible teeth, reduce yellow excess and lift luminance conservatively while retaining tooth shading, edges, texture, and believable shade variation. Already-light teeth must not become flat, blue, gray, clipped, or fluorescent. | One independent positive-only field; zero is exact neutral. Nonzero still-image requests use validated inner/outer-lip support and an accepted teeth mask. Output remains same-dimension and deterministic. | Closed mouth, no face, missing seeds/landmarks, implausible mouth/candidate area, or occlusion produces a local no-op. Lips, tongue, gums, braces, facial hair, skin, and mouth exterior remain unchanged. Fixed safe seed coverage may not be dropped by adaptive growth. | HIGH |
| `祛红血丝` / sclera redness reduction | On an eye with genuine visible sclera redness, reduce only measured red excess while preserving original luminance, natural vessels/detail, and the unedited appearance of iris, pupil, lashes, skin, and highlights. Clear sclera must not be whitened merely because strength is nonzero. | One independent positive-only field; zero is exact neutral. Validate and process left/right eyes independently from the shared request. Report aggregate applied/skipped-eye counts and fixed reason categories only. | No face, missing/inaccurate pupil, malformed/collapsed contour, blink, closure, occlusion, pupil outside aperture, or failed guard produces a per-eye no-op. Re-clip after feathering. Both geometric and adversarial final-output oracles must show zero protected iris/highlight changes. | HIGH |
| `去脂` / upper-eyelid fullness reduction | On a genuine positive, subtly reduce the appearance of fullness in the band between upper eye contour and eyebrow while preserving eye/brow position, eyelid crease, skin texture, identity, and RGB geometry. On a non-positive, produce no visible change. | A distinct positive-only field may be added only after the promotion gate passes. It must use an independently named non-warp provider and expose only aggregate applied/skipped reasons. | Missing paired eye/eyebrow support, implausible or too-small band, blink/closure, occlusion, or low-confidence support produces a local no-op. Never forward to `eyeHeight`, `upperEyelidLift`, brow movement, eye opening, global smoothing, eye-bag, or dark-circle behavior. | VERY HIGH / BLOCKED |

## Evidence Classification

### Evidence Classes and What They Prove

| Class | Required inputs | Can prove | Cannot prove |
| --- | --- | --- | --- |
| M — mechanics | Synthetic/AI or real local fixtures; deterministic tests | Mask construction executes, output is bounded, invariants hold, failures are isolated, original-pixel composition works. | Product target presence, useful population coverage, naturalness, demographic robustness, or commercial readiness. |
| S — safety/adversarial | Perturbed request-local geometry, deliberately opened score gates, protected-region truth, byte-level final-output checks | A bounded implementation resists the enumerated perturbations and keeps protected pixels unchanged within that tested grid. | Real target coverage, guard calibration, or product effectiveness outside the grid. |
| P+ — product positive | Rights-approved real fixture with the exact target visibly present, complete original/mask/after assets, approved manifest polarity, and 100%-detail review | The effect finds and improves its intended condition on the reviewed fixture without unacceptable collateral change. | General population readiness from one subject or one capture condition. |
| P- — product negative/control | Rights-approved real fixture where the target is absent or support is deliberately challenging, complete assets, nonzero requested strength, and 100%-detail review | The effect abstains or remains natural when it should not modify; protected anatomy and unsupported cases remain safe. | Positive effectiveness. |
| C — compatibility/regression | Legacy payloads/presets, default and combined parameter matrices, no-face and existing fixtures | Public contract neutrality, exact default behavior, safe sibling continuation, deterministic facade behavior, and absence of regressions. | Product naturalness or target validity. |
| R — release/commercial | Device, performance, packaging, distribution, broad visual review | Only the separately tested release dimension. | Not part of v1.14 feature promotion. |

Mechanics and safety evidence are necessary but never substitute for both P+ and P-. A rights-approved fixture is not automatically P+ or P-: its feature and polarity must be declared before review, target presence must agree with that declaration, and its asset/rights bundle must be complete.

### Current Evidence Status

| Feature | Current evidence | Correct classification | Promotion consequence |
| --- | --- | --- | --- |
| Teeth | Fixed and seeded adaptive masks improved AI-fixture coverage while dropping no strong baseline pixels and changing no pixels outside the mask. The current approved portrait exposes a smile with already-light teeth. | Adaptive result is M only. The approved portrait is a prospective P- containment/over-whitening control only after it is placed in a complete approved bundle and reviewed; it is not P+. | Product gate remains closed until genuine discoloration P+ and complete protected-tissue P- coverage pass. |
| Sclera | Guard-before-score, post-feather re-clip, and dual oracles produced zero protected changes over bounded native/adversarial grids, with substantial fail-closed behavior. | Guard/composition result is narrowly S/M. It proves the tested safety mechanism, not useful real redness coverage. The current approved portrait has no established polarity. | Product gate remains closed until real redness P+ and calibrated open/partial/blink/gaze P- bundles pass. |
| Upper eyelid | Tone/frequency mechanics retained texture and zero mask leakage on AI fixtures. Tested interior vertical warp reduced texture without clearer semantic benefit. | Tone/frequency path is M/PARTIAL. Warp is INVALIDATED. Neither is P+. Current approved portrait has no established polarity. | Do not add/promote the field until an independent non-warp method passes real P+ and P-. Otherwise keep `去脂` future. |

### Product-Evidence Bundle Gate

Every feature is evaluated separately. A feature's gate opens only when all of the following are true:

1. Every selected fixture is `approved_internal_evaluation`, has an opaque ID and rights-record ID, declares exactly one supported feature and `positive` or `negative` polarity, and includes complete original/mask/after assets.
2. The bundle contains at least one genuine P+ and one P-. Synthetic and `mechanics_only` items are excluded from product aggregates even if their schema is valid.
3. Feature acceptance rules are frozen before reviewers inspect outputs. Review remains local, blinded, and at original 100% detail.
4. Every positive review confirms target presence; every negative confirms the declared absence/challenge condition. Misclassified items are rejected from that gate rather than relabeled after seeing the output.
5. Hard safety passes on every reviewed item: no protected leakage, no structure change, no outside-mask change, no extent/orientation shift, and no forbidden proxy behavior.
6. Positive items receive acceptable mask coverage and naturalness; negative items abstain or remain visually neutral. The recommended initial bar is coverage and naturalness at least 4/5 on every accepted item, with an explicit accept decision and no hard-safety failure. Freeze any different bar before review.
7. Persistent export contains only opaque fixture ID, feature, polarity, structured judgments, fixed reason code, decision, and aggregates. It contains no media, filenames, paths, rights/documentation records, raw geometry, or freeform reviewer text.
8. Fixture count and composition are reported with limitations. Passing this gate supports SDK-core feature promotion only, not demographic, commercial, device, packaging, or release-readiness claims.

### Feature-Specific Positive and Negative Evidence

| Feature | Genuine P+ (effectiveness) | Required P- / challenge controls | Original-detail acceptance focus |
| --- | --- | --- | --- |
| Teeth | Rights-approved real smiles with visible natural yellow/gray discoloration; include central and darker side teeth, wide and small apertures, and varied lighting/skin tone. Permission plus visible teeth is insufficient if teeth are already light. | Already-light teeth; lips, tongue, gum, braces, occlusion, facial hair; closed mouth; no face; blur/compression; pose. The current approved exposed smile may cover the already-light containment case, not the full negative matrix. | Teeth-only mask containment; side-tooth inclusion; preserved enamel shading/edges; no lip/tongue/gum/braces change; no clipped, blue, gray, fluorescent, or uniformly painted result; safe no-op where no qualified tooth pixels exist. |
| Sclera | Rights-approved real eyes with mild and severe visible redness and vessel variation, including useful open-eye sclera. Color-adversarial recoloring is not a P+. | Clear/low-redness sclera; partial closure and blink; gaze changes; glasses/contacts; blue/brown irises; strong highlights; makeup/lashes; occlusion, pose, low light, blur/compression. Include cases where one eye is valid and the peer is not. | Useful redness reduction without porcelain-white sclera; preserved iris/pupil/highlights/lashes/skin; natural luminance and remaining detail; no peer-eye coupling; expected abstention on invalid eyes. |
| Upper eyelid | Rights-approved real portraits where a reviewer can confirm genuine upper-eyelid fullness before processing, across multiple skin tones, lighting conditions, and crease types, with sufficient eye-to-brow support. | No target fullness across eyelid crease types; makeup; blink/closure; glasses; side pose; expression; occlusion; small/implausible eye-brow gap. | Reduced fullness without moving eye/brow, changing aperture, erasing crease/texture, smoothing globally, treating eye bags/dark circles, or changing identity. RGB geometry must remain exact for the tone/frequency approach. |

## Differentiators

| Feature | Value Proposition | Complexity | Notes |
| --- | --- | --- | --- |
| Independent feature promotion | Teeth and redness can deliver value without forcing an unproven eyelid feature into the release. | LOW | Requirements and roadmap must retain separate evidence gates, fields, ledger updates, and ship/no-ship decisions. |
| Fail-closed at the smallest anatomical unit | Unsafe or missing support affects only the mouth region, eyelid band, or individual eye; safe sibling work continues. | HIGH | Especially valuable for blink/occlusion and one-eye-only validity. |
| Original-pixel, single-owner composition | Multiple local edits remain deterministic, bounded, and insensitive to execution order. | HIGH | Each feature proposes a result from original pixels; ownership collision is explicit and conservative. |
| Adversarial protected-region oracles | Safety is tested even when native colors would hide geometric leakage. | HIGH | Required for sclera; the same philosophy should cover teeth protected tissue and eyelid geometry invariance. |
| Evidence-honest SDK completion | Product readiness requires rights/polarity, facade output, and 100%-detail human review rather than screenshot presence or mechanics success. | MEDIUM | Preserves trust in `implemented` ledger status and keeps claims narrow. |
| Privacy-preserving evaluation | Local review supports auditable product evidence without persisting biometric-like masks or asset identifiers. | MEDIUM | Vessel-like sclera structure receives the strictest handling. |

## Anti-Features

| Anti-Feature | Why It May Be Requested | Why It Is Problematic | Required Alternative |
| --- | --- | --- | --- |
| All-or-nothing three-feature milestone | A single branch-closeout story looks simpler. | It pressures `去脂` into proxy behavior and blocks independently valid teeth/redness value. | Ship each evidence-qualified feature independently; close `眼睛` only if both eye rows pass. |
| `去脂` implemented by eye/brow warp or smoothing | Existing geometry controls are readily available. | It changes a different semantic, can alter identity/eye aperture, and the tested warp worsened texture without proving fullness reduction. | Retain only a separately validated non-warp tone/frequency or future approved semantic method. |
| Whole-mouth or lip-polygon whitening | It maximizes apparent tooth coverage. | `innerLips`/`outerLips` are aperture support, not tooth labels; lip, tongue, and gum leakage is likely. | Seeded teeth candidates inside a narrow hard envelope, with protected-tissue review. |
| Global face desaturation/brightening | It produces an obvious before/after quickly. | It changes skin/lips and misrepresents local tooth correction. | Apply a bounded yellow/luminance transform only under an accepted teeth mask. |
| Whole-eye whitening or global red suppression | It makes sclera look brighter on simple fixtures. | It can alter iris, highlights, skin, and normal anatomy and may hide an unsafe mask behind a dark native iris. | Guard each eye before scoring, protect iris/highlights explicitly, feather then re-clip, and run dual oracles. |
| Coverage-at-any-cost threshold relaxation | More selected pixels can look like better recall. | It defeats fail-closed geometry and increases protected leakage. | Preserve strict plausibility/guard gates; report abstention and calibrate with real P+/P-. |
| Synthetic fixtures labeled product evidence | They are easy to generate and reproduce. | They do not establish real target polarity, naturalness, or population behavior. | Use them only for M/S; require rights-approved real P+/P- for promotion. |
| Hidden or unlicensed Core ML dependency | A learned mask may look broader in a demo. | The audited candidate lacks an approved data/checkpoint/conversion/redistribution chain and has cold-start/memory risk. | Keep deterministic Apple Vision/color path; admit a model only after independent license, packaging, resource, and superiority gates. |
| Raw visual diagnostics or tracked portrait media | They simplify debugging and galleries. | Masks, pupils, vein patterns, landmarks, paths, and portrait media are sensitive and exceed the current repository/privacy contract. | Use request-local support, disposable ignored outputs, structured redacted exports, and aggregate diagnostics. |
| Realtime, Demo UI, cloud, or commercial scope | Users may expect parity across all product surfaces. | None is supported by the spike evidence and each adds distinct performance, UX, privacy, or release obligations. | Keep v1.14 SDK-SPM-only and still-image-only; plan later milestones separately. |
| Transparent, HDR/gain-map, or silent multi-face expansion | Broad input support appears convenient. | Current alignment/compositing and selection contracts are not proven for these modes. | Reject transparent local-retouch input and retain existing selected-face semantics; defer other modes to explicit policies. |

## Feature Dependencies

```text
Compatibility-safe public semantics
    └──requires──> canonical opaque still-image input
                         └──requires──> one selected-face Vision context
                                              └──requires──> request-local support providers

Teeth product gate ──requires──> teeth mask + bounded transform + P+/P- bundle
Sclera product gate ──requires──> per-eye guard + dual oracles + P+/P- bundle
Upper-eyelid product gate ──requires──> genuine P+ acquisition + independent non-warp path + P-/detail review

All admitted local features
    └──require──> original-pixel composition + single mask ownership
                     + public-facade output + compatibility/privacy/regression gates

Teeth gate PASS ──permits──> `白牙` implemented and branch `嘴唇` closeout
Redness gate PASS alone ──permits──> `祛红血丝` implemented; branch `眼睛` stays partial
Redness PASS + Upper-eyelid PASS ──permits──> branch `眼睛` closeout
Upper-eyelid gate FAIL ──requires──> no public proxy; `去脂` remains future
```

### Dependency Notes

- **Foundation before visible features:** Canonical input, selected-face reuse, request-local ownership, original-pixel composition, and redaction are shared prerequisites; feature calibration cannot repair a misaligned or multiply-owned base.
- **Teeth and sclera are peer slices:** They share infrastructure but not target evidence, mask acceptance, transforms, or promotion decisions. Neither gate may borrow the other's fixture pass.
- **Upper eyelid is acquisition-first:** Planning implementation before genuine positives risks optimizing a proxy. Acquire/classify the rights-approved bundle, freeze review criteria, then decide whether the tone/frequency path merits production work.
- **Branch status follows exact rows:** Teeth can close `嘴唇` because its other rows are implemented. `眼睛` closes only if both `祛红血丝` and `去脂` become implemented; otherwise it stays partial.

## Milestone MVP Definition

### Launch With (Independently Gated v1.14 Slice)

- [ ] Shared still-image local-retouch foundation — canonical input, one selected-face request, request-local masks, original-pixel composition, single ownership, local failure isolation, aggregate diagnostics, and transparent-input rejection.
- [ ] Compatibility and zero-default contract — legacy source/JSON/preset neutrality plus exact admitted-field inventory and combined-regression evidence.
- [ ] `白牙` if and only if its own P+/P-, containment, naturalness, public-output, privacy, and audit gates pass.
- [ ] `祛红血丝` if and only if its own P+/P-, per-eye calibration, dual-oracle, naturalness, public-output, privacy, and audit gates pass.
- [ ] Honest partial release — failure of either peer feature does not invalidate a passing sibling; documentation and ledger status must match the exact admitted set.

### Conditional in v1.14

- [ ] `去脂` only after genuine positive/negative evidence exists and an independent non-warp method passes hard geometry/detail and naturalness review.
- [ ] `眼睛` branch closeout only when both `祛红血丝` and `去脂` are independently implemented.
- [ ] `嘴唇` branch closeout when `白牙` is independently implemented.

### Future Consideration

- [ ] Realtime/pixel-buffer local retouch — requires a separate frame-state, latency, backpressure, device, and temporal-stability contract.
- [ ] Transparent/HDR/gain-map local retouch — requires explicit composite/color policies and alignment evidence.
- [ ] Multi-face local retouch or per-face parameters — requires an explicit selection and ownership UX/API.
- [ ] Learned segmentation — only with owned/licensed data and weights, pinned redistribution terms, package/resource review, and measured superiority over the deterministic path.
- [ ] Demo controls, presets, screenshots, commercial naturalness, device performance, packaging, shipping, and launch readiness — separate scopes, not consequences of SDK-core promotion.

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Evidence Risk | Priority |
| --- | --- | --- | --- | --- |
| Shared local-retouch foundation | HIGH | HIGH | MEDIUM | P1 |
| Rights-approved evaluation gate and original-detail review | HIGH | MEDIUM | HIGH (fixture acquisition) | P1 |
| Teeth whitening | HIGH | HIGH | MEDIUM-HIGH | P1, independently gated |
| Sclera redness reduction | HIGH | HIGH | HIGH (coverage/guard calibration) | P1, independently gated |
| Upper-eyelid fullness reduction | MEDIUM-HIGH | VERY HIGH | VERY HIGH / currently blocked | P2, conditional |
| Realtime/UI/model/input expansions | OUT OF SCOPE | VERY HIGH | HIGH | P3 / future |

**Priority key:** P1 is required for the evidence-qualified v1.14 slice; P2 advances only when its explicit prerequisite passes; P3 is deferred beyond this milestone.

## Requirement Seeds for Roadmap

| Category | Requirement seed | Verification shape |
| --- | --- | --- |
| Contract | Each admitted feature has one independent positive-only default-zero public field and no alias to existing geometry/color controls. | Compile/source contract tests, normalization/Codable equality, exact legacy payload and preset bytes, unequal-value round trips. |
| Path | Nonzero admitted fields activate only the public still-image local-retouch path; realtime is an honest safe no-op and transparent input rejects before analysis. | Facade integration tests with aggregate reason codes and proof that safe shipped siblings continue. |
| Teeth | Qualified positive teeth visibly improve; fixed safe seeds are retained; protected oral tissue and already-light teeth remain natural. | Deterministic mask/transform gates plus rights-approved P+/P- original-detail review. |
| Sclera | Qualified red excess reduces per eligible eye; iris/pupil/highlights/skin remain byte-unchanged; invalid peer eyes fail locally. | Guard calibration matrix, color-independent envelope oracle, adversarial final-output oracle, and rights-approved P+/P- review. |
| Upper eyelid | Promotion requires genuine target presence and a distinct non-warp transform that preserves geometry, crease, texture, and identity. | Rights-approved acquisition gate first; exact geometry invariance, texture/tone metrics, P+/P- review; otherwise absence of field/runtime route. |
| Composition | Every accepted local edit derives from original canonical pixels under exactly one mask owner; unexpected overlap fails closed. | Order-permutation equality, overlap adversarial tests, zero outside-owned-mask change, combined-feature facade output. |
| Evidence | No M/S fixture contributes to P+/P- aggregates; acceptance is frozen before blinded local 100%-detail review. | Manifest/schema validation, gate-closed negative tests, sanitized structured export, review inventory bijection. |
| Privacy | Raw portrait-derived support and asset identity never enters public/persisted diagnostics or tracked outputs. | Static scans, diagnostic schema tests, repeated/parallel request-isolation tests, ignored/disposable artifact checks. |
| Promotion | Tool and branch ledgers reflect only independently passed feature gates; no broader device/commercial/release claim is inferred. | Exact owner-document diff plus independent milestone audit. |

## Sources

- `.planning/PROJECT.md` — authoritative v1.14 goal, scope, current fixture limitations, staged shipping decision, and out-of-scope boundaries.
- `PRODUCT_SENSE.md` — SDK user journeys, natural-first/default-neutral/degrade-visibly principles, and prior feature-promotion precedent.
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` — exact `去脂`, `祛红血丝`, and `白牙` taxonomy rows and branch status rules.
- `.codex/skills/spike-findings-beauty/SKILL.md` — consolidated spike requirements and mechanics-versus-product evidence boundary.
- `.codex/skills/spike-findings-beauty/references/teeth-whitening.md` — teeth support, transform, failure, protected-tissue, licensing, and fixture requirements.
- `.codex/skills/spike-findings-beauty/references/sclera-redness.md` — per-eye guard, post-feather clip, dual safety oracles, privacy, and calibration requirements.
- `.codex/skills/spike-findings-beauty/references/upper-eyelid-fullness.md` — exact semantic, non-proxy rule, partial tone/frequency path, invalidated warp, and real-positive gate.
- `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md` — rights/polarity/asset gate, blinded review fields, and sanitized export contract.

---
*Feature research for: Beauty v1.14 Local Facial Retouch*
