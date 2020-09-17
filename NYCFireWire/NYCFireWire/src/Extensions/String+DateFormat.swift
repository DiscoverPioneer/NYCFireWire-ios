//
//  String+Date.swift
//  Call Logger
//
//  Created by Phil Scarfi on 6/1/17.
//  Copyright © 2017 Pioneer Mobile Applications. All rights reserved.
//

import Foundation

public extension String {
    public func convertedToDate(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        let dateFormatter = DateFormatter()
        let rawFormat = format
        dateFormatter.dateFormat = rawFormat
        return dateFormatter.date(from: self)
    }
    
    public func serverDateStringConvertedToDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: self)
    }
    
    public func facebookServerDateStringConvertedToDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+SSSS"
        return formatter.date(from: self)
    }
}
