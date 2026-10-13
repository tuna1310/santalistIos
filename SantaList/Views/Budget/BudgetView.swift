import SwiftUI
import SwiftData
import Charts

/// Tab 3: Budget tracking overview with KPI cards, Swift Charts, and per-person breakdown
public struct BudgetView: View {
    @Query(sort: \Person.name) private var people: [Person]
    @Query private var gifts: [Gift]

    public init() {}

    private var totalBudget: Int {
        BudgetCalculator.totalBudget(people: people)
    }

    private var totalPlanned: Int {
        BudgetCalculator.totalPlanned(gifts: gifts)
    }

    private var totalSpent: Int {
        BudgetCalculator.totalSpent(gifts: gifts)
    }

    private var totalRemaining: Int {
        BudgetCalculator.totalRemaining(people: people, gifts: gifts)
    }

    private var isOverallOverBudget: Bool {
        BudgetCalculator.isOverBudget(people: people, gifts: gifts)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeaderView()

                ScrollView {
                    VStack(spacing: 20) {
                        if people.isEmpty {
                            EmptyStateView(
                                title: "No Budget Data",
                                systemImage: "chart.bar.xaxis",
                                description: "Add recipients and set budgets to track your holiday spending."
                            )
                            .padding(.top, 40)
                        } else {
                            // 4 KPI Cards
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                KPICard(
                                    title: "Total Budget",
                                    amount: totalBudget,
                                    subtitle: "Sum of all budgets",
                                    icon: "wallet.pass.fill",
                                    color: Color("PineGreen")
                                )

                                KPICard(
                                    title: "Planned",
                                    amount: totalPlanned,
                                    subtitle: "Sum of all gift prices",
                                    icon: "list.clipboard.fill",
                                    color: Color("WarmGold")
                                )

                                KPICard(
                                    title: "Spent",
                                    amount: totalSpent,
                                    subtitle: "Ordered and above",
                                    icon: "creditcard.fill",
                                    color: Color.orange
                                )

                                KPICard(
                                    title: "Remaining",
                                    amount: totalRemaining,
                                    subtitle: isOverallOverBudget ? "Over budget!" : "Budget - Planned",
                                    icon: isOverallOverBudget ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",
                                    color: isOverallOverBudget ? Color("CranberryRed") : Color("PineGreen"),
                                    isWarning: isOverallOverBudget
                                )
                            }
                            .padding(.horizontal)

                            // Swift Charts comparison
                            if !people.isEmpty {
                                BudgetChartView(data: BudgetCalculator.calculatePerPerson(people: people))
                                    .padding(.horizontal)
                            }

                            // Per-Person breakdown section
                            peopleProgressSection
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, 20)
                }
            }
            .background(Color("AppBackground").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var peopleProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Per-Person Progress")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(people) { person in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(person.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color("TextPrimary"))

                            Spacer()

                            Text("\(Formatters.formatVND(person.plannedAmount)) / \(Formatters.formatVND(person.budget))")
                                .font(.caption)
                                .foregroundStyle(Color("TextSecondary"))
                        }

                        BudgetProgressBar(
                            planned: person.plannedAmount,
                            budget: person.budget
                        )

                        HStack {
                            Text("Actual spent: \(Formatters.formatVND(person.spentAmount))")
                                .font(.caption2)
                                .foregroundStyle(Color("PineGreen"))

                            Spacer()

                            if person.isOverBudget {
                                Text("Over: \(Formatters.formatVND(abs(person.remainingAmount)))")
                                    .font(.caption2.bold())
                                    .foregroundStyle(Color("CranberryRed"))
                            } else {
                                Text("Remaining: \(Formatters.formatVND(person.remainingAmount))")
                                    .font(.caption2)
                                    .foregroundStyle(Color("TextSecondary"))
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color("AppCard"))
                            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

/// KPI Metric Card
struct KPICard: View {
    let title: String
    let amount: Int
    var subtitle: String = ""
    let icon: String
    let color: Color
    var isWarning: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color("TextSecondary"))
                Spacer()
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
            }

            Text(Formatters.formatVND(amount))
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(isWarning ? Color("CranberryRed") : Color("TextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(isWarning ? Color("CranberryRed") : Color("TextSecondary"))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("AppCard"))
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
    }
}

public typealias BudgetOverviewView = BudgetView
