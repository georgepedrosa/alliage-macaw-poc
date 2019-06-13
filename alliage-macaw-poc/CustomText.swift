//
//  CustomText.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 10/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

protocol CustomTextDelegate {
    
    func activateKeyboard(customText: CustomText, activate: Bool)
    
}

class CustomText: Group, CustomShape {
    
    public var active: Bool = false
    public var rect: Shape!
    var textNode: Text!
    
    var isActive: Bool = false
    
    var delegate: CustomTextDelegate!
    
    required init(startPoint: Point, lastPoint: Point) {
        
    }
    
    init(text: String, startPoint: Point) {
        super.init()
        textNode = Text(text: text, fill: Color.white, place: .move(startPoint.x, startPoint.y))
        let rectLocus = Rect(x: 0, y: 0, w: textNode.bounds.w, h: textNode.bounds.h)
        rect = Shape(form: rectLocus, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0), place: .move(startPoint.x, startPoint.y))
        
//        self.onTap { (event) in
//            self.active = !self.active
//            if self.active {
//                self.rect.stroke = Stroke(fill: Color.green, width: 2.0)
//                self.delegate.activateKeyboard(customText: self, activate: true)
//                
//            } else {
//                self.rect.stroke = Stroke(fill: Color.red, width: 2.0)
//                self.delegate.activateKeyboard(customText: self, activate: false)
//            }
//        }
//        
//        self.onPan { (event) in
//            print("panned")
//        }
        
        contents = [rect, textNode]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        
    }
    
    func updateStroke(stroke: Stroke) {
        rect.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return rect.bounds?.center()
    }
    
    func activateCircleAction() {
        
    }

}
