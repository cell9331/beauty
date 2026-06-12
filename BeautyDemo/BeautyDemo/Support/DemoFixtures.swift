import Foundation

enum DemoFixtures {
    static let previewTitle = "Choose Camera or Photo"
    static let previewBody = "Use Camera for live preview, or Photo to process a local image on this device."
    static let activeCategoryTitle = "Beauty"
    static let visualPendingStatus = "Visual update pending Phase 6"

    static func inputModeItems(selectedMode: EditorInputMode?) -> [BeautyModeItem] {
        EditorInputMode.allCases.map { mode in
            BeautyModeItem(
                id: mode,
                title: mode.title,
                systemImageName: mode.systemImageName,
                isSelected: mode == selectedMode,
                isEnabled: true,
                accessibilityHint: mode.accessibilityHint
            )
        }
    }
}

enum EditorInputMode: String, CaseIterable, Identifiable, Equatable, Sendable {
    case camera
    case photo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .camera:
            return "Camera"
        case .photo:
            return "Photo"
        }
    }

    var systemImageName: String {
        switch self {
        case .camera:
            return "camera"
        case .photo:
            return "photo"
        }
    }

    var accessibilityHint: String {
        switch self {
        case .camera:
            return "Preview processing with the camera on this device."
        case .photo:
            return "Choose a local photo to process on this device."
        }
    }
}

struct BeautyModeItem: Identifiable, Equatable {
    let id: EditorInputMode
    let title: String
    let systemImageName: String
    let isSelected: Bool
    let isEnabled: Bool
    let accessibilityHint: String
}
