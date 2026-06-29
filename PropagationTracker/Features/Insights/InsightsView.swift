import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    summaryGrid
                    successByMethodCard
                    statusDistributionCard
                    methodBreakdownSection
                    topSpeciesCard
                }
                .padding(Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
            .background(AppBackground())
            .navigationTitle("Insights")
            .navigationDestination(for: PropagationMethod.self) { method in
                MethodBreakdownView(method: method)
            }
        }
    }

    private var summaryGrid: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                StatTile(value: "\(store.overallSuccessPercent)%", label: "Overall success",
                         icon: "chart.line.uptrend.xyaxis", tint: AppTheme.primary)
                StatTile(value: "\(store.totalLivingPlants)", label: "Living plants",
                         icon: "leaf.fill", tint: AppTheme.info)
            }
            HStack(spacing: Spacing.md) {
                StatTile(value: "\(store.batches.count)", label: "Total batches",
                         icon: "tray.full.fill", tint: AppTheme.accent)
                StatTile(value: "\(store.distinctSpeciesCount)", label: "Species tracked",
                         icon: "books.vertical.fill", tint: AppTheme.gold)
            }
        }
    }

    private var successByMethodCard: some View {
        let stats = store.methodStats().filter { $0.initial > 0 }
        return VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Success by method")
            if stats.isEmpty {
                Text("Log a few rooted batches to see which method works best for you.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                Chart(stats) { stat in
                    BarMark(
                        x: .value("Method", stat.method.title),
                        y: .value("Success", stat.successPercent)
                    )
                    .foregroundStyle(stat.method.tint.gradient)
                    .cornerRadius(8)
                    .annotation(position: .top) {
                        Text("\(stat.successPercent)%")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(values: [0, 50, 100]) { value in
                        AxisGridLine()
                        AxisValueLabel { if let v = value.as(Int.self) { Text("\(v)%") } }
                    }
                }
                .frame(height: 200)
            }
        }
        .cardStyle()
    }

    private var statusDistributionCard: some View {
        let counts = store.statusCounts().filter { $0.count > 0 }
        let total = max(1, counts.reduce(0) { $0 + $1.count })
        return VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Where your batches are")
            if counts.isEmpty {
                Text("No batches yet.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(counts, id: \.status) { item in
                            Rectangle()
                                .fill(item.status.tint)
                                .frame(width: max(6, geo.size.width * CGFloat(item.count) / CGFloat(total)))
                        }
                    }
                }
                .frame(height: 16)
                .clipShape(Capsule())

                VStack(spacing: Spacing.sm) {
                    ForEach(counts, id: \.status) { item in
                        HStack(spacing: Spacing.sm) {
                            Circle().fill(item.status.tint).frame(width: 10, height: 10)
                            Text(item.status.title)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Text("\(item.count)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    private var methodBreakdownSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "By method")
            ForEach(store.methodStats()) { stat in
                NavigationLink(value: stat.method) {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: stat.method.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(stat.method.tint)
                            .frame(width: 42, height: 42)
                            .background(stat.method.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(stat.method.title)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)
                            ProgressView(value: stat.successRate)
                                .tint(stat.method.tint)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(stat.initial > 0 ? "\(stat.successPercent)%" : "—")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("\(stat.batchCount) batches")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .cardStyle()
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var topSpeciesCard: some View {
        let species = store.speciesStats().prefix(5)
        return VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Most propagated")
            if species.isEmpty {
                Text("No species tracked yet.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(species.enumerated()), id: \.element.id) { index, stat in
                        HStack(spacing: Spacing.md) {
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.primary)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(stat.species)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .lineLimit(1)
                                Text("\(stat.living) living · \(stat.successPercent)% success")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                            Text("\(stat.batchCount)×")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(.vertical, Spacing.sm)
                        if index < species.count - 1 { Divider() }
                    }
                }
            }
        }
        .cardStyle()
    }
}

struct MethodBreakdownView: View {
    let method: PropagationMethod
    @EnvironmentObject private var store: AppStore

    private var batches: [PropagationBatch] {
        store.sortedBatches.filter { $0.method == method }
    }

    private var stat: AppStore.MethodStat? {
        store.methodStats().first { $0.method == method }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.lg) {
                headerCard
                if batches.isEmpty {
                    EmptyStateView(icon: method.icon, title: "No \(method.title.lowercased()) yet",
                                   message: "Batches you create with this method will appear here.")
                } else {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        SectionHeader(title: "Batches")
                        ForEach(batches) { batch in
                            NavigationLink(value: batch.id) {
                                BatchRowCard(batch: batch)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
        .background(AppBackground())
        .navigationTitle(method.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(for: UUID.self) { id in
            BatchDetailView(batchID: id)
        }
    }

    private var headerCard: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                Image(systemName: method.icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(method.tint, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(method.blurb)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            if let stat {
                HStack(spacing: Spacing.md) {
                    miniMetric(value: "\(stat.batchCount)", label: "Batches")
                    miniMetric(value: stat.initial > 0 ? "\(stat.successPercent)%" : "—", label: "Success")
                    miniMetric(value: "\(stat.surviving)", label: "Living")
                    miniMetric(value: "~\(method.estimatedRootingDays)d", label: "To root")
                }
            }
        }
        .cardStyle()
    }

    private func miniMetric(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(method.tint)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(AppTheme.surfaceAlt, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    InsightsView()
        .environmentObject(AppStore())
}
