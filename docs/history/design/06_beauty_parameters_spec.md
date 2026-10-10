# Beauty Parameters Spec

## 1. 文档目标

本文档定义 iOS 美颜 SDK 第一版到完整版本的参数模型。

该文档用于约束：

```text
SDK 对外 API
SwiftUI 参数滑杆
预设 JSON
算法模块
Metal Shader Uniform
测试用例
版本兼容
```

核心原则：

```text
1. 参数命名必须稳定。
2. 参数默认值必须是无效果状态。
3. App UI 可以显示 0~100，但 SDK 内部统一使用 Float。
4. 所有参数必须可 Codable。
5. 第一版未实现的参数可以预留，但不要默认生效。
6. 强度参数必须有安全上限，避免效果失控。
```

---

# 2. 参数范围规范

## 2.1 SDK 内部范围

SDK 内部统一使用 `Float`。

### 增强型参数

用于只增强、不反向调整的功能。

```text
范围：0.0 ... 1.0
默认：0.0
```

例如：

```text
skinSmoothing
skinWhitening
skinRosy
faceSlim
noseSlim
filterIntensity
```

### 双向调整参数

用于既可以变小，也可以变大的功能。

```text
范围：-1.0 ... 1.0
默认：0.0
```

例如：

```text
eyeSize
mouthSize
chinLength
eyeDistance
eyeYPosition
mouthWidth
```

### 枚举 / ID 参数

用于选择资源或模式。

```text
String?
Enum
Bool
```

例如：

```text
filterId
makeupId
presetId
```

---

## 2.2 UI 显示范围

App UI 不直接暴露 SDK 内部范围。

推荐 UI 显示：

```text
增强型参数：0 ... 100
双向参数：-100 ... 100
```

转换规则：

```swift
// UI 0...100 -> SDK 0...1
let sdkValue = uiValue / 100.0

// UI -100...100 -> SDK -1...1
let sdkValue = uiValue / 100.0
```

---

## 2.3 参数默认值

所有美颜参数默认必须表示“无效果”。

```text
Float：0.0
String?：nil
Bool：false，除非文档明确说明
Enum：default / none / natural
```

禁止默认开强效果。

---

# 3. 第一版 BeautyParameters 结构

第一版建议先定义 MVP 参数。

```swift
public struct BeautyParameters: Codable, Equatable, Sendable {

    // MARK: - Skin
    public var skinSmoothing: Float
    public var skinWhitening: Float
    public var skinRosy: Float
    public var skinSharpen: Float

    // MARK: - Color
    public var brightness: Float
    public var contrast: Float
    public var saturation: Float
    public var temperature: Float
    public var tint: Float
    public var exposure: Float
    public var highlight: Float
    public var shadow: Float

    // MARK: - Face Shape
    public var faceSlim: Float
    public var faceSmall: Float
    public var faceVShape: Float
    public var jawSlim: Float
    public var chinLength: Float

    // MARK: - Eyes
    public var eyeSize: Float
    public var eyeDistance: Float
    public var eyeYPosition: Float
    public var eyeTailLift: Float

    // MARK: - Nose
    public var noseSlim: Float
    public var noseWingSlim: Float
    public var noseTipSize: Float
    public var noseBridge: Float

    // MARK: - Mouth
    public var mouthSize: Float
    public var mouthWidth: Float
    public var smile: Float
    public var lipColor: Float

    // MARK: - Filter
    public var filterId: String?
    public var filterIntensity: Float

    public init(
        skinSmoothing: Float = 0,
        skinWhitening: Float = 0,
        skinRosy: Float = 0,
        skinSharpen: Float = 0,
        brightness: Float = 0,
        contrast: Float = 0,
        saturation: Float = 0,
        temperature: Float = 0,
        tint: Float = 0,
        exposure: Float = 0,
        highlight: Float = 0,
        shadow: Float = 0,
        faceSlim: Float = 0,
        faceSmall: Float = 0,
        faceVShape: Float = 0,
        jawSlim: Float = 0,
        chinLength: Float = 0,
        eyeSize: Float = 0,
        eyeDistance: Float = 0,
        eyeYPosition: Float = 0,
        eyeTailLift: Float = 0,
        noseSlim: Float = 0,
        noseWingSlim: Float = 0,
        noseTipSize: Float = 0,
        noseBridge: Float = 0,
        mouthSize: Float = 0,
        mouthWidth: Float = 0,
        smile: Float = 0,
        lipColor: Float = 0,
        filterId: String? = nil,
        filterIntensity: Float = 0
    ) {
        self.skinSmoothing = skinSmoothing
        self.skinWhitening = skinWhitening
        self.skinRosy = skinRosy
        self.skinSharpen = skinSharpen
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
        self.temperature = temperature
        self.tint = tint
        self.exposure = exposure
        self.highlight = highlight
        self.shadow = shadow
        self.faceSlim = faceSlim
        self.faceSmall = faceSmall
        self.faceVShape = faceVShape
        self.jawSlim = jawSlim
        self.chinLength = chinLength
        self.eyeSize = eyeSize
        self.eyeDistance = eyeDistance
        self.eyeYPosition = eyeYPosition
        self.eyeTailLift = eyeTailLift
        self.noseSlim = noseSlim
        self.noseWingSlim = noseWingSlim
        self.noseTipSize = noseTipSize
        self.noseBridge = noseBridge
        self.mouthSize = mouthSize
        self.mouthWidth = mouthWidth
        self.smile = smile
        self.lipColor = lipColor
        self.filterId = filterId
        self.filterIntensity = filterIntensity
    }
}
```

