# Inner canthus — 内眼角

[Current implementation comparison](当前实现对照.md)

[Implementation migration plan](改造计划.md) · [Separate evidence gaps](../证据缺口.md)

[Eye analysis index](../README.md) · [Input inventory](../输入清单.md)

Status: **measured endpoint comparison; candidate geometry only**. Analysis date: 2026-10-16. Source: `IMG_1947.PNG`, observed left slider endpoint. Target: `IMG_1948.PNG`, observed right endpoint. No numeric endpoint value or common neutral state is established.

The observed span moves each nasal canthal region toward the nose: image-left displacement is positive x, and image-right displacement is negative x. Motion is concentrated around the inner corners and adjacent nasal sclera. Iris interiors and the opposite, temporal corners remain much quieter. This is a local corner operation, rather than translation of the whole eye.

Dense horizontal displacement P1/P99 reaches approximately **+16.61 px** at the image-left eye and **−15.30 px** at the image-right eye. Independent moving texture support is sparse: **8 primary mobile matches** have P95 **2.28 px** difference from DIS. A smaller-template check supports the two corner directions but does not establish an exact plateau or support edge.

![Aligned endpoint comparison, signed horizontal/vertical displacement, and marked profiles](证据/位移证据.png)

The central vertical profiles pass through protected iris regions, rather than the active corners. Horizontal profiles show a shoulder of the corner field; their peaks are not the full field's maximum. Curves are seven-pixel band medians; nearby texture markers are independent of the dense estimate.

- [Analysis chain](分析链路.md)
- [Candidate implementation](实现方案.md)
- [Local measurement record](本地测量说明.md)

No SDK implementation was changed, and no reference reproduction is claimed.
