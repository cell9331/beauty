---
phase: 37
review: ASVS L1
threats_open: pending-live-gates
status: in_progress
---

# Phase 37 Security Review

## Scope and Blocking Rule

This ASVS Level 1 register covers active source, public and SPI compatibility, package/privacy/import/dependency boundaries, redacted diagnostics, local generated artifacts, command integrity, promotion truthfulness, and lifecycle separation. Any open HIGH, scan/tool error, zero-test suite, output mismatch, tracked/staged generated artifact, or review finding blocks Plan 37-04. The numeric zero state is deliberately withheld until the complete live gate passes.

## Threat Register

| ID | Threat | Severity | Mitigation | Required command evidence | Status |
| --- | --- | --- | --- | --- | --- |
| T37-01 | A negative scan fails open on a tool error or an unclassified match | high | Phase-owned wrapper classifies exit 0/1/>1 and self-tests match, no-match, missing tool, and command error | `check_nose_safety_boundaries.py --self-test` and default live run | pending live gate |
| T37-02 | Raw geometry, supports, landmarks, control points, provider/detector objects, or per-field payloads cross public/SPI diagnostics | high | Exact inventory, public/SPI declaration scan, facade redaction tests, and diagnostic lexical gate | boundary checker plus resolver/facade focused suites | pending live gate |
| T37-03 | Demo or renderer imports an internal package target | high | Both integration surfaces may import only the public `BeautySDK` facade plus platform modules | boundary checker import gate | pending live gate |
| T37-04 | A dependency, compatibility change, privacy-manifest drift, network/cloud path, or commercial execution path expands scope | high | Exact manifest/target and 33-field inventory checks; classified active-source scans; documented current privacy disposition | boundary checker manifest, inventory, privacy, network, and commercial gates | pending live gate |
| T37-05 | Copied/partial runtime output or a zero-test suite is presented as current evidence | high | Fresh nonzero focused/full SwiftPM plus renderer and unchanged strict Phase 36 36 x 7 helper | Task 37-03-02 command log | pending live gate |
| T37-06 | Generated output/gallery/staging/quarantine files become tracked or staged, or a path escapes the repository | high | Containment-safe path resolution, tracked and staged queries, and ignored representative paths | checker self-test/default plus artifact guards | pending live gate |
| T37-07 | Rows, branch, owners, requirements, or lifecycle state are promoted partially or prematurely | high | Default mode requires `提升: future`, `山根: partial`, branch `鼻子: partial`; allow-promotion mode checks every D-23/D-24 owner and lifecycle boundary | checker default live now; allow-promotion reserved for Plan 37-04 | pending live gate |
| T37-08 | Archived evidence is rewritten, or audit/archive/tag/shipping readiness is claimed before its owning workflow | high | Archive/worktree status gate and explicit absence of a v1.9 audit artifact or passed lifecycle claim | boundary checker and scoped diff review | pending live gate |

## Residual Risk and Non-Claims

The gate can prove current source/output/status integrity for SDK-core scope. It does not prove physical-device parity, subjective/commercial naturalness, optimized performance, packaging, shipping, launch readiness, or the later independent v1.9 milestone audit.
