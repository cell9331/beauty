# Pitfalls Research

**Domain:** Still-image local facial retouch in a mature local-first iOS SDK (`白牙`, `祛红血丝`, conditionally `去脂`)
**Researched:** 2026-07-30
**Confidence:** HIGH for project-specific mechanics, privacy, integration, and scope hazards; MEDIUM for product calibration until feature-specific rights-approved bundles exist

## Roadmap Phase Vocabulary

This document assigns prevention to the following recommended roadmap phases so that every warning has one accountable owner:

| Phase | Owner | Exit condition relevant to pitfalls |
| --- | --- | --- |
| **Phase 1 — Contract, Canonical Input, and Privacy Boundary** | Public parameter compatibility, still-image input policy, selected-face ownership, request-local support, aggregate diagnostics | One accepted canonical image feeds Vision and render; transparent/non-RGB/malformed inputs reject before Vision; no raw support crosses public, persistence, or diagnostic boundaries |
| **Phase 2 — Evidence Gate and Feature Eligibility** | Rights manifests, positive/negative fixture bundles, predeclared review criteria, `去脂` go/no-go | Product evaluation opens only for complete approved bundles; each feature has genuine positives and negatives; `去脂` either proves an independent non-warp path or remains absent/future |
| **Phase 3 — Teeth Provider and Bounded Transform** | Fixed/adaptive tooth selection, protected-tissue containment, whitening polarity and naturalness | Teeth mask never loses accepted fixed support, stays inside the narrow mouth envelope, changes no protected/outside pixel, and passes rights-approved original-detail review |
| **Phase 4 — Guarded Per-Eye Sclera Provider and Transform** | Per-eye geometry guards, iris/highlight protection, redness transform | Geometry and color-adversarial oracles both show zero protected changes; each eye fails independently; real redness positives prove useful natural reduction |
| **Phase 5 — Original-Pixel Composition and Performance** | Mask ownership, overlap policy, failure isolation, optimized execution, target-device profiling | Every accepted edit reads the original pixel under one owner; collisions preserve source; standalone/fused failure oracles agree; release device budgets are measured |
| **Phase 6 — Facade Output, Safety Closeout, and Independent Promotion** | Compatibility regression, saved-output review, security/quality scans, ledgers and independent audit | Only independently passing features are promoted; all nonclaims remain explicit; teeth/redness may ship without `去脂` and branch status stays honest |

## Critical Pitfalls

### Pitfall 1: Shipping a proxy and calling it upper-eyelid fullness reduction

**What goes wrong:**
`去脂` is implemented by forwarding to `eyeHeight`, `upperEyelidLift`, brow motion, eye opening, global smoothing, eye-bag/dark-circle removal, or the invalidated vertical warp. The output can move the eye or erase skin texture while never reducing genuine upper-eyelid fullness.

**Why it happens:**
Vision exposes eye and brow landmarks but no fullness semantic or target surface. Existing geometry controls already produce visible output, so aliasing them makes the feature look complete. The tested color-only approach was visually negligible on mechanics fixtures and the tested warp reduced texture energy without a clearer semantic benefit.

**How to avoid:**
Define `去脂` as an independent, non-warp upper-eyelid effect. Keep any future tone/frequency experiment within the observed eye-to-brow band, preserve high-frequency detail and RGB geometry, and require genuine upper-eyelid-fullness positives plus crease/makeup/blink/glasses/pose/skin-tone negatives. If the independent real-positive gate fails, do not add or activate the public field and keep branch `眼睛` partial.

**Warning signs:**
The implementation imports or writes an existing eye/brow strength; before/after overlays show eye or brow displacement; a test passes on a portrait with no established fullness; texture-energy loss is treated as improvement; roadmap language says all three features must ship together.

**Phase to address:**
Phase 2 owns the hard go/no-go; Phase 6 enforces non-promotion and partial-branch wording.

---

### Pitfall 2: Treating mechanics fixtures or the current portrait as product evidence

**What goes wrong:**
AI-generated fixtures, a clean smile, or the single rights-approved `p1.jpg` are used to claim effectiveness, demographic robustness, naturalness, or commercial readiness. The current portrait can expose teeth containment and over-whitening, but its already-light teeth are not a yellow-teeth positive and its eyes/eyelids are not established redness/fullness positives.

**Why it happens:**
Deterministic metrics are plentiful and easy to reproduce, while acquiring rights-approved feature positives/negatives is slower. A valid rights record is also easily confused with correct feature polarity.

**How to avoid:**
Separate `mechanics_only` from `approved_internal_evaluation`. For each feature, require opaque IDs, explicit positive/negative polarity, rights status/record, complete original-mask-after assets, and predeclared acceptance criteria. Review locally and blinded at 100% detail. Export only fixed structured judgments and aggregates. Do not pool evidence across features: a teeth-positive is not a sclera or eyelid positive.

