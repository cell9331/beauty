import Foundation

enum MeituHomeRoute: String, Equatable, Sendable {
    case photoEditor
    case cameraEditor
    case beautyEditor
    case disabled
}

enum MeituHomeActionID: String, CaseIterable, Hashable, Sendable {
    case photoBeautify
    case videoEdit
    case portraitBeauty
    case collage
    case camera
    case videoBeauty
}

enum MeituHomeActionSize: Equatable, Sendable {
    case large
    case small
}

struct MeituHomeAction: Identifiable, Equatable, Sendable {
    let id: MeituHomeActionID
    let title: String
    let systemImageName: String
    let size: MeituHomeActionSize
    let route: MeituHomeRoute

    var isEnabled: Bool {
        route != .disabled
    }
}

struct MeituHomeTool: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let systemImageName: String
    let badge: String?
    let route: MeituHomeRoute

    var isEnabled: Bool {
        route != .disabled
    }
}

struct MeituHomeToolPage: Identifiable, Equatable, Sendable {
    let id: Int
    let tools: [MeituHomeTool]
}

struct MeituHomeRecommendationSection: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let cards: [MeituHomeRecommendationCard]
}

struct MeituHomeRecommendationCard: Identifiable, Equatable, Sendable {
    let id: String
    let palette: MeituHomeCardPalette
}

struct MeituHomeCardPalette: Equatable, Sendable {
    let topHex: UInt32
    let bottomHex: UInt32
}

struct MeituHomeTab: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let isSelected: Bool
    let showsDot: Bool
}

struct MeituHomeHero: Equatable, Sendable {
    let title: String
    let subtitle: String
    let ctaTitle: String
}

struct MeituHomeViewState: Equatable, Sendable {
    let hero: MeituHomeHero
    let primaryActions: [MeituHomeAction]
    let toolPages: [MeituHomeToolPage]
    let recommendations: [MeituHomeRecommendationSection]
    let tabs: [MeituHomeTab]

    var stickyActions: [MeituHomeAction] {
        primaryActions
    }
}

