//
//  Ad.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 2/22/21.
//  Copyright © 2021 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation

struct Ad {
    let id: String
    let title: String
    let message: String
    let ios_image_url: String
    let ios_link: String
    let always_show: Bool
    
    init?(json: [String:Any]) {
        if let id = json["id"] as? String,
           let title = json["title"] as? String,
           let message = json["message"] as? String,
           let ios_image_url = json["ios_image_url"] as? String,
           let ios_link = json["ios_link"] as? String,
           let always_show = json["always_show"] as? Bool {
            self.id = id
            self.title = title
            self.message = message
            self.ios_image_url = ios_image_url
            self.ios_link = ios_link
            self.always_show = always_show
        } else {
            return nil
        }
    }
}
