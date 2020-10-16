//
//  AdController.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 3/1/19.
//  Copyright © 2019 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import GoogleMobileAds

//let HomePageInterstitialID = "ca-app-pub-7236390531604246~3719788746"
//let DetailPageInterstitialID = "ca-app-pub-7236390531604246/8558790686"

enum PageAdID: String {
    case HomePageInterstitialID = "ca-app-pub-7236390531604246/2886333587"
    case HomePageBannerID = "ca-app-pub-7236390531604246/4196039691"
    case DetailPageInterstitialID = "ca-app-pub-7236390531604246/8558790686"
    case TableViewBannerID = "ca-app-pub-7236390531604246/3954049463"
    case DetailPageBannerID = "ca-app-pub-7236390531604246/5820012511"
    case TestNativeID = "ca-app-pub-3940256099942544/8407707713"
    case TestBannerID = "ca-app-pub-3940256099942544/2934735716"
}

class AdCountController {
    func incrementCountForAd(id: String) -> Int {
        let count = UserDefaults.standard.integer(forKey: "AdCount\(id)") + 1
        UserDefaults.standard.set(count, forKey: "AdCount\(id)")
        return count
    }
}

class AdController: NSObject, GADInterstitialDelegate, GADBannerViewDelegate {
    static let shared = AdController()
    
    let appID = "ca-app-pub-7236390531604246~3719788746"
    var interstitial:GADInterstitial?
    var lastUsedPageAdID = PageAdID.HomePageInterstitialID
    
    
    
    //TableView
    /// The number of native ads to load (between 1 and 5 for this example).
    let numAdsToLoad = 5
    /// The native ads.
    var nativeAds = [GADUnifiedNativeAd]()
    /// The ad loader that loads the native ads.
    var adLoader: GADAdLoader!
    
    
    
    func initialize() {
        //TODO: - Change
        GADMobileAds.configure(withApplicationID: appID)
        GADMobileAds.sharedInstance().start { (status) in
            print("Ads status: \(status)")
        }
//        GADMobileAds.sharedInstance().tra
    }
    
    
    func preloadTableViewAds(vc: UIViewController, delegate: GADAdLoaderDelegate) {
        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = numAdsToLoad

        // Prepare the ad loader and start loading ads.
        adLoader = GADAdLoader(adUnitID: PageAdID.TableViewBannerID.rawValue,
                               rootViewController: vc,
                               adTypes: [GADAdLoaderAdType.unifiedNative],
                               options: [options])
        adLoader.delegate = delegate
        print("Preparing Native Ads")
        adLoader.load(GADRequest())

    }
    
    func addBannerToViewController(viewController: UIViewController, adUnitId: PageAdID = .HomePageBannerID) -> GADBannerView {
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(bannerView)
        viewController.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: viewController.view,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: viewController.view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        bannerView.adUnitID = adUnitId.rawValue
        bannerView.rootViewController = viewController
        let request = GADRequest()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["ad9575036cdcf54b0123221a352d0d11"]
        bannerView.delegate = self
        bannerView.load(request)
        
        return bannerView
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("RECIEVED BANNER AD")
    }
    
    
    
    func prepareForInterstitial(adUnitID: PageAdID) {
        let interstitial = GADInterstitial(adUnitID: adUnitID.rawValue)
        print("Using adUnitID: \(adUnitID.rawValue)")
        let request = GADRequest()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["ad9575036cdcf54b0123221a352d0d11"]
        interstitial.load(request)
        interstitial.delegate = self
        self.interstitial = interstitial
        self.lastUsedPageAdID = adUnitID
    }
    
    func showInterstitialToViewController(viewController: UIViewController, adUnitID: PageAdID) {
        guard let interstitial = interstitial else {
            prepareForInterstitial(adUnitID: adUnitID)
            return
        }
        if interstitial.hasBeenUsed {
            prepareForInterstitial(adUnitID: adUnitID)
            return
        }
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: viewController)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    func shouldShowAdditionalAds() -> Bool {
        let val = (Constants.constantForKey(key: ConfigKeys.hideAdditionalAds) as? Bool)
        return val == nil || val == false
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        prepareForInterstitial(adUnitID: lastUsedPageAdID)
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        prepareForInterstitial(adUnitID: lastUsedPageAdID)
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }

}
