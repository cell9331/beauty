# Eye height (眼高)

[Current implementation comparison](当前实现对照.md)

[Implementation migration plan](改造计划.md) · [Separate evidence gaps](../证据缺口.md)

Analysis date: 2026-10-16. **Status: measured endpoint geometry with a candidate field; no SDK implementation or reproduction claim.**

`IMG_1932.PNG` → `IMG_1933.PNG` is the observed left-to-right slider span. Both screenshots preserve the same native photo grid. No numeric values are visible and no common neutral is certified. All numbers below belong to this photograph and endpoint pair.

The superior eye region moves upward while the inferior region moves downward. Vertical displacement dominates, with smaller but visible horizontal components. The upper lobe is larger than the lower one in this comparison. This changes aperture height rather than simply moving the eye.

The independent primary check accepts 253/382 source-selected candidates; 43 have measured motion >2 px. Their NCC–DIS method-difference P95 is 2.86 px. This is method agreement, not ground-truth error.

- [Evidence chain and uncertainty](分析链路.md)
- [Candidate field, calibration and falsification](实现方案.md)
- [Local evidence and rerun boundary](本地测量说明.md)
- [Shared coordinates and mathematical rules](../实现公共约定.md)
- [All eye controls](../README.md)

![Aligned endpoint crops, signed forward dx/dy, and coordinate-marked profiles](证据/位移证据.png)

The figure is local and ignored by Git under the repository's image policy. Its heatmap colors encode displacement only.
