# SECURITY.md

## 2026-09-26 closed diagnostic vocabulary

Result diagnostics use a closed enum with three fixed codes and the existing
five log levels. The engine emits only an aggregate warning-presence flag,
successful-request event, and gated backend-stage event. No event can embed
raw pixels, masks, landmarks, paths, private locators, parameter values or
framework messages. No system or persistent log is written.

## 2026-09-26 opt-in performance metric

`enablePerformanceLog` emits only one finite nonnegative elapsed-time number
in a successful in-memory result. It never emits raw pixels, masks, landmarks,
encoded bytes, paths, input identifiers or framework diagnostics, and it adds
no persistent or OS logging sink.

## 2026-09-26 whole-face horizontal bounds

`wholeFaceXPosition` uses only the request-local selected-face geometry,
finite unit-bounded coordinates, a capped displacement and one bounded warp
point. Invalid contour or target support fails closed without retaining
landmarks, masks, pixels or private fixture locations.

## 2026-09-26 encoded input admission

The new in-memory encoded still-image entry checks `Data.count` before any
ImageIO work, accepts exactly one frame, verifies declared dimensions against
the configured pixel ceiling before image creation, and validates decoded
dimensions again before dispatch. Malformed or oversized input fails as
`invalidInput` without exposing bytes, paths, decoder details, pixels or face
support in the error. The existing decoded-image and pixel-buffer entries
retain their separate pixel-only admission.

## 2026-09-26 whole-face vertical input boundary

`wholeFaceYPosition` uses validated, request-local selected-face bounds and
the existing face contour. It emits no raw support, coordinates, or pixels in
public metrics or durable diagnostics. Missing or invalid support fails the
field closed. The new control does not add a model, network, file input,
permission, or distribution path.

## 2026-09-26 FACE-01 occluding hair boundary

Short dark bands crossing the cheek are treated as competing source edges
even when their inner return edge is weaker than the outer one. Their rows
fail closed locally; neighboring accepted rows still use request-local source
pixels. Generated tests and the frozen portrait oracle persist only aggregate
results, never the hair pixels or observed contour coordinates.

## 2026-09-26 indexed frame detection boundary

The frame interval never reuses raw landmarks or masks across frames. An
off-cycle face-dependent request has no selected support and cannot retouch a
different face using stale coordinates. Validation rejects negative frame
indices and non-camera/video metadata before processing; the public reason is
a fixed enum and contains no frame pixels or coordinates.

## 2026-09-26 preferred Vision detection boundary

`preferredProcessingSize` is applied only after the source pixel count is
admitted. It cannot turn an oversized original into an accepted request. The
smaller Vision raster is request-local, carries the same redacted support
boundary, and is not exposed in persistent diagnostics.

## 2026-09-26 skin-texture input boundary

The texture transform reads decoded pixels only inside the admitted request,
stores no neighborhood map or image outside it, and emits no pixel-derived
diagnostics. Opaque-footprint and strong-edge guards prevent this bounded
operation from sampling across transparent or strongly different-color
regions. They are not a skin classifier: an unprotected low-contrast background
may be edited. Generated inputs stay in memory; durable evidence records only
aggregate assertions and test outcomes. No model, network, permission, public
raw-pixel API, or private fixture locator was added.
`renderQuality` is a closed three-case enum. It only changes the bounded
request-local neighborhood radius from one to three pixels. It does not add a
source, output channel, persistent cache, or pixel-bearing diagnostic.

## 2026-09-26 FACE-01 source-edge trust boundary

Both bright and dark backgrounds can qualify, but a side must show a coherent
edge direction. Coherent weak contrast and contradictory row directions now
fail closed instead of entering the older point-centered fallback. A short
opaque double-edge occlusion is skipped locally. These checks use request-local
pixels and do not add persistent diagnostics.

The wider cheek correction treats input pixels as untrusted evidence. It
accepts only a coherent opaque outer edge near fresh observed lateral support,
clips all scans and samples to image bounds, and rejects competing outward
edges for the entire side. It does not persist source pixels, contours,
support coordinates, or generated media. Ambiguous or unsupported images
retain the established bounded local behavior or source-exact output.
Generated portrait verification records aggregate results only.

## Current generated-image trust boundary (2026-09-24)

The current no-skip gate accepts a generated Vision portrait only as a regular,
non-symlink file name under `example-images/input/portraits/`; path components
are rejected. Teeth/sclera bundle overrides must retain their ignored-local
manifest boundary and the feature tests' rights and pixel checks. Fixture
provenance alone neither grants nor denies effect credit.

Owner-authorized generated portrait-like inputs may supply effect positives,
negatives, and adversarial cases. They require permission for actual local use
and the same ignored-local storage, request-local mask/landmark handling,
aggregate-only durable evidence, and no-distribution boundary as other
fixtures. Genuine human photos are optional and never a privacy or evidence
prerequisite. See [image-effect acceptance](docs/IMAGE_EFFECT_ACCEPTANCE.md).

## 2026-09-24 audit repair input boundary

Serialized EXIF orientation values outside the defined 1–8 range are rejected;
they cannot silently become an unmirrored `.up` orientation. The configurable
pixel limit is capped at the backend's 50,000,000-pixel hard ceiling, including
Codable initialization. Fractional or nonfinite still-image dimensions are
rejected before expensive detection. Metal geometry exceeding its 256-point
payload budget fails closed. No raw pixels, landmarks, or private fixture
locators are added to persistent diagnostics.
At that audit date, `maximumInputByteCount` was not an enforced decoded-input
guard; the host had to bound encoded files. The new in-memory entry above
checks its encoded bytes; the SDK still does not read file paths.

## v1.24 upper-eyelid change boundary

The editor changes one package-only correction gain inside already approved
per-eye support. It does not admit new pixels or eyes, widen a hard envelope,
alter alpha, add a model/network path, or expose source RGB, masks, landmarks,
private fixture locations, or per-pixel diagnostics. Existing source-exact
rejection and collision behavior remains the trust boundary. Durable v1.24
evidence records aggregate ratios and test counts only.

