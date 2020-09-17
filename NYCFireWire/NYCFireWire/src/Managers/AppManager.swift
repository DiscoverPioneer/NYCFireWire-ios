//
//  AppManager.swift
//  SavePop
//
//  Created by Phil Scarfi on 8/11/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation

public class AppManager {
    static let shared = AppManager()
    var currentUser: FullUser?
    var menu: PioneerMenuController?
    
    var isLoggedIn: Bool {
        get {
            return userToken != nil
        }
    }
    
    var userToken: String? {
        get {
            return UserDefaultConstants().userToken
        }
    }
    
}
