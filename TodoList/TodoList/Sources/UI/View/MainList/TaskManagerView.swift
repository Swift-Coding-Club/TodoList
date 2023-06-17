//
//  TaskManagerView.swift
//  TodoList
//
//  Created by 서원지 on 2022/08/08.
//

import SwiftUI

struct TaskManagerView: View {
    @StateObject var taskModel: TaskViewModel = TaskViewModel()
    @Namespace var animation
    
    // MARK: Core Data Context
    @Environment(\.managedObjectContext) var context
    // MARK: Edit Button Context
    @Environment(\.editMode) var editButton
    
    var body: some View {
        VStack {
            calenderView()
        }
    }
    
    @ViewBuilder
    func calenderView() -> some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                // MARK: Lazy Stack With Pinned Header
                LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                    Section {
                        headerView()
                        // MARK: Current Week View
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(taskModel.currentWeek, id: \.self) { day in
                                    VStack(spacing: 10) {
                                        Text(taskModel.extractDate(date: day, format: "dd"))
                                            .font(.system(size: 15))
                                            .fontWeight(.semibold)
                                        
                                        // EEE will return day as MON,TUE,....etc
                                        Text(taskModel.extractDate(date: day, format: "EEE"))
                                            .font(.system(size: 14))
                                        
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 8, height: 8)
                                            .opacity(taskModel.isToday(date: day) ? 1 : 0)
                                    }
                                    // MARK: Foreground Style
                                    .foregroundStyle(taskModel.isToday(date: day) ? .primary : .secondary)
                                    .foregroundColor(taskModel.isToday(date: day) ? .white : .secondary)
                                    // MARK: Capsule Shape
                                    .frame(width: geometry.size.width / 9, height: geometry.size.height / 9)
                                    .background(
                                        ZStack {
                                            // MARK: Matched Geometry Effect
                                            if taskModel.isToday(date: day) {
                                                Capsule()
                                                    .fill(ColorAsset.mainColor)
                                                    .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                            }
                                        }
                                    )
                                    .contentShape(Capsule())
                                    .onTapGesture {
                                        // Updating Current Day
                                        withAnimation {
                                            taskModel.currentDate = day
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        taskView()
                    }
                }
            }
        }
        
        .ignoresSafeArea(.container, edges: .top)
        // MARK: Add Button
        .overlay(
            Button(action: {
                taskModel.addNewTask.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding()
                    .background(ColorAsset.mainColor, in: Circle())
            })
            .padding(),
            alignment: .bottomTrailing
        )
        .sheet(isPresented: $taskModel.addNewTask) {
            // Clearing Edit Data
            taskModel.editTask = nil
        } content: {
            AddNewTask()
                .environmentObject(taskModel)
        }
    }
    
    // MARK: Tasks View
    @ViewBuilder
    func taskView() -> some View {
        LazyVStack(spacing: 20) {
            // Converting object as Our Task Model
            DynamicFilteredView(dateToFilter: taskModel.currentDate) { (object: Task) in
                taskCardView(task: object)
            }
        }
        .padding()
        .padding(.top)
    }
    
    // MARK: Task Card View
    @ViewBuilder
    func taskCardView(task: Task) -> some View {
        // MARK: Since CoreData Values will Give Optinal data
        HStack(alignment: editButton?.wrappedValue == .active ? .center: .top, spacing: 30) {
            // If Edit mode enabled then showing Delete Button
            if editButton?.wrappedValue == .active {
                // Edit Button for Current and Future Tasks
                VStack(spacing: 10) {
                    if task.taskDate?.compare(Date()) == .orderedDescending || Calendar.current.isDateInToday(task.taskDate ?? Date()) {
                        Button {
                            taskModel.editTask = task
                            taskModel.addNewTask.toggle()
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title)
                        }
                    }
                    Button {
                        // MARK: Deleting Task
                        context.delete(task)
                        // Saving
                        try? context.save()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
            } else {
                // MARK: - 라인 색상
                VStack(spacing: 10) {
                    Circle()
                        .fill(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? (task.isCompleted ? ColorAsset.mainColor : .clear) : .clear)
                        .frame(width: 15, height: 15)
                        .background(
                            Circle()
                                .stroke(.clear, lineWidth: 0.5)
                                .padding(-3)
                        )
                        .scaleEffect(!taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0.8 : 1)
                    Rectangle()
                        .fill(ColorAsset.mainColor)
                        .frame(width: 3)
                        .cornerRadius(15)
                }
            }
            
            VStack {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(task.taskTitle ?? "")
                        
                        Text(task.taskDescription ?? "")
                            .font(.callout)
                    }
                    .hLeading()
                    
                    Text(task.taskDate?.formatted(date: .omitted, time: .shortened) ?? "")
                }
                .foregroundColor(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? .white : .secondary)
                
                if taskModel.isCurrentHour(date: task.taskDate ?? Date()) {
                    // MARK: Team Members
                    HStack(spacing: 12) {
                        // MARK: Check Button
                        if !task.isCompleted {
                            Button {
                                // MARK: Updating Task
                                task.isCompleted = true
                                // Saving
                                try? context.save()
                            } label: {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(ColorAsset.mainColor)
                                    .padding(10)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        Text(task.isCompleted ? "Completed tasks" : "Incompleted task")
                            .font(.system(size: task.isCompleted ? 14 : 16, weight: .light))
                            .foregroundColor(task.isCompleted ? .white : .white)
                            .hLeading()
                    }
                    .padding(.top)
                }
            }
            .padding(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 15 : 0)
            .padding(.bottom, taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0 : 10)
            .hLeading()
            .background(
                Color("MainColor")
                    .cornerRadius(25)
                    .opacity(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 1 : 0)
            )
        }
        .hLeading()
    }
    
    // MARK: Header
    @ViewBuilder
    func headerView() -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                // Text(Date().formatted(date: .abbreviated, time: .omitted))
                Text("TodoList")
                    .font(.title.bold())
                    .font(.custom("Helvetica Neue Bold", size: 30))
            }
            .foregroundColor(ColorAsset.mainColor)
            .hLeading()
            // MARK: Edit Button
            EditButton()
                .foregroundColor(ColorAsset.mainColor)
        }
        .padding()
        .padding(.top, getSafeArea().top)
    }
}

struct TaskManagerView_Previews: PreviewProvider {
    static var previews: some View {
        TaskManagerView()
    }
}
