//
//  UIImage+Extensions.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 15/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import UIKit
import Accelerate

extension UIImage{
    
    func pixelData<T>() -> [T]? where T:BinaryInteger{
        guard let cgImage = self.cgImage else { return nil }
        
        let colorSpace = cgImage.colorSpace!
        let isRGB = colorSpace.model == .rgb
        let numberOfComponents = isRGB ? 4 : 1
        let dataSize = cgImage.width * cgImage.height * numberOfComponents
        var pixelData = [T](repeating: 0, count: dataSize)
        let bitsPerComponent = cgImage.bitsPerComponent
        let is16Bit = bitsPerComponent == 16
        let bitmapInfo:CGBitmapInfo = [is16Bit ? .byteOrder16Little : .byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)]
        
        let grayscaleInfo: CGBitmapInfo = is16Bit ? CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue | CGBitmapInfo.byteOrder16Little.rawValue) : CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        let context = CGContext(data: &pixelData,
                                width: cgImage.width,
                                height: cgImage.height,
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: cgImage.width * numberOfComponents * (cgImage.bitsPerComponent/8),
                                space: colorSpace,
                                bitmapInfo: isRGB ? bitmapInfo.rawValue : grayscaleInfo.rawValue)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        
        if colorSpace.model == .rgb {
            var pixelDataWithoutAlpha = [T]()
            for i in stride(from: 0, to: Int(dataSize), by: 4){
                pixelDataWithoutAlpha.append(pixelData[i])
                pixelDataWithoutAlpha.append(pixelData[i+1])
                pixelDataWithoutAlpha.append(pixelData[i+2])
            }
            return pixelDataWithoutAlpha
        } else {
            return pixelData
        }
    }
    
    func resize(to size: CGSize, aspectFit: Bool = true) -> UIImage? {
        let originalSize = self.size
        
        let widthRatio  = size.width  / originalSize.width
        let heightRatio = size.height / originalSize.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        
        if aspectFit {
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: originalSize.width * heightRatio, height: originalSize.height * heightRatio)
            } else {
                newSize = CGSize(width: originalSize.width * widthRatio,  height: originalSize.height * widthRatio)
            }
        } else {
            newSize = size
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    @discardableResult
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
