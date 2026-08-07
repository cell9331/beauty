---
status: complete
phase: 64-sclera-output-adversarial-safety-and-independent-closeout
source:
  - 64-01-SUMMARY.md
  - 64-02-SUMMARY.md
  - 64-03-SUMMARY.md
  - 64-04-SUMMARY.md
started: 2026-08-07T23:37:36Z
updated: 2026-08-07T23:48:22Z
---

## Current Test

[testing complete]

## Tests

### 1. Color-independent protected-anatomy containment
expected: Across the bounded eye-support grid, open-redness perturbations enter none of the protected iris, pupil, highlight, lash, skin, or outside-aperture regions.
result: pass

### 2. End-to-end protected-pixel identity
expected: Even when protected iris pixels are recolored to look attractive to the production score, the final rendered output changes zero protected pixels after scoring, feathering, hard re-clipping, transform, and composition.
result: pass

### 3. Isolated public sclera output
expected: The public facade produces visible per-eye redness reduction on the positive input, continues safely when only the peer eye remains eligible, preserves dimensions and alpha, leaves negative/no-face inputs unchanged, and does not require Testing-only activation.
result: pass

### 4. Original-detail naturalness
expected: At original detail, the genuine-redness positive shows conservative visible improvement while retaining vessel variation, highlights, iris/pupil detail, lid edges, and surrounding skin; the normal negative and blink/gaze/glasses/highlight/occlusion challenges remain natural.
result: pass

### 5. Exact promotion and retained scope boundaries
expected: Product ownership promotes exactly `祛红血丝`; `眼睛` remains partial solely because `去脂` stays future, the three local-retouch Demo rows remain disabled and nil-mapped, and no broader release-readiness claim is introduced.
result: pass

## Summary

total: 5
passed: 5
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

[none yet]
