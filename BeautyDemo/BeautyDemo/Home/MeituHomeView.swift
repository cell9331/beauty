import SwiftUI

struct MeituHomeView: View {
    let onRoute: (MeituHomeRoute) -> Void
    private let initialStickyPreview: Bool

    @State private var selectedToolPage = 0
    @State private var showsStickyActions = false

    private let state = Self.viewState()

    init(
        initialStickyPreview: Bool = false,
        onRoute: @escaping (MeituHomeRoute) -> Void
    ) {
        self.initialStickyPreview = initialStickyPreview
        self.onRoute = onRoute
        self._showsStickyActions = State(initialValue: initialStickyPreview)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        hero
                        primaryActions
                        toolPager
                        recommendations
                            .id("recommendations")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 116)
                }
                .coordinateSpace(name: "home-scroll")
                .ignoresSafeArea(edges: .top)
                .onPreferenceChange(MeituHomeHeroOffsetPreferenceKey.self) { minY in
                    if initialStickyPreview {
                        showsStickyActions = true
                    } else {
                        showsStickyActions = minY < -320
                    }
                }
                .onAppear {
                    guard initialStickyPreview else {
                        return
                    }
                    DispatchQueue.main.async {
                        proxy.scrollTo("recommendations", anchor: .top)
                    }
                }
            }

            if showsStickyActions {
                stickyShortcutRail
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 8)
            }

            bottomTabBar
        }
        .animation(.easeInOut(duration: 0.18), value: showsStickyActions)
    }

    static func viewState() -> MeituHomeViewState {
        .reference
    }

    private var hero: some View {
        ZStack(alignment: .top) {
            RetroHeroBackground()

            VStack(spacing: 0) {
                topChrome
                    .padding(.top, 82)
                    .padding(.horizontal, 16)

                ZStack(alignment: .bottomTrailing) {
                    VStack(alignment: .leading, spacing: 12) {
                        Spacer(minLength: 34)
                        Text(state.hero.title)
                            .font(.system(size: 36, weight: .regular))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                            .shadow(color: .black.opacity(0.22), radius: 8, y: 3)

                        Text(state.hero.subtitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(hex: 0xD9E96F))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 28)
                    .padding(.bottom, 72)

                    filmFrame
                        .frame(width: 150, height: 190)
                        .rotationEffect(.degrees(5))
                        .offset(x: -18, y: -2)

                    Button {
                        onRoute(.cameraEditor)
                    } label: {
                        Text(state.hero.ctaTitle)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .frame(height: 41)
                            .background(
                                Capsule()
                                    .fill(Color(hex: 0xFF8B2C))
                                    .shadow(color: Color(hex: 0xFFB15A).opacity(0.75), radius: 18)
                            )
                    }
                    .buttonStyle(.plain)
                    .offset(x: -17, y: -74)
                }
                .frame(height: 236)
            }
        }
        .frame(height: 320)
        .frame(maxWidth: .infinity)
        .clipped()
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: MeituHomeHeroOffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("home-scroll")).minY
                )
            }
        )
    }

    private var topChrome: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 14) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                Text("搜索")
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundStyle(.white.opacity(0.82))
            .padding(.horizontal, 15)
            .frame(width: 132, height: 42, alignment: .leading)
            .background(Capsule().fill(Color.black.opacity(0.28)))
            .frame(maxWidth: .infinity, alignment: .leading)

            BrandCapsule()
                .scaleEffect(0.92)
                .offset(y: 12)

            vipChip
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 56)
        }
    }

    private var vipChip: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(Color.white.opacity(0.85))
                .frame(width: 43, height: 43)
                .overlay(
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: 0xF59CCD))
                )
            Text("VIP")
                .font(.system(size: 8, weight: .heavy))
                .foregroundStyle(Color(hex: 0xFF7FB5))
                .padding(.horizontal, 5)
                .frame(height: 13)
                .background(Capsule().fill(Color.white))
                .offset(x: 6, y: -2)
        }
    }

    private var filmFrame: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.black)
            VStack(spacing: 5) {
                filmPerforations
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: 0x1F3C22), Color(hex: 0xD2B348), Color(hex: 0x476229)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    VStack(spacing: 0) {
                        Circle()
                            .fill(Color(hex: 0xEAD2A6))
                            .frame(width: 43, height: 43)
                        RoundedRectangle(cornerRadius: 38)
                            .fill(Color(hex: 0xC59265))
                            .frame(width: 66, height: 82)
                            .offset(y: -6)
                    }
                    .offset(y: 13)
                }
                .clipShape(RoundedRectangle(cornerRadius: 2))
                filmPerforations
            }
            .padding(6)
        }
        .shadow(color: .black.opacity(0.42), radius: 16, y: 8)
        .accessibilityHidden(true)
    }

    private var filmPerforations: some View {
        HStack(spacing: 4) {
            ForEach(0..<9, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: 0xB8C76A))
                    .frame(width: 6, height: 4)
            }
        }
    }

    private var primaryActions: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(state.primaryActions.filter { $0.size == .large }) { action in
                    primaryActionButton(action)
                        .frame(maxWidth: .infinity)
                        .frame(height: 82)
                }
            }

            HStack(spacing: 10) {
                ForEach(state.primaryActions.filter { $0.size == .small }) { action in
                    primaryActionButton(action)
                        .frame(maxWidth: .infinity)
                        .frame(height: 75)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, -38)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private func primaryActionButton(_ action: MeituHomeAction) -> some View {
        Button {
            onRoute(action.route)
        } label: {
            VStack(spacing: action.size == .large ? 9 : 8) {
                Image(systemName: action.systemImageName)
                    .font(.system(size: action.size == .large ? 29 : 25, weight: .bold))
                    .frame(height: action.size == .large ? 30 : 25)
                Text(action.title)
                    .font(.system(size: action.size == .large ? 22 : 17, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(action.isEnabled ? Color(hex: 0x743015) : Color(hex: 0x4A2418))
            )
            .opacity(action.isEnabled ? 1 : 0.72)
        }
        .buttonStyle(.plain)
        .disabled(!action.isEnabled)
        .accessibilityLabel(action.title)
        .accessibilityHint(action.isEnabled ? "" : "v1.1 暂不支持")
    }

    private var toolPager: some View {
        VStack(spacing: 18) {
            TabView(selection: $selectedToolPage) {
                ForEach(state.toolPages) { page in
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                        spacing: 18
                    ) {
                        ForEach(page.tools) { tool in
                            toolButton(tool)
                        }
                    }
                    .padding(.horizontal, 22)
                    .tag(page.id)
                }
            }
            .frame(height: 174)
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 5) {
                ForEach(state.toolPages) { page in
                    Capsule()
                        .fill(page.id == selectedToolPage ? Color.white : Color.white.opacity(0.32))
                        .frame(width: page.id == selectedToolPage ? 26 : 20, height: 4)
                }
            }
        }
        .padding(.bottom, 34)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private func toolButton(_ tool: MeituHomeTool) -> some View {
        Button {
            onRoute(tool.route)
        } label: {
            VStack(spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tool.systemImageName)
                        .font(.system(size: 26, weight: .semibold))
                        .frame(width: 43, height: 36)
                    if let badge = tool.badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 4)
                            .frame(height: 13)
                            .background(Capsule().fill(Color(hex: 0x9DF4E6)))
                            .offset(x: 10, y: -4)
                    }
                }
                Text(tool.title)
                    .font(.system(size: 13, weight: .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .foregroundStyle(tool.isEnabled ? Color.white.opacity(0.92) : Color.white.opacity(0.68))
            .frame(maxWidth: .infinity, minHeight: 67)
        }
        .buttonStyle(.plain)
        .disabled(!tool.isEnabled)
        .accessibilityLabel(tool.title)
        .accessibilityHint(tool.isEnabled ? "" : "v1.1 暂不支持")
    }

    private var recommendations: some View {
        VStack(spacing: 28) {
            ForEach(state.recommendations) { section in
                recommendationSection(section)
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private func recommendationSection(_ section: MeituHomeRecommendationSection) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(section.title)
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(section.cards) { card in
                        recommendationCard(card)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func recommendationCard(_ card: MeituHomeRecommendationCard) -> some View {
        RoundedRectangle(cornerRadius: 19)
            .fill(
                LinearGradient(
                    colors: [Color(hex: card.palette.topHex), Color(hex: card.palette.bottomHex)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                VStack {
                    Circle()
                        .fill(Color.white.opacity(0.36))
                        .frame(width: 34, height: 34)
                    Spacer()
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.18))
                        .frame(width: 58, height: 68)
                }
                .padding(.top, 18)
                .padding(.bottom, 14)
            }
            .frame(width: 112, height: 154)
            .accessibilityHidden(true)
    }

    private var stickyShortcutRail: some View {
        HStack(spacing: 14) {
            Button {} label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 35, height: 35)
                    .background(Circle().fill(Color(hex: 0x743015)))
            }
            .buttonStyle(.plain)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(state.stickyActions) { action in
                        Button {
                            onRoute(action.route)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: action.systemImageName)
                                    .font(.system(size: 13, weight: .bold))
                                Text(action.title)
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .frame(height: 35)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(action.isEnabled ? Color(hex: 0x743015) : Color(hex: 0x4A2418))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!action.isEnabled)
                    }
                }
                .padding(.trailing, 24)
            }
        }
        .padding(.leading, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.94))
    }

    private var bottomTabBar: some View {
        HStack {
            ForEach(state.tabs) { tab in
                VStack(spacing: 9) {
                    ZStack(alignment: .topTrailing) {
                        Text(tab.title)
                            .font(.system(size: 20, weight: tab.isSelected ? .bold : .semibold))
                            .foregroundStyle(tab.isSelected ? .white : Color.white.opacity(0.36))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        if tab.showsDot {
                            Circle()
                                .fill(Color(hex: 0xFF3F78))
                                .frame(width: 7, height: 7)
                                .offset(x: 8, y: -3)
                        }
                    }

                    Capsule()
                        .fill(tab.isSelected ? Color(hex: 0xFF3F78) : Color.clear)
                        .frame(width: 28, height: 4)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: 0x191919))
        )
        .padding(.horizontal, 2)
        .padding(.bottom, 3)
    }
}

private struct RetroHeroBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0xE2F18E), Color(hex: 0x3D875B), Color(hex: 0x162E23)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Ellipse()
                    .fill(Color(hex: 0x0C6A3A).opacity(0.42))
                    .frame(width: proxy.size.width * 1.35, height: proxy.size.height * 1.45)
                    .rotationEffect(.degrees(-26))
                    .offset(x: proxy.size.width * 0.32, y: 4)
                Ellipse()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: proxy.size.width * 0.86, height: proxy.size.height * 0.55)
                    .rotationEffect(.degrees(-22))
                    .offset(x: -proxy.size.width * 0.36, y: 50)
                LinearGradient(
                    colors: [.clear, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }
}

struct BrandCapsule: View {
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: 0xFF2F68))
                .frame(width: 22, height: 22)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                )
            Text("美图秀秀")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 9)
        .frame(height: 32)
        .background(Capsule().fill(Color.white))
    }
}

private struct MeituHomeHeroOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
    MeituHomeView { _ in }
}
