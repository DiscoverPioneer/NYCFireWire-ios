//
//  ContainerViewController.swift
//  SavePop
//
//  Created by Allan Araujo on 8/12/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import CoreLocation

class PioneerMenuController: UIViewController {
    
    enum SlideOutState {
        case menuCollapsed
        case menuExpanded
    }
    
    var currentState: SlideOutState = .menuCollapsed {
        didSet {
            let shouldShowShadow = currentState != .menuCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    let centerPanelExpandedOffset: CGFloat = 60
    
    var slideOutMenuViewController: SlideOutMenuViewController?
    var centerNavigationController: UINavigationController!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavigation()
    }

    fileprivate func setupNavigation() {
        centerNavigationController = UINavigationController(rootViewController: MenuOptions.viewControllers[0])
        view.addSubview(centerNavigationController.view)
        addChild(centerNavigationController)
        centerNavigationController.didMove(toParent: self)
        setupLeftBarButtonItem()
        centerNavigationController?.navigationBar.barTintColor = UIColor.themeBackgroundColor
        centerNavigationController?.navigationBar.tintColor = UIColor.themeBackgroundColor
        centerNavigationController?.navigationBar.isTranslucent = false
        
    }
    
    fileprivate func setupLeftBarButtonItem() {
        centerNavigationController.navigationBar.topItem?.leftBarButtonItem = leftMenuButton()
    }
    
    fileprivate func leftMenuButton() -> UIBarButtonItem {
        let menuImage = UIImage(named: "menu")
        let menuButton = UIButton(type: .system)
        menuButton.setImage(menuImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        menuButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        menuButton.contentMode = .scaleAspectFit
        menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        return UIBarButtonItem(customView: menuButton)
    }
    
    fileprivate func setupGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func showMenu() {
        toggleLeftPanel()
    }
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .menuExpanded)
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addChildSidePanelController(_ sidePanelController: SlideOutMenuViewController) {
        
        sidePanelController.delegate = self
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChild(sidePanelController)
        sidePanelController.didMove(toParent: self)
    }
    
    func addLeftPanelViewController() {
        guard slideOutMenuViewController == nil else { return }

        slideOutMenuViewController = SlideOutMenuViewController(collectionViewLayout: UICollectionViewFlowLayout())
        addChildSidePanelController(slideOutMenuViewController!)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if shouldExpand {
            currentState = .menuExpanded
            animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
            
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                self.currentState = .menuCollapsed
                self.slideOutMenuViewController?.view.removeFromSuperview()
                self.slideOutMenuViewController = nil
            }
        }
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        
        if shouldShowShadow {
            centerNavigationController.view.layer.shadowOpacity = 0.5
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    fileprivate func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            print("perform log out")
            APIController.defaults.logout()
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            print("perform cancel")
        }))
        
        present(alertController, animated: true, completion: nil)
    }
}

extension PioneerMenuController: UIGestureRecognizerDelegate {
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
    
        switch recognizer.state {

            case .began:
                if currentState == .menuCollapsed {
                    if gestureIsDraggingFromLeftToRight {
                        addLeftPanelViewController()
                    }
                }
            
            case .changed:
                
                if (!gestureIsDraggingFromLeftToRight && currentState == .menuExpanded) || (gestureIsDraggingFromLeftToRight && currentState == .menuCollapsed) {
                    if let rview = recognizer.view {
                        rview.center.x = rview.center.x + recognizer.translation(in: view).x
                        recognizer.setTranslation(CGPoint.zero, in: view)
                    }
                }
            
            
            case .ended:
                if (!gestureIsDraggingFromLeftToRight && currentState == .menuExpanded) || (gestureIsDraggingFromLeftToRight && currentState == .menuCollapsed) {
                    if let _ = slideOutMenuViewController,
                        let rview = recognizer.view {
                        // animate the side panel open or closed based on whether the view has moved more or less than halfway
                        let hasMovedGreaterThanHalfway = rview.center.x > view.bounds.size.width
                        animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
                    }
                }
            default:
                break
        }
    }
}

extension PioneerMenuController: SlideOutMenuViewControllerDelegate {
    
    func didSelectMenuOption(index: Int) {
        let viewControllers = AppManager.shared.currentUser?.hasAdminAccess() == true ? MenuOptions.adminViewControllers : MenuOptions.viewControllers
        switch index {
        case 0:
            let vc = viewControllers[index]
            vc.navigationItem.leftBarButtonItem = leftMenuButton()
            centerNavigationController.viewControllers = [viewControllers[0]]
            break
        default:
            if index == viewControllers.count {
                //LOGOUT ACTIONS HERE
                print("logging out...")
                handleLogout()
            } else {
               let vc = viewControllers[index]
                vc.navigationItem.leftBarButtonItem = leftMenuButton()
                centerNavigationController.viewControllers = [vc]
            }
        }
        toggleLeftPanel()

    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
