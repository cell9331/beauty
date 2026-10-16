# Beauty SDK Algorithm Effects Implementation

## 1. 文档目标

本文档定义 BeautySDK 中核心美颜效果的实现方案。

覆盖第一版 MVP 必须实现的效果：

```text
1. 大眼 / 小眼
2. 眼距调整
3. 眼睛上下位置
4. 眼尾上扬
5. 瘦脸
6. 小脸
7. V 脸
8. 下巴调整
9. 瘦鼻
10. 鼻翼收窄
11. 鼻头缩小
12. 嘴巴大小
13. 嘴巴宽度
14. 嘴角微笑
15. 磨皮
16. 美白
17. 红润
18. 清晰 / 锐化
19. 唇色增强
20. LUT 滤镜
```

本文档用于指导：

```text
BeautyEffects 模块开发
Metal shader 开发
WarpControlPointProvider 开发
参数调试
效果验收
性能优化
```

---

# 2. 总体实现原则

## 2.1 几何形变统一进入 FaceWarpPass

以下功能全部属于几何形变：

```text
大眼
眼距
眼睛上下
眼尾上扬
瘦脸
小脸
V 脸
下巴
瘦鼻
鼻翼
鼻头
嘴巴大小
嘴巴宽度
嘴角微笑
```

这些功能不应该各自写独立 Metal Pass。

统一流程：

```text
BeautyParameters
        ↓
WarpControlPointProvider
        ↓
[WarpControlPoint]
        ↓
FaceWarpPass
        ↓
Warp.metal
        ↓
warpedTexture
```

## 2.2 颜色类效果合并处理

以下功能属于颜色和图像增强：

```text
美白
红润
清晰 / 锐化
唇色增强
LUT 滤镜
```

应尽量合并：

```text
SkinPass：磨皮、美白、红润
ColorPass：基础颜色、清晰 / 锐化
LUTPass：滤镜
MakeupPass：唇色、口红、腮红，后续版本
```

## 2.3 参数必须有安全强度映射

UI 传入值虽然是：

```text
0...1
-1...1
```

但算法内部不能直接线性使用完整范围。

应该做：

```text
normalized parameter
        ↓
clamp
        ↓
safety scale
        ↓
nonlinear curve
        ↓
actual displacement / color intensity
```

示例：

```swift
let safeStrength = pow(abs(parameter), 0.85) * maxStrength
```

---

# 3. 公共数据结构

## 3.1 WarpControlPoint

```swift
public struct WarpControlPoint: Sendable {
    public let source: SIMD2<Float>
    public let target: SIMD2<Float>
    public let radius: Float
    public let strength: Float
    public let falloff: Float
}
```

字段说明：

```text
source：控制点原始位置，Texture Normalized 坐标
target：控制点目标位置，Texture Normalized 坐标
radius：影响半径，Texture Normalized 单位
strength：实际强度，通常 0...1
falloff：衰减参数，控制边缘过渡
```

## 3.2 WarpControlPointProvider

```swift
public protocol WarpControlPointProvider {
    func makeControlPoints(
        face: BeautyFaceObservation,
        parameters: BeautyParameters,
        imageSize: CGSize
    ) -> [WarpControlPoint]
}
```

## 3.3 LandmarkGeometryHelper

所有 Provider 都应该依赖统一的几何工具，不要自己散写。

建议工具：

```swift
public enum LandmarkGeometryHelper {
    public static func center(of points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func boundingRect(of points: [SIMD2<Float>]) -> CGRect?
    public static func distance(_ a: SIMD2<Float>, _ b: SIMD2<Float>) -> Float
    public static func leftMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func rightMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func topMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
    public static func bottomMostPoint(in points: [SIMD2<Float>]) -> SIMD2<Float>?
}
```

---

# 4. FaceWarpPass 总体设计

## 4.1 输入

```text
inputTexture
BeautyParameters
[BeautyFaceObservation]
[WarpControlPointProvider]
```

## 4.2 输出

