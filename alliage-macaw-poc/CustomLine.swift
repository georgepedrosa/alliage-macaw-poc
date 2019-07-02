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
    var circle: Shape!
    var circle2: Shape!
    var backgroundLine: Shape!
    
    var startPoint: Point!
    var lastPoint: Point!
    
    var isActive: Bool = false {
        didSet {
            line.stroke = (isActive ? Stroke(fill: Color.blue, width: 5.0) : Stroke(fill: Color.red, width: 5.0))
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        self.startPoint = startPoint
        self.lastPoint = lastPoint
        
        let lineLocus = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        line = Shape(form: lineLocus, fill: Color.clear, stroke: stroke)
        backgroundLine = Shape(form: lineLocus, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let circleLocus = Circle(cx: lastPoint.x, cy: lastPoint.y, r: 15)
        circle = Shape(form: circleLocus, fill: Color.blue, stroke: stroke)
        
        let circleLocus2 = Circle(cx: startPoint.x, cy: startPoint.y, r: 15)
        circle2 = Shape(form: circleLocus2, fill: Color.blue, stroke: stroke)
        
        contents = [line, backgroundLine, circle, circle2]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        line.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        backgroundLine.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        circle.form = Circle(cx: lastPoint.x, cy: lastPoint.y, r: 15)
        circle2.form = Circle(cx: startPoint.x, cy: startPoint.y, r: 15)
        //self.startPoint = startPoint
        //self.lastPoint = lastPoint
    }
    
    func updateStroke(stroke: Stroke) {
        line.stroke = stroke
        circle.stroke = stroke
        circle2.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return line.bounds?.center()
    }
    
    func activateCircleAction() {
        
    }
}
