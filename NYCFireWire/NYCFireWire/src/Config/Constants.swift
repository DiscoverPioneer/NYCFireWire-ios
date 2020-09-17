//
//  Constants.swift
//  VinLabels
//
//  Created by Phil Scarfi on 5/30/18.
//

import Foundation

struct ConfigKeys {
    static let apiBaseURI = "apiBaseURI"
    static let webBaseURI = "webBaseURI"
    static let onesignalAppID = "onesignalAppID"
    static let liveStreamURI = "liveStreamURI"
    static let hideAdditionalAds = "hideAdditionalAds"
}

struct Constants {
    static func stringForKey(key: String) -> String {
        if let string = constantForKey(key: key) as? String {
            return string
        }
        return ""
    }
    
    static func constantForKey(key: String) -> Any? {
        //1. Look for file in documents directory
        //2. If no file in documents directory, pull from main budle
        
        var url: URL?

        //Check if file exists in documents, else pull from bundle
        if let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let config = Bundle.main.infoDictionary?["Configuration"] as? String {
            let filename = "\(config)_Config"
            let fileLocation = documentsUrl.appendingPathComponent("/files/\(filename).plist", isDirectory: false)
            if FileManager.default.fileExists(atPath: fileLocation.path) {
                url = fileLocation
                print("Using File URL, not bundle")
            }
            
            if url == nil {
                url = Bundle.main.url(forResource: filename, withExtension: "plist")
            }
            
            if let URL = url {
                if let dict = NSMutableDictionary(contentsOf: URL) {
                    print("Retrieved config plist")
                    return dict[key]
                } else {
                    print("Not a valid plist type")
                }
            } else {
                print("Not a valid URL")
            }
        }

        

//        if let config = Bundle.main.infoDictionary?["Configuration"] as? String, let plistPath = Bundle.main.path(forResource: "\(config)_Config", ofType: "plist"), let dict = NSMutableDictionary(contentsOfFile: plistPath) {
//            return dict[key]
//        }
        return nil
    }
}
