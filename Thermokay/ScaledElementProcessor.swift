//
//  ScaledElementProcessor.swift
//  Thermokay
//
//  Created by JJ Zapata on 5/1/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import Firebase
import Foundation

class ScaledElementProcessor {
    
    let vision = Vision.vision()
    var textRecognizer : VisionTextRecognizer!
    
    init() {
        textRecognizer = vision.onDeviceTextRecognizer()
    }
    
    func process(in imageView: UIImage, callback: @escaping (_ text: String) -> Void) {
        let visionImage = VisionImage(image: imageView)
        textRecognizer.process(visionImage) { (result, error) in
            guard error == nil, let result = result, !result.text.isEmpty else {
                callback("")
                return
            }
            callback(result.text)
        }
    }
}
