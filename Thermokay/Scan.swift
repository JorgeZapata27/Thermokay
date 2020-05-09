//
//  Scan.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/16/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class Scan: UIViewController, AVCapturePhotoCaptureDelegate{
    
    @IBOutlet var navView : UIView!
    @IBOutlet var textView : UIView!
    @IBOutlet var scanView : UIView!
    @IBOutlet var rotateView : UIView!
    
    @IBOutlet var mainButton : UIButton!
    
    @IBOutlet var imageToShow : UIImageView!
    @IBOutlet var gifIV : UIImageView!

    //Camera Capture requiered properties
    var captureSession : AVCaptureSession?
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    var frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    var capturePhotoOutput : AVCapturePhotoOutput?
    var degres = "0"
    var isRoateted = false
    
    let processor = ScaledElementProcessor()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isRoateted == false {
            self.mainButton.setTitle("Okay", for: .normal)
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                self.rotateView.alpha = 1
                self.scanView.alpha = 0
            }, completion: nil)
        } else {
            self.mainButton.setTitle("Scan", for: .normal)
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                self.rotateView.alpha = 0
                self.scanView.alpha = 1
            }, completion: nil)
        }
        
        self.mainButton.layer.borderColor = UIColor.white.cgColor
        self.mainButton.layer.borderWidth = 2
        
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
        
        self.mainButton.layer.shadowColor = UIColor.black.cgColor
        self.mainButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.mainButton.layer.shadowRadius = 8
        self.mainButton.layer.shadowOpacity = 0.5
        self.mainButton.layer.cornerRadius = self.mainButton.frame.height / 2
        self.mainButton.clipsToBounds = true
        self.mainButton.layer.masksToBounds = false
        
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
//            let frame : CGRect = self.scanView.layer.bounds
//            videoPreviewLayer?.frame = frame
            videoPreviewLayer?.bounds = self.scanView.bounds
//            videoPreviewLayer.videoOrientation = .right
            scanView.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
        } catch {
            print("error-jz")
        }
        
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true
        captureSession?.addOutput(capturePhotoOutput!)

        self.gifIV.loadGif(name: "rotate")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func alertView(_ sender: UIButton) {
        let titleText = self.mainButton.titleLabel?.text!
        if titleText == "Scan" {
            guard let capturePhotoOutput = self.capturePhotoOutput else { return }
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isHighResolutionPhotoEnabled = true
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        } else if titleText == "Next" {
            // Run Tesseract
            self.performSegue(withIdentifier: "toNextOfScanning111", sender: self)
        } else {
            print("Rotate")
            self.mainButton.setTitle("Scan", for: .normal)
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                self.rotateView.alpha = 0
                self.scanView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNextOfScanning111" {
            let secondController =  segue.destination as! EditScan
            secondController.temperatureToPass = degres
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard  error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("error-jz")
                return
        }
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else { return }
        let capturedImage = UIImage.init(data: imageData, scale: 1.0)
//        if let image = UIImage(named: "987") {
        if let image = capturedImage {
//            self.captureSession?.stopRunning()
            self.scanView.isHidden = true
            self.imageToShow.isHidden = false
            self.imageToShow.image = image
            
            guard
                let landscapeImage = imageToShow.image,
                let landscapeCGImage = landscapeImage.cgImage
            else { return }
            let portraitImage = UIImage(cgImage: landscapeCGImage, scale: landscapeImage.scale, orientation: .right)
            imageToShow.image = portraitImage
            print("Start")
            
            var processImage : UIImage?
            
            if let newimage = image.cgImage {
                processImage = UIImage(cgImage: newimage, scale: UIScreen.main.scale, orientation: .right)
                processor.process(in: processImage!) { (text) in
                                print(text)
                let actual = text.prefix(3)
                    self.degres = String(actual)
                                
                                var nextString = text.westernArabicNumeralsOnly
                //
                //                let testAlert = UIAlertController(title: "Testing", message: text, preferredStyle: .alert)
                //                testAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                //                self.present(testAlert, animated: true, completion: nil)

                    if nextString.count > 2 {
                        
                        var newString = nextString
                        var anotherString = nextString
                        
                        anotherString.insert(".", at: nextString.index(nextString.startIndex, offsetBy: 2))
                        
                        newString.insert(".", at: nextString.index(nextString.startIndex, offsetBy: 2))
                        newString.insert("°", at: nextString.index(nextString.endIndex, offsetBy: 0))
                        newString.insert("F", at: nextString.index(nextString.endIndex, offsetBy: 0))

                                    let alert = UIAlertController(title: "Is \(anotherString)°F Your Temperature?", message: "", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                                        self.degres = "Set"
                                        self.performSegue(withIdentifier: "toNextOfScanning111", sender: self)
                                    }))
                                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                        self.degres = "\(nextString)"
                                        self.performSegue(withIdentifier: "toNextOfScanning111", sender: self)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                } else {
                                    let alert = UIAlertController(title: "Error", message: "Unable To Read Your Temperature", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Scan Again", style: .default, handler: { (action) in
                                        self.imageToShow.isHidden = true
                                        self.scanView.isHidden = false
                                    }))
                                    alert.addAction(UIAlertAction(title: "Set Manually", style: .cancel, handler: { (action) in
                                        self.degres = "Set"
                                        self.performSegue(withIdentifier: "toNextOfScanning111", sender: self)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
            }
        }
    }
}

extension String {
    var westernArabicNumeralsOnly: String {
        let pattern = UnicodeScalar("0")..."9"
        return String(unicodeScalars
            .flatMap { pattern ~= $0 ? Character($0) : nil })
    }
}

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