---

# 4. 参数总表：MVP 版本

## 4.1 Skin：基础皮肤美颜

| 参数名 | 中文名 | 类型 | SDK 范围 | UI 范围 | 默认值 | 是否依赖人脸 | 是否实时 | 性能影响 | 算法模块 | 版本 |
|---|---|---:|---:|---:|---:|---|---|---|---|---|
| `skinSmoothing` | 磨皮 | Float | 0...1 | 0...100 | 0 | 否，后续建议依赖 skin mask | 是 | 中 | `SkinSmoothEffect` | 1.0 |
| `skinWhitening` | 美白 | Float | 0...1 | 0...100 | 0 | 否，后续建议依赖 skin mask | 是 | 低 | `SkinWhitenEffect` | 1.0 |
| `skinRosy` | 红润 | Float | 0...1 | 0...100 | 0 | 否，后续建议依赖 skin mask | 是 | 低 | `SkinRosyEffect` | 1.0 |
| `skinSharpen` | 清晰 / 锐化 | Float | 0...1 | 0...100 | 0 | 否 | 是 | 低 | `SkinSharpenEffect` / `ColorAdjustmentEffect` | 1.0 |

### 参数说明

#### skinSmoothing

作用：平滑皮肤，降低毛孔、轻微细纹和噪点。

第一版实现：

```text
边缘保护模糊
低频平滑
高频细节回加
```

后续增强：

```text
skin mask
五官保护 mask
高级 bilateral / guided filter
```

注意：

```text
强度过高会出现塑料脸。
第一版建议实际生效强度上限不超过 0.6。
```

#### skinWhitening

作用：提升肤色亮度，让皮肤更干净。

注意：

```text
不能直接提升全图亮度。
要保护高光，避免脸部过曝。
后续应只对 skin mask 区域生效。
```

#### skinRosy

作用：增加面部气色。

注意：

```text
红润应轻微作用于肤色区域。
不应该让嘴唇、衣服、背景明显变红。
```

#### skinSharpen

作用：提升图像清晰度。

注意：

```text
锐化应该放在磨皮之后。
避免把噪点和皮肤瑕疵锐化出来。
```

---

## 4.2 Color：基础颜色调整

| 参数名 | 中文名 | 类型 | SDK 范围 | UI 范围 | 默认值 | 是否依赖人脸 | 是否实时 | 性能影响 | 算法模块 | 版本 |
|---|---|---:|---:|---:|---:|---|---|---|---|---|
| `brightness` | 亮度 | Float | -1...1 | -100...100 | 0 | 否 | 是 | 低 | `ColorAdjustmentEffect` | 1.0 |
| `contrast` | 对比度 | Float | -1...1 | -100...100 | 0 | 否 | 是 | 低 | `ColorAdjustmentEffect` | 1.0 |
| `saturation` | 饱和度 | Float | -1...1 | -100...100 | 0 | 否 | 是 | 低 | `ColorAdjustmentEffect` | 1.0 |
| `temperature` | 色温 | Float | -1...1 | -100...100 | 0 | 否 | 是 | 低 | `ColorAdjustmentEffect` | 1.0 |
| `tint` | 色调偏移 | Float | -1...1 | -100...100 | 0 | 否 | 是 | 低 | `ColorAdjustmentEffect` | 1.0 |
| `exposure` | 曝光 | Float | -1...1 | -100...100 | 0 | 否 | 是 | 低 | `ColorAdjustmentEffect` | 1.0 |
| `highlight` | 高光 | Float | -1...1 | -100...100 | 0 | 否 | 是 | 低 | `ColorAdjustmentEffect` | 1.0 |
| `shadow` | 阴影 | Float | -1...1 | -100...100 | 0 | 否 | 是 | 低 | `ColorAdjustmentEffect` | 1.0 |

### 参数说明

这些参数属于第一版基础颜色调整，与 `skinSharpen` 一起进入 `ColorAdjustmentEffect`。

注意：

```text
实时预览中应合并为一个 ColorPass。
默认值必须保持中性，不改变原图。
色温、tint、exposure、highlight、shadow 的实际算法强度应有安全上限。
```

---

## 4.3 Face Shape：脸型调整

| 参数名 | 中文名 | 类型 | SDK 范围 | UI 范围 | 默认值 | 是否依赖人脸 | 是否实时 | 性能影响 | 算法模块 | 版本 |
|---|---|---:|---:|---:|---:|---|---|---|---|---|
| `faceSlim` | 瘦脸 | Float | 0...1 | 0...100 | 0 | 是 | 是 | 中 | `FaceShapeWarpProvider` | 1.0 |
| `faceSmall` | 小脸 | Float | 0...1 | 0...100 | 0 | 是 | 是 | 中 | `FaceShapeWarpProvider` | 1.0 |
| `faceVShape` | V 脸 | Float | 0...1 | 0...100 | 0 | 是 | 是 | 中 | `FaceShapeWarpProvider` | 1.0 |
| `jawSlim` | 下颌收紧 | Float | 0...1 | 0...100 | 0 | 是 | 是 | 中 | `FaceShapeWarpProvider` | 1.0 |
| `chinLength` | 下巴长度 | Float | -1...1 | -100...100 | 0 | 是 | 是 | 中 | `ChinWarpProvider` | 1.0 |

