//
//  NotificationSettings.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/16/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

class NotificationSettings: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var navView : UIView!
    @IBOutlet var mainView : UIView!
    @IBOutlet var textFieldView : UIView!
    
    @IBOutlet var mySwitch : UISwitch!
    
    @IBOutlet var timeTxtField : UITextField!
    
    @IBOutlet var mainButton : UIButton!
    
    let timePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showIndicator(withTitle: "Loading", and: "")
        
        self.mainView.layer.shadowColor = UIColor.black.cgColor
        self.mainView.layer.shadowOpacity = 0.1
        self.mainView.layer.shadowOffset = .zero
        self.mainView.layer.shadowRadius = 15
        self.mainView.layer.cornerRadius = 15
        
        self.textFieldView.layer.shadowColor = UIColor.black.cgColor
        self.textFieldView.layer.shadowOpacity = 0.1
        self.textFieldView.layer.shadowOffset = .zero
        self.textFieldView.layer.shadowRadius = 15
        self.textFieldView.layer.cornerRadius = 15
        
        self.navView.layer.cornerRadius = 15
        self.navView.layer.shadowColor = UIColor.gray.cgColor
        self.navView.layer.shadowOffset = .zero
        self.navView.layer.shadowOpacity = 0.9
        self.navView.layer.shadowRadius = 15
        self.navView.layer.shadowPath = UIBezierPath(rect: self.navView.bounds).cgPath
        self.navView.layer.shouldRasterize = true
        self.navView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        self.mainButton.layer.shadowColor = UIColor.black.cgColor
        self.mainButton.layer.shadowOpacity = 0.1
        self.mainButton.layer.shadowOffset = .zero
        self.mainButton.layer.shadowRadius = 20
        self.mainButton.layer.cornerRadius = 20
        
        self.mySwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        
        toolbar.setItems([doneButton], animated: true)
        
        timePicker.datePickerMode = .time

        timeTxtField.inputView = timePicker
        timeTxtField.inputAccessoryView = toolbar
        
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("notificationAlarm").observe(.value, with: { (data) in
            let qqqq : String = (data.value as? String)!
            if qqqq == "false" {
                self.mySwitch.isOn = false
            } else {
                self.mySwitch.isOn = true
            }
        })
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("notificationTime").observe(.value, with: { (data) in
            let qqqq : String = (data.value as? String)!
            self.timeTxtField.text = qqqq
        })
        
        self.hideIndicator()

        // Do any additional setup after loading the view.
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        timeTxtField.text = formatter.string(from: timePicker.date)
        self.view.endEditing(true)
    }

    @IBAction func mainBtnPressed(_ sender: UIButton) {
        self.showIndicator(withTitle: "Loading", and: "")
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("notificationTime").setValue(self.timeTxtField.text)
        if self.mySwitch.isOn {

        var timeString = self.timeTxtField.text

        let minuteString = String(timeString!.suffix(2))
        let minute = Int(minuteString) ?? 0
        timeString!.removeLast()
        timeString!.removeLast()
        timeString!.removeLast()
        let hour = Int(timeString!) ?? 0

         let center = UNUserNotificationCenter.current()

            let content = UNMutableNotificationContent()
            content.title = "Scan your Temperature!"
            content.body = "It's time for you to scan your Temperature!"
            content.categoryIdentifier = "alarm"
            content.userInfo = ["customData": "none"]
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
               center.add(request)

            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("notificationAlarm").setValue("true")

        } else {

         let center = UNUserNotificationCenter.current()
        
        center.removeAllPendingNotificationRequests()

            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("notificationAlarm").setValue("false")
        }
        self.hideIndicator()
        let alert = UIAlertController(title: "Success", message: "Your Notification Schedule Has Changed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
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