## Cross-face mapping isolation (2026-09-23)

Malformed detected-face support cannot invalidate a separate mapped face or
lend its geometry to one. Mapping and rejection stay within the request; only
aggregate counts and `.mappingFailed` leave the detector. No coordinates,
landmarks, stable face identities, pixels, or fixture locators are persisted or
added to public diagnostics.

## Source-fixed surface validation (2026-09-23)

The current root method uses the reviewed source-only dorsal marker definition,
not the historical certified-outer-edge requirement below. The validation-only
mesh runtime/model stays outside BeautySDK, is verified against its locked
payloads, and runs in network-denied isolated children. Actual RGB, source
coordinates and decoded cohort data remain in bounded memory pipes. Only typed
counts, conservative intervals and identity commitments enter evidence.

The65 successor consumes the same decoded batch source/root/neutral/three
siblings that the comparator scores. It binds their RGB digests and the fixed
source cohort into the stable payload. A native qualifier may reconstruct
source detection and sampling eligibility but must not rerender replacement
outputs. Historical original-source/ROI and failure receipts remain unchanged.
Default Vision's explicit sRGB CGImage is request-local and never persisted.


## Source-only coverage diagnostic (2026-09-15)

An independently authored exact14-entry review latch admits only bounded
aggregate coverage of the same source/ROI/contracts. Two source-only processes
must agree, with byte/environment identities rechecked. Only support-overlap
counts, fixed false/zero qualification flags, hashes and environment summaries
are exported. The observed11/16 crest and3/16 contour coverage does not grant
source registration, anatomical-boundary qualification or scoring permission.
No image, raw support, private locator or child transcript is persisted. The
original frozen registrar and its ambiguous failures remain unchanged.

## Phase 95 measurement identity and anatomical rows (2026-09-14)

Registrar transport v3 retains strict stdout JSON and separately drains native
stderr without persistence. Both streams count against the same bound; stderr
cannot create success or hide an exit failure. Original v2 reviewer receipt is
not reused for changed code. The observed structural ambiguity stays rejected.

Report validation now checks case-to-metric equality in addition to existing
inventory/verdict/digest checks; all eight recomputed-digest substitution probes
are rejected. This does not create a successor measurement authorization. The
original v1 registration is unchanged, and its comparator hash rejects the
modified implementation until a reviewed successor binding exists.

Root candidate rows partition actual eye extents. At each Y only one admitted
inward pair acts; its monotone map is identity at the local root/eye boundary,
preventing samples from entering protected eye pixels. Entire target disks are
inside their own vertical row and the corresponding horizontal safe interval.
No cross-row slope budget is borrowed. Historical stricter strip constraints
remain documented but are not the current anatomical support contract.

The new metric prototype accepts generated in-memory planes only. Source-only
edge templates/exclusions are explicitly committed and never persisted as raw
geometry or pixels. Positive affine/noise/blur ambiguity is retained as a
conservative position interval, not resolved by picking favorable matches.
Live source registration and scoring remain disabled pending independent review.

The generic draft-2 mathematics has since been independently approved; a new
source-only adapter is pending its own review. It verifies pinned definition/
legacy identities, strips both original CLI dispatchers at exact boundaries,
and composes the reviewed definitions in memory. It admits only the original
single source, opaque canonical pixels and original contract digest. Source
profiles/exclusions never leave memory except as commitments/counts. Process
input/output/deadlines are bounded; all child-group exits are cleaned. Unknown
arguments, stale review, duplicate fields and old source-result schemas reject.

## Internal-bound revision (2026-09-14)

Owner-approved chin/root displacement changes do not raise the 0.8 per-side
slope ceiling. Root inverse-sampling disks, not hypothetical source-centered
disks, are constrained to the canthus interval; the strictly monotone horizontal
map is identity at both interval boundaries, so its samples cannot cross them.
Generated coordinate sweeps and pixel protection tests supplement the analytic
bound. Root sub-cap radii solve containment before emission. Portrait acceptance
thresholds and privacy rules remain frozen, with no automatic promotion.

## Phase 95 ordered inward field bound (2026-09-13)

For horizontal linear cones with all positive-displacement targets preceding
all negative-displacement targets, the positive part of du/dx is bounded by
one side's sum(abs(deltaX)/radius). Requiring each sum <= 0.8 gives the normalized
inverse field a horizontal derivative >= 0.2; between the groups it is >= 1.
Admission checks finite unit coordinates, fixed Y, positive finite radius and
strength, linear falloff, ordered groups and bounded counts. Canonical CPU
sampling applies only to homogeneous admitted sets; this proof is not an
assertion about legacy/mixed sampling or other backends. Input support remains
request-local and non-persistent; no measurement thresholds are relaxed.

Phase 95's observed nose carrier is package-only and request-scoped, has no
Codable conformance, and redacts description/debug/reflection to counts. The
canonical mapper bounds each coordinate and caps each nose array at 32 points;
malformed explicit support stays empty and cannot borrow a legacy template.
Observed lips used by negative mouth and chin remain memory-only. No additional
detector, network, resource, model or persistent anatomical data is introduced.

## Phase 95 registered portrait evidence (2026-09-12)

Owner-authorized ROI registration reads only canonical source pixels and source
anatomy before outputs are evaluated. Its frozen binding contains hashes and
counts, never coordinates, raw support, media or fixture locators. Missing
anatomy, region overlap, changed source/manifest/comparator, or a different
registration digest rejects admission. Gaze direction aggregates cannot replace
target signal, locality or protected-pixel checks. Closeout validates the
runner envelope, recomputes payload digest and verdicts from measurements, and
retains actual measured protection values instead of inventing zero maxima.

> Current SDK-only privacy, input/resource trust, and archive safety contract.

## Current Post-Archive Audit Status

