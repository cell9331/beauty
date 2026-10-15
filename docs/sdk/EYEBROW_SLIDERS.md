# 眉毛滑杆与源材料路径

`BeautyEyebrowSlider` 是所有者宿主可调用的值映射，七项位置均为 `0...1`，
`.5` 精确中性。它没有视图或编辑状态；现有参数键、零默认和绝对 cap `.25` 保留。

| 滑杆 | 参数 | 向右端点 |
| --- | --- | --- |
| `verticalPosition` | `eyebrowYPosition` | 向上；直接 API 的正 Y 仍向下 |
| `thickness` | `eyebrowThickness` | 加粗 |
| `length` | `eyebrowLength` | 外端延长 |
| `spacing` | `eyebrowSpacing` | 拉开双眉 |
| `headSpacing` | `eyebrowHeadSpacing` | 拉开眉头，保持外端独立 |
| `tilt` | `eyebrowTilt` | 外端向下；直接 API 的正值仍抬高外端 |
| `peak` | `eyebrowPeakDefinition` | 增强眉峰；负值压平 |

```swift
let snapshot = BeautyEyebrowSlider.peak.applying(position: position, to: parameters)
let restoredPosition = BeautyEyebrowSlider.peak.position(in: snapshot)
```

眉峰现在与其余六项一样接受正负值，初始化、解码、mutable normalization、
resolver、绝对组合预算及 backend admission 保持一致。所有者调用行为由
[PRODUCT_SENSE](../../PRODUCT_SENSE.md) 拥有，参数契约由 [DESIGN](../../DESIGN.md) 拥有。

观察到的眉毛支撑走请求内 CPU-owned 材料路径，两种 still-image backend 共用。
它从未被其他几何修改的源图确定局部支持域，在源/目标支持域的并集中逆采样原图RGB，
以支持权重与当前carrier混合，保留原alpha；它不再合成肤色底层或重建眉毛前景色。
源材料不明确、透明采样、保护区冲突或先前几何已改动材料所有权时按侧退出；
双眉间距须有两侧实际材料准入。失败不恢复旧的粗点代理。规划的连续 field 计数
说明参数/支撑准入，不证明图片有效。像素路径与组合顺序由
[ARCHITECTURE](../../ARCHITECTURE.md) 拥有。

本次参考目标仍在验证中。实际结果、冻结保护域与失败尝试见
[现行计划](../../plans/active/A-2026-10-14-eyebrow-reference-refactor.md)。
合成源测试、参数 round-trip 或安全 no-op 均不能替代原图效果与原始细节验收。
旧 Phase 89/92 冻结夹具和回执保持其日期、输入及失败结果，不能由新源正例置换。
