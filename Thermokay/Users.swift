//
//  Users.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/21/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Users: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var searchBar : UISearchBar!
    
    var users = [UserObject]()
    var selectedUsers = [UserObject]()
    var isSearching = false
    var searchedUsers = [UserObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showIndicator(withTitle: "Loading", and: "")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        users.removeAll()
        tableView.reloadData()
        Database.database().reference().child("Users").observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                let user = UserObject()
                user.email = value["email"] as? String ?? "Error"
                user.name = value["name"] as? String ?? "Error"
                user.uid = value["uid"] as? String ?? "Error"
                self.users.append(user)
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
        self.hideIndicator()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isMovingFromParentViewController {
            GlobalVariables.selectedOnes = selectedUsers
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isSearching == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell", for: indexPath)
            cell.textLabel?.text = users[indexPath.row].name!
            cell.detailTextLabel?.text = users[indexPath.row].email!
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell", for: indexPath)
            cell.textLabel?.text = searchedUsers[indexPath.row].name!
            cell.detailTextLabel?.text = searchedUsers[indexPath.row].email!
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            return searchedUsers.count
        } else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                print("Hello")
            } else {
                
                self.selectedUsers.append(searchedUsers[indexPath.row])
                
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        } else {
            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                print("Hello")
            } else {
                
                self.selectedUsers.append(users[indexPath.row])
                GlobalVariables.selectedOnes = selectedUsers
                
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("hey")
        self.isSearching = true
        self.searchedUsers = users.filter({$0.name!.prefix(searchText.count) == searchText})
        self.tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        self.searchBar.text = ""
        self.tableView.reloadData()
    }
}
