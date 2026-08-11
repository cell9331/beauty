---
phase: 65-combined-facade-privacy-and-milestone-closeout
plan: "01"
subsystem: testing
tags: [combined, facade, collision, privacy, lifecycle]
requires:
  - phase: 64-sclera-output-adversarial-safety-and-independent-closeout
    provides: independently verified teeth and sclera standalone slices
provides:
  - actual-provider independent standalone merge oracle
  - explicit collision/four-failure/recovery contracts
  - eight-HIGH current/close/final checker
affects: [65-02, 65-03, 65-04]
key-files:
  created:
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineCombinedLocalRetouchCloseoutTests.swift
    - .planning/phases/65-combined-facade-privacy-and-milestone-closeout/check_phase65_combined_closeout.py
  modified:
    - .planning/phases/65-combined-facade-privacy-and-milestone-closeout/65-VALIDATION.md
requirements-completed: []
completed: 2026-08-08
status: complete
---

# Phase 65 Plan 01: Combined and Closeout Contracts Summary

**Combined public-facade bytes, collision semantics, four failure units,
privacy, exact owners and separate-audit sequencing are now executable before
any Testing or lifecycle closeout change.**

## Accomplishments

- Added ten focused contracts covering fresh source/teeth/sclera/both requests
  through both public entries, an independent per-pixel merge oracle, explicit
  collision-to-source, four failure quadrants, recovery, parallel/reset/
  pixel-buffer isolation and aggregate-only observations.
- Exposed three precise Wave 2 gaps: the no-lip/paired-eye Testing fixture is
  absent, reset does not clear the last Testing composition observation, and
  the no-color-pass test cannot use the color-pipeline callback as an sRGB
  oracle.
- Added a standard-library checker whose 8/8 mutation self-tests pass and whose
  live mode passes 72 exact authority, combined, failure, inventory, privacy,
  deferred-scope, owner and lifecycle assertions.

## Task Commit

- `3ca05d2` — freeze both Wave 1 tasks and validation evidence.

## Verification

- Combined RED suite: 10 tests compile/run; 7 pass and three intentional Wave 2
  contract gaps produce four assertions.
- HIGH checker mutation self-test: 8/8 pass.
- Live checker: all T-65-01...08 pass with 72 assertions.
- JSON and diff hygiene: pass.

## Scope

Production providers, composition, renderer, product owners and lifecycle
completion remain unchanged. No fixture locator, media, raw geometry, pixels or
metrics are tracked; Wave 2 may now close only the identified Testing and
combined-output gaps.
