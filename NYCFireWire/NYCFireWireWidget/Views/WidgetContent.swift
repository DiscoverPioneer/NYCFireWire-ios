//
//  WidgetContent.swift
//  NYCFireWire
//
//  Created by Alex Rhodes on 10/9/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import WidgetKit

struct WidgetContent: TimelineEntry {
    let date: Date
    let incident1: Incident
    let incident2: Incident
    let incident3: Incident
}

extension Incident {
    
//    let id = dict["id"] as? Int,
//    let title = dict["title"] as? String,
//    let subtitle = dict["subtitle"] as? String,
//    let address = dict["address"] as? String,
//    let lat = dict["latitude"] as? Double,
//    let lng = dict["longitude"] as? Double,
//    let createdAt = (dict["created_at"] as? String)?.serverDateStringConvertedToDate(),
//    let boro = dict["boro"] as? String,
//    let boxNumber = dict["box_number"] as? String {
//    let numberOfComments = (dict["number_of_comments"] as? Int) ?? 0
//    let numberOfViews = (dict["total_views"] as? Int) ?? 0
//    self.boxNumber = boxNumber
    
    
    static var placeholder: WidgetContent {
        let date = "2020-05-27T16:44:13.353Z"
        let widget = WidgetContent(date: Date(),
                      incident1: Incident(dict: ["id":1,
                                                 "title":"All Hands",
                                                 "subtitle":"Fire",
                                                 "address":"1600 Amphitheatre Parkway",
                                                 "latitude":0.0,
                                                 "longitude":0.0,
                                                 "created_at":date,
                                                 "boro":"Brooklyn",
                                                 "box_number": "1111",
                                                 "number_of_comments":0,
                                                 "total_views":0])!,
                      incident2: Incident(dict: ["id":1,
                                                 "title":"NYPD Incident",
                                                 "subtitle":"Hostage Situation",
                                                 "address":"Empire State Building",
                                                 "latitude":0.0,
                                                 "longitude":0.0,
                                                 "created_at":date,
                                                 "boro":"Brooklyn",
                                                 "box_number": "NYPD",
                                                 "number_of_comments":0,
                                                 "total_views":0])!,
                      incident3: Incident(dict: ["id":1,
                                                 "title":"2nd Alarm",
                                                 "subtitle":"Battalion 10 transmitting the 2nd alarm for heavy fire on the roof of a commercial building",
                                                 "address":"Grand Central Parkway & LIE",
                                                 "latitude":0.0,
                                                 "longitude":0.0,
                                                 "created_at":date,
                                                 "boro":"Manhattan",
                                                 "box_number": "9999",
                                                 "number_of_comments":0,
                                                 "total_views":0])!)
        
        return widget
    }
}
