# SECURITY.md

## Current trust boundary

The SDK-only SwiftPM repository operates inside the owner's controlled local
environment. Swift `public` permits local hosts to call the facade; source,
binaries, model/weights, private fixtures and derived data are not distributed.
No telemetry, upload, remote resource replacement or third-party delivery path
is authorized. A future distribution/dependency/model scope needs explicit
license, privacy and product review first. Actual-use rights matter even for
owner-only use; research-only data and derived models stay in a noncommercial lane.

| Boundary | Enforced ownership |
| --- | --- |
| Caller image/metadata/parameters → SDK | Dimension/format/limit/resource admission and deterministic normalization before dependent work. |
| Vision → providers | Package-only request-local validated support; missing or malformed anatomy fails locally. |
| Provider proposals → output | Immutable original pixels, hard support containment, protected bytes and collision-to-source composition. |
| SDK → host diagnostics | Typed/redacted errors, fixed events and aggregate metrics; no raw support payloads. |
| CLI/process → evidence | Validated output identities/counts, bounded temporary capture and allowlisted aggregates. |
| Historical ZIP → temporary restoration | Independently pinned hashes/manifests, safe streamed extraction and no active-source restoration. |

## Input and resource admission

Public inputs require finite positive dimensions and checked byte/pixel
multiplication. `maximumInputPixelCount` defaults/caps at 50,000,000;
encoded `Data` additionally obeys its byte bound (32 MiB default), one-frame
admission and declared-dimension checks before decode. Active texture has the
smaller 8,388,608-pixel ceiling. Unsupported formats/color and transparent
local-retouch inputs fail through typed errors. Selected GPU stills retain
opaque bounded-RGB admission. See [DESIGN.md](DESIGN.md) for route-specific policy.

Resource IDs are validated logical identifiers, never arbitrary caller paths.
Only bundled manifest/presets/LUTs and retained shader resources are admitted.
The shader bytes, package/backend API boundaries and imports are checked by
`scripts/check-sdk-only-boundary.sh`. External downloads, predictors, training,
conversion and inferred license coverage are not enabled by dormant types or
historical proposals. No registered upper-eyelid model exists.

`BeautyTextureExclusionMask` validates dimensions, checked byte count and binary
0/255 values. The engine rechecks its canonical grid even with neutral texture.
It is owner-supplied information that excludes smoothing/sharpening only, not
automatic skin/material/feature recognition or authority to change other effects.
Its bytes are absent from results, Codable diagnostics and custom reflection;
width/height descriptions are bounded aggregates.

## Request-local geometry and retouch

Landmarks, pupils, contours, source-raster boundaries, masks, integral arrays,
scores, predictor tensors and pixels remain package-only and request-local.
One canonical opaque retouch carrier, one detection/mapping handoff and one
original-source composition owner constrain the request. A valid eye/feature
cannot borrow invalid peer support. Missing, low-confidence, blinking/occluded,
out-of-envelope, duplicate or nonfinite support fails closed per smallest unit.
Reads of protected neighboring pixels guide an edit but never authorize
proposals on those pixels. Composition enforces exterior/protected RGB, source
alpha/metadata, unit ownership/capacity and unexpected-overlap source identity.

Still-image source refiners reject ambiguous hair/skin/lip/head/submental
support instead of reviving the legacy proxy. Geometry overflow changes only
the explicitly reported pre-dispatch capacity route; no points are discarded,
no second detection runs and GPU unavailable/runtime failure never retries.
The capacity metric contains no coordinates.

Upper-eyelid compatibility remains `suspended` and default-hidden. Its bounded
brightness analyzer is not fat/shape truth or natural-effect approval. The
inactive prediction validator has no predictor; invalid/absent predictions
grant no proposal. Failed experiments authorize neither replacement-model
downloads nor training. v1.25 is
[closed with unmet objectives](docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md);
historical provisional acceptance does not override that disposition.

