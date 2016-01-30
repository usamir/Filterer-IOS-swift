//
//  ViewController.swift
//  Filterer
//
//  Created by Samir on 05/01/16.
//  Copyright © 2016 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    var filteredImage: UIImage?
    var originalImage: UIImage!
    
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        originalImage = imgView.image!
        
        compare.enabled = false
        
        let touchImage = UILongPressGestureRecognizer(target: self, action: Selector("handleTap:"))
        touchImage.delegate = self
        imgView.addGestureRecognizer(touchImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(sender: UILongPressGestureRecognizer? = nil) {
        
        if sender!.state == .Began {
            imgView.image = filteredImage
        } else  {
            imgView.image = originalImage
        }
        
        
    }
    
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["check this out", imgView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    

    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: {
            action in
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                self.showCamera()
            } else {
                self.showNoCamera()
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: {
            action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera()
    {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        self.presentViewController(cameraPicker, animated: true, completion: nil)
        
    }
    
    func showNoCamera () {
        let alertNoCamera = UIAlertController(title: "No Camera",
            message: "The device has no camera",
            preferredStyle: .Alert)
        let pressOK = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertNoCamera.addAction(pressOK)
        
        self.presentViewController(alertNoCamera, animated: true, completion: nil)
    }
    
    // dismiss after cancel action
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgView.image = image
        }
        
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        self.presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    func showSecondaryMenu() {
        
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, heightConstraint, leftConstraint, rightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }
    
    func hideSecondaryMenu() {
        
        UIView.animateWithDuration(0.4, animations: {
              self.secondaryMenu.alpha = 0
                } ) { completed in
                    if completed == true {
                        self.secondaryMenu.removeFromSuperview()
                    }
        }
    }
    
    @IBOutlet var redFilter: UIButton!
    @IBAction func applyRedFilter(sender: AnyObject) {

        let rgbaImage = RGBAImage(image: originalImage)!
        
        var totalRed = 0
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                
                let index = y * rgbaImage.width + x
                
                var pixel = rgbaImage.pixels[index]
                
                totalRed += Int(pixel.red)
            }
        }
        
        let pixelCount = rgbaImage.width * rgbaImage.height
        let avgRed = totalRed / pixelCount
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                
                var pixel = rgbaImage.pixels[index]
                let redDelta = Int(pixel.red) - avgRed
                
                var modifier = 1 * 4 * (Double(y) / Double(rgbaImage.height))
                if (Int(pixel.red) < avgRed) {
                    modifier = 1
                }
                
                pixel.red = UInt8(max(min(255, Int(round(Double(avgRed) + modifier * Double(redDelta)))), 0))
                rgbaImage.pixels[index] = pixel
            
            }
        }
        
        filteredImage = rgbaImage.toUIImage()!
        compare.enabled = true
        imgView.image = filteredImage
    }
    
    @IBOutlet var compare: UIButton!
    @IBAction func onCompare(sender: AnyObject) {
        if compare.selected {
            imgView.image = filteredImage
            compare.selected = false
        } else {
            imgView.image = originalImage
            compare.selected = true
        }
        
    }
    
    @IBOutlet var greenFilter: UIButton!
    
    @IBAction func applyGreenFilter(sender: AnyObject) {
  
        let rgbaImage = RGBAImage(image: originalImage)!
        
        var totalGreen = 0
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                
                let index = y * rgbaImage.width + x
                
                var pixel = rgbaImage.pixels[index]
                
                totalGreen += Int(pixel.green)
            }
        }
        
        let pixelCount = rgbaImage.width * rgbaImage.height
        let avgGreen = totalGreen / pixelCount
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                
                var pixel = rgbaImage.pixels[index]
                let greenDelta = Int(pixel.green) - avgGreen
                
                var modifier = 1 * 4 * (Double(y) / Double(rgbaImage.height))
                if (Int(pixel.green) < avgGreen) {
                    modifier = 1
                }
                
                pixel.red = UInt8(max(min(255, Int(round(Double(avgGreen) + modifier * Double(greenDelta)))), 0))
                rgbaImage.pixels[index] = pixel
                
            }
        }
        
        filteredImage = rgbaImage.toUIImage()!
        compare.enabled = true
        imgView.image = filteredImage
    }
    
    @IBOutlet var blueFilter: UIButton!
    
    @IBAction func applyBlueFilter(sender: AnyObject) {

        let rgbaImage = RGBAImage(image: originalImage)!
        
        var totalBlue = 0
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                
                let index = y * rgbaImage.width + x
                
                var pixel = rgbaImage.pixels[index]
                
                totalBlue += Int(pixel.blue)
            }
        }
        
        let pixelCount = rgbaImage.width * rgbaImage.height
        let avgBlue = totalBlue / pixelCount
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                
                var pixel = rgbaImage.pixels[index]
                let blueDelta = Int(pixel.blue) - avgBlue
                
                var modifier = 1 * 4 * (Double(y) / Double(rgbaImage.height))
                if (Int(pixel.blue) < avgBlue) {
                    modifier = 1
                }
                
                pixel.red = UInt8(max(min(255, Int(round(Double(avgBlue) + modifier * Double(blueDelta)))), 0))
                rgbaImage.pixels[index] = pixel
                
            }
        }
        
        filteredImage = rgbaImage.toUIImage()!
        compare.enabled = true
        imgView.image = filteredImage
    }
}

