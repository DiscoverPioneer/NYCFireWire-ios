//
//  NotificationToggleCell.swift
//  SavePop
//
//  Created by Allan Araujo on 9/13/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

protocol NotificationToggleCellDelegate {
    func notificationToggleCell(cell: NotificationToggleCell, didToggle isOn: Bool)
}

class NotificationToggleCell: UITableViewCell {
    var delegate: NotificationToggleCellDelegate?
    
    lazy var notificationSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = UIColor.themeBackgroundColor
        sw.tintColor = UIColor.themeBackgroundColor
        sw.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
        return sw
    }()
    
    var label: UILabel = {
        let label = UILabel()
//        label.font = UIFont.mainFont(size: 18)
        label.text = "Push Notifications: On"
        label.numberOfLines = 1;
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment  = .left
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutView()
    }

    @objc fileprivate func switchStateDidChange(_ sender: UISwitch!) {
        print("Switch value is \(sender.isOn)")
        delegate?.notificationToggleCell(cell: self, didToggle: sender.isOn)
    }
    
    fileprivate func layoutView() {
        addSubview(notificationSwitch)
        notificationSwitch.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        label.trailingAnchor.constraint(equalTo: notificationSwitch.leadingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
