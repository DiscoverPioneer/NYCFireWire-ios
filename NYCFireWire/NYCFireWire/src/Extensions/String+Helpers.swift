//
//  String+Helpers.swift
//  Call Logger
//
//  Created by Phil Scarfi on 6/4/17.
//  Copyright © 2017 Pioneer Mobile Applications. All rights reserved.
//

import Foundation

extension String {
    var numbersInString: String {
        let pattern = UnicodeScalar("0")..."9"
        return String(unicodeScalars
            .compactMap { pattern ~= $0 ? Character($0) : nil })
    }
    
    var toInt: Int? {return Int(self)}
    

    
    func e164PhoneNumberFormat() -> String? {
        var replacement = replacingOccurrences(of: " ", with: "")
        replacement = replacement.replacingOccurrences(of: "(", with: "")
        replacement = replacement.replacingOccurrences(of: ")", with: "")
        replacement = replacement.replacingOccurrences(of: "-", with: "")
        if replacement.first == "+" && replacement.count > 11 {
            return replacement
        }
        return nil
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
