//
//  mulimApp.swift
//  mulim
//
//  Created by Alanoud Alamrani on 03/11/1446 AH.
//

import SwiftUI
import SwiftData
import AppIntents
import UserNotifications
@main
struct mulimApp: App {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("hasCompletedFirstSetup") var hasCompletedFirstSetup: Bool = false
   // @Query var ordersarray: [Order]
    @StateObject private var orderManager = OrderManager()

    var body: some Scene {
        WindowGroup {
            
            if !hasSeenOnboarding {
                
                Onbording()
                    .environmentObject(orderManager)
                    .preferredColorScheme(.light)
            } else if !hasCompletedFirstSetup {
                Products1stView {
                    hasCompletedFirstSetup = true
                }
                .environmentObject(orderManager)
                .preferredColorScheme(.light)
            } else {
                MainTabView()
                    .environmentObject(orderManager)
                    .preferredColorScheme(.light)
                  
            }
        }
        .modelContainer(for: [Product.self, Order.self])

//        WindowGroup {
//            if !hasSeenOnboarding {
//                Onbording()
//            } else if !hasCompletedFirstSetup {
//                Products1stView {
//                    hasCompletedFirstSetup = true
//                }
//            } else {
//                MainTabView()
//                    .environmentObject(orderManager)
//            }
//        }
//        .modelContainer(for: [Product.self, Order.self])
//
        

    }
}
// طلب الإذن للإشعارات
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
            print("✅ Notification permission granted.")
        } else {
            print("❌ Notification permission denied.")
        }
    }
}

func scheduleOrderNotifications(orders: [Order]) {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    
    print("📦 Total fetched orders: \(orders.count)")

    let todayOrders = orders.filter {
        calendar.isDate($0.deliveryDate, inSameDayAs: today) && $0.selectedStatus == "Open"
    }

    print("📅 Today's open orders: \(todayOrders.count)")

    let overdueOrders = orders.filter {
        $0.deliveryDate < today && $0.selectedStatus == "Open"
    }

    print("⏰ Overdue open orders: \(overdueOrders.count)")

    if !todayOrders.isEmpty {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Notification_today_title", comment: "")
        content.body = String(format: NSLocalizedString("Notification_today_body", comment: ""), todayOrders.count)
        content.sound = .default
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date().addingTimeInterval(60)) // بعد دقيقة

        var morningTime = DateComponents()
        morningTime.hour = 10 //اذا تبون تجربون حطوا هذا now.hour
        morningTime.minute = 00 //اذا تبون تجربون حطوا هذا now.minute
        print("🔔 Scheduling todayOrders notification at 23:38")
        scheduleNotification(content: content, at: morningTime, id: "todayOrders")
    }

    for order in overdueOrders {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Notification_late_title", comment: "")
        content.body = String(format: NSLocalizedString("Notification_late_body", comment: ""), order.clientName)
        content.sound = .default
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date().addingTimeInterval(60)) // بعد دقيقة

        var eveningTime = DateComponents()
        eveningTime.hour = 19 //اذا تبون تجربون حطوا هذا now.hour
        eveningTime.minute = 00 //اذا تبون تجربون حطوا هذا now.minute
        let id = "late-\(order.id.uuidString)"
        print("⚠️ Scheduling overdue notification for \(order.clientName) at 21:00")
        scheduleNotification(content: content, at: eveningTime, id: id)
    }
}


func scheduleNotification(content: UNNotificationContent, at time: DateComponents, id: String) {
    let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

    print("📬 Trying to add notification with ID: \(id) at hour: \(time.hour ?? 0), minute: \(time.minute ?? 0)")

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("❌ Notification error: \(error.localizedDescription)")
        } else {
            print("✅ Notification scheduled: \(id)")
        }
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
