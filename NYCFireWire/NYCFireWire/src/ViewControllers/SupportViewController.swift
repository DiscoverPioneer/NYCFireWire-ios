//
//  SupportViewController.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/4/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import MessageUI

class SupportViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

//MARK: - Helpers
extension SupportViewController {
    func sendEmail() {
        sendEmail(to: "admin@nycfirewire.net", subject: "NYC Fire Wire App", message: "")
    }
}

//MARK: - Actions
extension SupportViewController {
    @IBAction func websiteButtonTapped(sender:Any) {
        if let url = URL(string: "https://www.nycfirewire.net") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func pioneerButtonTapped(sender:Any) {
        if let url = URL(string: "https://www.pioneerapplications.com") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func emailButtonTapped(sender:Any) {
        sendEmail()
    }
    
    @IBAction func shareButtonTapped(sender:Any) {
        let items:[Any] = ["Hey! Have you checked out the NYC Fire Wire app??",URL(string: "https://www.nycfirewire.net/app")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
}