v1.21 activates the existing no-model upper-eyelid mechanics through one
owner-local scalar. This adds no external trust boundary: support, semantic
envelopes, pixels, proposals, and editor summaries stay package-only and
request-local; only `upperEyelidFullnessReduction` crosses the public boundary.
The owner accepts weak current visual quality, while the security posture
continues to fail closed on missing or untrusted per-eye support.
The final archive-first no-skip gate passed `816/0/0` with every opt-in exactly
once and zero skips.

The v1.17 archive at `afb04b4` preserves historical Metal-available evidence
(focused `12/0/0`, full `765/0/0`). Post-archive remediation has restored public
non-up/mirrored raw metadata compatibility (`53e8da1`), separated unavailable-
host typed coverage from GPU parity credit (`d29b90a`), and moved geometry point
payloads into request-local shared `MTLBuffer` storage (`556499a`). The buffer
does not persist points and is released deterministically; only the bounded
scalar count remains inline.

All audit findings now have bounded, mutation-tested dispositions. Backend-
result alpha/extent publication fails closed without retaining pixels. Local
retouch is CPU-owned original-pixel/Q16 composition followed by identity Metal
transport; Metal receives no masks, proposals, support, or source locators.
`.gpu` rejects non-opaque or unsupported RGB before detection and materializes
named-sRGB output. Geometry safety derives its envelope and request support from one
immutable observation with mutation-tested ownership (`a577dd1`). An unavailable
host reports `parity_executed=0` and
never GPU parity success. The current Metal-available branch recorded
`metal_available=1`, `metal_unavailable=0`, `parity_executed=1`,
`focused_tests=13`, and `unavailable_tests=0`. The archive-first closeout passed
on 2026-08-18 at XCTest `776/0/0`, with all eight opt-ins exactly once and
`skipped_tests=0`. This bounded package-host result is not a device, commercial,
or release trust decision; the archived `765/0/0` remains historical.

## 1. Default Posture

- Treat the SDK as owner-only: source packages, binaries, model resources,
  compiled weights, private fixtures, and derived data do not leave the
  owner-controlled environment.
- Process images, frames, parameters, detection support, and effects locally.
- Do not upload or persist source image/frame bytes, mapped landmarks, region maps, pupils,
  teeth/eye geometry, or private fixture locations.
- Keep raw/derived support request-local, package-only, non-Codable, and absent
  from public diagnostics, logs, metrics, files, and network payloads.
- Validate every caller/resource/archive input before expensive work or mutation.
- Expose only typed redacted errors, fixed warning reasons, and aggregate metrics.

Any network, cloud, telemetry, external model/resource, account, license, or
distribution behavior is outside the current contract and requires an
explicitly authorized new security and license review before use. Any internal
commercial use must be explicitly covered by the admitted actual-use license;
research-only data and derived models cannot supply that permission.

## 2. Active Trust Boundaries

| Boundary | Required checks |
| --- | --- |
| Host → public SDK | parameter finiteness/ranges, explicit metadata, supported format/color, finite dimensions, byte/pixel ceilings |
| Preset/resource ID → catalog | schema/version, conservative identifier, bundle membership, typed redacted failure |
| Vision → effects | bounded finite topology, request-local ownership, per-region fail-closed behavior |
| Local retouch → output | canonical opaque sRGB input, original-pixel composition, hard ownership, collision-to-source, checked budgets |
| Private fixture → opt-in test | ignored local bundle, rights/manifest validation, fixed aggregate result, no durable locator/media |
| Archive artifact → historical extraction | exact artifact/digest, safe entry path, manifest/content equality, new temporary destination |
| CLI input/output/report → executable boundary | existing regular directories, supported image decode, duplicate-stem rejection, atomic writes, reopen/dimension validation, bounded public identities only |
| Child test process → gate | bounded one-child output reduced to fixed aggregate pass/fail; raw output is not durable authority |
| Generated CPU oracle → gate | regular in-tree Swift sources, in-memory fixtures, no media/location/private diagnostics, CPU-only tokens, bounded focused execution |
| Automated image input/output oracle → milestone | generated in-memory or rights-approved ignored-local input, actual pixel/metadata assertions, temporary output, aggregate-only durable result; no physical-device dependency |
| Public generic result → concurrency boundary | `BeautyResult` is `Sendable` only when `Output: Sendable`; public field-preserving transfer is tested, while unconditional generic sendability is rejected by the boundary mutation self-test |
| Upper-eyelid public intent → experimental mechanics | positive finite scalar only; selected request-local observation; per-eye brow/eye envelope; source-derived relief approval; bounded channel deltas; immutable-source composition; no model/network/persistent anatomy |

## 3. Archive Entry and Extraction Safety

The exact retained artifacts live under `archives/legacy-ui/`. Verification must
fail closed when any ZIP, manifest, digest record, entry, or extraction differs.

Required invariants:

- only `BeautyDemo-v1.16` and `meituxiuxiu-v1.16` bundles are accepted;
- archive records use lowercase 64-hex SHA-256 bound to the exact ZIP filename;
- independent code-owned anchors pin both ZIP and manifest digests, exact
  inventories/counts, compressed and uncompressed totals, per-entry maxima, and
  compression-ratio ceilings; adjacent mutable records cannot re-authorize drift;
- entry names use forward-slash relative paths rooted under the exact source
  name, contain no absolute path, `.`/`..`, empty component, backslash, or NUL;
- entries are sorted, unique, file-only, normalized, and equal to their manifest;
- every extracted byte count and SHA-256 equals the manifest;
- decompression starts only after all archive-wide metadata/resource bounds pass,
  and each entry streams through bounded hashing into a newly created temporary
  directory without creating a symlink;
- review restoration never targets the repository or an existing directory.

Do not trust a general archive extractor before these checks. The Python verifier
performs entry validation before writing each extracted file and then independently
walks the extraction for exact equality.

## 4. Digest-Bound Deletion

The original-source retirement contract permits only the two exact top-level
non-symlink directories and only after fresh verification/reproduction.

- approval binds both exact source names to their current verified ZIP digests;
- any pre-existing tracked deletion fails before mutation; tracked deletions are
  then precomputed and compared as an absolute exact allowlist;
