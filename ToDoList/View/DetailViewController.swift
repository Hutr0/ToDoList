//
//  AddViewController.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 11.02.2021.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UITableViewController {
    
    let detailViewModel = DetailViewModel()
    
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var goMapButton: UIButton!
    @IBOutlet weak var pinPicture: UIImageView!
    @IBOutlet weak var pictureOfTask: UIImageView!
    @IBOutlet weak var titleOfTask: UITextField!
    @IBOutlet weak var descriptionOfTask: UITextView!
    @IBOutlet weak var locationOfTask: UITextField!
    @IBOutlet weak var deadlineOfTask: UIDatePicker!
    @IBOutlet weak var mapOfTask: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        mapOfTask.delegate = self
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        goMapButton.layer.cornerRadius = goMapButton.layer.frame.height / 8
        doneButton.isEnabled = false
        pinPicture.isHidden = true
        
        titleOfTask.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        locationOfTask.addTarget(self, action: #selector(locationChanged), for: .editingChanged)
        
        guard let task = detailViewModel.task else { return }
        setupNavigationBar(task)
        setupLoadedTask(task)
        if locationOfTask.text != nil && locationOfTask.text != "" {
            detailViewModel.updateLocation(mapView: mapOfTask, address: locationOfTask.text!, animated: false) {
                self.pinPicture.isHidden = false
            }
        }
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            detailViewModel.presentPhotoTypeSelectionAC(self)
        } else {
            tableView.endEditing(true)
        }
    }
    
    // MARK: Save Data
    
    func saveTask() {
        let currentTask = CurrentTask(title: titleOfTask.text!,
                                      desc: descriptionOfTask.text ?? "",
                                      picture: pictureOfTask.image?.pngData(),
                                      location: locationOfTask.text ?? "",
                                      deadline: deadlineOfTask.date)
        
        detailViewModel.saveTask(currentTask)
    }
    
    // MARK: Setup an interface
    
    private func setupLoadedTask(_ task: Task) {
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
        
        detailViewModel.pictureIsChanged = true
    }
    
    private func setupNavigationBar(_ task: Task) {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem?.title = "Save"
        title = task.title
        doneButton.isEnabled = true
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mapVC = segue.destination as? MapViewController else { return }
        mapVC.mapViewControllerDelegate = self
        
        if locationOfTask.text != "" {
            mapVC.mapViewModel.location = locationOfTask.text
        }
    }
    
    // MARK: Actions
    
    @IBAction private func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Text field delegate

extension DetailViewController: UISearchTextFieldDelegate, UINavigationControllerDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == locationOfTask && locationOfTask.text != nil && locationOfTask.text != "" {
            detailViewModel.updateLocation(mapView: mapOfTask, address: locationOfTask.text!, animated: true) {}
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldChanged() {
        if titleOfTask.text != "" {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    @objc func locationChanged() {
        if locationOfTask.text != nil && locationOfTask.text == "" {
            pinPicture.isHidden = true
        }
    }
}

// MARK: Work with image

extension DetailViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        pictureOfTask.image = info[.editedImage] as? UIImage
        pictureOfTask.contentMode = .scaleAspectFill
        pictureOfTask.clipsToBounds = true
        
        detailViewModel.pictureIsChanged = true
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Custom Protocol MapViewControllerDelegate

extension DetailViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        locationOfTask.text = address
        if address != nil && address != "" {
            detailViewModel.updateLocation(mapView: self.mapOfTask, address: address!, animated: false) {}
        }
    }
}
