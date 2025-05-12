import Foundation
import SwiftData
class OrderManager: ObservableObject {
    @Published var orders: [Order] = [] // ✅ ليست Optional

    func loadOrders(_ newOrders: [Order]) {
        self.orders = newOrders
    }

    var totalRevenue: Double {
        orders.reduce(0.0) { $0 + $1.totalPrice }
    }

    var uniqueCustomers: Int {
        Set(orders.map { $0.clientName }).count
    }

    var topProduct: String {
        let productCount = orders.reduce(into: [String: Int]()) { counts, order in
            counts[order.productType, default: 0] += 1
        }
        return productCount.max(by: { $0.value < $1.value })?.key ?? "-"
    }

    var thisWeekOrders: [Order] {
        let calendar = Calendar.current
        let now = Date()
        return orders.filter {
            calendar.isDate($0.deliveryDate, equalTo: now, toGranularity: .weekOfYear)
        }
    }

    var lastWeekOrders: [Order] {
        let calendar = Calendar.current
        guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) else { return [] }
        return orders.filter {
            calendar.isDate($0.deliveryDate, equalTo: lastWeek, toGranularity: .weekOfYear)
        }
    }

    var weeklyOrderGrowth: Int {
        let thisCount = thisWeekOrders.count
        let lastCount = lastWeekOrders.count
        guard lastCount > 0 else { return 100 }
        return Int(((Double(thisCount - lastCount) / Double(lastCount)) * 100).rounded())
    }

    var weeklyRevenueGrowth: Int {
        let thisRevenue = thisWeekOrders.reduce(0.0) { $0 + $1.totalPrice }
        let lastRevenue = lastWeekOrders.reduce(0.0) { $0 + $1.totalPrice }
        guard lastRevenue > 0 else { return 100 }
        return Int(((thisRevenue - lastRevenue) / lastRevenue * 100).rounded())
    }

    var monthlyRevenueData: [DailyRevenue] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: orders) {
            calendar.component(.weekOfMonth, from: $0.deliveryDate)
        }

        return (1...5).map { week in
            let total = (grouped[week] ?? []).reduce(0.0) { $0 + $1.totalPrice }
            return DailyRevenue(day: week, revenue: total)
        }
    }

    var yearlyRevenueData: [DailyRevenue] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: orders) {
            calendar.component(.month, from: $0.deliveryDate)
        }

        return (1...12).map { month in
            let total = (grouped[month] ?? []).reduce(0.0) { $0 + $1.totalPrice }
            return DailyRevenue(day: month, revenue: total)
        }
    }
    func fetchOrders(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Order>()
            orders = try context.fetch(descriptor)
            print("✅ Orders fetched in OrderManager: \(orders.count)")
        } catch {
            print("❌ Failed to fetch orders: \(error.localizedDescription)")
        }
    }
}


