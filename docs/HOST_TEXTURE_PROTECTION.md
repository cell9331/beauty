# 主机显式保护物体与唇缘

本页说明已有 `BeautyTextureExclusionMask` 的接入方式。主机知道哪些像素必须保留时，可以同时标记物体、唇缘或其他关键区域；在这些像素上关闭皮肤平滑/锐化，未标记的合格皮肤继续处理。SDK 不自动推断这些区域的材质或解剖语义。

## 准备输入

1. 使用不透明、受支持色彩空间的静图。主机的保护标记必须落在**转正并校正输入镜像后的最终像素栅格**，尺寸与该栅格相同。原照片、预览坐标和最终像素坐标不应混用。
2. 把所有必须源精确的已知区域取并集。仅标记物体不会保护未标记的唇缘；现有粗略五官守卫可能没有覆盖它们。
3. 每像素一字节，`255` 代表排除，`0` 代表保留既有准入规则。不是灰度权重、透明度或软羽化蒙版。数组行索引须与最终 canonical raster 一致，不直接照搬外部标注的屏幕坐标。
4. 把这份蒙版传入同一次 `processResult` 请求；图片或方向改变后重新对应保护标记。蒙版不进入结果/诊断，不是后续请求的引擎状态。

下面的调用假定 `uprightImage` 已转正、输入镜像已校正，主机已经按其最终 raster 提供已知保护像素索引。它可以用于项目所有者控制的本地工具，不增加 App/UI 或 SDK API：

```swift
import BeautySDK
import CoreImage

// Host-owned indices = known object pixels ∪ known complete lip/feature pixels.
// Obtain these independently of the SDK's coarse face/color admission guards.
func processKnownProtectedPixels(
    engine: BeautyEngine,
    uprightImage: CIImage,
    protectedPixelIndices: Set<Int>,
    smoothing: Float,
    sharpening: Float
) throws -> BeautyResult<CIImage> {
    let extent = uprightImage.extent
    let limit = min(engine.configuration.maximumInputPixelCount, 8_388_608)
    guard extent.origin == .zero,
          extent.width.isFinite, extent.height.isFinite,
          extent.width >= 1, extent.height >= 1,
          extent.width <= CGFloat(limit), extent.height <= CGFloat(limit),
          extent.width.rounded(.down) == extent.width,
          extent.height.rounded(.down) == extent.height
    else { throw BeautyError.invalidInput }
    let width = Int(extent.width)
    let height = Int(extent.height)
    let count = width.multipliedReportingOverflow(by: height)
    guard !count.overflow, count.partialValue <= limit,
          protectedPixelIndices.allSatisfy({ $0 >= 0 && $0 < count.partialValue })
    else { throw BeautyError.invalidInput }
    var bytes = [UInt8](repeating: 0, count: count.partialValue)
    for index in protectedPixelIndices { bytes[index] = 255 }
    let mask = try BeautyTextureExclusionMask(width: width, height: height, bytes: bytes)
    return try engine.processResult(
        image: uprightImage,
        metadata: BeautyInputMetadata(orientation: .up, source: .photo),
        parameters: BeautyParameters(skinSmoothing: smoothing, skinSharpen: sharpening),
        textureExclusionMask: mask
    )
}
```

上面调用在分配前检查零原点、有限正整数尺寸以及 `BeautyConfiguration.maximumInputPixelCount` 和纹理的 8,388,608 像素上限；保护索引也必须入界。它限定已转正、镜像已校正的 decoded 栅格，不替主机完成外部标记到最终栅格的坐标映射。默认 SDK 内存/资源限制见 [DESIGN](../DESIGN.md) 和 [RELIABILITY](../RELIABILITY.md)。所有者如传原始方向图，仍可调用同一 API，但蒙版始终按最终栅格构造。

已在内存中的编码 PNG 使用同一参数：

```swift
let result = try engine.processResult(
    encodedImageData: pngData,
    metadata: inputMetadata,
    parameters: BeautyParameters(skinSmoothing: 1),
    textureExclusionMask: maskForFinalUprightGrid
)
```

## 有效范围与错误处理

- 排除像素对**纹理阶段**源精确。上面的调用只请求纹理；若另行组合颜色、几何或其他效果，它们的契约独立，不能据此保证最终组合输出仍源精确。
- 未排除区域并非强制处理区：仍受新鲜主脸、颜色、边缘和像素预算守卫约束；没有合格人脸时纹理保持源图。
- 非二值、错误字节数量或网格尺寸失败为 `BeautyError.invalidInput`。修正后同一串行引擎可继续下一请求；不要把错误解释为已识别到物体。
- 将 `255` 覆盖全部图像会停掉全部纹理效果，适合作为拒绝处理的负例，不是正例完成证据。
- 同一个 `BeautyEngine` 的处理和 reset 访问须串行。主机不保存私有标记到仓库、日志或证据，不打印像素数组。

## 验证记录（2026-10-03）

[公开路径回归](../BeautySDK/Tests/BeautyCoreTests/BeautySkinTextureHostProtectionTests.swift)复用原冻结挑战的同一生成源、两种肤色和效果/保护谓词。新增的是主机提供的物体 + 完整唇区并集信息。方向门槛分别在只开 `skinSmoothing: 1` 或只开 `skinSharpen: 1` 的请求上验证；混合强度不获这组独立方向门槛声明。生产算法与公开接口不变，原失败挑战不动。

- 新增 4 tests / 0 failures / 0 skips；连同原物体蒙版回归，共 8/0/0。
- 深肤色无蒙版仍改动原唇缘，正确并集蒙版使完整唇缘与物体源精确；对侧平滑邻接亮度变化降低至少 20%、锐化增加至少 10%。全排除、平坦皮肤和无脸负例不会拿停掉正例冒充通过。
- 每个标记像素匹配源，未标记像素匹配相同请求无蒙版基线。RGB 改变量不超过 16，neutral、重复、眼/唇/背景/alpha、extent 与 sRGB 均检查。
- 八种方向 × 两种输入镜像、双肤色和两种纹理控制共 64 个方向/镜像效果组合，以局部并集蒙版检查完整输出一致性；预览镜像不改变存储结果。
- decoded 与内存 PNG 输出一致；错误网格后恢复、后续无蒙版/零蒙版不继承旧标记。CPU 与 GPU-selected 回归显式使用既有真实后端工厂，只注入源图对应的检测观测；纹理阶段仍为 CPU-owned，不构成新 GPU backend 或性能声明。原便捷注入器仅替换检测时默认使用 CPU 执行器，本轮已显式接入实际工厂以避免误报 GPU 覆盖。
- 本次 archive-first 完整 SDK 门禁返回 0：1076 tests / 0 failures / 0 skips，9 个 opt-in 测试身份全部执行。新回归实际执行 CPU = 1、Metal = 1、Metal unavailable = 0。

[旧冻结自动挑战](TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md)仍为 4 tests / 6 failures / 0 skips，未改成通过。正确并集蒙版的成功，只证明主机额外提供这些像素信息时的保护路径；**不修复无蒙版粗略唇区覆盖，也不恢复通用自动识别、去脂或模型研发**。
