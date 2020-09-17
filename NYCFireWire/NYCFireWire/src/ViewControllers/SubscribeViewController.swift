//
//  SubscribeViewController.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 4/8/19.
//  Copyright © 2019 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

class SubscribeViewController: UIViewController {
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    var isShowingModally = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailLabel.text = "With a premium account, you gain access to:\n-our Live Scanner Feeds\n-an Ad-Free app experience\n-custom notifications (specific units, boros, incident types, etc.)\n-custom notification sounds and more to come!"
        AnalyticsController.logEvent(eventName: "SubscribeViewController")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isShowingModally {
            closeButton.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func showAsPopupInVC(viewController: UIViewController) {
//        navigationController?.navigationBar.isHidden = true
        isShowingModally = true
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        viewController.definesPresentationContext = true
        viewController.present(self, animated: true, completion: nil)
    }
    
}

//MARK: - Helpers
extension SubscribeViewController {
}

//MARK: - Actions
extension SubscribeViewController {
    
    @IBAction func closeAction() {
//        navigationController?.navigationBar.isHidden = false
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func purchaseMonthlyAction() {
        self.subscribeAction()
    }
    
    @IBAction func restoreTapped() {
        self.restoreAction()
    }
    
    @IBAction func termsOfServiceAction() {
        UIApplication.shared.open(URL(string: "https://nycfirewire.net/about/terms")!, options: [:], completionHandler: nil)

    }
    
    @IBAction func privacyPolicyAction() {
        UIApplication.shared.open(URL(string: "https://nycfirewire.net/about/privacy")!, options: [:], completionHandler: nil)

    }
}
