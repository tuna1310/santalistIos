import SwiftUI
import Charts

/// Bar chart comparing Budget vs Planned per recipient using Swift Charts
public struct BudgetChartView: View {
    public let data: [PersonBudgetSummary]

    public struct ChartEntry: Identifiable {
        public let id = UUID()
        public let personName: String
        public let type: String
        public let amount: Int
    }

    public init(data: [PersonBudgetSummary]) {
        self.data = data
    }

    private var chartEntries: [ChartEntry] {
        var entries: [ChartEntry] = []
        for item in data {
            entries.append(ChartEntry(personName: item.name, type: "Budget", amount: item.budget))
            entries.append(ChartEntry(personName: item.name, type: "Planned", amount: item.projected))
        }
        return entries
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Comparison by Recipient")
                    .font(.headline)
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                HStack(spacing: 12) {
                    Label("Budget", systemImage: "circle.fill")
                        .font(.caption2)
                        .foregroundStyle(Color("WarmGold"))

                    Label("Planned", systemImage: "circle.fill")
                        .font(.caption2)
                        .foregroundStyle(Color("PineGreen"))
                }
            }

            Chart(chartEntries) { entry in
                BarMark(
                    x: .value("Recipient", entry.personName),
                    y: .value("Amount", entry.amount)
                )
                .foregroundStyle(by: .value("Type", entry.type))
                .position(by: .value("Type", entry.type))
                .cornerRadius(6)
            }
            .chartForegroundStyleScale([
                "Budget": Color("WarmGold"),
                "Planned": Color("PineGreen")
            ])
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    if let intValue = value.as(Int.self) {
                        AxisValueLabel {
                            Text(shortFormat(intValue))
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartLegend(.hidden)
            .frame(height: 220)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("AppCard"))
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }

    private func shortFormat(_ value: Int) -> String {
        if value >= 1_000_000 {
            let m = Double(value) / 1_000_000.0
            return String(format: "%.1fM", m)
        } else if value >= 1_000 {
            let k = Double(value) / 1_000.0
            return String(format: "%.0fk", k)
        } else {
            return "\(value)"
        }
    }
}
