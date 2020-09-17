//
//  FullUser.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/1/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation

struct FullUser {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let role: UserRole
    let title: String?
    let feedType: String?
    let verified: Bool
    init?(dict: [String:Any?]) {
        if let id = dict["id"] as? Int,
            let email = dict["email"] as? String,
            let firstName = dict["first_name"] as? String,
            let lastName = dict["last_name"] as? String {
            self.id = id
            self.email = email
            self.firstName = firstName
            self.lastName = lastName
            self.phoneNumber = dict["phone_number"] as? String
            self.title = dict["title"] as? String
            let rawRole = dict["role"] as? String ?? "basic_user"
            self.role = UserRole(rawValue: rawRole) ?? .basic
            self.feedType = dict["feed_type"] as? String ?? "all"
            self.verified = dict["verified"] as? Bool ?? false
            return
        }
        return nil
    }
    
    func hasAdminAccess() -> Bool {
        return role == UserRole.super || role == UserRole.admin || role == UserRole.subadmin
    }
    
    func hasPremiumAccess() -> Bool {
        return role == UserRole.premium_free
    }
}
