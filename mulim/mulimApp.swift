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
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("hasCompletedFirstSetup") var hasCompletedFirstSetup: Bool = false

    var body: some Scene {
        WindowGroup {
            if !hasSeenOnboarding {
                Onbording()
            } else if !hasCompletedFirstSetup {
                Products1stView {
                    hasCompletedFirstSetup = true
                }
            } else {
                MainTabView()
            }
        }
        .modelContainer(for: Product.self)
    }
}


//@main
//struct mulimApp: App {
//    @AppStorage("hasCompletedFirstSetup") private var hasCompletedFirstSetup = false
//    var body: some Scene {
//        
//        WindowGroup {
//            if hasCompletedFirstSetup {
//                MainTabView()
//            } else {
//                Products1stView(onFinish: {
//                                 hasCompletedFirstSetup = true
//                             })
//                         }
//        }
//        .modelContainer(for: Product.self) // ✅ مكانه الصحيح هنا
//        
//    }}

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
    }
}
*/