**Warning signs:**
Only one portrait appears in the denominator; positive and negative counts are absent; feature polarity is inferred from visible anatomy; thresholds are chosen after viewing results; reviewer notes or filenames substitute for fixed reason codes; claims mention population or commercial quality.

**Phase to address:**
Phase 2 blocks implementation promotion; Phase 6 verifies denominators, predeclared rules, and nonclaims.

---

### Pitfall 3: Whitening an aperture instead of selecting teeth

**What goes wrong:**
The full `innerLips`/`outerLips` polygon, or a global adaptive threshold, selects lip, tongue, gum, braces, facial hair, or mouth background. Conversely, fixed inner-lip support misses visible side teeth, producing a central white patch and inconsistent smile.

**Why it happens:**
Vision lip landmarks are coarse aperture support, not a tooth label. Expanding to the outer lip improves apparent coverage on easy fixtures, while protected-tissue leakage can remain subtle at normal zoom.

**How to avoid:**
Retain a conservative fixed inner-lip baseline, grow only from accepted seeds through connected candidates, constrain growth to the outer-lip polygon clipped to a narrow vertical aperture envelope, feather locally, re-clip, and preserve every strong fixed pixel. Fail closed for closed mouth, missing seeds/support, implausible geometry/area, or occlusion. Test side teeth and protected tissue separately on wide/small smiles, yellow/gray teeth, lips, tongue, gums, braces, blur, pose, lighting, and skin tones.

**Warning signs:**
Coverage rises while an upper-lip strip appears in the overlay; strong fixed pixels are dropped; mask ratios approach the entire aperture; selection survives closed-mouth/no-face inputs; output review has no lip/tongue/gum/braces judgments; only central-tooth pixel counts improve.

**Phase to address:**
Phase 3 owns containment, coverage, and product review; Phase 6 blocks `白牙` promotion on any protected-tissue failure.

---

### Pitfall 4: Over-whitening or whitening the wrong color polarity

**What goes wrong:**
The transform globally desaturates or brightens the mouth, turns teeth blue/chalky, crushes shade variation and enamel detail, or appears to work on already-light teeth while failing yellow/darker side teeth.

**Why it happens:**
Mask correctness and color correctness are separate. A large luminance lift produces an obvious pixel delta that passes weak automated visibility checks, and the active fixture favors containment rather than yellow-removal calibration.

**How to avoid:**
Read the original pixel, reduce measured yellow excess, apply a small bounded luminance lift/correction, cap target luminance, and preserve texture. Predeclare bounds for luminance change, yellow reduction, texture retention, maximum channel delta, and protected/outside changes. Require mild/severe yellow positives, gray/non-yellow negatives, already-light teeth negatives, and human naturalness review.

**Warning signs:**
Brightness rises equally for gray and yellow teeth; blue channel addition is constant regardless of yellow excess; side teeth clip to the same value as incisors; texture ratios fall; reviewers see a flat white patch; the only positive is the already-light current portrait.

**Phase to address:**
Phase 3 calibrates the transform; Phase 6 freezes final caps and rejects polarity/naturalness overclaims.

---

### Pitfall 5: Letting native iris color hide unsafe sclera geometry

**What goes wrong:**
The native redness mask appears to avoid the iris only because a dark iris receives a low sclera/redness score. Under a light/red iris-like input, landmark jitter, gaze, or partial closure, the same geometric envelope edits iris pixels.

**Why it happens:**
Color gating is evaluated after geometry, so an unsafe support envelope can look clean on ordinary fixtures. The original pupil-centered exclusion leaked in nearly every spike perturbation scenario.

**How to avoid:**
Validate each eye before color scoring: require finite noncollapsed contour support, calibrated aperture aspect, pupil containment, and uncertainty-inflated iris exclusion. Maintain two independent oracles: a color-independent eligibility envelope against unperturbed iris/highlight truth, and a final-output adversarial oracle that recolors only protected iris pixels to sclera-like red before running the actual score, feather, clip, and transform.

**Warning signs:**
Safety tests use only native eye colors; dark/brown iris fixtures always pass but no adversarial recolor exists; jitter changes iris overlap; a pupil outside the aperture still produces candidates; the guard is justified by visual inspection alone.

**Phase to address:**
Phase 4 owns both oracles and calibrated per-eye guards; Phase 6 treats any protected pixel change as a hard blocker.

---

### Pitfall 6: Feathering outside the anatomical envelope

**What goes wrong:**
A mask is intersected with the eye/mouth envelope before blur, but feathering creates new nonzero weights in iris, highlight, lip, skin, or outside-aperture pixels. Composition then changes pixels that were never valid candidates.

