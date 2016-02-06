//
//  ImageProcessor.swift
//  Filterer
//
//  Created by Samir on 05/02/16.
//  Copyright © 2016 UofT. All rights reserved.
//

import UIKit

struct ImageProcessor {
    
    init(filters: Filter...) {
        for filter in filters {
            self.filters.append(filter)
        }
    }
    
    init(intensity: Double) {
        self.intensity = intensity
    }
    
    init() {
        
    }
    
    var filters = [Filter]()
    var intensity = 2.0
    
    let filter1 = Filter(color: "Red")
    let filter2 = Filter(color: "Green")
    let filter3 = Filter(color: "Blue")
    let filter4 = Filter(contrast: 0.75)
    let filter5 = Filter(contrast: 1.25)
    let filter6 = Filter(contrast: 1.0)
    
    
    func process(image: RGBAImage) -> RGBAImage {
        var filtered = image
        for filterer in filters {
            filtered = filterer.filter(filtered, intensity: intensity)
        }
        return filtered
    }
    
    func predefined(image: RGBAImage, filter: String, intensity: Double) -> RGBAImage {
        var filtered: RGBAImage
        switch filter {
        case "Red":
            filtered = filter1.filter(image, intensity: intensity)
        case "Green":
            filtered = filter2.filter(image, intensity: intensity)
        case "Blue":
            filtered = filter3.filter(image, intensity: intensity)
        case "darken":
            filtered = filter4.filter(image, intensity: intensity)
        case "brighten":
            filtered = filter5.filter(image, intensity: intensity)
        case "negative":
            filtered = filter6.filter(image, intensity: intensity)
        default:
            filtered = image
        }
        return filtered
    }
    
}
