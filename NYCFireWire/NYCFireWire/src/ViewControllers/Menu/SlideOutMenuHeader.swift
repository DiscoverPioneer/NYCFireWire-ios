//
//  SlideOutMenuHeader.swift
//  SavePop
//
//  Created by Allan Araujo on 8/12/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

class SlideOutMenuHeader: UICollectionViewCell {
    
    let headerLabel : UILabel = {
        let label = UILabel()
        label.text = "NYC Fire Wire"
//        label.font = UIFont.mainFontBold(size: 64)
        label.textColor = UIColor.white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.themeBackgroundColor
        
        addSubview(headerLabel)
        headerLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        setupLineSeparatorView()
    }
    
    fileprivate func setupLineSeparatorView() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.white
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

