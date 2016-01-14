//
//  ViewController.swift
//  Filterer
//
//  Created by Samir on 05/01/16.
//  Copyright © 2016 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var filteredImage: UIImage?
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var imageToggle: UIButton!
    
    @IBAction func onImageToggle(sender: UIButton) {
        if imageToggle.selected {
            let beforeImage = UIImage(named: "scenery")!
            imgView.image = beforeImage
            imageToggle.selected = false
        } else {
            imgView.image = filteredImage
            imageToggle.selected = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let image = UIImage(named: "scenery")!
        
        let rgbaImage = RGBAImage(image: image)!
        
        let avgRed = 107
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                
                var pixel = rgbaImage.pixels[index]
                
                let redDelta = Int(pixel.red) - avgRed
                
                var modifier = 1 + 4 * (Double(y) / Double(rgbaImage.height))
                if(Int(pixel.red) < avgRed) {
                    modifier = 1
                }
                
                pixel.red = UInt8(max(min(255,
                    Int(round(Double(avgRed) + modifier *
                    Double(redDelta)))), 0))
                rgbaImage.pixels[index] = pixel
            }
            
            filteredImage = rgbaImage.toUIImage()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

