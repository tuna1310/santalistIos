import Foundation
import SwiftData

/// Recipient model in the gift tracking list
@Model
public final class Person: Identifiable {
    public var id: UUID = UUID()
    public var name: String = ""
    public var budget: Int = 0
    public var note: String = ""

    @Relationship(deleteRule: .cascade, inverse: \Gift.person)
    public var gifts: [Gift] = []

    public init(
        id: UUID = UUID(),
        name: String,
        budget: Int = 0,
        note: String = "",
        gifts: [Gift] = []
    ) {
        self.id = id
        self.name = name
        self.budget = max(0, budget)
        self.note = note
        self.gifts = gifts
    }

    /// Planned total value of all gifts for this recipient
    public var plannedAmount: Int {
        gifts.reduce(0) { $0 + $1.price }
    }

    public var totalGiftsPrice: Int {
        plannedAmount
    }

    /// Actual spent amount (gifts with status Ordered or higher)
    public var spentAmount: Int {
        gifts.filter { $0.status.isCountedAsSpent }.reduce(0) { $0 + $1.price }
    }

    /// Remaining budget: Budget - Planned
    public var remainingBudget: Int {
        budget - plannedAmount
    }

    public var remainingAmount: Int {
        remainingBudget
    }

    /// Whether this recipient's planned gifts exceed their budget
    public var isOverBudget: Bool {
        plannedAmount > budget
    }

    /// Budget progress ratio (0.0 to 1.0+)
    public var budgetProgress: Double {
        guard budget > 0 else {
            return plannedAmount > 0 ? 1.0 : 0.0
        }
        return Double(plannedAmount) / Double(budget)
    }

    /// Number of finished gifts
    public var completedGiftsCount: Int {
        gifts.filter { $0.status.isCompleted }.count
    }
}
