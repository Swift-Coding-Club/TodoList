//
//  AddNewTask.swift
//  TodoList
//
//  Created by 서원지 on 2022/08/10.
//

import SwiftUI

struct AddNewTask: View {
    @Environment(\.dismiss) var dismiss
    
    // MARK: Task Values
    @State var taskTitle: String = ""
    @State var taskDescription: String = ""
    @State var taskDate: Date = Date()
    
    // MARK: Core Data Context
    @Environment(\.managedObjectContext) var context
    
    @EnvironmentObject var taskModel: TaskViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Title", text: $taskTitle)
                }
                .onAppear(perform: UIApplication.shared.hideKeyboard)

                Section {
                    TextField("Description", text: $taskDescription)
                }
                .onAppear(perform: UIApplication.shared.hideKeyboard)
                // Disabling Date for Edit Mode
                if taskModel.editTask == nil {
                    Section {
                        DatePicker("", selection: $taskDate)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .font(.custom("나눔손글씨 둥근인연", size: 15))
            .navigationTitle("새로운 할 일")
            .navigationBarTitleDisplayMode(.inline)
            // MARK: Action Buttons
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("추가") {
                        if let task = taskModel.editTask {
                            task.taskTitle = taskTitle
                            task.taskDescription = taskDescription
                        } else {
                            let task = Task(context: context)
                            task.taskTitle = taskTitle
                            task.taskDescription = taskDescription
                            task.taskDate = taskDate
                        }
                        
                        // Saving
                        try? context.save()
                        // Dismissing View
                        dismiss()
                    }
                    .disabled(taskTitle == "" || taskDescription == "")
                    .foregroundColor(ColorAsset.mainColor)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(ColorAsset.mainColor)
                }
            }
            // Loading Task data if from Edit
            .onAppear {
                if let task = taskModel.editTask {
                    taskTitle = task.taskTitle ?? ""
                    taskDescription = task.taskDescription ?? ""
                }
            }
        }
    }
}

struct AddNewTask_Previews: PreviewProvider {
    static var previews: some View {
        AddNewTask()
            .environmentObject(TaskViewModel())
    }
}
