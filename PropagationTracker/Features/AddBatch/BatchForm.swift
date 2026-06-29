import SwiftUI
import PhotosUI

struct BatchDraft {
    var name = ""
    var species = ""
    var method: PropagationMethod = .cuttings
    var status: BatchStatus = .rooting
    var startDate = Date()
    var rootedDate: Date? = nil
    var initialCount = 4
    var survivingCount = 4
    var acclimationDays = 21
    var wateringIntervalDays = 3
    var notes = ""
    var photoData: Data? = nil

    init() {}

    init(from batch: PropagationBatch) {
        name = batch.name
        species = batch.species
        method = batch.method
        status = batch.status
        startDate = batch.startDate
        rootedDate = batch.rootedDate
        initialCount = batch.initialCount
        survivingCount = batch.survivingCount
        acclimationDays = batch.acclimationDays
        wateringIntervalDays = batch.wateringIntervalDays
        notes = batch.notes
        photoData = batch.photo
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !species.trimmingCharacters(in: .whitespaces).isEmpty &&
        initialCount > 0
    }

    func makeBatch() -> PropagationBatch {
        PropagationBatch(
            name: name.trimmingCharacters(in: .whitespaces),
            species: species.trimmingCharacters(in: .whitespaces),
            method: method,
            status: status,
            startDate: startDate,
            rootedDate: status.sortIndex >= BatchStatus.rooted.sortIndex ? (rootedDate ?? startDate) : rootedDate,
            initialCount: initialCount,
            survivingCount: min(survivingCount, initialCount),
            acclimationDays: acclimationDays,
            wateringIntervalDays: wateringIntervalDays,
            notes: notes,
            events: [CareEvent(date: startDate, type: .note, note: "Batch created.")],
            photo: photoData
        )
    }

    func apply(to batch: inout PropagationBatch) {
        batch.name = name.trimmingCharacters(in: .whitespaces)
        batch.species = species.trimmingCharacters(in: .whitespaces)
        batch.method = method
        batch.status = status
        batch.startDate = startDate
        if status.sortIndex >= BatchStatus.rooted.sortIndex, batch.rootedDate == nil {
            batch.rootedDate = rootedDate ?? startDate
        } else {
            batch.rootedDate = rootedDate
        }
        batch.initialCount = initialCount
        batch.survivingCount = min(survivingCount, initialCount)
        batch.acclimationDays = acclimationDays
        batch.wateringIntervalDays = wateringIntervalDays
        batch.notes = notes
        batch.photo = photoData
    }
}

struct BatchFormFields: View {
    @Binding var draft: BatchDraft
    var existingSpecies: [String] = []
    @State private var photoItem: PhotosPickerItem? = nil

    private let commonSpecies = [
        "Monstera deliciosa", "Epipremnum aureum", "Sansevieria trifasciata",
        "Ceropegia woodii", "Ficus lyrata", "Philodendron", "Tradescantia zebrina"
    ]

    private var speciesSuggestions: [String] {
        var seen = Set<String>()
        return (existingSpecies + commonSpecies).filter { seen.insert($0.lowercased()).inserted }
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            photoSection
            detailsSection
            methodSection
            quantitySection
            scheduleSection
            notesSection
        }
        .onChange(of: photoItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let compressed = UIImage(data: data)?.jpegData(compressionQuality: 0.6) {
                    draft.photoData = compressed
                }
            }
        }
    }

    private var photoSection: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            ZStack {
                if let data = draft.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(AppTheme.primary)
                        Text("Add a photo")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.surfaceAlt)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(alignment: .bottomTrailing) {
                if draft.photoData != nil {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.white, AppTheme.primary)
                        .padding(Spacing.sm)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var detailsSection: some View {
        formCard(title: "Details", icon: "leaf.fill") {
            AppTextField(title: "Batch name", placeholder: "e.g. Monstera Albo #3",
                         text: $draft.name, icon: "leaf.fill", autocapitalization: .words)
            AppTextField(title: "Species", placeholder: "e.g. Monstera deliciosa",
                         text: $draft.species, icon: "magnifyingglass", autocapitalization: .words)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(speciesSuggestions.prefix(8), id: \.self) { name in
                        Button {
                            Haptics.tap()
                            draft.species = name
                        } label: {
                            Text(name)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppTheme.primary.opacity(0.1), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var methodSection: some View {
        formCard(title: "Method", icon: "scissors") {
            VStack(spacing: Spacing.sm) {
                ForEach(PropagationMethod.allCases) { method in
                    Button {
                        Haptics.tap()
                        draft.method = method
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: method.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(method.tint)
                                .frame(width: 38, height: 38)
                                .background(method.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(method.title)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text(method.blurb)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: draft.method == method ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundStyle(draft.method == method ? method.tint : AppTheme.textSecondary.opacity(0.4))
                        }
                        .padding(Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(draft.method == method ? method.tint.opacity(0.08) : .clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var quantitySection: some View {
        formCard(title: "Quantity", icon: "number") {
            stepperRow(title: "Started with", value: $draft.initialCount, range: 1...500) {
                if draft.survivingCount > draft.initialCount { draft.survivingCount = draft.initialCount }
            }
            Divider()
            stepperRow(title: "Surviving", value: $draft.survivingCount, range: 0...draft.initialCount)
            if draft.initialCount > 0 {
                HStack {
                    Text("Current success rate")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Text("\(Int((Double(draft.survivingCount) / Double(draft.initialCount) * 100).rounded()))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }

    private var scheduleSection: some View {
        formCard(title: "Schedule", icon: "calendar") {
            DatePicker(selection: $draft.startDate, in: ...Date(), displayedComponents: .date) {
                Text("Start date")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .tint(AppTheme.primary)
            Divider()
            statusPicker
            Divider()
            stepperRow(title: "Water every (days)", value: $draft.wateringIntervalDays, range: 1...30)
            Divider()
            stepperRow(title: "Acclimation (days)", value: $draft.acclimationDays, range: 1...120)
            Text("After rooting, plants acclimate for \(draft.acclimationDays) days before they're ready to sell.")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var statusPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Status")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
            Picker("Status", selection: $draft.status) {
                ForEach(BatchStatus.allCases) { status in
                    Text(status.title).tag(status)
                }
            }
            .pickerStyle(.menu)
            .tint(AppTheme.primary)
        }
    }

    private var notesSection: some View {
        formCard(title: "Notes", icon: "text.bubble.fill") {
            AppTextField(placeholder: "Soil mix, location, pricing…", text: $draft.notes, multiline: true)
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

    private func stepperRow(title: String, value: Binding<Int>, range: ClosedRange<Int>, onChange: @escaping () -> Void = {}) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Text("\(value.wrappedValue)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.primary)
                .frame(minWidth: 34)
            Stepper("", value: value, in: range)
                .labelsHidden()
                .onChange(of: value.wrappedValue) { _ in onChange() }
        }
    }
}