```text
outputTexture
```

## 4.3 处理流程

```text
1. 遍历 faces。
2. 遍历 providers。
3. 每个 provider 根据当前 face 和 parameters 生成控制点。
4. 合并所有控制点。
5. 上传到 GPU buffer。
6. Warp.metal 对每个像素做反向采样。
7. 输出 warpedTexture。
```

## 4.4 Metal 采样逻辑

每个输出像素：

```text
p = 当前输出坐标
samplePosition = p

for controlPoint in controlPoints:
    d = distance(p, controlPoint.source)
    if d < radius:
        weight = falloff(d / radius)
        offset = (controlPoint.target - controlPoint.source) * weight * strength
        samplePosition -= offset

output[p] = input[samplePosition]
```

使用反向采样：

```text
从 output 像素反推 input 采样位置
避免出现空洞
```

## 4.5 falloff 曲线

推荐第一版：

```text
x = d / radius
weight = (1 - x)^2
```

更柔和：

```text
weight = smoothstep(1, 0, x)
```

Metal 示例：

```metal
float falloffWeight(float x, float falloff) {
    x = clamp(x, 0.0, 1.0);
    float w = 1.0 - smoothstep(0.0, 1.0, x);
    return pow(w, max(falloff, 0.001));
}
```

---

# 5. EyeWarpProvider：眼睛类效果

## 5.1 支持参数

```text
eyeSize
eyeDistance
eyeYPosition
eyeTailLift
```

依赖关键点：

```text
leftEye
rightEye
leftPupil，可选
rightPupil，可选
```

---

## 5.2 eyeSize：大眼 / 小眼

### 功能说明

调整眼睛整体大小。

```text
正数：眼睛变大
负数：眼睛变小
```

### 输入参数

```text
eyeSize: -1...1
```

### 依赖点位

```text
leftEye
rightEye
```

### 控制点生成

对每只眼睛：

```text
eyeCenter = center(eyePoints)
eyeRect = boundingRect(eyePoints)
eyeWidth = eyeRect.width
eyeHeight = eyeRect.height
radius = max(eyeWidth, eyeHeight) * radiusScale
```

推荐：

```text
radiusScale = 1.8 ~ 2.4
maxStrength = 0.45
```

对于大眼：

```text
source = eyeCenter
target = eyeCenter
```

但单个 source/target 点不足以表达放大，需要 shader 支持 radial scale 类型，或者用多个控制点。

第一版更简单方案：

```text
在 shader 中为 eyeSize 提供 radialScale control type。
```

如果坚持统一 WarpControlPoint，可以生成眼周多个控制点：

```text
眼上点向上移动
眼下点向下移动
眼头向外移动
眼尾向外移动
```

### 推荐第一版实现

为了统一 Provider，建议生成 4 个控制点：

```text
top point    -> 向上移动
bottom point -> 向下移动
inner point  -> 向眼头外侧移动
outer point  -> 向眼尾外侧移动
```

对于每只眼睛：

```text
top = topMostPoint(eyePoints)
bottom = bottomMostPoint(eyePoints)
left = leftMostPoint(eyePoints)
right = rightMostPoint(eyePoints)
center = center(eyePoints)
```

移动方向：

```text
direction = normalize(point - center)
target = point + direction * displacement
```

位移：

```text
displacement = eyeSize * maxStrength * eyeWidth
```

### 安全限制

```text
实际强度上限：0.45
影响半径不能超过眼睛宽度的 2.5 倍
不能明显影响眉毛和鼻梁
没有眼睛点时跳过
左右眼点数异常时跳过
```

### 验收标准

```text
眼睛变大明显但自然
眼球和眼皮边缘不破裂
眉毛不明显变形
鼻梁不被拉歪
左右眼效果一致
```

---

## 5.3 eyeDistance：眼距调整

### 功能说明

调整两眼之间距离。

```text
负数：眼距变近
正数：眼距变远
```

### 依赖点位