### 参数说明

#### faceSlim

作用：收窄脸颊区域。

依赖点位：

```text
faceContour
left cheek area
right cheek area
face center
```

实现方式：

```text
左右脸颊控制点向脸部中心移动。
影响范围沿脸颊区域平滑衰减。
```

安全限制：

```text
强度过高会导致背景拉伸。
建议实际生效上限 0.6。
```

#### faceSmall

作用：整体缩小脸部视觉面积。

依赖点位：

```text
faceContour
face bounding box
face center
```

实现方式：

```text
脸部轮廓点整体向中心收缩。
五官可以轻微跟随，但第一版不建议大幅移动五官。
```

#### faceVShape

作用：让脸型更接近 V 型。

依赖点位：

```text
faceContour
jaw contour
chin point
```

实现方式：

```text
下颌区域向内收缩。
下巴区域轻微拉长或收尖。
```

#### jawSlim

作用：收紧下颌线和腮帮。

依赖点位：

```text
lower face contour
jaw area
chin point
```

注意：

```text
不能影响嘴巴过多。
不能让下巴和脖子交界明显扭曲。
```

#### chinLength

作用：调整下巴长度。

范围说明：

```text
负数：缩短下巴
正数：拉长下巴
```

注意：

```text
双向参数。
强度过高会导致嘴巴和下颌区域变形。
```

---

## 4.4 Eyes：眼睛调整

| 参数名 | 中文名 | 类型 | SDK 范围 | UI 范围 | 默认值 | 是否依赖人脸 | 是否实时 | 性能影响 | 算法模块 | 版本 |
|---|---|---:|---:|---:|---:|---|---|---|---|---|
| `eyeSize` | 大眼 / 小眼 | Float | -1...1 | -100...100 | 0 | 是 | 是 | 中 | `EyeWarpProvider` | 1.0 |
| `eyeDistance` | 眼距 | Float | -1...1 | -100...100 | 0 | 是 | 是 | 中 | `EyeWarpProvider` | 1.0 |
| `eyeYPosition` | 眼睛上下位置 | Float | -1...1 | -100...100 | 0 | 是 | 是 | 中 | `EyeWarpProvider` | 1.0 |
| `eyeTailLift` | 眼尾上扬 | Float | -1...1 | -100...100 | 0 | 是 | 是 | 中 | `EyeWarpProvider` | 1.0 |

### 参数说明

#### eyeSize

作用：调整眼睛大小。

范围说明：

```text
负数：眼睛变小
正数：眼睛变大
```

依赖点位：

```text
leftEye
rightEye
leftPupil，可选
rightPupil，可选
```

实现方式：

```text
计算左右眼中心。
计算眼睛影响半径。
对眼周区域做局部放大或缩小采样。
```

安全限制：

```text
不应明显影响眉毛。
不应明显拉歪鼻梁。
不应导致眼球边缘断裂。
建议实际生效上限 0.45。
```

#### eyeDistance

作用：调整两眼之间距离。

范围说明：

```text
负数：眼距变近
正数：眼距变远
```

实现方式：

```text
左眼区域和右眼区域分别做局部横向位移。
```

注意：

```text
眼距调整影响范围必须控制，避免鼻梁明显变形。
```

#### eyeYPosition

作用：调整双眼上下位置。

范围说明：

```text
负数：眼睛下移
正数：眼睛上移
```

注意：

```text
这个参数要谨慎使用。
眼睛上下移动容易影响眉毛、鼻梁和脸部比例。
第一版强度应较低。
```

#### eyeTailLift

作用：调整眼尾角度。

范围说明：

```text
负数：眼尾下压
正数：眼尾上扬
```

依赖点位：

```text
leftEye outer corner
rightEye outer corner
```

注意：

```text
第一版只做轻微眼尾调整。
复杂眼型切换放到后续版本。
```

---

## 4.5 Nose：鼻子调整

| 参数名 | 中文名 | 类型 | SDK 范围 | UI 范围 | 默认值 | 是否依赖人脸 | 是否实时 | 性能影响 | 算法模块 | 版本 |
|---|---|---:|---:|---:|---:|---|---|---|---|---|
| `noseSlim` | 瘦鼻 | Float | 0...1 | 0...100 | 0 | 是 | 是 | 中 | `NoseWarpProvider` | 1.0 |
| `noseWingSlim` | 鼻翼收窄 | Float | 0...1 | 0...100 | 0 | 是 | 是 | 中 | `NoseWarpProvider` | 1.0 |
| `noseTipSize` | 鼻头大小 | Float | -1...1 | -100...100 | 0 | 是 | 是 | 中 | `NoseWarpProvider` | 1.0 |
| `noseBridge` | 鼻梁增强 | Float | 0...1 | 0...100 | 0 | 是 | 是 | 低~中 | `NoseWarpProvider` / `MakeupLightEffect` | 1.0 |