**Why it happens:**
Developers treat clipping as a one-time preprocessing step. Spatial filters expand support by design, and low alpha values are easy to miss in binary or normal-size overlays.

**How to avoid:**
Keep an immutable hard envelope. Re-intersect after every blur, feather, dilation, or growth operation and immediately before ownership sanitization. Test weighted—not merely binary—support, `changedOutsideMask == 0`, and byte-level changes inside protected truth. Apply the same rule to teeth and sclera.

**Warning signs:**
The final mask has nonzero pixels where the hard envelope is zero; tests inspect only the pre-feather mask; outside changes are counted with a threshold too high to see small weights; the render pass receives a blurred mask without a final clip.

**Phase to address:**
Phases 3 and 4 own provider-local re-clipping; Phase 5 repeats the invariant at composition.

---

### Pitfall 7: Orientation, color, detector, and canvas have multiple owners

**What goes wrong:**
Vision sees one orientation/color/background while the renderer sees another. Masks shift, mirrored sides swap, equivalent color profiles move landmark anchors, or a transparent border changes detection even when face pixels appear unchanged.

**Why it happens:**
Passing EXIF orientation only to Vision looks sufficient; implicit device RGB and separate `CIImage`/`CGImage` paths hide additional conversions. Exact mask-topology assertions are then added to force stability that Vision does not guarantee. Apple documents that orientation affects image-processing interpretation, Core Image color-manages between source/working/destination spaces, and Vision request revisions can change available detector behavior.

**How to avoid:**
Validate encoded metadata, accept only supported RGB input, normalize once to a declared up-oriented sRGB pixel format with one reused `CIContext`, then feed those same canonical pixels to one explicitly owned Vision revision and rendering. Reject transparent input before Vision for v1.14. Test all eight lossless EXIF encodings exactly, but use bounded anchor/output/containment criteria—not exact topology—for equivalent color profiles. Compare fresh-anchor and fixed-anchor variants to separate detector drift from mask/transform drift. Record OS/Vision revision in the test matrix without exposing request geometry.

**Warning signs:**
Orientation is passed to Vision while render assumes `.up`; multiple `CIContext` or decode paths exist; device RGB is implicit; alpha is merely copied back after detection; tests demand identical masks across Display-P3/sRGB; OS updates change output without a revision/stability record.

**Phase to address:**
Phase 1 owns the canonical boundary and rejection order; Phase 6 owns cross-profile/OS regression bounds.

---

### Pitfall 8: Silent face selection or repeated detection changes ownership

**What goes wrong:**
Each local effect runs its own Vision request, chooses a different face, or silently selects the largest face. Teeth and sclera masks can belong to different people, results drift between effects, and latency doubles. Missing support may be guessed or reused from another request.

**Why it happens:**
Vision can detect faces implicitly for a landmarks request, making one-request-per-effect convenient. The spikes selected the largest face only as a mechanics shortcut, not a product/API decision.

**How to avoid:**
Declare selected-face ownership in the still-image contract, run one face-landmark request on the canonical pixels, and construct one immutable request-local context. Never retry per effect, reuse stale support, synthesize a pupil/seed, or silently broaden multi-face scope. A provider returns only its local mask/no-op; one eye or region failing must not erase an accepted peer or sibling feature.

**Warning signs:**
Vision request count changes with the number of enabled effects; provider APIs accept an image rather than a request context; left-eye failure zeros right-eye candidates; teeth failure suppresses sclera; metrics cannot explain which regions were accepted without revealing geometry; multi-face tests have no declared selected-face result.

**Phase to address:**
Phase 1 freezes ownership; Phases 3–5 prove region/eye failure isolation; Phase 6 tests the public facade end to end.

---

### Pitfall 9: Sequential output feedback creates hidden priority and double edits

**What goes wrong:**
Sclera reads teeth-modified pixels (or vice versa), mask overlap is resolved by call order/max strength, and repeated processing compounds color. A fused loop can still be wrong if it reads the evolving output rather than the original image.

**Why it happens:**
Sequential filters are the simplest implementation and match results while masks happen to be disjoint. Once providers drift or overlap, ordering becomes an undocumented ownership policy.

**How to avoid:**
Clamp masks, require expected disjointness, and assign exactly one owner per pixel. Every accepted transform reads the original canonical pixel. Any unexpected teeth/sclera collision increments an aggregate counter and preserves the source pixel. Verify fused output against independently transformed/merged standalone oracles and inject collisions plus zero-teeth/zero-sclera/rejected-eye failures.

**Warning signs:**
Transform functions take the previous output; swapping pass order changes bytes; overlap has a priority enum not present in the product contract; no injected collision test exists; processing the same image twice increases whitening/redness reduction unexpectedly.

**Phase to address:**
Phase 5 owns composition and fault injection; Phase 6 verifies facade output and repeated-call neutrality/independence.

---

