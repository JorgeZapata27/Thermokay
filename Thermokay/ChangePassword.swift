//
//  ChangePassword.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/16/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChangePassword: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var oldPassword : UITextField!
    @IBOutlet var newPassword : UITextField!
    @IBOutlet var confirmPassword : UITextField!
    
    @IBOutlet var mainButton : UIButton!
    
    @IBOutlet var navView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainButton.layer.shadowColor = UIColor.black.cgColor
        self.mainButton.layer.shadowOpacity = 0.1
        self.mainButton.layer.shadowOffset = .zero
        self.mainButton.layer.shadowRadius = 20
        self.mainButton.layer.cornerRadius = 20
        
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
    
    @IBAction func mainBtnPressed(_ sender: UIButton) {
        self.showIndicator(withTitle: "Loading", and: "")
        if self.newPassword.text == self.confirmPassword.text {
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("password").observe(.value, with: { (data) in
                let qqqq : String = (data.value as? String)!
                if qqqq == self.oldPassword.text {
                    Auth.auth().currentUser?.updatePassword(to: self.confirmPassword.text!) { (error) in
                        if error == nil {
                            self.hideIndicator()
                            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("password").setValue(self.confirmPassword!.text!)
                            let alert = UIAlertController(title: "Success", message: "Your Password Was Changed", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                                self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.hideIndicator()
                            self.createAlert(title: "Error", message: error!.localizedDescription)
                        }
                    }
                } else {
                    self.hideIndicator()
                    self.createAlert(title: "Error", message: "Incorrect Old Password")
                }
            })
        } else {
            self.hideIndicator()
            self.createAlert(title: "Error", message: "Non Matching Passwords")
        }
    }
    
    @IBAction func dismiisView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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

}
