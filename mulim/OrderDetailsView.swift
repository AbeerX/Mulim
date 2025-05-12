import SwiftUI
import SwiftData

struct OrderDetailsView: View {
    @Bindable var order: Order
    var products: [Product]

    @Environment(\.dismiss) private var dismiss
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
//                        Button(action: { dismiss() }) {
//                            HStack {
//                                Image(systemName: "chevron.backward")
//                                Text("Back")
//                            }
//                        }
                         
                        
                        
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
                   
//                    Text("Order details")
//                        .font(.system(size: 18, weight: .medium))

                    Spacer()

                    Button(action: {
                        if isEditing {
                            order.orderedProducts = selectedProducts.map {
                                OrderedProduct(
                                    name: $0.product.productName,
                                    quantity: $0.quantity,
                                    price: $0.product.productPrice
                                )
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
                                title: "Total:",
                                value: String(format: "%.2f SR", order.orderedProducts.reduce(0) {
                                    $0 + ($1.price * Double($1.quantity))
                                })
                            )
                        }

                        groupedBox {
                            fieldRow(title: "Customer_name:", value: order.clientName, editable: true, binding: $order.clientName)
                            Divider().padding(.horizontal, 10)
                            phoneRow(title: "Customer_number:", text: $order.customerNumber)
                        }

                        groupedBox {
                            deliveryDateRow(title: "Delivery_time:", date: $order.deliveryDate)
                            Divider()
                                .padding(.horizontal, 10)
                           
                    
                            HStack {
                                Text("Order_status:")
                                    .font(.system(size: 18))
//                                    .padding(.trailing, 13) // ← المسافة المطلوبة بين النص والأزرار
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
                            noteRow(title: "Note:", text: $order.note)
                        }

                        Spacer()
                    }
                    .padding(.top)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)

            // Contact Picker
            .sheet(isPresented: $showContactPicker) {
                ContactPicker(selectedPhoneNumber: $order.customerNumber)
            }

            // Product Selection Sheet
            .sheet(isPresented: $showProductEditor, onDismiss: {
                // تحديث المنتجات داخل الطلب بعد التعديل
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

            // تحديث الكميات عند كل مرة يتم فتح الشيت
            .onChange(of: showProductEditor) { newValue in
                if newValue == true {
                    selectedProducts = order.orderedProducts.map {
                        SelectedProduct(
                            product: Product(productName: $0.name, productPrice: $0.price),
                            quantity: $0.quantity
                        )
                    }
                }
            }
        }
    }

    // MARK: - UI Components

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
            Text(LocalizedStringKey(title))
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
            Text(LocalizedStringKey(title))
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
            Text(LocalizedStringKey(title))
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
            Text(LocalizedStringKey(title))
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
//                Text(text.wrappedValue.isEmpty ? "Noـnote" : text.wrappedValue)
                Text(text.wrappedValue.isEmpty ? LocalizedStringKey("No_note") : LocalizedStringKey(text.wrappedValue))

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

    return OrderDetailsView(order: order, products: [])
}
