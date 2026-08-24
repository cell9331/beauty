# SECURITY.md

> Current SDK-only privacy, input/resource trust, and archive safety contract.

## Current Post-Archive Audit Status

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

- Process images, frames, parameters, detection support, and effects locally.
- Do not upload or persist source image/frame bytes, mapped landmarks, region maps, pupils,
  teeth/eye geometry, or private fixture locations.
- Keep raw/derived support request-local, package-only, non-Codable, and absent
  from public diagnostics, logs, metrics, files, and network payloads.
- Validate every caller/resource/archive input before expensive work or mutation.
- Expose only typed redacted errors, fixed warning reasons, and aggregate metrics.

Any network, cloud, telemetry, external model/resource, account, license, or
distribution behavior requires a new security review.

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
- `去脂` remains future upper-eyelid-fullness work and cannot alias existing eye,
  brow, smoothing, eye-bag, or dark-circle behavior.
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
  are enforced there. The editor cannot bypass that owner or authorize a
  public route.
- Real-fixture masks must match finite zero-origin dimensions/orientation before
  measurement; synthetic/AI fixtures cannot establish product feasibility.
- Phase 78 reuses the Phase 75 child-process evaluator and exports only fixed
  aggregate hashes, opaque IDs, counts, normalized reasons, and a decision.
  Missing or metadata-only evidence cannot authorize tuning or promotion.
- Optional additive-map candidates require separate approved model, data, and
  redistribution rights plus bounded output and identical safety gates. No raw
  candidate output, review prose, private locator, or face-derived artifact is
  persisted, and the current comparator disposition is `not-admitted`.
- Phase 79 consumes the failed decision as a hard authorization boundary:
  internal support/editor symbols cannot be reached through public fields,
  renderer cases, resources, package dependencies, or Testing SPI. The exact
  61/5/74 absence is checked before closeout.
- The current post-archive successor accepts only an explicit repository root
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
configuration are later-phase scope. Existing 61-field parameters, five neutral
presets, generated CPU oracles, 74-case renderer, and archive-only UI/Demo
boundary remain unchanged.

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
evidence. Only the previously authorized private originals may enter the later
external v4 gate, whose durable record remains aggregate-only.
