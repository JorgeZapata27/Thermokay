//
//  InboxCell.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/18/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit

class InboxCell: UITableViewCell {
    
    @IBOutlet var profileImage : UIImageView!
    @IBOutlet var profileLabel : UILabel!
    @IBOutlet var acceptButton : UIButton!
    @IBOutlet var declineButton : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