Known coarse-lip/object automatic protection failures remain public limitations.
Correct host object + complete-lip union masks protect their specified texture
pixels but add no automatic recognition credit. Generated inputs can qualify
the particular effect/protection contract they actually pass under
[IMAGE_EFFECT_ACCEPTANCE.md](docs/IMAGE_EFFECT_ACCEPTANCE.md).

## Diagnostics and durable evidence

Allowed durable data is limited to fixed error/reason/event codes, opaque or
relative public case/input/output IDs where allowed, counts, hashes, bounded
timings and approved numeric aggregates. Result diagnostics contain closed
codes/levels; enabling debug/performance does not create a storage or OS-log sink.
Error rendering/redaction is owned by `BeautyError`, not free-form framework output.

Raw pixels, masks, coordinates, landmarks, pupil/tooth/vein geometry, EXIF/
location, private fixture locators, reviewer identity/prose and child transcripts
must not enter tracked evidence. CLI reports reconcile identities and counts;
temporary input/output paths and raw child output are not report fields.
Renderer failure injection stays executable-internal test machinery.
Bounded semantic aggregates never substitute for actual target/protection pixels.
Frozen evidence identities, failures and rejected candidates must not be
rebound, retrospectively weakened or relabeled as current success.

Local authorized portrait/bundle opt-ins validate actual assets and output;
missing rights, masks, polarity or admissible inputs fail the complete gate.
No media becomes tracked merely because the source is generated. Optional
device feedback is sanitized into an issue; photos, landmarks and raw reports
stay local/ignored. Prefer a generated minimal reproduction for a reproducible defect.
No device/commercial/distribution claim is granted by package-host automation.

## Archive recovery and deletion

[archives/legacy-ui/README.md](archives/legacy-ui/README.md) is the historical
access contract. The verifier owns independent ZIP/manifest SHA-256, compressed
size, exact 45/26 file inventories, per-entry and uncompressed/ratio limits.
Entries must be sorted, unique safe files with matching path/size/content hashes,
valid CRC and normalized metadata. Symlinks, traversal, absolute paths,
special entries, duplicate names and unsafe compression are rejected.

Verify before restore. Stream into a nonexistent child of a fresh private
outside-repository temporary directory, with no-follow ownership and cleanup/
rollback on failure. Never restore either retired UI tree over current source,
use it as build input or add application artifacts to SDK targets. Historical
archives and archived milestone evidence remain read-only.

Deletion of retired source/caches requires the owning inventory/digest checks,
confirmed purpose and absence of active use. `.build` contains frozen fixtures,
sources and receipts; remove only confirmed regenerable compile/index/work
copies, retaining historical evidence, ignored required assets and Serena state.
Current documentation cleanup removes only identified obsolete material and
preserves archive/frozen identities.

## Example media retention

[example-images/README.md](example-images/README.md) owns exact quotas and
classification. Total storage is at most 128 MiB/160 images, single images
16 MiB, inputs 16 images/32 MiB. Checks fail rather than automatically delete.
Display previews are ignored JPEGs, at most 32 files, 512 KiB each and 1600 px
long edge; they apply orientation/sRGB conversion and remove source metadata.
Preview rewriting never touches original bytes, masks or fixed-hash inputs.
Original-size validation outputs are disposable; compressed previews are not
pixel-oracle input. Full system/Metal resource peaks are outside these quotas.

Explicit cleanup refuses symlink/mount/special-file or tracked cache entries,
checks current manifests, preserves inputs/current bundles/text/unknown files,
and touches only registered regenerable outputs. These tools assume the
owner's local filesystem; they are not a concurrent-filesystem security sandbox.

## Verification and change routing

Archive verification, boundary self-test/live scan and wrapper mutation checks
are the narrow document/boundary gates. SDK code/contract changes run the
owning public/target tests and the complete archive-first zero-failure/zero-skip
gate described in [QUALITY_SCORE.md](QUALITY_SCORE.md). New data/model/resource
or external access must update this trust contract and actual-use rights review
before implementation. Separately authorized external host UI stays outside
the repository under [FRONTEND.md](FRONTEND.md).
