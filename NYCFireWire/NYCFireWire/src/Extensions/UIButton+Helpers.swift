//
//  UIButton+Helpers.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 11/23/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func convertToBarButtonItem() -> UIBarButtonItem {
        let button = UIBarButtonItem(customView: self)
        let currWidth = button.customView?.widthAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        let currHeight = button.customView?.heightAnchor.constraint(equalToConstant: 20)
        currHeight?.isActive = true
        return button
    }
}
