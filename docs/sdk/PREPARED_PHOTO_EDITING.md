# 固定图片的连续编辑

这是把连续处理中的固定资源复用用于已有图片 SDK：同一张原图拖动滑块时，
有效检测无需逐次重跑；几何与像素效果仍根据每次参数从原图重新计算。
视频每帧的像素不同，不能用此入口复用上一帧支撑。普通静图、编码图片和
indexed camera/video 入口的检测与 cadence 契约保持原样。

## 接入

在同一个串行 owner/actor 内：

```swift
let engine = try BeautyEngine()
let source = try engine.prepareStillImage(image: originalCGImage)
let first = try engine.processResult(preparedImage: source,
    parameters: BeautyParameters(noseWingSlim: 0.1))
let second = try engine.processResult(preparedImage: source,
    parameters: BeautyParameters(noseWingSlim: 0.2))
engine.releasePreparedStillImage()
// source 现在已过期；再次使用会抛出 BeautyError.invalidInput。
```

只支持 `.photo` RGB 色彩空间、8 bits/component、24或32 bits/pixel。
保留输入的 bitmap、色彩、alpha 和显式方向/镜像；prepare 深拷贝原始栅格字节，
不保留调用者可变 provider 或任意 CIImage/CVPixelBuffer graph。尺寸和行字节
检查先于复制；总 snapshot 字节不超过 `maximumInputPixelCount × 4`。
超界返回 `invalidInput`，不支持的格式返回 `unsupportedPixelFormat`。
每个 engine 只保留一个 source；成功 prepare 替换它，失败 prepare 保留旧 source。
旧 token、另一 engine 的 token、release/reset 后的 token 都会在检测前被拒绝。
token/state 的 description/Mirror 只含类型、尺寸或数量，没有原图/点数组。

## 复用与恢复

检测仍按现有用途选择人脸：geometry、localSupport、combined各自独立；
原始 detector raster 与 local/mask 路由的 canonical raster 也各自独立，最多六项。
只缓存 usable/noFace；partial/lowConfidence/skipped 重新检测，不拿旧结果替代。
neutral、禁用检测或不需要支撑的颜色调整不触发检测。换原图/尺寸/方向/镜像
必须重新 prepare，不存在用户自造 cache key 或跨 engine 共享 raw support。

固定 source 的有效支撑仍属于当前原始像素；这不是视频旧帧 `.reused/.stale`。
每个调用的 source admission、source refiners、网格安全、局部修饰 owner 和保护
蒙版保持现有判断，计算完即释放，不缓存参数结果、mask 或 retouch unit。
`beauty.detection.preparedReuse` 在需要检测的 prepared 调用中为首次0/命中1；
summary 保留原始 outcome，原 detection timing 若存在也只是原检测耗时。
这不是每次都发生新检测的证明，也不能据此宣称fps或设备延迟。

## 编辑 Demo

独立 BeautyEditorApp 的 PhotoRenderer 在 actor 内通常按照片、CPU/Metal engine
分别保留 thumbnail-bound preview token。同一 preview 连续参数使用固定 source。
当前iris整改增加显式例外：非零pupilSize预览使用独立CPU engine及原图绑定token，
调用[source-first iris preview API](EYE_SHAPE_SLIDERS.md#原图先行的-iris-preview-api)。
其原图检测缓存与原CPU/Metal缩略图缓存隔离，不以960px支撑替代原图；每次参数
重算原图iris及请求内owner，结果与owner/mask不进入prepared缓存。C60/C61默认
mask=nil基准另在原源缩图后运行view color/texture/refiners；原尺寸IR prefix独立，
BO缩图仅支持精确未变化copy guard，几何hard owner仍授权clip，不缓存输出或
RGB语义mask。原图grid显式mask保持原prefix基准，不借到view。零iris仍走原
thumbnail入口。换图释放各engine的source/support及三类token，release/reset也
使对应handle失效；同engine只能保留当前一个source。C61定向fractional3与facade6
及C74实际原图/explicit CPU preview的单图冻结门已通过；这些只证明该输入和API
范围，细灰rim限制仍保留。旧十项保留/宿主UI6正在准备，iPad未新build/install，
未重新交付，也不声明一般外观或性能。
导出仍重解码原尺寸并通过普通入口fresh检测；不能把960px preview支撑直接用于原图。
既有单worker/最新请求、过期结果拦截、CPU fallback、调试独立复检与背景合成不变。
没有新视频导入、摄像头、时序滤波、语义蒙版、效果解锁或真实设备性能声明。

当前验证记录由 [PLANS](../../PLANS.md) 导航。

## 眼瞳原图优先预览

`processIrisPreviewResult(preparedImage:maximumPreviewEdge:parameters:textureExclusionMask:)`
提供显式CPU路线，眼瞳先在原图采样，再缩略并执行现有兄弟几何。上限1...960，
mask仍绑定原图网格。调用、已知缩小灰边与暂停状态见[眼瞳大小](IRIS_SIZE.md)。