### 参数说明

#### noseSlim

作用：整体收窄鼻子。

依赖点位：

```text
nose
noseCrest
face center
```

实现方式：

```text
鼻子左右区域向鼻梁中心线移动。
```

注意：

```text
鼻子区域点位通常不如眼睛、嘴巴稳定。
第一版强度要保守。
```

#### noseWingSlim

作用：收窄鼻翼。

依赖点位：

```text
nose lower points
nose wing estimated points
```

注意：

```text
Vision 默认鼻翼点可能不够精细。
第一版可以做基础效果。
高级鼻翼需要更密集点位。
```

#### noseTipSize

作用：调整鼻头大小。

范围说明：

```text
负数：鼻头缩小
正数：鼻头放大，通常不建议 UI 暴露正向
```

建议：

```text
产品 UI 可以只展示“鼻头缩小”，内部仍保留双向能力。
```

#### noseBridge

作用：增强鼻梁立体感。

实现方式：

```text
第一版：轻微鼻梁区域变窄 + 明暗增强。
后续：鼻梁高光 + 鼻侧阴影。
```

注意：

```text
鼻梁“变高”更多是光影效果，不应该只靠几何形变。
```

---

## 4.6 Mouth：嘴巴调整

| 参数名 | 中文名 | 类型 | SDK 范围 | UI 范围 | 默认值 | 是否依赖人脸 | 是否实时 | 性能影响 | 算法模块 | 版本 |
|---|---|---:|---:|---:|---:|---|---|---|---|---|
| `mouthSize` | 嘴巴大小 | Float | -1...1 | -100...100 | 0 | 是 | 是 | 中 | `MouthWarpProvider` | 1.0 |
| `mouthWidth` | 嘴巴宽度 | Float | -1...1 | -100...100 | 0 | 是 | 是 | 中 | `MouthWarpProvider` | 1.0 |
| `smile` | 嘴角微笑 | Float | 0...1 | 0...100 | 0 | 是 | 是 | 中 | `MouthWarpProvider` | 1.0 |
| `lipColor` | 唇色增强 | Float | 0...1 | 0...100 | 0 | 是，后续建议 lip mask | 是 | 低 | `LipColorEffect` | 1.0 |

### 参数说明

#### mouthSize

作用：调整嘴巴整体大小。

范围说明：

```text
负数：嘴巴变小
正数：嘴巴变大
```

依赖点位：

```text
outerLips
innerLips
mouth center
```

注意：

```text
嘴巴大小调整不能让牙齿区域严重拉伸。
```

#### mouthWidth

作用：调整嘴巴横向宽度。

范围说明：

```text
负数：嘴巴变窄
正数：嘴巴变宽
```

实现方式：

```text
左右嘴角区域横向移动。
```

#### smile

作用：嘴角上扬，制造轻微微笑感。

依赖点位：

```text
left mouth corner
right mouth corner
outerLips
```

实现方式：

```text
左右嘴角向上移动。
影响范围平滑衰减。
```

注意：

```text
不能把表情拉得太假。
建议实际强度上限 0.5。
```

#### lipColor

作用：增强自然唇色。

实现方式：

```text
第一版：根据嘴唇关键点生成基础区域，做颜色增强。
后续：完整 lipstick mask + blend mode。
```

---

## 4.7 Filter：滤镜参数

| 参数名 | 中文名 | 类型 | SDK 范围 | UI 范围 | 默认值 | 是否依赖人脸 | 是否实时 | 性能影响 | 算法模块 | 版本 |
|---|---|---:|---:|---:|---:|---|---|---|---|---|
| `filterId` | 滤镜 ID | String? | - | - | nil | 否 | 是 | 低~中 | `LUTFilterEffect` | 1.0 |
| `filterIntensity` | 滤镜强度 | Float | 0...1 | 0...100 | 0 | 否 | 是 | 低~中 | `LUTFilterEffect` | 1.0 |

### 参数说明

#### filterId

作用：指定当前使用的滤镜资源。

示例：

```text
clean_01
film_01
warm_01
cool_white_01
```

规则：

```text
filterId 为 nil 时，不应用 LUT 滤镜。
filterId 找不到资源时，应返回错误或降级为无滤镜。
```

#### filterIntensity

作用：控制滤镜强度。

实现：

```text
output = mix(original, filtered, filterIntensity)
```

规则：

```text
filterIntensity = 0 时必须等于原图。
filterIntensity = 1 时为完整滤镜。
```

---

# 5. 后续扩展参数表

以下参数不建议 1.0 全部实现，但建议从设计上预留分类。

---

## 5.1 Advanced Eyes：高级眼睛参数

