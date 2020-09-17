//
//  AnalyticsController.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 1/1/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import FacebookCore

class AnalyticsController {
    class func logEvent(eventName: String) {
        AppEvents.logEvent(AppEvents.Name(eventName))
    }
}
