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
                let unitsComment = TimeFrame(date: "Units", text: "\(data.units)", imageURL: nil, imageTapped: nil, hideMore: true)
                timeFrames.append(unitsComment)
            }
            
            for comment in adminComments {
                if let urlString = comment.imageURL {
                    timeFrames.append(TimeFrame(date:comment.createdAt.toLocalTime().smartStringFromDate() , text: comment.text, imageURL: URL(string: urlString), imageTapped: nil,hideMore: true))
                } else {
                    timeFrames.append(TimeFrame(date:comment.createdAt.toLocalTime().smartStringFromDate() , text: comment.text, imageURL: nil, imageTapped: nil,hideMore: true))
                }
            }
            let timeline = TimelineView(bulletType: .circle, timeFrames: timeFrames)
            self.timeline?.removeFromSuperview()
            timeline.addToScrollView(scrollView: scrollView)
            self.timeline = timeline
        }
    }
}

//MARK: - Actions
extension OfficialInformationViewController {
    
}
