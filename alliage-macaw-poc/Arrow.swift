//
//  Arrow.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 05/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

// Arrow calculations: https://math.stackexchange.com/questions/1314006/drawing-an-arrow

import UIKit
import Macaw

class Arrow: Group, CustomShape {
    
    let headAngle = Double.pi/4
    
    var delegate: MacawViewDelegate!
    var stroke: Stroke!
    
    var p0: Point!
    var p1: Point!

    var line: Shape!
    var headLeft: Shape!
    var headRight: Shape!
    var backgroundLine: Shape!
    var backgroundHeadLeft: Shape!
    var backgroundHeadRight: Shape!
    
    var circle0: Shape!
    var circle1: Shape!
    
    var anchor0: Shape!
    var anchor1: Shape!
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                contents = [line, backgroundLine, headLeft, backgroundHeadLeft, headRight, backgroundHeadRight, anchor0, anchor1, circle0, circle1]
            } else {
                contents = [line, backgroundLine, headLeft, backgroundHeadLeft, headRight, backgroundHeadRight]
            }
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        self.stroke = stroke
        
        p0 = startPoint
        p1 = lastPoint
        
        line = Shape(form: Line(), fill: Color.clear, stroke: stroke)
        backgroundLine = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        headLeft = Shape(form: Line(), fill: Color.clear, stroke: stroke)
        backgroundHeadLeft = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        headRight = Shape(form: Line(), fill: Color.clear, stroke: stroke)
        backgroundHeadRight = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        circle0 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle1 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        anchor0 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        anchor1 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        
        contents = [line, backgroundLine, headLeft, backgroundHeadLeft, headRight, backgroundHeadRight, anchor0, anchor1, circle0, circle1]
        
        updateFormFromPoints()
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        p0 = startPoint
        p1 = lastPoint
        updateFormFromPoints()
    }
    
    func setTransformEvents() {
        circle0.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            let newP0 = Point(x: loc.x, y: loc.y)
            self.p0 = newP0
            self.updateFormFromPoints()
        }
        
        circle1.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            let newP1 = Point(x: loc.x, y: loc.y)
            self.p1 = newP1
            self.updateFormFromPoints()
        }
        backgroundLine.onPan { (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            if !self.isActive { return }
            self.delegate.activateScrollView(enable: false)
            self.move(dx: event.dx, dy: event.dy)
            self.delegate.activateScrollView(enable: true)
        }
    }
    
    func updateFormFromPoints() {
        let x1 = p0.x
        let y1 = p0.y
        
        let x2 = p1.x
        let y2 = p1.y
        
        let l1 = distance(p0, p1)
        var l2 = l1/10
        
        if l2 > 25 {
            l2 = 25
        }
        
        let x3 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(headAngle) ) + ( (y1-y2) * (sin(headAngle) ) ) ) )
        let y3 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(headAngle) ) - ( (x1-x2) * (sin(headAngle) ) ) ) )
        let x4 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(headAngle) ) - ( (y1-y2) * (sin(headAngle) ) ) ) )
        let y4 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(headAngle) ) + ( (x1-x2) * (sin(headAngle) ) ) ) )
        
        let headLeftLocus = Line(x1: x2, y1: y2, x2: x3, y2: y3)
        let headRightLocus = Line(x1: x2, y1: y2, x2: x4, y2: y4)
        
        line.form = Line(p0.x, p0.y, p1.x, p1.y)
        backgroundLine.form = Line(p0.x, p0.y, p1.x, p1.y)
        headLeft.form = headLeftLocus
        backgroundHeadLeft.form = headLeftLocus
        headRight.form = headRightLocus
        backgroundHeadRight.form = headRightLocus
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 20)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 20)
        anchor0.form = Circle(cx: p0.x, cy: p0.y, r: 2)
        anchor1.form = Circle(cx: p1.x, cy: p1.y, r: 2)
    }
    
    func updateStroke(stroke: Stroke) {
        self.stroke = stroke
        line.stroke = stroke
        headLeft.stroke = stroke
        headRight.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return line.bounds?.center()
    }
    
    func distance(_ a: Point, _ b: Point) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        p1 = Point(x: p1.x + dx, y: p1.y + dy)
        updateFormFromPoints()
    }
}
