import SwiftUI
import SwiftData

struct NewOrder: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query var products: [Product]

    @State private var clientName = ""
    @State private var customerNumber = ""
    @State private var selectedProduct: Product? = nil
    @State private var note = ""
    @State private var deliveryDate = Date()
    @State private var showContactPicker = false

    var isFormValid: Bool {
        !clientName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !customerNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedProduct != nil
    }

    var totalPrice: Double {
        selectedProduct?.productPrice ?? 0.0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // ✅ بدون عنوان مكرر أو زر رجوع
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

                    ZStack(alignment: .topTrailing) {
                        HStack {
                            Spacer()
                            Picker("", selection: $selectedProduct) {
                                Text("None").tag(Product?.none)
                                ForEach(products) { product in
                                    Text(product.productName).tag(Product?.some(product))
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.blue)
                        }
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.customBlue, lineWidth: 1)
                        )

                        if selectedProduct == nil {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .padding(6)
                        }
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
        guard let selectedProduct = selectedProduct else { return }

        let newOrder = Order(
            productType: selectedProduct.productName,
            clientName: clientName,
            customerNumber: customerNumber,
            deliveryDate: deliveryDate,
            selectedStatus: "Open",
            note: note
        )

        context.insert(newOrder)
        dismiss()
    }
}

// MARK: - Text Field With Dot
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

// MARK: - Text Field Design
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

// MARK: - Color
extension Color {
    static let customBlue = Color(red: 0.0, green: 0.74, blue: 0.83) // #00BCD4
}

#Preview {
    NewOrder()
        .modelContainer(for: [Product.self, Order.self])
}
