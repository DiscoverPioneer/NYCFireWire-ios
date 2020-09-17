//
//  MenuConfiguration.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 9/13/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import SafariServices

class MenuOptions {
    
    static let labels = ["Home", "Notifications","Premium Access","Send Tip", "Store", "Settings", "About", "Log out"]
    static let version = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unkown")"
    static let viewControllers = [
        DashboardViewController.instantiateFromMainStoryboard()!,
        NotificationSettingsViewController.instantiateFromMainStoryboard()!,
        SubscribeViewController.instantiateFromMainStoryboard()!,
        SendTipViewController.instantiateFromMainStoryboard()!,
        SFSafariViewController(url: URL(string: "https://nycfirewire.net/store")!),
        SettingsViewController(),
        SupportViewController.instantiateFromMainStoryboard()!
        ]
    
    static let adminLabels = ["Home", "Create Incident", "Notifications","Premium Access","Send Tip", "Store", "Settings", "About", "Log out"]
    static let adminViewControllers = [
        DashboardViewController.instantiateFromMainStoryboard()!,
        CreateIncidentViewController.instantiateFromMainStoryboard()!,
        NotificationSettingsViewController.instantiateFromMainStoryboard()!,
        SubscribeViewController.instantiateFromMainStoryboard()!,
        SendTipViewController.instantiateFromMainStoryboard()!,
        SFSafariViewController(url: URL(string: "https://nycfirewire.net/store")!),
        SettingsViewController(),
        SupportViewController.instantiateFromMainStoryboard()!
    ]
}
