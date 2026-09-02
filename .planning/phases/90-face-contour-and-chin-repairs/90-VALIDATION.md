---
phase: 90
slug: face-contour-and-chin-repairs
status: validated
nyquist_compliant: true
wave_0_complete: true
created: 2026-09-01
updated: 2026-09-02
---

# Phase 90 — Validation Strategy

> Nyquist contract for the owner-approved Phase 90 contraction: FACE-02
> `chinTaper` is the sole active requirement; FACE-01 `faceContourSmooth` is a
> post-decision `completed-deferred`, non-GREEN artifact routed to FUTURE-04.

---

## Requirement and Evidence Authority

| Item | Phase 90 disposition | Validation authority |
| --- | --- | --- |
| FACE-02 | Sole active requirement; completed by Plan 90-02 and carried through Plans 90-03/04 | `90-02-SUMMARY.md`, focused chin tests, compatibility tests, Phase 89 preflight, archive verification, and SDK-only boundary scan |
| FACE-01 | Post-decision `completed-deferred`; never a completed Phase 90 requirement and never GREEN | `90-01-SUMMARY.md` must remain `status: completed-deferred`, `promotion_eligible: false`, and `requirements-completed: []`; further repair is FUTURE-04 |

The current contour implementation may be sampled only through these two
safe/current-behavior methods:

- `FaceContourSmoothRepairTests/testFACE01ExistingProviderEmitsOneCenteredObservedContourCorrection`
- `FaceContourSmoothRepairTests/testFACE01ProviderFailsOnlyNamedFieldClosedForInvalidSupportAndInputs`

They prove only present callable/fail-closed behavior. They do not prove the
deferred effectiveness contract. Phase 90 must not run
`FaceContourSmoothRepairTests/testFACE01GeneratedCPUFixturePassesFrozenSemanticAndProtectionContract`.

## Test Infrastructure

| Property | Value |
| --- | --- |
| Framework | Swift Testing/XCTest through SwiftPM plus SDK-owned Python, Swift, and Bash gates |
| Config file | `BeautySDK/Package.swift` |
| Immediate feedback | Deterministic summary/document assertions and diff checks, each targeted at no more than 30 seconds |
| Phase-completion evidence | The single bounded Plan 90-04 focused/compatibility/preflight/archive/boundary chain below |
| Persistent evidence | Aggregate command results only; no raw pixels, masks, landmarks, private paths, fixture locators, or child-process transcripts |

No new test scaffold, framework, package, dependency, fixture, model, weight,
network path, renderer case, backend, shader, UI/Demo, or device step is needed.

## Wave and Sampling Order

| Order | Task | Wave | Dependency | Immediate sampling |
| --- | --- | --- | --- | --- |
| 1 | `90-03-01` | 2 | Valid `90-01-SUMMARY.md` and completed `90-02-SUMMARY.md` | Run the terminal-summary assertion before edits; run the task's full automated command before commit |
| 2 | `90-03-02` | 2 | `90-03-01` owner-contract edits | Run its exact-section assertion after edits; run the task's full automated command before commit |
| 3 | `90-04-01` | 3 | `90-03-SUMMARY.md` with `requirements-completed: [FACE-02]` | Run the predecessor-summary assertion and source/script diff check; defer the long test/archive chain to the Phase Completion Gate |
| 4 | `90-04-02` | 3 | Task `90-04-01` quality evidence | Run the completed-ledger assertion after edits; run the task's full automated command before commit |

All available edit-loop checks target at most 30 seconds. The focused Swift
filters, compatibility filter, comparator self-test, `--preflight-only`, archive
verification, and post-archive SDK-only scan run once at phase completion; they
are not repeated as per-edit sampling.

## Per-Task Verification Map

### Task `90-03-01` — Wave 2

**Requirement:** FACE-02. FACE-01 is consumed only as a completed-deferred
predecessor record.

**Exact automated command:**

