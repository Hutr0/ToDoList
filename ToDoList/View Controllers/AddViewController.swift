//
//  AddViewController.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 11.02.2021.
//

import UIKit
import CoreData

class AddViewController: UITableViewController {

    var currentContext: NSManagedObjectContext!
    var task: Task?
    var pictureIsChanged: Bool = false
    
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var pictureOfTask: UIImageView!
    @IBOutlet weak var titleOfTask: UITextField!
    @IBOutlet weak var descriptionOfTask: UITextView!
    @IBOutlet weak var locationOfTask: UITextField!
    @IBOutlet weak var deadlineOfTask: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
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
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "Image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "Image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            ac.addAction(camera)
            ac.addAction(photo)
            ac.addAction(cancel)
            
            present(ac, animated: true)
        } else {
            tableView.endEditing(true)
        }
    }
    
    // MARK: Work with task
    
    func saveTask() {
        if task != nil {
            guard let taskObject = task else { return }
            
            save(taskObject)
            
            task = nil
        } else {
            guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: currentContext) else { return }
            let taskObject = Task(entity: entity, insertInto: currentContext)
            
            save(taskObject)
            
            task = taskObject
        }
    }
    
    private func save(_ taskObject: Task) {
        taskObject.title = titleOfTask.text
        taskObject.desc = descriptionOfTask.text
        taskObject.location = locationOfTask.text
        taskObject.deadline = deadlineOfTask.date
        if pictureIsChanged {
            taskObject.picture = pictureOfTask.image?.pngData()
        } else {
            task?.picture = nil
        }
        
        StorageManager.saveObject(currentContext)
    }
    
    private func loadTask() {
        guard let task = task else { return }
        
        titleOfTask.text = task.title
        descriptionOfTask.text = task.desc
        locationOfTask.text = task.location
        deadlineOfTask.date = task.deadline ?? Date()
        guard let imageData = task.picture, let image = UIImage(data: imageData) else {
            pictureOfTask.image = UIImage(named: "addNonPicture")
            return
        }
        pictureOfTask.image = image
        pictureOfTask.contentMode = .scaleAspectFill
        pictureIsChanged = true
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
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mapVC = segue.destination as? MapViewController else { return }
        mapVC.mapViewControllerDelegate = self
        
        if locationOfTask.text != "" {
            mapVC.location = locationOfTask.text
        }
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
        
        pictureIsChanged = true
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Custom Protocol MapViewControllerDelegate

extension AddViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        locationOfTask.text = address
    }
}
