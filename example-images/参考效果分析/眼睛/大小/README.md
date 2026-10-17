# Eye size (大小)

[Current implementation comparison](当前实现对照.md)

[Implementation migration plan](改造计划.md) · [Separate evidence gaps](../证据缺口.md)

Analysis date: 2026-10-16. **Status: measured endpoint geometry with a candidate field; no SDK implementation or reproduction claim.**

`IMG_1928.PNG` → `IMG_1929.PNG` is the observed left-to-right slider span. Both screenshots preserve the same native photo grid. No numeric values are visible and no common neutral is certified. All numbers below belong to this photograph and endpoint pair.

Both eyes expand in two dimensions: the horizontal component points away from the eye center on both sides, while the superior and inferior vertical components oppose each other. The larger horizontal peak does not, by itself, prove anisotropic scaling: the source eye is much wider than it is tall.

The independent primary check accepts 263/376 source-selected candidates; 54 have measured motion >2 px. Their NCC–DIS method-difference P95 is 1.02 px. This is method agreement, not ground-truth error.

- [Evidence chain and uncertainty](分析链路.md)
- [Candidate field, calibration and falsification](实现方案.md)
- [Local evidence and rerun boundary](本地测量说明.md)
- [Shared coordinates and mathematical rules](../实现公共约定.md)
- [All eye controls](../README.md)

![Aligned endpoint crops, signed forward dx/dy, and coordinate-marked profiles](证据/位移证据.png)

The figure is local and ignored by Git under the repository's image policy. Its heatmap colors encode displacement only.
