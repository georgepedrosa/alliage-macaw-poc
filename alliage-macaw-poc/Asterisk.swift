//
//  Asterisk.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 05/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class Asterisk: Group, CustomShape {
    
    var line1: Shape!
    var line2: Shape!
    var line3: Shape!
    var line4: Shape!
    
    var backgroundLine1: Shape!
    var backgroundLine2: Shape!
    var backgroundLine3: Shape!
    var backgroundLine4: Shape!
    
    required init(startPoint: Point, lastPoint: Point) {
        super.init()

        let x1 = startPoint.x
        let y1 = startPoint.y
        
        let x2 = lastPoint.x
        let y2 = lastPoint.y
        
        let cx = (x1+x2)/2
        let cy = (y1+y2)/2
        
        let x3 = (  (x1 - cx) * cos(0.78) + (y1 - cy) * sin(0.78) ) + cx
        let y3 = ( -(x1 - cx) * sin(0.78) + (y1 - cy) * cos(0.78) ) + cy
        
        let x4 = (  (x2 - cx) * cos(0.78) + (y2 - cy) * sin(0.78) ) + cx
        let y4 = ( -(x2 - cx) * sin(0.78) + (y2 - cy) * cos(0.78) ) + cy
        
        let x5 = (  (x1 - cx) * cos(1.57) + (y1 - cy) * sin(1.57) ) + cx
        let y5 = ( -(x1 - cx) * sin(1.57) + (y1 - cy) * cos(1.57) ) + cy
        
        let x6 = (  (x2 - cx) * cos(1.57) + (y2 - cy) * sin(1.57) ) + cx
        let y6 = ( -(x2 - cx) * sin(1.57) + (y2 - cy) * cos(1.57) ) + cy
        
        let x7 = (  (x1 - cx) * cos(2.36) + (y1 - cy) * sin(2.36) ) + cx
        let y7 = ( -(x1 - cx) * sin(2.36) + (y1 - cy) * cos(2.36) ) + cy
        
        let x8 = (  (x2 - cx) * cos(2.36) + (y2 - cy) * sin(2.36) ) + cx
        let y8 = ( -(x2 - cx) * sin(2.36) + (y2 - cy) * cos(2.36) ) + cy
        
        let lineLocus1 = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        line1 = Shape(form: lineLocus1, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        backgroundLine1 = Shape(form: lineLocus1, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let lineLocus2 = Line(x3, y3, x4, y4)
        line2 = Shape(form: lineLocus2, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        backgroundLine2 = Shape(form: lineLocus2, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let lineLocus3 = Line(x5, y5, x6, y6)
        line3 = Shape(form: lineLocus3, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        backgroundLine3 = Shape(form: lineLocus3, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let lineLocus4 = Line(x7, y7, x8, y8)
        line4 = Shape(form: lineLocus4, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        backgroundLine4 = Shape(form: lineLocus4, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        contents = [line1, backgroundLine1, line2, backgroundLine2, line3, backgroundLine3, line4, backgroundLine4]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        
        let x1 = startPoint.x
        let y1 = startPoint.y
        
        let x2 = lastPoint.x
        let y2 = lastPoint.y
        
        let cx = (x1+x2)/2
        let cy = (y1+y2)/2
        
        let x3 = (  (x1 - cx) * cos(0.78) + (y1 - cy) * sin(0.78) ) + cx
        let y3 = ( -(x1 - cx) * sin(0.78) + (y1 - cy) * cos(0.78) ) + cy
        
        let x4 = (  (x2 - cx) * cos(0.78) + (y2 - cy) * sin(0.78) ) + cx
        let y4 = ( -(x2 - cx) * sin(0.78) + (y2 - cy) * cos(0.78) ) + cy
        
        let x5 = (  (x1 - cx) * cos(1.57) + (y1 - cy) * sin(1.57) ) + cx
        let y5 = ( -(x1 - cx) * sin(1.57) + (y1 - cy) * cos(1.57) ) + cy
        
        let x6 = (  (x2 - cx) * cos(1.57) + (y2 - cy) * sin(1.57) ) + cx
        let y6 = ( -(x2 - cx) * sin(1.57) + (y2 - cy) * cos(1.57) ) + cy
        
        let x7 = (  (x1 - cx) * cos(2.36) + (y1 - cy) * sin(2.36) ) + cx
        let y7 = ( -(x1 - cx) * sin(2.36) + (y1 - cy) * cos(2.36) ) + cy
        
        let x8 = (  (x2 - cx) * cos(2.36) + (y2 - cy) * sin(2.36) ) + cx
        let y8 = ( -(x2 - cx) * sin(2.36) + (y2 - cy) * cos(2.36) ) + cy
        
        let lineLocus1 = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        let lineLocus2 = Line(x3, y3, x4, y4)
        let lineLocus3 = Line(x5, y5, x6, y6)
        let lineLocus4 = Line(x7, y7, x8, y8)

        line1.form = lineLocus1
        backgroundLine1.form = lineLocus1
        line2.form = lineLocus2
        backgroundLine2.form = lineLocus2
        line3.form = lineLocus3
        backgroundLine3.form = lineLocus3
        line4.form = lineLocus4
        backgroundLine4.form = lineLocus4
    }
    
    func updateStroke(stroke: Stroke) {
        line1.stroke = stroke
        line2.stroke = stroke
        line3.stroke = stroke
        line4.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return nil
    }
    
    func activateCircleAction() {
        
    }
    
}

