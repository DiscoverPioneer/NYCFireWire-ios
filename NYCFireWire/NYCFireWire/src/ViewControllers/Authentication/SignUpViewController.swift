//
//  SignUpViewController.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 9/13/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

let SignInText = "Already have an account?\nSign in"

class SignUpViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    let formVC = MountainClimberController()
    var allTextFields = [String:UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
extension SignUpViewController {
    fileprivate func setupUI() {
        signInButton.titleLabel?.numberOfLines = 0
        signInButton.titleLabel?.textAlignment = .center
        signInButton.setTitle(SignInText, for: .normal)
        let firstNameTF = addTextField(name: "firstName", placeHolder: "First Name")
        let lastNameTF = addTextField(name: "lastName", placeHolder: "Last Name")
        let emailTF = addTextField(name: "email", placeHolder: "Email")
        emailTF.keyboardType = .emailAddress
        let passwordTF = addTextField(name: "password", placeHolder: "Password (6 or more characters)")
        passwordTF.isSecureTextEntry = true
        let confirmPasswordTF = addTextField(name: "confirmPassword", placeHolder: "Confirm Password")
        confirmPasswordTF.isSecureTextEntry = true
        let phoneNumberTF = addTextField(name: "phoneNumber", placeHolder: "Phone Number (optional)")
        phoneNumberTF.keyboardType = .numberPad
        phoneNumberTF.addDoneButtonOnKeyboard()
        let rankTF = addTextField(name: "rank", placeHolder: "Rank/Title")
        
        let signupButton = UIButton(frame: CGRect(x: 0, y: 0, width: 250, height: 40))
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.setTitleColor(UIColor.white, for: .normal)
        signupButton.addTarget(self, action: #selector(SignUpViewController.signUpButtonTapped(sender:)), for: .touchUpInside)
        formVC.allViews = [firstNameTF, lastNameTF, emailTF, passwordTF, confirmPasswordTF, phoneNumberTF,rankTF, signupButton]
        addChild(page:formVC , toView: formView)
    }
    
    fileprivate func addTextField(name: String, placeHolder: String) -> UITextField {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 250, height: 40))
        textField.textAlignment = .center
        textField.textColor = UIColor.white
        textField.autocapitalizationType = .words
        textField.delegate = self
        textField.backgroundColor = UIColor.fireWireGray
        textField.placeholder = placeHolder
        textField.font = UIFont(name: "TimesNewRomanPSMT", size: 17)
        textField.setPlaceHolderColor(color: UIColor.white)
        self.allTextFields[name] = textField
        return textField
    }
    
    fileprivate func passwordsMatch() -> Bool {
        return allTextFields["password"]!.text == allTextFields["confirmPassword"]!.text
    }
    
    fileprivate func textFieldsAreValid() -> Bool {
        if !passwordsMatch() {
            self.showAlert(title: "Error", message: "Passwords don't match")
            return false
        }
        return allTextFields["firstName"]!.isValid(type: .regular) && allTextFields["lastName"]!.isValid(type: .regular)
            && allTextFields["email"]!.isValid(type: .email) && allTextFields["password"]!.isValid(type: .password) && allTextFields["confirmPassword"]!.isValid(type: .password) && (passwordsMatch())
    }
    
    fileprivate func completeSignup() {
        APIController().signup(email: allTextFields["email"]!.text!, password: allTextFields["password"]!.text!, firstName: allTextFields["firstName"]!.text!, lastName: allTextFields["lastName"]!.text!, phoneNumber: allTextFields["phoneNumber"]!.text, rank: allTextFields["rank"]!.text) { (user, errorMessage) in
            if let user = user {
                AppManager.shared.currentUser = user
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                let error = errorMessage ?? "Something went wrong. Please try again later..."
                self.showAlert(title: "Error", message: error)
            }
        }
    }
}

//MARK: - Actions
extension SignUpViewController {
    @IBAction func signUpButtonTapped(sender: Any) {
        print("Signing Up...")
        if textFieldsAreValid() {
            //here
            let alert = UIAlertController(title: "Agree to terms and conditions", message: "By signing up for \(ConfigHelper.navigationTitle), you agree to the terms and conditions", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I agree", style: .default, handler: { (action) in
                self.completeSignup()
            }))
            alert.addAction(UIAlertAction(title: "View terms and conditions", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: "https://nycfirewire.net/about/terms")!, options: [:], completionHandler: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: "Please make sure all fields are filled in")
        }
    }
    
    @IBAction func signinButtonTapped(sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
