//
//  MapViewController.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 12.02.2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        addressLabel.text = ""
        doneButton.layer.cornerRadius = doneButton.layer.frame.height / 2
        
        mapManager.checkLocationServices(mapView: mapView) {
            mapManager.locationManager.delegate = self
        }
    }
    
    @IBAction func centeringUserPosition(_ sender: UIButton) {
        mapManager.showUserLocation(mapView: mapView)
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
