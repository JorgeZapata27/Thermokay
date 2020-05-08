//
//  Location.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/19/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Location: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView : MKMapView!
    
    @IBOutlet var mainButton : UIButton!
    
    @IBOutlet var addressLabel : UILabel!
    
    let locationManager = CLLocationManager()
    
    var previousLocation : CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocatioNServices()
        
        self.mainButton.layer.shadowColor = UIColor.black.cgColor
        self.mainButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.mainButton.layer.shadowRadius = 8
        self.mainButton.layer.shadowOpacity = 0.5
        self.mainButton.layer.cornerRadius = self.mainButton.frame.height / 2
        self.mainButton.clipsToBounds = true
        self.mainButton.layer.masksToBounds = false

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController!.tabBar.isHidden = true
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000)
            self.mapView.setRegion(region, animated: true)
        } else {
        }
    }
    
    func checkLocatioNServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            self.startTrackingUserLocation()
            break
        case .denied:
            locationManager.requestWhenInUseAuthorization()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways:
            self.startTrackingUserLocation()
            break
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startTrackingUserLocation() {
        self.mapView.showsUserLocation = true
        self.centerViewOnUserLocation()
        self.locationManager.startUpdatingLocation()
        self.previousLocation = self.getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 2000, longitudinalMeters: 2000)
//        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        guard let previousLocation = self.previousLocation else { return }
        guard center.distance(from: self.previousLocation!) >  50 else { return }
        self.previousLocation = center
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemark , error) in
            guard let self = self else { return }
            if let _ = error {
                // error
                return
            }
            guard let placemark = placemark?.first else {
                // error
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        GlobalVariables.location = self.addressLabel.text!
        self.navigationController?.popViewController(animated: true)
    }

}
