//
//  SettingsCell.swift
//  SavePop
//
//  Created by Allan Araujo on 9/9/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

protocol SettingsCellDelegate {
    func didEndEditing(input: String)
}

class SettingsCell: UITableViewCell, UITextFieldDelegate {
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.isEnabled = false
//        tf.font = UIFont.mainFont(size: 18)
        tf.addDoneButtonOnKeyboard()
        return tf
    }()
    
    public var onEndEditing: ((String?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(textField)
        textField.delegate = self

        textField.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.onEndEditing?(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
