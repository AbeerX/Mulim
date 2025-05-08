import SwiftUI
import SwiftData

struct OrdersView: View {
    @Query var orders: [Order]
    @State private var selectedTab: String = "Current"

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // العنوان وزر الإضافة
                HStack {
                    NavigationLink(destination: NewOrder()) {
                        ZStack {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundColor(Color("C1"))
                        }
                    }

                    Spacer()
                    Text("Orders")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.black)
                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal)

                TextField("Search", text: .constant(""))
                    .padding(10)
                    .frame(height: 40)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        HStack {
                            Spacer()
                            Image(systemName: "mic.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 19)
                        }
                    )
                    .padding(.horizontal)

                HStack {
                    Button(action: {
                        selectedTab = "Current"
                    }) {
                        Text("Current orders")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(selectedTab == "Current" ? .black : Color(hex: "#A8A8A8"))
                    }

                    Spacer()

                    Button(action: {
                        selectedTab = "Previous"
                    }) {
                        Text("Previous orders")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(selectedTab == "Previous" ? .black : Color(hex: "#A8A8A8"))
                    }
                }
                .padding(.horizontal, 30)

                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3))

                let filteredOrders = orders.filter { order in
                    if selectedTab == "Current" {
                        return order.selectedStatus == "Open"
                    } else {
                        return order.selectedStatus == "Closed" || order.selectedStatus == "Canceled"
                    }
                }

                if filteredOrders.isEmpty {
                    Spacer()
                    Text("No orders yet.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredOrders) { order in
                                NavigationLink(destination: OrderDetailsView(order: order)) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Image(systemName: "doc.text")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(hex: "#393939"))

                                            Text(order.productType)
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(Color(hex: "#393939"))

                                            Spacer()
                                            statusBadge(for: order.selectedStatus)
                                        }

                                        HStack {
                                            Image(systemName: "person")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(hex: "#393939"))

                                            Text(order.clientName)
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "#393939"))
                                        }

                                        HStack {
                                            Image(systemName: "clock")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(hex: "#393939"))

                                            Text("Delivery: \(order.deliveryDate.formatted(date: .abbreviated, time: .omitted))")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(Color(hex: "#393939"))
                                        }

                                        HStack {
                                            Image(systemName: "creditcard")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(hex: "#393939"))

                                            Text("\(order.totalPrice, specifier: "%.2f") SR")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "#393939"))
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(hex: "#00BCD4"), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.top, 24)
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
}


#Preview {
    OrdersView()
        .modelContainer(for: [Order.self])
}
