//
//  EditScan.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/19/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class EditScan: UIViewController {
    
    @IBOutlet var navView : UIView!
    
    @IBOutlet var textField : UITextField!
    
    @IBOutlet var mainButton : UIButton!
    @IBOutlet var setButton : UIButton!
    
    @IBOutlet var timeLabel : UILabel!
    
    var temperatureToPass = "0"
    var location = "Set"

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
        
        self.mainButton.layer.shadowColor = UIColor.black.cgColor
        self.mainButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.mainButton.layer.shadowRadius = 8
        self.mainButton.layer.shadowOpacity = 0.5
        self.mainButton.layer.cornerRadius = self.mainButton.frame.height / 2
        self.mainButton.clipsToBounds = true
        self.mainButton.layer.masksToBounds = false
        
        self.textField.text = temperatureToPass
        if self.textField.text == "Set" {
            self.textField.text = ""
        }
        
        self.setButton.contentHorizontalAlignment = .right
        self.setButton.setTitle(location, for: .normal)
        
        let date = Date.init(timeIntervalSinceNow: 86400)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: date)
        self.timeLabel.text = dateString

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController!.tabBar.isHidden = false
        self.location = GlobalVariables.location
        self.setButton.setTitle(location, for: .normal)
    }
    
    // Hides keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mainButtonTapped(_ sender: UIButton) {
        self.showIndicator(withTitle: "Loading", and: "")
        let date = Date.init(timeIntervalSinceNow: 86400)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: date)

        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: date)

    var nextString = self.textField!.text!

                                nextString.insert(".", at: nextString.index(nextString.startIndex, offsetBy: 2))
                                nextString.insert("°", at: nextString.index(nextString.endIndex, offsetBy: 0))
                                nextString.insert("F", at: nextString.index(nextString.endIndex, offsetBy: 0))

        
        if self.setButton.titleLabel?.text == "Set" {
            self.createAlert(title: "Error", message: "Please Set Your Location!")
        } else {
            // Firebase Update
            print(timeString)
            print(dateString.components(separatedBy: " ").first!)
            print(self.temperatureToPass)
            let mainReference = Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid)
            mainReference.child("takenTestFirst").setValue("true")

            let key = Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).childByAutoId().key
            let uid = Auth.auth().currentUser!.uid
            let values = [
                            "postID" : key!,
                            "timeTaken" : "\(timeString)",
                            "dayTaken" : "\(dateString.components(separatedBy: ", ").first!)",
                            "locationTaken" : "\(self.setButton.titleLabel!.text!)",
                            "tempTaken" : "\(nextString)"] as [String : Any]
                        let postFeed = ["\(key!)" : values]
            Database.database().reference().child("Users").child(uid).child("My_Temperatures").updateChildValues(postFeed)
            
            mainReference.child("lastTemperature").child("timeTaken").setValue(timeString)
            mainReference.child("lastTemperature").child("dayTaken").setValue(dateString.components(separatedBy: ", ").first!)
            mainReference.child("lastTemperature").child("locationTaken").setValue(self.setButton.titleLabel?.text)
            mainReference.child("lastTemperature").child("tempTaken").setValue("\(nextString)")
            let alert = UIAlertController(title: "Success", message: "Update Complete", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.popViewController(animated: true)
            }))
            self.hideIndicator()
            self.present(alert, animated: true, completion: nil)
        }
    }

}
