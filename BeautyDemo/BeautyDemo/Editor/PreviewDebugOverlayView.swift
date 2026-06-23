import SwiftUI

struct PreviewDebugOverlayView: View {
    static let emptyStateText = "Debug details are unavailable for this preview."

    let state: PreviewDebugOverlayState?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let state {
                ForEach(state.rows) { row in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(row.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(red: 32 / 255, green: 47 / 255, blue: 77 / 255))
                            .frame(width: 76, alignment: .leading)

                        Text(row.value)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(red: 32 / 255, green: 47 / 255, blue: 77 / 255))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(row.label): \(row.value)")
                }
            } else {
                Text(Self.emptyStateText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 32 / 255, green: 47 / 255, blue: 77 / 255))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(Self.emptyStateText)
            }
        }
        .padding(16)
        .frame(maxWidth: 320, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.94))
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
        )
    }
}

extension PreviewDebugOverlayState.Row: Identifiable {
    var id: String {
        label
    }
}
