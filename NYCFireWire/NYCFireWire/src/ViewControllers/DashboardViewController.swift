//
//  DashboardViewController.swift
//  TestWizard
//
//  Created by Phil Scarfi on 9/12/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import MapKit
import GoogleMobileAds
import OneSignal
import WidgetKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var mapView: ExpandableMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeaderLabel: UILabel!
    
    var bannerView: GADBannerView!
    var tvBannerView: GADBannerView!
    let boroTextField = UITextField()

    let maxHeaderHeight: CGFloat = 250;
    let minHeaderHeight: CGFloat = 0;
    
    var previousScrollOffset: CGFloat = 0;
    var currentCoordinates = CLLocationCoordinate2D(latitude: 40.7806341, longitude: -73.9242574)
    var currentRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.7806341, longitude: -73.9242574), span: MKCoordinateSpan(latitudeDelta: 500, longitudeDelta: 500))
    var allIncidents = [Incident]()
    var allAdsDict = [Int: GADUnifiedNativeAd]()
    var allTableViewItems = [Any]()
    
    let feedTypes = ["All", "NYC", "Long Island", "Brooklyn", "Bronx", "Manhattan", "Queens", "Staten Island"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // Fallback on earlier versions
        }
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        title = "NYC Fire Wire"
        tableView.register(UINib(nibName: "IncidentTableViewCell", bundle: nil), forCellReuseIdentifier: "IncidentCell")
        tableView.register(UINib(nibName: "UnifiedNativeAdCell", bundle: nil), forCellReuseIdentifier: "UnifiedNativeAdCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DashboardViewController.refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        boroTextField.isHidden = true
        boroTextField.addDoneButtonOnKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("TextFieldDismissed"), object: nil)

        view.addSubview(boroTextField)
        refresh()
        IAPHandler.shared.fetchAvailableProducts()

        APIController.defaults.getMe { (fullUser) in
            if let user = fullUser {
                AppManager.shared.currentUser = user
                
                // widget info
                if let email = AppManager.shared.currentUser?.email,
                   let token = AppManager.shared.userToken {
                    UserDefaultsSuite().setString(value: email, key: UserDefaultSuiteKeys.userEmailKey.rawValue)
                    UserDefaultsSuite().setString(value: token, key: UserDefaultSuiteKeys.userTokenKey.rawValue)

                }
                if #available(iOS 14.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                } else {
                    // Fallback on earlier versions
                }
                
                //Show Ads
                if !IAPHandler.shared.isMonthlySubscriptionPurchased() {
                    if AdController.shared.shouldShowAdditionalAds() {
                        AdController.shared.preloadTableViewAds(vc: self, delegate: self)
                    }
                    self.bannerView = AdController().addBannerToViewController(viewController: self)
                }
                
                if user.verified {
                    self.showSubscribeAlert()
                } else {
                    self.showVerifyAlert(user: user)
                }
                
                //Update User
                let playerID = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId ?? ""
                let subscription = IAPHandler.shared.isMonthlySubscriptionPurchased() ? "subcribed_monthly" : "free"
                APIController.defaults.updateUser(updateDict: ["last_login":Date(),"push_id":playerID, "subscription":subscription]) { (user) in
                    print("Updated User")
                }
            }
        }
        self.mapViewHeightConstraint.constant = self.maxHeaderHeight
        
        mapView.addExpandButton()
        AnalyticsController.logEvent(eventName: "DashboardViewController")

        
    }
    
    func showVerifyAlert(user: FullUser) {
        
        if !user.email.isValidEmail() {
            showAlert(title: "Invalid Email", message: "We detected your email is not valid. Please go to settings and update it.")
            return
        }
        
        let verifyAction = UIAlertAction(title: "Verify Email", style: .default) { (action) in
            APIController.defaults.verifyUser(email: user.email) { (success) in
                if success {
                    self.showAlert(title: "Verification Sent", message: "Please check your email for a verification email.")
                } else {
                    self.showAlert(title: "Error", message: "Something went wrong. Please try again later")
                }
            }
        }
        showAlert(title: "Verify Email", message: "In order to access certain features of this app, you must verify your email. The email we have on file is: \(user.email). If this is incorrect, please update it in the settings page.", actions: [verifyAction], cancel: true)
    }
    
    func showHintAlert() {
        let defaults = UserDefaults.standard
        let defaultsKey = "DidShowFilterHintAlert1"
        if defaults.bool(forKey: defaultsKey) {
            print("Already showed alert")
            return
        }
        let message = "Did you know that you can filter your feed? Try it out by tapping on the 'Incidents' Label."
        
        showAlert(title: "Hint!", message: message)
        defaults.set(true, forKey: defaultsKey)
    }
    
    func showSubscribeAlert() {
        let defaults = UserDefaults.standard
        let defaultsKey = "DidShowSubscribeWelcomeAlert"
        if defaults.bool(forKey: defaultsKey) {
            print("Already showed alert1")
            showHintAlert()
            return
        }
        let message = "Thank you for downloading the NYC Fire Wire app. We now have premium features that you can subscribe to use.\nThese include our Live Scanner feeds, custom notifications (specific units, boros, incident types, etc.), custom notification sounds, and an Ad-Free experience.\nNOTE: General push notifications will still be available in the free version."
        let freeButton = UIAlertAction(title: "Continue with free version", style: .default, handler: nil)
        let subscribeButton = UIAlertAction(title: "GET PREMIUM FEATURES", style: .default) { (action) in
            _ = self.hasMonthlySubscription()
        }
        showAlert(title: "Welcome!", message: message, actions: [freeButton, subscribeButton])
        defaults.set(true, forKey: defaultsKey)
    }
    
    fileprivate func setupNavBar() {
        navigationController?.navigationBar.tintColor = UIColor.white
//        let locationBtn = UIButton(type: .custom)
//        locationBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
//        locationBtn.setImage(UIImage(named:"LocationFinder"), for: .normal)
//        locationBtn.addTarget(self, action: #selector(CreateIncidentViewController.scrollToUserLocation), for: UIControl.Event.touchUpInside)
//        let locationButton = locationBtn.convertToBarButtonItem()
        
//        navigationItem.rightBarButtonItem = locationButton
        if AudioManager.shared.isPlaying {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop Listening", style: .plain, target: self, action: #selector(listenLive))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listen Live", style: .plain, target: self, action: #selector(listenLive))
        }

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()

//        self.mapViewHeightConstraint.constant = self.maxHeaderHeight
//        updateHeader()
        mapView.setCenterCoordinate(centerCoordinate: CLLocationCoordinate2D(latitude: 40.7806341, longitude: -73.9242574), zoomLevel: 8, animated: true)
        self.currentRegion = mapView.region
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            if AdCountController().incrementCountForAd(id: "HomePageInterstitial") % 10 == 0 {
//                AdController.shared.showInterstitialToViewController(viewController: self,adUnitID: .HomePageInterstitialID)
//            }
//        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func refresh() {
        let activity = view.showActivity()
        let feedType = UserDefaults.standard.string(forKey: "selectedFeedType") ?? "NYC"
        self.setFeedTypeLabel()
        APIController.defaults.getAllIncidents(feedType: feedType) { (incidents) in
            self.allIncidents = incidents
            self.setTableViewItems()
            self.setPins()
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
            activity.removeFromSuperview()
        }
    }
    
    @IBAction func didTapIncidentHeaderLabel() {
        showBoroPicker()
    }
    
    func setTableViewItems() {
        
        var items = [Any]()
        items.append(contentsOf: allIncidents)
        let nativeAds = AdController.shared.nativeAds
        
        if nativeAds.count <= 0 {
            print("NO NATIVE ADS AVAILABLE")
        } else {
            let adInterval = (items.count / nativeAds.count) + 1
            var index = 3
            for nativeAd in nativeAds {
              if index < items.count {
                items.insert(nativeAd, at: index)
                self.allAdsDict[index] = nativeAd
                index += adInterval
              } else {
                break
              }
            }
        }
        self.allTableViewItems = items
        self.tableView.reloadData()
    }
    
}

