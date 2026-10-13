import Foundation
import SwiftData

/// Initial sample data seeder for first launch
public struct SeedData {
    public static let seededKey = "hasSeededInitialData"

    public static func seedInitialDataIfNeeded(context: ModelContext) {
        if UserDefaults.standard.bool(forKey: seededKey) {
            return
        }

        let descriptor = FetchDescriptor<Person>()
        if let count = try? context.fetchCount(descriptor), count > 0 {
            UserDefaults.standard.set(true, forKey: seededKey)
            return
        }

        seed(context: context)
        UserDefaults.standard.set(true, forKey: seededKey)
        UserDefaults.standard.set(true, forKey: "hasLoadedSampleData")
    }

    public static func seed(context: ModelContext, currentYear: Int = Calendar.current.component(.year, from: Date())) {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        // 1. Create 2 sample recipients
        let mom = Person(
            name: "Mom",
            budget: 2_000_000,
            note: "Most wonderful woman in the family"
        )

        let minh = Person(
            name: "Minh (best friend)",
            budget: 800_000,
            note: "Best friend from university"
        )

        context.insert(mom)
        context.insert(minh)

        // 2. Dates for the current year
        let dateDec15 = calendar.date(from: DateComponents(year: currentYear, month: 12, day: 15, hour: 9, minute: 0))
        let dateDec20 = calendar.date(from: DateComponents(year: currentYear, month: 12, day: 20, hour: 9, minute: 0))
        let dateDec10 = calendar.date(from: DateComponents(year: currentYear, month: 12, day: 10, hour: 9, minute: 0))

        // 3. Create 3 sample gifts
        let gift1 = Gift(
            title: "Cashmere scarf",
            price: 650_000,
            status: .ordered,
            dueDate: dateDec15,
            occasion: .christmas,
            note: "Light cream color, soft and warm cashmere",
            url: "https://example.com/scarf",
            person: mom
        )

        let gift2 = Gift(
            title: "Herbal tea set",
            price: 300_000,
            status: .idea,
            dueDate: dateDec20,
            occasion: .christmas,
            note: "Chamomile and mint relaxing tea",
            url: nil,
            person: mom
        )

        let gift3 = Gift(
            title: "Atomic Habits book",
            price: 220_000,
            status: .wrapped,
            dueDate: dateDec10,
            occasion: .christmas,
            note: "Hardcover edition with bookmark",
            url: "https://example.com/atomic-habits",
            person: minh
        )

        context.insert(gift1)
        context.insert(gift2)
        context.insert(gift3)

        mom.gifts.append(gift1)
        mom.gifts.append(gift2)
        minh.gifts.append(gift3)

        try? context.save()

        // Schedule local reminders
        ReminderService.shared.updateReminder(for: gift1)
        ReminderService.shared.updateReminder(for: gift2)
        ReminderService.shared.updateReminder(for: gift3)
    }
}

public typealias SampleDataLoader = SeedData
