//
//  MainViewController.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 11.02.2021.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    
    var context: NSManagedObjectContext!
    
    var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    private func loadData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            try tasks = context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            
            StorageManager.deleteObject(context: context, object: task)
            
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask" {
            let vc = segue.destination as! AddViewController
            
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let task = tasks[indexPath.row]
            
            // taskObject.picture = UIImage(named: "nothing")?.pngData()
            
            vc.currentContext = task.managedObjectContext
            vc.task = task
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let source = segue.source as? AddViewController else { return }
        
        source.currentContext = context
        source.saveTask()
        
        guard let task = source.task else {
            tableView.reloadData()
            return
        }
        
        tasks.append(task)
        tableView.reloadData()
    }
}