```text
leftEye center
rightEye center
face center
```

### 控制点生成

```text
leftEyeCenter
rightEyeCenter
faceCenterX
```

方向：

```text
left eye:
    eyeDistance > 0：向左移动
    eyeDistance < 0：向右移动

right eye:
    eyeDistance > 0：向右移动
    eyeDistance < 0：向左移动
```

位移：

```text
displacement = abs(eyeDistance) * maxStrength * distanceBetweenEyes
maxStrength = 0.12 ~ 0.18
```

控制点：

```text
source = eyeCenter
target = eyeCenter + horizontalOffset
radius = eyeWidth * 2.0
```

### 安全限制

```text
实际强度上限：0.3
影响区域不能覆盖整个鼻子
建议只影响眼眶周围
```

### 验收标准

```text
两眼距离变化自然
鼻梁不明显扭曲
眼睛形状不明显变形
```

---

## 5.4 eyeYPosition：眼睛上下位置

### 功能说明

整体调整眼睛垂直位置。

```text
正数：眼睛上移
负数：眼睛下移
```

### 控制点生成

每只眼睛生成一个中心控制点：

```text
source = eyeCenter
target = eyeCenter + SIMD2(0, -verticalOffset)
```

注意：

如果 Texture Normalized 坐标 y 向下增加，则：

```text
上移：target.y -= offset
下移：target.y += offset
```

位移：

```text
offset = eyeYPosition * maxStrength * faceHeight
maxStrength = 0.03 ~ 0.06
```

### 安全限制

```text
实际强度上限：0.25
眼睛上下位置属于强比例调整，第一版要保守
避免眉眼距离异常
```

---

## 5.5 eyeTailLift：眼尾上扬

### 功能说明

调整眼尾角度。

```text
正数：眼尾上扬
负数：眼尾下压
```

### 依赖点位

```text
leftEye
rightEye
```

### 眼尾判断

在非镜像统一坐标下：

```text
左眼外眼角：更靠左的点
右眼外眼角：更靠右的点
```

但如果输入是镜像后坐标，CoordinateMapper 已经统一到 texture 坐标，所以 Provider 只根据当前 texture 左右判断即可。

### 控制点生成

```text
leftEyeOuter = leftMostPoint(leftEye)
rightEyeOuter = rightMostPoint(rightEye)
```

移动：

```text
上扬：outer.y -= offset
下压：outer.y += offset
```

位移：

```text
offset = eyeTailLift * maxStrength * eyeHeight
maxStrength = 0.4 ~ 0.7
```

radius：

```text
eyeWidth * 1.2
```

### 验收标准

```text
眼尾角度变化可见
眼头不明显移动
眼睛不整体漂移
```

---

# 6. FaceShapeWarpProvider：脸型类效果

## 6.1 支持参数

```text
faceSlim
faceSmall
faceVShape
jawSlim
```

依赖关键点：

```text
faceContour
boundingBox
```

---

## 6.2 faceSlim：瘦脸

### 功能说明

收窄脸颊区域。

### 依赖点位

```text
faceContour
faceCenter
```

### 控制点选择

需要估计：

```text
leftCheek
rightCheek
```

如果 faceContour 点位按轮廓从一侧到另一侧排列，可以取中下部两侧点。

更稳健的第一版方式：

```text
faceRect = boundingRect(faceContour)
leftCheek = SIMD2(faceRect.minX, faceRect.midY + faceRect.height * 0.12)
rightCheek = SIMD2(faceRect.maxX, faceRect.midY + faceRect.height * 0.12)
faceCenter = center(faceContour)
```

### 控制点生成

```text
leftCheek target  = leftCheek  + SIMD2(+offset, 0)
rightCheek target = rightCheek + SIMD2(-offset, 0)
```

位移：

```text
offset = faceSlim * maxStrength * faceWidth
maxStrength = 0.08 ~ 0.12
```

radius：

```text
faceWidth * 0.35 ~ 0.45
```

### 安全限制

