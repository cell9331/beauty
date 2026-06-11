import SwiftUI

struct BeautyModeEntryView: View {
    let mode: DisabledMode

    var body: some View {
        Button {
        } label: {
            HStack(spacing: 8) {
                Image(systemName: mode.title == "Camera" ? "camera" : "photo")
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.title)
                        .font(.system(size: 16, weight: .semibold))
                    Text(mode.badge)
                        .font(.system(size: 13))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .disabled(true)
        .accessibilityLabel(mode.title)
        .accessibilityHint(mode.badge)
    }
}

