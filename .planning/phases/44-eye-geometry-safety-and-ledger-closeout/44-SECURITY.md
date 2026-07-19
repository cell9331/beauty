---
phase: 44-eye-geometry-safety-and-ledger-closeout
standard: ASVS-L1
reviewed: 2026-07-19
status: evidence-pending
high_severity_blocks_promotion: true
---

# Phase 44 Security Review

## Scope and assets

The Phase 44 boundary covers request-scoped observed eye contours and pupils, the scalar-only public facade, local provider eligibility, package/source ownership, generated image containment, exact promotion owners, and planning-state handoff. Raw biometric-adjacent geometry remains package-only, non-Codable, non-persistent, and excluded from warning and metric payloads.

## Threat disposition

| Threat | Severity | Mitigation | Status |
|---|---|---|---|
| Public/SPI raw contour, pupil, support, or control-point exposure | HIGH | Exact 48-field inventory plus public/SPI classifier | pending final live evidence |
| Codable, cache, preference, file, or diagnostic persistence | HIGH | Active-source persistence and diagnostic scans | pending final live evidence |
| Internal Demo/renderer import or dependency drift | HIGH | Phase 41 baseline, import, manifest, and source-owner gates | pending final live evidence |
| Network/cloud or commercial path | HIGH | Active-source classifiers; local-first contract | pending final live evidence |
| Unclassified active-source match or command error | HIGH | Exact eight-owner allowlist and fail-closed exit classification | pending final live evidence |
| Generated output/gallery/quarantine tracking or scope escape | HIGH | Canonical path and git containment checks | pending final live evidence |
| Premature/partial row promotion or lifecycle claim | HIGH | Separate pre-, promotion-, owner-, and allow-promotion modes | pending final live evidence |

`threats_open: 0` is deliberately not asserted until the fresh runtime, output, checker, review, and artifact evidence completes.