```text
实际强度上限：0.6
人脸太侧时降低强度
faceContour 不完整时跳过
脸太小则跳过或降低强度
```

### 验收标准

```text
脸颊变窄自然
背景拉伸不明显
嘴巴鼻子不明显变形
左右脸基本对称
```

---

## 6.3 faceSmall：小脸

### 功能说明

整体缩小脸部视觉面积。

### 实现思路

将脸部轮廓点整体向脸中心移动。

### 控制点生成

选择多个轮廓点：

```text
leftUpperFace
leftCheek
leftJaw
rightUpperFace
rightCheek
rightJaw
chin
```

每个点：

```text
direction = normalize(faceCenter - point)
target = point + direction * displacement
```

位移：

```text
displacement = faceSmall * maxStrength * faceWidth
maxStrength = 0.04 ~ 0.08
```

radius：

```text
faceWidth * 0.25 ~ 0.4
```

### 安全限制

```text
实际强度上限：0.45
不要让五官整体向中心塌陷
不建议第一版移动额头过多
```

---

## 6.4 faceVShape：V 脸

### 功能说明

收紧下脸部，让脸型更接近 V 型。

### 依赖点位

```text
faceContour
chin point
jaw points
```

### 控制点生成

```text
leftJaw  -> 向内上方移动
rightJaw -> 向内上方移动
chin     -> 轻微向下或保持，视产品效果决定
```

位移：

```text
jawOffsetX = faceVShape * maxStrength * faceWidth
jawOffsetY = faceVShape * maxStrength * faceHeight * 0.2
```

推荐：

```text
maxStrength = 0.06 ~ 0.1
```

### 安全限制

```text
实际强度上限：0.5
防止锥子脸
防止下巴过尖
```

---

## 6.5 jawSlim：下颌收紧

### 功能说明

优化下颌线和腮帮。

### 控制点生成

选择下颌左右两侧：

```text
leftJawArea
rightJawArea
```

目标：

```text
向内移动
轻微向上移动
```

### 验收标准

```text
下颌线更收紧
不影响嘴角
脖子区域不明显扭曲
```

---

# 7. ChinWarpProvider：下巴调整

## 7.1 chinLength：下巴长度

### 功能说明

```text
正数：拉长下巴
负数：缩短下巴
```

### 依赖点位

```text
faceContour bottom point
outerLips
faceCenter
```

### 控制点生成

```text
chinPoint = bottomMostPoint(faceContour)
```

移动：

```text
正数：chinPoint.y += offset
负数：chinPoint.y -= offset
```

如果 Texture 坐标 y 向下增加：

```text
拉长下巴 = y 增加
缩短下巴 = y 减少
```

位移：

```text
offset = chinLength * maxStrength * faceHeight
maxStrength = 0.06 ~ 0.1
```

radius：

```text
faceWidth * 0.25
```

### 安全限制

```text
实际强度上限：0.35
不要影响嘴巴区域过多
不要导致下巴尖锐畸形
```

---

# 8. NoseWarpProvider：鼻子类效果

## 8.1 支持参数

```text
noseSlim
noseWingSlim
noseTipSize
noseBridge
```

依赖关键点：

```text
nose
noseCrest
```

---

## 8.2 noseSlim：瘦鼻

### 功能说明

整体收窄鼻子区域。

### 依赖点位

```text
nose
noseCrest
```

### 鼻梁中心线估计

```text
noseCenter = center(nose + noseCrest)
noseRect = boundingRect(nose)
```

### 控制点生成

估计鼻子左右边界：

```text
leftNose = leftMostPoint(nose)
rightNose = rightMostPoint(nose)
```

向中心移动：

```text
leftNose target = leftNose + SIMD2(+offset, 0)
rightNose target = rightNose + SIMD2(-offset, 0)
```

位移：

```text
offset = noseSlim * maxStrength * noseWidth
maxStrength = 0.12 ~ 0.2
```

radius：

```text
noseWidth * 1.2 ~ 1.8
```

