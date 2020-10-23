//
//  TimelineView.swift
//  Evan Dekhayser
//
//  Created by Evan Dekhayser on 7/25/14.
//  Copyright (c) 2014 Evan Dekhayser. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit
import Kingfisher

protocol TimelineViewDelegate {
    func timelineView(timelineView: TimelineView, didTapElementAt index: Int)
    func moreButtonWasTapped(timelineView: TimelineView, didTapElementAt index: Int)
    func linkWasTapped(timelineView: TimelineView, url: URL)
}

/**
	Represents an instance in the Timeline. A Timeline is built using one or more of these TimeFrames.
*/
public struct TimeFrame {
	/**
		The date that the event occured.
	*/
	let date: String
    /**
     A description of the event.
     */
    let text: String?
	/**
		An optional image to show with the text and the date in the timeline.
	*/
	let imageURL: URL?
    
    /**
        An optional closure to call when an image is tapped.
    */
    let imageTapped: ((UIImageView) -> Void)?
    let hideMore: Bool
    public init(date: String, text: String? = nil, imageURL: URL? = nil, imageTapped: ((UIImageView) -> Void)? = nil, hideMore: Bool = false) {
        self.date = date
        self.text = text
        self.imageURL = imageURL
        self.imageTapped = imageTapped
        self.hideMore = hideMore
    }
}

/**
	The shape of a bullet that appears next to each event in the Timeline.
*/
public enum BulletType{
	/**
		Bullet shaped as a circle with no fill.
	*/
	case circle
	/**
		Bullet shaped as a hexagon with no fill.
	*/
	case hexagon
	/**
		Bullet shaped as a diamond with no fill.
	*/
	case diamond
	/**
		Bullet shaped as a circle with no fill and a horizontal line connecting two vertices.
	*/
	case diamondSlash
	/**
		Bullet shaped as a carrot facing inward toward the event.
	*/
	case carrot
	/**
		Bullet shaped as an arrow pointing inward toward the event.
	*/
	case arrow
}

/**
	View that shows the given events in bullet form.
*/
open class TimelineView: UIView {
    var delegate: TimelineViewDelegate?
    
	//MARK: Public Properties
	
	/**
		The events shown in the Timeline
	*/
	open var timeFrames: [TimeFrame]{
		didSet{
			setupContent()
		}
	}
	
	/**
		The color of the bullets and the lines connecting them.
	*/
	open var lineColor: UIColor = UIColor.lightGray{
		didSet{
			setupContent()
		}
	}
    
    /**
     The color of the data label.
     */
    open var dateLabelColor: UIColor = UIColor.red {
        didSet{
            setupContent()
        }
    }
	
    /**
        Configures the date labels in the timeline.
    */
    open var configureDateLabel: ((UILabel) -> Void) = { label in
        label.font = UIFont(name: "ArialMT", size: 15)
        label.textColor = UIColor.red//UIColor(red: 0/255, green: 180/255, blue: 160/255, alpha: 1)
    } {
        didSet {
            setupContent()
        }
    }
    
