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
                    title: "Customer name:",
                    placeholder: "Enter Customer Name",
                    text: $clientName,
                    isEmpty: clientName.isEmpty
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Customer phone number:")
                        .font(.subheadline)

                    ZStack(alignment: .topTrailing) {
                        HStack {
                            TextField("Enter Customer Phone", text: $customerNumber)
                                .font(.subheadline)
                                .padding(10)

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

                        if customerNumber.isEmpty {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .padding(6)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Product:")
                        .font(.subheadline)

                    Button(action: {
                        showProductSheet = true
                    }) {
                        HStack {
                            Text(selectedProducts.isEmpty ? "Select Products" : "\(selectedProducts.count) product(s) selected")
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
                        ProductSelectionSheet(products: products, selectedProducts: $selectedProducts)
                    }
                }

                RoundedTextField(title: "Note:", text: $note)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Delivery time:")
                        .font(.subheadline)
                        .padding(.horizontal, 4)
                    DatePicker("", selection: $deliveryDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .frame(maxHeight: 300)
                }
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.customBlue, lineWidth: 1)
                )

                HStack {
                    Text("Total price: \(totalPrice, specifier: "%.2f") SR")
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
                    Text("Done")
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
        }.sheet(isPresented: $showContactPicker) {
            ContactPicker(selectedPhoneNumber: $customerNumber)
        }
        .navigationTitle("New order")
        .navigationBarTitleDisplayMode(.inline)
    }

    func saveOrder() {
        for item in selectedProducts {
            let newOrder = Order(
                productType: item.product.productName,
                clientName: clientName,
                customerNumber: customerNumber,
                deliveryDate: deliveryDate,
                selectedStatus: "Open",
                note: note
            )
            context.insert(newOrder)
        }
        dismiss()
    }
}

struct ProductSelectionSheet: View {
    let products: [Product]
    @Binding var selectedProducts: [SelectedProduct]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { dismiss() }
                    .foregroundColor(.blue)

                Spacer()

                Text("Select Products")
                    .font(.headline)
                    .bold()

                Spacer()

                Button("Done") { dismiss() }
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(UIColor.systemGray6))

            Divider()

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(products) { product in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(product.productName)
                                        .font(.subheadline)
                                        .bold()
                                    Text("\(product.productPrice, specifier: "%.2f") SR")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                if let index = selectedProducts.firstIndex(where: { $0.product.id == product.id }) {
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            if selectedProducts[index].quantity > 1 {
                                                selectedProducts[index].quantity -= 1
                                            } else {
                                                selectedProducts.remove(at: index)
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }

                                        Text("\(selectedProducts[index].quantity)")
                                            .frame(minWidth: 24)

                                        Button(action: {
                                            selectedProducts[index].quantity += 1
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                } else {
                                    Button(action: {
                                        selectedProducts.append(SelectedProduct(product: product, quantity: 1))
                                    }) {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            Divider()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct RoundedTextFieldWithDot: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var isEmpty: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)

            ZStack(alignment: .topTrailing) {
                TextField(placeholder, text: $text)
                    .font(.subheadline)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.customBlue, lineWidth: 1)
                    )

                if isEmpty {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .padding(6)
                }
            }
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

            TextField("Optional note", text: $text)
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

#Preview {
    NewOrder()
        .modelContainer(for: [Product.self, Order.self])
}
