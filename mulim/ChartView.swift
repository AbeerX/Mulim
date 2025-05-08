import SwiftUI
import Charts

struct ChartView: View {
    let weeklyData: [DailyRevenue]
    let isYearly: Bool

    var body: some View {
        Chart {
            ForEach(weeklyData) { item in
                BarMark(
                    x: .value("Label", label(for: item.day)),
                    y: .value("Revenue", item.revenue)
                )
                .foregroundStyle(color(for: item.revenue))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }

    func label(for day: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")

        if isYearly {
            return formatter.shortMonthSymbols[(day - 1 + 12) % 12]
        } else {
            return "W\(day)" // يعرض الأسبوع W1، W2، ...
        }
    }

    func color(for revenue: Double) -> Color {
        if revenue >= 50 {
            return Color(hex: "#00BCD4") // High Growth
        } else if revenue > 0 {
            return Color(hex: "#B2EBF2") // Medium Growth
        } else {
            return Color(hex: "#FF5722") // Decline/No Growth
        }
    }
}
