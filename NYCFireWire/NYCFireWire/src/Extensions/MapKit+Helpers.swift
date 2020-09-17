//
//  MapKit+Helpers.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 9/17/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import MapKit


let MERCATOR_OFFSET = 268435456.0
let MERCATOR_RADIUS = 85445659.44705395
let DEGREES = 180.0
var MAP_ZOOM_LEVEL = 10.0

extension MKMapView{
    //MARK: Map Conversion Methods
    private func longitudeToPixelSpaceX(longitude:Double)->Double{
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * Double.pi / DEGREES)
    }
    
    private func latitudeToPixelSpaceY(latitude:Double)->Double{
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * Double.pi / DEGREES)) / (1 - sin(latitude * Double.pi / DEGREES))) / 2.0)
    }
    
    private func pixelSpaceXToLongitude(pixelX:Double)->Double{
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * DEGREES / Double.pi
        
    }
    
    private func pixelSpaceYToLatitude(pixelY:Double)->Double{
        return (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * DEGREES / Double.pi
    }
    
    private func coordinateSpanWithCenterCoordinate(centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double)->MKCoordinateSpan{
        
        // convert center coordiate to pixel space
        let centerPixelX = longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        
        // determine the scale value from the zoom level
        let zoomExponent:Double = 20.0 - zoomLevel
        let zoomScale:Double = pow(2.0, zoomExponent)
        
        // scale the map’s size in pixel space
        let mapSizeInPixels = self.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2.0)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2.0)
        
        // find delta between left and right longitudes
        let minLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        
        let minLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1.0 * (maxLat - minLat)
        
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    func setCenterCoordinate(centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double, animated:Bool){
        // clamp large numbers to 28
        let zoomLevel = min(zoomLevel, 28)
        MAP_ZOOM_LEVEL = zoomLevel
        // use the zoom level to compute the region
        let span = self.coordinateSpanWithCenterCoordinate(centerCoordinate: centerCoordinate, zoomLevel: zoomLevel)
        let region = MKCoordinateRegion.init(center: centerCoordinate, span: span)
        if region.center.longitude == -180.00000000{
            print("Invalid Region")
        }
        else{
            self.setRegion(region, animated: animated)
        }
    }
    
    
}

class ExpandableMapView: MKMapView {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var originalHeight: CGFloat = 0
    
    func addExpandButton() {
        let button = UIButton(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
//        button.setTitle("Expand", for: .normal)
        button.setImage(UIImage(named: "ExpandIcon"), for: .normal)
        button.addTarget(self, action: #selector(ExpandableMapView.expandButtonTapped(button:)), for: .touchUpInside)
        addSubview(button)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        self.addConstraints([
//            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 50),
//            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50),
//            NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -50),
//            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -50),
//            ])
    }
    
    @IBAction func expandButtonTapped(button: UIButton) {
        let screenHeight = UIScreen.main.bounds.height - 20
        var animateToHeight = screenHeight
        if heightConstraint.constant == screenHeight {
            animateToHeight = originalHeight
        } else {
            originalHeight = heightConstraint.constant
        }
        self.heightConstraint.constant = animateToHeight // Some value
        UIView.animate(withDuration: 1.5, animations: {
            self.layoutIfNeeded()
        })
    }
}
