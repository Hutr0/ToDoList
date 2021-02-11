//
//  AddViewController.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 11.02.2021.
//

import UIKit

class AddViewController: UITableViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var pictureOfTask: UIImageView!
    @IBOutlet weak var nameOfTask: UITextField!
    @IBOutlet weak var descriptionOfTask: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
