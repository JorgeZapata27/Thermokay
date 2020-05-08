//
//  Calendar.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/15/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class Calendar: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var navView : UIView!
    @IBOutlet var mainView : UIView!
    
    @IBOutlet var day1 : UILabel!
    @IBOutlet var day2 : UILabel!
    @IBOutlet var today : UILabel!
    @IBOutlet var day3 : UILabel!
    @IBOutlet var day4 : UILabel!
    
    @IBOutlet var m1 : UILabel!
    @IBOutlet var m2 : UILabel!
    @IBOutlet var td : UILabel!
    @IBOutlet var p1 : UILabel!
    @IBOutlet var p2 : UILabel!
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var month : UILabel!
    
    var temperatures = [TemperatureStructure]()
    var friends = [FriendObject]()
    var friendTemps = [TemperatureStructure]()
    var mainFriendTemps = [TemperatureStructure]()
    
    var dayAbb = ""
    var selection = "me"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.string(from: date)
        print(dayOfWeekString)
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let day = calendar.date(byAdding: .day, value: 1, to: NSDate() as Date, options: [])!
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd"
        let str = dateFormatter1.string(from: day)
        print(str)
        
        let TwoMoreDay = calendar.date(byAdding: .day, value: 2, to: NSDate() as Date, options: [])!
        let dateFormatter2More = DateFormatter()
        dateFormatter2More.dateFormat = "dd"
        let str2MoreDay = dateFormatter2More.string(from: TwoMoreDay)
        print(str2MoreDay)
        
        let BackOneDay = calendar.date(byAdding: .day, value: -1, to: NSDate() as Date, options: [])!
        let dateFormatterMinus1 = DateFormatter()
        dateFormatterMinus1.dateFormat = "dd"
        let strMinusOne = dateFormatterMinus1.string(from: BackOneDay)
        print(strMinusOne)
        
        let BackTwoDay = calendar.date(byAdding: .day, value: -2, to: NSDate() as Date, options: [])!
        let dateFormatterMinus2 = DateFormatter()
        dateFormatterMinus2.dateFormat = "dd"
        let strMinusTwo = dateFormatterMinus2.string(from: BackTwoDay)
        print(strMinusTwo)
        
        let taday = calendar.date(byAdding: .day, value: 0, to: NSDate() as Date, options: [])!
        let todayFormat = DateFormatter()
        todayFormat.dateFormat = "dd"
        let todayformattting = todayFormat.string(from: taday)
        print(todayformattting)
        
        let one = calendar.date(byAdding: .day, value: 0, to: NSDate() as Date, options: [])!
        let two = DateFormatter()
        two.dateFormat = "MM"
        let three = two.string(from: one)
        print(three)
        
        self.m2.text = strMinusTwo
        self.m1.text = strMinusOne
        self.td.text = todayformattting
        self.p1.text = str
        self.p2.text = str2MoreDay
        
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
        self.mainView.layer.shadowRadius = 15
        self.mainView.layer.cornerRadius = 15
        
        switch three {
        case "01":
            self.month.text = "Jan"
        case "02":
            self.month.text = "Feb"
        case "03":
            self.month.text = "Mar"
        case "04":
            self.month.text = "Apr"
        case "05":
            self.month.text = "May"
        case "06":
            self.month.text = "Jun"
        case "07":
            self.month.text = "Jul"
        case "08":
            self.month.text = "Aug"
        case "09":
            self.month.text = "Sep"
        case "10":
            self.month.text = "Oct"
        case "11":
            self.month.text = "Nov"
        case "12":
            self.month.text = "Dec"
        default:
            self.month.text = "Error"
        }
        
        switch dayOfWeekString {
        case "Sunday":
            day1.text = "Fri"
            day2.text = "Sat"
            today.text = "Sun"
            day3.text = "Mon"
            day4.text = "Tue"
        case "Monday":
            day1.text = "Sat"
            day2.text = "Sun"
            today.text = "Mon"
            day3.text = "Tue"
            day4.text = "Wed"
        case "Tuesday":
            day1.text = "Sun"
            day2.text = "Mon"
            today.text = "Tue"
            day3.text = "Wed"
            day4.text = "Thu"
        case "Wednesday":
            day1.text = "Mon"
            day2.text = "Tue"
            today.text = "Wed"
            day3.text = "Thu"
            day4.text = "Fri"
        case "Thursday":
            day1.text = "Tue"
            day2.text = "Wed"
            today.text = "Thu"
            day3.text = "Fri"
            day4.text = "Sat"
        case "Friday":
            day1.text = "Wed"
            day2.text = "Thu"
            today.text = "Fri"
            day3.text = "Sat"
            day4.text = "Sun"
        case "Saturday":
            day1.text = "Thu"
            day2.text = "Fri"
            today.text = "Sat"
            day3.text = "Sun"
            day4.text = "Mon"
        default:
            print("Hello")
        }

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selection == "me" {
            return self.temperatures.count
        } else {
            return self.friendTemps.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.selection == "me" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendarReuse", for: indexPath) as! CalendarCell
            
            cell.mainView.layer.shadowColor = UIColor.black.cgColor
            cell.mainView.layer.shadowOpacity = 0.1
            cell.mainView.layer.shadowOffset = .zero
            cell.mainView.layer.shadowRadius = 15
            cell.mainView.layer.cornerRadius = 15
            
            cell.day.text = temperatures[indexPath.row].dayy!
            cell.time.text = temperatures[indexPath.row].time!
            cell.loca.text = temperatures[indexPath.row].locat!
            cell.temp.text = temperatures[indexPath.row].temp!
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendarReuse", for: indexPath) as! CalendarCell
            
            cell.mainView.layer.shadowColor = UIColor.black.cgColor
            cell.mainView.layer.shadowOpacity = 0.1
            cell.mainView.layer.shadowOffset = .zero
            cell.mainView.layer.shadowRadius = 15
            cell.mainView.layer.cornerRadius = 15
            
            cell.day.text = friendTemps[indexPath.row].dayy!
            cell.time.text = friendTemps[indexPath.row].time!
            cell.loca.text = friendTemps[indexPath.row].locat!
            cell.temp.text = friendTemps[indexPath.row].temp!
            cell.name.text = friendTemps[indexPath.row].user!
            
            return cell
        }
    }
    
    @IBAction func segmentedSwitched(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.selection = "me"
            self.tableView.reloadData()
        } else {
            self.selection = "myfriends"
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.friendTemps.removeAll()
        
        self.showIndicator(withTitle: "Loading", and: "")
        Database.database().reference().child("Users").child("\(Auth.auth().currentUser!.uid)").child("takenTestFirst").observe(.value, with: { (data) in
            let boolean : String = (data.value as? String)!
            if boolean == "true" {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.tableView.alpha = 1
                }, completion: nil)
                
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
                    print("HI")
                    print(self.temperatures)
                    self.temperatures.reverse()
                    self.tableView.reloadData()
                    print("HI")
                }
                
                //Gets Friends
                // Adds To Friends Array
                
                

                Database.database().reference().child("Users").child(uid!).child("My_Friends").observe(.childAdded) { (snapshot) in
                    if let value = snapshot.value as? [String : Any] {
                        let user = FriendObject()
                        user.uid = value["uid"] as? String ?? "Not Found"
                        self.friends.append(user)
                    }
                    self.friends.reverse()
                    self.tableView.reloadData()

                    

                    for user in self.friends {
                        Database.database().reference().child("Users").child("\(user.uid!)").child("takenTestFirst").observe(.value, with: { (data) in
                            let boolean : String = (data.value as? String)!
                            if boolean == "true" {
                                print("Advance")
                                // Get Temperature Model
                                let tempModel = TemperatureStructure()
                                Database.database().reference().child("Users").child(user.uid!).child("lastTemperature").child("dayTaken").observe(.value, with: { (dayTakenResult) in
                                    let dayTaken : String = (dayTakenResult.value as? String)!
                                    print(dayTaken)
                                    Database.database().reference().child("Users").child(user.uid!).child("lastTemperature").child("locationTaken").observe(.value, with: { (locationTakenResult) in
                                        let locationTaken : String = (locationTakenResult.value as? String)!
                                        print(locationTaken)
                                        Database.database().reference().child("Users").child(user.uid!).child("lastTemperature").child("tempTaken").observe(.value, with: { (tempTakenResult) in
                                            let tempTaken : String = (tempTakenResult.value as? String)!
                                            print(tempTaken)
                                            Database.database().reference().child("Users").child(user.uid!).child("lastTemperature").child("timeTaken").observe(.value, with: { (timeTakenResult) in
                                                let timeTaken : String = (timeTakenResult.value as? String)!
                                                Database.database().reference().child("Users").child(user.uid!).child("name").observe(.value, with: { (userTakenResult) in
                                                    let userTaken : String = (userTakenResult.value as? String)!
                                                    print(userTaken)
                                                    tempModel.dayy = dayTaken
                                                    tempModel.locat = locationTaken
                                                    tempModel.temp = tempTaken
                                                    tempModel.time = timeTaken
                                                    tempModel.user = userTaken
                                                    self.friendTemps.append(tempModel)
                                                    self.tableView.reloadData()
                                                })
                                            })
                                        })
                                    })
                                })
                            } else {
                                print("Null")
                            }
                        })

                        print(user.uid!)

                    }
                }
                
            } else {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.tableView.alpha = 0
                }, completion: nil)
            }
        })
        
        self.hideIndicator()
    }

}
