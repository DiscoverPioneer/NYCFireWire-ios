//
//  MenuConstants.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 9/13/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation

enum APIEndpoint: String {
    case signinEndpoint = "/user/login"
    case signupEndpoint = "/user/signup"
    case resetPasswordEndpoint = "/user/reset-password"
    case logoutEndpoint = "/user/logout"
    case meEndpoint = "/user/me"
    case verifyEndpoint = "/user/send-email-verification"
    case updateUserEndpoint = "/user/update"
    case blockUserEndpoint = "/user/block"
    case allIncidentsEndpoint = "/incident/all"
    case incidentDetailsEndpoint = "/incident/"
    case updateIncidentViewsCountEndpoint = "/incident/update-view-count"
    case createIncidentEndpoint = "/incident/create"
    case createTipEndpoint = "/incident/send-tip"

    case fileSignEndpoint = "/file/sign"
}

extension APIConstants {
    
    static func construct(endpoint: APIEndpoint) -> String {
        return baseURL + endpoint.rawValue
    }
    
    static func construct(endpoint: String) -> String {
        return baseURL + endpoint
    }
}