- SDK/docs/planning/private-fixture sentinels are fingerprinted before mutation;
- both roots move to an outside-repository quarantine before the frozen bytes are
  re-inventoried and reproduced against the pinned manifests/ZIP digests;
- deletion-set and sentinel postconditions are checked before quarantine removal;
- any pre-final failure restores both roots in reverse order;
- no glob, unresolved environment variable, broad recursive target, or partial
  single-root approval may authorize deletion.

The completed deletion transaction is historical. Running retirement again when
the roots are absent must fail; recovery uses the retained archives, not a second
destructive transaction.

## 5. Recovery and Historical Access

Before recovery, run the verifier, create a fresh private parent, and let the
same tool restore the already validated snapshots:

```bash
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
restore_parent="$(mktemp -d "${TMPDIR:-/tmp}/beauty-legacy-ui-restore.XXXXXX")"
python3 scripts/archive-legacy-ui.py restore --output archives/legacy-ui \
  --destination "${restore_parent}/legacy-ui"
```

Restore only into a new temporary directory outside the repository. After review,
delete that temporary copy through an explicitly scoped local operation. Never
copy either root back into the repository; the post-archive scanner treats any
restoration as a boundary violation.

If an archive is corrupt, missing, symlinked, or digest-mismatched:

1. stop without extraction or mutation;
2. preserve the active SDK tree unchanged;
3. recover the exact committed archive artifact from trusted Git history;
4. rerun full verification; and
5. proceed only after both bundles pass.

Do not recreate a historical archive from memory or substitute a similarly named
artifact.

## 6. SDK Input and Resource Validation

- Public dimensions must be positive, finite, integral where required, and at or
  below configured ceilings before allocation/detection/render work.
- Unknown/non-output-capable/extended-range color and transparent local-retouch
  input fail through existing payload-free typed errors.
- Public numeric parameters normalize deterministically; non-finite values become
  documented no-op values before safety caps.
- Resource IDs are logical identifiers, never arbitrary paths.
- External packages/downloads remain disabled until type/size/path/integrity/
  cache/licensing/privacy behavior is explicitly designed.
- The retained shader file is byte-pinned; v1.16 rejects modification, additional
  shader sources, or public/backend drift.

## 7. Local-Retouch Privacy and Safety

- Canonical input, Vision support, provider masks/proposals, and composition owner
  remain within one request.
- Missing/malformed/closed/occluded/low-confidence support fails per smallest
  region without stale, mirrored, cached, or proxy recovery.
- Accepted edits derive from original canonical pixels and hard-reclipped masks;
  unexpected overlap preserves source.
- Teeth coverage remains fixed to its qualified inner aperture. Sclera work
  preserves iris, pupil, highlight, lash/lid, skin, caruncle, exterior, alpha,
  and colored-interior protections.
- Provisional `去脂` is exposed only as `upperEyelidFullnessReduction` and
  cannot alias existing eye, brow, smoothing, eye-bag, or dark-circle behavior.
  Internal experimental names and weak-effect history are not public support or
  efficacy claims.
- Phase 76 support remains package-only and request-local. A mapped eye envelope
  can constrain ownership but cannot authorize fullness; an injected semantic
  owner must approve each eye independently. Missing, malformed, ambiguous,
  closed, blinking, occluded, non-finite, duplicate, out-of-bounds, or
  outside-envelope support returns a typed source-exact no-op.
- The single-observation support handoff calls Vision once and releases support
  after the request. Descriptions and mirrors contain only aggregate status,
  confidence, counts, and reason codes; raw support arrays, coordinates,
  landmarks, masks, pixels, and private locators never enter durable evidence.
- Phase 77’s editor accepts only independently approved per-eye support and
  clamps every source-safe channel delta before proposal emission. It never
  writes raw pixels or masks to diagnostics, and rejected eyes remain
  source-exact without affecting an eligible peer.
- Final composition is still owned by the existing composition owner: exterior
  and protected bytes, alpha, metadata, and overlap-to-source collision policy
  are enforced there. The editor cannot bypass that owner; the public facade
  may invoke it only through this existing owner chain.
- Fixture masks must match finite zero-origin dimensions/orientation before
  measurement. The historical Phase 78 evaluator classified its own
  synthetic/AI inputs as mechanics-only; new authorized generated portraits
  may establish owner-local effect evidence under the current policy.
- Phase 78 reuses the Phase 75 child-process evaluator and exports only fixed
  aggregate hashes, opaque IDs, counts, normalized reasons, and a decision.
  Missing or metadata-only evidence cannot authorize tuning or promotion.
- Optional additive-map candidates require separate approved model, data, and
  redistribution rights plus bounded output and identical safety gates. No raw
  candidate output, review prose, private locator, or face-derived artifact is
  persisted, and the current comparator disposition is `not-admitted`.
- Historically, Phase 79 consumed the failed decision as an authorization boundary:
  internal support/editor symbols cannot be reached through public fields,
  renderer cases, resources, package dependencies, or Testing SPI. The exact
  61/5/74 absence was checked at that closeout. v1.21 supersedes only the
  current public-surface decision and does not rewrite that archive.
- The current historical-binding successor accepts only an explicit repository root
  and resolves each Phase 75/78/79 artifact from exactly one active or archived
  v1.18 location. Missing, duplicate, non-file, unreadable, and symlink inputs
  fail closed with normalized reason identifiers; caller cwd cannot redirect
  artifact ownership. Self/mutation diagnostics persist no child transcript,
  repository/private locator, raw pixel, mask, landmark, support, or review
  prose.

The mandatory CPU reference oracle is generated entirely in Swift memory from
small RGBA8/sRGB fixtures. Its static preflight rejects media reads, tracked
output writes, absolute/private locators, raw diagnostic printing, and
Metal/GPU/backend scope drift. Rights-approved portrait and native-Vision
tests retain their existing environment guards and remain optional evidence;
their skips cannot satisfy or be counted as generated-oracle success.

