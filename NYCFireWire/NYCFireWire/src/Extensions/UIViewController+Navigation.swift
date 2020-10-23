//
//  UIViewControllers+Navigation.swift
//  Call Logger
//
//  Created by Phil Scarfi on 5/1/17.
//  Copyright © 2017 Pioneer Mobile Applications. All rights reserved.
//

import Foundation
import UIKit



public extension UIViewController {
    
    func popPage(animated: Bool) -> UIViewController? {
        return navigationController?.popViewController(animated: animated)
    }
    
    func addChild(page: UIViewController, toView: UIView) {
        addChild(page)
        page.view.frame = CGRect(origin: CGPoint.zero, size: toView.frame.size)
        toView.addSubview(page.view)
        page.didMove(toParent: self)
    }
    
    func removeAsChild() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension UIViewController {
    class func instantiateFromMainStoryboard() -> Self? {
        return initiateFromStoryboardHelper(name: "Main", viewControllerId: String(describing: self))
    }
    
    class func instantiateFromMainStoryboard(id: String) -> Self? {
        return initiateFromStoryboardHelper(name: "Main", viewControllerId: id)
    }
    
    func showBasicAlert(title: String? = nil, message: String? = nil, dismissed: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default) { (action) in
            dismissed?()
        })
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, actions: [UIAlertAction], cancel: Bool = true) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        if cancel {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

private extension UIViewController {
    class func initiateFromStoryboardHelper<T>(name storyboardName: String, viewControllerId: String) -> T? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerId) as? T else {
            return nil
        }
        return viewController
    }
}
