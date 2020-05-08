//
//  ForgotPassword.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/15/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ForgotPassword: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var navView : UIView!
    
    @IBOutlet var email : UITextField!
    
    @IBOutlet var signUpButton : UIButton!

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
        
        self.email.attributedPlaceholder = NSAttributedString(string:"Write Here...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        self.signUpButton.layer.shadowColor = UIColor.black.cgColor
        self.signUpButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.signUpButton.layer.shadowRadius = 8
        self.signUpButton.layer.shadowOpacity = 0.5
        self.signUpButton.layer.cornerRadius = self.signUpButton.frame.height / 2
        self.signUpButton.clipsToBounds = true
        self.signUpButton.layer.masksToBounds = false

        // Do any additional setup after loading the view.
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SignIn")
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func mainBtnPressed(_ sender: UIButton) {
        self.showIndicator(withTitle: "Loading", and: "")
        Auth.auth().sendPasswordReset(withEmail: self.email!.text!) { error in
            if error == nil {
                self.hideIndicator()
                let alert = UIAlertController(title: "Sent!", message: "Your Message Has Been Sent To Your Email", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "SignIn")
                    controller.modalPresentationStyle = .overFullScreen
                    self.present(controller, animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.createAlert(title: "Error", message: error!.localizedDescription)
            }
        }
    }

}
