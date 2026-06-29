import SwiftUI

struct BatchesView: View {
    @EnvironmentObject private var store: AppStore
    @State private var searchText = ""
    @State private var methodFilter: PropagationMethod? = nil
    @State private var showActiveOnly = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.md) {
                    filterBar

                    if filteredBatches.isEmpty {
                        EmptyStateView(
                            icon: "leaf.fill",
                            title: store.batches.isEmpty ? "No batches yet" : "No matches",
                            message: store.batches.isEmpty
                                ? "Tap the Add tab to start tracking your first propagation."
                                : "Try clearing your filters or search."
                        )
                        .padding(.top, Spacing.xl)
                    } else {
                        ForEach(filteredBatches) { batch in
                            NavigationLink(value: batch.id) {
                                BatchRowCard(batch: batch)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
            .background(AppBackground())
            .navigationTitle("Plants")
            .searchable(text: $searchText, prompt: "Search name or species")
            .navigationDestination(for: UUID.self) { id in
                BatchDetailView(batchID: id)
            }
        }
    }

    private var filterBar: some View {
        VStack(spacing: Spacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    filterChip(title: "All", selected: methodFilter == nil) {
                        methodFilter = nil
                    }
                    ForEach(PropagationMethod.allCases) { method in
                        Button {
                            Haptics.tap()
                            methodFilter = (methodFilter == method) ? nil : method
                        } label: {
                            MethodChip(method: method, selected: methodFilter == method)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }

            HStack {
                Toggle(isOn: $showActiveOnly) {
                    Text("Active only")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .toggleStyle(.switch)
                .tint(AppTheme.primary)
                Spacer()
                Text("\(filteredBatches.count) batches")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    private func filterChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(selected ? .white : AppTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(selected ? AnyShapeStyle(AppTheme.primary) : AnyShapeStyle(AppTheme.surfaceAlt))
                )
        }
        .buttonStyle(.plain)
    }

    private var filteredBatches: [PropagationBatch] {
        store.sortedBatches.filter { batch in
            let matchesMethod = methodFilter == nil || batch.method == methodFilter
            let matchesActive = !showActiveOnly || batch.status.isActive
            let matchesSearch = searchText.isEmpty
                || batch.name.localizedCaseInsensitiveContains(searchText)
                || batch.species.localizedCaseInsensitiveContains(searchText)
            return matchesMethod && matchesActive && matchesSearch
        }
    }
}

#Preview {
    BatchesView()
        .environmentObject(AppStore())
}
