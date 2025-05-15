import SwiftUI
import SwiftData

struct SelectedProduct: Identifiable, Equatable {
    let id = UUID()
    let product: Product
    var quantity: Int
}

struct NewOrder: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query var products: [Product]
    @Query var existingOrders: [Order] // ✅ لإيجاد العميل بناءً على الرقم

    @State private var clientName = ""
    @State private var customerNumber = ""
    @State private var selectedProducts: [SelectedProduct] = []
    @State private var note = ""
    @State private var deliveryDate = Date()
    @State private var showContactPicker = false
    @State private var showProductSheet = false

    var isFormValid: Bool {
        !clientName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !customerNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedProducts.isEmpty
    }

    var totalPrice: Double {
        selectedProducts.reduce(0) { $0 + ($1.product.productPrice * Double($1.quantity)) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                RoundedTextFieldWithDot(
                    title: NSLocalizedString("Customer_name:", comment: ""),
                    placeholder: NSLocalizedString("enter_customer_name", comment: ""),
                    text: $clientName,
                    isEmpty: clientName.isEmpty
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 2) {
                        Text(NSLocalizedString("Customerـphoneـnumber:", comment: ""))
                            .font(.subheadline)
                        
                        if customerNumber.isEmpty {
                            Text("*")
                                .foregroundColor(.red)
                                .font(.subheadline.bold())
                        }
                    }

                    HStack {
                        TextField(NSLocalizedString("enter_customer_phone", comment: ""), text: $customerNumber)
                            .font(.subheadline)
                            .padding(10)
                            .onChange(of: customerNumber) { newValue in
                                if let existingOrder = existingOrders.first(where: { $0.customerNumber == newValue }) {
                                    clientName = existingOrder.clientName
                                }
                            }

                        Button(action: {
                            showContactPicker = true
                        }) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .foregroundColor(.blue)
                                .padding(.trailing, 10)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.customBlue, lineWidth: 1)
                    )
                }


                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("prodect:", comment: ""))
                        .font(.subheadline)

                    Button(action: {
                        showProductSheet = true
                    }) {
                        HStack {
                            Text(selectedProducts.isEmpty ?
                                 NSLocalizedString("select_products", comment: "") :
                                 String(format: NSLocalizedString("products_selected", comment: ""), selectedProducts.count)
                            )
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.customBlue, lineWidth: 1)
                        )
                    }
                    .sheet(isPresented: $showProductSheet) {
                        ProductSelectionSheet(
                            products: products,
                            originalOrder: Order(
                                clientName: "",
                                customerNumber: "",
                                deliveryDate: .now,
                                selectedStatus: "",
                                note: "",
                                orderedProducts: []
                            ),
                            selectedProducts: $selectedProducts
                        )
                    }
                    .presentationDetents([.medium]) // ✅ نفس مقاس ProductFormSheet
                        .presentationBackground(Color.white) // ✅ لون خلفية أبيض
                }

                RoundedTextField(title: NSLocalizedString("Note:", comment: ""), text: $note)

                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("Delivery_time:", comment: ""))
                        .font(.subheadline)
                        .padding(.horizontal, 4)

                    HStack {
                        DatePicker("", selection: $deliveryDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)

                        Spacer()
                    }
                    
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.customBlue, lineWidth: 1)
                    )
                }
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.customBlue, lineWidth: 1)
                )

                HStack {
                    Text("\(NSLocalizedString("Totalـprice", comment: "")) \(totalPrice, specifier: "%.2f") SR")
                    Spacer()
                }
                .font(.subheadline)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.customBlue, lineWidth: 1)
                )

                Button(action: {
                    saveOrder()
                }) {
                    Text(NSLocalizedString("done_button", comment: ""))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isFormValid ? Color.customBlue : Color.gray)
                        .cornerRadius(20)
                }
                .disabled(!isFormValid)
                .padding(.top, 8)

                Spacer(minLength: 30)
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $showContactPicker) {
            ContactPicker(selectedPhoneNumber: $customerNumber)
        }
//        .navigationTitle(NSLocalizedString("Newـorder", comment: ""))
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(true)
//        .toolbar(.hidden, for: .tabBar)
//   
//        .toolbar(.hidden, for: .tabBar)
        .navigationTitle(NSLocalizedString("Newـorder", comment: ""))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true) // نخفي الزر الأساسي
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(Color("C1"))
                        }
                    }
                }
                .toolbar(.hidden, for: .tabBar)
    }

    func saveOrder() {
        let productModels = selectedProducts.map { item in
            OrderedProduct(
                name: item.product.productName,
                quantity: item.quantity,
                price: item.product.productPrice
            )
        }

        let newOrder = Order(
            clientName: clientName,
            customerNumber: customerNumber,
            deliveryDate: deliveryDate,
            selectedStatus: "Open",
            note: note,
            orderedProducts: productModels
        )

        context.insert(newOrder)
        dismiss()
    }
}

// MARK: - Helpers

struct RoundedTextFieldWithDot: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var isEmpty: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                
                if isEmpty {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
            }

            TextField(placeholder, text: $text)
                .font(.subheadline)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.customBlue, lineWidth: 1)
                )
        }
    }
}


struct RoundedTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)

            TextField(NSLocalizedString("optional_note", comment: ""), text: $text)
                .font(.subheadline)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.customBlue, lineWidth: 1)
                )
        }
    }
}

extension Color {
    static let customBlue = Color(red: 0.0, green: 0.74, blue: 0.83)
}

// MARK: - Preview

#Preview {
    NewOrder()
        .modelContainer(for: [Product.self, Order.self])
}
