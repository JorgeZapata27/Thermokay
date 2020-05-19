//
//  SignUp.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/15/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUp: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var email : UITextField!
    @IBOutlet var password : UITextField!
    @IBOutlet var firstName : UITextField!
    @IBOutlet var lastName : UITextField!
    @IBOutlet var confirmPassword : UITextField!
    
    @IBOutlet var signUpButton : UIButton!
    
    @IBOutlet var navView : UIView!
    
    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var img : UIImageView!
    
    var imagePicker : UIImagePickerController!
    var filter : CIFilter!

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
        self.firstName.attributedPlaceholder = NSAttributedString(string:"Write Here...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.lastName.attributedPlaceholder = NSAttributedString(string:"Write Here...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.confirmPassword.attributedPlaceholder = NSAttributedString(string:"Write Here...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        self.signUpButton.layer.shadowColor = UIColor.black.cgColor
        self.signUpButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.signUpButton.layer.shadowRadius = 8
        self.signUpButton.layer.shadowOpacity = 0.5
        self.signUpButton.layer.cornerRadius = self.signUpButton.frame.height / 2
        self.signUpButton.clipsToBounds = true
        self.signUpButton.layer.masksToBounds = false

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
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
        if self.password.text == self.confirmPassword.text {
            guard let email = self.email.text else { return }
            guard let password = self.password.text else { return }
            let username = "\(firstName.text! + " " + lastName.text!)"
            guard let imageData = profileImageView.image?.jpegData(compressionQuality: 0.75) else { return }

            if email == "" || password == "" || username == "" {
                self.hideIndicator()
              let alertController = UIAlertController(title: "Error Creating Account", message: "Your Request Was Denied Because One Of Your Text Fields Was Left Clear", preferredStyle: .alert)
              let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
              alertController.addAction(okay)
              self.present(alertController, animated: true, completion: nil)
            } else {
              Auth.auth().createUser(withEmail: email, password: password) { (user1, error1) in
                if error1 == nil && user1 != nil {
                    var dict : Dictionary<String, Any> = [
                        "uid" : String(Auth.auth().currentUser!.uid),
                        "email" : String(Auth.auth().currentUser!.email!),
                        "profileImageURL" : "",
                        "name" : username,
                        "notificationTime" : "12:00",
                        "takenTestFirst" : "false",
                        "currentTemp" : "Unknown",
                        "password" : "\(password)",
                        "notificationAlarm" : "false",
                    ]
                    let storageRef = Storage.storage().reference()
                    let storageProfileRef = storageRef.child("Profiles").child("\(Auth.auth().currentUser!.uid)").child("ProfileImage")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpg"
                    storageProfileRef.putData(imageData, metadata: metadata) { (storageMetadata, error2) in
                        if error2 != nil {
                            print(error2!.localizedDescription)
                            print("ERROR")
                            print("ERROR")
                            print("ERROR")
                            print("ERROR")
                            return
                        }
                        storageProfileRef.downloadURL { (url, error3) in
                            if let metaImageURL = url?.absoluteString {
                                print(metaImageURL)
                                dict["profileImageURL"] = metaImageURL
                                Database.database().reference().child("Users").child((Auth.auth().currentUser!.uid)).updateChildValues(dict) { (error4, ref) in
                                    if error4 == nil {
                                        print("Hello")
                                        UserDefaults.standard.bool(forKey: "authBugBool")
                                        self.QRFunction()
                                    } else {
                                        print(error4!.localizedDescription)
                                    }
                                }
                            } else {
                                print(error3!.localizedDescription)
                            }
                        }
                    }
                } else {
                    self.hideIndicator()
                    let errorDesc = error1?.localizedDescription
                    let alertController = UIAlertController(title: "Error Creating Account", message: errorDesc, preferredStyle: .alert)
                    let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alertController.addAction(okay)
                    self.present(alertController, animated: true, completion: nil)
                }
              }
            }
        }
    }
    
    @IBAction func imageBtnPressed(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func QRFunction() {
        if let txtt = Auth.auth().currentUser?.uid {
            let metadataBarcode = StorageMetadata()
                let data = txtt.data(using: .ascii, allowLossyConversion: false)
                self.filter = CIFilter(name: "CIQRCodeGenerator")
                self.filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let image = UIImage(ciImage: self.filter.outputImage!.transformed(by: transform))
                self.img.image = image
                guard let barcodeData = image.jpegData(compressionQuality: 0.9) else { return }
                let storageRef = Storage.storage().reference()
            let storageProfileRef = storageRef.child("Profiles").child("\(Auth.auth().currentUser!.uid)").child("BarCode")
                metadataBarcode.contentType = "image/jpg"
        
                storageProfileRef.putData(barcodeData, metadata: metadataBarcode) { (NewstorageMetadata, newError) in
                    if newError != nil {
                        self.createAlert(title: "Error", message: newError!.localizedDescription)
                    }
                    storageProfileRef.downloadURL { (newUrl, AnotherError) in
                        if let barCodeURL = newUrl?.absoluteString {
                            print(barCodeURL)
                            Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("barcodeImage").setValue(barCodeURL)
                            self.hideIndicator()
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "TabbarController")
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                }
            }
    }
    
}
