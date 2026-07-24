# Phase 48 Face Safety Evidence

**Accepted:** 2026-07-24  
**Mode:** pre-promotion  
**Requirements:** SAFE-01, SAFE-02, SAFE-03

## Result

PASS. Fresh runtime, source-boundary, immutable decoded-output, gallery, privacy, security, and repository-hygiene gates all passed before any feature-row mutation.

The evidence freezes the four final `0.25` caps, the complete nine-field face/chin degradation contract, exact 37-field one-baseline convergence, and the unchanged Phase 47 public-facade saved-output contract. It does not claim physical-device parity, subjective naturalness, optimized performance, commercial approval, packaging, shipping, launch readiness, or milestone audit/archive completion.

## Runtime Evidence

The seven focused suites ran from the current Phase 48 source:

| Suite | Result |
|---|---:|
| `BeautySafetyCapsTests` | 5/5 |
| `BeautyEffectResolverTests` | 22/22 |
| `FaceShapeWarpProviderTests` | 17/17 |
| `MissingLandmarkDegradationTests` | 44/44 |
| `GeometryConflictResolverTests` | 13/13 |
| `CombinedEffectSafetyTests` | 15/15 |
| `BeautyEngineGeometryFacadeTests` | 16/16 |
| **Focused total** | **132/132** |

The full command passed:

```bash
swift test --package-path BeautySDK
```

Result: **375 tests executed, 3 pre-existing opt-in Apple Vision integration skips, 0 failures**.

Exact requirement evidence:

- SAFE-01: four exact final caps; positive-only zero/exact/overflow/negative/non-finite accounting; complete nine-field fresh/reused/stale/no-face/missing/malformed/provider-empty stateless transitions; redacted metadata.
- SAFE-02: exact ordered total `3.35 + 4.10 + 1.80 + 2.45 = 11.70`, retained count 37, one scale `1 / 11.70`, exact 37-removal ceiling, named-provider sanitization equality, and unified-dispatch equality.
- SAFE-03: public/SPI, persistence, diagnostics, import, dependency, model/resource, network/cloud, commercial, active-source, deferred-row, artifact, status, and command-error gates fail closed.

## Boundary Evidence

```bash
PYTHONPYCACHEPREFIX=/tmp/beauty-pycache python3 -m py_compile \
  .planning/phases/48-face-safety-and-scoped-closeout/check_face_safety_boundaries.py

python3 .planning/phases/48-face-safety-and-scoped-closeout/check_face_safety_boundaries.py \
  --self-test

python3 .planning/phases/48-face-safety-and-scoped-closeout/check_face_safety_boundaries.py
```

Results:

- Python compile: passed.
- Inherited plus Phase 48 mutation matrix: **70/70 passed**.
- Default pre-promotion live mode: **17/17 passed**.
- Active-source inventory: exactly **8/8** classified owners and zero unclassified matches.
- Public model: exactly **52 stored fields = 51 numeric + `filterId`**, with no public/SPI observed-support type.
- Status: exactly four target rows remain future; three semantic-region rows remain future; branch `脸型` remains partial.
- Generated roots: tracked 0, staged 0, non-ignored untracked 0.

The checker distinguishes `rg` match, clean no-match, and command error states; validates repository roots and required paths; rejects symlinks and escapes; and includes positive plus one-failure-per-boundary fixtures.

## Immutable Phase 47 Output Evidence

The unchanged helper and gallery self-tests passed:

```bash
python3 .planning/phases/47-public-facade-face-output-evidence/check_face_geometry_renderer_outputs.py \
  --self-test

python3 example-images/generate_gallery.py --self-test
```

After validating the physical output path and ignore rule, the exact output directory was cleaned and rendered afresh:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run \
  --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/output
```

Strict acceptance:

```bash
python3 .planning/phases/47-public-facade-face-output-evidence/check_face_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

Fresh result:

- exact inventory: **59 cases × 7 fixtures = 413/413** decoded, non-empty, same-dimension PNGs;
- eligible visibility/locality: **18/18**;
- fixed-neighbor distinctions: **49/49**;
- ineligible portrait no-ops: **6/6**;
- no-face watermark-safe no-ops: **4/4**;
- intended ROI share: minimum `1.000000`;
- outside changed pixels and RGB delta: maximum 0;
- renderer route: public `BeautySDK` facade only; raw geometry disclosure 0.

The gallery self-test passed, then exact publication wrote **413** ignored PNGs. Output/gallery bijection and containment were checked after publication:

- output PNGs: 413;
- gallery PNGs: 413;
- symlinks: 0;
- ignored output/gallery paths: 413/413 and 413/413;
- tracked, staged, and non-ignored untracked generated paths: 0/0/0.

## Pinned Source Hashes

Hashes use `git hash-object`:

| Owner | Blob hash |
|---|---|
| `BeautySDK/Package.swift` | `6f03b078816ad1f7a426e3f70d4f57503f3152e9` |
| Phase 45 support checker | `7f7cb4ad0ec7463e065ad7b88c6858c0fceb10c4` |
| Phase 47 strict helper | `ad25295356566a86d2b727cfb072fba62d24b4e7` |
| Gallery generator | `f68ee13855f99607480b1045b3c8f0ec8a0bdca1` |
| Public renderer source | `21c64452611bd45663db8d99660dd181bd1f131f` |
| Phase 48 safety checker | `2203901f66b6c7329b19a2c08cf1d0e0cec737de` |

## Review, Security, and Hygiene

- Standard review of `4f8703e..4fd4a78`: clean, with no critical, warning, or info finding.
- ASVS L1 Phase 48 analysis: all 16 registered threats and three repository-specific governance inputs closed; `threats_open: 0`.
- `git diff --check`: passed.
- Working tree before evidence authoring: clean.
- No dependency, target, render-pass, resource/model, network/cloud, account/payment/VIP/entitlement, Demo, public API, or generated-media tracking change occurred.

## Promotion Authorization

Pre-promotion evidence is green. Plan 48-04 is authorized to mutate exactly the four named blueprint rows and no other product status. The post-promotion and owner gates remain mandatory before Phase 48 can hand off to the independent milestone audit.
