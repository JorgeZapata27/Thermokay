//
//  ThisGroup.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/17/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ThisGroup: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let peopleName = ["Austin", "Carmen", "Daniel", "David","Fird"]
    let peoplePic = ["Austin", "Carmen", "Daniel", "David","Fird"]
    
    @IBOutlet var imageOfGroup : UIImageView!
    
    @IBOutlet var nameOfGroup : UILabel!
    
    @IBOutlet var navView : UIView!
    
    @IBOutlet var collectionView : UICollectionView!
    
    var name = ""
    var image = ""
    var id = ""
    
    var groups = [GroupObject]()
    var selected = 0
    var users = [UserObject]()

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

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SetupCollectionLayout()
        
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func SetupCollectionLayout() {
        self.showIndicator(withTitle: "Loading", and: "")
        let itemSize = UIScreen.main.bounds.width / 4
        let layout =     UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: itemSize-20, height: 120)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        self.collectionView.collectionViewLayout = layout
        
        self.imageOfGroup.loadImageUsingCacheWithUrlString(image)
        self.nameOfGroup!.text! = name
        
        self.users.removeAll()
        self.collectionView.reloadData()
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("My Groups").child(id).child("Users").observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                let user = UserObject()
                user.uid = value["uid"] as? String ?? "Error"
                self.users.append(user)
                self.collectionView.reloadData()
            }
            self.collectionView.reloadData()
        }
        self.collectionView.reloadData()
        self.hideIndicator()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyPersonCell", for: indexPath) as! MyGroupCell
        
        self.showIndicator(withTitle: "Loading", and: "")
        
        Database.database().reference().child("Users").child("\(users[indexPath.row].uid!)").child("name").observe(.value, with: { (data) in
            let name : String = (data.value as? String)!
            cell.labelText.text = name
        })
        
        Database.database().reference().child("Users").child("\(users[indexPath.row].uid!)").child("profileImageURL").observe(.value, with: { (data) in
            let image : String = (data.value as? String)!
            cell.imageView.loadImageUsingCacheWithUrlString(image)
        })
        
        cell.imageView.layer.cornerRadius = 15
        self.hideIndicator()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selected = indexPath.row
        self.performSegue(withIdentifier: "ToProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToProfile" {
            
            let secondController = segue.destination as! Account
            
            self.showIndicator(withTitle: "Loading", and: "")
            
            // Look For Name / Image / Temp
            
            Database.database().reference().child("Users").child("\(users[self.selected].uid!)").child("profileImageURL").observe(.value, with: { (data) in
                let image : String = (data.value as? String)!
                secondController.image = image
                
                Database.database().reference().child("Users").child("\(self.users[self.selected].uid!)").child("barcodeImage").observe(.value, with: { (data) in
                    let image : String = (data.value as? String)!
                    secondController.barcode = image
                    
                    Database.database().reference().child("Users").child("\(self.users[self.selected].uid!)").child("name").observe(.value, with: { (data) in
                        let name : String = (data.value as? String)!
                        secondController.username = name
                        
                        Database.database().reference().child("Users").child("\(self.users[self.selected].uid!)").child("takenTestFirst").observe(.value, with: { (data) in
                            let boolean : String = (data.value as? String)!
                            print(boolean)
                            if boolean == "true" {
                                Database.database().reference().child("Users").child("\(self.users[self.selected].uid!)").child("lastTemperature").child("tempTaken").observe(.value, with: { (data) in
                                    let temp : String = (data.value as? String)!
                                    secondController.temperature = temp
                                    self.hideIndicator()
                                })
                            } else {
                                secondController.temperature = " "
                                self.hideIndicator()
                            }
                        })
                    })
                })
            })
            
            //lastTemperature
        }
    }
    
    @IBAction func leaveGroup(_ sender: UIButton) {
        // Create An Alert
        self.showIndicator(withTitle: "Loading", and: "")
        let alert = UIAlertController(title: "Are You Sure You Want To Leave?", message: "You Must Be Reinvited To Join Again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("My Groups").child(self.id).removeValue()
            for user in self.users {
                Database.database().reference().child("Users").child(user.uid!).child("My Groups").child(self.id).child("Users").child(Auth.auth().currentUser!.uid).removeValue()
            }
            self.collectionView.reloadData()
            self.navigationController?.popViewController(animated: true)
        }))
        self.hideIndicator()
        self.present(alert, animated: true, completion: nil)
    }

}
