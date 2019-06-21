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
    
    var isActive: Bool = false {
        didSet {
            line.stroke = (isActive ? Stroke(fill: Color.blue, width: 5.0) : Stroke(fill: Color.red, width: 5.0))
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        let lineLocus = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        line = Shape(form: lineLocus, fill: Color.clear, stroke: stroke)
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
        return line.bounds?.center()
    }
    
    func activateCircleAction() {
        
    }
}
