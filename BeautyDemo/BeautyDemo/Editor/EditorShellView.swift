import BeautySDK
import SwiftUI

struct EditorShellView: View {
    @StateObject private var parameterStore = BeautyParameterStore()
    @State private var selectedCategoryID: BeautyCategoryID = .beauty
    @State private var selectedSubcategoryID: FacialFeatureSubcategoryID = .eyes

    var body: some View {
        VStack(spacing: 16) {
            modeHeader
            previewFixture
            BeautyPanelView(
                selectedCategoryID: selectedCategoryID,
                selectedSubcategoryID: $selectedSubcategoryID,
                parameterStore: parameterStore
            )
            BeautyCategoryRailView(selectedCategoryID: $selectedCategoryID)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 247 / 255, green: 248 / 255, blue: 250 / 255))
    }

    private var modeHeader: some View {
        HStack(spacing: 8) {
            ForEach(DemoFixtures.disabledModes) { mode in
                BeautyModeEntryView(mode: mode)
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
}

#Preview {
    EditorShellView()
}
