//
//  CustomArc.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 08/07/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class CustomArc: Group, CustomShape {
    
    var drawing: Shape!
    var backgroundDrawing: Shape!
    
    var circle0: Shape!
    var circle1: Shape!
    var circle2: Shape!
    
    var line1: Shape!
    var line2: Shape!
    
    var anchor0: Shape!
    var anchor1: Shape!
    var anchor2: Shape!
    
    var p0: Point!
    var p1: Point!
    var p2: Point!
    
    var delegate: MacawViewDelegate!
    
    var stroke: Stroke!
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                contents = [line1, line2, drawing, backgroundDrawing, anchor0, anchor1, anchor2, circle0, circle1, circle2]
            } else {
                contents = [drawing, backgroundDrawing]
            }
        }
    }

    init(p0: Point, p1: Point, p2: Point, delegate: MacawViewDelegate, stroke: Stroke) {
        super.init()
        
        self.delegate = delegate
        self.stroke = stroke
        
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        
        circle0 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle1 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle2 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        anchor0 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        anchor1 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        anchor2 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        line1 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.blue, width: 2.0))
        line2 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.blue, width: 2.0))

        let path: PathBuilder = MoveTo(x: p0.x, y: p0.y)
        
        drawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: stroke.fill,
                width: stroke.width,
                cap: .round
            )
        )
        
        backgroundDrawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: Color.clear,
                width: 30,
                cap: .round
            )
        )
        
        contents = [line1, line2, drawing, backgroundDrawing, anchor0, anchor1, anchor2, circle0, circle1, circle2]
        
        updateFormFromPoints()
    }
    
    func setTransformEvents() {
        self.circle0.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP0 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            self.p0 = newP0
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        self.circle1.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP1 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            self.p1 = newP1
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        self.circle2.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP2 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            self.p2 = newP2
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        self.backgroundDrawing.onPan { (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            if !self.isActive { return }
            self.delegate.activateScrollView(enable: false)
            self.move(dx: event.dx, dy: event.dy)
            self.delegate.activateScrollView(enable: true)
        }
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        
        p0 = startPoint
        p1 = Point((lastPoint.x + startPoint.x)/2, (lastPoint.y + startPoint.y)/2)
        p2 = lastPoint
        
        updateFormFromPoints()
    }
    
    func updateFormFromPoints() {
        var newPath: PathBuilder!
        
        newPath = MoveTo(x: p0.x, y: p0.y)
        
        for index in 1...100 {
            let t: Double = Double(index)/100
            let x = pow((1.0-t), 2.0)*p0.x + 2*(1.0-t)*t*p1.x + pow(t, 2.0)*p2.x
            let y = pow((1.0-t), 2.0)*p0.y + 2*(1.0-t)*t*p1.y + pow(t, 2.0)*p2.y
            
            newPath = newPath.lineTo(x: x, y: y)
        }
        
        drawing.form = newPath.build()
        backgroundDrawing.form = newPath.build()
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle2.form = Circle(cx: p2.x, cy: p2.y, r: 15)
        anchor0.form = Circle(cx: p0.x, cy: p0.y, r: 2)
        anchor1.form = Circle(cx: p1.x, cy: p1.y, r: 2)
        anchor2.form = Circle(cx: p2.x, cy: p2.y, r: 2)
        line1.form = Line(x1: p0.x, y1: p0.y, x2: p1.x, y2: p1.y)
        line2.form = Line(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y)
    }
    
    func updateStroke(stroke: Stroke) {
        drawing.stroke = stroke
    }
    
    func deleteShape() {
        contents = []
    }
    
    func redoShape() {
        contents = [drawing, backgroundDrawing]
        isActive = false
    }
    
    func getCenter() -> Point? {
        return p1
    }
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        p1 = Point(x: p1.x + dx, y: p1.y + dy)
        p2 = Point(x: p2.x + dx, y: p2.y + dy)
        updateFormFromPoints()
    }
}
