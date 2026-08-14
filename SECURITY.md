# SECURITY.md

> Current SDK-only privacy, input/resource trust, and archive safety contract.

## 1. Default Posture

- Process images, frames, parameters, detection support, and effects locally.
- Do not upload or persist raw image/frame bytes, landmarks, masks, pupils,
  teeth/eye geometry, or private fixture locators.
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
| Child test process → gate | bounded one-child transcript reduced to fixed aggregate pass/fail; raw output is not durable authority |
| Generated CPU oracle → gate | regular in-tree Swift sources, in-memory fixtures, no media/path/raw diagnostics, CPU-only tokens, bounded focused execution |

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
- Real-fixture masks must match finite zero-origin dimensions/orientation before
  measurement; synthetic/AI fixtures cannot establish product feasibility.

The mandatory CPU reference oracle is generated entirely in Swift memory from
small RGBA8/sRGB fixtures. Its static preflight rejects media reads, tracked
output writes, absolute/private locators, raw diagnostic printing, and
Metal/GPU/backend scope drift. Rights-approved portrait and native-Vision
tests retain their existing environment guards and remain optional evidence;
their skips cannot satisfy or be counted as generated-oracle success.

## 8. Logging and Evidence

Allowed durable data: fixed error/reason codes, feature/category names, counts,
timings, bounded numeric aggregates, and relative public input/case/output IDs
where the owning CLI/evidence contract permits them. The versioned renderer
report is allowlisted to schema/version, CPU token, case/input/output identities,
unit status/failure code, and reconciled counts.

Forbidden durable data: raw image or mask bytes, absolute paths/locators,
coordinates, landmark arrays, pupil/teeth/vein geometry, rights/reviewer identity,
raw framework errors, child transcripts, generated media, and any raw geometry,
pixels, private fixture metadata, or environment value. CLI paths and child
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
device, commercial, packaging, shipping, launch, or release claims.