### Pitfall 10: Request-local biometric-adjacent data leaks through diagnostics or evidence

**What goes wrong:**
Eye contours, pupils, masks, vein-like patterns, teeth geometry, image paths, raw metadata, rights records, thumbnails, or reviewer free text enter public APIs, Codable models, logs, metrics, test snapshots, review exports, or version control.

**Why it happens:**
Mask debugging is visual and developers want persistent artifacts. Sclera vasculature is especially sensitive, and harmless-looking stable geometry signatures can become cross-request identifiers. Rights documentation can also reveal subject/source identity.

**How to avoid:**
Keep raw/derived support immutable, package-internal, non-Codable, request-local, non-networked, and absent from descriptions/reflection. Allow only fixed reason codes and aggregate counts/timings. Keep fixture media and generated outputs local, ignored, metadata-sanitized, rights-gated, and bounded. The review export contains opaque fixture ID, feature/polarity, fixed judgments, decision, and aggregate counts—never paths, filenames, rights/documentation IDs, media, or free text.

**Warning signs:**
New public/SPI types mention mask/point/rect/pupil/vein/teeth support; JSON keys contain coordinates or asset paths; test failures dump arrays/pixels; generated portrait assets appear tracked or staged; review runs require a server/upload; logs contain per-eye positions or stable hashes.

**Phase to address:**
Phase 1 defines the boundary; every implementation phase runs redaction/artifact scans; Phase 6 performs independent security closeout.

---

### Pitfall 11: An unapproved learned model becomes a hidden production dependency

**What goes wrong:**
A research Core ML converter/model is vendored because it improves mask coverage, despite an incomplete dataset/checkpoint/conversion/redistribution license chain, unpinned artifact, large cold-load cost, or unclear package/privacy behavior.

**Why it happens:**
The learned output looks more complete than deterministic support and is easy to wrap behind a provider protocol. Technical success is mistakenly treated as legal and distribution approval.

**How to avoid:**
Keep the learned path comparator-only unless provenance, original data/checkpoint/conversion licenses, redistribution terms, exact version/checksum, package size, privacy behavior, cold/warm latency, peak memory, and SPM distribution are independently approved. Prefer the deterministic adaptive path for v1.14. If a model is later authorized, initialize/reuse it outside requests and reopen privacy-manifest/resource-trust review.

**Warning signs:**
Model or weight files appear without an owner manifest; repository/license pages are cited instead of the complete chain; model loads inside `process`; cold and warm numbers are combined; resource scans or package size change unexpectedly; implementation silently falls back to the model.

**Phase to address:**
Phase 2 is the legal/product gate; Phase 5 owns resource/performance review if and only if separately authorized; Phase 6 scans for unapproved assets and dependencies.

---

### Pitfall 12: Correct composition is mistaken for performant composition

**What goes wrong:**
The full-resolution image is scanned repeatedly with large floating masks, or a single full-frame CPU ownership loop is marketed as an optimization. Memory spikes and latency become unacceptable on real iPhones even though macOS release mechanics pass.

**Why it happens:**
“One loop” sounds faster, debug/simulator/macOS measurements are easier than device profiling, and evidence harnesses retain multiple oracle frames that obscure production memory. The tested full-frame CPU fused path was 2.6–3.1× slower than sparse sequential loops.

**How to avoid:**
Preserve ownership semantics while implementing bounded mouth/eye ROIs or a Metal/Core Image path. Reuse `CIContext` and immutable framework resources; do not create contexts or load models per request. Benchmark release on supported iOS devices and separately report normalization, Vision, mask generation, transform/composition, cold/warm model (if any), peak memory, and full-resolution cases. Treat spike timings as baselines/nonclaims, never budgets.

**Warning signs:**
Loops traverse the full frame when masks occupy small ROIs; each request allocates multiple full-size float masks/canonical frames; performance evidence is macOS or debug-only; model/context creation appears in request methods; only median color-pass time is reported while normalization/Vision/memory are omitted.

**Phase to address:**
Phase 5 owns architecture and device profiling; Phase 6 blocks any performance/readiness claim without target-device release evidence.

---

### Pitfall 13: Coupling three independent features into an all-or-nothing milestone

**What goes wrong:**
`白牙` and `祛红血丝` are held hostage by the blocked `去脂`, or `去脂` is weakened/aliased so the roadmap can claim complete `眼睛` and `嘴唇` branches together. A defect in one provider disables all local retouch.

**Why it happens:**
The taxonomy suggests a single “local retouch” launch, while the algorithms, evidence, failure modes, and fixture needs are independent.

**How to avoid:**
Share only canonical input, request context, privacy, ownership, and composition infrastructure. Give teeth, each eye, and upper-eyelid work separate eligibility, tests, evidence denominators, and promotion decisions. Explicitly authorize partial shipping: validated teeth and/or redness may ship; failed `去脂` remains future and `眼睛` remains partial. Do not close `嘴唇` unless `白牙` independently passes.

