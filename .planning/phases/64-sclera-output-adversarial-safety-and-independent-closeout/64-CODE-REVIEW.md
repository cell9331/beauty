---
phase: 64-sclera-output-adversarial-safety-and-independent-closeout
reviewed: 2026-08-07T23:55:20Z
depth: standard
files_reviewed: 6
files_reviewed_list:
  - BeautySDK/Sources/BeautyExampleRenderer/main.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift
  - docs/meitu-function-blueprint/FEATURE_MATRIX.md
  - docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md
  - example-images/generate_gallery.py
findings:
  critical: 2
  warning: 1
  info: 0
  total: 3
status: issues_found
---

# Phase 64: Code Review Report

**Reviewed:** 2026-08-07T23:55:20Z
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

The renderer inventory and gallery count agree at 74 cases, the public sclera case uses the intended scalar, and the focused 26 Swift tests plus the gallery self-test pass. Those green results do not establish the claimed adversarial safety gate: the new oracle checks only six individual pixels, all on or around the left synthetic eye, while both eyes are processed. The product ledgers therefore promote `祛红血丝` on evidence that does not meet Phase 64's own protected-anatomy contract. The renderer also converts the canonical result through a device-dependent RGB space when producing saved evidence.

## Critical Issues

### CR-01: Protected-anatomy oracle samples six pixels instead of protecting both anatomical regions

**Classification:** BLOCKER

**File:** `BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift:20-100` (truth definition at lines 199-207)

**Issue:** `protectedCoordinates()` supplies exactly one coordinate for each named family and every eye-related coordinate has `x <= 27`, although `makeEyeBytes()` creates a second eye centered at `x = 59`. Consequently, `colorIndependentProtectedTruth` and `recoloredProtected` contain only six pixels and contain no iris, pupil, highlight, lash, or skin truth for the right eye. Most of the left iris/pupil also retains its native dark color, so an unsafe proposal anywhere except the sampled pixel can still be hidden by the redness score. The three perturbations are symmetric, small, and required to keep both units accepted; they do not implement the promised inward/outward/asymmetric boundary grid. Finally, the test treats `summary.protectedProposalPixelCount == 0` as evidence even though the provider constructs that summary field as the constant `0`, rather than comparing proposal indices with independently authored truth. A regression that leaks into almost any protected pixel, including every protected pixel of the right eye, passes all five tests. This fails the Phase 64 D-09/D-10 contract and the repository skill's requirement for a color-independent full protected envelope followed by a recolored final-output oracle.

**Fix:** Build independent full-resolution bilateral truth masks for iris/pupil, highlights, lash margin, skin, and aperture exterior from unperturbed geometry/source truth. Recolor every protected pixel to score-attractive values, sweep independent left/right contour and pupil perturbations (including boundary and local fail-closed cases), and compare actual proposal indices and final changed indices against the full truth masks. Do not use the provider's aggregate as the oracle.

### CR-02: Product ledgers claim implementation after an unfulfilled mandatory safety gate

**Classification:** BLOCKER

**Files:**

- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md:94`
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md:25`

**Issue:** Both owners state that Phase 64 closed color-independent and recolored protected-anatomy safety and use that statement to mark `祛红血丝` implemented. The ledger's own completion rule requires relevant safety/degradation coverage before `implemented`, but CR-01 shows the advertised bilateral protected-region gate was not performed. These are broader completion claims than the executable evidence supports.

**Fix:** Until CR-01 is repaired and the full bilateral oracle passes, restore the sclera row to `partial` and remove the assertion that Phase 64 closed protected-anatomy safety. Reapply the exact promotion only after the corrected tests and independent verification pass.

## Warnings

### WR-01: Saved renderer evidence crosses a device-dependent color boundary

**Classification:** WARNING

**File:** `BeautySDK/Sources/BeautyExampleRenderer/main.swift:448-452`

**Issue:** The renderer converts `BeautyResult.output` through `CGColorSpaceCreateDeviceRGB()` for both the CI working and output spaces. Device RGB is not a stable, explicit sRGB contract, so identical canonical SDK output can encode different RGB values on different hosts or displays. That undermines reproducibility of the strict decoded output and original-detail gallery used to close Phase 64, and conflicts with the still-image integration rule that Vision/rendering share one explicitly managed sRGB space.

**Fix:** Render evidence through an explicit sRGB color space, and use the same named space for the bitmap/watermark path if watermarked output is retained.

---

_Reviewed: 2026-08-07T23:55:20Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
