import SwiftUI

struct NewOrder: View {

    @State private var clientName = ""
    @State private var customerNumber = ""
    @State private var productType = ""
    @State private var note = ""
    @State private var deliveryDate = Date()
    @State private var totalPrice = "50"
    
    var body: some View {
        VStack(spacing: 15) {
            Text("New order")
                .font(.title2)
                .bold()
                .padding(.top, 15)
                .padding(.bottom, 20)
               
            
            // الحقول
            RoundedTextField(title: "Customer name :", text: $clientName)
            RoundedTextField(title: "Customer phone number :", text: $customerNumber)
            RoundedTextField(title: "product :", text: $productType, trailingIcon: "plus.circle")
            RoundedTextField(title: "Note :", text: $note, trailingIcon: nil)

            // التقويم
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

            // السعر
            HStack {
                Text("Total price : \(totalPrice) SR")
                Spacer()
                Image(systemName: "pencil")
            }
            .font(.subheadline)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.customBlue, lineWidth: 1)
            )

            // زر الحفظ
            Button(action: {
                saveOrder()
            }) {
                Text("Done")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.customBlue)
                    .cornerRadius(20)
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal)
    }

    func saveOrder() {
        let newOrder = Order(
            productType: productType,
            clientName: clientName,
            customerNumber: customerNumber,
            deliveryDate: deliveryDate,
            selectedStatus: "Open"
        )

        clientName = ""
        customerNumber = ""
        productType = ""
        note = ""
        deliveryDate = Date()
        totalPrice = "50"
    }
}

// عنصر الحقل
struct RoundedTextField: View {
    var title: String
    @Binding var text: String
    var trailingIcon: String?

    var body: some View {
        HStack(spacing: 8) {
            TextField(title, text: $text)
                .font(.subheadline)
            if let icon = trailingIcon {
                Image(systemName: icon)
                    .foregroundColor(.orange)
            }
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.customBlue, lineWidth: 1)
        )
    }
}

// الامتداد لتعريف اللون الجديد
extension Color {
    static let customBlue = Color(red: 0.0, green: 0.74, blue: 0.83) // #00BCD4
}

#Preview {
    NewOrder()
}
