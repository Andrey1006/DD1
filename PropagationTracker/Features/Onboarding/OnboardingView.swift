import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "leaf.fill",
            tint: AppTheme.primary,
            title: "Welcome to Chikagation Tracker",
            subtitle: "Track every cutting, layer and division from snip to sale — all in one calm little garden."
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            tint: AppTheme.info,
            title: "Know what works",
            subtitle: "Log rooting dates and losses, and Chikagation Tracker calculates your success rate by method and species automatically."
        ),
        OnboardingPage(
            icon: "tag.fill",
            tint: AppTheme.accent,
            title: "Never miss a sale",
            subtitle: "Set an acclimation window and we'll tell you the moment a batch is ready to sell."
        )
    ]

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        pageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                pageIndicator
                    .padding(.bottom, Spacing.lg)

                controls
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
            }
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            ZStack {
                Circle()
                    .fill(page.tint.opacity(0.12))
                    .frame(width: 200, height: 200)
                Circle()
                    .fill(page.tint.opacity(0.18))
                    .frame(width: 140, height: 140)
                Image(systemName: page.icon)
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(page.tint)
            }

            VStack(spacing: Spacing.md) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal, Spacing.md)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? AppTheme.primary : AppTheme.primary.opacity(0.2))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }

    private var controls: some View {
        VStack(spacing: Spacing.sm) {
            Button {
                Haptics.tap()
                if currentPage == pages.count - 1 {
                    finish()
                } else {
                    withAnimation { currentPage += 1 }
                }
            } label: {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Skip") { finish() }
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .opacity(currentPage == pages.count - 1 ? 0 : 1)
        }
    }

    private func finish() {
        Haptics.success()
        hasSeenOnboarding = true
    }
}

#Preview {
    OnboardingView()
}
