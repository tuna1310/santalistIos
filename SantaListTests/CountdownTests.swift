import XCTest
@testable import SantaList

final class CountdownTests: XCTestCase {
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }

    func testBeforeChristmasThisYear() {
        let refDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 20, hour: 10, minute: 0))!
        let target = ChristmasCountdown.nextChristmas(from: refDate, calendar: calendar)

        let targetYear = calendar.component(.year, from: target)
        let targetMonth = calendar.component(.month, from: target)
        let targetDay = calendar.component(.day, from: target)

        XCTAssertEqual(targetYear, 2026)
        XCTAssertEqual(targetMonth, 12)
        XCTAssertEqual(targetDay, 25)

        let days = ChristmasCountdown.daysRemaining(from: refDate, calendar: calendar)
        XCTAssertEqual(days, 5)

        let display = ChristmasCountdown.countdownText(from: refDate, calendar: calendar)
        XCTAssertEqual(display, "5 days until Christmas 🎄")
    }

    func testOnChristmasDay() {
        let refDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 25, hour: 8, minute: 30))!
        let days = ChristmasCountdown.daysRemaining(from: refDate, calendar: calendar)
        XCTAssertEqual(days, 0)

        let display = ChristmasCountdown.countdownText(from: refDate, calendar: calendar)
        XCTAssertEqual(display, "Today is Christmas! 🎄")
    }

    func testAfterChristmasRollsOverToNextYear() {
        let refDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 26, hour: 12, minute: 0))!
        let target = ChristmasCountdown.nextChristmas(from: refDate, calendar: calendar)

        let targetYear = calendar.component(.year, from: target)
        let targetMonth = calendar.component(.month, from: target)
        let targetDay = calendar.component(.day, from: target)

        XCTAssertEqual(targetYear, 2027)
        XCTAssertEqual(targetMonth, 12)
        XCTAssertEqual(targetDay, 25)

        let days = ChristmasCountdown.daysRemaining(from: refDate, calendar: calendar)
        XCTAssertEqual(days, 364)
    }

    func testOneDayBeforeChristmasDisplay() {
        let refDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 24, hour: 14, minute: 0))!
        let display = ChristmasCountdown.countdownText(from: refDate, calendar: calendar)
        XCTAssertEqual(display, "1 day until Christmas 🎅")
    }
}
