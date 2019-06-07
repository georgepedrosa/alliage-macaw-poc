//
//  Line.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 06/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class CustomLine: Group, CustomShape {
    
    var line: Shape!
    var backgroundLine: Shape!
    
    required init(startPoint: Point, lastPoint: Point) {
        super.init()
        
        let lineLocus = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        line = Shape(form: lineLocus, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        backgroundLine = Shape(form: lineLocus, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        contents = [line, backgroundLine]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        line.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        backgroundLine.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
    }
    
    func updateStroke(stroke: Stroke) {
        line.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return nil
    }
    
    func activateCircleAction() {
        
    }
}
