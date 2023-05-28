//
//  DynamicFilteredView.swift
//  TodoList
//
//  Created by 서원지 on 2022/08/10.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View, T>: View where T: NSManagedObject {
    //MARK: - Core Data Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    @StateObject var taskModel: TaskViewModel = TaskViewModel()
    @State var animate: Bool = false
    
    //MARK: - Building Custom ForEach which will give CoreData object to build View
    init(dateToFilter: Date, @ViewBuilder content: @escaping (T) -> Content) {
        //MARK: - Predicate to Filter current date Task
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: dateToFilter)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        // Filter Key
        let filterKey = "taskDate"
        // This will fetch task between today and tomorrow which is 24 hours
        let predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@", argumentArray: [today, tomorrow])
        
        // Intializing Request With NSPredicate
        // Adding Sort
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [.init(keyPath: \Task.taskDate, ascending: false)], predicate: predicate)
        self.content = content
    }
    
    var body: some View {
        todoEmptyView()
    }
    
    @ViewBuilder
    private func todoEmptyView() -> some View {
        Group {
            if request.isEmpty {
                GeometryReader { geometry in
                    VStack(spacing: 10) {
                        Text("리스트가 없어요 😰")
                            .font(.custom("나눔손글씨 둥근인연", size: 30))
                            .fontWeight(.black)
                            .foregroundColor(ColorAsset.fontColor.opacity(1.0))
                        Text("혹시 오늘 할일이 없어요 ☹️?")
                            .fontWeight(.semibold)
                            .font(.custom("나눔손글씨 둥근인연", size: 18))
                        Text("만약에 할일이  있으면  Todo 리스트에 ")
                            .fontWeight(.semibold)
                            .font(.custom("나눔손글씨 둥근인연", size: 18))
                        Text("오늘의 할일을 추가 하는게 어떻게 생각해 😝")
                            .fontWeight(.semibold)
                            .font(.custom("나눔손글씨 둥근인연", size: 18))
                            .padding(.bottom, 80)
                            .overlay(
                                Button {
                                    taskModel.addNewTask.toggle()
                                } label: {
                                    Text("할일 추가 하러 가기 🥳")
                                        .font(.custom("나눔손글씨 둥근인연", size: 20))
                                        .foregroundColor(.white)
                                        .frame(width: geometry.size.width / 2, height: geometry.size.width / 8)
                                        .frame(maxWidth: .infinity)
                                        .background(animate ? ColorAsset.mainViewColor : ColorAsset.mainColor)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal, animate ? .zero : 5)
                                .shadow(color: animate ? ColorAsset.mainColor.opacity(0.7) :
                                                ColorAsset.changeColor.opacity(0.7)
                                            , radius: animate ? 10 : 20,
                                            x: .zero,
                                            y: animate ? 10 : 20)
                                .scaleEffect(animate ? 1.2 : 1.0)
                                .offset(y: animate ? -9 : 0)
                            )
                            .sheet(isPresented: $taskModel.addNewTask) {
                                // Clearing Edit Data
                                taskModel.editTask = nil
                            } content: {
                                AddNewTask()
                                    .environmentObject(taskModel)
                            }
                    }
                    .frame(maxWidth: 400)
                    .multilineTextAlignment(.leading)
                    .padding(30)
                    .onAppear(perform: addAnimation)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ForEach(request, id: \.objectID) { object in
                    self.content(object)
                }
            }
        }
    }
    
    //MARK: - 버튼 애니메이션
    func addAnimation() {
        guard !animate else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(
                Animation
                    .easeInOut(duration: 2.0)
                    .repeatForever() ) {
                        animate.toggle()
            }
        }
    }
}

struct DynamicFilteredView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var taskModel: TaskViewModel = TaskViewModel()
        DynamicFilteredView(dateToFilter: taskModel.currentDate, content: { _ in })
    }
}
