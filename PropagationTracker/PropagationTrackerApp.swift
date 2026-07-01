import SwiftUI

struct PropagationTracker: View {
    @StateObject private var store = AppStore()

    var body: some View {
        ContentView()
            .environmentObject(store)
            .tint(AppTheme.primary)
    }
}