    /**
        Configures the date labels in the timeline.
     */
    open var configureTextLabel: ((UILabel) -> Void) = { label in
        label.font = UIFont(name: "ArialMT", size: 17)
        label.textColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1)
    } {
        didSet {
            setupContent()
        }
    }
	
    open var configureTextView: ((UITextView) -> Void) = { textView in
        textView.font = UIFont(name: "ArialMT", size: 17)
        textView.textColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1)
        textView.isEditable = false
        textView.isSelectable = true
        textView.tintColor = .white
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link
        textView.translatesAutoresizingMaskIntoConstraints = false
    } {
        didSet {
            setupContent()
        }
    }
	/**
		The type of bullet shown next to each element.
	*/
	open var bulletType: BulletType = BulletType.diamond{
		didSet{
			setupContent()
		}
	}
    
    /**
        The width and height of the bullets
    */
    open var bulletSize: CGFloat = 18 {
        didSet {
            setupContent()
        }
    }
		
	//MARK: Public Methods
	
	/**
		Note that the timeFrames cannot be set by this method. Further setup is required once this initalization occurs.
	
		May require more work to allow this to work with restoration.
	
		@param coder An unarchiver object.
	*/
	required public init?(coder aDecoder: NSCoder) {
		timeFrames = []
		super.init(coder: aDecoder)
	}
	
	/**
		Initializes the timeline with all information needed for a complete setup.
	
		@param bulletType The type of bullet shown next to each element.
	
		@param timeFrames The events shown in the Timeline
	*/
	public init(bulletType: BulletType, timeFrames: [TimeFrame]){
		self.timeFrames = timeFrames
		self.bulletType = bulletType
		super.init(frame: CGRect.zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		setupContent()
	}
	
	//MARK: Private Methods
	
	fileprivate func setupContent(){
		for v in subviews{
			v.removeFromSuperview()
		}
		
		let guideView = UIView()
		guideView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(guideView)
		addConstraints([
			NSLayoutConstraint(item: guideView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: guideView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: guideView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: guideView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
			])
				
		var viewFromAbove = guideView
		
		for (index, element) in timeFrames.enumerated(){
            let v = blockForTimeFrame(element, isFirst: index == 0, isLast: index == timeFrames.count - 1, index: index)
            //Add Gesture Recognizer
            v.isUserInteractionEnabled = true
            v.tag = index
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TimelineView.viewWasTapped(tapGesture:))))
			addSubview(v)
			addConstraints([
				NSLayoutConstraint(item: v, attribute: .top, relatedBy: .equal, toItem: viewFromAbove, attribute: .bottom, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: v, attribute: .width, relatedBy: .equal, toItem: viewFromAbove, attribute: .width, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: v, attribute: .leading, relatedBy: .equal, toItem: viewFromAbove, attribute: .leading, multiplier: 1.0, constant: 0)
				])
			viewFromAbove = v
		}
        
