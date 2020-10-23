//
//  StackedTextFieldViewController.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 9/13/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

class MountainClimberController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    var allViews = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addKeyboardObservers()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
}

//MARK: - Helpers
extension MountainClimberController {
    fileprivate func setupUI() {
        let scrollView = UIScrollView(frame: view.frame)
        setView(myView: scrollView, equalTo: view)
        self.scrollView = scrollView
        let stackView = UIStackView(frame: scrollView.frame)
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 10
        for view in allViews {
            view.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
            view.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
            stackView.addArrangedSubview(view)
        }
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: stackView.frame.height)
        centerView(myView: stackView, equalTo: scrollView)
        self.stackView = stackView
    }
    
    fileprivate func setView(myView: UIView, equalTo otherView: UIView) {
        otherView.addSubview(myView)
        myView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: myView, attribute: .leading, relatedBy: .equal, toItem: otherView, attribute: .leading, multiplier: 1, constant: 0.0)
        let verticalConstraint = NSLayoutConstraint(item: myView, attribute: .bottom, relatedBy: .equal, toItem: otherView, attribute: .bottom, multiplier: 1, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: myView, attribute: .trailing, relatedBy: .equal, toItem: otherView, attribute: .trailing, multiplier: 1, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: myView, attribute: .top, relatedBy: .equal, toItem: otherView, attribute: .top, multiplier: 1, constant: 0.0)
        otherView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    fileprivate func centerView(myView: UIView, equalTo otherView: UIView) {
        otherView.addSubview(myView)
        myView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: myView, attribute: .centerX, relatedBy: .equal, toItem: otherView, attribute: .centerX, multiplier: 1, constant: 0.0)
        let verticalConstraint = NSLayoutConstraint(item: myView, attribute: .bottom, relatedBy: .equal, toItem: otherView, attribute: .bottom, multiplier: 1, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: myView, attribute: .centerX, relatedBy: .equal, toItem: otherView, attribute: .centerX, multiplier: 1, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: myView, attribute: .top, relatedBy: .equal, toItem: otherView, attribute: .top, multiplier: 1, constant: 0.0)
        otherView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(MountainClimberController.keyboardWillShow), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MountainClimberController.keyboardWillHide), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 5
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}

//MARK: - Actions
extension MountainClimberController {
    
}