### 安全限制

```text
实际强度上限：0.35
点位不足时跳过
侧脸时降低强度
```

---

## 8.3 noseWingSlim：鼻翼收窄

### 功能说明

收窄鼻翼。

### 控制点选择

选择 nose 区域下半部分左右边界。

如果 Vision 点位不够稳定：

```text
使用 nose boundingRect 下部估算鼻翼位置
```

```text
leftWing = SIMD2(noseRect.minX, noseRect.maxY - noseRect.height * 0.25)
rightWing = SIMD2(noseRect.maxX, noseRect.maxY - noseRect.height * 0.25)
```

移动：

```text
leftWing -> 向右
rightWing -> 向左
```

### 安全限制

```text
实际强度上限：0.35
半径要小于 noseSlim
不要影响嘴唇上方过多
```

---

## 8.4 noseTipSize：鼻头大小

### 功能说明

```text
负数：鼻头缩小
正数：鼻头放大，产品上通常不暴露
```

### 控制点生成

估计鼻头中心：

```text
noseTip = bottomMostPoint(nose)
```

缩小鼻头可以用多个点向鼻头中心移动：

```text
leftTipBoundary -> noseTipCenter
rightTipBoundary -> noseTipCenter
topTipBoundary -> noseTipCenter
bottomTipBoundary -> noseTipCenter
```

第一版简化：

```text
鼻头左右边界向中心移动
```

### 安全限制

```text
实际强度上限：0.3
避免鼻头塌陷
```

---

## 8.5 noseBridge：鼻梁增强

### 功能说明

增强鼻梁立体感。

### 实现策略

第一版可以分两部分：

```text
1. 轻微几何收窄鼻梁
2. 轻微光影增强
```

几何部分：

```text
noseCrest 周围左右区域向中心线移动
```

光影部分后续放到 Makeup / Light effect：

```text
鼻梁高光
鼻侧阴影
```

### 注意

```text
鼻梁变高不是纯几何问题。
不要只靠拉伸实现。
```

---

# 9. MouthWarpProvider：嘴巴类效果

## 9.1 支持参数

```text
mouthSize
mouthWidth
smile
```

依赖关键点：

```text
outerLips
innerLips
```

---

## 9.2 mouthSize：嘴巴大小

### 功能说明

```text
正数：嘴巴变大
负数：嘴巴变小
```

### 依赖点位

```text
outerLips
mouthCenter
```

### 控制点生成

取嘴巴上下左右边界：

```text
topLip
bottomLip
leftCorner
rightCorner
mouthCenter
```

移动：

```text
direction = normalize(point - mouthCenter)
target = point + direction * displacement
```

位移：

```text
displacement = mouthSize * maxStrength * mouthWidth
maxStrength = 0.15 ~ 0.25
```

radius：

```text
mouthWidth * 0.8 ~ 1.2
```

### 安全限制

```text
实际强度上限：0.35
不要严重拉伸牙齿区域
嘴巴点位不足时跳过
```

---

## 9.3 mouthWidth：嘴巴宽度

### 功能说明

```text
正数：嘴巴变宽
负数：嘴巴变窄
```

### 控制点生成

```text
leftCorner = leftMostPoint(outerLips)
rightCorner = rightMostPoint(outerLips)
```

移动：

```text
正数：leftCorner 左移，rightCorner 右移
负数：leftCorner 右移，rightCorner 左移
```

位移：

```text
offset = mouthWidth * maxStrength * mouthWidthValue
maxStrength = 0.2 ~ 0.3
```

---

## 9.4 smile：嘴角微笑

### 功能说明

让嘴角轻微上扬。

### 依赖点位

```text
leftCorner
rightCorner
outerLips
```

### 控制点生成

```text
leftCorner target.y -= offset
rightCorner target.y -= offset
```

如果 y 向下增加，则上扬就是 y 减少。

位移：

```text
offset = smile * maxStrength * mouthHeight
maxStrength = 0.6 ~ 1.0
```

