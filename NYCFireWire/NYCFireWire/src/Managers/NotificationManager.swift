//
//  NotificationManager.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/3/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import UIKit
import OneSignal

class NotificationManager {
    static let shared = NotificationManager()
    
    let notificationSounds = ["Default":"servicebell","Engine Ticket": "EngineTicket","Ladder Ticket":"LadderTicket", "Engine Ladder Ticket":"EngineLadderTicket","Special Unit":"SpecialUnit" ,"Acting Engine":"ActingEngineTicket", "Battalion": "BatalionTicket", "Division":"DivisionTicket", "Engine, Ladder, Battalion":"EngineLadderBatalionTicket", "Standby For Message":"StandbyForMessage", "Tones Only":"TonesOnly", "MDT Ring":"MDTRing"]
    
    
    func resetBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func setDefaultNotificationKeys() {
        UserDefaultConstants.setObjectForKey(key: .pushNotificationsDisabledKey, value: false)
//        UserDefaultConstants.setObjectForKey(key: .nearbyIncidentsNotificationsDisabledKey, value: false)
//        UserDefaultConstants.setObjectForKey(key: .nearbyInquiryNotificationsDisabledKey, value: false)
        
        //TODO -> Add to onesignal tags
        
    }
    
    func registerForNotification(launchOptions:[UIApplication.LaunchOptionsKey: Any]?) {
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: Constants.stringForKey(key: ConfigKeys.onesignalAppID),
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
    }
    
    func updateNotificationTags() {
        //IF DISABLE == true, dont send notification
        setTag(key: UserDefaultKeys.pushNotificationsDisabledKey.rawValue, value: UserDefaultConstants.boolForKey(key:.pushNotificationsDisabledKey))
//        setTag(key: UserDefaultKeys.nearbyIncidentsNotificationsDisabledKey.rawValue, value: UserDefaultConstants.boolForKey(key:.nearbyIncidentsNotificationsDisabledKey))
//        setTag(key: UserDefaultKeys.nearbyInquiryNotificationsDisabledKey.rawValue, value: UserDefaultConstants.boolForKey(key:.nearbyInquiryNotificationsDisabledKey))
//        OneSignal.setSubscription(!UserDefaultConstants.boolForKey(key:.nearbyInquiryNotificationsDisabledKey))
    }
    
    func setTag(key: String, value: Any) {
        OneSignal.sendTag(key, value: "\(value)")
    }
    
    func setNotificationSound(soundName: String) {
        let name = notificationSounds[soundName]
        //Get file from bundle and copy it to sounds
        if let bundleURL = Bundle.main.url(forResource: name, withExtension: "wav") {
            let baseSoundURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Sounds")
            let soundsDirectoryURL = baseSoundURL.appendingPathComponent("custom.wav")

            if !FileManager.default.fileExists(atPath: baseSoundURL.path) {
                do
                {
                    try FileManager.default.createDirectory(atPath: baseSoundURL.path, withIntermediateDirectories: true, attributes: nil)
//                    FileManager.default.createFile(atPath: soundsDirectoryURL.path, contents: nil, attributes: nil)
                }
                catch let error as NSError
                {
                    NSLog("Unable to create directory \(error.debugDescription)")
                }
            }
            
            
            print("Checking..\(FileManager.default.fileExists(atPath: soundsDirectoryURL.path))")

            
            try? FileManager.default.removeItem(at: soundsDirectoryURL)
            do {
                print("Copy from: \(bundleURL) to: \(soundsDirectoryURL)")
                try FileManager.default.copyItem(at: bundleURL, to: soundsDirectoryURL)
//                try FileManager.default.copyItem(atPath: bundlePath, toPath: soundsDirectoryURL.path)
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
//                if FileManager.default.fileExists(atPath: soundsDirectoryURL.path) {
//                    do
//                    {
//                        try FileManager.default.createFile(atPath: soundsDirectoryURL.path, contents: nil, attributes: nil)
//                    }
//                    catch let error as NSError
//                    {
//                        NSLog("Unable to create directory \(error.debugDescription)")
//                    }
//                }
            }
        } else {
//            print("Cant find file in bundle.... \(name)")
        }
//        if let bundlePath = Bundle.main.path(forResource: name, ofType: "wav") {
////            let fileName = "\(name).wav"
//            let soundsDirectoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Sounds").appendingPathComponent("custom.wav")
//
//            try? FileManager.default.removeItem(at: soundsDirectoryURL)
//            do {
//                try FileManager.default.copyItem(atPath: bundlePath, toPath: soundsDirectoryURL.path)
//            } catch let error as NSError {
//                print("Error: \(error.localizedDescription)")
//            }
//        }
        
        
        UserDefaults.standard.set(soundName, forKey: "pushSound")
        
        
        
        
        
        
        
        
        
//        let soundsDirectoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Sounds")
//
//
//
//
//        //attempt to create the folder
//        do {
//            try FileManager.default.createDirectory(atPath: soundsDirectoryURL.path,
//                                            withIntermediateDirectories: true, attributes: nil)
//        } catch let error as NSError {
//            print("Error: \(error.localizedDescription)")
//        }
    }
}
