//
//  SlideOutMenuCells.swift
//  SavePop
//
//  Created by Allan Araujo on 8/12/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

class SlideOutMenuCells: UICollectionViewCell {
    
    var shouldTintBackgroundWhenSelected = true
    
    var cellLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample"
//        label.font = UIFont.mainFontBold(size: 32)
        label.textColor = UIColor.white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.themeBackgroundColor
        
        addSubview(cellLabel)
        cellLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cellLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.white
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 250, height: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        willSet {
            onSelected(newValue)
        }
    }

    override var isSelected: Bool {
        willSet {
            onSelected(newValue)
        }
    }
    func onSelected(_ newValue: Bool) {
        guard selectedBackgroundView == nil else { return }
        if shouldTintBackgroundWhenSelected {
            contentView.backgroundColor = newValue ? UIColor.lightGray : UIColor.themeBackgroundColor
        }
    }
}