radius：

```text
mouthWidth * 0.35 ~ 0.5
```

### 安全限制

```text
实际强度上限：0.5
不要把嘴巴拉成假笑
不要明显影响鼻子和下巴
```

### 验收标准

```text
表情更柔和
嘴角上扬自然
牙齿区域不明显扭曲
左右嘴角对称
```

---

# 10. SkinSmoothEffect：磨皮

## 10.1 功能说明

磨皮用于降低皮肤噪声、毛孔和轻微纹理，但不能把五官和边缘磨糊。

参数：

```text
skinSmoothing: 0...1
```

## 10.2 第一版实现策略

第一版可以采用：

```text
低频平滑 + 高频细节回加
```

流程：

```text
inputTexture
    ↓
Blur / Smooth Texture
    ↓
detail = input - smooth
    ↓
output = mix(input, smooth + detail * detailPreserve, intensity)
```

## 10.3 更现实的 MVP 简化

为了快速落地，第一版可以：

```text
1. 用小半径 bilateral-like blur 或 edge-aware blur。
2. 根据 skinSmoothing 混合原图和平滑图。
3. 轻微保留高频细节。
```

如果没有 skin mask：

```text
强度必须低。
保护边缘。
不要全图强模糊。
```

## 10.4 推荐 Pass

```text
SkinBlurHorizontal
SkinBlurVertical
SkinBlend
```

或者：

```text
SkinPass 内部多阶段 encode
```

## 10.5 安全限制

```text
实际强度上限：0.6
边缘强度降低
高频细节保留默认 0.35 ~ 0.5
```

## 10.6 验收标准

```text
皮肤变平滑
眼睛、眉毛、嘴巴边缘不糊
头发边缘不糊
不会出现明显塑料脸
强度为 0 等于原图
```

---

# 11. SkinWhitenEffect：美白

## 11.1 功能说明

提升肤色亮度和干净感。

参数：

```text
skinWhitening: 0...1
```

## 11.2 第一版实现策略

没有 skin mask 时，采用保守全图肤色优化：

```text
1. 轻微提高中间调亮度。
2. 降低黄色 / 暗沉。
3. 保护高光，避免过曝。
4. 保持黑色区域不被抬太多。
```

## 11.3 简化公式思路

```text
luma = dot(color.rgb, vec3(0.299, 0.587, 0.114))
whitenWeight = smoothstep(0.2, 0.85, luma) * (1 - smoothstep(0.85, 1.0, luma))
color.rgb += whitenAmount * whitenWeight
```

可以轻微降低黄色：

```text
color.b += smallAmount
color.r += smallAmount * 0.5
```

## 11.4 安全限制

```text
实际强度上限：0.5
高光区域减少作用
暗部区域减少作用
后续必须接入 skin mask
```

## 11.5 验收标准

```text
肤色更亮更干净
背景不过度变亮
高光不过曝
不会假白
```

---

# 12. SkinRosyEffect：红润

## 12.1 功能说明

增加面部气色。

参数：

```text
skinRosy: 0...1
```

## 12.2 第一版实现策略

没有 skin mask 时，只做轻微色彩增强：

```text
提升红色通道
轻微降低绿色 / 蓝色平衡
根据亮度限制作用范围
```

## 12.3 推荐策略

```text
rosyColor = vec3(1.0, 0.82, 0.82)
output = mix(color, color * rosyColor, rosyWeight * intensity)
```

或者：

```text
color.r += 0.03 * intensity * skinLikeWeight
```

## 12.4 安全限制

```text
实际强度上限：0.4
不能让整张图发红
唇色和衣服红色不要被过度增强
```

---

# 13. SkinSharpenEffect / ColorSharpen：清晰锐化

## 13.1 功能说明

增强五官和图像清晰度。

参数：

```text
skinSharpen: 0...1
```

## 13.2 实现策略

使用简单 unsharp mask：

```text
blurred = blur(input)
detail = input - blurred
output = input + detail * sharpenAmount
```

