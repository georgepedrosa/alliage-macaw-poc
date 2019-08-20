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
    var circle0: Shape!
    var circle1: Shape!
    var backgroundLine: Shape!
    
    var p0: Point!
    var p1: Point!
    
    var radius: Double = 20
    
    var stroke: Stroke!
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                line.stroke = Stroke(fill: Color.blue, width: self.stroke.width)
                contents = [line, backgroundLine, circle0, circle1]
            } else {
                line.stroke = self.stroke
                contents = [line, backgroundLine]
            }
        }
    }
    
    var delegate: MacawViewDelegate!
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        self.stroke = stroke
        self.p0 = startPoint
        self.p1 = lastPoint
        
        let circleStroke = Stroke(fill: Color.green, width: 5.0)
        
        line = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.blue, width: self.stroke.width))
        backgroundLine = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        circle0 = Shape(form: Circle(), fill: Color.clear, stroke: circleStroke)
        circle1 = Shape(form: Circle(), fill: Color.clear, stroke: circleStroke)
        contents = [line, backgroundLine, circle0, circle1]
        updateFormFromPoints()
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        p0 = startPoint
        p1 = lastPoint
        updateFormFromPoints()
    }
    
    func updateStroke(stroke: Stroke) {
        line.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return line.bounds?.center()
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
            self.move(dx: event.dx, dy: event.dy)
            self.delegate.activateScrollView(enable: true)
        }
    }
    
    func updateFormFromPoints() {
        line.form = Line(p0.x, p0.y, p1.x, p1.y)
        backgroundLine.form = Line(p0.x, p0.y, p1.x, p1.y)
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: radius)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: radius)
    }
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        p1 = Point(x: p1.x + dx, y: p1.y + dy)
        updateFormFromPoints()
    }
}
