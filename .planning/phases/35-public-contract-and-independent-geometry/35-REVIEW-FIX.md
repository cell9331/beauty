---
phase: 35-public-contract-and-independent-geometry
source_review: .planning/phases/35-public-contract-and-independent-geometry/35-REVIEW.md
fixed_at: 2026-07-13T07:16:17Z
status: fixed
iteration: 1
fix_scope: critical_warning
fix_commits:
  - 3cf59de
  - bfd7375
findings_fixed:
  critical: 2
  warning: 0
  info: 0
  total: 2
---

# Phase 35 Code Review Fix Report

Both critical findings from the standard Phase 35 code review were fixed in iteration 1.

## Fixes

1. **CR-01: Unsupported independent supports affected conflict weakening**
   - Captured nose request intent, then validated and sanitized root/tip support before any face-shape or mouth conflict resolver can observe the strengths.
   - Reused the same provider for final nose dispatch while preserving isolated invalid-support skip diagnostics.
   - Added a mixed face-shape/invalid-root regression proving exact usable-work scaling and a weakened count of two.
   - Commit: `3cf59de` (`fix(35): sanitize independent supports before conflicts`).

2. **CR-02: Valid independent support masked unavailable legacy nose work**
   - Extended nose support availability with the legacy nose-center proxy.
   - Zeroed all four unavailable legacy strengths before conflict accounting while retaining independently supported root/tip work.
   - Added provider availability coverage and a mixed legacy/new/face-shape regression proving the legacy strengths remain zero, the supported new field stays active, and conflict metrics exclude non-rendering legacy work.
   - Commit: `bfd7375` (`fix(35): zero unavailable legacy nose strengths`).

## Verification

- PASS: affected focused suites (`BeautyEffectResolverTests`, `MissingLandmarkDegradationTests`, `GeometryConflictResolverTests`, `CombinedEffectSafetyTests`, and `NoseWarpProviderTests`) — 63/63 tests.
- PASS: `swift test --package-path BeautySDK` — 209/209 tests.
- PASS: `git diff --check`.

## Status

All in-scope critical and warning findings are fixed. No info findings existed, and no unrelated scope was changed.
