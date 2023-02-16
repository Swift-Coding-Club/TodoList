//
//  LanchView.swift
//  TodoList
//
//  Created by 서원지 on 2023/02/17.
//

import SwiftUI

struct LanchView: View {
    @Binding var showLanchView: Bool
    
    var body: some View {
        ZStack{
            Color("MainColor2")
                .ignoresSafeArea()
            
            VStack(alignment: .center){
                Image("to-do-list 1")
                    .resizable()
                    .frame(width: 150, height: 150)
                
                Spacer()
                    .frame(height: 20)
                
                Text("한다(Handa)")
                    .font(.custom("Helvetica Neue Bold", size: 30))
                    .foregroundColor(.white)
            }
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showLanchView.toggle()
            }
        }
    }
}

struct LanchView_Previews: PreviewProvider {
    static var previews: some View {
        LanchView(showLanchView: .constant(false))
    }
}

