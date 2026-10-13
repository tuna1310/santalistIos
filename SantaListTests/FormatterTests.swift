import XCTest
@testable import SantaList

final class FormatterTests: XCTestCase {
    func testVNDCurrencyFormatting() {
        XCTAssertEqual(Formatters.formatVND(1_250_000), "1.250.000 ₫")
        XCTAssertEqual(Formatters.formatVND(0), "0 ₫")
        XCTAssertEqual(Formatters.formatVND(650_000), "650.000 ₫")
        XCTAssertEqual(Formatters.formatVND(20_000_000), "20.000.000 ₫")
        XCTAssertEqual(Formatters.formatVND(-50_000), "-50.000 ₫")
    }

    func testRelativeDateFormatting() {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        XCTAssertEqual(Formatters.formatRelativeDate(today, referenceDate: today), "Today")
        XCTAssertEqual(Formatters.formatRelativeDate(tomorrow, referenceDate: today), "Tomorrow")
        XCTAssertEqual(Formatters.formatRelativeDate(yesterday, referenceDate: today), "Yesterday")
    }
}
