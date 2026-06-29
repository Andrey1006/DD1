import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("defaultWateringDays") private var defaultWateringDays = 3
    @AppStorage("defaultAcclimationDays") private var defaultAcclimationDays = 21

    @Environment(\.openURL) private var openURL
    @State private var showClearConfirm = false
    @State private var webLink: WebLink?

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    summaryCard
                    preferencesSection
                    dataSection
                    legalSection
                    aboutCard
                }
                .padding(Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
            .background(AppBackground())
            .navigationTitle("Settings")
            .alert("Clear all batches?", isPresented: $showClearConfirm) {
                Button("Delete Everything", role: .destructive) {
                    Haptics.warning()
                    store.batches.removeAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently removes every batch and its history. This cannot be undone.")
            }
            .sheet(item: $webLink) { link in
                WebViewSheet(link: link)
            }
        }
    }

    private var summaryCard: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(AppTheme.heroGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text("Chikagation Tracker")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("\(store.batches.count) batches · \(store.totalLivingPlants) living plants")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
        }
        .cardStyle()
    }

    private var preferencesSection: some View {
        section("Preferences") {
            toggleRow(icon: "bell.fill", tint: AppTheme.primary, title: "Care Reminders", isOn: $notificationsEnabled)
            rowDivider
            stepperRow(icon: "drop.fill", tint: AppTheme.info, title: "Default watering",
                       value: $defaultWateringDays, range: 1...30)
            rowDivider
            stepperRow(icon: "sun.max.fill", tint: AppTheme.gold, title: "Default acclimation",
                       value: $defaultAcclimationDays, range: 1...120)
        }
    }

    private var dataSection: some View {
        section("Data") {
            ShareLink(item: store.exportCSV(), preview: SharePreview("Chikagation Tracker export.csv")) {
                rowLabel(icon: "square.and.arrow.up", tint: AppTheme.info, title: "Export as CSV")
            }
            .buttonStyle(.plain)
            rowDivider
            Button {
                Haptics.tap()
                hasSeenOnboarding = false
            } label: {
                rowLabel(icon: "sparkles", tint: AppTheme.accent, title: "Replay Onboarding")
            }
            .buttonStyle(.plain)
            rowDivider
            Button {
                showClearConfirm = true
            } label: {
                rowLabel(icon: "trash", tint: Color(hex: 0xC0463E), title: "Clear All Batches",
                         titleColor: Color(hex: 0xC0463E), trailingSystemImage: nil)
            }
            .buttonStyle(.plain)
        }
    }

    private var legalSection: some View {
        section("Legal") {
            linkRow(icon: "hand.raised.fill", tint: AppTheme.primary, title: "Privacy Policy",
                    url: "https://sites.google.com/view/chikagation-tracker/privacy-policy")
            rowDivider
            linkRow(icon: "doc.text.fill", tint: AppTheme.textSecondary, title: "Terms of Service",
                    url: "https://sites.google.com/view/chikagation-tracker/terms-of-service")
        }
    }

    private var aboutCard: some View {
        VStack(spacing: Spacing.sm) {
            rowLabel(icon: "info.circle.fill", tint: AppTheme.info, title: "Version",
                     trailingSystemImage: nil, trailingText: appVersion)
                .cardStyle(padding: 0)
            Text("Made for plant people 🌱  ·  Chikagation Tracker v\(appVersion)")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, Spacing.xs)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.leading, 4)
            VStack(spacing: 0) { content() }
                .cardStyle(padding: 0)
        }
    }

    private var rowDivider: some View {
        Divider().padding(.leading, 60)
    }

    private func iconBadge(_ icon: String, _ tint: Color) -> some View {
        Image(systemName: icon.isEmpty ? "circle.fill" : icon)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(tint, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private func rowLabel(icon: String, tint: Color, title: String,
                          titleColor: Color = AppTheme.textPrimary,
                          trailingSystemImage: String? = "chevron.right",
                          trailingText: String? = nil) -> some View {
        HStack(spacing: Spacing.md) {
            iconBadge(icon, tint)
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(titleColor)
            Spacer()
            if let trailingText {
                Text(trailingText)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            if let trailingSystemImage {
                Image(systemName: trailingSystemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.6))
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }

    private func linkRow(icon: String, tint: Color, title: String, url: String) -> some View {
        Button {
            guard let u = URL(string: url) else { return }
            if u.scheme == "http" || u.scheme == "https" {
                webLink = WebLink(title: title, url: u)
            } else {
                openURL(u)
            }
        } label: {
            rowLabel(icon: icon, tint: tint, title: title)
        }
        .buttonStyle(.plain)
    }

    private func toggleRow(icon: String, tint: Color, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Spacing.md) {
            iconBadge(icon, tint)
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppTheme.primary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 9)
    }

    private func stepperRow(icon: String, tint: Color, title: String,
                            value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack(spacing: Spacing.md) {
            iconBadge(icon, tint)
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Text("\(value.wrappedValue)d")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.primary)
                .frame(minWidth: 34, alignment: .trailing)
            Stepper("", value: value, in: range)
                .labelsHidden()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 7)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppStore())
}
