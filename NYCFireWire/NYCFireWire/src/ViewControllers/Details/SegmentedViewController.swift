//
//  SegmentedViewController.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/1/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SegmentedViewController: ButtonBarPagerTabStripViewController {
    
    var selectedLocation: Location!
    var comments = [Comment]()
    var adminComments = [Comment]()
    weak var officialDataVC: OfficialInformationViewController?
    weak var chatVC: ChatViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor.white
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.selectedBarHeight = CGFloat(5)
        buttonBarView.selectedBar.backgroundColor = UIColor.white
        buttonBarView.backgroundColor = UIColor.themeBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        if let vc1 = OfficialInformationViewController.instantiateFromMainStoryboard(), let vc2 = ChatViewController.instantiateFromMainStoryboard() {
            vc1.dataSource = self
            self.officialDataVC = vc1
            vc2.dataSource = self
            vc2.delegate = self
            self.chatVC = vc2
            return [vc1,vc2]
        }
        return [OfficialInformationViewController(), ChatViewController()]
    }
    
}

//MARK: - Official Information Delegate & Datasource
extension SegmentedViewController: OfficialInformationViewControllerDataSource, ChatViewControllerDataSource, ChatViewControllerDelegate  {

    func dataForOfficialInformation(vc: OfficialInformationViewController) -> (title: String, subtitle: String?, address: String, units: [String]) {
        return (selectedLocation.title, selectedLocation.subtitle, selectedLocation.address, selectedLocation.units)
    }
    func adminCommentsFor(vc: OfficialInformationViewController) -> [Comment] {
        return adminComments
    }
    func commentsFor(vc: ChatViewController) -> [Comment] {
        return comments
    }
    
    func chatViewController(chatViewController: ChatViewController, didTapPostFor comment: String) {
        guard let user = AppManager.shared.currentUser, user.verified else {
            chatViewController.showAlert(title: "Verification", message: "You must verify you email in order to comment. Please do so in the settings page")
            return
        }
        let activity = chatViewController.view.showActivity()
        APIController.defaults.postCommentFor(location: selectedLocation, comment: comment) { (comment) in
            activity.stopAnimating()
            if let comment = comment {
                self.comments.append(comment)
                chatViewController.textView.text = ""
                chatViewController.reload()
            }
        }
    }
    
    func chatViewController(chatViewController: ChatViewController, didTapUploadFor comment: String, image: UIImage) {
        guard let user = AppManager.shared.currentUser, user.verified else {
            chatViewController.showAlert(title: "Verification", message: "You must verify you email in order to comment. Please do so in the settings page")
            return
        }
        let activity = chatViewController.view.showActivity()
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: nil, delegateQueue: nil)
        APIController.defaults.uploadImage(image: image, session: session) { (success, imageURL) in
            if let imageURL = imageURL {
                APIController.defaults.postCommentFor(location: self.selectedLocation, comment: comment, imageURL: imageURL) { (comment) in
                    activity.stopAnimating()
                    if let comment = comment {
                        self.comments.append(comment)
                        chatViewController.textView.text = ""
                        chatViewController.reload()
                    }
                }
            } else {
                self.showAlert(title: "Something went wrong", message: "We couldnt upload your image at this time. Please try again later")
                activity.stopAnimating()
            }
        }
    }
    
    func chatViewController(chatViewController: ChatViewController, didTapUploadVideoFor comment: String, url: URL) {
        guard let user = AppManager.shared.currentUser, user.verified else {
            chatViewController.showAlert(title: "Verification", message: "You must verify you email in order to comment. Please do so in the settings page")
            return
        }
        let activity = chatViewController.view.showActivity()
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: nil, delegateQueue: nil)
        APIController.defaults.uploadVideo(url: url, session: session) { (success, videoURL) in
            if let videoURL = videoURL {
                APIController.defaults.postCommentFor(location: self.selectedLocation, comment: comment, imageURL: videoURL, isVideo: true) { (comment) in
                    activity.stopAnimating()
                    if let comment = comment {
                        self.comments.append(comment)
                        chatViewController.textView.text = ""
                        chatViewController.reload()
                    }
                }
            } else {
                self.showAlert(title: "Something went wrong", message: "We couldnt upload your image at this time. Please try again later")
                activity.stopAnimating()
            }
        }
    }
    
}

//MARK: - Helpers
extension SegmentedViewController {
    func load(comments: [Comment], adminComments: [Comment]) {
        self.comments = comments.sorted(by: {$0.createdAt < $1.createdAt})
        self.adminComments = adminComments.sorted(by: {$0.createdAt < $1.createdAt})
        self.officialDataVC?.reload()
        self.chatVC?.reload()
        buttonBarView.reloadData()
        
    }
    
    func loadData() {
        let acitivity = view.showActivity()
        if selectedLocation is Incident { //Check if we need an incident or incident_inquiry
            APIController.defaults.getIncidentDetails(id: selectedLocation.id) { (incident, comments, adminComments) in
                acitivity.stopAnimating()
                self.load(comments: comments, adminComments: adminComments)
            }
        }
        
    }
}

//MARK: - Actions
extension SegmentedViewController {
    
}
