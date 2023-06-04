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
    @State private var showLaunchView: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                TodoListMainHomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
                ZStack {
                    if showLaunchView {
                        LaunchView(showLaunchView: $showLaunchView)
                            .transition(.move(edge: .leading))
                    }
                }
                .zIndex(1.0)
            }
        }
    }
}
