---
phase: 29-eye-renderer-output-evidence
slug: eye-renderer-output-evidence
status: verified
threats_open: 0
asvs_level: 1
created: 2026-07-10
verified: 2026-07-10
---

# Phase 29 - Security

Per-phase security contract: threat register, accepted risks, and audit trail for the Phase 29 public-facade eye renderer evidence slice.

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Renderer CLI -> local filesystem | `BeautyExampleRenderer` writes generated PNGs under ignored local output paths. | Local image fixtures and generated PNG artifacts. |
| Helper and renderer output -> evidence docs | Command output is copied into durable Markdown evidence. | Relative fixture names, case IDs, counts, dimensions, and comparison totals. |
| Generated output -> gallery | Flat ignored PNGs are copied into grouped ignored gallery directories. | Generated PNG review copies under `example-images/gallery/`. |
| Evidence -> planning ledgers | Phase evidence updates requirements, roadmap, quality, and plan ledgers. | Requirement status, command evidence, limitations, and next-phase routing. |
| Renderer evidence -> eye status ledgers | Renderer evidence can support Phase 30 but must not promote `眼睛` rows or branch status by itself. | Status wording and completion claims. |

## Threat Register

| Threat ID | Category | Component | Disposition | Mitigation | Status |
|-----------|----------|-----------|-------------|------------|--------|
| T-29-01-01 | Information Disclosure | Helper output | mitigate | Helper and evidence scans reject raw geometry, local paths, raw framework errors, raw JSON, image bytes, hashes, and point payloads. | closed |
| T-29-01-02 | Spoofing / Repudiation | Eye output evidence | mitigate | Helper verifies 36/36 portrait eye outputs against `geometryBaseline_noop` above the watermark band. | closed |
| T-29-01-03 | Information Disclosure / Repudiation | Generated PNG artifacts | mitigate | Generated PNGs stay under ignored `example-images/output/`; representative `git check-ignore` checks and `git ls-files` passed. | closed |
| T-29-01-04 | Tampering | Renderer public boundary | mitigate | Renderer tests and scans forbid internal SDK imports, new public parameters, Demo coupling, eye combo cases, commercial tokens, and network/cloud tokens. | closed |
| T-29-01-05 | Spoofing / Repudiation | Phase scope wording | mitigate | Verification and ledgers state Phase 29 records renderer evidence only; eye ledger/status closeout remains Phase 30 scope. | closed |
| T-29-01-SC | Tampering | Package-manager installs | mitigate | Phase work used SwiftPM, Python standard library, `rg`, git, and GSD tools only; no package-manager install was added. | closed |
| T-29-02-01 | Information Disclosure / Repudiation | Generated gallery outputs | mitigate | Gallery outputs remain under ignored `example-images/gallery/eyes/`; representative `git check-ignore` checks passed. | closed |
| T-29-02-02 | Spoofing / Repudiation | Example-image validation docs | mitigate | Docs cite 161/161 helper output and 36/36 comparison requirements, and keep eye rows/branch partial until Phase 30. | closed |
| T-29-02-03 | Tampering | Eye case matrix docs | mitigate | Gallery and docs use exactly the six locked case IDs; no combo, negative tail-lift, non-eye, public API, Demo, or commercial case was added. | closed |
| T-29-02-04 | Repudiation | Output path contract | mitigate | Touched active docs use canonical `example-images/output/`; active legacy path scans passed. | closed |
| T-29-02-SC | Tampering | Package-manager installs | mitigate | Gallery generation uses Python standard library only. | closed |
| T-29-03-01 | Information Disclosure | Evidence and verification artifacts | mitigate | Evidence/helper redaction scans passed over Phase 29 evidence, verification, validation, review, helper, gallery generator, and renderer source. | closed |
| T-29-03-02 | Spoofing / Repudiation | Eye renderer evidence claims | mitigate | Evidence cites helper 36/36 top-region comparisons above the watermark band against `geometryBaseline_noop`. | closed |
| T-29-03-03 | Information Disclosure / Repudiation | Generated output and gallery artifacts | mitigate | Evidence cites ignored output/gallery checks; no generated PNG baselines or hashes are committed. | closed |
| T-29-03-04 | Tampering | Hidden API, Demo, commercial, or network scope expansion | mitigate | Public raw geometry, internal import, commercial token, and network/cloud scans passed for touched source surfaces. | closed |
| T-29-03-05 | Spoofing / Repudiation | Evidence wording | mitigate | No-overclaim scans passed; Phase 29 does not claim UI completion, commercial quality, device parity, broad parity, release readiness, or eye branch completion. | closed |
| T-29-03-SC | Tampering | Package-manager installs | mitigate | Verification used existing SwiftPM, Python standard library, `rg`, git, and GSD tools only. | closed |
| T-29-04-01 | Spoofing / Repudiation | Requirement and roadmap status | mitigate | EYE-01 through EYE-03 cite `29-VERIFICATION.md`; EYE-04 through EYE-08 and DOC-01 remain pending. | closed |
| T-29-04-02 | Spoofing / Repudiation | Eye status wording | mitigate | Roadmap, state, quality, and plan ledgers state renderer evidence exists while `眼睛` rows and branch remain partial until Phase 30. | closed |
| T-29-04-03 | Tampering | Shape ledger and feature matrix | mitigate | `git diff --exit-code` passed for `SHAPE_FEATURE_LEDGER.md` and `FEATURE_MATRIX.md`. | closed |
| T-29-04-04 | Information Disclosure | Quality and plan ledgers | mitigate | Diff/redaction scans forbid raw geometry, absolute local paths, raw framework errors, raw JSON, image bytes, hashes, and point payloads. | closed |
| T-29-04-05 | Spoofing / Repudiation | Quality and plan claims | mitigate | No-overclaim scans passed; ledgers do not claim UI completion, commercial quality, device parity, broad parity, release readiness, or eye branch completion. | closed |
| T-29-04-SC | Tampering | Package-manager installs | mitigate | Closeout used existing docs, `rg`, git, and GSD tools only. | closed |

## Accepted Risks Log

No accepted risks.

## Evidence

- `29-REVIEW.md` records `status: clean` after resolving gallery-root deletion, renderer path-label, and full PNG decode findings.
- `29-VERIFICATION.md` records passed focused renderer tests, focused eye provider tests, full SDK tests, renderer build/run, helper checks, gallery checks, ignored artifact checks, redaction scans, and no-overclaim scans.
- `example-images/generate_gallery.py` refuses gallery directories outside `example-images/gallery/`, refuses input/output overlap, rejects symlink gallery roots, and rejects non-directory gallery paths before deleting any generated gallery directory.
- `BeautyExampleRenderer` emits filename-only success labels and fixture-relative or generic renderer-local error labels.
- `check_eye_renderer_outputs.py` fully decodes every expected generated PNG, requires `IEND`, and validates exact decoded scanline length before accepting dimensions and comparisons.

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-07-10 | 23 | 23 | 0 | Codex inline security closeout |

## Sign-Off

- [x] All threats have a disposition.
- [x] Accepted risks documented in Accepted Risks Log.
- [x] `threats_open: 0` confirmed.
- [x] `status: verified` set in frontmatter.

**Approval:** verified 2026-07-10
