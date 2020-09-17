//
//  Firehouse.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 3/1/19.
//  Copyright © 2019 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import CoreLocation

struct Firehouse {
    let name: String
    let location: CLLocation
}

class FirehouseParser {
    func getAllFirehouses() -> [Firehouse] {
        var firehouses = [Firehouse]()
        if let path = Bundle.main.path(forResource: "FirehouseLocations", ofType: "plist"), let rawFirehouses = NSArray(contentsOfFile: path) as? [[String:Any]] {
            for rawFirehouse in rawFirehouses {
                if let name = rawFirehouse["Name"] as? String, let coordinates = rawFirehouse["Coordinates"] as? String, coordinates.components(separatedBy: ",").count > 1 {
                    let coordinateComponents = coordinates.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
                
                    if let lat = Double(coordinateComponents[0]), let long = Double(coordinateComponents[1]) {
                        firehouses.append(Firehouse(name: name, location: CLLocation(latitude: lat, longitude: long)))
                    }
                }
            }
        }
        return firehouses
    }
    
    func getAllFormerFirehouses() -> [Firehouse] {
        var firehouses = [Firehouse]()
        if let path = Bundle.main.path(forResource: "FormerFirehouseLocations", ofType: "plist"), let rawFirehouses = NSArray(contentsOfFile: path) as? [[String:Any]] {
            for rawFirehouse in rawFirehouses {
                if let name = rawFirehouse["Name"] as? String, let coordinates = rawFirehouse["Coordinates"] as? String, coordinates.components(separatedBy: ",").count > 1 {
                    let coordinateComponents = coordinates.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
                
                    if let lat = Double(coordinateComponents[0]), let long = Double(coordinateComponents[1]) {
                        firehouses.append(Firehouse(name: name, location: CLLocation(latitude: lat, longitude: long)))
                    }
                }
            }
        }
        return firehouses
    }
}