| 参数名 | 中文名 | 类型 | SDK 范围 | 默认值 | 依赖 | 建议版本 |
|---|---|---:|---:|---:|---|---|
| `eyeWidth` | 眼睛宽度 | Float | -1...1 | 0 | leftEye / rightEye | 1.5 |
| `eyeHeight` | 眼睛高度 | Float | -1...1 | 0 | leftEye / rightEye | 1.5 |
| `leftEyeSize` | 左眼大小 | Float | -1...1 | 0 | leftEye | 1.5 |
| `rightEyeSize` | 右眼大小 | Float | -1...1 | 0 | rightEye | 1.5 |
| `innerEyeCorner` | 开内眼角 | Float | 0...1 | 0 | eye corners | 1.5 |
| `outerEyeCorner` | 开外眼角 | Float | 0...1 | 0 | eye corners | 1.5 |
| `eyeWhite` | 眼白提亮 | Float | 0...1 | 0 | eye mask | 1.5 |
| `eyeLight` | 眼神光 | Float | 0...1 | 0 | eye / pupil | 1.5 |
| `eyeBag` | 卧蚕 | Float | 0...1 | 0 | lower eye area | 2.0 |
| `darkCircleRemoval` | 黑眼圈淡化 | Float | 0...1 | 0 | under-eye mask | 2.0 |

---

## 5.2 Advanced Nose：高级鼻子参数

| 参数名 | 中文名 | 类型 | SDK 范围 | 默认值 | 依赖 | 建议版本 |
|---|---|---:|---:|---:|---|---|
| `noseHeight` | 鼻梁高度 | Float | 0...1 | 0 | noseCrest | 1.5 |
| `noseLength` | 鼻子长度 | Float | -1...1 | 0 | nose / noseCrest | 1.5 |
| `noseTipLift` | 鼻尖上翘 | Float | -1...1 | 0 | nose tip | 1.5 |
| `nosePositionY` | 鼻子上下位置 | Float | -1...1 | 0 | nose | 1.5 |
| `noseShadow` | 鼻影 | Float | 0...1 | 0 | nose mask | 2.0 |
| `noseHighlight` | 鼻梁高光 | Float | 0...1 | 0 | noseCrest mask | 2.0 |
| `noseBase` | 鼻基底 | Float | 0...1 | 0 | dense landmarks | 2.5 |

---

## 5.3 Advanced Mouth：高级嘴巴参数

| 参数名 | 中文名 | 类型 | SDK 范围 | 默认值 | 依赖 | 建议版本 |
|---|---|---:|---:|---:|---|---|
| `mouthYPosition` | 嘴巴上下位置 | Float | -1...1 | 0 | outerLips | 1.5 |
| `upperLipThickness` | 上唇厚度 | Float | -1...1 | 0 | outerLips / innerLips | 1.5 |
| `lowerLipThickness` | 下唇厚度 | Float | -1...1 | 0 | outerLips / innerLips | 1.5 |
| `lipGloss` | 唇部光泽 | Float | 0...1 | 0 | lip mask | 2.0 |
| `lipWrinkleSmooth` | 唇纹淡化 | Float | 0...1 | 0 | lip mask | 2.0 |
| `teethWhitening` | 牙齿美白 | Float | 0...1 | 0 | teeth mask | 2.0 |
| `philtrumLength` | 人中长度 | Float | -1...1 | 0 | nose + lips | 2.0 |

---

## 5.4 Eyebrow：眉毛参数

| 参数名 | 中文名 | 类型 | SDK 范围 | 默认值 | 依赖 | 建议版本 |
|---|---|---:|---:|---:|---|---|
| `eyebrowYPosition` | 眉毛上下位置 | Float | -1...1 | 0 | eyebrow landmarks | 1.5 |
| `eyebrowDistance` | 眉间距 | Float | -1...1 | 0 | eyebrow landmarks | 1.5 |
| `eyebrowThickness` | 眉毛粗细 | Float | -1...1 | 0 | eyebrow mask | 2.0 |
| `eyebrowColor` | 眉色强度 | Float | 0...1 | 0 | eyebrow mask | 2.0 |
| `eyebrowShapeId` | 眉形 ID | String? | - | nil | eyebrow landmarks | 2.0 |

---

## 5.5 Advanced Face Shape：高级脸型参数

| 参数名 | 中文名 | 类型 | SDK 范围 | 默认值 | 依赖 | 建议版本 |
|---|---|---:|---:|---:|---|---|
| `cheekboneSlim` | 颧骨内收 | Float | 0...1 | 0 | face contour | 1.5 |
| `foreheadHeight` | 额头高度 | Float | -1...1 | 0 | face contour / hairline | 2.0 |
| `templeFullness` | 太阳穴饱满 | Float | 0...1 | 0 | face contour | 2.0 |
| `faceSymmetry` | 左右脸对称 | Float | 0...1 | 0 | face contour | 2.0 |
| `midFaceLength` | 中庭长度 | Float | -1...1 | 0 | dense landmarks | 2.5 |
| `lowerFaceLength` | 下庭长度 | Float | -1...1 | 0 | dense landmarks | 2.5 |
| `hairlineHeight` | 发际线高度 | Float | -1...1 | 0 | hair / skin segmentation | 2.5 |

---

## 5.6 Advanced Skin：高级皮肤参数

