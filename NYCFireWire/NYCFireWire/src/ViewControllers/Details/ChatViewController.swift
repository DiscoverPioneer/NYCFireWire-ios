//
//  ChatViewController.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/1/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SafariServices

protocol ChatViewControllerDataSource {
    func commentsFor(vc: ChatViewController) -> [Comment]
    func incidentFor(vc: ChatViewController) -> Location

}

protocol ChatViewControllerDelegate {
    func chatViewController(chatViewController: ChatViewController, didTapPostFor comment: String)
    func chatViewController(chatViewController: ChatViewController, didTapUploadFor comment: String, image: UIImage)
    
}

class ChatViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIButton!
    
    var location: Location!
    var timeline: TimelineView?
    var dataSource: ChatViewControllerDataSource?
    var delegate: ChatViewControllerDelegate?
    
    var finishedLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.location = dataSource!.incidentFor(vc: self)
        finishedLoading = true
        reload()
        textView.contentInsetAdjustmentBehavior = .never
        textView.maxLength = 220
        addKeyboardObserver()
        postButton.isUserInteractionEnabled = false
        textView.minHeight = 45
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if let comments = dataSource?.commentsFor(vc: self), comments.count > 0 {
            return IndicatorInfo(title: "Chat (\(comments.count))")
        }
        return "Chat"
    }
    
    func reload() {
        setupTimeline()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Growing Text Field
extension ChatViewController: GrowingTextViewDelegate {
    
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count < 3 {
            postButton.isUserInteractionEnabled = false
        } else {
            postButton.isUserInteractionEnabled = true
        }
    }
    
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)),name: UIResponder.keyboardWillChangeFrameNotification,object: nil)
    }
    
    
    @objc func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
            let keyboardFrameInView = view.convert(endFrame, from: nil)
            let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
            let intersection = safeAreaFrame.intersection(keyboardFrameInView)
            let endFrameY = intersection.origin.y
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.textViewBottomConstraint?.constant = 0.0
            } else {
                self.textViewBottomConstraint.constant = (intersection.size.height) * -1
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
}

//MARK: - Helpers
extension ChatViewController {
    fileprivate func setupTimeline() {
        if !finishedLoading {
            return
        }
        if let comments = dataSource?.commentsFor(vc: self) {
            var timeFrames = [TimeFrame]()
            for comment in comments {
                
                let lastNameRep = comment.createdBy.lastName.first ?? Character(" ")
                var name = "\(comment.createdBy.firstName) \(lastNameRep)"
                if comment.createdBy.role == .super || comment.createdBy.role == .subadmin ||  comment.createdBy.role == .admin {
                    name = "Admin"
                }
                if let urlString = comment.imageURL {
                    timeFrames.append(TimeFrame(date:name , text: comment.text, imageURL: URL(string: urlString), imageTapped: nil))
                } else {
                    timeFrames.append(TimeFrame(date:name , text: comment.text, imageURL: nil, imageTapped: nil))
                }
            }
            let timeline = TimelineView(bulletType: .circle, timeFrames: timeFrames)
            timeline.delegate = self
            self.timeline?.removeFromSuperview()
            timeline.addToScrollView(scrollView: scrollView)
            self.timeline = timeline
        }
        //        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        //        scrollView.setContentOffset(bottomOffset, animated: true)
    }
}

//MARK: - Timeline
extension ChatViewController: TimelineViewDelegate {
    func linkWasTapped(timelineView: TimelineView, url: URL) {
        let vc = SFSafariViewController(url: url)
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func moreButtonWasTapped(timelineView: TimelineView, didTapElementAt index: Int) {
        if let comments = dataSource?.commentsFor(vc: self) {
            let comment = comments[index]
            let sheet = UIAlertController(title: "Flag User Comment?", message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "Report user", style: .destructive, handler: { (action) in
                let message = "I would like to report the comment with id: \(comment.id)\nPosted By: \(comment.createdBy.firstName) \(comment.createdBy.lastName)\nUser ID: \(comment.createdBy.id)\nContent: \(comment.text) \n\nPlease describe why below:\n\n"
                self.sendEmail(to: "admin@nycfirewire.net", subject: "REPORT: NYC Fire Wire App", message: message)
            }))
            sheet.addAction(UIAlertAction(title: "Block user", style: .destructive, handler: { (action) in
                APIController.defaults.blockUser(userID: comment.createdBy.id)
            }))
            
            if let string = comment.imageURL,
               let url = URL(string: string),
               let id =  UserDefaultsSuite().intFor(key: .selectedLocation) {
                    if AppManager.shared.currentUser?.hasAdminAccess() == true  {
                        let isImage = location.featuredImageURL == comment.imageURL
                        sheet.addAction(UIAlertAction(title: isImage ? "Remove Image" : "Set Featured Image", style: .destructive, handler: { (action) in
                            APIController.defaults.setFeaturedImage(imageURL: isImage ? nil : url, id: id, completion: { success in
                                if success {
                                    self.showAlert(title: "Image Set", message: "")
                                }
                                self.showAlert(title: "Error setting image", message: "")
                                return
                            })
                        }))
                    }
            }
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(sheet, animated: true, completion: nil)
        }
    }
    
    func timelineView(timelineView: TimelineView, didTapElementAt index: Int) {
        // replaced byt button for now
    }
    
}

//MARK: - Actions
extension ChatViewController {
    @IBAction func postButtonTapped(sender: Any) {
        print("Post button tapped...")
        if textView.text == nil || textView.text.count < 2 {
            return
        }
        textView.resignFirstResponder()
        delegate?.chatViewController(chatViewController: self, didTapPostFor: textView.text!)
        AnalyticsController.logEvent(eventName: "Sent Chat Message")
        
    }
    
    @IBAction func imageUploadTapped() {
        let alert = UIAlertController(title: "Upload an image", message: nil, preferredStyle: .actionSheet)
        alert.addAction((UIAlertAction(title: "Take Picture", style: .default, handler: { (alert) in
            DispatchQueue.main.async {
                self.getPhoto(type: .camera)
            }
        })))
        
        alert.addAction((UIAlertAction(title: "Photo Library", style: .default, handler: { (alert) in
            DispatchQueue.main.async {
                self.getPhoto(type: .photoLibrary)
            }
        })))
        
        alert.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
        })))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    override func imageFromPicker(_ image: UIImage) {
        print("Selected image \(image)")
        let useComment = (textView.text != nil && textView.text.count > 2)
        let title = useComment==false ? "Do you want to upload this image?" : "Do you want to upload this image with the comment  ''\(textView.text ?? "")''?"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "Upload", style: .default, handler: { (alert) in
            self.delegate?.chatViewController(chatViewController: self, didTapUploadFor: useComment ? self.textView.text! : "Uploaded Image", image: image)
        })))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert,animated:true,completion:nil)
    }
}
