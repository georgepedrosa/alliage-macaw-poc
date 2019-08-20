//
//  Multiline.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 22/07/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class Multiline: Group, CustomShape {
    var delegate: MacawViewDelegate!
    var drawing: Shape!
    var backgroundDrawing: Shape!
    var points: [Point] = []
    var anchors: Group!
    var circles: Group!
    
    //var backgroundDrawing: Shape!
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                contents = [drawing, backgroundDrawing, anchors, circles]
            } else {
                contents = [drawing, backgroundDrawing]
            }
        }
    }
    var stroke: Stroke!
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        self.stroke = stroke
        self.points.append(startPoint)
        
        let locusAnchor = Circle(cx: startPoint.x, cy: startPoint.y, r: 2)
        let locusCircle = Circle(cx: startPoint.x, cy: startPoint.y, r: 20)
        let anchor = Shape(form: locusAnchor, stroke: Stroke(fill: Color.green, width: 5))
        let circle = Shape(form: locusCircle, stroke: Stroke(fill: Color.clear, width: 5))
        setNewCircleEvent(circle: circle, index: 0)
        anchors = Group(contents: [anchor])
        circles = Group(contents: [circle])
        
        var path: PathBuilder = MoveTo(x: startPoint.x, y: startPoint.y)
        path = path.lineTo(x: startPoint.x + 1, y: startPoint.y + 1)
        
        drawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: stroke.fill,
                width: stroke.width,
                cap: .round
            )
        )
        
        backgroundDrawing  = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: Color.clear,
                width: 30,
                cap: .round
            )
        )
        
        contents = [drawing, backgroundDrawing, anchors, circles]
    
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        
    }
    
    func newPoint(point: Point) {
        points.append(point)
        
        let locusAnchor = Circle(cx: point.x, cy: point.y, r: 2)
        let anchor = Shape(form: locusAnchor, stroke: Stroke(fill: Color.green, width: 5))
        anchors.contents.append(anchor)
        
        circles.contents.removeAll()
        
        for point in points {
            let locusCircle = Circle(cx: point.x, cy: point.y, r: 20)
            
            let circle = Shape(form: locusCircle, fill: Color.clear,  stroke: Stroke(fill: Color.clear, width: 5))
            setNewCircleEvent(circle: circle, index: circles.contents.count)
            circles.contents.append(circle)
        }

        var path: PathBuilder = MoveTo(x: points[0].x, y: points[0].y)
        for point in points {
            path = path.lineTo(x: point.x, y: point.y)
        }
        
        drawing.form = path.build()
        backgroundDrawing.form = path.build()
    }
    
    func updateStroke(stroke: Stroke) {
        
    }
    
    func getCenter() -> Point? {
        return Point()
    }
    
    func setTransformEvents() {
        backgroundDrawing.onPan { (event) in
            guard let _ = event.node else { print("problem on pan")
                return
            }
            if !self.isActive { return }
            self.delegate.activateScrollView(enable: false)
            self.move(dx: event.dx, dy: event.dy)
            self.delegate.activateScrollView(enable: true)
        }
    }
    
    func setNewCircleEvent(circle: Shape, index: Int) {
        circle.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            let newPoint = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            self.points[index] = newPoint
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
    }
    
    func updateFormFromPoints() {
        anchors.contents.removeAll()
        circles.contents.removeAll()
        var path: PathBuilder = MoveTo(x: points[0].x, y: points[0].y)
        
        for i in 0..<points.count {
            path = path.lineTo(x: points[i].x, y: points[i].y)
            let locusAnchor = Circle(cx: points[i].x, cy: points[i].y, r: 2)
            let anchor = Shape(form: locusAnchor, stroke: Stroke(fill: Color.green, width: 5))
            anchors.contents.append(anchor)
            let locusCircle = Circle(cx: points[i].x, cy: points[i].y, r: 20)
            let circle = Shape(form: locusCircle, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5))
            setNewCircleEvent(circle: circle, index: i)
            circles.contents.append(circle)
        }

        drawing.form = path.build()
        backgroundDrawing.form = path.build()
    }
    
    func move(dx: Double, dy: Double) {
        for i in 0..<points.count {
            points[i] = Point(x: points[i].x + dx, y: points[i].y + dy)
        }
        updateFormFromPoints()
    }
}
