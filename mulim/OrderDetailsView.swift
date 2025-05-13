import SwiftUI
import SwiftData

struct OrderDetailsView: View {
    @Bindable var order: Order
    var products: [Product]
    @Binding var selectedTab: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var isEditing = false
    @State private var showContactPicker = false
    @State private var showProductEditor = false
    @State private var selectedProducts: [SelectedProduct] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    if isEditing {
                        Button("cancel_button") {
                            isEditing = false
                        }
                        .foregroundColor(.gray)
                    } else {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21, height: 20)
                                .foregroundColor(Color("C1"))
                        }
                    }

                    Spacer()
                    Text("Order_details")
                    Spacer()

                    Button(action: {
                        if isEditing {
                            if !selectedProducts.isEmpty {
                                order.orderedProducts = selectedProducts.map {
                                    OrderedProduct(
                                        name: $0.product.productName,
                                        quantity: $0.quantity,
                                        price: $0.product.productPrice
                                    )
                                }
                            }

                            try? context.save()

                            if order.selectedStatus == "Closed" || order.selectedStatus == "Canceled" {
                                selectedTab = "Previous"
                            }

                            isEditing = false
                        } else {
                            isEditing = true
                        }
                    }) {
                        if isEditing {
                            Text("done_button")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 20) {
                        groupedBox {
                            if isEditing {
                                Button {
                                    showProductEditor = true
                                } label: {
                                    HStack {
                                        Text("Edit_Products")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .padding()
                            } else {
                                VStack(alignment: .leading) {
                                    Text("Products:")
                                        .font(.headline)
                                    ForEach(order.orderedProducts) { item in
                                        Text("\(item.quantity)x \(item.name) - \(item.price, specifier: "%.2f") SR")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                            }

                            Divider().padding(.horizontal, 10)

                            fieldRow(
                                title: NSLocalizedString("Total:", comment: ""),
                                value: String(format: "%.2f SR", order.totalPrice)
                            )
                        }

                        groupedBox {
                            //                            fieldRow(title: NSLocalizedString("Customer_Name:", comment: ""), value: order.clientName, editable: true, binding: $order.clientName)
                            fieldRow(
                                title: NSLocalizedString("Customer_name:", comment: ""),
                                value: order.clientName,
                                editable: true,
                                binding: $order.clientName
                            )
                            
                            //                            fieldRow(title: "Customer_Name:", value: order.clientName, editable: true, binding: $order.clientName)
                            Divider()
                                .padding(.horizontal, 10)
                            
                            //                            phoneRow(title: "Customer_number:", text: $order.customerNumber)
                            
                            phoneRow(
                                title: NSLocalizedString("Customer_number:", comment: ""),
                                text: $order.customerNumber
                            )
                        }
                       

                        groupedBox {
                            
                            deliveryDateRow(
                                title: NSLocalizedString("Delivery_time:", comment: ""),
                                date: $order.deliveryDate
                            )
                            Divider()
                            .padding(.horizontal, 10)

                            HStack {
                                Text(LocalizedStringKey("Order_status:"))
                                 .font(.system(size: 18))
                                statusButton(title: NSLocalizedString("Canceled", comment: ""), color: .yellow)
                                        statusButton(title: NSLocalizedString("Open", comment: ""), color: .blue)
                                        statusButton(title: NSLocalizedString("Closed", comment: ""), color: .red)
//                                statusButton(title: "Canceled", color: .yellow)
//                                statusButton(title: "Open", color: .blue)
//                                statusButton(title: "Closed", color: .red)
                            }
                            .padding(.top, 16)
                            .padding(.leading, 13)
                            .padding(.bottom, 13)
                        }

                        groupedBox {
                            noteRow(
                                title: NSLocalizedString("Note:", comment: ""),
                                text: $order.note
                            )
                        }

                        Spacer()
                    }
                    .padding(.top)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showContactPicker) {
                ContactPicker(selectedPhoneNumber: $order.customerNumber)
            }
            .sheet(isPresented: $showProductEditor, onDismiss: {
                if isEditing {
                    order.orderedProducts = selectedProducts.map {
                        OrderedProduct(
                            name: $0.product.productName,
                            quantity: $0.quantity,
                            price: $0.product.productPrice
                        )
                    }
                }
            }) {
                ProductSelectionSheet(
                    products: products,
                    originalOrder: order,
                    selectedProducts: $selectedProducts
                )
            }
            .onChange(of: showProductEditor) { newValue in
                if newValue == true {
                    selectedProducts = order.orderedProducts.compactMap { item in
                        if let matched = products.first(where: { $0.productName == item.name }) {
                            return SelectedProduct(product: matched, quantity: item.quantity)
                        }
                        return nil
                    }
                }
            }
           
        }
    }

    private func groupedBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#00BCD4"), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private func fieldRow(title: String, value: String, editable: Bool = false, binding: Binding<String>? = nil) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18))

            if editable, let binding = binding, isEditing {
                TextField("", text: binding)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            } else {
                Text(value)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    private func phoneRow(title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18))

            if isEditing {
                TextField("", text: text)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)

                Button {
                    showContactPicker = true
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundColor(.blue)
                }
            } else {
                Text(text.wrappedValue)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    private func deliveryDateRow(title: String, date: Binding<Date>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18))

            if isEditing {
                DatePicker("", selection: date, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            } else {
                Text(date.wrappedValue.formatted(date: .numeric, time: .omitted))
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    private func noteRow(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18))

            if isEditing {
                TextEditor(text: text)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "#00BCD4"), lineWidth: 1)
                    )
            } else {
                Text(text.wrappedValue.isEmpty ? NSLocalizedString("No_note", comment: "") : text.wrappedValue)

//                Text(text.wrappedValue.isEmpty ? "No note" : text.wrappedValue)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    private func statusButton(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 12, weight: order.selectedStatus == title ? .bold : .regular))
            .foregroundColor(.black)
            .padding(.horizontal, 13)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(order.selectedStatus == title ? color.opacity(0.2) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color, lineWidth: 1.5)
                    )
            )
            .onTapGesture {
                if isEditing {
                    order.selectedStatus = title
                }
            }
    }
}

// MARK: - Hex Support
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    let order = Order(
        clientName: "Test Client",
        customerNumber: "0500000000",
        deliveryDate: .now,
        selectedStatus: "Open",
        note: "Extra note here",
        orderedProducts: [
            OrderedProduct(name: "Test Cake", quantity: 2, price: 25.0)
        ]
    )

    return OrderDetailsView(
        order: order,
        products: [
            Product(productName: "Test Cake", productPrice: 25.0)
        ],
        selectedTab: .constant("Current")
    )
    .modelContainer(for: [Order.self, Product.self])
}
