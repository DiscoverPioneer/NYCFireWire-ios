//
//  Comment.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/2/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation

enum CommentType {
    case Incident
    case IncidentInquiry
}

struct Comment {
    let id: Int
    let createdBy: SimpleUser
    let createdAt: Date
    let text: String
    let locationID: Int //Refers to either incident or incident inquiry
    let type: CommentType
    let imageURL: String?
    
    init?(dict: [String:Any?]) {
        self.imageURL = dict["image_url"] as? String
        if
            let id = dict["id"] as? Int,
            let createdBy = dict["_user"] as? Int,
            let createdAtRaw = dict["created_at"] as? String,
            let createdAt = createdAtRaw.serverDateStringConvertedToDate(),
            let text = dict["comment"] as? String,
            let firstName = dict["first_name"] as? String,
            let lastName = dict["last_name"] as? String,
            let role = dict["role"] as? String {
            self.id = id
            self.createdBy = SimpleUser(id: createdBy, firstName: firstName, lastName: lastName, role: role, points: dict["points"] as? Int)
            self.createdAt = createdAt
            self.text = text
            if let locationID = dict["incident"] as? Int {
                self.locationID = locationID
                self.type = .Incident
            } else if let locationID = dict["incident_inquiry"] as? Int {
                self.locationID = locationID
                self.type = .IncidentInquiry
            } else {
                return nil
            }
            return
        } else {
            return nil
        }
    }
}
