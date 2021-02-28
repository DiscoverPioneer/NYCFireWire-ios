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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
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
        
        setLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @IBAction func forgotPasswordButtonTapped() {
        let ac = UIAlertController(title: "Password Reset", message: "Please enter your email address associated with your acount", preferredStyle: .alert)
        ac.addTextField { (tf) in
            tf.keyboardType = .emailAddress
            tf.placeholder = "Email address"
        }

        let submitAction = UIAlertAction(title: "Reset Password", style: .default) { [unowned ac] _ in
            if let email = ac.textFields![0].text, email.isValidEmail() {
                APIController().resetPassword(email: email) {
                    self.showAlert(title: "Reset Sent", message: "Please check your email for a link to reset your password.")
                }
            }
        }

        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        present(ac, animated: true)
    }
}
