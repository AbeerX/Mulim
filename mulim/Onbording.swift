//
//  Onbording.swift
//  mulim
//
//  Created by Alanoud Alamrani on 06/11/1446 AH.
//

import SwiftUI

struct Onbording: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    var body: some View {

        NavigationStack {
            
            
            VStack {
                HStack {
                    Spacer()
                    Text("Skip")
                        .foregroundColor(Color("C1"))
                        .font(.system(size: 18, weight: .bold))
                        .padding()
                }
                
                TabView {
                    OnbordingPage(imageName: "OB1", title: "Welcome to Mulim!", description: """
              Easily manage your bookings and track your store reports.
              All your tools in one place to save time and focus on growing your business.
              """)
                    
                    OnbordingPage(imageName: "OB2", title: "", description: """
                Easily explore every order's details
              everything you need is just a tap away
              
              """)
                    
                    
                    VStack{
                        
                        OnbordingPage(imageName: "OB3", title: "", description: """
              Schedule order deliveries by day and track them with ease.
              Browse past and upcoming orders, and organize your schedule accurately and on time.
              """)
                        
                        NavigationLink(destination: Main()) {
                            
                            Text("Get Started")
                                .foregroundColor(.black)
                                .font(.system(size: 18, weight: .bold))
                                .padding()
                                .frame(width: 362, height: 52)
                                .background(Color("C1"))
                                .cornerRadius(25)
                            
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            hasSeenOnboarding = true
                        })
                    }
                    
                }
                
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }.navigationBarBackButtonHidden(true)

        
    }

    
        struct OnbordingPage:View {
            
            var imageName: String
            var title: String
            var description: String
            
            var body: some View {
                
                VStack {
                    Image(imageName)
                        .frame(height: 350)
                    Text(title)
                        .padding(.bottom, 4)
                    Text(description)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14))
                        .lineLimit(nil)
                    
                } .padding(.bottom, 140.0)
                
            }
        }
        
    }
    

#Preview {
    Onbording()
}
