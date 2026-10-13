import SwiftUI

/// Progress bar showing budget utilization with red warning when over budget
public struct BudgetProgressBar: View {
    public let planned: Int
    public let budget: Int

    public init(planned: Int, budget: Int) {
        self.planned = planned
        self.budget = budget
    }

    private var ratio: Double {
        guard budget > 0 else { return planned > 0 ? 1.0 : 0.0 }
        return Double(planned) / Double(budget)
    }

    private var isOver: Bool {
        planned > budget
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.18))
                        .frame(height: 8)

                    Capsule()
                        .fill(isOver ? Color("CranberryRed") : Color("PineGreen"))
                        .frame(width: max(0, min(geo.size.width * CGFloat(min(ratio, 1.0)), geo.size.width)), height: 8)
                        .animation(.easeInOut, value: ratio)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(Int(min(ratio * 100, 999)))% of budget")
                    .font(.caption2)
                    .foregroundStyle(isOver ? Color("CranberryRed") : Color("TextSecondary"))
                    .fontWeight(isOver ? .bold : .regular)

                Spacer()

                if isOver {
                    Text("Over by \(Formatters.formatVND(planned - budget))")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("CranberryRed"))
                } else {
                    Text("Remaining: \(Formatters.formatVND(budget - planned))")
                        .font(.caption2)
                        .foregroundStyle(Color("PineGreen"))
                }
            }
        }
    }
}

public struct ProgressBarView: View {
    public let progress: Double
    public let isOverBudget: Bool
    public var height: CGFloat = 8

    public init(progress: Double, isOverBudget: Bool, height: CGFloat = 8) {
        self.progress = progress
        self.isOverBudget = isOverBudget
        self.height = height
    }

    public var body: some View {
        BudgetProgressBar(planned: Int(progress * 100), budget: 100)
    }
}
