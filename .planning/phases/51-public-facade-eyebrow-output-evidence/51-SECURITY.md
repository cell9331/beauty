---
phase: 51
slug: public-facade-eyebrow-output-evidence
status: verified
threats_open: 0
asvs_level: 1
block_on: high
register_authored_at_plan_time: true
created: 2026-07-27
---

# Phase 51 — Security

> ASVS L1 verification of the plan-time STRIDE register for public-facade eyebrow output evidence.

## Trust Boundaries

| Boundary | Description | Data Crossing |
| --- | --- | --- |
| Fixture filesystem → renderer/helper | Local portrait, negative, and generated PNG files are untrusted until exact-name, type, size, identity, and containment checks pass. | Biometric-adjacent pixels and generated evidence |
| Public parameters → SDK facade | Every isolated renderer case must use the public facade and request-local observed support. | Scalar parameters and in-memory image buffers |
| Decoder/measurements → acceptance | Decoded bytes and measured pixels cannot choose the thresholds that accept them. | Bounded decoded pixels and aggregate metrics |
| Ignored output → gallery publication | Disposable output crosses into another ignored review tree through descriptor-relative bounded publication. | Generated PNG files and safe case names |
| Executed evidence → repository ledgers | Fresh test/output results may close only Phase 51 output requirements. | Aggregate counts, filenames, verdicts, and requirement state |

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation and verified evidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| T-51-01 | Spoofing | renderer fixture discovery | high | mitigate | Fixture preflight locks the sole active regular nonempty non-symlink portrait to `e6.jpg`; retired e1–e5 fixtures remain outside input and are rejected by helper/gallery tests. | closed |
| T-51-02 | Tampering | renderer case inventory | high | mitigate | Renderer regression and source gates prove an exact duplicate-free ordered 72-case inventory with thirteen isolated eyebrow cases. | closed |
| T-51-03 | Elevation of Privilege | renderer facade route | high | mitigate | The example renderer imports only `BeautySDK` for SDK access and contains exactly one public `BeautyEngine.processResult` route. | closed |
| T-51-04 | Information Disclosure | degradation diagnostics | high | mitigate | Facade tests and active-source scans retain fixed redacted reasons and aggregate metrics; no side, support, coordinate, provider, or local-path payload is public. | closed |
| T-51-05 | Denial of Service | malformed support | high | mitigate | Focused facade/provider suites prove request-local fail-closed degradation while valid siblings continue. | closed |
| T-51-06 | Spoofing | helper fixture discovery | high | mitigate | The helper requires exact `e6` portrait and no-face fixture sets and adversarially rejects unexpected or retired names. | closed |
| T-51-07 | Tampering | output matrix | high | mitigate | Strict acceptance requires an exact 72 portrait / 144 total bijection and rejects missing, extra, duplicate, stale, corrupt, and symlink outputs. | closed |
| T-51-08 | Denial of Service | bounded image decoder | high | mitigate | Self-tests verify single-descriptor reads, identity/growth checks, 16 MiB compressed, 4096-square dimension, and 64 MiB decoded ceilings. | closed |
| T-51-09 | Tampering | threshold selection | high | mitigate | Measurement mode cannot pass; strict mode uses committed positive constants and fixed predicates validated by reversed-direction and spill adversaries. | closed |
| T-51-10 | Information Disclosure | helper output | high | mitigate | Committed evidence contains aggregate counts, extrema, safe generated filenames, and qualitative observations only; no decoded pixels or raw geometry is recorded. | closed |
| T-51-11 | Repudiation | semantic evidence | medium | mitigate | Strict output reports separate baseline, visibility, signed-pair, family-pair, protected-region, direct-portrait, and no-face counters. | closed |
| T-51-12 | Tampering | ignored output root | high | mitigate | Final rendering resolves and allow-lists the exact ignored physical output root, cleans only its descendants, and rejects retired names. | closed |
| T-51-13 | Repudiation | measurement/strict chronology | medium | mitigate | The evidence ledger records separate guarded clean measurement and frozen strict runs with exact denominators and results. | closed |
| T-51-14 | Tampering | semantic thresholds | high | mitigate | Immutable thresholds, fixed ROI/protected budgets, and adversarial helper tests reject reversed, collapsed, watermark-only, and spill cases. | closed |
| T-51-15 | Spoofing | watermark/label signal | high | mitigate | The frozen brow ROI excludes the label band; helper self-tests prove labels cannot satisfy semantic acceptance. | closed |
| T-51-16 | Information Disclosure | evidence document | high | mitigate | Repository evidence excludes raw coordinates, support arrays, provider payloads, decoded pixels, image hashes, and generated PNG bytes. | closed |
| T-51-17 | Repudiation | visual verdict | medium | mitigate | The evidence table enumerates the baseline plus all thirteen eyebrow outputs; all fourteen were opened at original detail and the explicit verdict is `PASS`. | closed |
| T-51-18 | Tampering | gallery inventory | high | mitigate | Gallery self-tests and publication checks enforce exact renderer equality, safe stems, 144 paths, and thirteen eyebrow groups. | closed |
| T-51-19 | Elevation of Privilege | gallery filesystem publication | high | mitigate | Descriptor-relative no-follow acquisition, safe components, bounded copy, staging snapshots, and atomic rename prevent path escape and ancestor-swap publication. | closed |
| T-51-20 | Denial of Service | gallery source acquisition | high | mitigate | Source files are regular, stable, descriptor-opened, and bounded to 16 MiB; descriptor closure and fail-closed retry are adversarially tested. | closed |
| T-51-21 | Information Disclosure | generated artifacts | high | mitigate | Output, gallery, staging, and quarantine roots are ignored; tracked, staged, and non-ignored scans are empty. | closed |
| T-51-22 | Repudiation | live denominator claims | medium | mitigate | Owner documents distinguish 72 portrait outputs, thirteen negative comparisons, and 144 disposable two-fixture files. | closed |
| T-51-23 | Repudiation | validation ledger | high | mitigate | Validation records fresh command results, the initially failing full-suite run and fix, the green retry, exact counts, and zero pre-recorded acceptance. | closed |
| T-51-24 | Tampering | requirement/roadmap state | high | mitigate | Ledger scans close exactly OUT-01..03 and five Phase 51 plans while SAFE-01..03 and DOC-01 remain open. | closed |
| T-51-25 | Information Disclosure | root documentation | high | mitigate | Root owners use aggregate metrics and safe filenames only; the repository retains no raw support, points, pixels, or generated image bytes. | closed |
| T-51-26 | Elevation of Privilege | product promotion | high | mitigate | Product ledgers leave all seven eyebrow rows and branch promotion to Phase 52 and retain Demo, commercial, packaging, shipping, and release exclusions. | closed |
| T-51-27 | Spoofing | visual-review claim | high | mitigate | Exact evidence-row cardinality, actual file opening, strict-output agreement, and the explicit verdict gate bind the claim to the reviewed files. | closed |
| T-51-SC | Tampering | package and dependency surface | high | mitigate | `BeautySDK/Package.swift` retains hash `6f03b078816ad1f7a426e3f70d4f57503f3152e9`; plans use SwiftPM already in the repository and Python standard library only, with no install, target, model, resource, or network addition. | closed |

