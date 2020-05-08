//
//  Account.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/17/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit

class Account: UIViewController {
    
    @IBOutlet var navView : UIView!
    @IBOutlet var mainView : UIView!
    
    @IBOutlet var userImage : UIImageView!
    @IBOutlet var barcodeImage : UIImageView!
    
    @IBOutlet var userLabel : UILabel!
    @IBOutlet var tempLabel : UILabel!
    
    var username = ""
    var image = ""
    var temperature = ""
    var barcode = ""

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
        
        self.mainView.layer.shadowColor = UIColor.black.cgColor
        self.mainView.layer.shadowOpacity = 0.1
        self.mainView.layer.shadowOffset = .zero
        self.mainView.layer.shadowRadius = 25
        self.mainView.layer.cornerRadius = 25

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showIndicator(withTitle: "Loading", and: "")
        
        self.userImage.loadImageUsingCacheWithUrlString(image)
        self.userLabel!.text! = username
        self.tempLabel!.text! = temperature
        self.barcodeImage.loadImageUsingCacheWithUrlString(barcode)
        
        self.hideIndicator()
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func more(_ sender: UIButton) {
        self.showIndicator(withTitle: "Loading", and: "")
        let alertController = UIAlertController(title: "More", message: "", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (action) in
            let alertController = UIAlertController(title: "Success", message: "Account Reported", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertController, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.hideIndicator()
        self.present(alertController, animated: true, completion: nil)
    }

}
