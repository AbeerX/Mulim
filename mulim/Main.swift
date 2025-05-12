import SwiftUI
import SwiftData

struct Main: View {
    var orderManager: OrderManager
    var orders: [Order]
    var products: [Product]

    @State private var navigateToDashboard = false

    
    
    var currentOrders: [Order] {
        let today = Calendar.current.startOfDay(for: Date())
        return orders
            .filter { $0.deliveryDate >= today && $0.selectedStatus == "Open" }
            .sorted { $0.deliveryDate < $1.deliveryDate }
    }
    
    
    // أفضل العملاء حسب الاكثر شراء --فقط الطلبات المقفلة نحسبها
    var topCustomersBySpending: [(name: String, totalSpent: Double)] {
        let grouped = Dictionary(grouping: orders.filter { $0.selectedStatus == "Closed" }, by: \.clientName)

        let spending = grouped.map { (name, orders) in
            (name: name, totalSpent: orders.reduce(0) { $0 + $1.totalPrice })
        }

        return spending.sorted { $0.totalSpent > $1.totalSpent }.prefix(6).map { $0 }
    }


    func weeklyIncome() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? now
        let weekOrders = orders.filter { $0.deliveryDate >= weekStart && $0.deliveryDate < weekEnd }
        return weekOrders.reduce(0) { $0 + $1.totalPrice }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Welcome")
                        .fontWeight(.bold)
                        .font(.system(size: 24))
                        .padding(.top, 16)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    HStack {
                        Text("Report")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button {
                            orderManager.loadOrders(orders)
                            navigateToDashboard = true
                        } label: {
                            Text("SeeـAll")
                                .font(.system(size: 11))
                                .fontWeight(.bold)
                                .foregroundStyle(Color("C1"))
                        }
                    }
                    .padding(.horizontal,20)
                    
                    NavigationLink(destination: DashboardView().environmentObject(orderManager), isActive: $navigateToDashboard) {
                        EmptyView()
                    }
                    
                    HStack {
                        StatCard(title: "Total Revenue", value: "\(weeklyIncome()) SR")
                        StatCard(title: "Total Orders", value: "\(orderManager.orders.count)")
                    }
                    .padding(.horizontal,20)
                    
                    Text("ThisـMonth'sـRevenue")
                        .font(.headline)
                        .padding(.horizontal,20)
                    
                    ChartView(weeklyData: orderManager.monthlyRevenueData, isYearly: false)
                        .frame(height: 200)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    
                    HStack {
                        Text("CurrentـOrders")
                            .fontWeight(.bold)
                            .font(.system(size: 12))
                        
                        Spacer()
                        
                        NavigationLink(destination: OrdersView()) {
                            Text("SeeـAll")
                                .fontWeight(.bold)
                                .font(.system(size: 12))
                        }
                    }
                    .padding(.horizontal,20)
                    
                    if currentOrders.isEmpty {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color("C2").opacity(0.1))
                                    .frame(width: 88, height: 88)
                                Image(systemName: "tray")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(Color("C2"))
                            }

                            Text("Noـcurrentـordersـyet")
                                .font(.callout)
                                .foregroundColor(.gray)

                            Text("Orders will show up once received.")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, minHeight: 180)

                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(currentOrders.prefix(4)) { order in
                                    NavigationLink(destination: OrderDetailsView(order: order, products: products)) {
                                        OrderCard(order: order)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    
                    Text("Top Customers")
                        .font(.system(size: 12))
                        .fontWeight(.bold)
                        .padding(.horizontal,20)
                    if topCustomersBySpending.isEmpty {
                        VStack(alignment: .center, spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color("C2").opacity(0.1))
                                    .frame(width: 88, height: 88)
                                Image(systemName: "person.3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(Color("C2"))
                            }

                            Text("No customer data yet.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)

                            Text("Once orders are completed, top customers will appear here.")
                                .font(.system(size: 11))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            
                            HStack {
                                ForEach(topCustomersBySpending, id: \.name) { customer in
                                    VStack {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 62, height: 65)
                                            .foregroundColor(Color("C2"))
                                        Text(customer.name)
                                            .font(.system(size: 13))
                                     
                                    }
                                    .padding(.trailing, 14)
                                }
                            }
                            .padding(.horizontal, 20)
                        }}
}
                .onAppear {
                    orderManager.loadOrders(orders)
                }
            }
        }
    }
}

// MARK: - Components

struct OrderCard: View {
    let order: Order

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color("C2"), lineWidth: 1)
                .frame(width: 152, height: 138)

            VStack(alignment: .leading, spacing: 8) {
                row(icon: "number", text: String(order.id.uuidString.prefix(8)) + "...")
                row(icon: "person", text: order.clientName)
                row(icon: "alarm", text: deliveryLabel(for: order.deliveryDate))
                statusBadge(for: order.selectedStatus)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(10)
            .foregroundColor(.black)
        }
    }
}

struct StatCard: View {
    var title: String
    var value: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("C2"))
                .frame(width: 165, height: 91)
                .padding(.leading, 10)
            VStack {
                Text(value)
                Text(title)
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
        }
    }
}

// MARK: - Helpers

func statusBadge(for status: String) -> some View {
    let color: Color = switch status {
    case "Canceled": Color(hex: "#FFC835")
    case "Closed": Color(hex: "#FF5722")
    default: Color(hex: "#00BCD4")
    }

    return Text(status)
        .font(.system(size: 12))
        .foregroundColor(.black)
        .frame(minWidth: 55)
        .padding(.horizontal, 13)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: 1.5)
                )
        )
}

func row(icon: String, text: String) -> some View {
    HStack(spacing: 6) {
        Image(systemName: icon)
            .frame(width: 16, alignment: .leading)
        Text(text)
            .font(.system(size: 10))
            .fontWeight(.bold)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

func deliveryLabel(for date: Date) -> String {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let deliveryDay = calendar.startOfDay(for: date)
    let components = calendar.dateComponents([.day], from: today, to: deliveryDay)
    guard let days = components.day else { return "Unknown" }

    switch days {
    case 0: return "Today"
    case 1: return "Tomorrow"
    case 2...6: return "In \(days) days"
    case -1: return "Yesterday"
    case ..<0: return "Delivered"
    default: return date.formatted(date: .abbreviated, time: .omitted)
    }
}

#Preview {
    Main(orderManager: OrderManager(), orders: [], products: [])
}
