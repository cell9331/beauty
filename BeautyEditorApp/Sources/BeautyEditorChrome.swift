import SwiftUI

enum BeautyStyle {
    static let ink = Color(red: 21/255, green: 21/255, blue: 21/255)
    static let muted = Color(red: 144/255, green: 148/255, blue: 156/255)
    static let accent = Color(red: 242/255, green: 61/255, blue: 87/255)
}

struct BeautyEditorChrome: View {
    @Bindable var model: EditorModel
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            adjustmentRow
            toolBar
            categoryBar
        }
        .foregroundStyle(BeautyStyle.ink)
        // safeAreaInset in EditorScreen owns the content footprint. Only this surface
        // extends to the container bottom; no fixed Home Indicator inset is added.
        .background { Color.white.ignoresSafeArea(.container, edges: .bottom) }
    }

    private var adjustmentRow: some View {
        HStack(spacing: 12) {
            BeautySlider(value: model.value, range: model.selectedTool.range,
                         enabled: !model.controlsDisabled && model.selectedTool.available,
                         title: model.selectedTool.title,
                         referenceStyle: model.selectedTool.usesReferenceSlider,
                         onBegin: model.beginAdjustment,
                         onChange: model.updateValue,
                         onEnd: model.endAdjustment)
                .frame(height: 44)
                .background(Color.white)
                .accessibilityIdentifier("adjustment-slider")
            if model.category.showsScope {
                Text("整体")
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 44, height: 28)
                    .background(Color(red: 247/255, green: 247/255, blue: 248/255), in: Capsule())
                    .accessibilityLabel("调整范围：整体")
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, model.category.showsScope ? 12 : 20)
        .frame(height: 48)
        .overlay(alignment: .topLeading) {
            if !model.selectedTool.usesReferenceSlider && abs(model.value) > 0.5 {
                Text(String(Int(model.value.rounded())))
                    .font(.system(size: 10, weight: .medium).monospacedDigit())
                    .foregroundStyle(BeautyStyle.muted)
                    .padding(.leading, 20)
                    .offset(y: -1)
                    .allowsHitTesting(false)
                    .accessibilityIdentifier("adjustment-value")
            }
        }
    }

    private var toolBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: model.category == .face ? -2 : 0) {
                    ForEach(ToolCatalog.tools(in: model.category)) { tool in
                        BeautyToolItem(tool: tool, selected: model.selectedToolID == tool.id,
                                       active: abs(tool.value(in: model.snapshot.parameters)) > 0.5,
                                       action: { model.selectTool(tool) })
                        .id(tool.id)
                        .disabled(model.controlsDisabled || !tool.available)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
            .scrollIndicators(.hidden)
            .frame(height: 80)
            .accessibilityIdentifier("tool-scroll")
            .id(model.category)
            .onAppear { proxy.scrollTo(model.selectedToolID, anchor: .center) }
            .onChange(of: model.category) { _, _ in
                proxy.scrollTo(model.selectedToolID, anchor: .center)
            }
            .onChange(of: model.selectedToolID) { _, id in
                withAnimation(.easeInOut(duration: 0.18)) { proxy.scrollTo(id, anchor: .center) }
            }
        }
    }

    private var categoryBar: some View {
        HStack(spacing: 0) {
            Button(action: onClose) {
                Image("action_close").resizable().scaledToFit().frame(width: 24, height: 24)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("取消编辑")
            .accessibilityIdentifier("cancel-editing")

            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(BeautyCategory.allCases) { category in
                            Button { model.selectCategory(category) } label: {
                                VStack(spacing: 4) {
                                    Text(category.title)
                                        .font(.system(size: 15, weight: model.category == category ? .medium : .regular))
                                        .foregroundStyle(model.category == category ? BeautyStyle.ink : BeautyStyle.muted)
                                    Rectangle().fill(BeautyStyle.accent)
                                        .frame(width: 18, height: 2)
                                        .opacity(model.category == category ? 1 : 0)
                                }
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .contentShape(Rectangle())
                            }
                            .id(category)
                            .disabled(!category.hasDesign)
                            .opacity(category.hasDesign ? 1 : 0.35)
                            .accessibilityValue(category.hasDesign ? "" : "未开放")
                            .accessibilityIdentifier("category-\(category.rawValue)")
                            .accessibilityAddTraits(model.category == category ? .isSelected : [])
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onAppear { proxy.scrollTo(model.category, anchor: .center) }
                .onChange(of: model.category) { _, category in
                    withAnimation(.easeInOut(duration: 0.2)) { proxy.scrollTo(category, anchor: .center) }
                }
                .accessibilityIdentifier("category-scroll")
            }
            Button { model.confirmEditing() } label: {
                Image("action_confirm").resizable().scaledToFit().frame(width: 24, height: 24)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("完成编辑")
            .accessibilityIdentifier("confirm-editing")
        }
        .buttonStyle(.plain)
        .disabled(model.controlsDisabled)
        .frame(height: 56)
    }
}

struct BeautyToolItem: View {
    let tool: ToolDefinition
    let selected: Bool
    let active: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Group {
                    if let symbol = tool.systemSymbol {
                        Image(systemName: symbol)
                            .font(.system(size: 24, weight: .regular))
                            .symbolRenderingMode(.monochrome)
                    } else {
                        Image(tool.icon).renderingMode(.template).resizable().scaledToFit()
                    }
                }
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)
                Text(tool.title)
                    .font(.system(size: 12, weight: selected ? .medium : .regular))
                    .lineLimit(1)
                    .frame(height: 16)
            }
            .frame(width: 69, height: 64)
            .foregroundStyle(selected ? BeautyStyle.accent : BeautyStyle.ink)
            .opacity(tool.available ? 1 : 0.35)
            .overlay(alignment: .topTrailing) {
                if tool.promo {
                    Text("限免").font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white).padding(.horizontal, 4).padding(.vertical, 2)
                        .background(Color(red: 1, green: 107/255, blue: 145/255), in: RoundedRectangle(cornerRadius: 4))
                        .offset(x: -1, y: -3)
                }
            }
            .overlay(alignment: .trailing) {
                if tool.pro {
                    Text("Pro").font(.system(size: 7, weight: .medium)).offset(x: -12, y: -5)
                } else if !tool.available || (tool.smart && !active) {
                    Text("OFF").font(.system(size: 8, weight: .medium)).offset(x: -8, y: -5)
                }
            }
            .overlay(alignment: .bottomLeading) {
                if tool.smart {
                    Image("smart_indicator").resizable().scaledToFit()
                        .frame(width: 12, height: 12).offset(x: 2, y: -9)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tool.title + (tool.pro ? " Pro" : ""))
        .accessibilityValue(tool.available ? (selected ? "已选中" : "") : "未开放")
        .accessibilityHint(tool.note ?? "选择后拖动上方滑块调整")
        .accessibilityIdentifier("tool-\(tool.id)")
    }
}