//MARK: - TableView DataSource
extension DashboardViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let _ = allTableViewItems[indexPath.row] as? Incident {
            return UITableView.automaticDimension
        } else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        if let incident = allTableViewItems[indexPath.row] as? Incident {
            //Incident
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentCell", for: indexPath) as! IncidentTableViewCell
            cell.tag = indexPath.row
            cell.delegate = self
            cell.isLiked = incident.isLiked
            cell.boroLabel.text = incident.boro
            cell.dateLabel.text = incident.createdAt.smartStringFromDate()
            if let boxNumber = Int(incident.boxNumber) {
                cell.boxLabel.text = "Box \(boxNumber)"
            } else {
                cell.boxLabel.text = incident.boxNumber
            }
            cell.titleLabel.text = "*\(incident.title)*"
            cell.subtitleLabel.text = incident.subtitle
            cell.numberOfLikesLabel.text = "\(incident.numberOfLikes)"
//            if incident.numberOfLikes == 0 {
//                cell.numberOfLikesLabel.isHidden = true
//            } else {
//                cell.numberOfLikesLabel.text = "\(incident.numberOfLikes) likes"
//            }
            
            cell.numberOfCommentsLabel.text = "\(incident.numberOfComments)"
            
            if let image = incident.featuredImageURL {
                cell.featuredImage.isHidden = false
                let url = URL(string: image)
                cell.featuredImage.kf.setImage(with: url)
            }
            
            return cell
        } else {
            //Ad
            print("ads: \(AdController.shared.nativeAds)")
            print("\(allTableViewItems[indexPath.row] as? GADUnifiedNativeAd)")
            guard let nativeAd = self.allAdsDict[indexPath.row] else {
                return UITableViewCell()
            }//AdController.shared.nativeAds.first!//allTableViewItems[indexPath.row] as! GADUnifiedNativeAd
            /// Set the native ad's rootViewController to the current view controller.
            nativeAd.rootViewController = self

            let nativeAdCell = tableView.dequeueReusableCell(
                withIdentifier: "UnifiedNativeAdCell", for: indexPath)

            // Get the ad view from the Cell. The view hierarchy for this cell is defined in
            // UnifiedNativeAdCell.xib.
            let adView : GADUnifiedNativeAdView = nativeAdCell.contentView.subviews.first as! GADUnifiedNativeAdView

            // Associate the ad view with the ad object.
            // This is required to make the ad clickable.
            adView.nativeAd = nativeAd

            // Populate the ad view with the ad assets.
            (adView.headlineView as! UILabel).text = nativeAd.headline
            (adView.priceView as! UILabel).text = nativeAd.price
            if let starRating = nativeAd.starRating {
              (adView.starRatingView as! UILabel).text =
                  starRating.description + "\u{2605}"
            } else {
              (adView.starRatingView as! UILabel).text = nil
            }
            (adView.bodyView as! UILabel).text = nativeAd.body
            (adView.advertiserView as! UILabel).text = nativeAd.advertiser
            // The SDK automatically turns off user interaction for assets that are part of the ad, but
            // it is still good to be explicit.
            (adView.callToActionView as! UIButton).isUserInteractionEnabled = false
            (adView.callToActionView as! UIButton).setTitle(
                nativeAd.callToAction, for: UIControl.State.normal)

            return nativeAdCell
        }
        
        
    }
}

