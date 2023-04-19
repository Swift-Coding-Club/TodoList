//
//  View.swift
//  TodoList
//
//  Created by 서원지 on 2022/08/08.
//

import SwiftUI
//MARK:  - 뷰 확장 레이아웃
extension View {
    func hLeading() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func hTralling() -> some View {
        self.frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    func hCenter() -> some View {
        self.frame(maxWidth: .infinity, alignment: .center)
    }
    
    func getSafeArea()->UIEdgeInsets{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .zero
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        return safeArea
    }
}
