//
//  MainViewController.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 11.02.2021.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    
    let mainViewModel = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainViewModel.loadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainViewModel.numberOfRowsInSection()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configuredCell = mainViewModel.configureTheCell(tableView, for: indexPath)
        
        return configuredCell
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mainViewModel.removeObject(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            mainViewModel.prepareEditTask(for: segue, at: indexPath)
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        mainViewModel.unwindSegue(segue, closure: { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        })
    }
}
