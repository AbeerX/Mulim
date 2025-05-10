//
//  products.swift
//  mulim
//
//  Created by Abeer on 08/11/1446 AH.
//
import SwiftUI
import SwiftData

struct products: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [Product]

    @State private var showAddSheet = false
    @State private var editProduct: Product?

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack {
                if products.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        
//شعار اللوقو هنا
                        Image("logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 186, height: 231.01)

                        
                        Text("Thereـareـnoـproductsـcurrentlyـavailable.")
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

                                    // الاسم
                                    Text(product.productName)
                                        .font(.custom("SFPro", size: 18))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                           //السعر

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
//
                                    
                                }
                                .padding()
                                
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("C1"))
//                                        .frame(width: 376, height: 82)
                                        .frame(width: 360, height: 82)

                                      )
                                
                                
                            }
                        }
                        
                        .padding(.top, -50) // تقليل المسافه بين العنوان وتحته

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
                    productSheet(productToEdit: editProduct)
                }
                .presentationDetents([.medium])
            }
        }
    }
}


#Preview {
  products()
}

