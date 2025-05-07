//
//  maintabview.swift
//  mulim
//
//  Created by Alanoud Alamrani on 08/11/1446 AH.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        NavigationStack {
            TabView {
                NavigationStack {
                    Main()
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Main")
                    
                   
                }
                
                NavigationStack {
               
                }
                .tabItem {
                    Image(systemName: "cart.fill.badge.plus")
                        .resizable()
                        .frame(width: 22, height: 22)
                    Text("Orders")
                }
                
                NavigationStack {
                  
                }
                .tabItem {
                    Image(systemName: "book.pages.fill")
                    Text("Products")
                }
            }
            .accentColor(Color("C1"))
            .navigationBarBackButtonHidden(true)
        }
    }
}


