import SwiftUI

enum PropagationMethod: String, Codable, CaseIterable, Identifiable, Hashable {
    case cuttings
    case layering
    case division

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cuttings: return "Cuttings"
        case .layering: return "Layering"
        case .division: return "Division"
        }
    }

    var icon: String {
        switch self {
        case .cuttings: return "scissors"
        case .layering: return "arrow.triangle.branch"
        case .division: return "square.split.2x1.fill"
        }
    }

    var blurb: String {
        switch self {
        case .cuttings: return "Snip a stem or leaf and root it in water or soil."
        case .layering: return "Root a stem while it's still attached to the parent."
        case .division: return "Split a mature clump into several rooted plants."
        }
    }

    var tint: Color {
        switch self {
        case .cuttings: return AppTheme.primary
        case .layering: return AppTheme.info
        case .division: return AppTheme.gold
        }
    }

    var estimatedRootingDays: Int {
        switch self {
        case .cuttings: return 21
        case .layering: return 35
        case .division: return 14
        }
    }
}

enum BatchStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case rooting
    case rooted
    case acclimating
    case readyForSale
    case sold

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rooting: return "Rooting"
        case .rooted: return "Rooted"
        case .acclimating: return "Acclimating"
        case .readyForSale: return "Ready to Sell"
        case .sold: return "Sold"
        }
    }

    var icon: String {
        switch self {
        case .rooting: return "drop.fill"
        case .rooted: return "leaf.fill"
        case .acclimating: return "sun.max.fill"
        case .readyForSale: return "tag.fill"
        case .sold: return "checkmark.seal.fill"
        }
    }

    var tint: Color {
        switch self {
        case .rooting: return AppTheme.info
        case .rooted: return AppTheme.primary
        case .acclimating: return AppTheme.gold
        case .readyForSale: return AppTheme.accent
        case .sold: return Color(hex: 0x7A8A80)
        }
    }

    var sortIndex: Int {
        switch self {
        case .rooting: return 0
        case .rooted: return 1
        case .acclimating: return 2
        case .readyForSale: return 3
        case .sold: return 4
        }
    }

    var next: BatchStatus? {
        switch self {
        case .rooting: return .rooted
        case .rooted: return .acclimating
        case .acclimating: return .readyForSale
        case .readyForSale: return .sold
        case .sold: return nil
        }
    }

    var advanceActionTitle: String? {
        switch self {
        case .rooting: return "Mark Rooted"
        case .rooted: return "Start Acclimating"
        case .acclimating: return "Mark Ready to Sell"
        case .readyForSale: return "Mark as Sold"
        case .sold: return nil
        }
    }

    var isActive: Bool { self != .sold }
}

enum CareEventType: String, Codable, CaseIterable, Identifiable, Hashable {
    case watered
    case fertilized
    case rootCheck
    case repotted
    case loss
    case statusChange
    case note

    var id: String { rawValue }

    var title: String {
        switch self {
        case .watered: return "Watered"
        case .fertilized: return "Fertilized"
        case .rootCheck: return "Root Check"
        case .repotted: return "Repotted"
        case .loss: return "Loss Recorded"
        case .statusChange: return "Status Changed"
        case .note: return "Note"
        }
    }

    var icon: String {
        switch self {
        case .watered: return "drop.fill"
        case .fertilized: return "leaf.circle.fill"
        case .rootCheck: return "magnifyingglass"
        case .repotted: return "arrow.up.bin.fill"
        case .loss: return "exclamationmark.triangle.fill"
        case .statusChange: return "arrow.right.circle.fill"
        case .note: return "text.bubble.fill"
        }
    }

    var tint: Color {
        switch self {
        case .watered: return AppTheme.info
        case .fertilized: return AppTheme.primary
        case .rootCheck: return AppTheme.gold
        case .repotted: return AppTheme.accent
        case .loss: return Color(hex: 0xC0463E)
        case .statusChange: return AppTheme.primaryDeep
        case .note: return AppTheme.textSecondary
        }
    }

    static var loggable: [CareEventType] {
        [.watered, .fertilized, .rootCheck, .repotted, .loss, .note]
    }
}

struct CareEvent: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var type: CareEventType
    var note: String
    var quantity: Int?

    init(id: UUID = UUID(), date: Date = Date(), type: CareEventType, note: String = "", quantity: Int? = nil) {
        self.id = id
        self.date = date
        self.type = type
        self.note = note
        self.quantity = quantity
    }
}

struct PropagationBatch: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var species: String
    var method: PropagationMethod
    var status: BatchStatus
    var startDate: Date
    var rootedDate: Date?
    var initialCount: Int
    var survivingCount: Int
    var acclimationDays: Int
    var wateringIntervalDays: Int
    var lastWateredDate: Date?
    var notes: String
    var events: [CareEvent]
    var photo: Data?

    init(
        id: UUID = UUID(),
        name: String,
        species: String,
        method: PropagationMethod,
        status: BatchStatus = .rooting,
        startDate: Date = Date(),
        rootedDate: Date? = nil,
        initialCount: Int,
        survivingCount: Int? = nil,
        acclimationDays: Int = 21,
        wateringIntervalDays: Int = 3,
        lastWateredDate: Date? = nil,
        notes: String = "",
        events: [CareEvent] = [],
        photo: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.method = method
        self.status = status
        self.startDate = startDate
        self.rootedDate = rootedDate
        self.initialCount = initialCount
        self.survivingCount = survivingCount ?? initialCount
        self.acclimationDays = acclimationDays
        self.wateringIntervalDays = wateringIntervalDays
        self.lastWateredDate = lastWateredDate
        self.notes = notes
        self.events = events
        self.photo = photo
    }
}

extension PropagationBatch {
    var successRate: Double {
        guard initialCount > 0 else { return 0 }
        return Double(survivingCount) / Double(initialCount)
    }

    var successPercent: Int { Int((successRate * 100).rounded()) }

    var lostCount: Int { max(0, initialCount - survivingCount) }

    var daysSinceStart: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
    }

    var nextWateringDate: Date {
        let base = lastWateredDate ?? startDate
        return Calendar.current.date(byAdding: .day, value: wateringIntervalDays, to: base) ?? base
    }

    var needsWateringSchedule: Bool {
        status == .rooting || status == .rooted || status == .acclimating
    }

    var isWateringDue: Bool {
        needsWateringSchedule && nextWateringDate <= Date()
    }

    var readyDate: Date? {
        guard let rootedDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: acclimationDays, to: rootedDate)
    }

    var isReadyForSale: Bool {
        if status == .readyForSale { return true }
        if status == .acclimating, let readyDate { return readyDate <= Date() }
        return false
    }

    var needsRootCheck: Bool {
        status == .rooting && daysSinceStart >= method.estimatedRootingDays
    }

    var progress: Double {
        switch status {
        case .rooting:
            let frac = Double(daysSinceStart) / Double(max(1, method.estimatedRootingDays))
            return min(0.45, max(0.04, frac * 0.45))
        case .rooted:
            return 0.55
        case .acclimating:
            guard let rootedDate, let readyDate else { return 0.7 }
            let total = readyDate.timeIntervalSince(rootedDate)
            let done = Date().timeIntervalSince(rootedDate)
            let frac = total > 0 ? done / total : 1
            return min(0.97, 0.6 + max(0, frac) * 0.37)
        case .readyForSale:
            return 1.0
        case .sold:
            return 1.0
        }
    }

    var daysUntilReady: Int? {
        guard let readyDate, !isReadyForSale else { return nil }
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: readyDate).day ?? 0)
    }

    var timeline: [CareEvent] {
        events.sorted { $0.date > $1.date }
    }
}
