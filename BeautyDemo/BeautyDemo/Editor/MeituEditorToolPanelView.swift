import SwiftUI

struct MeituEditorToolPanelView: View {
    @Binding var selectedCategoryID: MeituEditorCategoryID
    @Binding var selectedToolID: String
    @ObservedObject var parameterStore: BeautyParameterStore
    let compareTitle: String
    let debugTitle: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    private let categories = MeituEditorCategory.all

    var body: some View {
        let state = Self.viewState(
            selectedCategoryID: selectedCategoryID,
            selectedToolID: selectedToolID,
            displayValue: displayValue,
            compareTitle: compareTitle,
            debugTitle: debugTitle
        )

        VStack(spacing: 0) {
            sliderRow(state)
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 12)

            toolRail(state)
                .padding(.bottom, 12)

            categoryRail(state)
                .padding(.bottom, 14)

            bottomActions
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
        }
        .background(Color.white)
    }

    static func viewState(
        selectedCategoryID: MeituEditorCategoryID,
        selectedToolID: String?,
        displayValue: Double,
        compareTitle: String,
        debugTitle: String
    ) -> MeituEditorToolPanelState {
        let selectedCategory = MeituEditorCategory.category(id: selectedCategoryID)
        let selectedTool = selectedToolID.flatMap { toolID in selectedCategory.tools.first { $0.id == toolID } }
            ?? selectedCategory.tools.first { $0.isSupported }
            ?? selectedCategory.tools[0]
        let range = selectedTool.controlID
            .map { BeautyControlDescriptor.descriptor(id: $0).displayRange }
            ?? .enhancement

        return MeituEditorToolPanelState(
            categories: MeituEditorCategory.all,
            selectedCategory: selectedCategory,
            selectedTool: selectedTool,
            selectedValue: displayValue,
            sliderRange: range,
            compareTitle: compareTitle,
            debugTitle: debugTitle,
            backgroundProtectionTitle: "背景保护",
            wholeTitle: "整体"
        )
    }

    private var displayValue: Double {
        guard let controlID = selectedTool.controlID else {
            return 0
        }
        return parameterStore.displayValue(for: controlID)
    }

    private var selectedTool: MeituEditorTool {
        categories.tool(id: selectedToolID)
            ?? MeituEditorCategory.category(id: selectedCategoryID).tools.first { $0.isSupported }
            ?? MeituEditorCategory.category(id: selectedCategoryID).tools[0]
    }

    private func sliderRow(_ state: MeituEditorToolPanelState) -> some View {
        VStack(spacing: 15) {
            HStack(spacing: 10) {
                Slider(
                    value: Binding(
                        get: { state.selectedValue },
                        set: { setSelectedDisplayValue($0, for: state.selectedTool) }
                    ),
                    in: state.sliderRange.bounds,
                    step: 1
                )
                .tint(Color(hex: 0xFF2F68))
                .disabled(!state.selectedTool.isSupported)
                .accessibilityLabel(state.selectedTool.title)
                .accessibilityValue(BeautySliderView.accessibilityValueText(
                    state.selectedValue,
                    range: state.sliderRange
                ))

                Button(state.wholeTitle) {}
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 17)
                    .frame(height: 36)
                    .background(Capsule().fill(Color(hex: 0xF7F7F7)))
                    .buttonStyle(.plain)
            }

            HStack {
                Toggle(state.backgroundProtectionTitle, isOn: .constant(false))
                    .toggleStyle(.switch)
                    .font(.system(size: 13, weight: .medium))
                    .tint(Color(hex: 0xFF2F68))
                    .disabled(true)
                    .fixedSize()

                Spacer()

                HStack(spacing: 16) {
                    Text(BeautySliderView.displayValueText(state.selectedValue, range: state.sliderRange))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x767676))
                    Text(state.compareTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x767676))
                    Text(state.debugTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x767676))
                }
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            }
        }
    }

    private func toolRail(_ state: MeituEditorToolPanelState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 13) {
                ForEach(state.selectedCategory.tools) { tool in
                    Button {
                        selectedToolID = tool.id
                    } label: {
                        VStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                Circle()
                                    .strokeBorder(
                                        tool.id == state.selectedTool.id ? Color(hex: 0xFF2F68) : Color(hex: 0x1F1F1F),
                                        lineWidth: tool.id == state.selectedTool.id ? 3 : 2
                                    )
                                    .frame(width: 42, height: 42)
                                    .overlay(
                                        Image(systemName: tool.systemImageName)
                                            .font(.system(size: 20, weight: .regular))
                                            .foregroundStyle(toolColor(tool, selectedToolID: state.selectedTool.id))
                                    )

                                if let badge = tool.badge {
                                    Text(badge.rawValue)
                                        .font(.system(size: 8, weight: .heavy))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 4)
                                        .frame(height: 13)
                                        .background(Capsule().fill(badgeColor(badge)))
                                        .offset(x: 7, y: -5)
                                } else if !tool.isSupported {
                                    Text("OFF")
                                        .font(.system(size: 8, weight: .heavy))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 4)
                                        .frame(height: 13)
                                        .background(Capsule().fill(Color(hex: 0xA8A8A8)))
                                        .offset(x: 7, y: -5)
                                }
                            }

                            Text(tool.title)
                                .font(.system(size: 13, weight: tool.id == state.selectedTool.id ? .semibold : .regular))
                                .foregroundStyle(toolColor(tool, selectedToolID: state.selectedTool.id))
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                        }
                        .frame(width: 62, height: 75)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(tool.title)
                    .accessibilityHint(tool.isSupported ? "" : (tool.unavailableReason ?? "v1.1 暂不支持"))
                }
            }
            .padding(.horizontal, 18)
        }
    }

    private func categoryRail(_ state: MeituEditorToolPanelState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(state.categories) { category in
                    Button {
                        selectedCategoryID = category.id
                        selectedToolID = category.tools.first { $0.isSupported }?.id ?? category.tools[0].id
                    } label: {
                        VStack(spacing: 8) {
                            Text(category.title)
                                .font(.system(size: 19, weight: category.id == selectedCategoryID ? .bold : .semibold))
                                .foregroundStyle(category.id == selectedCategoryID ? Color.black : Color(hex: 0x9B9BA1))
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)

                            Capsule()
                                .fill(category.id == selectedCategoryID ? Color(hex: 0xFF2F68) : Color.clear)
                                .frame(width: 28, height: 4)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(category.title)
                    .accessibilityAddTraits(category.id == selectedCategoryID ? .isSelected : [])
                }
            }
            .padding(.horizontal, 52)
        }
    }

    private var bottomActions: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("取消")

            Spacer()

            Button(action: onConfirm) {
                Image(systemName: "checkmark")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("确认")
        }
    }

    private func setSelectedDisplayValue(_ value: Double, for tool: MeituEditorTool) {
        guard let controlID = tool.controlID else {
            return
        }
        parameterStore.setDisplayValue(value, for: controlID)
    }

    private func toolColor(_ tool: MeituEditorTool, selectedToolID: String) -> Color {
        if tool.id == selectedToolID {
            return Color(hex: 0xFF2F68)
        }

        return tool.isSupported ? Color(hex: 0x242424) : Color(hex: 0xB4B4BA)
    }

    private func badgeColor(_ badge: MeituEditorToolBadge) -> Color {
        switch badge {
        case .free:
            Color(hex: 0xFF7EB3)
        case .pro:
            Color(hex: 0x161616)
        case .off:
            Color(hex: 0x9E9E9E)
        }
    }
}

private extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

#Preview {
    @Previewable @State var category: MeituEditorCategoryID = .faceShape
    @Previewable @State var tool = "face.width"
    MeituEditorToolPanelView(
        selectedCategoryID: $category,
        selectedToolID: $tool,
        parameterStore: BeautyParameterStore(),
        compareTitle: "对比",
        debugTitle: "调试",
        onCancel: {},
        onConfirm: {}
    )
}
