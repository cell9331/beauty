# Phase 67 Validation Contract

**Status:** Draft execution contract  
**Research:** Explicitly skipped by user; no `67-RESEARCH.md` or UI specification is authorized.  
**Boundary:** SwiftPM library/CLI only; generated synthetic inputs; no UI, Demo,
simulator, device, Metal/GPU public API, remote package, or release claim.

## Decision Traceability

The locked bullets in `67-CONTEXT.md` did not carry identifiers. Plans use the
following stable, order-preserving labels so executors and checkers can trace
every decision without rewriting the source context.

| ID | Locked decision |
| --- | --- |
| D-01 | External consumer depends on and imports only the public BeautySDK project product; no internal/test/Demo/Xcode/device seam. |
| D-02 | Use a small repository-owned external local-path SwiftPM executable fixture. |
| D-03 | Generate consumer input entirely in Swift with no tracked media. |
| D-04 | Assert public success, exact dimensions, neutral semantics, and concrete output observation. |
| D-05 | Preserve the exact 74 cases and compatible input/output/case/no-watermark flags; add deterministic case discovery and reporting. |
| D-06 | Require explicit render output and no UI/Demo/simulator/device dependency. |
| D-07 | Accept the CPU CLI token only; reject GPU/unknown values until v1.17 without a public SDK backend switch. |
| D-08 | Emit one versioned aggregate JSON report with reconciled counts and privacy-safe bounded identities. |
| D-09 | Return stable typed nonzero failures for all listed argument/input/decode/render/encode/write/output/report faults. |
| D-10 | Exit zero only when every requested input×case output exists, decodes, is non-empty/same-dimension, and counts reconcile. |
| D-11 | Keep generated output/report ignored and reproducible; tests use cleaned temporary directories. |
| D-12 | Exercise the compiled executable through SwiftPM and Foundation Process, never a disconnected parser-only test. |

## Nyquist Matrix

