//
//  maintabview.swift
//  mulim
//
//  Created by Alanoud Alamrani on 08/11/1446 AH.
//
//
import SwiftUI


struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Orders Screen Placeholder") // مؤقتًا

                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Main")
                }
            Text("Orders Screen Placeholder") // مؤقتًا

                .tabItem {
                    Image(systemName: "cart.fill.badge.plus")
                    Text("Orders")
                }

            products()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Products")
                }
        }
        .accentColor(Color("C1"))
    }
}
