//
//  UIViewController+Inherited.swift
//  Call Logger
//
//  Created by Phil Scarfi on 5/1/17.
//  Copyright © 2017 Pioneer Mobile Applications. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import MessageUI
import Photos

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension UIViewController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received response \(response)")
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Presenting... \(notification)")
    }
}

//MARK: - Helpers
extension UIViewController: MFMailComposeViewControllerDelegate, IAPHandlerDelegate {
    func sendEmail(to: String, subject: String, message:String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([to])
            mail.setSubject(subject)
            mail.setMessageBody(message, isHTML: false)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("FInishe")
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func hasMonthlySubscription() -> Bool {
        //TODO - Add a nice graphic instead of an alert
        if IAPHandler.shared.isMonthlySubscriptionPurchased() {
            return true
        } else {
            
            if let vc = SubscribeViewController.instantiateFromMainStoryboard() {
                let showIn = navigationController ?? self
                vc.showAsPopupInVC(viewController: showIn)
            }
            return false
            
//            if let product = IAPHandler.shared.allProducts.first {
//                let alert = UIAlertController(title: "Monthly Subscription Required", message: "In order to access this feature, you must purchase a monthly subscription for \(product.price).\n This includes our Live Scanner feed, custom notifications, custom notification sounds, and an Ad-Free experience", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Purchase Monthly Subscription", style: .default, handler: { (action) in
//                    IAPHandler.shared.delegate = self
//                    IAPHandler.shared.purchaseMyProduct(index: 0)
//                }))
//
////                alert.addAction(UIAlertAction(title: "Restore Monthly Subscription", style: .default, handler: { (action) in
////                    IAPHandler.shared.restorePurchase()
////                }))
//
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
//
//                }))
//                present(alert, animated: true, completion: nil)
//
//            }
//            return false
        }
    }
    
    func subscribeAction() {
        IAPHandler.shared.delegate = self
        IAPHandler.shared.purchaseMyProduct(index: 0)
    }
    
    func restoreAction() {
        IAPHandler.shared.delegate = self
        IAPHandler.shared.restorePurchase()
    }
    
    func purchaseTransactionComplete(success: Bool) {
        let title = success ? "Transaction Completed" : "There was an error completing your transaction"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            
        }))
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - ImagePicker & ProgressBar
extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func getPhoto(type: UIImagePickerController.SourceType) {PHPhotoLibrary.requestAuthorization({ (status) -> Void in
        DispatchQueue.main.async {

            if status == .authorized {
                if UIImagePickerController.isSourceTypeAvailable(type){
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = type
                    imagePicker.mediaTypes = ["public.image"]
                    imagePicker.allowsEditing = true
                    DispatchQueue.main.async {
                        self.present(imagePicker, animated: true, completion: nil)
                    }
                }else {
                    let typeStr = (type.rawValue == 1) ? "Camera" : "PhotoLibrary"
                    self.showAlert(title: "Wait!", message: "\(typeStr) not avaiable")
                }
            }else {
                self.showAlert(title: "Wait!", message: "Access not granted")
                print("access not granted")}
        }
        }
        )
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.progressComplete()
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            if let image = info[.editedImage] as? UIImage {
                self.imageFromPicker(image)
            }else{
                print("error accessing photo")
            }
        }
    }
    
    @objc func imageFromPicker(_ image: UIImage) {}
    
    @objc func progressComplete() {}
}