**Warning signs:**
One boolean represents all local retouch; one provider failure returns the original full image; requirement wording says “all three”; branch ledgers update before per-feature evidence; a shared cap or mask type erases feature-specific rules.

**Phase to address:**
Phase 1 establishes independent contracts; Phases 3 and 4 deliver independent slices; Phase 6 owns exact per-feature and branch promotion.

---

### Pitfall 14: Scope expansion invalidates the evidence boundary

**What goes wrong:**
Still-image findings are reused to add realtime/pixel-buffer processing, transparent images, HDR/gain maps, Demo UI, silent multi-face behavior, external models, cloud processing, or release-readiness claims.

**Why it happens:**
The reusable mask/color foundation appears broadly applicable, but those paths have different scheduling, orientation, alpha/compositing, memory, UX, privacy, and performance owners.

**How to avoid:**
Keep v1.14 SDK-SPM-only and still-image-only. Reject transparent input before Vision. State that HDR/gain maps, realtime/camera, Demo/UI, new multi-face UX, external resources, device/commercial/packaging/shipping/launch readiness are excluded and require separate milestones/contracts. Run scope scans over targets, imports, dependencies, resources, network APIs, and ledgers.

**Warning signs:**
Pixel-buffer overloads reference local masks; SwiftUI/Demo files change; alpha preservation is described as transparent support; HDR is accepted without a gain-map contract; new dependency/model/network matches appear; milestone verification uses words such as device-ready, commercial, shipping, or launch.

**Phase to address:**
Phase 1 freezes scope; Phase 6 independently verifies it did not expand.

## Hard Promotion Gates

These are blocking, not score-balancing criteria. A strong result in one row cannot compensate for a failure in another.

