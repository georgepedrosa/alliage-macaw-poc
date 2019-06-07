//
//  CustomRect.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 06/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class CustomRect: Group, CustomShape {
    
    var rect: Shape!
    
    required init(startPoint: Point, lastPoint: Point) {
        super.init()
        
        let width = lastPoint.x - startPoint.x
        let height = lastPoint.y - startPoint.y
        
        let rectLocus = Rect(x: startPoint.x, y: startPoint.y, w: width, h: height)
        rect = Shape(form: rectLocus, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        
        contents = [rect]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        let width = lastPoint.x - startPoint.x
        let height = lastPoint.y - startPoint.y
        self.rect.form = Rect(x: startPoint.x, y: startPoint.y, w: width, h: height)
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
