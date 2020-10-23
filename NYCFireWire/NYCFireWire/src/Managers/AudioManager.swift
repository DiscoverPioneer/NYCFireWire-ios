//
//  AudioManager.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 3/30/19.
//  Copyright © 2019 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioManagerDelegate {
    func audioManager(manager: AudioManager, didUpdateMetadata metadata: String)
}

class AudioManager: NSObject {
    let timedMetadataKey = "timedMetadata"
    static let shared = AudioManager()
    var delegate: AudioManagerDelegate?
    
    var player: AVPlayer?
    
    var isPlaying: Bool {
        get {
            return player?.rate != 0 && player?.error == nil && player != nil
        }
    }
    override init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
    }
    
    func streamAudioFromURL(url: URL) {
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        self.player = AVPlayer.init(playerItem: item)
//        self.player = AVPlayer.init(url: url)
//        self.player?.addObserver(self, forKeyPath: "status", options: [], context: nil)
        item.addObserver(self, forKeyPath: timedMetadataKey, options: [.new], context: nil)
        self.player?.play()
    }
    
    func stopStreaming() {
        self.player?.pause()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       
        if let playerItem = object as? AVPlayerItem, let metadataArray = playerItem.timedMetadata, keyPath == "timedMetadata" {
            for metaData in metadataArray {
//                print("Meta: \(metaData.stringValue)")
                if let metadata = metaData.stringValue {
                    delegate?.audioManager(manager: self, didUpdateMetadata: metadata)
                }
            }
        }
    }
}
