import SwiftUI

struct BeautySliderView: View {
    let descriptor: BeautyControlDescriptor
    @ObservedObject var parameterStore: BeautyParameterStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(descriptor.label)
                    .font(.system(size: 16))
                Spacer()
                Text(valueOrBadgeText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(valueOrBadgeColor)
            }

            if descriptor.availability.isEnabled {
                Slider(
                    value: Binding(
                        get: { parameterStore.displayValue(for: descriptor) },
                        set: { parameterStore.setDisplayValue($0, for: descriptor) }
                    ),
                    in: descriptor.displayRange.bounds,
                    step: 1
                )
                .tint(Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255))
                .accessibilityLabel(descriptor.label)
                .accessibilityValue(Self.accessibilityValueText(
                    parameterStore.displayValue(for: descriptor),
                    range: descriptor.displayRange
                ))

                HStack {
                    Text(rangeEndpointText(descriptor.displayRange.bounds.lowerBound))
                    Spacer()
                    Button(descriptor.resetLabel) {
                        parameterStore.reset(descriptor)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel(descriptor.resetLabel)
                    Spacer()
                    Text(rangeEndpointText(descriptor.displayRange.bounds.upperBound))
                }
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            } else if let reason = descriptor.availability.reason {
                Text(reason)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 138 / 255, green: 143 / 255, blue: 152 / 255))
                    .accessibilityHint(descriptor.availability.badge ?? "")
            }
        }
        .padding(12)
        .background(descriptor.availability.isEnabled ? Color(red: 247 / 255, green: 248 / 255, blue: 250 / 255) : Color(red: 238 / 255, green: 240 / 255, blue: 243 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .contain)
    }

    static func displayValueText(_ value: Double, range: BeautyDisplayRange) -> String {
        let roundedValue = Int(value.rounded())

        if range == .bidirectional && roundedValue > 0 {
            return "+\(roundedValue)"
        }

        return "\(roundedValue)"
    }

    static func accessibilityValueText(_ value: Double, range: BeautyDisplayRange) -> String {
        "\(displayValueText(value, range: range)) percent"
    }

    private var valueOrBadgeText: String {
        if descriptor.availability.isEnabled {
            return Self.displayValueText(
                parameterStore.displayValue(for: descriptor),
                range: descriptor.displayRange
            )
        }

        return descriptor.availability.badge ?? "Unavailable"
    }

    private var valueOrBadgeColor: Color {
        descriptor.availability.isEnabled
            ? .secondary
            : Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255)
    }

    private func rangeEndpointText(_ value: Double) -> String {
        Self.displayValueText(value, range: descriptor.displayRange)
    }
}

