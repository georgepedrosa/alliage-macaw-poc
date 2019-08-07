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
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                line.stroke = Stroke(fill: Color.blue, width: self.stroke.width)
                headLeft.stroke = Stroke(fill: Color.blue, width: self.stroke.width)
                headRight.stroke = Stroke(fill: Color.blue, width: self.stroke.width)
                contents = [line, backgroundLine, headLeft, backgroundHeadLeft, headRight, backgroundHeadRight, circle0, circle1]
            } else {
                line.stroke = self.stroke
                headLeft.stroke = self.stroke
                headRight.stroke = self.stroke
                contents = [line, backgroundLine, headLeft, backgroundHeadLeft, headRight, backgroundHeadRight]
            }
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        self.stroke = stroke
        
        p0 = startPoint
        p1 = lastPoint
        
        let x1 = startPoint.x
        let y1 = startPoint.y
        
        let x2 = lastPoint.x
        let y2 = lastPoint.y
        
        let l1 = max(distance(startPoint, lastPoint),0.005)
        var l2 = l1/10
        
        if l2 > 25 {
            l2 = 25
        }
        
        let x3 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(0.78) ) + ( (y1-y2) * (sin(0.78) ) ) ) )
        let y3 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(0.78) ) - ( (x1-x2) * (sin(0.78) ) ) ) )
        let x4 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(0.78) ) - ( (y1-y2) * (sin(0.78) ) ) ) )
        let y4 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(0.78) ) + ( (x1-x2) * (sin(0.78) ) ) ) )
        
        let lineLocus = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        let headLeftLocus = Line(x1: x2, y1: y2, x2: x3, y2: y3)
        let headRightLocus = Line(x1: x2, y1: y2, x2: x4, y2: y4)
        
        line = Shape(form: lineLocus, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: self.stroke.width))
        backgroundLine = Shape(form: lineLocus, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        headLeft = Shape(form: headLeftLocus, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: self.stroke.width))
        backgroundHeadLeft = Shape(form: headLeftLocus, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        headRight = Shape(form: headRightLocus, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: self.stroke.width))
        backgroundHeadRight = Shape(form: headRightLocus, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let circleLocus = Circle(cx: startPoint.x, cy: startPoint.y, r: 20)
        circle0 = Shape(form: circleLocus, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        
        let circleLocus2 = Circle(cx: lastPoint.x, cy: lastPoint.y, r: 20)
        circle1 = Shape(form: circleLocus2, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        
        contents = [line, backgroundLine, headLeft, backgroundHeadLeft, headRight, backgroundHeadRight, circle0, circle1]
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
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP0 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            
            self.p0 = newP0
            self.updateFormFromPoints()
        }
        
        circle1.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP1 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            
            self.p1 = newP1
            self.updateFormFromPoints()
        }
        backgroundLine.onPan { (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            if !self.isActive { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
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
        
        let x3 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(0.78) ) + ( (y1-y2) * (sin(0.78) ) ) ) )
        let y3 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(0.78) ) - ( (x1-x2) * (sin(0.78) ) ) ) )
        let x4 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(0.78) ) - ( (y1-y2) * (sin(0.78) ) ) ) )
        let y4 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(0.78) ) + ( (x1-x2) * (sin(0.78) ) ) ) )
        
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
}
