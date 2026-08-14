# RELIABILITY.md

> Current SDK-only error, degradation, observability, performance-risk, archive,
> and recovery contract.

## 1. Posture

- Recoverable/environmental failures return typed errors or documented local
  degradation; production code does not crash for caller input or missing optional work.
- Every request recomputes support, effects, ownership, warnings, and metrics;
  no failed or prior request may contaminate the next valid request.
- Safe independent work continues when one support region/effect unit abstains.
- SwiftPM and SDK-owned scripts are the only active verification surfaces.
- Performance targets are engineering budgets, not claims; current v1.16 closeout
  adds no device/performance evidence.

## 2. Core Invariants

| ID | Invariant |
| --- | --- |
| R1 | Public failures use stable, redacted `BeautyError` cases. |
| R2 | Invalid input is rejected before resource, detection, allocation-heavy, or render work. |
| R3 | Default/zero-strength input is deterministic and inert. |
| R4 | No-face/missing/malformed support removes only dependent work while safe siblings continue. |
| R5 | Request-local support, masks, proposals, composition, and diagnostics are cleared on success and throw. |
| R6 | Repeated, valid-invalid-valid, reset, and independent parallel-engine tests recover without stale state. |
| R7 | Metrics/logs are optional, aggregate, bounded, and privacy-safe. |
| R8 | Generated output is disposable, ignored, bounded, and never required as a tracked baseline. |
| R9 | Archive corruption/restoration/static-boundary failure stops the mandatory suite before SwiftPM execution. |
| R10 | The no-skip parser accepts one child only and rejects failure, skip, ambiguity, oversize, or zero execution. |

## 3. Error and Degradation Policy

| Condition | Required behavior |
| --- | --- |
| invalid extent/orientation/limit/alpha | payload-free `.invalidInput` before expensive work |
| unsupported format/color | payload-free `.unsupportedPixelFormat` or the documented typed conversion path |
| unknown resource ID | typed redacted resource error; do not treat ID as path |
| no face | keep supported face-independent work; skip support-dependent work |
| malformed support | abstain at the smallest region/feature unit; valid peer/sibling survives |
| stale/reused support | apply the field/domain-specific documented zero or reuse scale without prior-vector carryover |
| provider-empty result | remove it from final strengths, domains, totals, warnings, metrics, points, and dispatch |
| composition collision | preserve original source pixel |
| optional private fixture absent | default suite may record the documented skip; mandatory no-skip gate fails unless opt-in executes |

Internal framework details, paths, pixels, masks, or coordinates never enter public
error associated values.

## 4. Current Processing Reliability

Still-image local retouch follows one deterministic request sequence:

```text
validate/canonicalize
→ one detection/mapping request when demanded
→ request-local support/context
→ provider units from immutable original pixels
→ one ownership/composition transaction
→ output or typed error
```

Affected-eye/feature failure remains local. Teeth and sclera share the request
owner but not evidence, support, admission, or promotion authority. Pixel-buffer
processing and `reset()` create no local-retouch request work.

The current geometry implementation is CPU/Core Image-backed. The retained shader
resource and render foundations do not establish current GPU execution. v1.16 must
not add a public backend switch, silent fallback, or parity claim.

## 5. Archive Verification and Recovery

The active repository relies on two committed historical archives. Verification
must check both ZIP digests, integrity, normalized safe entries, manifest equality,
fresh temporary extraction, and extracted content hashes before any historical use.

Recovery policy:

1. A missing, corrupt, symlinked, unsafe, or digest-mismatched bundle stops the
   gate immediately without partial extraction or SwiftPM execution.
2. Recover the exact committed artifact from trusted Git history; never repair by
   editing its manifest/digest or substituting another bundle.
3. Rerun verification for both archives.
4. Restore only into a new outside-repository temporary directory.
5. Rerun the post-archive scanner; restored repository roots are failure.

The historical retirement transaction was digest-bound and exact-target. A failure
before its irreversible point restored both staged roots; the completed current
state recovers from archives and does not rerun retirement.

## 6. Mandatory No-Skip Gate

`scripts/run-no-skip-swiftpm.sh` must execute in this order:

1. archive verification;
2. post-archive SDK-only boundary scanner;
3. the existing one-child hardened SwiftPM run with all eight opt-in environment
   variables; and
4. transcript reduction that proves each expected identity exactly once, zero
   failures, zero skips, and nonzero all-tests execution.

Archive and scanner output is short aggregate status. The private test child may
write its bounded transcript only to a temporary file that is removed on exit;
the gate emits no private locator or raw child transcript as durable evidence.

Any preflight failure returns non-zero and prevents test execution. Any malformed,
missing, ambiguous, failed, skipped, oversized, or zero-test transcript returns
non-zero even if the child process exit status is otherwise zero.

## 7. Observability

Allowed: fixed subsystem/category/event/error codes; request-local counts, bounded
timings, caps/scales, active/skipped domain counts, and output dimension buckets.

Forbidden: image/mask bytes, paths, fixture locators, support points, bounding
boxes, pupils, tooth/eye geometry, candidate colors, rights/reviewer detail, raw
JSON, raw framework errors, and raw child transcripts.

Logs are disabled or error-level by default and never required for correctness.
Per-request arrays/caches must be bounded and released at request completion.

## 8. Performance and Resource Boundaries

- Validate dimensions and checked byte/pixel multiplication before allocation.
- Reuse contexts/resources where the existing implementation specifies reuse;
  request-owned pixel/support storage must not become engine-global state.
- Composition owners enforce unit/capacity budgets before raster/mask allocation.
- Generated/private fixture files have explicit size/inventory/path checks.
- No current package run establishes target-device frame rate, memory, thermal,
  endurance, or optimized latency.

## 9. Verification

```bash
swift test --package-path BeautySDK
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
git diff --check
bash scripts/run-no-skip-swiftpm.sh
```

Passing these commands establishes bounded SDK-core correctness and recovery only.
Commercial approval, packaging, shipping, launch, and release readiness remain
separate future scopes.
