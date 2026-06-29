import SwiftUI
import Combine

enum CareTaskKind {
    case watering
    case rootCheck
    case readyForSale
    case sellNow

    var title: String {
        switch self {
        case .watering: return "Water"
        case .rootCheck: return "Check for roots"
        case .readyForSale: return "Move to ready"
        case .sellNow: return "Ready to sell"
        }
    }

    var icon: String {
        switch self {
        case .watering: return "drop.fill"
        case .rootCheck: return "magnifyingglass"
        case .readyForSale: return "sun.max.fill"
        case .sellNow: return "tag.fill"
        }
    }

    var tint: Color {
        switch self {
        case .watering: return AppTheme.info
        case .rootCheck: return AppTheme.gold
        case .readyForSale: return AppTheme.primary
        case .sellNow: return AppTheme.accent
        }
    }
}

struct CareTask: Identifiable {
    let id: String
    let batchID: UUID
    let kind: CareTaskKind
    let batchName: String
    let species: String

    var title: String { kind.title }
    var subtitle: String { "\(batchName) · \(species)" }
}

final class AppStore: ObservableObject {
    @Published var batches: [PropagationBatch] {
        didSet { persist() }
    }

    private let storageKey = "rooted.batches.v1"
    private let defaults = UserDefaults.standard

    init() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([PropagationBatch].self, from: data) {
            batches = decoded
        } else {
            batches = SampleData.batches
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(batches) {
            defaults.set(data, forKey: storageKey)
        }
    }

    func add(_ batch: PropagationBatch) {
        batches.insert(batch, at: 0)
    }

    func update(_ batch: PropagationBatch) {
        guard let index = batches.firstIndex(where: { $0.id == batch.id }) else { return }
        batches[index] = batch
    }

    func delete(_ batch: PropagationBatch) {
        batches.removeAll { $0.id == batch.id }
    }

    func delete(at offsets: IndexSet, in list: [PropagationBatch]) {
        let ids = offsets.map { list[$0].id }
        batches.removeAll { ids.contains($0.id) }
    }

    func batch(id: UUID) -> PropagationBatch? {
        batches.first { $0.id == id }
    }

    private func mutate(_ id: UUID, _ change: (inout PropagationBatch) -> Void) {
        guard let index = batches.firstIndex(where: { $0.id == id }) else { return }
        change(&batches[index])
    }

    func addEvent(_ event: CareEvent, to id: UUID) {
        mutate(id) { $0.events.append(event) }
    }

    func water(_ id: UUID) {
        mutate(id) { batch in
            batch.lastWateredDate = Date()
            batch.events.append(CareEvent(type: .watered, note: "Watered"))
        }
    }

    func recordLoss(_ count: Int, for id: UUID, note: String = "") {
        guard count > 0 else { return }
        mutate(id) { batch in
            batch.survivingCount = max(0, batch.survivingCount - count)
            batch.events.append(
                CareEvent(type: .loss, note: note.isEmpty ? "Lost \(count)" : note, quantity: count)
            )
        }
    }

    func advanceStatus(_ id: UUID) {
        mutate(id) { batch in
            guard let next = batch.status.next else { return }
            batch.status = next
            if next == .rooted, batch.rootedDate == nil {
                batch.rootedDate = Date()
            }
            batch.events.append(
                CareEvent(type: .statusChange, note: "Moved to \(next.title)")
            )
        }
    }

    func setStatus(_ status: BatchStatus, for id: UUID) {
        mutate(id) { batch in
            guard batch.status != status else { return }
            batch.status = status
            if status == .rooted, batch.rootedDate == nil {
                batch.rootedDate = Date()
            }
            batch.events.append(CareEvent(type: .statusChange, note: "Moved to \(status.title)"))
        }
    }

    var activeBatches: [PropagationBatch] {
        batches.filter { $0.status.isActive }
    }

    var sortedBatches: [PropagationBatch] {
        batches.sorted { lhs, rhs in
            if lhs.status.sortIndex != rhs.status.sortIndex {
                return lhs.status.sortIndex < rhs.status.sortIndex
            }
            return lhs.startDate > rhs.startDate
        }
    }

