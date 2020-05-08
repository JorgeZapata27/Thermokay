//
//  SettingsCell.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/16/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet var myView : UIView!
    @IBOutlet var myLabel : UILabel!
    @IBOutlet var myImage : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.myView.layer.shadowColor = UIColor.black.cgColor
        self.myView.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.myView.layer.shadowRadius = 8
        self.myView.layer.shadowOpacity = 0.1
        self.myView.layer.cornerRadius = self.myView.frame.height / 4
        self.myView.clipsToBounds = true
        self.myView.layer.masksToBounds = false
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
