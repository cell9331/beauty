# Eye tilt — 倾斜

[Current implementation comparison](当前实现对照.md)

[Current-map comparison and directed validation](实施与验证.md) · [Implementation migration plan](改造计划.md) · [Separate evidence gaps](../证据缺口.md)

[Eye analysis index](../README.md) · [Evidence chain](分析链路.md) · [Candidate implementation](实现方案.md) · [Local measurement notes](本地测量说明.md)

**Status: a finite rotational core is supported; peripheral support and pivot remain uncertain.** Fresh analysis dated 2026-10-16 compares `IMG_1945.PNG → IMG_1946.PNG`, the observed left-to-right slider span. This is an endpoint rotation span, not two neutral-referenced angles.

Both eyes lower the outer side and raise the inner side in this pair. The accompanying horizontal motion also reverses between upper and lower texture. Independent core correspondences fit an approximately 8–9° mirrored finite rotation substantially better than a vertical-only shear. A whole eye window also contains stationary peripheral skin and therefore cannot be treated as one rigid object.

![Aligned endpoints, signed fields, and profiles](证据/位移证据.png)

![Independent full-vector core geometry and competing shear fit](证据/旋转机制复核.png)

The proposed field combines finite core rotation with a continuous return to stationary surroundings. It is a candidate, not a statement of the original algorithm or an implemented SDK effect. Local images and raw correspondences follow repository privacy and ignore rules.

The owner skipped further 去脂 work and proceeded to tilt. The [current-map execution record](实施与验证.md) adds a conditional same-source endpoint comparator, actual photo replay, full-vector/rigidity diagnostics and 30 distinct directed test passes. The existing production tilt formula is retained; neutral, support and independent reference acceptance remain unresolved.
