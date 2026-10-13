import Foundation

/// Overall budget summary statistics
public struct BudgetSummary: Equatable, Sendable {
    public let totalBudget: Int
    public let projectedTotal: Int
    public let spentTotal: Int
    public let remainingBudget: Int
    public let isOverBudget: Bool

    public init(
        totalBudget: Int = 0,
        projectedTotal: Int = 0,
        spentTotal: Int = 0,
        remainingBudget: Int = 0,
        isOverBudget: Bool = false
    ) {
        self.totalBudget = totalBudget
        self.projectedTotal = projectedTotal
        self.spentTotal = spentTotal
        self.remainingBudget = remainingBudget
        self.isOverBudget = isOverBudget
    }
}

/// Per-person budget summary
public struct PersonBudgetSummary: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let budget: Int
    public let projected: Int
    public let spent: Int
    public let remaining: Int
    public let isOverBudget: Bool
    public let progress: Double

    public init(
        id: UUID,
        name: String,
        budget: Int,
        projected: Int,
        spent: Int,
        remaining: Int,
        isOverBudget: Bool,
        progress: Double
    ) {
        self.id = id
        self.name = name
        self.budget = budget
        self.projected = projected
        self.spent = spent
        self.remaining = remaining
        self.isOverBudget = isOverBudget
        self.progress = progress
    }
}

/// Budget calculator utility
public struct BudgetCalculator {
    public static func totalBudget(people: [Person]) -> Int {
        people.reduce(0) { $0 + max(0, $1.budget) }
    }

    public static func totalPlanned(gifts: [Gift]) -> Int {
        gifts.reduce(0) { $0 + max(0, $1.price) }
    }

    public static func totalSpent(gifts: [Gift]) -> Int {
        gifts.filter { $0.status.isCountedAsSpent }.reduce(0) { $0 + max(0, $1.price) }
    }

    public static func totalRemaining(people: [Person], gifts: [Gift]) -> Int {
        totalBudget(people: people) - totalPlanned(gifts: gifts)
    }

    public static func isOverBudget(people: [Person], gifts: [Gift]) -> Bool {
        totalRemaining(people: people, gifts: gifts) < 0
    }

    public static func calculate(people: [Person]) -> BudgetSummary {
        let budget = totalBudget(people: people)
        var allGifts: [Gift] = []
        for p in people {
            allGifts.append(contentsOf: p.gifts)
        }
        let planned = totalPlanned(gifts: allGifts)
        let spent = totalSpent(gifts: allGifts)
        let remaining = budget - planned

        return BudgetSummary(
            totalBudget: budget,
            projectedTotal: planned,
            spentTotal: spent,
            remainingBudget: remaining,
            isOverBudget: remaining < 0
        )
    }

    public static func calculatePerPerson(people: [Person]) -> [PersonBudgetSummary] {
        people.map { person in
            let budget = max(0, person.budget)
            let projected = person.plannedAmount
            let spent = person.spentAmount
            let remaining = budget - projected
            let isOver = projected > budget
            let progress = budget > 0 ? (Double(projected) / Double(budget)) : (projected > 0 ? 1.0 : 0.0)

            return PersonBudgetSummary(
                id: person.id,
                name: person.name,
                budget: budget,
                projected: projected,
                spent: spent,
                remaining: remaining,
                isOverBudget: isOver,
                progress: progress
            )
        }
    }
}