The public `BeautyResultConcurrencyTests` result is aggregate-only evidence:
3 tests pass with zero failures, including a complete async transfer of a
sendable payload and all public result fields. Non-sendable payloads remain
outside the positive contract; the boundary self-test mutates a temporary
fixture to the historical unconditional declaration and requires rejection.
No payload, support, pixel, mask, landmark, fixture location, or child output
is persisted.

Physical-iPhone testing is optional post-SDK user evaluation, not a mandatory
trust boundary or milestone gate. Any later user feedback must be reduced to a
sanitized issue description before durable recording; do not persist submitted
device photos, raw outputs, masks, landmarks, EXIF/location data, private paths,
or unredacted diagnostic payloads. Prefer a generated minimal reproduction; if
an authorized real fixture is necessary, keep it ignored and local under the
existing manifest/opt-in contract.

## 8. Logging and Evidence

Allowed durable data: fixed error/reason codes, feature/category names, counts,
timings, bounded numeric aggregates, and relative public input/case/output IDs
where the owning CLI/evidence contract permits them. The versioned renderer
report is allowlisted to schema/version, CPU token, case/input/output identities,
unit status/failure code, and reconciled counts.

Forbidden durable data: source image or region bytes, absolute locations/locators,
coordinates, landmark collections, pupil/teeth/vein geometry, rights/reviewer identity,
raw framework errors, child output, generated media, and any private geometry,
pixels, private test metadata, or environment value. CLI paths and child
output are untrusted and remain temporary; relative public identities are the
only path-like values permitted in the durable report. The executable-local
render/encode failure seam is test-only machinery and must not become a flag,
public SDK API, help text, diagnostic payload, or report field.

The release default remains redacted and local; no data collection or upload is
claimed. Reassess privacy-manifest needs before adding required-reason APIs,
third-party dependencies, collection, or distribution scope.

## 9. Required Gates

```bash
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
bash scripts/check-swiftpm-consumer.sh
bash scripts/check-cpu-reference-oracles.sh
bash scripts/run-no-skip-swiftpm.sh
```

These gates authorize SDK-core repository correctness only. They do not authorize
device, commercial, packaging, shipping, launch, or release claims. Their
completion also does not wait for physical-iPhone access or post-SDK user
feedback; that evidence is supplemental unless a later user decision explicitly
creates a device-focused scope.

## Phase 89 Semantic Validation Trust Boundary

The semantic manifest and every `--input`, `--output`, and `--report` value are
untrusted. Before mutation, the runner requires the exact live/selected/semantic
inventory `75/65/8`, schema `beauty.face-feature-batch-report.semantic.1`, and
regular non-symlink descendant paths with no input/output/report overlap.
Unknown or duplicate inventory, unsafe path components, stale destinations,
decode/dimension failures, or incomplete renderer output fail closed without
borrowing a prior result.

Decoded pixels and target, sibling, outside, ROI/support, protection, and
watermark geometry are request-local. The durable allowlist contains only the
aggregate `stableSemanticPayload`, fixed schema/contract and CPU identifiers,
opaque fixture IDs/counts, fixed case/direction identities and reasons, bounded
source/neutral/target/outside/protected metrics, verdicts, and digests. Source
paths or locators, raw media or pixels, masks, landmarks, pupil/anatomy values,
private geometry or metadata, raw framework errors, and child transcripts are
forbidden. Parameter watermarks remain only in ignored first-attempt PNGs and
are excluded from measurement.

Two fresh attempts must complete the same 75/65/8 contract and reconcile the
same completion class, canonical `stableSemanticPayload` bytes, and digests
before atomic publication. The retained first attempt contains only ignored
watermarked PNGs. Successful semantic publication requires verified cleanup
of repeat media, renderer/comparator reports, workspaces, and transcripts. A
`cleanup_failure` publishes no creditable semantic result and means removal
could not be verified; the owner must contain and remove any remaining
artifacts locally. Complete deterministic failure is
`semantic_fail` at exit 3 and remains trustworthy aggregate measurement. Any
admission, render, output, report, stale-state, or determinism fault is the
separate exit `2` `infrastructure_failure`. The report destination is
admitted independently before input/output admission: when it is structurally
safe and distinct, descriptor-relative atomic replacement publishes a
sanitized current envelope so no stale prior report remains creditable. An
unsafe or aliased report path is never mutated; exit 2 then invalidates any
pre-existing document for the invocation.

Metric admission is all-or-nothing. A source, neutral, candidate, or sibling
metric failure cannot be serialized as a completed direction with the original
fixture count. In particular, gaze remains non-creditable because this
milestone has no independently admitted request-local pupil/own-eye anatomy;
dark pixels, lashes, shadows, and foreign patches are forbidden proxies. The
fixed `unsupported_metric` category stays transient and reaches only the
sanitized infrastructure envelope—no anatomy or abstained-row detail persists.

This owner-local boundary preserves the current 62/5/75 public inventory,
still-image facades, CPU/GPU policy, and local-retouch exclusions. It grants no
device, population, naturalness, commercial, packaging, shipping, launch,
release-readiness, or distribution authority.

## 10. Phase 70 Backend Privacy Contract

`BeautyBackendRequest` is an internal, non-Codable trust boundary. Selected
support, canonical still-image storage, and composition state are request-local
and released with the synchronous execution. `BeautyBackendResult` admits only
the matching pixel-buffer or `CIImage` output plus `BeautyBackendDiagnostics`;
diagnostics are limited to dimensions, alpha/extent flags, and bounded
unit/failure/collision/change counts. They contain no support payload, geometry,
landmark values, raster bytes, path-like data, or framework error detail.

The contract keeps `.cpu` as the only Phase-70 policy and does not add a public
backend selector, parameter/preset key, Metal import, or new algorithm. CPU is
the current reference. Metal resources/passes and public `.cpu`/`.gpu`
configuration were later-phase scope. At Phase 70 the 61-field parameters, five
neutral presets, 74-case renderer, and archive-only UI/Demo boundary remained
unchanged; the current v1.21 surface is 62/5/75.

