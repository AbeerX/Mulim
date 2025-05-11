import Foundation
import SwiftData

@Model
class OrderedProduct {
    @Attribute var name: String
    @Attribute var quantity: Int
    @Attribute var price: Double

    init(name: String, quantity: Int, price: Double) {
        self.name = name
        self.quantity = quantity
        self.price = price
    }
}

@Model
class Order {
    @Attribute(.unique) var id: UUID
    @Attribute var clientName: String
    @Attribute var customerNumber: String
    @Attribute var deliveryDate: Date
    @Attribute var selectedStatus: String
    @Attribute var note: String
    @Attribute var orderedProducts: [OrderedProduct]

    init(
        id: UUID = UUID(),
        clientName: String,
        customerNumber: String,
        deliveryDate: Date,
        selectedStatus: String,
        note: String = "",
        orderedProducts: [OrderedProduct] = []
    ) {
        self.id = id
        self.clientName = clientName
        self.customerNumber = customerNumber
        self.deliveryDate = deliveryDate
        self.selectedStatus = selectedStatus
        self.note = note
        self.orderedProducts = orderedProducts
    }

    var totalPrice: Double {
        orderedProducts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    var productType: String {
        orderedProducts.first?.name ?? "-"
    }
}
