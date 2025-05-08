//
//  maintabview.swift
//  mulim
//
//  Created by Alanoud Alamrani on 08/11/1446 AH.
//
//
//import SwiftUI
//
//
//struct MainTabView: View {
//    var body: some View {
//        TabView {
//            Text("Orders Screen Placeholder") // مؤقتًا
//            
//            NavigationStack {
//                TabView {
//                    NavigationStack {
//                        Main()
//                    }
//                    Main()
//
//                        .tabItem {
//                            Image(systemName: "house.fill")
//                            Text("Main")
//                            
//                            
//                        }
//                    Text("Orders Screen Placeholder") // مؤقتًا
//                    
//                        .tabItem {
//                            Image(systemName: "cart.fill.badge.plus")
//                            Text("Orders")
//                        }
//                    
//                    products()
//                        .tabItem {
//                            Image(systemName: "book.pages.fill")
//                            Text("Products")
//                        }
//                }
//                .accentColor(Color("C1"))
//            }
//        }
//    }}
import SwiftUI
import SwiftData

struct MainTabView: View {
    @Query var orders: [Order]
    @EnvironmentObject var orderManager: OrderManager

    var body: some View {
        TabView {
            NavigationStack {
                Main(orderManager: orderManager, orders: orders)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Main")
            }

            NavigationStack {
                OrdersView()
            }
            .tabItem {
                Image(systemName: "cart.fill.badge.plus")
                Text("Orders")
            }

            NavigationStack {
                products()
            }
            .tabItem {
                Image(systemName: "book.pages.fill")
                Text("Products")
            }
        }
        .accentColor(Color("C1"))
    }
}

