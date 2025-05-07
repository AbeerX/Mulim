//
//  mulimApp.swift
//  mulim
//
//  Created by Alanoud Alamrani on 03/11/1446 AH.
//

import SwiftUI
import SwiftData
@main
struct mulimApp: App {
    //    var body: some Scene {
    //         WindowGroup {
    //             Products1stView().modelContainer(for: Product.self)
    //         }
    //     }
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainTabView()
                    .environment(\.font, Font.custom("Tajawal-Regular", size: 16))
            } else {
                Onbording()
                    .environment(\.font, Font.custom("Tajawal-Regular", size: 16))
            }
        }
    }
}
