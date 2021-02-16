//
//  SettingsViewController.swift
//  SavePop
//
//  Created by Allan Araujo on 8/17/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsViewController: UITableViewController, NotificationToggleCellDelegate {
    
    
    
    let cellId = "cellId"
    let toggleId = "toggleId"
    
    var inEditMode = false
    
    var apiController: APIController?
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var phoneNumber: String?
    var userTitle: String?
    var userId: Int?
    var sound: String?
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(SettingsCell.self, forCellReuseIdentifier: cellId)
        tableView.register(NotificationToggleCell.self, forCellReuseIdentifier: toggleId)
        
        
        setupNavigation()
        
        apiController = APIController(email: UserDefaultConstants().userEmail, token: UserDefaultConstants().userToken)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        getUserInfo()

    }
    
    fileprivate func setupNavigation() {
        editButtonItem.action = #selector(showEditing)
        editButtonItem.title = "Edit"
        editButtonItem.tintColor = UIColor.white
        
        let verifyButton = UIBarButtonItem(title: "Verify", style: .plain, target: self, action: #selector(verifyButtonTapped))
        var buttons = [editButtonItem]
        if AppManager.shared.currentUser?.verified != true {
            buttons.append(verifyButton)
        }
        self.navigationItem.rightBarButtonItems = buttons
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationItem.title = "NYC Fire Wire"
    }
    
    @objc func verifyButtonTapped() {
        verifyEmail()
    }
    
    func verifyEmail(title: String = "Verify Email") {
        guard let user = AppManager.shared.currentUser else {
            return
        }
        if !user.email.isValidEmail() {
            showAlert(title: "Invalid Email", message: "We detected your email is not valid. Please go to settings and update it.")
            return
        }
        
        let checkIfVerified = UIAlertAction(title: "Check Verification Status", style: .default) { (action) in
            let spinner = self.view.showActivity()
            APIController.defaults.getMe { (user) in
                spinner.stopAnimating()
                if let user = user, user.verified {
                    AppManager.shared.currentUser = user
                    self.reloadView()
                    self.showAlert(title: "Verified", message: "You have successfully verified your email")
                } else {
                    self.verifyEmail(title: "Your account is not verified")
                }
            }
        }
        
        
        let verifyAction = UIAlertAction(title: "Send Verification Email", style: .default) { (action) in
            APIController.defaults.verifyUser(email: user.email) { (success) in
                if success {
                    self.showAlert(title: "Verification Sent", message: "Please check your email for a verification email.")
                } else {
                    self.showAlert(title: "Error", message: "Something went wrong. Please try again later")
                }
            }
        }
        showAlert(title: title, message: "In order to access certain features of this app, you must verify your email. The email we have on file is: \(user.email). If this is incorrect, please update it in the settings page.", actions: [checkIfVerified, verifyAction], cancel: true)
    }
    
    func reloadView() {
        self.tableView.reloadData()
        self.setupNavigation()
    }
    
    fileprivate func getUserInfo() {
        APIController.defaults.getMe { (user) in
            if let user = user {
                AppManager.shared.currentUser = user
                self.firstName = user.firstName
                self.lastName = user.lastName
                self.email = user.email
                self.phoneNumber = user.phoneNumber
                self.userTitle = user.title
                self.sound = UserDefaults.standard.object(forKey: "pushSound") as? String
            }
            self.reloadView()
        }
    }
    
    @objc func showEditing(sender: UIBarButtonItem)
    {
        if(self.tableView.isEditing == false)
        {
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItem?.title = "Save"
            self.tableView.reloadData()
        }
        else
        {
            let alertController = UIAlertController(title: "Change info?", message: "Are you sure you want to change your info?", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                print("saving user changes")
                self.saveUserChanges()
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                print("perform cancel")
            }))
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func saveUserChanges() {
//        editButtonItem.isEnabled = false
        var updateDict = [String: Any]()
        
        if let firstName = firstName, let lastName = lastName, let email = email {
            if let phoneNumber = phoneNumber{
                updateDict = ["first_name": firstName, "last_name": lastName, "email": email, "phone_number": phoneNumber]
            } else {
                updateDict = ["first_name": firstName, "last_name": lastName, "email": email]
            }
            if let userTitle = userTitle {
                updateDict["title"] = userTitle
            }
            if AppManager.shared.currentUser?.email != email {
                updateDict["verified"] = false
            }
        }
        if let pushSound = sound {
            updateDict["sound"] = pushSound
            UserDefaults.standard.set(pushSound, forKey: "pushSound")
        }
        
        APIController.defaults.updateUser(updateDict: updateDict) { (user) in
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            self.editButtonItem.isEnabled = true
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.themeBackgroundColor
        
        
        //name section
        if section == 0 {
            label.text = " Name"
        }
        
        //email section
        if section == 1 {
            label.text = " Email"
        }
        
        //phone section
        if section == 2 {
            label.text = " Phone"
        }
        
        //notification section
        if section == 3 {
            label.text = " Notifications"
        }
        
        return label
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //name section
        if section == 0 {
            return 3
        }
        
        //email section
        if section == 1 {
            return 1
        }
        
        //phone section
        if section == 2 {
            return 1
        }
        
        //notification section
        if section == 3 {
            return 2
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 3 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: toggleId, for: indexPath) as! NotificationToggleCell
                cell.selectionStyle = .none
                cell.delegate = self
                cell.tag = indexPath.row
                let isOn = !UserDefaultConstants.boolForKey(key: .pushNotificationsDisabledKey)
                cell.label.text = "  Push Notifications: \(isOn ? "On" : "Off")"
                cell.notificationSwitch.isOn = isOn
                return cell
            } else  {
                let cell = UITableViewCell()
                
//                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SettingsCell
                cell.selectionStyle = .none
                cell.textLabel?.text = "Sound: \(sound ?? "Default")"
                if self.tableView.isEditing == true {
//                    cell.textField.isEnabled = true
//                    cell.textField.delegate = self
                    
//                    cell.onEndEditing = { info in
//                        //print("Cell Editing finished with text: \(info)")
//                        if let info = info {
//                            self.setNewUserInfo(indexpath: indexPath, info: info)
//                            cell.textField.resignFirstResponder()
//                            cell.textField.removeFromSuperview()
//                        }
//                    }
                    
                } else {
//                    cell.textField.isEnabled = false
                }
//                filloutUserInfo(indexPath: indexPath, cell: cell)
                
                return cell
            }

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SettingsCell
            cell.selectionStyle = .none
            if self.tableView.isEditing == true {
                cell.textField.isEnabled = true
                cell.textField.isUserInteractionEnabled = true
                
                if indexPath.section == 1, AppManager.shared.currentUser?.verified == true {
                    cell.textField.isUserInteractionEnabled = false
                } else if indexPath.section == 2 {
                    cell.textField.keyboardType = .phonePad
                }
                
                cell.onEndEditing = { info in
                    //print("Cell Editing finished with text: \(info)")
                    if let info = info {
                        self.setNewUserInfo(indexpath: indexPath, info: info)
                        cell.textField.resignFirstResponder()
                        cell.textField.removeFromSuperview()
                    }
                }
                
            } else {
                cell.textField.isEnabled = false
            }
            filloutUserInfo(indexPath: indexPath, cell: cell)
            
            return cell
        }
        
    }
    
    func notificationToggleCell(cell: NotificationToggleCell, didToggle isOn: Bool) {
        print("Cell Is Disabled: \(!isOn)")
        if cell.tag == 0 {
            UserDefaultConstants.setObjectForKey(key: .pushNotificationsDisabledKey, value: !isOn)
            cell.label.text = " Push Notifications: \(isOn ? "On" : "Off")"
        }
//        else if cell.tag == 1 {
//            UserDefaultConstants.setObjectForKey(key: .nearbyIncidentsNotificationsDisabledKey, value: !isOn)
//            cell.label.text = "Nearby Incidents: \(isOn ? "On" : "Off")"
//        } else if cell.tag == 2 {
//            UserDefaultConstants.setObjectForKey(key: .nearbyInquiryNotificationsDisabledKey, value: !isOn)
//            cell.label.text = "Nearby Inquiries: \(isOn ? "On" : "Off")"
//        }
        NotificationManager.shared.updateNotificationTags()
    }
    
    fileprivate func setNewUserInfo(indexpath: IndexPath, info: String) {
        //name section
        if indexpath.section == 0 {
            if indexpath.row == 0 {
                firstName = info
            } else if indexpath.row == 1 {
                lastName = info
            } else if indexpath.row == 2 {
                self.userTitle = info
            }
            
        }
        
        //email section
        if indexpath.section == 1 {
            email = info
        }
        
        //phone section
        if indexpath.section == 2 {
            phoneNumber = info
        }
        
        if indexpath.section == 3 {
            sound = info
        }
    }
    
    func filloutUserInfo(indexPath: IndexPath, cell: SettingsCell) {
        
        //name section
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textField.placeholder = "First Name"
                if let firstName = firstName {
                    cell.textField.text = firstName
                }
            } else if indexPath.row == 1 {
                cell.textField.placeholder = "Last Name"
                if let lastName = lastName {
                    cell.textField.text = lastName
                }
            } else if indexPath.row == 2 {
                cell.textField.placeholder = "Title/Rank"
                if let userTitle = userTitle {
                    cell.textField.text = userTitle
                }
            } else if indexPath.row == 3 {
                cell.textField.placeholder = "Sound"
                if let userTitle = userTitle {
                    cell.textField.text = userTitle
                }
                cell.textField.delegate = self

            }
        }
        
        //email section
        if indexPath.section == 1 {
            if let email = email {
                cell.textField.text = email
            }
            
        }
        
        //phone section
        if indexPath.section == 2 {
            if let phoneNumber = phoneNumber {
                cell.textField.text = phoneNumber
            }
        }
        
        //notification section
        if indexPath.section == 3 {
            cell.textField.text = "Sound: \(sound ?? "Default")"
            cell.textField.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 1 {
            if !hasMonthlySubscription() {
                return
            }
            let actionSheet = UIAlertController(title: "Push Notification Sound", message: nil, preferredStyle: .actionSheet)
            for type in Array(NotificationManager.shared.notificationSounds.keys) as [String] {
                actionSheet.addAction(UIAlertAction(title: type, style: .default, handler: { (action) in
                    self.showAlertForSound(sound: type)
                }))
            }
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func showAlertForSound(sound: String) {
        let alert = UIAlertController(title: sound, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Preview Sound", style: .default, handler: { (action) in
            do {
                let filename = NotificationManager.shared.notificationSounds[sound]
                 let bundleURL = Bundle.main.url(forResource: filename, withExtension: "wav")

//                print("BUNDLE: \(bundleURL)")
                if let fileURL = Bundle.main.path(forResource: filename, ofType: "wav") {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                    self.audioPlayer?.play()
                } else {
                    print("No file with specified name exists")
                }
            } catch let error {
                print("Can't play the audio file failed with an error \(error.localizedDescription)")
            }

        }))
        alert.addAction(UIAlertAction(title: "Set Sound", style: .default, handler: { (action) in
            self.sound = sound
            NotificationManager.shared.setNotificationSound(soundName: sound)
            self.tableView.reloadData()
        }))
        present(alert, animated: true, completion: nil)
    }
}


extension String {
    public func isValid(type: TextFieldType) -> Bool {
        let text = self
        let isEmpty = text.count == 0 || text.isEmpty
        
        switch type {
        case .regular:
            return !isEmpty
        case .email:
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: text) && !isEmpty
        case .password:
            return !isEmpty && text.count > 3
        case .phoneNumber:
            return !isEmpty && text.count == 17
        }
    }
}

