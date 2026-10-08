# 人脸解析模型转 Core ML 与评估方案

> 说明：本文在无网络、无 Xcode 的环境中撰写，脚本和代码**没有实际运行过**。请在 macOS 上执行，并以第 5 节的一致性对比作为转换是否可信的依据。

## 1. 目标与结论

- **目标**：把预训练人脸解析模型（BiSeNet，来自 face-parsing.PyTorch）转成 Core ML，为磨皮/锐化提供皮肤、唇、五官等区域的蒙版。
- **转换和评估不需要训练。**
- **预期结果**：现成模型有皮肤、唇、眉、眼、鼻等类别，但没有“贴片”类别，所以它大概率会把贴片当成皮肤。本阶段要验证的是：五官和完整唇缘的保护是否够用。贴片识别留到第 8 节（合成数据微调）。

## 2. 环境准备

- macOS 13 以上，Xcode 15 以上。
- Python 3.10 或 3.11，建议用虚拟环境：

```
python -m venv .venv
source .venv/bin/activate
pip install torch torchvision coremltools pillow numpy
```

注意：coremltools 对 torch 版本有支持范围。如果转换时出现版本警告或报错，按提示换一个受支持的 torch 版本。

## 3. 获取代码和权重

1. 克隆 `zllrunning/face-parsing.PyTorch`（代码为 MIT 许可）。
2. 按仓库 README 下载预训练权重 `79999_iter.pth`，放到 `res/cp/` 目录。
3. 下面的脚本都放在仓库根目录，与 `model.py` 同级。

## 4. 转换脚本 `convert_face_parsing.py`

要点：

- 把 ImageNet 归一化放进模型内部，这样 Core ML 的输入只需要 0\~1 的 RGB 图像（`scale=1/255`）。
- 该仓库的 BiSeNet 前向返回 3 个输出，只取第一个。
- 输出做 softmax，得到每类概率，Swift 侧既可以取 argmax，也可以直接用概率做软蒙版。

```
import torch
import coremltools as ct
from model import BiSeNet


class Wrapper(torch.nn.Module):
    def __init__(self, net):
        super().__init__()
        self.net = net
        self.register_buffer('mean', torch.tensor([0.485, 0.456, 0.406]).view(1, 3, 1, 1))
        self.register_buffer('std', torch.tensor([0.229, 0.224, 0.225]).view(1, 3, 1, 1))

    def forward(self, x):
        # x: 0~1 的 RGB，形状 1x3x512x512
        logits = self.net((x - self.mean) / self.std)[0]
        return torch.softmax(logits, dim=1)   # 1x19x512x512


def load_wrapper(weights='res/cp/79999_iter.pth'):
    net = BiSeNet(n_classes=19)
    net.load_state_dict(torch.load(weights, map_location='cpu'))
    net.eval()
    return Wrapper(net).eval()


def main():
    model = load_wrapper()
    example = torch.rand(1, 3, 512, 512)
    traced = torch.jit.trace(model, example)
    mlmodel = ct.convert(
        traced,
        inputs=[ct.ImageType(name='image', shape=example.shape,
                             scale=1 / 255.0, color_layout=ct.colorlayout.RGB)],
        outputs=[ct.TensorType(name='probs')],
        convert_to='mlprogram',
        compute_precision=ct.precision.FLOAT16,
        minimum_deployment_target=ct.target.iOS16,
    )
    mlmodel.save('FaceParsing.mlpackage')
    print('saved FaceParsing.mlpackage')


if __name__ == '__main__':
    main()
```

运行：`python convert_face_parsing.py`。

## 5. 一致性验证脚本 `verify_coreml.py`

这一步用来确认转换没有出错（常见错误是归一化、通道顺序或输出选错）。同一张图分别跑 PyTorch 和 Core ML，对比逐像素的类别图。**只能在 macOS 上运行**，因为 `predict` 依赖 Core ML 运行时。

```
import sys
import numpy as np
import torch
import coremltools as ct
from PIL import Image
from convert_face_parsing import load_wrapper


def main(path):
    img = Image.open(path).convert('RGB').resize((512, 512), Image.BILINEAR)
    x = torch.from_numpy(np.asarray(img)).permute(2, 0, 1).float().unsqueeze(0) / 255.0

    wrapper = load_wrapper()
    with torch.no_grad():
        ref = wrapper(x).numpy()[0]          # 19x512x512

    ml = ct.models.MLModel('FaceParsing.mlpackage')
    out = np.array(ml.predict({'image': img})['probs'])[0]   # 19x512x512

    a = ref.argmax(0)
    b = out.argmax(0)
    print('overall pixel agreement: %.4f' % (a == b).mean())
    for c in range(19):
        inter = np.logical_and(a == c, b == c).sum()
        union = np.logical_or(a == c, b == c).sum()
        if union > 0:
            print('class %2d IoU: %.4f' % (c, inter / union))


if __name__ == '__main__':
    main(sys.argv[1])
```

