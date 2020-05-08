//
//  Settings.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/15/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import StoreKit
import Firebase
import FirebaseAuth

class Settings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var navView : UIView!
    @IBOutlet var tableView : UITableView!
    
    let imageNames = ["lock.open", "bell", "lock", "doc.plaintext", "square.and.arrow.up", "star", "xmark"]
    let labelNames = ["Change Password", "Notification Settings", "Privacy Policy", "Terms & Conditions", "Share App", "Rate App", "Log Out"]

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

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.myImage.image = UIImage(systemName: imageNames[indexPath.row])
        cell.myLabel.text = labelNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "ToChangePassword", sender: self)
        case 1:
            self.performSegue(withIdentifier: "ToNotiSettings", sender: self)
        case 2:
            self.performSegue(withIdentifier: "ToPolicy", sender: self)
        case 3:
            self.performSegue(withIdentifier: "ToTerms", sender: self)
        case 4:
            self.share()
        case 5:
            self.request()
        case 6:
            self.logout()
        default:
            print("HI")
        }
    }
    
    func logout() {
        let alertController = UIAlertController(title: "Are You Sure You Want To Logout?", message: "Please Select One!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            do {
                try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "SignIn")
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            } catch let error {
                print(error)
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func request() {
        SKStoreReviewController.requestReview()
        Database.database().reference().child("AppInfo").child("AppStoreLink").setValue("google.com")
    }
    
    func share() {
        Database.database().reference().child("AppInfo").child("AppStoreLink").observe(.value, with: { (data) in
            let qqqq : String = (data.value as? String)!
            let activityVC = UIActivityViewController(activityItems: ["\(qqqq)"], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        })
    }

}
