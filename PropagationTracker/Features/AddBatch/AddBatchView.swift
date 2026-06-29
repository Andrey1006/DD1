import SwiftUI

struct AddBatchView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject private var store: AppStore

    @State private var draft = BatchDraft()
    @State private var showConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    introCard
                    BatchFormFields(draft: $draft, existingSpecies: existingSpecies)
                    saveButton
                }
                .padding(Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
            .background(AppBackground())
            .navigationTitle("New Batch")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") { draft = BatchDraft() }
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .overlay(alignment: .top) {
                if showConfirmation { savedToast }
            }
        }
    }

    private var existingSpecies: [String] {
        Array(Set(store.batches.map { $0.species })).sorted()
    }

    private var introCard: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(AppTheme.accentGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text("Start a propagation")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Fill in the details and we'll track the rest.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
        }
        .cardStyle()
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Label("Save Batch", systemImage: "checkmark.circle.fill")
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!draft.isValid)
        .opacity(draft.isValid ? 1 : 0.5)
    }

    private var savedToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
            Text("Batch saved")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 10)
        .background(AppTheme.primary, in: Capsule())
        .shadow(radius: 8, y: 4)
        .padding(.top, Spacing.sm)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func save() {
        guard draft.isValid else { return }
        Haptics.success()
        store.add(draft.makeBatch())
        draft = BatchDraft()
        withAnimation { showConfirmation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation { showConfirmation = false }
            selectedTab = 1
        }
    }
}

struct EditBatchSheet: View {
    let batchID: UUID
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var draft: BatchDraft

    init(batch: PropagationBatch) {
        self.batchID = batch.id
        _draft = State(initialValue: BatchDraft(from: batch))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                BatchFormFields(draft: $draft, existingSpecies: existingSpecies)
                    .padding(Spacing.md)
                    .padding(.bottom, Spacing.xl)
            }
            .background(AppBackground())
            .navigationTitle("Edit Batch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!draft.isValid)
                }
            }
        }
    }

    private var existingSpecies: [String] {
        Array(Set(store.batches.map { $0.species })).sorted()
    }

    private func save() {
        guard var batch = store.batch(id: batchID) else { dismiss(); return }
        draft.apply(to: &batch)
        store.update(batch)
        Haptics.success()
        dismiss()
    }
}

#Preview {
    AddBatchView(selectedTab: .constant(2))
        .environmentObject(AppStore())
}
