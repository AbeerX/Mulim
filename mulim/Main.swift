import SwiftUI
import SwiftData

struct Main: View {
    var orderManager: OrderManager
    var orders: [Order]
    var products: [Product]

    @State private var navigateToDashboard = false
    @State private var showWhatsAppSheet = false
     @State private var selectedCustomer: (name: String, number: String)? = nil
     @State private var messageText: String = ""
    
    var currentOrders: [Order] {
        let today = Calendar.current.startOfDay(for: Date())
        return orders
            .filter { $0.deliveryDate >= today && $0.selectedStatus == "Open" }
            .sorted { $0.deliveryDate < $1.deliveryDate }
    }
    var closedOrders: [Order] {
        return orders.filter { $0.selectedStatus == "Closed" }
    }

 
    
    // أفضل العملاء حسب الاكثر شراء --فقط الطلبات المقفلة نحسبها
    var topCustomersBySpending: [(name: String,number: String, totalSpent: Double)] {
        let grouped = Dictionary(grouping: orders.filter { $0.selectedStatus == "Closed" }, by: \.clientName)

        let spending = grouped.map { (name, orders) in
              let number = orders.first?.customerNumber ?? ""
              let total = orders.reduce(0) { $0 + $1.totalPrice }
              return (name: name, number: number, totalSpent: total)
        }

        return spending.sorted { $0.totalSpent > $1.totalSpent }.prefix(6).map { $0 }
    }
    func cleanedPhoneNumber(_ number: String) -> String {
        // نحذف أي رموز أو مسافات ونخلي الرقم أرقام فقط
        let digits = number.filter { "0123456789".contains($0) }

        // إذا كان يبدأ بـ "05"، نغيره إلى "9665..."
        if digits.hasPrefix("05") {
            let index = digits.index(digits.startIndex, offsetBy: 1)
            return "966" + digits[index...]
        }

        // إذا كان يبدأ بـ "5" مباشرة (بدون صفر)، نضيف 966
        if digits.hasPrefix("5") && digits.count == 9 {
            return "966" + digits
        }

        // إذا كان بصيغة دولية صحيحة، نرجعه كما هو
        return digits
    }
    func normalizedPhoneNumber(_ number: String) -> String? {
        // نشيل كل الرموز ونبقي الأرقام فقط
        let digits = number.filter { "0123456789".contains($0) }

        // إذا الرقم يبدأ بـ 00 نحوله لـ صيغة دولية
        if digits.hasPrefix("00") {
            return String(digits.dropFirst(2)) // تحذف الـ 00
        }

        // إذا يبدأ بـ 05 نحوله لـ 9665...
        if digits.hasPrefix("05") {
            let index = digits.index(digits.startIndex, offsetBy: 1)
            return "966" + digits[index...]
        }

        // إذا يبدأ بـ 5 (بدون صفر) و 9 أرقام، نفس الشي نضيف 966
        if digits.hasPrefix("5") && digits.count == 9 {
            return "966" + digits
        }

        // إذا يبدأ بـ 966 و طوله صحيح
        if digits.hasPrefix("966") && digits.count >= 11 {
            return digits
        }

        // إذا رقم دولي عشوائي (مثلاً 971, 20 الخ...)
        if digits.count >= 10 {
            return digits
        }

        // غير معروف أو ناقص
        return nil
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
                                    Button {
                                        selectedCustomer = (customer.name, customer.number)
                                        showWhatsAppSheet = true
                                    } label:{
                                        
                                        VStack {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 62, height: 65)
                                                .foregroundColor(Color("C2"))
                                            Text(customer.name)
                                                .font(.system(size: 13)).foregroundStyle(Color.black).bold()
                                            
                                        }
                                        .padding(.trailing, 14)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }.sheet(isPresented: $showWhatsAppSheet) {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    if let customer = selectedCustomer {
                                        Text("customer_info")
                                            .font(.title2)
                                            .fontWeight(.bold)

                                        Text(String(format: NSLocalizedString("whats_sheet_name", comment: ""), customer.name))

                                        Text(String(format: NSLocalizedString("whats_sheet_number", comment: ""), customer.number))

                                        if let bestProduct = bestSellingProduct(for: customer.name) {
                                            HStack {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(Color("C1"))

                                                Text("Customer favourite product:")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                Text(bestProduct)
                                                    .font(.subheadline)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color("C2"))
                                                    .cornerRadius(5)
                                            }
                                        }

                                        Divider()

                                        Text("whats_sheet_previous")
                                            .font(.headline)

                                        let customerOrders = closedOrders.filter { $0.clientName == customer.name }

                                        ForEach(customerOrders) { order in
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Text("📅 \(order.deliveryDate.formatted(date: .abbreviated, time: .omitted))")
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                    Spacer()
                                                    switch order.selectedStatus {
                                                    case "Canceled":
                                                        statusButton(title: "Canceled", color: .yellow)
                                                    case "Closed":
                                                        statusButton(title: "Closed", color: .red)
                                                    default:
                                                        statusButton(title: "Open", color: .blue)
                                                    }
                                                }

                                                ForEach(order.orderedProducts, id: \.name) { product in
                                                    Text("• \(product.name) ×\(product.quantity)")
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            .padding(.vertical, 6)
                                        }

                                        if let phone = normalizedPhoneNumber(customer.number),
                                           let url = URL(string: "https://wa.me/\(phone)")
         {
                                            Button {
                                                UIApplication.shared.open(url)
                                            } label: {
                                                HStack {
                                                    Text("whats_button")
                                                    Image(systemName: "message.fill")
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color("C1"))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                            }
                                            .padding(.top)
                                        }
                                    }
                                }
                                .padding()
                            }
                            .presentationDetents([.fraction(0.60), .medium, .large])
                        }
                        
                        
                        
                    }
}
                .onAppear {
                    orderManager.loadOrders(orders)
                   
                }
            }
        }
    }
    func bestSellingProduct(for customerName: String) -> String? {
        let customerOrders = closedOrders.filter {
            $0.clientName == customerName
        }

        let allProducts = customerOrders.flatMap { $0.orderedProducts }

        let productCounts = Dictionary(grouping: allProducts, by: { $0.name })
            .mapValues { $0.reduce(0) { $0 + $1.quantity } }

        return productCounts.max(by: { $0.value < $1.value })?.key
    }


    func statusButton(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 12))
            .foregroundColor(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 1)
            )
            .cornerRadius(8)
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
