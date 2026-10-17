# Eye reference displacement analysis

[Reference-analysis library](../README.md) · [Input inventory](输入清单.md) · [Shared candidate mathematics](实现公共约定.md) · [Validation and limits](验证记录.md) · [Current eleven-control comparison](十一项当前实现对照.md) · [Original seventeen-control audit](实现差异统计.md) · [Migration plan](改造计划.md) · [Evidence gaps](证据缺口.md)

Analysis started 2026-10-16 and reviewed 2026-10-17 on branch `codex/eye-displacement-analysis-20261016`. This study examines every eye control represented by the supplied screenshot set: **23 screenshots, 12 selected controls, and 5 additional visible menu controls without effect samples**. The latter receive explicit evidence-gap records. This is not a claim to cover controls absent from the supplied menus or other versions of the application.

The original English study describes measured geometry, competing explanations, a minimal candidate forward field, and tests that could disprove it. That analysis did not change the SDK/host. UI names identify inputs; they do not establish proprietary mechanisms. Heatmap colors encode displacement, not an appearance/color study.

The follow-up [migration plan](改造计划.md), prepared on 2026-10-17, gives first priority to iris size, upper-eyelid adjustment and tilt, with individual plans for all 17 controls and a separate [evidence-gap register](证据缺口.md). The subsequently authorized [iris implementation record](眼瞳大小/实施与验证.md) now documents an explicit calibrated research route, 44 distinct directed test passes and actual photo replay. Its effect gate remains unpassed; default/editor behavior and the other 16 controls are unchanged by that implementation.

The owner retained the current iris outcome, then deferred/skipped further 去脂 work. Its [test-only experiment and failed/insufficient evidence](去脂/实施与验证.md) remain preserved, with scalar/default/host behavior unchanged. The next [tilt execution record](倾斜/实施与验证.md) establishes the current conditional relative-endpoint baseline and 30 distinct directed test passes. Its production formula is retained; the reference-effect gate is unqualified.

## Feature-by-feature results

Every selected control has its own overview, evidence chain, candidate scheme, local measurement note and locally retained evidence figure. Filenames remain consistent with the existing library; the analysis prose is English.

| Control | Observed inputs | Supported result | Qualification / main limit |
| --- | --- | --- | --- |
| [大小 — eye size](大小/README.md) | 1928 → 1929 | Two-dimensional expansion; approximately similar core gains in x/y | Supports an expansion core; precise anisotropy/support unresolved |
| [上下 — vertical position](上下/README.md) | 1930 → 1931 | Inferior core translation, about +19.52/+18.40 px dy | Independent core rigidity supported; transition widths unresolved |
| [眼高 — eye height](眼高/README.md) | 1932 → 1933 | Superior/inferior separation, predominantly normal expansion | Dense-method sensitivity prevents precise gain/anchor calibration |
| [长度 — eye length](长度/README.md) | 1934 → 1935 | Tangential expansion; independent core relative horizontal gain about 1.15 | Small normal follow motion retained; precise support unresolved |
| [眼距 — eye spacing](眼距/README.md) | 1936 → 1937 | Outward core translations, about −26.96/+25.58 px dx | Approximate core rigidity supported; bridge-side falloff unresolved |
| [去脂 — upper-eyelid adjustment](去脂/README.md) | S0 → 1938 only | Upper-lid texture moves upward by roughly 1–2 px | **Source-relative only; no isolated control span or certified zero** |
| [眼瞳大小 — iris-size control](眼瞳大小/README.md) | 1939 → 1940 | Compact expansion also moves adjacent lids and sclera | A strict iris-only mask is contradicted; narrow boundaries uncertain |
| [眼睑下至 — lower-lid adjustment](眼睑下至/README.md) | 1941 → 1942 | Local inferior displacement at outer lower-lid regions | **Partial: mobile-point peak validation failed; exact amplitude unresolved** |
| [眼尾上扬 — outer-eye lift](眼尾上扬/README.md) | 1943 → 1944 | Compact upward outer-eye displacement | Local bump is a candidate; a pivoted rotation is not fully excluded |
| [倾斜 — tilt](倾斜/README.md) | 1945 → 1946 | Finite rotational core with opposite bilateral signs | Small-template fits about 8–9° endpoint span; template bias retained |
| [内眼角 — inner canthus](内眼角/README.md) | 1947 → 1948 | Local nasal-corner displacement toward the nose | Sparse moving checks and method sensitivity limit peak/support claims |
| [外眼角 — outer canthus](外眼角/README.md) | 1949 → 1950 | Local temporal-corner displacement outward | Small vertical component retained; no exact horizontal-only claim |
| [提肌 — lid-lift menu item](提肌/README.md) | Visible OFF only | No effect map measured | Missing selected/effect samples |
| [眼神矫正 — gaze-correction menu item](眼神矫正/README.md) | Visible OFF only | No effect map measured | Missing selected/effect samples |
| [对称 — symmetry](对称/README.md) | Menu only | No effect map measured | Missing state and effect samples |
| [去眼袋 — under-eye-bag menu item](去眼袋/README.md) | Menu only | No effect map measured | Missing state and effect samples |
| [祛红血丝 — redness menu item](祛红血丝/README.md) | Menu only | No effect map measured | A redness study would need separately defined appearance evidence |

Numbers identify the screenshot suffixes, not slider values. “Image-left/right” is screen position. All displacements use native aligned screenshot pixels, x right and y down. Paired figures use photo-crop coordinates; the source-relative 去脂 figure explicitly uses full screenshot coordinates. The [shared conventions](实现公共约定.md) explain domain conversion and endpoint comparability.

