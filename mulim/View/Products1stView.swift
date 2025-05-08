//
//  Untitled.swift
//  mulim
//
//  Created by Noura Alrowais on 08/11/1446 AH.

import SwiftUI
import Foundation
import SwiftData
import PhotosUI
struct Products1stView: View {
    var onFinish: () -> Void
    @State private var showSheet = false
    @Query var products: [Product]
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(spacing: 0) {

                
                if products.isEmpty{
                    Spacer()
                    Text("Enter your products with prices to make it easier to manage your products and track your income.").font(.system(size: 14)).foregroundColor(Color.gray).multilineTextAlignment(.center).lineLimit(nil).frame(height: 45.0).padding().padding(.top,200)
                    
                }
                else{
                    
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(products) { product in
                            VStack {
                                if let data = product.productImage, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 21))
                                        .clipped()
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 150, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 21))
                                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                                }
                                
                                Text(product.productName)
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                
                                Text("\(product.productPrice, specifier: "%.2f") SR")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .padding(.top, -50) 

                }
            }
            //.padding(.bottom, 150.0)
            .sheet(isPresented: $showSheet) {
                NavigationStack {
                    productSheet()
                }
                .presentationDetents([.medium])
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSheet.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(Color("C1"))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Add Your Products")
                        .font(.system(size: 18))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if products.isEmpty{
                        Button(action: {
                            //onFinish()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onFinish()
                            }
                        }){
                            Text("Skip")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(Color("C1"))
                        }
                    }
                    else{
                        Button(action: {
                            //onFinish()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onFinish()
                            }
                        }){
                            Text("Next")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(Color("C1"))
                        }
                    }
                }
            }
        }
        }
    }
}

struct productSheet: View {
    var productToEdit: Product? = nil

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var name: String = ""
    @State private var price: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    var body: some View {
        
        VStack{
            HStack{
                
       Button("Done") {
                    if let priceValue = Double(price) {
                        if let productToEdit = productToEdit {
                            // تعديل
                            productToEdit.productName = name
                            productToEdit.productPrice = priceValue
                            productToEdit.productImage = selectedImageData
                        } else {
                            // إضافة جديدة
                            let newProduct = Product(productName: name, productPrice: priceValue, productImage: selectedImageData)
                            modelContext.insert(newProduct)
                        }
                        dismiss()
                    }
                }
                .foregroundColor(.blue)
                Spacer()
                Text("Add New Product").font(.system(size: 16))
              Spacer()
                Button("Cancel"){
                    dismiss()
                }
                .foregroundColor(.gray)
                
            }
            .padding()
            PhotosPicker(selection: $selectedItem, matching: .images) {
                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height:207)
                       
                } else {
                    VStack {
                        Image(systemName: "photo.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(Color("C1"))
                        Text("Upload Photo")
                            .font(.system(size: 14))
                            .foregroundColor(Color.black)
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

            HStack{
                Text("Product Name:")
                TextField("Enter Product Name", text: $name)
            }
            .padding()
            Divider()
            HStack{
                Text("Product Price:")
                TextField("Enter Product Price", text: $price)
                    .keyboardType(.decimalPad)
            }.padding()
            
        }
        .onAppear {
            if let product = productToEdit {
                name = product.productName
                price = String(product.productPrice)
                selectedImageData = product.productImage
            }
        }

        Spacer()
    }
}
#Preview {
    Products1stView(onFinish: {})
}
