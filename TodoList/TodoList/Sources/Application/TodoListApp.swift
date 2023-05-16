//
//  TodoListApp.swift
//  TodoList
//
//  Created by 서원지 on 2022/08/04.
//

import SwiftUI
import CoreData

@main
struct TodoListApp: App {
    let persistenceController = PersistenceController.shared
    @State private var showLanchView: Bool = true
    @StateObject var fontSettings = FontSettings()
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                TodoLIstMainHomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(fontSettings)
                ZStack{
                    if showLanchView {
                        LanchView(showLanchView: $showLanchView)
                            .transition(.move(edge: .leading))
                    }
                }
                .zIndex(1.0)
            }
        }
    }
}
