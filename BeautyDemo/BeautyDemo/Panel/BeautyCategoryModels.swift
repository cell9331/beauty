import Foundation

struct BeautyAvailability: Equatable, Sendable {
    let isEnabled: Bool
    let badge: String?
    let reason: String?

    static let available = BeautyAvailability(
        isEnabled: true,
        badge: nil,
        reason: nil
    )

    static func disabled(badge: String, reason: String) -> BeautyAvailability {
        BeautyAvailability(
            isEnabled: false,
            badge: badge,
            reason: reason
        )
    }

    static let futureResourceSupport = BeautyAvailability.disabled(
        badge: "Not in v1",
        reason: "This control is not included in v1."
    )

    static let resourceUnavailable = BeautyAvailability.disabled(
        badge: "Unavailable",
        reason: "This resource is unavailable in this build."
    )
}

enum BeautyPanelKind: String, Equatable, Sendable {
    case controls
    case facialFeatures
    case disabled
}

enum BeautyCategoryID: String, CaseIterable, Hashable, Sendable {
    case beauty
    case faceShape
    case facialFeatures
    case makeup
    case filters
    case stickers
    case background
    case style
}

struct BeautyCategory: Identifiable, Equatable, Sendable {
    let id: BeautyCategoryID
    let title: String
    let availability: BeautyAvailability
    let panelKind: BeautyPanelKind
}

extension BeautyCategory {
    static let all: [BeautyCategory] = [
        BeautyCategory(
            id: .beauty,
            title: "Beauty",
            availability: .available,
            panelKind: .controls
        ),
        BeautyCategory(
            id: .faceShape,
            title: "Face Shape",
            availability: .available,
            panelKind: .controls
        ),
        BeautyCategory(
            id: .facialFeatures,
            title: "Facial Features",
            availability: .available,
            panelKind: .facialFeatures
        ),
        BeautyCategory(
            id: .makeup,
            title: "Makeup",
            availability: .disabled(
                badge: "Not in v1",
                reason: "Makeup templates are not included in v1."
            ),
            panelKind: .disabled
        ),
        BeautyCategory(
            id: .filters,
            title: "Filters",
            availability: .available,
            panelKind: .controls
        ),
        BeautyCategory(
            id: .stickers,
            title: "Stickers",
            availability: .disabled(
                badge: "Not in v1",
                reason: "Sticker effects are not included in v1."
            ),
            panelKind: .disabled
        ),
        BeautyCategory(
            id: .background,
            title: "Background",
            availability: .disabled(
                badge: "Not in v1",
                reason: "Background editing is not included in v1."
            ),
            panelKind: .disabled
        ),
        BeautyCategory(
            id: .style,
            title: "Style",
            availability: .disabled(
                badge: "Not in v1",
                reason: "Style templates are not included in v1."
            ),
            panelKind: .disabled
        )
    ]

    static func category(id: BeautyCategoryID) -> BeautyCategory {
        all.first { $0.id == id }!
    }
}

enum FacialFeatureSubcategoryID: String, CaseIterable, Hashable, Sendable {
    case eyes
    case nose
    case mouth
    case eyebrows
    case teeth
    case hairline
}

struct FacialFeatureSubcategory: Identifiable, Equatable, Sendable {
    let id: FacialFeatureSubcategoryID
    let title: String
    let availability: BeautyAvailability
}

extension FacialFeatureSubcategory {
    static let all: [FacialFeatureSubcategory] = [
        FacialFeatureSubcategory(
            id: .eyes,
            title: "Eyes",
            availability: .available
        ),
        FacialFeatureSubcategory(
            id: .nose,
            title: "Nose",
            availability: .available
        ),
        FacialFeatureSubcategory(
            id: .mouth,
            title: "Mouth",
            availability: .available
        ),
        FacialFeatureSubcategory(
            id: .eyebrows,
            title: "Eyebrows",
            availability: .disabled(
                badge: "Not in v1",
                reason: "Eyebrow controls are not included in v1."
            )
        ),
        FacialFeatureSubcategory(
            id: .teeth,
            title: "Teeth",
            availability: .disabled(
                badge: "Not in v1",
                reason: "Teeth whitening is not included in v1."
            )
        ),
        FacialFeatureSubcategory(
            id: .hairline,
            title: "Hairline",
            availability: .disabled(
                badge: "Not in v1",
                reason: "Hairline controls are not included in v1."
            )
        )
    ]

    static func subcategory(id: FacialFeatureSubcategoryID) -> FacialFeatureSubcategory {
        all.first { $0.id == id }!
    }
}
