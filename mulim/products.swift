import SwiftUI
import SwiftData
import PhotosUI

struct ProductsView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var products: [Product]

    @State private var showAddSheet = false
    @State private var editProduct: Product?

    var body: some View {
        NavigationStack {
            VStack {
                if products.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("There are no products currently available.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: -8) {
                            ForEach(products) { product in
                                HStack(spacing: 16) {
                                    // الصورة
                                    if let imageData = product.productImage,
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 70, height: 64)
                                            .clipShape(RoundedRectangle(cornerRadius: 21))
                                            .clipped()
                                    } else {
                                        RoundedRectangle(cornerRadius: 21)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 70, height: 64)
                                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                                    }

                                    Text(product.productName)
                                        .font(.custom("SFPro", size: 18))
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    VStack(alignment: .trailing, spacing: 4) {
                                        Menu {
                                            Button("Edit") {
                                                editProduct = product
                                                showAddSheet = true
                                            }
                                            Button("Delete", role: .destructive) {
                                                modelContext.delete(product)
                                            }
                                        } label: {
                                            Text("⋯")
                                                .font(.title3)
                                                .bold()
                                                .padding(.bottom, 38)
                                        }

                                        Text("\(product.productPrice, specifier: "%.2f") SR")
                                            .font(.custom("SFPro", size: 14))
                                            .foregroundColor(.gray)
                                            .padding(.top, -39)
                                    }
                                    .frame(width: 80, alignment: .trailing)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("C1"))
                                        .frame(width: 360, height: 82)
                                )
                            }
                        }
                        .padding(.top, -50)
                        .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        editProduct = nil
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(Color("C1"))
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Products")
                        .font(.system(size: 18))
                }
            }

            .sheet(isPresented: $showAddSheet) {
                NavigationStack {
                    ProductFormSheet(productToEdit: editProduct)
                }
                .presentationDetents([.medium])
            }

        }
    }
}

struct ProductFormSheet: View {
    var productToEdit: Product?

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        VStack {
            HStack {
                Button("cancel_button") {
                    dismiss()
                }
                .foregroundColor(.gray)

                Spacer()

                Text("add_new_product").font(.system(size: 16))

                Spacer()

                Button("done_button") {
                    if let priceValue = Double(price) {
                        if let productToEdit = productToEdit {
                            productToEdit.productName = name
                            productToEdit.productPrice = priceValue
                            productToEdit.productImage = selectedImageData
                        } else {
                            let newProduct = Product(productName: name, productPrice: priceValue, productImage: selectedImageData)
                            modelContext.insert(newProduct)
                        }
                        dismiss()
                    }
                }
                .foregroundColor(.blue)
            }
            .padding()

            PhotosPicker(selection: $selectedItem, matching: .images) {
                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 207)
                } else {
                    VStack {
                        Image(systemName: "photo.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(Color("C1"))
                        Text("upload_photo")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    .frame(height: 207)
                    .frame(maxWidth: .infinity)
                    .background(Color("PhotoGray"))
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }

            HStack {
                Text("product_name")
                TextField("enter_name", text: $name)
            }
            .padding()
            Divider()

            HStack {
                Text("product_price")
                TextField("enter_price", text: $price)
                    .keyboardType(.decimalPad)
            }
            .padding()

            Spacer()
        }
        .onAppear {
            if let product = productToEdit {
                name = product.productName
                price = String(product.productPrice)
                selectedImageData = product.productImage
            }
        }
    }
}

#Preview {
    ProductsView()
}
