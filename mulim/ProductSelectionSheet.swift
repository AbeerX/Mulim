import SwiftUI

struct ProductSelectionSheet: View {
    let products: [Product]
    let originalOrder: Order
    @Binding var selectedProducts: [SelectedProduct]
    @Environment(\.dismiss) var dismiss

    var totalPrice: Double {
        selectedProducts.reduce(0) { $0 + ($1.product.productPrice * Double($1.quantity)) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
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

            // Product List
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
                                    let quantity = selectedProducts[index].quantity

                                    HStack(spacing: 8) {
                                        Button {
                                            if quantity == 1 {
                                                selectedProducts.remove(at: index)
                                            } else {
                                                var updated = selectedProducts[index]
                                                updated.quantity -= 1
                                                selectedProducts[index] = updated
                                            }
                                        } label: {
                                            Image(systemName: quantity == 1 ? "trash" : "minus.circle.fill")
                                                .foregroundColor(quantity == 1 ? .gray : .red)
                                        }

                                        Text("\(quantity)")
                                            .frame(minWidth: 24)

                                        Button {
                                            var updated = selectedProducts[index]
                                            updated.quantity += 1
                                            selectedProducts[index] = updated
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                } else {
                                    Button {
                                        selectedProducts.append(SelectedProduct(product: product, quantity: 1))
                                    } label: {
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

                    // Total Price
                    if !selectedProducts.isEmpty {
                        HStack {
                            Text("Total:")
                                .font(.subheadline)
                                .bold()
                            Spacer()
                            Text("\(totalPrice, specifier: "%.2f") SR")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)

        // ✅ تحميل الكميات الأصلية عند أول ظهور
        .onAppear {
            selectedProducts = products.compactMap { product in
                if let existing = originalOrder.orderedProducts.first(where: { $0.name == product.productName }) {
                    return SelectedProduct(product: product, quantity: existing.quantity)
                }
                return nil
            }
        }
        }
    }

