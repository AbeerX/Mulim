import SwiftUI

struct ProductSelectionSheet: View {
    let products: [Product]
    let originalOrder: Order?
    @Binding var selectedProducts: [SelectedProduct]

    @Environment(\.dismiss) var dismiss

    // ✅ حساب السعر الإجمالي
    var totalPrice: Double {
        selectedProducts.reduce(0) { $0 + ($1.product.productPrice * Double($1.quantity)) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // ✅ رأس الصفحة (العنوان + الأزرار)
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)

                Spacer()

                Text("Select Products")
                    .font(.headline)
                    .bold()

                Spacer()

                Button("Done") {
                    dismiss() // ✅ سيتم تمرير selectedProducts للصفحة الأم
                }
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color(UIColor.systemGray6))

            Divider()

            // ✅ قائمة المنتجات
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(products) { product in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                // ✅ عرض اسم المنتج وسعره
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(product.productName)
                                        .font(.subheadline)
                                        .bold()

                                    Text("\(product.productPrice, specifier: "%.2f") SR")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                // ✅ أدوات التحكم بالكمية
                                if let index = selectedProducts.firstIndex(where: { $0.product.productName == product.productName }) {
                                    let quantity = selectedProducts[index].quantity

                                    HStack(spacing: 8) {
                                        // زر النقص أو الحذف
                                        Button {
                                            if quantity == 1 {
                                                selectedProducts.remove(at: index)
                                            } else {
                                                selectedProducts[index].quantity -= 1
                                            }
                                        } label: {
                                            Image(systemName: quantity == 1 ? "trash" : "minus.circle.fill")
                                                .foregroundColor(quantity == 1 ? .gray : .red)
                                        }

                                        // عرض الكمية الحالية
                                        Text("\(quantity)")
                                            .frame(minWidth: 24)

                                        // زر الإضافة
                                        Button {
                                            selectedProducts[index].quantity += 1
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                } else {
                                    // ✅ زر الإضافة لأول مرة
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

                    // ✅ عرض المجموع الكلي إذا تم اختيار منتجات
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

        // ✅ تحميل المنتجات من الطلب الحالي عند الفتح
        .onAppear {
            guard let order = originalOrder else { return }

            selectedProducts = order.orderedProducts.compactMap { item in
                if let matchedProduct = products.first(where: { $0.productName == item.name }) {
                    return SelectedProduct(product: matchedProduct, quantity: item.quantity)
                }
                return nil
            }
        }
    }
}
