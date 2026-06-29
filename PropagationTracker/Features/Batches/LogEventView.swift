import SwiftUI

struct LogEventView: View {
    let batchID: UUID
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var type: CareEventType
    @State private var note: String = ""
    @State private var lossCount: Int = 1
    @State private var date: Date = Date()

    init(batchID: UUID, presetType: CareEventType = .watered) {
        self.batchID = batchID
        _type = State(initialValue: presetType)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    typeGrid

                    formCard(title: "Details", icon: "square.and.pencil") {
                        DatePicker("Date", selection: $date, in: ...Date())
                            .font(.system(size: 15, design: .rounded))
                            .tint(AppTheme.primary)

                        if type == .loss {
                            Divider()
                            HStack {
                                Text("How many lost?")
                                    .font(.system(size: 15, design: .rounded))
                                Spacer()
                                Text("\(lossCount)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(CareEventType.loss.tint)
                                Stepper("", value: $lossCount, in: 1...max(1, survivingCount))
                                    .labelsHidden()
                            }
                        }

                        Divider()
                        AppTextField(title: "Note (optional)", placeholder: placeholder,
                                     text: $note, multiline: true)
                    }
                }
                .padding(Spacing.md)
            }
            .background(AppBackground())
            .navigationTitle("Log Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var survivingCount: Int {
        store.batch(id: batchID)?.survivingCount ?? 1
    }

    private var placeholder: String {
        switch type {
        case .watered: return "Top-up, misting, bottom-watered…"
        case .fertilized: return "Which feed, what dilution…"
        case .rootCheck: return "Root length, condition…"
        case .repotted: return "Pot size, soil mix…"
        case .loss: return "What happened — rot, pests…"
        case .note, .statusChange: return "Anything worth remembering…"
        }
    }

    private var typeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
            ForEach(CareEventType.loggable) { eventType in
                Button {
                    Haptics.tap()
                    type = eventType
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: eventType.icon)
                            .font(.system(size: 18, weight: .semibold))
                        Text(eventType.title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(type == eventType ? .white : eventType.tint)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(type == eventType ? AnyShapeStyle(eventType.tint) : AnyShapeStyle(eventType.tint.opacity(0.12)))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func formCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppTheme.primary)
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            content()
        }
        .cardStyle()
    }

    private func save() {
        if type == .loss {
            store.recordLoss(lossCount, for: batchID, note: note)
            Haptics.warning()
        } else {
            if type == .watered {
                if var batch = store.batch(id: batchID) {
                    batch.lastWateredDate = date
                    store.update(batch)
                }
            }
            store.addEvent(CareEvent(date: date, type: type, note: note), to: batchID)
            Haptics.success()
        }
        dismiss()
    }
}

#Preview {
    LogEventView(batchID: UUID())
        .environmentObject(AppStore())
}
