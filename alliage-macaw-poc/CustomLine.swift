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
    
    var radius: Double = 20
    
    var isActive: Bool = false {
        didSet {
            line.stroke = (isActive ? Stroke(fill: Color.blue, width: 5.0) : Stroke(fill: Color.red, width: 5.0))
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        self.startPoint = startPoint
        self.lastPoint = lastPoint
        
        let circleStroke = Stroke(fill: Color.clear)
        
        let lineLocus = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        line = Shape(form: lineLocus, fill: Color.clear, stroke: stroke)
        backgroundLine = Shape(form: lineLocus, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let circleLocus = Circle(cx: lastPoint.x, cy: lastPoint.y, r: radius)
        circle = Shape(form: circleLocus, fill: Color.clear, stroke: circleStroke)
        
        let circleLocus2 = Circle(cx: startPoint.x, cy: startPoint.y, r: radius)
        circle2 = Shape(form: circleLocus2, fill: Color.clear, stroke: circleStroke)
        
        contents = [line, backgroundLine, circle, circle2]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        line.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        backgroundLine.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        circle.form = Circle(cx: lastPoint.x, cy: lastPoint.y, r: radius)
        circle2.form = Circle(cx: startPoint.x, cy: startPoint.y, r: radius)
        //self.startPoint = startPoint
        //self.lastPoint = lastPoint
    }
    
    func updateStroke(stroke: Stroke) {
        line.stroke = stroke
    }
    
    func updateCircleStroke(stroke: Stroke) {
        circle.stroke = stroke
        circle2.stroke = stroke
    }
    
    func updateSize(scale: Double) {
        let circleLocus = circle.form as! Circle
        let newLocus = Circle(cx: circleLocus.cx, cy: circleLocus.cy, r: radius/scale)
        circle.form = newLocus
        
        let circle2Locus = circle2.form as! Circle
        let newLocus2 = Circle(cx: circle2Locus.cx, cy: circle2Locus.cy, r: radius/scale)
        circle2.form = newLocus2
    }
    
    func getCenter() -> Point? {
        return line.bounds?.center()
    }
    
    func activateCircleAction() {
        
    }
}
