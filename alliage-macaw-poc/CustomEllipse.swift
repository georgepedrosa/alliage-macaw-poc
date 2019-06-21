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
    
    var isActive: Bool = false {
        didSet {
            ellipse.stroke = (isActive ? Stroke(fill: Color.blue, width: 5.0) : Stroke(fill: Color.red, width: 5.0))
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        let width = lastPoint.x - startPoint.x
        let height = lastPoint.y - startPoint.y
        let ellipseLocus = Ellipse(cx: startPoint.x + width/2.0, cy: startPoint.y + height/2.0, rx: width/2.0, ry: height/2.0)
        ellipse = Shape(form: ellipseLocus, fill: Color.clear, stroke: stroke)
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

