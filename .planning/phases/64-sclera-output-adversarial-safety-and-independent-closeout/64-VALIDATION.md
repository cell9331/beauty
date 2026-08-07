---
phase: 64
slug: sclera-output-adversarial-safety-and-independent-closeout
status: ready
nyquist_compliant: true
wave_0_complete: true
created: 2026-08-07
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05]
---

# Phase 64 - Validation Strategy

| Task ID | Plan | Wave | Requirements | Automated evidence | Status |
| --- | --- | ---: | --- | --- | --- |
| 64-01-01 | 01 | 1 | SCLERA-16, SCLERA-17, OUT-05 | Exact renderer/helper RED contract; 14/14 helper mutations | executed |
| 64-01-02 | 01 | 1 | SCLERA-14, SCLERA-15, SCLERA-18 | 5/5 adversarial contracts; 8/8 HIGH checker mutations and green pre-mode | executed |
| 64-02-01 | 02 | 2 | SCLERA-17, OUT-05 | Exact 74-case public renderer regression | pending |
| 64-02-02 | 02 | 2 | SCLERA-16, SCLERA-17, OUT-05 | Required private 6/6 decoded output | pending |
| 64-03-01 | 03 | 3 | SCLERA-14, SCLERA-15 | Geometry, recolor, peer and recovery matrices | pending |
| 64-03-02 | 03 | 3 | SCLERA-16, SCLERA-18 | Fresh blinded review and 8/8 HIGH | pending |
| 64-04-01 | 04 | 4 | SCLERA-18 | Full pre-promotion conjunction and exact owner update | pending |
| 64-04-02 | 04 | 4 | SCLERA-14...18, OUT-05 | Independent post-promotion verification | pending |

Task count target: **8 task IDs = 8 validation rows**.

Required final gates: exact 74-case renderer; helper self/live; required private
6/6; positive/negative/no-face bounds; both adversarial oracles; original-detail
review; 8/8 HIGH; exact 61 fields/five presets/disabled Demo; full SwiftPM and
explicit Demo build/test; exact single-row promotion; independent post-promotion
rerun. No broad suite substitutes for private output, zero protected identity,
visual review or post-promotion verification.
