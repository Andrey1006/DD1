import SwiftUI

@main
struct PropagationTrackerApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .tint(AppTheme.primary)
        }
    }
}
