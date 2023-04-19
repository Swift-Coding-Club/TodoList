//
//  TaskViewModel.swift
//  TodoList
//
//  Created by 서원지 on 2022/08/08.
//


import SwiftUI

class TaskViewModel : ObservableObject {
    //MARK:  - date
    @Published var currentWeek : [Date] = []
    //MARK:  Current Day
    @Published var currentDate: Date = Date()
    //MARK:  Filtering 날짜
    @Published var filteredTasks: [Task]?
    //MARK:  New task VIEW
    @Published var addNewTask: Bool = false
    //MARK: - Edit Task
    @Published var editTask: Task?
    
    init() {
        fetchCurrentWeek()
    }
    //MARK: - 일주일 날짜
    func fetchCurrentWeek() {
        let today = Date()
        let calender = Calendar.current
        
        let week = calender.dateInterval(of: .weekOfMonth, for: today)
        
        guard let firstWeekDay = week?.start else { return}
        let weekend: ClosedRange<Int> = 1...7
        (weekend).forEach { day in
            if let weekday = calender.date(byAdding: .day, value: day ,to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
    }
    //MARK: Dateformatter
    func extractDate(date: Date, format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    //MARK:  Filtering  날짜
    //MARK: 날짜 확인
    func isToday(date: Date) -> Bool {
        let calender = Calendar.current
        
        return calender.isDate(currentDate, inSameDayAs: date)
    }
    
    func isCurrentHour(date:Date) -> Bool {
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        let currentHour = calender.component(.hour, from: Date())
        return hour == currentHour
    }
}
