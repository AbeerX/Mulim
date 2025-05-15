import SwiftUI

struct ProductSelectionSheet: View {
    let products: [Product]
    let originalOrder: Order?
    @Binding var selectedProducts: [SelectedProduct]

    @Environment(\.dismiss) var dismiss
    @State private var didLoad = false

    // ✅ حساب السعر الإجمالي
    var totalPrice: Double {
        selectedProducts.reduce(0) { $0 + ($1.product.productPrice * Double($1.quantity)) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // ✅ رأس الصفحة (العنوان + الأزرار)
            HStack {
                Button(NSLocalizedString("cancel_button", comment: "")) {
                    dismiss()
                }
                .foregroundColor(.gray)

                Spacer()

                Text(NSLocalizedString("select_products", comment: ""))
                    .font(.headline)
                    .bold()

                Spacer()

                Button(NSLocalizedString("done_button", comment: "")) {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding()
//            .background(Color(UIColor.systemGray6))

            Divider()

            // ✅ قائمة المنتجات
            ScrollView {
                VStack(spacing: 10) {

                    if (products.isEmpty || (selectedProducts.isEmpty && originalOrder == nil)) && didLoad {
                        VStack(spacing: 12) {

                        ZStack {
                            Circle()
                                .fill(Color("C2").opacity(0.1))
                                .frame(width: 88, height: 88)
//                                .fill(Color("C1"))
//                                .frame(width: 88, height: 88)
//                                .opacity(0.1)
                            Image(systemName: "menucard.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .foregroundColor(Color("C2"))
//                                .font(.system(size: 36))
//                                .foregroundColor(Color("C1"))
                        }
                                Text("You_have_not_entered_your_products_yet")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        
                        
                                            }
                                .padding(.top, 40)
                                 .frame(maxWidth: .infinity)

                                        }
                    
                    ForEach(products) { product in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 12) {
                                // ✅ عرض الصورة إذا موجودة
                                if let imageData = product.productImage,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .clipped()
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 56, height: 56)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        )
                                }

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

                                        Text("\(quantity)")
                                            .frame(minWidth: 24)

                                        Button {
                                            selectedProducts[index].quantity += 1
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

        
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)

        // ✅ تحميل المنتجات من الطلب الحالي عند الفتح
        .onAppear {
            guard let order = originalOrder else {
                didLoad = true // ✅ حتى لو ما فيه أوردر، ننهي التحميل
return }

            selectedProducts = order.orderedProducts.compactMap { item in
                if let matchedProduct = products.first(where: { $0.productName == item.name }) {
                    return SelectedProduct(product: matchedProduct, quantity: item.quantity)
                }
                return nil
            }
            didLoad = true // ✅ بعد التحميل نسمح بإظهار رسالة "لا يوجد منتجات"

        }
    }
   
}
