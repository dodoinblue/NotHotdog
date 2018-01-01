//
//  ViewController.swift
//  NotHotdog
//
//  Created by charles.liu on 2017-12-31.
//  Copyright © 2017 Charles Liu. All rights reserved.
//

import UIKit
import CoreML
import Vision
import NVActivityIndicatorView

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable {
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UIScreen.main.bounds: \(UIScreen.main.bounds)")
        let _ = NVActivityIndicatorView(frame: UIScreen.main.bounds,
                                                            type: NVActivityIndicatorType(rawValue: 14)!)
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("imagePickerController didFinishPickingMediaWithInfo")
        let size = CGSize(width: 30, height: 30)
        startAnimating(size, message: "Processing...", type: NVActivityIndicatorType(rawValue: 14)!)
        imagePicker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            
            guard let ciimage = CIImage(image: pickedImage) else {
                fatalError("cannot convert to CIImage")
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                print("async task")
                self.detect(image: ciimage)
                self.stopAnimating()
            }
            print("after async task declaration")
        }
    }
    
    func detect(image: CIImage) {
        print("detect")
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("cannot load model")
        }

        let request = VNCoreMLRequest(model: model) {(request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("wrong classification observation format")
            }
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("\(error)")
        }
    }

    @IBAction func cameraButtonPressed(_ sender: Any) {
        print("camerabutton pressed")
        present(imagePicker, animated: true) {
            print("imagepicker completion")
        }
    }
    
}