struct BeautyPreviewControls: View {
    @Bindable var model: EditorModel
    var body: some View {
        ZStack {
            Button { model.toggleBackgroundProtection() } label: {
                HStack(spacing: 2) {
                    Text("背景保护").font(.system(size: 13))
                    Image(model.snapshot.protectBackground ? "protection_on" : "protection_off")
                        .resizable().scaledToFit().frame(width: 40, height: 22)
                }
                .foregroundStyle(.white)
                .padding(.leading, 10).padding(.trailing, 2)
                .frame(height: 32)
                .background(.black.opacity(0.55), in: Capsule())
                .frame(height: 44)
                .contentShape(Rectangle())
            }
            .disabled(model.controlsDisabled)
            .accessibilityLabel("背景保护")
            .accessibilityValue(model.snapshot.protectBackground ? "开启" : "关闭")
            .accessibilityIdentifier("background-protection")

            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 1.3).stroke(.white.opacity(0.65), lineWidth: 1.4)
                    .frame(width: 20, height: 18)
                    .overlay(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 0.7).fill(.white.opacity(0.18))
                            .frame(width: 6, height: 14).padding(.trailing, 2)
                    }
                    .frame(width: 44, height: 44)
                    .background(model.comparing ? .black.opacity(0.25) : .clear, in: Circle())
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { _ in if !model.controlsDisabled { model.comparing = true } }
                        .onEnded { _ in model.comparing = false })
                    .accessibilityElement()
                    .accessibilityLabel("按住对比原图")
                    .accessibilityValue(model.comparing ? "原图" : "编辑效果")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAction { model.comparing.toggle() }
                    .accessibilityIdentifier("compare-original")
            }
            .padding(.trailing, 8)
        }
        .frame(height: 44)
        .buttonStyle(.plain)
    }
}