MVP 可以在 ColorPass 中做轻量锐化。

## 13.3 安全限制

```text
实际强度上限：0.4
磨皮后锐化
不要增强噪点
暗光场景降低锐化
```

---

# 14. LipColorEffect：唇色增强

## 14.1 功能说明

增强自然唇色，不做完整口红。

参数：

```text
lipColor: 0...1
```

## 14.2 依赖点位

```text
outerLips
innerLips
```

## 14.3 第一版实现策略

通过嘴唇关键点生成粗略 lip mask。

MVP 可简化：

```text
根据 outerLips boundingRect 生成椭圆区域
排除 innerLips 区域，可选
```

颜色增强：

```text
提升红色 / 饱和度
保留原有明暗纹理
```

混合方式：

```text
output = mix(input, enhancedLipColor, mask * lipColor)
```

## 14.4 安全限制

```text
实际强度上限：0.5
不要像纯色贴片
不要涂到牙齿外
没有 lips 点时跳过
```

---

# 15. LUTFilterEffect：滤镜

## 15.1 功能说明

应用 LUT 风格滤镜。

参数：

```text
filterId: String?
filterIntensity: 0...1
```

## 15.2 实现流程

```text
filterId
    ↓
LUTLoader
    ↓
3D LUT Texture
    ↓
LUTPass
    ↓
filteredColor
    ↓
mix(original, filtered, filterIntensity)
```

## 15.3 规则

```text
filterId == nil：跳过
filterIntensity == 0：跳过
LUT 找不到：抛错或降级无滤镜
LUT 不能每帧解析
```

## 15.4 验收标准

```text
强度 0 等于原图
强度 1 是完整滤镜
滑杆变化平滑
多个滤镜切换不崩溃
资源缓存有效
```

---

# 16. 参数组合顺序

推荐渲染顺序：

```text
1. FaceWarpPass
2. SkinPass
3. LipColor / MakeupPass
4. ColorPass
5. LUTPass
6. OutputPass
```

原因：

```text
先做形变，再做皮肤和颜色，避免磨皮结果被形变拉伸。
唇色在形变后做，贴合当前嘴唇位置。
LUT 最后做，统一整体风格。
```

---

# 17. 参数冲突处理

## 17.1 大眼 + 眼距

问题：

```text
两个效果都影响眼周区域。
```

策略：

```text
先生成所有 eye control points。
合并时限制总位移。
eyeDistance 影响半径略大，eyeSize 影响半径略小。
```

## 17.2 瘦脸 + 小脸 + V 脸

问题：

```text
多个脸型参数叠加容易过度变形。
```

策略：

```text
脸型类总强度做归一化限制。
总位移不超过 faceWidth * 0.12。
```

## 17.3 瘦鼻 + 鼻翼 + 鼻头

问题：

```text
鼻子区域点位少，叠加后容易塌。
```

策略：

```text
nose 总强度限制。
优先 noseWingSlim，其次 noseSlim，最后 noseTipSize。
```

## 17.4 嘴巴大小 + 微笑

问题：

```text
嘴角同时被 mouthSize 和 smile 影响。
```

策略：

```text
嘴角点位总位移限制。
smile 的 y 位移优先，mouthSize 的 x/y 位移减弱。
```

---

# 18. 降级策略

## 18.1 没有人脸

```text
跳过所有 FaceWarpPass 控制点。
继续执行不依赖人脸的滤镜 / 色彩。
```

## 18.2 部分关键点缺失

```text
没有眼睛点：跳过眼睛效果。
没有鼻子点：跳过鼻子效果。
没有嘴唇点：跳过嘴巴和唇色。
没有轮廓点：跳过脸型。
```

## 18.3 人脸过小

```text
降低几何形变强度。
跳过高级效果。
```

## 18.4 侧脸 / 大角度

第一版可通过 boundingBox 和关键点分布粗略判断。

策略：

