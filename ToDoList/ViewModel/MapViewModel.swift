//
//  MapManager.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 12.02.2021.
//

import UIKit
import MapKit

class MapViewModel {
    
    let locationManager = CLLocationManager()
    
    var location: String?
    let regionInMeters = 500.0
    
    func getLocationAddress(mapView: MKMapView) -> String? {
        if location == nil {
            showUserLocation(mapView: mapView)
            return ""
        } else {
            showSpecificLocation(mapView: mapView, address: location!)
            return location
        }
    }
    
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
    
    func showSpecificLocation(mapView: MKMapView, address: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if let error = error {
                print(error)
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            guard let latitude = placemark?.location?.coordinate.latitude,
                  let longitude = placemark?.location?.coordinate.longitude else { return }
            
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: location, latitudinalMeters: self.regionInMeters, longitudinalMeters: self.regionInMeters)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func getCenterLocation(mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func regionDidChange(mapView: MKMapView, closure: @escaping (String) -> ()) {
        let center = getCenterLocation(mapView: mapView)
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
                closure("\(city!), \(street!), \(build!)")
            } else if street != nil && build != nil {
                closure("\(street!), \(build!)")
            } else if street != nil {
                closure("\(street!)")
            } else {
                closure("")
            }
        }
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