```bash
python3 -c 'from pathlib import Path; p=Path(".planning/phases/90-face-contour-and-chin-repairs/90-01-SUMMARY.md"); assert p.is_file() and not p.is_symlink(); s=p.read_text(); fm=s.split("---",2)[1]; low=s.lower(); assert "status: completed-deferred" in fm and "promotion_eligible: false" in fm and "requirements-completed: []" in fm; assert "prior_stop_not_reproduced" in low and "zero render/oracle invocations" in low and "revision 23" in low and "not a green" in low; assert "face01_semantic_status=green" not in low; print("FACE01_DEFERRED_SUMMARY_VERIFIED")' && python3 -c 'from pathlib import Path; extract=lambda p,h:Path(p).read_text().split(h,1)[1].split("\n## ",1)[0].lower(); d=extract("DESIGN.md","## Phase 90 Chin Repair and Contour Deferral Design Contract"); t=extract("docs/SDK_EFFECT_TAXONOMY.md","## Phase 90 Chin Repair and Contour Deferral"); assert all(x in d for x in ("facecontoursmooth","partial","future-04","prior_stop_not_reproduced","zero render","chintaper","0.25","0.016","float.ulpofone","phase 95")); assert all(x in t for x in ("facecontoursmooth","partial","future-04","chintaper","implemented","62","five","75")); print("phase90_design_taxonomy=deferred-plus-proven")' && git diff --quiet -- BeautySDK scripts && git diff --check
```

**Nyquist result:** The command validates the terminal FACE-01 disposition,
the FACE-02 design/taxonomy contract, and zero production/test/script drift.

### Task `90-03-02` — Wave 2

**Requirement:** FACE-02, with FACE-01 preserved only as deferred context.

**Exact automated command:**

```bash
python3 -c 'from pathlib import Path; extract=lambda p,h:Path(p).read_text().split(h,1)[1].split("\n## ",1)[0].lower(); p=extract("PRODUCT_SENSE.md","## Phase 90 Chin Repair and Contour Deferral Owner Journey"); s=extract("SECURITY.md","## Phase 90 Chin Repair and Contour Deferral Trust Boundary"); r=extract("RELIABILITY.md","## Phase 90 Chin Repair and Contour Deferral Reliability Contract"); assert all(x in p for x in ("facecontoursmooth","partial","chintaper","62","five","75","phase 95","owner-local")); assert all(x in s for x in ("prior_stop_not_reproduced","request-local","aggregate","zero render","phase 95")); assert all(x in r for x in ("completed-deferred","chintaper","neutral","0.25","fail closed","phase 95","one-step")); joined=p+s+r; assert not any(x in joined for x in ("release ready","commercially ready","device qualified","face-01 is green")); print("phase90_owner_contracts=deferred-plus-proven")' && git diff --quiet -- BeautySDK scripts && git diff --check
```

**Nyquist result:** The command checks the product, security, and reliability
owners against the same FACE-02-complete/FACE-01-deferred contract.

### Task `90-04-01` — Wave 3

**Requirement:** FACE-02. The two allowlisted contour methods are current-safety
sampling only.

**Exact automated command:** This is the long bounded evidence chain and is
scheduled only as the Phase Completion Gate below, not as an edit-loop sample.