extension MeituHomeViewState {
    static let reference = MeituHomeViewState(
        hero: MeituHomeHero(
            title: "复古胶片相机",
            subtitle: "不去建模 - 拍出氛围感照片",
            ctaTitle: "拍一拍"
        ),
        primaryActions: [
            MeituHomeAction(
                id: .photoBeautify,
                title: "图片美化",
                systemImageName: "wand.and.stars",
                size: .large,
                route: .photoEditor
            ),
            MeituHomeAction(
                id: .videoEdit,
                title: "修视频",
                systemImageName: "movieclapper",
                size: .large,
                route: .disabled
            ),
            MeituHomeAction(
                id: .portraitBeauty,
                title: "人像美容",
                systemImageName: "face.smiling",
                size: .small,
                route: .beautyEditor
            ),
            MeituHomeAction(
                id: .collage,
                title: "拼图",
                systemImageName: "square.grid.2x2",
                size: .small,
                route: .disabled
            ),
            MeituHomeAction(
                id: .camera,
                title: "相机",
                systemImageName: "camera.fill",
                size: .small,
                route: .cameraEditor
            ),
            MeituHomeAction(
                id: .videoBeauty,
                title: "视频美容",
                systemImageName: "person.crop.rectangle",
                size: .small,
                route: .disabled
            )
        ],
        toolPages: [
            MeituHomeToolPage(id: 0, tools: [
                MeituHomeTool(id: "mind.effects", title: "脑洞特效", systemImageName: "brain.head.profile", badge: "New", route: .disabled),
                MeituHomeTool(id: "ai.group", title: "AI合照", systemImageName: "person.2", badge: nil, route: .disabled),
                MeituHomeTool(id: "quality.repair", title: "画质修复", systemImageName: "square.text.square", badge: nil, route: .disabled),
                MeituHomeTool(id: "video.erase", title: "视频消除", systemImageName: "eraser", badge: nil, route: .disabled),
                MeituHomeTool(id: "apple.mode", title: "苹果模式", systemImageName: "camera", badge: nil, route: .disabled),
                MeituHomeTool(id: "ai.edit", title: "AI改图", systemImageName: "bubble.left.and.sparkles", badge: "Agent", route: .disabled),
                MeituHomeTool(id: "collage.seamless", title: "无缝拼图", systemImageName: "rectangle.split.3x1", badge: nil, route: .disabled),
                MeituHomeTool(id: "id.photo", title: "证件照", systemImageName: "person.text.rectangle", badge: "Hot", route: .disabled)
            ]),
            MeituHomeToolPage(id: 1, tools: [
                MeituHomeTool(id: "ai.dance", title: "AI舞蹈", systemImageName: "figure.dance", badge: "AI", route: .disabled),
                MeituHomeTool(id: "creative.play", title: "创意玩法", systemImageName: "sparkles", badge: nil, route: .disabled),
                MeituHomeTool(id: "ai.expand", title: "AI扩图", systemImageName: "arrow.up.left.and.arrow.down.right", badge: "AI", route: .disabled),
                MeituHomeTool(id: "ai.avatar", title: "AI形象照", systemImageName: "person.crop.square", badge: nil, route: .disabled),
                MeituHomeTool(id: "live.edit", title: "修Live", systemImageName: "livephoto", badge: nil, route: .disabled),
                MeituHomeTool(id: "flash", title: "闪光灯", systemImageName: "bolt", badge: nil, route: .disabled),
                MeituHomeTool(id: "batch", title: "批量修图", systemImageName: "rectangle.stack", badge: nil, route: .disabled),
                MeituHomeTool(id: "ai.erase", title: "AI消除", systemImageName: "xmark.bin", badge: "AI", route: .disabled),
                MeituHomeTool(id: "studio", title: "设计室", systemImageName: "paintpalette", badge: nil, route: .disabled),
                MeituHomeTool(id: "transfer", title: "闪传相册", systemImageName: "arrow.left.arrow.right", badge: nil, route: .disabled),
                MeituHomeTool(id: "ai.hair", title: "AI发型", systemImageName: "person.crop.circle", badge: "AI", route: .disabled),
                MeituHomeTool(id: "ai.photo", title: "AI写真", systemImageName: "camera.filters", badge: "AI", route: .disabled)
            ]),
            MeituHomeToolPage(id: 2, tools: [
                MeituHomeTool(id: "smart.cutout", title: "智能抠图", systemImageName: "person.crop.artframe", badge: nil, route: .disabled)
            ])
        ],
        recommendations: [
            MeituHomeRecommendationSection(
                id: "euro.flash",
                title: "欧美闪光滤镜",
                cards: [
                    MeituHomeRecommendationCard(id: "flash.1", palette: MeituHomeCardPalette(topHex: 0x4B3D39, bottomHex: 0xB9836B)),
                    MeituHomeRecommendationCard(id: "flash.2", palette: MeituHomeCardPalette(topHex: 0x2A4858, bottomHex: 0xD1B07D)),
                    MeituHomeRecommendationCard(id: "flash.3", palette: MeituHomeCardPalette(topHex: 0x1E2C2F, bottomHex: 0xB8898A)),
                    MeituHomeRecommendationCard(id: "flash.4", palette: MeituHomeCardPalette(topHex: 0x6D5246, bottomHex: 0xD7B48C))
                ]
            ),
            MeituHomeRecommendationSection(
                id: "hot.play",
                title: "不能错过热门玩法",
                cards: [
                    MeituHomeRecommendationCard(id: "play.1", palette: MeituHomeCardPalette(topHex: 0x33483F, bottomHex: 0xC06973)),
                    MeituHomeRecommendationCard(id: "play.2", palette: MeituHomeCardPalette(topHex: 0x233B59, bottomHex: 0x7C9BC0)),
                    MeituHomeRecommendationCard(id: "play.3", palette: MeituHomeCardPalette(topHex: 0x523A4C, bottomHex: 0xDFA4B3))
                ]
            ),
            MeituHomeRecommendationSection(
                id: "curve.body",
                title: "欧美曲线塑形",
                cards: [
                    MeituHomeRecommendationCard(id: "curve.1", palette: MeituHomeCardPalette(topHex: 0x262F2B, bottomHex: 0xCFA36A)),
                    MeituHomeRecommendationCard(id: "curve.2", palette: MeituHomeCardPalette(topHex: 0x473B4F, bottomHex: 0xBA90D4)),
                    MeituHomeRecommendationCard(id: "curve.3", palette: MeituHomeCardPalette(topHex: 0x2D4357, bottomHex: 0xA4C2D8))
                ]
            ),
            MeituHomeRecommendationSection(
                id: "beauty.daily",
                title: "欧美美容常态",
                cards: [
                    MeituHomeRecommendationCard(id: "daily.1", palette: MeituHomeCardPalette(topHex: 0x3F2C35, bottomHex: 0xD7A4A5)),
                    MeituHomeRecommendationCard(id: "daily.2", palette: MeituHomeCardPalette(topHex: 0x20333D, bottomHex: 0x93B8C7)),
                    MeituHomeRecommendationCard(id: "daily.3", palette: MeituHomeCardPalette(topHex: 0x4B4839, bottomHex: 0xD6D0A4))
                ]
            )
        ],
        tabs: [
            MeituHomeTab(id: "home", title: "首页", isSelected: true, showsDot: false),
            MeituHomeTab(id: "library", title: "图库", isSelected: false, showsDot: false),
            MeituHomeTab(id: "ai", title: "AI 修图", isSelected: false, showsDot: false),
            MeituHomeTab(id: "me", title: "我", isSelected: false, showsDot: true)
        ]
    )
}
