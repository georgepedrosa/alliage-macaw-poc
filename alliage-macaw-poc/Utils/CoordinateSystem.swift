//
//  CoordinateSystem.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 15/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class CoordinateSystem {
    
    var frameWidth: Double
    var frameHeight: Double
    var imageWidth: Double
    var imageHeight: Double
    
    init(frameWidth: Double, frameHeight: Double, imageWidth: Double, imageHeight: Double) {
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
    }
    
    func getViewToImageX(x: Double) -> Double {
        let newX = (x * imageWidth)/frameWidth
        return newX
    }
    
    func getViewToImageY(y: Double) -> Double {
        let newY = (y * imageHeight)/frameHeight
        return newY
    }
    
    func getImageToViewPoint(x: Double, y: Double) -> Point {
        let newX = (x * frameWidth)/imageWidth
        let newY = (y * frameHeight)/imageHeight
        return Point(newX, newY)
    }
    
    func getImageToViewHeight(height: Double) -> Double {
        let newHeight = (height * frameHeight)/imageHeight
        return newHeight
    }
    
    func getImageToViewWidth(width: Double) -> Double {
        let newWidth = (width * frameWidth)/imageWidth
        return newWidth
    }
}

