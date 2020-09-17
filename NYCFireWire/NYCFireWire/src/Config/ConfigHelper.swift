//
//  ConfigHelper.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 1/3/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation

struct ConfigHelper {
    static var availableFeeds: [ScannerFeed] {
        get {
            var feeds = [ScannerFeed]()
            if let rawFeeds = Constants.constantForKey(key: "availableScannerFeeds") as? [[String: String?]] {
                for rawFeed in rawFeeds {
                    if let name = rawFeed["name"] as? String {
                        feeds.append(ScannerFeed(name: name, url: rawFeed["url"] as? String))
                    }
                }
            }
            
            return feeds
        }
    }
}

struct ScannerFeed {
    let name: String
    let url: String?
}
