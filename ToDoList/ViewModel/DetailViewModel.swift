//
//  DetailViewModel.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 17.02.2021.
//

import UIKit
import CoreData
import MapKit

class DetailViewModel {
    
    var currentContext: NSManagedObjectContext!
    var task: Task?
    var pictureIsChanged: Bool = false
    
    // MARK: Save Data
    
    func saveTask(_ currentTask: CurrentTask) {
        if task != nil {
            save(currentTask, task!)
            task = nil
        } else {
            guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: currentContext) else { return }
            let savedTask = Task(entity: entity, insertInto: currentContext)

            save(currentTask, savedTask)
            task = savedTask
        }
    }
    
    private func save(_ currentTask: CurrentTask, _ savedTask: Task) {
        savedTask.title = currentTask.title
        savedTask.desc = currentTask.desc
        savedTask.location = currentTask.location
        savedTask.deadline = currentTask.deadline
        if pictureIsChanged {
            savedTask.picture = currentTask.picture
        } else {
            savedTask.picture = nil
        }
        
        StorageManager.saveObject(currentContext)
    }
    
    // MARK: Work with MapView
    
    func updateLocation(mapView: MKMapView, address: String, animated: Bool, closure: @escaping () -> ()) {
        let geocoder = CLGeocoder()
        let regionInMeters = 1000.0
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            guard let latitude = placemark?.location?.coordinate.latitude,
                  let longitude = placemark?.location?.coordinate.longitude else { return }
            
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            
            closure()
            mapView.setRegion(region, animated: animated)
        }
    }
    
    // MARK: Work with image
    
    func presentPhotoTypeSelectionAC(_ dvc: DetailViewController) {
        let cameraIcon = #imageLiteral(resourceName: "camera")
        let photoIcon = #imageLiteral(resourceName: "photo")
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.chooseImagePicker(dvc, source: .camera)
        }
        camera.setValue(cameraIcon, forKey: "Image")
        camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let photo = UIAlertAction(title: "Photo", style: .default) { _ in
            self.chooseImagePicker(dvc, source: .photoLibrary)
        }
        photo.setValue(photoIcon, forKey: "Image")
        photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(camera)
        ac.addAction(photo)
        ac.addAction(cancel)
        
        dvc.present(ac, animated: true)
    }
    
    private func chooseImagePicker(_ dvc: DetailViewController, source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = dvc
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            dvc.present(imagePicker, animated: true, completion: nil)
        }
    }
}
