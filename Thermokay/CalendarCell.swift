//
//  CalendarCell.swift
//  Thermokay
//
//  Created by JJ Zapata on 5/6/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit

class CalendarCell: UITableViewCell {
    
    @IBOutlet var name : UILabel!
    @IBOutlet var temp : UILabel!
    @IBOutlet var loca : UILabel!
    @IBOutlet var day : UILabel!
    @IBOutlet var time : UILabel!
    
    @IBOutlet var mainView : UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
