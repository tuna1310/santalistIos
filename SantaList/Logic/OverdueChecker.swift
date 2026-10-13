import Foundation

/// Timeline sorting and overdue evaluation logic
public struct OverdueChecker {
    /// Checks whether a gift is overdue (due date < today and not completed)
    public static func isOverdue(
        dueDate: Date?,
        status: GiftStatus,
        referenceDate: Date = Date(),
        calendar: Calendar = Calendar.current
    ) -> Bool {
        guard let dueDate = dueDate else { return false }
        if status.isCompleted {
            return false
        }

        let startOfToday = calendar.startOfDay(for: referenceDate)
        let startOfDue = calendar.startOfDay(for: dueDate)
        return startOfDue < startOfToday
    }

    /// Sort comparator for timeline: due date ascending, nil dates at the end
    public static func compareForTimeline(
        _ giftA: Gift,
        _ giftB: Gift
    ) -> Bool {
        switch (giftA.dueDate, giftB.dueDate) {
        case let (.some(dateA), .some(dateB)):
            if dateA != dateB {
                return dateA < dateB
            }
            return giftA.title.localizedStandardCompare(giftB.title) == .orderedAscending
        case (.some, .none):
            return true
        case (.none, .some):
            return false
        case (.none, .none):
            return giftA.title.localizedStandardCompare(giftB.title) == .orderedAscending
        }
    }
}
