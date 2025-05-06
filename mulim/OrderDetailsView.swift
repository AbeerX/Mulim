import SwiftUI

struct OrderDetailsView: View {
    @State private var isEditing = false

    @State private var productType = "Strawberry Cake"
    @State private var clientName = "Reem Al-Ghafis"
    @State private var customerNumber = "0502698873"
    @State private var deliveryDate = Date() // ✅ استخدم Date بدل String
    @State private var selectedStatus = "Canceled"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                groupedBox {
                    fieldRow(title: "Product Type:", text: $productType)
                }

                groupedBox {
                    fieldRow(title: "Client name:", text: $clientName)
                    Divider().padding(.horizontal, 10)
                    fieldRow(title: "Customer number:", text: $customerNumber)
                }

                groupedBox {
                    deliveryDateRow(title: "Delivery time:", date: $deliveryDate)
                    Divider().padding(.horizontal, 10)

                    HStack(alignment: .center, spacing: 10) {
                        Text("Order status:")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.black)

                        statusButton(title: "Canceled", color: Color(hex: "#FFC835"))
                        statusButton(title: "open", color: Color(hex: "#00BCD4"))
                        statusButton(title: "Closed", color: Color(hex: "#FF5722"))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Order details")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.black)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditing {
                        Button("Cancel") {
                            isEditing = false
                        }
                        .foregroundColor(Color(hex: "#999999"))
                        .font(.system(size: 18, weight: .regular))
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        if isEditing {
                            Text("Done")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Grouped Box
    private func groupedBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#00BCD4"), lineWidth: 1)
        )
    }

    // MARK: - Field Row
    private func fieldRow(title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.black)

            if isEditing {
                TextField("", text: text)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.gray)
            } else {
                Text(text.wrappedValue)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    // ✅ MARK: - Date Row
    private func deliveryDateRow(title: String, date: Binding<Date>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.black)

            if isEditing {
                DatePicker("", selection: date, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            } else {
                Text(date.wrappedValue.formatted(date: .numeric, time: .omitted))
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    // MARK: - Status Button
    private func statusButton(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(.black)
            .padding(.horizontal, 13)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedStatus == title ? color.opacity(0.4) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color, lineWidth: 1.5)
                    )
            )
            .onTapGesture {
                if isEditing {
                    selectedStatus = title
                }
            }
    }
}

// MARK: - Hex Color Support
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
    OrderDetailsView()
}
