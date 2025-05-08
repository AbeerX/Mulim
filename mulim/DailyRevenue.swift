import Foundation

struct DailyRevenue: Identifiable {
    var id: Int { day }
    let day: Int
    let revenue: Double
}
