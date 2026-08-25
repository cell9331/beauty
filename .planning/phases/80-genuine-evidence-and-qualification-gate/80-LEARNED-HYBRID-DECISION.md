---
phase: 80
decision: learned-bounded-hybrid-upper-eyelid-editor
status: adopted-for-implementation
date: 2026-08-25
public_surface: unchanged-61-5-74
implementation_gate: actual-use-approved-owner-local-paired-training-data
---

# Upper-Eyelid Fullness Reduction: Implementable Technical Decision

## 0. Executive decision / 决策摘要

`去脂` is a cosmetic visual effect that makes a genuinely full or puffy upper
eyelid look flatter and less bulky. It is not eye opening, upper-lid lifting,
brow movement, eye-bag removal, dark-circle correction, regional darkening, or
skin smoothing. The effect is a visual simulation only; it does not estimate
fat, diagnose anatomy, or represent a medical procedure.

Candidates v1 through v4 establish that the current hand-authored
tone/frequency route is not a viable product solution:

- v1 introduced a rectangular dark block and weak target semantics;
- v2 failed real-image boundary and texture gates;
- v3 passed automated safety but a genuine positive review saw no meaningful
  fullness reduction;
- v4 failed repeatably before review: it edited two negatives, overshot one
  positive, and produced a maximum adjacent jump of `13` against the frozen
  maximum of `5`.

These are not tuning misses. A single RGB portrait does not let fixed
brightness/convexity thresholds reliably separate upper-lid volume from
lighting, makeup, crease shape, skin texture, and camera processing. More
threshold tuning would overfit the current private fixtures and is rejected.

The adopted implementation direction is a **small, on-device, per-eye learned
hybrid editor trained only from owned data or data explicitly licensed for the
actual owner-only use**. Research-only inputs and their derived model stay in a
separated non-commercial local research lane. Apple Vision
may locate and normalize the eye/brow crop, but it
does not decide whether upper-lid fullness exists. The model predicts:

1. applicability confidence plus uncertainty;
2. a soft target-support alpha;
3. a bounded smooth upper-lid soft-tissue displacement field; and
4. a bounded low-frequency log-luminance residual.

The runtime warps the immutable source texture with the learned field and then
applies the low-frequency shading residual. It never generates a replacement
face or unconstrained RGB patch. Eye aperture, lash margin, iris, pupil,
sclera, brow, protected crease detail, alpha, and pixels outside the admitted
support remain source-owned.

This decision creates an explicit distinction:

- If the project keeps an absolute no-geometry contract, the honest product is
  only `upperEyelidReliefSoftening`, a subtle tone effect; it must not be named
  or promoted as `去脂`.
- For the requested visibly obvious `去脂`, the project adopts a narrow
  exception for a learned, bounded upper-lid soft-tissue displacement field.
  Generic warp, landmark-driven warp, eye opening, eye-contour movement, and
  brow movement remain prohibited.

The existing v1-v4 code is experimental mechanics only. It must not receive a
candidate-v5 threshold retune, public route, or efficacy claim. The first code
remediation after this document is frozen is to quarantine the failed
heuristic as non-production and establish the learned-model boundary. Actual
model training starts only after the paired-data, exact-target, and actual-use
license gate below is satisfied. The SDK, model, and compiled weights never
leave the owner-controlled environment.

## 1. Why this is the correct semantic target

