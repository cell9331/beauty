# Lower-lid lowering — 眼睑下至

[Current implementation comparison](当前实现对照.md)

[Implementation migration plan](改造计划.md) · [Separate evidence gaps](../证据缺口.md)

[Eye analysis index](../README.md) · [Evidence chain](分析链路.md) · [Candidate implementation](实现方案.md) · [Local measurement notes](本地测量说明.md)

**Status: partial geometric identification; peak displacement and horizontal motion remain unresolved.** Fresh analysis dated 2026-10-16 compares `IMG_1941.PNG → IMG_1942.PNG`, the observed left-to-right slider endpoints. These images do not establish a neutral state, a symmetric signed range, or an intermediate response.

The reference opens the outer part of the lower eyelid downward while the inner eye and much of the upper contour remain stable. A compact lower-lid deformation is supported. The exact peak, footprint, and horizontal component are not independently established: dense methods disagree substantially, and the initial moving-point check fails despite a very small all-point statistic. The candidate is a falsifiable local field, not a calibrated reproduction or a claim about the closed-source algorithm.

![Aligned endpoint crops, signed displacement estimates, and targeted profiles](证据/位移证据.png)

The figure deliberately retains conflicting correspondences. Images and raw measurements stay local under the repository's evidence policy; the English Markdown records aggregates and reasoning. No SDK implementation, SDK test, or simulator run is part of this analysis.
