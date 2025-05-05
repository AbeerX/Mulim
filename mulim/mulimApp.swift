//
//  mulimApp.swift
//  mulim
//
//  Created by Alanoud Alamrani on 03/11/1446 AH.
//

import SwiftUI

@main
struct mulimApp: App {
    var body: some Scene {
        WindowGroup {
           // ContentView()
            Onbording()
                .environment(\.font, Font.custom("Tajawal-Regular", size: 16))
        }
    }
}
