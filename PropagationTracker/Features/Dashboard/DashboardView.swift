import SwiftUI

struct DashboardView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    header
                    summaryGrid

                    if store.todaysTasks.isEmpty {
                        allCaughtUpCard
                    } else {
                        tasksSection
                    }

                    if !store.readyToSellBatches.isEmpty {
                        readyToSellSection
                    }

                    recentActivitySection
                }
                .padding(Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
            .background(AppBackground())
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: UUID.self) { id in
                BatchDetailView(batchID: id)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
            Text("\(store.todaysTasks.count) task\(store.todaysTasks.count == 1 ? "" : "s") need attention")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            HStack(spacing: Spacing.md) {
                miniStat(value: "\(store.activeBatches.count)", label: "active batches")
                Divider().frame(height: 28).overlay(.white.opacity(0.3))
                miniStat(value: "\(store.totalLivingPlants)", label: "growing plants")
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .background(AppTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white.opacity(0.08))
                .offset(x: 10, y: -10)
        }
        .clipped()
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning 🌱"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Late-night gardening"
        }
    }

    private var summaryGrid: some View {
        HStack(spacing: Spacing.md) {
            StatTile(value: "\(store.overallSuccessPercent)%", label: "Success rate",
                     icon: "chart.line.uptrend.xyaxis", tint: AppTheme.primary)
            StatTile(value: "\(store.readyToSellBatches.count)", label: "Ready to sell",
                     icon: "tag.fill", tint: AppTheme.accent)
            StatTile(value: "\(store.distinctSpeciesCount)", label: "Species",
                     icon: "leaf.fill", tint: AppTheme.info)
        }
    }

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Needs attention")
            ForEach(store.todaysTasks) { task in
                TaskRow(task: task)
            }
        }
    }

    private var allCaughtUpCard: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundStyle(AppTheme.primary)
            Text("All caught up!")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Text("No care tasks due right now. Time to start a new batch?")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            Button("Start a Batch") {
                Haptics.tap()
                selectedTab = 2
            }
            .buttonStyle(SoftButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .cardStyle()
    }

    private var readyToSellSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Ready to sell")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(store.readyToSellBatches) { batch in
                        NavigationLink(value: batch.id) {
                            readyCard(batch)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private func readyCard(_ batch: PropagationBatch) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            BatchThumbnail(batch: batch, size: 64)
            Text(batch.name)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
            Text("\(batch.survivingCount) plants · \(batch.successPercent)%")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
            StatusBadge(status: batch.status)
        }
        .padding(Spacing.md)
        .frame(width: 170, alignment: .leading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.accent.opacity(0.4), lineWidth: 1.5)
        )
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Recent activity")
            let recent = recentEvents()
            if recent.isEmpty {
                Text("No activity logged yet.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .cardStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recent.enumerated()), id: \.element.0.id) { index, pair in
                        let (event, batch) = pair
                        ActivityRow(event: event, batchName: batch)
                        if index < recent.count - 1 {
                            Divider().padding(.leading, 44)
                        }
                    }
                }
                .cardStyle()
            }
        }
    }

    private func recentEvents() -> [(CareEvent, String)] {
        store.batches
            .flatMap { batch in batch.events.map { ($0, batch.name) } }
            .sorted { $0.0.date > $1.0.date }
            .prefix(6)
            .map { ($0.0, $0.1) }
    }
}

private struct TaskRow: View {
    let task: CareTask
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationLink(value: task.batchID) {
            HStack(spacing: Spacing.md) {
                Image(systemName: task.kind.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(task.kind.tint)
                    .frame(width: 42, height: 42)
                    .background(task.kind.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(task.subtitle)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()
                quickAction
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var quickAction: some View {
        switch task.kind {
        case .watering:
            Button {
                Haptics.tap()
                store.water(task.batchID)
            } label: {
                Image(systemName: "drop.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.info, in: Circle())
            }
            .buttonStyle(.plain)
        case .readyForSale:
            Button {
                Haptics.success()
                store.setStatus(.readyForSale, for: task.batchID)
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.primary, in: Circle())
            }
            .buttonStyle(.plain)
        case .rootCheck, .sellNow:
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

private struct ActivityRow: View {
    let event: CareEvent
    let batchName: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: event.type.icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(event.type.tint)
                .frame(width: 30, height: 30)
                .background(event.type.tint.opacity(0.15), in: Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(event.note.isEmpty ? event.type.title : event.note)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                Text(batchName)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            Text(event.date.relativeShort())
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    DashboardView(selectedTab: .constant(0))
        .environmentObject(AppStore())
}
