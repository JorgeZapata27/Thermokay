//
//  Home.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/15/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Home: UIViewController {
    
    @IBOutlet var navView : UIView!
    @IBOutlet var mainView : UIView!
    
    @IBOutlet var tempLabel : UILabel!
    
    @IBOutlet var barcodeImage : UIImageView!
    
    var temperatures = [TemperatureStructure]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
        
        Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("barcodeImage").observe(.value, with: { (data) in
            let imageUrl : String = (data.value as? String)!
            self.barcodeImage.loadImageUsingCacheWithUrlString(imageUrl)
            
            Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("takenTestFirst").observe(.value, with: { (data) in
                let boolean : String = (data.value as? String)!
                if boolean == "true" {
                    self.temperatures.removeAll()
                    let uid = Auth.auth().currentUser?.uid
                    Database.database().reference().child("Users").child(uid!).child("My_Temperatures").observe(.childAdded) { (snapshot) in
                        if let value = snapshot.value as? [String : Any] {
                            let user = TemperatureStructure()
                            user.temp = value["tempTaken"] as? String ?? "Not Found"
                            user.locat = value["locationTaken"] as? String ?? "Not Found"
                            user.dayy = value["dayTaken"] as? String ?? "Not Found"
                            user.time = value["timeTaken"] as? String ?? "Not Found"
                            user.postId = value["postID"] as? String ?? "Not Found"
                            self.temperatures.append(user)
                        }
                        if self.temperatures.count > 0 {
                            print(self.temperatures)
                            self.temperatures.reverse()
                            print(self.temperatures.count)
                            self.tempLabel!.text! = self.temperatures[0].temp!
                            self.hideIndicator()
                        } else {
                            self.tempLabel!.text! = " "
                            self.hideIndicator()
                        }
                        self.hideIndicator()
                    }
                    self.hideIndicator()
                } else {
                    self.tempLabel!.text! = " "
                    self.hideIndicator()
                }
            })
        })
    }

}