//MARK: - TableView Delegate
extension DashboardViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let location = allTableViewItems[indexPath.row] as? Incident, let vc = DetailsViewController.instantiateFromMainStoryboard() {
            vc.selectedLocation = location
            navigationController?.pushViewController(vc, animated: true)
            UserDefaultsSuite().setInt(value: location.id, key: UserDefaultSuiteKeys.selectedLocation.rawValue)
            UserDefaultsSuite().setString(value: location.featuredImageURL ?? "", key: UserDefaultSuiteKeys.locationImageURL.rawValue)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        if canAnimateHeader(scrollView) {
            
            // Calculate new header height
            var newHeight = self.mapViewHeightConstraint.constant
            if isScrollingDown {
                newHeight = max(self.minHeaderHeight, self.mapViewHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(self.maxHeaderHeight, self.mapViewHeightConstraint.constant + abs(scrollDiff))
            }
            
            // Header needs to animate
            if newHeight != self.mapViewHeightConstraint.constant {
                self.mapViewHeightConstraint.constant = newHeight
                self.setScrollPosition(self.previousScrollOffset)
            }
            
            self.previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.mapViewHeightConstraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.mapViewHeightConstraint.constant - minHeaderHeight
        
        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.mapViewHeightConstraint.constant = self.minHeaderHeight
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.mapViewHeightConstraint.constant = self.maxHeaderHeight
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.mapView.setRegion(self.currentRegion, animated: true)
            }
        }
    }
    
    func setScrollPosition(_ position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
}

