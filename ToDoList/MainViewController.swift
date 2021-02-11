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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell

        cell.nameLabel.text = "text"
        cell.descriptionLabel.text = "description"
        cell.picture.image = UIImage(named: "nothing")

        return cell
    }

}
