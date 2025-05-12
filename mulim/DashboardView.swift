import SwiftUI
import Charts

//enum ChartPeriod: String, CaseIterable {
//    case monthly = "Month"
//    
//    case yearly = "Year"
//}
enum ChartPeriod: String, CaseIterable {
    case monthly = "Month"
    case yearly = "Year"

    // ✅ Note: Add this computed property for localization
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}

struct DashboardView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var orderManager: OrderManager
    @State private var selectedPeriod: ChartPeriod = .monthly

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Dashboard Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        dashboardCard(title: "TotalـRevenue", value: String(format: "%.0f SAR", orderManager.totalRevenue))
                        dashboardCard(title: "TotalـOrders", value: "\(orderManager.orders.count)")
                        dashboardCard(title: "TotalـCustomers", value: "\(orderManager.uniqueCustomers)")
                        dashboardCard(title: "TopـProduct", value: orderManager.topProduct)
                        
                        dashboardCard(
                            title: "OrderـGrowth",
                            value: "\(orderManager.weeklyOrderGrowth)%",
                            icon: { growthIcon(for: orderManager.weeklyOrderGrowth) }
                        )
                        
                        dashboardCard(
                            title: "RevenueـGrowth",
                            value: "\(orderManager.weeklyRevenueGrowth)%",
                            icon: { growthIcon(for: orderManager.weeklyRevenueGrowth) }
                        )
                    }
                    .padding(.horizontal)
                    
                    Text("RevenueـComparisonـOverـTime")
                        .font(.custom("SF Pro", size: 16))
                        .foregroundColor(Color(hex: "#7F7F7F"))
                        .padding(.horizontal)
                    
                    Picker("Chart Type", selection: $selectedPeriod) {
                        ForEach(ChartPeriod.allCases, id: \.self) { period in
                            //                            Text(period.rawValue).tag(period)
                            Text(period.localized).tag(period) // ✅ Note: Displays localized period names
                            
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
                    //
                    //                    Text("You added \(orderManager.thisWeekOrders.count) orders this week – \(orderManager.weeklyOrderGrowth)% more than last week.")
                    Text(String(format: NSLocalizedString("weekly_summary", comment: ""), orderManager.thisWeekOrders.count, orderManager.weeklyOrderGrowth))
                    // ✅ Note: Add "weekly_summary" to Localizable.strings
                    
                        .font(.custom("SF Pro", size: 16))
                        .foregroundColor(Color(hex: "#7F7F7F"))
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle(Text("Report")
//                .font(.custom("SF Pro", size: 22))
//                .fontWeight(.regular)
            )
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationBarBackButtonHidden(true) // ← يخفي زر الرجوع التلقائي
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss() // ← يرجع تلقائيًا للصفحة السابقة مثل Main
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(Color("C1"))
                    }
                }
            }
        }
    }

    // MARK: - Dashboard Card With Icon Support
    @ViewBuilder
    func dashboardCard<V: View>(title: String, value: String, @ViewBuilder icon: () -> V) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(value)
                .font(.custom("SF Pro", size: 16))
                .foregroundColor(.black)

            HStack(spacing: 4) {
//                Text(title)
                Text(LocalizedStringKey(title)) // ✅ This enables dynamic key-based localization

                    .font(.custom("SF Pro", size: 16))
                    .foregroundColor(Color(hex: "#7F7F7F"))

                icon()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 65)
        .padding(10)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#00BCD4"), lineWidth: 1)
        )
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