//MARK: - MapView Delegate
extension DashboardViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.currentRegion = mapView.region
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {  //Handle user location annotation..
            return nil  //Default is to let the system handle it.
        }
        
        if !annotation.isKind(of: ImageAnnotation.self) {  //Handle non-ImageAnnotations..
            var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
            }
            return pinAnnotationView
        }
        
        //Handle ImageAnnotations..
        var view: ImageAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? ImageAnnotationView
        if view == nil {
            view = ImageAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
        }
        
        let annotation = annotation as! ImageAnnotation
        view?.image = annotation.image
        view?.annotation = annotation
        
        return view
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let view = view as! ImageAnnotationView
        let index = (view.annotation as! ImageAnnotation).id
        let indexPath = IndexPath(row: index, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
    }
}

//MARK: - Helpers
extension DashboardViewController {
    func setPins() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        var index = 0
        for incident in allIncidents {
            let annotation = ImageAnnotation()
            annotation.id = index
            annotation.coordinate = incident.location.coordinate
            annotation.title = incident.title
            annotation.subtitle = incident.address
            annotation.image = UIImage(named:"IncidentIcon")
            self.mapView.addAnnotation(annotation)

            DispatchQueue.main.async {
            }
            index += 1
        }
    }
}

//MARK: - Actions
extension DashboardViewController {
    @IBAction func showAdminPage() {
        if let vc = CreateIncidentViewController.instantiateFromMainStoryboard() {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func scrollToUserLocation() {
        if let location = LocationManager.shared.manager.location?.coordinate {
            mapView.setCenterCoordinate(centerCoordinate: location, zoomLevel: 14, animated: true)
        }
    }
    
    @IBAction func listenLive() {
        if AudioManager.shared.isPlaying {
            //Stop Playing
            AudioManager.shared.stopStreaming()
            self.view.hideAllToasts()

            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listen Live", style: .plain, target: self, action: #selector(listenLive))

        } else {
            showScannerFeedOptions()
        }
        
    }
    
    func listenToFeed(feedURL: String) {
        if !hasMonthlySubscription() {
            return
        }
        print("Listening to feed url: \(feedURL)")
        AudioManager.shared.delegate = self
        let audioManager = AudioManager.shared
        audioManager.streamAudioFromURL(url: URL(string: feedURL)!)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop Listening", style: .plain, target: self, action: #selector(listenLive))
        AnalyticsController.logEvent(eventName: "LiveScannerActivated")
    }
    
    func showScannerFeedOptions() {
        let actionSheet = UIAlertController(title: "Choose a feed", message: nil, preferredStyle: .actionSheet)
        actionSheet.modalPresentationStyle = .popover
        let scannerFeeds = ConfigHelper.availableFeeds
        for feed in scannerFeeds {
            actionSheet.addAction((UIAlertAction(title: feed.name, style: .default, handler: { (action) in
                AnalyticsController.logEvent(eventName: "LiveScanner-\(feed.name)")
//                print("Feed Selected: \(feed.name), \(feed.url)")
                if let url = feed.url {
                    self.listenToFeed(feedURL: url)
                } else {
                    self.showAlert(title: "Not Available", message: "This feed is not available yet.")
                }
            })))
        }
       
        actionSheet.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        })))
        if let presenter = actionSheet.popoverPresentationController, let button = navigationItem.rightBarButtonItem {
            presenter.barButtonItem = button
        }
        present(actionSheet, animated: true, completion: nil)
    }
}

