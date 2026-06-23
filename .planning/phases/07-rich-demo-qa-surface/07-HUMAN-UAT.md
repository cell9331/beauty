---
status: partial
phase: 07-rich-demo-qa-surface
source:
  - 07-VERIFICATION.md
started: 2026-06-23T02:07:30Z
updated: 2026-06-23T02:07:30Z
---

# Phase 7 Human UAT

## Current Test

awaiting human testing

## Tests

### 1. Parameter JSON Visible Flow

expected: The sheet shows Import/Export copy, Apply stays disabled until a valid preview, valid Apply changes settings, and failed previews leave current settings unchanged.
result: pending

Test: Launch the Demo, switch to a preview mode with a usable camera or photo preview, open Parameter JSON, export JSON, paste it into Import, preview it, and apply it.

### 2. Preset And Reset Visible State

expected: Preset/import/custom source behavior is reflected by selected chips and reset behavior without stale state.
result: pending

Test: Use preset, manual slider/filter edit, single reset, and reset all in the visible Demo panel.

### 3. Compare And Debug Overlay

expected: Compare and debug controls coexist, debug rows are readable and redacted, and toggling debug does not alter output or parameters.
result: pending

Test: Toggle Show Before/Show After and Show Debug Details/Hide Debug Details on camera and photo previews.

### 4. Disabled/Future Category Readiness

expected: Implemented categories remain active; future categories/subcategories stay visible, disabled, and labeled Not in v1.
result: pending

Test: Open top-level and Facial Features categories, including Makeup, Stickers, Background, Style, Eyebrows, Teeth, and Hairline.

## Summary

total: 4
passed: 0
issues: 0
pending: 4
skipped: 0
blocked: 0

## Gaps
