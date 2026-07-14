---
phase: 39-public-facade-mouth-geometry-output-evidence
status: passed
reviewed: 2026-07-14
standard: OWASP ASVS L1 adapted to generated local evidence
threats_open: 0
---

# Phase 39 Security Review

## Threat Inventory

| Threat | Classification | Mitigation and evidence | Status |
| --- | --- | --- | --- |
| Malicious fixture/output parsing or allocation | High | No-follow single-descriptor reads, regular-file/identity/size stability, 16 MiB file, 4,096 × 4,096 extent, and 64 MiB decoded ceilings; PNG CRC/chunk/zlib/filter checks and JPEG extent checks; negative self-tests pass. | closed |
| Stale, incomplete, or aliased evidence acceptance | High | Live ID/fixture discovery, duplicate rejection, exact 44 × 7 assertion, exact flat-name set, full decode/dimension checks, frozen ROI/floors, sixteen separately gated families, and fresh strict regeneration pass. | closed |
| Raw image or biometric-adjacent geometry disclosure | High | Fixtures/decoded pixels remain local and ignored; committed evidence contains only aggregate counts/minima; public facade diagnostics remain aggregate/redacted. | closed |
| Path escape or destructive generated-root cleanup | High | Cleanup requires physical equality with the exact ignored output allow-list before descendant deletion; gallery publication is descriptor-relative, no-follow, bounded, staged, and atomically renamed. | closed |
| Gallery mismatch, tracking, or publication race | Medium | Duplicate-free renderer bijection, stable bounded source snapshots, 308 regular-file count, quarantine-sensitive single publication, and ignored/tracked/staged checks pass. | closed |
| Dependency, network/cloud, or commercial drift | Medium | Package/protected-runtime diffs are empty; renderer imports only public `BeautySDK`; changed-source scans find no remote, payment, entitlement, or added dependency path. | closed |
| Premature promotion or false readiness | Medium | Protected product ledgers, PROJECT, QUALITY_SCORE, Demo, caps, providers, and resolvers are unchanged; five rows and `嘴唇` remain unpromoted for Phase 40. | closed |

## ASVS L1 Result

Input validation, bounded resource use, generated-path containment, data minimization, dependency/external-communication boundaries, deterministic failure handling, and evidence integrity pass. No open threat remains.

Residual product risks—final caps, exhaustive degradation/conflict behavior, subjective naturalness, device parity, and promotion—remain explicitly owned by Phase 40 or later setup-specific work.
