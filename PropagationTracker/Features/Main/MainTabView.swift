import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selection = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: 0x161A17) : UIColor.white
        }
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selection) {
            DashboardView(selectedTab: $selection)
                .tabItem { Label("Today", systemImage: "sun.max.fill") }
                .tag(0)

            BatchesView()
                .tabItem { Label("Plants", systemImage: "leaf.fill") }
                .tag(1)

            AddBatchView(selectedTab: $selection)
                .tabItem { Label("Add", systemImage: "plus.circle.fill") }
                .tag(2)

            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar.fill") }
                .tag(3)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(4)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStore())
}
