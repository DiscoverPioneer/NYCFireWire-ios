//
//  LocationManager.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/2/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func clearToObtainLocation(locationManager: LocationManager)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    let manager = CLLocationManager()
    var delegate: LocationManagerDelegate?
    
    override init() {
        super.init()
        isAuthorizedtoGetUserLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            delegate?.clearToObtainLocation(locationManager: self)
        }
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            manager.requestAlwaysAuthorization()
        }
    }
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("User allowed us to access location")
            //do whatever init activities here.
            self.manager.startUpdatingLocation()
            delegate?.clearToObtainLocation(locationManager: self)
        }
    }
    
    
    //this method is called by the framework on         locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //store the user location here to firebase or somewhere
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }
    
}
