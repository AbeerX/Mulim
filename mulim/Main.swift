//
//  Main.swift
//  mulim
//
//  Created by Alanoud Alamrani on 08/11/1446 AH.
//

import SwiftUI

struct Main: View {
    var body: some View {
        
        VStack {
            
            Text("Welcome..")
                .fontWeight(.bold)
                .font(.system(size: 18))
                .padding(.trailing, 266.0)
                .padding(.bottom, 16)
            
            Text("Report")
                .fontWeight(.bold)
                .padding(.trailing, 300.0)
            
            HStack {
                ZStack{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Corner Radius@*/10.0/*@END_MENU_TOKEN@*/)
                        .fill(Color("C2"))
                        .frame(width: 146, height: 96)
                    VStack{
                        Text("")
                        Text("Best Selling Product")
                        .foregroundColor(Color(.gray))
                        .font(.system(size: 12))
                    }
                }
                ZStack{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Corner Radius@*/10.0/*@END_MENU_TOKEN@*/)
                        .fill(Color("C2"))
                        .frame(width: 146, height: 96)
                    
                    VStack{
                        Text("")
                        Text("Income")
                        .foregroundColor(Color(.gray))
                        .font(.system(size: 12))
                    }
                }
                
            }
        }

    }
}

#Preview {
    Main()
}
