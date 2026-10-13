import Foundation
import UserNotifications

/// Service for managing local gift notifications (9:00 AM 1 day before due date)
public final class ReminderService: @unchecked Sendable {
    public static let shared = ReminderService()

    private let center: UNUserNotificationCenter

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    /// Request notification authorization
    @discardableResult
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error requesting notification authorization: \(error.localizedDescription)")
            return false
        }
    }

    /// Schedule or cancel reminder based on gift status and deadline
    public func updateReminder(for gift: Gift) {
        let identifier = gift.notificationIdentifier

        // 1. Cancel existing notification
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        // 2. Only schedule if gift is not completed and has a due date
        guard !gift.status.isCompleted, let dueDate = gift.dueDate else {
            return
        }

        let calendar = Calendar.current
        guard let dayBefore = calendar.date(byAdding: .day, value: -1, to: dueDate) else {
            return
        }

        var triggerComponents = calendar.dateComponents([.year, .month, .day], from: dayBefore)
        triggerComponents.hour = 9
        triggerComponents.minute = 0
        triggerComponents.second = 0

        guard let scheduledDate = calendar.date(from: triggerComponents) else {
            return
        }

        // Do not schedule if trigger time has already passed
        if scheduledDate < Date() {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Gift Reminder: \(gift.title)"
        let recipientName = gift.person?.name.isEmpty == false ? gift.person!.name : "your recipient"
        content.body = "Deadline is tomorrow! For \(recipientName)."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification \(identifier): \(error.localizedDescription)")
            }
        }
    }

    public func scheduleReminder(for gift: Gift) {
        updateReminder(for: gift)
    }

    public func cancelReminder(for identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    public func cancelReminder(for id: UUID) {
        cancelReminder(for: "gift-\(id.uuidString)")
    }

    public func cancelReminder(for gift: Gift) {
        cancelReminder(for: gift.notificationIdentifier)
    }

    public func cancelReminders(for gifts: [Gift]) {
        let identifiers = gifts.map { $0.notificationIdentifier }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}