运行：`python verify_coreml.py face.jpg`。

**判断标准（经验值，不是定律）**：整体一致率应在 99% 左右，皮肤、唇、眼等主要类别的 IoU 应在 0.95 以上。如果明显偏低，先检查归一化和通道顺序，再检查是否取错了输出。FP16 带来的少量边缘像素差异是正常的。

## 6. 类别编号

| 编号 | 类别 | 编号 | 类别 |
| --- | --- | --- | --- |
| 0 | 背景 | 10 | 鼻 |
| 1 | 皮肤 | 11 | 口腔 |
| 2 | 左眉 | 12 | 上唇 |
| 3 | 右眉 | 13 | 下唇 |
| 4 | 左眼 | 14 | 脖子 |
| 5 | 右眼 | 15 | 项链 |
| 6 | 眼镜 | 16 | 衣服 |
| 7 | 左耳 | 17 | 头发 |
| 8 | 右耳 | 18 | 帽子 |
| 9 | 耳环 |  |  |

左右按模型定义，不要依赖它判断被摄者的真实左右。建议的映射：

- **可处理的皮肤**：类别 1。
- **必须保护的五官**：2、3、4、5、6、10、11、12、13。
- **保护链路的“物体 + 完整唇并集蒙版”**：把 12、13（必要时加 11）并入你们已验证的宿主蒙版。

## 7. Swift 接入骨架

把 `FaceParsing.mlpackage` 拖进 Xcode，Xcode 会自动生成 `FaceParsing` 类。下面是骨架，**未经编译验证**，仅表达流程：先用 Vision 检测人脸，按人脸框外扩裁成正方形，送入模型，再把类别图映射回原图。

```
import Vision
import CoreML
import CoreImage

enum FaceLabel: Int {
    case background = 0, skin, lBrow, rBrow, lEye, rEye, eyeGlasses
    case lEar, rEar, earring, nose, mouth, upperLip, lowerLip
    case neck, necklace, cloth, hair, hat
}

enum FaceParseError: Error { case crop, output }

final class FaceParser {
    static let side = 512
    private let vnModel: VNCoreMLModel

    init() throws {
        let cfg = MLModelConfiguration()
        cfg.computeUnits = .all
        vnModel = try VNCoreMLModel(for: FaceParsing(configuration: cfg).model)
    }

    /// faceRect：像素坐标，左上角为原点。
    /// 返回 512x512 的类别图，以及它对应在原图中的裁剪区域。
    func labels(for image: CGImage, faceRect: CGRect) throws -> (labels: [UInt8], crop: CGRect) {
        let side = max(faceRect.width, faceRect.height) * 1.4
        var crop = CGRect(x: faceRect.midX - side / 2, y: faceRect.midY - side / 2,
                          width: side, height: side).integral
        // 注意：越界时应先补边再裁剪，否则 scaleFill 会拉伸变形。这里仅做简单截断。
        crop = crop.intersection(CGRect(x: 0, y: 0, width: image.width, height: image.height))
        guard let cropped = image.cropping(to: crop) else { throw FaceParseError.crop }

        let request = VNCoreMLRequest(model: vnModel)
        request.imageCropAndScaleOption = .scaleFill
        try VNImageRequestHandler(cgImage: cropped).perform([request])

        guard let obs = request.results?.first as? VNCoreMLFeatureValueObservation,
              let arr = obs.featureValue.multiArrayValue else { throw FaceParseError.output }

        let n = FaceParser.side
        let classes = 19
        var result = [UInt8](repeating: 0, count: n * n)
        let s = arr.strides.map { $0.intValue }   // [1, 19, 512, 512] 对应的步长

        if arr.dataType == .float32 {
            let p = arr.dataPointer.bindMemory(to: Float.self, capacity: arr.count)
            for y in 0..<n {
                for x in 0..<n {
                    var best = 0
                    var bestV = -Float.infinity
                    for c in 0..<classes {
                        let v = p[c * s[1] + y * s[2] + x * s[3]]
                        if v > bestV { bestV = v; best = c }
                    }
                    result[y * n + x] = UInt8(best)
                }
            }
        } else {
            // FP16 等其他类型：先用慢速路径保证正确，后续再优化
            for y in 0..<n {
                for x in 0..<n {
                    var best = 0
                    var bestV = -Float.infinity
                    for c in 0..<classes {
                        let v = arr[[0, c, y, x] as [NSNumber]].floatValue
                        if v > bestV { bestV = v; best = c }
                    }
                    result[y * n + x] = UInt8(best)
                }
            }
        }
        return (result, crop)
    }
}
```

