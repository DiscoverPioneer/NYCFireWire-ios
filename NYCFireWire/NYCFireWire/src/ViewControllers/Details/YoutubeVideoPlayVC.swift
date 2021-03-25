//
//  YoutubeVideoPlayVC.swift
//  NYCFireWire
//
//  Created by mac on 11/03/21.
//  Copyright © 2021 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import YouTubePlayer
import youtube_ios_player_helper
import NVActivityIndicatorView
//import YTPlayerView

class YoutubeVideoPlayVC: UIViewController,YTPlayerViewDelegate{

    @IBOutlet weak var videoView: YTPlayerView!
    @IBOutlet weak var youtubePlayerView: YouTubePlayerView!
    
    var videoUrl = String()
    var activity : NVActivityIndicatorView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView(){
        videoView.isHidden = true
        videoView.delegate = self
        activity = self.view.showActivity()
        videoView.load(withVideoId:videoUrl.youtubeID ?? "")
        
        let myVideoURL = URL(string: "https://www.youtube.com/watch?v=sCbbMZ-q4-I")
        youtubePlayerView.loadVideoURL(myVideoURL!)
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        videoView.isHidden = false
        activity?.stopAnimating()
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        
    }
}
extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"

        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)

        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }

        return (self as NSString).substring(with: result.range)
    }
}
