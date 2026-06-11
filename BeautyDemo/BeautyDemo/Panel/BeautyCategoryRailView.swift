import SwiftUI

struct BeautyCategoryRailItem: Identifiable, Equatable {
    let id: BeautyCategoryID
    let title: String
    let availability: BeautyAvailability
    let isSelected: Bool
}

struct BeautyCategoryRailView: View {
    private let categories: [BeautyCategory]
    @Binding private var selectedCategoryID: BeautyCategoryID

    init(
        categories: [BeautyCategory] = BeautyCategory.all,
        selectedCategoryID: Binding<BeautyCategoryID>
    ) {
        self.categories = categories
        self._selectedCategoryID = selectedCategoryID
    }

    var body: some View {
        let items = Self.viewState(
            categories: categories,
            selectedCategoryID: selectedCategoryID
        )

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    Button {
                        selectedCategoryID = item.id
                    } label: {
                        Text(item.title)
                            .font(.system(size: 13, weight: item.isSelected ? .semibold : .regular))
                            .foregroundStyle(foregroundColor(for: item))
                            .padding(.horizontal, 12)
                            .frame(minHeight: 44)
                            .background(backgroundColor(for: item))
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

    static func viewState(
        categories: [BeautyCategory] = BeautyCategory.all,
        selectedCategoryID: BeautyCategoryID
    ) -> [BeautyCategoryRailItem] {
        categories.map { category in
            BeautyCategoryRailItem(
                id: category.id,
                title: category.title,
                availability: category.availability,
                isSelected: category.id == selectedCategoryID
            )
        }
    }

    private func foregroundColor(for item: BeautyCategoryRailItem) -> Color {
        if item.isSelected {
            return .white
        }

        return item.availability.isEnabled ? .primary : Color(red: 138 / 255, green: 143 / 255, blue: 152 / 255)
    }

    private func backgroundColor(for item: BeautyCategoryRailItem) -> Color {
        if item.isSelected {
            return Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255)
        }

        return item.availability.isEnabled ? .white : Color(red: 238 / 255, green: 240 / 255, blue: 243 / 255)
    }
}
