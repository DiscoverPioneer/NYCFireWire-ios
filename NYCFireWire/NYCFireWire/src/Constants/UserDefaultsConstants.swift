//
//  UserDefaultsConstants.swift
//  SavePop
//
//  Created by Phil Scarfi on 8/11/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation

extension APIController {
    class var defaults: APIController {
        get {
            return APIController(email: UserDefaultConstants().userEmail, token: UserDefaultConstants().userToken)
        }
    }
}

enum UserDefaultKeys: String {
    case userTokenKey = "userToken"
    case userEmailKey = "userEmail"
    case pushNotificationsDisabledKey = "pushNotificationsDisabled"

}

public struct UserDefaultConstants {
    private let defaults = UserDefaults.standard
    
    static func setObjectForKey(key: UserDefaultKeys, value: Any?) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    static func objectForKey(key: UserDefaultKeys) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
    
    static func boolForKey(key: UserDefaultKeys) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    var userToken: String? {
        get {
            return stringForKey(key: UserDefaultKeys.userTokenKey.rawValue)
        }
    }
    
    var userEmail: String? {
        get {
            return stringForKey(key: UserDefaultKeys.userEmailKey.rawValue)
        }
    }
    
    func stringForKey(key: String) -> String? {
        return defaults.object(forKey: key) as? String
    }
    
    func objectForKey(key: String) -> [String:Any]? {
        return defaults.object(forKey: key) as? [String:Any]
    }
}

enum UserDefaultSuiteKeys: String {
    case userTokenKey = "userToken"
    case userEmailKey = "userEmail"
    case selectedFeedType = "selectedFeedType"
    case selectedLocation = "selectedLocation"
    case featuredImageURL = "featuredImageURL"

}

public struct UserDefaultsSuite {
    
    public let suite = UserDefaults(suiteName: "group.com.Pioneer.NYCFireWire")!
    
    func setInt(value: Int, key: String) {
        suite.setValue(value, forKey: key)
    }
    
    func setString(value: String, key: String) {
        suite.setValue(value, forKey: key)
    }
    
    func stringFor(key: UserDefaultSuiteKeys) -> String? {
        return suite.string(forKey: key.rawValue)
    }
    
    func intFor(key: UserDefaultSuiteKeys) -> Int? {
        return suite.integer(forKey: key.rawValue)
    }
    
    var userEmail: String? {
        suite.string(forKey: UserDefaultSuiteKeys.userEmailKey.rawValue)
    }
    
    var token: String? {
        suite.string(forKey: UserDefaultSuiteKeys.userTokenKey.rawValue)
    }
}
