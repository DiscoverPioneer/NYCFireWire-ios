//
//  NotificationSettingsViewController.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 2/16/19.
//  Copyright © 2019 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import OneSignal

class NotificationSettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var customNotificationsSwitch: UISwitch!
    var selectedTags = [String]()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        //Get Selected Tags
        title = "Custom Notifications"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let spinner = view.showActivity()
        OneSignal.getTags { (tags) in
//            print("My Tags Are: \(tags)")
            guard let tags = tags, let tagArray = Array(tags.keys) as? [String] else {
                return
            }
            let boros = PickerData.boros
            let units = PickerData.units.map({$0.name})
            let incidents = PickerData.incidentTypes
            for tag in tagArray {
                if boros.firstIndex(of: tag) != nil {
                    self.selectedTags.append(tag)
                } else if units.firstIndex(of: tag) != nil {
                    self.selectedTags.append(tag)
                } else if incidents.firstIndex(of: tag) != nil {
                    self.selectedTags.append(tag)
                }
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                spinner.stopAnimating()
                self.updateNumberLabel()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

//MARK: - TableView
extension NotificationSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Boros/Areas"
        case 1:
            return "Incident Types"
        case 2:
            return "Units"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return PickerData.boros.count
        case 1:
            return PickerData.incidentTypes.count
        case 2:
            return PickerData.units.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellTitle = cellTitleForIndex(indexPath: indexPath)
        
        
        let cell = UITableViewCell()
        if selectedTags.firstIndex(of: cellTitle) != nil {
            cell.accessoryType = .checkmark
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
            cell.isSelected = false
        }
        cell.textLabel?.text = cellTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !hasMonthlySubscription() {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadData()
            return
        }
        let cellTitle = cellTitleForIndex(indexPath: indexPath)

        if let cell = tableView.cellForRow(at: indexPath) {
            if selectedTags.firstIndex(of: cellTitle) != nil {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            cell.accessoryType = .checkmark

        }
        selectedTags.append(cellTitle)
        addTags()
        updateNumberLabel()

        print("Selected row")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Deselected row")
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        let cellTitle = cellTitleForIndex(indexPath: indexPath)
        selectedTags.removeAll{$0 == cellTitle}
        deleteTag(tag: cellTitle)
        updateNumberLabel()
    }
    
    func cellTitleForIndex(indexPath: IndexPath) -> String {
        let cellTitle:String
        switch indexPath.section {
        case 0:
            cellTitle = PickerData.boros[indexPath.row]
        case 1:
            cellTitle = PickerData.incidentTypes[indexPath.row]
        case 2:
            cellTitle = PickerData.units[indexPath.row].name
        default:
            cellTitle = ""
        }
        return cellTitle
    }
}

//MARK: - Helpers
extension NotificationSettingsViewController {
    func addTags() {
        var allTags = [String:Any]()
        for tag in selectedTags {
            allTags[tag] = "true"
        }
        OneSignal.sendTags(allTags)
        
    }
    
    func deleteTag(tag: String) {
        OneSignal.deleteTag(tag)
    }
    
    func deleteAllTags() {
        OneSignal.deleteTags(selectedTags)
    }
    
    func updateNumberLabel() {
        let numberSelected = selectedTags.count
        
        
        if numberSelected > 0 {
            OneSignal.sendTags(["custom_notifications_enabled":"true"])
            let button = UIBarButtonItem(title: "(\(numberSelected))", style: .plain, target: nil, action: nil)
            navigationItem.rightBarButtonItem = button
            customNotificationsSwitch.isOn = false

        } else {
            OneSignal.sendTags(["custom_notifications_enabled":"false"])
            navigationItem.rightBarButtonItem = nil
            customNotificationsSwitch.isOn = true

        }
    }
}

//MARK: - Actions
extension NotificationSettingsViewController {
    @IBAction func didToggleCustomNotificationsSwitch(notificationsSwitch: UISwitch) {
        if notificationsSwitch.isOn {
            deleteAllTags()
            selectedTags.removeAll()
            updateNumberLabel()
            tableView.reloadData()
        }
    }
}
