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
    
    var currentContext: NSManagedObjectContext!
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        doneButton.isEnabled = false
        titleOfTask.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        if task != nil {
            setupNavigationBar()
            loadTask()
        }
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            ac.addAction(photo)
            ac.addAction(camera)
            ac.addAction(cancel)
            
            present(ac, animated: true)
        } else {
            tableView.endEditing(true)
        }
    }
    
    // MARK: Work with task
    
    func saveTask() {
        if task != nil {
            guard let task = task else { return }
            
            task.title = titleOfTask.text
            task.desc = descriptionOfTask.text
            task.picture = pictureOfTask.image?.pngData()
            
            StorageManager.saveObject(currentContext)
            
            self.task = nil
        } else {
            guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: currentContext) else { return }
            let taskObject = Task(entity: entity, insertInto: currentContext)
            
            taskObject.title = titleOfTask.text
            taskObject.desc = descriptionOfTask.text
            taskObject.picture = pictureOfTask.image?.pngData()
            
            StorageManager.saveObject(currentContext)
            
            task = taskObject
        }
    }
    
    private func loadTask() {
        guard let task = task else { return }
        
        titleOfTask.text = task.title
        descriptionOfTask.text = task.desc
        pictureOfTask.image = UIImage(data: task.picture!)
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem?.title = "Save"
        title = task!.title
        doneButton.isEnabled = true
    }
    
    // MARK: Actions
    
    @IBAction private func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Text field delegate

extension AddViewController: UISearchTextFieldDelegate, UINavigationControllerDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldChanged() {
        if titleOfTask != nil {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
}

// MARK: Work with image

extension AddViewController: UIImagePickerControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        pictureOfTask.image = info[.editedImage] as? UIImage
        pictureOfTask.contentMode = .scaleAspectFill
        pictureOfTask.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
}
