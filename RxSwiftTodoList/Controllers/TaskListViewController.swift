//
//  TaskListViewController.swift
//  RxSwiftTodoList
//
//  Created by usr on 2021/8/6.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TaskListViewController: UIViewController {
    // MARK: - Properties
    // 囊括了 Task 的 Variable
    private var tasks = BehaviorRelay<[Task]>(value: [])
    private var tasks_deprecated = Variable<[Task]>([])
    let disposeBag = DisposeBag()
    private var filteredTasks = [Task]()
    
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController,
              let addTaskVC = nav.viewControllers.first as? AddTaskViewController else { fatalError("Controller not found") }
        
        addTaskVC.taskSubjectObservable
            .subscribe(onNext: { [unowned self] task in
                
                // 對 Variable<Task> 的陣列做新增元素（過時）
                // self.tasks.value.append(task)
                
                let priority = Priority(rawValue: self.prioritySegmentedControl.selectedSegmentIndex - 1)
                                                                    // -1：All
                
                /* ⭐️ 對 BehaviorRelay 加入元素的方式
                 * ⚠️ 不能直接用 .append() */
                var existingTasks = self.tasks.value
                existingTasks.append(task)
                self.tasks.accept(existingTasks)
                
                self.filterTasks(by: priority)
                
            }).disposed(by: disposeBag)

    }
    
    // MARK: - Selectors
    @IBAction func priorityValueChanged(segmentedControl: UISegmentedControl) {
        let priority = Priority(rawValue: segmentedControl.selectedSegmentIndex - 1)
        filterTasks(by: priority)
    }
    
    // MARK: - Helpers
    private func filterTasks(by priority: Priority?) {
        if priority == nil {  // 不做篩選
            self.filteredTasks = self.tasks.value
            self.updateTableView()
        } else {
            /* ⭐️ 條件篩選 ⭐️ */
            self.tasks.map { tasks in
                return tasks.filter { $0.priority == priority! }
            }.subscribe(onNext: { [weak self] tasks in
                self?.filteredTasks = tasks
                self?.updateTableView()
            }).disposed(by: disposeBag)
        }
    }
    
    private func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        cell.textLabel?.text = filteredTasks[indexPath.row].title
        return cell
    }
}
