//
//  Task.swift
//  RxSwiftTodoList
//
//  Created by usr on 2021/8/6.
//

import Foundation

struct Task {
    let title: String
    let priority: Priority
}

enum Priority: Int {
    case high
    case medium
    case low
}
