---
phase: 36-public-facade-output-evidence
status: clean
depth: deep
reviewed: 2026-07-14
reviewed_commit: efdaad4
files_reviewed: 10
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
---

# Phase 36 Final Code Re-Review - Iteration 5

## Scope

Fresh independent deep review after remediation commit `efdaad4` covered the complete Phase 36 implementation and evidence path, all prior review/remediation history, and the repository contracts changed by the remediation:

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`
- `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py`
- `example-images/generate_gallery.py`
- `example-images/README.md`
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`
- `.gitignore`
- `SECURITY.md`
- `RELIABILITY.md`
- `PLANS.md`

The review re-audited CR-01 through CR-04 and WR-01 through WR-06, including descriptor ownership on every exceptional acquisition path, exact renderer/gallery bijection, source and staging snapshot stability, the 16 MiB source/work ceiling, bounded PNG/JPEG acquisition and decompression, descriptor-relative publication, ancestor replacement, and non-traversed quarantine behavior.

## Findings

No critical, warning, or informational findings remain.

## Remediation Verification

- **WR-04 descriptor ownership:** `input_fd` is registered before the fallible output acquisition, every later publication descriptor is registered immediately after acquisition, and `_mkdir_open(...)` closes its locally owned descriptor on every exceptional post-open exit. Repeated missing-output and forced post-open identity failures leave the descriptor count unchanged.
- **WR-05 torn-copy rejection:** source acceptance compares device, inode, size, nanosecond modification time, and change time before destination creation and after the bounded copy. Each destination's full snapshot is retained and revalidated immediately before publication. Deterministic same-size source mutation and an independent staged-file in-place mutation both fail before the existing gallery is moved or staging is published.
- **WR-06 bounded work:** a source above 16 MiB is rejected before destination creation. A second descriptor snapshot rejects post-open growth before destination creation, copy reads are capped by the accepted size, and the one-byte post-copy read rejects later growth without unbounded allocation or copying.
- **Critical containment:** repository, `example-images`, output, staging, quarantine, and gallery operations remain anchored to no-follow descriptors. Fresh staging uses exclusive destination creation and descriptor-relative atomic rename. A swapped pathname cannot redirect writes into the replacement tree.
- **Quarantine:** an old gallery is renamed intact into one ignored quarantine entry without enumeration or recursive deletion. Existing staging or quarantine blocks retry. The expected local quarantine is preserved and is not treated as a finding.
- **Strict helper:** PNG/JPEG acquisition opens once, requires a regular file, retains at most its ceiling plus one byte, and rejects replacement/growth. PNG parsing retains CRC, chunk bounds, IEND/trailing-data, dimension, decoded-length, stream-EOF, unused-data, and unconsumed-tail gates with bounded incremental zlib output.
- **Inventory and evidence:** duplicate renderer IDs, duplicate fixture stems, missing/extra output names, corrupt output, and renderer/gallery inventory mismatch fail closed. Current inventory remains the exact 36 cases x 7 fixtures = 252 outputs.
- **Portability:** publication explicitly requires the needed `dir_fd`, `follow_symlinks`, `O_DIRECTORY`, and `O_NOFOLLOW` support and otherwise fails closed.

## Verification Run

- PASS: `python3 example-images/generate_gallery.py --self-test`.
- PASS: `python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py --self-test`.
- PASS: `python3 -m py_compile example-images/generate_gallery.py .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py`.
- PASS: independent staged-snapshot adversarial test; an in-place staging mutation was rejected, the prior gallery stayed visible, and quarantine publication did not begin.
- PASS: `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` — 10/10 XCTest cases, zero failures.
- PASS: live strict helper — 252/252 fully decoded same-dimension PNGs; 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face comparisons.
- PASS: containment state — visible gallery has 252 files, quarantine `previous/` has 252 regular files and zero symlinks, staging is absent, generated routes are ignored, and tracked/staged generated-route scans are empty.

## Verdict

Phase 36 is clean at deep review depth after `efdaad4`: 0 critical, 0 warning, and 0 informational findings. WR-04, WR-05, and WR-06 are closed, and every earlier critical/warning remediation remains effective. The preserved local quarantine is the documented fail-closed handoff state pending the orchestrator's atomic out-of-repository move; it is not a review defect.