| Candidate | Hard gate | Required result | Failure disposition |
| --- | --- | --- | --- |
| Shared foundation | Canonical input | All 8 lossless EXIF orientations exact; supported RGB only; transparent/malformed/non-RGB rejected before Vision; one canonical image shared by detector/render | Do not route any local-retouch field |
| Shared foundation | Ownership/privacy | One selected-face request; masks request-local; transforms read original pixels; collision preserves source; aggregate-only diagnostics | Foundation incomplete; no feature promotion |
| `白牙` | Evidence polarity | Approved yellow/darker-teeth positives plus already-light/closed/protected-tissue negatives | Keep `白牙` future; current portrait contributes containment only |
| `白牙` | Containment/naturalness | Zero changed pixels outside accepted teeth mask and protected tissues; no dropped strong baseline support; bounded luminance/texture/channel change; original-detail accept | Keep `白牙` future and `嘴唇` partial |
| `祛红血丝` | Evidence polarity | Approved mild/severe redness positives and blink/gaze/iris/highlight/glasses/contact negatives | Keep `祛红血丝` future |
| `祛红血丝` | Protected regions | Zero iris/highlight changes under both color-independent and adversarial final-output oracles; failure local per eye; positive shows useful natural redness reduction | Keep `祛红血丝` future and `眼睛` partial |
| `去脂` | Semantic independence | Genuine fullness positives and negatives; independent non-warp path; no eye/brow movement; detail/identity preserved | Omit/inert field, keep row future and `眼睛` partial; teeth/redness may proceed |
| Any promoted feature | Integration/performance | Public-facade saved output, full regression, no shipped-effect drift, release target-device profiling, security/artifact scans | No readiness/performance claim; do not promote if correctness/privacy fails |
| Branch promotion | Exact ledger ownership | Promote only rows whose individual gates pass; independent audit confirms owners and nonclaims | Preserve partial branch status |

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
| --- | --- | --- | --- |
| Reuse eye/brow geometry for `去脂` | Immediate visible delta | Permanent semantic lie; impossible honest branch closeout | Never |
| Whole inner/outer-lip mask | Simple tooth implementation | Lip/tongue/gum leakage or poor side-tooth coverage | Mechanics comparison only, never product output |
| Native-color-only sclera safety | Easy green tests | Dark iris hides unsafe geometry | Never |
| Clip only before feather | Simple mask pipeline | Anatomical leakage after filtering | Never |
| Sequential output-as-input transforms | Minimal integration work | Hidden priority, double edits, non-local failures | Oracle only while proving disjointness; never ownership contract |
| Exact cross-profile topology assertion | Deterministic-looking test | Brittle false failures and pressure to bypass color management | Never; use bounded stability |
| Largest-face selection without contract | Easy multi-face behavior | Wrong-person edits and unstable ownership | Mechanics fixture only |
| Full-frame CPU float-mask loop | Simple correct reference | Device latency and memory debt | Reference oracle only; not production budget evidence |
| Per-request `CIContext`/model creation | Local construction convenience | Cold latency, memory churn, cache duplication | Never in production request path |
| Add all public fields before feasibility | Early API completeness | Stable no-op/alias contract that cannot be removed | Only default-neutral internal planning types; public `去脂` remains conditional |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
| --- | --- | --- |
| ImageIO metadata | Decode first and assume `.up` or trust malformed orientation | Validate size/color/orientation first; normalize accepted EXIF 1…8 once |
| Core Image | Implicit device RGB or separate contexts/spaces | Reuse one context with explicit working/output color spaces and canonical sRGB output |
| Apple Vision | One request per effect, unpinned/default revision, silent largest-face choice | One request on canonical pixels, explicit supported revision/selected-face owner, OS/revision regression record |
| Vision landmarks | Treat lip/eye landmarks as semantic segmentation | Use them only as bounded support; feature-specific color/geometry validation still required |
| Teeth provider | Grow candidates without fixed seeds or narrow envelope | Seed from conservative fixed mask, connected growth, final hard re-clip, preserve fixed support |
| Sclera provider | Score color before geometry guard or reuse one eye’s support | Guard each eye first, score/feather/re-clip per eye, compose accepted peers independently |
| Renderer | Feed one effect’s output into the next | Original-pixel deterministic transforms under explicit mask ownership |
| Public facade | Expose masks/landmarks for debugging | Public scalar controls plus typed/redacted aggregate result only |
| Local reviewer | Use a server, paths, rights IDs, or freeform export | Browser-local files, opaque IDs, fixed judgments/reason codes, sanitized aggregate export |
| Core ML | Bundle a convenient converted artifact | Require complete provenance/license/checksum/resource/performance approval first |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
| --- | --- | --- | --- |
| Full-frame ownership pass for tiny regions | Fused CPU path slower than sparse passes; high temporary memory | ROI or Metal/Core Image execution while preserving original-pixel ownership | Already observed at 506×900 and 1728×2304; 2.6–3.1× slower in spike |
| Multiple full-resolution oracle frames in production | Peak RSS scales with image and enabled feature count | Keep oracle retention in tests only; reuse bounded buffers and release temporaries | High-resolution stills; spike harness peaks are explicit non-budgets |
| Repeat Vision per effect | Detection dominates and results can drift | One request/request context for all local regions | With two enabled effects already duplicates dominant work |
| Context/model load per request | First edit stalls; memory spikes; warm numbers hide cold start | Reuse `CIContext`; preinitialize only approved model resources asynchronously | Research model showed ~1.68 s cold load and ~198 MB high-resolution peak RSS |
| Reporting transform-only time | Fast-looking metric while decode/normalization/Vision dominate | Separate end-to-end stages and peak memory on release iOS devices | Any product/readiness claim |
| Debug/macOS numbers as iOS budget | Green local benchmark but poor device behavior | Release builds on supported physical iPhones, multiple resolutions, cold/warm runs | Before setting or claiming a budget |

## Security Mistakes

| Mistake | Risk | Prevention |
| --- | --- | --- |
| Persisting sclera/vein masks or descriptors | Sensitive biometric-adjacent pattern exposure | Ephemeral request-local buffers; no cache/persistence/public diagnostics |
| Logging geometry, paths, framework errors, or model tensors | User-content and filesystem leakage | Fixed reason codes and aggregate counts/timings only; allowlist JSON keys |
| Tracking fixture/generated media | Portrait, likeness, derivative, and metadata exposure | Local ignored assets, sanitized metadata, opaque rights record, artifact scans |
| Exporting rights/documentation IDs or free text | Re-identification and retention-policy leakage | Sanitized structured export with opaque fixture IDs and fixed fields |
| Accepting traversal/absolute asset paths in review bundle | Local file disclosure | Conservative relative paths, duplicate/traversal/asset-inventory validation |
| Adding a local review server/network beacon | Unapproved content transfer | Static browser File API workflow; scan for fetch/XHR/WebSocket/beacon/URLs |
| Vendoring unlicensed model/weights | Redistribution/legal and supply-chain risk | Independent license/provenance review, pinned checksum/version, package audit |
| Stable geometry hashes/signatures in metrics | Cross-request subject linkage | Aggregate ephemeral counts only; no stable support-derived identifier |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
| --- | --- | --- |
| Chalk-white teeth at moderate strength | Artificial smile, lost enamel detail | Bounded yellow reduction and small luminance lift with naturalness cap |
| Central teeth whitened, side teeth unchanged | Patchy, visibly algorithmic result | Seeded adaptive side-tooth coverage under protected-tissue gates |
| Whole eye whitened | Iris/highlight damage and uncanny gaze | Red-excess-only edit inside guarded, re-clipped per-eye sclera support |
| Both eyes disabled because one blinks | Inconsistent “feature does nothing” experience | Per-eye fail-closed behavior with accepted peer retained |
| `去脂` moves eye/brow or erases crease | Identity/structure change; misleading feature name | Do not ship until independent real-positive non-warp effect passes |
| Silent no-op presented as success | Host app/user cannot understand unavailable support | Redacted fixed degradation reasons and aggregate acceptance counts |
| Before/after shifts from orientation/profile | Users perceive false geometry change | One canonical input/crop and bounded detector stability review |
| Three-feature launch promise | Validated features delayed or blocked feature faked | Independent controls, gates, and partial shipping/branch status |