//        let line = UIView()
//        line.translatesAutoresizingMaskIntoConstraints = false
//        line.backgroundColor = lineColor
//        addSubview(line)
//        sendSubview(toBack: line)
//        addConstraints([
//            NSLayoutConstraint(item: line, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1),
//            NSLayoutConstraint(item: line, attribute: .top, relatedBy: .equal, toItem: viewFromAbove, attribute: .bottom, multiplier: 1.0, constant: 0),
//            NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: extraSpace),
//            NSLayoutConstraint(item: line, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 8 + bulletSize / 2.0)
//            ])
        addConstraint(NSLayoutConstraint(item: viewFromAbove, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
	}
    
    @objc func viewWasTapped(tapGesture: UITapGestureRecognizer) {
        if let index = tapGesture.view?.tag {
            delegate?.timelineView(timelineView: self, didTapElementAt: index)
        }
    }

    @objc func buttonWasTapped(button: UIButton) {
        delegate?.moreButtonWasTapped(timelineView: self,didTapElementAt: button.tag)
    }
    
    fileprivate func bulletView(_ width: CGFloat, bulletType: BulletType) -> UIView {
        var path: UIBezierPath
        switch bulletType {
        case .circle:
            path = UIBezierPath(ovalOfSize: width)
        case .diamond:
            path = UIBezierPath(diamondOfSize: width)
        case .diamondSlash:
            path = UIBezierPath(diamondSlashOfSize: width)
        case .hexagon:
            path = UIBezierPath(hexagonOfSize: width)
        case .carrot:
            path = UIBezierPath(carrotOfSize: width)
        case .arrow:
            path = UIBezierPath(arrowOfSize: width)
        }

        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.path = path.cgPath

        let v = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        
        let shouldFlip: Bool
        if #available(iOS 9, *) {
            shouldFlip = UIView.userInterfaceLayoutDirection(for: v.semanticContentAttribute) == .rightToLeft
        } else {
            shouldFlip = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        }
        
        if shouldFlip {
            shapeLayer.transform = CATransform3DTranslate(CATransform3DScale(CATransform3DIdentity, -1, 1, 1), -width, 0, 0)
        }
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addConstraints([
            NSLayoutConstraint(item: v, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width),
            NSLayoutConstraint(item: v, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
            ])
        v.layer.addSublayer(shapeLayer)
        return v
    }
    
    fileprivate func blockForTimeFrame(_ element: TimeFrame, isFirst: Bool = false, isLast: Bool = false, index: Int) -> UIView {
		let v = UIView()
		v.translatesAutoresizingMaskIntoConstraints = false
        v.addConstraint(NSLayoutConstraint(item: v, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: bulletSize))
        
		//bullet
        let bullet: UIView = bulletView(bulletSize, bulletType: bulletType)
		v.addSubview(bullet)
        v.addConstraints([
            NSLayoutConstraint(item: bullet, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: v, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: bullet, attribute: .leading, relatedBy: .equal, toItem: v, attribute: .leading, multiplier: 1.0, constant: 8)
            ])
        
        //top line, if necessary
        if !isFirst {
            let topLine = UIView()
            topLine.translatesAutoresizingMaskIntoConstraints = false
            topLine.backgroundColor = lineColor
            v.addSubview(topLine)
            sendSubviewToBack(topLine)
            v.addConstraints([
                NSLayoutConstraint(item: topLine, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1),
                NSLayoutConstraint(item: topLine, attribute: .top, relatedBy: .equal, toItem: v, attribute: .top, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: topLine, attribute: .bottom, relatedBy: .equal, toItem: bullet, attribute: .top, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: topLine, attribute: .centerX, relatedBy: .equal, toItem: bullet, attribute: .centerX, multiplier: 1.0, constant: 0),
                ])
        }
		
		let dateLabel = UILabel()
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		
		dateLabel.text = element.date
		dateLabel.numberOfLines = 1
        configureDateLabel(dateLabel)
        v.addSubview(dateLabel)
		v.addConstraints([
            NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: v, attribute: .top, multiplier: 1.0, constant: 20),
            NSLayoutConstraint(item: dateLabel, attribute: .leading, relatedBy: .equal, toItem: bullet, attribute: .trailing, multiplier: 1.0, constant: 8),
            NSLayoutConstraint(item: dateLabel, attribute: .trailing, relatedBy: .equal, toItem: v, attribute: .trailing, multiplier: 1.0, constant: -16),
            NSLayoutConstraint(item: dateLabel, attribute: .centerY, relatedBy: .equal, toItem: bullet, attribute: .centerY, multiplier: 1.0, constant: 1)
			])
        dateLabel.textAlignment = .natural
		
        var lastView: UIView = dateLabel
        
        if let text = element.text {
            let textView = UITextView()
            textView.backgroundColor = self.backgroundColor
            textView.text = text
            textView.delegate = self
            configureTextView(textView)
            v.addSubview(textView)
            v.addConstraints([
                textView.heightAnchor.constraint(equalToConstant: 30),
                NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: dateLabel, attribute: .trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: dateLabel, attribute: .bottom, multiplier: 1.0, constant: 3),
                NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: dateLabel, attribute: .leading, multiplier: 1.0, constant: 0)
                ])
            textView.textAlignment = .natural
            lastView = textView

        } else {
           
        }
        
        //image
        if let imageURL = element.imageURL {
            
            let backgroundViewForImage = UIView()
            backgroundViewForImage.translatesAutoresizingMaskIntoConstraints = false
            backgroundViewForImage.backgroundColor = UIColor.black
            backgroundViewForImage.layer.cornerRadius = 10
            v.addSubview(backgroundViewForImage)
            v.addConstraints([
                NSLayoutConstraint(item: backgroundViewForImage, attribute: .trailing, relatedBy: .equal, toItem: dateLabel, attribute: .trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: backgroundViewForImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 130),
                NSLayoutConstraint(item: backgroundViewForImage, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 10),
                NSLayoutConstraint(item: backgroundViewForImage, attribute: .bottom, relatedBy: .equal, toItem: v, attribute: .bottom, multiplier: 1.0, constant: -10),
                NSLayoutConstraint(item: backgroundViewForImage, attribute: .leading, relatedBy: .equal, toItem: dateLabel, attribute: .leading, multiplier: 1.0, constant: 0)
            ])
            
            let imageView = CLImageViewPopup(frame: CGRect(x: 0,y: 0,width: 500,height: 500))
            
            
            
            imageView.layer.cornerRadius = 10
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            v.addSubview(imageView)
            
            
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imageURL)
            
            
            v.addConstraints([
                NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .left, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .right, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .top, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .bottom, multiplier: 1.0, constant: 0)
            ])
            
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = UIColor.clear
            button.addTargetClosure {
                element.imageTapped?(imageView)
                imageView.popUpImageToFullScreen()
            }
            v.addSubview(button)
            v.addConstraints([
                NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .width, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .height, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .top, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .leading, multiplier: 1.0, constant: 0)
            ])
            lastView = imageView
            
        } else {
            v.addConstraint(NSLayoutConstraint(item: lastView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: v, attribute: .bottom, multiplier: 1.0, constant: -20))
        }
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = index
        button.tintColor = .lightGray
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.addTarget(self, action: #selector(buttonWasTapped), for: .allEvents)
        button.isSpringLoaded = true
        if element.hideMore {
                    button.isHidden = true
                }
        v.addSubview(button)
        v.addConstraints([
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: lastView, attribute: .trailing, multiplier: 1.0, constant: 0)

        ])
        lastView = button
        
        //draw the bottom line between the bullets
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = lineColor
        v.addSubview(line)
        sendSubviewToBack(line)
        v.addConstraints([
            NSLayoutConstraint(item: line, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1),
            NSLayoutConstraint(item: line, attribute: .top, relatedBy: .equal, toItem: bullet, attribute: .bottom, multiplier: 1.0, constant: 0)
        ])
        if isLast {
            let extraSpace: CGFloat = 2000
            v.addConstraint(NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: v, attribute: .height, multiplier: 1.0, constant: extraSpace))
        } else {
            v.addConstraint(NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: v, attribute: .height, multiplier: 1.0, constant: -bulletSize))
        }
        
        v.addConstraint(NSLayoutConstraint(item: line, attribute: .centerX, relatedBy: .equal, toItem: bullet, attribute: .centerX, multiplier: 1.0, constant: 0))
		
		return v
	}
}

