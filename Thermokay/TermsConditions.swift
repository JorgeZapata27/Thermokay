//
//  TermsConditions.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/16/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit

class TermsConditions: UIViewController {
        
        @IBOutlet var navView : UIView!

        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.navView.layer.cornerRadius = 15
            self.navView.layer.shadowColor = UIColor.gray.cgColor
            self.navView.layer.shadowOffset = .zero
            self.navView.layer.shadowOpacity = 0.9
            self.navView.layer.shadowRadius = 15
            self.navView.layer.shadowPath = UIBezierPath(rect: self.navView.bounds).cgPath
            self.navView.layer.shouldRasterize = true
            self.navView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

            // Do any additional setup after loading the view.
        }
        
        @IBAction func dismissView(_ sender: UIButton) {
            self.navigationController?.popViewController(animated: true)
        }

    }

