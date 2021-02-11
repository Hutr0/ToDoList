//
//  MainViewController.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 11.02.2021.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var tasks: [String] = ["Первая", "Вторая", "Третья" ,"Четвёртая" ,"Пятая"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell

        cell.nameLabel.text = tasks[indexPath.row]

        return cell
    }

    // MARK: Navigation
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        <#code#>
//    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let source = segue.source as? AddViewController else { return }
        tasks.append(source.nameOfTask.text!)
        tableView.reloadData()
    }
}
