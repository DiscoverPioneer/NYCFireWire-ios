//
//  YoutubeVideoPlayVC.swift
//  NYCFireWire
//
//  Created by mac on 11/03/21.
//  Copyright © 2021 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import YouTubePlayer

//import YTPlayerView

class YoutubeVideoPlayVC: UIViewController,YTPlayerViewDelegate{

    @IBOutlet weak var videoView: YTPlayerView!
    @IBOutlet weak var youtubePlayerView: YouTubePlayerView!
    
    var videoUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView(){
//        videoView.delegate = self
//        videoView.load(withVideoId:"sCbbMZ-q4-I")
//        videoView.loadVideo(byURL: "https://www.youtube.com/watch?v=sCbbMZ-q4-I", startSeconds: 0)
        
        // Load video from YouTube URL
        let myVideoURL = URL(string: "https://www.youtube.com/watch?v=sCbbMZ-q4-I")
        youtubePlayerView.loadVideoURL(myVideoURL!)
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
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
