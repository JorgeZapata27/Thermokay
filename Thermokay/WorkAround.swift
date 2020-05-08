//
//  WorkAround.swift
//  Thermokay
//
//  Created by JJ Zapata on 4/26/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import AVFoundation

class WorkAround: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var scanView : UIView!
    
    var captureSession : AVCaptureSession!
    var previewLayer : AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
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

        // Do any additional setup after loading the view.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let first = metadataObjects.first {
            guard let readableObejct = first as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObejct.stringValue else { return }
            self.found(code: stringValue)
        } else {
            print("Not able to reaf the code!")
        }
    }
    
    func found(code: String) {
        print(code)
    }

}
