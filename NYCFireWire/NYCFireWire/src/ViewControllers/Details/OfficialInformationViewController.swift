//
//  OfficialInformationViewController.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/1/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import GoogleMobileAds
import SafariServices

protocol OfficialInformationViewControllerDataSource {
    func dataForOfficialInformation(vc: OfficialInformationViewController) -> (title: String, subtitle: String?, address: String, units: [String])
    func adminCommentsFor(vc: OfficialInformationViewController) -> [Comment]
}


class OfficialInformationViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var timeline: TimelineView?
    var bannerView: GADBannerView!
    var dataSource: OfficialInformationViewControllerDataSource?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !IAPHandler.shared.isMonthlySubscriptionPurchased() && AdController.shared.shouldShowAdditionalAds() {
            self.bannerView = AdController().addBannerToViewController(viewController: self, adUnitId: .DetailPageBannerID)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Details")
    }
    
    func reload() {
        let data = dataSource?.dataForOfficialInformation(vc: self)
        titleLabel.text = data?.title
        subtitleLabel.text = data?.subtitle
        addressLabel.text = data?.address
        setupTimeline()
    }
}

//MARK: - Helpers
extension OfficialInformationViewController {
    fileprivate func setupTimeline() {
        //Make first comment responding units
        if let adminComments = dataSource?.adminCommentsFor(vc: self) {
            var timeFrames = [TimeFrame]()
            if let data = dataSource?.dataForOfficialInformation(vc: self), data.units.count > 0 {
                let unitsComment = TimeFrame(date: "Units", text: "\(data.units)", imageURL: nil, imageTapped: nil)
                timeFrames.append(unitsComment)
            }
            
            for comment in adminComments {
                if let urlString = comment.imageURL {
                    timeFrames.append(TimeFrame(date:comment.createdAt.toLocalTime().smartStringFromDate() , text: comment.text, imageURL: URL(string: urlString), imageTapped: nil))
                } else {
                    timeFrames.append(TimeFrame(date:comment.createdAt.toLocalTime().smartStringFromDate() , text: comment.text, imageURL: nil, imageTapped: nil))
                }
            }
            let timeline = TimelineView(bulletType: .circle, timeFrames: timeFrames)
            timeline.delegate = self
            self.timeline?.removeFromSuperview()
            timeline.addToScrollView(scrollView: scrollView)
            self.timeline = timeline
        }
    }
}

//MARK: - Actions
extension OfficialInformationViewController {
    
}

extension OfficialInformationViewController: TimelineViewDelegate {
    func timelineView(timelineView: TimelineView, didTapElementAt index: Int) {
        
    }
    
    func moreButtonWasTapped(timelineView: TimelineView, didTapElementAt index: Int) {
        if let adminComments = dataSource?.adminCommentsFor(vc: self) {
            let sheet = UIAlertController(title: "Flag User Comment?", message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "Report user", style: .destructive, handler: { (action) in
                let message = "" //"I would like to report the comment with id: \(comment.id)\nPosted By: \(comment.createdBy.firstName) \(comment.createdBy.lastName)\nUser ID: \(comment.createdBy.id)\nContent: \(comment.text) \n\nPlease describe why below:\n\n"
                self.sendEmail(to: "admin@nycfirewire.net", subject: "REPORT: NYC Fire Wire App", message: message)
            }))
//            sheet.addAction(UIAlertAction(title: "Block user", style: .destructive, handler: { (action) in
//                APIController.defaults.blockUser(userID: comment.createdBy.id)
//            }))
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(sheet, animated: true, completion: nil)
        }
    }
    
    func linkWasTapped(timelineView: TimelineView, url: URL) {
        let vc = SFSafariViewController(url: url)
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    
}

