import Foundation

/// Christmas countdown calculator for December 25th
public struct ChristmasCountdown {
    /// Next Christmas target date (rolls over to next year after Dec 25)
    public static func nextChristmas(from referenceDate: Date = Date(), calendar: Calendar = .current) -> Date {
        let currentYear = calendar.component(.year, from: referenceDate)
        var components = DateComponents(year: currentYear, month: 12, day: 25, hour: 0, minute: 0, second: 0)

        guard let targetThisYear = calendar.date(from: components) else {
            return referenceDate
        }

        let startOfToday = calendar.startOfDay(for: referenceDate)
        let startOfTargetThisYear = calendar.startOfDay(for: targetThisYear)

        if startOfToday > startOfTargetThisYear {
            components.year = currentYear + 1
            return calendar.date(from: components) ?? targetThisYear
        }

        return targetThisYear
    }

    /// Days remaining until the target Christmas date
    public static func daysRemaining(from referenceDate: Date = Date(), calendar: Calendar = .current) -> Int {
        let target = nextChristmas(from: referenceDate, calendar: calendar)
        let startOfToday = calendar.startOfDay(for: referenceDate)
        let startOfTarget = calendar.startOfDay(for: target)

        let diff = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
        return max(0, diff.day ?? 0)
    }

    /// Friendly English countdown string
    public static func countdownText(from referenceDate: Date = Date(), calendar: Calendar = .current) -> String {
        let days = daysRemaining(from: referenceDate, calendar: calendar)
        if days == 0 {
            return "Today is Christmas! 🎄"
        } else if days == 1 {
            return "1 day until Christmas 🎅"
        } else {
            return "\(days) days until Christmas 🎄"
        }
    }
}

public struct CountdownCalculator {
    public static func targetChristmasDate(from referenceDate: Date = Date(), calendar: Calendar = .current) -> Date {
        ChristmasCountdown.nextChristmas(from: referenceDate, calendar: calendar)
    }

    public static func daysRemaining(from referenceDate: Date = Date(), calendar: Calendar = .current) -> Int {
        ChristmasCountdown.daysRemaining(from: referenceDate, calendar: calendar)
    }

    public static func countdownDisplayString(from referenceDate: Date = Date(), calendar: Calendar = .current) -> String {
        ChristmasCountdown.countdownText(from: referenceDate, calendar: calendar)
    }
}
