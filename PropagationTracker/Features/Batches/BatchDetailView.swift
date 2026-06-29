import SwiftUI

struct BatchDetailView: View {
    let batchID: UUID
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var showEdit = false
    @State private var showLog = false
    @State private var logPreset: CareEventType = .watered
    @State private var showDeleteConfirm = false

    var body: some View {
        Group {
            if let batch = store.batch(id: batchID) {
                content(for: batch)
            } else {
                removedPlaceholder
            }
        }
        .background(AppBackground())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let batch = store.batch(id: batchID) {
                    Menu {
                        Button { showEdit = true } label: { Label("Edit", systemImage: "pencil") }
                        ShareLink(item: shareText(for: batch)) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Divider()
                        Button(role: .destructive) { showDeleteConfirm = true } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            if let batch = store.batch(id: batchID) {
                EditBatchSheet(batch: batch)
            }
        }
        .sheet(isPresented: $showLog) {
            LogEventView(batchID: batchID, presetType: logPreset)
        }
        .alert("Delete this batch?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let batch = store.batch(id: batchID) { store.delete(batch) }
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes the batch and its history.")
        }
    }

    private func content(for batch: PropagationBatch) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.lg) {
                hero(batch)
                progressCard(batch)
                if let action = batch.status.advanceActionTitle {
                    advanceButton(batch, title: action)
                }
                quickActions(batch)
                statsGrid(batch)
                lifecycleCard(batch)
                if !batch.notes.isEmpty { notesCard(batch) }
                timelineCard(batch)
            }
            .padding(Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
    }

