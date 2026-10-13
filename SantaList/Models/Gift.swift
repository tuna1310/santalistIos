import Foundation
import SwiftData

/// Gift item model
@Model
public final class Gift: Identifiable {
    public var id: UUID = UUID()
    public var title: String = ""
    public var price: Int = 0
    public var statusRaw: String = GiftStatus.idea.rawValue
    public var dueDate: Date?
    public var occasionRaw: String = Occasion.christmas.rawValue
    public var note: String = ""
    public var url: String?

    public var person: Person?

    public init(
        id: UUID = UUID(),
        title: String,
        price: Int = 0,
        status: GiftStatus = .idea,
        dueDate: Date? = nil,
        occasion: Occasion = .christmas,
        note: String = "",
        url: String? = nil,
        person: Person? = nil
    ) {
        self.id = id
        self.title = title
        self.price = max(0, price)
        self.statusRaw = status.rawValue
        self.dueDate = dueDate
        self.occasionRaw = occasion.rawValue
        self.note = note
        self.url = url
        self.person = person
    }

    public var status: GiftStatus {
        get {
            GiftStatus(rawValue: statusRaw) ?? .idea
        }
        set {
            statusRaw = newValue.rawValue
        }
    }

    public var occasion: Occasion {
        get {
            Occasion(rawValue: occasionRaw) ?? .christmas
        }
        set {
            occasionRaw = newValue.rawValue
        }
    }

    /// Whether this gift is overdue (due < today and not yet Received or Wrapped)
    public func isOverdue(referenceDate: Date = Date()) -> Bool {
        guard let due = dueDate else { return false }
        if status.isCompleted {
            return false
        }
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: referenceDate)
        let startOfDue = calendar.startOfDay(for: due)
        return startOfDue < startOfToday
    }

    public var notificationIdentifier: String {
        "gift-\(id.uuidString)"
    }
}
