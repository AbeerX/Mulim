//
//  Main.swift
//  mulim
//
//  Created by Alanoud Alamrani on 08/11/1446 AH.
//
import SwiftUI
import SwiftData

struct Main: View {
    var orderManager: OrderManager
    var orders: [Order]

    @State private var navigateToDashboard = false

    
    //تظهر لي الطلبات باولوية قرب وقت التسليم
    var currentOrders: [Order] {
        let today = Calendar.current.startOfDay(for: Date())
        return orders
            .filter { $0.deliveryDate >= today && $0.selectedStatus == "Open" }
            .sorted { $0.deliveryDate < $1.deliveryDate }
    }

    
    var body: some View {
        NavigationStack {
            VStack {
                    Text("Welcome..")
                        .fontWeight(.bold)
                        .font(.system(size: 18))
                        .padding(.trailing, 266)
                
                
                .padding(.horizontal)
                .padding(.bottom, 16)

                Text("Report")
                    .fontWeight(.bold)
                    .padding(.trailing, 300)

                HStack {
                    ZStack {
                           RoundedRectangle(cornerRadius: 10)
                               .fill(Color("C2"))
                               .frame(width: 146, height: 96)
                           VStack {
                               Text("\(weeklyIncome(), specifier: "%.2f") SR")
                               Text("Total Revenue")
                                   .foregroundColor(.gray)
                                   .font(.system(size: 12))
                           }
                    }
                    
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("C2"))
                            .frame(width: 146, height: 96)
                        VStack {
                           
                            Text("\(orderManager.orders.count)")
                            Text("Total Orders")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                    }
               
                }
                
                Text("This Month's Revenue")
                    .font(.headline)
                    .padding(.top, 16)
                    .padding(.horizontal)

                ChartView(weeklyData: orderManager.monthlyRevenueData, isYearly: false)
                    .frame(height: 200)
                    .padding(.horizontal)
                    .padding(.bottom, 16)

            }
            
            Button {
                orderManager.loadOrders(orders)
                navigateToDashboard = true
            } label: {
                ZStack {
                       RoundedRectangle(cornerRadius: 7)
                           .stroke(Color("C2"))
                           .frame(width: 261, height: 21)
                       VStack {
                           Text("More details ")
                               .foregroundColor(Color.black)
                               .font(.system(size: 10))
                               .fontWeight(.bold)
                       }
                } .padding(.bottom,16)
            }
            // زر الانتقال إلى DashboardView
            NavigationLink(destination: DashboardView().environmentObject(orderManager), isActive: $navigateToDashboard) {
                EmptyView()
            }
            
           
        
            HStack{
                
                Text("Current Orders")
                    .fontWeight(.bold)
                    .font(.system(size: 12))
                    .padding(.leading,34)
                Spacer()
                
                NavigationLink(destination: OrdersView()) {
                    Text("All")
                        .fontWeight(.bold)
                        .font(.system(size: 12))
                }
                .padding(.trailing, 34)

            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(currentOrders.prefix(4)) { order in
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color("C2"), lineWidth: 1)
                                .frame(width: 152, height: 138)

                            VStack(alignment: .leading, spacing: 8) {
                                row(icon: "heart.text.square", text: order.productType)
                                row(icon: "person", text: order.clientName)
                                
                                row(icon: "alarm", text: deliveryLabel(for: order.deliveryDate))

                               

                                statusBadge(for: order.selectedStatus)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                            }
                            .padding(10)
                        }
                    }

                    }}.padding(.leading,8)
            

        }
        .onAppear {
            orderManager.loadOrders(orders)
        }
    }
    
    
    
    func weeklyIncome() -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? now

        let weekOrders = orders.filter { order in
            order.deliveryDate >= weekStart && order.deliveryDate < weekEnd
        }

        return weekOrders.reduce(0) { total, order in
            total + order.totalPrice
        }
    }
    
    
   
    //دالة لاظهار يوم التسليم المتوقع بدل التاريخ
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
    
    
    // صف ثابت يحتوي أيقونة ونص بمحاذاة مثالية
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



}


#Preview {
    Main(orderManager: OrderManager(), orders: [])
}
