//
//  SimpleUser.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/3/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation

enum UserRole: String {
    case `super` = "super"
    case admin = "admin"
    case subadmin = "subadmin"
    case premium_free = "premium_free"
    case basic = "basic_user"
}

struct SimpleUser {
    let id: Int
    let firstName: String
    let lastName: String
    let role: UserRole
    let points: Int?
    
    var isAdmin: Bool {
        return role == .super || role == .subadmin ||  role == .admin
    }
    
    init(id: Int, firstName: String, lastName: String, role: String, points: Int?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.role = UserRole(rawValue: role) ?? .basic
        self.points = points
    }
    
    
}
