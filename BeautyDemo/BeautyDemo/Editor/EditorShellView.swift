import BeautySDK
import SwiftUI

struct EditorShellView: View {
    @State private var parameters = BeautyParameters()

    var body: some View {
        VStack(spacing: 16) {
            modeHeader
            previewFixture
            parameterPanel
            categoryRail
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 247 / 255, green: 248 / 255, blue: 250 / 255))
    }

    private var modeHeader: some View {
        HStack(spacing: 8) {
            ForEach(DemoFixtures.disabledModes) { mode in
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
                .accessibilityHint(mode.badge)
            }
        }
    }

    private var previewFixture: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)

            VStack(spacing: 16) {
                portraitGlyph

                VStack(spacing: 8) {
                    Text(DemoFixtures.previewTitle)
                        .font(.system(size: 28, weight: .semibold))
                    Text(DemoFixtures.previewBody)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 320)
        .accessibilityElement(children: .combine)
    }

    private var portraitGlyph: some View {
        ZStack {
            Circle()
                .fill(Color(red: 238 / 255, green: 243 / 255, blue: 255 / 255))
                .frame(width: 132, height: 132)

            Circle()
                .fill(Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255).opacity(0.16))
                .frame(width: 72, height: 72)
                .offset(y: -24)

            Capsule()
                .fill(Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255).opacity(0.14))
                .frame(width: 96, height: 56)
                .offset(y: 40)
        }
        .accessibilityHidden(true)
    }

    private var parameterPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(DemoFixtures.activeCategoryTitle)
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Text("Apply Parameters")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255))
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255))
                    .frame(width: 8, height: 8)
                Text("Parameters applied")
                    .font(.system(size: 13))
                Text(DemoFixtures.visualPendingStatus)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Text("Default SDK snapshot: \(parameters.skinSmoothing, specifier: "%.0f")")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var categoryRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["Beauty", "Face Shape", "Facial Features", "Makeup", "Filters", "Stickers", "Background", "Style"], id: \.self) { category in
                    Text(category)
                        .font(.system(size: 13, weight: category == DemoFixtures.activeCategoryTitle ? .semibold : .regular))
                        .foregroundStyle(category == DemoFixtures.activeCategoryTitle ? Color.white : Color.primary)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .background(category == DemoFixtures.activeCategoryTitle ? Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityAddTraits(category == DemoFixtures.activeCategoryTitle ? .isSelected : [])
                }
            }
        }
    }
}

#Preview {
    EditorShellView()
}