## Input state, global alignment and neutral qualification

All 23 screenshots encode 1170 × 2532 pixels and contain the same portrait/photo display. UI labels and sliders were checked individually using a contact sheet and native-detail strips. Eleven controls have a left and right endpoint; 去脂 has one right-endpoint state. **No numeric slider values or neutral screenshot are visible.** The UI does not certify that previous adjustments were reset. A direct pairwise endpoint map can be measured without inventing neutral strengths, symmetry, or intermediate response.

The registration audit excludes the eyes, brows, UI and photo overlays. It selects distributed stable photo texture independently of the effect field: 153 candidates, 143 accepted, 10 rejected for ambiguous peaks; 95 fit points and 48 held-out points. Accepted screenshot-to-screenshot peaks are exactly identity. The stable pixel audit is byte-identical for 16 screenshots; the other seven differ only at 167–168 upper-hair pixels with a maximum channel change of 6/255. No global geometric correction is warranted. **Screenshot pairs preserve the native crop bytes without resampling**, and no deformable registration removes the target change. This does not prove zero effect elsewhere or certify common neutral state.

A separate authorized photograph, S0, is supported as the same photographic content after one stable-region similarity transform (scale approximately 0.94376; negligible rotation). Among all 824 held-out SIFT matches, residual median/P95 is 0.292/0.859 px; a retained false match reaches 46.7 px. Independent stable NCC accepts 131/153 candidates, with median/P95/max residual 0.072/0.200/0.374 px. S0 is sampled directly onto the screenshot grid once. This supports the source-relative 去脂 comparison above its measured registration floor; content identity and alignment **do not establish S0 as the application's common neutral**.

## Field estimation and independent checks

Before measurement the local protocol fixed source/target order, coordinate signs, effect and protection observations, registration restrictions and competing mechanisms. DIS dense forward and reverse estimates retain dx and dy separately. Forward/backward closure, a second dense method (Farneback), source-texture NCC checks, native endpoint inspection and per-feature core/semantic checks test their limits. Weak skin texture is an estimate; dense pixel counts do not constitute independent evidence.

The primary paired-study NCC uses source-only spatial texture selection, a 19 px template, ±64 px search expanded to ±96 px when needed, contrast/peak-uniqueness checks and independent reverse closure. No correspondence is initialized or accepted by flow agreement. The following are **cross-method differences**, not ground-truth errors. Mobile means independently measured magnitude >2 px; stationary means <0.5 px. The points between those thresholds are retained in the per-feature counts. 去脂 uses its own smaller-motion checks and is intentionally outside this table.

| Pair | Accepted / source candidates | Mobile count | Mobile NCC–DIS P95, px | Stationary count / P95, px |
| --- | ---: | ---: | ---: | ---: |
| Eye size | 263 / 376 | 54 | 1.02 | 201 / 0.086 |
| Vertical position | 254 / 382 | 57 | 0.60 | 197 / 0.085 |
| Eye height | 253 / 382 | 43 | 2.86 | 204 / 0.086 |
| Eye length | 273 / 381 | 52 | 1.06 | 205 / 0.084 |
| Eye spacing | 256 / 380 | 58 | 0.91 | 198 / 0.086 |
| Iris size | 262 / 385 | 31 | 1.03 | 227 / 0.103 |
| Lower lid | 269 / 387 | 4 | **12.33 — failed peak qualification** | 264 / 0.087 |
| Outer-eye lift | 260 / 387 | 9 | 1.22 | 244 / 0.104 |
| Tilt | 246 / 380 | 41 | 1.26 | 201 / 0.084 |
| Inner canthus | 272 / 383 | 8 | 2.28 | 263 / 0.097 |
| Outer canthus | 273 / 386 | 11 | 1.50 | 259 / 0.086 |

Exact acceptance/rejection reasons, independent stationary coverage, secondary-method sensitivity and retained disagreements appear in each evidence chain. The lower-lid study was rechecked with denser source selection and multiple template sizes; it remains partial. Tilt was rechecked on source-defined core correspondences with rigid/affine/shear models and a finite-rotation control. Those refinements improve the mechanism test without replacing inconvenient primary results. The iris and corner studies additionally inspect source-defined anatomical/protection windows.

Evidence figures provide endpoint crops, signed dx/dy heatmaps with complete component ranges, coordinate-marked horizontal/vertical narrow-band profiles, and nearby independent points. Curves are estimates; markers need not lie exactly on their strip. Both local scales and all units are labelled. No field, actual point list, mask or original pixel array enters aggregate Markdown.

## Retention and verification boundary

The function-level `证据/` figures are retained locally and remain ignored by Git. Shared and feature-local `本地测量/` directories hold raw observations, correspondence arrays, fields, control receipts and script snapshots under the existing ignore rule. The English aggregate documents are trackable. Without the authorized local images/evidence, a repository clone contains the conclusions and limits but cannot reproduce the measurements or display the local figures.

The original analysis verification covers the input inventory, stable alignment, geometric measurements, selected synthetic controls, formula review, documents, references and ignore rules, with no SDK build or rendered-candidate acceptance at that time. The subsequent [iris implementation record](眼瞳大小/实施与验证.md) adds focused Swift builds/tests and actual photo replay, without a simulator/device run, full regression or reference-effect acceptance. The [validation record](验证记录.md) distinguishes these scopes.
