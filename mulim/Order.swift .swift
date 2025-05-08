import Foundation
import SwiftData

@Model
class Order {
    @Attribute(.unique) var id: UUID
    var productType: String
    var clientName: String
    var customerNumber: String
    var deliveryDate: Date
    var selectedStatus: String
    var note: String
    var productPrice: Double // ✅ السعر محفوظ هنا

    init(id: UUID = UUID(), productType: String, clientName: String, customerNumber: String, deliveryDate: Date, selectedStatus: String, note: String = "", productPrice: Double = 0.0) {
        self.id = id
        self.productType = productType
        self.clientName = clientName
        self.customerNumber = customerNumber
        self.deliveryDate = deliveryDate
        self.selectedStatus = selectedStatus
        self.note = note
        self.productPrice = productPrice
    }

    var totalPrice: Double {
        return productPrice
    }
}
