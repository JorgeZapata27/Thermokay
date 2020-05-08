//
//  FindFriend.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/26/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FindFriend: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var navView : UIView!
    @IBOutlet var textView : UIView!
    @IBOutlet var scanView : UIView!
    
    var captureSession : AVCaptureSession!
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    var temperatures = [TemperatureStructure]()
    
    var degres = "0"
    var userUid = ""

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
        
        self.textView.layer.shadowColor = UIColor.black.cgColor
        self.textView.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.textView.layer.shadowRadius = 8
        self.textView.layer.shadowOpacity = 0.1
        self.textView.layer.cornerRadius = self.textView.frame.height / 3
        self.textView.clipsToBounds = true
        self.textView.layer.masksToBounds = false
        
        self.scanView.layer.cornerRadius = 15
        self.scanView.clipsToBounds = false
        
        setupAVCapture()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToUserProfile" {
            self.showIndicator(withTitle: "Loading", and: "")
            
            let secondController = segue.destination as! Account
            
            Database.database().reference().child("Users").child("\(userUid)").child("name").observe(.value, with: { (data) in
                let name : String = (data.value as? String)!
                secondController.username = name
                
                print("userUid")
                print(self.userUid)
                print("userUid")

                Database.database().reference().child("Users").child("\(self.userUid)").child("profileImageURL").observe(.value, with: { (data) in
                    let image : String = (data.value as? String)!
                    secondController.image = image
                    
                    Database.database().reference().child("Users").child("\(self.userUid)").child("barcodeImage").observe(.value, with: { (data) in
                        let brcode : String = (data.value as? String)!
                        secondController.barcode = brcode

                        Database.database().reference().child("Users").child("\(self.userUid)").child("takenTestFirst").observe(.value, with: { (data) in
                            let boolean : String = (data.value as? String)!
                            print(boolean)
                            if boolean == "true" {
                                self.temperatures.removeAll()
                                Database.database().reference().child("Users").child(self.userUid).child("My_Temperatures").observe(.childAdded) { (snapshot) in
                                    if let value = snapshot.value as? [String : Any] {
                                        let user = TemperatureStructure()
                                        user.temp = value["tempTaken"] as? String ?? "Not Found"
                                        user.locat = value["locationTaken"] as? String ?? "Not Found"
                                        user.dayy = value["dayTaken"] as? String ?? "Not Found"
                                        user.time = value["timeTaken"] as? String ?? "Not Found"
                                        user.postId = value["postID"] as? String ?? "Not Found"
                                        self.temperatures.append(user)
                                    }
                                    
                                    print(self.temperatures)
                                    self.temperatures.reverse()
                                    print(self.temperatures.count)
                                    secondController.temperature = self.temperatures[0].temp!
                                    self.hideIndicator()
                                }
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
    
    
     func setupAVCapture(){
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.setupCaptureSession()
            
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.setupCaptureSession()
                    }
                }
            
            case .denied: // The user has previously denied access.
                print("ERROR")
                return

            case .restricted: // The user can't grant access due to restrictions.
                print("ERROR")
                return
        }
         
         
    }
    
    func setupCaptureSession() {
        self.captureSession = AVCaptureSession()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                print("Your device is not aplicable for video processing.")
                return
            }
            let videoInput : AVCaptureDeviceInput
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                print("Your device cannot give video input")
                return
            }
            if (self.captureSession.canAddInput(videoInput)) {
                self.captureSession.addInput(videoInput)
            } else {
                print("Your device can not add input in the capture session.")
                return
            }
            let metadataOutput = AVCaptureMetadataOutput()
            if (self.captureSession.canAddOutput(metadataOutput)) {
                self.captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
            } else {
                return
            }
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer.frame = self.scanView.layer.bounds
            self.previewLayer.videoGravity = .resizeAspectFill
            self.scanView.layer.addSublayer(self.previewLayer)
            print("Running")
            self.captureSession.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let first = metadataObjects.first {
            guard let readableObejct = first as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObejct.stringValue else { return }
            self.found(code: stringValue)
            self.captureSession.stopRunning()
            self.userUid = stringValue
            let key = Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("My_Friends").childByAutoId().key
            let uid = Auth.auth().currentUser!.uid
            let values = [
                "uid" : userUid] as [String : Any]
            let postFeed = ["\(key!)" : values]
            Database.database().reference().child("Users").child(uid).child("My_Friends").updateChildValues(postFeed)
            self.performSegue(withIdentifier: "ToUserProfile", sender: self)
        } else {
            print("Not able to reaf the code!")
        }
    }
    
    func found(code: String) {
        print(code)
    }
}
