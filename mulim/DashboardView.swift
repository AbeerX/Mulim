import SwiftUI
import Charts

enum ChartPeriod: String, CaseIterable {
    case monthly = "Month"
    case yearly = "Year"
}

struct DashboardView: View {
    @EnvironmentObject var orderManager: OrderManager
    @State private var selectedPeriod: ChartPeriod = .monthly

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Report")
                        .font(.largeTitle).bold()
                        .padding(.horizontal)

                    // Dashboard Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        dashboardCard(title: "Total Revenue", value: String(format: "%.0f SAR", orderManager.totalRevenue))
                        dashboardCard(title: "Total Orders", value: "\(orderManager.orders.count)")
                        dashboardCard(title: "Total Customers", value: "\(orderManager.uniqueCustomers)")
                        dashboardCard(title: "Top Product", value: orderManager.topProduct)

                        dashboardCard(
                            title: "Order Growth",
                            value: "\(orderManager.weeklyOrderGrowth)%",
                            icon: { growthIcon(for: orderManager.weeklyOrderGrowth) }
                        )

                        dashboardCard(
                            title: "Revenue Growth",
                            value: "\(orderManager.weeklyRevenueGrowth)%",
                            icon: { growthIcon(for: orderManager.weeklyRevenueGrowth) }
                        )
                    }
                    .padding(.horizontal)

                    Text("Revenue Comparison Over Time")
                        .font(.headline)
                        .padding(.horizontal)

                    Picker("Chart Type", selection: $selectedPeriod) {
                        ForEach(ChartPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    if selectedPeriod == .monthly {
                        ChartView(weeklyData: orderManager.monthlyRevenueData, isYearly: false)
                            .frame(height: 200)
                    } else {
                        ChartView(weeklyData: orderManager.yearlyRevenueData, isYearly: true)
                            .frame(height: 200)
                    }

                    Text("You added \(orderManager.thisWeekOrders.count) orders this week – \(orderManager.weeklyOrderGrowth)% more than last week.")
                        .font(.callout)
                        .padding(.horizontal)

                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }

    // MARK: - Dashboard Card With Icon Support
    @ViewBuilder
    func dashboardCard<V: View>(title: String, value: String, @ViewBuilder icon: () -> V) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                Text(value)
                    .font(.subheadline)
                    .bold()

                icon()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 65)
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    // MARK: - Dashboard Card Without Icon
    func dashboardCard(title: String, value: String) -> some View {
        dashboardCard(title: title, value: value) {
            EmptyView()
        }
    }

    // MARK: - Growth Arrow Icon
    @ViewBuilder
    private func growthIcon(for value: Int) -> some View {
        if value > 0 {
            Image(systemName: "arrow.up")
                .foregroundColor(.green)
        } else if value < 0 {
            Image(systemName: "arrow.down")
                .foregroundColor(.red)
        } else {
            Image(systemName: "minus")
                .foregroundColor(.gray)
        }
    }
}




#Preview {
    DashboardView()
        .environmentObject(OrderManager())
}