| 参数名 | 中文名 | 类型 | SDK 范围 | 默认值 | 依赖 | 建议版本 |
|---|---|---:|---:|---:|---|---|
| `skinTexturePreserve` | 皮肤纹理保留 | Float | 0...1 | 0.5 | skin mask | 2.0 |
| `skinEvenTone` | 肤色均匀 | Float | 0...1 | 0 | skin mask | 2.0 |
| `acneRemoval` | 祛痘 | Float | 0...1 | 0 | blemish detection | 2.0 |
| `spotRemoval` | 祛斑 | Float | 0...1 | 0 | blemish detection | 2.0 |
| `tearTroughRemoval` | 泪沟淡化 | Float | 0...1 | 0 | under-eye mask | 2.0 |
| `nasolabialFoldRemoval` | 法令纹淡化 | Float | 0...1 | 0 | mouth / cheek mask | 2.0 |
| `foreheadWrinkleRemoval` | 额头纹淡化 | Float | 0...1 | 0 | forehead mask | 2.0 |

---

## 5.7 Makeup：妆容参数

| 参数名 | 中文名 | 类型 | SDK 范围 | 默认值 | 依赖 | 建议版本 |
|---|---|---:|---:|---:|---|---|
| `makeupId` | 妆容 ID | String? | - | nil | makeup resources | 2.0 |
| `makeupIntensity` | 妆容整体强度 | Float | 0...1 | 0 | makeup resources | 2.0 |
| `lipstickIntensity` | 口红强度 | Float | 0...1 | 0 | lip mask | 2.0 |
| `blushIntensity` | 腮红强度 | Float | 0...1 | 0 | cheek mask | 2.0 |
| `eyeshadowIntensity` | 眼影强度 | Float | 0...1 | 0 | eye mask | 2.0 |
| `eyelinerIntensity` | 眼线强度 | Float | 0...1 | 0 | eye landmarks | 2.0 |
| `eyelashIntensity` | 睫毛强度 | Float | 0...1 | 0 | eye landmarks | 2.0 |
| `contourIntensity` | 修容强度 | Float | 0...1 | 0 | face mask | 2.0 |
| `highlightIntensity` | 高光强度 | Float | 0...1 | 0 | face mask | 2.0 |

---

## 5.8 Background：背景与人像分割参数

| 参数名 | 中文名 | 类型 | SDK 范围 | 默认值 | 依赖 | 建议版本 |
|---|---|---:|---:|---:|---|---|
| `portraitSegmentationEnabled` | 人像分割开关 | Bool | - | false | person segmentation | 2.5 |
| `backgroundBlur` | 背景虚化 | Float | 0...1 | 0 | portrait mask | 2.5 |
| `backgroundDarken` | 背景压暗 | Float | 0...1 | 0 | portrait mask | 2.5 |
| `backgroundReplaceId` | 背景替换 ID | String? | - | nil | portrait mask | 2.5 |
| `portraitOutline` | 人像描边 | Float | 0...1 | 0 | portrait mask | 2.5 |
| `edgeLight` | 边缘光 | Float | 0...1 | 0 | portrait mask | 2.5 |

---

## 5.9 Body：身体美型参数

| 参数名 | 中文名 | 类型 | SDK 范围 | 默认值 | 依赖 | 建议版本 |
|---|---|---:|---:|---:|---|---|
| `legLength` | 长腿 | Float | 0...1 | 0 | body pose | 3.0 |
| `bodySlim` | 瘦身 | Float | 0...1 | 0 | body pose / segmentation | 3.0 |
| `waistSlim` | 瘦腰 | Float | 0...1 | 0 | body pose | 3.0 |
| `armSlim` | 瘦手臂 | Float | 0...1 | 0 | body pose | 3.0 |
| `legSlim` | 瘦腿 | Float | 0...1 | 0 | body pose | 3.0 |
| `headSize` | 头部大小 | Float | -1...1 | 0 | face + body pose | 3.0 |
| `shoulderWidth` | 肩宽 | Float | -1...1 | 0 | body pose | 3.0 |

---

# 6. 参数分类与 UI 映射

App 侧参数面板建议这样分组。

## 6.1 一级分类

```text
美颜
脸型
眼睛
鼻子
嘴巴
眉毛
妆容
滤镜
背景
身体
```

## 6.2 MVP UI 映射

### 美颜

```text
磨皮 -> skinSmoothing
美白 -> skinWhitening
红润 -> skinRosy
清晰 -> skinSharpen
亮度 -> brightness
对比度 -> contrast
饱和度 -> saturation
色温 -> temperature
色调 -> tint
曝光 -> exposure
高光 -> highlight
阴影 -> shadow
```

### 脸型

```text
瘦脸 -> faceSlim
小脸 -> faceSmall
V脸 -> faceVShape
下颌 -> jawSlim
下巴 -> chinLength
```

### 眼睛

```text
大眼 -> eyeSize
眼距 -> eyeDistance
上下 -> eyeYPosition
眼尾 -> eyeTailLift
```

### 鼻子

```text
瘦鼻 -> noseSlim
鼻翼 -> noseWingSlim
鼻头 -> noseTipSize
鼻梁 -> noseBridge
```

### 嘴巴

```text
嘴巴大小 -> mouthSize
嘴巴宽度 -> mouthWidth
微笑 -> smile
唇色 -> lipColor
```

### 滤镜

```text
滤镜选择 -> filterId
滤镜强度 -> filterIntensity
```

---

# 7. 参数归一化规范

