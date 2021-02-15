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
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var location: String?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.layer.cornerRadius = doneButton.layer.frame.height / 2
        
        mapView.delegate = self
        mapManager.checkLocationServices(mapView: mapView) {
            mapManager.locationManager.delegate = self
        }
        
        if location == nil {
            mapManager.showUserLocation(mapView: mapView)
            addressLabel.text = ""
        } else {
            mapManager.showSpecificLocation(mapView: mapView, address: location!)
            addressLabel.text = location
        }
    }
    
    @IBAction func centeringUserPosition(_ sender: UIButton) {
        mapManager.showUserLocation(mapView: mapView)
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
        let center = mapManager.getCenterLocation(mapView: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center, preferredLocale: Locale(identifier: "ru_RU")) { (placemarks, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let city = placemark?.locality
            let street = placemark?.thoroughfare
            let build = placemark?.subThoroughfare
            
            if city != nil && street != nil && build != nil {
                self.addressLabel.text = "\(city!), \(street!), \(build!)"
            } else if street != nil && build != nil {
                self.addressLabel.text = "\(street!), \(build!)"
            } else if street != nil {
                self.addressLabel.text = "\(street!)"
            } else {
                self.addressLabel.text = ""
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAutorization(mapView: mapView)
    }
}
