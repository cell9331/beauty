---
phase: 47-public-facade-face-output-evidence
plan: "02"
subsystem: output-evidence
tags: [python, png, decoder, locality, renderer, security]

requires:
  - phase: 47-public-facade-face-output-evidence
    plan: "01"
    provides: frozen 59-case renderer and representative public degradation contracts
provides:
  - bounded strict decoder for the exact 59 by 7 public renderer matrix
  - fixed visibility, locality, eligibility, nearest-neighbor, and no-face gates
  - independently accepted 413-output aggregate evidence
affects: [47-03, 48, example-gallery, output-regression]

tech-stack:
  added: []
  patterns:
    - descriptor-safe standard-library PNG/JPEG evidence acquisition
    - measurement render followed by frozen constants and an independent strict render
    - fixed family-specific normalized regions shared across all fixtures

key-files:
  created:
    - .planning/phases/47-public-facade-face-output-evidence/check_face_geometry_renderer_outputs.py
    - .planning/phases/47-public-facade-face-output-evidence/47-FACE-OUTPUT-EVIDENCE.md
  modified: []

key-decisions:
  - "Freeze contour/temple eligibility at e2-e6 and cheekbone/chin eligibility at e2,e3,e5,e6; excluded pairs must be exact no-ops."
  - "Require at least 0.99 intended RGB share and permit zero outside-region signal for baseline comparisons."
  - "Use all eleven fixed comparators from Phase 47 context, never a dynamically strongest family."
  - "Retain the Phase 43 descriptor, decode-budget, CRC, zlib, filter, and race hardening while replacing eye semantics."

requirements-completed: []

duration: 43 min
completed: 2026-07-24
---

# Phase 47 Plan 02: Bounded Face Output Evidence Summary

**A self-tested strict helper accepted exactly 413 public outputs with fixed face-local visibility, locality, independence, eligibility, and safe no-op evidence**

## Accomplishments

- Specialized the archived Phase 43 decoder/security baseline for the exact 59-case, seven-fixture Phase 47 matrix.
- Preserved descriptor/no-follow acquisition, identity snapshots, compressed/dimension/decoded budgets, strict PNG CRC/chunk/zlib/filter validation, bounded JPEG dimensions, exact inventory, and same-dimension checks.
- Froze four shared normalized face regions, positive field-specific visibility floors, a 0.99 intended-signal share, zero permitted outside signal, fixed eligibility partitions, and eleven exact comparator families.
- Added adversarial self-tests for inventory drift, malformed image data, descriptor races, watermark overlap, dynamic/zero floors, comparator or eligibility drift, outside-only change, and raw disclosure.
- Performed one measurement render, cleaned and rerendered independently, then accepted strict mode: 413/413 decoded outputs, 18/18 visibility/locality comparisons, 49/49 fixed-neighbor comparisons, 6/6 ineligible portrait no-ops, and 4/4 no-face no-ops.

## Task Commits

1. **Task 47-02-01: Create bounded matrix decoder and semantic locality gate** — `a3546dd`
2. **Task 47-02-02: Freeze regions/floors and accept clean output** — `6526970`

## Verification

- Helper `--self-test` — **PASS**.
- Python bytecode compilation with workspace-safe cache prefix — **PASS**.
- Measurement run — **PASS, 413/413**.
- Independent clean strict run — **PASS, 413/413**.
- Exact dimension distribution — **PASS: 59 at 64×64, 236 at 506×900, 59 at 675×900, 59 at 1728×2304**.
- Generated output containment — **PASS: exactly 413 ignored, untracked, unstaged PNGs**.
- `git diff --check` — **PASS**.

## Deviations from Plan

None. Python bytecode verification used `PYTHONPYCACHEPREFIX=/tmp/beauty-pycache` after the managed sandbox denied writes to the default user cache; the source and verification semantics were unchanged.

## Next Phase Readiness

Plan 47-03 can add the exact four case IDs to the descriptor-safe gallery, publish the ignored 413-file bijection, synchronize evidence owners, and run final Phase 47 execution gates.

## Self-Check: PASSED

- Both plan-owned artifacts and this summary exist.
- Both task commits exist in repository history.
- Strict acceptance used an independent clean render and committed constants only.

---
*Phase: 47-public-facade-face-output-evidence*
*Completed: 2026-07-24*
