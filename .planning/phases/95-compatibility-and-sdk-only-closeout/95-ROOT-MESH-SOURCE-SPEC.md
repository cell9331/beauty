# Source-only mesh/visible-knot diagnostic

Scope: two bounded observations of the original authorized source, no output
images, scoring, anatomical qualification or milestone acceptance. The user has
requested autonomous completion without manual annotation. This diagnostic
checks the applicability of one combined candidate, not a new product gate.

The existing source transport retains its exact source/manifest/contracts hashes,
canonical opaque sRGB pixels, original16 root rows, original ROI and eye exclusion
bounds. Native source code remains in memory. A nearest-center RGB sample with
longest side at most512 is also exported through the bounded pipe. Original
full-size luminance profiles and row coordinates remain unchanged. This sampling
is only for a semantic prior; it does not change the effect input or its units.

A separate isolated Python worker uses the hash-verified task and18 installed
packages in the clean runtime, with CPU/IMAGE, at most2 faces (to reject ambiguous
multi-face support), no blendshapes/matrices, no camera/audio/file image input,
-I and deny-network sandboxing. A network-denial probe precedes library imports.
All image and landmark data travels through capped in-memory pipes. Native stderr
is discarded, never promoted to JSON. Parent requires exactly one face and478
finite normalized XY predictions; worker rejects changed input pixels.

All intersections with both frozen public candidate chains are retained; there
is no extrapolation or invented closure. Their hull plus one small-image pixel
search padding supplies an exterior-to-interior search band for each root row.
Padding is explicitly not detector-error certification. Bands crossing the
original eye-excluded bounds are unavailable. The visible-knot component searches
local affine flanks, verifies visible support intersecting the band, and retains
all outward alternatives and both lighting polarities. Ambiguity budget failures
are unavailable, never truncated to favorable candidates.

The local fit reuses the earlier exact2-byte residual and4/8/16 supports, with
minimum slope-change signal8. These are model assumptions, not measured anatomy
or modified16-Q16 effect criteria. Source-visible matching and static mesh
correspondence still do not independently establish that a particular detected
transition defines root width. Coverage results cannot be promoted to source
registration. This diagnostic is necessary to see whether this candidate even
has useful source support before end-to-end measurement admission.

The source child has the existing180-second/16MiB bounds; the mesh worker is
bounded to90 seconds/1MiB combined output. All owned child groups are cleaned on
all exits. Snapshot includes source transport, candidate/worker/tests, model,
runtime configuration and interpreter, exact18-wheel inventory and installed
payload bytes. Independent review must match the exact snapshot before source IO.
Before/after snapshots and the two complete aggregate observations must agree.

Persistent output is only source/contracts hashes, attempts=2,16-row coverage
counts, candidate-pair count and false source_registered/portrait_acceptance/
acceptance_credit flags. No pixels, landmarks, geometry, private filenames,
worker transcripts or media are persisted. Unsupported coverage is not an effect
failure or success. The next legitimate decision depends on the actual result,
not on a guaranteed promise that this portrait will qualify.

Runtime executable closure: reject unexpected files and symlinks throughout site-packages. Only exact distribution bookkeeping is hash-bound separately; existing standard source-associated bytecode caches are ignored because each worker uses `-I -B -X pycache_prefix=<fresh empty temporary directory>`. The temporary cache directory is removed after worker process-group cleanup.

Coordinate convention: normalized mesh coordinates use image-edge units. Original row centers query `(y+0.5)/H`; a normalized horizontal intersection maps to profile sample coordinates as `x*W-0.5`. Nearest-center resampling quantization remains covered only as search padding, not a detector accuracy guarantee. Generated odd/even and noninteger-scale center checks cover this mapping.
