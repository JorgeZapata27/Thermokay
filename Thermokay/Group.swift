//
//  Group.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/15/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Group: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionView : UICollectionView!
    @IBOutlet var navView : UIView!

    let arrayImage = ["Austin", "Carmen", "Daniel", "David","Fird", "John", "Jonas", "Josh","Michael"]
    let arrayName = ["Austin's Group", "Carmen's Group", "Daniel's Group", "David's Group","Fird's Group", "John's Group", "Jonas's Group", "Josh's Group","Michael's Group"]
    
    var groups = [GroupObject]()
    var selected = 0

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SetupCollectionLayout()
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
        
        self.groups.removeAll()
        self.collectionView.reloadData()
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("My Groups").observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                let user = GroupObject()
                user.groupId = value["groupId"] as? String ?? "Error"
                user.groupName = value["group-Name"] as? String ?? "Error"
                user.groupImageUrl = value["group-ImageUrl"] as? String ?? "Error"
                self.groups.append(user)
                self.collectionView.reloadData()
            }
            self.collectionView.reloadData()
        }
        self.collectionView.reloadData()
        self.hideIndicator()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyGroupsCell", for: indexPath) as! MyGroupCell
        cell.imageView.loadImageUsingCacheWithUrlString(groups[indexPath.row].groupImageUrl!)
        cell.imageView.layer.cornerRadius = 15
        cell.labelText.text = groups[indexPath.row].groupName!
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selected = indexPath.row
        self.performSegue(withIdentifier: "ToGroup", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToGroup" {
            let secondController = segue.destination as! ThisGroup
            secondController.name = self.groups[selected].groupName!
            secondController.image = self.groups[selected].groupImageUrl!
            secondController.id = self.groups[selected].groupId!
        }
    }
    
    @IBAction func addGroup(_ sender: UIButton) {
        self.performSegue(withIdentifier: "ToNewGroupAdd", sender: self)
    }
    
    @IBAction func inbox(_ sender: UIButton) {
        self.performSegue(withIdentifier: "ToInbox", sender: self)
    }
}