后续要做软蒙版时，直接保留某几类概率之和即可，不必只用 argmax。

## 8. 在 30 个 SEG 冻结案例上评估

我没有看到仓库里 G0 案例和验收器的具体格式，所以这里只给评估设计，按你们已有的验收器接入。**原则：沿用冻结的输入和判据，不移动任何标准。**

| 检查项 | 做法 | 说明 |
| --- | --- | --- |
| 五官保护 | 模型预测的眉、眼、鼻、唇与冻结关键区对比，算 IoU / 漏掉的像素数 | 判断能否替代“粗略五官守卫” |
| 完整唇缘 | 单独看 12、13 类是否覆盖冻结的完整唇区域 | 这是之前周期候选的失败点 |
| 正常皮肤覆盖 | 类别 1 与固定皮肤评估区的重合比例 | 对应“至少 50% 仍可处理” |
| 贴片像素 | 统计贴片区域被判为皮肤的比例 | **预期很高**，这是第二阶段的动机，不算本阶段失败 |
| 尺度一致性 | 同一案例 512 / 1024 两档的类别图对比 | 之前贴片闭合边界在缩小后会断裂 |
| 肤色分层 | 深、中、浅肤色分别统计上面各项 | 之前中肤色没有成功例 |

**决策规则**（本阶段开始前先定下来）：

- 五官、唇的保护达标，且正常皮肤覆盖稳定 → 采用该模型作为保护蒙版来源，进入第二阶段处理贴片。
- 五官或唇仍大面积漏掉 → 先分析原因（裁剪外扩比例、尺度、肤色偏差），再决定是否换模型，不要先放宽阈值。

用开发集诊断，留出集只用于最后一次判定，沿用你们已有的纪律。

## 9. 第二阶段：合成贴片微调（仅在第 8 节显示需要时再做）

1. **数据**：用有授权的人脸图，按肤色（深、中、浅）均衡采样。用第 8 节的解析结果限定“脸颊皮肤区域”，在其中合成贴片。
2. **合成方法**：
   - 贴片颜色取自周围皮肤，再叠加随机的色差、纹理、哑光程度。
   - 边缘锐度、形状、大小随机变化。
   - 贴片真值蒙版随合成自动得到。
   - 一部分样本不加贴片，作为正常皮肤负例，防止模型把一切都判成贴片。
3. **训练方式**：冻结主干，只微调最后的分类层，类别从 19 扩成 20（新增“贴片”）。数据量不大时，Mac 或免费云 GPU 就够。
4. **划分**：按源图家族切分开发集和留出集，同一张源图的变体不能跨集。这样才能真实反映泛化，而不是记住了某个家族。
5. **导出**：沿用第 4 节的转换流程，并用第 5 节的方法再做一次一致性验证。
6. **评估口径不变**：仍是 30 个冻结案例的判据（物体 95% 以上像素源精确、包络外不改动、固定皮肤区 50% 以上仍可处理、肤色分层）。

注意：合成贴片和真实贴片之间有分布差距。验收必须在你们冻结的真实风格输入上做，不能只看合成验证集的分数。

## 10. 风险与许可

- **许可**：代码为 MIT；权重使用 CelebAMask-HQ 训练，该数据集偏非商业研究用途。你们是所有者自用，但建议在记录里写明来源和用途限制。
- **贴片这类“新类别”无法靠现成模型获得**，只能微调或改成点选/笔刷式半自动。
- **分辨率**：模型输入是 512，裁剪外扩比例会影响细唇缘的质量，需要在评估中调这个参数，而不是调阈值。
- **FP16**：边缘像素有轻微差异，用第 5 节确认可接受；若影响保护边界，可改用 FLOAT32 转换再对比。
- **越界裁剪**：人脸靠近图像边缘时要补边，否则会变形。
- **验收口径**：测试执行成功不等于效果合格，转换成功也不等于分割可用。

## 11. 检查清单

- [ ] 环境搭好，能 `import torch, coremltools`
- [ ] 权重放入 `res/cp/79999_iter.pth`
- [ ] 运行 `convert_face_parsing.py` 得到 `FaceParsing.mlpackage`
- [ ] 用 3 张以上不同肤色的图跑 `verify_coreml.py`，一致率与 IoU 达标
- [ ] 拖入 Xcode，用 Swift 骨架跑通一张图并可视化类别图
- [ ] 在 30 个冻结案例上按第 8 节出表格（先开发集）
- [ ] 按决策规则判断是否进入第二阶段
- [ ] 记录许可与来源
