---
phase: 64-sclera-output-adversarial-safety-and-independent-closeout
plan: "01"
subsystem: testing
tags: [swift, sclera, public-output, adversarial, privacy]
requires:
  - phase: 63-guarded-per-eye-sclera-production-integration
    provides: frozen guarded per-eye provider and native Vision evidence
provides:
  - strict 74-case/six-output decoder contract with 14 mutation checks
  - five protected-anatomy/recovery closeout tests
  - eight-HIGH pre/post promotion checker
affects: [64-02, 64-03, 64-04]
key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_sclera_renderer_outputs.py
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py
  modified:
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-VALIDATION.md
requirements-completed: []
completed: 2026-08-07
status: complete
---

# Phase 64 Plan 01: Output and Adversarial Contracts Summary

**Public output, protected-anatomy, privacy and promotion sequencing are now executable before any renderer or product-owner change.**

## Accomplishments

- Added a bounded sclera decoder that reuses the audited PNG parser, freezes an
  exact six-output matrix and passes 14/14 malformed/output mutations.
- Added five green deterministic closeout tests for color-independent protected
  truth, score-attractive protected recoloring, peer-eye continuation,
  valid-invalid-valid recovery and parallel request isolation.
- Added a checker whose eight isolated HIGH mutations pass 8/8 and whose live
  pre-promotion mode accepts only the current 73-case/future-row state.

## Task Commit

- `64738d8` — freeze both Wave 1 tasks and validation evidence.

## Verification

- Strict helper self-test: 14/14 pass.
- HIGH checker mutation self-test: 8/8 pass.
- Live pre-promotion checker: all T-64-01...08 pass.
- Adversarial XCTest: 5/5 pass.
- `git diff --check`: pass.

## Scope

Renderer remains 73 cases and `祛红血丝` remains future. No private media,
fixture locator, raw anatomy or reviewed mask is tracked. Wave 2 may now add the
one exact public case and run the authorized pair.