App 传入 SDK 前应保证参数范围合法。

SDK 内部也必须二次 clamp，避免外部传错。

```swift
extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
```

建议提供：

```swift
public struct BeautyParameterNormalizer {
    public func normalize(_ parameters: BeautyParameters) -> BeautyParameters {
        var result = parameters

        result.skinSmoothing = result.skinSmoothing.clamped(to: 0...1)
        result.skinWhitening = result.skinWhitening.clamped(to: 0...1)
        result.skinRosy = result.skinRosy.clamped(to: 0...1)
        result.skinSharpen = result.skinSharpen.clamped(to: 0...1)

        result.faceSlim = result.faceSlim.clamped(to: 0...1)
        result.faceSmall = result.faceSmall.clamped(to: 0...1)
        result.faceVShape = result.faceVShape.clamped(to: 0...1)
        result.jawSlim = result.jawSlim.clamped(to: 0...1)
        result.chinLength = result.chinLength.clamped(to: -1...1)

        result.eyeSize = result.eyeSize.clamped(to: -1...1)
        result.eyeDistance = result.eyeDistance.clamped(to: -1...1)
        result.eyeYPosition = result.eyeYPosition.clamped(to: -1...1)
        result.eyeTailLift = result.eyeTailLift.clamped(to: -1...1)

        result.noseSlim = result.noseSlim.clamped(to: 0...1)
        result.noseWingSlim = result.noseWingSlim.clamped(to: 0...1)
        result.noseTipSize = result.noseTipSize.clamped(to: -1...1)
        result.noseBridge = result.noseBridge.clamped(to: 0...1)

        result.mouthSize = result.mouthSize.clamped(to: -1...1)
        result.mouthWidth = result.mouthWidth.clamped(to: -1...1)
        result.smile = result.smile.clamped(to: 0...1)
        result.lipColor = result.lipColor.clamped(to: 0...1)

        result.filterIntensity = result.filterIntensity.clamped(to: 0...1)

        return result
    }
}
```

---

# 8. 参数安全强度建议

即使 SDK 范围是 0...1 或 -1...1，实际算法内部也不应线性使用全部强度。

## 8.1 MVP 安全上限

| 参数 | 建议算法实际最大强度 | 原因 |
|---|---:|---|
| `skinSmoothing` | 0.6 | 避免塑料脸 |
| `skinWhitening` | 0.5 | 避免过曝和假白 |
| `skinRosy` | 0.4 | 避免脸部发红 |
| `faceSlim` | 0.6 | 避免背景拉伸 |
| `faceSmall` | 0.45 | 避免五官比例异常 |
| `faceVShape` | 0.5 | 避免锥子脸 |
| `chinLength` | 0.35 | 避免下巴畸形 |
| `eyeSize` | 0.45 | 避免眼睛过大 |
| `eyeDistance` | 0.3 | 避免鼻梁变形 |
| `eyeYPosition` | 0.25 | 避免脸部比例异常 |
| `eyeTailLift` | 0.3 | 避免眼型变假 |
| `noseSlim` | 0.35 | Vision 鼻子点位有限 |
| `noseWingSlim` | 0.35 | 鼻翼点位不够密 |
| `noseTipSize` | 0.3 | 避免鼻头变形 |
| `mouthSize` | 0.35 | 避免牙齿拉伸 |
| `mouthWidth` | 0.35 | 避免嘴角变形 |
| `smile` | 0.5 | 避免假笑 |
| `lipColor` | 0.5 | 避免口红感过重 |

---

# 9. 参数与算法模块映射

## 9.1 FaceWarpPass 参数

以下参数应该统一进入 `FaceWarpPass`：

```text
faceSlim
faceSmall
faceVShape
jawSlim
chinLength
eyeSize
eyeDistance
eyeYPosition
eyeTailLift
noseSlim
noseWingSlim
noseTipSize
mouthSize
mouthWidth
smile
```

对应 Provider：

```text
FaceShapeWarpProvider
ChinWarpProvider
EyeWarpProvider
NoseWarpProvider
MouthWarpProvider
```

## 9.2 SkinPass 参数

```text
skinSmoothing
skinWhitening
skinRosy
```

对应 Effect：

```text
SkinSmoothEffect
SkinWhitenEffect
SkinRosyEffect
```

## 9.3 ColorPass 参数

```text
skinSharpen
brightness
contrast
saturation
temperature
tint
exposure
highlight
shadow
```

## 9.4 LUTPass 参数

```text
filterId
filterIntensity
```

对应 Effect：

```text
LUTFilterEffect
```

## 9.5 MakeupPass 参数

MVP 里暂时只保留：

```text
lipColor
```

后续进入完整妆容：

```text
makeupId
makeupIntensity
lipstickIntensity
blushIntensity
eyeshadowIntensity
eyelinerIntensity
```

---

# 10. 参数 Codable JSON 示例

## 10.1 单个参数组

