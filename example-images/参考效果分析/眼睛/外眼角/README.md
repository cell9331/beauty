# Outer canthus — 外眼角

[Current implementation comparison](当前实现对照.md)

[Implementation migration plan](改造计划.md) · [Separate evidence gaps](../证据缺口.md)

[Eye analysis index](../README.md) · [Input inventory](../输入清单.md)

Status: **measured endpoint comparison; candidate geometry only**. Analysis date: 2026-10-16. Source: `IMG_1949.PNG`, observed left slider endpoint. Target: `IMG_1950.PNG`, observed right endpoint. Numeric endpoint strengths and a common neutral state are unknown.

The observed span moves the temporal canthal regions outward: image-left displacement is negative x, and image-right displacement is positive x. Adjacent temporal sclera follows, with a much smaller vertical component. Iris interiors and the nasal canthi are quiet. This distinguishes the control from whole-eye translation and from the nasal localization of the inner-canthus control.

Dense horizontal displacement P1/P99 reaches approximately **−11.40 px / +12.02 px** at the image-left/right eyes. The **11 primary mobile NCC matches** differ from DIS by P95 **1.50 px**. A smaller-template check gives a similar mobile P95, while dense methods remain sensitive to local support width and the small vertical component.

![Aligned endpoint comparison, signed horizontal/vertical displacement, and marked profiles](证据/位移证据.png)

The figure preserves displacement direction. Curves use seven-pixel median bands, and black markers are nearby source-only matches. Central vertical profiles examine the quiet iris region rather than the active temporal corners.

- [Analysis chain](分析链路.md)
- [Candidate implementation](实现方案.md)
- [Local measurement record](本地测量说明.md)

No SDK or host implementation was changed, and this report does not certify a reproduced reference effect.