## Phase 71 Metal Runtime Trust and Privacy Contract

The package-internal `BeautyMetalRuntime` is owned by `BeautyRender`, while
`BeautyEffects` owns the package-only `BeautyMetalBackend` executor. The
runtime validates dimensions and RGBA8 byte counts before allocation, creates
bounded device/queue/pipeline/texture/buffer/command resources, encodes the
retained identity transaction, synchronizes and inspects terminal status,
materializes the matching output, and releases every request resource on both
success and error. No host Metal device is an explicit `.metalUnavailable`
terminal outcome; it cannot be credited as GPU success, CPU fallback, or retry.

Only aggregate status and bounded diagnostics are allowed across this trust
boundary. Support, raster, texture, framework, geometry, and path details stay
request-local and are never persisted. The runtime has no application, UI, or
capture lifecycle dependency, and `BeautySDK` exposes no public backend
selector in Phase 71. The existing dependency direction, 61-field parameter
model, five presets, 74 renderer cases, archive boundary, and local-retouch
privacy rules remain authoritative.

The static/runtime preflight is itself bounded and emits fixed aggregate
markers, including separate `metal_available` and `metal_unavailable` values,
zero failure/skip accounting, and no child output or framework error detail.
Phase 72 owns feature passes, Phase 73 owns public `.cpu`/`.gpu` configuration
and typed availability policy, and Phase 74 owns generated parity/no-skip
closeout. This evidence makes no simulator/physical-device, performance,
commercial, packaging, shipping, launch, or release-readiness claim.

## Phase 72 Local-Retouch Metal Trust Boundary

`BeautyLocalRetouchCompositionOwner` is the sole trust boundary for teeth and
sclera proposals, hard envelopes, duplicate/collision handling, and original
source binding. The Metal backend accepts only its canonical RGBA8 carrier and
six bounded counters. Those carrier bytes are already composed on CPU; the
composed-retouch kernel is an identity-preserving
boundary pass; it cannot reconstruct support or inspect provider units. A
terminal Metal failure publishes no partial carrier and leaves no request
resources active. Generated in-memory coverage verifies protected bytes,
alpha, containment, collision-to-source, smallest-unit isolation, and mixed
pass ordering without persistent private payloads. Public `.cpu`/`.gpu`
configuration and broad parity claims remain outside this phase.

## Phase 73 Backend Configuration Trust Boundary

`BeautyConfiguration.renderBackend` is the sole public backend-policy input and
contains exactly `.cpu` or `.gpu`; it is not part of `BeautyParameters` or
preset data. New and legacy/missing-key configurations default to `.cpu`.
`BeautySDK.BeautyBackendFactory` is the package-owned immutable selection point:
`.cpu` preserves the permanent reference, while `.gpu` constructs the package
Metal backend. A missing Metal capability returns terminal
`.metalUnavailable`; no CPU fallback, retry, or success classification is
allowed. Package-only injection is test-only and cannot become a host escape
hatch.

Historical durable Phase 73 evidence is restricted to aggregate focused/full counts and
availability classifications: configuration `16/0/0`, runtime `34/0/0`, full
`753/0/0`, eight opt-ins exactly once, `metal_available=1`, and
`metal_unavailable=0`. No pixels, masks, landmarks, framework objects, paths,
or private fixture locators are persisted. Phase 74 parity remains separate;
UI/Demo, simulator/device, performance, commercial, packaging, shipping,
launch, and release-readiness claims remain excluded.

## Phase 74 Historical Generated Parity Trust Boundary

Generated in-memory RGBA8 inputs cross into CPU and Metal only through the
validated backend request. The parity suites retain aggregate kind, dimensions,
alpha/extent flags, named color metadata, changed counts, and bounded deltas;
raw pixels, masks, landmarks, support, paths, and fixture locators remain
request-local. Mutation checks reject removal of CPU comparison, weakened
tolerances, omitted safety suites, raw file output, and availability merging.

The archived gate records focused `12/0/0`, full `765/0/0`, eight opt-ins
exactly once, and separate `metal_available=1` / `metal_unavailable=0`.
`.metalUnavailable` is terminal and never GPU parity success or CPU fallback.
The repaired current gate reports `focused_tests=13` / `parity_executed=1`
only when Metal is available; unavailable-host typed coverage reports
`parity_executed=0`. The bounded current result does not authorize transparent
input, end-to-end GPU local retouch, shared-instance parallel safety, or broad
release equivalence. UI/Demo,
simulator/device, performance, commercial, packaging, shipping, launch, and
release-readiness claims remain outside the trust boundary.

## v1.19 Phase 80 Candidate-v3 Support Trust Boundary

Candidate v2 narrowed upper-eyelid ownership from an eye-aligned rectangle to a
same-side brow-to-lid permitted band. The resolver rejects missing/malformed
brows, implausible or crossed gaps, insufficient horizontal overlap, malformed
dimensions, duplicate pixels, invalid Q16 weights, and pixels or hard envelopes
outside the permitted region. A semantic owner remains mandatory; eye/brow
landmarks and the feather helper cannot authorize fullness by themselves.

Every accepted pixel carries request-local soft ownership no greater than its
elliptical boundary ceiling. Weights, masks, landmarks, raw pixels, stable IDs,
and support geometry have no Codable/public surface and are released with the
request. Diagnostics expose only side/status/confidence/reason and aggregate
pixel counts. The immutable-source composer still owns exterior/protected
bytes, alpha, foreign/duplicate units, and collision-to-source behavior.

Candidate v3 retains that ownership boundary and changes only the editor's
request-local correction: one shared, non-positive, clipping-safe scalar is
used for the accepted eye before Q16 feathering. This removes the v2 path where
neighboring source-derived corrections could flip sign while preserving the
same fail-closed ownership and immutable-source composer.

