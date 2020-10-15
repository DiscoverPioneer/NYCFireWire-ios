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
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
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
        delegate?.incidentLiked()
    }
}
