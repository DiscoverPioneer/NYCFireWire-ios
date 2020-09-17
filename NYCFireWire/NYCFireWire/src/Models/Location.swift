//
//  Location.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/1/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import CoreLocation

class Location {
    let id: Int
    let createdAt: Date
    let location: CLLocation
    let title: String
    let subtitle: String?
    let address: String
    let numberOfComments: Int
    let numberOfViews: Int
    let boro: String
    var units = [String]()
    
    init(id: Int, createdAt: Date, location: CLLocation, title: String, subtitle: String?, address: String, numberOfComments: Int, numberOfViews: Int, boro: String) {
        self.id = id
        self.createdAt = createdAt
        self.location = location
        self.title = title
        self.subtitle = subtitle
        self.address = address
        self.numberOfComments = numberOfComments
        self.numberOfViews = numberOfViews
        self.boro = boro
    }
}