The rejected v1 private bundle/review and the automated-failed v2 bundle remain external. Durable remediation
evidence contains only fixed test counts, normalized dispositions, and public
inventory facts; it does not retain private paths, media, geometry, metric rows,
rights details, reviewer identity, or freeform text.

## v1.19 Phase 80 Candidate-v4 Relief Trust Boundary

Candidate v4 reads source RGB only for the already admitted request-local
brow-to-lid support. Its derived luminance samples, integral arrays, fitted
plane, convexity score, corrections, and pixel proposals are non-Codable,
package-only values released with the request. They are not logged, cached,
exported, embedded in decisions, or sent to a model or network service.

Source-derived relief may authorize applicability only inside the independent
eye/brow envelope and existing pose/occlusion guards. It cannot expand support,
move geometry, authorize a peer eye, or create a public `去脂` route. Malformed
dimensions, duplicate/out-of-bounds pixels, invalid weights, unsolved planes,
and sub-threshold or negative relief fail closed. Immutable-source composition
continues to own exterior, protected, alpha, foreign, duplicate, and collision
pixels.

Public web examples are concept references only. They are not downloaded into
the repository, used as fixtures or training data, or credited as qualification
evidence. Only the previously authorized private originals entered the frozen
external v4 gate; its terminal durable record remains aggregate-only.

## v1.19 Learned Upper-Eyelid Model Trust Boundary

Candidates v1-v4 are terminal and their source-derived scores cannot authorize
an owner-local edit. Plan 80-19 admits a learned model only after data rights
explicitly cover the actual owner-only use: ML research/training, retouched
derivatives, target-author ownership, retention, and local derived-model use.
Compiled-weight redistribution rights are not a current gate because model
distribution is prohibited. FFHQR, PPR10K, or another non-commercial/research-
limited corpus may enter only an isolated non-commercial local research path
under its upstream terms; it cannot authorize commercial use, external transfer,
or a future distributed checkpoint and still does not supply the exact
upper-eyelid-fullness targets required for qualification.

The future model resource is owner-local only, versioned, checksum-pinned, size-
reviewed, and centrally resolved; caller paths, remote downloads, dynamic model
replacement, and unknown third-party weights are rejected. The model receives
only request-local canonical per-eye RGB plus permitted/protected priors. Crops,
tensors, landmarks, masks, flow, tone, confidence, uncertainty, and pixels are
released with the request and never enter Codable/public diagnostics or durable
evidence. Durable records allow only aggregate counts, normalized dispositions,
tool/model digests, and license-approval status.

Any later proposal to monetize, publish, deliver to a customer, register a
package, ship an App, or transfer a model/weight invalidates the current license
admission and requires a new audit of every portrait, target, annotation,
checkpoint, derivative, and resource.

Prediction validation fails closed on resource absence or mismatch, unsupported
platform, compilation failure, malformed shape, NaN/Inf, low confidence, high
uncertainty, out-of-support alpha/flow/tone, non-zero protected/boundary flow,
excess displacement, or fold-over risk. Eye aperture, lash, iris/pupil, sclera,
brow, protected crease, exterior, overlap, and alpha remain immutable-source
owned. The learned field never enters the public geometry pipeline or retained
`Warp.metal`.

Plan 80-20 implements the no-model portion of this boundary without importing
Core ML or adding a resource. Requests independently validate canonical bytes,
dimensions, containment, unique support, and protected/support disjointness
before any predictor call. Predictions validate side, finite scores, exact
sample ownership, alpha ceiling, feather-boundary zero, bounded/smooth flow,
positive local Jacobian, and bounded/smooth tone. Diagnostics expose only side,
normalized reason, and accepted sample count; validated tensors remain request-
local. The rejected heuristic is available only under explicit
`BeautyExperimentalUpperEyelid*` package names and has no public/facade route.

The owner canceled the remaining `去脂` data/model path on 2026-08-25. No
portrait corpus, target, checkpoint, compiled weight, or model resource is to
be admitted under v1.19; retained experimental source does not reopen any
privacy or resource boundary. A future retry requires a new explicit audit.

## Phase 90 Chin Repair and Contour Deferral Trust Boundary

Promotion from the terminal FACE-01 summary into durable owner documents is an
untrusted claim boundary. Before synchronization, the summary must be a regular
non-symlink file with `status: completed-deferred`,
`promotion_eligible: false`, and no completed requirement. Revision 22 may
contribute only the aggregate diagnostic classification
`prior_stop_not_reproduced`, its single request-local reconstruction, matching
admission/final counts, zero render/oracle invocations, byte-exact rollback,
temporary-symbol absence, and rollback-verifier result. None may be promoted
to semantic, repair, effectiveness, or GREEN authority.

FACE-02 consumes contours, the interpolated median, control points, and source
pixels only within the current request. Bilateral ownership, X-only bounded
movement, protected pixels, failure isolation, and immutable input ownership
remain enforced by the existing provider and public-facade tests. Durable
evidence is aggregate only. Raw anatomy, contours, medians, coordinates,
landmarks, masks, pixels, private fixture locators, generated media, and child
transcripts must not enter owner documents, summaries, diagnostics, or logs.

The trust surface remains exactly 62 stored parameter fields, five presets, 75
renderer cases, `BeautyEngine.processResult(image:metadata:parameters:)`, and
`BeautyEngine.process(image:orientation:parameters:)`. CPU remains the
reference; selectable GPU either succeeds through retained `Warp.metal` or
terminates with typed `.metalUnavailable` without fallback. Phase 95 owns the
direct one-step-above-neutral, cap-adjacent, quantization-threshold-adjacent,
and tie tests, plus the clean 65-output seven-effective-plus-one-deferred
publication and complete no-skip closeout.

Package-host automation remains owner-local and SDK-only. It authorizes no
device or population qualification, commercial quality, packaging, shipping,
launch, release readiness, or distribution. Any future FACE-01 work belongs to
separately authorized FUTURE-04 and cannot inherit revision-22 diagnostic
credit.

## Phase 91 Independent Gaze Correction Trust Boundary

