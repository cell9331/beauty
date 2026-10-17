# Iris size — 眼瞳大小

[Current implementation comparison](当前实现对照.md)

[Side-by-side review and minimum evidence plan](效果对照与补证方案.md) · [Implementation migration plan](改造计划.md) · [Implementation and directed validation](实施与验证.md) · [Separate evidence gaps](../证据缺口.md)

[Eye analysis index](../README.md) · [Input inventory](../输入清单.md)

Status: **measured endpoint comparison; calibrated research implementation tested on 2026-10-17; reference-effect qualification not passed**. Analysis date: 2026-10-16. Source: `IMG_1939.PNG`, observed left slider endpoint. Target: `IMG_1940.PNG`, observed right endpoint. Neither a numeric slider value nor a common neutral state is established.

The observed span expands the region around each iris: horizontal displacement points away from the iris center, and the upper/lower parts move upward/downward. The effect also moves adjacent scleral texture and central eyelid margins. An iris-only binary mask with fixed lids is therefore inconsistent with this pair. The outer canthi are much quieter; the nasal side has weak residual follow motion and should not be declared strictly fixed.

Dense eye-window displacement magnitude P99 is approximately **11.24 px / 11.10 px** for the image-left/right eyes. These are quantiles of estimated fields, not exact maxima or original-camera pixels. Independent mobile texture matches differ from the main dense method by P95 **1.03 px**; a smaller-template eye-only check increases this to **2.25 px**, revealing uncertainty around occlusion and support transitions.

![Aligned endpoint comparison, signed horizontal/vertical displacement, and marked profiles](证据/位移证据.png)

The figure shows the actual left-to-right span on the screenshot grid. Curves aggregate seven-pixel bands; black markers are nearby independent texture matches, not exact samples on the curve. Heatmap colors encode displacement only.

- [Analysis chain](分析链路.md): measurements, cross-checks, protected areas, and remaining ambiguity.
- [Candidate implementation](实现方案.md): compact local expansion and its falsification criteria.
- [Local measurement record](本地测量说明.md): retained artifacts and replay limits.

The follow-up [implementation record](实施与验证.md) documents the new explicit following-field route, 44 distinct directed test passes, actual photo replay, failed/insufficient effect evidence and remaining gates. The normal public/editor route is unchanged; no portrait-specific support/gain defaults were promoted. The reference effect has not been qualified as reproduced.

**Owner disposition, 2026-10-17:** retain the current local rendered outcome and continue to the next planned feature, 去脂. No further iris calibration is made in that next task. This retention decision does not close the documented evidence gates or select the research route as the normal SDK/editor default.
