//
//  SignInViewController.swift
//  TestWizard
//
//  Created by Phil Scarfi on 9/12/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import SwiftVideoBackground

let SignUpText = "Don't have an account?\nGet started"

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        do {
            try VideoBackground.shared.play(view: view, videoName: "homescreen", videoType: "mp4")

        } catch  {
            print("Something went wrong trying to play video")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

//MARK: - Helpers
extension SignInViewController {
    fileprivate func setupUI() {
        emailTextField.setPlaceHolderColor(color: UIColor.white)
        passwordTextField.setPlaceHolderColor(color: UIColor.white)
        signUpButton.titleLabel?.numberOfLines = 0
        signUpButton.titleLabel?.textAlignment = .center
        signUpButton.setTitle(SignUpText, for: .normal)
    }
    
    fileprivate func fieldsAreValid() -> Bool {
        return emailTextField.isValid(type: .email) && passwordTextField.isValid(type: .regular)
    }
}

//MARK: - Actions
extension SignInViewController {
    @IBAction func signUpButtonTapped(sender: Any) {
        if let vc = SignUpViewController.instantiateFromMainStoryboard() {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func signInButtonTapped(sender: Any) {
        if fieldsAreValid() {
            let spinner = view.showActivity()
            APIController(email: nil, token: nil).signin(email: emailTextField.text!, password: passwordTextField.text!) { (user, errorMessage) in
                spinner.stopAnimating()
                if let user = user {
                    AppManager.shared.currentUser = user
//                    NotificationManager.shared.setDefaultNotificationKeys()
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    let error = errorMessage ?? "Something went wrong. Please try again later..."
                    self.showAlert(title: "Error", message: error)
                }
            }
        } else {
            showAlert(title: "Hold on", message: "Please make sure all fields are correctly filled in.")
        }
    }
}