    var todaysTasks: [CareTask] {
        var tasks: [CareTask] = []
        for batch in batches where batch.status.isActive {
            if batch.status == .readyForSale {
                tasks.append(CareTask(id: "\(batch.id)-sell", batchID: batch.id, kind: .sellNow,
                                      batchName: batch.name, species: batch.species))
                continue
            }
            if batch.isReadyForSale {
                tasks.append(CareTask(id: "\(batch.id)-ready", batchID: batch.id, kind: .readyForSale,
                                      batchName: batch.name, species: batch.species))
            }
            if batch.needsRootCheck {
                tasks.append(CareTask(id: "\(batch.id)-root", batchID: batch.id, kind: .rootCheck,
                                      batchName: batch.name, species: batch.species))
            }
            if batch.isWateringDue {
                tasks.append(CareTask(id: "\(batch.id)-water", batchID: batch.id, kind: .watering,
                                      batchName: batch.name, species: batch.species))
            }
        }
        return tasks
    }

    var readyToSellBatches: [PropagationBatch] {
        batches.filter { $0.isReadyForSale }
    }

    var totalLivingPlants: Int {
        activeBatches.reduce(0) { $0 + $1.survivingCount }
    }

    var distinctSpeciesCount: Int {
        Set(batches.map { $0.species.lowercased() }).count
    }

    var overallSuccessRate: Double {
        let relevant = batches.filter { $0.status != .rooting }
        let initial = relevant.reduce(0) { $0 + $1.initialCount }
        let surviving = relevant.reduce(0) { $0 + $1.survivingCount }
        guard initial > 0 else { return 0 }
        return Double(surviving) / Double(initial)
    }

    var overallSuccessPercent: Int { Int((overallSuccessRate * 100).rounded()) }

    struct MethodStat: Identifiable {
        let method: PropagationMethod
        let batchCount: Int
        let initial: Int
        let surviving: Int
        var id: String { method.id }
        var successRate: Double { initial > 0 ? Double(surviving) / Double(initial) : 0 }
        var successPercent: Int { Int((successRate * 100).rounded()) }
    }

    func methodStats() -> [AppStore.MethodStat] {
        PropagationMethod.allCases.map { method in
            let group = batches.filter { $0.method == method && $0.status != .rooting }
            return MethodStat(
                method: method,
                batchCount: batches.filter { $0.method == method }.count,
                initial: group.reduce(0) { $0 + $1.initialCount },
                surviving: group.reduce(0) { $0 + $1.survivingCount }
            )
        }
    }

    struct SpeciesStat: Identifiable {
        let species: String
        let batchCount: Int
        let living: Int
        let successPercent: Int
        var id: String { species }
    }

    func speciesStats() -> [AppStore.SpeciesStat] {
        let groups = Dictionary(grouping: batches, by: { $0.species })
        return groups.map { species, items in
            let scored = items.filter { $0.status != .rooting }
            let initial = scored.reduce(0) { $0 + $1.initialCount }
            let surviving = scored.reduce(0) { $0 + $1.survivingCount }
            let percent = initial > 0 ? Int((Double(surviving) / Double(initial) * 100).rounded()) : 0
            let living = items.filter { $0.status.isActive }.reduce(0) { $0 + $1.survivingCount }
            return SpeciesStat(species: species, batchCount: items.count, living: living, successPercent: percent)
        }
        .sorted { $0.batchCount > $1.batchCount }
    }

    func statusCounts() -> [(status: BatchStatus, count: Int)] {
        BatchStatus.allCases.map { status in
            (status, batches.filter { $0.status == status }.count)
        }
    }

    func exportCSV() -> String {
        var rows = ["Name,Species,Method,Status,Started,Initial,Surviving,SuccessRate"]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for batch in sortedBatches {
            let fields = [
                batch.name,
                batch.species,
                batch.method.title,
                batch.status.title,
                formatter.string(from: batch.startDate),
                "\(batch.initialCount)",
                "\(batch.survivingCount)",
                "\(batch.successPercent)%"
            ].map { "\"\($0.replacingOccurrences(of: "\"", with: "'"))\"" }
            rows.append(fields.joined(separator: ","))
        }
        return rows.joined(separator: "\n")
    }
}
