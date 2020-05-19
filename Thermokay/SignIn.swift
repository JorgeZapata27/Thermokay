//
//  ViewController.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/15/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import MBProgressHUD

class SignIn: UIViewController {
    
    @IBOutlet var email : UITextField!
    @IBOutlet var password : UITextField!
    
    @IBOutlet var signInButton : UIButton!
    @IBOutlet var forgotPassword : UIButton!
    
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
        
        self.email.attributedPlaceholder = NSAttributedString(string:"Write Here...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.password.attributedPlaceholder = NSAttributedString(string:"Write Here...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        self.signInButton.layer.shadowColor = UIColor.black.cgColor
        self.signInButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.signInButton.layer.shadowRadius = 8
        self.signInButton.layer.shadowOpacity = 0.5
        self.signInButton.layer.cornerRadius = self.signInButton.frame.height / 2
        self.signInButton.clipsToBounds = true
        self.signInButton.layer.masksToBounds = false
        
        self.forgotPassword.contentHorizontalAlignment = .right
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = Auth.auth().currentUser {
            print(user.uid)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "TabbarController")
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: false, completion: nil)
        }
        
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SignUp")
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ForgotPassword")
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
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
    
    @IBAction func mainBtnPressed(_ sender: UIButton) {
        self.showIndicator(withTitle: "Loading", and: "Hello")
        Auth.auth().signIn(withEmail: self.email!.text!, password: self.password!.text!) { (result, error) in
            if result != nil {
                self.hideIndicator()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "TabbarController")
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
                print("All Good. Logging in. ")
                UserDefaults.standard.bool(forKey: "authBugBool")
            } else {
                self.hideIndicator()
                if let myError = error?.localizedDescription {
                    print(myError)
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print("ERROR")
                }
            }
        }
    }

}