```text
yaw 过大时降低脸型、鼻子、嘴巴强度。
```

---

# 19. 验收测试图集

每个效果必须在以下场景测试：

```text
正脸
轻微侧脸
圆脸
长脸
宽脸
小眼睛
大眼睛
塌鼻梁
宽鼻翼
薄嘴唇
厚嘴唇
戴眼镜
刘海遮挡
暗光
强光
前置摄像头
后置摄像头
多人脸
```

---

# 20. 第一版开发顺序

建议顺序：

```text
1. LUTFilterEffect
2. ColorPass / skinSharpen
3. SkinWhitenEffect
4. SkinRosyEffect
5. FaceWarpPass 基础框架
6. EyeWarpProvider.eyeSize
7. FaceShapeWarpProvider.faceSlim
8. FaceShapeWarpProvider.faceSmall / faceVShape
9. ChinWarpProvider.chinLength
10. NoseWarpProvider.noseSlim
11. MouthWarpProvider.smile
12. 补 eyeDistance / eyeYPosition / eyeTailLift
13. 补 noseWingSlim / noseTipSize
14. 补 mouthSize / mouthWidth
15. SkinSmoothEffect
16. LipColorEffect
```

原因：

```text
先做不依赖点位的效果，快速验证 RenderGraph。
再做 FaceWarpPass，先实现大眼和瘦脸两个标志效果。
最后补完整 MVP 参数。
```

---

# 21. 第一版 Provider 文件规划

```text
BeautyEffects/Warp/
├── WarpControlPoint.swift
├── WarpControlPointProvider.swift
├── FaceWarpEffect.swift
├── EyeWarpProvider.swift
├── FaceShapeWarpProvider.swift
├── ChinWarpProvider.swift
├── NoseWarpProvider.swift
└── MouthWarpProvider.swift
```

```text
BeautyEffects/Skin/
├── SkinSmoothEffect.swift
├── SkinWhitenEffect.swift
├── SkinRosyEffect.swift
└── SkinSharpenEffect.swift
```

```text
BeautyEffects/Color/
├── ColorAdjustmentEffect.swift
├── LUTFilterEffect.swift
└── FilterBlendEffect.swift
```

```text
BeautyEffects/Makeup/
└── LipColorEffect.swift
```

---

# 22. 第一版效果验收标准

## 22.1 基础效果

```text
参数为 0 时输出接近原图。
参数逐渐增大时效果连续变化。
强度最大时不出现严重破图。
没有关键点时自动跳过对应效果。
```

## 22.2 实时性能

```text
720p 30fps 可用。
1080p 在中高端设备可用。
大眼 + 瘦脸 + 美白 + LUT 同时开启不卡顿。
```

## 22.3 视觉效果

```text
大眼自然。
瘦脸不拉背景。
鼻子不塌。
嘴角不假。
磨皮不塑料。
美白不假白。
红润不过红。
滤镜不偏色严重。
```

---

# 23. 后续高级算法扩展

## 23.1 高级眼睛

```text
眼宽
眼高
开内眼角
开外眼角
卧蚕
眼神光
眼白提亮
美瞳
```

## 23.2 高级皮肤

```text
skin mask
五官保护 mask
祛痘
祛斑
法令纹
泪沟
皮肤纹理保留
```

## 23.3 高级妆容

```text
口红
腮红
眼影
眼线
睫毛
眉毛
修容
高光
```

## 23.4 高级形变

```text
mesh warp
dense landmarks
face mesh
3D pose aware deformation
```

---

# 24. 一句话结论

第一版算法实现不要追求功能数量，而要保证底层模式正确：

```text
所有五官形变都生成 WarpControlPoint，统一进入 FaceWarpPass。
所有颜色和皮肤效果都按 Pass 合并，避免每个参数一个 shader。
每个参数都有安全强度、降级策略和验收标准。
```

只要这套规则稳定，后续增加高级眼睛、完整妆容、皮肤修复、背景分割，都可以在同一套架构上继续扩展。