```bash
swift test --package-path BeautySDK --filter 'ChinTaperRepairTests|BeautyEngineChinTaperRepairTests|FaceContourSmoothRepairTests/testFACE01ExistingProviderEmitsOneCenteredObservedContourCorrection|FaceContourSmoothRepairTests/testFACE01ProviderFailsOnlyNamedFieldClosedForInvalidSupportAndInputs|FaceShapeWarpProviderTests|BeautyEffectResolverTests|GeometryConflictResolverTests|CombinedEffectSafetyTests|BeautyMetalGeometryPassTests|MissingLandmarkDegradationTests' && swift test --package-path BeautySDK --filter 'BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|BeautyEngineTests|BeautyEngineGeometryFacadeTests|BeautyEngineMetadataCompatibilityTests|BeautyBackendContractTests|BeautyEngineBackendRoutingTests|BeautyBackendSelectionConcurrencyTests' && swift scripts/compare-face-feature-batches.swift --self-test && bash scripts/run-face-feature-batches.sh --preflight-only && python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui && bash scripts/check-sdk-only-boundary.sh --post-archive && python3 -c 'from pathlib import Path; q=Path("QUALITY_SCORE.md").read_text().split("## Phase 90 Chin Repair and Contour Deferral Evidence",1)[1].split("\n## ",1)[0].lower(); required=("face-01","completed-deferred","face-02","chintaper","partial","62","five","75","75/65/8","float.ulpofone.nextup","nextdown","quantization","tie","phase 95","preflight-only","no-skip"); assert all(x in q for x in required); assert not any(x in q for x in ("face-01 is green","65/65 semantic_pass","release ready","commercially ready","device qualified")); print("phase90_quality=bounded-closeout")' && git diff --quiet -- BeautySDK scripts && git diff --check
```

**Nyquist result:** The command produces bounded package-host evidence for
FACE-02, samples only the two permitted contour safety methods, and keeps live
portrait and final no-skip ownership outside Phase 90.

### Task `90-04-02` — Wave 3

**Requirement:** FACE-02 closeout and deterministic Phase 91/95 handoff.

**Exact automated command:**

```bash
python3 -c 'from pathlib import Path; p=Path("PLANS.md").read_text(); heading="### C-2026-09-02-phase-90-chin-repair-and-contour-deferral"; assert heading in p; s=p.split(heading,1)[1].split("\n### ",1)[0].lower(); required=("completed","face-01","completed-deferred","future-04","prior_stop_not_reproduced","face-02","chintaper","62","five","75","75/65/8","phase 91","one research","two implementation attempts","phase 95","seven","no-skip","one-step","tie"); assert all(x in s for x in required); assert not any(x in s for x in ("face-01 is green","65/65 semantic_pass","release ready","commercially ready","device qualified")); active=p.split("## 3. Active",1)[1].split("## 4. Completed",1)[0]; assert "P-2026-08-29-phase-90-face-contour-smooth" not in active; print("phase90_ledger=completed-deferred-plus-face02")' && git diff --quiet -- BeautySDK scripts && git diff --check
```

**Nyquist result:** The command proves the ledger completes FACE-02 only,
records FACE-01 as FUTURE-04/completed-deferred, and preserves source/script
immutability.

## Chin Precision Residual Owned by Phase 95

Phase 90 records, but does not add tests for, these direct-test residuals:

- `Float.ulpOfOne.nextUp` at the strict neutral threshold.
- `BeautySafetyCaps.chinTaper.nextDown` and
  `BeautySafetyCaps.chinTaper.nextUp` around the cap.
- The representable values immediately below, equal to, and immediately above
  the quantization threshold.
- Strict-comparison tie behavior, including the exact equality branch for
  `immediateDistance == maximumDisplacement * 0.5` and the source's strict
  `<` selection behavior.

Direct Phase 90 evidence already covers exact `Float.ulpOfOne` rejection,
`Float.ulpOfOne.nextDown` rejection, least-nonzero rejection, half strength
`0.125`, exact cap `0.25`, and request `1` clamping to the cap. Source-defined
behavior is not mislabeled as directly executed evidence.

## Phase Completion Gate

Run the following bounded Plan 90-04 gate once after Tasks `90-03-01`,
`90-03-02`, `90-04-01`, and `90-04-02` complete in wave order:

