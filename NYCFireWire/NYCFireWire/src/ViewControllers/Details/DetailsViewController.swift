//
//  DetailsViewController.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/1/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var mapView: ExpandableMapView!
    @IBOutlet weak var containerView: UIView!
    
    var selectedLocation: Location!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if let vc = SegmentedViewController.instantiateFromMainStoryboard() {
            addChild(page: vc, toView: containerView)
            vc.selectedLocation = selectedLocation
        }

        navigationController?.navigationBar.tintColor = UIColor.white
        mapView.addExpandButton()

        
        
//        let buttonTitle = selectedLocation is Incident ? "Share Incident" : "Share Inquiry"
//        let shareButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(DetailsViewController.share))
//
//        navigationItem.rightBarButtonItem = shareButton

        
        
        
        
        
        APIController.defaults.updateViewsCountForLocation(location: selectedLocation as! Incident)
        if !IAPHandler.shared.isMonthlySubscriptionPurchased() {
            if AdCountController().incrementCountForAd(id: "DetailViewAd") % 3 == 0 {
                AdController.shared.showInterstitialToViewController(viewController: self, adUnitID: .DetailPageInterstitialID)
            }
        }
        AnalyticsController.logEvent(eventName: "DetailsViewController")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAndZoomToMapLocation()
        if AudioManager.shared.isPlaying {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop Listening", style: .plain, target: self, action: #selector(listenLive))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listen Live", style: .plain, target: self, action: #selector(listenLive))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func share() {
        let title = "Check out this incident on NYC Fire Wire"
        let baseURL = Constants.constantForKey(key: ConfigKeys.webBaseURI) as! String
        let url = "\(baseURL)/alert-details/id=\(selectedLocation.id)"

        let items:[Any] = [title,URL(string: url)!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    
    
}

//MARK: - Helpers
extension DetailsViewController {
    func setAndZoomToMapLocation() {
        let annotation = IncidentAnnotation()
        annotation.coordinate = selectedLocation.location.coordinate
        annotation.title = selectedLocation.title
        annotation.subtitle = selectedLocation.address

        self.mapView.addAnnotation(annotation)
        placeFirehouses()
        mapView.setCenterCoordinate(centerCoordinate: selectedLocation.location.coordinate, zoomLevel: 15, animated: true)
    }
    
    func placeFirehouses() {
        let firehouses = FirehouseParser().getAllFirehouses()
        for firehouse in firehouses {
            let annotation = FirehouseAnnotation()
            annotation.coordinate = firehouse.location.coordinate
            annotation.title = firehouse.name
            annotation.subtitle = ""
            self.mapView.addAnnotation(annotation)
        }
        let formerFirehouses = FirehouseParser().getAllFormerFirehouses()
        for firehouse in formerFirehouses {
            let annotation = FormerFirehouseAnnotation()
            annotation.coordinate = firehouse.location.coordinate
            annotation.title = firehouse.name
            annotation.subtitle = "Former Firehouse"
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
    
    //Scanner
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

extension DetailsViewController: AudioManagerDelegate {
    func audioManager(manager: AudioManager, didUpdateMetadata metadata: String) {
        ToastManager.shared.isTapToDismissEnabled = true
        self.view.hideAllToasts()
        self.view.makeToast(metadata, duration: 30.0, position: .bottom)
    }
}

class FormerFirehouseAnnotation: MKPointAnnotation {
    
}

class FirehouseAnnotation: MKPointAnnotation {
    
}

class IncidentAnnotation: MKPointAnnotation {
    
}

extension DetailsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {  //Handle user location annotation..
            return nil  //Default is to let the system handle it.
        }
        
        //Handle ImageAnnotations..
        var view: ImageAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? ImageAnnotationView
        if view == nil {
            view = ImageAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
        }

        view?.glyphImage = nil
        view?.glyphTintColor = UIColor.white
        if annotation is FormerFirehouseAnnotation {
            view?.markerTintColor = UIColor.black
        } else if annotation is IncidentAnnotation {
            view?.glyphImage = UIImage(named:"IncidentIcon")
            view?.glyphTintColor = UIColor.red
            view?.markerTintColor = UIColor.white
        } else {
            view?.markerTintColor = UIColor.blue
        }
        
        view?.annotation = annotation

        
        return view
    }
}

//MARK: - Actions
extension DetailsViewController {
    
}