## “Looks Done But Isn’t” Checklist

- [ ] **Canonical input:** Often missing rejection order and single ownership — verify malformed orientation, non-RGB, alpha, size, and pixel ceilings reject before Vision/allocation-heavy work.
- [ ] **EXIF support:** Often checks only rotations — verify all eight rotation/mirror encodings normalize exactly.
- [ ] **Profile stability:** Often demands impossible topology identity — verify bounded fresh-anchor and fixed-anchor output/containment separately.
- [ ] **Face ownership:** Often silently uses largest face — verify one declared selected-face policy and one Vision request.
- [ ] **Request locality:** Often hides support in cached/provider state — verify valid→invalid→valid and concurrent requests cannot reuse masks/landmarks.
- [ ] **Teeth mask:** Often confuses lip aperture with teeth — verify side-tooth gain, zero fixed-support loss, and lip/tongue/gum/braces/closed-mouth negatives.
- [ ] **Teeth transform:** Often proves a delta, not whitening quality — verify yellow polarity, bounded luminance/channel change, texture, and already-light negative.
- [ ] **Sclera geometry:** Often passes because the iris is dark — verify color-independent jitter and adversarial final-output oracles.
- [ ] **Sclera filtering:** Often omits the second hard clip — verify final weighted mask is zero outside the hard envelope.
- [ ] **Regional failure:** Often turns local rejection into global no-op — verify zero teeth, zero sclera, rejected left eye, and rejected right eye independently.
- [ ] **Composition:** Often hides order semantics — verify every accepted pixel reads original input and injected overlap stays byte-identical to source.
- [ ] **Fixture evidence:** Often has rights but wrong polarity — verify complete approved positive/negative bundles per feature and predeclared criteria.
- [ ] **Privacy:** Often leaks via tests/review exports rather than runtime logs — scan public/SPI/Codable/reflection, JSON keys, artifacts, media, paths, and free text.
- [ ] **Performance:** Often reports only transform time — profile normalization, Vision, masks, composition, cold/warm resources, and peak memory on release devices.
- [ ] **Promotion:** Often closes the taxonomy instead of the evidence — promote only individually passing rows; explicitly keep `去脂`/branches partial when gated.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
| --- | --- | --- |
| Proxy `去脂` already implemented | HIGH | Remove routing/output claim, preserve source compatibility only if unavoidable, restore row/branch to future/partial, reopen Phase 2 with genuine positives and independent design |
| Teeth leakage | MEDIUM | Roll back to fixed safe baseline/no-op, tighten envelope/seeds/plausibility, add protected-tissue positives/negatives, rerun original-detail review |
| Sclera protected-pixel change | MEDIUM | Disable affected eye/provider, restore guard-before-score and final re-clip, add both oracles, recalibrate only after zero leakage |
| Canonical input mismatch | HIGH | Centralize decode/orientation/color ownership, invalidate old saved-output calibration, rerun EXIF/profile/background and every feature gate |
| Cross-mask ordering/overlap bug | MEDIUM | Restore original pixels for collisions, make transforms original-input functions, add standalone/fused/failure injection oracles |
| Sensitive diagnostic/artifact leak | HIGH | Stop emission, remove public/persistence path, purge generated tracked artifacts according to repository policy, rotate/reissue sanitized evidence, rerun security audit |
| Unapproved model landed | HIGH | Remove artifact/dependency/runtime route, audit distribution history and licenses, revert to deterministic/no-op provider, reopen resource/privacy review only with authorization |
| Device performance miss | MEDIUM | Keep correctness oracle, move production to ROI/Metal/Core Image, reuse contexts/buffers, reprofile; retain no performance claim until pass |
| One feature fails final gate | LOW | Ship only independently validated siblings, keep failed row future and affected branch partial, preserve exact nonclaims |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
| --- | --- | --- |
| Proxy/invalid `去脂` | Phase 2, Phase 6 | Genuine positive/negative review; no eye/brow movement; independent non-warp route; exact future/partial ledger if blocked |
| Mechanics treated as product proof | Phase 2 | Manifest validation, approved positive+negative counts per feature, blinded structured review, sanitized export |
| Teeth aperture leakage/side undercoverage | Phase 3 | Fixed-vs-adaptive comparison, no dropped strong pixels, protected-tissue/closed-mouth/no-face gates, original-detail review |
| Over-whitening/wrong polarity | Phase 3, Phase 6 | Yellow/gray/already-light matrix; bounded luminance/channel/texture; human naturalness pass |
| Native color hides iris leakage | Phase 4 | Zero protected changes in color-independent and adversarial final-output oracles |
| Feather escape | Phases 3–5 | Final weighted mask subset of immutable hard envelope; byte-level outside/protected deltas zero |
| Multiple orientation/color/canvas owners | Phase 1, Phase 6 | Exact 8-way EXIF normalization; alpha/non-RGB rejection before Vision; bounded profile fresh/fixed-anchor regression |
| Silent face selection/repeated Vision | Phase 1 | One selected-face request counter and immutable request-context tests |
| Regional failure coupling | Phases 3–5 | Zero-feature and left/right rejection injections byte-match unaffected standalone output |
| Hidden sequential priority | Phase 5 | Original-pixel functions; fused equals independently merged standalone; overlap counted/suppressed/source-identical |
| Biometric-adjacent leakage | Phase 1 and every closeout | Public/SPI/Codable/reflection/log/event/artifact/path/media scans; aggregate allowlist only |
| Unapproved model | Phase 2, Phase 6 | No model/weight/dependency drift; if authorized, complete license/checksum/package/privacy/performance record |
| Full-frame/device performance debt | Phase 5 | ROI/accelerated production path and stage-separated release physical-iPhone latency/RSS evidence |
| All-or-nothing promotion | Phase 6 | Per-feature requirement/evidence ledgers and independent audit; teeth/redness may promote while `去脂` remains future |
| Realtime/alpha/HDR/UI/cloud scope creep | Phase 1, Phase 6 | Target/import/dependency/resource/network/API/ledger scans and explicit nonclaims |

