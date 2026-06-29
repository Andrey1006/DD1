import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            if hasSeenOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: hasSeenOnboarding)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStore())
}