extension DashboardViewController: AudioManagerDelegate {
    func audioManager(manager: AudioManager, didUpdateMetadata metadata: String) {
        ToastManager.shared.isTapToDismissEnabled = true
        self.view.hideAllToasts()
        self.view.makeToast(metadata, duration: 30.0, position: .bottom)
    }
}


//TableView Ads
extension DashboardViewController: GADUnifiedNativeAdLoaderDelegate {

    func adLoader(_ adLoader: GADAdLoader,
                  didFailToReceiveAdWithError error: GADRequestError) {
      print("\(adLoader) failed with error: \(error.localizedDescription)")

    }

    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
//        print("Received native ad: \(nativeAd)")
//        print("Name: \(nativeAd.headline)")

      // Add the native ad to the list of native ads.
        AdController.shared.nativeAds.append(nativeAd)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
      //reload tableView
        setTableViewItems()
    }
}

extension DashboardViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return feedTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return feedTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let title = feedTypes[row]
        UserDefaults.standard.set(title, forKey: "selectedFeedType")
        UserDefaultsSuite().setString(value: title, key: "selectedFeedType")
        if title == "Long Island" || title == "All" {
            OneSignal.sendTag("Long Island", value: "true", onSuccess: { (sucess) in
                print("Updated tag1")
            }) { (error) in
//                print("Error Updating Tag... \(error)")
            }
        } else {
            OneSignal.deleteTag("Long Island", onSuccess: { (success) in
//                print("Deleted tag1: \(success)")
                OneSignal.getTags { (tags) in
//                    print("Tags: \(tags)")
                }
            }) { (error) in
//                print("Error Deleting Tag... \(error)")
            }
            
            
        }
        setFeedTypeLabel()
    }
    
    func setFeedTypeLabel() {
        if let title = UserDefaults.standard.string(forKey: "selectedFeedType") {
            tableViewHeaderLabel.text = "Incidents - \(title)"
        } else {
            tableViewHeaderLabel.text = "Incidents - NYC"
        }

    }
    
    func showBoroPicker() {
        let _ = boroTextField.usePickerView(dataSource: self, delegate: self)
        boroTextField.becomeFirstResponder()
//        pickerView(picker, didSelectRow: 0, inComponent: 0)
    }
    
}

extension DashboardViewController: LikeButtonDelegate {
    func incidentLikedTapped(cell: IncidentTableViewCell) {
        guard let incident = allTableViewItems[cell.tag] as? Incident else {
            return
        }
        incident.like()
        allTableViewItems[cell.tag] = incident
        // API call
        APIController.defaults.acknowledgeIncident(id: incident.id, completion: { success in
            if success {
                print("Incident liked")
            }
        })
        tableView.reloadData()
    }
    
    
    //Currently not going to be used
    func incidentUnliked(cell: IncidentTableViewCell) {
        guard let incident = allTableViewItems[cell.tag] as? Incident else {
            return
        }
        incident.unlike()
        allTableViewItems[cell.tag] = incident
        // API call
        APIController.defaults.unlikeIncident(id: incident.id, completion: { success in
            if success {
                print("Incident unliked")
            }
        })
        tableView.reloadData()
    }
}
