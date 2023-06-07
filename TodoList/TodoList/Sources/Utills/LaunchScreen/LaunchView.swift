//
//  LaunchView.swift
//  TodoList
//
//  Created by 서원지 on 2023/02/17.
//

import SwiftUI

struct LaunchView: View {
    @Binding var showLaunchView: Bool
    
    var body: some View {
        ZStack {
            Color("MainColor")
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                Image("Icon")
                    .resizable()
                    .frame(width: 150, height: 150)
                
                Spacer()
                    .frame(height: 20)
                
                Text("한다")
                    .font(.custom("Helvetica Neue Bold", size: 30))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showLaunchView.toggle()
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(showLaunchView: .constant(false))
    }
}
