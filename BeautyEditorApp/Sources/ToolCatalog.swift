import Foundation
import BeautySDK

// Figma tool order and names, adapted to the current SDK taxonomy.
enum ToolCatalog {
    static let all: [ToolDefinition] = [
        ToolDefinition(id: "face.width", title: "脸宽", category: .face, field: "faceSlim", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "face.size", title: "小脸", category: .face, field: "faceSmall", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "face.contourSmooth", title: "面部流畅", category: .face, field: "faceContourSmooth", range: .unit, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "face.temple", title: "太阳穴", category: .face, field: "templeFullness", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "face.cheekbone", title: "颧骨", category: .face, field: "cheekboneSlim", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "face.chinLength", title: "下巴长短", category: .face, field: "chinLength", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "face.doubleChin", title: "去双下巴", category: .face, field: "doubleChinReduction", range: .unit, promo: false, pro: false, smart: false, note: nil, enabled: false),
        ToolDefinition(id: "face.doubleChinRefine", title: "去双下巴", category: .face, field: "doubleChinReductionPro", range: .unit, promo: true, pro: true, smart: false, note: nil, enabled: false),
        ToolDefinition(id: "face.chinPoint", title: "尖下巴", category: .face, field: "chinTaper", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "face.vShape", title: "V脸", category: .face, field: "faceVShape", range: .unit, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "face.jawAngle", title: "下颌角", category: .face, field: "jawSlim", range: .signed, promo: false, pro: false, smart: false),
        ToolDefinition(id: "face.jawline", title: "下颌线", category: .face, field: "jawlineShadow", range: .unit, promo: false, pro: false, smart: false),
        ToolDefinition(id: "face.hairline", title: "发际线", category: .face, field: "hairlineHeight", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "ratio.headSize", title: "小头", category: .ratio, field: "headSmall", range: .unit, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "ratio.headToFace", title: "头包脸", category: .ratio, field: "headWrap", range: .unit, promo: true, pro: false, smart: false, note: nil),
        ToolDefinition(id: "ratio.cranialTop", title: "颅顶", category: .ratio, field: "cranialCrownHeight", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "ratio.forehead", title: "额头", category: .ratio, field: "foreheadHeight", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "ratio.midface", title: "中庭", category: .ratio, field: "midfaceLength", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "ratio.philtrum", title: "人中", category: .ratio, field: "philtrumLength", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "ratio.lowerFace", title: "下庭", category: .ratio, field: "lowerFaceLength", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "ratio.faceLength", title: "短脸", category: .ratio, field: "faceShortening", range: .unit, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "eye.size", title: "大小", category: .eye, field: "eyeSize", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "eye.positionY", title: "上下", category: .eye, field: "eyeYPosition", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "eye.eyelidSize", title: "眼高", category: .eye, field: "eyeHeight", range: .signed, promo: false, pro: false, smart: false, note: "调整眼睑开合高度；眼瞳大小使用独立工具。"),
        ToolDefinition(id: "eye.length", title: "长度", category: .eye, field: "eyeLength", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "eye.spacing", title: "眼距", category: .eye, field: "eyeDistance", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "eye.fatRemoval", title: "去脂", category: .eye, field: nil, range: .unit, promo: false, pro: false, smart: false, note: "去脂效果尚未通过验收，当前停用。"),
        ToolDefinition(id: "eye.lidLift", title: "提肌", category: .eye, field: "upperEyelidLift", range: .unit, promo: false, pro: false, smart: true, note: "暂未开放。", enabled: false),
        ToolDefinition(id: "eye.irisSize", title: "眼瞳大小", category: .eye, field: "pupilSize", range: .signed, promo: true, pro: false, smart: false, note: "调整可见虹膜区域大小，不改变眼睑开合高度。"),
        ToolDefinition(id: "eye.gazeCorrection", title: "眼神矫正", category: .eye, field: "gazeCorrection", range: .unit, promo: false, pro: false, smart: true, note: "暂未开放。", enabled: false),
        ToolDefinition(id: "eye.lowerLid", title: "眼睑下至", category: .eye, field: "lowerEyelidDrop", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "eye.tailLift", title: "眼尾上扬", category: .eye, field: "eyeTailLift", range: .signed, promo: false, pro: false, smart: false, note: "与「上扬」同步调整。"),
        ToolDefinition(id: "eye.tilt", title: "倾斜", category: .eye, field: "eyeTilt", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "eye.symmetry", title: "对称", category: .eye, field: "eyeSymmetry", range: .unit, promo: false, pro: false, smart: true, note: "暂未开放。", enabled: false),
        ToolDefinition(id: "eye.redness", title: "祛红血丝", category: .eye, field: "scleraRednessReduction", range: .unit, promo: false, pro: false, smart: false, note: "暂未开放。", enabled: false),
        ToolDefinition(id: "eye.innerCorner", title: "内眼角", category: .eye, field: "innerCornerOpen", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "eye.outerCorner", title: "外眼角", category: .eye, field: "outerCornerOpen", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "eye.lift", title: "上扬", category: .eye, field: "eyeTailLift", range: .signed, promo: false, pro: false, smart: false, note: "与「眼尾上扬」同步调整。"),
        ToolDefinition(id: "mouth.size", title: "大小", category: .mouth, field: "mouthSize", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "mouth.width", title: "宽度", category: .mouth, field: "mouthWidth", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "mouth.positionY", title: "上下", category: .mouth, field: "mouthYPosition", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "mouth.tilt", title: "倾斜", category: .mouth, field: "mouthTilt", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "mouth.positionX", title: "左右", category: .mouth, field: "mouthXPosition", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "mouth.mShape", title: "M唇", category: .mouth, field: "lipPeakDefinition", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "mouth.fullness", title: "丰唇", category: .mouth, field: "lipPlump", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "mouth.smile", title: "微笑", category: .mouth, field: "smile", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "mouth.teethWhitening", title: "白牙", category: .mouth, field: "teethWhitening", range: .unit, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "nose.size", title: "大小", category: .nose, field: "noseSlim", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "nose.lift", title: "提升", category: .nose, field: "noseTipLift", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "nose.ala", title: "鼻翼", category: .nose, field: "noseWingSlim", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "nose.root", title: "山根", category: .nose, field: "noseRootNarrowing", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "nose.bridge", title: "鼻梁", category: .nose, field: "noseBridge", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "nose.tip", title: "鼻尖", category: .nose, field: "noseTipSize", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "brow.thickness", title: "粗细", category: .brow, field: "eyebrowThickness", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "brow.length", title: "长短", category: .brow, field: "eyebrowLength", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "brow.spacing", title: "间距", category: .brow, field: "eyebrowSpacing", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "brow.innerSpacing", title: "眉头间距", category: .brow, field: "eyebrowHeadSpacing", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "brow.tilt", title: "倾斜", category: .brow, field: "eyebrowTilt", range: .signed, promo: false, pro: false, smart: false, note: nil),
        ToolDefinition(id: "brow.peak", title: "眉峰", category: .brow, field: "eyebrowPeakDefinition", range: .unit, promo: false, pro: false, smart: false, note: nil)
    ]
    // These SF Symbols are available before our iOS 17 minimum. Existing
    // design assets remain unchanged; new algorithm controls use native icons.
    static let systemSymbols: [String: String] = [
        "eye.size": "eye",
        "eye.positionY": "arrow.up.and.down",
        "eye.length": "arrow.left.and.right",
        "eye.spacing": "arrow.left.and.right",
        "eye.irisSize": "circle.circle",
    ]
    // Mirrors the SDK resolver's admission caps, checked by check-sdk-bindings.py.
    // 100 on the slider means the admitted maximum rather than an early plateau.
    static let safetyCaps: [String: Float] = [
        "faceSlim": 0.60,
        "faceSmall": 0.45,
        "faceContourSmooth": 0.25,
        "templeFullness": 0.25,
        "cheekboneSlim": 0.25,
        "chinLength": 0.35,
        "doubleChinReduction": 0.25,
        "doubleChinReductionPro": 0.25,
        "chinTaper": 0.25,
        "faceVShape": 0.50,
        "jawSlim": 0.45,
        "jawlineShadow": 0.25,
        "hairlineHeight": 0.25,
        "headSmall": 0.30,
        "headWrap": 0.25,
        "cranialCrownHeight": 0.25,
        "foreheadHeight": 0.30,
        "midfaceLength": 0.30,
        "philtrumLength": 0.30,
        "lowerFaceLength": 0.30,
        "faceShortening": 0.30,
        "eyeSize": 0.45,
        "eyeYPosition": 0.25,
        "eyeLength": 0.35,
        "eyeDistance": 0.30,
        "pupilSize": 0.25,
        "eyeTailLift": 0.30,
        "eyeTilt": 0.25,
        "scleraRednessReduction": 1.0,
        "innerCornerOpen": 0.25,
        "outerCornerOpen": 0.25,
        "eyeSymmetry": 0.25,
        "upperEyelidLift": 0.30,
        "eyeHeight": 0.35,
        "gazeCorrection": 0.25,
        "lowerEyelidDrop": 0.30,
        "mouthSize": 0.35,
        "mouthWidth": 0.35,
        "mouthYPosition": 0.25,
        "mouthTilt": 0.25,
        "mouthXPosition": 0.25,
        "lipPeakDefinition": 0.25,
        "lipPlump": 0.25,
        "smile": 0.50,
        "teethWhitening": 1.0,
        "noseSlim": 0.35,
        "noseTipLift": 0.25,
        "noseWingSlim": 0.35,
        "noseRootNarrowing": 0.25,
        "noseBridge": 0.30,
        "noseTipSize": 0.30,
        "eyebrowThickness": 0.25,
        "eyebrowLength": 0.25,
        "eyebrowSpacing": 0.25,
        "eyebrowHeadSpacing": 0.25,
        "eyebrowTilt": 0.25,
        "eyebrowPeakDefinition": 0.25,
    ]
    static var canonicalTools: [ToolDefinition] {
        var seen = Set<String>()
        return all.filter { tool in
            guard let field = tool.field else { return false }
            return seen.insert(field).inserted
        }
    }
    // Diagnostic request sum only; never a host slider admission budget.
    static func geometryTotal(in parameters: BeautyParameters, excluding field: String? = nil) -> Double {
        canonicalTools.filter { $0.isGeometry && $0.field != field }
            .reduce(0) { $0 + abs(Double($1.sdkValue(in: parameters))) }
    }
    static func tools(in category: BeautyCategory) -> [ToolDefinition] {
        all.filter { $0.category == category }
    }
    static func find(_ id: String) -> ToolDefinition? { all.first { $0.id == id } }
}
