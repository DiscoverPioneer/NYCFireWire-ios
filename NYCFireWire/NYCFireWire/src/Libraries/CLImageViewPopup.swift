//
//  CLImageViewPopup.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 10/11/19.
//  Copyright © 2019 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import UIKit

class CLImageViewPopup: UIImageView, UIScrollViewDelegate {
    var tempRect: CGRect?
    var bgView: UIView!
    
    var animated: Bool = true
    var intDuration = 0.25
    //MARK: Life cycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CLImageViewPopup.popUpImageToFullScreen))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
        //        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Actions of Gestures
    @objc func exitFullScreen () {
        let imageV = bgView.subviews[0] //as! UIImageView
        
        UIView.animate(withDuration: intDuration, animations: {
                imageV.frame = self.tempRect!
                self.bgView.alpha = 0
            }, completion: { (bol) in
                self.bgView.removeFromSuperview()
        })
    }
    
    var imageView: UIImageView?
    @objc func popUpImageToFullScreen() {
        
        if let window = UIApplication.shared.delegate?.window {
//            let parentView = self.findParentViewController(self)!.view
            bgView = UIView(frame: UIScreen.main.bounds)
            bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CLImageViewPopup.exitFullScreen)))
            bgView.alpha = 0
            bgView.backgroundColor = UIColor.black
            let imageV = UIImageView(image: self.image)
            self.imageView = imageV
            let scrollView = UIScrollView(frame: bgView.bounds)
            
            scrollView.addSubview(imageV)
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 10.0
            let point = self.convert(self.bounds, to: bgView)
            imageV.frame = point
            tempRect = point
            imageV.contentMode = .scaleAspectFit
            self.bgView.addSubview(scrollView)
            window?.addSubview(bgView)
            
            if animated {
                UIView.animate(withDuration: intDuration, animations: {
                    self.bgView.alpha = 1
                    imageV.frame = CGRect(x: 0, y: 0, width: (self.bgView?.frame.width)!, height: (self.bgView?.frame.width)!)
                    imageV.center = (self.bgView?.center)!
                })
            }
        }
    }
    
    func findParentViewController(_ view: UIView) -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return imageView
    }
}
