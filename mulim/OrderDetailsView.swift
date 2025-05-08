import SwiftUI
import SwiftData

struct OrderDetailsView: View {
    @Bindable var order: Order
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var showContactPicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    if isEditing {
                        Button("Cancel") {
                            isEditing = false
                        }
                        .foregroundColor(.gray)
                    } else {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.backward")
                                Text("Back")
                            }
                        }
                        .foregroundColor(.blue)
                    }

                    Spacer()

                    Text("Order details")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: {
                        if isEditing {
                            isEditing = false
                            dismiss()
                        } else {
                            isEditing = true
                        }
                    }) {
                        if isEditing {
                            Text("Done")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 20) {
                        groupedBox {
                            fieldRow(title: "Product Type:", text: $order.productType)
                        }

                        groupedBox {
                            fieldRow(title: "Client name:", text: $order.clientName)
                            Divider().padding(.horizontal, 10)
                            phoneRow(title: "Customer number:", text: $order.customerNumber)
                        }

                        groupedBox {
                            deliveryDateRow(title: "Delivery time:", date: $order.deliveryDate)
                            Divider().padding(.horizontal, 10)

                            HStack(alignment: .center, spacing: 10) {
                                Text("Order status:")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)

                                statusButton(title: "Canceled", color: Color(hex: "#FFC835"))
                                statusButton(title: "Open", color: Color(hex: "#00BCD4"))
                                statusButton(title: "Closed", color: Color(hex: "#FF5722"))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 12)
                        }

                        groupedBox {
                            noteRow(title: "Note:", text: $order.note)
                        }

                        Spacer()
                    }
                    .padding(.top, 12)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showContactPicker) {
                ContactPicker(selectedPhoneNumber: $order.customerNumber)
            }
        }
    }

    private func groupedBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#00BCD4"), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private func fieldRow(title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(.black)

            if isEditing {
                TextField("", text: text)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            } else {
                Text(text.wrappedValue)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    private func phoneRow(title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(.black)

            if isEditing {
                TextField("", text: text)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)

                Button(action: {
                    showContactPicker = true
                }) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundColor(.blue)
                }
            } else {
                Text(text.wrappedValue)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    private func deliveryDateRow(title: String, date: Binding<Date>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(.black)

            if isEditing {
                DatePicker("", selection: date, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            } else {
                Text(date.wrappedValue.formatted(date: .numeric, time: .omitted))
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    private func noteRow(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(.black)

            if isEditing {
                TextEditor(text: text)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "#00BCD4"), lineWidth: 1)
                    )
            } else {
                Text(text.wrappedValue.isEmpty ? "No note" : text.wrappedValue)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    private func statusButton(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 12))
            .foregroundColor(.black)
            .padding(.horizontal, 13)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(order.selectedStatus == title ? color.opacity(0.4) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color, lineWidth: 1.5)
                    )
            )
            .onTapGesture {
                if isEditing {
                    order.selectedStatus = title
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
    let sampleOrder = Order(
        productType: "Test Cake",
        clientName: "Test Client",
        customerNumber: "0500000000",
        deliveryDate: .now,
        selectedStatus: "Open",
        note: "Extra note here"
    )
    return OrderDetailsView(order: sampleOrder)
}