```bash
python3 -c 'from pathlib import Path; paths=[(".planning/phases/90-face-contour-and-chin-repairs/90-01-SUMMARY.md","01"),(".planning/phases/90-face-contour-and-chin-repairs/90-02-SUMMARY.md","02"),(".planning/phases/90-face-contour-and-chin-repairs/90-03-SUMMARY.md","03")]; docs={k:Path(p).read_text() for p,k in paths}; f1=docs["01"].split("---",2)[1]; f2=docs["02"].split("---",2)[1]; f3=docs["03"].split("---",2)[1]; completed=lambda f:next(line.strip() for line in f.splitlines() if line.strip().startswith("requirements-completed:")); assert "status: completed-deferred" in f1 and "promotion_eligible: false" in f1 and completed(f1)=="requirements-completed: []"; assert completed(f2)=="requirements-completed: [FACE-02]" and completed(f3)=="requirements-completed: [FACE-02]"; print("PHASE90_PREDECESSORS_VERIFIED")' && swift test --package-path BeautySDK --filter 'ChinTaperRepairTests|BeautyEngineChinTaperRepairTests|FaceContourSmoothRepairTests/testFACE01ExistingProviderEmitsOneCenteredObservedContourCorrection|FaceContourSmoothRepairTests/testFACE01ProviderFailsOnlyNamedFieldClosedForInvalidSupportAndInputs|FaceShapeWarpProviderTests|BeautyEffectResolverTests|GeometryConflictResolverTests|CombinedEffectSafetyTests|BeautyMetalGeometryPassTests|MissingLandmarkDegradationTests' && swift test --package-path BeautySDK --filter 'BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|BeautyEngineTests|BeautyEngineGeometryFacadeTests|BeautyEngineMetadataCompatibilityTests|BeautyBackendContractTests|BeautyEngineBackendRoutingTests|BeautyBackendSelectionConcurrencyTests' && swift scripts/compare-face-feature-batches.swift --self-test && bash scripts/run-face-feature-batches.sh --preflight-only && python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui && bash scripts/check-sdk-only-boundary.sh --post-archive && git diff --quiet -- BeautySDK scripts && git diff --check
```

All commands must pass, no HIGH threat may remain open, the Task 90-04-01
QUALITY_SCORE assertion and Task 90-04-02 PLANS assertion must pass, and
`git diff --quiet -- BeautySDK scripts` must confirm no production, test, or
script drift.

## Prohibited Phase 90 Execution

Phase 90 must not run:

- `FaceContourSmoothRepairTests/testFACE01GeneratedCPUFixturePassesFrozenSemanticAndProtectionContract`.
- Live portrait execution through `scripts/run-face-feature-batches.sh`; only
  `--preflight-only` is permitted.
- `scripts/run-no-skip-swiftpm.sh`.
- Any device, commercial, release-readiness, packaging, launch, shipping, or
  external-distribution qualification.

Phase 95 owns the clean 65-output run, seven effective directions plus the one
explicitly deferred contour direction, the precision residual above, and the
complete all-opt-ins no-skip closeout.

## Privacy and Product Boundary

- Persist aggregate-only command outcomes; never persist raw pixels, masks,
  landmarks, anatomy, private fixture locators, local paths, or child output.
- Keep the repository SDK-only and owner-local. Do not restore UI/Demo source.
- Package-host evidence is not real-device evidence and grants no commercial,
  release, packaging, launch, shipping, or distribution authority.
- Archive verification must precede the post-archive SDK-only boundary scan.

## Validation Sign-Off

- [x] FACE-02 is the only active Phase 90 requirement in the task map.
- [x] FACE-01 is a completed-deferred, promotion-ineligible, zero-requirement
  artifact routed to FUTURE-04 and is never represented as GREEN.
- [x] All four pending tasks have exact automated commands and explicit wave
  order.
- [x] Immediate task sampling targets no more than 30 seconds where available;
  the long evidence chain is phase-completion only.
- [x] The contour test allowlist contains exactly the two current-safety methods.
- [x] Live portrait, frozen FACE-01 effectiveness, and complete no-skip commands
  are excluded from Phase 90.
- [x] Phase 95 retains all named direct precision/tie residuals.
- [x] Phase completion requires zero `BeautySDK`/`scripts` diff.
- [x] Aggregate-only privacy, SDK-only, owner-local, and non-device/commercial/
  release/distribution boundaries are explicit.

**Approval:** validation contract reconciled to the owner-approved contraction;
execution evidence remains produced by Plans 90-03/04.
