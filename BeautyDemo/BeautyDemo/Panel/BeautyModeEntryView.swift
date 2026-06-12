import SwiftUI

struct BeautyModeEntryView: View {
    let item: BeautyModeItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(.plain)
        .disabled(!item.isEnabled)
        .accessibilityLabel(item.title)
        .accessibilityHint(item.accessibilityHint)
        .accessibilityAddTraits(item.isSelected ? .isSelected : [])
    }

    private var label: some View {
        HStack(spacing: 8) {
            Image(systemName: item.systemImageName)
            Text(item.title)
                .font(.system(size: 16, weight: .semibold))
        }
        .foregroundStyle(foregroundColor)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(backgroundColor)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: item.isSelected ? 1 : 0)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var foregroundColor: Color {
        if item.isSelected {
            return .white
        }

        return item.isEnabled ? .primary : Color(red: 138 / 255, green: 143 / 255, blue: 152 / 255)
    }

    private var backgroundColor: Color {
        if item.isSelected {
            return Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255)
        }

        return item.isEnabled ? .white : Color(red: 238 / 255, green: 240 / 255, blue: 243 / 255)
    }

    private var borderColor: Color {
        item.isSelected ? Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255) : .clear
    }
}
