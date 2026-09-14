# Source-only registrar integration v2

Status: implementation pending independent integration review. The generic
definition is approved at exact hashes in `95-ROOT-METRIC-DEFINITION-FREEZE-v2.json`
and review v3 (commit `a205d973`). Those four frozen files must not be rewritten
to update status prose. This document owns the new adapter, not the mathematics.

## Execution and authority

`python3 scripts/phase95-root-registration.py --self-test` executes generated
adapter and admission probes only. `--register-source` is disabled unless the
independent reviewer creates `95-ROOT-REGISTRAR-REVIEW-v2.json` with the exact
schema, passing status, reviewer ID, empty findings and complete current file
snapshot required by `validate_review`. No command accepts an output directory,
candidate, neutral, sibling, alternate input or alternate metric. Unknown args
are rejected. A valid reviewer receipt authorizes source-only registration, not
portrait scoring or Phase95 completion.

The driver verifies fixed SHA values for the independently approved metric,
spec, provider test, mathematical review, original registration, original
manifest and the current comparator (only the separately verified identity fix
after the original v1 bytes). Adapter/driver/generic-freeze file hashes also
enter the integration review snapshot. At runtime it slices each admitted
source at one exact, unique fixed dispatcher boundary: all original CLI entry
code is excluded. Definitions are joined with the source-only adapter in memory
and sent to `/usr/bin/swift -O -`; neither original standalone file is edited.
This avoids copying or reimplementing the original ROI and canonicalization.
The slices and their admission policy are themselves part of integration review.

Child input is limited to 1 MiB, combined stdout/stderr to 16 MiB, and execution
to 180 seconds using both wall and monotonic time. A writer thread avoids stdin
deadlock. Every exit cleans the owned process group (including descendants),
joins the writer and closes output. Only a schema-checked aggregate result may
escape; arbitrary compiler errors, child transcripts and exception descriptions
are not emitted. No registration result file is written by the driver.

## Source carrier and ROI

Use the same admitted single portrait inventory, byte digest and the original
manifest; no replacement fixture or source-driven constant selection. The
original comparator's canonicalImage implementation performs EXIF orientation,
integral extent, sRGB CG rasterization. The adapter additionally requires an
opaque alpha byte at every pixel and the frozen prototype dimensions/sample
limit. Exact legacy lumaQ8 is divided by 256 without further preprocessing.

Recompute ALL original portrait contracts through the original function, and
require the exact v1 contracts SHA. Extract only the root target after that
check. Root ROI must remain above the original watermark exclusion. Thresholds,
signs, original target/protected rectangles and sibling comparisons are not
redefined here. CanonicalImage and Vision carrier dimensions must agree.

Obtain exactly two finite 3...32 point eye contours from the same canonical
source observation. Map Vision Y once as in the original registration recipe;
take contour min/max boxes. For these NEW explicit measurement exclusions only,
convert to full outward pixel coverage: floor(min*extent), ceil(max*extent).
This conservative eye exclusion rule is not a change to the original acceptance
ROIs. The prototype deterministically sorts and commits the boxes, fixed row
set, source profile and windows. No raw geometry or profile is persisted.

The original recipe and eye extraction are separate Vision requests on the same
admitted canonical source. Their determinism is not assumed: the complete
registration pipeline is executed twice in independent child processes. Both
complete aggregate records must be equal, including source/contract identity,
canonical-plane digest, source-registration commitment, row/exclusion counts and
Vision revision. Recheck source byte identity after each registration. Compiler
version, OS build, OS version, architecture and all reviewed input hashes are
checked before/after both runs. Mismatch or unmeasurability rejects; never retry
with altered rows, ROI, constants, fixture or thresholds.

## Aggregate schema and next boundary

The child returns only versioned status, original source/contracts SHA,
canonical-source/source-registration SHA, registered row count, two-exclusion
count, Vision revision, metric ID, canonicalization enum and
`portrait_scoring_enabled=false`. The parent strictly checks keys, types,
identities, enums and bounded counts, adds attempts=2 and environment/adapter
identities, then prints deterministic JSON. Duplicate JSON fields and old
schemas are rejected even when a content digest could be recomputed.

Registration's canonical source-plane digest binds pixels only through a
cryptographic commitment, not a persistent media artifact. A later scoring
adapter must reconstruct the same registration in memory and match its digest
before touching any output. Future `95-ROOT-METRIC-AMENDMENT-v2.json`, report,
reconciliation, classifier and genuine closeout consumers remain unimplemented
and require separate review. Nothing in this registration grants a live pass.
