//
//  SwiftUIView.swift
//  mulim
//
//  Created by Noura Alrowais on 15/11/1446 AH.
//

import SwiftUI

struct Splash: View {
    @State private var opacity = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var hideSplash = false

    var body: some View {
        ZStack {
           
                Color.white
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 298.72, height: 371)
                        .opacity(opacity)
                        .scaleEffect(scale)
                        .onAppear {
                            // تظهر الصورة بتدرج وتكبر شوي
                            withAnimation(.easeOut(duration: 1.5)) {
                                opacity = 1.0
                                scale = 1.0
                            }

                     

                           
                            }
                        }
                }
            
        }
    }


#Preview {
    Splash()
}

