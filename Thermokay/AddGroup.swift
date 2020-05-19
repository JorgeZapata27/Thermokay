//
//  AddGroupController.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/17/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AddGroup: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var navView : UIView!
    
    @IBOutlet var textFieldView : UIView!
    @IBOutlet var textFieldView1 : UIView!
    
    @IBOutlet var timeTxtField : UITextField!
    @IBOutlet var usersT : UITextField!
    
    @IBOutlet var mainButton : UIButton!
    
    @IBOutlet var profileImageView : UIImageView!
    
    var groupMembers = [UserObject]()

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
        
        self.textFieldView.layer.shadowColor = UIColor.black.cgColor
        self.textFieldView.layer.shadowOpacity = 0.1
        self.textFieldView.layer.shadowOffset = .zero
        self.textFieldView.layer.shadowRadius = 15
        self.textFieldView.layer.cornerRadius = 15
        
        self.textFieldView1.layer.shadowColor = UIColor.black.cgColor
        self.textFieldView1.layer.shadowOpacity = 0.1
        self.textFieldView1.layer.shadowOffset = .zero
        self.textFieldView1.layer.shadowRadius = 15
        self.textFieldView1.layer.cornerRadius = 15
        
        self.mainButton.layer.shadowColor = UIColor.black.cgColor
        self.mainButton.layer.shadowOpacity = 0.1
        self.mainButton.layer.shadowOffset = .zero
        self.mainButton.layer.shadowRadius = 20
        self.mainButton.layer.cornerRadius = 20
        
        self.usersT.delegate = self
        
        Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("profileImageURL").observe(.value, with: { (data) in
            let photoUrl : String = (data.value as? String)!
            self.profileImageView.loadImageUsingCacheWithUrlString(photoUrl)
            print("Hello")
        })

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isMovingFromParentViewController {
            GlobalVariables.selectedOnes.removeAll
        }
        
        self.groupMembers = GlobalVariables.selectedOnes
        
        for user in groupMembers {
            print("hello" + "\(user.name!)")
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usersT {
            usersT.resignFirstResponder()
            self.performSegue(withIdentifier: "ToPeopleAdd", sender: self)
        }
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func mainBtnPressed(_ sender: UIButton) {
        
        self.showIndicator(withTitle: "Loading", and: "")
        
        self.groupMembers = GlobalVariables.selectedOnes
        
        var username = ""
        
        let groupReference = Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("My Groups")
        
        Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("name").observe(.value, with: { (data) in
            let name : String = (data.value as? String)!
            username = name
        })
        
        let uid = Auth.auth().currentUser!.uid
                let ref = Database.database().reference()
                let storage = Storage.storage().reference()
                let key = ref.child("Posts").childByAutoId().key
                let data = self.profileImageView.image!.jpegData(compressionQuality: 0.9)
                let imageName = NSUUID().uuidString
                let Storageref = Storage.storage().reference().child("groupImages").child("\(imageName).jpg")
                if let uploadData = data {
                    Storageref.putData(uploadData, metadata: nil) { (metadata, error) in
                        if error != nil{
                            print("Failed to upload image:", error as Any)
                            
                            return
                        }
                        print(Storageref.downloadURL(completion: { (url, err) in
                            if err != nil{
                                print(err as Any)
                                return
                            }
                            print("Good")
                                if let imageUrl = url?.absoluteString {
                                    print(imageUrl)
                                                let values = [
                                                    "groupId" : key!,
                                                    "group-Name" : "\(self.timeTxtField!.text!)",
                                                    "group-ImageUrl" : imageUrl] as [String : Any]
                                                let postFeed = ["\(key!)" : values]

                                                let NewUservalues = [
                                                    "uid" : "\(Auth.auth().currentUser!.uid)"] as [String : Any]
                                                let newpostFeed = ["\(Auth.auth().currentUser!.uid)" : NewUservalues]
                                                
                                    groupReference.updateChildValues(postFeed)
                                    
                                    for user in self.groupMembers {
                                        Database.database().reference().child("Users").child(user.uid!).child("My Groups").updateChildValues(postFeed)
                                        Database.database().reference().child("Users").child(user.uid!).child("My Groups").child(key!).child("Users").updateChildValues(newpostFeed)
                                        Database.database().reference().child("Users").child(user.uid!).child("My Groups").child(key!).child("Users").child(user.uid!).child("uid").setValue(user.uid!)
                                        
                                        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("My Groups").child(key!).child("Users").setValue(newpostFeed)
                                        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("My Groups").child(key!).child("Users").child(user.uid!).child("uid").setValue(user.uid!)
                                    }
                                    
                                    let alertController = UIAlertController(title: "Success", message: "Your Account Was Added", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                                        GlobalVariables.selectedOnes.removeAll()
                                        self.navigationController?.popViewController(animated: true)
                                    }))
                                    self.hideIndicator()
                                    self.present(alertController, animated: true, completion: nil)
                                }
                        }))
                    }
            }
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

