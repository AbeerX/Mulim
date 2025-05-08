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

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Welcome..")
                        .fontWeight(.bold)
                        .font(.system(size: 18))
                    Spacer()
                    Button {
                        orderManager.loadOrders(orders)
                        navigateToDashboard = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                    }
                    // زر الانتقال إلى DashboardView
                    NavigationLink(destination: DashboardView().environmentObject(orderManager), isActive: $navigateToDashboard) {
                        EmptyView()
                    }
                    .hidden()
                }
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
                            Text("")
                            Text("Best Selling Product")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("C2"))
                            .frame(width: 146, height: 96)
                        VStack {
                            Text("")
                            Text("Income")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    
}
