//
//  Incident.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 9/13/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import CoreLocation

class Incident: Location {
    let boxNumber: String
    
    init?(dict:[String:Any?]) {
        if
            let id = dict["id"] as? Int,
            let title = dict["title"] as? String,
            let subtitle = dict["subtitle"] as? String,
            let address = dict["address"] as? String,
            let lat = dict["latitude"] as? Double,
            let lng = dict["longitude"] as? Double,
            let createdAt = (dict["created_at"] as? String)?.serverDateStringConvertedToDate(),
            let boro = dict["boro"] as? String,
            let boxNumber = dict["box_number"] as? String {
            let numberOfComments = (dict["number_of_comments"] as? Int) ?? 0
            let numberOfViews = (dict["total_views"] as? Int) ?? 0
            let numberOfLikes = (dict["number_of_likes"] as? Int) ?? 0
            let isLiked: Bool = ((dict["number_of_likes"] as? Int) ?? 0).boolValue
            self.boxNumber = boxNumber

            super.init(id: id, createdAt: createdAt, location: CLLocation(latitude: lat, longitude: lng), title: title, subtitle: subtitle, address: address, numberOfComments:numberOfComments, numberOfViews: numberOfViews, boro: boro, numberOfLikes: numberOfLikes, isLiked: isLiked)
            if let respondingUnits = dict["responding_units"] as? [String] {
                self.units = respondingUnits
            }
            return
        }
        return nil
    }
}
