//
//  Inbox.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/17/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Inbox: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var navView : UIView!
    
    @IBOutlet var tableView : UITableView!
    
    let arrayImage = ["Austin", "Carmen", "Daniel", "David","Fird", "John", "Jonas", "Josh","Michael"]
    let arrayName = ["Austin's Group", "Carmen's Group", "Daniel's Group", "David's Group","Fird's Group", "John's Group", "Jonas's Group", "Josh's Group","Michael's Group"]
    
    var users = [InboxObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showIndicator(withTitle: "Loading", and: "")

        users.removeAll()
        tableView.reloadData()
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("MyInbox").observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                let user = InboxObject()
                user.id = value["groupId"] as? String ?? "Error"
                user.name = value["group-Name"] as? String ?? "Error"
                user.image = value["group-ImageUrl"] as? String ?? "Error"
                self.users.append(user)
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
        
        self.navView.layer.cornerRadius = 15
        self.navView.layer.shadowColor = UIColor.gray.cgColor
        self.navView.layer.shadowOffset = .zero
        self.navView.layer.shadowOpacity = 0.9
        self.navView.layer.shadowRadius = 15
        self.navView.layer.shadowPath = UIBezierPath(rect: self.navView.bounds).cgPath
        self.navView.layer.shouldRasterize = true
        self.navView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        self.hideIndicator()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismiisView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! InboxCell
        cell.profileImage.loadImageUsingCacheWithUrlString(users[indexPath.row].image!)
        cell.profileLabel.text = users[indexPath.row].name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accept = acceptAction(at: indexPath, withReferenceId: users[indexPath.row].id!)
        return UISwipeActionsConfiguration(actions: [accept])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func acceptAction(at indexPath: IndexPath, withReferenceId key : String) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Accept") { (action, view, completion) in

          // Steps To Success:
          // Breakpoint Here
          // 1. Add The Reference To My Groups With The Following
          //      - Group Name
          //      - Group Id
          //      - Group Image
          //      - Group Users
          
          Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("MyInbox").child(key).child("groupId").observe(.value, with: { (data) in
              let groupId : String = (data.value as? String)!
              print("GroupId : \(groupId)")
          })
          
          Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("MyInbox").child(key).child("group-Name").observe(.value, with: { (data) in
              let groupName : String = (data.value as? String)!
              print("GroupName : \(groupName)")
          })
          
          Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("MyInbox").child(key).child("group-ImageUrl").observe(.value, with: { (data) in
              let groupUrl : String = (data.value as? String)!
              print("GroupUrl : \(groupUrl)")
          })
          
          Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("MyInbox").child(key).child("Users").observe(.value, with: { (data) in
              let groupUsers : String = (data.value as? String)!
              print("GroupUsers : \(groupUsers)")
          })
            
            let reference1 = Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("My Groups").child("\(key)")
            
            print(reference1)
            
            // Get Key
            
          // Breakpoint Here
          // 2. Add The Reference To Other Users In My Group
          //      - Group Name
          //      - Group Id
          //      - Group Image
          //      - Group Users
            
          // Breakpoint Here
          // 3. Remove Reference From Inbox
//          Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("MyInbox").child(reference!).removeValue()
          //
          // 4. Dismiss Views And Return Nessasary Functions.
        }
        action.backgroundColor = UIColor.green
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
        }
        return action
    }
}
