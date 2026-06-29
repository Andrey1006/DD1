import Foundation

enum SampleData {
    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    static var batches: [PropagationBatch] {
        [
            PropagationBatch(
                name: "Monstera Albo #3",
                species: "Monstera deliciosa",
                method: .cuttings,
                status: .rooting,
                startDate: daysAgo(24),
                initialCount: 6,
                survivingCount: 5,
                acclimationDays: 21,
                wateringIntervalDays: 3,
                lastWateredDate: daysAgo(4),
                notes: "Node cuttings in sphagnum moss. Keep humidity high.",
                events: [
                    CareEvent(date: daysAgo(24), type: .note, note: "Took 6 node cuttings from mother plant."),
                    CareEvent(date: daysAgo(18), type: .watered, note: "Misted moss."),
                    CareEvent(date: daysAgo(10), type: .loss, note: "One cutting rotted", quantity: 1)
                ]
            ),

            PropagationBatch(
                name: "Pothos Marble Queen",
                species: "Epipremnum aureum",
                method: .cuttings,
                status: .rooted,
                startDate: daysAgo(30),
                rootedDate: daysAgo(5),
                initialCount: 10,
                survivingCount: 9,
                acclimationDays: 18,
                wateringIntervalDays: 4,
                lastWateredDate: daysAgo(2),
                notes: "Water propagation — strong white roots.",
                events: [
                    CareEvent(date: daysAgo(30), type: .note, note: "10 cuttings in water jar."),
                    CareEvent(date: daysAgo(5), type: .statusChange, note: "Moved to Rooted"),
                    CareEvent(date: daysAgo(2), type: .watered, note: "Topped up water.")
                ]
            ),

            PropagationBatch(
                name: "Snake Plant Division A",
                species: "Sansevieria trifasciata",
                method: .division,
                status: .acclimating,
                startDate: daysAgo(48),
                rootedDate: daysAgo(20),
                initialCount: 4,
                survivingCount: 4,
                acclimationDays: 21,
                wateringIntervalDays: 7,
                lastWateredDate: daysAgo(8),
                notes: "Divided rhizome into 4 potted-up plants.",
                events: [
                    CareEvent(date: daysAgo(48), type: .note, note: "Split mother into 4 sections."),
                    CareEvent(date: daysAgo(20), type: .repotted, note: "Potted into 4\" nursery pots."),
                    CareEvent(date: daysAgo(8), type: .watered, note: "Light watering.")
                ]
            ),

            PropagationBatch(
                name: "String of Hearts Batch 1",
                species: "Ceropegia woodii",
                method: .cuttings,
                status: .readyForSale,
                startDate: daysAgo(70),
                rootedDate: daysAgo(45),
                initialCount: 8,
                survivingCount: 7,
                acclimationDays: 21,
                wateringIntervalDays: 6,
                lastWateredDate: daysAgo(3),
                notes: "Full, established trailers. Priced at $12 each.",
                events: [
                    CareEvent(date: daysAgo(70), type: .note, note: "8 strand cuttings laid on soil."),
                    CareEvent(date: daysAgo(45), type: .statusChange, note: "Moved to Rooted"),
                    CareEvent(date: daysAgo(20), type: .fertilized, note: "Diluted feed."),
                    CareEvent(date: daysAgo(10), type: .statusChange, note: "Moved to Ready to Sell")
                ]
            ),

            PropagationBatch(
                name: "Fiddle Leaf Air-Layer",
                species: "Ficus lyrata",
                method: .layering,
                status: .rooting,
                startDate: daysAgo(28),
                initialCount: 2,
                survivingCount: 2,
                acclimationDays: 30,
                wateringIntervalDays: 5,
                lastWateredDate: daysAgo(1),
                notes: "Air-layered two branches with moss + wrap.",
                events: [
                    CareEvent(date: daysAgo(28), type: .note, note: "Wrapped moss around scored stems."),
                    CareEvent(date: daysAgo(1), type: .watered, note: "Re-moistened moss.")
                ]
            ),

            PropagationBatch(
                name: "ZZ Plant Division (Spring)",
                species: "Zamioculcas zamiifolia",
                method: .division,
                status: .sold,
                startDate: daysAgo(120),
                rootedDate: daysAgo(95),
                initialCount: 5,
                survivingCount: 5,
                acclimationDays: 21,
                wateringIntervalDays: 10,
                lastWateredDate: daysAgo(40),
                notes: "All 5 sold at the spring market.",
                events: [
                    CareEvent(date: daysAgo(120), type: .note, note: "Divided into 5."),
                    CareEvent(date: daysAgo(30), type: .statusChange, note: "Moved to Sold")
                ]
            )
        ]
    }
}