    private func hero(_ batch: PropagationBatch) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                if let data = batch.photo, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    AppTheme.heroGradient
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: batch.method.icon)
                                .font(.system(size: 70))
                                .foregroundStyle(.white.opacity(0.18))
                        )
                }
                LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)
                    .frame(height: 200)
                VStack(alignment: .leading, spacing: 6) {
                    Text(batch.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(batch.species)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(Spacing.md)
            }
            HStack(spacing: Spacing.sm) {
                StatusBadge(status: batch.status)
                MethodChip(method: batch.method)
                Spacer()
            }
            .padding(Spacing.md)
            .background(AppTheme.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }

    private func progressCard(_ batch: PropagationBatch) -> some View {
        HStack(spacing: Spacing.lg) {
            ProgressRing(
                progress: batch.progress,
                size: 96,
                lineWidth: 11,
                tint: batch.status.tint,
                centerText: "\(Int(batch.progress * 100))%"
            )
            VStack(alignment: .leading, spacing: 6) {
                Text(progressHeadline(batch))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(progressSubtitle(batch))
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .cardStyle()
    }

    private func progressHeadline(_ batch: PropagationBatch) -> String {
        switch batch.status {
        case .rooting: return batch.needsRootCheck ? "Check for roots" : "Rooting in progress"
        case .rooted: return "Roots established"
        case .acclimating:
            if let days = batch.daysUntilReady { return days == 0 ? "Ready any day now" : "\(days) days to ready" }
            return "Acclimating"
        case .readyForSale: return "Ready to sell 🎉"
        case .sold: return "Sold & complete"
        }
    }

    private func progressSubtitle(_ batch: PropagationBatch) -> String {
        switch batch.status {
        case .rooting:
            return "Started \(batch.daysSinceStart) days ago · typical for \(batch.method.title.lowercased()): ~\(batch.method.estimatedRootingDays) days."
        case .rooted:
            return "Rooted \(batch.rootedDate?.relativeShort() ?? "recently"). Move to acclimating when potted up."
        case .acclimating:
            if let ready = batch.readyDate { return "Estimated ready around \(ready.mediumString())." }
            return "Hardening off before sale."
        case .readyForSale:
            return "\(batch.survivingCount) plants ready at a \(batch.successPercent)% success rate."
        case .sold:
            return "Final success rate \(batch.successPercent)%. Nice work!"
        }
    }

    private func advanceButton(_ batch: PropagationBatch, title: String) -> some View {
        Button {
            Haptics.success()
            store.advanceStatus(batch.id)
        } label: {
            Label(title, systemImage: batch.status.next?.icon ?? "arrow.right")
        }
        .buttonStyle(PrimaryButtonStyle(tint: batch.status.next?.tint ?? AppTheme.primary))
    }

    private func quickActions(_ batch: PropagationBatch) -> some View {
        HStack(spacing: Spacing.sm) {
            quickAction(title: "Water", icon: "drop.fill", tint: AppTheme.info) {
                Haptics.tap()
                store.water(batch.id)
            }
            quickAction(title: "Log", icon: "square.and.pencil", tint: AppTheme.primary) {
                logPreset = .note
                showLog = true
            }
            quickAction(title: "Record loss", icon: "exclamationmark.triangle.fill", tint: CareEventType.loss.tint) {
                logPreset = .loss
                showLog = true
            }
        }
    }

    private func quickAction(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func statsGrid(_ batch: PropagationBatch) -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: Spacing.md) {
            InfoPill(icon: "calendar", label: "Started", value: batch.startDate.mediumString(), tint: AppTheme.primary)
            InfoPill(icon: "clock.fill", label: "Age", value: "\(batch.daysSinceStart) days", tint: AppTheme.info)
            InfoPill(icon: "chart.line.uptrend.xyaxis", label: "Success", value: "\(batch.successPercent)%", tint: AppTheme.primary)
            InfoPill(icon: "leaf.fill", label: "Surviving", value: "\(batch.survivingCount)/\(batch.initialCount)", tint: AppTheme.accent)
            InfoPill(icon: "drop.fill", label: "Next water", value: batch.needsWateringSchedule ? batch.nextWateringDate.relativeShort() : "—", tint: AppTheme.info)
            InfoPill(icon: "tag.fill", label: "Est. ready", value: readyValue(batch), tint: AppTheme.accent)
        }
    }

    private func readyValue(_ batch: PropagationBatch) -> String {
        if batch.status == .sold { return "Sold" }
        if batch.isReadyForSale { return "Now" }
        if let ready = batch.readyDate { return ready.mediumString() }
        return "After rooting"
    }

    private func lifecycleCard(_ batch: PropagationBatch) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Lifecycle")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            VStack(spacing: 0) {
                let stages = BatchStatus.allCases
                ForEach(Array(stages.enumerated()), id: \.element) { index, stage in
                    HStack(spacing: Spacing.md) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(stage.sortIndex <= batch.status.sortIndex ? stage.tint : AppTheme.surfaceAlt)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: stage.sortIndex <= batch.status.sortIndex ? "checkmark" : stage.icon)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(stage.sortIndex <= batch.status.sortIndex ? .white : AppTheme.textSecondary)
                                )
                            if index < stages.count - 1 {
                                Rectangle()
                                    .fill(stage.sortIndex < batch.status.sortIndex ? stage.tint : AppTheme.surfaceAlt)
                                    .frame(width: 2, height: 28)
                            }
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text(stage.title)
                                .font(.system(size: 14, weight: stage == batch.status ? .bold : .medium, design: .rounded))
                                .foregroundStyle(stage.sortIndex <= batch.status.sortIndex ? AppTheme.textPrimary : AppTheme.textSecondary)
                            if stage == batch.status {
                                Text("Current stage")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(stage.tint)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .cardStyle()
    }

    private func notesCard(_ batch: PropagationBatch) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Notes")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Text(batch.notes)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardStyle()
    }

    private func timelineCard(_ batch: PropagationBatch) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Timeline")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button {
                    logPreset = .note
                    showLog = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.primary)
            }
            if batch.timeline.isEmpty {
                Text("No events yet.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                ForEach(batch.timeline) { event in
                    HStack(alignment: .top, spacing: Spacing.md) {
                        Image(systemName: event.type.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(event.type.tint)
                            .frame(width: 32, height: 32)
                            .background(event.type.tint.opacity(0.15), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.type.title)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)
                            if !event.note.isEmpty {
                                Text(event.note)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        Spacer()
                        Text(event.date.relativeShort())
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
        .cardStyle()
    }

    private var removedPlaceholder: some View {
        EmptyStateView(
            icon: "leaf.fill",
            title: "Batch removed",
            message: "This batch is no longer available."
        )
    }

    private func shareText(for batch: PropagationBatch) -> String {
        """
        🌱 \(batch.name) — \(batch.species)
        Method: \(batch.method.title)
        Status: \(batch.status.title)
        Surviving: \(batch.survivingCount)/\(batch.initialCount) (\(batch.successPercent)%)
        Started: \(batch.startDate.mediumString())
        Tracked with Chikagation Tracker.
        """
    }
}

#Preview {
    NavigationStack {
        BatchDetailView(batchID: SampleData.batches[0].id)
            .environmentObject({
                let s = AppStore()
                return s
            }())
    }
}
