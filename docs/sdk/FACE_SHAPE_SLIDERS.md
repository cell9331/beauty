# 脸型滑杆与连续轮廓（2026-10-11）

实现参考所有者的单参数美图截图及导入手册的脸型、位移场和保护区描述。
当前 authority 是代码、测试与 [taxonomy](../SDK_EFFECT_TAXONOMY.md)。截图没有
数值；下面对齐中性位置、左右方向和连续强度，不承诺未知幅度或逐像素复刻。

## 宿主映射

`BeautyFaceShapeSlider` 接受 `0...1` 位置并返回参数快照；其他字段保留 normalized
值。超范围位置截断，非有限位置回到中性。端点对应既有安全 cap，避免中途触顶。

| 控件 / enum case | 字段 | 左 → 右 | 参数端点 |
| --- | --- | --- | --- |
| 脸宽 / `faceWidth` | `faceSlim` | 宽 → 窄 | −0.60 → +0.60 |
| 小脸 / `smallFace` | `faceSmall` | 大 → 小 | −0.45 → +0.45 |
| 太阳穴 / `temple` | `templeFullness` | 收 → 丰满 | −0.25 → +0.25 |
| 颧骨 / `cheekbone` | `cheekboneSlim` | 宽 → 收 | −0.25 → +0.25 |
| 下巴长短 / `chinLength` | `chinLength` | 长 → 短 | +0.35 → −0.35 |
| 尖下巴 / `chinTaper` | `chinTaper` | 圆宽 → 尖窄 | −0.25 → +0.25 |
| 下颌角 / `jawAngle` | `jawSlim` | 宽 → 收 | −0.45 → +0.45 |
| V 脸 / `vFace` | `faceVShape` | 中性 → 下脸收窄 | 0 → +0.50 |
| 面部流畅 / `contourSmooth` | `faceContourSmooth` | 中性 → 源边缘修整 | 0 → +0.25 |
| 发际线 / `hairline` | `hairlineHeight` | 上移 → 下移 | −0.25 → +0.25 |

双向控件中性为 `0.5`，V 脸与面部流畅为 `0`。宿主接线：

```swift
parameters = BeautyFaceShapeSlider.chinLength.applying(
    position: sliderPosition, to: parameters
)
```

六项新增 signed 字段保留 Codable key、零默认值与 cap。直接 `chinLength` 正值
仍表示拉长，只有 helper 反向映射。本轮没有更新或安装独立宿主 App。
CLI 显式 `--case faceSlider_<case>_<index>`；index `0...4` 对应位置
`0, .25, .5, .75, 1`。例如 `faceSlider_smallFace_4`。50 个新增 opt-in 个案
不进入既有 98 个默认清单。

## 八项连续场

脸宽、小脸、太阳穴、颧骨、下巴长短、尖下巴、下颌角与 V 脸共用
`BeautyContinuousFaceMap`。实测下轮廓、有效眼部和已注册外唇共同准入；粗代理
旧正向路线保持兼容，新增负向缺少已注册外唇时退出。

双眼建立像素局部坐标。Hermite 轮廓的最近投影定义位移，外侧四次衰减形成连续
窄带，代替多个点拉伸相加；小脸在下脸做平滑缩放。太阳穴上方支撑属于二维
轮廓延伸，不代表实测发际线。眼睛、外唇包围域及边缘节点固定，ROI 外复制源
字节；alpha 不修改，跨不同 alpha 的插值退出。

每轴 65 个基础节点再加入特征保护边缘。当前与同符号 cap 形态共同限制梯度
Frobenius 范数 ≤ .45、位移 ≤ 轮廓像素宽的 6%；姿态进一步减弱。核和 cap
形态不随档位移动；四分档由独立像素重心验证。陈旧、无效或不足支撑退出，
已注册新路线不恢复旧点拉伸。映射不可编码，诊断只暴露尺寸和节点数。

CPU 与 Metal-selected 静图在已有 legacy/dense 采样之后、整体平移之前共享此
CPU-owned 采样，对应八项旧点不再执行。其他 dense 字段仍用原 map。两阶段
分别有界，不声称全部效果组合只有一次采样或共享单一 6% 总位移界。无新
shader、模型或 GPU API；像素缓冲路线不接入这一静图效果。

## 验证与剩余边界

测试使用生成源固定标记，断言反向/四档单调、眼嘴/外围/alpha 精确保护、平滑
下巴不新增波纹、neutral/无脸/无效退出、重复性及公共 CPU/实际 Metal 一致性。
宽高、非零 extent、sRGB、旋转/镜像输出元数据和 typed failure/recovery 另有公共
断言。合成 dense carrier 不等于本次执行了 iOS/MediaPipe 推理。

两张授权原图的 macOS/Vision 单字段输出已对照；小脸下巴起伏已消除，八项有
目标方向变化。发际线增加连续柔和发肤边界准入，但两图仍未准入；面部流畅
也仍返回中性像素。刘海、发丝遮挡、语义分割及美图外观完全一致仍未实现。
见 [记录](../../plans/history/2026-10/A-2026-10-11-face-continuous.md)。
