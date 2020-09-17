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