## Explicit Nonclaims That Must Survive Closeout

- v1.14 evidence applies to **still images only**, not camera/realtime/pixel-buffer processing.
- Rejecting transparent input is the current policy; preserving alpha bytes is not transparent-compositing support.
- 8-bit sRGB/Display-P3 testing does not establish HDR, extended-range, or gain-map support.
- Apple Vision lip/eye/brow landmarks provide geometric support, not tooth, sclera-redness, or eyelid-fullness semantics.
- Spike thresholds and coefficients are calibration seeds, not public constants or population-safe values.
- AI fixtures prove mechanics only; `p1.jpg` proves only the feature polarity and review uses explicitly assigned to it.
- macOS/debug/simulator timings are not target-iOS budgets; transform-only time is not end-to-end performance.
- No commercial naturalness, demographic robustness, device parity, packaging, shipping, launch, or release-readiness claim follows from SDK-core automation.
- No external model, third-party beauty SDK, network/cloud behavior, tracked fixture/output media, public raw mask/geometry, or Demo/UI surface is authorized.
- `白牙`, `祛红血丝`, and `去脂` promote independently. If `去脂` fails, it remains future and branch `眼睛` remains partial; passing siblings may still ship.

## Sources

### Project-primary sources (HIGH confidence)

- `.codex/skills/spike-findings-beauty/SKILL.md`
- `.codex/skills/spike-findings-beauty/references/upper-eyelid-fullness.md`
- `.codex/skills/spike-findings-beauty/references/teeth-whitening.md`
- `.codex/skills/spike-findings-beauty/references/sclera-redness.md`
- `.codex/skills/spike-findings-beauty/references/still-image-integration.md`
- `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md`
- `.planning/PROJECT.md`
- `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`

### Official platform sources (HIGH confidence for API behavior)

- Apple Vision face-landmarks request and explicit input face observations: https://developer.apple.com/documentation/vision/detectfacelandmarksrequest
- Apple Vision landmark request revisions and supported-revision behavior: https://developer.apple.com/documentation/vision/detectfacelandmarksrequest/revision-swift.enum
- Apple `VNFaceLandmarks2D` coordinate/support surface: https://developer.apple.com/documentation/vision/vnfacelandmarks2d
- Apple Image I/O orientation semantics: https://developer.apple.com/documentation/imageio/cgimagepropertyorientation
- Apple Image I/O image/color/alpha metadata properties: https://developer.apple.com/documentation/imageio/image-properties
- Apple Core Image context, color management, reuse, and rendering behavior: https://developer.apple.com/documentation/coreimage/cicontext
- Apple Core ML model loading surface (relevant only if a separately approved model path is reopened): https://developer.apple.com/documentation/coreml/mlmodel

---
*Pitfalls research for: Beauty v1.14 Local Facial Retouch*
*Researched: 2026-07-30*
