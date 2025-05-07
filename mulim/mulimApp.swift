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
    @State private var hasCompletedFirstSetup = false // ✅ هنا

    var body: some Scene {

        WindowGroup {
                    if hasCompletedFirstSetup {
                        MainTabView()
                    } else {
                        Products1stView(hasCompletedFirstSetup: $hasCompletedFirstSetup)
                    }
                }
         .modelContainer(for: Product.self) // ✅ مكانه الصحيح هنا

     }

  /*  @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
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
    }*/
}
