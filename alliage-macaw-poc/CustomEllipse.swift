//
//  CustomEllipse.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 07/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class CustomEllipse: Group, CustomShape {
    
    var ellipse: Shape!
    
    required init(startPoint: Point, lastPoint: Point) {
        super.init()
        
        let width = lastPoint.x - startPoint.x
        let height = lastPoint.y - startPoint.y
        let ellipseLocus = Ellipse(cx: startPoint.x + width/2.0, cy: startPoint.y + height/2.0, rx: width/2.0, ry: height/2.0)
        ellipse = Shape(form: ellipseLocus, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        contents = [ellipse]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        let width = lastPoint.x - startPoint.x
        let height = lastPoint.y - startPoint.y
        self.ellipse.form = Ellipse(cx: startPoint.x + width/2.0, cy: startPoint.y + height/2.0, rx: width/2.0, ry: height/2.0)
    }
    
    func updateStroke(stroke: Stroke) {
        ellipse.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return self.ellipse.bounds?.center()
    }
    
    func activateCircleAction() {
        
    }

}

