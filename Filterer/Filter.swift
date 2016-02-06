//
//  Filter.swift
//  Filterer
//
//  Created by Samir on 04/02/16.
//  Copyright © 2016 UofT. All rights reserved.
//


import UIKit

struct Filter {
    var color = "Transparent"
    var isRed = false
    var isGreen = false
    var isBlue = false
    var isTransparent = false
    var contrast = 1.0
    
    init(contrast: Double) {
        self.contrast = contrast
    }
    
    init(color: String) {
        self.color = color
        
        switch color {
            case "Red":
                isRed = true
            case "Green":
                isGreen = true
            case "Blue":
                isBlue = true
            default:
                isTransparent = true
        }
    }
    
    func averageValues(image: RGBAImage) -> (red: Int, green: Int, blue: Int) {
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        
        for y in 0..<image.height {
            for x in 0..<image.width {
                let index = y * image.width + x
                let pixel = image.pixels[index]
                
                totalRed += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue += Int(pixel.blue)
            }
        }
        
        let pixelCount = image.width * image.height
        return (totalRed / pixelCount, totalGreen / pixelCount, totalBlue / pixelCount)
    }
    
    func filter(image: RGBAImage, intensity: Double) -> RGBAImage {
        let (avgRed, avgGreen, avgBlue) = averageValues(image)
        
        for y in 0..<image.height {
            for x in 0..<image.width {
                
                let index = y * image.width + x
                var pixel = image.pixels[index]
                
                // color boosting
                if isRed == true {
                    let redDelta = Int(pixel.red) - avgRed
                    pixel.red = UInt8(max(min(255, Int(round(Double(avgRed) + intensity * Double(redDelta)))), 0))
                } else if isGreen == true {
                    let greenDelta = Int(pixel.green) - avgGreen
                    pixel.green = UInt8(max(min(255, Int(round(Double(avgGreen) + intensity * Double(greenDelta)))), 0))
                } else if isBlue == true {
                    let blueDelta = Int(pixel.blue) - avgBlue
                    pixel.blue = UInt8(max(min(255, Int(round(Double(avgBlue) + intensity * Double(blueDelta)))), 0))
                } else if isTransparent == true {
                    pixel.red = UInt8(max(min(255, 255 - pixel.red), 0))
                    pixel.green = UInt8(max(min(255, 255 - pixel.green), 0))
                    pixel.blue = UInt8(max(min(255, 255 - pixel.blue), 0))
                }
                
                // contrast change
                pixel.red = UInt8(max(0, min(255, Double(pixel.red) * contrast)))
                pixel.green = UInt8(max(0, min(255, Double(pixel.green) * contrast)))
                pixel.blue = UInt8(max(0, min(255, Double(pixel.blue) * contrast)))
                
                image.pixels[index] = pixel
            }
        }
        
        return image
    }

}