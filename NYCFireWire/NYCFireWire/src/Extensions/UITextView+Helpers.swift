//
//  UITextView+Helpers.swift
//  HitchHiker
//
//  Created by Phil Scarfi on 8/13/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    ///Add a toolbar above the keyboard with a done button that will dismiss the keyboard. This is good for phone number keyboards
    func addDoneButtonOnKeyboard(backgroundTint: UIColor = UIColor.gray
        , buttonTint: UIColor = UIColor.white) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 329, height: 50))
        doneToolbar.barStyle = UIBarStyle.black
        doneToolbar.isTranslucent = false
        doneToolbar.barTintColor = backgroundTint
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonAction))
        done.tintColor = buttonTint
        doneToolbar.items = [flexSpace, done]
        if backgroundTint == .white {
            doneToolbar.layer.borderWidth = 1
            doneToolbar.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        }
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}
