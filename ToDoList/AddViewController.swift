//
//  AddViewController.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 11.02.2021.
//

import UIKit
import CoreData

class AddViewController: UITableViewController {

    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var pictureOfTask: UIImageView!
    @IBOutlet weak var titleOfTask: UITextField!
    @IBOutlet weak var descriptionOfTask: UITextView!
    
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        doneButton.isEnabled = false
        titleOfTask.addTarget(self, action: #selector(nameDidChanged), for: .editingChanged)
    }
    
    func saveTask(_ context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        let taskObject = Task(entity: entity, insertInto: context)
        
        taskObject.title = titleOfTask.text
        taskObject.desc = descriptionOfTask.text
        
        StorageManager.saveObject(context)
        
        task = taskObject
    }
    
    @objc private func nameDidChanged() {
        if titleOfTask != nil {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    @IBAction private func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
