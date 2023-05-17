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
    // MARK: Font Select
    @EnvironmentObject var fontSettings: FontSettings
    
    var body: some View {
        NavigationView {
            VStack {
                calenderView()
            }
            
        }
    }
    
    @ViewBuilder
    func calenderView() -> some View {
        GeometryReader { gemotry in
            ScrollView(.vertical, showsIndicators: false) {
                // MARK: Lazy Stack With Pinned Header
                LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                    Section {
                        // MARK: Current Week View
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            HStack(spacing: 10){
                                
                                ForEach(taskModel.currentWeek, id: \.self){day in
                                    
                                    VStack(spacing: 10){
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
                                    .foregroundColor(taskModel.isToday(date: day) ? .white : ColorAsset.dateColor)
                                    // MARK: Capsule Shape
                                    .frame(width: (gemotry.size.width / 9), height: (gemotry.size.height / 9))
                                    .background(
                                        
                                        ZStack{
                                            // MARK: Matched Geometry Effect
                                            if taskModel.isToday(date: day){
                                                Capsule()
                                                    .fill(ColorAsset.mainViewColor)
                                                    .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                            }
                                        }
                                    )
                                    .contentShape(Capsule())
                                    .onTapGesture {
                                        // Updating Current Day
                                        withAnimation{
                                            taskModel.currentDate = day
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        tasksView()
                    } header: {
                        headerView()
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
                    .background(ColorAsset.mainViewColor, in: Circle())
            })
            .padding()
            
            ,alignment: .bottomTrailing
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
    func tasksView()->some View{
        LazyVStack(spacing: 20){
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
    func taskCardView(task: Task) -> some View{
        // MARK: Since CoreData Values will Give Optinal data
        HStack(alignment: editButton?.wrappedValue == .active ? .center : .top, spacing: 30){
            // If Edit mode enabled then showing Delete Button
            if editButton?.wrappedValue == .active{
                // Edit Button for Current and Future Tasks
                VStack(spacing: 10){
                    if task.taskDate?.compare(Date()) == .orderedDescending || Calendar.current.isDateInToday(task.taskDate ?? Date()){
                        
                        Button {
                            taskModel.editTask = task
                            taskModel.addNewTask.toggle()
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title)
                                .foregroundColor(ColorAsset.dateColor)
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
            }
            else{
                //MARK: - 라인 색상
                VStack(spacing: 10){
                    Circle()
                        .fill(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? (task.isCompleted ? .green : ColorAsset.dateColor) : .clear)
                        .frame(width: 15, height: 15)
                        .background(
                            
                            Circle()
                                .stroke(ColorAsset.dateColor, lineWidth: 0.5)
                                .padding(-3)
                        )
                        .scaleEffect(!taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0.8 : 1)
                    Rectangle()
                        .fill(ColorAsset.mainViewColor)
                        .frame(width: 3)
                }
            }
            
            VStack{
                
                HStack(alignment: .top, spacing: 10) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text(task.taskTitle ?? "")
                            .font(.custom(fontSettings.selectedFont.rawValue, size: 20))
                            //.font(.title2.bold())
                            //.foregroundColor(ColorAsset.dateColor)
                        
                        Text(task.taskDescription ?? "")
                            //.font(.callout)
                            //.foregroundColor(Color(.lightGray))
                            //.foregroundStyle(.secondary)
                            .font(.custom(fontSettings.selectedFont.rawValue, size: 20))

                    }
                    .hLeading()
                    
                    Text(task.taskDate?.formatted(date: .omitted, time: .shortened) ?? "")
                        .foregroundColor(ColorAsset.dateColor)
                }
                
                if taskModel.isCurrentHour(date: task.taskDate ?? Date()){
                    
                    // MARK: Team Members
                    HStack(spacing: 12){
                        // MARK: Check Button
                        if !task.isCompleted{
                            Button {
                                // MARK: Updating Task
                                task.isCompleted = true
                                // Saving
                                try? context.save()
                            } label: {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(ColorAsset.titleColor, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        Text(task.isCompleted ? "Marked as Completed" : "Mark Task as Completed")
                            .font(.system(size: task.isCompleted ? 14 : 16, weight: .light))
                            .foregroundColor(task.isCompleted ? .white : .white)
                            .hLeading()
                    }
                    .padding(.top)
                }
            }
            .foregroundColor(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? ColorAsset.dateColor :  ColorAsset.dateColor)
            
            .padding(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 15 : 0)
            .padding(.bottom, taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0 : 10)
            .hLeading()
            .background(
                Color("MainColor2")
                    .cornerRadius(25)
                    .opacity(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 1 : 0)
            )
        }
        .hLeading()
    }
    // MARK: Header
    @ViewBuilder
    func headerView() -> some View{
        HStack(spacing: 10){
            VStack(alignment: .leading, spacing: 10) {
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.gray)
                Text("Todo List 📝")
                    .font(.largeTitle.bold())
            }
            .foregroundColor(ColorAsset.mainViewColor)
            .hLeading()
            // MARK: Edit Button
            EditButton()
                .foregroundColor(ColorAsset.mainViewColor)
            // MARK: Setting Button
            NavigationLink {
                settingView()
            } label: {
                Text("설정")
            }
            
        }
        .padding()
        .padding(.top, getSafeArea().top)
    }
    
    @ViewBuilder
    func settingView() -> some View {
        VStack {
            List(FontType.allCases, id: \.self) { font in
                Button {
                    fontSettings.selectedFont = font
                } label: {
                    HStack {
                        Text(font.rawValue)
                        if font == fontSettings.selectedFont {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .navigationTitle("본문 폰트 설정")

    }
}

struct TaskManagerView_Previews: PreviewProvider {
    static var previews: some View {
        TaskManagerView()
    }
}