*Status: open · closed · open — below high threshold (non-blocking).*

## Verification Evidence

The 2026-07-27 ASVS L1 audit completed with exit status `0`:

- output-helper and gallery-generator adversarial self-tests passed;
- all eleven validation task rows are mapped and passed;
- manifest hash, public-facade import route, public/SPI raw-geometry absence, and network/cloud absence checks passed;
- exact output/gallery inventories remain 144 each, contain no e1–e5 accepting artifact, and remain ignored, untracked, and unstaged;
- the visual evidence verdict is `PASS`, OUT-01..03 are closed, SAFE-01..03 and DOC-01 remain open, and Phase 52 remains the only promotion owner;
- `git diff --check` passed.

The full SwiftPM, focused facade/provider, guarded strict-output, and original-detail image-review evidence is preserved in `51-VALIDATION.md` and `51-EYEBROW-OUTPUT-EVIDENCE.md`.

## Accepted Risks Log

No accepted risks.

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
| --- | ---: | ---: | ---: | --- |
| 2026-07-27 | 28 | 28 | 0 | Codex autonomous ASVS L1 audit |

## Sign-Off

- [x] All threats have a mitigate disposition.
- [x] No accepted risk is required.
- [x] Plan-time register verified at ASVS L1.
- [x] `threats_open: 0` confirmed.
- [x] `status: verified` set in frontmatter.

**Approval:** verified 2026-07-27. Phase 51 is threat-secure within its output-evidence scope; Phase 52 still owns effective caps, exhaustive safety/convergence, exact product promotion, and documentation closure.
