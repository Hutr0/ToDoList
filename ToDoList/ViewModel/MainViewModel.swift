//
//  MainViewModel.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 17.02.2021.
//

import UIKit
import CoreData

class MainViewModel {
    
    var context: NSManagedObjectContext!
    
    var tasks: [Task] = []
    
    func loadData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            try tasks = context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func numberOfRowsInSection() -> Int {
        return tasks.count
    }
    
    func configureTheCell(_ tableView: UITableView, for indexPath: IndexPath) -> Cell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        
        let task = tasks[indexPath.row]
        
        cell.nameLabel.text = task.title
        cell.descriptionLabel.text = task.desc
        if let pictureOfTask = task.picture {
            cell.picture.image = UIImage(data: pictureOfTask)
        } else {
            cell.picture.image = #imageLiteral(resourceName: "nothing")
        }
        
        return cell
    }
    
    func removeObject(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        StorageManager.deleteObject(context: context, object: task)
        tasks.remove(at: indexPath.row)
    }
    
    func prepareEditTask(for segue: UIStoryboardSegue, at indexPath: IndexPath) {
        let vc = segue.destination as! DetailViewController
        let task = tasks[indexPath.row]
        
        vc.detailViewModel.currentContext = task.managedObjectContext
        vc.detailViewModel.task = task
    }
    
    func unwindSegue(_ segue: UIStoryboardSegue, closure: @escaping () -> ()) {
        guard let source = segue.source as? DetailViewController else { return }
        
        source.detailViewModel.currentContext = context
        source.saveTask()
        
        guard let task = source.detailViewModel.task else {
            closure()
            return
        }
        
        tasks.append(task)
        closure()
    }
}