| Requirement | Owning plan | Automated evidence | Required assertion |
| --- | --- | --- | --- |
| SPM-01 | 67-01 | `bash scripts/check-swiftpm-consumer.sh` | Clean scratch resolve/build/run; only local public BeautySDK product and no internal import. |
| SPM-02 | 67-01 | `bash scripts/check-swiftpm-consumer.sh` | Generated 4x3 RGBA input; public neutral result; exact dimensions and bytes. |
| CLI-01 | 67-02 | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` plus process suite | Exact ordered 74 IDs, compatible flags, explicit output, CPU-only CLI selection. |
| CLI-02 | 67-02 | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyExampleRendererProcessTests` | Deterministic versioned JSON, exact identities/counts, no forbidden sensitive tokens. |
| CLI-03 | 67-03 | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyExampleRendererProcessTests` | Real binary returns typed nonzero failures, independently exercises render/encode failures, and refuses incomplete outputs. |

The final aggregate is `bash scripts/run-no-skip-swiftpm.sh`; it must execute
archive verification, SDK-only scanning, the external consumer, and one complete
SwiftPM test child with positive execution, all eight opt-ins, zero failure, and
zero skip. Focused commands diagnose ownership; only the conjunction closes the
phase.

## Process Matrix

| Class | Invocation/fixture | Expected |
| --- | --- | --- |
| Discovery | `--list-cases` twice | exit 0; byte-identical v1 JSON; exact ordered unique 74 IDs |
| Neutral success | generated image + explicit input/output/case/backend/no-watermark | exit 0; one decodable same-size output; 1/1/0/0 report |
| Reproducibility | same request in two fresh temp roots | output PNG and report bytes match |
| Arguments | unknown flag; missing value; missing output; duplicated `--input`, `--output`, `--case`, or `--backend` | exact typed usage/`duplicate_argument` code; nonzero; no render attempt |
| Selection | unknown case; `gpu`; other backend | exact typed code; nonzero; no fallback |
| Input | missing/empty input; normalized duplicate stems; corrupt image | exact typed code; nonzero |
| Output | nonexistent explicit output; output root is file/symlink; destination is directory; expected file absent/invalid | nonexistent root is `output_directory_missing` and is never created; other exact typed code; failed/skipped accounting; nonzero |
| Render failure | executable-internal environment seam selects `render` | real binary emits `render_failed`; nonzero; no PNG; 1/0/1/0 reconciled report |
| Encode failure | executable-internal environment seam selects `encode` | real binary emits `encode_failed`; nonzero; no PNG; 1/0/1/0 reconciled report |
| Report | report path is a directory/unwritable | `report_write_failed`; nonzero |
| Privacy | every stdout/stderr/report | no absolute temp path, raw error, pixel, mask, landmark, coordinate, or private locator |
| Resource bounds | SwiftPM build then renderer invocations | build timeout 120 seconds; renderer timeout 30 seconds; stdout/stderr each at most 1 MiB; temp cleanup |

## Reachability

- `scripts/run-no-skip-swiftpm.sh` invokes the external consumer checker before
  its complete test child, so SPM-01/SPM-02 cannot become orphan evidence.
- `BeautyExampleRenderer` remains a declared executable product and its 74-case
  catalog is passed into the factored runner; the render/encode failure seam is
  executable-internal and absent from public BeautySDK, flags, help, and reports.
- `BeautyCoreTests` invokes SwiftPM to build the executable once, resolves the
  reported bin path, and then runs that regular binary; it imports no CLI
  implementation module.
- All successful render outputs and the fixed report live under the explicit
  output root. Tests supply a unique temporary root; normal repository use points
  at the existing ignored generated-output area.

## Multi-Source Coverage Audit

| SOURCE | ID | Feature/Requirement | Plan | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| GOAL | — | Public BeautySDK consumption and deterministic processing entirely through SwiftPM/SDK CLI | 67-01..04 | COVERED | External package, real renderer/process matrix, and current-owner closeout form one serial path. |
| REQ | SPM-01 | Clean external public-product consumer | 67-01 | COVERED | Manifest/source classifier plus clean-scratch compile/link/run. |
| REQ | SPM-02 | Generated neutral public-facade request and dimension-preserving output | 67-01 | COVERED | Exact generated bytes and extent. |
| REQ | CLI-01 | Deterministic input/case/backend/output/case-discovery contract | 67-02 | COVERED | Existing 74 catalog, compatible flags, explicit output, CPU token. |
| REQ | CLI-02 | Machine-readable aggregate privacy-safe report | 67-02 | COVERED | Fixed version, sorted identities, exact counts, redaction. |
| REQ | CLI-03 | Typed nonzero failure and reproducible ignored/generated output | 67-03 | COVERED | Actual-binary invalid matrix and temp cleanup. |
| RESEARCH | — | No research artifact | — | EXCLUDED | User explicitly selected `--skip-research`; no external dependency or unfamiliar integration is introduced. |
| CONTEXT | D-01 | Public-only external consumer | 67-01 | COVERED | Tasks 67-01-01/02. |
| CONTEXT | D-02 | Repository-owned local-path fixture | 67-01 | COVERED | Task 67-01-01. |
| CONTEXT | D-03 | Swift-generated input | 67-01 | COVERED | Task 67-01-01. |
| CONTEXT | D-04 | Success/dimensions/neutral/concrete output | 67-01 | COVERED | Task 67-01-01. |
| CONTEXT | D-05 | Preserve 74 cases/flags and add discovery/reporting | 67-02 | COVERED | Tasks 67-02-01/02. |
| CONTEXT | D-06 | Explicit output and SDK-only execution | 67-02 | COVERED | Tasks 67-02-01/02. |
| CONTEXT | D-07 | CPU-only CLI token; reject GPU/unknown; no public switch | 67-02, 67-03 | COVERED | Implementation plus process assertions. |
| CONTEXT | D-08 | Versioned aggregate privacy-safe JSON | 67-02, 67-03 | COVERED | Implementation plus process assertions. |
| CONTEXT | D-09 | Complete typed failure families | 67-02, 67-03 | COVERED | Codes in Plan 02; actual invalid matrix in Plan 03. |
| CONTEXT | D-10 | Zero only for complete validated reconciled outputs | 67-02, 67-03 | COVERED | Runner invariant plus incomplete-output process cases. |
| CONTEXT | D-11 | Ignored/reproducible outputs and temporary cleanup | 67-02, 67-03 | COVERED | Explicit output ownership and fresh-temp tests. |
| CONTEXT | D-12 | Real compiled executable via Process | 67-03 | COVERED | Test target dependency and Process-only observations. |

Deferred GPU execution/public backend API, Phase 68 CPU oracle breadth,
UI/Demo, simulator/device, commercial, packaging, shipping, and release work do
not appear in the plans.
