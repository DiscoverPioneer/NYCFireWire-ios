//
//  IncidentTableViewCell.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 9/13/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

protocol LikeButtonDelegate {
    func incidentLiked()
}

class IncidentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var boroLabel: UILabel!
    @IBOutlet weak var boxLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    
    var incident: Incident?
    var isLiked: Bool = false
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
        guard let incident = incident else { return }
        if incident.isLiked {
            likeButton.setImage(UIImage(systemName: AssetConstants.likeFilled), for: .normal)
            delegate?.incidentLiked()
        } else {
            likeButton.setImage(UIImage(systemName: AssetConstants.like), for: .normal)
        }
    }
}