Observed eye contours, centers, pupils, clearances, control points, masks, and
source/output pixels are request-local or test-local values. They are neither
Codable nor public diagnostics and must not enter summaries, logs, renderer
status, retained reports, paths, or transcripts. A valid eye cannot borrow the
peer's support, and observed-but-invalid support never falls back to legacy or
proxy anatomy.

The durable evidence allowlist is exactly six bounded aggregate meanings:
eligible, corrected, and rejected counts; all-reduced; abstained; and minimum-
reduction Q16. The renderer spelling is exactly `eligibleCount`,
`correctedCount`, `rejectedCount`, `allReduced`, `abstained`, and
`minimumReductionQ16`. The values are admitted only on the matching successful
CPU gaze unit after schema, input, case, output, backend, uniqueness, integral
range, and algebra checks. Missing/extra/duplicate/fractional/nonfinite,
contradictory, wrong-identity, replayed, stale, aliased, proxy-only, or sibling
evidence is rejected rather than repaired.

Direction credit remains conjoined with actual-pixel target, sibling, locality,
contour, brow, background, and watermark gates. Both attempt report trees stay
under verified no-follow ownership until comparison, then are removed and
verified absent before publication. The boundary suite passed with
`report_cleanup=6`; any residue or deletion uncertainty is a sanitized
infrastructure failure with no semantic credit.

All Plans 91-01 through 91-03 used implementation attempt 1. Comparator
self-test passed 576 mutations, backend-neutral privacy/inventory gates passed,
both archive hashes verified, and the post-archive SDK-only boundary passed.
The 62/5/75 surface, public facades, CPU/GPU policy, and retained `Warp.metal`
are unchanged. Phase 95 alone owns authorized portraits, clean 65-output
publication, and the full no-skip closeout; Phase 91 grants no device,
commercial, release, or distribution authority.

## Phase 93 Evidence Admission and Privacy Boundary

The owner-local trust boundary is request-local support to field emission and
measured receipts to claims. Current independent code review and
[93-CHECKS.json](.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-CHECKS.json)
bind the exact candidate, frozen tests and validator identities. Regular,
non-symlink path admission, immutable hashes, bounded child capture, exact
method discovery, fail-closed RED classification and aggregate-only export
remain required. Raw support, pixels, masks, private locators and transcripts
are not durable evidence. No network, authentication, model or service boundary
was introduced.

The original gate remains `873dba5a...`; its bindings are unchanged. The three
reviewed entrypoints form the recovery chain:
`check-phase93-attempt2.py` (`4b07195c...`),
`check-phase93-timeout-recovery.py` (`eb7ccc0f...`), and
`check-phase93-regression-closeout.py` (`7ff1598b...`).
CHECKS plus `93-TIMEOUT-AMENDMENT.json` and
`93-REGRESSION-DISPOSITION.json` retain full identities and receipt provenance.
Compatibility/check receipts 53/54 belong to the timeout runner; regression
56 belongs to the new closeout runner. Reuse of completed receipts is explicit,
not a claimed rerun or retroactive rebinding.

Two substantive candidates were consumed. Candidate-1 failure, timeout 39,
rollback 40 and supplemental scope error 55 remain immutable. The last
disposition admits only that exact extra selection error; new failures still
block acceptance and support owned rollback. Its fresh 106/0/0 deterministic
regression grants no credit to excluded portrait tests. Separate core,
compatibility and script gates passed 36/0/0, 229/0/0 and 8/0/0.

Independent goal verification passed. Phase 95 owns private portraits,
final 65-output evidence and full no-skip closeout. No device, commercial or
external-distribution authority is conferred.

Independent goal verdict: [93-VERIFICATION.md](.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-VERIFICATION.md), 18/18 must-haves and zero blockers.

## Phase94 Negative Mouth-Width Evidence Boundary

MOUTH-01 acceptance is bound to `94-REMAINING-CHECKS.json` SHA256
`fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4`.
Historical prerequisites remain immutable at their original provider identity.
The current exception admits only the reviewed private negative provider
addition through a counted begin, exact compile receipt, independent review,
seal and fresh41-method acceptance. All other pinned code/tests remain exact.

The initial runner and seed are preserved under the separate independently
reviewed authoring disposition. Strict event replay validates writes before
append; exclusive receipts publish atomically and orphaned/interrupted receipts
cannot grant completion. Current inputs, history and reviews are checked around
each bounded child. Native output is capped at8MiB in memory, with owned-process
cleanup; only fixed markers, reconciled counts, bounded aggregates and digests
enter durable evidence. Generated pixels, masks, geometry, private locators
and native transcripts remain request-local and are not persisted.

Both original defects and the failed policyA attempt/rollback remain recorded;
policyB is attempt2/2, with no hidden retry or threshold edit. No external
dependency installation, new public API, service, model/data, shader/backend,
UI or redistribution scope was introduced. Phase95 private portraits/final65/
full no-skip and device/commercial/release qualification remain separate.

## v1.23 FACE-01 Raster and Evidence Boundary

The contour refiner reads only the current request's canonical RGBA8 bytes
and observed support. It produces no persistent mask, contour, coordinate,
pixel, or fixture locator. It copies source alpha and edits RGB only when the
destination and both interpolation neighbors are fully opaque; invalid
dimensions, overflow, nonfinite geometry, missing support, and out-of-bounds
samples fail closed. The two lateral bands exclude the central chin; field
emission is checked before raster work. The owned image copy is released with
the request and does not change public diagnostics.
The bounded strong-edge scan reads only four horizontal source pairs per row
near each observed lateral crossing; it retains no edge map or pixel-derived
state after the request.

Current portrait evidence remains aggregate-only. The historical Phase 95
FACE-01 fixed ROIs cannot be treated as anatomical protection proof for a
natural portrait; the source-admitted exploratory ROI was not promoted into
the signed comparator. No raw pixels, coordinates, private paths, or child
transcripts enter durable evidence. The existing owner-local, non-distributed
boundary remains in force.
