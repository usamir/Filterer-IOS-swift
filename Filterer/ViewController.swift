//
//  ViewController.swift
//  Filterer
//
//  Created by Samir on 05/01/16.
//  Copyright © 2016 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var isRed: Bool = false
    var isGreen: Bool = false
    var isBlue: Bool = false
    
    var filteredImage: UIImage?
    var originalImage: UIImage!
    
    var modifier: Double! = 5.0
    var imageProcessor: ImageProcessor?
    
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    
    @IBOutlet var labelOrigImage: UILabel!
    
    @IBOutlet var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        originalImage = imgView.image!
        
        compare.enabled = false
        
        filteredImgView.translatesAutoresizingMaskIntoConstraints = false
        
        let touchImage = UILongPressGestureRecognizer(target: self, action: Selector("handleTap:"))
        touchImage.delegate = self
        imgView.addGestureRecognizer(touchImage)
        
        imageProcessor = ImageProcessor()
        
        redFilter.setImage(getFilterIcon("Red"), forState: .Normal)
        greenFilter.setImage(getFilterIcon("Green"), forState: .Normal)
        blueFilter.setImage(getFilterIcon("Blue"), forState: .Normal)
        
        SliderMenu.translatesAutoresizingMaskIntoConstraints = false
        SliderMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        editButton.enabled = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getFilterIcon(apply: String) -> UIImage {
        let filterIcon = UIImage(named: "scenery")!
        let rgba = RGBAImage(image: filterIcon)!
        let filtered = imageProcessor!.predefined(rgba, filter: apply, intensity: modifier)
        return filtered.toUIImage()!
    }
    
    func handleTap(sender: UILongPressGestureRecognizer? = nil) {
        
        if sender!.state == .Began {
            showFilteredImageView()
            hideLabel()
        } else  {
            hideFilteredImageView()
            imgView.image = originalImage
            showLabel()
        }
    }
    
    func showLabel() {
        
        imgView.addSubview(labelOrigImage)
        
        let topConstraint = labelOrigImage.topAnchor.constraintEqualToAnchor(imgView.topAnchor)
        let heightConstraint = labelOrigImage.heightAnchor.constraintEqualToConstant(21)
        let centerConstraint = labelOrigImage.centerXAnchor.constraintEqualToAnchor(imgView.centerXAnchor)
        
        NSLayoutConstraint.activateConstraints([topConstraint, heightConstraint, centerConstraint])
        
        view.layoutIfNeeded()

    }
    
    func hideLabel() {
        labelOrigImage.removeFromSuperview()
    }
    
    @IBOutlet var filteredImgView: UIImageView!
    
    func showFilteredImageView() {
        
        if filterButton.selected {
            hideSecondaryMenu()
            filterButton.selected = false
        }
        
        if editButton.selected {
            editButton.selected = false
        }

        view.addSubview(filteredImgView)
        filteredImgView.image = filteredImage
        
        let bottomConstraint = filteredImgView.bottomAnchor.constraintEqualToAnchor(imgView.bottomAnchor)
        let topConstraint = filteredImgView.topAnchor.constraintEqualToAnchor(imgView.topAnchor)
        let leftConstraint = filteredImgView.leftAnchor.constraintEqualToAnchor(imgView.leftAnchor)
        let rightConstraint = filteredImgView.rightAnchor.constraintEqualToAnchor(imgView.rightAnchor)

        NSLayoutConstraint.activateConstraints([bottomConstraint, topConstraint, leftConstraint, rightConstraint])
        
        view.layoutIfNeeded()
        
        self.filteredImgView.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.filteredImgView.alpha = 1.0
        }
    }
    
    func hideFilteredImageView() {
        
        UIView.animateWithDuration(0.4, animations: {
            self.filteredImgView.alpha = 0
            } ) { completed in
                if completed == true {
                    self.filteredImgView.removeFromSuperview()
                }
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
            originalImage = image
            filteredImage = image
            compare.enabled = false
            imgView.image = originalImage
            hideFilteredImageView()
            editButton.enabled = false
            isRed = false
            isBlue = false
            isGreen = false
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
    
    @IBOutlet var compare: UIButton!
    @IBAction func onCompare(sender: AnyObject) {
        if compare.selected {
            showFilteredImageView()
            compare.selected = false
            hideLabel()
        } else {
            hideFilteredImageView()
            imgView.image = originalImage
            compare.selected = true
            showLabel()
        }
        
    }
    

    
    @IBOutlet var redFilter: UIButton!
    @IBAction func applyRedFilter(sender: AnyObject) {

        let rgbaImage = RGBAImage(image: originalImage)!

        let filtered = imageProcessor!.predefined(rgbaImage, filter: "Red", intensity: modifier)
        filteredImage = filtered.toUIImage()!
        
        compare.enabled = true
        hideLabel()
        editButton.enabled = true
        showFilteredImageView()
        
        isRed = true
        isBlue = false
        isGreen = false
    }
    
    @IBOutlet var greenFilter: UIButton!
    @IBAction func applyGreenFilter(sender: AnyObject) {
  
        let rgbaImage = RGBAImage(image: originalImage)!
        
        let filtered = imageProcessor!.predefined(rgbaImage, filter: "Green", intensity: modifier)
        filteredImage = filtered.toUIImage()!
        
        compare.enabled = true
        hideLabel()
        editButton.enabled = true
        showFilteredImageView()
        
        isRed = false
        isBlue = false
        isGreen = true
    }
    
    @IBOutlet var blueFilter: UIButton!
    @IBAction func applyBlueFilter(sender: AnyObject) {

        let rgbaImage = RGBAImage(image: originalImage)!
        
        let filtered = imageProcessor!.predefined(rgbaImage, filter: "Blue", intensity: modifier)
        filteredImage = filtered.toUIImage()!
        
        compare.enabled = true
        hideLabel()
        editButton.enabled = true
        showFilteredImageView()
        
        isRed = false
        isBlue = true
        isGreen = false
    }
    
    
    @IBOutlet var SliderMenu: UIView!
    func showSliderMenu() {
        
        view.addSubview(SliderMenu)
        
        let bottomConstraint = SliderMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let heightConstraint = SliderMenu.heightAnchor.constraintEqualToConstant(44)
        let leftConstraint = SliderMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = SliderMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, heightConstraint, leftConstraint, rightConstraint])
        
        view.layoutIfNeeded()
    }
    
    func hideSliderMenu() {
        self.SliderMenu.removeFromSuperview()
    }
    
    @IBAction func onEdit(sender: UIButton) {
        if (sender.selected) {
            hideSliderMenu()
            sender.selected = false
        } else {
            hideSecondaryMenu()
            showSliderMenu()
            sender.selected = true
        }
    }
    
    
    @IBAction func onSlide(sender: UISlider) {
        modifier = Double(sender.value)
        if isRed {
            applyRedFilter(sender)
        } else if isGreen {
            applyGreenFilter(sender)
        } else if isBlue {
            applyBlueFilter(sender)
        }
    }

}

