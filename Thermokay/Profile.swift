//
//  Profile.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/15/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Profile: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var editBtn : UIButton!
    @IBOutlet var shareButton : UIButton!
    
    @IBOutlet var navView : UIView!
    @IBOutlet var mainView : UIView!
    @IBOutlet var bigView : UIView!
    
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var emailLabel : UILabel!
    
    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var barcodeImage : UIImageView!
    
    var imagePicker : UIImagePickerController!
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
        
        self.editBtn.layer.shadowColor = UIColor.black.cgColor
        self.editBtn.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.editBtn.layer.shadowRadius = 15
        self.editBtn.layer.shadowOpacity = 0.3
        self.editBtn.layer.cornerRadius = self.editBtn.frame.height / 2
        self.editBtn.clipsToBounds = true
        self.editBtn.layer.masksToBounds = false

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showIndicator(withTitle: "Loading", and: "")
        
        Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("name").observe(.value, with: { (data) in
            let name : String = (data.value as? String)!
            self.nameLabel.text = name
            
            Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("email").observe(.value, with: { (data) in
                let email : String = (data.value as? String)!
                self.emailLabel.text = email
                
                Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("profileImageURL").observe(.value, with: { (data) in
                    let profileImageURL : String = (data.value as? String)!
                    self.profileImageView.loadImageUsingCacheWithUrlString(profileImageURL)
                    
                    Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("barcodeImage").observe(.value, with: { (data) in
                        let backcodeImageUrl : String = (data.value as? String)!
                        self.barcodeImage.loadImageUsingCacheWithUrlString(backcodeImageUrl)
                        
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
//                                            self.tempLabel!.text! = self.temperatures[0].temp!
                                            self.hideIndicator()
                                        } else {
//                                            self.tempLabel!.text! = " "
                                            self.hideIndicator()
                                        }
                                        self.hideIndicator()
                                    }
                                    self.hideIndicator()
                            } else {
//                                self.tempLabel.text = ""
                                self.hideIndicator()
                            }
                        })
                    })
                })
            })
        })
    }
    
    @IBAction func openImagePickerController(_ sender: UIButton) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func sharePressed(_ sender: UIButton) {
        Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("takenTestFirst").observe(.value, with: { (data) in
            let boolean : String = (data.value as? String)!
            if boolean == "true" {
                Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("lastTemperature").child("tempTaken").observe(.value, with: { (data) in
                    let tempTaken : String = (data.value as? String)!
                    let activityVC = UIActivityViewController(activityItems: ["My temperature is \(tempTaken). Start using THERMOKAY today!"], applicationActivities: nil)
                    activityVC.popoverPresentationController?.sourceView = self.view
                    self.present(activityVC, animated: true, completion: nil)
                })
            } else {
                let activityVC = UIActivityViewController(activityItems: ["Hey! Start using THERMOKAY today!"], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = editedImage
            let storageRef = Storage.storage().reference(forURL: "gs://thermokay-cabef.appspot.com")
              let storageProfileRef = storageRef.child("Profile").child(Auth.auth().currentUser!.uid)
              let metadata = StorageMetadata()
            guard let imageData = editedImage.jpegData(compressionQuality: 0.75) else { return }
              metadata.contentType = "image/jpg"
              storageProfileRef.putData(imageData, metadata: metadata) { (storageMetadata, error) in
                  if error != nil {
                      print(error!.localizedDescription)
                      return
                  }
                  storageProfileRef.downloadURL { (url, error) in
                      if let metaImageURL = url?.absoluteString {
                          print(metaImageURL)
                        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("profileImageURL").setValue(metaImageURL)
                    }
                  }
              }
              self.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImageView.image = originalImage
            let storageRef = Storage.storage().reference(forURL: "gs://thermokay-cabef.appspot.com")
              let storageProfileRef = storageRef.child("Profile").child(Auth.auth().currentUser!.uid)
              let metadata = StorageMetadata()
            guard let imageData = originalImage.jpegData(compressionQuality: 0.75) else { return }
              metadata.contentType = "image/jpg"
              storageProfileRef.putData(imageData, metadata: metadata) { (storageMetadata, error) in
                  if error != nil {
                      print(error!.localizedDescription)
                      return
                  }
                  storageProfileRef.downloadURL { (url, error) in
                      if let metaImageURL = url?.absoluteString {
                          print(metaImageURL)
                        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("profileImageURL").setValue(metaImageURL)
                    }
                  }
              }
              self.dismiss(animated: true, completion: nil)
        }
    }

}
