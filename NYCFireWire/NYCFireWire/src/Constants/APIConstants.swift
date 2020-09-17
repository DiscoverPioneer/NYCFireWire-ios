//
//  APIConstants.swift
//  SavePop
//
//  Created by Phil Scarfi on 8/11/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation

struct APIConstants {
    
    enum ErrorType {
        case unknown
        case custom
        case missingCredentials
        case invalidCredentials
        func error(message: String? = nil) -> Error {
            return Error(type: self, message: message)
        }
    }
    
    struct Error {
        let type: ErrorType
        let message: String?
        
        init(type: ErrorType, message: String? = nil) {
            self.type = type
            self.message = message
        }
    }
    
    struct Keys {
        static let error = "error"
        static let fileName = "filename"
        static let fileType = "filetype"
    }
    
    //MARK: - ENDPOINTS
    static let baseURL = Constants.constantForKey(key: ConfigKeys.apiBaseURI) as! String

}
