//
//  SendTipViewController.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 5/27/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

class SendTipViewController: UIViewController {

    @IBOutlet weak var infoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Send Tip"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitTapped))
        
    }
    

    @objc func submitTapped() {
        if AppManager.shared.currentUser?.verified != true {
            showAlert(title: "Cannot submit tip", message: "Please verify your email before you submit a tip. This can be done in the 'Settings' page.")
            return
        }
        if infoTextView.text.count < 5 {
            showAlert(title: "Missing Fields", message: "Please add information about your tip.")
            return
        }
        let params:[String:Any] = [
            "tip":infoTextView.text
        ]
        let activity = view.showActivity()
        APIController.defaults.createTipWithParams(params: params) { (success) in
            activity.stopAnimating()
            print("Created Tip:")
            if success {
                self.showBasicAlert(title: "Tip Submitted", message: "Thanks for submitting your tip! The \(ConfigHelper.navigationTitle) Team will review it ASAP.", dismissed: {
                    self.infoTextView.text = ""
                    AppManager.shared.menu?.currentState = .menuExpanded
                    AppManager.shared.menu?.didSelectMenuOption(index: 0)
                })
            } else {
                self.showAlert(title: "Error", message: "Something went wrong. Please try again later")
            }
        }
    }
   

}
