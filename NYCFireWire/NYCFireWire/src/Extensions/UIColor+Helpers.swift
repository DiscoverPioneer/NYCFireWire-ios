//
//  UIColor+Helpers.swift
//  Call Logger
//
//  Created by Phil Scarfi on 5/31/17.
//  Copyright © 2017 Pioneer Mobile Applications. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    public class func colorWithRGB(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
}
