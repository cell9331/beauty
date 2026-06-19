import SwiftUI

struct BeautySubcategoryRailItem: Identifiable, Equatable {
    let id: FacialFeatureSubcategoryID
    let title: String
    let availability: BeautyAvailability
    let isSelected: Bool
}

struct BeautyPanelViewState: Equatable {
    let category: BeautyCategory
    let activeAvailability: BeautyAvailability
    let subcategories: [BeautySubcategoryRailItem]
    let presetPickerItems: [BeautyPresetPickerItem]
    let filterPickerItems: [BeautyFilterPickerItem]
    let resourceFailure: BeautyResourcePickerFailureState?
    let controls: [BeautyControlDescriptor]
    let disabledControls: [BeautyControlDescriptor]
    let showsResetAll: Bool
    let status: BeautyParameterStatus
}

struct BeautyPanelView: View {
    let selectedCategoryID: BeautyCategoryID
    @Binding var selectedSubcategoryID: FacialFeatureSubcategoryID
    @ObservedObject var parameterStore: BeautyParameterStore

    var body: some View {
        let state = Self.viewState(
            categoryID: selectedCategoryID,
            selectedSubcategoryID: selectedSubcategoryID,
            status: parameterStore.status
        )

        VStack(alignment: .leading, spacing: 12) {
            header(for: state)

            if !state.subcategories.isEmpty {
                subcategoryRail(state.subcategories)
            }

            if !state.presetPickerItems.isEmpty {
                presetPicker(state.presetPickerItems)
            }

            if !state.filterPickerItems.isEmpty {
                filterPicker(state.filterPickerItems)
            }

            if let resourceFailure = state.resourceFailure {
                resourceFailureMessage(resourceFailure)
            }

            if state.activeAvailability.isEnabled {
                controlList(state.controls)
            } else {
                disabledMessage(for: state.activeAvailability)
                controlList(state.disabledControls)
            }

            if let primaryText = state.status.primaryText,
               let secondaryText = state.status.secondaryText {
                statusRow(primaryText: primaryText, secondaryText: secondaryText)
            }

            if state.showsResetAll {
                Button(BeautyControlDescriptor.resetAllTitle) {
                    parameterStore.resetAll()
                }
                .font(.system(size: 13, weight: .semibold))
                .buttonStyle(.bordered)
                .accessibilityLabel(BeautyControlDescriptor.resetAllTitle)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    static func viewState(
        categoryID: BeautyCategoryID,
        selectedSubcategoryID: FacialFeatureSubcategoryID,
        status: BeautyParameterStatus
    ) -> BeautyPanelViewState {
        let category = BeautyCategory.category(id: categoryID)

        switch category.panelKind {
        case .controls:
            let controls = BeautyControlDescriptor.controls(for: categoryID)
            let presetItems = categoryID == .beauty ? BeautyResourcePickerModels.presetItems() : []
            let filterItems = categoryID == .filters ? BeautyResourcePickerModels.filterItems() : []
            return BeautyPanelViewState(
                category: category,
                activeAvailability: category.availability,
                subcategories: [],
                presetPickerItems: presetItems,
                filterPickerItems: filterItems,
                resourceFailure: categoryID == .beauty && presetItems.isEmpty ? .unavailable : nil,
                controls: controls,
                disabledControls: [],
                showsResetAll: category.availability.isEnabled && !controls.isEmpty,
                status: status
            )
        case .facialFeatures:
            let selectedSubcategory = FacialFeatureSubcategory.subcategory(id: selectedSubcategoryID)
            let subcategories = FacialFeatureSubcategory.all.map { subcategory in
                BeautySubcategoryRailItem(
                    id: subcategory.id,
                    title: subcategory.title,
                    availability: subcategory.availability,
                    isSelected: subcategory.id == selectedSubcategoryID
                )
            }
            let controls = selectedSubcategory.availability.isEnabled
                ? BeautyControlDescriptor.controls(for: selectedSubcategoryID)
                : []

            return BeautyPanelViewState(
                category: category,
                activeAvailability: selectedSubcategory.availability,
                subcategories: subcategories,
                presetPickerItems: [],
                filterPickerItems: [],
                resourceFailure: nil,
                controls: controls,
                disabledControls: [],
                showsResetAll: selectedSubcategory.availability.isEnabled && !controls.isEmpty,
                status: status
            )
        case .disabled:
            return BeautyPanelViewState(
                category: category,
                activeAvailability: category.availability,
                subcategories: [],
                presetPickerItems: [],
                filterPickerItems: [],
                resourceFailure: nil,
                controls: [],
                disabledControls: category.id == .filters ? BeautyControlDescriptor.filterControls : [],
                showsResetAll: false,
                status: status
            )
        }
    }

    private func presetPicker(_ items: [BeautyPresetPickerItem]) -> some View {
        pickerSection(title: "Presets") {
            ForEach(items) { item in
                pickerButton(
                    title: item.title,
                    isSelected: parameterStore.selectedPresetId == item.id,
                    accessibilityLabel: item.accessibilityLabel
                ) {
                    parameterStore.applyPreset(item.preset)
                }
            }
        }
    }

    private func filterPicker(_ items: [BeautyFilterPickerItem]) -> some View {
        pickerSection(title: "Filters") {
            ForEach(items) { item in
                pickerButton(
                    title: item.title,
                    isSelected: parameterStore.selectedFilterId == item.filterId,
                    accessibilityLabel: item.accessibilityLabel
                ) {
                    parameterStore.selectFilter(id: item.filterId)
                }
                .disabled(!item.availability.isEnabled)
                .accessibilityHint(item.availability.reason ?? "")
            }
        }
    }

    private func pickerSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    content()
                }
            }
        }
    }

    private func pickerButton(
        title: String,
        isSelected: Bool,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .background(
                    isSelected
                        ? Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255)
                        : Color(red: 247 / 255, green: 248 / 255, blue: 250 / 255)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func header(for state: BeautyPanelViewState) -> some View {
        HStack {
            Text(state.category.title)
                .font(.system(size: 20, weight: .semibold))
            Spacer()
            Text("Apply Parameters")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255))
        }
    }

    private func subcategoryRail(_ items: [BeautySubcategoryRailItem]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    Button {
                        selectedSubcategoryID = item.id
                    } label: {
                        Text(item.title)
                            .font(.system(size: 13, weight: item.isSelected ? .semibold : .regular))
                            .foregroundStyle(subcategoryForegroundColor(for: item))
                            .padding(.horizontal, 12)
                            .frame(minHeight: 44)
                            .background(subcategoryBackgroundColor(for: item))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.title)
                    .accessibilityHint(item.availability.badge ?? "")
                    .accessibilityAddTraits(item.isSelected ? .isSelected : [])
                }
            }
        }
    }

    private func controlList(_ controls: [BeautyControlDescriptor]) -> some View {
        VStack(spacing: 8) {
            ForEach(controls) { descriptor in
                BeautySliderView(descriptor: descriptor, parameterStore: parameterStore)
            }
        }
    }

    private func statusRow(primaryText: String, secondaryText: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255))
                .frame(width: 8, height: 8)
            Text(primaryText)
                .font(.system(size: 13))
            Text(secondaryText)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }

    private func disabledMessage(for availability: BeautyAvailability) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let badge = availability.badge {
                Text(badge)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 238 / 255, green: 243 / 255, blue: 255 / 255))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if let reason = availability.reason {
                Text(reason)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func resourceFailureMessage(_ state: BeautyResourcePickerFailureState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(state.heading)
                .font(.system(size: 13, weight: .semibold))
            Text(state.body)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }

    private func subcategoryForegroundColor(for item: BeautySubcategoryRailItem) -> Color {
        if item.isSelected {
            return .white
        }

        return item.availability.isEnabled ? .primary : Color(red: 138 / 255, green: 143 / 255, blue: 152 / 255)
    }

    private func subcategoryBackgroundColor(for item: BeautySubcategoryRailItem) -> Color {
        if item.isSelected {
            return Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255)
        }

        return item.availability.isEnabled ? Color(red: 247 / 255, green: 248 / 255, blue: 250 / 255) : Color(red: 238 / 255, green: 240 / 255, blue: 243 / 255)
    }
}
