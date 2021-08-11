//
//  AddTaskViewController.swift
//  RxSwiftTodoList
//
//  Created by usr on 2021/8/6.
//

import Foundation
import UIKit
import RxSwift

class AddTaskViewController: UIViewController {
    // MARK: - Properties
    private let taskSubject = PublishSubject<Task>()
    var taskSubjectObservable: Observable<Task> {
        return taskSubject.asObserver()
    }
    
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet weak var taskTitleTextField: UITextField!
    
    // MARK: - Selector
    @IBAction func save() {
        guard let priorty = Priority(rawValue: self.prioritySegmentedControl.selectedSegmentIndex),
              let title = self.taskTitleTextField.text else {
            return
        }
        
        let task = Task(title: title, priority: priorty)
        // ➡️ 透過 RxSwift 傳值而非 delegate-protocol
        taskSubject.onNext(task)
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
