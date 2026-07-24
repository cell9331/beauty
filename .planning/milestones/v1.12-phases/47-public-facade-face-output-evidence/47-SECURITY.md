---
phase: 47
slug: public-facade-face-output-evidence
status: verified
threats_open: 0
asvs_level: 1
block_on: high
register_authored_at_plan_time: true
created: 2026-07-24
---

# Phase 47 — Security

> Per-phase security contract for public-facade face output acquisition, bounded decoded evidence, and descriptor-safe ignored gallery publication.

## Trust Boundaries

| Boundary | Description | Data Crossing |
|---|---|---|
| Public renderer source → facade | Case IDs and public scalar requests must not bypass or import internal geometry components. | Public parameters |
| Vision/public facade → degraded result | Missing or malformed observed support must remove dependent work without leaking support or suppressing safe siblings. | Aggregate summaries, warnings, metrics |
| Filesystem → output helper | PNG/JPEG fixtures and renderer outputs are untrusted until opened without following links, bounded, identity-checked, and strictly decoded. | Compressed image bytes |
| Decoded pixels → semantic acceptance | Visibility, locality, eligibility, and independence must use fixed contracts rather than values selected from the accepting matrix. | Aggregate pixel deltas |
| Flat output → gallery | Source files and publication directories may race, alias, change, or contain links. | Ignored PNG bytes |
| Generated evidence → repository | Biometric-adjacent portrait outputs must remain disposable local artifacts rather than tracked product data. | Output/gallery paths |
| Phase evidence → requirements/status | Provisional output evidence must close OUT requirements only and cannot promote final safety or feature rows. | Validation and planning state |

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation / Evidence | Status |
|---|---|---|---|---|---|---|
| T-47-01 | Tampering / Spoofing | renderer inventory | high | mitigate | Exact ordered 59-ID XCTest, one-field snippets, duplicate rejection, and preserved prior IDs pass. | closed |
| T-47-02 | Elevation of Privilege | public facade boundary | high | mitigate | Exact system-plus-`BeautySDK` import list and one shared `engine.processResult` call are enforced by XCTest and helper. | closed |
| T-47-03 | Information Disclosure | no-face/degraded results | high | mitigate | Fixed aggregate assertions and forbidden support/provider/path terms pass across warnings, metrics, and summaries. | closed |
| T-47-04 | Spoofing / Tampering | missing/malformed support | high | mitigate | Testing-only fixtures traverse production mapping/validation; all four new fields equal sibling-only output while `faceSlim` continues. | closed |
| T-47-05 | Tampering / Denial of Service | untrusted images | high | mitigate | No-follow descriptor reads, identity snapshots, 16 MiB/4096²/64 MiB budgets, strict CRC/zlib/filter/decode, and race self-tests pass. | closed |
| T-47-06 | Repudiation | matrix inventory | high | mitigate | Live discovery plus exact 59/7/413 set equality rejects missing, extra, stale, duplicate, symlink, empty, and dimension-changing output. | closed |
| T-47-07 | Tampering / Repudiation | visual thresholds | high | mitigate | Measurement and strict acceptance use separate clean renders; positive committed floors cannot be derived or lowered in strict mode. | closed |
| T-47-08 | Spoofing | locality/independence | high | mitigate | Four fixed watermark-safe regions, zero outside allowance, explicit eligibility, eleven fixed comparators, and adversarial false-positive tests pass. | closed |
| T-47-09 | Information Disclosure | helper/evidence output | high | mitigate | Pixel-only aggregate processing, raw-disclosure token rejection, redacted terminal evidence, and no landmark/provider parsing pass. | closed |
| T-47-10 | Tampering / Elevation of Privilege | gallery publication | high | mitigate | Descriptor-relative no-follow bounded copy, source snapshots, exact renderer equality, staging revalidation, quarantine, and atomic rename self-tests pass. | closed |
| T-47-11 | Repudiation | validation/evidence | high | mitigate | Fresh focused/full counts, independent final strict run, clean review, 16/16 verification, and zero-gap Nyquist audit agree. | closed |
| T-47-12 | Tampering | planning/status ledgers | high | mitigate | Only OUT-01 through OUT-03 close; SAFE/DOC, final caps, feature rows, root owners, and branch status remain unchanged. | closed |
| T-47-13 | Information Disclosure | docs/generated artifacts | high | mitigate | Committed evidence is aggregate; 413 output and 413 gallery files are ignored, untracked, unstaged, non-symlinked, and disposable. | closed |
| T-47-SC | Tampering | package/dependencies | medium | mitigate | No install occurred; `Package.swift` remains blob `6f03b078816ad1f7a426e3f70d4f57503f3152e9`; targets, resources, models, and dependencies are unchanged. | closed |

## Repository-Specific Governance Inputs

| Prohibition | Audit evidence | Status |
|---|---|---|
| Generated portrait outputs must not become tracked biometric-adjacent repository data. | Exact output/gallery tracked, staged, non-ignored, symlink, and publication-slot scans pass; only aggregate Markdown/helper source is committed. | verified |
| The helper must not infer, print, or persist raw contour, centerline, coordinates, provider objects, or filesystem paths. | It consumes decoded RGB rows only, enforces disclosure tokens and public renderer imports, prints aggregate metrics, and creates no evidence cache/persistence. | verified |
| Provisional `0.25` output evidence must not be treated as final safety, promotion, or branch completion. | SAFE-01 through SAFE-03 and DOC-01 remain pending; production caps/providers/resolver/render pass, feature ledgers, root owners, and branch `脸型` are unchanged. | verified |

These statements verify current repository behavior. They do not establish policy for external host applications or future features that do not exist in this source tree.

## Accepted Risks

No accepted risks. The three opt-in Apple Vision integration skips are pre-existing host-configured tests and are covered here by deterministic fixtures plus successful live public output on the committed portraits. Subjective naturalness, device parity, commercial review, final cap calibration, and release readiness are downstream product evidence, not open Phase 47 security threats.

## Security Audit 2026-07-24

| Metric | Count |
|---|---:|
| Threats registered | 14 |
| Closed | 14 |
| Open | 0 |
| Governance inputs resolved | 3 |

Fresh audit evidence:

- Focused renderer/facade suites — **15/15 and 16/16 passed**.
- Full SwiftPM — **371 executed, 3 opt-in Apple Vision skips, 0 failures**.
- Bounded helper — **self-test passed; strict matrix 413/413 passed**.
- Semantic gates — **18/18 visibility/locality, 49/49 fixed-neighbor, 6/6 ineligible no-op, 4/4 no-face no-op**.
- Gallery — **self-test and exact 413-file descriptor-safe publication/bijection passed**.
- Standard review — **clean**.
- Goal verification — **16/16**.
- Nyquist audit — **0 gaps**.
- Package/predecessor hashes, artifact containment, privacy/scope/no-promotion, and complete phase-range diff hygiene — **passed**.

ASVS L1 short-circuit applies because the threat register was authored during planning, every registered threat has direct implementation/test/static evidence, all three repository governance inputs have explicit scoped dispositions, and `threats_open: 0` at the configured high blocking threshold.

## Sign-Off

- [x] Every registered threat has a disposition.
- [x] All high-severity threats are closed.
- [x] All governance inputs have explicit evidence and scope.
- [x] No accepted risk is hidden.
- [x] Generated portrait output remains outside tracked repository data.
- [x] `threats_open: 0` confirmed.
- [x] `status: verified` set in frontmatter.

**Approval:** verified — 2026-07-24
