import Foundation

enum MeituEditorCategoryID: String, CaseIterable, Hashable, Sendable {
    case threeDShape
    case proportion
    case faceShape
    case eyes
    case lips
    case nose
    case eyebrows
}

enum MeituEditorToolBadge: String, Equatable, Sendable {
    case free = "限免"
    case pro = "Pro"
    case off = "OFF"
}

struct MeituEditorCategory: Identifiable, Equatable, Sendable {
    let id: MeituEditorCategoryID
    let title: String
    let tools: [MeituEditorTool]
}

struct MeituEditorTool: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let systemImageName: String
    let badge: MeituEditorToolBadge?
    let controlID: BeautyControlID?
    let unavailableReason: String?

    var isSupported: Bool {
        controlID != nil
    }
}

struct MeituEditorToolPanelState: Equatable, Sendable {
    let categories: [MeituEditorCategory]
    let selectedCategory: MeituEditorCategory
    let selectedTool: MeituEditorTool
    let selectedValue: Double
    let sliderRange: BeautyDisplayRange
    let compareTitle: String
    let debugTitle: String
    let backgroundProtectionTitle: String
    let wholeTitle: String
}

extension MeituEditorCategory {
    static let all: [MeituEditorCategory] = [
        MeituEditorCategory(
            id: .threeDShape,
            title: "3D塑颜",
            tools: [
                unsupported("threeD.symmetry", title: "对称", icon: "face.smiling", badge: .free),
                unsupported("threeD.upDown", title: "上下", icon: "arrow.up.and.down"),
                unsupported("threeD.leftRight", title: "左右", icon: "arrow.left.and.right"),
                unsupported("threeD.tilt", title: "倾斜", icon: "arrow.triangle.2.circlepath")
            ]
        ),
        MeituEditorCategory(
            id: .proportion,
            title: "比例",
            tools: [
                supported("proportion.smallHead", title: "小头", icon: "person.crop.circle", controlID: .faceSmall),
                unsupported("proportion.headFace", title: "头包脸", icon: "person.crop.square"),
                unsupported("proportion.skullTop", title: "颅顶", icon: "arrow.up.to.line"),
                unsupported("proportion.forehead", title: "额头", icon: "rectangle.topthird.inset.filled"),
                unsupported("proportion.midFace", title: "中庭", icon: "rectangle.center.inset.filled"),
                unsupported("proportion.philtrum", title: "人中", icon: "line.diagonal"),
                unsupported("proportion.lowerFace", title: "下庭", icon: "rectangle.bottomthird.inset.filled"),
                unsupported("proportion.shortFace", title: "短脸", icon: "arrow.down.to.line")
            ]
        ),
        MeituEditorCategory(
            id: .faceShape,
            title: "脸型",
            tools: [
                supported("face.width", title: "脸宽", icon: "oval", controlID: .faceSlim),
                supported("face.small", title: "小脸", icon: "person.crop.circle", controlID: .faceSmall),
                unsupported("face.smooth", title: "面部流畅", icon: "circle.dashed"),
                unsupported("face.temple", title: "太阳穴", icon: "circle.lefthalf.filled"),
                unsupported("face.cheekbone", title: "颧骨", icon: "circle.grid.cross"),
                supported("face.chinLength", title: "下巴长短", icon: "arrow.up.and.down", controlID: .chinLength),
                unsupported("face.doubleChin", title: "去双下巴", icon: "person.crop.circle.badge.minus"),
                unsupported("face.doubleChinPro", title: "去双下巴", icon: "person.crop.circle.badge.minus", badge: .pro),
                unsupported("face.pointedChin", title: "尖下巴", icon: "triangle"),
                supported("face.vShape", title: "V脸", icon: "chevron.down", controlID: .faceVShape),
                supported("face.jawAngle", title: "下颌角", icon: "angle", controlID: .jawSlim),
                supported("face.jawLine", title: "下颌线", icon: "line.diagonal", controlID: .jawSlim),
                unsupported("face.hairline", title: "发际线", icon: "person.crop.rectangle")
            ]
        ),
        MeituEditorCategory(
            id: .eyes,
            title: "眼睛",
            tools: [
                supported("eyes.size", title: "大小", icon: "eye", controlID: .eyeSize),
                supported("eyes.upDown", title: "上下", icon: "arrow.up.and.down", controlID: .eyeYPosition),
                unsupported("eyes.height", title: "眼高", icon: "arrow.up.to.line"),
                unsupported("eyes.length", title: "长度", icon: "arrow.left.and.right"),
                supported("eyes.distance", title: "眼距", icon: "arrow.left.and.right.circle", controlID: .eyeDistance),
                unsupported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free),
                unsupported("eyes.liftMuscle", title: "提肌", icon: "arrow.up.circle"),
                unsupported("eyes.pupil", title: "眼瞳大小", icon: "circle.circle"),
                unsupported("eyes.gaze", title: "眼神矫正", icon: "scope"),
                unsupported("eyes.lowerLid", title: "眼睑下至", icon: "arrow.down.circle"),
                supported("eyes.tailLift", title: "眼尾上扬", icon: "arrow.up.right", controlID: .eyeTailLift),
                unsupported("eyes.tilt", title: "倾斜", icon: "arrow.triangle.2.circlepath"),
                unsupported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free),
                unsupported("eyes.innerCorner", title: "内眼角", icon: "lessthan"),
                unsupported("eyes.outerCorner", title: "外眼角", icon: "greaterthan"),
                unsupported("eyes.symmetry", title: "对称", icon: "square.split.2x1")
            ]
        ),
        MeituEditorCategory(
            id: .lips,
            title: "嘴唇",
            tools: [
                supported("lips.size", title: "大小", icon: "mouth", controlID: .mouthSize),
                supported("lips.width", title: "宽度", icon: "arrow.left.and.right", controlID: .mouthWidth),
                unsupported("lips.upDown", title: "上下", icon: "arrow.up.and.down"),
                unsupported("lips.tilt", title: "倾斜", icon: "arrow.triangle.2.circlepath"),
                unsupported("lips.leftRight", title: "左右", icon: "arrow.left.and.right.circle"),
                unsupported("lips.mShape", title: "M唇", icon: "mustache", badge: .free),
                supported("lips.full", title: "丰唇", icon: "mouth", controlID: .lipColor),
                supported("lips.smile", title: "微笑", icon: "face.smiling", controlID: .smile),
                unsupported("lips.teeth", title: "白牙", icon: "sparkles")
            ]
        ),
        MeituEditorCategory(
            id: .nose,
            title: "鼻子",
            tools: [
                supported("nose.size", title: "大小", icon: "triangle", controlID: .noseSlim),
                unsupported("nose.lift", title: "提升", icon: "arrow.up"),
                supported("nose.wing", title: "鼻翼", icon: "arrow.left.and.right", controlID: .noseWingSlim),
                supported("nose.root", title: "山根", icon: "line.diagonal", controlID: .noseBridge),
                supported("nose.bridge", title: "鼻梁", icon: "rectangle.portrait", controlID: .noseBridge),
                supported("nose.tip", title: "鼻尖", icon: "circle", controlID: .noseTipSize)
            ]
        ),
        MeituEditorCategory(
            id: .eyebrows,
            title: "眉毛",
            tools: [
                unsupported("brows.upDown", title: "上下", icon: "arrow.up.and.down", badge: .off),
                unsupported("brows.thickness", title: "粗细", icon: "lineweight"),
                unsupported("brows.length", title: "长短", icon: "arrow.left.and.right"),
                unsupported("brows.distance", title: "间距", icon: "arrow.left.and.right.circle"),
                unsupported("brows.headDistance", title: "眉头间距", icon: "lessthan.circle"),
                unsupported("brows.tilt", title: "倾斜", icon: "arrow.triangle.2.circlepath"),
                unsupported("brows.peak", title: "眉峰", icon: "chevron.up")
            ]
        )
    ]

    static func category(id: MeituEditorCategoryID) -> MeituEditorCategory {
        all.first { $0.id == id }!
    }

    private static func supported(
        _ id: String,
        title: String,
        icon: String,
        badge: MeituEditorToolBadge? = nil,
        controlID: BeautyControlID
    ) -> MeituEditorTool {
        MeituEditorTool(
            id: id,
            title: title,
            systemImageName: icon,
            badge: badge,
            controlID: controlID,
            unavailableReason: nil
        )
    }

    private static func unsupported(
        _ id: String,
        title: String,
        icon: String,
        badge: MeituEditorToolBadge? = nil
    ) -> MeituEditorTool {
        MeituEditorTool(
            id: id,
            title: title,
            systemImageName: icon,
            badge: badge,
            controlID: nil,
            unavailableReason: "v1.1 暂未实现该美图参考功能"
        )
    }
}

extension Array where Element == MeituEditorCategory {
    func category(id: MeituEditorCategoryID) -> MeituEditorCategory {
        first { $0.id == id } ?? MeituEditorCategory.category(id: id)
    }

    func tool(id: String) -> MeituEditorTool? {
        flatMap(\.tools).first { $0.id == id }
    }
}