extension TimelineView: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.linkWasTapped(timelineView: self, url: URL)
        print("delegate method hit")
        return false
    }
    
}

fileprivate extension CGFloat {
    func radians() -> CGFloat {
        return CGFloat(GLKMathDegreesToRadians(Float(self)))
    }
}

fileprivate func polygonPointArray(sides: Int, x: CGFloat, y: CGFloat, radius: CGFloat) -> [CGPoint] {
    let angle = 2 * CGFloat.pi / CGFloat(sides)
    var i = 0
    var points = [CGPoint]()
    while i <= sides {
        let xpo = x + radius * sin(angle * CGFloat(i))
        let ypo = y + radius * cos(angle * CGFloat(i))
        points.append(CGPoint(x: xpo, y: ypo))
        i += 1
    }
    return points
}

extension UIBezierPath {

    convenience init(hexagonOfSize width: CGFloat) {
        self.init()
        let points = polygonPointArray(sides: 6, x: width / 2, y: width / 2, radius: width / 2.0)
        move(to: points[0])
        for point in points[1...] {
            addLine(to: point)
        }
        close()
    }

    convenience init(diamondOfSize width: CGFloat) {
        self.init()
        let points = polygonPointArray(sides: 4, x: width / 2, y: width / 2, radius: width / 2.0)
        move(to: points[0])
        for point in points[1...] {
            addLine(to: point)
        }
        close()
    }

    convenience init(diamondSlashOfSize width: CGFloat) {
        self.init(diamondOfSize: width)
        move(to: CGPoint(x: 0, y: width/2))
        addLine(to: CGPoint(x: width, y: width / 2))
    }

    convenience init(ovalOfSize width: CGFloat) {
        self.init(ovalIn: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width)))
    }

    convenience init(carrotOfSize width: CGFloat) {
        self.init()
        move(to: CGPoint(x: width/2, y: 0))
        addLine(to: CGPoint(x: width, y: width / 2))
        addLine(to: CGPoint(x: width / 2, y: width))
    }

    convenience init(arrowOfSize width: CGFloat) {
        self.init(carrotOfSize: width)
        move(to: CGPoint(x: 0, y: width/2))
        addLine(to: CGPoint(x: width, y: width / 2))
    }
}

fileprivate typealias UIButtonTargetClosure = () -> Void

fileprivate class ClosureWrapper: NSObject {
    let closure: UIButtonTargetClosure
    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
}

fileprivate extension UIButton {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure()
    }
}

extension TimelineView {
    func addToScrollView(scrollView: UIScrollView) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(self)
        scrollView.addConstraints([
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: -20),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0)
        ])
    }
}
