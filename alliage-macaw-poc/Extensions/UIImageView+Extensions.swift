//
//  UIImage+Extensions.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 15/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import UIKit

extension UIImageView {
//    var contentClippingRect: CGRect {
//        guard let image = image else { return bounds }
//        guard contentMode == .scaleAspectFit else { return bounds }
//        guard image.size.width > 0 && image.size.height > 0 else { return bounds }
//
//        let scale: CGFloat
//        if image.size.width > image.size.height {
//            scale = bounds.width / image.size.width
//        } else {
//            scale = bounds.height / image.size.height
//        }
//
//        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
//        let x = (bounds.width - size.width) / 2.0
//        let y = (bounds.height - size.height) / 2.0
//
//        return CGRect(x: x, y: y, width: size.width, height: size.height)
//    }
    
    func calculateRectOfImageInImageView() -> CGRect {
        let imageViewSize = self.frame.size
        let imgSize = self.image?.size
        
        guard let imageSize = imgSize else {
            return CGRect.zero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
        // Center image
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
        
        // Add imageView offset
        imageRect.origin.x += self.frame.origin.x
        imageRect.origin.y += self.frame.origin.y
        
        return imageRect
    }
}


extension UIImageView {
    func rotate(radians: CGFloat){
        image = image?.rotate(radians: radians)
    }
}