Clinical descriptions are used only to disambiguate the visible anatomy, not
to create a medical claim. The American Society of Plastic Surgeons describes
upper-eyelid correction as involving excess skin and protruding or repositioned
fat, with a smoother and better-defined eyelid as the visible result. That
supports the product distinction: true fullness reduction changes perceived
soft-tissue contour, not merely pixel darkness. See the
[ASPS procedure overview](https://www.plasticsurgery.org/cosmetic-procedures/eyelid-surgery/procedure).

Product-positive rows therefore need all of the following:

- clearly visible pre-existing upper-eyelid fullness in at least one eye;
- a flatter, less bulky upper-lid result at active strength;
- no larger eye opening, brow lift, new crease, eye-bag/dark-circle treatment,
  or unrelated skin retouch;
- retained identity, skin texture, lash detail, gaze, and natural asymmetry.

Negative and stress rows include naturally flat lids, deep or multiple creases,
hooded anatomy without the target fullness, strong directional lighting,
makeup edges, glasses, hair/hand occlusion, blink or squint, low resolution,
motion blur, extreme pose, and ambiguous crops. A safe no-op is the correct
result whenever support or applicability is uncertain.

## 2. Evidence behind the architecture decision

Apple Vision exposes eye, eyebrow, and pupil landmark regions through
[`VNFaceLandmarks2D`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d).
It exposes no upper-eyelid-fullness semantic. Vision is therefore a crop and
hard-containment owner only.

Large-scale face and portrait retouching work learns the mapping from paired
original/retouched data rather than fixed local brightness rules. AutoRetouch
uses large professional before/after collections and a local-receptive-field
network to retain detail; PPR10K provides 11,161 portraits, expert retouches,
and human-region masks. These works do not directly solve this narrow effect,
but they demonstrate that credible retouching is a data-and-model problem:

- [AutoRetouch, WACV 2021](https://openaccess.thecvf.com/content/WACV2021/html/Shafaei_AutoRetouch_Automatic_Professional_Face_Retouching_WACV_2021_paper.html)
- [PPR10K, CVPR 2021](https://openaccess.thecvf.com/content/CVPR2021/html/Liang_PPR10K_A_Large-Scale_Portrait_Photo_Retouching_Dataset_With_Human-Region_Mask_CVPR_2021_paper.html)

Semantic face editing research also separates spatial deformation from
appearance. Smooth learned warp fields can preserve high-resolution source
texture and expose a continuous strength control, while the authors explicitly
note that warp-only editing cannot repair every appearance effect. This
supports a bounded flow plus low-frequency shading residual rather than either
global RGB synthesis or a handcrafted warp. See
[The GAN That Warped, CVPR 2020](https://openaccess.thecvf.com/content_CVPR_2020/html/Dorta_The_GAN_That_Warped_Semantic_Attribute_Editing_With_Unpaired_Data_CVPR_2020_paper.html).

## 3. Rejected solution classes

| Route | Decision | Reason |
| --- | --- | --- |
| More v4 thresholds or a v5 convexity rule | Reject | Private failures prove false positives, overshoot, seams, and weak semantics; further tuning would overfit eight admitted fixtures. |
| Uniform darkening/highlighting | Reject | Changes tone without reliably changing perceived fullness; v3 already failed the human checkpoint. |
| Vision landmarks as fullness detector | Reject | Landmarks provide geometry only and cannot distinguish volume from lighting, crease, or makeup. |
| `eyeHeight`, `upperEyelidLift`, brow movement, or eye opening | Reject | These are different user-visible controls and prohibited proxies. |
| Hand-authored local warp | Reject | The earlier spike degraded texture energy without a clearer benefit and has no semantic authority. |
| Generic beauty SDK or unknown pretrained weights | Reject | Dataset, checkpoint, model behavior, privacy, conversion, actual-use authorization, and long-term ownership are not established. |
| FFHQR or PPR10K as exact target data | Reject | Their global retouches do not isolate upper-eyelid fullness. Under their upstream terms they may be considered only for an isolated non-commercial local research/pretraining path, never commercial use or distribution. |
| Full RGB GAN/diffusion patch generation | Reject | Unnecessary identity drift, hallucination, latency, memory, licensing, and determinism risk for a narrow local effect. |
| Cloud inference | Reject | Violates the local-first privacy and offline SDK boundary. |

The FFHQR repository says the retouched dataset is CC BY-NC-SA 4.0 and the
underlying originals have mixed licenses; the PPR10K repository limits its
dataset to non-commercial research. Those restrictions are compatible only
with the matching owner-local non-commercial research lane; they remain hard
blockers for any later commercial or distributed use and are not solved by
attribution alone:

- [FFHQR dataset and license](https://github.com/skylab-tech/ffhqr-dataset)
- [PPR10K dataset terms](https://github.com/csjliang/PPR10K)

## 4. Selected model and pixel pipeline

### 4.1 Canonical request

The still-image pipeline continues to own one up-oriented, non-mirrored,
named-sRGB, opaque RGBA8 canonical image. One Vision observation is shared for
the request. Each usable eye is handled independently:

1. derive a brow-to-eye hard-containment polygon from the same-side eye and
   eyebrow landmarks;
2. reject missing, crossed, too-small, too-large, occluded, blinked, extreme-
   pose, or malformed support;
3. crop with explicit padding and resample to a fixed per-eye tensor;
4. mirror the left/right crop into one canonical anatomical orientation;
5. run the model once for that eye;
6. unmirror and map output fields back to the canonical source extent;
7. compose both eyes once against immutable source pixels; overlap returns to
   the source.

The first feasibility experiment uses a `256 × 128` crop. It is a candidate,
not a permanent public contract; `192 × 128` and `256 × 160` must be compared
for detail, model size, and conversion parity before the model interface is
frozen. Crop/scale policy must be explicit because Vision/Core ML crop choices
change image coordinates and content.

### 4.2 Input tensor

The compact model consumes five normalized channels:

- source crop RGB in the pinned training color transfer;
- a soft permitted-region prior;
- a binary protected-region prior for eye aperture/lash/brow boundaries.

The priors constrain where an answer may exist; they do not assert fullness.
No stable face identifier, raw file path, EXIF identity, or fixture label enters
the model.

### 4.3 Multi-head output

One shared mobile encoder/decoder produces four heads:

| Head | Shape | Runtime meaning |
| --- | --- | --- |
| Applicability | scalar confidence + scalar uncertainty | Fail closed unless confidence and uncertainty both pass calibration gates. |
| Support | one-channel soft alpha | Must remain inside the permitted region and decay to exact zero before its boundary. |
| Flow | two-channel dense displacement | Bounded upper-lid soft-tissue field; zero in protected pixels and at the support boundary. |
| Tone | one-channel log-luminance residual | Smooth low-frequency shading correction; zero outside support and bounded before composition. |

A MobileNetV3-small-style depthwise encoder with a small U-Net-style decoder is
the starting architecture, not a mandated vendor model. These are efficient and
well-understood building blocks for mobile dense prediction:

- [MobileNetV3](https://arxiv.org/abs/1905.02244)
- [U-Net](https://arxiv.org/abs/1505.04597)

The first model-size objective is at most `12 MiB` packaged and at most `96 MiB`
peak request memory on the supported package-host measurement path. These are
engineering objectives, not release or physical-device claims; they may be
tightened only after correctness and target-platform measurements exist.

### 4.4 Composition equation

Let `S` be immutable source color, `F` the bounded flow, `T` the bounded
low-frequency log-luminance residual, `A` the admitted alpha, and `k` the
normalized user strength.

```text
W = sample_source_texture(S, k * F)
L = clamp(exp(k * T), toneMinimum, toneMaximum)
P = preserve_chroma_and_high_frequency(W, L)
O = source_owned_compose(S, P, A)
```

Required invariants:

- `k = 0` is byte-exact source identity;
- flow is zero outside target support, at its boundary, and in protected masks;
- the maximum displacement is versioned, small relative to crop height, and
  independently checked after coordinate mapping;
- no fold-over is allowed: the sampled field must preserve a positive local
  Jacobian determinant under the frozen safety tolerance;
- tone is smooth, multiplicative in luminance, clipping-safe, and does not
  invent chroma;
- original high-frequency detail is carried from the warped source, not
  synthesized by the model;
- outside/protected/overlap/alpha bytes are source-owned exactly.

This does not reuse the existing landmark geometry pipeline or retained
`Warp.metal`. It is a private local-retouch proposal stage with CPU reference
composition. A later GPU path may only transport already-owned local-retouch
bytes under the existing contract.

## 5. Data and authorization contract

### 5.1 What the current private images can prove

The currently admitted private bundle contains eight fixtures and twenty-four
assets. It is valuable as a frozen evaluation set and has already exposed real
algorithm failures. It is far too small to train, calibrate, or select a learned
model, and must not be repeatedly used as a tuning loop.

Those images remain holdout evaluation fixtures. They do not move into training
unless the data owner separately grants ML-training, retouched-derivative, and
local derived-model rights for the actual owner-only use and the evaluation
split is replaced with unseen identities.

### 5.2 Required rights

Before any portrait enters training or retouch-target authoring, a data owner
must establish all of the following outside repository evidence:

- subject/image rights cover ML training and creation of retouched derivatives;
- the license permits the actual owner-only research/evaluation or operational
  use, target-authoring, training, and local compiled Core ML use;
- retention, deletion, access, and review responsibilities are assigned;
- retoucher output and any annotation tooling have compatible ownership;
- no dataset license requires disclosure of private weights or unrelated data;
- identity-disjoint split membership is fixed before model selection.

The SDK, training outputs, checkpoint, Core ML resource, private fixtures, and
derived data stay inside the owner-controlled environment. Redistribution
permission is not required because redistribution is prohibited. A research-
only input creates a research-only model: it cannot be monetized, delivered to
a customer, published, transferred, or reused in a later commercial scope.
Any such scope change invalidates current admission and requires a new audit.

The repository stores only aggregate admission counts, normalized dispositions,
model hashes, tool versions, and license-approval status. It never stores raw
portraits, private locators, masks, landmarks, rights documents, reviewer
identity, or freeform subject data.

### 5.3 Project-proposed collection minimums

There is no public paper that guarantees a universal sample count for this
narrow effect. The following numbers are project admission minimums, chosen to
prevent another eight-image overfit; they are not scientific guarantees:

| Gate | Proposed minimum | Purpose |
| --- | --- | --- |
| Feasibility pilot | 300 unique identities, at least two target authors, at least 600 paired edits, identity-disjoint validation/test | Determine whether the hybrid representation can beat source/no-op and tone-only baselines. |
| Owner-local qualification candidate | 2,000 unique identities and 5,000 paired edits, with a separately frozen holdout | Train/calibrate a compact model and measure subgroup failure. |
| Final private qualification | The existing frozen genuine bundle plus a new unseen, category-complete holdout | Prevent training/selection data from receiving product evidence credit. |

Collection strata must deliberately cover eyelid anatomy, skin tones, age
bands appropriate to the authorized product population, natural asymmetry,
makeup/no-makeup, glasses, pose, gaze, blink/squint, occlusion, lighting,
exposure, blur, resolution, camera processing, and positive/negative target
prevalence. Aggregate strata counts are recorded; private identities are not.

### 5.4 Target-authoring package

Every authored positive contains, outside the repository:

- original crop/image;
- professionally retouched target at one agreed reference strength;
- target soft support and protected regions;
- a displacement field or matched before/after deformation representation;
- a separated low-frequency tone layer where the tool supports it;
- a structured label for applicability, uncertainty, and failure reason.

Negative targets are exact source. Retouchers may flatten only the upper-lid
soft-tissue appearance and must not change eye opening, eye contour, brow,
lashes, iris/sclera, gaze, global face shape, unrelated skin texture, or image
grade. Two authors edit an overlap subset; disagreement is adjudicated before
the row becomes trainable.

## 6. Training and conversion contract

### 6.1 Losses

The reference training implementation combines:

- calibrated focal/BCE loss for applicability;
- uncertainty calibration and abstention loss;
- Dice/BCE loss for target support;
- robust supervised flow loss;
- flow smoothness, zero-boundary, protected-zero, magnitude, Jacobian, and
  fold-over penalties;
- low-frequency log-luminance reconstruction and smoothness losses;
- exact-negative/no-op loss;
- protected/exterior source-identity loss;
- high-frequency texture-retention and local-gradient losses;
- landmark/identity consistency checks that are evaluation constraints, not
  semantic labels;
- strength monotonicity and left/right canonicalization consistency.

Training compares at least source/no-op, the frozen v4 heuristic, tone-only,
flow-only, and hybrid ablations. The hybrid path advances only if it is visibly
better than every simpler admissible baseline without a safety regression.

### 6.2 Reproducibility

Each model candidate binds:

- source commit and clean training entry point;
- dataset manifest digest and split digest without private locators;
- target-authoring protocol version;
- dependency lock, random seeds, configuration, and numeric precision;
- checkpoint digest, export digest, Core ML package digest, and model card;
- aggregate training/validation/test metrics and subgroup dispositions;
- license/provenance approval state.

### 6.3 Core ML route

The reference model is trained in PyTorch and exported with a fixed-shape
interface. Apple currently documents `torch.jit.trace` followed by `ct.convert`
as the stable recommended conversion path; the conversion, input image type,
deployment target, and precision are pinned before qualification. See
[Apple's PyTorch conversion workflow](https://apple.github.io/coremltools/docs-guides/source/convert-pytorch-workflow.html)
and [Core ML](https://developer.apple.com/documentation/coreml).

Required conversion checks:

- representative PyTorch and Core ML outputs agree within frozen per-head
  tolerances;
- source and converted applicability decisions are identical at threshold
  boundaries;
- NaN/Inf, shape, channel order, crop, mirror, color transfer, and precision
  mutations fail closed;
- compression or quantization is attempted only after the uncompressed model
  passes quality gates, and the compressed candidate must requalify independently;
- the compiled model is loaded once per engine/resource owner, while tensors,
  crops, masks, fields, and outputs remain request-local.

## 7. Runtime API and package ownership

No public parameter is added while this decision is being implemented. The
first internal boundary is conceptually:

```swift
package protocol BeautyUpperEyelidFullnessPredicting {
    func predict(_ request: CanonicalPerEyeRequest) throws
        -> BeautyUpperEyelidFullnessPrediction
}
```

The exact Swift names are implementation details, but the ownership is fixed:

- `BeautyDetection` supplies one mapped Vision observation and crop geometry;
- `BeautyResources` validates the bundled model identifier and digest;
- `BeautyEffects` owns model input, prediction validation, proposal creation,
  and immutable-source composition;
- `BeautySDK` owns engine-scoped model availability and typed owner-local public failure or
  source-exact local no-op behavior;
- no public diagnostics expose support, confidence values, crop geometry,
  model tensors, masks, or pixels.

Model absence, checksum mismatch, unsupported platform, compile failure,
invalid output, low confidence, high uncertainty, unsupported pose, blink,
occlusion, or malformed mapping fails closed. A peer-eye failure does not
authorize work or suppress a valid independent eye.

Only after every Phase-80 evidence gate passes may Phase 81 add the default-zero
positive-only `upperEyelidFullnessReduction` owner-local public field and still-image route.
No realtime/pixel-buffer route follows automatically.

## 8. Qualification gates

### 8.1 Automated pixel/model gates

Every owner-local qualification candidate must pass, with zero skipped required rows:

- model license/provenance/resource/digest admission;
- source-to-Core-ML numerical and decision parity;
- exact strength-zero identity;
- visible target change on genuine positives under a frozen minimum;
- safe no-op/applicability behavior on all negatives and stress rows;
- exact source ownership for eye aperture, lashes, iris, pupil, sclera, brow,
  protected crease, exterior, overlap, and alpha;
- maximum flow, zero-boundary, smoothness, positive-Jacobian, and no-fold-over
  bounds;
- minimum high-frequency/detail retention and maximum boundary discontinuity;
- bounded tone/chroma/channel movement and clipping safety;
- extent, orientation, mirror, named-sRGB, alpha, and metadata invariants;
- deterministic repeat, independent-eye isolation, cancellation/recovery, and
  parallel independent-engine behavior;
- typed invalid-resource/model/output failure with no proxy fallback.

No single metric proves efficacy. Passing requires both a target semantic delta
and protected-source safety.

### 8.2 Human review

Only after the automated matrix passes twice against the frozen candidate may
blinded original-detail review open. At least two reviewers independently score:

- clearly visible fullness reduction on positive eyes;
- natural contour and fold/shading;
- identity and high-frequency detail preservation;
- absence of boundary blocks, halos, dark patches, stretching, duplicated
  texture, or fold-over;
- unchanged eye opening, brow, gaze, lashes, sclera/iris, and unrelated skin;
- correct no-op on negative and unsupported rows.

Any required-row failure is terminal for that model digest. Thresholds cannot
be relaxed after viewing outcomes. Review disagreement is adjudicated under the
frozen rubric; it is not averaged into a pass.

### 8.3 Performance boundary

SwiftPM and SDK-owned repeatable image/model checks remain the milestone's
primary evidence. A later optional real-iPhone run should record cold/warm
latency, peak memory, thermal behavior, and energy before any device or release
claim, but missing physical-device evidence is not a project blocker under the
standing automation policy. Package-host results make no device, battery,
thermal, commercial, packaging, shipping, launch, or release-readiness claim.

## 9. Implementation sequence and stop rules

| Step | Deliverable | Entry gate | Exit gate |
| --- | --- | --- | --- |
| R0 | This decision, owner-doc synchronization, v1-v4 terminal record | v4 terminal | Documentation consistency and no source edits. |
| R1 | Quarantine failed heuristic; add internal prediction/resource seam and generated safety oracles | R0 committed | Build/tests pass; public 61/5/74 unchanged; no fake model. |
| R2 | Rights/data admission, target-authoring tool/protocol, frozen splits | Actual-use-approved local research/training, derivative, and local-model rights | Pilot minimum and category completeness pass. |
| R3 | Offline PyTorch baselines and hybrid model | R2 | Hybrid beats source, v4, tone-only, and flow-only under frozen validation. |
| R4 | Core ML conversion, package resource, source/Core-ML parity | R3 | Conversion, model, pixel, privacy, and resource gates pass. |
| R5 | Fresh private automation and blinded review | R4 frozen | All automated rows pass twice and every required human row passes. |
| R6 | Owner-local still-image activation and closeout | R5 canonical pass | API/output/compatibility/taxonomy/no-skip gates pass. |

Hard stop rules:

- Without actual-use-authorized paired training data and exact fullness targets,
  stop after R1. Do not resume heuristic tuning and do not create an inert
  owner-local public field.
- If the pilot does not produce a clearly visible improvement over source/no-op
  and tone-only baselines, keep `去脂` future.
- If negatives cannot fail closed, protected pixels drift, the flow folds, or
  reviewers cannot reliably see the target effect, reject the candidate digest.
- Any new model/dataset/license or conversion change creates a new candidate
  requiring a new frozen qualification; prior passing rows cannot be borrowed.

## 10. Immediate code disposition

Once this document is committed, code work may begin in this order only:

1. mark `BeautyUpperEyelidReliefModel` and the v4 editor path as rejected
   experimental mechanics rather than a candidate-v5 implementation;
2. prevent any new plan or test from treating v4 thresholds as a production
   semantic owner;
3. add a package-only predictor/result boundary with strict validation and an
   explicit unavailable/no-model fail-closed outcome;
4. add generated tests for resource absence, malformed outputs, protected-flow
   zeroing, immutable-source ownership, and exact public absence;
5. stop before enabling a model or claiming visible efficacy until R2 data,
   exact targets, and actual-use rights exist; never distribute the result.

This is the smallest honest repair. It removes the false premise from the old
code while preserving reusable canonicalization, one-observation mapping,
request-local ownership, original-pixel composition, privacy, and qualification
infrastructure.
