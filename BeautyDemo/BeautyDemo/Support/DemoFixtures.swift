import Foundation

enum DemoFixtures {
    static let previewTitle = "Preview fixture ready"
    static let previewBody = "Adjust a Beauty slider to update the SDK parameter snapshot. Visual effects arrive in later phases."
    static let activeCategoryTitle = "Beauty"
    static let visualPendingStatus = "Visual update pending Phase 6"

    static let disabledModes: [DisabledMode] = [
        DisabledMode(title: "Camera", badge: "Coming in Phase 3"),
        DisabledMode(title: "Photo", badge: "Coming in Phase 3")
    ]
}

struct DisabledMode: Identifiable, Equatable {
    let title: String
    let badge: String

    var id: String { title }
}
