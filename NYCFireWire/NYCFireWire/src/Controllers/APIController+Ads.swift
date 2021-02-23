//
//  APIController+Ads.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 2/23/21.
//  Copyright © 2021 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation

extension APIController {
    func getAd(completion: @escaping (_ user: Ad?) -> Void) {
        let url = "https://pioneerapplications.com/AppResources/nycfirewire/ads.json"
        makeRequest(type: .get, url: url, parameters: nil) { (success, error, data) in
            if let data = data, let ad = Ad(json: data) {
                completion(ad)
            } else {
                completion(nil)
            }
        }
    }
}
