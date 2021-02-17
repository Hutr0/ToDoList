//
//  MapViewController.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 12.02.2021.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapViewModel = MapViewModel()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.layer.cornerRadius = doneButton.layer.frame.height / 2
        
        mapView.delegate = self
        mapViewModel.checkLocationServices(mapView: mapView) {
            mapViewModel.locationManager.delegate = self
        }
        
        addressLabel.text = mapViewModel.getLocationAddress(mapView: mapView)
    }
    
    @IBAction func centeringUserPosition(_ sender: UIButton) {
        mapViewModel.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        mapViewModel.regionDidChange(mapView: mapView, closure: { (address) in
            self.addressLabel.text = address
        })
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapViewModel.checkLocationAutorization(mapView: mapView)
    }
}
