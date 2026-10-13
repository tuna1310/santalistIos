import Foundation

/// Formatting utility for currency and dates
public struct Formatters {
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "dd MMM"
        return formatter
    }()

    /// Currency format with dot grouping: "1.250.000 ₫", "0 ₫", "-100.000 ₫"
    public static func formatVND(_ amount: Int) -> String {
        let formattedNumber = currencyFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formattedNumber) ₫"
    }

    /// Full date: "15/12/2026"
    public static func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    /// Short date: "15 Dec"
    public static func formatShortDate(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }

    /// Contextual relative date: "Today", "Tomorrow", "Yesterday", or formatted date
    public static func formatRelativeDate(_ date: Date, referenceDate: Date = Date()) -> String {
        let calendar = Calendar.current
        let startOfRef = calendar.startOfDay(for: referenceDate)
        let startOfTarget = calendar.startOfDay(for: date)

        guard let days = calendar.dateComponents([.day], from: startOfRef, to: startOfTarget).day else {
            return formatDate(date)
        }

        switch days {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        case -1:
            return "Yesterday"
        default:
            return formatShortDate(date)
        }
    }
}
