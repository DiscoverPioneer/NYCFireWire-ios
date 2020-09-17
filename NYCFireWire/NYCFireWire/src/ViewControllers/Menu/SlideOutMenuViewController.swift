//
//  SlideOutMenuViewController.swift
//  SavePop
//
//  Created by Allan Araujo on 8/12/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

protocol SlideOutMenuViewControllerDelegate {
    func didSelectMenuOption(index: Int)
}

class SlideOutMenuViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
   
    var delegate: SlideOutMenuViewControllerDelegate?
    
    let cellId = "slideOutMenuCellID"
    let headerId = "slideOutMenuHeaderID"
    
    let versionLabel: UILabel = {
        let label = UILabel()
        label.text = MenuOptions.version
//        label.font = UIFont.mainFont(size: 12)
        label.textColor = UIColor.white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.isUserInteractionEnabled = true
        collectionView?.backgroundColor = UIColor.themeBackgroundColor
        
        collectionView?.register(SlideOutMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(SlideOutMenuCells.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.addSubview(versionLabel)
        versionLabel.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 150)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! SlideOutMenuHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 60.0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let labels = AppManager.shared.currentUser?.hasAdminAccess() == true ? MenuOptions.adminLabels : MenuOptions.labels

        return labels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SlideOutMenuCells
        let labels = AppManager.shared.currentUser?.hasAdminAccess() == true ? MenuOptions.adminLabels : MenuOptions.labels

        cell.cellLabel.text = labels[indexPath.item]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectMenuOption(index: indexPath.item)
    }
}
