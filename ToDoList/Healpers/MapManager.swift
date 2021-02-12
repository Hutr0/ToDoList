//
//  MapManager.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 12.02.2021.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    let regionInMeters = 500.0
    
    func checkLocationServices(mapView: MKMapView, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.showAlert(title: "Location Services are Disabled",
                               message: "To endable it go: Settings -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    func checkLocationAutorization(mapView: MKMapView) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.showAlert(title: "Location Services are denied",
                               message: "To enable your location tracking: Setting -> ToDoList -> Location")
            }
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            showUserLocation(mapView: mapView)
            break
        @unknown default:
            print("New cases was added")
        }
    }
    
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getCenterLocation(mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        ac.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(ac, animated: true)
    }
}