```json
{
  "skinSmoothing": 0.3,
  "skinWhitening": 0.2,
  "skinRosy": 0.1,
  "skinSharpen": 0.15,
  "brightness": 0,
  "contrast": 0,
  "saturation": 0,
  "temperature": 0,
  "tint": 0,
  "exposure": 0,
  "highlight": 0,
  "shadow": 0,
  "faceSlim": 0.2,
  "faceSmall": 0.1,
  "faceVShape": 0.12,
  "jawSlim": 0.08,
  "chinLength": 0.05,
  "eyeSize": 0.18,
  "eyeDistance": 0,
  "eyeYPosition": 0,
  "eyeTailLift": 0.08,
  "noseSlim": 0.12,
  "noseWingSlim": 0.1,
  "noseTipSize": -0.08,
  "noseBridge": 0.12,
  "mouthSize": 0,
  "mouthWidth": 0,
  "smile": 0.08,
  "lipColor": 0.2,
  "filterId": "clean_01",
  "filterIntensity": 0.35
}
```

## 10.2 预设 JSON 示例

```json
{
  "id": "natural_01",
  "name": "自然",
  "version": "1.0.0",
  "parameters": {
    "skinSmoothing": 0.22,
    "skinWhitening": 0.12,
    "skinRosy": 0.08,
    "skinSharpen": 0.08,
    "faceSlim": 0.08,
    "faceSmall": 0.04,
    "faceVShape": 0.04,
    "jawSlim": 0.02,
    "chinLength": 0,
    "eyeSize": 0.06,
    "eyeDistance": 0,
    "eyeYPosition": 0,
    "eyeTailLift": 0.02,
    "noseSlim": 0.04,
    "noseWingSlim": 0.02,
    "noseTipSize": 0,
    "noseBridge": 0.03,
    "mouthSize": 0,
    "mouthWidth": 0,
    "smile": 0.03,
    "lipColor": 0.08,
    "filterId": "clean_01",
    "filterIntensity": 0.2
  }
}
```

---

# 11. 参数版本策略

## 11.1 新增参数

新增参数必须满足：

```text
默认值是无效果状态。
不会破坏旧 JSON 解码。
不会让旧预设效果变化。
必须写入参数表。
必须写入 CHANGELOG。
```

## 11.2 删除参数

不建议删除对外参数。

如果必须废弃：

```swift
@available(*, deprecated, message: "Use xxx instead")
```

## 11.3 参数重命名

原则上禁止重命名。

如果必须重命名：

```text
保留旧字段兼容至少一个大版本。
PresetLoader 做字段映射。
文档标记 deprecated。
```

---

# 12. 参数测试规范

## 12.1 默认值测试

必须测试：

```text
BeautyParameters() 所有参数为无效果状态。
filterId == nil。
filterIntensity == 0。
```

## 12.2 范围测试

必须测试：

```text
传入小于最小值时会 clamp。
传入大于最大值时会 clamp。
双向参数不会被错误 clamp 到 0...1。
```

## 12.3 Codable 测试

必须测试：

```text
BeautyParameters 可以 encode。
BeautyParameters 可以 decode。
缺失字段可以使用默认值，或通过 PresetLoader 兼容。
旧版本 preset 可以加载。
```

## 12.4 效果关闭测试

必须测试：

```text
所有参数为 0 时，输出应等于或近似等于输入。
单个参数为 0 时，对应 Effect 不应产生副作用。
filterIntensity 为 0 时，即使 filterId 存在也不应改变图像。
```

---

# 13. 第一版参数实现优先级

## P0：必须实现

```text
skinSmoothing
skinWhitening
skinRosy
skinSharpen
faceSlim
faceSmall
faceVShape
chinLength
eyeSize
eyeDistance
noseSlim
mouthSize
smile
filterId
filterIntensity
```

## P1：建议 1.0 实现

```text
jawSlim
eyeYPosition
eyeTailLift
noseWingSlim
noseTipSize
noseBridge
mouthWidth
lipColor
```

## P2：1.5 以后实现

```text
eyeWidth
eyeHeight
innerEyeCorner
outerEyeCorner
cheekboneSlim
upperLipThickness
lowerLipThickness
eyebrowYPosition
teethWhitening
```

## P3：2.0 以后实现

```text
完整妆容
高级皮肤
祛痘
法令纹
背景分割
身体美型
```

---

# 14. 第一版参数最终建议

第一版 `BeautyParameters` 不要太大，但要能覆盖核心体验。

最终建议 1.0 包含 31 个字段：

```text
skinSmoothing
skinWhitening
skinRosy
skinSharpen
brightness
contrast
saturation
temperature
tint
exposure
highlight
shadow

faceSlim
faceSmall
faceVShape
jawSlim
chinLength

eyeSize
eyeDistance
eyeYPosition
eyeTailLift

noseSlim
noseWingSlim
noseTipSize
noseBridge

mouthSize
mouthWidth
smile
lipColor

filterId
filterIntensity
```

这些参数足够支撑：

```text
基础美颜
基础脸型
基础眼睛
基础鼻子
基础嘴巴
基础滤镜
基础预设
```

后续高级功能不要一开始塞进 1.0 参数模型，避免 API 过早膨胀。

---

# 15. 一句话结论

第一版 BeautyParameters 的目标不是覆盖所有幻想功能，而是稳定支撑一个可实时运行、可预设、可扩展的美颜 SDK MVP。

```text
参数少一点，但每个参数都要稳定、可解释、可测试、可扩展。
```
