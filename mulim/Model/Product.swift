//
//  Untitled.swift
//  mulim
//
//  Created by Noura Alrowais on 08/11/1446 AH.
//

import Foundation
import SwiftUI
import SwiftData
@Model
class Product{
    var productName: String
    var productPrice: Double
    var productImage: Data?
    init(productName: String, productPrice: Double, productImage: Data? = nil) {
        self.productName = productName
        self.productPrice = productPrice
        self.productImage = productImage
    
    }
    
}
