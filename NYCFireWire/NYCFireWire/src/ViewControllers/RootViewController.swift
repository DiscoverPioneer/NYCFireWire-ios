//
//  RootViewController.swift
//  TestWizard
//
//  Created by Phil Scarfi on 9/12/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        if let config = Bundle.main.infoDictionary?["Configuration"] as? String,let configURIString = Bundle.main.infoDictionary?["ConfigurationURI"] as? String, let url = URL(string: configURIString) {
            let filename = "\(config)_Config"
            FileUpdater().syncFileFrom(url: url, andSaveAs: filename) {
                print("Synced config file")
            }
        }
        setLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppManager.shared.isLoggedIn {
            let containerVC = PioneerMenuController()
            navigationController?.pushViewController(containerVC, animated: true)
        } else {
            if let vc = SignInViewController.instantiateFromMainStoryboard() {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setLabels() {
        titleLabel.text = ConfigHelper.navigationTitle
        subtitleLabel.text = Constants.stringForKey(key: ConfigKeys.tagLine).returnIfFilled() ?? "New York's Bravest Fire News Network"
    }
}

//MARK: - Helpers
extension RootViewController {
    
}

//MARK: - Actions
extension RootViewController {
    
}
