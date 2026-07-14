---
phase: 36
review: ASVS L1
threats_open: 0
---

# Phase 36 Security Review

## Scope and Blocking Rule

This ASVS L1 review covers local fixture/output parsing, biometric-adjacent image and geometry privacy, cleanup and gallery path containment, dependency/network drift, generated-artifact tracking, evidence integrity, and premature product promotion. Any unresolved high-severity threat blocks Phase 36 completion. `threats_open` was set to `0` only after the fresh focused/full XCTest, renderer build, guarded clean renderer/helper/gallery, containment, boundary, no-promotion, schema-drift, and diff-hygiene gates all passed.

Assets: committed fixtures, ignored renderer/gallery artifacts, aggregate evidence, public-facade isolation, planning traceability, and the later atomic Phase 37 promotion.

Trust boundaries: committed local fixtures enter the public renderer; generated flat outputs enter the decoder and gallery copier; only aggregate counts/minima and owned scripts/docs cross into git; product readiness remains outside this phase.

## Threat Register

| ID | Threat | Severity | Mitigation | Observed automated evidence | Residual risk | Status |
| --- | --- | --- | --- | --- | --- | --- |
| T36-01 | Malformed, duplicate, missing, extra, truncated, or dimension-drifted fixture/output data spoofs the matrix | high | Discover both inventories, reject duplicate IDs/stems, require exact 36 × 7 product, fully decode PNG streams/CRC/filter rows, and reject missing/extra/dimension drift | Helper self-tests plus fresh strict 252/252 decode passed | New fixture or renderer cases require intentional inventory updates | mitigated; closed |
| T36-02 | Raw fixture pixels, face geometry, coordinates, paths, or framework objects leak into committed evidence | high | Keep PNGs ignored; record only aggregate counts, extents, comparison minima, fixed ROI, and category-only no-face evidence | Renderer XCTest redaction passed 10/10; tracked/staged scans are empty; evidence contains no raw geometry payload | Phase 37 owns the final active-source privacy scan | mitigated; closed |
| T36-03 | Cleanup escapes the disposable output/gallery roots or follows an unsafe gallery path | high | Require exact physical output root and git-ignore before deletion; gallery root is allow-listed, non-overlapping, and rejects a gallery symlink | Guarded clean render and safe-root gallery generation passed | Operators must retain the allow-listed commands | mitigated; closed |
| T36-04 | Gallery silently omits or duplicates renderer cases while still producing plausible files | high | Flatten `CASE_GROUPS`, reject duplicates, and require exact equality with discovered `RenderCase` IDs before copying | Clean gallery wrote exactly 252 files after exact inventory validation | Future case additions fail closed until gallery routing is updated | mitigated; closed |
| T36-05 | Network/cloud/commercial behavior or a dependency/target is added under an evidence-only phase | high | Renderer imports only `BeautySDK` plus platform libraries; helper/gallery use the standard library; Package.swift, product sources, and Demo are guarded read-only | Import/token, Package.swift, active-source, Demo, and baseline diff gates passed | Phase 37 reruns final active-source closeout | mitigated; closed |
| T36-06 | Generated PNGs are staged or tracked | high | Keep output/gallery ignored and check representative paths plus full tracked/staged roots | 252 output and 252 gallery PNGs are ignored; tracked/staged queries are empty | Local disposable files remain outside source control | mitigated; closed |
| T36-07 | Output evidence is promoted into final caps, product rows, whole-branch completion, or release readiness | high | Guard product ledgers, nose README, PROJECT, QUALITY_SCORE, providers/resolvers/caps, Package.swift, and Demo as read-only; state explicit non-claims | Baseline diff is quiet for every guarded owner; `提升` remains future, `山根` partial, and branch-level `鼻子` partial | Phase 37 owns cap, exhaustive safety, boundary closeout, and atomic promotion | mitigated; closed |
| T36-08 | Copied or stale test output is reported as fresh verification | high | Run focused and full SwiftPM plus a guarded clean render/helper/gallery in the final closeout | Fresh 10/10 focused and 220/220 full XCTest passed; fresh 252/252 output and gallery gates passed | Future source changes require fresh reruns | mitigated; closed |

## Residual Risk and Non-Claims

Phase 36 proves deterministic public-facade output visibility, non-aliasing, extent, and local artifact containment. The `0.25` values remain provisional output inputs. Final caps, exhaustive six-field no-face/missing/stale/reused/provider-empty behavior, exactly-once combined weakening, final active-source closeout, product-row promotion, and branch completion remain Phase 37. No device parity, commercial visual approval, packaging, shipping, launch readiness, or broad product parity is claimed.
