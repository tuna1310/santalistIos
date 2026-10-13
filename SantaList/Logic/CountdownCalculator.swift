import Foundation

// For backwards compatibility
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
