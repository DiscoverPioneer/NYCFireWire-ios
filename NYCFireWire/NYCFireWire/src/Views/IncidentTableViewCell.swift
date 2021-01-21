//
//  IncidentTableViewCell.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 9/13/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

protocol LikeButtonDelegate {
    func incidentLikedTapped(cell: IncidentTableViewCell)
    func incidentUnliked(cell: IncidentTableViewCell)
}

class IncidentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var boroLabel: UILabel!
    @IBOutlet weak var boxLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var featuredImage: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    let alreadyLikedImage = UIImage(systemName: AssetConstants.likeFilled)
    let likeImage = UIImage(systemName: AssetConstants.like)
    
    
//    var id: Int?
    var isLiked: Bool = false {
        didSet {
            likeButton.setImage(nil, for: .normal)
            if isLiked {
                likeButton.setTitle("🔥", for: .normal)
//                likeButton.setImage(alreadyLikedImage, for: .normal)
            } else {
                likeButton.setTitle("🔥", for: .normal)
//                likeButton.setImage(likeImage, for: .normal)
            }
        }
    }
    var delegate: LikeButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeTapped() {
        delegate?.incidentLikedTapped(cell: self)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {        
            self.likeButton.center.y -= 10
            self.likeButton.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
            self.likeButton.alpha = 0.2
        }, completion: {_ in
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                self.likeButton.center.y -= 40
                self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self.likeButton.alpha = 0.8
            }, completion: {_ in
                UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                    self.likeButton.center.y += 50
                    self.likeButton.transform = .identity
                }, completion: nil)
            })
        })
        
        //Changing way of liking incidents
//        if isLiked {
//            likeButton.setImage(alreadyLikedImage, for: .normal)
//            delegate?.incidentUnliked(cell: self)
//        } else {
//            likeButton.setImage(likeImage, for: .normal)
//            delegate?.incidentLikedTapped(cell: self)
//        }
    }
}
