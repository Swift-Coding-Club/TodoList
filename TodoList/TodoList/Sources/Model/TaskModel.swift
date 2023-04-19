//
//  TaskModel.swift
//  TodoList
//
//  Created by 서원지 on 2022/08/08.
//

import SwiftUI

struct TaskModel: Identifiable {
    var id = UUID().uuidString
    var taskTitle : String
    var taskDecription : String
    var taskDate: Date
}
